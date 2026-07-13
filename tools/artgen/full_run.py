"""tools/artgen/full_run.py

FINAL texture pass driver (director's order, 2026-07-13): bespoke texture +
walk-mask for every one of the 1815 rooms in tools/artgen/full_run_manifest.json,
via the upgraded pipeline -- labeled-box conditioning (box_conditioning.py),
walk-mask derivation with the portal-connectivity hard gate (walkmask.py),
and the decal diegesis plan (decal_plan.py) -- on top of the existing v2
programmatic gate stack (texture_checks.py) + Gemini geometry judge
(verify_gemini.py).

Ship-or-bare, sticky acceptance:
  - up to 3 generation attempts per room against the FULL gate stack
    (fullbleed, interior_void, shape_conformance, guide_ink, detail_budget
    [box-aware, recalibrated 2026-07-13], gemini_geometry, item_placement).
  - a room that exhausts attempts ships bare (no texture on disk) -- logged,
    never a gate-failing texture.
  - an accepted room's texture is FINAL; re-running this script skips any
    room already recorded "accepted" or "bare" in the progress file unless
    --rooms force-clears it.
  - walk-mask: derived (no extra API cost) from the accepted texture +
    boxes, checked against the portal-connectivity hard gate. Retried up to
    3x with the boxes inset progressively (20%, 40%) to open more floor
    around portals before giving up. A mask that still fails ships the
    texture with NO mask file (absence = fully walkable, per engine
    contract) -- logged.

Usage:
    uv run python -m tools.artgen.full_run --level l01
    uv run python -m tools.artgen.full_run --level l01 --workers 4
    uv run python -m tools.artgen.full_run --rooms l01/room_000,l01/room_002
"""
from __future__ import annotations

import argparse
import json
import sys
import threading
import time
import traceback
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from PIL import Image

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[1]))

from tools.artgen.gen import generate_image
from tools.artgen.verify_gemini import verify_texture
from tools.artgen.box_conditioning import (
    boxes_prompt_note, draw_labeled_boxes, verify_item_placement,
)
from tools.artgen.decal_plan import build_level_decal_plan, decal_prompt_note
from tools.artgen.pilot_texture_lib import (
    SCRATCH, TEXTURES_ROOT, apply_mask, build_neighbor_composite,
    build_room_prompt, get_level, make_guide, room_mask, save_review_overlay,
    texture_out_path, wall_edges_px,
)
from tools.artgen.texture_checks import (
    crop_outer_black_margin, verify_detail_budget, verify_fullbleed,
    verify_no_guide_ink, verify_no_interior_void, verify_shape_conformance,
)
from tools.artgen.walkmask import (
    check_room_portal_connectivity, derive_walkmask, portal_points_px,
    walkmask_out_path,
)

import numpy as np

GUIDE_DIR = SCRATCH / "guides"
MATERIALS_DIR = SCRATCH / "materials"
NEIGHBOR_DIR = SCRATCH / "neighbor_composites"
GEN_SCRATCH = SCRATCH / "gen_rooms_full"
REVIEW_DIR = HERE / "review"
MANIFEST_PATH = HERE / "full_run_manifest.json"
PROGRESS_PATH = HERE / "full_run_progress.json"
RUN_LOG_PATH = HERE / "full_run_log.json"

_lock = threading.Lock()


def _load_progress() -> dict:
    if PROGRESS_PATH.exists():
        return json.loads(PROGRESS_PATH.read_text())
    return {}


def _save_progress(progress: dict) -> None:
    with _lock:
        PROGRESS_PATH.write_text(json.dumps(progress, indent=2))


def _sized_mask(stem: str, idx: int, tex_w: int, tex_h: int) -> np.ndarray:
    mask = room_mask(stem, idx)
    if mask.shape != (tex_h, tex_w):
        m = Image.fromarray((mask.astype("uint8") * 255), mode="L")
        m = m.resize((tex_w, tex_h), Image.NEAREST)
        mask = np.asarray(m) > 127
    return mask


def _tex_size(stem: str, idx: int) -> tuple[int, int]:
    pilot_path = HERE / "pilot_rooms.json"
    if pilot_path.exists():
        rooms = json.loads(pilot_path.read_text())["rooms"]
        for r in rooms:
            if r["level"] == stem and r["room_index"] == idx:
                return r["tex_w"], r["tex_h"]
    mask = room_mask(stem, idx)
    h, w = mask.shape
    return w, h


def load_manifest_rooms(level: str | None = None) -> list[tuple[str, int, str]]:
    """Returns [(stem, room_idx, kind), ...] in neighbor-conditioning
    order, across every level (or just `level` if given)."""
    manifest = json.loads(MANIFEST_PATH.read_text())
    out = []
    for stem in manifest["levels"]:
        if level and stem != level:
            continue
        detail = manifest["levels_detail"][stem]
        rooms_by_idx = {r["room_index"]: r for r in detail["rooms"]}
        order = detail["neighbor_conditioning_order"]
        for key in order:
            idx = int(key.split("_")[-1])
            kind = rooms_by_idx[idx]["kind"]
            out.append((stem, idx, kind))
    return out


def room_key(stem: str, idx: int) -> str:
    return f"{stem}/room_{idx:03d}"


def process_room(stem: str, idx: int, kind: str, progress: dict) -> dict:
    key = room_key(stem, idx)
    guide_path = GUIDE_DIR / stem / f"room_{idx:03d}.png"
    if not guide_path.exists():
        make_guide(stem, idx, guide_path)
    material_path = MATERIALS_DIR / f"{kind}.png"
    if not material_path.exists():
        raise RuntimeError(f"no material swatch for kind={kind!r} at {material_path}; "
                            "run tools.artgen.gen_kind_materials first")

    boxed_guide_path = GEN_SCRATCH / "guides" / f"{stem}_room{idx:03d}.png"
    boxed_guide_path.parent.mkdir(parents=True, exist_ok=True)
    _, boxes = draw_labeled_boxes(guide_path, stem, idx, kind, boxed_guide_path)

    decal_plan = build_level_decal_plan(stem)
    d_note = decal_prompt_note(decal_plan["marks"], stem, idx)
    b_note = boxes_prompt_note(boxes)

    neighbor_path = NEIGHBOR_DIR / stem / f"room_{idx:03d}.png"
    neighbor_path = build_neighbor_composite(stem, idx, neighbor_path)
    reference_images = [str(boxed_guide_path), str(material_path)]
    if neighbor_path is not None:
        reference_images.append(str(neighbor_path))
    prompt = build_room_prompt(kind, has_neighbor_composite=neighbor_path is not None,
                                box_note=b_note, decal_note=d_note)

    tex_w, tex_h = _tex_size(stem, idx)
    mask = _sized_mask(stem, idx, tex_w, tex_h)
    wall_edges = wall_edges_px(stem, idx)

    guide_im = Image.open(boxed_guide_path)
    gw, gh = guide_im.size
    sx, sy = tex_w / gw, tex_h / gh
    scaled_boxes = [
        dict(b, box=(int(b["box"][0] * sx), int(b["box"][1] * sy),
                      int(b["box"][2] * sx), int(b["box"][3] * sy)))
        for b in boxes
    ]

    total_cost = 0.0
    verdicts = []
    GEN_SCRATCH.mkdir(parents=True, exist_ok=True)
    accepted_final = None

    for attempt in (1, 2, 3):
        gen_out = GEN_SCRATCH / f"{stem}_room{idx:03d}_a{attempt}.png"
        this_prompt = prompt
        if attempt > 1 and verdicts:
            this_prompt += (
                f"\n\nPREVIOUS ATTEMPT FAILED REVIEW: {verdicts[-1].get('notes', '')} "
                "Fix that specific problem this time."
            )
        try:
            gr = generate_image(this_prompt, gen_out, reference_images=reference_images)
            total_cost += gr["cost"]
        except Exception as exc:  # noqa: BLE001
            verdicts.append({"verdict": "fail", "notes": f"generation error: {exc}"})
            continue

        raw_im = Image.open(gen_out).convert("RGB")
        raw_im = crop_outer_black_margin(raw_im)
        raw_resized = raw_im.resize((tex_w, tex_h), Image.LANCZOS)

        fb = verify_fullbleed(raw_resized, mask, darken_thresh=1.55)
        if not fb["ok"]:
            verdicts.append({"verdict": "fail", "notes":
                              f"programmatic full-bleed rejected (darken_ratio="
                              f"{fb.get('darken_ratio')}, grad_ratio={fb.get('grad_ratio')})."})
            continue

        iv = verify_no_interior_void(raw_resized, mask)
        if not iv["ok"]:
            verdicts.append({"verdict": "fail", "notes":
                              f"programmatic interior-void rejected: "
                              f"{iv['black_frac']:.1%} painted near-black."})
            continue

        sc = verify_shape_conformance(raw_resized, mask, wall_edges)
        if not sc["ok"]:
            verdicts.append({"verdict": "fail", "notes":
                              f"programmatic shape-conformance rejected: "
                              f"mean angle error {sc.get('mean_err'):.1f} deg."})
            continue

        gi = verify_no_guide_ink(raw_resized, mask)
        if not gi["ok"]:
            verdicts.append({"verdict": "fail", "notes":
                              f"programmatic guide-ink rejected: "
                              f"{gi['leak_frac']:.2%} saturated ink."})
            continue

        db = verify_detail_budget(raw_resized, mask, Image.open(material_path).convert("RGB"),
                                   boxes=scaled_boxes)
        if not db["ok"]:
            verdicts.append({"verdict": "fail", "notes":
                              f"programmatic detail-budget rejected: "
                              f"bg_ratio={db.get('background_grad_ratio', db['grad_ratio_vs_material']):.2f} "
                              f"eq_ratio={db.get('equipment_grad_ratio')}.",
                              "_detail_budget": db})
            continue

        try:
            v = verify_texture(guide_path, gen_out, kind, anchor_path=material_path,
                                allowed_items=[b["label"] for b in boxes])
            total_cost += v.get("_cost", 0.0)
        except Exception as exc:  # noqa: BLE001
            v = {"verdict": "fail", "notes": f"verify error: {exc}"}
        if v.get("verdict") != "pass":
            verdicts.append(v)
            continue

        out_final = GEN_SCRATCH / "final" / f"{stem}_room{idx:03d}.png"
        out_final.parent.mkdir(parents=True, exist_ok=True)
        final_im = apply_mask(raw_resized, mask)
        final_im.save(out_final)

        try:
            item_gate = verify_item_placement(out_final, scaled_boxes, kind)
            total_cost += item_gate.get("_cost", 0.0)
        except Exception as exc:  # noqa: BLE001
            item_gate = {"all_present": False, "results": [], "_cost": 0.0,
                         "_error": str(exc)}
        if not item_gate.get("all_present", True):
            verdicts.append({"verdict": "fail",
                              "notes": f"item-placement gate rejected: {item_gate.get('results')}",
                              "_item_placement": item_gate})
            continue

        accepted_final = out_final
        verdicts.append(v)
        break

    if accepted_final is None:
        stale = texture_out_path(stem, idx)
        removed_stale = stale.is_file()
        if removed_stale:
            stale.unlink()
        stale_mask = walkmask_out_path(stale)
        if stale_mask.is_file():
            stale_mask.unlink()
        result = dict(key=key, status="bare", cost=total_cost, verdicts=verdicts,
                      removed_stale_texture=removed_stale)
        progress[key] = result
        _save_progress(progress)
        return result

    # ACCEPTED: ship the texture, then derive + gate the walk-mask.
    ship_path = texture_out_path(stem, idx)
    ship_path.parent.mkdir(parents=True, exist_ok=True)
    ship_path.write_bytes(accepted_final.read_bytes())

    review_path = REVIEW_DIR / f"full_{stem}_room{idx:03d}.png"
    save_review_overlay(stem, idx, ship_path, review_path)

    pts = portal_points_px(stem, idx, get_level(stem))
    final_im = Image.open(ship_path).convert("RGB")
    mask_status = "omitted"
    conn_result = None
    for inset_frac in (0.0, 0.20, 0.40):
        if inset_frac == 0.0:
            trial_boxes = scaled_boxes
        else:
            trial_boxes = []
            for b in scaled_boxes:
                x0, y0, x1, y1 = b["box"]
                dx, dy = (x1 - x0) * inset_frac / 2, (y1 - y0) * inset_frac / 2
                trial_boxes.append(dict(b, box=(x0 + dx, y0 + dy, x1 - dx, y1 - dy)))
        walk_im = derive_walkmask(mask, trial_boxes, texture=final_im)
        walk_arr = np.asarray(walk_im) > 127
        conn_result = check_room_portal_connectivity(walk_arr, pts)
        if conn_result["ok"]:
            walk_path = walkmask_out_path(ship_path)
            walk_im.save(walk_path)
            review_walk = REVIEW_DIR / f"full_{stem}_room{idx:03d}_walkmask.png"
            review_walk.write_bytes(walk_path.read_bytes())
            mask_status = "shipped"
            break

    result = dict(key=key, status="accepted", cost=total_cost, texture=str(ship_path),
                  mask_status=mask_status, walkmask_connectivity=conn_result,
                  n_boxes=len(boxes), used_neighbor_composite=neighbor_path is not None,
                  review_overlay=str(review_path))
    progress[key] = result
    _save_progress(progress)
    return result


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", type=str, default=None, help="restrict to one level, e.g. l01")
    ap.add_argument("--workers", type=int, default=4)
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--rooms", type=str, default=None,
                     help="comma-separated stem/room_XXX keys to force-redo")
    args = ap.parse_args()

    rooms = load_manifest_rooms(args.level)
    if args.limit:
        rooms = rooms[: args.limit]

    progress = _load_progress()
    if args.rooms:
        force = set(args.rooms.split(","))
        for stem, idx, _kind in rooms:
            k = room_key(stem, idx)
            if k in force:
                progress.pop(k, None)

    todo = [(s, i, k) for s, i, k in rooms if room_key(s, i) not in progress]
    print(f"[full_run] level={args.level or 'ALL'} {len(rooms)} rooms, "
          f"{len(rooms) - len(todo)} already done, {len(todo)} to process, "
          f"workers={args.workers}")

    t0 = time.time()
    n_done = 0
    n_accepted = 0
    n_bare = 0
    n_masked = 0
    n_mask_omitted = 0
    run_cost = 0.0

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {ex.submit(process_room, s, i, k, progress): (s, i, k) for s, i, k in todo}
        for fut in as_completed(futs):
            s, i, k = futs[fut]
            n_done += 1
            try:
                res = fut.result()
                run_cost += res["cost"]
                if res["status"] == "accepted":
                    n_accepted += 1
                    if res["mask_status"] == "shipped":
                        n_masked += 1
                    else:
                        n_mask_omitted += 1
                else:
                    n_bare += 1
                print(f"[{n_done}/{len(todo)}] {res['key']:20s} {res['status']:10s} "
                      f"mask={res.get('mask_status', '-'):8s} cost=${res['cost']:.4f} "
                      f"run_total=${run_cost:.2f} elapsed={time.time()-t0:.0f}s")
            except Exception as exc:  # noqa: BLE001
                print(f"[{n_done}/{len(todo)}] {room_key(s, i)} CRASHED: {exc}")
                traceback.print_exc()

    summary = dict(level=args.level, n_rooms=len(rooms), n_processed=len(todo),
                    n_accepted=n_accepted, n_bare=n_bare, n_masked=n_masked,
                    n_mask_omitted=n_mask_omitted, run_cost=run_cost,
                    elapsed_sec=time.time() - t0)
    print(f"\n[full_run] SUMMARY {json.dumps(summary)}")
    with _lock:
        log = json.loads(RUN_LOG_PATH.read_text()) if RUN_LOG_PATH.exists() else []
        log.append(summary)
        RUN_LOG_PATH.write_text(json.dumps(log, indent=2))


if __name__ == "__main__":
    main()
