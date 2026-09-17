#!/usr/bin/env python
"""Generate the configurable AXI4 interrupt handler sequence from docs/txt/irq_seq.txt."""

import argparse
import os
import re
import shlex


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


def clean(value):
    if value is None:
        return ""
    return value.strip()


def parse_int_text(value, key, line_num):
    text = clean(value).replace("_", "")
    try:
        return int(text, 0)
    except ValueError:
        if re.match(r"^[0-9A-Fa-f]+$", text) and re.search(r"[A-Fa-f]", text):
            return int(text, 16)
        raise ValueError(
            "%s:%d key '%s' must be an integer or hex value, got %s"
            % ("docs/txt/irq_seq.txt", line_num, key, value)
        )


def sv_int(value):
    if isinstance(value, (int, long)):
        return str(value)
    if not isinstance(value, basestring):
        raise ValueError("Expected int or hex string, got %r" % (value,))
    text = value.replace("_", "")
    if text.lower().startswith("0x"):
        return "'h%s" % text[2:]
    return value


def require_key(fields, key, op, line_num):
    value = clean(fields.get(key))
    if value == "":
        raise ValueError("docs/txt/irq_seq.txt:%d op=%s requires key '%s'" % (line_num, op, key))
    return value


def optional_gap(fields, line_num):
    value = clean(fields.get("gap"))
    if value == "":
        return ""
    level = value.upper()
    if level == "RAND":
        level = "RANDOM"
    if level not in GAP_LEVELS + GAP_RANDOM_VALUES:
        raise ValueError(
            "docs/txt/irq_seq.txt:%d gap must be one of %s, got %s"
            % (line_num, "/".join(GAP_LEVELS + GAP_RANDOM_VALUES), value)
        )
    return level


def sv_gap_wait_call(gap):
    return 'axi_wait_tr_gap_text("%s");' % gap


def parse_line(line, line_num):
    tokens = shlex.split(line, comments=True)
    if not tokens:
        return None

    op = ""
    if "=" not in tokens[0]:
        op = tokens.pop(0).lower()

    fields = {}
    for token in tokens:
        if "=" not in token:
            raise ValueError(
                "docs/txt/irq_seq.txt:%d token must be key=value, got %s" % (line_num, token)
            )
        key, value = token.split("=", 1)
        key = key.strip().lower()
        if key in fields:
            raise ValueError("docs/txt/irq_seq.txt:%d duplicates key '%s'" % (line_num, key))
        fields[key] = value

    if not op:
        op = clean(fields.pop("op", "")).lower()
    if op not in ("write", "read"):
        raise ValueError("docs/txt/irq_seq.txt:%d op must be write or read, got %s" % (line_num, op))

    allowed = set(["addr", "data", "expect", "strb", "gap", "comment"])
    unknown = sorted([key for key in fields if key not in allowed])
    if unknown:
        raise ValueError("docs/txt/irq_seq.txt:%d unknown keys: %s" % (line_num, ", ".join(unknown)))

    step = {
        "op": op,
        "addr": require_key(fields, "addr", op, line_num),
        "gap": optional_gap(fields, line_num),
        "comment": clean(fields.get("comment")),
        "line_num": line_num,
    }
    parse_int_text(step["addr"], "addr", line_num)

    if op == "write":
        if clean(fields.get("expect")):
            raise ValueError("docs/txt/irq_seq.txt:%d op=write must not set expect" % line_num)
        data = require_key(fields, "data", op, line_num)
        parse_int_text(data, "data", line_num)
        step["data"] = data
        strb = clean(fields.get("strb"))
        if strb:
            parse_int_text(strb, "strb", line_num)
            step["strb"] = strb
    else:
        if clean(fields.get("data")) or clean(fields.get("strb")):
            raise ValueError("docs/txt/irq_seq.txt:%d op=read must not set data or strb" % line_num)
        expect = require_key(fields, "expect", op, line_num)
        parse_int_text(expect, "expect", line_num)
        step["expect"] = expect

    return step


def load_steps(path):
    steps = []
    with open(path, "r") as in_file:
        for line_num, line in enumerate(in_file, start=1):
            step = parse_line(line, line_num)
            if step is not None:
                steps.append(step)
    if not steps:
        raise ValueError("%s does not contain any interrupt handler operations" % path)
    return steps


def emit_step(step, idx):
    lines = []
    comment = step.get("comment") or "from docs/txt/irq_seq.txt line %d" % step["line_num"]
    lines.append("      // step %d: %s" % (idx, comment))

    if step["op"] == "write":
        lines.append(
            "      axi_write_checked(%s, %s, %s);"
            % (
                sv_int(step["addr"]),
                sv_int(step["data"]),
                sv_int(step.get("strb", "AXI_DEFAULT_STRB")),
            )
        )
    elif step["op"] == "read":
        lines.append("      axi_read(%s, rdata);" % sv_int(step["addr"]))
        lines.extend(
            [
                "      if (rdata !== %s) begin" % sv_int(step["expect"]),
                (
                    "        `uvm_error(get_type_name(), $sformatf("
                    "\"IRQ read mismatch at addr=0x%%0h expected=0x%%0h got=0x%%0h\", "
                    "%s, %s, rdata))"
                )
                % (sv_int(step["addr"]), sv_int(step["expect"])),
                "      end else begin",
                (
                    "        `uvm_info(get_type_name(), $sformatf("
                    "\"IRQ read match at addr=0x%%0h expected=0x%%0h got=0x%%0h\", "
                    "%s, %s, rdata), UVM_LOW)"
                )
                % (sv_int(step["addr"]), sv_int(step["expect"])),
                "      end",
            ]
        )
    else:
        raise ValueError("Unsupported op: %s" % step["op"])

    if step.get("gap"):
        lines.append("      %s" % sv_gap_wait_call(step["gap"]))
    return lines


def emit_sequence(steps, source_path):
    lines = [
        "// Auto-generated by scripts/gen_irq_seq.py from %s. Do not edit by hand." % source_path,
        "  class axi4_irq_handler_seq extends axi4_sequence_base;",
        "    `uvm_object_utils(axi4_irq_handler_seq)",
        "",
        "    function new(string name = \"axi4_irq_handler_seq\");",
        "      super.new(name);",
        "    endfunction",
        "",
        "    task body();",
        "      bit [AXI_DATA_WIDTH-1:0] rdata;",
        "      `uvm_info(get_type_name(), \"Handle interrupt using generated irq sequence\", UVM_LOW)",
    ]
    for idx, step in enumerate(steps):
        lines.extend(emit_step(step, idx))
    lines.extend(
        [
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


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--txt", default="docs/txt/irq_seq.txt")
    parser.add_argument("--out", default="tb/generated/axi4_irq_handler_seq.svh")
    args = parser.parse_args()

    steps = load_steps(args.txt)
    write_lines(args.out, emit_sequence(steps, args.txt))
    print("Generated %s from %s with %d interrupt steps" % (args.out, args.txt, len(steps)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
