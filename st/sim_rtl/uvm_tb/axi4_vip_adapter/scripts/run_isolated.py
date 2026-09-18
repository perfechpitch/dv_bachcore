#!/usr/bin/env python3
"""Prepare/run the complete demo top without rewriting the source workbooks.

Only JSON/SV generation happens in a fresh copy. Logs and the effective profile
are retained so a run can be reproduced independently of Excel's FINAL sheet.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import signal
import shutil
import subprocess
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parent))
from workbook_baseline import BASELINE_SHA

WORKBOOK = Path("docs/vip/vip_cfg.xlsx")


def run_bounded(command, cwd, env, timeout, stdout=None):
    """Bound the entire make/VCS process group, including compiler children."""
    process = subprocess.Popen(command, cwd=str(cwd), env=env, stdout=stdout,
                               stderr=subprocess.STDOUT if stdout else None,
                               start_new_session=True)
    try:
        status = process.wait(timeout=timeout)
    except (subprocess.TimeoutExpired, KeyboardInterrupt):
        try:
            os.killpg(process.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            pass
        # The group leader can exit before a compiler child which ignores
        # SIGTERM. Always kill the remaining group, even if wait() succeeded.
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        process.wait()
        raise
    if status:
        # A suite may catch its own compiler timeout and exit while compiler
        # children remain in this group. Clean those up on failure as well.
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        raise subprocess.CalledProcessError(status, command)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def prepare(project, destination, profile=None, plan=None):
    if digest(project / WORKBOOK) != BASELINE_SHA:
        raise ValueError("source vip_cfg.xlsx differs from the protected baseline")
    for name in ("Makefile", "filelist.f", "docs", "scripts", "tb", "tests"):
        source = project / name
        if source.is_dir():
            shutil.copytree(str(source), str(destination / name),
                            ignore=shutil.ignore_patterns("__pycache__", "*.pyc", "work", "*.log"))
        elif source.is_file():
            shutil.copy2(str(source), str(destination / name))
    cfg = destination / "tb/generated/axi4_vip_cfg.json"
    if profile:
        shutil.copy2(str(profile), str(cfg))
    commands = [
        ["scripts/gen_vip_cfg.py", "--cfg", str(cfg), "--out", "tb/generated/axi4_vip_cfg_pkg.sv"],
        ["scripts/gen_axi_vip_filelist.py", "--cfg", str(cfg), "--out", "tb/generated/axi4_vip_filelist.f", "--project-root", "."],
    ]
    if plan:
        shutil.copy2(str(plan), str(destination / "docs/seq/seq_plan.json"))
    # Production generated files are intentionally not deployed. Regenerate
    # templates in the copy from its active JSON/TXT, preserving user inputs.
    commands.append(["scripts/gen_axi4_seq.py", "--plan", "docs/seq/seq_plan.json",
                     "--out", "tb/generated/axi4_generated_seq_pkg.sv", "--seq-dir", "tb/generated/seqs"])
    commands.append(["scripts/gen_irq_seq.py", "--txt", "docs/txt/irq_seq.txt",
                     "--out", "tb/generated/axi4_irq_handler_seq.svh"])
    env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
    for command in commands:
        run_bounded([sys.executable] + command, destination, env, 60)
    if digest(destination / WORKBOOK) != BASELINE_SHA:
        raise ValueError("isolated preparation changed vip_cfg.xlsx")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--profile", type=Path, help="independent VIP JSON; defaults to current generated JSON")
    parser.add_argument("--plan", type=Path, help="optional independent sequence plan JSON")
    parser.add_argument("--seq", default="axi4_user_two_regs")
    parser.add_argument("--irq", action="store_true")
    parser.add_argument("--sim-arg", action="append", default=[])
    parser.add_argument("--work-root", type=Path, default=Path(tempfile.gettempdir()))
    parser.add_argument("--prepare-only", action="store_true")
    parser.add_argument("--compile-timeout", type=int, default=180)
    parser.add_argument("--run-timeout", type=int, default=60)
    args = parser.parse_args()
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", args.seq):
        parser.error("--seq must be a SystemVerilog identifier")
    if min(args.compile_timeout, args.run_timeout) <= 0:
        parser.error("timeouts must be positive")
    project = Path(__file__).resolve().parents[1]
    if project == args.work_root.resolve() or project in args.work_root.resolve().parents:
        parser.error("--work-root must be outside the source project")
    args.work_root.mkdir(parents=True, exist_ok=True)
    destination = Path(tempfile.mkdtemp(prefix="axi4_isolated_", dir=str(args.work_root.resolve())))
    print("ISOLATED_PROJECT={}".format(destination), flush=True)
    report = {"source": str(project), "workbook_sha256": BASELINE_SHA,
              "seq": args.seq, "irq": args.irq, "sim_args": args.sim_arg,
              "status": "failed", "stage": "prepare"}
    failure = None
    try:
        prepare(project, destination, args.profile, args.plan)
        report["profile_sha256"] = digest(destination / "tb/generated/axi4_vip_cfg.json")
        report["plan_sha256"] = digest(destination / "docs/seq/seq_plan.json")
        if not args.prepare_only:
            env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
            report["stage"] = "compile"
            report["compile_command"] = ["make", "--no-print-directory", "_compile_current", "WAVE=0",
                                         "RUN_WORK_DIR=work/isolated"]
            run_bounded(report["compile_command"], destination, env, args.compile_timeout)
            log = destination / "work/isolated/sim.log"
            command = [str(destination / "work/isolated/simv"), "+UVM_TESTNAME=axi4_doc_test",
                       "+SEQ=" + args.seq, "+IRQ_EN=" + str(int(args.irq))] + args.sim_arg
            report["run_command"] = command
            report["stage"] = "run"
            with log.open("w") as output:
                run_bounded(command, destination, env, args.run_timeout, output)
            output = log.read_text()
            print(output)
            report["stage"] = "validate"
            if re.search(r"(?:^Fatal:|^Error:|Error-\[|AXI_CHECKER_FAILED|^UVM_(?:ERROR|FATAL)[ \t]+[^ \t:])", output, re.MULTILINE):
                raise ValueError("HDL/checker diagnostic; see {}".format(log))
            for severity in ("ERROR", "FATAL"):
                counts = re.findall(r"UVM_" + severity + r"\s*:\s*(\d+)", output)
                if not counts or any(int(count) for count in counts):
                    raise ValueError("missing/failed UVM {} summary; see {}".format(severity, log))
            if "AXI_CHECKER_PASS" not in output:
                raise ValueError("missing integrated checker completion; see {}".format(log))
            report["status"] = "passed"
        else:
            report["status"] = "prepared"
    except BaseException as error:
        failure = error
        report["status"] = "failed"
        report["error"] = str(error)
    finally:
        integrity_errors = []
        for label, root in (("source", project), ("isolated", destination)):
            workbook = root / WORKBOOK
            # A rejected source can fail before the isolated copy exists.
            if label == "isolated" and not workbook.exists() and report["stage"] == "prepare":
                continue
            try:
                actual_sha = digest(workbook)
                report[label + "_workbook_sha256"] = actual_sha
                if actual_sha != BASELINE_SHA:
                    integrity_errors.append(label + " vip_cfg.xlsx differs from the protected baseline")
            except OSError as error:
                integrity_errors.append("cannot verify {} vip_cfg.xlsx: {}".format(label, error))
        if integrity_errors:
            report["status"] = "failed"
            report["integrity_errors"] = integrity_errors
            if failure is None:
                failure = ValueError("; ".join(integrity_errors))
                report["error"] = str(failure)
        if failure is None:
            report["stage"] = "complete"
        (destination / "isolated_result.json").write_text(json.dumps(report, indent=2) + "\n")
    if failure is not None:
        raise failure
    print("ISOLATED_{} {}".format(report["status"].upper(), destination))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print("ERROR: {}".format(error), file=sys.stderr)
        sys.exit(1)
