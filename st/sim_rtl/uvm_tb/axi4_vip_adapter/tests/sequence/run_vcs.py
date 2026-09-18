#!/usr/bin/env python3
"""Run feature04 in an isolated directory after loading the VCS module.

Uses standalone JSON and generated SV, never make or workbook writes.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from cases import plan, lane_plan, mixed_plan

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from workbook_baseline import BASELINE_SHA


def run(command, cwd, log, timeout):
    with log.open("w") as stream:
        result = subprocess.run(command, cwd=str(cwd), stdout=stream,
                                stderr=subprocess.STDOUT, timeout=timeout)
    output = log.read_text(errors="replace")
    if result.returncode:
        print(output[-12000:])
        raise RuntimeError("Command failed; see " + str(log))
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--case", choices=["burst128", "lanes", "mixed", "legacy"], default="burst128")
    parser.add_argument("--work-dir", type=Path)
    args = parser.parse_args()
    workbook = ROOT / "docs/vip/vip_cfg.xlsx"
    before = hashlib.sha256(workbook.read_bytes()).hexdigest()
    if before != BASELINE_SHA:
        raise RuntimeError("Workbook differs from required baseline")
    work = (args.work_dir or Path(tempfile.mkdtemp(prefix="axi04_sequence_"))).resolve()
    work.mkdir(parents=True, exist_ok=True)
    # Relative data_file paths in the original examples resolve in scratch.
    (work / "docs/txt").mkdir(parents=True, exist_ok=True)
    for source in (ROOT / "docs/txt").glob("*.txt"):
        shutil.copyfile(str(source), str(work / "docs/txt" / source.name))
    legacy = args.case == "legacy"
    advanced_plans = {"burst128": plan, "lanes": lane_plan, "mixed": mixed_plan}
    seq_plan = json.loads((ROOT / "docs/seq/seq_plan.json").read_text()) if legacy else advanced_plans[args.case]()
    if legacy:
        # Exercise the standalone range_read operation without changing the
        # original workbook or its generated plan.
        common = {"addr": "0x400", "addr_stride": 4, "count": 4,
                  "data_file": "docs/txt/mem20_data.txt", "data_start": 0}
        seq_plan["sequences"].append({"name": "axi4_range_read_compat", "steps": [
            dict(common, op="range_write", readback=False, write_mode="FULL_ADDR_FULL_BYTE"),
            dict(common, op="range_read"),
        ]})
    cfg = {
        "axi": {"data_width": 32 if legacy else 256, "addr_width": 32,
                "id_width": 4 if legacy else 8, "len_width": 8 if legacy else 4,
                "qos_width": 0, "region_width": 0, "max_burst_len": 16,
                "max_outstanding_reads": 128, "max_outstanding_writes": 128,
                "max_outstanding_total": 128,
                "read_timeout_cycles": 20000, "write_timeout_cycles": 20000,
                "ready_timeout_cycles": 20000},
        "support": {"exclusive_access": False, "locked_access": False,
                    "narrow_burst": False, "unaligned_access": False,
                    "fixed_burst": False, "incrementing_burst": True,
                    "wrapping_burst": False, "byte_strobe": True},
    }
    (work / "config.json").write_text(json.dumps(cfg, indent=2) + "\n")
    (work / "plan.json").write_text(json.dumps(seq_plan, indent=2) + "\n")
    for script, options in [
        ("gen_vip_cfg.py", ["--cfg", "config.json", "--out", "axi4_vip_cfg_pkg.sv"]),
        ("gen_axi4_seq.py", ["--plan", "plan.json", "--out", "axi4_generated_seq_pkg.sv", "--seq-dir", "seqs"]),
        ("gen_irq_seq.py", ["--txt", "docs/txt/irq_seq.txt", "--out", "axi4_irq_handler_seq.svh"]),
    ]:
        subprocess.run([sys.executable, str(ROOT / "scripts" / script)] + options,
                       cwd=str(work), check=True)
    sources = [work / "axi4_vip_cfg_pkg.sv", ROOT / "tb/generated/axi4_seq_cfg_pkg.sv",
               ROOT / "tb/axi4/axi4_if.sv", ROOT / "tb/axi4/axi4_vip_adapter_pkg.sv",
               ROOT / "tb/axi4/simple_axi4_bfm_adapter.sv",
               work / "axi4_generated_seq_pkg.sv", ROOT / "tb/axi4/axi4_interrupt_pkg.sv",
               ROOT / "tests/sequence/sequence_mem.sv", ROOT / "tests/sequence/sequence_tb.sv"]
    compile_cmd = [os.environ.get("VCS", "vcs"), "-full64", "-sverilog", "-ntb_opts", "uvm",
                   "-timescale=1ns/1ps", "-top", "sequence_tb",
                   "+incdir+" + str(ROOT / "tb/axi4"), "+incdir+" + str(work),
                   "+incdir+" + str(work / "seqs"), "-Mdir=" + str(work / "csrc"),
                   "-o", str(work / "simv")] + list(map(str, sources))
    run(compile_cmd, work, work / "compile.log", 240)
    variants = [(args.case, [])]
    if legacy:
        variants = [
            ("users", ["+SEQ=all", "+EXPECT_AW=5", "+EXPECT_AR=5"]),
            ("single", ["+SEQ=axi4_single_addr_cfg_seq", "+EXPECT_AW=2", "+EXPECT_AR=2"]),
            ("range", ["+SEQ=axi4_range_window_seq", "+EXPECT_AW=5", "+EXPECT_AR=5"]),
            ("byte_single", ["+SEQ=axi4_user_two_regs", "+write_mode=SINGLE_ADDR_SINGLE_BYTE", "+EXPECT_AW=9", "+EXPECT_AR=9"]),
            ("byte_range", ["+SEQ=axi4_range_window_seq", "+write_mode=SINGLE_ADDR_SINGLE_BYTE", "+EXPECT_AW=17", "+EXPECT_AR=17"]),
            ("lane_range", ["+SEQ=axi4_range_window_seq", "+write_mode=FULL_ADDR_SINGLE_BYTE", "+EXPECT_AW=17", "+EXPECT_AR=5"]),
            ("range_read", ["+SEQ=axi4_range_read_compat", "+EXPECT_AW=5", "+EXPECT_AR=5"]),
            ("byte_range_read", ["+SEQ=axi4_range_read_compat", "+write_mode=SINGLE_ADDR_SINGLE_BYTE", "+EXPECT_AW=17", "+EXPECT_AR=17"]),
        ]
    for name, plusargs in variants:
        log = work / (name + ".log")
        output = run([str(work / "simv"), "+CASE=" + args.case] + plusargs, work, log, 30)
        if "SEQUENCE_TEST_PASS " + args.case not in output:
            print(output[-10000:])
            raise RuntimeError("Missing pass marker: " + str(log))
        print("PASS " + name + " " + str(log))
        print("\n".join(line for line in output.splitlines() if line.startswith("SEQUENCE_COUNTS")))
    negatives = []
    if legacy:
        negatives = [
            ("addr_parse_overflow", ["+range_base_addr=0x100000000", "+range_addr_stride=4"], "range_base_addr overflows 32 bits"),
            ("count_parse_overflow", ["+range_count=4294967296", "+range_addr_stride=4"], "range_count overflows 32 bits"),
            ("window_overflow", ["+range_base_addr=0xfffffffc", "+range_addr_stride=4"], "Range address window overflows"),
            ("bad_stride", ["+range_addr_stride=2", "+range_readback=0"], "must be bus-byte aligned"),
            ("overlap_readback", ["+write_mode=SINGLE_ADDR_SINGLE_BYTE", "+range_addr_stride=1"], "Range readback windows overlap"),
        ]
        negative_prefix = ["+CASE=legacy", "+SEQ=axi4_range_window_seq"]
    elif args.case == "burst128":
        negative_prefix = ["+CASE=abort"]
        negatives = [("reset_abort", [], "AXI_SEQ_ABORT")]
    if negatives:
        for name, plusargs, expected in negatives:
            log = work / (name + ".log")
            with log.open("w") as stream:
                subprocess.run([str(work / "simv")] + negative_prefix + plusargs,
                               cwd=str(work), stdout=stream, stderr=subprocess.STDOUT, timeout=30)
            output = log.read_text(errors="replace")
            if expected not in output or "UVM_FATAL" not in output or "SEQUENCE_TEST_PASS" in output:
                print(output[-10000:])
                raise RuntimeError("Expected rejection missing: " + str(log))
            print("PASS expected rejection " + name + " " + str(log))
    if hashlib.sha256(workbook.read_bytes()).hexdigest() != before:
        raise RuntimeError("Workbook changed during regression")
    print("WORKBOOK_SHA256 " + before)
    print("ARTIFACT_DIR " + str(work))


if __name__ == "__main__":
    main()
