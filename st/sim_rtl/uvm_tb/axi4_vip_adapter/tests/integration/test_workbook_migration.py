#!/usr/bin/env python3
"""Temporary-file tests for the explicitly authorized workbook transition."""
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

PROJECT = Path(__file__).resolve().parents[2]
SPEC = importlib.util.spec_from_file_location("deploy_verified", str(PROJECT / "scripts/deploy_verified.py"))
DEPLOY = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DEPLOY)


def sha(data):
    return hashlib.sha256(data).hexdigest()


class WorkbookMigrationTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="axi4_workbook_migration_")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.staged = self.root / "staged"
        self.target = self.root / "target"
        self.backups = self.root / "backups"
        self.before = b"reviewed old workbook"
        self.after = b"reviewed new workbook"
        self.baseline = {
            "version": 1, "workbook": DEPLOY.WORKBOOK,
            "current_sha256": sha(self.after), "previous_sha256": sha(self.before),
            "backup_git_revision": "1" * 40, "backup_git_path": "project/" + DEPLOY.WORKBOOK,
            "authorization": "test fixture for an explicit reviewed transition"}
        self.baseline_path = self.root / "workbook_baseline.json"
        self.baseline_path.write_text(json.dumps(self.baseline) + "\n")
        self.rows = []
        self.originals = {}
        for name, old, new in (
                (DEPLOY.WORKBOOK, self.before, self.after),
                ("docs/vip/base_vip_cfg.lock.json", b"old lock", b"new lock"),
                (DEPLOY.BASELINE_MANIFEST, None, self.baseline_path.read_bytes()),
                ("scripts/workbook_baseline.py", None,
                 (PROJECT / "scripts/workbook_baseline.py").read_bytes()),
                ("scripts/example.py", b"old script", b"new script")):
            candidate = self.staged / name
            candidate.parent.mkdir(parents=True, exist_ok=True)
            candidate.write_bytes(new)
            if old is not None:
                original = self.target / name
                original.parent.mkdir(parents=True, exist_ok=True)
                original.write_bytes(old)
            self.originals[name] = old
            self.rows.append({"path": name, "baseline_sha256": None if old is None else sha(old),
                              "candidate_sha256": sha(new)})
        self.migration = {"baseline_sha256": sha(self.before), "candidate_sha256": sha(self.after)}
        self.manifest = {"version": 1, "workbook_migration": self.migration, "files": self.rows}
        self.manifest_path = self.root / "manifest.json"
        self.save_manifest()
        for name, value in (("BASELINE", self.baseline), ("BASELINE_PATH", self.baseline_path),
                            ("WORKBOOK_SHA256", sha(self.after))):
            patch = mock.patch.object(DEPLOY, name, value)
            patch.start()
            self.addCleanup(patch.stop)

    def save_manifest(self):
        self.manifest_path.write_text(json.dumps(self.manifest) + "\n")

    def deploy(self, **kwargs):
        kwargs.setdefault("allow_workbook_migration", True)
        return DEPLOY.deploy(str(self.manifest_path), str(self.staged), str(self.target),
                             str(self.backups), **kwargs)

    def assert_originals(self):
        for name, data in self.originals.items():
            path = self.target / name
            if data is None:
                self.assertFalse(path.exists(), name)
            else:
                self.assertEqual(path.read_bytes(), data, name)

    def test_migration_requires_explicit_flag_and_exact_reviewed_pair(self):
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "explicit --allow"):
            self.deploy(allow_workbook_migration=False)
        self.migration["baseline_sha256"] = "0" * 64
        self.save_manifest()
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "reviewed previous/current"):
            self.deploy()
        self.assert_originals()
        self.assertFalse(self.backups.exists())

    def test_all_three_protected_files_are_required(self):
        self.rows[:] = [row for row in self.rows if row["path"] != DEPLOY.BASELINE_MANIFEST]
        self.save_manifest()
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "must list workbook"):
            self.deploy()
        self.assert_originals()

    def test_migration_does_not_unlock_other_configuration(self):
        self.rows.append({"path": "docs/vip/unrelated.json", "baseline_sha256": None,
                          "candidate_sha256": "0" * 64})
        self.save_manifest()
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "protected configuration"):
            self.deploy()
        self.assert_originals()

    def test_candidate_baseline_manifest_must_match_reviewed_manifest(self):
        self.rows[2]["candidate_sha256"] = "0" * 64
        self.save_manifest()
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "reviewed baseline"):
            self.deploy()
        self.assert_originals()

    def test_lock_hash_conflict_prevents_every_write(self):
        (self.target / "docs/vip/base_vip_cfg.lock.json").write_bytes(b"user edited lock")
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "user changes"):
            self.deploy()
        self.assertEqual((self.target / DEPLOY.WORKBOOK).read_bytes(), self.before)
        self.assertFalse(self.backups.exists())

    def test_concurrent_workbook_change_before_replace_is_not_overwritten(self):
        replace = DEPLOY.atomic_replace

        def edit_before_replace(*args, **kwargs):
            (self.target / DEPLOY.WORKBOOK).write_bytes(b"concurrent user workbook")
            return replace(*args, **kwargs)

        with mock.patch.object(DEPLOY, "atomic_replace", edit_before_replace):
            with self.assertRaisesRegex(DEPLOY.DeploymentError, "failed_needs_manual_recovery"):
                self.deploy()
        self.assertEqual((self.target / DEPLOY.WORKBOOK).read_bytes(), b"concurrent user workbook")
        self.assertEqual((self.target / "scripts/example.py").read_bytes(), b"old script")
        backup = next(self.backups.iterdir())
        self.assertEqual((backup / "files" / DEPLOY.WORKBOOK).read_bytes(), self.before)

    def test_checked_deploy_backup_standalone_rollback_and_idempotence(self):
        check = self.deploy(check_only=True)
        self.assertEqual(check["status"], "preflight_passed")
        self.assertFalse(self.backups.exists())
        result = self.deploy()
        self.assertEqual(result["status"], "deployed")
        self.assertEqual((self.target / DEPLOY.WORKBOOK).read_bytes(), self.after)
        self.assertTrue((self.target / "scripts/workbook_baseline.py").is_file())
        backup = Path(result["backup"])
        self.assertEqual((backup / "files" / DEPLOY.WORKBOOK).read_bytes(), self.before)
        self.assertEqual(json.loads((backup / "workbook_baseline.json").read_text()), self.baseline)
        again = self.deploy()
        self.assertEqual(again["applied_files"], [])
        DEPLOY.rollback(again["backup"])
        self.assertEqual((self.target / DEPLOY.WORKBOOK).read_bytes(), self.after)
        result = subprocess.run(["sh", str(backup / "rollback.sh")], stdout=subprocess.PIPE,
                                stderr=subprocess.STDOUT, universal_newlines=True, timeout=10)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assert_originals()
        self.assertFalse((self.target / "scripts/workbook_baseline.py").exists())
        self.assertEqual(DEPLOY.rollback(str(backup))["restored_files"], [])

    def test_mid_migration_failure_restores_workbook_and_lock(self):
        replace = DEPLOY.atomic_replace
        calls = [0]

        def fail_third(*args, **kwargs):
            calls[0] += 1
            if calls[0] == 3:
                raise OSError("injected failure after workbook and lock")
            return replace(*args, **kwargs)

        with mock.patch.object(DEPLOY, "atomic_replace", fail_third):
            with self.assertRaisesRegex(DEPLOY.DeploymentError, "failed_rolled_back"):
                self.deploy()
        self.assert_originals()

    def test_failure_after_all_protected_files_restores_previous_baseline(self):
        replace = DEPLOY.atomic_replace
        calls = []
        injected = [False]

        def fail_fourth(*args, **kwargs):
            calls.append(args[2])
            if len(calls) == 4:
                self.assertEqual(set(calls[:3]), DEPLOY.MIGRATION_PATHS)
                self.assertEqual(args[2], "scripts/workbook_baseline.py")
                # Establish that the new baseline really reached the target,
                # rather than merely failing before the third protected write.
                for name in DEPLOY.MIGRATION_PATHS:
                    self.assertEqual((self.target / name).read_bytes(),
                                     (self.staged / name).read_bytes(), name)
                self.assertFalse((self.target / "scripts/workbook_baseline.py").exists())
                injected[0] = True
                raise OSError("injected failure after all protected files")
            return replace(*args, **kwargs)

        with mock.patch.object(DEPLOY, "atomic_replace", fail_fourth):
            with self.assertRaisesRegex(
                    DEPLOY.DeploymentError,
                    "injected failure after all protected files; status=failed_rolled_back"):
                self.deploy()
        self.assertTrue(injected[0], "failure injection never reached the migrated baseline")
        self.assert_originals()
        self.assertFalse((self.target / DEPLOY.BASELINE_MANIFEST).exists())
        self.assertFalse((self.target / "scripts/workbook_baseline.py").exists())
        backup = next(self.backups.iterdir())
        report = json.loads((backup / "report.json").read_text())
        self.assertEqual(report["status"], "failed_rolled_back")
        self.assertEqual(set(report["applied_files"]), DEPLOY.MIGRATION_PATHS)

    def test_post_migration_user_workbook_change_blocks_entire_rollback(self):
        result = self.deploy()
        (self.target / DEPLOY.WORKBOOK).write_bytes(b"user workbook after deployment")
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "workbook SHA mismatch"):
            DEPLOY.rollback(result["backup"])
        self.assertEqual((self.target / "scripts/example.py").read_bytes(), b"new script")
        self.assertEqual((self.target / DEPLOY.WORKBOOK).read_bytes(), b"user workbook after deployment")

    def test_user_change_to_skipped_lock_blocks_entire_rollback(self):
        lock = "docs/vip/base_vip_cfg.lock.json"
        (self.target / lock).write_bytes((self.staged / lock).read_bytes())
        result = self.deploy()
        self.assertEqual(next(row["action"] for row in result["files"] if row["path"] == lock), "skip")
        (self.target / lock).write_bytes(b"user edited previously current lock")
        before = {row["path"]: (self.target / row["path"]).read_bytes() for row in self.rows}
        with self.assertRaisesRegex(DEPLOY.DeploymentError, "post-deployment user changes in " + lock):
            DEPLOY.rollback(result["backup"])
        after = {row["path"]: (self.target / row["path"]).read_bytes() for row in self.rows}
        self.assertEqual(after, before)
        self.assertEqual((self.target / DEPLOY.WORKBOOK).read_bytes(), self.after)


if __name__ == "__main__":
    unittest.main()
