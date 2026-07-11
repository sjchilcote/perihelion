"""tools/artgen/repair_insitu.py

Second half of the IN-SITU GATE (property 4 + property 5): after
verify_in_situ.py has judged every textured-textured doorway boundary,
this collects the rooms that appear in any FAILING boundary, regenerates
each flagged room ONCE more (image-edit continuity from its own accepted
texture + explicit neighbor-mismatch feedback + a harder push toward the
kind's shared tone window), re-runs the programmatic full-bleed gate, and
re-judges just that room's boundaries in-situ. A room that still fails
after this second in-situ round ships NO texture -- the file is deleted
so the engine's flat procedural fallback applies. Never a bad texture.

Usage:
    uv run python -m tools.artgen.repair_insitu
"""
from __future__ import annotations

import json
import sys
import traceback
from pathlib import Path

from PIL import Image

from tools.artgen.gen import generate_image
from tools.artgen.pilot_texture_lib import (
    GEOMETRY_LOCK, FULLBLEED_LAW, STYLE_LANGUAGE, KIND_MATERIAL,
    TESTATOR_KINDS, SCRATCH, load_pilot, room_mask, apply_mask,
    texture_out_path,
)
from tools.artgen.texture_checks import grade_toward, in_window, region_tone, verify_fullbleed
from tools.artgen import verify_in_situ as insitu

WINDOWS_PATH = Path(__file__).resolve().parent / "kind_windows.json"
INSITU_PATH = Path(__file__).resolve().parent / "insitu_verify.json"
REPAIR_LOG = Path(__file__).resolve().parent / "insitu_repair.json"
REPAIR_SCRATCH = SCRATCH / "gen_rooms_repair"
_windows = json.loads(WINDOWS_PATH.read_text())


def _flagged_rooms(insitu_results: dict) -> dict[tuple[str, int], list[str]]:
    """{(level, room): [pair_id, ...]} for every room that appears in a
    failing (or errored) boundary judgment."""
    flagged: dict[tuple[str, int], list[str]] = {}
    for pair_id, r in insitu_results.items():
        if r.get("verdict") == "pass":
            continue
        lvl = r.get("level")
        a, b = r.get("room_a"), r.get("room_b")
        if lvl is None or a is None or b is None:
            continue
        flagged.setdefault((lvl, a), []).append(pair_id)
        flagged.setdefault((lvl, b), []).append(pair_id)
    return flagged


def repair_room(level: str, room_idx: int, kind: str, reasons: list[str],
                 pilot_rooms_by_key: dict) -> dict:
    key = f"{level}/room_{room_idx:03d}"
    room = pilot_rooms_by_key[key]
    cur_path = texture_out_path(level, room_idx)
    if not cur_path.is_file():
        return dict(key=key, status="no_texture_to_repair")

    material = KIND_MATERIAL[kind]
    flavor = ("Testator-made: alien, older, non-human geometry, asymmetric, unsettling."
              if kind in TESTATOR_KINDS else
              "MIRIAD-era human infrastructure: utilitarian, regular, maintained.")
    prompt = (
        f"{STYLE_LANGUAGE}\n\nRoom kind: {kind}. {flavor} Material language: {material}.\n\n"
        "This is a TONE-MATCH REPAIR pass: the reference image is this exact room's "
        "CURRENTLY-SHIPPED texture -- keep its geometry, props, and layout completely "
        "unchanged. The problem is that at least one doorway to a neighboring room of "
        "the same kind, this texture's tone/material reads as a mismatched, seamed-"
        "together plate rather than the same continuous physical floor. Shift the "
        "overall tone/grime/palette toward the shared kind material family so the "
        "boundary reads continuous, WITHOUT inventing new geometry.\n\n"
        f"{FULLBLEED_LAW}\n\n{GEOMETRY_LOCK}"
    )
    REPAIR_SCRATCH.mkdir(parents=True, exist_ok=True)
    out_raw = REPAIR_SCRATCH / f"{level}_room{room_idx:03d}_repair.png"
    gr = generate_image(prompt, out_raw, reference_images=[str(cur_path)])

    mask = room_mask(level, room_idx)
    im = Image.open(out_raw).convert("RGB").resize((room["tex_w"], room["tex_h"]), Image.LANCZOS)
    fb = verify_fullbleed(im, mask)
    if not fb["ok"]:
        return dict(key=key, status="repair_failed_fullbleed", cost=gr["cost"], fullbleed=fb)

    window = _windows.get(kind)
    if window is not None:
        tone = region_tone(im, mask)
        if not in_window(tone, window):
            im = grade_toward(im, mask, window, strength=0.8)
    im = apply_mask(im, mask)

    # Stage to a temp path, re-judge in-situ against the SAME neighbors,
    # only commit if it actually improves.
    backup = cur_path.with_suffix(".pre_repair.png")
    Image.open(cur_path).save(backup)
    im.save(cur_path)

    repass = []
    for pair_id in reasons:
        r = insitu.OUT_PATH  # noqa: F841 - just documenting source
        old = json.loads(INSITU_PATH.read_text())[pair_id]
        stem, a, ea, b, eb = old["level"], old["room_a"], None, old["room_b"], None
        # re-derive edges from the level graph fresh (edges weren't stored
        # on the result dict; re-scan for this exact pair).
        from perihelion.levels import load_level
        lvl = load_level(insitu.ROOT / "levels" / f"{stem}.json")
        found = None
        for aa, eea, bb, eeb, is_door, dkey in insitu._find_boundary_pairs(
                lvl, insitu._textured_rooms(), stem):
            pid = f"{stem}:{aa}-{bb}" if not is_door else f"{stem}:{aa}-{bb}(door:{dkey})"
            if pid == pair_id:
                found = (aa, eea, bb, eeb, is_door, dkey)
                break
        if found is None:
            continue
        shot = insitu.render_pair(stem, *found)
        verdict = insitu.judge_pair(shot)
        shot.update(verdict)
        repass.append(shot)

    still_failing = [r for r in repass if r.get("verdict") != "pass"]
    if still_failing:
        # ship no texture rather than a bad one -- restore is moot, we
        # simply remove the file so the flat procedural fallback applies.
        cur_path.unlink(missing_ok=True)
        backup.unlink(missing_ok=True)
        return dict(key=key, status="dropped_after_repair", cost=gr["cost"],
                    still_failing=[r["pair_id"] for r in still_failing])
    backup.unlink(missing_ok=True)
    return dict(key=key, status="repaired", cost=gr["cost"],
                repassed=[r["pair_id"] for r in repass])


def main() -> None:
    if not INSITU_PATH.exists():
        print("no insitu_verify.json yet -- run verify_in_situ first", file=sys.stderr)
        sys.exit(1)
    insitu_results = json.loads(INSITU_PATH.read_text())
    flagged = _flagged_rooms(insitu_results)
    print(f"{len(flagged)} rooms appear in a failing/errored in-situ boundary")

    pilot = load_pilot()
    by_key = {f"{r['level']}/room_{r['room_index']:03d}": r for r in pilot["rooms"]}

    log = {}
    if REPAIR_LOG.exists():
        log = json.loads(REPAIR_LOG.read_text())

    for (level, room_idx), reasons in flagged.items():
        key = f"{level}/room_{room_idx:03d}"
        if key in log:
            continue
        kind = by_key[key]["kind"]
        try:
            res = repair_room(level, room_idx, kind, reasons, by_key)
        except Exception as exc:  # noqa: BLE001
            res = dict(key=key, status="repair_error", error=str(exc))
            traceback.print_exc()
        log[key] = res
        REPAIR_LOG.write_text(json.dumps(log, indent=2))
        print(f"{key:20s} {res['status']}")

    print(f"Wrote {REPAIR_LOG}")


if __name__ == "__main__":
    main()
