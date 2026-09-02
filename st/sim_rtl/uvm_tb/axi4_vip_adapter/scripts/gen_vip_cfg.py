#!/usr/bin/env python
"""Generate an AXI4 VIP configuration package from generated VIP cfg JSON."""

import argparse
import copy
import json
import os
import re


SV_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")

try:
    long
except NameError:
    long = int

try:
    basestring
except NameError:
    basestring = str


DEFAULT_CFG = {
    "generated_package": "axi4_vip_cfg_pkg",
    "template_version": 4,
    "design_name": "default_axi4_demo",
    "description": "Full default AXI4 VIP configuration template. Modify only the fields required by the current design document.",
    "axi": {
        "protocol": "AXI4",
        "vip_path": "tb/axi4",
        "addr_width": 32,
        "data_width": 32,
        "id_width": 4,
        "len_width": 8,
        "size_width": 3,
        "burst_width": 2,
        "lock_width": 1,
        "cache_width": 4,
        "prot_width": 3,
        "qos_width": 4,
        "region_width": 4,
        "resp_width": 2,
        "awuser_width": 0,
        "aruser_width": 0,
        "wuser_width": 0,
        "ruser_width": 0,
        "buser_width": 0,
        "default_id": 0,
        "default_strb": "auto",
        "default_burst_type": "INCR",
        "default_burst_len": 1,
        "default_lock": 0,
        "default_cache": "0x2",
        "default_prot": "0x0",
        "default_qos": "0x0",
        "default_region": "0x0",
        "default_awuser": "0x0",
        "default_aruser": "0x0",
        "default_wuser": "0x0",
        "max_burst_len": 1,
        "max_outstanding_reads": 1,
        "max_outstanding_writes": 1,
        "read_timeout_cycles": 1000,
        "write_timeout_cycles": 1000,
        "ready_timeout_cycles": 1000,
    },
    "support": {
        "exclusive_access": False,
        "locked_access": False,
        "narrow_burst": True,
        "unaligned_access": False,
        "fixed_burst": True,
        "incrementing_burst": True,
        "wrapping_burst": False,
        "byte_strobe": True,
    },
    "checker": {
        "enable_protocol_checks": True,
        "enable_x_checks": True,
        "enable_alignment_checks": True,
        "enable_strobe_checks": True,
        "enable_response_checks": True,
        "enable_timeout_checks": True,
    },
    "coverage": {
        "enable_coverage": False,
        "enable_transaction_coverage": False,
        "enable_protocol_coverage": False,
        "enable_error_coverage": False,
    },
}

BURST_CODES = {
    "FIXED": 0,
    "INCR": 1,
    "WRAP": 2,
}

def merged_cfg(user_cfg):
    cfg = copy.deepcopy(DEFAULT_CFG)
    deep_update(cfg, user_cfg)

    raw_axi = user_cfg.get("axi", {}) if isinstance(user_cfg.get("axi", {}), dict) else {}
    if "outstanding" in raw_axi:
        if "max_outstanding_reads" not in raw_axi:
            cfg["axi"]["max_outstanding_reads"] = raw_axi["outstanding"]
        if "max_outstanding_writes" not in raw_axi:
            cfg["axi"]["max_outstanding_writes"] = raw_axi["outstanding"]
    return cfg


def deep_update(base, override):
    for key, value in override.items():
        if (
            key in base
            and isinstance(base[key], dict)
            and isinstance(value, dict)
        ):
            deep_update(base[key], value)
        else:
            base[key] = value


def require_ident(name):
    if not SV_IDENT.match(name):
        raise ValueError("Invalid SystemVerilog identifier: %s" % name)
    return name


def require_string(cfg, key, default=None):
    value = cfg.get(key, default)
    if value is None:
        raise ValueError("Missing required config value: %s" % key)
    return str(value)


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


def require_bool(cfg, key, default=False):
    value = cfg.get(key, default)
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, long)):
        if value in (0, 1):
            return bool(value)
    if isinstance(value, basestring):
        text = value.strip().lower()
        if text in ("1", "true", "yes", "on"):
            return True
        if text in ("0", "false", "no", "off"):
            return False
    raise ValueError("Config value %s must be boolean, got %r" % (key, value))


def sv_string(value):
    return json.dumps(str(value))


def sv_int_literal(value):
    if isinstance(value, bool):
        raise ValueError("Expected int or string literal, got bool")
    if isinstance(value, (int, long)):
        return str(value)
    if not isinstance(value, basestring):
        raise ValueError("Expected int or string literal, got %r" % (value,))
    text = value.strip().replace("_", "")
    if text.lower().startswith("0x"):
        return "'h%s" % text[2:]
    return str(int(text, 0))


def sv_bool_literal(value):
    return "1'b1" if value else "1'b0"


def parse_int_literal(value, key):
    if isinstance(value, bool):
        raise ValueError("Config value %s must be an integer, got bool" % key)
    if isinstance(value, (int, long)):
        return int(value)
    if isinstance(value, basestring):
        return int(value.replace("_", ""), 0)
    raise ValueError("Config value %s must be an integer literal, got %r" % (key, value))


def check_fits(value, width, key):
    parsed = parse_int_literal(value, key)
    if width == 0:
        if parsed != 0:
            raise ValueError("Config value %s must be 0 when width is 0" % key)
        return
    if parsed < 0 or parsed >= (1 << width):
        raise ValueError("Config value %s=%s does not fit width %d" % (key, value, width))


def strb_literal(default_strb, strb_width):
    if default_strb is None or str(default_strb).strip().lower() == "auto":
        return "'1"
    check_fits(default_strb, strb_width, "axi.default_strb")
    return sv_int_literal(default_strb)


def named_code(value, mapping, key):
    if isinstance(value, (int, long)):
        return int(value), str(value)
    text = str(value).strip()
    upper = text.upper()
    if upper in mapping:
        return mapping[upper], upper
    parsed = int(text.replace("_", ""), 0)
    reverse = dict((code, name) for name, code in mapping.items())
    return parsed, reverse.get(parsed, text)


def add_param(lines, type_text, name, value):
    lines.append("  parameter %s %s = %s;" % (type_text, name, value))


def generate(user_cfg):
    cfg = merged_cfg(user_cfg)
    package = require_ident(cfg.get("generated_package", "axi4_vip_cfg_pkg"))
    template_version = require_int(cfg, "template_version", 2, 1)
    design_name = require_string(cfg, "design_name", "default_axi4_design")
    description = require_string(cfg, "description", "")
    axi = cfg.get("axi", {})
    support = cfg.get("support", {})
    checker = cfg.get("checker", {})
    coverage = cfg.get("coverage", {})

    vip_path = require_string(axi, "vip_path", DEFAULT_CFG["axi"]["vip_path"]).strip()
    if not vip_path:
        raise ValueError("axi.vip_path must not be empty")
    if "\n" in vip_path or "\r" in vip_path:
        raise ValueError("axi.vip_path must be a single path")

    addr_width = require_int(axi, "addr_width", 32, 1)
    data_width = require_int(axi, "data_width", 32, 8)
    id_width = require_int(axi, "id_width", 4, 1)
    if data_width % 8 != 0:
        raise ValueError("axi.data_width must be a multiple of 8")

    strb_width = data_width // 8
    len_width = require_int(axi, "len_width", 8, 1)
    size_width = require_int(axi, "size_width", 3, 1)
    burst_width = require_int(axi, "burst_width", 2, 1)
    lock_width = require_int(axi, "lock_width", 1, 1)
    cache_width = require_int(axi, "cache_width", 4, 1)
    prot_width = require_int(axi, "prot_width", 3, 1)
    qos_width = require_int(axi, "qos_width", 4, 1)
    region_width = require_int(axi, "region_width", 4, 1)
    resp_width = require_int(axi, "resp_width", 2, 1)
    awuser_width = require_int(axi, "awuser_width", 0, 0)
    aruser_width = require_int(axi, "aruser_width", 0, 0)
    wuser_width = require_int(axi, "wuser_width", 0, 0)
    ruser_width = require_int(axi, "ruser_width", 0, 0)
    buser_width = require_int(axi, "buser_width", 0, 0)

    max_burst_len = require_int(axi, "max_burst_len", 1, 1)
    default_burst_len = require_int(axi, "default_burst_len", 1, 1)
    if max_burst_len > 256:
        raise ValueError("axi.max_burst_len must be <= 256 for AXI4")
    if default_burst_len > max_burst_len:
        raise ValueError("axi.default_burst_len must be <= axi.max_burst_len")

    max_rd_outstanding = require_int(axi, "max_outstanding_reads", 1, 1)
    max_wr_outstanding = require_int(axi, "max_outstanding_writes", 1, 1)
    outstanding = max(max_rd_outstanding, max_wr_outstanding)
    read_timeout = require_int(axi, "read_timeout_cycles", 1000, 0)
    write_timeout = require_int(axi, "write_timeout_cycles", 1000, 0)
    ready_timeout = require_int(axi, "ready_timeout_cycles", 1000, 0)

    default_id = axi.get("default_id", 0)
    default_lock = axi.get("default_lock", 0)
    default_cache = axi.get("default_cache", "0x2")
    default_prot = axi.get("default_prot", "0x0")
    default_qos = axi.get("default_qos", "0x0")
    default_region = axi.get("default_region", "0x0")
    check_fits(default_id, id_width, "axi.default_id")
    check_fits(default_lock, lock_width, "axi.default_lock")
    check_fits(default_cache, cache_width, "axi.default_cache")
    check_fits(default_prot, prot_width, "axi.default_prot")
    check_fits(default_qos, qos_width, "axi.default_qos")
    check_fits(default_region, region_width, "axi.default_region")
    check_fits(axi.get("default_awuser", "0x0"), awuser_width, "axi.default_awuser")
    check_fits(axi.get("default_aruser", "0x0"), aruser_width, "axi.default_aruser")
    check_fits(axi.get("default_wuser", "0x0"), wuser_width, "axi.default_wuser")

    default_strb = strb_literal(axi.get("default_strb", "auto"), strb_width)
    burst_code, burst_name = named_code(axi.get("default_burst_type", "INCR"), BURST_CODES, "axi.default_burst_type")
    if burst_code < 0 or burst_code >= (1 << burst_width):
        raise ValueError("axi.default_burst_type does not fit axi.burst_width")

    lines = [
        "// Auto-generated by scripts/gen_vip_cfg.py. Do not edit by hand.",
        "package %s;" % package,
    ]

    add_param(lines, "int", "VIP_CFG_TEMPLATE_VERSION", template_version)
    add_param(lines, "string", "VIP_CFG_DESIGN_NAME", sv_string(design_name))
    add_param(lines, "string", "VIP_CFG_DESCRIPTION", sv_string(description))
    add_param(lines, "string", "VIP_AXI_PROTOCOL", sv_string(axi.get("protocol", "AXI4")))
    add_param(lines, "string", "VIP_AXI_VIP_PATH", sv_string(vip_path))
    lines.append("")

    add_param(lines, "int", "VIP_AXI_ADDR_WIDTH", addr_width)
    add_param(lines, "int", "VIP_AXI_DATA_WIDTH", data_width)
    add_param(lines, "int", "VIP_AXI_ID_WIDTH", id_width)
    add_param(lines, "int", "VIP_AXI_STRB_WIDTH", strb_width)
    add_param(lines, "int", "VIP_AXI_LEN_WIDTH", len_width)
    add_param(lines, "int", "VIP_AXI_SIZE_WIDTH", size_width)
    add_param(lines, "int", "VIP_AXI_BURST_WIDTH", burst_width)
    add_param(lines, "int", "VIP_AXI_LOCK_WIDTH", lock_width)
    add_param(lines, "int", "VIP_AXI_CACHE_WIDTH", cache_width)
    add_param(lines, "int", "VIP_AXI_PROT_WIDTH", prot_width)
    add_param(lines, "int", "VIP_AXI_QOS_WIDTH", qos_width)
    add_param(lines, "int", "VIP_AXI_REGION_WIDTH", region_width)
    add_param(lines, "int", "VIP_AXI_RESP_WIDTH", resp_width)
    add_param(lines, "int", "VIP_AXI_AWUSER_WIDTH", awuser_width)
    add_param(lines, "int", "VIP_AXI_ARUSER_WIDTH", aruser_width)
    add_param(lines, "int", "VIP_AXI_WUSER_WIDTH", wuser_width)
    add_param(lines, "int", "VIP_AXI_RUSER_WIDTH", ruser_width)
    add_param(lines, "int", "VIP_AXI_BUSER_WIDTH", buser_width)
    lines.append("")

    add_param(lines, "bit [VIP_AXI_ID_WIDTH-1:0]", "VIP_AXI_DEFAULT_ID", sv_int_literal(default_id))
    add_param(lines, "bit [VIP_AXI_STRB_WIDTH-1:0]", "VIP_AXI_DEFAULT_STRB", default_strb)
    add_param(lines, "string", "VIP_AXI_DEFAULT_BURST_TYPE", sv_string(burst_name))
    add_param(lines, "bit [VIP_AXI_BURST_WIDTH-1:0]", "VIP_AXI_DEFAULT_BURST", burst_code)
    add_param(lines, "int", "VIP_AXI_DEFAULT_BURST_LEN", default_burst_len)
    add_param(lines, "bit [VIP_AXI_LOCK_WIDTH-1:0]", "VIP_AXI_DEFAULT_LOCK", sv_int_literal(default_lock))
    add_param(lines, "bit [VIP_AXI_CACHE_WIDTH-1:0]", "VIP_AXI_DEFAULT_CACHE", sv_int_literal(default_cache))
    add_param(lines, "bit [VIP_AXI_PROT_WIDTH-1:0]", "VIP_AXI_DEFAULT_PROT", sv_int_literal(default_prot))
    add_param(lines, "bit [VIP_AXI_QOS_WIDTH-1:0]", "VIP_AXI_DEFAULT_QOS", sv_int_literal(default_qos))
    add_param(lines, "bit [VIP_AXI_REGION_WIDTH-1:0]", "VIP_AXI_DEFAULT_REGION", sv_int_literal(default_region))
    add_param(lines, "int", "VIP_AXI_DEFAULT_AWUSER", sv_int_literal(axi.get("default_awuser", "0x0")))
    add_param(lines, "int", "VIP_AXI_DEFAULT_ARUSER", sv_int_literal(axi.get("default_aruser", "0x0")))
    add_param(lines, "int", "VIP_AXI_DEFAULT_WUSER", sv_int_literal(axi.get("default_wuser", "0x0")))
    lines.append("")

    add_param(lines, "int", "VIP_AXI_MAX_BURST_LEN", max_burst_len)
    add_param(lines, "int", "VIP_AXI_MAX_OUTSTANDING_READS", max_rd_outstanding)
    add_param(lines, "int", "VIP_AXI_MAX_OUTSTANDING_WRITES", max_wr_outstanding)
    add_param(lines, "int", "VIP_AXI_OUTSTANDING", outstanding)
    add_param(lines, "int", "VIP_AXI_READ_TIMEOUT_CYCLES", read_timeout)
    add_param(lines, "int", "VIP_AXI_WRITE_TIMEOUT_CYCLES", write_timeout)
    add_param(lines, "int", "VIP_AXI_READY_TIMEOUT_CYCLES", ready_timeout)
    lines.append("")

    for key, param in (
        ("exclusive_access", "VIP_SUPPORT_EXCLUSIVE_ACCESS"),
        ("locked_access", "VIP_SUPPORT_LOCKED_ACCESS"),
        ("narrow_burst", "VIP_SUPPORT_NARROW_BURST"),
        ("unaligned_access", "VIP_SUPPORT_UNALIGNED_ACCESS"),
        ("fixed_burst", "VIP_SUPPORT_FIXED_BURST"),
        ("incrementing_burst", "VIP_SUPPORT_INCREMENTING_BURST"),
        ("wrapping_burst", "VIP_SUPPORT_WRAPPING_BURST"),
        ("byte_strobe", "VIP_SUPPORT_BYTE_STROBE"),
    ):
        add_param(lines, "bit", param, sv_bool_literal(require_bool(support, key, DEFAULT_CFG["support"][key])))
    lines.append("")

    for key, param in (
        ("enable_protocol_checks", "VIP_ENABLE_PROTOCOL_CHECKS"),
        ("enable_x_checks", "VIP_ENABLE_X_CHECKS"),
        ("enable_alignment_checks", "VIP_ENABLE_ALIGNMENT_CHECKS"),
        ("enable_strobe_checks", "VIP_ENABLE_STROBE_CHECKS"),
        ("enable_response_checks", "VIP_ENABLE_RESPONSE_CHECKS"),
        ("enable_timeout_checks", "VIP_ENABLE_TIMEOUT_CHECKS"),
    ):
        add_param(lines, "bit", param, sv_bool_literal(require_bool(checker, key, DEFAULT_CFG["checker"][key])))
    lines.append("")

    for key, param in (
        ("enable_coverage", "VIP_ENABLE_COVERAGE"),
        ("enable_transaction_coverage", "VIP_ENABLE_TRANSACTION_COVERAGE"),
        ("enable_protocol_coverage", "VIP_ENABLE_PROTOCOL_COVERAGE"),
        ("enable_error_coverage", "VIP_ENABLE_ERROR_COVERAGE"),
    ):
        add_param(lines, "bit", param, sv_bool_literal(require_bool(coverage, key, DEFAULT_CFG["coverage"][key])))

    lines.extend([
        "endpackage : %s" % package,
        "",
    ])
    return lines


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cfg", default="tb/generated/axi4_vip_cfg.json")
    parser.add_argument("--out", default="tb/generated/axi4_vip_cfg_pkg.sv")
    args = parser.parse_args()

    with open(args.cfg, "r") as cfg_file:
        user_cfg = json.load(cfg_file)

    out_dir = os.path.dirname(args.out)
    if out_dir and not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    with open(args.out, "w") as out_file:
        out_file.write("\n".join(generate(user_cfg)))
    print("Generated %s from %s" % (args.out, args.cfg))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
