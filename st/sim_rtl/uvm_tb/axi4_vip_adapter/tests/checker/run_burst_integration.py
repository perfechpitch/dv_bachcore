#!/usr/bin/env python3
"""Feature 02 + 05 integration, using copied benches and isolated configuration.

Python 3.6 compatible. Load VCS before running. Default modes are legal
positive/narrow_enabled/strobe_disabled. Optional response_off replaces only
the original test's X response sample with EXOKAY in the temporary bench;
it verifies known error-response suppression without disabling X checking.
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
DEFAULT_MODES = ['positive', 'narrow_enabled', 'strobe_disabled']
MODE_CASE = dict((name, name) for name in DEFAULT_MODES)
MODE_CASE['response_off'] = 'responses'
MODE_CASE['timeout_off'] = 'delayed'
MODE_CASE['zero_timeout'] = 'delayed'


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def replace_once(source, anchor, replacement, description):
    if source.count(anchor) != 1:
        raise RuntimeError('Upstream bench changed: expected exactly one ' + description)
    return source.replace(anchor, replacement, 1)


def config_for(mode):
    return {
        'design_name': 'feature02_05_isolated_monitor_integration',
        'description': ('Test assumption: DATA256/ADDR32/ID8/LEN4, 16 beats maximum, '
                        'blocking single-transaction API at 1GHz. The requirements '
                        'do not establish the business burst maximum or 128 limit scope.'),
        'axi': {
            'data_width': 256, 'addr_width': 32, 'id_width': 8, 'len_width': 4,
            'qos_width': 0, 'max_burst_len': 16, 'default_burst_len': 1,
            'max_outstanding_reads': 1, 'max_outstanding_writes': 1,
            'max_outstanding_total': 2,
            # These remain feature-02's per-stage driver budgets.
            'read_timeout_cycles': 0 if mode == 'zero_timeout' else 12,
            'write_timeout_cycles': 0 if mode == 'zero_timeout' else 12,
            'ready_timeout_cycles': 0 if mode == 'zero_timeout' else 12,
        },
        'support': {
            'exclusive_access': False, 'locked_access': False,
            'narrow_burst': mode == 'narrow_enabled', 'unaligned_access': False,
            'fixed_burst': False, 'incrementing_burst': True,
            'wrapping_burst': False, 'byte_strobe': mode != 'strobe_disabled',
        },
        'checker': {
            'enable_protocol_checks': True, 'enable_x_checks': True,
            'enable_alignment_checks': True, 'enable_strobe_checks': True,
            'enable_response_checks': mode != 'response_off',
            'enable_timeout_checks': mode != 'timeout_off',
        },
        'coverage': {
            'enable_coverage': True, 'enable_transaction_coverage': True,
            'enable_protocol_coverage': True, 'enable_error_coverage': True,
        },
    }


def monitor_instance(name, timeout, response_override=None, fatal=True, timeout_override=None):
    parameters = [
        ('ADDR_WIDTH', 'AXI_ADDR_WIDTH'), ('DATA_WIDTH', 'AXI_DATA_WIDTH'),
        ('ID_WIDTH', 'AXI_ID_WIDTH'), ('LEN_WIDTH', 'AXI_LEN_WIDTH'),
        ('MAX_BURST_BEATS', 'AXI_MAX_BURST_LEN'),
        ('MAX_OUTSTANDING_READS', 'AXI_MAX_OUTSTANDING_READS'),
        ('MAX_OUTSTANDING_WRITES', 'AXI_MAX_OUTSTANDING_WRITES'),
        ('MAX_OUTSTANDING_TOTAL', 'AXI_MAX_OUTSTANDING_TOTAL'),
    ]
    for group in ['PROTOCOL', 'X', 'ALIGNMENT', 'STROBE', 'RESPONSE', 'TIMEOUT']:
        value = 'axi4_vip_cfg_pkg::VIP_ENABLE_' + group + '_CHECKS'
        if group == 'RESPONSE' and response_override is not None:
            value = str(response_override)
        if group == 'TIMEOUT' and timeout_override is not None:
            value = str(timeout_override)
        parameters.append(('ENABLE_' + group + '_CHECKS', value))
    for group in ['INCREMENTING_BURST', 'FIXED_BURST', 'WRAPPING_BURST',
                  'EXCLUSIVE_ACCESS', 'LOCKED_ACCESS', 'NARROW_BURST',
                  'UNALIGNED_ACCESS', 'BYTE_STROBE']:
        parameters.append(('SUPPORT_' + group, 'axi4_vip_cfg_pkg::VIP_SUPPORT_' + group))
    parameters += [
        ('READ_TIMEOUT_CYCLES', str(timeout)), ('WRITE_TIMEOUT_CYCLES', str(timeout)),
        ('READY_TIMEOUT_CYCLES', str(timeout)), ('REQUIRE_ALIGNED_ACCESS', '0'),
        ('ALLOW_NARROW_SINGLE', '1'), ('ENFORCE_TRAFFIC_POLICY', '1'),
        ('ENABLE_COVERAGE', '1'), ('ENABLE_TRANSACTION_COVERAGE', '1'),
        ('ENABLE_PROTOCOL_COVERAGE', '1'), ('ENABLE_ERROR_COVERAGE', '1'),
        ('REPORT_ERRORS', '1' if fatal else '0'), ('FATAL_ON_ERROR', '1' if fatal else '0'),
    ]
    text = ',\n'.join('    .{}({})'.format(key, value) for key, value in parameters)
    return '  axi4_protocol_monitor #(\n' + text + '\n  ) ' + name + '(axi);\n'


def instrument(source, mode, timeout):
    budget = 0 if mode == 'zero_timeout' else 4 if mode == 'timeout_off' else timeout
    monitor = monitor_instance('integration_monitor', budget)
    if mode in ('timeout_off', 'zero_timeout'):
        monitor += monitor_instance('timeout_enabled_witness', 4, fatal=False, timeout_override=1)
    if mode == 'response_off':
        # Keep X checks enabled. This is explicitly a known-response variant,
        # not a claim that the original X-bearing responses test passed.
        source = replace_once(
            source,
            "logic [1:0] codes[3] = '{2'b10,2'b11,2'bx1};",
            "logic [1:0] codes[3] = '{2'b10,2'b11,2'b01};",
            'response-code array for the known-response variant')
        monitor += monitor_instance('response_enabled_witness', timeout,
                                    response_override=1, fatal=False)
    source = replace_once(source, '  simple_axi4_bfm_adapter adapter;',
                          monitor + '\n  simple_axi4_bfm_adapter adapter;',
                          'adapter declaration injection anchor')
    acceptance = '''    integration_monitor.check_quiescent();
    require(integration_monitor.error_count() == 0,
            "Independent monitor reported an error");
    require(integration_monitor.aw_count > 0 && integration_monitor.w_count > 0 &&
            integration_monitor.b_count > 0 && integration_monitor.ar_count > 0 &&
            integration_monitor.r_count > 0, "Independent monitor saw no traffic");
    require(integration_monitor.aw_count == slave.aw_count &&
            integration_monitor.w_count == slave.w_count &&
            integration_monitor.b_count == slave.b_count &&
            integration_monitor.ar_count == slave.ar_count &&
            integration_monitor.r_count == slave.r_count,
            "Independent monitor/slave handshake counts differ");
    require(integration_monitor.current_reads == 0 && integration_monitor.current_writes == 0,
            "Independent monitor has unfinished requests");
    require(integration_monitor.transaction_samples > 0 &&
            integration_monitor.protocol_samples > 0, "Independent coverage did not sample");
'''
    if mode == 'response_off':
        acceptance += '''    response_enabled_witness.check_quiescent();
    require(response_enabled_witness.response_errors > 0,
            "Response-on witness did not detect the injected error responses");
    require(response_enabled_witness.error_count() == response_enabled_witness.response_errors,
            "Response-on witness found an unrelated protocol/X/policy violation");
    require(integration_monitor.response_hits[1] > 0 &&
            integration_monitor.response_hits[2] > 0 && integration_monitor.response_hits[3] > 0,
            "Known EXOKAY/SLVERR/DECERR response samples were not all observed");
    $display("MONITOR_RESPONSE_SWITCH_PASS known_responses_only=1 response_off_errors=%0d response_on_errors=%0d",
             integration_monitor.response_errors, response_enabled_witness.response_errors);
'''
    if mode in ('timeout_off', 'zero_timeout'):
        acceptance += '''    timeout_enabled_witness.check_quiescent();
    require(timeout_enabled_witness.timeout_errors > 0,
            "Timeout-on witness did not observe over-budget traffic");
    require(timeout_enabled_witness.error_count() == timeout_enabled_witness.timeout_errors,
            "Timeout-on witness found an unrelated protocol/X/policy violation");
    $display("MONITOR_TIMEOUT_SWITCH_PASS mode=%s disabled_errors=%0d enabled_errors=%0d",
             "''' + mode + '''", integration_monitor.timeout_errors, timeout_enabled_witness.timeout_errors);
'''
    acceptance += '''    $display("MONITOR_DRIVER_PASS %s error_count=%0d aw=%0d w=%0d b=%0d ar=%0d r=%0d",
             case_name, integration_monitor.error_count(), integration_monitor.aw_count,
             integration_monitor.w_count, integration_monitor.b_count,
             integration_monitor.ar_count, integration_monitor.r_count);
'''
    anchor = '    $display("BURST_TEST_PASS %s", case_name);'
    return replace_once(source, anchor, acceptance + anchor, 'final PASS injection anchor')


def run_command(command, log, timeout):
    with log.open('w') as stream:
        result = subprocess.run(command, cwd=str(log.parent), stdout=stream,
                                stderr=subprocess.STDOUT, timeout=timeout)
    return result.returncode, log.read_text(errors='replace')


def validate_run(output, case, mode):
    if not re.search(r'^BURST_TEST_PASS ' + re.escape(case) + r'$', output, re.M):
        return False
    match = re.search(r'^MONITOR_DRIVER_PASS ' + re.escape(case) +
                      r' error_count=0 aw=(\d+) w=(\d+) b=(\d+) ar=(\d+) r=(\d+)$',
                      output, re.M)
    if match is None or not all(int(value) > 0 for value in match.groups()):
        return False
    if re.search(r'Fatal:|Error-|TEST_CHECK_FAILED|TEST_WATCHDOG|AXI_CHECK\[', output):
        return False
    if mode == 'response_off' and not re.search(
            r'^MONITOR_RESPONSE_SWITCH_PASS known_responses_only=1 response_off_errors=0 '
            r'response_on_errors=[1-9][0-9]*$', output, re.M):
        return False
    if mode in ('timeout_off', 'zero_timeout') and not re.search(
            r'^MONITOR_TIMEOUT_SWITCH_PASS mode=' + mode + r' disabled_errors=0 '
            r'enabled_errors=[1-9][0-9]*$', output, re.M):
        return False
    return True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--work-dir', type=Path, help='New or empty artifact directory')
    parser.add_argument('--mode', choices=list(MODE_CASE), action='append', dest='modes')
    parser.add_argument('--monitor-timeout-cycles', type=int, default=1000)
    parser.add_argument('--prepare-only', action='store_true', help='Generate isolated inputs without invoking VCS')
    args = parser.parse_args()
    if args.monitor_timeout_cycles < 1:
        parser.error('--monitor-timeout-cycles must be positive')
    modes = args.modes or DEFAULT_MODES
    if len(modes) != len(set(modes)):
        parser.error('--mode values must be unique')
    workbook = ROOT / 'docs/vip/vip_cfg.xlsx'
    inputs = [workbook, ROOT/'tests/burst/burst_tb.sv', ROOT/'tests/burst/burst_test_slave.sv',
              ROOT/'tests/burst/run_vcs.py', ROOT/'scripts/gen_vip_cfg.py', ROOT/'Makefile',
              ROOT/'filelist.f', ROOT/'tb/generated/axi4_vip_cfg_pkg.sv',
              ROOT/'tb/generated/axi4_seq_cfg_pkg.sv', ROOT/'tb/axi4/axi4_if.sv',
              ROOT/'tb/axi4/axi4_vip_adapter_pkg.sv', ROOT/'tb/axi4/simple_axi4_bfm_adapter.sv',
              ROOT/'tb/axi4/checker/axi4_checker_pkg.sv', ROOT/'tb/axi4/checker/axi4_protocol_monitor.sv']
    snapshots = dict((str(path), sha256(path)) for path in inputs)
    if snapshots[str(workbook)] != BASELINE_SHA:
        raise RuntimeError('Workbook differs from required baseline before integration')
    if args.work_dir:
        work = args.work_dir.resolve()
        if work.exists() and any(work.iterdir()):
            raise RuntimeError('Artifact directory is not empty: ' + str(work))
        work.mkdir(parents=True, exist_ok=True)
    else:
        work = Path(tempfile.mkdtemp(prefix='axi05_burst_integration_')).resolve()
    print('ARTIFACT_DIR ' + str(work))
    manifest = {
        'modes': modes, 'source_sha256': snapshots,
        'driver_timeout_cycles_by_mode': dict((m, 0 if m == 'zero_timeout' else 12) for m in modes),
        'monitor_inactivity_timeout_cycles_by_mode': dict((m, 0 if m == 'zero_timeout' else 4 if m == 'timeout_off' else args.monitor_timeout_cycles) for m in modes),
        'response_off_scope': 'Temporary known-response variant: X response replaced with EXOKAY; X checks remain enabled',
        'results': {},
    }
    original = (ROOT/'tests/burst/burst_tb.sv').read_text()
    try:
        for mode in modes:
            mode_dir = work / mode
            mode_dir.mkdir()
            cfg_path = mode_dir / 'config.json'
            cfg_path.write_text(json.dumps(config_for(mode), indent=2) + '\n')
            bench = mode_dir / 'burst_tb.sv'
            bench.write_text(instrument(original, mode, args.monitor_timeout_cycles))
            code, output = run_command(
                [sys.executable, str(ROOT/'scripts/gen_vip_cfg.py'), '--cfg', str(cfg_path),
                 '--out', str(mode_dir/'axi4_vip_cfg_pkg.sv')], mode_dir/'config.log', 30)
            if code:
                raise RuntimeError('Config generation failed: ' + output[-4000:])
            sources = [mode_dir/'axi4_vip_cfg_pkg.sv', ROOT/'tb/generated/axi4_seq_cfg_pkg.sv',
                       ROOT/'tb/axi4/axi4_if.sv', ROOT/'tb/axi4/axi4_vip_adapter_pkg.sv',
                       ROOT/'tb/axi4/simple_axi4_bfm_adapter.sv',
                       ROOT/'tb/axi4/checker/axi4_checker_pkg.sv',
                       ROOT/'tb/axi4/checker/axi4_protocol_monitor.sv',
                       ROOT/'tests/burst/burst_test_slave.sv', bench]
            command = [os.environ.get('VCS', 'vcs'), '-full64', '-sverilog', '-ntb_opts', 'uvm',
                       '-timescale=1ns/1ps', '+incdir+'+str(ROOT/'tb/axi4'), '-top', 'burst_tb',
                       '-Mdir='+str(mode_dir/'csrc'), '-o', str(mode_dir/'simv')] + list(map(str, sources))
            manifest['results'][mode] = {'case': MODE_CASE[mode], 'compile_command': command,
                                         'status': 'prepared',
                                         'monitor_timeout_cycles': 0 if mode == 'zero_timeout' else 4 if mode == 'timeout_off' else args.monitor_timeout_cycles,
                                         'driver_timeout_cycles': 0 if mode == 'zero_timeout' else 12}
            if args.prepare_only:
                print('PREPARED ' + mode)
                continue
            code, output = run_command(command, mode_dir/'compile.log', 240)
            if code or 'Error-' in output or not os.access(str(mode_dir/'simv'), os.X_OK):
                raise RuntimeError('Compile failed: {}\n{}'.format(mode_dir/'compile.log', output[-6000:]))
            code, output = run_command([str(mode_dir/'simv'), '+CASE='+MODE_CASE[mode]], mode_dir/'sim.log', 60)
            ok = code == 0 and validate_run(output, MODE_CASE[mode], mode)
            manifest['results'][mode]['status'] = 'pass' if ok else 'fail'
            print(('PASS ' if ok else 'FAIL ') + mode + ' ' + str(mode_dir/'sim.log'))
            if not ok:
                raise RuntimeError('Integration failed: {}\n{}'.format(mode_dir/'sim.log', output[-6000:]))
        print('MONITOR_DRIVER_PREPARED' if args.prepare_only else 'MONITOR_DRIVER_SUITE_PASS')
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
