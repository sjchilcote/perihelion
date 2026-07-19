"""tools/artgen/audit_clearance.py

Stop-the-line audit (director's order, 2026-07-13): every shipped l01-l03
walk-mask passed the plain portal-connectivity BFS, but that gate shipped
polygon 112 (l01) with only a ~13-unit bottom channel -- reachable, not
traversable. Re-check every shipped mask against the new clearance gate
(walkmask.check_polygon_portal_clearance) and report failures so they can be
regenerated (mask-only) or shipped mask-less (absence = walkable).

Usage:
    uv run python -m tools.artgen.audit_clearance [--level l01]
    uv run python -m tools.artgen.audit_clearance --fix   # mask-only rerun of failures
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1]))

import numpy as np
from PIL import Image

from tools.artgen.pilot_texture_lib import get_level
from tools.artgen.walkmask import check_polygon_portal_clearance, portal_points_px

PROGRESS_PATH = HERE / "full_run_progress.json"


def audit(level_filter: str | None = None) -> dict:
    progress = json.loads(PROGRESS_PATH.read_text())
    results = {}
    n_checked = 0
    n_fail = 0
    n_no_mask = 0
    for key, rec in progress.items():
        stem, polygon_key = key.split("/")
        if level_filter and stem != level_filter:
            continue
        if rec.get("status") != "accepted":
            continue
        if rec.get("mask_status") != "shipped":
            n_no_mask += 1
            continue
        idx = int(polygon_key.split("_")[1])
        texture_path = Path(rec["texture"])
        mask_path = texture_path.with_name(texture_path.stem + "_walkmask.png")
        if not mask_path.is_file():
            results[key] = dict(ok=False, reason="mask_status=shipped but file missing on disk")
            n_fail += 1
            continue
        walk_arr = np.asarray(Image.open(mask_path).convert("L")) > 127
        level = get_level(stem)
        pts = portal_points_px(stem, idx, level)
        res = check_polygon_portal_clearance(walk_arr, pts)
        n_checked += 1
        results[key] = res
        if not res["ok"]:
            n_fail += 1
    summary = dict(n_checked=n_checked, n_fail=n_fail, n_no_mask_skipped=n_no_mask,
                    failures=[k for k, v in results.items() if not v.get("ok", True)])
    return dict(summary=summary, results=results)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", type=str, default=None)
    ap.add_argument("--out", type=str, default=str(HERE / "clearance_audit.json"))
    args = ap.parse_args()

    report = audit(args.level)
    Path(args.out).write_text(json.dumps(report, indent=2, default=str))
    s = report["summary"]
    print(f"checked={s['n_checked']} fail={s['n_fail']} no_mask_skipped={s['n_no_mask_skipped']}")
    if s["failures"]:
        print("FAILURES:")
        for k in s["failures"]:
            print(f"  {k}")


if __name__ == "__main__":
    main()
