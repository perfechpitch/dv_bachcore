#!/usr/bin/env python
"""Protect the semantic contents of the BASE_VIP_CFG workbook sheet."""

from __future__ import print_function

import argparse
import hashlib
import io
import json
import os
import sys
from collections import OrderedDict

from xls_table import read_table


FIELDS = ("section", "key", "value", "type", "description")
LOCK_VERSION = 1

try:
    TEXT_TYPE = unicode
except NameError:
    TEXT_TYPE = str


def clean(value):
    if value is None:
        return TEXT_TYPE("")
    if not isinstance(value, TEXT_TYPE):
        value = TEXT_TYPE(value)
    return value.strip()


def load_rows(table_ref):
    fieldnames, source_rows = read_table(table_ref)
    missing = [name for name in FIELDS if name not in fieldnames]
    if missing:
        raise ValueError("%s requires columns: %s" % (table_ref, ", ".join(missing)))

    rows = []
    seen = set()
    for row_num, source in enumerate(source_rows, start=2):
        row = OrderedDict((name, clean(source.get(name))) for name in FIELDS)
        if not any(row.values()):
            continue
        if not row["section"] or not row["key"] or not row["type"]:
            raise ValueError(
                "%s row %d requires section, key, and type" % (table_ref, row_num)
            )
        identity = "%s.%s" % (row["section"], row["key"])
        if identity in seen:
            raise ValueError("%s contains duplicate parameter %s" % (table_ref, identity))
        seen.add(identity)
        rows.append(row)
    if not rows:
        raise ValueError("%s contains no VIP parameters" % table_ref)
    return rows


def fingerprint(rows):
    text = json.dumps(rows, ensure_ascii=True, separators=(",", ":"))
    if not isinstance(text, bytes):
        text = text.encode("utf-8")
    return hashlib.sha256(text).hexdigest()


def write_lock(path, sheet_name, rows):
    directory = os.path.dirname(path)
    if directory and not os.path.isdir(directory):
        os.makedirs(directory)
    payload = OrderedDict(
        (
            ("version", LOCK_VERSION),
            ("sheet", sheet_name),
            ("fingerprint", fingerprint(rows)),
            ("rows", rows),
        )
    )
    serialized = json.dumps(payload, indent=2, ensure_ascii=False)
    if not isinstance(serialized, TEXT_TYPE):
        serialized = serialized.decode("utf-8")
    with io.open(path, "w", encoding="utf-8") as lock_file:
        lock_file.write(serialized)
        lock_file.write(TEXT_TYPE("\n"))
    print(
        "Updated BASE_VIP_CFG lock: %s (%s)"
        % (path, payload["fingerprint"][:12])
    )


def describe_changes(expected, current):
    expected_ids = ["%s.%s" % (row["section"], row["key"]) for row in expected]
    current_ids = ["%s.%s" % (row["section"], row["key"]) for row in current]
    expected_map = dict(zip(expected_ids, expected))
    current_map = dict(zip(current_ids, current))
    changes = []
    changes.extend(
        "removed %s" % identity for identity in expected_ids if identity not in current_map
    )
    changes.extend(
        "added %s" % identity for identity in current_ids if identity not in expected_map
    )
    if set(expected_ids) == set(current_ids) and expected_ids != current_ids:
        changes.append("parameter row order changed")
    for identity in expected_ids:
        if identity not in current_map:
            continue
        for field in ("value", "type", "description"):
            if expected_map[identity].get(field, "") != current_map[identity].get(field, ""):
                changes.append("%s.%s changed" % (identity, field))
    return changes or ["sheet content changed"]


def verify_lock(path, sheet_name, rows):
    if not os.path.isfile(path):
        raise ValueError(
            "BASE_VIP_CFG lock is missing: %s; restore it or run "
            "`make vip_cfg_lock` after review" % path
        )
    with io.open(path, "r", encoding="utf-8") as lock_file:
        payload = json.load(lock_file, object_pairs_hook=OrderedDict)
    if payload.get("version") != LOCK_VERSION or not isinstance(
        payload.get("rows"), list
    ):
        raise ValueError("BASE_VIP_CFG lock is invalid: %s" % path)
    if fingerprint(payload["rows"]) != payload.get("fingerprint"):
        raise ValueError("BASE_VIP_CFG lock was modified or corrupted: %s" % path)
    if payload.get("sheet") != sheet_name:
        raise ValueError(
            "BASE_VIP_CFG lock protects sheet %s, not %s"
            % (payload.get("sheet"), sheet_name)
        )
    current = fingerprint(rows)
    if current != payload["fingerprint"]:
        changes = describe_changes(payload["rows"], rows)
        raise ValueError(
            "BASE_VIP_CFG integrity check failed: %s. Use DUT_BUFF_FEATURE for "
            "DUT changes; intentionally changed defaults require `make vip_cfg_lock`."
            % "; ".join(changes[:8])
        )
    print("Verified BASE_VIP_CFG integrity lock: %s (%s)" % (path, current[:12]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--cfg",
        required=True,
        help="Workbook reference, for example file.xlsx::BASE_VIP_CFG",
    )
    parser.add_argument("--lock", required=True, help="Integrity lock JSON path")
    parser.add_argument(
        "--refresh", action="store_true", help="Replace the reviewed baseline lock"
    )
    args = parser.parse_args()
    rows = load_rows(args.cfg)
    sheet_name = args.cfg.rsplit("::", 1)[-1]
    if args.refresh:
        write_lock(args.lock, sheet_name, rows)
    else:
        verify_lock(args.lock, sheet_name, rows)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        sys.stderr.write("ERROR: %s\n" % exc)
        sys.exit(2)
