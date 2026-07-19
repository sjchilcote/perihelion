"""tools/artgen/manifest.py

Full-run manifest (director's order, 2026-07-13, "Also" section): every
polygon in all ten levels/*.json (+ vigil), with its floorplan role, item
layout, decal plan entry, neighbor-conditioning BFS order, and an
estimated total cost for texture+mask generation with expected retry
rates drawn from cost_log.json's real call history. This is the number
the director needs before authorizing the full delete-and-regenerate run
-- NOT a generation run itself (no textures are produced or deleted here).

Usage:
    uv run python -m tools.artgen.manifest --out tools/artgen/full_run_manifest.json
"""
from __future__ import annotations

import argparse
import json
import statistics
from pathlib import Path

from tools.artgen.decal_plan import HUB_KINDS, LEVEL_STEMS, build_level_decal_plan
from tools.artgen.gen_pilot_textures_v2 import _bfs_order, polygon_key
from tools.artgen.item_layouts import KIND_ITEM_TEMPLATE, polygon_item_layout
from tools.artgen.pilot_texture_lib import TESTATOR_KINDS, get_level

COST_LOG = Path(__file__).resolve().parent / "cost_log.json"
PILOT_VERIFY = Path(__file__).resolve().parent / "pilot_verify_v2.json"


def _cost_history() -> dict:
    """Real per-call-kind cost stats from cost_log.json's 2257-call
    history (gen.py's running log, spans the whole rewrite-day pipeline),
    plus the accepted/dropped retry rate from pilot_verify_v2.json's 14
    judged polygons (the only polygons with a full attempt-count record)."""
    log = json.loads(COST_LOG.read_text())
    calls = log.get("calls", [])
    gen_costs = [c["cost"] for c in calls
                 if c.get("cost", 0) > 0 and "verify" not in c.get("out", "")
                 and "audit" not in c.get("out", "") and "item_placement" not in c.get("out", "")]
    verify_costs = [c["cost"] for c in calls
                     if c.get("cost", 0) > 0 and c.get("out", "").startswith("verify:")]
    item_costs = [c["cost"] for c in calls
                  if c.get("cost", 0) > 0 and "item_placement" in c.get("out", "")]

    mean_gen = statistics.mean(gen_costs) if gen_costs else 0.07
    mean_verify = statistics.mean(verify_costs) if verify_costs else 0.006
    # item_placement calls are new (this order); calibrate_v3.py's 2-polygon,
    # 4-and-3-box batch measured ~$0.0095-0.0102/call -- used as the
    # estimate until a larger batch exists.
    mean_item = statistics.mean(item_costs) if item_costs else 0.0098

    verify_data = json.loads(PILOT_VERIFY.read_text()) if PILOT_VERIFY.exists() else {}
    attempts = [v["attempt"] for v in verify_data.values() if v.get("status") == "accepted" and "attempt" in v]
    accepted = sum(1 for v in verify_data.values() if v.get("status") == "accepted")
    dropped = sum(1 for v in verify_data.values() if v.get("status") == "dropped")
    mean_attempts = statistics.mean(attempts) if attempts else 1.75
    accept_rate = accepted / max(1, accepted + dropped)

    return dict(mean_gen_cost=mean_gen, mean_verify_cost=mean_verify,
                mean_item_placement_cost=mean_item, mean_attempts_per_accepted_polygon=mean_attempts,
                accept_rate_sample=accept_rate, n_gen_calls_history=len(gen_costs),
                n_verify_calls_history=len(verify_costs), n_item_calls_history=len(item_costs),
                n_judged_polygons_sample=accepted + dropped)


def build_manifest() -> dict:
    hist = _cost_history()
    levels_out = {}
    total_polygons = 0
    total_item_boxes = 0
    total_decal_marks = 0

    for stem in LEVEL_STEMS:
        level = get_level(stem)
        decal_plan = build_level_decal_plan(stem)
        marks_by_polygon = {}
        for m in decal_plan["marks"]:
            marks_by_polygon.setdefault(m["polygon"], []).append(m)

        polygons_meta = []
        for idx in range(len(level.polygon_verts)):
            kind = level.polygon_kinds[idx]
            items = polygon_item_layout(kind)
            decals = marks_by_polygon.get(idx, [])
            polygons_meta.append(dict(
                polygon_index=idx, kind=kind,
                lane="TESTATOR" if kind in TESTATOR_KINDS else "MIRIAD",
                is_hub=kind in HUB_KINDS,
                n_item_boxes=len(items), item_labels=[i["label"] for i in items],
                n_decal_marks=len(decals),
                decal_justifications=[m["justification"] for m in decals],
            ))
            total_item_boxes += len(items)
            total_decal_marks += len(decals)

        neighbor_order = [polygon_key({"level": stem, "polygon_index": r["polygon_index"]})
                           for r in _bfs_order([dict(level=stem, polygon_index=r["polygon_index"])
                                                 for r in polygons_meta])]

        levels_out[stem] = dict(
            n_polygons=len(polygons_meta), n_hub_polygons=decal_plan["n_hubs"],
            n_decal_marks=decal_plan["n_marks"],
            n_unreachable_no_mark=decal_plan["n_unreachable_no_mark"],
            neighbor_conditioning_order=neighbor_order,
            polygons=polygons_meta,
        )
        total_polygons += len(polygons_meta)

    # cost model: every polygon attempts generation `mean_attempts` times on
    # average (retry loop, capped at 3, per gen_pilot_textures_v2.py); each
    # attempt pays ONE generation call + ONE gemini-geometry verify call +
    # ONE item-placement vision call (new, workstream 1) if it has boxes;
    # accepted polygons additionally get a free (no API call) walk-mask
    # derivation. Polygons with 0 item boxes (the "generic" kind, 30 polygons)
    # skip the item-placement call.
    n_with_boxes = sum(1 for stem in LEVEL_STEMS for idx in range(len(get_level(stem).polygon_verts))
                        if polygon_item_layout(get_level(stem).polygon_kinds[idx]))
    n_without_boxes = total_polygons - n_with_boxes

    per_attempt_with_boxes = hist["mean_gen_cost"] + hist["mean_verify_cost"] + hist["mean_item_placement_cost"]
    per_attempt_without_boxes = hist["mean_gen_cost"] + hist["mean_verify_cost"]
    est_cost = (n_with_boxes * per_attempt_with_boxes + n_without_boxes * per_attempt_without_boxes) \
        * hist["mean_attempts_per_accepted_polygon"]

    # small extra margin for the arrow-signage post-audit pass (workstream
    # 3) at verify_arrow_signage.py's measured per-call cost, run once per
    # SHIPPED (accepted) polygon -- assume the sample's accept_rate holds.
    arrow_audit_calls = json.loads(COST_LOG.read_text())["calls"]
    arrow_costs = [c["cost"] for c in arrow_audit_calls if "arrow_audit" in c.get("out", "") and c["cost"] > 0]
    mean_arrow_cost = statistics.mean(arrow_costs) if arrow_costs else 0.006
    est_arrow_audit = total_polygons * hist["accept_rate_sample"] * mean_arrow_cost
    est_total = est_cost + est_arrow_audit

    return dict(
        total_polygons=total_polygons, total_levels=len(LEVEL_STEMS), levels=LEVEL_STEMS,
        total_item_boxes_authored=total_item_boxes, total_decal_marks=total_decal_marks,
        n_polygons_with_item_boxes=n_with_boxes, n_polygons_without_item_boxes=n_without_boxes,
        cost_history=hist,
        cost_estimate=dict(
            per_attempt_cost_with_boxes=round(per_attempt_with_boxes, 4),
            per_attempt_cost_without_boxes=round(per_attempt_without_boxes, 4),
            mean_attempts_per_polygon=round(hist["mean_attempts_per_accepted_polygon"], 3),
            generation_and_verify_estimate_usd=round(est_cost, 2),
            arrow_signage_post_audit_estimate_usd=round(est_arrow_audit, 2),
            TOTAL_ESTIMATE_USD=round(est_total, 2),
            note=("Walk-mask derivation (workstream 2) adds NO generation cost -- "
                  "approach (b), derived from boxes + texture analysis, zero API calls. "
                  "Estimate assumes the pilot sample's 57% accept rate and 1.75 mean "
                  "attempts hold at full scale; small-n (14 judged polygons) so treat as "
                  "order-of-magnitude, not precise -- re-measure after the first ~50 "
                  "polygons of the real full run and update this number before committing "
                  "to the remaining budget."),
        ),
        levels_detail=levels_out,
    )


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str, default=None)
    args = ap.parse_args()
    m = build_manifest()
    summary = {k: v for k, v in m.items() if k != "levels_detail"}
    print(json.dumps(summary, indent=2))
    if args.out:
        Path(args.out).write_text(json.dumps(m, indent=2))
        print(f"\nwrote full manifest (incl. per-polygon detail) to {args.out}")


if __name__ == "__main__":
    main()
