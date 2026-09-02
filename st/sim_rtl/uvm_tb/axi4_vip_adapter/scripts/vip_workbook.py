#!/usr/bin/env python
"""Read VIP cfg JSON or flat/multi-sheet VIP cfg workbooks."""

from __future__ import print_function

import json
import os
from collections import OrderedDict

from xls_table import read_table, read_workbook, split_table_ref


VIP_SECTIONS = ("axi", "support", "checker", "coverage")
FINAL_VIP_SHEET = "FINAL_FEATURE"


def value_type(value):
    if isinstance(value, bool):
        return "bool"
    if isinstance(value, int):
        return "int"
    if value is None:
        return "null"
    return "string"


def value_text(value):
    if isinstance(value, bool):
        return str(value).lower()
    if value is None:
        return "null"
    return str(value)


def parse_int(text, label):
    try:
        return int(str(text).replace("_", ""), 0)
    except ValueError:
        raise ValueError("%s must be an integer, got %s" % (label, text))


def parse_value(text, type_text, label):
    raw = str(text).strip()
    kind = str(type_text).strip().lower()
    if kind == "":
        if raw.lower() in ("true", "false"):
            kind = "bool"
        elif raw.lower() == "null":
            kind = "null"
        else:
            try:
                parse_int(raw, label)
                kind = "int"
            except ValueError:
                kind = "string"

    if kind == "bool":
        if raw.lower() in ("1", "true", "yes", "y", "on"):
            return True
        if raw.lower() in ("0", "false", "no", "n", "off"):
            return False
        raise ValueError("%s must be bool, got %s" % (label, text))
    if kind == "int":
        return parse_int(raw, label)
    if kind == "null":
        if raw.lower() not in ("", "null"):
            raise ValueError("%s must be null, got %s" % (label, text))
        return None
    if kind == "json":
        return json.loads(raw)
    if kind == "string":
        return raw
    raise ValueError("%s has unsupported type %s" % (label, type_text))


def load_json_cfg(path):
    with open(path, "r") as cfg_file:
        return json.load(cfg_file, object_pairs_hook=OrderedDict)


def load_vip_cfg(ref):
    path, sheet_name = split_table_ref(ref)
    if os.path.splitext(path)[1].lower() == ".json":
        return load_json_cfg(path)

    if sheet_name:
        fieldnames, rows = read_table(ref)
        if "section" in fieldnames and "key" in fieldnames and "value" in fieldnames:
            return load_flat_vip_cfg(ref, rows)

    workbook = read_workbook(path)
    if not sheet_name and FINAL_VIP_SHEET in workbook:
        fieldnames, rows = workbook[FINAL_VIP_SHEET]
        if "section" in fieldnames and "key" in fieldnames and "value" in fieldnames:
            return load_flat_vip_cfg("%s::%s" % (path, FINAL_VIP_SHEET), rows)

    cfg = OrderedDict()
    for section in VIP_SECTIONS:
        table_ref = "%s::%s" % (path, section)
        fieldnames, rows = read_table(table_ref)
        if "key" not in fieldnames or "value" not in fieldnames:
            raise ValueError("%s requires columns key and value" % table_ref)
        section_cfg = OrderedDict()
        for row_num, row in enumerate(rows, start=2):
            key = str(row.get("key", "")).strip()
            if not key:
                continue
            label = "%s row %d key %s" % (table_ref, row_num, key)
            section_cfg[key] = parse_value(row.get("value", ""), row.get("type", ""), label)
        cfg[section] = section_cfg
    return cfg


def load_flat_vip_cfg(ref, rows):
    cfg = OrderedDict()
    seen = set()
    for row_num, row in enumerate(rows, start=2):
        section = str(row.get("section", "")).strip()
        key = str(row.get("key", "")).strip()
        if not section and not key:
            continue
        if not section or not key:
            raise ValueError("%s row %d requires section and key" % (ref, row_num))
        identity = "%s.%s" % (section, key)
        if identity in seen:
            raise ValueError("%s contains duplicate parameter %s" % (ref, identity))
        seen.add(identity)
        if section not in cfg:
            cfg[section] = OrderedDict()
        label = "%s row %d parameter %s" % (ref, row_num, identity)
        cfg[section][key] = parse_value(row.get("value", ""), row.get("type", ""), label)
    return cfg
