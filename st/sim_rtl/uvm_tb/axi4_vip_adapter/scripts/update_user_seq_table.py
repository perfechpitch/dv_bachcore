#!/usr/bin/env python
"""Create or update a user seq table sheet from a base sequence and make variables."""

from __future__ import print_function

import argparse
import os
import re
import shlex

from xls_table import read_table, table_file_exists, write_grouped_table


SV_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")
VALID_WRITE_MODES = (
    "FULL_ADDR_FULL_BYTE",
    "FULL_ADDR_SINGLE_BYTE",
    "SINGLE_ADDR_SINGLE_BYTE",
)
GAP_MODES = ("FIXED", "RANDOM")
DEFAULT_WRITE_MODE = "FULL_ADDR_FULL_BYTE"
MANUAL_BASE_SEQ = "MANUAL"
MANUAL_BASE_MARKERS = ("", "MANUAL", "USER", "CUSTOM", "TABLE")
TABLE_COLUMNS = (
    "seq_name",
    "seq_description",
    "seq_gap",
    "step",
    "op",
    "addr_mode",
    "addr",
    "data",
    "expect",
    "tr_gap",
    "addr_stride",
    "count",
    "data_file",
    "data_start",
    "readback",
    "write_mode",
)
METADATA_COLUMNS = (
    "base_seq",
    "change_para",
)
ALL_COLUMNS = TABLE_COLUMNS + METADATA_COLUMNS
LEGACY_METADATA_COLUMNS = (
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
RANGE_ONLY_COLUMNS = (
    "addr_stride",
    "count",
    "data_file",
    "data_start",
    "readback",
)
RUNTIME_ONLY_VARS = ()
ENV_TO_COLUMN = (
    ("SEQ_DESCRIPTION", "seq_description"),
    ("seq_description", "seq_description"),
    ("SEQ_DESC", "seq_description"),
    ("seq_desc", "seq_description"),
    ("SEQ_GAP", "seq_gap"),
    ("seq_gap", "seq_gap"),
    ("ADDR", "addr"),
    ("addr", "addr"),
    ("BASE_ADDR", "addr"),
    ("base_addr", "addr"),
    ("RANGE_BASE_ADDR", "addr"),
    ("range_base_addr", "addr"),
    ("DATA", "data"),
    ("data", "data"),
    ("EXPECT", "expect"),
    ("expect", "expect"),
    ("TR_GAP", "tr_gap"),
    ("tr_gap", "tr_gap"),
    ("RANGE_GAP", "tr_gap"),
    ("range_gap", "tr_gap"),
    ("ADDR_STRIDE", "addr_stride"),
    ("addr_stride", "addr_stride"),
    ("RANGE_ADDR_STRIDE", "addr_stride"),
    ("range_addr_stride", "addr_stride"),
    ("COUNT", "count"),
    ("count", "count"),
    ("RANGE_COUNT", "count"),
    ("range_count", "count"),
    ("DATA_FILE", "data_file"),
    ("data_file", "data_file"),
    ("RANGE_DATA_FILE", "data_file"),
    ("range_data_file", "data_file"),
    ("DATA_START", "data_start"),
    ("data_start", "data_start"),
    ("RANGE_DATA_START", "data_start"),
    ("range_data_start", "data_start"),
    ("READBACK", "readback"),
    ("readback", "readback"),
    ("RANGE_READBACK", "readback"),
    ("range_readback", "readback"),
    ("WRITE_MODE", "write_mode"),
    ("write_mode", "write_mode"),
    ("RANGE_WRITE_MODE", "write_mode"),
    ("range_write_mode", "write_mode"),
    ("WRITE_TR_MODE", "write_mode"),
    ("write_tr_mode", "write_mode"),
    ("TR_WRITE_MODE", "write_mode"),
    ("tr_write_mode", "write_mode"),
)
LIST_ENV_NAMES = {
    "addr": ("addr_list", "addrs", "single_addr_list", "ADDR_LIST", "ADDRS", "SINGLE_ADDR_LIST"),
    "data": ("data_list", "datas", "single_data_list", "DATA_LIST", "DATAS", "SINGLE_DATA_LIST"),
    "expect": ("expect_list", "expects", "single_expect_list", "EXPECT_LIST", "EXPECTS", "SINGLE_EXPECT_LIST"),
}
KEY_ALIASES = {
    "seq_description": "seq_description",
    "seq_desc": "seq_description",
    "description": "seq_description",
    "seq_gap": "seq_gap",
    "addr": "addr",
    "base_addr": "addr",
    "range_base_addr": "addr",
    "data": "data",
    "expect": "expect",
    "tr_gap": "tr_gap",
    "range_gap": "tr_gap",
    "addr_stride": "addr_stride",
    "range_addr_stride": "addr_stride",
    "count": "count",
    "range_count": "count",
    "data_file": "data_file",
    "range_data_file": "data_file",
    "data_start": "data_start",
    "range_data_start": "data_start",
    "readback": "readback",
    "range_readback": "readback",
    "write_mode": "write_mode",
    "range_write_mode": "write_mode",
    "write_tr_mode": "write_mode",
    "tr_write_mode": "write_mode",
}
CHANGE_VALUE_LABELS = {
    "seq_description": "Description",
    "seq_gap": "Seq_gap",
    "addr": "Addr",
    "data": "data",
    "expect": "Expect",
    "tr_gap": "Tr_gap",
    "addr_stride": "Addr_stride",
    "count": "Count",
    "data_file": "Data_file",
    "data_start": "Data_start",
    "readback": "Readback",
    "write_mode": "Write_mode",
}


def clean(value):
    if value is None:
        return ""
    return str(value).strip()


def clean_write_mode(value):
    mode = clean(value).upper()
    if mode == "":
        return ""
    if mode not in VALID_WRITE_MODES:
        raise ValueError(
            "write_mode must be one of %s, got %s"
            % ("/".join(VALID_WRITE_MODES), value)
        )
    return mode


def clean_gap_mode(value, label):
    mode = clean(value).upper()
    if mode == "":
        return ""
    if mode not in GAP_MODES:
        raise ValueError("%s must be FIXED or RANDOM, got %s" % (label, value))
    return mode


def is_blank_row(row):
    return not any(clean(value) for value in row.values() if value is not None)


def require_ident(value, label):
    if not SV_IDENT.match(value):
        raise ValueError("%s must be a valid SystemVerilog identifier, got %s" % (label, value))


def normalized_row(row):
    normalized = dict((name, clean(row.get(name))) for name in ALL_COLUMNS)
    if clean(normalized.get("op")).lower() == "write" and clean(normalized.get("write_mode")) == "":
        normalized["write_mode"] = DEFAULT_WRITE_MODE
    if clean(normalized.get("op")).lower() != "write":
        normalized["write_mode"] = ""
    return normalized


def read_sequence_list(path, require_exists):
    if not table_file_exists(path):
        if require_exists:
            raise ValueError("Missing table: %s" % path)
        return []

    sequences = []
    current_name = None
    current_rows = []
    fieldnames, rows = read_table(path)
    required_columns = tuple(name for name in TABLE_COLUMNS if name != "write_mode")
    missing = [name for name in required_columns if name not in fieldnames]
    if missing:
        raise ValueError("%s is missing table columns: %s" % (path, ", ".join(missing)))

    for row_num, row in enumerate(rows, start=2):
        if is_blank_row(row):
            continue

        row = normalized_row(row)
        row_name = clean(row.get("seq_name"))
        if row_name:
            if current_rows and row_name == current_name:
                row["seq_name"] = ""
                row["seq_description"] = ""
                row["seq_gap"] = ""
                row["base_seq"] = ""
                row["change_para"] = ""
            elif current_rows:
                sequences.append((current_name, current_rows))
                current_name = row_name
                current_rows = []
            else:
                current_name = row_name
                current_rows = []
        elif current_name is None:
            raise ValueError("%s row %d has blank seq_name before any sequence starts" % (path, row_num))
        current_rows.append(row)

    if current_rows:
        sequences.append((current_name, current_rows))
    return sequences


def add_override(overrides, sources, column, value, source):
    value = clean(value)
    if value == "":
        return
    if column not in TABLE_COLUMNS:
        raise ValueError("Unsupported override column: %s" % column)
    if column == "write_mode":
        value = clean_write_mode(value)
    old_value = overrides.get(column)
    if old_value is not None and old_value != value:
        raise ValueError(
            "Conflicting overrides for %s: %s=%s and %s=%s"
            % (column, sources[column], old_value, source, value)
        )
    overrides[column] = value
    sources[column] = source


def collect_overrides(env):
    overrides = {}
    sources = {}

    for name in RUNTIME_ONLY_VARS:
        if clean(env.get(name)):
            raise ValueError(
                "%s is a runtime-only setting and is not stored in the user seq table. "
                "Use make variable write_mode=<mode> or range_write_mode=<mode> when running simulation."
                % name
            )

    for env_name, column in ENV_TO_COLUMN:
        add_override(overrides, sources, column, env.get(env_name), env_name)

    override_text = clean(env.get("OVERRIDES"))
    if override_text:
        for token in shlex.split(override_text):
            if "=" not in token:
                raise ValueError("OVERRIDES item must be key=value, got %s" % token)
            key, value = token.split("=", 1)
            column = KEY_ALIASES.get(key.strip().lower())
            if column is None:
                raise ValueError("Unsupported OVERRIDES key: %s" % key)
            add_override(overrides, sources, column, value, "OVERRIDES.%s" % key)

    return overrides


def first_env_value(env, names):
    for name in names:
        value = clean(env.get(name))
        if value:
            return name, value
    return "", ""


def split_list_value(value, label):
    items = [clean(item) for item in value.split(",")]
    if not items or any(item == "" for item in items):
        raise ValueError("%s must be a comma-separated list without blank items" % label)
    return items


def collect_single_pairs(env):
    addr_name, addr_text = first_env_value(env, LIST_ENV_NAMES["addr"])
    data_name, data_text = first_env_value(env, LIST_ENV_NAMES["data"])
    expect_name, expect_text = first_env_value(env, LIST_ENV_NAMES["expect"])

    if expect_text and not (addr_text or data_text):
        raise ValueError("%s requires addr_list and data_list" % expect_name)
    if not addr_text and not data_text:
        return None
    if not addr_text or not data_text:
        raise ValueError("addr_list and data_list must be used together")

    addrs = split_list_value(addr_text, addr_name)
    datas = split_list_value(data_text, data_name)
    if len(addrs) != len(datas):
        raise ValueError("addr_list count (%d) must match data_list count (%d)" % (len(addrs), len(datas)))

    expects = datas
    if expect_text:
        expects = split_list_value(expect_text, expect_name)
        if len(expects) != len(addrs):
            raise ValueError(
                "expect_list count (%d) must match addr_list count (%d)"
                % (len(expects), len(addrs))
            )

    return [
        {
            "addr": addrs[index],
            "data": datas[index],
            "expect": expects[index],
        }
        for index in range(len(addrs))
    ]


def is_range_row(row):
    if clean(row.get("addr_mode")).lower() == "range":
        return True
    return any(clean(row.get(name)) for name in RANGE_ONLY_COLUMNS)


def is_command_generated_sequence(base_sequences, rows):
    if not rows:
        return False
    base_seq_name = clean(rows[0].get("base_seq"))
    return base_seq_name in base_sequences


def require_manual_value(row, column, seq_name, row_label):
    value = clean(row.get(column))
    if value == "":
        raise ValueError(
            "Manual user seq %s %s requires column '%s'. "
            "Only change_para may be left blank; unrelated op-only columns should stay blank."
            % (seq_name, row_label, column)
        )
    return value


def require_manual_blank(row, column, seq_name, row_label, reason):
    value = clean(row.get(column))
    if value != "":
        raise ValueError("Manual user seq %s %s column '%s' must be blank: %s" % (seq_name, row_label, column, reason))


def validate_manual_sequence(seq_name, rows):
    require_ident(seq_name, "manual user seq_name")
    require_manual_value(rows[0], "seq_description", seq_name, "first row")
    rows[0]["seq_gap"] = clean_gap_mode(
        require_manual_value(rows[0], "seq_gap", seq_name, "first row"),
        "Manual user seq %s seq_gap" % seq_name,
    )

    for index, row in enumerate(rows):
        row_label = "step row %d" % (index + 1)
        if index > 0:
            for column in ("seq_name", "seq_description", "seq_gap", "base_seq", "change_para"):
                require_manual_blank(row, column, seq_name, row_label, "fill sequence-level fields only on the first row")

        require_manual_value(row, "step", seq_name, row_label)
        op = require_manual_value(row, "op", seq_name, row_label).lower()
        if op not in ("write", "read"):
            raise ValueError("Manual user seq %s %s op must be write or read, got %s" % (seq_name, row_label, op))
        row["op"] = op

        addr_mode = require_manual_value(row, "addr_mode", seq_name, row_label).lower()
        if addr_mode not in ("single", "range"):
            raise ValueError(
                "Manual user seq %s %s addr_mode must be single or range, got %s"
                % (seq_name, row_label, addr_mode)
            )
        row["addr_mode"] = addr_mode
        require_manual_value(row, "addr", seq_name, row_label)
        row["tr_gap"] = clean_gap_mode(
            require_manual_value(row, "tr_gap", seq_name, row_label),
            "Manual user seq %s %s tr_gap" % (seq_name, row_label),
        )

        if addr_mode == "single":
            for column in RANGE_ONLY_COLUMNS:
                require_manual_blank(row, column, seq_name, row_label, "addr_mode=single does not use range-only columns")
            if op == "write":
                require_manual_value(row, "data", seq_name, row_label)
                require_manual_blank(row, "expect", seq_name, row_label, "op=write uses data; add a read row for expect")
                row["write_mode"] = clean_write_mode(
                    require_manual_value(row, "write_mode", seq_name, row_label)
                )
            else:
                require_manual_blank(row, "data", seq_name, row_label, "op=read uses expect, not data")
                require_manual_value(row, "expect", seq_name, row_label)
                require_manual_blank(row, "write_mode", seq_name, row_label, "write_mode is only valid for op=write")
        else:
            for column in ("addr_stride", "count", "data_file", "data_start"):
                require_manual_value(row, column, seq_name, row_label)
            require_manual_blank(row, "data", seq_name, row_label, "addr_mode=range uses data_file, not data")
            require_manual_blank(row, "expect", seq_name, row_label, "addr_mode=range uses data_file, not expect")
            if op == "write":
                require_manual_value(row, "readback", seq_name, row_label)
                row["write_mode"] = clean_write_mode(
                    require_manual_value(row, "write_mode", seq_name, row_label)
                )
            else:
                require_manual_blank(row, "readback", seq_name, row_label, "readback is only valid for range write")
                require_manual_blank(row, "write_mode", seq_name, row_label, "write_mode is only valid for op=write")


def manual_step_summary(row):
    columns = (
        "step",
        "op",
        "addr_mode",
        "addr",
        "data",
        "expect",
        "tr_gap",
        "addr_stride",
        "count",
        "data_file",
        "data_start",
        "readback",
        "write_mode",
    )
    items = ["%s=%s" % (column, clean(row.get(column))) for column in columns if clean(row.get(column))]
    return ", ".join(items)


def manual_change_para(seq_name, rows):
    lines = ["Manual seq:%s defined in user_seq table" % seq_name]
    for row in rows:
        lines.append("step%s:%s" % (clean(row.get("step")), manual_step_summary(row)))
    return "\n".join(lines)


def value_text(value):
    value = clean(value)
    if value == "":
        return "<blank>"
    return value


def change_text(column, before, after):
    label = CHANGE_VALUE_LABELS.get(column, column)
    return "%s:%s -> %s" % (label, value_text(before), value_text(after))


def record_change(changes, column, before, after):
    text = change_text(column, before, after)
    if text not in changes:
        changes.append(text)


def record_list_change(changes, column, before, values):
    values = [clean(value) for value in values if clean(value)]
    if not values:
        return
    if len(values) == 1 and clean(before) == values[0]:
        return
    record_change(changes, column, before, ",".join(values))


def change_cell(row, column, value, changes, label):
    before = clean(row.get(column))
    value = clean(value)
    if before == value:
        return False
    row[column] = value
    record_change(changes, column, before, value)
    return True


def apply_to_rows(rows, column, value, predicate, changes, explicit):
    changed_any = False
    matched_any = False
    for index, row in enumerate(rows):
        if predicate(row):
            matched_any = True
            changed_any = change_cell(row, column, value, changes, "") or changed_any
    if explicit and not matched_any:
        raise ValueError("Override %s does not match any row in base sequence" % column)
    return changed_any


def clear_following_seq_fields(rows):
    for row in rows[1:]:
        row["seq_name"] = ""
        row["seq_description"] = ""
        row["seq_gap"] = ""
        row["base_seq"] = ""
        row["change_para"] = ""


def set_first_seq_fields(rows, base_rows, base_seq_name, new_seq_name):
    rows[0]["seq_name"] = new_seq_name
    rows[0]["seq_description"] = clean(base_rows[0].get("seq_description"))
    rows[0]["seq_gap"] = clean(base_rows[0].get("seq_gap"))
    rows[0]["base_seq"] = base_seq_name
    rows[0]["change_para"] = ""
    clear_following_seq_fields(rows)


def build_single_pair_rows(base_seq_name, new_seq_name, base_rows, single_pairs, changes):
    if any(is_range_row(row) for row in base_rows):
        raise ValueError("addr_list/data_list are only valid for single-address base seq")

    write_templates = [
        row for row in base_rows
        if clean(row.get("op")).lower() == "write"
    ]
    read_templates = [
        row for row in base_rows
        if clean(row.get("op")).lower() == "read"
    ]
    if not write_templates:
        raise ValueError("addr_list/data_list require a single-address base seq with a write row")

    write_template = write_templates[0]
    read_template = read_templates[0] if read_templates else None
    rows = []
    step = 0
    for pair in single_pairs:
        write_row = normalized_row(write_template)
        write_row["step"] = str(step)
        write_row["addr"] = pair["addr"]
        write_row["data"] = pair["data"]
        write_row["expect"] = ""
        rows.append(write_row)
        step += 1

        if read_template is not None:
            read_row = normalized_row(read_template)
            read_row["step"] = str(step)
            read_row["addr"] = pair["addr"]
            read_row["data"] = ""
            read_row["expect"] = pair["expect"]
            rows.append(read_row)
            step += 1

    set_first_seq_fields(rows, base_rows, base_seq_name, new_seq_name)
    record_list_change(changes, "addr", clean(write_template.get("addr")), [pair["addr"] for pair in single_pairs])
    record_list_change(changes, "data", clean(write_template.get("data")), [pair["data"] for pair in single_pairs])
    if read_template is not None:
        record_list_change(
            changes,
            "expect",
            clean(read_template.get("expect")),
            [pair["expect"] for pair in single_pairs],
        )
    return rows


def build_user_rows(base_seq_name, new_seq_name, base_rows, overrides, single_pairs=None):
    base_rows = [normalized_row(row) for row in base_rows]
    changes = []

    if single_pairs:
        blocked = [key for key in ("addr", "data", "expect") if key in overrides]
        if blocked:
            raise ValueError(
                "Do not mix addr_list/data_list with scalar overrides: %s"
                % ", ".join(blocked)
            )
        rows = build_single_pair_rows(base_seq_name, new_seq_name, base_rows, single_pairs, changes)
    else:
        rows = [normalized_row(row) for row in base_rows]
        set_first_seq_fields(rows, base_rows, base_seq_name, new_seq_name)

    if "seq_description" in overrides:
        change_cell(rows[0], "seq_description", overrides["seq_description"], changes, "seq")
    if "seq_gap" in overrides:
        change_cell(rows[0], "seq_gap", overrides["seq_gap"], changes, "seq")

    if not single_pairs and "addr" in overrides:
        apply_to_rows(
            rows,
            "addr",
            overrides["addr"],
            lambda row: clean(row.get("addr")) != "",
            changes,
            True,
        )

    if not single_pairs and "data" in overrides:
        if any(is_range_row(row) for row in rows):
            raise ValueError("data is only valid for single-address seq. Use data_file/data_start for range seq.")
        apply_to_rows(
            rows,
            "data",
            overrides["data"],
            lambda row: clean(row.get("op")).lower() == "write",
            changes,
            True,
        )
        if "expect" not in overrides:
            apply_to_rows(
                rows,
                "expect",
                overrides["data"],
                lambda row: clean(row.get("op")).lower() == "read",
                changes,
                False,
            )

    if not single_pairs and "expect" in overrides:
        apply_to_rows(
            rows,
            "expect",
            overrides["expect"],
            lambda row: clean(row.get("op")).lower() == "read" and not is_range_row(row),
            changes,
            True,
        )

    if "tr_gap" in overrides:
        apply_to_rows(
            rows,
            "tr_gap",
            overrides["tr_gap"],
            lambda row: clean(row.get("op")) != "",
            changes,
            True,
        )

    if "write_mode" in overrides:
        apply_to_rows(
            rows,
            "write_mode",
            clean_write_mode(overrides["write_mode"]),
            lambda row: clean(row.get("op")).lower() == "write",
            changes,
            True,
        )

    for column in RANGE_ONLY_COLUMNS:
        if column in overrides:
            apply_to_rows(
                rows,
                column,
                overrides[column],
                is_range_row,
                changes,
                True,
            )

    rows[0]["change_para"] = "\n".join(changes)
    return rows


def same_step_rows(user_rows, base_rows):
    return len(user_rows) == len(base_rows)


def refresh_change_para_for_sequence(base_sequences, rows):
    if not rows:
        return
    for row in rows:
        row["change_para"] = ""

    seq_name = clean(rows[0].get("seq_name"))
    base_seq_name = clean(rows[0].get("base_seq"))
    if base_seq_name.upper() in MANUAL_BASE_MARKERS or base_seq_name not in base_sequences:
        validate_manual_sequence(seq_name, rows)
        rows[0]["base_seq"] = MANUAL_BASE_SEQ
        rows[0]["change_para"] = manual_change_para(seq_name, rows)
        return

    base_rows = [normalized_row(row) for row in base_sequences[base_seq_name]]
    user_rows = [normalized_row(row) for row in rows]
    changes = []

    if clean(user_rows[0].get("seq_description")) != clean(base_rows[0].get("seq_description")):
        record_change(
            changes,
            "seq_description",
            clean(base_rows[0].get("seq_description")),
            clean(user_rows[0].get("seq_description")),
        )
    if clean(user_rows[0].get("seq_gap")) != clean(base_rows[0].get("seq_gap")):
        record_change(changes, "seq_gap", clean(base_rows[0].get("seq_gap")), clean(user_rows[0].get("seq_gap")))

    if same_step_rows(user_rows, base_rows):
        for base_row, user_row in zip(base_rows, user_rows):
            for column in (
                "addr",
                "data",
                "expect",
                "tr_gap",
                "addr_stride",
                "count",
                "data_file",
                "data_start",
                "readback",
                "write_mode",
            ):
                before = clean(base_row.get(column))
                after = clean(user_row.get(column))
                if before != after:
                    record_change(changes, column, before, after)
    else:
        write_rows = [
            row for row in user_rows
            if clean(row.get("op")).lower() == "write"
        ]
        read_rows = [
            row for row in user_rows
            if clean(row.get("op")).lower() == "read"
        ]
        addrs = [clean(row.get("addr")) for row in write_rows if clean(row.get("addr"))]
        if not addrs:
            addrs = [clean(row.get("addr")) for row in user_rows if clean(row.get("addr"))]
        datas = [clean(row.get("data")) for row in write_rows if clean(row.get("data"))]
        expects = [clean(row.get("expect")) for row in read_rows if clean(row.get("expect"))]
        write_modes = [clean(row.get("write_mode")) for row in write_rows if clean(row.get("write_mode"))]
        base_write = next((row for row in base_rows if clean(row.get("op")).lower() == "write"), base_rows[0])
        base_read = next((row for row in base_rows if clean(row.get("op")).lower() == "read"), base_rows[-1])
        record_list_change(changes, "addr", clean(base_write.get("addr")), addrs)
        record_list_change(changes, "data", clean(base_write.get("data")), datas)
        record_list_change(changes, "expect", clean(base_read.get("expect")), expects)
        record_list_change(changes, "write_mode", clean(base_write.get("write_mode")), write_modes)

    rows[0]["change_para"] = "\n".join(changes)


def refresh_change_para(base_sequences, sequence_list):
    seen = set()
    for _, rows in sequence_list:
        seq_name = clean(rows[0].get("seq_name")) if rows else ""
        if seq_name in seen:
            raise ValueError("Duplicate user seq name in user table: %s" % seq_name)
        seen.add(seq_name)
        refresh_change_para_for_sequence(base_sequences, rows)


def write_user_table(path, sequence_list):
    row_groups = []
    for _, rows in sequence_list:
        row_groups.append([dict((name, clean(row.get(name))) for name in ALL_COLUMNS) for row in rows])
    write_grouped_table(path, ALL_COLUMNS, row_groups)


def clear_user_sequences(sequence_list, remove_seq_name):
    if remove_seq_name == "":
        removed = len(sequence_list)
        return [], removed
    require_ident(remove_seq_name, "USER_SEQ")
    kept = [(name, rows) for name, rows in sequence_list if name != remove_seq_name]
    return kept, len(sequence_list) - len(kept)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-table", default="docs/seq/seq_table.xlsx::BASE_SEQ")
    parser.add_argument("--user-table", default="docs/seq/seq_table.xlsx::USER_SEQ")
    parser.add_argument("--base-seq", default=clean(os.environ.get("BASE_SEQ")))
    parser.add_argument("--new-seq", default=clean(os.environ.get("NEW_SEQ")))
    parser.add_argument("--normalize-only", action="store_true")
    parser.add_argument("--clear-user-table", action="store_true")
    parser.add_argument("--remove-seq", default="")
    args = parser.parse_args()

    base_sequences = dict(read_sequence_list(args.base_table, True))
    user_sequences = read_sequence_list(args.user_table, False)
    refresh_change_para(base_sequences, user_sequences)

    if args.normalize_only:
        write_user_table(args.user_table, user_sequences)
        print("Normalized user sequence table: %s" % args.user_table)
        return 0

    if args.clear_user_table:
        remove_seq_name = clean(args.remove_seq)
        if remove_seq_name == "":
            remove_seq_name = clean(os.environ.get("CLEAR_SEQ"))
        if remove_seq_name == "":
            remove_seq_name = clean(os.environ.get("USER_SEQ"))
        if remove_seq_name == "":
            remove_seq_name = clean(os.environ.get("REMOVE_SEQ"))
        if remove_seq_name == "":
            remove_seq_name = clean(os.environ.get("NEW_SEQ"))
        user_sequences, removed = clear_user_sequences(user_sequences, remove_seq_name)
        write_user_table(args.user_table, user_sequences)
        if remove_seq_name:
            print(
                "Removed %d user sequence(s) named %s from %s"
                % (removed, remove_seq_name, args.user_table)
            )
        else:
            print("Cleared %d user sequence(s) from %s" % (removed, args.user_table))
        return 0

    base_seq_name = clean(args.base_seq)
    new_seq_name = clean(args.new_seq)
    if base_seq_name == "":
        raise ValueError("BASE_SEQ is required")
    if new_seq_name == "":
        raise ValueError("NEW_SEQ is required")
    require_ident(base_seq_name, "BASE_SEQ")
    require_ident(new_seq_name, "NEW_SEQ")
    if new_seq_name == base_seq_name:
        raise ValueError("NEW_SEQ must be different from BASE_SEQ")

    if base_seq_name not in base_sequences:
        raise ValueError("Cannot find BASE_SEQ=%s in %s" % (base_seq_name, args.base_table))
    if new_seq_name in base_sequences:
        raise ValueError("NEW_SEQ=%s already exists in base table" % new_seq_name)

    user_sequences = [(name, rows) for name, rows in user_sequences if name != new_seq_name]

    overrides = collect_overrides(os.environ)
    single_pairs = collect_single_pairs(os.environ)
    new_rows = build_user_rows(
        base_seq_name,
        new_seq_name,
        base_sequences[base_seq_name],
        overrides,
        single_pairs,
    )
    user_sequences.append((new_seq_name, new_rows))
    write_user_table(args.user_table, user_sequences)

    print("Recorded user sequence %s from %s into %s" % (new_seq_name, base_seq_name, args.user_table))
    print("Change para: %s" % (clean(new_rows[0].get("change_para")).replace("\n", "; ") or "none"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
