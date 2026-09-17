#!/usr/bin/env bash
# Standalone feature03 regression. Does not invoke make or touch vip_cfg.xlsx.
set -euo pipefail
project=$(cd "$(dirname "$0")/../.." && pwd)
build=${OUT_DIR:-$(mktemp -d "${TMPDIR:-/tmp}/axi03_vcs.XXXXXXXX")}
mkdir -p "$build"
build=$(cd "$build" && pwd)
if [[ -x /fastone/softwares/modules/bin/modulecmd ]]; then
  eval "$(/fastone/softwares/modules/bin/modulecmd sh load vcs/S-2021.09-SP2)"
fi
python_bin=${PYTHON:-python3}
read -r -a cases <<< "${CASES:-positive timeout_aw timeout_w timeout_b timeout_ar timeout_r bad_bid bad_rid early_rlast missing_rlast early_b poison_cleanup lifecycle clock_reset timeout_edge_r timeout_edge_b}"
need_outstanding=0
need_lifecycle=0
need_clock_reset=0
for test_case in "${cases[@]}"; do
  case "$test_case" in
    lifecycle) need_lifecycle=1 ;;
    clock_reset) need_clock_reset=1 ;;
    positive|timeout_aw|timeout_w|timeout_b|timeout_ar|timeout_r|bad_bid|bad_rid|early_rlast|missing_rlast|early_b|poison_cleanup|timeout_edge_r|timeout_edge_b)
      need_outstanding=1 ;;
    *) echo "Unknown outstanding CASES entry: $test_case" >&2; exit 2 ;;
  esac
done
"$python_bin" "$project/scripts/gen_vip_cfg.py" \
  --cfg "$project/tests/outstanding/profile.json" --out "$build/axi4_vip_cfg_pkg.sv"
cd "$build"
common_sources=(
  "$build/axi4_vip_cfg_pkg.sv" "$project/tb/generated/axi4_seq_cfg_pkg.sv"
  "$project/tb/axi4/axi4_if.sv" "$project/tb/axi4/axi4_vip_adapter_pkg.sv"
  "$project/tb/axi4/simple_axi4_bfm_adapter.sv"
  "$project/tests/outstanding/controlled_slave.sv"
)
if (( need_outstanding )); then
  timeout 180 "${VCS:-vcs}" -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
    +incdir+"$project/tb/axi4" "${common_sources[@]}" \
    "$project/tests/outstanding/outstanding_tb.sv" -top outstanding_tb \
    -Mdir="$build/csrc_outstanding" -o "$build/simv" -l "$build/compile.log"
fi
if (( need_lifecycle )); then
  timeout 180 "${VCS:-vcs}" -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
    +incdir+"$project/tb/axi4" "${common_sources[@]}" \
    "$project/tests/outstanding/lifecycle_tb.sv" -top lifecycle_tb \
    -Mdir="$build/csrc_lifecycle" -o "$build/simv_lifecycle" -l "$build/compile_lifecycle.log"
fi
if (( need_clock_reset )); then
  timeout 180 "${VCS:-vcs}" -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ns/1ps \
    +incdir+"$project/tb/axi4" "${common_sources[@]}" \
    "$project/tests/outstanding/clock_reset_tb.sv" -top clock_reset_tb \
    -Mdir="$build/csrc_clock_reset" -o "$build/simv_clock_reset" -l "$build/compile_clock_reset.log"
fi
for test_case in "${cases[@]}"; do
  if [[ "$test_case" == clock_reset ]]; then
    timeout 90 "$build/simv_clock_reset" -l "$build/clock_reset.log"
    pass_marker=CLOCK_RESET_REGRESSION_PASS
  elif [[ "$test_case" == lifecycle ]]; then
    timeout 90 "$build/simv_lifecycle" -l "$build/lifecycle.log"
    pass_marker=LIFECYCLE_REGRESSION_PASS
  else
    timeout 90 "$build/simv" "+CASE=$test_case" -l "$build/${test_case}.log"
    pass_marker=OUTSTANDING_REGRESSION_PASS
  fi
  "$python_bin" - "$build/${test_case}.log" "$pass_marker" <<'PY'
import re, sys
text = open(sys.argv[1]).read()
if sys.argv[2] not in text or re.search(r'UVM_(?:ERROR|FATAL)\s*:\s*[1-9]', text):
    raise SystemExit('Regression missing PASS or has unexpected UVM errors/fatals')
print('Validated ' + sys.argv[2] + ':', sys.argv[1])
PY
done
