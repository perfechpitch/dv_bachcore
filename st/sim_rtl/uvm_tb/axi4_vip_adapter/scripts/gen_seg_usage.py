#!/usr/bin/env python3
from __future__ import print_function

import argparse
import os
from collections import OrderedDict

from gen_seq_cfg import load_usage_cfg
from xls_table import (
    XLSX_STYLE_CONFIG_VALUE,
    read_table,
    read_workbook,
    split_table_ref,
    table_file_exists,
    write_workbook,
)


FIELDNAMES = (
    "item",
    "value",
    "usage",
    "config_source",
    "current_value",
    "edit_rule",
)


SEQ_COLUMNS = (
    ("seq_name", "", "Sequence name. Fill only on the first row of a sequence.", "Required for the first row."),
    ("seq_description", "", "Short description printed by uvm_info.", "Optional; fill only on the first row."),
    ("seq_gap", "FIXED or RANDOM", "Gap used between sequences only when a generated plan runs multiple sequences in one simulation.", "Use FIXED/RANDOM only."),
    ("step", "0, 1, 2, ...", "Step order inside one sequence.", "Required and must be unique within a sequence."),
    ("op", "write or read", "Operation type.", "Use write/read only."),
    ("addr_mode", "single or range", "Address style.", "single uses addr; range uses addr/addr_stride/count."),
    ("addr", "hex value", "AXI address or range base address.", "Required for write/read rows."),
    ("data", "hex value", "Write data for single-address write.", "Required for single write; must fit FINAL_FEATURE axi.data_width."),
    ("expect", "hex value", "Expected read data.", "Required for single read; must fit FINAL_FEATURE axi.data_width."),
    ("tr_gap", "FIXED or RANDOM", "Gap inserted after each transaction.", "Use FIXED/RANDOM only."),
    ("addr_stride", "hex value", "Address stride for range rows.", "Required for range rows."),
    ("count", "integer", "Number of range accesses.", "Required for range rows."),
    ("data_file", "txt path", "Memory data file used by range write/read.", "Required for range write/read."),
    ("data_start", "integer, 0-based", "Start index in data_file for range rows.", "Required for range rows."),
    ("readback", "0 or 1", "Whether range write performs readback.", "Optional; default is 1."),
    ("write_mode", "FULL_ADDR_FULL_BYTE/FULL_ADDR_SINGLE_BYTE/SINGLE_ADDR_SINGLE_BYTE", "Write expansion mode for write rows.", "Optional for write rows; default is FULL_ADDR_FULL_BYTE."),
)
USER_SEQ_COLUMNS = (
    ("base_seq", "base seq name or MANUAL", "Source base seq for make-generated rows; MANUAL is used for table-authored user seq.", "For hand-written user seq, leave blank or set MANUAL; make seq_gen will normalize it."),
    ("change_para", "auto-generated", "Readable change summary. For MANUAL seq this lists the filled step parameters.", "Leave blank; make seq_gen fills it."),
)


MAKE_COMMANDS = (
    ("make help", "Show Makefile help."),
    ("make vip_cfg", "Merge DUT overrides with base defaults, then generate FINAL_FEATURE, JSON, SV cfg, and the selected AXI VIP filelist."),
    ("make seq_gen", "Run make vip_cfg first, then regenerate seq cfg, usage sheets, seq plan, irq seq, and generated seq SV."),
    ("make user_seq BASE_SEQ=<base_seq> NEW_SEQ=<new_seq> [addr=<addr>] [data=<data>]", "Create or replace a user seq, run seq_gen, then compile/run NEW_SEQ; roll back the table if validation fails."),
    ("make clear_user_seq", "Clear all user seq records from the user table, then run seq_gen."),
    ("make clear_user_seq USER_SEQ=<seq_name>", "Remove one user seq record from the user table, then run seq_gen."),
    ("make clean", "Remove simulator outputs, logs, and waveform files."),
    ("make SEQ_ALL", "Run make seq_gen, then compile and run every user seq as an independent simulation under work/SEQ_ALL/<seq_name>."),
    ("make seq_all", "Lowercase alias of make SEQ_ALL."),
    ("make SEQ=<seq_name>", "Run make seq_gen first, check the selected seq exists in the generated plan, then compile and run it."),
    ("make SEQ=<seq_name> write_mode=<mode>", "Run one selected seq with a runtime write-mode override."),
    ("make user_seq BASE_SEQ=<base_seq> NEW_SEQ=<new_seq> write_mode=<mode>", "Create a user seq, write write_mode into seq_table.xlsx::USER_SEQ, then compile and run it."),
    ("make SEQ_ALL <seq_name> verdi", "Open work/SEQ_ALL/<seq_name>/axi4_bfm.fsdb without compiling or simulating."),
    ("make SEQ=<seq_name> verdi", "Open the existing waveform in Verdi without compiling or simulating."),
)


MAKE_VARIABLES = (
    ("TEST=<uvm_test_name>", "Selected UVM test."),
    ("SEQ=<seq_name>", "Selected generated seq for single-seq run."),
    ("IRQ_EN=0|1", "Default 0. Set 1 to enable interrupt rising-edge detection, the generated interrupt handler sequence, and the post-seq IRQ wait; supported by make user_seq, make SEQ=<seq_name>, and make SEQ_ALL."),
    ("write_mode=<mode>", "Set generated user-seq write_mode, or override one run."),
    ("range_write_mode=<mode>", "Alias for write_mode during user_seq; range-only write-mode override for normal run."),
    ("RUN_AFTER_USER_SEQ=0|1", "Set 0 to create a user seq without compiling/running it."),
    ("WAVE=0|1", "Set 0 to run without FSDB dump."),
    ("WORK_ROOT=<dir>", "Root directory for per-run outputs; default is work."),
    ("SEQ_ALL_WORK_DIR=<dir>", "Parent directory for independent SEQ_ALL runs; default is work/SEQ_ALL."),
    ("RUN_SIMV=<file>", "Simulator executable path; single run uses work/<SEQ>/simv and SEQ_ALL uses work/SEQ_ALL/<SEQ>/simv."),
    ("RUN_CSRC_DIR=<dir>", "VCS compile work directory; SEQ_ALL creates one csrc directory per seq."),
    ("COMPILE_LOG=<file.log>", "VCS compile log in the selected seq output directory."),
    ("WAVE_FILE=<file.fsdb>", "Waveform in the selected seq output directory."),
    ("RUN_LOG=<file.log>", "Simulator output in the selected seq output directory; checked for non-zero UVM_ERROR/UVM_FATAL."),
    ("VERDI=<verdi_cmd>", "Verdi executable."),
    ("VERDI_ARGS='<args>'", "Extra arguments passed to Verdi."),
    ("NOVAS_PLI_DIR=<dir>", "Optional path to Verdi share/PLI/VCS/LINUX64."),
    ("PYTHON=<python_cmd>", "Python executable; auto-detect python3, otherwise python."),
    ("VCS=<vcs_cmd>", "VCS executable."),
    ("VIP_WORKBOOK=<file.xlsx>", "Three-sheet VIP cfg workbook path."),
    ("BASE_VIP_CFG=<file.xlsx::sheet>", "Base VIP defaults sheet."),
    ("DUT_VIP_CFG=<file.xlsx::sheet>", "DUT override input sheet; blank values use defaults."),
    ("FINAL_VIP_CFG=<file.xlsx::sheet>", "Generated final VIP cfg sheet used by seq generation."),
    ("BASE_SEQ_TABLE=<file.xlsx::sheet>", "Base seq sheet path."),
    ("USER_SEQ_TABLE=<file.xlsx::sheet>", "User seq sheet path."),
    ("TABLE_USAGE=<file.xlsx::sheet>", "Seq table usage and gap configuration sheet path."),
    ("MAKE_USAGE=<file.xlsx::sheet>", "Makefile command and variable usage sheet path."),
)


USER_SEQ_UPDATES = (
    ("BASE_SEQ=<seq_name>", "Base sequence copied from docs/seq/seq_table.xlsx::BASE_SEQ."),
    ("NEW_SEQ=<seq_name>", "New or replacement user sequence written to docs/seq/seq_table.xlsx::USER_SEQ."),
    ("seq_description='<text>'", "Override seq_description in the new user seq."),
    ("seq_gap=FIXED|RANDOM", "Override seq gap in the new user seq."),
    ("addr=<addr>", "Update all address cells in the copied seq."),
    ("data=<data>", "Update single-address write data; read expect follows data when expect is not set."),
    ("expect=<data>", "Update single-address read expect."),
    ("addr_list=<addr0,addr1,...>", "Expand a single-address base seq into multiple address/data operations."),
    ("data_list=<data0,data1,...>", "Data values used with addr_list; count must match addr_list."),
    ("expect_list=<data0,data1,...>", "Optional read expect values for addr_list; defaults to data_list."),
    ("tr_gap=FIXED|RANDOM", "Override transaction gap cells in the copied seq."),
    ("addr_stride=<stride>", "Override range addr_stride."),
    ("count=<n>", "Override range count."),
    ("data_file=<path>", "Override range data_file."),
    ("data_start=<idx>", "Override range data_start."),
    ("readback=0|1", "Override range readback."),
    ("write_mode=<mode>", "Set write_mode cells in the generated user seq; default is FULL_ADDR_FULL_BYTE."),
    ("range_write_mode=<mode>", "Alias of write_mode when creating a user seq."),
    ("OVERRIDES='addr=0x800 data=0x55 tr_gap=RANDOM'", "Compact lowercase key=value form; supported keys match the lowercase names above."),
)


def row(_section, item, value, usage, config_source="", current_value="", edit_rule=""):
    return {
        "item": item,
        "value": value,
        "usage": usage,
        "config_source": config_source,
        "current_value": current_value,
        "edit_rule": edit_rule,
    }


def clean_value(value):
    if isinstance(value, dict):
        return "; ".join("%s:%s" % (key, value[key]) for key in sorted(value, key=lambda item: int(item)))
    return str(value)


def level_summary(level_cfg):
    min_cycles = level_cfg.get("min_cycles", "")
    max_cycles = level_cfg.get("max_cycles", "")
    weight = level_cfg.get("weight", "")
    return "range=[%s,%s]; level_weight=%s" % (min_cycles, max_cycles, weight)


def build_table_rows(cfg, usage_path, base_seq_table, user_seq_table):
    rows = []
    rows.append(row("table.part", "1", "seq_table", "Seq table columns and gap configuration."))
    for item, value, usage, edit_rule in SEQ_COLUMNS:
        rows.append(
            row(
                "table.column",
                item,
                value,
                usage,
                "%s or %s" % (base_seq_table, user_seq_table),
                "",
                edit_rule,
            )
        )
    for item, value, usage, edit_rule in USER_SEQ_COLUMNS:
        rows.append(
            row(
                "table.user_column",
                item,
                value,
                usage,
                user_seq_table,
                "",
                edit_rule,
            )
        )

    gap_cfg = cfg.get("gap", {})
    fixed_cycles = gap_cfg.get("fixed_cycles", 2)
    default_policy = gap_cfg.get("default_policy", "WEIGHTED")
    rows.extend(
        [
            row(
                "table.gap_mode",
                "FIXED",
                "FIXED",
                "Deterministic gap. The same cycle count is used every time.",
                "%s: gap.fixed_cycles" % usage_path,
                "%s cycles" % fixed_cycles,
                "Edit this row current_value, then run make seq_gen.",
            ),
            row(
                "table.gap_mode",
                "RANDOM",
                "RANDOM",
                "Random gap. The level is selected by gap.default_policy, then cycle_weights choose the cycle.",
                "%s: gap.default_policy" % usage_path,
                default_policy,
                "Edit this row current_value; use UNIFORM or WEIGHTED.",
            ),
        ]
    )

    levels = gap_cfg.get("levels", {})
    for level in ("MIN", "MID", "HIGH", "MAX"):
        level_cfg = levels.get(level, {})
        rows.append(
            row(
                "table.random_level",
                level,
                "RANDOM internal level",
                "Selected internally when seq_table gap is RANDOM.",
                "%s: gap.levels.%s" % (usage_path, level),
                level_summary(level_cfg),
                "Edit this row current_value.",
            )
        )
        rows.append(
            row(
                "table.random_cycle_weights",
                "%s.cycle_weights" % level,
                "RANDOM internal cycle",
                "Weighted cycle selection after this random level is selected.",
                "%s: gap.levels.%s.cycle_weights" % (usage_path, level),
                clean_value(level_cfg.get("cycle_weights", {})),
                "Edit this row current_value; every cycle in the range must have one weight.",
            )
        )
    return rows


def build_make_rows(args):
    rows = [row("make.part", "2", "makefile", "Makefile commands and runtime controls.")]

    for value, usage in MAKE_COMMANDS:
        rows.append(row("make.command", value, value, usage, "Makefile"))
    for value, usage in MAKE_VARIABLES:
        current = ""
        if value.startswith("TEST="):
            current = args.test
        elif value.startswith("IRQ_EN="):
            current = "0"
        elif value.startswith("VIP_WORKBOOK="):
            current = args.vip_workbook
        elif value.startswith("BASE_VIP_CFG="):
            current = args.base_vip_cfg
        elif value.startswith("DUT_VIP_CFG="):
            current = args.dut_vip_cfg
        elif value.startswith("FINAL_VIP_CFG="):
            current = args.final_vip_cfg
        elif value.startswith("BASE_SEQ_TABLE="):
            current = args.base_seq_table
        elif value.startswith("USER_SEQ_TABLE="):
            current = args.user_seq_table
        elif value.startswith("TABLE_USAGE="):
            current = args.out
        elif value.startswith("MAKE_USAGE="):
            current = args.make_out
        rows.append(row("make.variable", value.split("=", 1)[0], value, usage, "Makefile", current))
    for value, usage in USER_SEQ_UPDATES:
        rows.append(row("make.user_seq_update", value.split("=", 1)[0], value, usage, "make user_seq"))

    rows.append(row("make.write_mode", "FULL_ADDR_FULL_BYTE", "FULL_ADDR_FULL_BYTE", "One full-width write, wstrb='1."))
    rows.append(row("make.write_mode", "FULL_ADDR_SINGLE_BYTE", "FULL_ADDR_SINGLE_BYTE", "One write per byte lane to the same address."))
    rows.append(row("make.write_mode", "SINGLE_ADDR_SINGLE_BYTE", "SINGLE_ADDR_SINGLE_BYTE", "One byte write per byte address; generated read rows are skipped."))
    return rows


def can_read_table(ref):
    if not table_file_exists(ref):
        return False
    try:
        read_table(ref)
        return True
    except ValueError:
        return False


def table_usage_cell_styles(rows):
    return dict(
        ((index, "current_value"), XLSX_STYLE_CONFIG_VALUE)
        for index, usage_row in enumerate(rows)
        if ": gap." in str(usage_row.get("config_source", ""))
    )


def write_usage_sheets(table_ref, make_ref, table_rows, make_rows):
    table_path, table_sheet = split_table_ref(table_ref)
    make_path, make_sheet = split_table_ref(make_ref)
    table_sheet = table_sheet or "TABLE_USAGE"
    make_sheet = make_sheet or "MAKE_USAGE"
    table_cell_styles = table_usage_cell_styles(table_rows)

    if table_path != make_path:
        sheets = OrderedDict([(table_sheet, (FIELDNAMES, table_rows, None, table_cell_styles))])
        write_workbook(table_path, sheets)
        sheets = OrderedDict([(make_sheet, (FIELDNAMES, make_rows))])
        write_workbook(make_path, sheets)
        return

    if os.path.exists(table_path):
        sheets = read_workbook(table_path)
    else:
        sheets = OrderedDict()
    if "SEG_USAGE" not in (table_sheet, make_sheet):
        sheets.pop("SEG_USAGE", None)
    sheets[table_sheet] = (FIELDNAMES, table_rows, None, table_cell_styles)
    sheets[make_sheet] = (FIELDNAMES, make_rows)
    write_workbook(table_path, sheets)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--vip-workbook", default="docs/vip/vip_cfg.xlsx")
    parser.add_argument("--plan", default="docs/seq/seq_plan.json")
    parser.add_argument("--out", default="docs/seq/seq_table.xlsx::TABLE_USAGE")
    parser.add_argument("--make-out", default="docs/seq/seq_table.xlsx::MAKE_USAGE")
    parser.add_argument("--legacy-usage", default="docs/seq/seq_table.xlsx::SEG_USAGE")
    parser.add_argument("--base-seq-table", default="docs/seq/seq_table.xlsx::BASE_SEQ")
    parser.add_argument("--user-seq-table", default="docs/seq/seq_table.xlsx::USER_SEQ")
    parser.add_argument("--base-vip-cfg", default="docs/vip/vip_cfg.xlsx::BASE_VIP_CFG")
    parser.add_argument("--dut-vip-cfg", default="docs/vip/vip_cfg.xlsx::DUT_BUFF_FEATURE")
    parser.add_argument("--final-vip-cfg", default="docs/vip/vip_cfg.xlsx::FINAL_FEATURE")
    parser.add_argument("--test", default="axi4_doc_test")
    args = parser.parse_args()

    cfg_ref = args.out if can_read_table(args.out) else args.legacy_usage
    cfg = load_usage_cfg(cfg_ref)
    table_rows = build_table_rows(cfg, args.out, args.base_seq_table, args.user_seq_table)
    make_rows = build_make_rows(args)

    write_usage_sheets(args.out, args.make_out, table_rows, make_rows)

    print("Generated table usage sheet: %s" % args.out)
    print("Generated make usage sheet: %s" % args.make_out)
    print("Gap settings were loaded from %s" % cfg_ref)


if __name__ == "__main__":
    main()
