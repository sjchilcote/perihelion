"""tools/artgen/gen_pilot_textures.py

Main pilot driver: for every room in pilot_rooms.json, generate a bespoke
texture (image-edit mode: refs = [kind style anchor, room base truth]),
verify with Gemini vision, rework once on failure, post-process (resize to
exact target size, reapply the room-polygon black mask), and save to
game/perihelion/assets/textures/<level>/room_<idx>.png.

Checkpointed to scratch/pilot_progress.json so a crash/interrupt can
resume without re-spending on already-decided rooms.

Usage:
    uv run python -m tools.artgen.gen_pilot_textures [--workers 7] [--limit N]
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
GUIDE_DIR = SCRATCH / "guides"

ANCHOR_DIR = SCRATCH / "anchors_final"
ANCHOR_MAP = json.loads((SCRATCH / "anchor_map.json").read_text())
PROGRESS_PATH = SCRATCH / "pilot_progress.json"
VERIFY_OUT = Path(__file__).resolve().parent / "pilot_verify.json"
GEN_SCRATCH = SCRATCH / "gen_rooms"

_lock = threading.Lock()


def _load_progress() -> dict:
    if PROGRESS_PATH.exists():
        return json.loads(PROGRESS_PATH.read_text())
    return {}


def _save_progress(progress: dict) -> None:
    with _lock:
        PROGRESS_PATH.write_text(json.dumps(progress, indent=2))


def room_key(r: dict) -> str:
    return f"{r['level']}/room_{r['room_index']:03d}"


def postprocess_and_save(gen_path: Path, room: dict) -> Path:
    im = Image.open(gen_path).convert("RGB")
    im = im.resize((room["tex_w"], room["tex_h"]), Image.LANCZOS)
    mask = room_mask(room["level"], room["room_index"])
    im = apply_mask(im, mask)
    out = texture_out_path(room["level"], room["room_index"])
    out.parent.mkdir(parents=True, exist_ok=True)
    im.save(out)
    return out


def is_anchor_room(room: dict) -> str | None:
    for kind, info in ANCHOR_MAP.items():
        if info["level"] == room["level"] and info["room_index"] == room["room_index"]:
            return kind
    return None


def process_room(room: dict, progress: dict) -> dict:
    key = room_key(room)
    kind = room["kind"]
    anchor_kind_here = is_anchor_room(room)

    if anchor_kind_here:
        # This exact room *is* the style anchor for its kind: reuse the
        # accepted anchor image directly as this room's final texture, no
        # extra generation/verify spend.
        anchor_path = ANCHOR_DIR / f"{anchor_kind_here}.png"
        out = postprocess_and_save(anchor_path, room)
        result = dict(key=key, status="anchor_reuse", texture=str(out), cost=0.0)
        progress[key] = result
        _save_progress(progress)
        return result

    anchor_path = ANCHOR_DIR / f"{kind}.png"
    guide_path = GUIDE_DIR / room["level"] / f"room_{room['room_index']:03d}.png"
    if not guide_path.exists():
        make_guide(room["level"], room["room_index"], guide_path)
    prompt = build_room_prompt(kind)
    GEN_SCRATCH.mkdir(parents=True, exist_ok=True)

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
            gr = generate_image(this_prompt, gen_out, reference_images=[str(guide_path), str(anchor_path)])
            total_cost += gr["cost"]
        except Exception as exc:  # noqa: BLE001
            verdicts.append({"verdict": "fail", "notes": f"generation error: {exc}"})
            continue

        try:
            v = verify_texture(guide_path, gen_out, kind, anchor_path=anchor_path)
            total_cost += v.get("_cost", 0.0)
        except Exception as exc:  # noqa: BLE001
            v = {"verdict": "fail", "notes": f"verify error: {exc}"}
        verdicts.append(v)

        if v.get("verdict") == "pass":
            out = postprocess_and_save(gen_out, room)
            result = dict(key=key, status="accepted", attempt=attempt, texture=str(out),
                          cost=total_cost, verdicts=verdicts)
            progress[key] = result
            _save_progress(progress)
            return result

    # Both attempts failed: no texture shipped, fallback stays the
    # existing procedural look.
    result = dict(key=key, status="dropped", cost=total_cost, verdicts=verdicts)
    progress[key] = result
    _save_progress(progress)
    return result


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--workers", type=int, default=7)
    ap.add_argument("--limit", type=int, default=None)
    ap.add_argument("--only-kind", type=str, default=None)
    args = ap.parse_args()

    pilot = load_pilot()
    rooms = pilot["rooms"]
    if args.only_kind:
        rooms = [r for r in rooms if r["kind"] == args.only_kind]
    if args.limit:
        rooms = rooms[: args.limit]

    progress = _load_progress()
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

    # Write a consolidated verify log.
    final_progress = _load_progress()
    VERIFY_OUT.write_text(json.dumps(final_progress, indent=2))
    print(f"Wrote {VERIFY_OUT}")


if __name__ == "__main__":
    main()
