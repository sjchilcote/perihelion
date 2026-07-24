"""Director-ordered flicker gate (2026-07-10): a square polygon with four
square neighbors, high-contrast decals in every neighbor, rendered through
the REAL game path every tick while the player tours and strafes across
every doorway threshold. Pixel truth: a neighbor's decal ink must never
collapse between consecutive ticks while the player is barely moving.

The defect class this guards: visible_set wedge clips carrying an adjacent
duplicate vertex whose zero-length edge fabricated a phantom half-plane
(geom::DEGENERATE_EDGE), blinking a polygon's entire prim/entity layer at up
to 30Hz. Root-caused from seed-7 campaign tick 740; fixed engine-side
(canonical clip output + degenerate-edge guards in every consumer).
"""
from __future__ import annotations

import importlib.util
import math
import os
import random
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pygame
import pytest

_TOOL = Path(__file__).resolve().parents[2] / "tools" / "playtest" / "flicker_cross.py"
_spec = importlib.util.spec_from_file_location("flicker_cross", _TOOL)
flicker_cross = importlib.util.module_from_spec(_spec)
sys.modules["flicker_cross"] = flicker_cross
_spec.loader.exec_module(flicker_cross)

from perihelion.render import Renderer, INTERNAL_W, INTERNAL_H  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402


@pytest.mark.parametrize("braided", [False, True], ids=["cross", "braided"])
def test_neighbor_decor_never_blinks(braided):
    pygame.init()
    level, polygons = flicker_cross.build_world(braided)
    session = GameSession(level, seed=7, screen=(INTERNAL_W, INTERNAL_H))
    probe_polygons = {k: polygons[k] for k in flicker_cross.NEIGHBORS}
    flicker_cross.plant_decals(session, polygons, probe_polygons)
    ren = Renderer(session)
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    decal_local = {name: [(x, y) for _, x, y, _, _ in session.decals[r]]
                   for name, r in probe_polygons.items()}
    prev = None
    prev_pos = None
    events = []
    for tick in range(1, 700):
        mx, my = flicker_cross.movement(tick)
        session.tick(InputFrame(mx=mx, my=my, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                                fire=False, alt=False, interact=False, weapon=0))
        random.seed(tick)
        ren.consume_fx(session.fx)
        pygame.surfarray.blit_array(surf, ren.draw(surf))
        vis = session.visible()
        by_polygon = {}
        for inst in vis:
            by_polygon.setdefault(inst[0], []).append(inst)
        px, py = session.player_pos()
        moved = 0.0 if prev_pos is None else math.hypot(px - prev_pos[0], py - prev_pos[1])
        prev_pos = (px, py)
        row = {}
        for name, r in probe_polygons.items():
            insts = by_polygon.get(r, [])
            ink = max((flicker_cross.probe_ink(surf, flicker_cross._xform_of(i),
                                               decal_local[name])
                       for i in insts), default=0)
            row[name] = (len(insts), ink)
        if prev is not None:
            for name in probe_polygons:
                (pi, pink), (ci, cink) = prev[name], row[name]
                if pi > 0 and pink >= 15 and moved < 3.0 and \
                        (ci == 0 or cink < 0.3 * pink):
                    events.append((tick, name, pink, cink, moved))
        prev = row
    assert not events, f"decor blinked: {events[:5]}"
