#!/usr/bin/env python
"""Convert a VIP cfg workbook or legacy JSON cfg into JSON."""

from __future__ import print_function

import argparse
import json
import os
import sys

from vip_workbook import load_vip_cfg


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--cfg", default="docs/vip/vip_cfg.xlsx::FINAL_FEATURE")
    parser.add_argument("--out", default="tb/generated/axi4_vip_cfg.json")
    args = parser.parse_args()

    cfg = load_vip_cfg(args.cfg)
    out_dir = os.path.dirname(args.out)
    if out_dir and not os.path.isdir(out_dir):
        os.makedirs(out_dir)
    with open(args.out, "w") as out_file:
        json.dump(cfg, out_file, indent=2)
        out_file.write("\n")
    print("Generated %s from %s" % (args.out, args.cfg))
    return 0


def cli_main():
    try:
        return main()
    except (IOError, OSError, ValueError) as err:
        print("ERROR: %s" % err, file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(cli_main())
