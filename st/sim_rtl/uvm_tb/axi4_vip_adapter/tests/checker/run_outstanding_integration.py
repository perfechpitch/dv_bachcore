#!/usr/bin/env python3
"""Isolated feature 03 + 05 positive/lifecycle/clock-reset monitor integration.

Python 3.6 compatible. Load VCS before running. Original benches, profile,
driver, generated configuration, and workbook remain read-only.
"""
import argparse
import json
import os
from pathlib import Path
import re
import sys
import subprocess
import tempfile

sys.dont_write_bytecode = True
from run_burst_integration import (ROOT, sha256, replace_once,
                                   monitor_instance, run_command)
from workbook_baseline import BASELINE_SHA


CASES = {
    'positive': ('outstanding_tb', 'OUTSTANDING_REGRESSION_PASS CASE=positive'),
    'lifecycle': ('lifecycle_tb', 'LIFECYCLE_REGRESSION_PASS'),
    'clock_reset': ('clock_reset_tb', 'CLOCK_RESET_REGRESSION_PASS'),
    'progress': ('outstanding_tb', 'OUTSTANDING_REGRESSION_PASS CASE=positive'),
    'w_before_aw': ('outstanding_tb', 'OUTSTANDING_REGRESSION_PASS CASE=positive'),
}


def monitor_helpers(case):
    helpers = '''
  longint unsigned monitor_epoch_aw = 0, monitor_epoch_w = 0, monitor_epoch_b = 0;
  longint unsigned monitor_epoch_ar = 0, monitor_epoch_r = 0;
  int unsigned monitor_drains = 0, monitor_plateaus = 0;

  function automatic void monitor_snapshot_epoch();
    monitor_epoch_aw = integration_monitor.aw_count;
    monitor_epoch_w = integration_monitor.w_count;
    monitor_epoch_b = integration_monitor.b_count;
    monitor_epoch_ar = integration_monitor.ar_count;
    monitor_epoch_r = integration_monitor.r_count;
  endfunction

  // Cumulative monitor counters survive reset; slave counters start a new
  // epoch. Also covers reset_bus() calls made outside setup(), and a stopped
  // AXI clock. No accepted transfer can occur while reset remains asserted.
  always @(negedge reset_n) begin
    #1ps;
    monitor_snapshot_epoch();
  end

  function automatic void monitor_accept_epoch(input string label_text);
    integration_monitor.check_quiescent();
    if (integration_monitor.error_count() != 0)
      $fatal(1, "MONITOR_INTEGRATION_FAIL %s: unexpected checker errors=%0d",
        label_text, integration_monitor.error_count());
    if (integration_monitor.current_reads != 0 || integration_monitor.current_writes != 0)
      $fatal(1, "MONITOR_INTEGRATION_FAIL %s: outstanding requests remain", label_text);
    if (integration_monitor.aw_count - monitor_epoch_aw != slave.aw_count ||
        integration_monitor.w_count - monitor_epoch_w != slave.w_count ||
        integration_monitor.b_count - monitor_epoch_b != slave.b_count ||
        integration_monitor.ar_count - monitor_epoch_ar != slave.ar_count ||
        integration_monitor.r_count - monitor_epoch_r != slave.r_count)
      $fatal(1, "MONITOR_INTEGRATION_FAIL %s: reset-epoch handshake mismatch", label_text);
'''
    if case == 'positive':
        helpers += '''    response_enabled_witness.check_quiescent();
    if (response_enabled_witness.error_count() != response_enabled_witness.response_errors)
      $fatal(1, "MONITOR_INTEGRATION_FAIL %s: witness errors outside response category", label_text);
'''
    helpers += '''    monitor_drains++;
    $display("MONITOR_DRAIN %s epochAW=%0d epochW=%0d epochB=%0d epochAR=%0d epochR=%0d errors=%0d",
      label_text, integration_monitor.aw_count - monitor_epoch_aw,
      integration_monitor.w_count - monitor_epoch_w, integration_monitor.b_count - monitor_epoch_b,
      integration_monitor.ar_count - monitor_epoch_ar, integration_monitor.r_count - monitor_epoch_r,
      integration_monitor.error_count());
  endfunction

  function automatic void monitor_finish();
    monitor_accept_epoch("FINAL");
    if (integration_monitor.aw_count == 0 || integration_monitor.w_count == 0 ||
        integration_monitor.b_count == 0 || integration_monitor.ar_count == 0 ||
        integration_monitor.r_count == 0 || integration_monitor.transaction_samples == 0 ||
        integration_monitor.protocol_samples == 0)
      $fatal(1, "MONITOR_INTEGRATION_FAIL: missing handshake/coverage evidence");
'''
    if case == 'positive':
        helpers += '''    if (integration_monitor.max_reads_seen != 128 ||
        integration_monitor.max_writes_seen != 128 || integration_monitor.max_total_seen != 128 ||
        integration_monitor.depth_hits[3] == 0)
      $fatal(1, "MONITOR_INTEGRATION_FAIL: missing exact 128 physical outstanding evidence");
    if (response_enabled_witness.response_errors == 0 ||
        integration_monitor.response_hits[2] == 0 || integration_monitor.response_hits[3] == 0)
      $fatal(1, "MONITOR_INTEGRATION_FAIL: missing expected SLVERR/DECERR response evidence");
    $display("MONITOR_RESPONSE_SWITCH_PASS response_off_errors=%0d response_on_errors=%0d SLVERR=%0d DECERR=%0d",
      integration_monitor.response_errors, response_enabled_witness.response_errors,
      integration_monitor.response_hits[2], integration_monitor.response_hits[3]);
    $display("MONITOR_DEPTH_PASS maxR=%0d maxW=%0d maxTotal=%0d depth128=%0d",
      integration_monitor.max_reads_seen, integration_monitor.max_writes_seen,
      integration_monitor.max_total_seen, integration_monitor.depth_hits[3]);
'''
    if case == 'progress':
        helpers += '''    if (integration_monitor.aw_count != 12 || integration_monitor.w_count != 192 ||
        integration_monitor.b_count != 12 || integration_monitor.ar_count != 12 ||
        integration_monitor.r_count != 192)
      $fatal(1, "MONITOR_INTEGRATION_FAIL: progressing traffic handshake counts differ");
'''
    if case == 'w_before_aw':
        helpers = replace_once(helpers,
            'integration_monitor.b_count == 0 || integration_monitor.ar_count == 0 ||\n'
            '        integration_monitor.r_count == 0 || integration_monitor.transaction_samples == 0 ||',
            'integration_monitor.b_count == 0 || integration_monitor.transaction_samples == 0 ||',
            'write-only final acceptance')
        helpers += '''    if (integration_monitor.aw_count != 8 || integration_monitor.w_count != 32 ||
        integration_monitor.b_count != 8 || integration_monitor.ar_count != 0 ||
        integration_monitor.r_count != 0)
      $fatal(1, "MONITOR_INTEGRATION_FAIL: W-before-AW handshake counts differ");
'''
    helpers += '''    $display("MONITOR_OUTSTANDING_PASS CASE=CASE_TOKEN errors=%0d AW=%0d W=%0d B=%0d AR=%0d R=%0d drains=%0d plateaus=%0d",
      integration_monitor.error_count(), integration_monitor.aw_count, integration_monitor.w_count,
      integration_monitor.b_count, integration_monitor.ar_count, integration_monitor.r_count,
      monitor_drains, monitor_plateaus);
  endfunction

  // run_test() terminates the lifecycle simulation inside UVM; final functions
  // also execute there. The runner rejects Fatal even if VCS exits status zero.
  final begin
    monitor_finish();
  end
'''.replace('CASE_TOKEN', case)
    return helpers


def instrument(source, case):
    short_budget = case in ('progress', 'w_before_aw')
    instances = monitor_instance('integration_monitor', 4 if short_budget else 10000,
                                 response_override=0 if case == 'positive' else None)
    if short_budget:
        instances = replace_once(instances, '.READY_TIMEOUT_CYCLES(4)',
                                 '.READY_TIMEOUT_CYCLES({})'.format(16 if case == 'progress' else 40),
                                 'short-budget READY timeout parameter')
        anchor = '''      depth_cases(); independent_aw_w_case(); concurrent_callers_case();
      legacy_case(); error_response_case(); same_id_case(); progressing_timeout_case();
      submit_snapshot_case(); reset_case(); reset_midburst_case(); total_one_fairness_case();'''
        source = replace_once(source, anchor,
                              '      progressing_timeout_case();' if case == 'progress' else
                              '      independent_aw_w_case();',
                              'positive execution block for isolated progressing traffic')
        if case == 'w_before_aw':
            anchor = '    slave.awready_requires_wvalid = 1;'
            source = replace_once(source, anchor,
                                  anchor + '\n    adapter.configure_timeouts(4, 4, 40);',
                                  'W-before-AW directed timeout override')
    if case == 'positive':
        instances += monitor_instance('response_enabled_witness', 10000,
                                      response_override=1, fatal=False)
    anchor = '    .DATA_WIDTH(AXI_DATA_WIDTH), .ID_WIDTH(AXI_ID_WIDTH)) slave(axi);'
    source = replace_once(source, anchor, anchor + '\n' + instances + monitor_helpers(case),
                          'controlled slave declaration injection anchor')
    if case == 'positive':
        anchor = '    slave.report({label_text, "_HELD"});'
        plateau = '''    if (integration_monitor.current_reads != slave.live_reads ||
        integration_monitor.current_writes != slave.live_writes ||
        integration_monitor.current_reads + integration_monitor.current_writes != target)
      $fatal(1, "MONITOR_INTEGRATION_FAIL %s: physical outstanding plateau mismatch", label_text);
    if (integration_monitor.current_reads > slave.read_limit ||
        integration_monitor.current_writes > slave.write_limit ||
        integration_monitor.current_reads + integration_monitor.current_writes > slave.total_limit)
      $fatal(1, "MONITOR_INTEGRATION_FAIL %s: dynamic outstanding cap exceeded", label_text);
    monitor_plateaus++;
    $display("MONITOR_PLATEAU %s R=%0d W=%0d total=%0d caps=%0d/%0d/%0d",
      label_text, integration_monitor.current_reads, integration_monitor.current_writes, target,
      slave.read_limit, slave.write_limit, slave.total_limit);
'''
        source = replace_once(source, anchor, plateau + anchor, 'plateau report anchor')
    if case in ('positive', 'progress', 'w_before_aw'):
        anchor = '    slave.report(label_text);'
        source = replace_once(source, anchor, '    monitor_accept_epoch(label_text);\n' + anchor,
                              'drain report anchor')
    return source


def validate_output(output, case):
    if CASES[case][1] not in output:
        return False
    match = re.search(r'^MONITOR_OUTSTANDING_PASS CASE=' + case +
                      r' errors=0 AW=(\d+) W=(\d+) B=(\d+) AR=(\d+) R=(\d+) '
                      r'drains=(\d+) plateaus=(\d+)$', output, re.M)
    required = (0, 1, 2, 5) if case == 'w_before_aw' else range(6)
    if match is None or not all(int(match.group(index + 1)) > 0 for index in required):
        return False
    if re.search(r'Fatal:|Error-|MONITOR_INTEGRATION_FAIL|AXI_CHECK\[|'
                 r'UVM_(?:ERROR|FATAL)\s*:\s*[1-9]', output):
        return False
    if case == 'progress' and list(map(int, match.groups()[:5])) != [12, 192, 12, 12, 192]:
        return False
    if case == 'w_before_aw' and list(map(int, match.groups()[:5])) != [8, 32, 8, 0, 0]:
        return False
    if case == 'positive':
        expected = {'READ128': 128, 'WRITE128': 128, 'MIXED128': 128,
                    'ASYMMETRIC_READ3': 3, 'ASYMMETRIC_WRITE5': 5, 'ASYMMETRIC_TOTAL7': 7,
                    'SAME_ID_FIFO': 12, 'RESET_PENDING': 3}
        for label, target in expected.items():
            pattern = (r'^MONITOR_PLATEAU ' + label + r' R=(\d+) W=(\d+) total=' + str(target) +
                       r' caps=(\d+)/(\d+)/(\d+)$')
            hit = re.search(pattern, output, re.M)
            if hit is None:
                return False
            rd, wr, rcap, wcap, tcap = map(int, hit.groups())
            if rd + wr != target or rd > rcap or wr > wcap or target > tcap:
                return False
        if not re.search(r'^MONITOR_DEPTH_PASS maxR=128 maxW=128 maxTotal=128 depth128=[1-9][0-9]*$',
                         output, re.M):
            return False
        if not re.search(r'^MONITOR_RESPONSE_SWITCH_PASS response_off_errors=0 '
                         r'response_on_errors=[1-9][0-9]* SLVERR=[1-9][0-9]* DECERR=[1-9][0-9]*$',
                         output, re.M):
            return False
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work-dir', type=Path, help='New or empty artifact directory')
    parser.add_argument('--case', choices=list(CASES), action='append', dest='cases')
    parser.add_argument('--prepare-only', action='store_true')
    args = parser.parse_args()
    cases = args.cases or list(CASES)
    if len(cases) != len(set(cases)):
        parser.error('--case values must be unique')
    inputs = [ROOT/'docs/vip/vip_cfg.xlsx', ROOT/'Makefile', ROOT/'filelist.f',
              ROOT/'scripts/gen_vip_cfg.py', ROOT/'tb/generated/axi4_vip_cfg_pkg.sv',
              ROOT/'tb/generated/axi4_seq_cfg_pkg.sv', ROOT/'tb/axi4/axi4_if.sv',
              ROOT/'tb/axi4/axi4_vip_adapter_pkg.sv', ROOT/'tb/axi4/simple_axi4_bfm_adapter.sv',
              ROOT/'tb/axi4/checker/axi4_checker_pkg.sv', ROOT/'tb/axi4/checker/axi4_protocol_monitor.sv',
              ROOT/'tests/checker/run_burst_integration.py']
    inputs += sorted((ROOT/'tests/outstanding').glob('*'))
    inputs = [path for path in inputs if path.is_file()]
    snapshots = dict((str(path), sha256(path)) for path in inputs)
    workbook = ROOT/'docs/vip/vip_cfg.xlsx'
    if snapshots[str(workbook)] != BASELINE_SHA:
        raise RuntimeError('Workbook differs from required baseline before integration')
    profile = json.loads((ROOT/'tests/outstanding/profile.json').read_text())
    if [profile['axi'][key] for key in ('max_outstanding_reads', 'max_outstanding_writes',
                                       'max_outstanding_total')] != [128, 128, 128]:
        raise RuntimeError('Upstream profile no longer declares the required 128/128/128 test limits')
    if [profile['axi'][key] for key in ('read_timeout_cycles', 'write_timeout_cycles',
                                       'ready_timeout_cycles')] != [10000, 10000, 10000]:
        raise RuntimeError('Upstream profile timeout budget changed from 10000')
    if args.work_dir:
        work = args.work_dir.resolve()
        if work.exists() and any(work.iterdir()):
            raise RuntimeError('Artifact directory is not empty: ' + str(work))
        work.mkdir(parents=True, exist_ok=True)
    else:
        work = Path(tempfile.mkdtemp(prefix='axi05_outstanding_integration_')).resolve()
    print('ARTIFACT_DIR ' + str(work))
    manifest = {
        'cases': cases, 'source_sha256': snapshots, 'results': {},
        'monitor_static_limits': {'reads': 128, 'writes': 128, 'total': 128},
        'profile_timeout_cycles': 10000,
        'dynamic_limit_verification': 'Original slave/driver checks plus independent monitor checks at each held plateau',
        'positive_response_scope': 'Original deliberate SLVERR/DECERR unchanged; main response checker off, response-on witness enabled',
        'progress_scope': 'Only original progressing_timeout_case; all checks enabled, monitor and driver READ/WRITE=4 READY=16',
        'w_before_aw_scope': 'Only original independent_aw_w_case with driver and monitor READ/WRITE=4 READY=40; original 20-cycle blocked AW remains',
    }
    try:
        for case in cases:
            top = CASES[case][0]
            case_dir = work/case
            case_dir.mkdir()
            cfg_path = case_dir/'config.json'
            cfg_path.write_text(json.dumps(profile, indent=2) + '\n')
            original = (ROOT/'tests/outstanding'/(top+'.sv')).read_text()
            bench = case_dir/(top+'.sv')
            bench.write_text(instrument(original, case))
            code, output = run_command(
                [sys.executable, str(ROOT/'scripts/gen_vip_cfg.py'), '--cfg', str(cfg_path),
                 '--out', str(case_dir/'axi4_vip_cfg_pkg.sv')], case_dir/'config.log', 30)
            if code:
                raise RuntimeError('Configuration generation failed: ' + output[-4000:])
            sources = [case_dir/'axi4_vip_cfg_pkg.sv', ROOT/'tb/generated/axi4_seq_cfg_pkg.sv',
                       ROOT/'tb/axi4/axi4_if.sv', ROOT/'tb/axi4/axi4_vip_adapter_pkg.sv',
                       ROOT/'tb/axi4/simple_axi4_bfm_adapter.sv',
                       ROOT/'tb/axi4/checker/axi4_checker_pkg.sv',
                       ROOT/'tb/axi4/checker/axi4_protocol_monitor.sv',
                       ROOT/'tests/outstanding/controlled_slave.sv', bench]
            command = [os.environ.get('VCS', 'vcs'), '-full64', '-sverilog', '-ntb_opts', 'uvm-1.2',
                       '-timescale=1ns/1ps', '+incdir+'+str(ROOT/'tb/axi4'), '-top', top,
                       '-Mdir='+str(case_dir/'csrc'), '-o', str(case_dir/'simv')] + list(map(str, sources))
            manifest['results'][case] = {'top': top, 'compile_command': command, 'status': 'prepared'}
            manifest['results'][case]['monitor_timeout_cycles'] = (
                {'read': 4, 'write': 4, 'ready': 16} if case == 'progress' else
                {'read': 4, 'write': 4, 'ready': 40} if case == 'w_before_aw' else
                {'read': 10000, 'write': 10000, 'ready': 10000})
            if args.prepare_only:
                print('PREPARED ' + case)
                continue
            code, output = run_command(command, case_dir/'compile.log', 240)
            if code or 'Error-' in output or not os.access(str(case_dir/'simv'), os.X_OK):
                raise RuntimeError('Compile failed: {}\n{}'.format(case_dir/'compile.log', output[-6000:]))
            command = [str(case_dir/'simv')]
            if case in ('positive', 'progress', 'w_before_aw'):
                command.append('+CASE=positive')
            code, output = run_command(command, case_dir/'sim.log', 90)
            ok = code == 0 and validate_output(output, case)
            manifest['results'][case]['status'] = 'pass' if ok else 'fail'
            print(('PASS ' if ok else 'FAIL ') + case + ' ' + str(case_dir/'sim.log'))
            if not ok:
                raise RuntimeError('Integration failed: {}\n{}'.format(case_dir/'sim.log', output[-10000:]))
        print('MONITOR_OUTSTANDING_PREPARED' if args.prepare_only else 'MONITOR_OUTSTANDING_SUITE_PASS')
    finally:
        changed = [path for path, digest in snapshots.items() if sha256(Path(path)) != digest]
        manifest['source_files_unchanged'] = not changed
        (work/'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
        if changed:
            raise RuntimeError('Protected source/configuration changed: ' + ', '.join(changed))
        print('WORKBOOK_SHA256 ' + sha256(workbook))
        print('UPSTREAM_SOURCE_HASHES_UNCHANGED')


if __name__ == '__main__':
    try:
        main()
    except (RuntimeError, OSError, subprocess.TimeoutExpired) as error:
        raise SystemExit('ERROR: ' + str(error))
