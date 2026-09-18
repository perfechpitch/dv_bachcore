#!/usr/bin/env python3
"""Exercise the actual demo top with legacy and independent DATA256 sequences."""
import argparse
import json
import os
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from run_isolated import run_bounded


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-dir", type=Path, required=True)
    args = parser.parse_args()
    work = args.work_dir.resolve()
    work.mkdir(parents=True, exist_ok=False)
    cases = [
        ("legacy_irq", None, "axi4_user_two_regs", True, 10.0, (3, 3, 3, 2, 2)),
        ("target_mixed", "sequence_256_mixed.json", "axi4_mixed_burst_seq", False, 1.0, (8, 27, 8, 8, 27)),
        ("target_mixed_irq", "sequence_256_mixed.json", "axi4_mixed_burst_seq", True, 1.0, (9, 28, 9, 8, 27)),
        ("target_lanes", "sequence_256_lanes.json", "axi4_lane_seq", False, 1.0, (67, 67, 67, 37, 37)),
    ]
    results = []
    for name, plan, seq, irq, period, expected in cases:
        case = work / name
        case.mkdir()
        command = [sys.executable, str(ROOT / "scripts/run_isolated.py"),
                   "--work-root", str(case), "--seq", seq,
                   "--sim-arg", "+AXI_CLK_PERIOD_NS=" + str(period)]
        if irq:
            command.append("--irq")
        if plan:
            command += ["--profile", str(ROOT / "tests/configs/scp_bach_ctrl_m0.json"),
                        "--plan", str(ROOT / "docs/examples" / plan)]
        with (case / "run.log").open("w") as log:
            run_bounded(command, ROOT, dict(os.environ, PYTHONDONTWRITEBYTECODE="1"), 300, log)
        output = (case / "run.log").read_text()
        measured = re.findall(r"AXI_CLOCK_MEASURED period_ns=([0-9.]+) samples=10", output)
        if len(measured) != 1 or abs(float(measured[0]) - period) > 0.001:
            raise ValueError("clock period was not measured correctly: " + name)
        target = "ADDR_WIDTH=32 DATA_WIDTH=256 STRB_WIDTH=32 ID_WIDTH=8 LEN_WIDTH=4"
        if plan and target not in output:
            raise ValueError("target widths not confirmed: " + name)
        count = re.search(r"AXI_CHECKER_SUMMARY errors=0 AW=(\d+) W=(\d+) B=(\d+) AR=(\d+) R=(\d+)", output)
        if not count or "AXI_CHECKER_PASS" not in output:
            raise ValueError("missing checker success: " + name)
        actual = tuple(int(value) for value in count.groups())
        if expected is not None and actual != expected:
            raise ValueError("handshake counts differ: {} {} != {}".format(name, actual, expected))
        if name.startswith("target_mixed"):
            coverage = re.search(r"AXI_COVERAGE_LENGTHS one=(\d+) two=(\d+) four=(\d+) sixteen=(\d+)", output)
            if not coverage or any(int(value) == 0 for value in coverage.groups()):
                raise ValueError("integrated burst coverage bins were not sampled: " + name)
        if irq and "Interrupt rising edge detected; start handler seq #1" not in output:
            raise ValueError("IRQ handler did not run: " + name)
        row = {"case": name, "status": "passed", "clock_ns": float(measured[0]),
               "aw_w_b_ar_r": actual, "command": command, "log": str(case / "run.log")}
        results.append(row)
        print("TOP_SMOKE_PASS {} period_ns={} AW_W_B_AR_R={}".format(name, measured[0], actual), flush=True)
    (work / "result.json").write_text(json.dumps(results, indent=2) + "\n")
    print("TOP_SMOKE_SUITE_PASS cases=" + str(len(results)), flush=True)


if __name__ == "__main__":
    main()
