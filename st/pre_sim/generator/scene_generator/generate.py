#!/usr/bin/env python3
"""Maintain pre_sim directed scenes and optionally execute them.

The input JSON is the source of truth.  Scenario SystemVerilog files declare
the plusargs they support; this tool validates configured values against that
interface and owns marked blocks in inst_generator/rsim/case_lst/directed.lst.
"""

from __future__ import print_function

import argparse
import datetime
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time


CASE_NAME_RE = re.compile(r"^[A-Za-z][A-Za-z0-9_]*$")
BEGIN_RE = re.compile(r"^\s*#\s*PRE_SIM_SCENE_BEGIN\s+(\S+)\s*$")
END_RE = re.compile(r"^\s*#\s*PRE_SIM_SCENE_END\s+(\S+)\s*$")
CASE_RE = re.compile(r"\bcase_name\s*=\s*(\S+)")
REGISTER_RE = re.compile(
    r"`DIRECTED_SCENARIO_REGISTER\s*\(\s*[A-Za-z_][A-Za-z0-9_]*\s*,\s*\"([^\"]+)\"\s*\)"
)
VALUE_PLUSARG_RE = re.compile(
    r"\$value\$plusargs\s*\(\s*\"([^\"]+)\"", re.MULTILINE
)
TEST_PLUSARG_RE = re.compile(
    r"\$test\$plusargs\s*\(\s*\"([^\"]+)\"", re.MULTILINE
)
FORMAT_RE = re.compile(r"%(?:0?\d+)?([dDhHxXsS])")
SUPPORTED_FORMATS = set("dDhHxXsS")
SEND_UNIT = {"dte": "00", "mu": "01", "vu": "10"}
MANAGED_BEGIN = "# PRE_SIM_SCENE_BEGIN {0}"
MANAGED_END = "# PRE_SIM_SCENE_END {0}"


class SceneError(ValueError):
    pass


def read_text(path):
    with open(path, "r", encoding="utf-8") as handle:
        return handle.read()


def atomic_write(path, text):
    directory = os.path.dirname(os.path.abspath(path))
    fd, temporary = tempfile.mkstemp(prefix=".pre_sim_", dir=directory)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(text)
        os.replace(temporary, path)
    except Exception:
        if os.path.exists(temporary):
            os.unlink(temporary)
        raise


def load_scenes(path):
    if os.path.isdir(path):
        json_paths = [
            os.path.join(path, name)
            for name in sorted(os.listdir(path))
            if name.endswith(".json")
        ]
        if not json_paths:
            raise SceneError("scene directory contains no JSON files: {0}".format(path))
        scenes = []
        for json_path in json_paths:
            scenes.extend(_load_scene_file(json_path))
    else:
        scenes = _load_scene_file(path)

    validate_scenes(scenes)
    return scenes


def _load_scene_file(path):
    try:
        root = json.loads(read_text(path))
    except (OSError, ValueError) as exc:
        raise SceneError("cannot load scene JSON {0}: {1}".format(path, exc))
    scenes = root.get("scenes") if isinstance(root, dict) else None
    if not isinstance(scenes, list) or not scenes:
        raise SceneError("{0}: scene JSON must contain a non-empty 'scenes' list".format(path))
    return scenes


def validate_scenes(scenes):
    ids = set()
    names = set()
    for index, scene in enumerate(scenes):
        where = "scenes[{0}]".format(index)
        if not isinstance(scene, dict):
            raise SceneError("{0} must be an object".format(where))
        scene_id = scene.get("scene_id")
        name = scene.get("scene_name")
        if not isinstance(scene_id, int) or isinstance(scene_id, bool) or scene_id < 0:
            raise SceneError("{0}.scene_id must be a non-negative integer".format(where))
        if scene_id in ids:
            raise SceneError("duplicate scene_id: {0}".format(scene_id))
        ids.add(scene_id)
        if not isinstance(name, str) or not CASE_NAME_RE.match(name):
            raise SceneError(
                "{0}.scene_name must match {1}".format(where, CASE_NAME_RE.pattern)
            )
        if name in names:
            raise SceneError("duplicate scene_name/case_name: {0}".format(name))
        names.add(name)
        scenario = scene.get("scenario")
        if not isinstance(scenario, dict):
            raise SceneError("{0}.scenario must be an object".format(where))
        for key in ("category", "seq_file", "seq_name"):
            if not isinstance(scenario.get(key), str) or not scenario[key]:
                raise SceneError("{0}.scenario.{1} is required".format(where, key))
        if scenario["category"] not in ("mu", "vu", "dte", "workload"):
            raise SceneError(
                "{0}.scenario.category must be mu, vu, dte, or workload".format(where)
            )
        args = scenario.get("args", {})
        if not isinstance(args, dict):
            raise SceneError("{0}.scenario.args must be an object".format(where))
        scenario["args"] = args
        chain = scene.get("task_chain")
        if not isinstance(chain, dict) or not isinstance(chain.get("tasks"), list):
            raise SceneError("{0}.task_chain.tasks must be a list".format(where))
        if chain.get("task_num") != len(chain["tasks"]):
            raise SceneError("{0}.task_chain.task_num does not match tasks length".format(where))
        task_ids = []
        for task_index, task in enumerate(chain["tasks"]):
            if not isinstance(task, dict) or not isinstance(task.get("task_id"), int):
                raise SceneError("{0}.task_chain.tasks[{1}] needs an integer task_id".format(
                    where, task_index
                ))
            if task.get("execute_unit") not in SEND_UNIT:
                raise SceneError("{0}.task_chain.tasks[{1}] has invalid execute_unit".format(
                    where, task_index
                ))
            if task.get("execution_mode") not in ("rvcore_only", "rvcore_dsa"):
                raise SceneError("{0}.task_chain.tasks[{1}] has invalid execution_mode".format(
                    where, task_index
                ))
            task_ids.append(task["task_id"])
        if len(task_ids) != len(set(task_ids)):
            raise SceneError("{0}.task_chain contains duplicate task_id".format(where))


def select_scenes(scenes, names, select_all):
    if select_all:
        return list(scenes)
    requested = []
    for value in names or []:
        requested.extend(item for item in value.split(",") if item)
    if not requested:
        raise SceneError("select scenes with --scene NAME[,NAME...] or --all")
    by_name = dict((scene["scene_name"], scene) for scene in scenes)
    missing = [name for name in requested if name not in by_name]
    if missing:
        raise SceneError("unknown scene_name(s): {0}".format(", ".join(missing)))
    if len(set(requested)) != len(requested):
        raise SceneError("the same --scene was selected more than once")
    return [by_name[name] for name in requested]


def scenario_source(pre_sim_root, scene):
    scenario = scene["scenario"]
    relative = scenario["seq_file"].replace("\\", "/")
    if os.path.isabs(relative) or relative.startswith("../") or "/../" in relative:
        raise SceneError("{0}: seq_file must be relative to input/scenario/directed".format(
            scene["scene_name"]
        ))
    expected_prefix = scenario["category"] + "/"
    if not relative.startswith(expected_prefix):
        raise SceneError(
            "{0}: seq_file must be under directed/{1}/".format(
                scene["scene_name"], scenario["category"]
            )
        )
    path = os.path.join(pre_sim_root, "input", "scenario", "directed", *relative.split("/"))
    if not os.path.isfile(path):
        raise SceneError("{0}: scenario file not found: {1}".format(scene["scene_name"], path))
    return path, relative


def parse_supported_plusargs(text, scene_name):
    supported = {}
    for raw in TEST_PLUSARG_RE.findall(text):
        name = raw.strip()
        if not CASE_NAME_RE.match(name):
            raise SceneError("{0}: unsupported dynamic/invalid $test$plusargs literal: {1}".format(
                scene_name, raw
            ))
        previous = supported.get(name)
        current = {"kind": "flag", "format": None, "display": name + "(flag)"}
        if previous and previous != current:
            raise SceneError("{0}: plusarg {1} has conflicting declarations".format(scene_name, name))
        supported[name] = current

    for raw in VALUE_PLUSARG_RE.findall(text):
        matches = FORMAT_RE.findall(raw)
        if len(matches) != 1:
            raise SceneError(
                "{0}: $value$plusargs must contain exactly one supported conversion: {1}".format(
                    scene_name, raw
                )
            )
        fmt = matches[0]
        if fmt not in SUPPORTED_FORMATS:
            raise SceneError("{0}: unsupported plusarg format in {1}".format(scene_name, raw))
        marker = FORMAT_RE.search(raw)
        prefix = raw[:marker.start()].strip()
        name = prefix[:-1] if prefix.endswith("=") else prefix
        if not CASE_NAME_RE.match(name):
            raise SceneError("{0}: invalid plusarg name in {1}".format(scene_name, raw))
        current = {"kind": "value", "format": fmt.lower(), "display": raw.strip()}
        previous = supported.get(name)
        if previous and previous != current:
            raise SceneError("{0}: plusarg {1} has conflicting declarations".format(scene_name, name))
        supported[name] = current
    return supported


def validate_arg_value(scene_name, name, value, definition):
    if definition["kind"] == "flag":
        if not isinstance(value, bool):
            raise SceneError("{0}: flag plusarg {1} must be true or false".format(scene_name, name))
        return
    fmt = definition["format"]
    if fmt in ("d", "h", "x"):
        if isinstance(value, bool):
            raise SceneError("{0}: numeric plusarg {1} cannot be boolean".format(scene_name, name))
        try:
            int(value, 0) if isinstance(value, str) else int(value)
        except (TypeError, ValueError):
            raise SceneError("{0}: plusarg {1} must be numeric for %{2}".format(
                scene_name, name, fmt
            ))
    elif fmt == "s":
        if not isinstance(value, str) or not value or any(ch.isspace() for ch in value):
            raise SceneError("{0}: plusarg {1} must be a non-empty string without whitespace".format(
                scene_name, name
            ))


def validate_scenario(pre_sim_root, scene):
    path, relative = scenario_source(pre_sim_root, scene)
    text = read_text(path)
    registrations = REGISTER_RE.findall(text)
    seq_name = scene["scenario"]["seq_name"]
    if registrations.count(seq_name) != 1:
        raise SceneError(
            "{0}: seq_name {1!r} must appear exactly once in DIRECTED_SCENARIO_REGISTER; found {2}".format(
                scene["scene_name"], seq_name, registrations
            )
        )
    include_file = os.path.join(
        pre_sim_root, "input", "scenario", "directed", "directed_scenario_list.svh"
    )
    include_text = read_text(include_file)
    include_target = "directed/" + relative
    include_matches = re.findall(r"`include\s+\"([^\"]+)\"", include_text)
    if include_target not in include_matches:
        raise SceneError(
            "{0}: scenario is not included by directed_scenario_list.svh: {1}".format(
                scene["scene_name"], include_target
            )
        )
    supported = parse_supported_plusargs(text, scene["scene_name"])
    configured = scene["scenario"]["args"]
    unknown = sorted(set(configured) - set(supported))
    if unknown:
        raise SceneError(
            "{0}: configured plusarg(s) not used by the scenario: {1}; supported: {2}".format(
                scene["scene_name"], ", ".join(unknown),
                ", ".join(sorted(supported)) or "<none>"
            )
        )
    for name, value in configured.items():
        validate_arg_value(scene["scene_name"], name, value, supported[name])
    scene["_seq_path"] = path
    scene["_seq_relative"] = relative
    scene["_supported_args"] = supported
    return scene


def format_arg(name, value, definition):
    if definition["kind"] == "flag":
        return "+" + name if value else ""
    fmt = definition["format"]
    if fmt in ("h", "x"):
        number = int(value, 0) if isinstance(value, str) else int(value)
        rendered = format(number, "x")
    elif fmt == "d":
        rendered = str(int(value, 0) if isinstance(value, str) else int(value))
    else:
        rendered = value
    return "+{0}={1}".format(name, rendered)


def render_case(scene, batch_times=1):
    scenario = scene["scenario"]
    supported = scene["_supported_args"]
    displays = [supported[name]["display"] for name in sorted(supported)]
    args = ["+directed_seq_name=" + scenario["seq_name"]]
    for name, value in scenario["args"].items():
        rendered = format_arg(name, value, supported[name])
        if rendered:
            args.append(rendered)
    name = scene["scene_name"]
    lines = [
        MANAGED_BEGIN.format(name),
        "# scene_id: {0}".format(scene["scene_id"]),
        "# seq_file: directed/{0}".format(scene["_seq_relative"]),
        "# supported_plusargs: {0}".format(", ".join(displays) if displays else "<none>"),
        "- case_name      = {0}".format(name),
        "  uvm_tc         = directed_inst_test",
        "  vcs_tb_args    = {0}".format("".join(args)),
        "  batch_times    = {0}".format(batch_times),
        MANAGED_END.format(name),
    ]
    return "\n".join(lines) + "\n"


def parse_case_list(text):
    managed = {}
    case_owners = {}
    lines = text.splitlines(True)
    index = 0
    while index < len(lines):
        begin = BEGIN_RE.match(lines[index].rstrip("\n"))
        if begin:
            name = begin.group(1)
            if name in managed:
                raise SceneError("duplicate managed block: {0}".format(name))
            end_index = index + 1
            while end_index < len(lines) and not END_RE.match(lines[end_index].rstrip("\n")):
                end_index += 1
            if end_index == len(lines):
                raise SceneError("unterminated managed block: {0}".format(name))
            end = END_RE.match(lines[end_index].rstrip("\n"))
            if end.group(1) != name:
                raise SceneError("managed block marker mismatch: {0}/{1}".format(name, end.group(1)))
            block_cases = []
            for line in lines[index:end_index + 1]:
                match = CASE_RE.search(line)
                if match:
                    block_cases.append(match.group(1))
            if block_cases != [name]:
                raise SceneError("managed block {0} must contain exactly its own case_name".format(name))
            managed[name] = (index, end_index + 1)
            index = end_index + 1
            continue
        match = CASE_RE.search(lines[index])
        if match:
            name = match.group(1)
            if name in case_owners:
                raise SceneError("duplicate case_name in directed.lst: {0}".format(name))
            case_owners[name] = "manual"
        index += 1
    for name in managed:
        if name in case_owners:
            raise SceneError("case_name appears both inside and outside managed block: {0}".format(name))
        case_owners[name] = "managed"
    return lines, managed, case_owners


def sync_directed_list(path, scenes, dry_run=False):
    original = read_text(path) if os.path.exists(path) else ""
    lines, managed, owners = parse_case_list(original)
    for scene in scenes:
        name = scene["scene_name"]
        if owners.get(name) == "manual":
            raise SceneError(
                "{0}: directed.lst already contains an unmanaged case; add PRE_SIM markers or rename the scene".format(name)
            )
    replacements = dict((scene["scene_name"], render_case(scene)) for scene in scenes)
    result = []
    index = 0
    replaced = set()
    while index < len(lines):
        begin = BEGIN_RE.match(lines[index].rstrip("\n"))
        if begin and begin.group(1) in replacements:
            name = begin.group(1)
            start, end = managed[name]
            result.append(replacements[name])
            replaced.add(name)
            index = end
        else:
            result.append(lines[index])
            index += 1
    missing = [scene["scene_name"] for scene in scenes if scene["scene_name"] not in replaced]
    if missing:
        if result and not result[-1].endswith("\n"):
            result[-1] += "\n"
        if result and "".join(result).strip():
            result.append("\n")
        for name in missing:
            result.append(replacements[name])
            result.append("\n")
    updated = "".join(result).rstrip() + "\n"
    # Re-parse before replacing the real file.
    parse_case_list(updated)
    if not dry_run and updated != original:
        atomic_write(path, updated)
    return updated, updated != original


def write_temp_case_list(case_list_dir, scenes, batch_times):
    fd, path = tempfile.mkstemp(prefix="_pre_sim_", suffix=".lst", dir=case_list_dir)
    with os.fdopen(fd, "w", encoding="utf-8") as handle:
        for scene in scenes:
            handle.write(render_case(scene, batch_times=batch_times))
            handle.write("\n")
    return path


def run_command(command, cwd, log_path=None, env=None):
    print("RUN ({0}): {1}".format(cwd, " ".join(command)))
    if log_path:
        os.makedirs(os.path.dirname(log_path), exist_ok=True)
        with open(log_path, "w", encoding="utf-8") as handle:
            return subprocess.call(command, cwd=cwd, stdout=handle,
                                   stderr=subprocess.STDOUT, env=env)
    return subprocess.call(command, cwd=cwd, env=env)


def verify_single_result(sim_dir, started, stage):
    compile_log = os.path.join(sim_dir, "compile.log")
    sim_log = os.path.join(sim_dir, "sim.log")
    for path in (compile_log, sim_log):
        if not os.path.isfile(path) or os.path.getmtime(path) + 1 < started:
            raise SceneError(
                "{0} did not produce a fresh {1}; verify_tools may have hidden a make failure".format(
                    stage, path
                )
            )
    text = read_text(sim_log)
    for severity in ("UVM_ERROR", "UVM_FATAL"):
        match = re.search(r"^{0}\s*:\s*(\d+)\s*$".format(severity), text, re.MULTILINE)
        if not match:
            raise SceneError("{0} sim.log has no {1} summary".format(stage, severity))
        if int(match.group(1)):
            raise SceneError("{0} reported {1} {2}(s)".format(stage, match.group(1), severity))
    if re.search(r"\bTEST\s+FAIL\b", text, re.IGNORECASE):
        raise SceneError("{0} reported TEST FAIL".format(stage))


def verify_batch_result(batch_log, stage):
    if not os.path.isfile(batch_log):
        raise SceneError("{0} did not produce batch.log".format(stage))
    text = read_text(batch_log)
    counts = {}
    for label in ("Total", "Pass", "Fail", "UnRun"):
        matches = re.findall(r"^{0}\s*:\s*(\d+)\s*$".format(label), text,
                             re.MULTILINE | re.IGNORECASE)
        if matches:
            counts[label.lower()] = int(matches[-1])
    if set(counts) != {"total", "pass", "fail", "unrun"}:
        raise SceneError("{0} batch.log has no complete summary".format(stage))
    if counts["fail"] or counts["unrun"] or counts["pass"] != counts["total"]:
        raise SceneError(
            "{0} batch incomplete: total={1}, pass={2}, fail={3}, unrun={4}".format(
                stage, counts["total"], counts["pass"], counts["fail"], counts["unrun"]
            )
        )


def copy_tree_contents(source, target):
    if os.path.isdir(target):
        shutil.rmtree(target)
    if os.path.isdir(source):
        shutil.copytree(source, target)


def parse_task_log(path):
    text = read_text(path)
    tasks = []
    current = None
    for line in text.splitlines():
        match = re.match(r"\s*task_id:\s*(\d+)", line)
        if match:
            if current:
                tasks.append(current)
            current = {"task_id": int(match.group(1))}
            continue
        if current is None:
            continue
        match = re.match(r"\s*rv_core:\s*(\S+)", line)
        if match:
            current["execute_unit"] = match.group(1).lower()
            continue
        match = re.match(r"\s*start_pc:\s*0x([0-9a-fA-F]+)", line)
        if match:
            current["start_pc"] = "0x{0:08x}".format(int(match.group(1), 16))
    if current:
        tasks.append(current)
    if not tasks:
        raise SceneError("cannot parse any task from {0}".format(path))
    return tasks


def enrich_tasks(scene, generated_tasks):
    configured = dict((task["task_id"], task) for task in scene["task_chain"]["tasks"])
    generated = dict((task["task_id"], task) for task in generated_tasks)
    if set(configured) != set(generated):
        raise SceneError(
            "{0}: JSON task IDs {1} do not match inst_gen task IDs {2}".format(
                scene["scene_name"], sorted(configured), sorted(generated)
            )
        )
    result = []
    for task in generated_tasks:
        merged = dict(configured[task["task_id"]])
        expected_core = merged["execute_unit"]
        actual_core = task.get("execute_unit")
        if actual_core and actual_core.replace("hart_", "") != expected_core:
            raise SceneError(
                "{0}: task {1} execute_unit mismatch: JSON={2}, inst_gen={3}".format(
                    scene["scene_name"], task["task_id"], expected_core, actual_core
                )
            )
        merged.update(task)
        merged["execute_unit"] = expected_core
        merged["uid"] = int(merged.get("user_id", merged.get("uid", 0)))
        merged["stream_id"] = int(merged.get("stream_id", 0))
        merged["pid"] = int(merged.get("path_id", merged.get("pid", 0)))
        merged["vcid"] = int(merged.get("vc_id", merged.get("vcid", 0)))
        result.append(merged)
    return result


def write_scene_protocol_artifacts(scene_dir, tasks):
    stimulus_dir = os.path.join(scene_dir, "stimulus")
    dut_cfg_dir = os.path.join(scene_dir, "dut_cfg")
    os.makedirs(stimulus_dir, exist_ok=True)
    os.makedirs(dut_cfg_dir, exist_ok=True)
    task_lines = []
    cfg_lines = []
    for index, task in enumerate(tasks):
        start_pc = int(task["start_pc"], 0)
        dsa_en = 1 if task["execution_mode"] == "rvcore_dsa" else 0
        recv_unit = "01" if dsa_en else "00"
        task_lines.append("%04x %02x %x %08x %s %s %02x %x" % (
            task["uid"], task["task_id"], task["stream_id"], start_pc,
            task["execute_unit"].upper(), task["execution_mode"].upper(),
            task["pid"], task["vcid"]
        ))
        cfg_lines.extend([
            "[task_{0}]".format(task["task_id"]),
            "TASK_PC=0x{0:08x}".format(start_pc),
            "TASK_SEND_UNIT=" + SEND_UNIT[task["execute_unit"]],
            "TASK_DSA_EN={0}".format(dsa_en),
            "TASK_RECV_UNIT=" + recv_unit,
            "TASK_END={0}".format(1 if index == len(tasks) - 1 else 0),
        ])
    atomic_write(os.path.join(stimulus_dir, "ts_task.log"), "\n".join(task_lines) + "\n")
    atomic_write(os.path.join(dut_cfg_dir, "ts_cfg.txt"), "\n".join(cfg_lines) + "\n")


def publish_single_scene(scene, rsim_dir, output_root):
    sim_dir = os.path.join(rsim_dir, "sim_single")
    task_log = os.path.join(sim_dir, "log", "task_info.log")
    if not os.path.isfile(task_log):
        raise SceneError("inst_gen did not produce {0}".format(task_log))
    scene_dir = os.path.join(output_root, "scene_{0:03d}".format(scene["scene_id"]))
    expected_parent = os.path.realpath(output_root) + os.sep
    if not os.path.realpath(scene_dir).startswith(expected_parent):
        raise SceneError("refuse to replace scene output outside {0}".format(output_root))
    if os.path.isdir(scene_dir):
        shutil.rmtree(scene_dir)
    program_dir = os.path.join(scene_dir, "program")
    os.makedirs(program_dir, exist_ok=True)
    vmem_files = []
    core_vmem_names = ["mu_test.vmem", "vu_test.vmem", "dte_test.vmem"]
    available_core_vmem = [name for name in core_vmem_names
                           if os.path.isfile(os.path.join(sim_dir, name))]
    candidates = available_core_vmem or ["test.vmem"]
    for filename in candidates:
        if os.path.isfile(os.path.join(sim_dir, filename)):
            source = os.path.join(sim_dir, filename)
            target = os.path.join(program_dir, filename)
            shutil.copy2(source, target)
            vmem_files.append(target)
    if not vmem_files:
        raise SceneError("inst_gen did not produce any .vmem in {0}".format(sim_dir))
    shutil.copy2(task_log, os.path.join(program_dir, "task_info.log"))
    tasks = enrich_tasks(scene, parse_task_log(task_log))
    with open(os.path.join(scene_dir, "task_info.json"), "w", encoding="utf-8") as handle:
        json.dump({"scene_id": scene["scene_id"], "scene_name": scene["scene_name"],
                   "tasks": tasks}, handle, indent=2)
        handle.write("\n")
    write_scene_protocol_artifacts(scene_dir, tasks)
    return scene_dir, vmem_files


def make_reproduce_script(scene_dir, repo_root, scene_name):
    path = os.path.join(scene_dir, "reproduce.sh")
    text = """#!/usr/bin/env bash
set -euo pipefail
REPO_ROOT={repo!r}
cd "$REPO_ROOT"
python3 st/pre_sim/generator/scene_generator/generate.py --scene {scene} --mode "${{1:-full}}"
""".format(repo=repo_root, scene=scene_name)
    atomic_write(path, text)
    os.chmod(path, 0o755)


def run_single_inst_gen(repo_root, rsim_dir, scene, output_root):
    regression = os.path.join(repo_root, "verify_tools", "script", "regression")
    case_list_dir = os.path.join(rsim_dir, "case_lst")
    temporary = write_temp_case_list(case_list_dir, [scene], 1)
    try:
        command = [sys.executable, regression, "cmd=single",
                   "lst=" + os.path.basename(temporary), "case=" + scene["scene_name"]]
        started = time.time()
        rc = run_command(command, rsim_dir)
        if rc:
            raise SceneError("inst_gen failed for {0} (exit {1})".format(scene["scene_name"], rc))
        verify_single_result(os.path.join(rsim_dir, "sim_single"), started, "inst_gen")
        scene_dir, vmem_files = publish_single_scene(scene, rsim_dir, output_root)
        make_reproduce_script(scene_dir, repo_root, scene["scene_name"])
        return scene_dir, vmem_files
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def build_ref_case(scene, scene_dir, vmem_files):
    args = []
    for index, path in enumerate(vmem_files):
        args.append("+MEM_INIT{0}={1}".format(index, path))
    args.append("+TASK_INFO_PATH=" + os.path.abspath(os.path.join(scene_dir, "task_info.json")))
    return "\n".join([
        "- case_name      = " + scene["scene_name"],
        "  uvm_tc         = reference_execution_test",
        "  vcs_tb_args    = " + "".join(args),
        "  batch_times    = 1",
    ]) + "\n"


def run_single_ref(repo_root, scene, scene_dir, vmem_files):
    ref_dir = os.path.join(repo_root, "st", "core_ref", "ref_sim")
    regression = os.path.join(repo_root, "verify_tools", "script", "regression")
    case_list_dir = os.path.join(ref_dir, "case_lst")
    ref_src_dir = os.path.join(ref_dir, "src_file")
    staged_mem_dir = tempfile.mkdtemp(prefix=".pre_sim_", dir=ref_src_dir)
    staged_mem_files = []
    for index, source in enumerate(vmem_files):
        name = "mem_init{0}_{1}".format(index, os.path.basename(source))
        shutil.copy2(source, os.path.join(staged_mem_dir, name))
        staged_mem_files.append(os.path.join(os.path.basename(staged_mem_dir), name))
    fd, temporary = tempfile.mkstemp(prefix="_pre_sim_", suffix=".lst", dir=case_list_dir)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(build_ref_case(scene, scene_dir, staged_mem_files))
        command = [sys.executable, regression, "cmd=single",
                   "lst=" + os.path.basename(temporary), "case=" + scene["scene_name"]]
        started = time.time()
        ref_env = os.environ.copy()
        ref_env.setdefault("GCC_OPTS", '-LDFLAGS "-lmpfr -lgmp"')
        rc = run_command(command, ref_dir, env=ref_env)
        if rc:
            raise SceneError("core_ref failed for {0} (exit {1})".format(scene["scene_name"], rc))
        verify_single_result(os.path.join(ref_dir, "sim_single"), started, "core_ref")
        copy_tree_contents(os.path.join(ref_dir, "sim_single", "log"),
                           os.path.join(scene_dir, "ref_log"))
        stimulus_dir = os.path.join(scene_dir, "stimulus")
        for req_log in ("vu_req.log", "mu_req.log", "dte_req.log"):
            source = os.path.join(ref_dir, "sim_single", "log", req_log)
            if os.path.isfile(source):
                shutil.copy2(source, os.path.join(stimulus_dir, req_log))
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
        shutil.rmtree(staged_mem_dir, ignore_errors=True)


def batch_output_dir(output_root):
    return os.path.join(output_root, "batch", datetime.date.today().isoformat())


def replace_day_batch(staging, target):
    parent = os.path.dirname(target)
    os.makedirs(parent, exist_ok=True)
    old = target + ".old"
    if os.path.exists(old):
        shutil.rmtree(old)
    if os.path.exists(target):
        os.rename(target, old)
    os.rename(staging, target)
    if os.path.exists(old):
        shutil.rmtree(old)


def run_inst_gen_batch(repo_root, rsim_dir, scenes, output_root, batch_times):
    regression = os.path.join(repo_root, "verify_tools", "script", "regression")
    case_list_dir = os.path.join(rsim_dir, "case_lst")
    temporary = write_temp_case_list(case_list_dir, scenes, batch_times)
    target = batch_output_dir(output_root)
    batch_root = os.path.join(output_root, "batch")
    os.makedirs(batch_root, exist_ok=True)
    staging = tempfile.mkdtemp(prefix=".batch_", dir=batch_root)
    try:
        log_dir = os.path.join(staging, "inst_gen")
        os.makedirs(log_dir)
        command = [sys.executable, regression, "cmd=batch",
                   "lst=" + os.path.basename(temporary), "times=" + str(batch_times)]
        rc = run_command(command, rsim_dir)
        native_log = os.path.join(rsim_dir, "sim_batch", "batch.log")
        if os.path.isfile(native_log):
            shutil.copy2(native_log, os.path.join(log_dir, "batch.log"))
        if rc:
            raise SceneError("inst_gen batch failed (exit {0})".format(rc))
        verify_batch_result(native_log, "inst_gen")
        reproduce = os.path.join(staging, "reproduce.sh")
        atomic_write(reproduce, "#!/usr/bin/env bash\nset -euo pipefail\ncd {0!r}\npython3 st/pre_sim/generator/scene_generator/generate.py --scene {1} --mode inst-gen --batch-times {2}\n".format(
            repo_root, ",".join(scene["scene_name"] for scene in scenes), batch_times
        ))
        os.chmod(reproduce, 0o755)
        replace_day_batch(staging, target)
        staging = None
        return target
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)
        if staging and os.path.isdir(staging):
            shutil.rmtree(staging)


def parse_args(argv=None):
    here = os.path.dirname(os.path.abspath(__file__))
    pre_sim_root = os.path.abspath(os.path.join(here, "..", ".."))
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", default=os.path.join(pre_sim_root, "input", "hardware_feature.json"))
    parser.add_argument("--scene", action="append", help="scene_name or comma-separated scene_names")
    parser.add_argument("--all", action="store_true", help="select every scene")
    parser.add_argument("--mode", choices=("sync", "inst-gen", "full"), default="sync")
    parser.add_argument("--batch-times", type=int, default=1,
                        help="use verify_tools batch test; does not publish scene artifacts")
    parser.add_argument("--dry-run", action="store_true", help="validate and print without writing/running")
    args = parser.parse_args(argv)
    if args.all and args.scene:
        parser.error("--all and --scene are mutually exclusive")
    if args.batch_times < 1:
        parser.error("--batch-times must be >= 1")
    return args, pre_sim_root


def main(argv=None):
    args, pre_sim_root = parse_args(argv)
    repo_root = os.path.abspath(os.path.join(pre_sim_root, "..", ".."))
    rsim_dir = os.path.join(pre_sim_root, "generator", "inst_generator", "rsim")
    directed_list = os.path.join(rsim_dir, "case_lst", "directed.lst")
    output_root = os.path.join(pre_sim_root, "output")

    scenes = load_scenes(os.path.abspath(args.input))
    selected = select_scenes(scenes, args.scene, args.all)
    for scene in selected:
        validate_scenario(pre_sim_root, scene)
    _, changed = sync_directed_list(directed_list, selected, dry_run=args.dry_run)
    print("validated {0} scene(s); directed.lst {1}".format(
        len(selected), "would change" if args.dry_run and changed else
        ("updated" if changed else "unchanged")
    ))
    if args.dry_run or args.mode == "sync":
        return 0

    os.makedirs(output_root, exist_ok=True)
    use_batch = len(selected) > 1 or args.batch_times > 1
    if use_batch:
        if args.mode == "full":
            raise SceneError(
                "full batch publication needs per-case VMEM archiving from verify_tools; "
                "run --mode full per scene, or use --mode inst-gen for batch testing"
            )
        result = run_inst_gen_batch(repo_root, rsim_dir, selected, output_root, args.batch_times)
        print("batch log collected under {0}".format(result))
        return 0

    scene = selected[0]
    scene_dir, vmem_files = run_single_inst_gen(repo_root, rsim_dir, scene, output_root)
    if args.mode == "full":
        run_single_ref(repo_root, scene, scene_dir, vmem_files)
    print("generated {0} in {1}".format(scene["scene_name"], scene_dir))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except SceneError as exc:
        sys.stderr.write("pre_sim error: {0}\n".format(exc))
        sys.exit(2)
