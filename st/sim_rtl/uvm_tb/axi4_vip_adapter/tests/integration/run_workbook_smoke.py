#!/usr/bin/env python3
"""Generate from the reviewed workbook in one copy; simulate its JSON in another."""
import argparse
import json
import os
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts"))
from run_isolated import BASELINE_SHA, WORKBOOK, digest, prepare, run_bounded
from vip_workbook import load_vip_cfg
from xls_table import read_workbook


def single_beat_plan(cfg):
    """Match the merged bus width without assuming an unspecified burst maximum."""
    axi = cfg['axi']
    byte_count = axi['data_width'] // 8
    size = byte_count.bit_length() - 1
    if byte_count != 1 << size:
        raise ValueError('workbook smoke needs a power-of-two byte width')
    steps = []
    reads = []
    for index in range(2):
        # Exercise every byte lane, including the upper DATA256 bits. Addresses
        # are scratch RAM locations and do not imply a confirmed NoC address map.
        data = '0x' + ''.join('{:02x}'.format((lane * 13 + 37 + index * 71) % 256)
                              for lane in range(byte_count))
        common = {'addr': hex(0x1000 + index * byte_count),
                  'id': (1 << axi['id_width']) - 1 - index,
                  'size': size, 'beats': 1, 'burst': 'INCR'}
        steps.append(dict(common, op='submit_write', data=[data]))
        reads.append(dict(common, op='submit_read', expect=[data]))
    steps += [{'op': 'await_all'}] + reads + [{'op': 'await_all'}]
    return {'description': 'Workbook-generated configuration smoke; aligned full-width single beats only.',
            'axi_data_width': axi['data_width'], 'axi_addr_width': axi['addr_width'],
            'axi_id_width': axi['id_width'], 'axi_len_width': axi['len_width'],
            'max_burst_len': axi['max_burst_len'],
            'sequences': [{'name': 'axi4_workbook_single_beat_seq', 'steps': steps}]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work-dir", type=Path, required=True)
    args = parser.parse_args()
    work = args.work_dir.resolve()
    if work == ROOT or ROOT in work.parents:
        parser.error("--work-dir must be outside the source project")
    work.mkdir(parents=True, exist_ok=False)
    result = {"status": "failed", "source": str(ROOT), "work": str(work)}
    try:
        if digest(ROOT / WORKBOOK) != BASELINE_SHA:
            raise ValueError("source workbook differs from the reviewed baseline")
        expected_tables = read_workbook(str(ROOT / WORKBOOK))
        expected_cfg = load_vip_cfg(str(ROOT / WORKBOOK))
        chain = work / "configuration_chain"
        chain.mkdir()
        prepare(ROOT, chain)
        env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        with (work / "configuration_chain.log").open("w") as log:
            run_bounded(["make", "--no-print-directory", "vip_cfg"], chain, env, 120, log)
        generated = chain / "tb/generated/axi4_vip_cfg.json"
        actual_cfg = json.loads(generated.read_text())
        if actual_cfg != expected_cfg:
            raise ValueError("generated JSON differs from the reviewed FINAL values")
        if read_workbook(str(chain / WORKBOOK)) != expected_tables:
            raise ValueError("configuration chain changed reviewed sheet semantics")
        result.update({"generated_profile": str(generated),
                       "generated_profile_sha256": digest(generated),
                       "chain_workbook_sha256": digest(chain / WORKBOOK),
                       "chain_semantics_unchanged": True})
        plan = work / 'workbook_single_beat_plan.json'
        plan.write_text(json.dumps(single_beat_plan(actual_cfg), indent=2) + '\n')
        result.update({'plan': str(plan), 'plan_sha256': digest(plan),
                       'data_width': actual_cfg['axi']['data_width'],
                       'max_burst_len': actual_cfg['axi']['max_burst_len'],
                       'traffic_beats_per_transaction': 1})
        command = [sys.executable, str(ROOT / "scripts/run_isolated.py"),
                   "--work-root", str(work / "simulation"),
                   "--profile", str(generated), "--plan", str(plan),
                   "--seq", "axi4_workbook_single_beat_seq", "--irq"]
        with (work / "smoke.log").open("w") as log:
            run_bounded(command, ROOT, env, 300, log)
        reports = list((work / "simulation").glob("axi4_isolated_*/isolated_result.json"))
        if len(reports) != 1:
            raise ValueError("expected exactly one isolated simulation report")
        smoke = json.loads(reports[0].read_text())
        if smoke["status"] != "passed" or smoke["profile_sha256"] != digest(generated):
            raise ValueError("smoke did not use the workbook-generated JSON")
        if smoke['plan_sha256'] != digest(plan):
            raise ValueError('smoke did not use the matching single-beat plan')
        output = (work / "smoke.log").read_text()
        axi = actual_cfg['axi']
        widths = 'ADDR_WIDTH={} DATA_WIDTH={} STRB_WIDTH={} ID_WIDTH={} LEN_WIDTH={}'.format(
            axi['addr_width'], axi['data_width'], axi['data_width'] // 8,
            axi['id_width'], axi['len_width'])
        if widths not in output:
            raise ValueError('simulated widths differ from the workbook-generated JSON')
        count = re.search(r"AXI_CHECKER_SUMMARY errors=0 AW=(\d+) W=(\d+) B=(\d+) AR=(\d+) R=(\d+)", output)
        if not count or tuple(map(int, count.groups())) != (3, 3, 3, 2, 2):
            raise ValueError("workbook-generated single-beat IRQ handshake counts differ")
        if "AXI_CLOCK_MEASURED period_ns=10.000000 samples=10" not in output:
            raise ValueError("workbook metadata changed the default simulation clock")
        result.update({"status": "passed", "smoke_report": str(reports[0]),
                       "clock_ns": 10.0, "aw_w_b_ar_r": [3, 3, 3, 2, 2]})
    except BaseException as error:
        result["error"] = str(error)
        raise
    finally:
        try:
            result["source_workbook_sha256"] = digest(ROOT / WORKBOOK)
            if result["source_workbook_sha256"] != BASELINE_SHA:
                result["status"] = "failed"
                result["integrity_error"] = "source workbook changed"
        except OSError as error:
            result["status"] = "failed"
            result["integrity_error"] = str(error)
        (work / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    if result["status"] != "passed":
        raise ValueError(result.get("integrity_error", "workbook smoke failed"))
    print("WORKBOOK_CHAIN_SMOKE_PASS " + str(work / "result.json"), flush=True)


if __name__ == "__main__":
    main()
