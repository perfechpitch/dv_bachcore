#!/usr/bin/env python
"""Check that a selected sequence exists in the generated seq plan."""

from __future__ import print_function

import argparse
import json
import os


def clean(value):
    if value is None:
        return ""
    return str(value).strip()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--plan", default="docs/seq/seq_plan.json")
    parser.add_argument("--seq")
    parser.add_argument(
        "--list-run-all",
        action="store_true",
        help="Print one run_all_sequences entry per line.",
    )
    parser.add_argument(
        "--run-all-only",
        action="store_true",
        help="Require --seq to be part of run_all_sequences.",
    )
    args = parser.parse_args()

    if not os.path.exists(args.plan):
        raise ValueError("Missing seq plan: %s. Run make seq_gen first." % args.plan)

    with open(args.plan, "r") as plan_file:
        plan = json.load(plan_file)

    sequences = plan.get("sequences", [])
    by_name = dict((seq.get("name"), seq) for seq in sequences)
    run_all_names = plan.get("run_all_sequences", [])
    unknown_run_all = [name for name in run_all_names if name not in by_name]
    if unknown_run_all:
        raise ValueError(
            "run_all_sequences contains unknown seq: %s"
            % ", ".join(unknown_run_all)
        )

    if args.list_run_all:
        if args.seq:
            raise ValueError("--list-run-all cannot be combined with --seq")
        for name in run_all_names:
            print(name)
        return 0

    seq_name = clean(args.seq)
    if seq_name == "":
        raise ValueError("SEQ is required")
    if seq_name in by_name:
        if args.run_all_only and seq_name not in run_all_names:
            valid = ", ".join(run_all_names)
            raise ValueError(
                "SEQ=%s is not a SEQ_ALL user sequence. Valid values: %s"
                % (seq_name, valid)
            )
        seq = by_name[seq_name]
        print("Selected seq %s found in seq plan as %s seq." % (seq_name, seq.get("source", "base")))
        return 0

    valid = ", ".join(seq.get("name", "") for seq in sequences)
    raise ValueError("SEQ=%s is not found in generated seq plan. Valid SEQ values: %s" % (seq_name, valid))


if __name__ == "__main__":
    raise SystemExit(main())
