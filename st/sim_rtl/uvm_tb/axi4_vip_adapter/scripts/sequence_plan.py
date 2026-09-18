"""Validate independent JSON traffic plans before emitting SystemVerilog.

Submit data, strobes, expected data and masks are transfer-relative (right
aligned), never bus-lane shifted. The sequence wrapper performs lane placement.
Legacy operations retain their schema and full-bus-word semantics. A legacy
``read`` inherits the most recent single-write mode, as the generated API does.
This module does not load data files or change the input object.
"""

import copy
import re


try:
    INTEGER_TYPES = (int, long)
    STRING_TYPES = (basestring,)
except NameError:
    INTEGER_TYPES = (int,)
    STRING_TYPES = (str,)

_DECIMAL = re.compile(r"^[0-9]+(?:_[0-9]+)*$")
_HEX = re.compile(r"^0[xX][0-9a-fA-F]+(?:_[0-9a-fA-F]+)*$")
_WRITE_MODES = (
    "FULL_ADDR_FULL_BYTE", "FULL_ADDR_SINGLE_BYTE", "SINGLE_ADDR_SINGLE_BYTE"
)
_SUBMIT_COMMON = {"op", "addr", "id", "size", "beats", "burst",
                  "expect_resp", "comment", "tr_gap"}
_LEGACY_COMMON = {"op", "addr", "comment", "tr_gap"}
_LEGACY_FIELDS = {
    "write": {"data", "strb"},
    "write_by_mode": {"data", "write_mode"},
    "read": {"expect"},
    "range_write": {"addr_stride", "count", "data_file", "data_start",
                    "readback", "write_mode"},
    "range_read": {"addr_stride", "count", "data_file", "data_start"},
}
_GAPS = {"", "MIN", "MID", "HIGH", "MAX", "FIXED", "RANDOM", "UNIFORM", "WEIGHTED"}


def _uint(value, label, width=None, minimum=0):
    if isinstance(value, bool):
        raise ValueError("%s must be an unsigned integer, not bool" % label)
    if isinstance(value, INTEGER_TYPES):
        result = value
    elif isinstance(value, STRING_TYPES):
        text = value.strip()
        if _HEX.match(text):
            result = int(text.replace("_", ""), 16)
        elif _DECIMAL.match(text):
            result = int(text.replace("_", ""), 10)
        else:
            raise ValueError("%s must be decimal or 0x hexadecimal, got %r" %
                             (label, value))
    else:
        raise ValueError("%s must be an unsigned integer, got %r" % (label, value))
    if result < minimum:
        raise ValueError("%s must be >= %d" % (label, minimum))
    if width is not None and result >= (1 << width):
        raise ValueError("%s must fit %d bits" % (label, width))
    return result


def _field(step, key, label, width=None, minimum=0):
    if key not in step:
        raise ValueError("%s requires %s" % (label, key))
    step[key] = _uint(step[key], "%s.%s" % (label, key), width, minimum)
    return step[key]


def _values(value, label, count, width):
    if not isinstance(value, list) or len(value) != count:
        raise ValueError("%s must be a list containing %d beats" % (label, count))
    return [_uint(item, "%s[%d]" % (label, idx), width)
            for idx, item in enumerate(value)]


def _window(addr, byte_count, addr_width, label):
    if addr + byte_count - 1 >= (1 << addr_width):
        raise ValueError("%s address window overflows %d bits" % (label, addr_width))


def _gap(value, label, text_only=False):
    """Match the generated helper: cycle-count or named-gap entry points."""
    if isinstance(value, bool):
        raise ValueError("%s must be a gap name or unsigned cycle count, not bool" % label)
    if isinstance(value, INTEGER_TYPES):
        cycles = _uint(value, label, 32)
        if text_only:
            if cycles:
                raise ValueError("%s requires a named gap (FIXED/MIN/MID/HIGH/MAX/"
                                 "RANDOM/UNIFORM/WEIGHTED); this legacy operation "
                                 "does not support numeric cycle gaps" % label)
            return ""
        return cycles
    if value is None:
        return ""
    if isinstance(value, STRING_TYPES):
        gap = value.strip().upper()
        gap = {"RAND": "RANDOM", "NONE": ""}.get(gap, gap)
        if gap in _GAPS:
            return gap
    raise ValueError("%s must be a valid gap name or unsigned cycle count" % label)


def _submit(step, profile, label):
    is_write = step["op"] == "submit_write"
    allowed = _SUBMIT_COMMON | ({"data", "strb"} if is_write else
                                {"expect", "expect_mask"})
    unknown = set(step) - allowed
    if unknown:
        raise ValueError("%s contains unknown fields: %s" %
                         (label, ", ".join(sorted(unknown))))
    addr = _field(step, "addr", label, profile["axi_addr_width"])
    _field(step, "id", label, profile["axi_id_width"])
    size = _field(step, "size", label)
    beats = _field(step, "beats", label, minimum=1)
    if size > profile["axi_data_width"].bit_length() - 4:
        raise ValueError("%s.size exceeds the bus byte width" % label)
    if beats > profile["max_burst_len"]:
        raise ValueError("%s.beats exceeds max_burst_len=%d" %
                         (label, profile["max_burst_len"]))
    burst = step.get("burst", "INCR")
    if burst != "INCR":
        raise ValueError("%s supports only burst=INCR" % label)
    step["burst"] = "INCR"
    step["expect_resp"] = _uint(step.get("expect_resp", 0),
                                label + ".expect_resp", 2)
    byte_count = 1 << size
    if addr % byte_count:
        raise ValueError("%s.addr must be aligned to SIZE (%d bytes)" %
                         (label, byte_count))
    if (beats > 1 and byte_count < profile["axi_data_width"] // 8 and
            not profile["support_narrow_burst"]):
        raise ValueError("%s narrow bursts require support_narrow_burst=true" % label)
    _window(addr, byte_count * beats, profile["axi_addr_width"], label)
    if (addr & 4095) + byte_count * beats > 4096:
        raise ValueError("%s burst crosses a 4KB boundary" % label)
    if is_write:
        if "data" not in step:
            raise ValueError("%s requires data" % label)
        step["data"] = _values(step["data"], label + ".data", beats, 8 * byte_count)
        step["strb"] = _values(step.get("strb", [(1 << byte_count) - 1] * beats),
                                label + ".strb", beats, byte_count)
    elif "expect" in step:
        step["expect"] = _values(step["expect"], label + ".expect", beats,
                                  8 * byte_count)
        step["expect_mask"] = _values(
            step.get("expect_mask", [(1 << (8 * byte_count)) - 1] * beats),
            label + ".expect_mask", beats, 8 * byte_count)
    elif "expect_mask" in step:
        raise ValueError("%s.expect_mask requires expect" % label)


def _legacy(step, profile, label, last_mode):
    op = step["op"]
    submit_only = set(step) & {"id", "size", "beats", "burst", "expect_resp", "expect_mask"}
    if submit_only:
        raise ValueError("%s.%s does not support %s; use submit_write/submit_read "
                         "for explicit ID, SIZE, burst, or response checks" %
                         (label, op, ", ".join(sorted(submit_only))))
    unknown = set(step) - (_LEGACY_COMMON | _LEGACY_FIELDS[op])
    if unknown:
        raise ValueError("%s.%s contains unsupported fields: %s" %
                         (label, op, ", ".join(sorted(unknown))))
    addr = _field(step, "addr", label, profile["axi_addr_width"])
    bus_bytes = profile["axi_data_width"] // 8
    if op == "write":
        mode = "FULL_ADDR_FULL_BYTE"
    elif op in ("write_by_mode", "range_write"):
        mode = step.get("write_mode", "FULL_ADDR_FULL_BYTE")
        if mode not in _WRITE_MODES:
            raise ValueError("%s.write_mode is unsupported: %r" % (label, mode))
        if op == "write_by_mode":
            step["write_mode"] = mode
    elif op == "read":
        mode = last_mode
    else:
        mode = "FULL_ADDR_FULL_BYTE"
    byte_window = mode == "SINGLE_ADDR_SINGLE_BYTE"
    if not byte_window and addr % bus_bytes:
        raise ValueError("%s.addr must be aligned to %d bus bytes" % (label, bus_bytes))
    _window(addr, bus_bytes, profile["axi_addr_width"], label)
    if op in ("write", "write_by_mode"):
        _field(step, "data", label, profile["axi_data_width"])
    for key in ("data", "expect"):
        if key in step:
            step[key] = _uint(step[key], "%s.%s" % (label, key),
                              profile["axi_data_width"])
    if "strb" in step:
        step["strb"] = _uint(step["strb"], label + ".strb", bus_bytes)
    if op in ("range_write", "range_read"):
        count = _field(step, "count", label, 32, 1)
        stride = _field(step, "addr_stride", label, profile["axi_addr_width"], 1)
        if op == "range_write":
            readback = step.get("readback", True)
            if not isinstance(readback, bool):
                raise ValueError("%s.readback must be a JSON boolean" % label)
            if readback and count > 1 and stride < bus_bytes:
                raise ValueError("%s overlapping write windows cannot use readback=true; "
                                 "increase addr_stride or use readback=false" % label)
        if not byte_window and stride % bus_bytes:
            raise ValueError("%s.addr_stride must be aligned to %d bus bytes" %
                             (label, bus_bytes))
        _window(addr + (count - 1) * stride, bus_bytes,
                profile["axi_addr_width"], label)
        if "data_start" in step:
            _field(step, "data_start", label, 32)
    return mode if op in ("write", "write_by_mode") else last_mode


def normalize_plan(plan):
    """Return a validated deep copy with unsigned numeric fields as Python ints.

    Profiles default to legacy DATA32/ADDR32/ID4/LEN8. ``max_burst_len`` defaults
    to min(16, 2**LEN_WIDTH); neither that default nor the test memory addresses
    establish a target NoC requirement. Existing metadata is preserved.
    """
    if not isinstance(plan, dict):
        raise ValueError("plan must be an object")
    result = copy.deepcopy(plan)
    for key, default in (("axi_data_width", 32), ("axi_addr_width", 32),
                         ("axi_id_width", 4), ("axi_len_width", 8)):
        result[key] = _uint(result.get(key, default), key, minimum=1)
    data_width = result["axi_data_width"]
    if data_width < 8 or data_width > 1024 or data_width & (data_width - 1):
        raise ValueError("axi_data_width must be a power of two from 8 through 1024")
    if result["axi_len_width"] > 8:
        raise ValueError("axi_len_width must be from 1 through 8 for AXI4")
    len_limit = 1 << result["axi_len_width"]
    result["max_burst_len"] = _uint(result.get("max_burst_len", min(16, len_limit)),
                                     "max_burst_len", minimum=1)
    if result["max_burst_len"] > len_limit:
        raise ValueError("max_burst_len exceeds AXI LEN width capacity")
    narrow = result.get("support_narrow_burst", False)
    if not isinstance(narrow, bool):
        raise ValueError("support_narrow_burst must be a JSON boolean")
    result["support_narrow_burst"] = narrow
    sequences = result.get("sequences", [])
    if not isinstance(sequences, list):
        raise ValueError("sequences must be a list")
    for seq_idx, seq in enumerate(sequences):
        if not isinstance(seq, dict) or not isinstance(seq.get("steps", []), list):
            raise ValueError("sequences[%d] must be an object with a steps list" % seq_idx)
        if "seq_gap" in seq:
            seq["seq_gap"] = _gap(seq["seq_gap"], "sequences[%d].seq_gap" % seq_idx)
        last_mode = "FULL_ADDR_FULL_BYTE"
        for idx, step in enumerate(seq.get("steps", [])):
            label = "sequences[%d].steps[%d]" % (seq_idx, idx)
            if not isinstance(step, dict):
                raise ValueError("%s must be an object" % label)
            op = step.get("op")
            if "tr_gap" in step:
                step["tr_gap"] = _gap(step["tr_gap"], label + ".tr_gap",
                                       op in ("write_by_mode", "range_write", "range_read"))
            if op in ("submit_write", "submit_read"):
                _submit(step, result, label)
            elif op == "await_all":
                if set(step) - {"op", "comment", "tr_gap"}:
                    raise ValueError("%s.await_all contains unknown fields" % label)
            elif op in ("write", "write_by_mode", "read", "range_write", "range_read"):
                last_mode = _legacy(step, result, label, last_mode)
            else:
                raise ValueError("%s has unsupported op: %r" % (label, op))
    return result
