"""One reviewed workbook baseline for runners and deployment (Python 3.6+).

Updating this manifest is an explicit configuration change, never a test side
effect. Standalone rollback copies retain the exact manifest used at deployment.
"""
import json
from pathlib import Path
import re

WORKBOOK = "docs/vip/vip_cfg.xlsx"
BASELINE_MANIFEST = "docs/vip/workbook_baseline.json"
_SAVED_MANIFEST = Path(__file__).resolve().with_name("workbook_baseline.json")
BASELINE_PATH = (_SAVED_MANIFEST if _SAVED_MANIFEST.is_file() else
                 Path(__file__).resolve().parents[1] / BASELINE_MANIFEST)


def load_baseline(path=None):
    with Path(path or BASELINE_PATH).open("r", encoding="utf-8") as stream:
        baseline = json.load(stream)
    if not isinstance(baseline, dict) or baseline.get("version") != 1:
        raise ValueError("workbook baseline must have version: 1")
    if baseline.get("workbook") != WORKBOOK:
        raise ValueError("workbook baseline has an unexpected workbook path")
    for key in ("current_sha256", "previous_sha256"):
        value = baseline.get(key)
        if not isinstance(value, str) or not re.fullmatch(r"[0-9a-f]{64}", value):
            raise ValueError("workbook baseline has invalid " + key)
    for key in ("backup_git_revision", "backup_git_path", "authorization"):
        if not isinstance(baseline.get(key), str) or not baseline[key].strip():
            raise ValueError("workbook baseline needs audit field " + key)
    return baseline


BASELINE_SHA = load_baseline()["current_sha256"]
