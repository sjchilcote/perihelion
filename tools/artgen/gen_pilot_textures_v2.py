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
    SCRATCH, TEXTURES_ROOT, apply_mask, basetruth_path, build_room_prompt,
    load_pilot, make_guide, room_mask, texture_out_path,
)
from tools.artgen.texture_checks import (
    grade_toward, in_window, region_tone, verify_fullbleed,
    verify_no_interior_void,
)

GUIDE_DIR = SCRATCH / "guides"
MATERIALS_DIR = SCRATCH / "materials"
WINDOWS_PATH = Path(__file__).resolve().parent / "kind_windows.json"
PROGRESS_PATH = SCRATCH / "pilot_progress_v2.json"
VERIFY_OUT = Path(__file__).resolve().parent / "pilot_verify_v2.json"
GEN_SCRATCH = SCRATCH / "gen_rooms_v2"

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


def process_room(room: dict, progress: dict) -> dict:
    key = room_key(room)
    kind = room["kind"]
    material_path = MATERIALS_DIR / f"{kind}.png"
    guide_path = GUIDE_DIR / room["level"] / f"room_{room['room_index']:03d}.png"
    if not guide_path.exists():
        make_guide(room["level"], room["room_index"], guide_path)
    prompt = build_room_prompt(kind)
    GEN_SCRATCH.mkdir(parents=True, exist_ok=True)
    mask = _sized_mask(room)

    total_cost = 0.0
    verdicts = []
    for attempt in (1, 2):
        gen_out = GEN_SCRATCH / f"{room['level']}_room{room['room_index']:03d}_a{attempt}.png"
        this_prompt = prompt
        if attempt == 2 and verdicts:
            this_prompt += (
                f"\n\nPREVIOUS ATTEMPT FAILED REVIEW: {verdicts[-1].get('notes', '')} "
                "Fix that specific problem this time."
            )
        try:
            gr = generate_image(this_prompt, gen_out,
                                reference_images=[str(guide_path), str(material_path)])
            total_cost += gr["cost"]
        except Exception as exc:  # noqa: BLE001
            verdicts.append({"verdict": "fail", "notes": f"generation error: {exc}"})
            continue

        # PROGRAMMATIC gate first (property 1): reject painted negative
        # space before spending on Gemini judging at all.
        raw_im = Image.open(gen_out).convert("RGB")
        raw_resized = raw_im.resize((room["tex_w"], room["tex_h"]), Image.LANCZOS)
        fb = verify_fullbleed(raw_resized, mask)
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

        try:
            v = verify_texture(guide_path, gen_out, kind, anchor_path=material_path)
            total_cost += v.get("_cost", 0.0)
        except Exception as exc:  # noqa: BLE001
            v = {"verdict": "fail", "notes": f"verify error: {exc}"}
        v["_fullbleed"] = fb
        verdicts.append(v)

        if v.get("verdict") == "pass":
            out, tone_after = postprocess_and_save(gen_out, room)
            result = dict(key=key, status="accepted", attempt=attempt, texture=str(out),
                          cost=total_cost, verdicts=verdicts, tone_after=tone_after)
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


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--workers", type=int, default=7)
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--only-kind", type=str, default=None)
    ap.add_argument("--rooms", type=str, default=None,
                     help="comma-separated level/room_index keys to force-redo")
    args = ap.parse_args()

    pilot = load_pilot()
    rooms = pilot["rooms"]
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

    todo = [r for r in rooms if room_key(r) not in progress]
    print(f"{len(rooms)} rooms total, {len(rooms) - len(todo)} already done, {len(todo)} to process")

    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {ex.submit(process_room, r, progress): r for r in todo}
        done = 0
        for fut in as_completed(futs):
            r = futs[fut]
            done += 1
            try:
                res = fut.result()
                print(f"[{done}/{len(todo)}] {res['key']:20s} {res['status']:12s} cost=${res['cost']:.4f}")
            except Exception as exc:  # noqa: BLE001
                print(f"[{done}/{len(todo)}] {room_key(r)} CRASHED: {exc}")
                traceback.print_exc()

    final_progress = _load_progress()
    VERIFY_OUT.write_text(json.dumps(final_progress, indent=2))
    print(f"Wrote {VERIFY_OUT}")


if __name__ == "__main__":
    main()
