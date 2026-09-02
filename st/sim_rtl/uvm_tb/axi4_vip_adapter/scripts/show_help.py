#!/usr/bin/env python
"""Print Makefile help with the current generated AXI4 sequence list."""

from __future__ import print_function

import argparse
import json
import os


def load_plan(path):
    if not os.path.exists(path):
        return {}, "Missing %s. Run `make seq_gen` first." % path
    try:
        with open(path, "r") as plan_file:
            return json.load(plan_file), None
    except ValueError as err:
        return {}, "Cannot parse %s: %s" % (path, err)


def section(title):
    print("")
    print(title)
    print("-" * len(title))


def step_count(seq):
    return len(seq.get("steps", []))


def seq_description(seq):
    desc = str(seq.get("description", "")).strip()
    if desc:
        return desc
    return "%d step(s)" % step_count(seq)


def print_seq_summary(plan, warning):
    top_sequence = plan.get("top_sequence", "axi4_doc_plan_seq")
    sequences = plan.get("sequences", [])
    user_sequences = [seq for seq in sequences if seq.get("source") == "user"]
    base_sequences = [seq for seq in sequences if seq.get("source", "base") == "base"]

    section("Sequence Summary")
    if warning:
        print("Warning: %s" % warning)
    print("Top sequence : %s" % top_sequence)
    print("Seq count    : %d" % len(sequences))
    print("Base seq     : %d (reference/template; run explicitly with make SEQ=<seq_name>)" % len(base_sequences))
    print("User seq     : %d (make SEQ_ALL runs these only)" % len(user_sequences))
    if not sequences:
        print("Seq list     : <none>")
        return sequences

    print("Available SEQ:")
    for idx, seq in enumerate(sequences, start=1):
        print("  %2d. %-36s [%s]" % (idx, seq.get("name", "<unnamed>"), seq.get("source", "base")))
    if not user_sequences:
        print("SEQ_ALL note : no user seq yet; create one with make user_seq.")
    return sequences


def print_common_commands(args, sequences):
    section("Make Commands")
    print("  make help")
    print("      Show this help.")
    print("  make seq_gen")
    print("      Run make vip_cfg first, then regenerate seq cfg, usage sheets, seq plan, irq seq, and generated seq SV.")
    print("  make vip_cfg")
    print("      Merge DUT overrides with base defaults, then generate FINAL_FEATURE, JSON, SV cfg, and the selected AXI VIP filelist.")
    print("  make user_seq BASE_SEQ=<base_seq> NEW_SEQ=<new_seq> [addr=<addr>] [data=<data>] [...]")
    print("      Create or replace a user seq, run seq_gen, then compile/run NEW_SEQ; roll back the table if validation fails.")
    print("  make clear_user_seq")
    print("      Clear all user seq records from the user table, then run seq_gen.")
    print("  make clear_user_seq USER_SEQ=<seq_name>")
    print("      Remove one user seq record from the user table, then run seq_gen.")
    print("  make clean")
    print("      Remove simulator outputs, logs, and waveform files.")
    print("  make SEQ_ALL")
    print("      Run seq_gen, then compile/run every user seq as an independent simulation under work/SEQ_ALL/<seq_name>.")
    print("  make seq_all")
    print("      Lowercase alias of make SEQ_ALL.")
    print("  make SEQ=<seq_name>")
    print("      Run seq_gen first, check SEQ exists in the plan, then compile/run one selected seq.")
    print("  make SEQ_ALL <seq_name> verdi")
    print("      Open work/SEQ_ALL/<seq_name>/axi4_bfm.fsdb without compiling or simulating.")
    print("  make SEQ=<seq_name> verdi")
    print("      Open the existing waveform in Verdi without compiling or simulating.")


def print_variables(args):
    section("Make Variables")
    print("  TEST=<uvm_test_name>       default: %s" % args.test)
    print("  SEQ=<seq_name>             selected generated seq for single-seq run")
    print("  IRQ_EN=0|1                default: 0, set 1 to enable interrupt detection and post-seq IRQ wait")
    print("  write_mode=<mode>          set generated user-seq write_mode, or override one run")
    print("  range_write_mode=<mode>    alias for write_mode during user_seq; range-only write-mode override for normal run")
    print("  RUN_AFTER_USER_SEQ=0|1     default: 1, set 0 to create a user seq without compiling/running it")
    print("  WAVE=0|1                  default: 1, set 0 to run without FSDB dump")
    print("  WORK_ROOT=<dir>            default: work, root for per-run compile/sim outputs")
    print("  SEQ_ALL_WORK_DIR=<dir>     default: work/SEQ_ALL, parent of per-seq SEQ_ALL outputs")
    print("  RUN_SIMV=<file>            default: work/<SEQ>/simv; SEQ_ALL uses work/SEQ_ALL/<SEQ>/simv")
    print("  RUN_CSRC_DIR=<dir>         default: work/<SEQ>/csrc; SEQ_ALL uses one csrc per seq")
    print("  COMPILE_LOG=<file.log>     default: compile.log in the selected seq output directory")
    print("  WAVE_FILE=<file.fsdb>      default: axi4_bfm.fsdb in the selected seq output directory")
    print("  RUN_LOG=<file.log>         default: sim.log in the selected seq output directory")
    print("  VERDI=<verdi_cmd>          default: verdi")
    print("  VERDI_ARGS='<args>'        extra arguments passed to Verdi")
    print("  NOVAS_PLI_DIR=<dir>        optional path to Verdi share/PLI/VCS/LINUX64")
    print("  PYTHON=<python_cmd>        default: auto-detect python3, otherwise python")
    print("  VCS=<vcs_cmd>              default: vcs")
    print("  VERDI_MODULE=<module>      default: verdi/T-2022.06")
    print("  VIP_WORKBOOK=<file.xlsx>   default: %s" % args.vip_workbook)
    print("  BASE_VIP_CFG=<file.xlsx::sheet>  default: %s" % args.base_vip_cfg)
    print("  DUT_VIP_CFG=<file.xlsx::sheet>   default: %s" % args.dut_vip_cfg)
    print("  FINAL_VIP_CFG=<file.xlsx::sheet> default: %s" % args.final_vip_cfg)
    print("  BASE_SEQ_TABLE=<file.xlsx::sheet> default: %s" % args.base_seq_table)
    print("  USER_SEQ_TABLE=<file.xlsx::sheet> default: %s" % args.user_seq_table)
    print("  TABLE_USAGE=<file.xlsx::sheet> default: %s" % args.table_usage)
    print("  MAKE_USAGE=<file.xlsx::sheet>  default: %s" % args.make_usage)
    print("  USER_SEQ=<seq_name>        user seq selected by make clear_user_seq")
    print("  CLEAR_SEQ=<seq_name>       alias for USER_SEQ in make clear_user_seq")


def print_user_seq_variables():
    section("User Seq Generation")
    print("  BASE_SEQ=<seq_name>")
    print("      Base sequence copied from docs/seq/seq_table.xlsx::BASE_SEQ.")
    print("  NEW_SEQ=<seq_name>")
    print("      New or replacement user sequence written to docs/seq/seq_table.xlsx::USER_SEQ.")
    print("  SEQ_DESCRIPTION='<text>'")
    print("      Override seq_description in the new user seq.")
    print("  SEQ_GAP=FIXED|RANDOM")
    print("      Override seq gap in the new user seq.")
    print("  addr=<addr>")
    print("      Update all address cells in the copied seq.")
    print("  data=<data>")
    print("      Update single-address write data; value must fit FINAL_FEATURE axi.data_width.")
    print("  expect=<data>")
    print("      Update single-address read expect; value must fit FINAL_FEATURE axi.data_width.")
    print("  addr_list=<addr0,addr1,...>")
    print("      Expand a single-address base seq into multiple address/data operations.")
    print("  data_list=<data0,data1,...>")
    print("      Data values used with addr_list; count must match addr_list.")
    print("  expect_list=<data0,data1,...>")
    print("      Optional read expect values for addr_list; defaults to data_list.")
    print("  tr_gap=FIXED|RANDOM")
    print("      Override transaction gap cells in the copied seq.")
    print("  addr_stride=<stride>")
    print("      Override range addr_stride.")
    print("  count=<n>")
    print("      Override range count.")
    print("  data_file=<path>")
    print("      Override range data_file.")
    print("  data_start=<idx>")
    print("      Override range data_start.")
    print("  readback=0|1")
    print("      Override range readback.")
    print("  write_mode=FULL_ADDR_FULL_BYTE|FULL_ADDR_SINGLE_BYTE|SINGLE_ADDR_SINGLE_BYTE")
    print("      Set write_mode cells in the generated user seq; default is FULL_ADDR_FULL_BYTE.")
    print("  range_write_mode=<mode>")
    print("      Alias of write_mode when creating a user seq.")
    print("  OVERRIDES='addr=0x800 data=0x55 tr_gap=RANDOM'")
    print("      Optional compact lowercase key=value form; supported keys match the variable names above.")
    print("")
    print("Write mode values:")
    print("  FULL_ADDR_FULL_BYTE")
    print("  FULL_ADDR_SINGLE_BYTE")
    print("  SINGLE_ADDR_SINGLE_BYTE")
    print("")
    print("Example single-address user seq:")
    print("  make user_seq BASE_SEQ=axi4_single_addr_cfg_seq NEW_SEQ=axi4_user_reg0 addr=0x120 data=0x55")
    print("")
    print("Example multi-address single user seq:")
    print("  make user_seq BASE_SEQ=axi4_single_addr_cfg_seq NEW_SEQ=axi4_user_two_regs addr_list=0x120,0x124 data_list=0x55,0xaa")
    print("")
    print("Example range user seq:")
    print("  make user_seq BASE_SEQ=axi4_range_window_seq NEW_SEQ=axi4_user_range0 addr=0x800 addr_stride=0x4 count=8 data_start=4 tr_gap=RANDOM")
    print("")
    print("Example user seq with write mode:")
    print("  make user_seq BASE_SEQ=axi4_single_addr_cfg_seq NEW_SEQ=axi4_user_reg0 addr=0x120 data=0x55 write_mode=FULL_ADDR_SINGLE_BYTE")
    print("")
    print("Example 64-bit full-word user seq (after DUT_BUFF_FEATURE axi.data_width=64 and make vip_cfg):")
    print("  make user_seq BASE_SEQ=axi4_single_addr_cfg_seq NEW_SEQ=axi4_user_64b addr=0x1000 data=0x1122334455667788 write_mode=FULL_ADDR_FULL_BYTE")
    print("  For 64-bit word-aligned range accesses, normally use addr_stride=0x8.")


def print_vip_cfg_variables(args):
    section("DUT VIP Cfg Generation")
    print("  Workbook:")
    print("      %s" % args.vip_workbook)
    print("  Table 1, base defaults:")
    print("      %s" % args.base_vip_cfg)
    print("  Table 2, user-entered DUT overrides:")
    print("      %s" % args.dut_vip_cfg)
    print("  Table 3, generated final cfg:")
    print("      %s" % args.final_vip_cfg)
    print("  Generate and select the final cfg:")
    print("      make vip_cfg")
    print("  Regenerate seq files with the final cfg:")
    print("      make seq_gen")
    print("  Rule:")
    print("      Fill only DUT_BUFF_FEATURE.value cells that differ from the defaults; blank cells use BASE_VIP_CFG values.")
    print("  AXI VIP path:")
    print("      axi.vip_path defaults to tb/axi4. Set DUT_BUFF_FEATURE.value to a compatible target directory to override it.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", default="docs/seq/seq_plan.json")
    parser.add_argument("--base-seq-table", default="docs/seq/seq_table.xlsx::BASE_SEQ")
    parser.add_argument("--user-seq-table", default="docs/seq/seq_table.xlsx::USER_SEQ")
    parser.add_argument("--table-usage", default="docs/seq/seq_table.xlsx::TABLE_USAGE")
    parser.add_argument("--make-usage", default="docs/seq/seq_table.xlsx::MAKE_USAGE")
    parser.add_argument("--vip-workbook", default="docs/vip/vip_cfg.xlsx")
    parser.add_argument("--base-vip-cfg", default="docs/vip/vip_cfg.xlsx::BASE_VIP_CFG")
    parser.add_argument("--dut-vip-cfg", default="docs/vip/vip_cfg.xlsx::DUT_BUFF_FEATURE")
    parser.add_argument("--final-vip-cfg", default="docs/vip/vip_cfg.xlsx::FINAL_FEATURE")
    parser.add_argument("--test", default="axi4_doc_test")
    args = parser.parse_args()

    print("AXI4 VIP Adapter Make Help")
    plan, warning = load_plan(args.plan)
    sequences = print_seq_summary(plan, warning)
    print_common_commands(args, sequences)
    print_variables(args)
    print_vip_cfg_variables(args)
    print_user_seq_variables()
    print("")


if __name__ == "__main__":
    main()
