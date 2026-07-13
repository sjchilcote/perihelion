"""tools/artgen/regen_clearance_masks.py

Mask-only regeneration for rooms whose SHIPPED walk-mask fails the new
clearance gate (tools/artgen/audit_clearance.py). Textures stay untouched
-- zero API cost, zero generation risk: this only recomputes the derived
walk-mask (box geometry + texture analysis, walkmask.derive_walkmask) and
re-gates it.

For each failing room, retries the SAME progressive-inset ladder
full_run.py already uses on first generation (0%, 20%, 40%) but widened
(0%, 20%, 40%, 60%, 80%) since the bar is now stricter, then a final
"drop all boxes" try (walk-mask degenerates to the bare room polygon --
still gated). If nothing survives clearance, ships mask-less (delete the
walk-mask file; absence = fully walkable, the engine's own contract) --
this can never fail the gate, since there is no terrain left to pinch a
route.
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

from tools.artgen.box_conditioning import compute_item_boxes
from tools.artgen.full_run import GUIDE_DIR, REVIEW_DIR, load_manifest_rooms
from tools.artgen.pilot_texture_lib import get_level, make_guide, room_mask
from tools.artgen.walkmask import (
    check_room_portal_clearance, check_room_portal_connectivity, derive_walkmask,
    portal_points_px, walkmask_out_path,
)

PROGRESS_PATH = HERE / "full_run_progress.json"
AUDIT_PATH = HERE / "clearance_audit.json"

INSET_LADDER = (0.0, 0.20, 0.40, 0.60, 0.80)


def _kind_lookup(stem: str) -> dict[int, str]:
    return {idx: kind for s, idx, kind in load_manifest_rooms(stem) if s == stem}


def regen_one(stem: str, idx: int, kind: str, texture_path: Path) -> dict:
    guide_path = GUIDE_DIR / stem / f"room_{idx:03d}.png"
    if not guide_path.exists():
        make_guide(stem, idx, guide_path)
    boxes = compute_item_boxes(guide_path, stem, idx, kind)
    gw, gh = Image.open(guide_path).size

    final_im = Image.open(texture_path).convert("RGB")
    tex_w, tex_h = final_im.size
    sx, sy = tex_w / gw, tex_h / gh
    scaled_boxes = [
        dict(b, box=(int(b["box"][0] * sx), int(b["box"][1] * sy),
                      int(b["box"][2] * sx), int(b["box"][3] * sy)))
        for b in boxes
    ]
    mask = room_mask(stem, idx, 3)
    if mask.shape != (tex_h, tex_w):
        # room_mask's own default px_per_unit may not match this texture's
        # actual raster size (kept in step with full_run.py's own
        # _sized_mask, which resizes to the true texture size).
        mask_im = Image.fromarray((mask.astype(np.uint8) * 255), mode="L")
        mask = np.asarray(mask_im.resize((tex_w, tex_h), Image.NEAREST)) > 127

    level = get_level(stem)
    pts = portal_points_px(stem, idx, level)

    trials = list(INSET_LADDER) + ["no_boxes"]
    for inset in trials:
        if inset == "no_boxes":
            trial_boxes = []
        elif inset == 0.0:
            trial_boxes = scaled_boxes
        else:
            trial_boxes = []
            for b in scaled_boxes:
                x0, y0, x1, y1 = b["box"]
                dx, dy = (x1 - x0) * inset / 2, (y1 - y0) * inset / 2
                trial_boxes.append(dict(b, box=(int(x0 + dx), int(y0 + dy),
                                                 int(x1 - dx), int(y1 - dy))))
        walk_im = derive_walkmask(mask, trial_boxes, texture=final_im)
        walk_arr = np.asarray(walk_im) > 127
        conn = check_room_portal_connectivity(walk_arr, pts)
        if not conn["ok"]:
            continue
        clearance = check_room_portal_clearance(walk_arr, pts)
        if clearance["ok"]:
            walk_path = walkmask_out_path(texture_path)
            walk_im.save(walk_path)
            review_walk = REVIEW_DIR / f"full_{stem}_room{idx:03d}_walkmask.png"
            review_walk.write_bytes(walk_path.read_bytes())
            return dict(ok=True, mask_status="shipped", inset=inset,
                        connectivity=conn, clearance=clearance)

    # nothing survived -- ship mask-less.
    walk_path = walkmask_out_path(texture_path)
    removed = walk_path.is_file()
    if removed:
        walk_path.unlink()
    return dict(ok=True, mask_status="omitted", removed_existing_mask=removed)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", type=str, default=None)
    args = ap.parse_args()

    audit = json.loads(AUDIT_PATH.read_text())
    failures = audit["summary"]["failures"]
    if args.level:
        failures = [k for k in failures if k.startswith(args.level + "/")]

    progress = json.loads(PROGRESS_PATH.read_text())
    kind_cache: dict[str, dict[int, str]] = {}
    out = {}
    for key in failures:
        stem, room_key = key.split("/")
        idx = int(room_key.split("_")[1])
        if stem not in kind_cache:
            kind_cache[stem] = _kind_lookup(stem)
        kind = kind_cache[stem][idx]
        texture_path = Path(progress[key]["texture"])
        res = regen_one(stem, idx, kind, texture_path)
        out[key] = res
        progress[key]["mask_status"] = res["mask_status"]
        if res["mask_status"] == "shipped":
            progress[key]["walkmask_connectivity"] = res["connectivity"]
        else:
            progress[key].pop("walkmask_connectivity", None)
        print(key, res["mask_status"], res.get("inset", ""))

    PROGRESS_PATH.write_text(json.dumps(progress, indent=2, default=str))
    n_shipped = sum(1 for v in out.values() if v["mask_status"] == "shipped")
    n_omitted = len(out) - n_shipped
    print(f"regenerated {len(out)}: shipped={n_shipped} omitted={n_omitted}")


if __name__ == "__main__":
    main()
