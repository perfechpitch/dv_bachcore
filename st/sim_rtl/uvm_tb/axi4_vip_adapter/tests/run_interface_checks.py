#!/usr/bin/env python3
"""Run VCS connection tests in a new output directory; never invoke workbook make targets."""
import argparse
import copy
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts'))
from gen_vip_cfg import generate


def run(command, cwd, log, seconds):
    with log.open('w') as stream:
        subprocess.run(command, cwd=str(cwd), stdout=stream, stderr=subprocess.STDOUT,
                       timeout=seconds, check=True)
    text = log.read_text()
    if re.search(r'UVM_(?:ERROR|FATAL)\s*:\s*[1-9]|^UVM_(?:ERROR|FATAL)[ \t]+[^ \t:]|^Error:', text, re.MULTILINE) or 'Fatal:' in text or 'Error-[' in text or 'AXI_CHECKER_FAILED' in text:
        raise RuntimeError('Simulator error in ' + str(log))
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work-dir', required=True, type=Path, help='Must not already exist')
    parser.add_argument('--vcs', default='vcs')
    args = parser.parse_args()
    work = args.work_dir.resolve()
    work.mkdir(parents=True, exist_ok=False)
    default = json.loads((ROOT / 'tb/generated/axi4_vip_cfg.json').read_text())
    target = json.loads((ROOT / 'tests/configs/scp_bach_ctrl_m0.json').read_text())
    sideband = copy.deepcopy(target)
    sideband['axi'].update(qos_width=4, region_width=4, awuser_width=65,
                           aruser_width=33, wuser_width=64, ruser_width=17, buser_width=9,
                           default_id=0xA5, default_qos=0xD, default_region=0xE,
                           default_cache=0xA, default_prot=5, default_awuser='0x10000000000000001',
                           default_aruser='0x100000001', default_wuser='0x8000000000000001')
    base_sources = ['tb/generated/axi4_seq_cfg_pkg.sv', 'tb/axi4/axi4_if.sv',
                    'tb/axi4/axi4_vip_adapter_pkg.sv', 'tb/axi4/simple_axi4_bfm_adapter.sv',
                    'tests/axi4_interface_check.sv']
    for name, cfg in [('default', default), ('target', target), ('sideband', sideband)]:
        case = work / name
        case.mkdir()
        pkg = case / 'axi4_vip_cfg_pkg.sv'
        pkg.write_text('\n'.join(generate(cfg)))
        cmd = [args.vcs, '-full64', '-sverilog', '-ntb_opts', 'uvm', '-timescale=1ns/1ps',
               '+incdir+' + str(ROOT / 'tb/axi4'),
               '-top', 'axi4_interface_check', str(pkg)]
        cmd += [str(ROOT / f) for f in base_sources]
        cmd += ['-o', str(case / 'simv'), '-Mdir=' + str(case / 'csrc')]
        run(cmd, case, case / 'compile.log', 180)
        result = run([str(case / 'simv')], case, case / 'sim.log', 30)
        if 'INTERFACE_CHECK_PASS' not in result:
            raise RuntimeError('Missing PASS in ' + str(case))
        print(next(line for line in result.splitlines() if 'INTERFACE_CHECK_PASS' in line), flush=True)
    # Compile and execute the unchanged default demo sequences and actual tb_top.
    case = work / 'default_demo'
    case.mkdir()
    sources = (ROOT / 'tb/generated/axi4_vip_filelist.f').read_text().splitlines()
    resolved = []
    for line in sources:
        if not line or line.startswith('#'):
            continue
        if line.startswith('+incdir+'):
            resolved.append('+incdir+' + str(ROOT / line[len('+incdir+'):]))
        else:
            resolved.append(str(ROOT / line))
    cmd = [args.vcs, '-full64', '-sverilog', '-ntb_opts', 'uvm', '-timescale=1ns/1ps',
           '+define+USE_SIMPLE_AXI4_BFM', '-top', 'tb_top'] + resolved
    cmd += ['-o', str(case / 'simv'), '-Mdir=' + str(case / 'csrc')]
    run(cmd, case, case / 'compile.log', 180)
    result = run([str(case / 'simv'), '+UVM_TESTNAME=axi4_doc_test', '+SEQ=axi4_user_two_regs', '+IRQ_EN=0'],
                 case, case / 'sim.log', 30)
    if not re.search(r'UVM_ERROR\s*:\s*0', result) or not re.search(r'UVM_FATAL\s*:\s*0', result):
        raise RuntimeError('Missing clean UVM summary in default demo')
    if 'AXI_CHECKER_PASS' not in result:
        raise RuntimeError('Missing integrated checker completion in default demo')
    print('DEFAULT_DEMO_PASS axi4_user_two_regs UVM_ERROR=0 UVM_FATAL=0', flush=True)
    print('Logs: ' + str(work))


if __name__ == '__main__':
    main()
