#!/usr/bin/env python3
"""Check SV measurement counters against known traffic and the actual VCD."""
import argparse
import json
import sys
from pathlib import Path
from run_perf import checked_run


def run(out):
    root = Path(__file__).resolve().parents[2]
    out = Path(out).resolve()
    out.mkdir(parents=True, exist_ok=False)
    files = [root / 'tb/axi4/axi4_if.sv', root / 'tests/perf/axi4_perf_monitor.sv',
             root / 'tests/perf/monitor_unit_top.sv']
    checked_run(['vcs', '-full64', '-sverilog', '-debug_access+all',
                 '-timescale=1ns/1ps', '-top', 'monitor_unit_top', '-o', out / 'simv'] + files,
                out, out / 'compile.log')
    log = checked_run([out / 'simv'], out, out / 'sim.log', 15)
    if 'MONITOR_UNIT_PASS' not in log:
        raise RuntimeError('Missing monitor unit success marker')
    expected = dict(period_ns=1.0, elapsed_ns=10.0, cycles=10, write_bytes=48,
                    read_bytes=64, aw_count=1, ar_count=1, b_count=1, rlast_count=1,
                    w_beats=2, r_beats=2, w_stalls=2, r_stalls=0,
                    write_gbps=4.8, read_gbps=6.4, total_gbps=11.2)
    (out / 'expected.json').write_text(json.dumps(expected, indent=2) + '\n')
    result = checked_run([sys.executable, root / 'tests/perf/check_perf_vcd.py',
                          out / 'monitor_unit.vcd', '--top', 'monitor_unit_top',
                          '--interface', 'bus', '--expected-json', out / 'expected.json'],
                         out, out / 'wave_check.json')
    print(result)
    print('MONITOR_REGRESSION_PASS measurement self-check; not VIP performance')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True)
    run(parser.parse_args().out)
