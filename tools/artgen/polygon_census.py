"""tools/artgen/polygon_census.py

Census of polygon `kind` values across the campaign + vigil level files (the
1,815-polygon universe measured in ARTSTYLE_DIRECTION.md: l01..l10 + vigil.json;
the manifest campaign.json and the demo/test fixtures marathon_arrival.json,
maze_demo.json, smoke_4polygon.json are NOT part of the shipped station and are
excluded).

For each `kind`, reports polygon count and a histogram of centered-bbox sizes
in world units (polygons are irregular polygons; the bbox is what a bespoke
rectangular texture would need to cover).

Usage: uv run python tools/artgen/polygon_census.py [--json-only]
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

from perihelion.levels import load_level  # noqa: E402

LEVEL_FILES = [f"l{n:02d}" for n in range(1, 11)] + ["vigil"]


def census() -> dict:
    by_kind: dict[str, dict] = defaultdict(lambda: dict(
        count=0, per_level=defaultdict(int), bboxes=[]))
    total_polygons = 0
    for stem in LEVEL_FILES:
        path = ROOT / "levels" / f"{stem}.json"
        level = load_level(path)
        for ri, verts in enumerate(level.polygon_verts):
            kind = level.polygon_kinds[ri]
            xs = [v[0] for v in verts]
            ys = [v[1] for v in verts]
            w = max(xs) - min(xs)
            h = max(ys) - min(ys)
            rec = by_kind[kind]
            rec["count"] += 1
            rec["per_level"][stem] += 1
            rec["bboxes"].append((round(w, 1), round(h, 1)))
            total_polygons += 1

    out = {"total_polygons": total_polygons, "levels": LEVEL_FILES, "kinds": {}}
    for kind, rec in sorted(by_kind.items(), key=lambda kv: -kv[1]["count"]):
        bboxes = rec["bboxes"]
        ws = [b[0] for b in bboxes]
        hs = [b[1] for b in bboxes]
        out["kinds"][kind] = dict(
            count=rec["count"],
            per_level=dict(rec["per_level"]),
            bbox_w_min=min(ws), bbox_w_max=max(ws),
            bbox_w_median=sorted(ws)[len(ws) // 2],
            bbox_h_min=min(hs), bbox_h_max=max(hs),
            bbox_h_median=sorted(hs)[len(hs) // 2],
        )
    return out


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--json-only", action="store_true",
                     help="print raw JSON only (no table)")
    args = ap.parse_args()
    data = census()
    if args.json_only:
        print(json.dumps(data, indent=2))
        return

    print(json.dumps(data, indent=2))
    print("\n# kind census (table)", file=sys.stderr)
    print(f"{'kind':<14} {'count':>6} {'bbox_w med':>11} "
          f"{'bbox_h med':>11} {'w range':>15} {'h range':>15}",
          file=sys.stderr)
    for kind, rec in data["kinds"].items():
        print(f"{kind:<14} {rec['count']:>6} {rec['bbox_w_median']:>11.1f} "
              f"{rec['bbox_h_median']:>11.1f} "
              f"{rec['bbox_w_min']:>6.1f}-{rec['bbox_w_max']:<7.1f} "
              f"{rec['bbox_h_min']:>6.1f}-{rec['bbox_h_max']:<7.1f}",
              file=sys.stderr)
    print(f"\nTOTAL polygons: {data['total_polygons']}", file=sys.stderr)


if __name__ == "__main__":
    main()
