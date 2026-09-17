#!/usr/bin/env python
"""Generate AXI4 UVM sequences from docs/seq/seq_plan.json."""

import argparse
import json
import os
import re

from sequence_plan import normalize_plan


SV_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")
GAP_LEVELS = ("MIN", "MID", "HIGH", "MAX")
GAP_RANDOM_VALUES = ("FIXED", "RANDOM", "RAND", "UNIFORM", "WEIGHTED")

try:
    long
except NameError:
    long = int

try:
    basestring
except NameError:
    basestring = str


def sv_int(value):
    if isinstance(value, (int, long)):
        return "'h%x" % value if value >= 0 else str(value)
    if not isinstance(value, basestring):
        raise ValueError("Expected int or hex string, got %r" % (value,))
    text = value.replace("_", "")
    if text.lower().startswith("0x"):
        return "'h%s" % text[2:]
    return value


def sv_bits(value, width):
    return "%s'(%s)" % (width, sv_int(value))


def sv_string(value):
    text = "" if value is None else str(value)
    return '"%s"' % text.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t")


def sv_bool(value):
    return "1'b1" if value else "1'b0"


def require_ident(name):
    if not SV_IDENT.match(name):
        raise ValueError("Invalid SystemVerilog identifier: %s" % name)
    return name


def sv_gap_wait_call(value, gap_kind):
    task_prefix = "axi_wait_%s_gap" % gap_kind.lower()
    if isinstance(value, (int, long)):
        if isinstance(value, bool) or value < 0 or value > 0xffffffff:
            raise ValueError("Gap cycles must be an unsigned 32-bit integer")
        if value:
            return "%s_cycles(%d);" % (task_prefix, value)
        return ""
    if isinstance(value, basestring):
        level = value.strip().upper()
        if level == "":
            return ""
        if level == "RAND":
            level = "RANDOM"
        if level not in GAP_LEVELS + GAP_RANDOM_VALUES:
            raise ValueError("Invalid gap level: %s" % value)
        return "%s_text(%s);" % (task_prefix, sv_string(level))
    if value is None:
        return ""
    raise ValueError("Expected gap level string or int, got %r" % (value,))


def range_step_indices(seq):
    return [
        (idx, step)
        for idx, step in enumerate(seq.get("steps", []))
        if step.get("op") in ("range_write", "range_read")
    ]


def emit_range_controls(range_steps):
    lines = []
    for idx, step in range_steps:
        prefix = "range%d" % idx
        lines.extend(
            [
                "    // Range step %d controls. Edit these defaults, or override with +range_* plusargs." % idx,
                "    bit [AXI_ADDR_WIDTH-1:0] %s_base_addr = %s;" % (prefix, sv_bits(step["addr"], "AXI_ADDR_WIDTH")),
                "    bit [AXI_ADDR_WIDTH-1:0] %s_addr_stride = %s;" % (prefix, sv_bits(step["addr_stride"], "AXI_ADDR_WIDTH")),
                "    int unsigned %s_count = %d;" % (prefix, int(step.get("count", 0))),
                "    int unsigned %s_data_start = %d;" % (prefix, int(step.get("data_start", 0))),
                "    bit %s_readback_enable = %s;" % (prefix, sv_bool(step.get("readback", True))),
                "    string %s_data_file = %s;" % (prefix, sv_string(step.get("data_file", ""))),
                "    axi_write_mode_e %s_write_mode = %s;" % (prefix, step.get("write_mode", "FULL_ADDR_FULL_BYTE")),
                "    string %s_gap = %s;" % (prefix, sv_string(step.get("tr_gap", ""))),
                "",
            ]
        )
    return lines


def emit_range_plusarg_task(idx, check_readback=False):
    prefix = "range%d" % idx
    return [
        "    task apply_%s_plusargs();" % prefix,
        "      string value_text;",
        "      bit range_plusarg_used;",
        "      bit addr_stride_plusarg_set;",
        "",
        "      range_plusarg_used = 1'b0;",
        "      addr_stride_plusarg_set = 1'b0;",
        "      %s_write_mode = axi_write_mode_from_plusargs(%s_write_mode);" % (prefix, prefix),
      "      if ($value$plusargs(\"range_base_addr=%s\", value_text) ||",
      "          $value$plusargs(\"RANGE_BASE_ADDR=%s\", value_text)) begin",
      "        range_plusarg_used = 1'b1;",
      "        %s_base_addr = axi_parse_addr_text(value_text, \"range_base_addr\");" % prefix,
      "      end",
      "      if ($value$plusargs(\"range_addr_stride=%s\", value_text) ||",
      "          $value$plusargs(\"RANGE_ADDR_STRIDE=%s\", value_text)) begin",
      "        range_plusarg_used = 1'b1;",
      "        addr_stride_plusarg_set = 1'b1;",
        "        %s_addr_stride = axi_parse_addr_text(value_text, \"range_addr_stride\");" % prefix,
        "      end",
        "      if ($value$plusargs(\"range_count=%s\", value_text) ||",
        "          $value$plusargs(\"RANGE_COUNT=%s\", value_text)) begin",
        "        range_plusarg_used = 1'b1;",
        "        %s_count = axi_parse_uint_text(value_text, \"range_count\");" % prefix,
        "      end",
        "      if ($value$plusargs(\"range_data_start=%s\", value_text) ||",
        "          $value$plusargs(\"RANGE_DATA_START=%s\", value_text)) begin",
        "        range_plusarg_used = 1'b1;",
        "        %s_data_start = axi_parse_uint_text(value_text, \"range_data_start\");" % prefix,
        "      end",
        "      if ($value$plusargs(\"range_readback=%s\", value_text) ||",
        "          $value$plusargs(\"RANGE_READBACK=%s\", value_text)) begin",
        "        range_plusarg_used = 1'b1;",
        "        %s_readback_enable = axi_parse_bit_text(value_text, \"range_readback\");" % prefix,
        "      end",
        "      if ($value$plusargs(\"range_data_file=%%s\", %s_data_file) ||" % prefix,
        "          $value$plusargs(\"RANGE_DATA_FILE=%%s\", %s_data_file)) begin" % prefix,
        "        range_plusarg_used = 1'b1;",
        "      end",
        "      if ($value$plusargs(\"range_write_mode=%s\", value_text) ||",
        "          $value$plusargs(\"RANGE_WRITE_MODE=%s\", value_text)) begin",
        "        range_plusarg_used = 1'b1;",
        "        %s_write_mode = axi_write_mode_from_text(value_text);" % prefix,
        "      end",
        "      if ($value$plusargs(\"range_gap=%%s\", %s_gap) ||" % prefix,
        "          $value$plusargs(\"RANGE_GAP=%%s\", %s_gap)) begin" % prefix,
        "        range_plusarg_used = 1'b1;",
        "      end",
        "      if (range_plusarg_used && !addr_stride_plusarg_set) begin",
        "        `uvm_fatal(get_type_name(), \"range_addr_stride must be set when using range_* plusargs\")",
        "      end",
        "      if (%s_count == 0) begin" % prefix,
        "        `uvm_fatal(get_type_name(), \"range_count must be > 0\")",
        "      end",
        "      if (%s_addr_stride == '0) begin" % prefix,
        "        `uvm_fatal(get_type_name(), \"range_addr_stride must be > 0\")",
        "      end",
        "      axi_check_range(%s_base_addr, %s_addr_stride, %s_count, %s_write_mode, %s);" % (prefix, prefix, prefix, prefix, prefix + "_readback_enable" if check_readback else "1'b0"),
        "    endtask",
        "",
    ]


def emit_range_write(step_idx):
    prefix = "range%d" % step_idx
    return [
        "      apply_%s_plusargs();" % prefix,
        "      axi_load_mem_window(%s_data_file, %s_data_start, %s_count, %s_data_values);" % (prefix, prefix, prefix, prefix),
        "      if (%s_readback_enable) begin" % prefix,
        "          %s_expect_values = %s_data_values;" % (prefix, prefix),
        "      end",
        "      `uvm_info(get_type_name(), $sformatf(\"Range write: write_mode=%%s addr=0x%%0h count=%%0d stride=0x%%0h file=%%s start=%%0d readback=%%0d\", axi_write_mode_name(%s_write_mode), %s_base_addr, %s_count, %s_addr_stride, %s_data_file, %s_data_start, %s_readback_enable), UVM_LOW)" % (prefix, prefix, prefix, prefix, prefix, prefix, prefix),
        "      for (int idx = 0; idx < %s_count; idx++) begin" % prefix,
        "        %s_current_addr = %s_base_addr + idx * %s_addr_stride;" % (prefix, prefix, prefix),
        "        axi_write_by_mode_with_gap(%s_current_addr, %s_data_values[idx], %s_write_mode, %s_gap);" % (prefix, prefix, prefix, prefix),
        "      end",
        "      if (%s_readback_enable) begin" % prefix,
        "        for (int idx = 0; idx < %s_count; idx++) begin" % prefix,
        "          %s_current_addr = %s_base_addr + idx * %s_addr_stride;" % (prefix, prefix, prefix),
        "          axi_read_by_mode_checked(%s_current_addr, %s_expect_values[idx], %s_write_mode);" % (prefix, prefix, prefix),
        "          axi_wait_tr_gap_text(%s_gap);" % prefix,
        "        end",
        "      end",
    ]


def emit_range_read(step_idx):
    prefix = "range%d" % step_idx
    return [
        "      apply_%s_plusargs();" % prefix,
        "      axi_load_mem_window(%s_data_file, %s_data_start, %s_count, %s_expect_values);" % (prefix, prefix, prefix, prefix),
        "      `uvm_info(get_type_name(), $sformatf(\"Range read: addr=0x%%0h count=%%0d stride=0x%%0h data_file=%%s data_start=%%0d\", %s_base_addr, %s_count, %s_addr_stride, %s_data_file, %s_data_start), UVM_LOW)" % (prefix, prefix, prefix, prefix, prefix),
        "      for (int idx = 0; idx < %s_count; idx++) begin" % prefix,
        "        %s_current_addr = %s_base_addr + idx * %s_addr_stride;" % (prefix, prefix, prefix),
        "        axi_read_by_mode_checked(%s_current_addr, %s_expect_values[idx], %s_write_mode);" % (prefix, prefix, prefix),
        "        axi_wait_tr_gap_text(%s_gap);" % prefix,
        "      end",
    ]


def emit_sequence(seq, profile=None):
    name = require_ident(seq["name"])
    desc = seq.get("description", "")
    ranges = range_step_indices(seq)
    lines = [
        "  class %s extends axi4_sequence_base;" % name,
        "    `uvm_object_utils(%s)" % name,
        "",
    ]
    if ranges:
        lines.extend(emit_range_controls(ranges))
    lines.extend(
        [
        "    function new(string name = \"%s\");" % name,
        "      super.new(name);",
        "    endfunction",
        "",
        ]
    )
    for idx, step in ranges:
        lines.extend(emit_range_plusarg_task(idx, step["op"] == "range_write"))
    lines.extend(
        [
        "    task body();",
        "      bit [AXI_DATA_WIDTH-1:0] rdata;",
        "      axi_write_mode_e effective_write_mode;",
        "      axi_write_mode_e last_write_mode;",
        ]
    )
    for idx, step in enumerate(seq.get("steps", [])):
        if step.get("op") in ("submit_write", "submit_read"):
            lines.append("      axi4_completion seq_handle_%d;" % idx)
    for idx, _ in ranges:
        prefix = "range%d" % idx
        lines.extend(
            [
                "      bit [AXI_DATA_WIDTH-1:0] %s_data_values[$];" % prefix,
                "      bit [AXI_DATA_WIDTH-1:0] %s_expect_values[$];" % prefix,
                "      bit [AXI_ADDR_WIDTH-1:0] %s_current_addr;" % prefix,
            ]
        )
    lines.extend(
        [
        "      `uvm_info(get_type_name(), %s, UVM_LOW)" % sv_string(desc),
        "      last_write_mode = FULL_ADDR_FULL_BYTE;",
        ]
    )
    if profile is not None:
        checks = ["%s != %d" % (sv, profile[key]) for sv, key in
                  (("AXI_DATA_WIDTH", "axi_data_width"),
                   ("AXI_ADDR_WIDTH", "axi_addr_width"),
                   ("AXI_ID_WIDTH", "axi_id_width"),
                   ("AXI_LEN_WIDTH", "axi_len_width"))]
        lines += ["      if (%s) begin" % " || ".join(checks),
                  '        `uvm_fatal(get_type_name(), "Sequence plan widths differ from compiled VIP; regenerate using the active profile")',
                  "      end"]
    pending = []
    for idx, step in enumerate(seq.get("steps", [])):
        op = step.get("op")
        comment = step.get("comment", "")
        if comment:
            lines.extend("      // step %d: %s" % (idx, line) for line in str(comment).splitlines())
        if op in ("submit_write", "submit_read"):
            lines.extend(emit_submit(step, idx))
            pending.append((idx, step))
        elif op == "await_all":
            for submit_idx, submitted in pending:
                lines.extend(emit_await(submitted, submit_idx))
            pending = []
        elif op == "write":
            lines.append(
                "      axi_write_checked("
                "%s, %s, %s);"
                % (
                    sv_bits(step["addr"], "AXI_ADDR_WIDTH"),
                    sv_bits(step["data"], "AXI_DATA_WIDTH"),
                    sv_bits(step.get("strb", "AXI_DEFAULT_STRB"), "AXI_STRB_WIDTH"),
                )
            )
            lines.append("      last_write_mode = FULL_ADDR_FULL_BYTE;")
        elif op == "write_by_mode":
            lines.extend(
                [
                    "      effective_write_mode = axi_write_mode_from_plusargs(%s);" % step["write_mode"],
                    (
                        "      `uvm_info(get_type_name(), $sformatf("
                        "\"Write by mode: write_mode=%%s addr=0x%%0h data=0x%%0h\", "
                        "axi_write_mode_name(effective_write_mode), %s, %s), UVM_LOW)"
                    )
                    % (sv_bits(step["addr"], "AXI_ADDR_WIDTH"), sv_bits(step["data"], "AXI_DATA_WIDTH")),
                    "      axi_write_by_mode_with_gap(%s, %s, effective_write_mode, %s);"
                    % (
                        sv_bits(step["addr"], "AXI_ADDR_WIDTH"),
                        sv_bits(step["data"], "AXI_DATA_WIDTH"),
                        sv_string(step.get("tr_gap", "")),
                    ),
                    "      last_write_mode = effective_write_mode;",
                ]
            )
        elif op == "read":
            lines.extend(
                [
                    "      begin",
                    "        axi_read_by_mode(%s, rdata, last_write_mode);" % sv_bits(step["addr"], "AXI_ADDR_WIDTH"),
                ]
            )
            if "expect" in step:
                lines.extend(
                    [
                        "        if (rdata !== %s) begin" % sv_bits(step["expect"], "AXI_DATA_WIDTH"),
                        (
                            "          `uvm_error(get_type_name(), $sformatf("
                            "\"Read mismatch at addr=0x%%0h expected=0x%%0h got=0x%%0h\", "
                            "%s, %s, rdata))"
                        )
                        % (sv_bits(step["addr"], "AXI_ADDR_WIDTH"), sv_bits(step["expect"], "AXI_DATA_WIDTH")),
                        "        end else begin",
                        (
                            "          `uvm_info(get_type_name(), $sformatf("
                            "\"Read match at addr=0x%%0h expected=0x%%0h got=0x%%0h\", "
                            "%s, %s, rdata), UVM_LOW)"
                        )
                        % (sv_bits(step["addr"], "AXI_ADDR_WIDTH"), sv_bits(step["expect"], "AXI_DATA_WIDTH")),
                        "        end",
                    ]
                )
            tr_gap_call = sv_gap_wait_call(step.get("tr_gap", 0), "tr")
            if tr_gap_call:
                lines.append("        %s" % tr_gap_call)
            lines.append("      end")
        elif op == "range_write":
            lines.extend(emit_range_write(idx))
        elif op == "range_read":
            lines.extend(emit_range_read(idx))
        else:
            raise ValueError("Unsupported op in %s: %r" % (name, op))
        tr_gap_call = "" if op in ("range_write", "range_read", "write_by_mode", "read") else sv_gap_wait_call(step.get("tr_gap", 0), "tr")
        if tr_gap_call:
            lines.append("      %s" % tr_gap_call)
    # A sequence owns only its own completions; never drain another sequence/IRQ.
    for submit_idx, submitted in pending:
        lines.extend(emit_await(submitted, submit_idx))
    lines.extend(
        [
            "    endtask",
            "  endclass",
            "",
        ]
    )
    return lines


def sized_hex(value, kind):
    # Explicit context avoids unsized integer truncation for 256-bit payloads.
    return "%s'('h%x)" % (kind, value)


def emit_submit(step, idx):
    args = [sized_hex(step["addr"], "AXI_ADDR_WIDTH"),
            sized_hex(step["id"], "AXI_ID_WIDTH"), str(step["size"])]
    if step["op"] == "submit_read":
        return ["      axi_submit_read_payload(%s, %d, seq_handle_%d);" %
                (", ".join(args), step["beats"], idx)]
    lines = ["      begin", "        logic [AXI_DATA_WIDTH-1:0] payload[];",
             "        logic [AXI_STRB_WIDTH-1:0] strobes[];",
             "        payload = new[%d];" % step["beats"],
             "        strobes = new[%d];" % step["beats"]]
    for beat, value in enumerate(step["data"]):
        lines.append("        payload[%d] = %s;" % (beat, sized_hex(value, "AXI_DATA_WIDTH")))
        lines.append("        strobes[%d] = %s;" % (beat, sized_hex(step["strb"][beat], "AXI_STRB_WIDTH")))
    lines += ["        axi_submit_write_payload(%s, payload, strobes, seq_handle_%d);" %
              (", ".join(args), idx), "      end"]
    return lines


def emit_await(step, idx):
    response = step.get("expect_resp", 0)
    if step["op"] == "submit_write":
        return ["      axi_wait_write_checked(seq_handle_%d, 2'd%d);" % (idx, response)]
    expected = step.get("expect", [])
    masks = step.get("expect_mask", [])
    lines = ["      begin", "        logic [AXI_DATA_WIDTH-1:0] expected[];",
             "        logic [AXI_DATA_WIDTH-1:0] masks[];",
             "        expected = new[%d];" % len(expected),
             "        masks = new[%d];" % len(masks)]
    for beat, value in enumerate(expected):
        lines.append("        expected[%d] = %s;" % (beat, sized_hex(value, "AXI_DATA_WIDTH")))
        lines.append("        masks[%d] = %s;" % (beat, sized_hex(masks[beat], "AXI_DATA_WIDTH")))
    lines += ["        axi_wait_read_checked(seq_handle_%d, %s, %d, expected, masks, 2'd%d);" %
              (idx, sized_hex(step["addr"], "AXI_ADDR_WIDTH"), step["size"], response), "      end"]
    return lines


def emit_plan_sequence(plan, sequences):
    name = require_ident(plan.get("top_sequence", "axi4_doc_plan_seq"))
    desc = plan.get("top_sequence_description", "Run all user-generated AXI4 sequences in table order.")
    child_names = [require_ident(seq["name"]) for seq in sequences]
    seq_gaps = [seq.get("seq_gap", 0) for seq in sequences]
    run_all_names = [require_ident(seq_name) for seq_name in plan.get("run_all_sequences", child_names)]
    unknown_run_all = [seq_name for seq_name in run_all_names if seq_name not in child_names]
    if unknown_run_all:
        raise ValueError("run_all_sequences contains unknown seq: %s" % ", ".join(unknown_run_all))
    run_all_set = set(run_all_names)
    run_all_indices = [idx for idx, child_name in enumerate(child_names) if child_name in run_all_set]
    valid_seq_text = ", ".join(["all"] + child_names)
    lines = [
        "  class %s extends axi4_sequence_base;" % name,
        "    `uvm_object_utils(%s)" % name,
        "",
        "    function new(string name = \"%s\");" % name,
        "      super.new(name);",
        "    endfunction",
        "",
        "    task body();",
        "      string selected_seq;",
        "      bit run_all;",
        "      bit matched;",
    ]

    for idx, child_name in enumerate(child_names):
        lines.append("      %s seq_%d;" % (child_name, idx))

    lines.extend(
        [
            "      run_all = !$value$plusargs(\"SEQ=%s\", selected_seq);",
            "      run_all = run_all || selected_seq == \"all\" || selected_seq == \"ALL\";",
            "      matched = 1'b0;",
            "      if (run_all) begin",
        ]
    )
    if run_all_names:
        lines.extend(
            [
            "        `uvm_info(get_type_name(), %s, UVM_LOW)" % sv_string(desc),
            ]
        )
    else:
        lines.extend(
            [
            "        matched = 1'b1;",
            "        `uvm_fatal(get_type_name(), \"SEQ_ALL has no user-generated sequences. Create one with make user_seq, or run a base seq explicitly with make SEQ=<seq_name>.\")",
            ]
        )
    lines.extend(
        [
            "      end else begin",
            "        `uvm_info(get_type_name(), $sformatf(\"Run selected AXI4 sequence: %s\", selected_seq), UVM_LOW)",
            "      end",
            "",
        ]
    )
    for idx, child_name in enumerate(child_names):
        run_all_clause = "run_all" if child_name in run_all_set else "1'b0"
        lines.extend(
            [
                "      if ((%s) || selected_seq == \"%s\") begin" % (run_all_clause, child_name),
                "        matched = 1'b1;",
                "        seq_%d = %s::type_id::create(\"seq_%d\");" % (idx, child_name, idx),
                "        seq_%d.start(p_sequencer);" % idx,
                "        `uvm_info(get_type_name(), \"----------------------------------------------------------\", UVM_LOW)",
            ]
        )
        seq_gap_call = sv_gap_wait_call(seq_gaps[idx], "seq")
        if idx in run_all_indices[:-1] and seq_gap_call:
            lines.append("        if (run_all) begin %s end" % seq_gap_call)
        lines.append("      end")

    lines.extend(
        [
            "      if (!matched) begin",
            "        `uvm_fatal(get_type_name(), $sformatf(\"Unknown SEQ='%%s'. Valid values: %%s\", selected_seq, \"%s\"))" % valid_seq_text,
            "      end",
            "    endtask",
            "  endclass",
            "",
        ]
    )
    return lines


def write_lines(path, lines):
    out_dir = os.path.dirname(path)
    if out_dir and not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    with open(path, "w") as out_file:
        out_file.write("\n".join(lines))


def reset_seq_dir(seq_dir):
    if not os.path.isdir(seq_dir):
        os.makedirs(seq_dir)
        return
    for name in os.listdir(seq_dir):
        if name.endswith(".svh"):
            os.remove(os.path.join(seq_dir, name))


def seq_file_name(seq_name):
    return "%s.svh" % require_ident(seq_name)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", default="docs/seq/seq_plan.json")
    parser.add_argument("--out", default="tb/generated/axi4_generated_seq_pkg.sv")
    parser.add_argument("--seq-dir", default="tb/generated/seqs")
    args = parser.parse_args()

    with open(args.plan, "r") as plan_file:
        plan = normalize_plan(json.load(plan_file))
    package = require_ident(plan.get("generated_package", "axi4_generated_seq_pkg"))
    sequences = plan.get("sequences", [])
    top_seq_name = require_ident(plan.get("top_sequence", "axi4_doc_plan_seq"))

    rendered = []
    include_files = []
    for seq in sequences:
        seq_name = require_ident(seq["name"])
        file_name = seq_file_name(seq_name)
        if file_name in include_files or seq_name == top_seq_name:
            raise ValueError("Duplicate sequence/top name: %s" % seq_name)
        rendered.append((file_name,
            ["// Auto-generated by scripts/gen_axi4_seq.py. Do not edit by hand."] + emit_sequence(seq, plan),
        ))
        include_files.append(file_name)

    top_file_name = seq_file_name(top_seq_name)
    rendered.append((top_file_name,
        ["// Auto-generated by scripts/gen_axi4_seq.py. Do not edit by hand."]
        + emit_plan_sequence(plan, sequences),
    ))
    include_files.append(top_file_name)

    lines = [
        "// Auto-generated by scripts/gen_axi4_seq.py. Do not edit by hand.",
        "package %s;" % package,
        "  import uvm_pkg::*;",
        "  `include \"uvm_macros.svh\"",
        "  import axi4_vip_adapter_pkg::*;",
        "",
    ]
    for file_name in include_files:
        lines.append("  `include \"%s\"" % file_name)
    lines.append("endpackage : %s" % package)
    lines.append("")

    # Complete all validation/rendering before touching prior generated output.
    reset_seq_dir(args.seq_dir)
    for file_name, seq_lines in rendered:
        write_lines(os.path.join(args.seq_dir, file_name), seq_lines)
    write_lines(args.out, lines)
    print("Generated %s and %d seq files from %s" % (args.out, len(include_files), args.plan))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
