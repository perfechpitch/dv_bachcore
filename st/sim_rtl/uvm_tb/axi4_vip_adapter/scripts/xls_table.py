#!/usr/bin/env python
"""Small table reader/writer for CSV-like files and multi-sheet workbooks.

Table references may use ``path::sheet`` to address one sheet inside a workbook.
New generated workbooks are standard ``.xlsx`` files so Excel/WPS shows sheet
tabs at the bottom. Legacy CSV-like ``.xls`` files and Excel 2003 XML ``.xls``
files are still readable for migration.
"""

from __future__ import print_function

import csv
import os
import re
import sys
import zipfile
from collections import OrderedDict
from xml.etree import ElementTree as ET
from xml.sax.saxutils import escape, quoteattr


SS_NS = "urn:schemas-microsoft-com:office:spreadsheet"
SS_INDEX_ATTR = "{%s}Index" % SS_NS
SS_NAME_ATTR = "{%s}Name" % SS_NS

XLSX_MAIN_NS = "http://schemas.openxmlformats.org/spreadsheetml/2006/main"
XLSX_REL_NS = "http://schemas.openxmlformats.org/package/2006/relationships"
XLSX_OFFICE_REL_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
XLSX_STYLE_HEADER = 1
XLSX_STYLE_BODY = 2
XLSX_STYLE_CONFIG_VALUE = 3

try:
    unicode
except NameError:
    unicode = str

try:
    basestring
except NameError:
    basestring = (str,)


def _to_text(value):
    if value is None:
        return u""
    if isinstance(value, unicode):
        return value
    if isinstance(value, bytes):
        return value.decode("utf-8")
    return unicode(value)


def _clean_header(value):
    return _to_text(value).strip()


def split_table_ref(ref):
    text = _to_text(ref)
    if "::" in text:
        path, sheet = text.split("::", 1)
        return path, sheet
    if "#" in text:
        path, sheet = text.split("#", 1)
        return path, sheet
    return text, None


def table_file_exists(ref):
    path, _ = split_table_ref(ref)
    return os.path.exists(path)


def _is_csv(path):
    return os.path.splitext(path)[1].lower() == ".csv"


def _is_xlsx_path(path):
    return os.path.splitext(path)[1].lower() == ".xlsx"


def _ensure_parent(path):
    out_dir = os.path.dirname(path)
    if out_dir and not os.path.isdir(out_dir):
        os.makedirs(out_dir)


def _csv_open_read(path):
    return open(path, "r")


def _csv_open_write(path):
    if sys.version_info[0] >= 3:
        return open(path, "w", newline="")
    return open(path, "wb")


def _read_csv_table(path):
    with _csv_open_read(path) as table_file:
        reader = csv.DictReader(table_file)
        return reader.fieldnames or [], list(reader)


def _head_bytes(path):
    with open(path, "rb") as in_file:
        return in_file.read(512).lstrip()


def _looks_like_xml(path):
    return _head_bytes(path).startswith(b"<")


def _looks_like_xlsx(path):
    return zipfile.is_zipfile(path)


def _raw_rows_to_table(path, raw_rows):
    header_index = None
    fieldnames = []
    for index, raw_row in enumerate(raw_rows):
        if any(_to_text(value).strip() for value in raw_row):
            header_index = index
            fieldnames = [_clean_header(value) for value in raw_row]
            break

    if header_index is None:
        return [], []

    if any(name == "" for name in fieldnames):
        raise ValueError("%s header row contains blank column names" % path)

    rows = []
    for row_index, raw_row in enumerate(raw_rows[header_index + 1 :], start=header_index + 2):
        extra_values = raw_row[len(fieldnames) :]
        if any(_to_text(value).strip() for value in extra_values):
            raise ValueError("%s row %d has values beyond the header columns" % (path, row_index))
        row = {}
        for column_index, name in enumerate(fieldnames):
            value = raw_row[column_index] if column_index < len(raw_row) else ""
            row[name] = _to_text(value)
        rows.append(row)
    return fieldnames, rows


def _local_name(tag):
    if "}" in tag:
        return tag.rsplit("}", 1)[1]
    return tag


def _iter_children(element, local_name):
    for child in list(element):
        if _local_name(child.tag) == local_name:
            yield child


def _cell_text(cell):
    for data in _iter_children(cell, "Data"):
        if hasattr(data, "itertext"):
            return "".join(data.itertext())
        return data.text or ""
    return ""


def _worksheet_name(worksheet, index):
    name = worksheet.attrib.get(SS_NAME_ATTR)
    if name:
        return name
    for key, value in worksheet.attrib.items():
        if key.endswith("}Name") or key == "Name":
            return value
    return "Sheet%d" % (index + 1)


def _read_xml_worksheet_rows(worksheet):
    rows = []
    for table in _iter_children(worksheet, "Table"):
        for row_el in _iter_children(table, "Row"):
            values = []
            column_index = 0
            for cell in _iter_children(row_el, "Cell"):
                raw_index = cell.attrib.get(SS_INDEX_ATTR)
                if raw_index:
                    target_index = int(raw_index) - 1
                    while column_index < target_index:
                        values.append("")
                        column_index += 1
                values.append(_cell_text(cell))
                column_index += 1
            rows.append(values)
        return rows
    return rows


def _read_xml_xls_workbook(path):
    try:
        root = ET.parse(path).getroot()
    except ET.ParseError as err:
        raise ValueError(
            "%s is not a supported XML .xls table. Re-save it as .xlsx "
            "or regenerate it with make seq_gen. Parse error: %s" % (path, err)
        )

    sheets = OrderedDict()
    worksheets = [node for node in root.iter() if _local_name(node.tag) == "Worksheet"]
    if not worksheets:
        return sheets

    for index, worksheet in enumerate(worksheets):
        name = _worksheet_name(worksheet, index)
        sheets[name] = _raw_rows_to_table("%s::%s" % (path, name), _read_xml_worksheet_rows(worksheet))
    return sheets


def _xlsx_tag(local):
    return "{%s}%s" % (XLSX_MAIN_NS, local)


def _rels_tag(local):
    return "{%s}%s" % (XLSX_REL_NS, local)


def _office_rel_attr(local):
    return "{%s}%s" % (XLSX_OFFICE_REL_NS, local)


def _read_zip_xml(workbook_zip, name):
    return ET.fromstring(workbook_zip.read(name))


def _read_shared_strings(workbook_zip):
    if "xl/sharedStrings.xml" not in workbook_zip.namelist():
        return []
    root = _read_zip_xml(workbook_zip, "xl/sharedStrings.xml")
    values = []
    for si in root.findall(_xlsx_tag("si")):
        text_parts = []
        for text_node in si.iter(_xlsx_tag("t")):
            text_parts.append(text_node.text or "")
        values.append("".join(text_parts))
    return values


def _column_to_index(cell_ref):
    match = re.match(r"([A-Za-z]+)", cell_ref or "")
    if not match:
        return None
    result = 0
    for char in match.group(1).upper():
        result = result * 26 + (ord(char) - ord("A") + 1)
    return result - 1


def _xlsx_cell_text(cell, shared_strings):
    cell_type = cell.attrib.get("t", "")
    if cell_type == "inlineStr":
        parts = []
        for text_node in cell.iter(_xlsx_tag("t")):
            parts.append(text_node.text or "")
        return "".join(parts)

    value_node = cell.find(_xlsx_tag("v"))
    if value_node is None or value_node.text is None:
        return ""

    if cell_type == "s":
        try:
            return shared_strings[int(value_node.text)]
        except (ValueError, IndexError):
            return ""
    return value_node.text


def _read_xlsx_sheet_rows(root, shared_strings):
    rows = []
    sheet_data = root.find(_xlsx_tag("sheetData"))
    if sheet_data is None:
        return rows
    for row_el in sheet_data.findall(_xlsx_tag("row")):
        values = []
        column_index = 0
        for cell in row_el.findall(_xlsx_tag("c")):
            target_index = _column_to_index(cell.attrib.get("r"))
            if target_index is not None:
                while column_index < target_index:
                    values.append("")
                    column_index += 1
            values.append(_xlsx_cell_text(cell, shared_strings))
            column_index += 1
        rows.append(values)
    return rows


def _read_xlsx_workbook(path):
    sheets = OrderedDict()
    with zipfile.ZipFile(path, "r") as workbook_zip:
        shared_strings = _read_shared_strings(workbook_zip)
        workbook_root = _read_zip_xml(workbook_zip, "xl/workbook.xml")
        rels_root = _read_zip_xml(workbook_zip, "xl/_rels/workbook.xml.rels")

        rel_targets = {}
        for rel in rels_root.findall(_rels_tag("Relationship")):
            rel_targets[rel.attrib.get("Id")] = rel.attrib.get("Target")

        sheets_node = workbook_root.find(_xlsx_tag("sheets"))
        if sheets_node is None:
            return sheets

        for index, sheet_el in enumerate(sheets_node.findall(_xlsx_tag("sheet"))):
            sheet_name = sheet_el.attrib.get("name", "Sheet%d" % (index + 1))
            rel_id = sheet_el.attrib.get(_office_rel_attr("id"))
            target = rel_targets.get(rel_id)
            if not target:
                continue
            if target.startswith("/"):
                target_path = target.lstrip("/")
            elif target.startswith("xl/"):
                target_path = target
            else:
                target_path = "xl/%s" % target
            sheet_root = _read_zip_xml(workbook_zip, target_path)
            sheets[sheet_name] = _raw_rows_to_table(
                "%s::%s" % (path, sheet_name),
                _read_xlsx_sheet_rows(sheet_root, shared_strings),
            )
    return sheets


def read_workbook(path):
    path, sheet_name = split_table_ref(path)
    if sheet_name:
        fieldnames, rows = read_table("%s::%s" % (path, sheet_name))
        return OrderedDict([(sheet_name, (fieldnames, rows))])
    if _is_csv(path):
        return OrderedDict([("Sheet1", _read_csv_table(path))])
    if _is_xlsx_path(path) or _looks_like_xlsx(path):
        return _read_xlsx_workbook(path)
    if _looks_like_xml(path):
        return _read_xml_xls_workbook(path)
    return OrderedDict([("Sheet1", _read_csv_table(path))])


def read_table(ref, sheet_name=None):
    path, ref_sheet = split_table_ref(ref)
    if sheet_name is None:
        sheet_name = ref_sheet
    if _is_csv(path):
        if sheet_name:
            raise ValueError("%s is not a multi-sheet workbook; cannot read sheet %s" % (path, sheet_name))
        return _read_csv_table(path)

    if _is_xlsx_path(path) or _looks_like_xlsx(path):
        workbook = _read_xlsx_workbook(path)
    elif _looks_like_xml(path):
        workbook = _read_xml_xls_workbook(path)
    else:
        if sheet_name:
            raise ValueError("%s is not a multi-sheet workbook; cannot read sheet %s" % (path, sheet_name))
        return _read_csv_table(path)

    if not workbook:
        return [], []
    if sheet_name:
        if sheet_name not in workbook:
            raise ValueError("%s does not contain sheet %s" % (path, sheet_name))
        return workbook[sheet_name]
    first_sheet = next(iter(workbook))
    return workbook[first_sheet]


def _xml_cell(value, style_id="Text"):
    value = escape(_to_text(value), {'"': "&quot;"})
    return '        <Cell ss:StyleID="%s"><Data ss:Type="String">%s</Data></Cell>' % (
        style_id,
        value,
    )


def _sheet_name(name):
    value = _to_text(name).strip()
    if not value:
        raise ValueError("Sheet name must not be blank")
    invalid = u"[]:*?/\\"
    for char in invalid:
        value = value.replace(char, "_")
    return value[:31]


def _write_xml_sheet(lines, sheet_name, fieldnames, rows, blank_row_indexes=None):
    blank_row_indexes = set(blank_row_indexes or [])
    lines.append("  <Worksheet ss:Name=%s>" % quoteattr(_sheet_name(sheet_name)))
    lines.append("    <Table>")
    for _ in fieldnames:
        lines.append('      <Column ss:AutoFitWidth="1" ss:Width="120"/>')

    lines.append("      <Row>")
    for name in fieldnames:
        lines.append(_xml_cell(name, "Header"))
    lines.append("      </Row>")

    for index, row in enumerate(rows):
        if index in blank_row_indexes:
            lines.append("      <Row/>")
        lines.append("      <Row>")
        for name in fieldnames:
            lines.append(_xml_cell(row.get(name, ""), "Text"))
        lines.append("      </Row>")

    lines.append("    </Table>")
    lines.append("  </Worksheet>")


def _write_xml_workbook(path, sheets):
    _ensure_parent(path)
    lines = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<?mso-application progid="Excel.Sheet"?>',
        '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"',
        '          xmlns:o="urn:schemas-microsoft-com:office:office"',
        '          xmlns:x="urn:schemas-microsoft-com:office:excel"',
        '          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"',
        '          xmlns:html="http://www.w3.org/TR/REC-html40">',
        "  <Styles>",
        '    <Style ss:ID="Header"><Font ss:Bold="1"/><Interior ss:Color="#D9EAF7" ss:Pattern="Solid"/></Style>',
        '    <Style ss:ID="Text"><Alignment ss:Vertical="Top" ss:WrapText="1"/></Style>',
        "  </Styles>",
    ]

    for sheet_name, payload in sheets.items():
        if len(payload) == 2:
            fieldnames, rows = payload
            blank_row_indexes = None
        else:
            fieldnames, rows, blank_row_indexes = payload
        _write_xml_sheet(lines, sheet_name, fieldnames, rows, blank_row_indexes)

    lines.extend(["</Workbook>", ""])
    with open(path, "wb") as out_file:
        out_file.write("\n".join(lines).encode("utf-8"))


def _xlsx_escape(value):
    return escape(_to_text(value), {'"': "&quot;"})


def _col_name(index):
    index += 1
    name = ""
    while index:
        index, remainder = divmod(index - 1, 26)
        name = chr(ord("A") + remainder) + name
    return name


def _xlsx_cell(row_num, col_index, value, style_index):
    text = _xlsx_escape(value)
    ref = "%s%d" % (_col_name(col_index), row_num)
    return '<c r="%s" t="inlineStr" s="%d"><is><t xml:space="preserve">%s</t></is></c>' % (
        ref,
        style_index,
        text,
    )


def _plain_cell_text(value):
    return _to_text(value).replace("\r\n", "\n").replace("\r", "\n")


def _preferred_column_bounds(fieldname):
    name = _to_text(fieldname).strip().lower()
    if name in ("seq_description", "description", "usage", "edit_rule", "change_para"):
        return 24, 80
    if name in ("data_file", "config_source", "current_value"):
        return 18, 60
    if name in ("seq_name", "base_seq", "new_seq", "item"):
        return 16, 42
    if name in ("addr", "data", "expect", "addr_stride", "value"):
        return 14, 34
    return 12, 30


def _display_len(value):
    text = _plain_cell_text(value)
    if not text:
        return 0
    return max(len(part) for part in text.split("\n"))


def _xlsx_column_widths(fieldnames, rows):
    widths = []
    for name in fieldnames:
        min_width, max_width = _preferred_column_bounds(name)
        width = max(min_width, min(max_width, _display_len(name) + 2))
        for row in rows:
            cell_width = _display_len(row.get(name, "")) + 2
            if cell_width > width:
                width = min(max_width, cell_width)
        widths.append(width)
    return widths


def _wrapped_line_count(value, width):
    text = _plain_cell_text(value)
    if not text:
        return 1
    usable_width = max(8, int(width) - 2)
    lines = 0
    for part in text.split("\n"):
        lines += max(1, (len(part) + usable_width - 1) // usable_width)
    return lines


def _xlsx_row_height(values, widths, min_height=15, max_height=240):
    max_lines = 1
    for index, value in enumerate(values):
        width = widths[index] if index < len(widths) else 20
        max_lines = max(max_lines, _wrapped_line_count(value, width))
    return min(max_height, max(min_height, 15 * max_lines))


def _xlsx_row_open(row_num, height=None):
    if height and height != 15:
        return '<row r="%d" ht="%.1f" customHeight="1">' % (row_num, float(height))
    return '<row r="%d">' % row_num


def _xlsx_ref(first_row, first_col, last_row, last_col):
    return "%s%d:%s%d" % (_col_name(first_col), first_row, _col_name(last_col), last_row)


def _xlsx_sheet_xml(fieldnames, rows, blank_row_indexes=None, cell_style_indexes=None):
    blank_row_indexes = set(blank_row_indexes or [])
    cell_style_indexes = cell_style_indexes or {}
    total_cols = max(1, len(fieldnames))
    widths = _xlsx_column_widths(fieldnames, rows)
    last_row_num = len(rows) + 1 + len(blank_row_indexes)
    filter_ref = _xlsx_ref(1, 0, max(1, last_row_num), total_cols - 1)
    lines = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<worksheet xmlns="%s">' % XLSX_MAIN_NS,
        '<sheetViews><sheetView workbookViewId="0"><pane ySplit="1" topLeftCell="A2" activePane="bottomLeft" state="frozen"/><selection pane="bottomLeft"/></sheetView></sheetViews>',
        '<sheetFormatPr defaultRowHeight="15"/>',
        "<cols>",
    ]
    for col_index in range(total_cols):
        width = widths[col_index] if col_index < len(widths) else 20
        lines.append('<col min="%d" max="%d" width="%.1f" customWidth="1"/>' % (col_index + 1, col_index + 1, float(width)))
    lines.extend(["</cols>", "<sheetData>"])

    row_num = 1
    lines.append(_xlsx_row_open(row_num, 24))
    for col_index, name in enumerate(fieldnames):
        lines.append(_xlsx_cell(row_num, col_index, name, XLSX_STYLE_HEADER))
    lines.append("</row>")
    row_num += 1

    for index, row in enumerate(rows):
        if index in blank_row_indexes:
            lines.append('<row r="%d" ht="8" customHeight="1"/>' % row_num)
            row_num += 1
        values = [row.get(name, "") for name in fieldnames]
        lines.append(_xlsx_row_open(row_num, _xlsx_row_height(values, widths)))
        for col_index, name in enumerate(fieldnames):
            style_index = cell_style_indexes.get((index, name), XLSX_STYLE_BODY)
            lines.append(_xlsx_cell(row_num, col_index, row.get(name, ""), style_index))
        lines.append("</row>")
        row_num += 1

    lines.extend(
        [
            "</sheetData>",
            '<autoFilter ref="%s"/>' % filter_ref,
            '<pageMargins left="0.7" right="0.7" top="0.75" bottom="0.75" header="0.3" footer="0.3"/>',
            "</worksheet>",
        ]
    )
    return "\n".join(lines).encode("utf-8")


def _xlsx_content_types(sheet_count):
    overrides = [
        '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
        '<Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>',
        '<Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>',
        '<Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>',
    ]
    for index in range(1, sheet_count + 1):
        overrides.append(
            '<Override PartName="/xl/worksheets/sheet%d.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>'
            % index
        )
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n'
        '<Default Extension="xml" ContentType="application/xml"/>\n'
        "%s\n"
        "</Types>"
    ) % "\n".join(overrides)


def _xlsx_workbook_xml(sheet_names):
    sheet_lines = []
    for index, name in enumerate(sheet_names, start=1):
        sheet_lines.append(
            '<sheet name="%s" sheetId="%d" r:id="rId%d"/>'
            % (_xlsx_escape(_sheet_name(name)), index, index)
        )
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<workbook xmlns="%s" xmlns:r="%s">\n'
        "<workbookViews><workbookView activeTab=\"0\"/></workbookViews>\n"
        "<sheets>\n%s\n</sheets>\n"
        "</workbook>"
    ) % (XLSX_MAIN_NS, XLSX_OFFICE_REL_NS, "\n".join(sheet_lines))


def _xlsx_workbook_rels(sheet_count):
    rels = []
    for index in range(1, sheet_count + 1):
        rels.append(
            '<Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet%d.xml"/>'
            % (index, index)
        )
    rels.append(
        '<Relationship Id="rId%d" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        % (sheet_count + 1)
    )
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="%s">\n%s\n</Relationships>'
    ) % (XLSX_REL_NS, "\n".join(rels))


def _xlsx_root_rels():
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Relationships xmlns="%s">\n'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>\n'
        '<Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>\n'
        '<Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>\n'
        "</Relationships>"
    ) % XLSX_REL_NS


def _xlsx_styles():
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<styleSheet xmlns="%s">\n'
        '<fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><b/><sz val="11"/><name val="Calibri"/></font></fonts>\n'
        '<fills count="4"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill><fill><patternFill patternType="solid"><fgColor rgb="FFD9EAF7"/><bgColor indexed="64"/></patternFill></fill><fill><patternFill patternType="solid"><fgColor rgb="FFEAF2F8"/><bgColor indexed="64"/></patternFill></fill></fills>\n'
        '<borders count="2"><border><left/><right/><top/><bottom/><diagonal/></border><border><left style="thin"><color rgb="FFD9D9D9"/></left><right style="thin"><color rgb="FFD9D9D9"/></right><top style="thin"><color rgb="FFD9D9D9"/></top><bottom style="thin"><color rgb="FFD9D9D9"/></bottom><diagonal/></border></borders>\n'
        '<cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>\n'
        '<cellXfs count="4"><xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/><xf numFmtId="0" fontId="1" fillId="2" borderId="1" xfId="0" applyFont="1" applyFill="1" applyBorder="1" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf><xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf><xf numFmtId="0" fontId="0" fillId="3" borderId="1" xfId="0" applyFill="1" applyBorder="1" applyAlignment="1"><alignment vertical="top" wrapText="1"/></xf></cellXfs>\n'
        '<cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>\n'
        "</styleSheet>"
    ) % XLSX_MAIN_NS


def _xlsx_doc_props_app(sheet_names):
    titles = "".join("<vt:lpstr>%s</vt:lpstr>" % _xlsx_escape(_sheet_name(name)) for name in sheet_names)
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" '
        'xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">\n'
        "<Application>AXI4 VIP Adapter</Application>\n"
        "<HeadingPairs><vt:vector size=\"2\" baseType=\"variant\"><vt:variant><vt:lpstr>Worksheets</vt:lpstr></vt:variant><vt:variant><vt:i4>%d</vt:i4></vt:variant></vt:vector></HeadingPairs>\n"
        "<TitlesOfParts><vt:vector size=\"%d\" baseType=\"lpstr\">%s</vt:vector></TitlesOfParts>\n"
        "</Properties>"
    ) % (len(sheet_names), len(sheet_names), titles)


def _xlsx_doc_props_core():
    return (
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
        '<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" '
        'xmlns:dc="http://purl.org/dc/elements/1.1/" '
        'xmlns:dcterms="http://purl.org/dc/terms/" '
        'xmlns:dcmitype="http://purl.org/dc/dcmitype/" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">\n'
        "<dc:creator>AXI4 VIP Adapter</dc:creator>\n"
        "<cp:lastModifiedBy>AXI4 VIP Adapter</cp:lastModifiedBy>\n"
        "</cp:coreProperties>"
    )


def _write_xlsx_workbook(path, sheets):
    _ensure_parent(path)
    if not sheets:
        sheets = OrderedDict([("Sheet1", ([], []))])
    sheet_names = list(sheets.keys())
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as workbook_zip:
        workbook_zip.writestr("[Content_Types].xml", _xlsx_content_types(len(sheet_names)))
        workbook_zip.writestr("_rels/.rels", _xlsx_root_rels())
        workbook_zip.writestr("docProps/app.xml", _xlsx_doc_props_app(sheet_names))
        workbook_zip.writestr("docProps/core.xml", _xlsx_doc_props_core())
        workbook_zip.writestr("xl/workbook.xml", _xlsx_workbook_xml(sheet_names))
        workbook_zip.writestr("xl/_rels/workbook.xml.rels", _xlsx_workbook_rels(len(sheet_names)))
        workbook_zip.writestr("xl/styles.xml", _xlsx_styles())
        for index, payload in enumerate(sheets.values(), start=1):
            if len(payload) == 2:
                fieldnames, rows = payload
                blank_row_indexes = None
                cell_style_indexes = None
            elif len(payload) == 3:
                fieldnames, rows, blank_row_indexes = payload
                cell_style_indexes = None
            else:
                fieldnames, rows, blank_row_indexes, cell_style_indexes = payload
            workbook_zip.writestr(
                "xl/worksheets/sheet%d.xml" % index,
                _xlsx_sheet_xml(fieldnames, rows, blank_row_indexes, cell_style_indexes),
            )


def write_workbook(path, sheets):
    if _is_xlsx_path(path):
        _write_xlsx_workbook(path, sheets)
    else:
        _write_xml_workbook(path, sheets)


def _write_csv_table(path, fieldnames, rows, blank_row_indexes=None):
    _ensure_parent(path)
    blank_row_indexes = set(blank_row_indexes or [])
    with _csv_open_write(path) as out_file:
        writer = csv.DictWriter(out_file, fieldnames=fieldnames, lineterminator="\n")
        writer.writeheader()
        for index, row in enumerate(rows):
            if index in blank_row_indexes:
                if sys.version_info[0] >= 3:
                    out_file.write("\n")
                else:
                    out_file.write(b"\n")
            writer.writerow(dict((name, _to_text(row.get(name, ""))) for name in fieldnames))


def _read_existing_sheets(path):
    if not os.path.exists(path):
        return OrderedDict()
    if _is_csv(path):
        fieldnames, rows = _read_csv_table(path)
        return OrderedDict([("Sheet1", (fieldnames, rows))])
    if _is_xlsx_path(path) or _looks_like_xlsx(path):
        return _read_xlsx_workbook(path)
    if _looks_like_xml(path):
        return _read_xml_xls_workbook(path)
    fieldnames, rows = _read_csv_table(path)
    return OrderedDict([("Sheet1", (fieldnames, rows))])


def write_table(ref, fieldnames, rows, blank_row_indexes=None):
    path, sheet_name = split_table_ref(ref)
    if sheet_name:
        sheets = _read_existing_sheets(path)
        sheets[sheet_name] = (fieldnames, rows, blank_row_indexes)
        write_workbook(path, sheets)
        return
    _write_csv_table(path, fieldnames, rows, blank_row_indexes)


def write_grouped_table(ref, fieldnames, row_groups):
    rows = []
    blank_row_indexes = []
    for group_index, group in enumerate(row_groups):
        if group_index:
            blank_row_indexes.append(len(rows))
        rows.extend(group)
    write_table(ref, fieldnames, rows, blank_row_indexes)
