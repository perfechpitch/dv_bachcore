#!/usr/bin/env python3
"""Optional workbook values and requirement metadata, using scratch fixtures only.

Run: python3 -B -m unittest discover -s tests -p 'test_workbook_metadata.py' -v
The synthetic workbooks exercise the reader/merger; the project workbook is never
written. These are configuration checks, not proof of NoC performance/capability.
"""

import copy
import json
from collections import OrderedDict
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest
from xml.etree import ElementTree as ET
import zipfile


ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"
sys.path.insert(0, str(SCRIPTS))
import gen_dut_vip_cfg as merge
import gen_vip_cfg as gen
import vip_workbook as workbook
from xls_table import read_table, write_workbook


REQUIREMENTS = OrderedDict([
    ("name", "scp_bach_ctrl_m0"), ("access_mode", "rw"),
    ("barrier", False), ("max_wrap_size", "no"),
    ("align_info", "none"), ("diff_id", "none"),
    ("clock_freq_mhz", 1000), ("bandwidth_gbps", 24),
    ("bandwidth_scope", None), ("use_rob", False),
    ("max_burst_beats", None), ("max_burst_bytes", None),
    ("outstanding", 128), ("outstanding_scope", None),
])


def row(section, key, value, kind):
    return {"section": section, "key": key, "value": value, "type": kind,
            "description": "Scratch test parameter " + key}


def fixture_rows():
    base = [row("axi", "max_outstanding_reads", "1", "int"),
            row("axi", "max_outstanding_writes", "1", "int"),
            row("axi", "max_outstanding_total", "", "optional_int")]
    for key, value in REQUIREMENTS.items():
        base.append(row("requirements", key, workbook.value_text(value), gen.REQUIREMENT_TYPES[key]))
    dut = copy.deepcopy(base)
    for entry in dut:
        entry["value"] = ""
    dut[0]["value"] = "3"
    dut[1]["value"] = "5"
    return base, dut


def write_fixture(path, base, dut):
    final = copy.deepcopy(base)
    for entry in final:
        entry["source"] = "default"
    write_workbook(str(path), OrderedDict([
        ("BASE_VIP_CFG", (merge.BASE_COLUMNS, base)),
        ("DUT_BUFF_FEATURE", (merge.BASE_COLUMNS, dut)),
        ("FINAL_FEATURE", (merge.FINAL_COLUMNS, final)),
    ]))


def load_merge(path):
    base_ref = str(path) + "::BASE_VIP_CFG"
    dut_ref = str(path) + "::DUT_BUFF_FEATURE"
    base = merge.load_parameter_rows(base_ref, "base", True)
    dut = merge.load_parameter_rows(dut_ref, "dut", False)
    merge.validate_matching_tables(base, dut, base_ref, dut_ref)
    return merge.build_final(base, dut, base_ref, dut_ref)


def runtime_parameters(config):
    return re.findall(r"^\s*parameter .+;$", "\n".join(gen.generate(config)), re.MULTILINE)


class WorkbookMetadataTests(unittest.TestCase):
    def run_script(self, name, *args):
        return subprocess.run([sys.executable, "-B", str(SCRIPTS / name)] + list(args),
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              universal_newlines=True, timeout=15)

    def test_optional_blank_is_distinct_from_zero_false_none_and_no(self):
        for kind in ("optional_int", "optional_string"):
            for value in ("", None):
                with self.subTest(kind=kind, value=value):
                    self.assertIsNone(workbook.parse_value(value, kind, "test"))
        self.assertEqual(workbook.parse_value("0", "optional_int", "test"), 0)
        for value in ("none", "no", "null", "0", "false"):
            self.assertEqual(workbook.parse_value(value, "optional_string", "test"), value)
        for value in ("none", "no", "null", "false", " "):
            with self.subTest(value=value), self.assertRaises(ValueError):
                workbook.parse_value(value, "optional_int", "test")
        for value in ("0", "false", "no"):
            self.assertIs(workbook.parse_value(value, "bool", "test"), False)
        self.assertEqual(workbook.value_text(False), "false")
        self.assertEqual(workbook.value_text(0), "0")
        self.assertEqual(workbook.value_text(None), "")
        self.assertEqual(workbook.value_type(None), "null")
        for value in ("", "null"):
            self.assertIsNone(workbook.parse_value(value, "null", "legacy null"))

    def test_required_base_blanks_rejected_optional_and_legacy_null_allowed(self):
        with tempfile.TemporaryDirectory(prefix="axi4_base_blank_") as directory:
            path = Path(directory) / "input.xlsx"
            for kind in ("int", "string", "bool", "json"):
                base = [row("test", "required", "", kind)]
                write_fixture(path, base, copy.deepcopy(base))
                with self.subTest(kind=kind), self.assertRaisesRegex(ValueError, "no default value"):
                    load_merge(path)
            for kind in ("optional_int", "optional_string", "null"):
                base = [row("test", "optional", "", kind)]
                write_fixture(path, base, copy.deepcopy(base))
                cfg, final, changes = load_merge(path)
                self.assertIsNone(cfg["test"]["optional"])
                self.assertEqual(final[0]["value"], "")
                self.assertEqual(changes, [])

    def test_legacy_section_workbooks_keep_optional_requirements_when_present(self):
        with tempfile.TemporaryDirectory(prefix="axi4_metadata_sections_") as directory:
            path = Path(directory) / "input.xlsx"
            sheets = OrderedDict((name, (("key", "value", "type"), []))
                                 for name in workbook.VIP_SECTIONS)
            write_workbook(str(path), sheets)
            self.assertNotIn("requirements", workbook.load_vip_cfg(str(path)))
            metadata = [row("requirements", key, workbook.value_text(value), gen.REQUIREMENT_TYPES[key])
                        for key, value in REQUIREMENTS.items()]
            sheets["requirements"] = (("key", "value", "type"), metadata)
            write_workbook(str(path), sheets)
            cfg = workbook.load_vip_cfg(str(path))
            self.assertEqual(cfg["requirements"], REQUIREMENTS)
            self.assertEqual(runtime_parameters(cfg), runtime_parameters({}))

    def test_dut_inheritance_and_final_direction_caps_resolve_total(self):
        with tempfile.TemporaryDirectory(prefix="axi4_optional_merge_") as directory:
            path = Path(directory) / "input.xlsx"
            for total, expected in (("", 8), ("7", 7)):
                base, dut = fixture_rows()
                dut[2]["value"] = total
                write_fixture(path, base, dut)
                cfg, final, changes = load_merge(path)
                self.assertEqual(cfg["requirements"], REQUIREMENTS)
                self.assertEqual(cfg["axi"]["max_outstanding_reads"], 3)
                self.assertEqual(cfg["axi"]["max_outstanding_writes"], 5)
                self.assertEqual(final[2]["value"], total)
                self.assertEqual(final[2]["source"], "default" if total == "" else "dut_override")
                self.assertIn("  parameter int VIP_AXI_MAX_OUTSTANDING_TOTAL = %d;" % expected,
                              gen.generate(cfg))
                self.assertEqual(len(changes), 2 if total == "" else 3)
        without_total = {"axi": {"max_outstanding_reads": 3, "max_outstanding_writes": 5}}
        with_null = copy.deepcopy(without_total)
        with_null["axi"]["max_outstanding_total"] = None
        self.assertEqual(gen.generate(without_total), gen.generate(with_null))

    def test_cli_merge_json_sv_round_trip_keeps_metadata_and_physical_blanks(self):
        with tempfile.TemporaryDirectory(prefix="axi4_metadata_chain_") as directory:
            path = Path(directory) / "input.xlsx"
            json_path = Path(directory) / "result.json"
            sv_path = Path(directory) / "result.sv"
            base, dut = fixture_rows()
            write_fixture(path, base, dut)
            original_tables = [read_table(str(path) + "::" + name) for name in ("BASE_VIP_CFG", "DUT_BUFF_FEATURE")]
            result = self.run_script("gen_dut_vip_cfg.py", "--workbook", str(path))
            self.assertEqual(result.returncode, 0, result.stderr)
            for index, name in enumerate(("BASE_VIP_CFG", "DUT_BUFF_FEATURE")):
                self.assertEqual(read_table(str(path) + "::" + name), original_tables[index])
            result = self.run_script("vip_table_to_json.py", "--cfg", str(path), "--out", str(json_path))
            self.assertEqual(result.returncode, 0, result.stderr)
            cfg = json.loads(json_path.read_text())
            self.assertEqual(cfg["requirements"], REQUIREMENTS)
            self.assertIsNone(cfg["axi"]["max_outstanding_total"])
            self.assertFalse(cfg["requirements"]["barrier"])
            self.assertEqual(cfg["requirements"]["align_info"], "none")
            result = self.run_script("gen_vip_cfg.py", "--cfg", str(json_path), "--out", str(sv_path))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn("VIP_AXI_MAX_OUTSTANDING_TOTAL = 8;", sv_path.read_text())
            self.assertIn("source metadata only", sv_path.read_text())
            self.assertIn("VIP_AXI_DATA_WIDTH = 32;", sv_path.read_text())
            self.assertIn("VIP_AXI_MAX_BURST_LEN = 1;", sv_path.read_text())
            with zipfile.ZipFile(str(path)) as archive:
                sheet = ET.fromstring(archive.read(merge.workbook_sheet_path(archive, "FINAL_FEATURE")))
            ns = {"m": merge.MAIN_NS}
            for index, entry in enumerate(base, start=2):
                if entry["value"] != "":
                    continue
                cell = sheet.find(".//m:c[@r='C%d']" % index, ns)
                self.assertIsNotNone(cell)
                self.assertEqual(list(cell), [], "blank cell contains an XML value")
                self.assertNotIn("t", cell.attrib)
            self.assertEqual(workbook.load_vip_cfg(str(path)), cfg)

    def test_requirements_changes_leave_generated_sv_identical(self):
        config = {"requirements": copy.deepcopy(REQUIREMENTS)}
        before = copy.deepcopy(config)
        changed = copy.deepcopy(config)
        changed["requirements"].update({
            "clock_freq_mhz": 750, "bandwidth_gbps": 50, "outstanding": 256,
            "outstanding_scope": "reads", "bandwidth_scope": "writes",
            "barrier": True, "use_rob": True, "align_info": "4096 bytes",
            "max_burst_beats": 16, "max_burst_bytes": 512,
        })
        self.assertEqual(gen.generate(config), gen.generate(changed))
        self.assertEqual(runtime_parameters(config), runtime_parameters({}))
        self.assertEqual(config, before)
        self.assertEqual(gen.merged_cfg(config)["requirements"], REQUIREMENTS)
        changed["support"] = {"exclusive_access": True}
        with self.assertRaisesRegex(ValueError, "exclusive_access"):
            gen.generate(changed)

    def test_requirements_schema_rejects_unknown_keys_wrong_types_and_nonpositive_values(self):
        for value in (None, [], "requirements", False):
            with self.subTest(value=value), self.assertRaisesRegex(ValueError, "must be an object"):
                gen.generate({"requirements": value})
        with self.assertRaisesRegex(ValueError, "Unknown requirements"):
            gen.generate({"requirements": {"bandwidth_typo": 24}})
        for key, kind in gen.REQUIREMENT_TYPES.items():
            if kind.endswith("int"):
                invalid = (0, -1, True, 1.5, "24")
            elif kind == "bool":
                invalid = (None, 0, 1, "false", "no")
            else:
                invalid = (0, False, [], "", " ")
            if not kind.startswith("optional_"):
                invalid += (None,)
            for value in invalid:
                with self.subTest(key=key, value=value), self.assertRaisesRegex(ValueError, key):
                    gen.generate({"requirements": {key: value}})
        for key in ("bandwidth_scope", "outstanding_scope"):
            for value in (None, "none", "no", "0"):
                gen.generate({"requirements": {key: value}})

    def test_invalid_merge_or_generation_keeps_existing_files_unchanged(self):
        with tempfile.TemporaryDirectory(prefix="axi4_metadata_invalid_") as directory:
            path = Path(directory) / "input.xlsx"
            base, dut = fixture_rows()
            for target, value in ((2, "0"), (2, "none"), (9, "0")):
                invalid_dut = copy.deepcopy(dut)
                invalid_dut[target]["value"] = value
                write_fixture(path, base, invalid_dut)
                original = path.read_bytes()
                result = self.run_script("gen_dut_vip_cfg.py", "--workbook", str(path))
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual(path.read_bytes(), original)
            cfg_path = Path(directory) / "input.json"
            sv_path = Path(directory) / "output.sv"
            sentinel = b"Existing output\x00\xff"
            for cfg in ({"requirements": {"clock_freq_mhz": 0}},
                        {"requirements": {"use_rob": "no"}},
                        {"axi": {"max_outstanding_total": 0}}):
                cfg_path.write_text(json.dumps(cfg))
                sv_path.write_bytes(sentinel)
                result = self.run_script("gen_vip_cfg.py", "--cfg", str(cfg_path), "--out", str(sv_path))
                self.assertNotEqual(result.returncode, 0, result.stdout)
                self.assertEqual(sv_path.read_bytes(), sentinel)


if __name__ == "__main__":
    unittest.main()
