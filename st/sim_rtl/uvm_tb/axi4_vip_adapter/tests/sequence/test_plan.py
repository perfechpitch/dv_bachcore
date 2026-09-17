"""Sequence JSON contract tests; run directly or through unittest discovery."""

import copy
import json
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from sequence_plan import normalize_plan


def profile(*steps, **changes):
    result = dict(axi_data_width=256, axi_addr_width=32, axi_id_width=8,
                  axi_len_width=4, max_burst_len=16,
                  sequences=[dict(name="contract_seq", steps=list(steps))])
    result.update(changes)
    return result


def submit(op="submit_write", **changes):
    result = dict(op=op, addr="0x1000", id=255, size=5, beats=1)
    if op == "submit_write":
        result["data"] = ["0x" + "ab" * 32]
    result.update(changes)
    return result


def step(plan):
    return normalize_plan(plan)["sequences"][0]["steps"][0]


class PlanContract(unittest.TestCase):
    def bad(self, plan):
        with self.assertRaises(ValueError):
            normalize_plan(plan)

    def test_256_payload_and_default_masks_strobes(self):
        value = (1 << 255) | 0x12345678
        write = step(profile(submit(data=[hex(value)])))
        self.assertEqual(write["data"], [value])
        self.assertEqual(write["strb"], [(1 << 32) - 1])
        read = step(profile(submit("submit_read", expect=[hex(value)])))
        self.assertEqual(read["expect_mask"], [(1 << 256) - 1])
        self.assertEqual(read["expect_resp"], 0)
        self.assertEqual(read["burst"], "INCR")

    def test_no_mutation_and_metadata_preserved(self):
        plan = profile(submit(), description="test memory only")
        saved = copy.deepcopy(plan)
        actual = normalize_plan(plan)
        actual["sequences"][0]["steps"][0]["data"][0] = 0
        self.assertEqual(plan, saved)
        self.assertEqual(actual["description"], plan["description"])

    def test_strict_unsigned_numbers(self):
        for value in (-1, True, False, 1.0, None, "-1", "1+2", "'hff",
                      "32'h1", "0b1", "ff", "0x", "0x_ff", "_1", "1__0"):
            with self.subTest(value=value):
                self.bad(profile(submit(id=value)))
        self.assertEqual(step(profile(submit(id="00015")))["id"], 15)
        self.assertEqual(step(profile(submit(addr="0x0000_1000")))["addr"], 4096)

    def test_lengths_and_limits(self):
        valid = submit(beats=16, data=[0] * 16)
        self.assertEqual(step(profile(valid))["beats"], 16)
        for changes in (dict(beats=0, data=[]), dict(beats=17, data=[0] * 17),
                        dict(beats=2, data=[0]), dict(data=1), dict(strb=[]),
                        dict(beats=True), dict(beats=1, data=[0, 0])):
            with self.subTest(changes=changes):
                self.bad(profile(submit(**changes)))
        self.bad(profile(valid, max_burst_len=8))
        self.bad(profile(submit(), max_burst_len=17))
        self.bad(profile(submit(), max_burst_len=0))
        self.assertEqual(normalize_plan(dict(axi_len_width=2))["max_burst_len"], 4)

    def test_payload_strobes_and_masks_do_not_truncate(self):
        for changes in (dict(data=[1 << 256]), dict(strb=[1 << 32]),
                        dict(data=[-1]), dict(strb=[-1])):
            self.bad(profile(submit(**changes)))
        for changes in (dict(expect=[1 << 256]), dict(expect=[0], expect_mask=[1 << 256]),
                        dict(expect=[0], expect_mask=[]), dict(expect_mask=[0]),
                        dict(expect=[]), dict(expect=[0, 0])):
            self.bad(profile(submit("submit_read", **changes)))
        read = step(profile(submit("submit_read", expect=[0], expect_mask=[0])))
        self.assertEqual(read["expect_mask"], [0])

    def test_single_beat_narrow_lanes(self):
        for size in range(6):
            transfer_bytes = 1 << size
            for addr in range(0x1000, 0x1020, transfer_bytes):
                value = (1 << (8 * transfer_bytes)) - 1
                actual = step(profile(submit(addr=addr, size=size, data=[value])))
                self.assertEqual(actual["data"], [value])
                self.assertEqual(actual["strb"], [(1 << transfer_bytes) - 1])
        # Relative strobe/payload only: a byte at lane 31 still uses strb=1.
        self.bad(profile(submit(addr=0x101f, size=0, data=[0xff], strb=[1 << 31])))
        self.bad(profile(submit(addr=0x101f, size=0, data=[0x100])))
        self.bad(profile(submit(size=6, data=[0])))
        self.bad(profile(submit(addr=0x1001, size=1, data=[0])))

    def test_narrow_burst_requires_opt_in(self):
        narrow = submit(addr=0x101e, size=1, beats=2, data=[0x1234, 0x5678])
        self.bad(profile(narrow))
        actual = step(profile(narrow, support_narrow_burst=True))
        self.assertEqual(actual["data"], [0x1234, 0x5678])
        self.assertEqual(actual["strb"], [3, 3])
        self.bad(profile(narrow, support_narrow_burst="false"))

    def test_4kb_and_address_boundaries(self):
        self.assertEqual(step(profile(submit(addr=0xfe0)))["addr"], 0xfe0)
        self.bad(profile(submit(addr=0xfe0, beats=2, data=[0, 0])))
        self.bad(profile(submit(addr=1 << 32)))
        self.bad(profile(submit(addr=0xffffffe0, beats=2, data=[0, 0])))
        self.assertEqual(step(profile(submit(addr=0xffffffe0)))["addr"], 0xffffffe0)
        self.bad(profile(submit(id=256)))
        self.bad(profile(submit(addr=0x1004)))

    def test_submit_fields_required_unknown_fields_and_responses(self):
        for key in ("addr", "id", "size", "beats", "data"):
            value = submit()
            del value[key]
            self.bad(profile(value))
        for changes in (dict(burst="WRAP"), dict(burst=1), dict(strbb=[1]),
                        dict(expect_resp=4), dict(expect_resp=-1), dict(expect=[0])):
            self.bad(profile(submit(**changes)))
        self.bad(profile(dict(op="await_all", count=2)))
        for response in range(4):
            self.assertEqual(step(profile(submit(expect_resp=response)))["expect_resp"],
                             response)

    def test_legacy_width_alignment_and_default_profile(self):
        old = dict(sequences=[dict(name="old", steps=[
            dict(op="write", addr="0x124", data="0xffffffff"),
            dict(op="read", addr="0x124", expect="0xffffffff")])])
        normalized = normalize_plan(old)
        self.assertEqual(normalized["axi_data_width"], 32)
        self.assertEqual(normalized["axi_id_width"], 4)
        self.assertEqual(normalized["sequences"][0]["steps"][0]["data"], 0xffffffff)
        self.bad(dict(old, axi_data_width=256))
        self.bad(profile(dict(op="write", addr=0, data=1 << 256)))
        self.bad(profile(dict(op="read", addr=0, expect=1 << 256)))
        self.bad(profile(dict(op="write", addr=0, data=0, strb=1 << 32)))
        self.assertEqual(step(profile(dict(op="write", addr=0, data=1 << 255)))["data"],
                         1 << 255)

    def test_legacy_byte_window(self):
        write = dict(op="write_by_mode", addr=0x101f, data=1 << 255,
                     write_mode="SINGLE_ADDR_SINGLE_BYTE")
        normalize_plan(profile(write, dict(op="read", addr=0x101f, expect=1 << 255)))
        self.bad(profile(dict(write, addr=0xfffffff0)))
        self.bad(profile(dict(write, write_mode="FULL_ADDR_SINGLE_BYTE")))
        self.bad(profile(dict(write, write_mode="UNKNOWN")))
        self.bad(profile(write, dict(op="write", addr=0x1000, data=0),
                         dict(op="read", addr=0x101f)))

    def test_ranges_and_files_left_untouched(self):
        value = dict(op="range_write", addr=0x1000, addr_stride=32, count=3,
                     data_file="/nonexistent/untouched.hex", data_start=0)
        self.assertEqual(step(profile(value))["data_file"], value["data_file"])
        for changes in (dict(count=0), dict(count=-1), dict(count=1 << 32),
                        dict(addr_stride=0), dict(addr_stride=4), dict(addr=0x1004),
                        dict(addr=0xffffffe0, count=2), dict(data_start=1 << 32)):
            self.bad(profile(dict(value, **changes)))
        byte_range = dict(value, addr=0x101f, addr_stride=1,
                          write_mode="SINGLE_ADDR_SINGLE_BYTE", readback=False)
        normalize_plan(profile(byte_range))
        self.bad(profile(dict(byte_range, op="range_read")))

    def test_legacy_rejects_submit_fields_instead_of_ignoring(self):
        samples = [dict(op="write", addr=0x5000, data=1),
                   dict(op="write_by_mode", addr=0x5000, data=1),
                   dict(op="read", addr=0x5000),
                   dict(op="range_write", addr=0x5000, count=2, addr_stride=32),
                   dict(op="range_read", addr=0x5000, count=2, addr_stride=32)]
        extra_fields = dict(id=7, size=2, beats=4, burst="INCR",
                            expect_resp=2, expect_mask=0xff)
        for sample in samples:
            for key, value in extra_fields.items():
                with self.subTest(op=sample["op"], field=key):
                    with self.assertRaisesRegex(ValueError, "use submit_write/submit_read"):
                        normalize_plan(profile(dict(sample, **{key: value})))
            self.bad(profile(dict(sample, typo_field=1)))
        self.bad(profile(dict(op="write", addr=0, data=0, expect=0)))
        self.bad(profile(dict(op="write_by_mode", addr=0, data=0, strb=1)))
        self.bad(profile(dict(op="read", addr=0, data=0)))
        self.bad(profile(dict(op="range_read", addr=0, count=1, addr_stride=32,
                              readback=True)))

    def test_overlapping_write_windows_require_readback_disabled(self):
        overlap = dict(op="range_write", addr=0x101f, addr_stride=1, count=2,
                       write_mode="SINGLE_ADDR_SINGLE_BYTE")
        self.bad(profile(overlap))
        self.bad(profile(dict(overlap, readback=True)))
        normalize_plan(profile(dict(overlap, readback=False)))
        normalize_plan(profile(dict(overlap, count=1)))
        normalize_plan(profile(dict(overlap, addr_stride=32)))
        self.bad(profile(dict(overlap, readback="false")))

    def test_gap_validation_matches_helper_types(self):
        write = dict(op="write", addr=0, data=0)
        for invalid in (-1, True, False, 1 << 32, "3", "-1", "UNKNOWN", [], 1.5):
            with self.subTest(value=invalid):
                self.bad(profile(dict(write, tr_gap=invalid)))
                plan = profile(write)
                plan["sequences"][0]["seq_gap"] = invalid
                self.bad(plan)
        for valid in (0, 3, "FIXED", "RANDOM", "RAND", "MID", "", None):
            normalize_plan(profile(dict(write, tr_gap=valid)))
            plan = profile(write)
            plan["sequences"][0]["seq_gap"] = valid
            normalize_plan(plan)
        text_gap_ops = [dict(write, op="write_by_mode"),
                        dict(op="range_write", addr=0, addr_stride=32, count=1),
                        dict(op="range_read", addr=0, addr_stride=32, count=1)]
        for sample in text_gap_ops:
            self.bad(profile(dict(sample, tr_gap=3)))
            self.assertEqual(step(profile(dict(sample, tr_gap=0)))["tr_gap"], "")
            self.assertEqual(step(profile(dict(sample, tr_gap=" random ")))["tr_gap"],
                             "RANDOM")

    def test_original_example_is_valid_and_128_plan(self):
        original = json.loads((ROOT / "docs/seq/seq_plan.json").read_text())
        normalize_plan(original)
        sys.path.insert(0, str(Path(__file__).resolve().parent))
        from cases import plan
        traffic = normalize_plan(plan())
        steps = traffic["sequences"][0]["steps"]
        first_wait = next(i for i, item in enumerate(steps) if item["op"] == "await_all")
        self.assertEqual(first_wait, 128)
        self.assertEqual(len({item["id"] for item in steps[:first_wait]}), 128)
        self.assertGreater(steps[0]["data"][0], 1 << 248)

    def test_profile_and_structure_validation(self):
        for changes in (dict(axi_data_width=24), dict(axi_data_width=7),
                        dict(axi_data_width=2048), dict(axi_len_width=9),
                        dict(axi_addr_width=0), dict(axi_id_width=True),
                        dict(sequences={}), dict(sequences=[dict(steps={})])):
            self.bad(profile(**changes))
        self.bad([])
        self.bad(profile(dict(op="silent_unknown")))


if __name__ == "__main__":
    unittest.main()
