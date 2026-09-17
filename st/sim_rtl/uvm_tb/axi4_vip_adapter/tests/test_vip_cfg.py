#!/usr/bin/env python3
"""Configuration contract checks; no make target or workbook writer is invoked.

Run with: python3 -B -m unittest discover -s tests -p 'test_vip_cfg.py' -v
Generated files and deliberately invalid CLI inputs live in TemporaryDirectory.
These checks establish configuration semantics, not burst/concurrency capability.
"""

import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from workbook_baseline import BASELINE_SHA

GENERATOR = ROOT / "scripts" / "gen_vip_cfg.py"
WORKBOOK = ROOT / "docs" / "vip" / "vip_cfg.xlsx"

spec = importlib.util.spec_from_file_location("gen_vip_cfg_under_test", GENERATOR)
gen = importlib.util.module_from_spec(spec)
previous_dont_write_bytecode = sys.dont_write_bytecode
try:
    sys.dont_write_bytecode = True
    spec.loader.exec_module(gen)
finally:
    sys.dont_write_bytecode = previous_dont_write_bytecode


def package_params(text):
    """Read emitted declarations, retaining both type and literal for assertions."""
    return {
        name: (type_text.strip(), value.strip())
        for type_text, name, value in re.findall(
            r"^\s*parameter\s+(.+?)\s+(VIP_\w+)\s*=\s*(.+);$", text, re.MULTILINE
        )
    }


class VipConfigTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.workbook_before = hashlib.sha256(WORKBOOK.read_bytes()).hexdigest()
        if cls.workbook_before != BASELINE_SHA:
            raise AssertionError("vip_cfg.xlsx does not match the protected baseline")

    @classmethod
    def tearDownClass(cls):
        after = hashlib.sha256(WORKBOOK.read_bytes()).hexdigest()
        if after != cls.workbook_before:
            raise AssertionError("vip_cfg.xlsx changed during configuration tests")

    def render(self, config):
        return "\n".join(gen.generate(config))

    def params(self, config):
        return package_params(self.render(config))

    def assert_int_params(self, params, expected):
        for suffix, value in expected.items():
            with self.subTest(parameter=suffix):
                self.assertEqual(params["VIP_AXI_" + suffix], ("int", str(value)))

    def test_default_demo_and_existing_json_remain_usable(self):
        demo = json.loads((ROOT / "tb/generated/axi4_vip_cfg.json").read_text())
        for config in ({}, demo):
            with self.subTest(config="empty" if not config else "checked-in demo"):
                params = self.params(config)
                self.assert_int_params(params, {
                    "ADDR_WIDTH": 32, "DATA_WIDTH": 32, "ID_WIDTH": 4,
                    "STRB_WIDTH": 4, "LEN_WIDTH": 8, "MAX_BURST_LEN": 1,
                    "MAX_OUTSTANDING_READS": 1, "MAX_OUTSTANDING_WRITES": 1,
                    "MAX_OUTSTANDING_TOTAL": 2,
                })
                self.assertEqual(params["VIP_AXI_PROTOCOL"][1], '"AXI4"')
                self.assertEqual(params["VIP_AXI_DEFAULT_BURST"][1], "1")
                self.assertEqual(params["VIP_AXI_DEFAULT_STRB"][1], "'1")

    def test_target_profile_is_independent_and_labels_unconfirmed_limits(self):
        target = json.loads((ROOT / "tests/configs/scp_bach_ctrl_m0.json").read_text())
        self.assert_int_params(self.params(target), {
            "ADDR_WIDTH": 32, "DATA_WIDTH": 256, "ID_WIDTH": 8,
            "STRB_WIDTH": 32, "LEN_WIDTH": 4, "MAX_BURST_LEN": 16,
            "QOS_WIDTH": 0, "REGION_WIDTH": 0,
            "AWUSER_WIDTH": 0, "ARUSER_WIDTH": 0, "WUSER_WIDTH": 0,
            "RUSER_WIDTH": 0, "BUSER_WIDTH": 0,
            "MAX_OUTSTANDING_READS": 128, "MAX_OUTSTANDING_WRITES": 128,
            "MAX_OUTSTANDING_TOTAL": 128,
        })
        self.assertIn("test_assumptions", target)
        for key in ("burst", "outstanding", "clock_and_bandwidth", "address_map"):
            self.assertTrue(target["test_assumptions"].get(key), key)

    def test_generation_does_not_mutate_inputs_or_defaults(self):
        config = {"axi": {"outstanding": 128, "qos_width": 0}}
        config_before = copy.deepcopy(config)
        defaults_before = copy.deepcopy(gen.DEFAULT_CFG)
        self.render(config)
        self.assertEqual(config, config_before)
        self.assertEqual(gen.DEFAULT_CFG, defaults_before)

    def test_supported_data_widths_derive_byte_strobes(self):
        for width in (8, 16, 32, 64, 128, 256, 512, 1024):
            with self.subTest(width=width):
                self.assert_int_params(self.params({"axi": {"data_width": width}}), {
                    "DATA_WIDTH": width, "STRB_WIDTH": width // 8,
                })

    def test_invalid_width_matrix(self):
        cases = {
            "addr_width": (0, -1, True, 32.5),
            "id_width": (0, -1, False, 8.5),
            "data_width": (0, 1, 7, 24, 255, 2048, -8, True, 256.0),
            "len_width": (0, 9, -1),
            "size_width": (0, 2, 4),
            "burst_width": (0, 1, 3),
            "lock_width": (0, 2),
            "cache_width": (0, 3, 5),
            "prot_width": (0, 2, 4),
            "resp_width": (0, 1, 3),
            "qos_width": (-1, 1, 3, 5),
            "region_width": (-1, 1, 3, 5),
            "awuser_width": (-1,), "aruser_width": (-1,),
            "wuser_width": (-1,), "ruser_width": (-1,), "buser_width": (-1,),
        }
        for key, values in cases.items():
            for value in values:
                with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                    self.render({"axi": {key: value}})

    def test_len_encoding_boundary_and_default_burst_limit(self):
        for width in range(1, 9):
            maximum = 1 << width
            with self.subTest(len_width=width):
                self.assert_int_params(self.params({"axi": {
                    "len_width": width, "max_burst_len": maximum,
                    "default_burst_len": maximum,
                }}), {"LEN_WIDTH": width, "MAX_BURST_LEN": maximum,
                      "DEFAULT_BURST_LEN": maximum})
                with self.assertRaises(ValueError):
                    self.render({"axi": {"len_width": width, "max_burst_len": maximum + 1}})
        for axi in ({"max_burst_len": 0}, {"default_burst_len": 0},
                    {"max_burst_len": 4, "default_burst_len": 5}):
            with self.subTest(axi=axi), self.assertRaises(ValueError):
                self.render({"axi": axi})

    def test_only_axi4_incr_and_nonexclusive_defaults_are_accepted(self):
        for protocol in ("AXI3", "AXI4LITE", "AXI5", "", 4):
            with self.subTest(protocol=protocol), self.assertRaises(ValueError):
                self.render({"axi": {"protocol": protocol}})
        for burst in ("FIXED", "WRAP", 0, 2, 3, "0x3"):
            with self.subTest(burst=burst), self.assertRaises(ValueError):
                self.render({"axi": {"default_burst_type": burst}})
        for burst in ("INCR", "incr", 1, "0x1"):
            with self.subTest(burst=burst):
                params = self.params({"axi": {"default_burst_type": burst}})
                self.assertEqual(params["VIP_AXI_DEFAULT_BURST_TYPE"][1], '"INCR"')
        with self.assertRaisesRegex(ValueError, "default_lock"):
            self.render({"axi": {"default_lock": 1}})

    def test_unsupported_support_flags_reject_instead_of_claiming_capability(self):
        for key in ("exclusive_access", "locked_access", "unaligned_access", "wrapping_burst"):
            for value in (True, 1, "true"):
                with self.subTest(key=key, value=value), self.assertRaisesRegex(ValueError, key):
                    self.render({"support": {key: value}})
        with self.assertRaisesRegex(ValueError, "incrementing_burst"):
            self.render({"support": {"incrementing_burst": False}})

    def test_capability_notes_match_burst_driver(self):
        generated = self.render({})
        self.assertIn("support.fixed_burst is legacy policy only", generated)
        self.assertIn("aligned INCR bursts", generated)
        self.assertIn("permits aligned narrow INCR bursts", generated)
        restricted = self.render({"support": {"narrow_burst": False, "fixed_burst": False}})
        self.assertNotIn("is legacy policy only", restricted)
        self.assertIn("partial WSTRB is rejected",
                      self.render({"support": {"byte_strobe": False}}))

    def test_zero_width_sidebands_have_safe_typed_zero_defaults(self):
        axi = {key + "_width": 0 for key in ("qos", "region", "awuser", "aruser", "wuser")}
        params = self.params({"axi": axi})
        for signal in ("QOS", "REGION", "AWUSER", "ARUSER", "WUSER"):
            with self.subTest(signal=signal):
                type_text, literal = params["VIP_AXI_DEFAULT_" + signal]
                self.assertIn("VIP_AXI_" + signal + "_WIDTH", type_text)
                self.assertIn("? VIP_AXI_" + signal + "_WIDTH : 1", type_text)
                self.assertTrue(type_text.startswith("bit ["), type_text)
                self.assertEqual(literal, "'h0")
        for signal in ("qos", "region", "awuser", "aruser", "wuser"):
            for invalid in (1, -1, "0x100"):
                config = {"axi": dict(axi, **{"default_" + signal: invalid})}
                with self.subTest(signal=signal, invalid=invalid), self.assertRaises(ValueError):
                    self.render(config)

    def test_user_values_wider_than_32_bits_are_preserved_in_vectors(self):
        values = {"awuser": "0x123456789abcdef01", "aruser": "0xfedcba9876543210",
                  "wuser": "0x100000001"}
        axi = {}
        for signal, value in values.items():
            axi[signal + "_width"] = 65
            axi["default_" + signal] = value
        params = self.params({"axi": axi})
        for signal, value in values.items():
            with self.subTest(signal=signal):
                type_text, literal = params["VIP_AXI_DEFAULT_" + signal.upper()]
                self.assertTrue(type_text.startswith("bit ["), type_text)
                self.assertEqual(literal, "'h" + value[2:])
        with self.assertRaises(ValueError):
            self.render({"axi": {"awuser_width": 33, "default_awuser": "0x200000000"}})

    def test_default_payloads_cannot_silently_truncate(self):
        params = self.params({"axi": {
            "data_width": 256, "id_width": 8, "default_id": 255,
            "default_strb": "0xffffffff", "default_cache": 15,
            "default_prot": 7, "default_qos": 15, "default_region": 15,
        }})
        self.assertEqual(params["VIP_AXI_DEFAULT_STRB"][1], "'hffffffff")
        for key, value in (("default_id", 256), ("default_strb", "0x100000000"),
                           ("default_cache", 16), ("default_prot", 8),
                           ("default_qos", 16), ("default_region", 16),
                           ("default_id", -1), ("default_strb", -1)):
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                self.render({"axi": {"data_width": 256, "id_width": 8, key: value}})

    def test_direction_and_aggregate_outstanding_limits_and_legacy_alias(self):
        self.assert_int_params(self.params({"axi": {
            "max_outstanding_reads": 7, "max_outstanding_writes": 11,
        }}), {"MAX_OUTSTANDING_READS": 7, "MAX_OUTSTANDING_WRITES": 11,
              "MAX_OUTSTANDING_TOTAL": 18, "OUTSTANDING": 11})
        self.assert_int_params(self.params({"axi": {
            "outstanding": 128, "max_outstanding_reads": 3, "max_outstanding_total": 9,
        }}), {"MAX_OUTSTANDING_READS": 3, "MAX_OUTSTANDING_WRITES": 128,
              "MAX_OUTSTANDING_TOTAL": 9, "OUTSTANDING": 128})
        for key in ("max_outstanding_reads", "max_outstanding_writes", "max_outstanding_total"):
            for value in (0, -1, True, 1.5, 2147483648):
                with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                    self.render({"axi": {key: value}})
        with self.assertRaises(ValueError):
            self.render({"axi": {"max_outstanding_reads": 2147483647}})

    def test_unknown_keys_and_nonobject_sections_are_rejected(self):
        for section in ("axi", "support", "checker", "coverage"):
            with self.subTest(section=section, issue="unknown key"):
                with self.assertRaisesRegex(ValueError, "Unknown " + section):
                    self.render({section: {"misspelled_option": True}})
            for value in (None, [], "not an object", True):
                with self.subTest(section=section, value=value), self.assertRaises(ValueError):
                    self.render({section: value})
        for config in ([], None, 3, "AXI4"):
            with self.subTest(config=config), self.assertRaises(ValueError):
                self.render(config)

    def test_checker_and_coverage_boolean_values_are_validated(self):
        for section, key, param in (
            ("checker", "enable_protocol_checks", "VIP_ENABLE_PROTOCOL_CHECKS"),
            ("coverage", "enable_coverage", "VIP_ENABLE_COVERAGE"),
        ):
            for value, expected in ((True, "1'b1"), ("yes", "1'b1"), (0, "1'b0"), ("off", "1'b0")):
                with self.subTest(section=section, value=value):
                    self.assertEqual(self.params({section: {key: value}})[param], ("bit", expected))
            with self.assertRaises(ValueError):
                self.render({section: {key: "perhaps"}})

    def test_cli_invalid_input_never_truncates_existing_output(self):
        invalid_inputs = (
            json.dumps({"axi": {"protocol": "AXI3"}}),
            json.dumps({"axi": {"qos_width": 0, "default_qos": 1}}),
            json.dumps({"support": {"exclusive_access": True}}),
            json.dumps({"coverage": {"enable_coverage": "perhaps"}}),
            json.dumps({"checker": {"misspelled_option": True}}),
            "{ malformed JSON", "[]",
        )
        sentinel = b"// Existing generated output must survive invalid input.\n\x00\xff"
        with tempfile.TemporaryDirectory(prefix="axi4_cfg_invalid_") as directory:
            cfg_path = Path(directory) / "input.json"
            out_path = Path(directory) / "existing.sv"
            for content in invalid_inputs:
                with self.subTest(input=content):
                    cfg_path.write_text(content)
                    out_path.write_bytes(sentinel)
                    result = subprocess.run(
                        [sys.executable, "-B", str(GENERATOR), "--cfg", str(cfg_path), "--out", str(out_path)],
                        stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, timeout=15,
                    )
                    self.assertNotEqual(result.returncode, 0, result.stdout)
                    self.assertEqual(out_path.read_bytes(), sentinel)

    def test_cli_valid_profile_writes_only_requested_temporary_output(self):
        profile = ROOT / "tests/configs/scp_bach_ctrl_m0.json"
        expected = self.render(json.loads(profile.read_text()))
        with tempfile.TemporaryDirectory(prefix="axi4_cfg_valid_") as directory:
            output = Path(directory) / "nested" / "target_pkg.sv"
            result = subprocess.run(
                [sys.executable, "-B", str(GENERATOR), "--cfg", str(profile), "--out", str(output)],
                stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True, timeout=15,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(output.read_text(), expected)
            self.assertIn("does not prove driver or DUT capability", result.stderr)


if __name__ == "__main__":
    unittest.main()
