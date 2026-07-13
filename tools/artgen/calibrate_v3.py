"""tools/artgen/calibrate_v3.py

Small calibration driver (director's order, 2026-07-13: "You may spend up
to $10 on small calibration batches to prove the new pipeline stages
work") for the three new workstreams: labeled-box conditioning, walk-mask
derivation, and the decal-plan wayfinding exception. Runs a handful of
rooms end-to-end through the FULL new gate stack (all existing gates +
item-placement vision gate + walk-mask connectivity hard gate) and writes
review artifacts to tools/artgen/review/ for personal frame reading.

Does NOT touch shipped textures (game/perihelion/assets/textures) -- all
output goes to a v3 scratch/review area, exactly like the existing sample
pipeline's separation between calibration and ship.

Usage:
    uv run python -m tools.artgen.calibrate_v3 --rooms l01/0,l03/0
"""
from __future__ import annotations

import argparse
import json
from pathlib import Path

from PIL import Image

from tools.artgen.gen import generate_image
from tools.artgen.pilot_texture_lib import (
    SCRATCH, basetruth_path, build_room_prompt, get_level, room_mask,
)
from tools.artgen.box_conditioning import (
    boxes_prompt_note, draw_labeled_boxes, verify_item_placement,
)
from tools.artgen.decal_plan import build_level_decal_plan, decal_prompt_note
from tools.artgen.texture_checks import (
    crop_outer_black_margin, verify_detail_budget, verify_fullbleed,
    verify_no_guide_ink, verify_no_interior_void,
)
from tools.artgen.verify_gemini import verify_texture
from tools.artgen.walkmask import (
    check_room_portal_connectivity, derive_walkmask, portal_points_px,
    walkmask_out_path,
)

GUIDE_DIR = SCRATCH / "guides"
MATERIALS_DIR = SCRATCH / "materials"
V3_OUT = SCRATCH / "v3_calibration"
REVIEW_DIR = Path(__file__).resolve().parent / "review"
REPORT_PATH = Path(__file__).resolve().parent / "calibration_v3_report.json"

import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "game"))
import numpy as np  # noqa: E402


def _tex_size(stem: str, room_idx: int) -> tuple[int, int]:
    rooms = json.loads((Path(__file__).resolve().parent / "pilot_rooms.json").read_text())["rooms"]
    for r in rooms:
        if r["level"] == stem and r["room_index"] == room_idx:
            return r["tex_w"], r["tex_h"]
    # fall back to the room_mask's own bbox->px sizing
    mask = room_mask(stem, room_idx)
    h, w = mask.shape
    return w, h


def run_room(stem: str, room_idx: int, kind_override: str | None = None) -> dict:
    level = get_level(stem)
    kind = kind_override or level.room_kinds[room_idx]
    guide_path = GUIDE_DIR / stem / f"room_{room_idx:03d}.png"
    if not guide_path.exists():
        raise RuntimeError(f"no cached guide for {stem}/room_{room_idx:03d} -- run gen_pilot_textures_v2 "
                            "first to populate the guide cache, or point --guide-dir elsewhere")
    material_path = MATERIALS_DIR / f"{kind}.png"

    boxed_guide_path = V3_OUT / "guides" / f"{stem}_room{room_idx:03d}.png"
    boxed_guide_path.parent.mkdir(parents=True, exist_ok=True)
    _, boxes = draw_labeled_boxes(guide_path, stem, room_idx, kind, boxed_guide_path)

    decal_plan = build_level_decal_plan(stem)
    d_note = decal_prompt_note(decal_plan["marks"], stem, room_idx)
    b_note = boxes_prompt_note(boxes)
    prompt = build_room_prompt(kind, has_neighbor_composite=False, box_note=b_note, decal_note=d_note)

    tex_w, tex_h = _tex_size(stem, room_idx)
    gen_out = V3_OUT / "gen" / f"{stem}_room{room_idx:03d}.png"
    gen_out.parent.mkdir(parents=True, exist_ok=True)
    gr = generate_image(prompt, gen_out, reference_images=[str(boxed_guide_path), str(material_path)])
    total_cost = gr["cost"]

    raw_im = Image.open(gen_out).convert("RGB")
    raw_im = crop_outer_black_margin(raw_im)
    raw_resized = raw_im.resize((tex_w, tex_h), Image.LANCZOS)

    mask = room_mask(stem, room_idx)
    if mask.shape != (tex_h, tex_w):
        m = Image.fromarray((mask.astype("uint8") * 255), mode="L")
        m = m.resize((tex_w, tex_h), Image.NEAREST)
        mask = np.asarray(m) > 127

    gates = {}
    gates["fullbleed"] = verify_fullbleed(raw_resized, mask, darken_thresh=1.55)
    gates["interior_void"] = verify_no_interior_void(raw_resized, mask)
    gates["guide_ink"] = verify_no_guide_ink(raw_resized, mask)
    gates["detail_budget"] = verify_detail_budget(
        raw_resized, mask, Image.open(material_path).convert("RGB"))

    gv = verify_texture(guide_path, gen_out, kind, anchor_path=material_path,
                         allowed_items=[b["label"] for b in boxes])
    total_cost += gv.get("_cost", 0.0)
    gates["gemini_geometry"] = gv

    # scale boxes from the boxed-guide's px size to the final texel size
    # before cropping the finished texture (they can differ slightly).
    guide_im = Image.open(boxed_guide_path)
    gw, gh = guide_im.size
    sx, sy = tex_w / gw, tex_h / gh
    scaled_boxes = []
    for b in boxes:
        x0, y0, x1, y1 = b["box"]
        scaled_boxes.append(dict(b, box=(int(x0 * sx), int(y0 * sy), int(x1 * sx), int(y1 * sy))))

    out_final = V3_OUT / "final" / f"{stem}_room{room_idx:03d}.png"
    out_final.parent.mkdir(parents=True, exist_ok=True)
    from tools.artgen.pilot_texture_lib import apply_mask
    final_im = apply_mask(raw_resized, mask)
    final_im.save(out_final)

    item_gate = verify_item_placement(out_final, scaled_boxes, kind)
    total_cost += item_gate.get("_cost", 0.0)
    gates["item_placement"] = item_gate

    walk_im = derive_walkmask(mask, scaled_boxes, texture=final_im)
    walk_path = walkmask_out_path(out_final)
    walk_im.save(walk_path)

    walk_arr = np.asarray(walk_im) > 127
    pts = portal_points_px(stem, room_idx, level)
    conn = check_room_portal_connectivity(walk_arr, pts)
    gates["walkmask_connectivity"] = conn

    review_path = REVIEW_DIR / f"v3_{stem}_room{room_idx:03d}_texture.png"
    review_path.write_bytes(out_final.read_bytes())
    review_boxed_guide = REVIEW_DIR / f"v3_{stem}_room{room_idx:03d}_boxed_guide.png"
    review_boxed_guide.write_bytes(boxed_guide_path.read_bytes())
    review_walk = REVIEW_DIR / f"v3_{stem}_room{room_idx:03d}_walkmask.png"
    review_walk.write_bytes(walk_path.read_bytes())

    overall_ok = all(
        gates[k].get("ok", gates[k].get("all_present", gates[k].get("verdict") == "pass"))
        for k in gates
    )

    return dict(
        key=f"{stem}/room_{room_idx:03d}", kind=kind, cost=total_cost,
        n_boxes=len(boxes), n_decal_marks=len([m for m in decal_plan["marks"] if m["room"] == room_idx]),
        gates={k: {kk: vv for kk, vv in v.items() if kk != "_raw"} for k, v in gates.items()},
        overall_ok=overall_ok,
        review_texture=str(review_path), review_boxed_guide=str(review_boxed_guide),
        review_walkmask=str(review_walk),
    )


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rooms", type=str, required=True,
                     help="comma-separated stem/idx pairs, e.g. l01/0,l03/0")
    args = ap.parse_args()

    results = {}
    for spec in args.rooms.split(","):
        stem, idx = spec.split("/")
        idx = int(idx)
        print(f"=== {stem}/room_{idx:03d} ===")
        res = run_room(stem, idx)
        results[res["key"]] = res
        print(json.dumps({k: v for k, v in res.items() if k != "gates"}, indent=2))

    REPORT_PATH.write_text(json.dumps(results, indent=2))
    print(f"\nWrote {REPORT_PATH}")


if __name__ == "__main__":
    main()
