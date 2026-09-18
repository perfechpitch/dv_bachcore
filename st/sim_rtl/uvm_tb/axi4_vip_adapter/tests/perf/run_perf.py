#!/usr/bin/env python3
"""Run isolated VCS payload-bandwidth tests; never regenerate a workbook."""
import argparse
import hashlib
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'scripts'))
from workbook_baseline import BASELINE_SHA


def checked_run(argv, cwd, logfile, timeout=120):
    with Path(logfile).open('w') as log:
        proc = subprocess.run([str(x) for x in argv], cwd=str(cwd), stdout=log,
                              stderr=subprocess.STDOUT, timeout=timeout)
    content = Path(logfile).read_text(errors='replace')
    diagnostic = re.search(
        r'^(?:Error[-:]|Fatal:)|^UVM_(?:ERROR|FATAL)(?!\s*:\s*0(?:\s|$))',
        content, re.MULTILINE)
    if proc.returncode or diagnostic:
        raise RuntimeError('Command failed; inspect ' + str(logfile))
    return content


def run(args):
    root = ROOT
    out = Path(args.out).resolve()
    if out.exists():
        raise ValueError('--out must be a new scratch directory: ' + str(out))
    out.mkdir(parents=True)
    workbook = root / 'docs/vip/vip_cfg.xlsx'
    before = hashlib.sha256(workbook.read_bytes()).hexdigest()
    if before != BASELINE_SHA:
        raise ValueError('Original workbook is not the required baseline')
    try:
        cfg = out / 'axi4_vip_cfg_pkg.sv'
        checked_run([sys.executable, root / 'scripts/gen_vip_cfg.py', '--cfg',
                     root / 'tests/perf/perf_profile.json', '--out', cfg],
                    out, out / 'generate.log')
        files = [cfg, root / 'tb/generated/axi4_seq_cfg_pkg.sv',
                 root / 'tb/axi4/axi4_if.sv', root / 'tb/axi4/axi4_vip_adapter_pkg.sv',
                 root / 'tb/axi4/simple_axi4_bfm_adapter.sv']
        flags = []
        if args.checker:
            files += [root / 'tb/axi4/checker/axi4_checker_pkg.sv',
                      root / 'tb/axi4/checker/axi4_protocol_monitor.sv']
            flags += ['+define+AXI_PERF_CHECKER']
        files += [root / 'tests/perf/axi4_perf_slave.sv',
                  root / 'tests/perf/axi4_perf_monitor.sv',
                  root / 'tests/perf/axi4_perf_top.sv']
        (out / 'filelist.f').write_text('\n'.join(str(f) for f in files) + '\n')
        tracked = files + [root / 'tests/perf/axi4_perf_sequence.svh',
                           root / 'tests/perf/perf_profile.json',
                           root / 'tests/perf/run_perf.py',
                           root / 'tests/perf/check_perf_vcd.py']
        # Driver/sequence include files may be introduced by upstream features.
        tracked += sorted((root / 'tb/axi4').glob('*.svh'))
        manifest = dict((str(p.relative_to(root)) if p != cfg else 'generated_config.sv',
                         hashlib.sha256(p.read_bytes()).hexdigest()) for p in tracked)
        (out / 'source_sha256.json').write_text(json.dumps(manifest, indent=2, sort_keys=True) + '\n')
        command = ['vcs', '-full64', '-sverilog', '-ntb_opts', 'uvm',
                   '-timescale=1ns/1ps', '-debug_access+all',
                   '+incdir+' + str(root / 'tests/perf'),
                   '+incdir+' + str(root / 'tb/axi4'),
                   '-top', 'axi4_perf_top', '-f', str(out / 'filelist.f'),
                   '-o', str(out / 'simv')] + flags
        (out / 'compile_command.json').write_text(json.dumps(command, indent=2) + '\n')
        checked_run(command, out, out / 'compile.log', 180)
        cases = [
            ('write_open', 'write', 1.0, 0, 0, 0),
            ('read_open', 'read', 1.0, 0, 0, 0),
            ('mixed_open', 'mixed', 1.0, 0, 0, 0),
            ('mixed_half', 'mixed', 1.0, 2, 1, 0),
            ('write_half_strobe', 'write', 1.0, 0, 0, 1),
            ('mixed_500MHz', 'mixed', 2.0, 0, 0, 0),
        ]
        results = {}
        for name, mode, period, throttle_period, throttle_open, half_strb in cases:
            case = out / name
            case.mkdir()
            log = checked_run([out / 'simv', '+PERF_MODE=' + mode,
                               '+AXI_CLK_PERIOD_NS=' + str(period),
                               '+PERF_THROTTLE_PERIOD=' + str(throttle_period),
                               '+PERF_THROTTLE_OPEN=' + str(throttle_open),
                               '+PERF_HALF_STRB=' + str(half_strb),
                               '+PERF_WARMUP=' + str(args.warmup),
                               '+PERF_CYCLES=' + str(args.cycles),
                               '+PERF_VCD=perf.vcd'], case, case / 'sim.log', 45)
            matches = re.findall(r'^PERF_RESULT (\{.*\})$', log, re.MULTILINE)
            if len(matches) != 1 or 'PERF_PASS' not in log:
                raise RuntimeError('Missing completion evidence: ' + name)
            data = json.loads(matches[0])
            (case / 'result.json').write_text(json.dumps(data, indent=2) + '\n')
            checked_run([sys.executable, root / 'tests/perf/check_perf_vcd.py',
                         case / 'perf.vcd', '--expected-json', case / 'result.json'],
                        case, case / 'wave_check.json')
            results[name] = data
            print(name + ': ' + json.dumps(data, sort_keys=True), flush=True)
        for case, metric in [('write_open', 'write_gbps'), ('read_open', 'read_gbps'),
                             ('mixed_open', 'write_gbps'), ('mixed_open', 'read_gbps')]:
            if results[case][metric] < 24.0:
                raise AssertionError(case + ' below 24 GB/s: ' + metric)
        for case in ('write_open', 'write_half_strobe'):
            if results[case]['read_bytes'] or results[case]['ar_count']:
                raise AssertionError(case + ' unexpectedly generated reads')
        if results['read_open']['write_bytes'] or results['read_open']['aw_count']:
            raise AssertionError('read_open unexpectedly generated writes')
        for metric in ('write_gbps', 'read_gbps', 'total_gbps'):
            ratio = results['mixed_half'][metric] / results['mixed_open'][metric]
            if not 0.4 <= ratio <= 0.6:
                raise AssertionError('Backpressure comparison failed: ' + metric)
            ratio = results['mixed_500MHz'][metric] / results['mixed_open'][metric]
            if abs(ratio - 0.5) > 0.01:
                raise AssertionError('Clock scaling comparison failed: ' + metric)
        ratio = results['write_half_strobe']['write_gbps'] / results['write_open']['write_gbps']
        if abs(ratio - 0.5) > 0.01:
            raise AssertionError('WSTRB byte accounting comparison failed')
        (out / 'summary.json').write_text(json.dumps(results, indent=2, sort_keys=True) + '\n')
        print('PERF_REGRESSION_PASS ' + str(out / 'summary.json'))
    finally:
        after = hashlib.sha256(workbook.read_bytes()).hexdigest()
        (out / 'workbook_sha256.txt').write_text('before=' + before + '\nafter=' + after + '\n')
        if after != before:
            raise RuntimeError('Original workbook changed during performance regression')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, help='new scratch/output directory')
    parser.add_argument('--checker', action='store_true', help='include feature05 monitor')
    parser.add_argument('--warmup', type=int, default=1024)
    parser.add_argument('--cycles', type=int, default=4096)
    run(parser.parse_args())
