#!/usr/bin/env python3
"""Run standalone demo-RAM VCS tests in an explicit new scratch directory.

Load the VCS module before running. Only this test, axi4_if and the RAM are
compiled. No workbook, generated configuration, or production work is written.
"""
import argparse
import json
from pathlib import Path
import re
import subprocess


def run(command, destination, log_name, timeout):
    log = destination / log_name
    with log.open("w") as stream:
        subprocess.run(command, cwd=str(destination), stdout=stream,
                       stderr=subprocess.STDOUT, timeout=timeout, check=True)
    text = log.read_text()
    if re.search(r"Fatal:|Error-\[|Error:", text):
        raise RuntimeError("simulation/compiler error: " + str(log))
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-dir", required=True, type=Path, help="Must not exist")
    parser.add_argument("--vcs", default="vcs")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    work = args.work_dir.resolve()
    work.mkdir(parents=True, exist_ok=False)
    results = []
    for name, defines in (("target256", []), ("legacy32", ["+define+SIMPLE_MEM_LEGACY"])):
        case = work / name
        case.mkdir()
        command = [args.vcs, "-full64", "-sverilog", "-timescale=1ns/1ps",
                   "-top", "simple_mem_top"] + defines
        command += [str(root / relative) for relative in
                    ("tb/axi4/axi4_if.sv", "tb/axi4/axi4_simple_mem_slave.sv",
                     "tests/integration/simple_mem_top.sv")]
        command += ["-o", str(case / "simv"), "-Mdir=" + str(case / "csrc")]
        run(command, case, "compile.log", 120)
        output = run([str(case / "simv")], case, "sim.log", 30)
        matches = re.findall(r"SIMPLE_MEM_PASS[^\n]*", output)
        rejects = len(re.findall(r"AXI4_SIMPLE_MEM_REJECT", output))
        strengthened_checks = ["CONTINUOUS", "4KB_PRESERVED", "EARLY_LAST"]
        if (len(matches) != 1 or rejects != 14 or
                any("SIMPLE_MEM_" + check + "_PASS" not in output for check in strengthened_checks)):
            raise RuntimeError("missing PASS/negative diagnostics: " + str(case / "sim.log"))
        print(matches[0], flush=True)
        results.append({"case": name, "status": "passed", "pass": matches[0],
                        "expected_rejection_diagnostics": rejects,
                        "strengthened_checks": strengthened_checks,
                        "counts": re.findall(r"SIMPLE_MEM_COUNTS[^\n]*", output)})
    (work / "result.json").write_text(json.dumps(results, indent=2) + "\n")
    print("Logs: " + str(work), flush=True)


if __name__ == "__main__":
    main()
