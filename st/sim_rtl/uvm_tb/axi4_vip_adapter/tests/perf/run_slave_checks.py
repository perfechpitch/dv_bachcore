#!/usr/bin/env python3
"""Self-check the controlled performance slave with VCS (Python >= 3.6).

Use after loading the VCS environment, for example on xingan-login:
  eval "$(/fastone/softwares/modules/bin/modulecmd sh load vcs/S-2021.09-SP2)"
  python3 tests/perf/run_slave_checks.py --out /tmp/perf-slave-unique-run

The output directory must not already exist. No generated project files or
workbooks are touched. This direct-signal unit test validates the test endpoint
only; its passing marker and handshake counts are NOT VIP bandwidth results.
"""
import argparse
import json
import re
import subprocess
from pathlib import Path


def run(out, vcs):
    root = Path(__file__).resolve().parents[2]
    out = Path(out).resolve()
    out.mkdir(parents=True, exist_ok=False)
    sources = [root / 'tb/axi4/axi4_if.sv',
               root / 'tests/perf/axi4_perf_slave.sv',
               root / 'tests/perf/slave_unit_top.sv']
    compile_args = [vcs, '-full64', '-sverilog', '-timescale=1ns/1ps',
                    '-top', 'slave_unit_top', '-o', 'slave_simv']
    compile_args.extend(str(path) for path in sources)
    (out / 'compile_command.json').write_text(json.dumps(compile_args, indent=2) + '\n')
    with (out / 'compile.log').open('w') as log:
        subprocess.run(compile_args, cwd=str(out), stdout=log,
                       stderr=subprocess.STDOUT, timeout=120, check=True)

    cases = [('open', []), ('stress', ['+STRESS'])]
    results = []
    for name, args in cases:
        proc = subprocess.run([str(out / 'slave_simv')] + args, cwd=str(out),
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              universal_newlines=True, timeout=30)
        (out / (name + '.log')).write_text(proc.stdout)
        match = re.search(r'^PERF_SLAVE_UNIT_PASS (.+)$', proc.stdout, re.MULTILINE)
        if proc.returncode or not match or 'Fatal:' in proc.stdout or 'Error-' in proc.stdout:
            raise RuntimeError('slave unit case failed: ' + name + '; see ' + str(out))
        fields = dict(re.findall(r'(\w+)=([0-9.]+)', match.group(1)))
        if fields.get('vip_api_used') != '0':
            raise RuntimeError('invalid slave unit marker: ' + match.group(0))
        results.append({'case': name, 'measurements': fields})
    report = {
        'purpose': 'controlled-slave self-check; not VIP bandwidth validation',
        'vip_api_used': False,
        'results': results,
    }
    (out / 'slave_summary.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, help='new directory for VCS outputs and logs')
    parser.add_argument('--vcs', default='vcs', help='VCS executable (default: vcs from PATH)')
    args = parser.parse_args()
    run(args.out, args.vcs)
