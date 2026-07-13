"""tools/artgen/gen_pilot_textures_v2.py

Rebuilt per-room floor-texture driver (director's ruling, 2026-07-10):
generate against the kind's TILEABLE BASE MATERIAL (tools/artgen/
gen_kind_materials.py) instead of a single "anchor room" photo, reject
negative-space/border defects PROGRAMMATICALLY before any paid Gemini
call, grade the accepted room's tone toward the kind's shared luminance/
chroma window (style continuity), then Gemini-verify geometry/style, then
apply the exact polygon mask (never painted by the model).

The IN-SITU gate (verify_in_situ.py) runs as a separate pass after this
one: it renders real adjacent room pairs with the real Renderer and is
the actual ship/no-ship decision for two-attempt rooms whose neighbors
are also textured. This script's own two-attempt loop covers the
single-room checks (full-bleed, geometry, style, palette); rooms that
fail *those* twice already ship with no texture, same as before.

Usage:
    uv run python -m tools.artgen.gen_pilot_textures_v2 [--workers 7] [--limit N]
"""
from __future__ import annotations

import argparse
import json
import threading
import traceback
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

from PIL import Image

from tools.artgen.gen import generate_image
from tools.artgen.verify_gemini import verify_texture
from tools.artgen.pilot_texture_lib import (
    SCRATCH, TEXTURES_ROOT, apply_mask, basetruth_path, build_neighbor_composite,
    build_room_prompt, load_pilot, make_guide, room_mask, save_review_overlay,
    texture_out_path, wall_edges_px,
)
from tools.artgen.texture_checks import (
    crop_outer_black_margin, grade_toward, in_window, region_tone,
    verify_detail_budget, verify_fullbleed, verify_no_guide_ink,
    verify_no_interior_void, verify_shape_conformance,
)

GUIDE_DIR = SCRATCH / "guides"
MATERIALS_DIR = SCRATCH / "materials"
WINDOWS_PATH = Path(__file__).resolve().parent / "kind_windows.json"
PROGRESS_PATH = SCRATCH / "pilot_progress_v2.json"
VERIFY_OUT = Path(__file__).resolve().parent / "pilot_verify_v2.json"
GEN_SCRATCH = SCRATCH / "gen_rooms_v2"
NEIGHBOR_DIR = SCRATCH / "neighbor_composites"
REVIEW_DIR = Path(__file__).resolve().parent / "review"

_lock = threading.Lock()
_windows = json.loads(WINDOWS_PATH.read_text())


def _load_progress() -> dict:
    if PROGRESS_PATH.exists():
        return json.loads(PROGRESS_PATH.read_text())
    return {}


def _save_progress(progress: dict) -> None:
    with _lock:
        PROGRESS_PATH.write_text(json.dumps(progress, indent=2))


def room_key(r: dict) -> str:
    return f"{r['level']}/room_{r['room_index']:03d}"


def _sized_mask(room: dict):
    """room_mask nearest-resized to the exact pilot tex_w/tex_h texel size.
    The two disagree by <=1px on either axis (the same rounding slop
    apply_mask tolerates); every numpy-side consumer here needs them equal."""
    import numpy as np
    mask = room_mask(room["level"], room["room_index"])
    if mask.shape != (room["tex_h"], room["tex_w"]):
        m = Image.fromarray((mask.astype("uint8") * 255), mode="L")
        m = m.resize((room["tex_w"], room["tex_h"]), Image.NEAREST)
        mask = np.asarray(m) > 127
    return mask


def postprocess_and_save(gen_path: Path, room: dict) -> tuple[Path, dict]:
    """Resize to exact texel size, grade tone toward the kind window,
    apply the EXACT polygon mask (the pipeline applies it -- the model
    never paints the boundary), save. Returns (out_path, tone_after)."""
    im = Image.open(gen_path).convert("RGB")
    # normalize the model's systematic thin black outer gutter BEFORE the
    # resize (the same normalization the gates saw -- see process_room)
    im = crop_outer_black_margin(im)
    im = im.resize((room["tex_w"], room["tex_h"]), Image.LANCZOS)
    mask = _sized_mask(room)
    window = _windows.get(room["kind"])
    if window is not None:
        tone = region_tone(im, mask)
        if not in_window(tone, window):
            im = grade_toward(im, mask, window)
    im = apply_mask(im, mask)
    out = texture_out_path(room["level"], room["room_index"])
    out.parent.mkdir(parents=True, exist_ok=True)
    im.save(out)
    tone_after = region_tone(im, mask)
    return out, tone_after


def process_room(room: dict, progress: dict, tag: str = "p1") -> dict:
    key = room_key(room)
    stem, idx = room["level"], room["room_index"]
    kind = room["kind"]
    material_path = MATERIALS_DIR / f"{kind}.png"
    guide_path = GUIDE_DIR / stem / f"room_{idx:03d}.png"
    if not guide_path.exists():
        make_guide(stem, idx, guide_path)

    # NEIGHBOR-CONTINUITY COMPOSITE (director's ruling, 2026-07-11): only
    # available once at least one adjacent room already has a shipped
    # texture -- main()'s BFS ordering generates rooms in an order that
    # maximizes how often this is true, and a second pass re-runs any room
    # whose neighbor arrived after it.
    neighbor_path = NEIGHBOR_DIR / stem / f"room_{idx:03d}.png"
    neighbor_path = build_neighbor_composite(stem, idx, neighbor_path)
    reference_images = [str(guide_path), str(material_path)]
    if neighbor_path is not None:
        reference_images.append(str(neighbor_path))
    prompt = build_room_prompt(kind, has_neighbor_composite=neighbor_path is not None)
    GEN_SCRATCH.mkdir(parents=True, exist_ok=True)
    mask = _sized_mask(room)
    wall_edges = wall_edges_px(stem, idx)

    total_cost = 0.0
    verdicts = []
    for attempt in (1, 2, 3):
        gen_out = GEN_SCRATCH / f"{room['level']}_room{room['room_index']:03d}_{tag}_a{attempt}.png"
        this_prompt = prompt
        if attempt > 1 and verdicts:
            this_prompt += (
                f"\n\nPREVIOUS ATTEMPT FAILED REVIEW: {verdicts[-1].get('notes', '')} "
                "Fix that specific problem this time."
            )
        try:
            gr = generate_image(this_prompt, gen_out,
                                reference_images=reference_images)
            total_cost += gr["cost"]
        except Exception as exc:  # noqa: BLE001
            verdicts.append({"verdict": "fail", "notes": f"generation error: {exc}"})
            continue

        # PROGRAMMATIC gate first (property 1): reject painted negative
        # space before spending on Gemini judging at all.
        raw_im = Image.open(gen_out).convert("RGB")
        # normalize the model's systematic thin black outer gutter (a few
        # px of pure black around an otherwise-correct room) before any
        # gating; big margins/layout failures are NOT rescued (capped in
        # crop_outer_black_margin) and still fail the full-bleed gate.
        raw_im = crop_outer_black_margin(raw_im)
        raw_resized = raw_im.resize((room["tex_w"], room["tex_h"]), Image.LANCZOS)
        # darken_thresh recalibrated 1.30 -> 1.55 (2026-07-11): faithful
        # re-renders of prop-dense rooms (crates/cots/troughs authored
        # against walls, per the base truth) legitimately have darker
        # edge bands than the open center; 1.30 was rejecting personally
        # verified good candidates at 1.33-1.47 while every real
        # vignette/void case measured >= 1.7.
        fb = verify_fullbleed(raw_resized, mask, darken_thresh=1.55)
        if not fb["ok"]:
            extreme = (fb.get("darken_ratio") or 0) > 5.0
            if extreme:
                explain = (
                    "The near-black region right at the polygon edge is almost "
                    "certainly INVENTED GEOMETRY: you likely rendered a notch, "
                    "chamfered corner, or extra wall/void that is NOT in the "
                    "geometry guide's actual silhouette (the guide's true "
                    "outline -- often a plain rectangle -- is binding; do not "
                    "add bevelled/octagonal corners or any boundary detail not "
                    "present in image 1)."
                )
            else:
                explain = (
                    "The floor material must run flush to the room's true wall "
                    "line with no darkened margin or drawn border."
                )
            verdicts.append({
                "verdict": "fail",
                "notes": (f"programmatic full-bleed check rejected: border/vignette/"
                          f"invented-void detected inside the polygon (darken_ratio="
                          f"{fb.get('darken_ratio')}, grad_ratio={fb.get('grad_ratio')}). "
                          f"{explain}"),
                "_fullbleed": fb,
            })
            continue

        # SECOND programmatic gate: an invented CORNER/INTERIOR void
        # (e.g. a chamfered/octagonal silhouette painted over a true
        # rectangle) that verify_fullbleed's uniform-edge-band comparison
        # can miss because a localized wedge is diluted by the rest of a
        # clean edge band. Caught by personal frame review on l05/room_007
        # (2026-07-11): an accepted room shipped with invented black
        # corner wedges neither gate above nor the Gemini judge flagged.
        iv = verify_no_interior_void(raw_resized, mask)
        if not iv["ok"]:
            verdicts.append({
                "verdict": "fail",
                "notes": (f"programmatic interior-void check rejected: "
                          f"{iv['black_frac']:.1%} of the TRUE floor polygon "
                          f"is painted near-black (threshold {iv['frac_thresh']:.0%}) "
                          "-- this is almost always an invented notch/chamfer/"
                          "corner cut that does not exist in the base truth's "
                          "actual silhouette. Render ordinary floor material "
                          "there instead."),
                "_interior_void": iv,
            })
            continue

        # THIRD programmatic gate: SHAPE CONFORMANCE (director's ruling,
        # 2026-07-11 -- "it still doesn't match the shape of the rooms").
        # A rectilinear plate grid stamped over an oblique polygon and
        # cropped by the mask reads as wrong even when it passes the
        # full-bleed/void checks above (those only look at brightness/
        # black-fraction, not seam orientation).
        sc = verify_shape_conformance(raw_resized, mask, wall_edges)
        if not sc["ok"]:
            verdicts.append({
                "verdict": "fail",
                "notes": (f"programmatic shape-conformance check rejected: "
                          f"mean wall-vs-plate-seam angle error "
                          f"{sc.get('mean_err'):.1f} deg (threshold "
                          f"{sc.get('angle_tol_deg')} deg) -- the plate/seam "
                          "grid is not tracking this room's actual (often "
                          "oblique) wall angles. Angle the plate rows/seams "
                          "to run parallel to the nearest wall segment shown "
                          "in the geometry guide, especially near corners "
                          "and doorways."),
                "_shape": sc,
            })
            continue

        # (RETIRED 2026-07-11 fix round) FOURTH gate was REPETITION
        # (verify_no_repetition, room-level threshold 0.42), meant to catch
        # a distinctive feature (text, arrow, unique stain) recurring at a
        # visible period. Validated on known-answer fixtures once the base
        # truth became floor-only and it turned out to be ANTI-correlated
        # with the defect: the two director-photographed arrow rooms (old
        # shipped l07/room_6 and room_7) measure peak_ratio 0.219 -- the
        # arrow appears only twice, which autocorrelation barely sees --
        # while personally-verified CLEAN prop-free candidates measure
        # 0.24-0.49 because evenly spaced rivet rows / plate pitch are
        # legitimately, strongly periodic. No threshold separates them
        # (the defect class scores LOWER than the clean class). The gate
        # only ever "worked" while baked props broke up the plate grid's
        # natural periodicity. The arrow/signage defect is now prevented
        # at the source instead: props are no longer in the base truth at
        # all, the prompt + Gemini geometry_ok judge explicitly forbid any
        # painted arrow/sign/object, and the kind materials are personally
        # reviewed signage-free. (verify_no_repetition itself remains in
        # texture_checks.py for the material-swatch gate, where the 2x2
        # tile context it was designed for still applies.)

        # FOURTH programmatic gate: GUIDE-INK LEAK. The model occasionally
        # renders the guide's cyan outline (or, before they were removed,
        # the magenta doorway stubs) as literal saturated paint on the
        # floor -- caught by eye on l05/room_4 (pink doorway rectangles).
        gi = verify_no_guide_ink(raw_resized, mask)
        if not gi["ok"]:
            verdicts.append({
                "verdict": "fail",
                "notes": (f"programmatic guide-ink check rejected: "
                          f"{gi['leak_frac']:.2%} of the floor polygon is "
                          "saturated cyan/magenta -- you rendered the "
                          "reference annotation lines as literal paint. The "
                          "cyan lines in the guide mark wall positions; the "
                          "floor under them is ordinary material, never "
                          "colored ink."),
                "_guide_ink": gi,
            })
            continue

        # FIFTH programmatic gate: DETAIL BUDGET (director's ruling,
        # 2026-07-11 fix round: shipped rooms read "a little visually
        # noisy"). Mean gradient energy inside the polygon must not exceed
        # 1.25x the kind's approved material swatch -- the floor lives
        # under live props/decals/lighting and must be QUIETER than its
        # swatch, never busier. Calibration + why intensity entropy does
        # NOT work here: see verify_detail_budget's block comment.
        db = verify_detail_budget(raw_resized, mask,
                                   Image.open(material_path).convert("RGB"))
        if not db["ok"]:
            verdicts.append({
                "verdict": "fail",
                "notes": (f"programmatic detail-budget check rejected: "
                          f"gradient energy {db['grad_ratio_vs_material']:.2f}x "
                          f"the kind's material swatch (threshold "
                          f"{db['ratio_thresh']}x) -- the floor is "
                          "over-detailed/visually noisy. Render large calm "
                          "plate areas with sparse, localized wear; overall "
                          "wear/marking density must be LOWER than the "
                          "material swatch, not higher."),
                "_detail_budget": db,
            })
            continue

        try:
            v = verify_texture(guide_path, gen_out, kind, anchor_path=material_path)
            total_cost += v.get("_cost", 0.0)
        except Exception as exc:  # noqa: BLE001
            v = {"verdict": "fail", "notes": f"verify error: {exc}"}
        v["_fullbleed"] = fb
        verdicts.append(v)

        if v.get("verdict") == "pass":
            out, tone_after = postprocess_and_save(gen_out, room)
            review_path = REVIEW_DIR / f"{stem}_room{idx:03d}.png"
            save_review_overlay(stem, idx, out, review_path)
            result = dict(key=key, status="accepted", attempt=attempt, texture=str(out),
                          cost=total_cost, verdicts=verdicts, tone_after=tone_after,
                          review_overlay=str(review_path),
                          used_neighbor_composite=neighbor_path is not None)
            progress[key] = result
            _save_progress(progress)
            return result

    # Ship NO texture rather than a bad one (property 5): a stale texture
    # from the OLD pipeline (pre-rebuild, negative-space defects and all)
    # must not survive a dropped room -- delete it so the engine's flat
    # procedural floor fallback applies, exactly as if this room had never
    # had bespoke art.
    stale = texture_out_path(room["level"], room["room_index"])
    removed_stale = stale.is_file()
    if removed_stale:
        stale.unlink()
    result = dict(key=key, status="dropped", cost=total_cost, verdicts=verdicts,
                  removed_stale_texture=removed_stale)
    progress[key] = result
    _save_progress(progress)
    return result


# Director-ordered sample set (FLOORPLANS.md), used by --sample. Kept here
# rather than re-deriving from pilot_rooms.json's 199-room census so the
# neighbor-conditioning BFS below has a small, well-understood graph.
SAMPLE_KEYS = [
    "l01/room_000", "l01/room_002", "l01/room_055", "l01/room_117",
    "l03/room_000", "l03/room_005", "l03/room_059",
    "l05/room_004", "l07/room_002",
    # director-pointed calibration pair (f52 frame, 2026-07-11): the two
    # rooms whose shipped textures photographed the baked-arrow and
    # shape-mismatch defects. Both corridor kind.
    "l07/room_006", "l07/room_007",
]


def _bfs_order(rooms: list[dict]) -> list[dict]:
    """Order `rooms` so a room with an already-visited same-level
    neighbor (per level.connects/connects_x/doors) comes after that
    neighbor, breadth-first per level. Rooms with no in-set neighbor (or
    in levels with no graph info) keep their original relative order."""
    from tools.artgen.pilot_texture_lib import get_level
    by_key = {room_key(r): r for r in rooms}
    by_level: dict[str, set[int]] = {}
    for r in rooms:
        by_level.setdefault(r["level"], set()).add(r["room_index"])

    adj: dict[str, list[str]] = {k: [] for k in by_key}
    for stem, idxs in by_level.items():
        level = get_level(stem)
        pairs = list(level.connects) + [(c[0], c[1], c[2], c[3]) for c in level.connects_x]
        pairs += [(d.a, d.ea, d.b, d.eb) for d in level.doors]
        for a, _ea, b, _eb in pairs:
            if a in idxs and b in idxs:
                ka, kb = f"{stem}/room_{a:03d}", f"{stem}/room_{b:03d}"
                adj[ka].append(kb)
                adj[kb].append(ka)

    visited: list[str] = []
    seen = set()
    remaining = list(by_key.keys())
    while remaining:
        start = remaining[0]
        queue = [start]
        while queue:
            k = queue.pop(0)
            if k in seen:
                continue
            seen.add(k)
            visited.append(k)
            for nb in adj.get(k, []):
                if nb not in seen:
                    queue.append(nb)
        remaining = [k for k in remaining if k not in seen]
    return [by_key[k] for k in visited]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--workers", type=int, default=7)
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--only-kind", type=str, default=None)
    ap.add_argument("--rooms", type=str, default=None,
                     help="comma-separated level/room_index keys to force-redo")
    ap.add_argument("--sample", action="store_true",
                     help="restrict to the director-ordered sample set (SAMPLE_KEYS), "
                          "BFS-ordered, sequential, with a neighbor-conditioning second pass")
    ap.add_argument("--only-keys", type=str, default=None,
                     help="comma-separated level/room_index keys (e.g. l07/room_005) to "
                          "RESTRICT the run's scope to (unlike --rooms, which only "
                          "force-clears progress within whatever scope is already "
                          "selected). BFS-ordered, sequential, same neighbor-conditioning "
                          "second pass as --sample -- for remediation batches picked by "
                          "an external audit rather than the hardcoded SAMPLE_KEYS.")
    args = ap.parse_args()

    pilot = load_pilot()
    rooms = pilot["rooms"]
    if args.sample:
        rooms = [r for r in rooms if room_key(r) in SAMPLE_KEYS]
        rooms = _bfs_order(rooms)
        args.workers = 1  # sequential: composites depend on already-shipped neighbors
    if args.only_keys:
        keys = set(args.only_keys.split(","))
        rooms = [r for r in rooms if room_key(r) in keys]
        rooms = _bfs_order(rooms)
        args.workers = 1
    if args.only_kind:
        rooms = [r for r in rooms if r["kind"] == args.only_kind]
    if args.limit:
        rooms = rooms[: args.limit]

    progress = _load_progress()
    if args.rooms:
        force = set(args.rooms.split(","))
        for r in rooms:
            if room_key(r) in force:
                progress.pop(room_key(r), None)

    def _run_pass(pass_rooms: list[dict], label: str, tag: str = "p1") -> None:
        todo = [r for r in pass_rooms if room_key(r) not in progress]
        print(f"[{label}] {len(pass_rooms)} rooms, {len(pass_rooms) - len(todo)} already done, "
              f"{len(todo)} to process")
        with ThreadPoolExecutor(max_workers=args.workers) as ex:
            futs = {ex.submit(process_room, r, progress, tag): r for r in todo}
            done = 0
            for fut in as_completed(futs):
                r = futs[fut]
                done += 1
                try:
                    res = fut.result()
                    print(f"[{label} {done}/{len(todo)}] {res['key']:20s} {res['status']:12s} "
                          f"cost=${res['cost']:.4f} neighbor_cond="
                          f"{res.get('used_neighbor_composite')}")
                except Exception as exc:  # noqa: BLE001
                    print(f"[{label} {done}/{len(todo)}] {room_key(r)} CRASHED: {exc}")
                    traceback.print_exc()

    _run_pass(rooms, "pass1")

    if args.sample or args.only_keys:
        # SECOND PASS (director's ruling, 2026-07-11): regenerate a sample
        # room that has an in-sample neighbor, now that pass 1 has shipped
        # textures for the whole set -- so every room sees a neighbor
        # composite for EVERY already-textured neighbor, not just the ones
        # that happened to precede it in BFS order.
        #
        # STICKY ACCEPTANCE (director's correction, 2026-07-11 fix round:
        # "are we applying textures to different, new rooms every pass?
        # ... stop doing that"): an accepted room whose accepted result
        # ALREADY used a neighbor composite is FINAL -- it is never
        # re-rolled. The original version force-redid every room with an
        # in-sample neighbor on EVERY invocation, silently replacing
        # personally-verified accepted textures with fresh model rolls --
        # so each run re-exposed the same failure modes on rooms that were
        # already done, and the set never converged. pass2 now only redoes
        # rooms that (a) have an in-sample neighbor and (b) are not
        # already accepted-with-neighbor-conditioning.
        from tools.artgen.pilot_texture_lib import get_level
        by_level: dict[str, set[int]] = {}
        for r in rooms:
            by_level.setdefault(r["level"], set()).add(r["room_index"])
        has_neighbor: set[str] = set()
        for stem, idxs in by_level.items():
            level = get_level(stem)
            pairs = list(level.connects) + [(c[0], c[1], c[2], c[3]) for c in level.connects_x]
            pairs += [(d.a, d.ea, d.b, d.eb) for d in level.doors]
            for a, _ea, b, _eb in pairs:
                if a in idxs and b in idxs:
                    has_neighbor.add(f"{stem}/room_{a:03d}")
                    has_neighbor.add(f"{stem}/room_{b:03d}")

        def _final(k: str) -> bool:
            p = progress.get(k, {})
            return (p.get("status") == "accepted"
                    and p.get("used_neighbor_composite") is True)

        redo = [r for r in rooms
                if room_key(r) in has_neighbor and not _final(room_key(r))]
        # BACKUP pass-1 results before force-redoing: if a pass-2 regen
        # fails its gates, the room must KEEP its accepted pass-1 texture
        # (bug caught 2026-07-11: pass 2 deleted an accepted pass-1
        # texture when the neighbor-conditioned regen dropped).
        backups: dict[str, tuple[dict, bytes | None]] = {}
        for r in redo:
            k = room_key(r)
            tex = texture_out_path(r["level"], r["room_index"])
            backups[k] = (progress.get(k),
                          tex.read_bytes() if tex.is_file() else None)
            progress.pop(k, None)
        _run_pass(redo, "pass2-neighbor-cond", tag="p2")
        progress.update(_load_progress())
        for r in redo:
            k = room_key(r)
            prev_result, prev_bytes = backups[k]
            now = progress.get(k, {})
            if now.get("status") != "accepted" and prev_result is not None \
                    and prev_result.get("status") == "accepted" and prev_bytes:
                tex = texture_out_path(r["level"], r["room_index"])
                tex.parent.mkdir(parents=True, exist_ok=True)
                tex.write_bytes(prev_bytes)
                prev_result = dict(prev_result)
                prev_result["note"] = ("pass2 neighbor-conditioned regen failed its "
                                        "gates; kept the accepted pass1 texture")
                progress[k] = prev_result
                print(f"[pass2-restore] {k}: kept accepted pass1 texture")
        _save_progress(progress)

    final_progress = _load_progress()
    VERIFY_OUT.write_text(json.dumps(final_progress, indent=2))
    print(f"Wrote {VERIFY_OUT}")


if __name__ == "__main__":
    main()
