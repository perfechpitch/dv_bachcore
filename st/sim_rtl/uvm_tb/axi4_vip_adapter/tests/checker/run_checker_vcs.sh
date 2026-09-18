#!/usr/bin/env bash
set -euo pipefail

# No make target or generated workbook configuration is invoked. All simulator
# products are isolated under a newly allocated scratch directory.
test_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
project_dir=$(cd -- "$test_dir/../.." && pwd)
scratch_parent=${CHECKER_SCRATCH_PARENT:-${TMPDIR:-/tmp}}
mkdir -p -- "$scratch_parent"
run_dir=$(mktemp -d "$scratch_parent/axi4_checker.XXXXXXXX")
printf 'Checker scratch: %s\n' "$run_dir"

workbook="$project_dir/docs/vip/vip_cfg.xlsx"
sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}
workbook_before=$(sha256_file "$workbook")
preserve_workbook() {
  status=$?
  workbook_after=$(sha256_file "$workbook")
  if [[ "$workbook_after" != "$workbook_before" ]]; then
    printf 'ERROR: protected workbook changed during checker tests\n' >&2
    exit 1
  fi
  printf 'Protected workbook unchanged: %s\n' "$workbook_after"
  exit "$status"
}
trap preserve_workbook EXIT

vcs_bin=${VCS:-vcs}
if ! command -v "$vcs_bin" >/dev/null 2>&1; then
  modulecmd=${MODULECMD:-/fastone/softwares/modules/bin/modulecmd}
  vcs_module=${VCS_MODULE:-vcs/S-2021.09-SP2}
  if [[ ! -x "$modulecmd" ]]; then
    printf 'ERROR: VCS is unavailable and modulecmd was not found\n' >&2
    exit 2
  fi
  # Server login shell is csh; this runner explicitly uses bash/sh module output.
  eval "$("$modulecmd" sh load "$vcs_module")"
fi

bounded() {
  if command -v timeout >/dev/null 2>&1; then
    timeout "$@"
  else
    shift
    "$@"
  fi
}

compile_top() {
  top=$1
  source=$2
  mkdir "$run_dir/$top"
  cd "$run_dir/$top"
  bounded "${CHECKER_COMPILE_TIMEOUT:-180}" "$vcs_bin" -full64 -sverilog \
    -timescale=1ns/1ps -top "$top" \
    "$project_dir/tb/axi4/axi4_if.sv" \
    "$project_dir/tb/axi4/checker/axi4_checker_pkg.sv" \
    "$project_dir/tb/axi4/checker/axi4_protocol_monitor.sv" \
    "$test_dir/$source" -Mdir=csrc -o simv -l compile.log
}

compile_top tb_axi4_protocol_monitor tb_axi4_protocol_monitor.sv
bounded "${CHECKER_RUN_TIMEOUT:-90}" ./simv > sim.log 2>&1
cat sim.log
if ! grep -q 'CHECKER_REGRESSION_PASS' sim.log; then
  printf 'ERROR: checker regression did not produce its PASS marker\n' >&2
  exit 1
fi
if grep -Eq 'CHECKER_TEST_FAIL|Fatal:|Error-' sim.log; then
  printf 'ERROR: unexpected simulator diagnostic\n' >&2
  exit 1
fi

compile_top tb_axi4_checker_progress tb_axi4_checker_progress.sv
bounded "${CHECKER_RUN_TIMEOUT:-90}" ./simv > sim.log 2>&1
cat sim.log
if ! grep -q 'CHECKER_PROGRESS_PASS scenarios=6' sim.log || \
    grep -Eq 'CHECKER_PROGRESS_FAIL|Fatal:|Error-' sim.log; then
  printf 'ERROR: short-budget progress checker regression failed\n' >&2
  exit 1
fi

compile_top tb_axi4_checker_report tb_axi4_checker_report.sv
set +e
bounded "${CHECKER_RUN_TIMEOUT:-90}" ./simv > sim.log 2>&1
report_status=$?
set -e
cat sim.log
# VCS can terminate on $fatal while returning status 0. Require the exact fatal
# diagnostic and reject timeout/watchdog, rather than relying on process status.
if [[ "$report_status" -eq 124 || "$report_status" -eq 137 ]] || \
    ! grep -Eq '^Fatal:.*tb_axi4_checker_report\.dut\.violation:' sim.log || \
    ! grep -Eq '^AXI_CHECK\[AXI_RESPONSE\] cycle=[0-9]+ BID has no outstanding write$' sim.log || \
    grep -q 'CHECKER_REPORT_SMOKE_MISSING_EXPECTED_ERROR' sim.log; then
  printf 'ERROR: expected fatal response checker diagnostic was not observed\n' >&2
  exit 1
fi
printf 'CHECKER_REPORT_SMOKE_PASS observed_status=%s expected_fatal=AXI_RESPONSE\n' "$report_status"

compile_top tb_axi4_checker_capability tb_axi4_checker_capability.sv
set +e
bounded "${CHECKER_RUN_TIMEOUT:-90}" ./simv > sim.log 2>&1
capability_status=$?
set -e
cat sim.log
if [[ "$capability_status" -eq 124 || "$capability_status" -eq 137 ]] || \
    ! grep -Eq '^Fatal:.*tb_axi4_checker_capability\.dut' sim.log || \
    ! grep -q '^checker implements normal INCR only; unsupported capability requested$' sim.log || \
    grep -q 'CHECKER_CAPABILITY_SMOKE_MISSING_EXPECTED_ERROR' sim.log; then
  printf 'ERROR: expected unsupported capability startup fatal was not observed\n' >&2
  exit 1
fi
printf 'CHECKER_CAPABILITY_SMOKE_PASS observed_status=%s expected_fatal=unsupported_capability\n' "$capability_status"
printf 'CHECKER_SUITE_PASS logs=%s\n' "$run_dir"
