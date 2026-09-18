import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from gen_axi4_seq import emit_sequence
from sequence_plan import normalize_plan
from cases import plan, lane_plan


class GeneratorTest(unittest.TestCase):
    def test_128_submissions_precede_wait(self):
        normalized = normalize_plan(plan())
        text = "\n".join(emit_sequence(normalized["sequences"][0], normalized))
        prefix = text.split("axi_wait_write_checked", 1)[0]
        self.assertEqual(prefix.count("axi_submit_write_payload("), 128)
        self.assertEqual(text.count("axi_submit_write_payload("), 192)
        self.assertEqual(text.count("axi_submit_read_payload("), 320)
        self.assertNotIn("lock_bus", text)

    def test_high_payload_and_readback_are_emitted(self):
        normalized = normalize_plan(lane_plan())
        text = "\n".join(emit_sequence(normalized["sequences"][0], normalized))
        self.assertIn("AXI_DATA_WIDTH'('h", text)
        self.assertIn("axi_read_by_mode", text)
        self.assertNotIn("skip_read", text)
        self.assertIn("AXI_DATA_WIDTH != 256", text)

    def test_missing_final_await_is_drained(self):
        normalized = normalize_plan(plan())
        seq = {"name": "last_read", "steps": [normalized["sequences"][0]["steps"][129]]}
        text = "\n".join(emit_sequence(seq, normalized))
        self.assertEqual(text.count("axi_submit_read_payload("), 1)
        self.assertEqual(text.count("axi_wait_read_checked("), 1)

    def test_invalid_input_keeps_prior_outputs(self):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            seq_dir = work / "seqs"
            seq_dir.mkdir()
            prior = seq_dir / "previous.svh"
            prior.write_text("unchanged")
            source = work / "plan.json"
            for invalid in [
                {"sequences": [{"name": "bad-name", "steps": []}]},
                {"sequences": [{"name": "valid_name", "steps": [{"op": "read", "addr": 3}]}]},
                {"sequences": [{"name": "axi4_doc_plan_seq", "steps": []}]},
            ]:
                source.write_text(json.dumps(invalid))
                result = subprocess.run([sys.executable, str(ROOT / "scripts/gen_axi4_seq.py"),
                                         "--plan", str(source), "--out", str(work / "out.sv"),
                                         "--seq-dir", str(seq_dir)],
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(prior.read_text(), "unchanged")

    def test_table_profile_rejects_old_stride_at_256(self):
        with tempfile.TemporaryDirectory() as directory:
            work = Path(directory)
            table = work / "sequence.csv"
            table.write_text("seq_name,step,op,addr,data\nold_register,1,write,0x124,0x66\n")
            cfg = work / "cfg.json"
            output = work / "plan.json"
            for width, should_pass in [(32, True), (256, False)]:
                cfg.write_text(json.dumps({"axi": {"data_width": width}}))
                output.write_text("prior plan")
                result = subprocess.run([sys.executable, str(ROOT / "scripts/table_to_seq_plan.py"),
                                         "--table", str(table), "--vip-cfg", str(cfg),
                                         "--out", str(output)],
                                        stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                self.assertEqual(result.returncode == 0, should_pass)
                if should_pass:
                    self.assertEqual(json.loads(output.read_text())["axi_data_width"], 32)
                else:
                    self.assertEqual(output.read_text(), "prior plan")


if __name__ == "__main__":
    unittest.main()
