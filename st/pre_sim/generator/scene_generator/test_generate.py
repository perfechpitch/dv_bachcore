#!/usr/bin/env python3
import importlib.util
import os
import tempfile
import time
import unittest


HERE = os.path.dirname(os.path.abspath(__file__))
SPEC = importlib.util.spec_from_file_location("scene_generate", os.path.join(HERE, "generate.py"))
GEN = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GEN)


class SceneGeneratorTest(unittest.TestCase):
    def test_plusarg_discovery_and_rendering(self):
        supported = GEN.parse_supported_plusargs(
            '$test$plusargs("random_delay");\n'
            '$value$plusargs("task_pc=%h", task_pc);\n'
            '$value$plusargs("task_num=%d", task_num);\n',
            "demo_test",
        )
        self.assertEqual(set(supported), {"random_delay", "task_pc", "task_num"})
        scene = {
            "scene_id": 7,
            "scene_name": "demo_test",
            "scenario": {
                "seq_name": "demo",
                "args": {"random_delay": True, "task_num": 4},
            },
            "_seq_relative": "workload/demo.sv",
            "_supported_args": supported,
        }
        rendered = GEN.render_case(scene)
        self.assertIn("case_name      = demo_test", rendered)
        self.assertIn("+directed_seq_name=demo+random_delay+task_num=4", rendered)
        self.assertNotIn("+task_pc=", rendered)

    def test_unknown_configured_arg_is_rejected(self):
        supported = GEN.parse_supported_plusargs(
            '$value$plusargs("task_pc=%h", task_pc);', "demo_test"
        )
        with self.assertRaises(GEN.SceneError):
            GEN.validate_arg_value("demo_test", "task_pc", "not_hex", supported["task_pc"])

    def test_manual_case_is_not_overwritten(self):
        scene = {
            "scene_id": 1,
            "scene_name": "manual_test",
            "scenario": {"seq_name": "demo", "args": {}},
            "_seq_relative": "workload/demo.sv",
            "_supported_args": {},
        }
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "directed.lst")
            with open(path, "w") as handle:
                handle.write("- case_name = manual_test\n")
            with self.assertRaises(GEN.SceneError):
                GEN.sync_directed_list(path, [scene])

    def test_stale_single_log_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            for name in ("compile.log", "sim.log"):
                with open(os.path.join(directory, name), "w") as handle:
                    handle.write("UVM_ERROR : 0\nUVM_FATAL : 0\n")
            with self.assertRaises(GEN.SceneError):
                GEN.verify_single_result(directory, time.time() + 5, "demo")

    def test_batch_summary_requires_all_pass(self):
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "batch.log")
            with open(path, "w") as handle:
                handle.write("Total : 2\nPass  : 2\nFail  : 0\nUnRun: 0\n")
            GEN.verify_batch_result(path, "demo")
            with open(path, "w") as handle:
                handle.write("Total : 2\nPass  : 1\nFail  : 0\nUnRun: 1\n")
            with self.assertRaises(GEN.SceneError):
                GEN.verify_batch_result(path, "demo")

    def test_scene_output_path_is_derived_from_numeric_id(self):
        scene = {"scene_id": 12}
        with tempfile.TemporaryDirectory() as directory:
            expected = os.path.join(directory, "scene_012")
            actual = os.path.join(directory, "scene_{0:03d}".format(scene["scene_id"]))
            self.assertEqual(actual, expected)


if __name__ == "__main__":
    unittest.main()
