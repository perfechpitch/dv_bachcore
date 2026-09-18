#!/usr/bin/env python3
"""Isolated burst regression for the feature-03 scheduler; load VCS first.

No workbook, generated source, generic filelist or Makefile is modified.
The protocol_off profile still rejects malformed ID/LAST: response matching
is mandatory scheduler safety. Former direct-channel pacing uses submit/wait.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from workbook_baseline import BASELINE_SHA


def run(args, log, timeout=180):
    with log.open('w') as stream:
        result = subprocess.run(args, cwd=str(log.parent), stdout=stream,
                                stderr=subprocess.STDOUT, timeout=timeout)
    return result.returncode, log.read_text(errors='replace')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work-dir', type=Path)
    parser.add_argument('--mode', choices=['checked', 'response_off', 'protocol_off', 'timeout_off', 'zero_timeout', 'narrow_enabled', 'strobe_disabled'], default='checked')
    parser.add_argument('--case', action='append', dest='cases')
    args = parser.parse_args()
    workbook = ROOT / 'docs/vip/vip_cfg.xlsx'
    before = hashlib.sha256(workbook.read_bytes()).hexdigest()
    if before != BASELINE_SHA:
        raise SystemExit('Workbook differs from required baseline before regression')
    work = (args.work_dir or Path(tempfile.mkdtemp(prefix='axi02_burst_'))).resolve()
    work.mkdir(parents=True, exist_ok=True)
    cfg = {
        'design_name': 'feature02_burst_test_assumptions',
        'description': '16 beats tests LEN4 encoding; business maximum remains unspecified. One transaction at a time.',
        'axi': {'data_width': 256, 'addr_width': 32, 'id_width': 8, 'len_width': 4,
                'qos_width': 0, 'max_burst_len': 16, 'default_burst_len': 1,
                'max_outstanding_reads': 1, 'max_outstanding_writes': 1,
                'read_timeout_cycles': 12, 'write_timeout_cycles': 12, 'ready_timeout_cycles': 12},
        'support': {'exclusive_access': False, 'locked_access': False,
                    'narrow_burst': False, 'unaligned_access': False,
                    'fixed_burst': False, 'incrementing_burst': True,
                    'wrapping_burst': False, 'byte_strobe': True},
        'checker': {'enable_response_checks': args.mode != 'response_off',
                    'enable_protocol_checks': args.mode != 'protocol_off',
                    'enable_timeout_checks': args.mode != 'timeout_off'}
    }
    if args.mode == 'narrow_enabled':
        cfg['support']['narrow_burst'] = True
    if args.mode == 'strobe_disabled':
        cfg['support']['byte_strobe'] = False
    if args.mode == 'zero_timeout':
        for key in ['read_timeout_cycles', 'write_timeout_cycles', 'ready_timeout_cycles']:
            cfg['axi'][key] = 0
    cfg_path = work / 'config.json'
    cfg_path.write_text(json.dumps(cfg, indent=2) + '\n')
    subprocess.run([sys.executable, str(ROOT/'scripts/gen_vip_cfg.py'), '--cfg', str(cfg_path),
                    '--out', str(work/'axi4_vip_cfg_pkg.sv')], check=True)
    sources = [work/'axi4_vip_cfg_pkg.sv', ROOT/'tb/generated/axi4_seq_cfg_pkg.sv',
               ROOT/'tb/axi4/axi4_if.sv', ROOT/'tb/axi4/axi4_vip_adapter_pkg.sv',
               ROOT/'tb/axi4/simple_axi4_bfm_adapter.sv',
               ROOT/'tests/burst/burst_test_slave.sv', ROOT/'tests/burst/burst_tb.sv']
    command = [os.environ.get('VCS', 'vcs'), '-full64', '-sverilog', '-ntb_opts', 'uvm',
               '-timescale=1ns/1ps', '+incdir+'+str(ROOT/'tb/axi4'), '-top', 'burst_tb',
               '-Mdir='+str(work/'csrc'), '-o', str(work/'simv')] + list(map(str, sources))
    code, output = run(command, work/'compile.log', 240)
    if code:
        print(output[-12000:])
        raise SystemExit('Compile failed: '+str(work/'compile.log'))
    cases = args.cases or (['positive', 'responses', 'protocol', 'illegal',
                           'timeout_aw', 'timeout_w', 'timeout_ar', 'timeout_b', 'timeout_r', 'reset', 'illegal_api']
                          if args.mode == 'checked' else
                          ['responses'] if args.mode == 'response_off' else
                          ['protocol'] if args.mode == 'protocol_off' else
                          [args.mode] if args.mode in ['narrow_enabled', 'strobe_disabled'] else ['delayed'])
    failed = []
    for case in cases:
        code, output = run([str(work/'simv'), '+CASE='+case], work/(case+'.log'), 30)
        is_fatal = case.startswith('timeout_') or case in ['reset', 'illegal_api']
        if is_fatal:
            marker = r'^EXPECTED_FATAL ' + re.escape(case) + r' id=AXI_BFM_ABORT message='
            expected_error_id = ('AXI_BFM_TIMEOUT' if case.startswith('timeout_') else
                                 'AXI_ILLEGAL' if case == 'illegal_api' else None)
            error_markers = re.findall(r'^EXPECTED_ERROR (\S+) ', output, re.M)
            ok = (len(re.findall(marker, output, re.M)) == 1 and
                  error_markers == ([expected_error_id] if expected_error_id else []) and
                  re.search(r'UVM_FATAL[^\n]*\[AXI_BFM_ABORT\]', output) is not None)
        else:
            marker = r'^BURST_TEST_PASS ' + re.escape(case) + r'$'
            ok = code == 0 and len(re.findall(marker, output, re.M)) == 1
        ok = ok and not re.search(r'TEST_CHECK_FAILED|TEST_WATCHDOG|UVM_ERROR[^\n]*\[', output)
        print(('PASS ' if ok else 'FAIL ')+args.mode+'/'+case+' '+str(work/(case+'.log')))
        if not ok:
            failed.append(case)
            print(output[-6000:])
    after = hashlib.sha256(workbook.read_bytes()).hexdigest()
    if after != before:
        raise SystemExit('Workbook changed during regression')
    print('WORKBOOK_SHA256 '+after)
    print('ARTIFACT_DIR '+str(work))
    if failed:
        raise SystemExit('Failed cases: '+', '.join(failed))


if __name__ == '__main__':
    main()
