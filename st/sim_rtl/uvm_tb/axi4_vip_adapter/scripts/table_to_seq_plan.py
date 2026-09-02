#!/usr/bin/env python
"""Convert sequence Excel tables into docs/seq/seq_plan.json."""

import argparse
import json
import os
import re

from xls_table import read_table


SV_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")
GAP_LEVELS = ("MIN", "MID", "HIGH", "MAX")
GAP_MODES = ("FIXED", "RANDOM", "RAND", "UNIFORM", "WEIGHTED")
VALID_WRITE_MODES = (
    "FULL_ADDR_FULL_BYTE",
    "FULL_ADDR_SINGLE_BYTE",
    "SINGLE_ADDR_SINGLE_BYTE",
)
DEFAULT_WRITE_MODE = "FULL_ADDR_FULL_BYTE"
REQUIRED_COLUMNS = ("seq_name", "step", "op")
OPTIONAL_COLUMNS = (
    "seq_description",
    "seq_gap",
    "addr_mode",
    "addr",
    "addr_stride",
    "count",
    "data",
    "data_file",
    "data_start",
    "expect",
    "readback",
    "tr_gap",
    "write_mode",
)
METADATA_COLUMNS = (
    "base_seq",
    "change_para",
    "changed_params",
    "change_seq_description",
    "change_seq_gap",
    "change_addr",
    "change_data",
    "change_expect",
    "change_tr_gap",
    "change_addr_stride",
    "change_count",
    "change_data_file",
    "change_data_start",
    "change_readback",
    "change_write_mode",
)
RANGE_COLUMNS = (
    "addr_stride",
    "count",
    "data_file",
    "data_start",
    "readback",
)


def clean(value):
    if value is None:
        return ""
    return value.strip()


def require_ident(name, row_num):
    if not SV_IDENT.match(name):
        raise ValueError("Row %d has invalid sequence name: %s" % (row_num, name))
    return name


def require_value(row, key, row_num):
    value = clean(row.get(key))
    if value == "":
        raise ValueError("Row %d op=%s requires column '%s'" % (row_num, row.get("op"), key))
    return value


def optional_value(row, key):
    return clean(row.get(key))


def parse_int_text(value, key, row_num):
    text = clean(value).replace("_", "")
    try:
        return int(text, 0)
    except ValueError:
        if re.match(r"^[0-9A-Fa-f]+$", text) and re.search(r"[A-Fa-f]", text):
            return int(text, 16)
        raise ValueError(
            "Row %d column '%s' must be an integer or hex value, got %s"
            % (row_num, key, value)
        )


def load_data_width(path):
    if not os.path.exists(path):
        raise ValueError("Missing active VIP cfg: %s. Run `make vip_cfg` first." % path)
    with open(path, "r") as cfg_file:
        cfg = json.load(cfg_file)
    value = cfg.get("axi", {}).get("data_width", 32)
    try:
        data_width = int(str(value), 0)
    except ValueError:
        raise ValueError("axi.data_width must be an integer, got %s" % value)
    if data_width < 8 or data_width % 8 != 0:
        raise ValueError("axi.data_width must be a positive multiple of 8, got %d" % data_width)
    return data_width


def hex_value(value, width=None):
    digits = 8 if width is None else max(1, (width + 3) // 4)
    return "0x%0*X" % (digits, value)


def optional_gap(row, key, row_num):
    value = clean(row.get(key))
    if value == "":
        return None
    level = value.upper()
    if level == "RAND":
        level = "RANDOM"
    if level not in GAP_MODES + GAP_LEVELS:
        raise ValueError(
            "Row %d column '%s' must be one of FIXED/RANDOM, got %s"
            % (row_num, key, value)
        )
    return level


def parse_addr_mode(row, row_num):
    mode = optional_value(row, "addr_mode").lower()
    if mode == "":
        return "range" if any(optional_value(row, key) for key in RANGE_COLUMNS) else "single"
    if mode not in ("single", "range"):
        raise ValueError("Row %d column 'addr_mode' must be single or range, got %s" % (row_num, mode))
    return mode


def single_addr_value(row, row_num):
    mode = parse_addr_mode(row, row_num)
    addr = require_value(row, "addr", row_num)

    if mode == "single":
        blocked = [key for key in RANGE_COLUMNS if optional_value(row, key)]
        if blocked:
            raise ValueError(
                "Row %d addr_mode=single must not set range-only columns: %s"
                % (row_num, ", ".join(blocked))
            )
        return addr

    return addr


def require_width_value(value, key, row_num, width):
    data = parse_int_text(value, key, row_num)
    if data < 0 or data >= (1 << width):
        raise ValueError(
            "Row %d column '%s' must fit axi.data_width=%d bits"
            % (row_num, key, width)
        )
    return data


def write_by_mode_step(addr, data, write_mode, data_width):
    return {
        "op": "write_by_mode",
        "addr": hex_value(addr),
        "data": hex_value(data, data_width),
        "write_mode": write_mode,
    }


def expand_write_mode(row, row_num, write_mode, data_width):
    blocked = [key for key in ("data_file",) if optional_value(row, key)]
    if blocked:
        raise ValueError(
                "Row %d columns %s are no longer used by table-generated sequences. "
                "Use addr_mode=range for file-driven or multi-address operations."
            % (row_num, ", ".join(blocked))
        )

    steps = []
    addr = single_addr_value(row, row_num)
    addr_int = parse_int_text(addr, "addr", row_num)
    data_int = require_width_value(
        require_value(row, "data", row_num), "data", row_num, data_width
    )

    if write_mode not in VALID_WRITE_MODES:
        raise ValueError("Row %d has unsupported write_mode: %s" % (row_num, write_mode))

    steps.append(
        write_by_mode_step(
            addr_int,
            data_int,
            write_mode,
            data_width,
        )
    )
    return steps


def optional_uint(row, key, row_num, default_value=None):
    value = optional_value(row, key)
    if value == "":
        return default_value
    parsed = parse_int_text(value, key, row_num)
    if parsed < 0:
        raise ValueError("Row %d column '%s' must be >= 0" % (row_num, key))
    return parsed


def optional_bool(row, key, row_num, default_value):
    value = optional_value(row, key)
    if value == "":
        return default_value
    text = value.lower()
    if text in ("1", "true", "yes", "y", "on"):
        return True
    if text in ("0", "false", "no", "n", "off"):
        return False
    raise ValueError("Row %d column '%s' must be 0/1/true/false, got %s" % (row_num, key, value))


def optional_write_mode(row, row_num):
    value = optional_value(row, "write_mode")
    if value == "":
        return DEFAULT_WRITE_MODE
    mode = value.upper()
    if mode not in VALID_WRITE_MODES:
        raise ValueError(
            "Row %d column 'write_mode' must be one of %s, got %s"
            % (row_num, "/".join(VALID_WRITE_MODES), value)
        )
    return mode


def require_addr_stride(row, row_num):
    stride_text = optional_value(row, "addr_stride")
    if stride_text == "":
        raise ValueError("Row %d addr_mode=range requires column 'addr_stride'" % row_num)
    stride = parse_int_text(stride_text, "addr_stride", row_num)
    if stride <= 0:
        raise ValueError("Row %d column 'addr_stride' must be > 0" % row_num)
    return stride_text


def range_count(row, row_num):
    count = optional_uint(row, "count", row_num)
    if count is None:
        raise ValueError("Row %d addr_mode=range requires column 'count'" % row_num)
    if count == 0:
        raise ValueError("Row %d column 'count' must be > 0 for addr_mode=range" % row_num)
    return count


def range_step(row, row_num, op, write_mode):
    step = {
        "op": "range_%s" % op,
        "addr": require_value(row, "addr", row_num),
        "addr_stride": require_addr_stride(row, row_num),
        "count": range_count(row, row_num),
    }

    if op == "write":
        if optional_value(row, "data") or optional_value(row, "expect"):
            raise ValueError(
                "Row %d addr_mode=range op=write uses data_file, not data/expect"
                % row_num
            )
        step.update(
            {
                "write_mode": write_mode,
                "data_file": require_value(row, "data_file", row_num),
                "data_start": optional_uint(row, "data_start", row_num, 0),
                "readback": optional_bool(row, "readback", row_num, True),
            }
        )
        return step

    if op == "read":
        if write_mode is not None:
            raise ValueError("Row %d column 'write_mode' is only valid for op=write" % row_num)
        if optional_value(row, "data") or optional_value(row, "expect"):
            raise ValueError(
                "Row %d addr_mode=range op=read uses data_file, not data/expect"
                % row_num
            )
        data_file = optional_value(row, "data_file")
        if data_file == "":
            raise ValueError("Row %d addr_mode=range op=read requires data_file" % row_num)
        step.update(
            {
                "data_file": data_file,
                "data_start": optional_uint(row, "data_start", row_num, 0),
            }
        )
        return step

    raise ValueError("Row %d addr_mode=range supports only op=write or op=read" % row_num)


def parse_sequence(row, row_num, current_seq_name):
    seq_name_text = clean(row.get("seq_name"))
    desc = clean(row.get("seq_description"))
    seq_gap_text = clean(row.get("seq_gap"))

    if seq_name_text:
        seq_name = require_ident(seq_name_text, row_num)
        seq_gap = optional_gap(row, "seq_gap", row_num) if seq_gap_text else None
        return seq_name, desc, seq_gap

    if desc or seq_gap_text:
        raise ValueError(
            "Row %d has seq_description or seq_gap without seq_name. "
            "For merged sequence rows, leave all three sequence columns blank."
            % row_num
        )

    if current_seq_name:
        return current_seq_name, "", None

    raise ValueError("Row %d has blank seq_name before any sequence starts" % row_num)


def parse_step(row, row_num, data_width):
    op = require_value(row, "op", row_num).lower()
    common = {}
    tr_gap = optional_gap(row, "tr_gap", row_num)
    if tr_gap:
        common["tr_gap"] = tr_gap

    if op == "write":
        write_mode = optional_write_mode(row, row_num)
    else:
        if optional_value(row, "write_mode"):
            raise ValueError("Row %d column 'write_mode' is only valid for op=write" % row_num)
        write_mode = None

    mode = parse_addr_mode(row, row_num)

    if mode == "range":
        steps = [range_step(row, row_num, op, write_mode)]
    elif optional_value(row, "data_file"):
        raise ValueError(
            "Row %d data_file requires addr_mode=range for table-generated sequences."
            % row_num
        )
    elif op == "write" and optional_value(row, "expect"):
        raise ValueError(
            "Row %d op=write must not set expect; add a separate op=read row"
            % row_num
        )
    elif op == "write":
        steps = expand_write_mode(row, row_num, write_mode, data_width)
    elif op == "read":
        addr = single_addr_value(row, row_num)
        expect = require_width_value(
            require_value(row, "expect", row_num), "expect", row_num, data_width
        )
        steps = [{"op": op, "addr": addr, "expect": hex_value(expect, data_width)}]
    else:
        raise ValueError(
            "Row %d has unsupported op: %s. wait op has been removed; use tr_gap or seq_gap instead."
            % (row_num, op)
        )

    for step in steps:
        step.update(common)

    order_text = clean(row.get("step"))
    order = int(order_text, 0) if order_text else row_num
    return order, steps


def convert(table_paths, data_width=32):
    sequences = []
    by_name = {}
    for table_path in table_paths:
        current_seq_name = None
        fieldnames, rows = read_table(table_path)
        is_user_table = "base_seq" in fieldnames
        missing = [name for name in REQUIRED_COLUMNS if name not in fieldnames]
        if missing:
            raise ValueError(
                "%s is missing required table columns: %s"
                % (table_path, ", ".join(missing))
            )
        allowed = set(REQUIRED_COLUMNS + OPTIONAL_COLUMNS + METADATA_COLUMNS)
        extra = [name for name in fieldnames if name not in allowed]
        if extra:
            raise ValueError(
                "%s has unsupported table columns: %s"
                % (table_path, ", ".join(extra))
            )

        for row_num, row in enumerate(rows, start=2):
            if not any(clean(value) for value in row.values() if value is not None):
                continue

            seq_name, desc, seq_gap = parse_sequence(row, row_num, current_seq_name)
            current_seq_name = seq_name
            order, row_steps = parse_step(row, row_num, data_width)
            if seq_name not in by_name:
                seq = {
                    "name": seq_name,
                    "description": desc,
                    "seq_gap": seq_gap if seq_gap is not None else 0,
                    "source": "user" if is_user_table else "base",
                    "_seq_gap_set": seq_gap is not None,
                    "_ordered_steps": [],
                }
                by_name[seq_name] = seq
                sequences.append(seq)
            elif desc and by_name[seq_name].get("description", "") != desc:
                raise ValueError(
                    "%s row %d changes description for sequence %s"
                    % (table_path, row_num, seq_name)
                )
            elif seq_gap is not None:
                current_seq = by_name[seq_name]
                if current_seq.get("_seq_gap_set") and current_seq.get("seq_gap") != seq_gap:
                    raise ValueError(
                        "%s row %d changes seq_gap for sequence %s"
                        % (table_path, row_num, seq_name)
                    )
                current_seq["seq_gap"] = seq_gap
                current_seq["_seq_gap_set"] = True
            for sub_idx, step in enumerate(row_steps):
                by_name[seq_name]["_ordered_steps"].append((order, row_num, sub_idx, step))

    for seq in sequences:
        ordered_steps = sorted(seq.pop("_ordered_steps"), key=lambda item: (item[0], item[1], item[2]))
        seq.pop("_seq_gap_set")
        seq["steps"] = [step for _, _, _, step in ordered_steps]

    run_all_sequences = [
        seq["name"]
        for seq in sequences
        if seq.get("source") == "user"
    ]

    return {
        "generated_package": "axi4_generated_seq_pkg",
        "top_sequence": "axi4_doc_plan_seq",
        "axi_data_width": data_width,
        "run_all_sequences": run_all_sequences,
        "description": (
            "AXI4 sequence plan. Generated from base and user sequence Excel tables. "
            "Base sequences are templates; SEQ_ALL runs user sequences only. "
            "Edit Excel tables, then run `make seq_gen`."
        ),
        "sequences": sequences,
    }


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--table", action="append", dest="tables")
    parser.add_argument("--vip-cfg", default="tb/generated/axi4_vip_cfg.json")
    parser.add_argument("--out", default="docs/seq/seq_plan.json")
    args = parser.parse_args()

    table_paths = args.tables or ["docs/seq/seq_table.xlsx::BASE_SEQ"]
    data_width = load_data_width(args.vip_cfg)
    plan = convert(table_paths, data_width)
    out_dir = os.path.dirname(args.out)
    if out_dir and not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    with open(args.out, "w") as out_file:
        json.dump(plan, out_file, indent=2)
        out_file.write("\n")
    print(
        "Generated %s from %s with axi.data_width=%d"
        % (args.out, ", ".join(table_paths), data_width)
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
