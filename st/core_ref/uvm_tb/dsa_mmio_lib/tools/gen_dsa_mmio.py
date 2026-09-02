#!/usr/bin/env python3

import argparse
import json
import os
import sys


def die(msg):
    print("ERROR: %s" % msg, file=sys.stderr)
    sys.exit(1)


def to_int(value, name):
    if isinstance(value, bool):
        die("%s must be integer" % name)
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        try:
            return int(value, 0)
        except ValueError:
            pass
    die("%s invalid integer: %r" % (name, value))


def hex32(value):
    return "32'h%08X" % (value & 0xffffffff)


def load_desc(path):
    try:
        with open(path, "r") as f:
            desc = json.load(f)
    except FileNotFoundError:
        die("description file not found: %s" % path)
    except json.JSONDecodeError as e:
        die("JSON parse failed: %s" % e)

    if not isinstance(desc.get("dsa"), str) or not desc["dsa"]:
        die("missing dsa")
    return desc


def parse_field(reg_name, item):
    name = item.get("name")
    if not isinstance(name, str) or not name:
        die("%s has field without name" % reg_name)

    msb = to_int(item.get("msb"), "%s.%s.msb" % (reg_name, name))
    lsb = to_int(item.get("lsb"), "%s.%s.lsb" % (reg_name, name))
    if not 0 <= lsb <= msb < 32:
        die("%s.%s invalid bit range" % (reg_name, name))

    return {
        "name": name,
        "lower": name.lower(),
        "msb": msb,
        "lsb": lsb,
        "access": item.get("access", "RW")
    }


def parse_register(item):
    name = item.get("name")
    if not isinstance(name, str) or not name:
        die("register missing name")

    reg = {
        "name": name,
        "lower": name.lower(),
        "addr": to_int(item.get("addr"), "%s.addr" % name),
        "reset": to_int(item.get("reset", 0), "%s.reset" % name),
        "count": to_int(item.get("count", 1), "%s.count" % name),
        "stride": to_int(item.get("stride", 4), "%s.stride" % name),
        "trigger": bool(item.get("trigger", False)),
        "fields": [parse_field(name, x) for x in item.get("fields", [])]
    }

    if reg["addr"] % 4:
        die("%s address must be 4-byte aligned" % name)
    if reg["count"] <= 0 or reg["stride"] <= 0:
        die("%s count/stride must be > 0" % name)
    if not reg["fields"]:
        die("%s has no fields" % name)

    used = 0
    for field in reg["fields"]:
        width = field["msb"] - field["lsb"] + 1
        mask = ((1 << width) - 1) << field["lsb"]
        if used & mask:
            die("%s has overlapping fields" % name)
        used |= mask

    return reg


def parse_custom_window(item):
    name = item.get("name")
    if not isinstance(name, str) or not name:
        die("custom_window missing name")

    addr = to_int(item.get("addr"), "%s.addr" % name)
    if addr % 4:
        die("%s address must be 4-byte aligned" % name)

    return {"name": name, "lower": name.lower(), "addr": addr}


def parse_state_array(item):
    name = item.get("name")
    if not isinstance(name, str) or not name:
        die("state_array missing name")

    count = to_int(item.get("count"), "%s.count" % name)
    width = to_int(item.get("width"), "%s.width" % name)
    reset = to_int(item.get("reset", 0), "%s.reset" % name)

    if count <= 0 or width <= 0:
        die("%s count/width must be > 0" % name)

    return {
        "name": name.lower(),
        "count": count,
        "width": width,
        "reset": reset
    }


def parse_internal_state(item):
    name = item.get("name")
    if not isinstance(name, str) or not name:
        die("internal_state missing name")

    width = to_int(item.get("width"), "%s.width" % name)
    reset = to_int(item.get("reset", 0), "%s.reset" % name)
    if width <= 0:
        die("%s width must be > 0" % name)

    return {"name": name.lower(), "width": width, "reset": reset}


def find_field(reg, name):
    for field in reg["fields"]:
        if field["name"] == name:
            return field
    die("register %s has no field %s" % (reg["name"], name))


def parse_exec_config(raw, reg_map):
    if raw is None:
        return None
    if not isinstance(raw, dict):
        die("exec_config must be object")

    index_reg_name = raw.get("index_register")
    mask_reg_name = raw.get("mask_register")
    if index_reg_name not in reg_map:
        die("exec_config index register not found: %s" % index_reg_name)
    if mask_reg_name not in reg_map:
        die("exec_config mask register not found: %s" % mask_reg_name)

    index_reg = reg_map[index_reg_name]
    mask_reg = reg_map[mask_reg_name]
    return {
        "index_reg": index_reg,
        "index_field": find_field(index_reg, raw.get("index_field")),
        "mask_reg": mask_reg,
        "mask_field": find_field(mask_reg, raw.get("mask_field"))
    }


def parse_param_group(item, reg_map, exec_config):
    if exec_config is None:
        die("param_groups require exec_config")

    name = item.get("name")
    dynamic_name = item.get("dynamic")
    static_name = item.get("static")
    mask_bit = to_int(item.get("mask_bit"), "%s.mask_bit" % name)

    if dynamic_name not in reg_map or static_name not in reg_map:
        die("%s dynamic/static register not found" % name)

    dynamic = reg_map[dynamic_name]
    static = reg_map[static_name]

    if dynamic["count"] != 1 or static["count"] <= 1:
        die("%s invalid dynamic/static count" % name)

    dyn_fields = [(x["name"], x["msb"], x["lsb"]) for x in dynamic["fields"]]
    sta_fields = [(x["name"], x["msb"], x["lsb"]) for x in static["fields"]]
    if dyn_fields != sta_fields:
        die("%s dynamic/static fields differ" % name)

    mask_width = exec_config["mask_field"]["msb"] - exec_config["mask_field"]["lsb"] + 1
    if not 0 <= mask_bit < mask_width:
        die("%s invalid mask_bit=%d" % (name, mask_bit))

    return {
        "name": name.lower(),
        "type": "%s_param_s" % name.lower(),
        "mask_bit": mask_bit,
        "dynamic": dynamic,
        "static": static
    }


def parse_static_param(item, reg_map, exec_config):
    if exec_config is None:
        die("static_params require exec_config")

    name = item.get("name")
    reg_name = item.get("register")
    if reg_name not in reg_map:
        die("%s register not found: %s" % (name, reg_name))

    reg = reg_map[reg_name]
    if reg["count"] <= 1:
        die("%s static register must have count>1" % name)

    return {
        "name": name.lower(),
        "type": "%s_param_s" % name.lower(),
        "register": reg
    }


def validate_names(registers, custom_windows):
    names = set()
    for item in registers + custom_windows:
        if item["name"] in names:
            die("duplicate MMIO object name: %s" % item["name"])
        names.add(item["name"])


def validate_exec_banks(param_groups, static_params, exec_config):
    if exec_config is None:
        return

    field = exec_config["index_field"]
    max_count = 1 << (field["msb"] - field["lsb"] + 1)

    for group in param_groups:
        if group["static"]["count"] > max_count:
            die("%s static bank exceeds CONFIG_IDX capacity" % group["name"])

    for param in static_params:
        if param["register"]["count"] > max_count:
            die("%s static bank exceeds CONFIG_IDX capacity" % param["name"])


def struct_members(reg):
    fields = sorted(reg["fields"], key=lambda x: x["msb"], reverse=True)
    members = []
    current = 31

    for field in fields:
        if field["msb"] < current:
            members.append({
                "lower": "reserved_%d_%d" % (current, field["msb"] + 1),
                "msb": current,
                "lsb": field["msb"] + 1
            })
        members.append(field)
        current = field["lsb"] - 1

    if current >= 0:
        members.append({
            "lower": "reserved_%d_0" % current,
            "msb": current,
            "lsb": 0
        })

    return members


def emit_field(out, field, indent="    "):
    width = field["msb"] - field["lsb"] + 1
    if width == 1:
        out.append("%sbit %s;" % (indent, field["lower"]))
    else:
        out.append("%sbit [%d:0] %s;" % (indent, width - 1, field["lower"]))


def emit_decl(dsa, registers, custom_windows, state_arrays,
              internal_states, param_groups, static_params, exec_config):
    out = []

    for state in state_arrays:
        out.append("bit [%d:0] %s[%d];" %
                   (state["width"] - 1, state["name"], state["count"]))

    for state in internal_states:
        out.append("bit [%d:0] %s;" %
                   (state["width"] - 1, state["name"]))

    for window in custom_windows:
        out.append("localparam bit [31:0] %s_BASE_ADDR = %s;" %
                   (window["name"], hex32(window["addr"])))

    for reg in registers:
        out.append("localparam bit [31:0] %s_BASE_ADDR = %s;" %
                   (reg["name"], hex32(reg["addr"])))

        if reg["count"] > 1:
            out.append("localparam int %s_COUNT = %d;" %
                       (reg["name"], reg["count"]))
            out.append("localparam bit [31:0] %s_STRIDE = %s;" %
                       (reg["name"], hex32(reg["stride"])))
            out.append("localparam bit [31:0] %s_END_ADDR = %s;" %
                       (reg["name"],
                        hex32(reg["addr"] + (reg["count"] - 1) * reg["stride"])))

        out.append("typedef struct packed {")
        for field in struct_members(reg):
            emit_field(out, field)
        out.append("} %s_field_s;" % reg["lower"])

        suffix = "[%d]" % reg["count"] if reg["count"] > 1 else ""
        out.append("%s_field_s %s%s;" % (reg["lower"], reg["lower"], suffix))
        out.append("bit [31:0] %s_val%s;" % (reg["lower"], suffix))

    if exec_config is None:
        return out

    if param_groups:
        out.append("typedef enum bit {PARAM_STATIC, PARAM_DYNAMIC} param_src_e;")

    for group in param_groups:
        out.append("typedef struct {")
        for field in group["dynamic"]["fields"]:
            emit_field(out, field)
        out.append("    param_src_e src;")
        out.append("} %s;" % group["type"])

    for param in static_params:
        out.append("typedef struct {")
        for field in param["register"]["fields"]:
            emit_field(out, field)
        out.append("} %s;" % param["type"])

    field = exec_config["index_field"]
    index_width = field["msb"] - field["lsb"] + 1

    out.append("typedef struct {")
    out.append("    bit [%d:0] config_idx;" % (index_width - 1))
    for group in param_groups:
        out.append("    %s %s;" % (group["type"], group["name"]))
    for param in static_params:
        out.append("    %s %s;" % (param["type"], param["name"]))
    out.append("} %s_exec_param_s;" % dsa)
    out.append("%s_exec_param_s exec_param;" % dsa)
    out.append("bit trigger_pending;")

    return out


def emit_reset(registers, state_arrays, internal_states,
               param_groups, static_params, exec_config):
    out = []

    for state in state_arrays:
        value = "'0" if state["reset"] == 0 else "%d'h%X" % (
            state["width"], state["reset"])
        out.append("foreach(%s[i]) %s[i] = %s;" %
                   (state["name"], state["name"], value))

    for state in internal_states:
        value = "'0" if state["reset"] == 0 else "%d'h%X" % (
            state["width"], state["reset"])
        out.append("%s = %s;" % (state["name"], value))

    for reg in registers:
        if reg["count"] == 1:
            out.append("%s_val = %s;" % (reg["lower"], hex32(reg["reset"])))
            out.append("%s = %s_val;" % (reg["lower"], reg["lower"]))
        else:
            out += [
                "foreach(%s[i]) begin" % reg["lower"],
                "    %s_val[i] = %s;" % (reg["lower"], hex32(reg["reset"])),
                "    %s[i] = %s_val[i];" % (reg["lower"], reg["lower"]),
                "end"
            ]

    if exec_config is None:
        return out

    out.append("exec_param.config_idx = '0;")

    for group in param_groups:
        for field in group["dynamic"]["fields"]:
            out.append("exec_param.%s.%s = '0;" %
                       (group["name"], field["lower"]))
        out.append("exec_param.%s.src = PARAM_STATIC;" % group["name"])

    for param in static_params:
        for field in param["register"]["fields"]:
            out.append("exec_param.%s.%s = '0;" %
                       (param["name"], field["lower"]))

    out.append("trigger_pending = 1'b0;")
    return out


def reg_match(reg):
    if reg["count"] == 1:
        return "addr == %s_BASE_ADDR" % reg["name"]

    return (
        "(addr >= %s_BASE_ADDR) && (addr <= %s_END_ADDR) && "
        "(((addr - %s_BASE_ADDR) %% %s_STRIDE) == 0)"
    ) % (reg["name"], reg["name"], reg["name"], reg["name"])


def emit_write(registers):
    out = []

    for reg in registers:
        out.append("if(!mmio_hit && (%s)) begin" % reg_match(reg))

        if reg["count"] == 1:
            out.append("    %s_val = data;" % reg["lower"])
            out.append("    %s = data;" % reg["lower"])
        else:
            out.append("    int unsigned reg_idx;")
            out.append("    reg_idx = (addr - %s_BASE_ADDR) / %s_STRIDE;" %
                       (reg["name"], reg["name"]))
            out.append("    %s_val[reg_idx] = data;" % reg["lower"])
            out.append("    %s[reg_idx] = data;" % reg["lower"])

        if reg["trigger"]:
            out.append("    inst_trigger = 1'b1;")

        out.append("    mmio_hit = 1'b1;")
        out.append("end")

    return out


def emit_read(registers):
    out = []

    for reg in registers:
        out.append("if(!mmio_hit && (%s)) begin" % reg_match(reg))

        if reg["count"] == 1:
            out.append("    data = %s_val;" % reg["lower"])
        else:
            out.append("    int unsigned reg_idx;")
            out.append("    reg_idx = (addr - %s_BASE_ADDR) / %s_STRIDE;" %
                       (reg["name"], reg["name"]))
            out.append("    data = %s_val[reg_idx];" % reg["lower"])

        out.append("    mmio_hit = 1'b1;")
        out.append("end")

    return out


def emit_resolve(param_groups, static_params, exec_config):
    if exec_config is None:
        return []

    out = []
    mask_reg = exec_config["mask_reg"]["lower"]
    mask_field = exec_config["mask_field"]["lower"]
    index_reg = exec_config["index_reg"]["lower"]
    index_field = exec_config["index_field"]["lower"]

    out.append("exec_param.config_idx = %s.%s;" % (index_reg, index_field))

    for group in param_groups:
        dst = "exec_param.%s" % group["name"]
        dynamic = group["dynamic"]["lower"]
        static = group["static"]["lower"]

        out.append("if(%s.%s[%d]) begin" %
                   (mask_reg, mask_field, group["mask_bit"]))
        for field in group["dynamic"]["fields"]:
            out.append("    %s.%s = %s.%s;" %
                       (dst, field["lower"], dynamic, field["lower"]))
        out.append("    %s.src = PARAM_DYNAMIC;" % dst)
        out.append("end")
        out.append("else begin")
        for field in group["dynamic"]["fields"]:
            out.append("    %s.%s = %s[exec_param.config_idx].%s;" %
                       (dst, field["lower"], static, field["lower"]))
        out.append("    %s.src = PARAM_STATIC;" % dst)
        out.append("end")

    for param in static_params:
        dst = "exec_param.%s" % param["name"]
        src = param["register"]["lower"]
        for field in param["register"]["fields"]:
            out.append("%s.%s = %s[exec_param.config_idx].%s;" %
                       (dst, field["lower"], src, field["lower"]))

    return out


def write_file(path, src, lines):
    with open(path, "w") as f:
        f.write("// AUTO-GENERATED from %s. DO NOT EDIT.\n" % src)
        if lines:
            f.write("\n%s\n" % "\n".join(lines))
    print("wrote %s" % path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("desc")
    parser.add_argument("-o", "--out-dir")
    args = parser.parse_args()

    desc = load_desc(args.desc)
    dsa = desc["dsa"].lower()

    registers = [parse_register(x) for x in desc.get("registers", [])]
    custom_windows = [parse_custom_window(x) for x in desc.get("custom_windows", [])]
    state_arrays = [parse_state_array(x) for x in desc.get("state_arrays", [])]
    internal_states = [parse_internal_state(x) for x in desc.get("internal_states", [])]

    reg_map = {x["name"]: x for x in registers}
    if len(reg_map) != len(registers):
        die("duplicate register name")

    validate_names(registers, custom_windows)

    exec_config = parse_exec_config(desc.get("exec_config"), reg_map)

    param_groups = [
        parse_param_group(x, reg_map, exec_config)
        for x in desc.get("param_groups", [])
    ]
    static_params = [
        parse_static_param(x, reg_map, exec_config)
        for x in desc.get("static_params", [])
    ]

    validate_exec_banks(param_groups, static_params, exec_config)

    if exec_config is None and (param_groups or static_params):
        die("param_groups/static_params require exec_config")

    out_dir = args.out_dir or os.path.normpath(os.path.join(
        os.path.dirname(os.path.abspath(args.desc)), "..", "generated"))
    os.makedirs(out_dir, exist_ok=True)

    src = os.path.basename(args.desc)
    prefix = "%s_mmio" % dsa

    outputs = {
        "decl": emit_decl(
            dsa, registers, custom_windows, state_arrays, internal_states,
            param_groups, static_params, exec_config),
        "reset": emit_reset(
            registers, state_arrays, internal_states,
            param_groups, static_params, exec_config),
        "write": emit_write(registers),
        "read": emit_read(registers),
        "resolve": emit_resolve(param_groups, static_params, exec_config)
    }

    for kind, lines in outputs.items():
        write_file(
            os.path.join(out_dir, "%s_%s_auto.svh" % (prefix, kind)),
            src,
            lines
        )


if __name__ == "__main__":
    main()