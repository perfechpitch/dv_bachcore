#!/usr/bin/env python3
"""Compile the actual tb_top clock block in a tiny isolated VCS harness."""
import argparse
import json
import re
import subprocess
from pathlib import Path


def run(out):
    root = Path(__file__).resolve().parents[2]
    out = Path(out).resolve()
    out.mkdir(parents=True, exist_ok=False)
    text = (root / 'tb/tb_top.sv').read_text()
    block = text[text.index('  initial begin : configure_axi_clock'):text.index('  axi4_if #(')]
    harness = '''`timescale 1ns/1ps
module clock_unit_top;
  bit aclk;
''' + block + '''
  initial begin
    realtime first_edge, actual, expected;
    expected = 10.0;
    void'($value$plusargs("EXPECTED_PERIOD_NS=%f", expected));
    @(posedge aclk); first_edge = $realtime;
    repeat (10) @(posedge aclk);
    actual = ($realtime - first_edge) / 10.0;
    if (actual - expected > 0.0001 || expected - actual > 0.0001)
      $fatal(1, "CLOCK_UNIT wrong measured period");
    #1ps;
    $display("CLOCK_UNIT_PASS measured_period_ns=%0.6f", actual);
    $finish;
  end
endmodule
'''
    (out / 'clock_unit_top.sv').write_text(harness)
    with (out / 'clock_compile.log').open('w') as log:
        subprocess.run(['vcs', '-full64', '-sverilog', '-top', 'clock_unit_top',
                        'clock_unit_top.sv', '-o', 'clock_simv'], cwd=str(out),
                       stdout=log, stderr=subprocess.STDOUT, timeout=120, check=True)
    cases = [('default', [], 10.0), ('1GHz', ['+AXI_CLK_PERIOD_NS=1.0'], 1.0),
             ('500MHz', ['+AXI_CLK_PERIOD_NS=2.0'], 2.0)]
    results = []
    for name, args, expected in cases:
        proc = subprocess.run([str(out / 'clock_simv')] + args +
                              ['+EXPECTED_PERIOD_NS=' + str(expected)], cwd=str(out),
                              stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              universal_newlines=True, timeout=10)
        (out / (name + '.log')).write_text(proc.stdout)
        if proc.returncode or 'CLOCK_UNIT_PASS' not in proc.stdout or 'AXI_CLOCK_MEASURED' not in proc.stdout:
            raise RuntimeError(name + ' clock check failed')
        value = float(re.search(r'measured_period_ns=([0-9.]+)', proc.stdout).group(1))
        results.append({'case': name, 'measured_period_ns': value})
    for idx, arg in enumerate(['0', '-1', '0.001', '0.0001', '1junk', 'nan', '']):
        proc = subprocess.run([str(out / 'clock_simv'), '+AXI_CLK_PERIOD_NS=' + arg],
                              cwd=str(out), stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                              universal_newlines=True, timeout=10)
        (out / ('invalid_%d.log' % idx)).write_text(proc.stdout)
        if 'Fatal:' not in proc.stdout or 'CLOCK_UNIT_PASS' in proc.stdout:
            raise RuntimeError('invalid clock accepted: ' + repr(arg))
        results.append({'invalid_period': arg, 'rejected': True})
    (out / 'clock_summary.json').write_text(json.dumps(results, indent=2) + '\n')
    print(json.dumps(results, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True)
    run(parser.parse_args().out)
