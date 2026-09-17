#!/usr/bin/env python3
r"""Deploy an explicit, reviewed file manifest; never generate configuration.

Python 3.6+, standard library only. Manifest example:
  {"version": 1, "files": [{"path": "tb/example.sv",
    "baseline_sha256": "<64 lowercase hex digits, or null for a new file>",
    "candidate_sha256": "<64 lowercase hex digits>"}]}

Commands (paths are project roots, not their parent repository):
  python3 scripts/deploy_verified.py deploy --manifest /tmp/manifest.json \
    --staged /tmp/reviewed-project --target /path/to/axi4_vip_adapter --check-only
  python3 scripts/deploy_verified.py deploy --manifest /tmp/manifest.json \
    --staged /tmp/reviewed-project --target /path/to/axi4_vip_adapter \
    --backup-root /path/to/backups
  python3 /path/to/backups/<timestamp>/rollback.py rollback \
    --backup /path/to/backups/<timestamp>
  python3 scripts/deploy_verified.py self-test

Ordinary manifests cannot write configuration. The explicit
--allow-workbook-migration switch additionally requires workbook_migration:
  {"baseline_sha256": "<reviewed previous>", "candidate_sha256": "<reviewed current>"}
matching docs/vip/workbook_baseline.json, and all three exact protected paths
(vip_cfg.xlsx, base_vip_cfg.lock.json, workbook_baseline.json) in files. Include
their actual target/candidate hashes; an unexpected target edit aborts all writes.

Only listed regular files are replaced, individually and atomically. All files
are checked before any target mutation, then checked again immediately before
replacement. Stop builds/editors that write these files during deployment:
this is not a filesystem snapshot and cannot fence unrelated external writers.
The backup includes original files/modes, manifest.json, deployment.json,
new_files.json, report.json, and a standalone rollback.py/rollback.sh with its
own workbook_baseline.py/workbook_baseline.json. Recovery never reads the
target's baseline manifest: saved hashes also cover partial/idempotent rollback.
Rollback refuses unexpected post-deployment content before restoring anything.
An ordinary failure attempts automatic rollback; after SIGKILL/power loss use
the saved rollback command. Existing directories and unlisted files are kept.
Backups and directory entries are fsynced before target replacement, and each
replacement/removal fsyncs its parent. Unsupported fsync fails before deployment.
Durability is limited to the filesystem/server's fsync contract; this does not
promise survival of NFS server or hardware failures beyond that contract.
"""

import argparse
import datetime
import hashlib
import json
import os
import re
import shlex
import shutil
import stat
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from workbook_baseline import BASELINE_MANIFEST, BASELINE_PATH, load_baseline

WORKBOOK = "docs/vip/vip_cfg.xlsx"
BASELINE = load_baseline()
WORKBOOK_SHA256 = BASELINE["current_sha256"]
MIGRATION_PATHS = frozenset((WORKBOOK, "docs/vip/base_vip_cfg.lock.json", BASELINE_MANIFEST))
HEX_SHA256 = re.compile(r"^[0-9a-f]{64}$")
BLOCKED_COMPONENTS = frozenset((".git", ".svn", "work", "csrc", "dvefiles",
                                "verdilog", "__pycache__", "simv.daidir"))
BLOCKED_NAMES = frozenset(("simv", "ucli.key", "vc_hdrs.h", "novas.conf", "novas.rc"))
BLOCKED_SUFFIXES = (".xlsx", ".fsdb", ".vcd", ".vpd", ".vdb", ".log", ".pyc")


class DeploymentError(Exception):
    pass


def digest(path):
    result = hashlib.sha256()
    with open(path, "rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            result.update(block)
    return result.hexdigest()


def validated_path(value, migration=False):
    if not isinstance(value, str) or not value or "\\" in value or "\x00" in value:
        raise DeploymentError("invalid manifest path: {!r}".format(value))
    parts = value.split("/")
    if any(part in ("", ".", "..") for part in parts):
        raise DeploymentError("path must be relative and normalized: " + value)
    if migration and value in MIGRATION_PATHS:
        return value
    lowered = [part.lower() for part in parts]
    if (any(part in BLOCKED_COMPONENTS for part in lowered)
            or lowered[-1] in BLOCKED_NAMES
            or any(part.endswith(BLOCKED_SUFFIXES) for part in lowered)
            or lowered[:2] in (["docs", "seq"], ["docs", "txt"], ["docs", "vip"], ["tb", "generated"])):
        raise DeploymentError("protected configuration/build path: " + value)
    return value


def read_json(path):
    with open(path, "r", encoding="utf-8") as stream:
        return json.load(stream)


def load_manifest(path, allow_workbook_migration=False):
    manifest = read_json(path)
    if not isinstance(manifest, dict) or manifest.get("version") != 1:
        raise DeploymentError("manifest must have version: 1")
    migration = manifest.get("workbook_migration")
    if "workbook_migration" in manifest:
        if not allow_workbook_migration:
            raise DeploymentError("workbook migration needs explicit --allow-workbook-migration")
        expected = {"baseline_sha256": BASELINE["previous_sha256"],
                    "candidate_sha256": WORKBOOK_SHA256}
        if migration != expected or expected["baseline_sha256"] == expected["candidate_sha256"]:
            raise DeploymentError("workbook migration must match reviewed previous/current baseline")
    rows = manifest.get("files")
    if not isinstance(rows, list) or not rows:
        raise DeploymentError("manifest files must be a nonempty list")
    names = set()
    normalized = []
    for row in rows:
        if not isinstance(row, dict) or set(row) != {"path", "baseline_sha256", "candidate_sha256"}:
            raise DeploymentError("each file needs exactly path, baseline_sha256, candidate_sha256")
        name = validated_path(row["path"], migration=bool(migration))
        if name in names:
            raise DeploymentError("duplicate manifest path: " + name)
        names.add(name)
        for key in ("baseline_sha256", "candidate_sha256"):
            value = row[key]
            if key == "baseline_sha256" and value is None:
                continue
            if not isinstance(value, str) or not HEX_SHA256.fullmatch(value):
                raise DeploymentError("invalid {} for {}".format(key, name))
        normalized.append(dict(row))
    for name in names:
        parent = name.rpartition("/")[0]
        while parent:
            if parent in names:
                raise DeploymentError("manifest contains a file and its descendant: " + name)
            parent = parent.rpartition("/")[0]
    result = {"version": 1, "files": normalized}
    if migration:
        if not MIGRATION_PATHS.issubset(names):
            raise DeploymentError("workbook migration must list workbook, BASE lock and baseline manifest paths")
        by_name = {row["path"]: row for row in normalized}
        if {key: by_name[WORKBOOK][key] for key in migration} != migration:
            raise DeploymentError("workbook file hashes differ from migration")
        if by_name[BASELINE_MANIFEST]["candidate_sha256"] != digest(str(BASELINE_PATH)):
            raise DeploymentError("candidate baseline manifest differs from reviewed baseline")
        result["workbook_migration"] = migration
    return result


def root_dir(path):
    absolute = os.path.abspath(path)
    if os.path.islink(absolute) or not os.path.isdir(absolute):
        raise DeploymentError("root must be an existing non-symlink directory: " + absolute)
    return os.path.realpath(absolute)


def file_path(root, relative):
    """Reject symlinks/non-directories in every existing path component."""
    parts = relative.split("/")
    current = root
    for index, part in enumerate(parts):
        current = os.path.join(current, part)
        if not os.path.lexists(current):
            continue
        mode = os.lstat(current).st_mode
        if stat.S_ISLNK(mode):
            raise DeploymentError("symlinks are not allowed: " + current)
        expected = stat.S_ISREG if index == len(parts) - 1 else stat.S_ISDIR
        if not expected(mode):
            raise DeploymentError("not a regular file/directory: " + current)
    return current


def current_sha(root, relative):
    path = file_path(root, relative)
    return digest(path) if os.path.exists(path) else None


def check_workbook(root, expected=None):
    actual = current_sha(root, WORKBOOK)
    expected = (WORKBOOK_SHA256,) if expected is None else expected
    if actual not in expected:
        raise DeploymentError("protected workbook SHA mismatch in {}: {}".format(root, actual))
    return actual


def permitted_workbook_hashes(manifest):
    migration = manifest.get("workbook_migration")
    return tuple(migration.values()) if migration else (WORKBOOK_SHA256,)


def disjoint(first, second):
    common = os.path.commonpath((first, second))
    if common in (first, second):
        raise DeploymentError("directories must not overlap: {} and {}".format(first, second))


def fsync_file(path):
    with open(path, "rb") as stream:
        os.fsync(stream.fileno())


def fsync_directory(path):
    descriptor = os.open(path, os.O_RDONLY | getattr(os, "O_DIRECTORY", 0))
    try:
        os.fsync(descriptor)
    finally:
        os.close(descriptor)


def durable_backup_tree(root):
    """Commit original bytes, recovery tools and every directory before writes."""
    def walk_error(error):
        raise error
    for current, directories, files in os.walk(root, topdown=False, followlinks=False,
                                               onerror=walk_error):
        for name in directories:
            if os.path.islink(os.path.join(current, name)):
                raise DeploymentError("symlink in backup: " + os.path.join(current, name))
        for name in files:
            path = os.path.join(current, name)
            if not stat.S_ISREG(os.lstat(path).st_mode):
                raise DeploymentError("non-regular backup file: " + path)
            fsync_file(path)
        fsync_directory(current)
    fsync_directory(os.path.dirname(root))


def check_target_fsync(target, rows):
    """Probe existing destination filesystems before any target mutation."""
    directories = {target}
    for row in rows:
        if row["action"] == "skip":
            continue
        parent = os.path.dirname(file_path(target, row["path"]))
        while not os.path.isdir(parent):
            parent = os.path.dirname(parent)
        directories.add(parent)
    for directory in sorted(directories):
        fsync_directory(directory)


def write_json(path, value):
    # A killed report update must leave either the previous or the new JSON,
    # never a truncated recovery record.
    parent = os.path.dirname(os.path.abspath(path))
    descriptor, temporary = tempfile.mkstemp(prefix=".axi4_record_", dir=parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            json.dump(value, stream, indent=2, sort_keys=True)
            stream.write("\n")
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
        fsync_directory(parent)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def ensure_parents(root, relative):
    current = root
    for component in relative.split("/")[:-1]:
        current = os.path.join(current, component)
        if not os.path.exists(current):
            os.mkdir(current)
            fsync_directory(current)
            fsync_directory(os.path.dirname(current))
        if os.path.islink(current) or not os.path.isdir(current):
            raise DeploymentError("unsafe destination parent: " + current)


def atomic_replace(source, root, relative, expected, candidate, mode=None):
    ensure_parents(root, relative)
    destination = file_path(root, relative)
    descriptor, temporary = tempfile.mkstemp(prefix=".axi4_deploy_", dir=os.path.dirname(destination))
    os.close(descriptor)
    try:
        shutil.copy2(source, temporary)
        if mode is not None:
            os.chmod(temporary, mode)
        if digest(temporary) != candidate:
            raise DeploymentError("source changed after preflight: " + relative)
        fsync_file(temporary)
        if current_sha(root, relative) != expected:
            raise DeploymentError("target changed after preflight: " + relative)
        os.replace(temporary, destination)
        fsync_directory(os.path.dirname(destination))
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def preflight(manifest, staged, target):
    check_workbook(target, permitted_workbook_hashes(manifest))
    if os.path.lexists(os.path.join(staged, WORKBOOK)):
        check_workbook(staged)
    errors = []
    rows = []
    for original in manifest["files"]:
        row = dict(original)
        name = row["path"]
        try:
            if current_sha(staged, name) != row["candidate_sha256"]:
                raise DeploymentError("candidate SHA mismatch or file missing: " + name)
            actual = current_sha(target, name)
            if actual == row["candidate_sha256"]:
                row["action"] = "skip"
            elif actual == row["baseline_sha256"]:
                row["action"] = "add" if actual is None else "replace"
            else:
                raise DeploymentError("target has user changes: {} (expected {}, found {})".format(
                    name, row["baseline_sha256"], actual))
            rows.append(row)
        except (OSError, DeploymentError) as error:
            errors.append(str(error))
    if errors:
        raise DeploymentError("preflight refused; no target files changed:\n" + "\n".join(errors))
    return rows


def rollback(backup):
    backup = root_dir(backup)
    originals = root_dir(os.path.join(backup, "files"))
    record = read_json(os.path.join(backup, "deployment.json"))
    target = root_dir(record["target"])
    disjoint(target, backup)
    # Revalidate persisted paths/hashes before using a backup as a write plan.
    manifest = load_manifest(os.path.join(backup, "manifest.json"),
                             allow_workbook_migration=True)
    expected = {row["path"]: row for row in manifest["files"]}
    if len(record["files"]) != len(expected):
        raise DeploymentError("backup record and manifest differ")
    check_workbook(target, permitted_workbook_hashes(manifest))
    restore = []
    seen = set()
    for row in record["files"]:
        name = validated_path(row["path"], migration=bool(manifest.get("workbook_migration")))
        if name in seen or {key: row[key] for key in expected.get(name, {})} != expected.get(name):
            raise DeploymentError("backup record and manifest differ: " + name)
        seen.add(name)
        if row["action"] == "skip":
            if current_sha(target, name) != row["candidate_sha256"]:
                raise DeploymentError("rollback refused: post-deployment user changes in " + name)
            continue
        required_action = "add" if row["baseline_sha256"] is None else "replace"
        if row["action"] != required_action:
            raise DeploymentError("invalid backup action: " + name)
        if row["baseline_sha256"] is not None:
            saved = current_sha(originals, name)
            if saved != row["baseline_sha256"]:
                raise DeploymentError("backup original SHA mismatch: " + name)
        actual = current_sha(target, name)
        if actual == row["baseline_sha256"]:
            continue  # Not yet deployed, or already rolled back.
        if actual != row["candidate_sha256"]:
            raise DeploymentError("rollback refused: post-deployment user changes in " + name)
        restore.append(row)
    # No mutation above: one modified file prevents the entire rollback.
    check_target_fsync(target, restore)
    restored = []
    for row in reversed(restore):
        name = row["path"]
        if row["baseline_sha256"] is None:
            if current_sha(target, name) != row["candidate_sha256"]:
                raise DeploymentError("target changed during rollback: " + name)
            os.unlink(file_path(target, name))
            fsync_directory(os.path.dirname(os.path.join(target, name)))
        else:
            atomic_replace(file_path(originals, name), target, name,
                           row["candidate_sha256"], row["baseline_sha256"])
        restored.append(name)
    expected_workbook = WORKBOOK_SHA256
    for row in record["files"]:
        if row["path"] == WORKBOOK and row["action"] != "skip":
            expected_workbook = row["baseline_sha256"]
    check_workbook(target, (expected_workbook,))
    result = {"status": "rolled_back", "target": target, "backup": backup,
              "restored_files": restored, "workbook_sha256": expected_workbook}
    write_json(os.path.join(backup, "report.json"), result)
    return result


def deploy(manifest_path, staged, target, backup_root=None, check_only=False,
           allow_workbook_migration=False):
    manifest = load_manifest(manifest_path, allow_workbook_migration)
    staged, target = root_dir(staged), root_dir(target)
    disjoint(staged, target)
    rows = preflight(manifest, staged, target)
    summary = {"status": "preflight_passed", "target": target, "files": rows,
               "workbook_sha256": WORKBOOK_SHA256}
    if check_only:
        return summary
    if not backup_root:
        raise DeploymentError("deployment requires an explicit --backup-root")
    check_target_fsync(target, rows)
    backup_root = os.path.realpath(os.path.abspath(backup_root))
    disjoint(backup_root, target)
    disjoint(backup_root, staged)
    if not os.path.isdir(backup_root):
        missing = []
        parent = backup_root
        while not os.path.exists(parent):
            missing.append(parent)
            parent = os.path.dirname(parent)
        os.makedirs(backup_root)
        for directory in missing:
            fsync_directory(directory)
            fsync_directory(os.path.dirname(directory))
    stamp = datetime.datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    backup = tempfile.mkdtemp(prefix="axi4_{}_".format(stamp), dir=backup_root)
    os.mkdir(os.path.join(backup, "files"))
    record = {"version": 1, "target": target, "staged": staged,
              "created_utc": stamp, "files": rows, "workbook_sha256": WORKBOOK_SHA256}
    # Finish and verify all backup copies before changing the target.
    for row in rows:
        if row["action"] == "replace":
            ensure_parents(os.path.join(backup, "files"), row["path"])
            saved = file_path(os.path.join(backup, "files"), row["path"])
            shutil.copy2(file_path(target, row["path"]), saved)
            if digest(saved) != row["baseline_sha256"]:
                raise DeploymentError("target changed during backup; no deployment: " + row["path"])
    write_json(os.path.join(backup, "manifest.json"), manifest)
    write_json(os.path.join(backup, "deployment.json"), record)
    write_json(os.path.join(backup, "new_files.json"), [r["path"] for r in rows if r["action"] == "add"])
    shutil.copy2(os.path.realpath(__file__), os.path.join(backup, "rollback.py"))
    shutil.copy2(os.path.join(os.path.dirname(os.path.realpath(__file__)), "workbook_baseline.py"),
                 os.path.join(backup, "workbook_baseline.py"))
    shutil.copy2(str(BASELINE_PATH), os.path.join(backup, "workbook_baseline.json"))
    shell = os.path.join(backup, "rollback.sh")
    with open(shell, "w", encoding="utf-8") as stream:
        stream.write('#!/bin/sh\nset -eu\nbackup=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)\n'
                     'exec python3 "$backup/rollback.py" rollback --backup "$backup"\n')
    os.chmod(shell, 0o700)
    summary.update({"status": "prepared", "backup": backup,
                    "rollback_command": "sh {}".format(shlex.quote(shell)), "applied_files": []})
    write_json(os.path.join(backup, "report.json"), summary)
    durable_backup_tree(backup)
    try:
        check_workbook(target, permitted_workbook_hashes(manifest))
        for row in rows:
            if row["action"] == "skip":
                if current_sha(target, row["path"]) != row["candidate_sha256"]:
                    raise DeploymentError("previously current target changed: " + row["path"])
                continue
            old_mode = None
            if row["action"] == "replace":
                old_mode = stat.S_IMODE(os.stat(file_path(os.path.join(backup, "files"), row["path"])).st_mode)
            atomic_replace(file_path(staged, row["path"]), target, row["path"],
                           row["baseline_sha256"], row["candidate_sha256"], old_mode)
            summary["applied_files"].append(row["path"])
            write_json(os.path.join(backup, "report.json"), summary)
        for row in rows:
            if current_sha(target, row["path"]) != row["candidate_sha256"]:
                raise DeploymentError("post-deploy SHA mismatch: " + row["path"])
        check_workbook(target)
    except (Exception, KeyboardInterrupt) as error:
        summary["error"] = str(error)
        try:
            rollback(backup)
            summary["status"] = "failed_rolled_back"
        except (Exception, KeyboardInterrupt) as recovery_error:
            summary["status"] = "failed_needs_manual_recovery"
            summary["rollback_error"] = str(recovery_error)
        write_json(os.path.join(backup, "report.json"), summary)
        raise DeploymentError("{}; status={}; backup={}".format(error, summary["status"], backup))
    summary["status"] = "deployed"
    write_json(os.path.join(backup, "report.json"), summary)
    return summary


def self_test(workbook):
    if digest(workbook) != WORKBOOK_SHA256:
        raise DeploymentError("self-test needs the unchanged project workbook")
    passed = []
    with tempfile.TemporaryDirectory(prefix="axi4_deploy_test_") as temporary:
        def fixture(label):
            root = os.path.join(temporary, label)
            os.mkdir(root)
            staged, target, backups = [os.path.join(root, name) for name in ("staged", "target", "backups")]
            os.mkdir(staged)
            os.mkdir(target)
            os.makedirs(os.path.join(target, "docs/vip"))
            shutil.copy2(workbook, os.path.join(target, WORKBOOK))
            rows = []
            for name, old, new in (("tb/existing.sv", b"old\n", b"new\n"),
                                   ("scripts/new.py", None, b"new file\n"),
                                   ("already.txt", None, b"already current\n")):
                ensure_parents(staged, name)
                with open(os.path.join(staged, name), "wb") as stream:
                    stream.write(new)
                if old is not None or name == "already.txt":
                    ensure_parents(target, name)
                    with open(os.path.join(target, name), "wb") as stream:
                        stream.write(new if old is None else old)
                rows.append({"path": name, "baseline_sha256": hashlib.sha256(old).hexdigest() if old else None,
                             "candidate_sha256": hashlib.sha256(new).hexdigest()})
            with open(os.path.join(target, "user_output.txt"), "wb") as stream:
                stream.write(b"unlisted\n")
            manifest = os.path.join(root, "manifest.json")
            write_json(manifest, {"version": 1, "files": rows})
            return manifest, staged, target, backups

        def refuses(call, expected):
            try:
                call()
            except DeploymentError as error:
                if expected not in str(error):
                    raise AssertionError("wrong refusal: " + str(error))
            else:
                raise AssertionError("expected refusal: " + expected)

        args = fixture("success")
        manifest, staged, target, backups = args
        os.chmod(os.path.join(target, "tb/existing.sv"), 0o640)
        check = deploy(*args, check_only=True)
        assert check["status"] == "preflight_passed" and not os.path.exists(backups)
        result = deploy(*args)
        assert result["status"] == "deployed" and len(result["applied_files"]) == 2
        assert stat.S_IMODE(os.stat(os.path.join(target, "tb/existing.sv")).st_mode) == 0o640
        assert read_json(os.path.join(result["backup"], "new_files.json")) == ["scripts/new.py"]
        assert open(os.path.join(target, "user_output.txt"), "rb").read() == b"unlisted\n"
        check_workbook(target)
        import subprocess
        subprocess.check_call(["sh", os.path.join(result["backup"], "rollback.sh")], stdout=subprocess.DEVNULL)
        assert current_sha(target, "tb/existing.sv") == load_manifest(manifest)["files"][0]["baseline_sha256"]
        assert not os.path.exists(os.path.join(target, "scripts/new.py"))
        assert current_sha(target, "already.txt") == current_sha(staged, "already.txt")
        assert rollback(result["backup"])["restored_files"] == []
        passed.append("deploy/dry-run/standalone rollback/idempotence/mode/unlisted/workbook")

        args = fixture("changed")
        with open(os.path.join(args[2], "already.txt"), "wb") as stream:
            stream.write(b"user modification\n")
        refuses(lambda: deploy(*args), "user changes")
        assert open(os.path.join(args[2], "tb/existing.sv"), "rb").read() == b"old\n"
        assert not os.path.exists(args[3])
        passed.append("late manifest user change rejects all writes")

        args = fixture("new_file_collision")
        ensure_parents(args[2], "scripts/new.py")
        with open(os.path.join(args[2], "scripts/new.py"), "wb") as stream:
            stream.write(b"untracked user file\n")
        refuses(lambda: deploy(*args), "user changes")
        assert open(os.path.join(args[2], "tb/existing.sv"), "rb").read() == b"old\n"
        passed.append("new candidate cannot overwrite an existing user file")

        args = fixture("protected")
        for forbidden in ("docs/vip/vip_cfg.xlsx", "docs/vip/base_vip_cfg.lock.json", "docs/txt/data.txt", "other.XLSX", "docs/seq/plan.json", "tb/generated/config.sv",
                          "work/job/result", "csrc/build.c", "out/waves.fsdb", "../escape", "/absolute"):
            write_json(args[0], {"version": 1, "files": [{"path": forbidden, "baseline_sha256": None,
                        "candidate_sha256": "0" * 64}]})
            refuses(lambda: deploy(*args), "path")
        passed.append("workbooks/configuration/build outputs/path traversal prohibited")

        args = fixture("candidate")
        with open(os.path.join(args[1], "tb/existing.sv"), "wb") as stream:
            stream.write(b"candidate changed\n")
        refuses(lambda: deploy(*args), "candidate SHA")
        passed.append("changed candidate refused")

        args = fixture("workbook")
        with open(os.path.join(args[2], WORKBOOK), "ab") as stream:
            stream.write(b"changed")
        refuses(lambda: deploy(*args), "workbook SHA")
        passed.append("changed protected workbook refused")

        args = fixture("rollback_guard")
        result = deploy(*args)
        with open(os.path.join(args[2], "tb/existing.sv"), "wb") as stream:
            stream.write(b"later user edit\n")
        refuses(lambda: rollback(result["backup"]), "post-deployment user changes")
        assert os.path.isfile(os.path.join(args[2], "scripts/new.py"))
        assert open(os.path.join(args[2], "tb/existing.sv"), "rb").read() == b"later user edit\n"
        passed.append("rollback refuses all writes after later user edit")

        args = fixture("symlink")
        os.unlink(os.path.join(args[2], "tb/existing.sv"))
        os.symlink(os.path.join(args[1], "tb/existing.sv"), os.path.join(args[2], "tb/existing.sv"))
        refuses(lambda: deploy(*args), "symlinks")
        passed.append("symlink target refused")

        args = fixture("interrupted")
        original_replace = globals()["atomic_replace"]
        calls = [0]
        def fail_second(*values, **kwargs):
            calls[0] += 1
            if calls[0] == 2:
                raise OSError("injected disk failure")
            return original_replace(*values, **kwargs)
        globals()["atomic_replace"] = fail_second
        try:
            refuses(lambda: deploy(*args), "failed_rolled_back")
        finally:
            globals()["atomic_replace"] = original_replace
        assert open(os.path.join(args[2], "tb/existing.sv"), "rb").read() == b"old\n"
        assert not os.path.exists(os.path.join(args[2], "scripts/new.py"))
        check_workbook(args[2])
        passed.append("injected mid-deploy failure restores previous writes")

        args = fixture("durability_order")
        real_file_sync = globals()["fsync_file"]
        real_directory_sync = globals()["fsync_directory"]
        real_replace = globals()["atomic_replace"]
        real_os_replace, real_os_unlink = os.replace, os.unlink
        synced_files, synced_directories = [], []
        durability_events = []
        replacements = [0]
        def track_file_sync(path):
            real_file_sync(path)
            synced_files.append(os.path.realpath(path))
        def track_directory_sync(path):
            real_directory_sync(path)
            synced_directories.append(os.path.realpath(path))
            durability_events.append(("directory", os.path.realpath(path)))
        def track_os_replace(source, destination):
            real_os_replace(source, destination)
            durability_events.append(("replace", os.path.realpath(destination)))
        def track_os_unlink(path, *values, **kwargs):
            real_os_unlink(path, *values, **kwargs)
            durability_events.append(("unlink", os.path.realpath(path)))
        def verify_replacement_barrier(*values, **kwargs):
            backup = os.path.join(args[3], os.listdir(args[3])[0])
            required_files = [os.path.join(backup, name) for name in (
                "files/tb/existing.sv", "manifest.json", "deployment.json",
                "new_files.json", "report.json", "rollback.py", "rollback.sh",
                "workbook_baseline.py", "workbook_baseline.json")]
            required_directories = [os.path.join(backup, name) for name in ("files/tb", "files")]
            required_directories.extend((backup, args[3], os.path.dirname(args[3])))
            assert set(map(os.path.realpath, required_files)).issubset(set(synced_files)), "target write before durable backup files"
            assert set(map(os.path.realpath, required_directories)).issubset(set(synced_directories)), "target write before durable backup directories"
            before = len(durability_events)
            real_replace(*values, **kwargs)
            target_path = os.path.realpath(os.path.join(values[1], values[2]))
            replaced_at = durability_events.index(("replace", target_path), before)
            assert ("directory", os.path.dirname(target_path)) in durability_events[replaced_at+1:], "atomic replacement did not sync target parent afterward"
            replacements[0] += 1
        globals()["fsync_file"] = track_file_sync
        globals()["fsync_directory"] = track_directory_sync
        globals()["atomic_replace"] = verify_replacement_barrier
        os.replace, os.unlink = track_os_replace, track_os_unlink
        try:
            result = deploy(*args)
            assert replacements[0] == 2
            before = len(durability_events)
            rollback(result["backup"])
            removed = os.path.realpath(os.path.join(args[2], "scripts/new.py"))
            removed_at = durability_events.index(("unlink", removed), before)
            assert ("directory", os.path.dirname(removed)) in durability_events[removed_at+1:], "rollback unlink did not sync parent afterward"
        finally:
            globals()["fsync_file"] = real_file_sync
            globals()["fsync_directory"] = real_directory_sync
            globals()["atomic_replace"] = real_replace
            os.replace, os.unlink = real_os_replace, real_os_unlink
        passed.append("backup files/tools/metadata/directories durable before writes; replace/unlink sync parents")

        args = fixture("backup_fsync_failure")
        def fail_backup_file_sync(path):
            if os.path.commonpath((os.path.realpath(path), os.path.realpath(args[3]))) == os.path.realpath(args[3]):
                raise OSError("injected unsupported backup fsync")
            return real_file_sync(path)
        globals()["fsync_file"] = fail_backup_file_sync
        try:
            try:
                deploy(*args)
            except OSError as error:
                assert "unsupported backup fsync" in str(error)
            else:
                raise AssertionError("unsupported backup fsync was ignored")
        finally:
            globals()["fsync_file"] = real_file_sync
        assert open(os.path.join(args[2], "tb/existing.sv"), "rb").read() == b"old\n"
        assert not os.path.exists(os.path.join(args[2], "scripts"))
        passed.append("backup fsync failure rejects deployment before any target file or directory mutation")

        args = fixture("target_fsync_failure")
        def fail_target_directory_sync(path):
            if os.path.commonpath((os.path.realpath(path), os.path.realpath(args[2]))) == os.path.realpath(args[2]):
                raise OSError("injected unsupported target directory fsync")
            return real_directory_sync(path)
        globals()["fsync_directory"] = fail_target_directory_sync
        try:
            try:
                deploy(*args)
            except OSError as error:
                assert "unsupported target directory fsync" in str(error)
            else:
                raise AssertionError("unsupported target directory fsync was ignored")
        finally:
            globals()["fsync_directory"] = real_directory_sync
        assert open(os.path.join(args[2], "tb/existing.sv"), "rb").read() == b"old\n"
        assert not os.path.exists(os.path.join(args[2], "scripts"))
        assert not os.path.exists(args[3])
        passed.append("unsupported target directory fsync rejected during read-only destination probe")
    return {"status": "self_test_passed", "cases": passed, "case_count": len(passed)}


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    commands = parser.add_subparsers(dest="command")
    deploy_parser = commands.add_parser("deploy", help="preflight and deploy an explicit manifest")
    deploy_parser.add_argument("--manifest", required=True)
    deploy_parser.add_argument("--staged", required=True)
    deploy_parser.add_argument("--target", required=True)
    deploy_parser.add_argument("--backup-root")
    deploy_parser.add_argument("--check-only", action="store_true")
    deploy_parser.add_argument("--allow-workbook-migration", action="store_true",
                               help="apply the exact reviewed workbook baseline migration")
    rollback_parser = commands.add_parser("rollback", help="restore a saved deployment")
    rollback_parser.add_argument("--backup", required=True)
    test_parser = commands.add_parser("self-test", help="run isolated temporary-directory tests")
    test_parser.add_argument("--workbook", default=os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), WORKBOOK))
    args = parser.parse_args()
    if args.command == "deploy":
        result = deploy(args.manifest, args.staged, args.target, args.backup_root, args.check_only,
                        args.allow_workbook_migration)
    elif args.command == "rollback":
        result = rollback(args.backup)
    elif args.command == "self-test":
        result = self_test(args.workbook)
    else:
        parser.error("choose deploy, rollback, or self-test")
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    try:
        main()
    except (DeploymentError, OSError, ValueError, KeyError, TypeError) as error:
        print("ERROR: {}".format(error), file=sys.stderr)
        sys.exit(1)
