#!/usr/bin/env python
"""Generate sequence-behavior configuration from docs/seq/seq_table.xlsx::TABLE_USAGE."""

from __future__ import print_function

import argparse
import copy
import json
import os
import re

from xls_table import read_table, split_table_ref, table_file_exists


SV_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")
GAP_POLICY_CODES = {
    "UNIFORM": "SEQ_GAP_POLICY_UNIFORM",
    "WEIGHTED": "SEQ_GAP_POLICY_WEIGHTED",
}
GAP_LEVEL_NAMES = ("MIN", "MID", "HIGH", "MAX")

try:
    long
except NameError:
    long = int

try:
    basestring
except NameError:
    basestring = str


DEFAULT_CFG = {
    "generated_package": "axi4_seq_cfg_pkg",
    "gap": {
        "fixed_cycles": 2,
        "default_policy": "WEIGHTED",
        "levels": {
            "MIN": {
                "min_cycles": 0,
                "max_cycles": 5,
                "weight": 50,
                "cycle_weights": {
                    "0": 30,
                    "1": 25,
                    "2": 20,
                    "3": 15,
                    "4": 7,
                    "5": 3,
                },
            },
            "MID": {
                "min_cycles": 5,
                "max_cycles": 10,
                "weight": 30,
                "cycle_weights": {
                    "5": 30,
                    "6": 25,
                    "7": 20,
                    "8": 15,
                    "9": 7,
                    "10": 3,
                },
            },
            "HIGH": {
                "min_cycles": 10,
                "max_cycles": 15,
                "weight": 15,
                "cycle_weights": {
                    "10": 30,
                    "11": 25,
                    "12": 20,
                    "13": 15,
                    "14": 7,
                    "15": 3,
                },
            },
            "MAX": {
                "min_cycles": 15,
                "max_cycles": 20,
                "weight": 5,
                "cycle_weights": {
                    "15": 30,
                    "16": 25,
                    "17": 20,
                    "18": 15,
                    "19": 7,
                    "20": 3,
                },
            },
        },
    },
}


def deep_update(base, override):
    for key, value in override.items():
        if key in base and isinstance(base[key], dict) and isinstance(value, dict):
            deep_update(base[key], value)
        else:
            base[key] = value


def merged_cfg(user_cfg):
    cfg = copy.deepcopy(DEFAULT_CFG)
    deep_update(cfg, user_cfg)
    return cfg


def parse_int_text(text, key):
    match = re.search(r"[-+]?(?:0x[0-9a-fA-F_]+|[0-9_]+)", str(text))
    if not match:
        raise ValueError("%s must contain an integer, got %r" % (key, text))
    return int(match.group(0).replace("_", ""), 0)


def parse_level_summary(text, level):
    match = re.search(
        r"range\s*=\s*\[\s*([^,\]]+)\s*,\s*([^\]]+)\s*\]\s*;\s*level_weight\s*=\s*([^;\s]+)",
        str(text),
        re.IGNORECASE,
    )
    if not match:
        raise ValueError(
            "table.random_level %s current_value must use 'range=[min,max]; level_weight=weight', got %r"
            % (level, text)
        )
    return {
        "min_cycles": parse_int_text(match.group(1), "gap.levels.%s.min_cycles" % level),
        "max_cycles": parse_int_text(match.group(2), "gap.levels.%s.max_cycles" % level),
        "weight": parse_int_text(match.group(3), "gap.levels.%s.weight" % level),
    }


def parse_cycle_weights(text, level):
    weights = {}
    for chunk in str(text).split(";"):
        item = chunk.strip()
        if not item:
            continue
        if ":" not in item:
            raise ValueError(
                "table.random_cycle_weights %s current_value must use 'cycle:weight' entries, got %r"
                % (level, item)
            )
        raw_cycle, raw_weight = item.split(":", 1)
        cycle = parse_int_text(raw_cycle, "gap.levels.%s.cycle_weights cycle" % level)
        weight = parse_int_text(raw_weight, "gap.levels.%s.cycle_weights weight" % level)
        weights[str(cycle)] = weight
    if not weights:
        raise ValueError("table.random_cycle_weights %s current_value is empty" % level)
    return weights


def is_legacy_html_usage(path):
    path, _ = split_table_ref(path)
    try:
        with open(path, "rb") as usage_file:
            head = usage_file.read(512).lstrip().lower()
    except IOError:
        return False
    return head.startswith(b"<!doctype html") or head.startswith(b"<html")


def load_usage_cfg(path):
    cfg = copy.deepcopy(DEFAULT_CFG)
    if not path or not table_file_exists(path):
        return cfg
    if is_legacy_html_usage(path):
        return cfg

    try:
        _, rows = read_table(path)
    except ValueError:
        return cfg
    for row in rows:
        section = str(row.get("section", "")).strip()
        item = str(row.get("item", "")).strip()
        config_source = str(row.get("config_source", "")).strip()
        current_value = str(row.get("current_value", "")).strip()
        if not current_value:
            continue

        is_fixed_gap = section == "table.gap_mode" or config_source.endswith("gap.fixed_cycles")
        is_random_policy = section == "table.gap_mode" or config_source.endswith("gap.default_policy")
        is_random_level = section == "table.random_level" or (
            item in GAP_LEVEL_NAMES and config_source.endswith("gap.levels.%s" % item)
        )
        is_cycle_weights = section == "table.random_cycle_weights" or config_source.endswith(".cycle_weights")

        if is_fixed_gap and item == "FIXED":
            cfg["gap"]["fixed_cycles"] = parse_int_text(current_value, "gap.fixed_cycles")
        elif is_random_policy and item == "RANDOM":
            cfg["gap"]["default_policy"] = current_value.strip().upper()
        elif is_random_level and item in GAP_LEVEL_NAMES:
            cfg["gap"]["levels"][item].update(parse_level_summary(current_value, item))
        elif is_cycle_weights:
            level = item.split(".", 1)[0]
            if level in GAP_LEVEL_NAMES:
                cfg["gap"]["levels"][level]["cycle_weights"] = parse_cycle_weights(current_value, level)
    return cfg


def require_ident(name):
    if not SV_IDENT.match(name):
        raise ValueError("Invalid SystemVerilog identifier: %s" % name)
    return name


def require_int(cfg, key, default=None, min_value=0):
    value = cfg.get(key, default)
    if value is None:
        raise ValueError("Missing required config value: %s" % key)
    if isinstance(value, bool):
        raise ValueError("Config value %s must be an integer, got bool" % key)
    if isinstance(value, (int, long)):
        result = int(value)
    elif isinstance(value, basestring):
        result = int(value.replace("_", ""), 0)
    else:
        raise ValueError("Config value %s must be an integer, got %r" % (key, value))
    if result < min_value:
        raise ValueError("Config value %s must be >= %d, got %d" % (key, min_value, result))
    return result


def sv_string(value):
    return json.dumps(str(value))


def add_param(lines, type_text, name, value):
    lines.append("  parameter %s %s = %s;" % (type_text, name, value))


def gap_policy(value):
    text = str(value).strip().upper()
    if text in ("RANDOM", "RAND", "DEFAULT"):
        text = "WEIGHTED"
    if text not in GAP_POLICY_CODES:
        raise ValueError("gap.default_policy must be UNIFORM or WEIGHTED, got %s" % value)
    return text, GAP_POLICY_CODES[text]


def cycle_weight_cfg(level_cfg, level, min_cycles, max_cycles, defaults):
    raw_weights = level_cfg.get("cycle_weights", defaults.get("cycle_weights", {}))
    if raw_weights is None:
        raw_weights = {}

    weights = []
    if isinstance(raw_weights, list):
        expected_len = max_cycles - min_cycles + 1
        if len(raw_weights) != expected_len:
            raise ValueError(
                "gap.levels.%s.cycle_weights list must contain %d entries for [%d, %d]"
                % (level, expected_len, min_cycles, max_cycles)
            )
        for idx, raw_weight in enumerate(raw_weights):
            cycle = min_cycles + idx
            weight = require_int({"weight": raw_weight}, "weight", None, 0)
            weights.append((cycle, weight))
    elif isinstance(raw_weights, dict):
        normalized_weights = {}
        for raw_cycle in raw_weights:
            try:
                cycle = int(str(raw_cycle).replace("_", ""), 0)
            except ValueError:
                raise ValueError(
                    "gap.levels.%s.cycle_weights key must be a cycle number, got %s"
                    % (level, raw_cycle)
                )
            if cycle < min_cycles or cycle > max_cycles:
                raise ValueError(
                    "gap.levels.%s.cycle_weights has cycle %d outside [%d, %d]"
                    % (level, cycle, min_cycles, max_cycles)
                )
            if cycle in normalized_weights:
                raise ValueError(
                    "gap.levels.%s.cycle_weights has duplicate cycle %d"
                    % (level, cycle)
                )
            normalized_weights[cycle] = raw_weights[raw_cycle]

        for cycle in range(min_cycles, max_cycles + 1):
            if cycle not in normalized_weights:
                raise ValueError(
                    "gap.levels.%s.cycle_weights is missing cycle %d"
                    % (level, cycle)
                )
            weight = require_int({"weight": normalized_weights[cycle]}, "weight", None, 0)
            weights.append((cycle, weight))
    else:
        raise ValueError("gap.levels.%s.cycle_weights must be an object or list" % level)

    if sum(weight for _, weight in weights) == 0:
        raise ValueError("gap.levels.%s.cycle_weights must contain at least one non-zero weight" % level)
    return weights


def gap_level_cfg(gap_cfg, level):
    levels = gap_cfg.get("levels", {})
    if not isinstance(levels, dict):
        raise ValueError("gap.levels must be an object")
    level_cfg = levels.get(level, {})
    if not isinstance(level_cfg, dict):
        raise ValueError("gap.levels.%s must be an object" % level)
    defaults = DEFAULT_CFG["gap"]["levels"][level]
    min_cycles = require_int(level_cfg, "min_cycles", defaults["min_cycles"], 0)
    max_cycles = require_int(level_cfg, "max_cycles", defaults["max_cycles"], 0)
    weight = require_int(level_cfg, "weight", defaults["weight"], 0)
    if max_cycles < min_cycles:
        raise ValueError("gap.levels.%s.max_cycles must be >= min_cycles" % level)
    cycle_weights = cycle_weight_cfg(level_cfg, level, min_cycles, max_cycles, defaults)
    return min_cycles, max_cycles, weight, cycle_weights


def gap_cycle_weight_param(level, cycle):
    return "SEQ_GAP_%s_CYCLE_%d_WEIGHT" % (level, cycle)


def add_gap_cycle_function(lines, level, cycle_weights):
    func_name = "seq_gap_%s_cycles" % level.lower()
    param_names = [gap_cycle_weight_param(level, cycle) for cycle, _ in cycle_weights]
    total_expr = " + ".join(param_names)

    lines.append("  function automatic int unsigned %s();" % func_name)
    lines.append("    int unsigned total_weight;")
    lines.append("    int unsigned pick;")
    lines.append("    int unsigned cursor;")
    lines.append("")
    lines.append("    total_weight = %s;" % total_expr)
    lines.append("    pick = $urandom_range(total_weight - 1, 0);")
    lines.append("")
    for idx, (cycle, _) in enumerate(cycle_weights):
        param_name = gap_cycle_weight_param(level, cycle)
        if idx == 0:
            lines.append("    cursor = %s;" % param_name)
        else:
            lines.append("    cursor = cursor + %s;" % param_name)
        lines.append("    if (pick < cursor) begin")
        lines.append("      return %d;" % cycle)
        lines.append("    end")
    lines.append("    return %d;" % cycle_weights[-1][0])
    lines.append("  endfunction")


def generate(user_cfg):
    cfg = merged_cfg(user_cfg)
    package = require_ident(cfg.get("generated_package", "axi4_seq_cfg_pkg"))
    gap = cfg.get("gap", {})
    if not isinstance(gap, dict):
        raise ValueError("gap must be an object")

    lines = [
        "// Auto-generated by scripts/gen_seq_cfg.py. Do not edit by hand.",
        "package %s;" % package,
    ]

    add_param(lines, "int", "SEQ_GAP_POLICY_UNIFORM", 0)
    add_param(lines, "int", "SEQ_GAP_POLICY_WEIGHTED", 1)
    lines.append("")

    gap_policy_name, gap_policy_param = gap_policy(
        gap.get("default_policy", DEFAULT_CFG["gap"]["default_policy"])
    )
    add_param(lines, "int", "SEQ_GAP_FIXED_CYCLES", require_int(gap, "fixed_cycles", DEFAULT_CFG["gap"]["fixed_cycles"], 0))
    add_param(lines, "string", "SEQ_GAP_DEFAULT_POLICY_NAME", sv_string(gap_policy_name))
    add_param(lines, "int", "SEQ_GAP_DEFAULT_POLICY", gap_policy_param)

    gap_cycle_weights = {}
    for level in GAP_LEVEL_NAMES:
        min_cycles, max_cycles, weight, cycle_weights = gap_level_cfg(gap, level)
        add_param(lines, "int", "SEQ_GAP_%s_MIN_CYCLES" % level, min_cycles)
        add_param(lines, "int", "SEQ_GAP_%s_MAX_CYCLES" % level, max_cycles)
        add_param(lines, "int", "SEQ_GAP_%s_WEIGHT" % level, weight)
        for cycle, cycle_weight in cycle_weights:
            add_param(lines, "int", gap_cycle_weight_param(level, cycle), cycle_weight)
        gap_cycle_weights[level] = cycle_weights
    lines.append("")

    for level in GAP_LEVEL_NAMES:
        add_gap_cycle_function(lines, level, gap_cycle_weights[level])
        lines.append("")

    lines.extend([
        "endpackage : %s" % package,
        "",
    ])
    return lines


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--usage", default="docs/seq/seq_table.xlsx::TABLE_USAGE")
    parser.add_argument("--out", default="tb/generated/axi4_seq_cfg_pkg.sv")
    args = parser.parse_args()

    user_cfg = load_usage_cfg(args.usage)

    out_dir = os.path.dirname(args.out)
    if out_dir and not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    with open(args.out, "w") as out_file:
        out_file.write("\n".join(generate(user_cfg)))
    print("Generated %s from %s" % (args.out, args.usage))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
