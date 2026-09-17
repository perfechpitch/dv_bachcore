"""Deterministic sequence test plans; addresses are a test-only memory map.

No target NoC address map or maximum business burst length was supplied.
16 beats and a combined 128 transaction window are test assumptions.
"""

import json
from pathlib import Path


def payload(tag, beat=0):
    # Distinct nonzero bytes in every lane, including bits 255:248.
    return sum(((tag + beat * 37 + lane * 11) % 255 + 1) << (8 * lane)
               for lane in range(32))


def plan():
    steps = []
    # Exactly 128 submissions before the first wait, mixed 1/2/4/16 beats.
    for idx in range(128):
        beats = (1, 2, 4, 16)[idx % 4]
        steps.append({"op": "submit_write", "addr": hex(0x10000 + idx * 512),
                      "id": idx, "size": 5, "beats": beats,
                      "data": [hex(payload(idx, beat)) for beat in range(beats)]})
    steps.append({"op": "await_all"})
    for idx in range(128):
        beats = (1, 2, 4, 16)[idx % 4]
        steps.append({"op": "submit_read", "addr": hex(0x10000 + idx * 512),
                      "id": idx, "size": 5, "beats": beats,
                      "expect": [hex(payload(idx, beat)) for beat in range(beats)]})
    steps.append({"op": "await_all"})
    # 64 read + 64 write independent addresses in one submission batch.
    for idx in range(64):
        steps.append({"op": "submit_read", "addr": hex(0x10000 + idx * 512),
                      "id": idx % 8, "size": 5, "beats": 1,
                      "expect": [hex(payload(idx))]})
        steps.append({"op": "submit_write", "addr": hex(0x30000 + idx * 32),
                      "id": idx % 8, "size": 5, "beats": 1,
                      "data": [hex(payload(128 + idx))]})
    steps.append({"op": "await_all"})
    for ordinal in range(128):
        idx = ordinal % 64
        steps.append({"op": "submit_read", "addr": hex(0x30000 + idx * 32),
                      "id": idx % 8, "size": 5, "beats": 1,
                      "expect": [hex(payload(128 + idx))]})
    steps.append({"op": "await_all"})
    return {
        "description": "TEST ONLY: 0x10000..0x307ff sparse RAM; 16 beats and combined 128 are assumptions, not confirmed NoC requirements.",
        "axi_data_width": 256, "axi_addr_width": 32, "axi_id_width": 8,
        "axi_len_width": 4, "max_burst_len": 16,
        "sequences": [{"name": "axi4_128_submit_seq", "steps": steps}],
    }


def lane_plan():
    original = payload(73)
    replacement = 0x89abcdef
    updated = original
    for byte in (1, 3):
        updated &= ~(0xff << (8 * (28 + byte)))
        updated |= ((replacement >> (8 * byte)) & 0xff) << (8 * (28 + byte))
    steps = [
        {"op": "submit_write", "addr": "0x5000", "id": 201, "size": 5,
         "beats": 1, "data": [hex(original)]},
        {"op": "await_all"},
        {"op": "submit_write", "addr": "0x501c", "id": 202, "size": 2,
         "beats": 1, "data": [hex(replacement)], "strb": ["0xa"]},
        {"op": "await_all"},
        {"op": "submit_write", "addr": "0x5000", "id": 202, "size": 5,
         "beats": 1, "data": [hex(payload(74))], "strb": [0]},
        {"op": "await_all"},
        {"op": "submit_read", "addr": "0x5000", "id": 203, "size": 5,
         "beats": 1, "expect": [hex(updated)]},
        {"op": "submit_read", "addr": "0x501c", "id": 204, "size": 2,
         "beats": 1, "expect": [hex(updated >> 224)]},
        {"op": "submit_read", "addr": "0x501f", "id": 205, "size": 0,
         "beats": 1, "expect": ["0x89"]},
        {"op": "submit_read", "addr": "0x501c", "id": 206, "size": 2,
         "beats": 1, "expect": [hex(((updated >> 224) & 0xffff) | 0x12340000)],
         "expect_mask": ["0xffff"]},
        {"op": "await_all"},
        {"op": "write_by_mode", "addr": "0x505f", "data": hex(payload(181)),
         "write_mode": "SINGLE_ADDR_SINGLE_BYTE"},
        {"op": "read", "addr": "0x505f", "expect": hex(payload(181))},
        {"op": "write_by_mode", "addr": "0x50a0", "data": hex(payload(182)),
         "write_mode": "FULL_ADDR_SINGLE_BYTE"},
        {"op": "read", "addr": "0x50a0", "expect": hex(payload(182))},
    ]
    result = plan()
    result["description"] = "TEST ONLY: RAM 0x5000..0x50bf; DATA256 narrow single beats and byte lanes, not an actual NoC address map."
    result["sequences"] = [{"name": "axi4_lane_seq", "steps": steps}]
    return result


def mixed_plan():
    result = plan()
    steps = []
    for idx, beats in enumerate((1, 2, 4, 16)):
        steps.append({"op": "submit_write", "addr": hex(0x1000 + idx * 512),
                      "id": idx % 2, "size": 5, "beats": beats,
                      "data": [hex(payload(210 + idx, beat)) for beat in range(beats)]})
    steps.append({"op": "await_all"})
    for idx, beats in enumerate((1, 2, 4, 16)):
        steps.append({"op": "submit_read", "addr": hex(0x1000 + idx * 512),
                      "id": 200 + idx, "size": 5, "beats": beats,
                      "expect": [hex(payload(210 + idx, beat)) for beat in range(beats)]})
        steps.append({"op": "submit_write", "addr": hex(0x2000 + idx * 32),
                      "id": 255, "size": 5, "beats": 1,
                      "data": [hex(payload(220 + idx))]})
    steps.append({"op": "await_all"})
    for idx in range(4):
        steps.append({"op": "submit_read", "addr": hex(0x2000 + idx * 32),
                      "id": 255, "size": 5, "beats": 1,
                      "expect": [hex(payload(220 + idx))]})
    steps.append({"op": "await_all"})
    result["description"] = "TEST ONLY: RAM 0x1000..0x207f; 1/2/4/16 INCR beats plus mixed single reads/writes. 16 beats is a test assumption."
    result["sequences"] = [{"name": "axi4_mixed_burst_seq", "steps": steps}]
    return result


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", required=True)
    parser.add_argument("--case", choices=["burst128", "lanes", "mixed"], default="burst128")
    args = parser.parse_args()
    plans = {"burst128": plan, "lanes": lane_plan, "mixed": mixed_plan}
    Path(args.out).write_text(json.dumps(plans[args.case](), indent=2) + "\n")
