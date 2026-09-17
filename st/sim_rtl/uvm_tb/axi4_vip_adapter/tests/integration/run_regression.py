#!/usr/bin/env python3
"""Run the integrated suite serially in a fresh project copy (Python 3.6+)."""
import argparse
import datetime
import json
import os
from pathlib import Path
import re
import sys
import tempfile
import time

PROJECT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(PROJECT / "scripts"))
from run_isolated import BASELINE_SHA, WORKBOOK, digest, prepare, run_bounded


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-root", type=Path, default=Path(tempfile.gettempdir()))
    parser.add_argument("--only", action="append", default=[], help="run only named suite(s)")
    args = parser.parse_args()
    root = args.work_root.resolve()
    if root == PROJECT or PROJECT in root.parents:
        parser.error("--work-root must be outside the source project")
    root.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix="axi4_regression_", dir=str(root)))
    staged = work / "project"
    staged.mkdir()
    result = {"started_utc": datetime.datetime.utcnow().isoformat() + "Z",
              "work": str(work), "source": str(PROJECT),
              "tested_revision": os.environ.get("AXI_SOURCE_REVISION", "unversioned"),
              "status": "failed", "suites": []}
    print("REGRESSION_WORK=" + str(work), flush=True)
    try:
        prepare(PROJECT, staged)
        manifest = json.loads((staged / "tests/integration/suites.json").read_text())
        names = {suite["name"] for suite in manifest["suites"]}
        if set(args.only) - names:
            raise ValueError("unknown --only suite: " + str(set(args.only) - names))
        env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        for suite in manifest["suites"]:
            if args.only and suite["name"] not in args.only:
                continue
            case = work / suite["name"]
            case.mkdir()
            substitutions = {"python": sys.executable, "project": str(staged),
                             "case": str(case), "work": str(work)}
            command = [arg.format(**substitutions) for arg in suite["command"]]
            row = {"name": suite["name"], "command": command,
                   "status": "failed", "log": str(case / "suite.log")}
            result["suites"].append(row)
            started = time.monotonic()
            print("START " + suite["name"], flush=True)
            try:
                with (case / "suite.log").open("w") as log:
                    run_bounded(command, staged, env, suite.get("timeout_seconds", 600), log)
                output = (case / "suite.log").read_text(errors="replace")
                for marker in suite.get("required_patterns", []):
                    if not re.search(marker, output, re.MULTILINE):
                        raise ValueError("missing result pattern: " + marker)
                row["status"] = "passed"
                row["result_lines"] = [line for line in output.splitlines()
                                       if re.search(r"PASS|passed|Ran \d+ tests|^OK$|GB/s|GBps", line)][-100:]
            except BaseException as error:
                row["error"] = str(error)
                raise
            finally:
                row["seconds"] = round(time.monotonic() - started, 3)
                if (case / "suite.log").exists():
                    row["log_sha256"] = digest(case / "suite.log")
            print("PASS " + suite["name"], flush=True)
        result["status"] = "passed"
    except BaseException as error:
        result["error"] = str(error)
        raise
    finally:
        integrity_errors = []
        for name, directory in (("source", PROJECT), ("staged", staged)):
            try:
                sha = digest(directory / WORKBOOK)
                result[name + "_workbook_sha256"] = sha
                if sha != BASELINE_SHA:
                    integrity_errors.append(name + " workbook changed")
            except OSError as error:
                integrity_errors.append("cannot verify {} workbook: {}".format(name, error))
        if integrity_errors:
            result["status"] = "failed"
            result["integrity_errors"] = integrity_errors
            result["integrity_error"] = "; ".join(integrity_errors)
            result.setdefault("error", result["integrity_error"])
        result["finished_utc"] = datetime.datetime.utcnow().isoformat() + "Z"
        (work / "regression_result.json").write_text(json.dumps(result, indent=2) + "\n")
        print("REGRESSION_RESULT=" + str(work / "regression_result.json"), flush=True)
    if result["status"] != "passed":
        raise ValueError("workbook integrity failed")
    print("REGRESSION_PASS suites=" + str(len(result["suites"])), flush=True)


if __name__ == "__main__":
    main()
