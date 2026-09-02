#!/usr/bin/env python
"""Merge DUT VIP overrides with base defaults and update FINAL_FEATURE."""

from __future__ import print_function

import argparse
import os
import posixpath
import sys
import zipfile
from collections import OrderedDict
from xml.etree import ElementTree as ET

import gen_vip_cfg
from vip_workbook import parse_value, value_text
from xls_table import read_table


MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
PKG_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
OFFICE_REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
XML_NS = "http://www.w3.org/XML/1998/namespace"
BASE_COLUMNS = ("section", "key", "value", "type", "description")
FINAL_COLUMNS = ("section", "key", "value", "source", "type", "description")
BAD_ZIP_ERROR = getattr(zipfile, "BadZipFile", getattr(zipfile, "BadZipfile", Exception))


def tag(namespace, name):
    return "{%s}%s" % (namespace, name)


def clean(value):
    return str(value if value is not None else "").strip()


def load_parameter_rows(ref, label, require_value):
    fieldnames, rows = read_table(ref)
    missing = [name for name in BASE_COLUMNS if name not in fieldnames]
    if missing:
        raise ValueError("%s requires columns: %s" % (ref, ", ".join(BASE_COLUMNS)))

    result = []
    seen = set()
    for row_num, row in enumerate(rows, start=2):
        section = clean(row.get("section"))
        key = clean(row.get("key"))
        value = clean(row.get("value"))
        type_text = clean(row.get("type"))
        description = clean(row.get("description"))
        if not any((section, key, value, type_text, description)):
            continue
        if not section or not key or not type_text:
            raise ValueError("%s row %d requires section, key, and type" % (ref, row_num))
        identity = "%s.%s" % (section, key)
        if identity in seen:
            raise ValueError("%s contains duplicate parameter %s" % (ref, identity))
        if require_value and value == "":
            raise ValueError("%s row %d parameter %s has no default value" % (ref, row_num, identity))
        seen.add(identity)
        result.append(
            {
                "section": section,
                "key": key,
                "value": value,
                "type": type_text,
                "description": description,
                "row_num": row_num,
                "label": label,
            }
        )
    if not result:
        raise ValueError("%s contains no VIP parameters" % ref)
    return result


def validate_matching_tables(base_rows, dut_rows, base_ref, dut_ref):
    if len(base_rows) != len(dut_rows):
        raise ValueError(
            "%s has %d parameters but %s has %d; copy every base row into DUT_BUFF_FEATURE"
            % (base_ref, len(base_rows), dut_ref, len(dut_rows))
        )
    for index, (base, dut) in enumerate(zip(base_rows, dut_rows), start=2):
        base_id = "%s.%s" % (base["section"], base["key"])
        dut_id = "%s.%s" % (dut["section"], dut["key"])
        if dut_id != base_id:
            raise ValueError(
                "%s row %d must be %s to match %s; got %s"
                % (dut_ref, index, base_id, base_ref, dut_id)
            )
        if dut["type"].lower() != base["type"].lower():
            raise ValueError(
                "%s row %d parameter %s type must remain %s"
                % (dut_ref, index, base_id, base["type"])
            )


def build_final(base_rows, dut_rows, base_ref, dut_ref):
    cfg = OrderedDict()
    final_rows = []
    changes = []
    for base, dut in zip(base_rows, dut_rows):
        identity = "%s.%s" % (base["section"], base["key"])
        default_value = parse_value(
            base["value"],
            base["type"],
            "%s row %d parameter %s" % (base_ref, base["row_num"], identity),
        )
        if dut["value"] == "":
            final_value = default_value
            source = "default"
        else:
            final_value = parse_value(
                dut["value"],
                base["type"],
                "%s row %d parameter %s" % (dut_ref, dut["row_num"], identity),
            )
            source = "dut_override"
            if final_value != default_value:
                changes.append((identity, value_text(default_value), value_text(final_value)))

        if base["section"] not in cfg:
            cfg[base["section"]] = OrderedDict()
        cfg[base["section"]][base["key"]] = final_value
        final_rows.append(
            {
                "section": base["section"],
                "key": base["key"],
                "value": value_text(final_value),
                "source": source,
                "type": base["type"],
                "description": base["description"],
            }
        )
    return cfg, final_rows, changes


def column_name(index):
    index += 1
    result = ""
    while index:
        index, remainder = divmod(index - 1, 26)
        result = chr(ord("A") + remainder) + result
    return result


def column_index(cell_ref):
    result = 0
    found = False
    for char in str(cell_ref or ""):
        if not char.isalpha():
            break
        found = True
        result = result * 26 + (ord(char.upper()) - ord("A") + 1)
    return result - 1 if found else None


def workbook_sheet_path(workbook_zip, sheet_name):
    workbook_root = ET.fromstring(workbook_zip.read("xl/workbook.xml"))
    rels_root = ET.fromstring(workbook_zip.read("xl/_rels/workbook.xml.rels"))
    rel_targets = {}
    for rel in rels_root.findall(tag(PKG_REL_NS, "Relationship")):
        rel_targets[rel.attrib.get("Id")] = rel.attrib.get("Target")

    sheets = workbook_root.find(tag(MAIN_NS, "sheets"))
    for sheet in sheets.findall(tag(MAIN_NS, "sheet")):
        if sheet.attrib.get("name") != sheet_name:
            continue
        rel_id = sheet.attrib.get(tag(OFFICE_REL_NS, "id"))
        target = rel_targets.get(rel_id)
        if not target:
            break
        if target.startswith("/"):
            return target.lstrip("/")
        return posixpath.normpath(posixpath.join("xl", target))
    raise ValueError("Workbook does not contain sheet %s" % sheet_name)


def update_final_sheet(path, sheet_name, rows):
    matrix = [list(FINAL_COLUMNS)]
    for row in rows:
        matrix.append([row.get(name, "") for name in FINAL_COLUMNS])

    with zipfile.ZipFile(path, "r") as workbook_zip:
        sheet_path = workbook_sheet_path(workbook_zip, sheet_name)
        sheet_root = ET.fromstring(workbook_zip.read(sheet_path))
        sheet_data = sheet_root.find(tag(MAIN_NS, "sheetData"))
        if sheet_data is None:
            raise ValueError("%s sheet %s has no sheetData" % (path, sheet_name))
        row_map = dict((int(row.attrib.get("r", "0")), row) for row in sheet_data.findall(tag(MAIN_NS, "row")))
        for row_num, values in enumerate(matrix, start=1):
            row_element = row_map.get(row_num)
            if row_element is None:
                raise ValueError("%s sheet %s is missing row %d" % (path, sheet_name, row_num))
            cell_map = {}
            for cell in row_element.findall(tag(MAIN_NS, "c")):
                index = column_index(cell.attrib.get("r"))
                if index is not None:
                    cell_map[index] = cell
            for col_index, value in enumerate(values):
                cell = cell_map.get(col_index)
                if cell is None:
                    cell = ET.SubElement(row_element, tag(MAIN_NS, "c"))
                    cell.attrib["r"] = "%s%d" % (column_name(col_index), row_num)
                original_ref = cell.attrib.get("r", "%s%d" % (column_name(col_index), row_num))
                original_style = cell.attrib.get("s")
                for child in list(cell):
                    cell.remove(child)
                cell.attrib.clear()
                cell.attrib["r"] = original_ref
                if original_style is not None:
                    cell.attrib["s"] = original_style
                cell.attrib["t"] = "inlineStr"
                inline = ET.SubElement(cell, tag(MAIN_NS, "is"))
                text = ET.SubElement(inline, tag(MAIN_NS, "t"))
                rendered = str(value if value is not None else "")
                if rendered != rendered.strip():
                    text.attrib[tag(XML_NS, "space")] = "preserve"
                text.text = rendered
        new_sheet = (
            b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
            + ET.tostring(sheet_root, encoding="utf-8")
        )

        temp_path = "%s.tmp.%d" % (path, os.getpid())
        try:
            with zipfile.ZipFile(temp_path, "w", zipfile.ZIP_DEFLATED) as out_zip:
                for item in workbook_zip.infolist():
                    data = new_sheet if item.filename == sheet_path else workbook_zip.read(item.filename)
                    out_zip.writestr(item, data)
        except Exception:
            if os.path.exists(temp_path):
                os.remove(temp_path)
            raise

    if hasattr(os, "replace"):
        os.replace(temp_path, path)
    else:
        os.rename(temp_path, path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--workbook", default="docs/vip/vip_cfg.xlsx")
    parser.add_argument("--base-sheet", default="BASE_VIP_CFG")
    parser.add_argument("--dut-sheet", default="DUT_BUFF_FEATURE")
    parser.add_argument("--final-sheet", default="FINAL_FEATURE")
    args = parser.parse_args()

    base_ref = "%s::%s" % (args.workbook, args.base_sheet)
    dut_ref = "%s::%s" % (args.workbook, args.dut_sheet)
    base_rows = load_parameter_rows(base_ref, "base", True)
    dut_rows = load_parameter_rows(dut_ref, "dut", False)
    validate_matching_tables(base_rows, dut_rows, base_ref, dut_ref)
    cfg, final_rows, changes = build_final(base_rows, dut_rows, base_ref, dut_ref)

    gen_vip_cfg.generate(cfg)
    update_final_sheet(args.workbook, args.final_sheet, final_rows)

    print("Generated %s::%s from base defaults and DUT overrides" % (args.workbook, args.final_sheet))
    if changes:
        print("Applied DUT VIP overrides:")
        for key, old, new in changes:
            print("  %s: %s -> %s" % (key, old, new))
    else:
        print("No DUT override values were provided; FINAL_FEATURE uses all base defaults.")
    return 0


def cli_main():
    try:
        return main()
    except (IOError, OSError, ValueError, BAD_ZIP_ERROR) as err:
        print("ERROR: %s" % err, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(cli_main())
