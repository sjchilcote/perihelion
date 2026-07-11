"""tools/artgen/room_basetruth.py

Base-truth captures for the texture pilot: for every room listed in
tools/artgen/pilot_rooms.json, render the room's CURRENT authored look
(floor fill + detail prims -- the existing procedural prop language from
game/perihelion/render.py) at 3 px/world-unit in the room's own local
frame. No entities, no darkness/fog, no camera -- just the flat floor and
its props, the priors the image model will be asked to reinterpret.

Reuses Renderer._draw_floor / Renderer._draw_detail directly (the same
code the live game calls) rather than reimplementing the prop language.
Each level file is loaded standalone (not streamed), so every pilot room
is addressed by (level stem, room index) exactly as authored in
levels/<stem>.json.

Usage:
    uv run python tools/artgen/room_basetruth.py --out DIR
    uv run python tools/artgen/room_basetruth.py --out DIR --pilot tools/artgen/pilot_rooms.json
"""
from __future__ import annotations

import argparse
import json
import math
import os
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import pygame  # noqa: E402
import necore  # noqa: E402

from perihelion.levels import load_level  # noqa: E402
from perihelion.render import Renderer, _PygameCanvas  # noqa: E402
from perihelion.sim import GameSession  # noqa: E402

DEFAULT_PILOT = ROOT / "tools" / "artgen" / "pilot_rooms.json"


def render_room(renderer: Renderer, room_idx: int, px_per_unit: float) -> "pygame.Surface":
    level = renderer.session.level
    verts = level.room_verts[room_idx]
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    x0, x1 = min(xs), max(xs)
    y0, y1 = min(ys), max(ys)
    w_px = max(1, math.ceil((x1 - x0) * px_per_unit))
    h_px = max(1, math.ceil((y1 - y0) * px_per_unit))

    surf = pygame.Surface((w_px, h_px))
    surf.fill((0, 0, 0))  # pixels outside the room polygon stay black

    xform = necore.mat_mul(necore.mat_scale(px_per_unit, px_per_unit),
                            necore.mat_translate(-x0, -y0))
    room_screen = [necore.mat_apply(xform, x, y) for x, y in verts]

    canvas = _PygameCanvas(surf)
    # depth=0: no fog/darkness dimming -- the flat authored appearance
    renderer._draw_floor(canvas, room_idx, 0, room_screen)
    # _draw_detail (PROPS: crates, consoles, vent grates, pipe runs, floor
    # chevrons -- every "line"/"polyline"/"poly"/"dot" prim) is DELIBERATELY
    # NOT called here (2026-07-11 fix-round, director's correction: "the
    # props should not be baked in either -- comprehend the concept of a
    # texture"). A texture is the tileable floor MATERIAL, not an
    # illustration of scene content. Renderer._draw_world (render.py
    # ~line 1663-1664) draws _draw_floor then _draw_detail UNCONDITIONALLY
    # every frame, textured room or not -- every prop (crate, console,
    # chevron, pipe run) is ALREADY drawn live, every frame, by the game's
    # real vector prop layer regardless of what the floor texture shows.
    # Baking a painted illustration of the same crate/chevron/pipe into the
    # floor art is not "informing the material," it's re-illustrating scene
    # content the engine already owns -- redundant at best (a solid prop
    # fully covers its baked echo) and a visible doubled/ghosted mark at
    # worst (a thin line prim does not). The base truth here is FLOOR FILL
    # ONLY; wall/doorway geometry still reaches the model via make_guide's
    # explicit cyan wall-line overlay, and per-kind wear concentration
    # still reaches it via the FLOORPLAN_NOTE text prompt injection
    # (pilot_texture_lib.py) -- neither depends on this render.
    # Deliberate, LABELED prop-to-paint substitution ("draw a hydroponics
    # rack where this box is") is a real, sound technique the director
    # named as the correct way to let specific props steer the paint job --
    # it is NOT implemented by this pipeline yet; a future round should add
    # it explicitly (per-prop-kind prompt clauses tied to prop screen
    # position), not by re-adding the whole detail render as an implicit
    # "copy this" reference.
    return surf


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True, help="output directory root")
    ap.add_argument("--pilot", default=str(DEFAULT_PILOT))
    args = ap.parse_args()

    pilot = json.loads(Path(args.pilot).read_text())
    px_per_unit = pilot.get("px_per_unit", 3)
    out_root = Path(args.out)
    out_root.mkdir(parents=True, exist_ok=True)

    by_level: dict[str, list[dict]] = {}
    for r in pilot["rooms"]:
        by_level.setdefault(r["level"], []).append(r)

    failures = []
    written = 0
    for stem, rooms in sorted(by_level.items()):
        level_path = ROOT / "levels" / f"{stem}.json"
        level = load_level(level_path)
        session = GameSession(level)
        renderer = Renderer(session, backend="pygame")
        level_out = out_root / stem
        level_out.mkdir(parents=True, exist_ok=True)
        for r in rooms:
            idx = r["room_index"]
            try:
                if idx >= len(level.room_verts):
                    raise IndexError(
                        f"room {idx} out of range (level has {len(level.room_verts)})")
                surf = render_room(renderer, idx, px_per_unit)
                out_path = level_out / f"room_{idx:03d}.png"
                pygame.image.save(surf, str(out_path))
                written += 1
            except Exception as exc:  # noqa: BLE001 - report and continue
                failures.append(dict(level=stem, room_index=idx, error=str(exc)))

    print(json.dumps(dict(written=written, failures=failures,
                          out_dir=str(out_root)), indent=2))
    if failures:
        sys.exit(1)


if __name__ == "__main__":
    main()
