#!/usr/bin/env python3
"""Exercise isolation and process cleanup without requiring an HDL simulator.

Run with Python 3.6+: python3 -B -m unittest discover -s tests/integration -v
The generated configuration uses the real project generators. Fake make/simv
executables test orchestration only; they are not evidence of HDL correctness.
"""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock


PROJECT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT / "scripts"))
SPEC = importlib.util.spec_from_file_location("run_isolated", str(PROJECT / "scripts/run_isolated.py"))
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)
REGRESSION_SPEC = importlib.util.spec_from_file_location(
    "integration_regression", str(PROJECT / "tests/integration/run_regression.py"))
REGRESSION = importlib.util.module_from_spec(REGRESSION_SPEC)
REGRESSION_SPEC.loader.exec_module(REGRESSION)


def snapshot(root):
    return {str(path.relative_to(root)): hashlib.sha256(path.read_bytes()).hexdigest()
            for path in root.rglob("*") if path.is_file() and "__pycache__" not in path.parts}


def live_process(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    # Linux containers may retain adopted zombies until PID 1 reaps them.
    # Avoid ps: macOS sandbox profiles may prohibit launching it.
    try:
        fields = (Path("/proc") / str(pid) / "stat").read_text().rsplit(")", 1)[1].split()
        return fields[0] != "Z"
    except (OSError, IndexError):
        return True


class IsolatedRunnerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="axi4_isolation_test_")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.project = self.root / "source"
        self.project.mkdir()
        # Never edit the real source: even deliberate integrity violations use
        # this private fixture. Exclude tests to avoid recursively copying it.
        for name in ("Makefile", "filelist.f", "docs", "scripts", "tb"):
            source = PROJECT / name
            if source.is_dir():
                shutil.copytree(str(source), str(self.project / name),
                                ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "*.log"))
            else:
                shutil.copy2(str(source), str(self.project / name))
        self.work = self.root / "runs"
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        self.env["PATH"] = str(self.bin) + os.pathsep + self.env.get("PATH", "")
        self.pid_file = self.root / "child_pids"
        self.env["AXI_ISOLATED_TEST_PIDS"] = str(self.pid_file)
        self.env["AXI_ISOLATED_TEST_SOURCE"] = str(self.project)

    def write_executable(self, path, body):
        path.write_text("#!{}\n{}\n".format(sys.executable, body))
        path.chmod(0o755)

    def mock_make(self, simulation):
        body = ("from pathlib import Path\n"
                "out = Path('work/isolated')\n"
                "out.mkdir(parents=True, exist_ok=True)\n"
                "simv = out / 'simv'\n"
                "simv.write_text({!r})\n"
                "simv.chmod(0o755)\n").format("#!{}\n{}\n".format(sys.executable, simulation))
        self.write_executable(self.bin / "make", body)

    def cli(self, *args):
        command = [sys.executable, "-B", str(self.project / "scripts/run_isolated.py"),
                   "--work-root", str(self.work)] + list(args)
        result = subprocess.run(command, env=self.env, stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, universal_newlines=True, timeout=20)
        destinations = list(self.work.glob("axi4_isolated_*"))
        self.assertEqual(len(destinations), 1, result.stdout)
        report = json.loads((destinations[0] / "isolated_result.json").read_text())
        return result, report, destinations[0]

    def test_prepare_preserves_source_and_both_workbooks(self):
        before = snapshot(self.project)
        destination = self.root / "prepared"
        destination.mkdir()
        RUNNER.prepare(self.project, destination)
        self.assertEqual(snapshot(self.project), before)
        self.assertEqual(RUNNER.digest(destination / RUNNER.WORKBOOK), RUNNER.BASELINE_SHA)
        self.assertEqual((destination / "docs/seq/seq_table.xlsx").read_bytes(),
                         (self.project / "docs/seq/seq_table.xlsx").read_bytes())
        self.assertTrue((destination / "tb/generated/axi4_vip_cfg_pkg.sv").is_file())

    def test_prepare_only_records_independent_profile_and_plan(self):
        profile = self.root / "profile.json"
        cfg = json.loads((self.project / "tb/generated/axi4_vip_cfg.json").read_text())
        cfg["axi"].update(data_width=256, id_width=8, len_width=4)
        profile.write_text(json.dumps(cfg))
        plan = self.root / "plan.json"
        shutil.copy2(str(self.project / "docs/seq/seq_plan.json"), str(plan))
        before = snapshot(self.project)
        result, report, destination = self.cli("--prepare-only", "--profile", str(profile),
                                               "--plan", str(plan))
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(report["status"], "prepared")
        self.assertEqual(report["stage"], "complete")
        self.assertEqual(report["profile_sha256"], RUNNER.digest(profile))
        self.assertEqual(report["plan_sha256"], RUNNER.digest(plan))
        self.assertEqual(report["source_workbook_sha256"], RUNNER.BASELINE_SHA)
        self.assertEqual(report["isolated_workbook_sha256"], RUNNER.BASELINE_SHA)
        self.assertEqual(snapshot(self.project), before)

    def test_changed_source_rejected_and_failure_recorded(self):
        workbook = self.project / RUNNER.WORKBOOK
        workbook.write_bytes(workbook.read_bytes() + b"intentional test change")
        result, report, destination = self.cli("--prepare-only")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertIn("protected baseline", report["error"])
        self.assertEqual(report["source_workbook_sha256"], RUNNER.digest(workbook))
        self.assertFalse((destination / "tb").exists())

    def test_invalid_profile_failure_recorded(self):
        profile = self.root / "invalid.json"
        profile.write_text("{")
        result, report, destination = self.cli("--prepare-only", "--profile", str(profile))
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["stage"], "prepare")
        self.assertIn("non-zero exit status", report["error"])
        self.assertEqual(report["source_workbook_sha256"], RUNNER.BASELINE_SHA)

    def test_compile_failure_records_command_and_stage(self):
        self.write_executable(self.bin / "make", "import sys\nsys.exit(7)")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["stage"], "compile")
        self.assertIn("_compile_current", report["compile_command"])
        self.assertIn("exit status 7", report["error"])

    def test_run_failure_records_command_and_stage(self):
        self.mock_make("import sys\nsys.exit(9)")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["stage"], "run")
        self.assertTrue(report["run_command"][0].endswith("/simv"))
        self.assertIn("exit status 9", report["error"])

    def test_missing_uvm_summary_fails(self):
        self.mock_make("print('simulation stopped before UVM summary')")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["stage"], "validate")
        self.assertEqual(report["status"], "failed")
        self.assertIn("missing/failed UVM ERROR summary", report["error"])

    def test_nonzero_uvm_summary_fails(self):
        self.mock_make("print('UVM_ERROR : 1\\nUVM_FATAL : 0\\nAXI_CHECKER_PASS')")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertIn("missing/failed UVM ERROR summary", report["error"])

    def test_hdl_error_with_zero_process_status_fails(self):
        self.mock_make("print('Error: checker violation\\nUVM_ERROR : 0\\nUVM_FATAL : 0\\nAXI_CHECKER_FAILED')")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("HDL/checker diagnostic", report["error"])

    def test_missing_checker_completion_fails(self):
        self.mock_make("print('UVM_ERROR : 0\\nUVM_FATAL : 0')")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("missing integrated checker", report["error"])

    def test_zero_uvm_summaries_pass_and_preserve_source(self):
        self.mock_make("print('UVM_ERROR : 0\\nUVM_FATAL : 0\\nAXI_CHECKER_PASS')")
        before = snapshot(self.project)
        result, report, destination = self.cli()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["stage"], "complete")
        self.assertEqual(snapshot(self.project), before)

    def test_final_integrity_failure_cannot_leave_passed_report(self):
        self.mock_make("import os\nfrom pathlib import Path\n"
                       "source = Path(os.environ['AXI_ISOLATED_TEST_SOURCE'])\n"
                       "workbook = source / 'docs/vip/vip_cfg.xlsx'\n"
                       "workbook.write_bytes(workbook.read_bytes() + b'test corruption')\n"
                       "print('UVM_ERROR : 0\\nUVM_FATAL : 0\\nAXI_CHECKER_PASS')")
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertIn("source vip_cfg.xlsx", report["integrity_errors"][0])
        self.assertNotIn("ISOLATED_PASSED", result.stdout)

    def test_isolated_workbook_change_fails_and_source_stays_unchanged(self):
        self.mock_make("from pathlib import Path\n"
                       "workbook = Path('docs/vip/vip_cfg.xlsx')\n"
                       "workbook.write_bytes(workbook.read_bytes() + b'test corruption')\n"
                       "print('UVM_ERROR : 0\\nUVM_FATAL : 0\\nAXI_CHECKER_PASS')")
        before = snapshot(self.project)
        result, report, destination = self.cli()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(report["status"], "failed")
        self.assertIn("isolated vip_cfg.xlsx", report["integrity_errors"][0])
        self.assertEqual(snapshot(self.project), before)

    def process_tree_body(self):
        helper = self.root / "ignore_term_child.py"
        helper.write_text("import os, signal, subprocess, sys, time\n"
                          "signal.signal(signal.SIGTERM, signal.SIG_IGN)\n"
                          "with open(os.environ['AXI_ISOLATED_TEST_PIDS'], 'a') as out:\n"
                          "    out.write(str(os.getpid()) + '\\n')\n"
                          "if sys.argv[1] == 'child':\n"
                          "    subprocess.Popen([sys.executable, __file__, 'grandchild'])\n"
                          "time.sleep(60)\n")
        return ("import os, subprocess, sys, time\n"
                "with open(os.environ['AXI_ISOLATED_TEST_PIDS'], 'a') as out:\n"
                "    out.write(str(os.getpid()) + '\\n')\n"
                "subprocess.Popen([sys.executable, {!r}, 'child'])\n"
                "time.sleep(60)\n").format(str(helper))

    def assert_tree_stopped(self, action):
        pids = []
        try:
            result, report, destination = action()
            pids = [int(value) for value in self.pid_file.read_text().splitlines()]
            self.assertEqual(len(pids), 3, result.stdout)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(report["status"], "failed")
            self.assertIn("timed out", report["error"])
            deadline = time.monotonic() + 2
            while any(live_process(pid) for pid in pids) and time.monotonic() < deadline:
                time.sleep(0.02)
            self.assertFalse([pid for pid in pids if live_process(pid)],
                             "timeout left a running child or grandchild")
            return report
        finally:
            if self.pid_file.exists():
                pids = [int(value) for value in self.pid_file.read_text().splitlines()]
            for pid in pids:
                if live_process(pid):
                    try:
                        os.kill(pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass

    def test_compile_timeout_kills_child_and_grandchild_after_leader_exits(self):
        self.write_executable(self.bin / "make", self.process_tree_body())
        report = self.assert_tree_stopped(lambda: self.cli("--compile-timeout", "1"))
        self.assertEqual(report["stage"], "compile")

    def test_run_timeout_kills_child_and_grandchild_after_leader_exits(self):
        self.mock_make(self.process_tree_body())
        report = self.assert_tree_stopped(lambda: self.cli("--run-timeout", "1"))
        self.assertEqual(report["stage"], "run")


class RegressionIntegrityTests(unittest.TestCase):
    """Successful child suites cannot conceal damage from final verification."""

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="axi4_regression_integrity_")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.project = self.root / "source"
        workbook = self.project / RUNNER.WORKBOOK
        workbook.parent.mkdir(parents=True)
        shutil.copyfile(str(PROJECT / RUNNER.WORKBOOK), str(workbook))
        self.work = self.root / "runs"

    def run_fixture(self, body="", unreadable=False, prepare_failure=False):
        def prepare_fixture(source, staged):
            if prepare_failure:
                raise RuntimeError("intentional preparation failure")
            workbook = staged / RUNNER.WORKBOOK
            workbook.parent.mkdir(parents=True)
            shutil.copyfile(str(source / RUNNER.WORKBOOK), str(workbook))
            manifest = staged / "tests/integration/suites.json"
            manifest.parent.mkdir(parents=True)
            script = ("from pathlib import Path\n"
                      "source = Path({!r})\n"
                      "staged = Path({!r})\n{}\n"
                      "print('INTEGRITY_FIXTURE_PASS')\n").format(
                          str(source / RUNNER.WORKBOOK), str(RUNNER.WORKBOOK), body)
            manifest.write_text(json.dumps({"suites": [{
                "name": "fixture", "command": [sys.executable, "-B", "-c", script],
                "required_patterns": ["^INTEGRITY_FIXTURE_PASS$"],
                "timeout_seconds": 10}]}))

        real_digest = REGRESSION.digest

        def checked_digest(path):
            # chmod is not a portable unreadable-file test when run as root.
            if unreadable and path.name == RUNNER.WORKBOOK.name:
                raise PermissionError("intentional workbook read denial")
            return real_digest(path)

        output = io.StringIO()
        failure = None
        with mock.patch.object(REGRESSION, "PROJECT", self.project), \
                mock.patch.object(REGRESSION, "prepare", prepare_fixture), \
                mock.patch.object(REGRESSION, "digest", checked_digest), \
                mock.patch.object(sys, "argv", ["run_regression.py", "--work-root", str(self.work)]), \
                contextlib.redirect_stdout(output):
            try:
                REGRESSION.main()
            except Exception as error:
                failure = error
        reports = list(self.work.glob("axi4_regression_*/regression_result.json"))
        self.assertEqual(len(reports), 1, output.getvalue())
        return failure, json.loads(reports[0].read_text()), output.getvalue()

    def assert_integrity_failure(self, failure, report, output):
        self.assertIsInstance(failure, ValueError)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["suites"][0]["status"], "passed")
        self.assertIn("finished_utc", report)
        self.assertNotIn("REGRESSION_PASS", output)

    def test_intact_workbooks_pass_and_record_hashes(self):
        failure, report, output = self.run_fixture()
        self.assertIsNone(failure)
        self.assertEqual(report["status"], "passed")
        self.assertEqual(report["source_workbook_sha256"], RUNNER.BASELINE_SHA)
        self.assertEqual(report["staged_workbook_sha256"], RUNNER.BASELINE_SHA)
        self.assertIn("REGRESSION_PASS suites=1", output)

    def test_deleted_source_workbook_fails_with_json(self):
        failure, report, output = self.run_fixture("source.unlink()")
        self.assert_integrity_failure(failure, report, output)
        self.assertIn("cannot verify source workbook", report["integrity_error"])
        self.assertEqual(report["staged_workbook_sha256"], RUNNER.BASELINE_SHA)

    def test_deleted_staged_workbook_fails_with_json(self):
        failure, report, output = self.run_fixture("staged.unlink()")
        self.assert_integrity_failure(failure, report, output)
        self.assertIn("cannot verify staged workbook", report["integrity_error"])
        self.assertEqual(report["source_workbook_sha256"], RUNNER.BASELINE_SHA)

    def test_both_changed_workbooks_retain_all_hashes_and_errors(self):
        failure, report, output = self.run_fixture(
            "source.write_bytes(b'changed source')\nstaged.write_bytes(b'changed staged')")
        self.assert_integrity_failure(failure, report, output)
        self.assertEqual(report["integrity_errors"],
                         ["source workbook changed", "staged workbook changed"])
        for label in ("source", "staged"):
            expected = hashlib.sha256(("changed " + label).encode()).hexdigest()
            self.assertEqual(report[label + "_workbook_sha256"], expected)

    def test_unreadable_workbooks_fail_without_preventing_json(self):
        failure, report, output = self.run_fixture(unreadable=True)
        self.assert_integrity_failure(failure, report, output)
        self.assertEqual(len(report["integrity_errors"]), 2)
        for label, error in zip(("source", "staged"), report["integrity_errors"]):
            self.assertIn("cannot verify " + label + " workbook", error)
            self.assertIn("intentional workbook read denial", error)

    def test_prepare_failure_retained_when_staged_workbook_missing(self):
        failure, report, output = self.run_fixture(prepare_failure=True)
        self.assertIsInstance(failure, RuntimeError)
        self.assertEqual(report["status"], "failed")
        self.assertEqual(report["error"], "intentional preparation failure")
        self.assertIn("cannot verify staged workbook", report["integrity_error"])
        self.assertEqual(report["source_workbook_sha256"], RUNNER.BASELINE_SHA)
        self.assertNotIn("REGRESSION_PASS", output)


if __name__ == "__main__":
    unittest.main()
