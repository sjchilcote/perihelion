"""Run-44 confirmed blocker, pinned: pickup floaters must render when
every OTHER effect pool is empty. The _draw_effects early-return guard
omitted _floaters, so pickup text drew only while gibs/sparks/bolts/
screams happened to be live — quiet out-of-combat pickups (the exact
case the legibility law targets) showed no world-space cause for HUD
changes."""
from __future__ import annotations

import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import numpy as np
from perihelion.levels import LevelBuilder
from perihelion.render import Renderer
from perihelion.sim import GameSession, InputFrame


def test_floater_renders_with_all_other_pools_empty():
    b = LevelBuilder("FLOAT", 1)
    room = b.rect(0, 0, 400, 300)
    b.player(room, (200, 150))
    s = GameSession(b.build(), seed=3, screen=(640, 360), zoom=0.45)
    r = Renderer(s)
    surf = (640, 360)
    idle = InputFrame()
    for _ in range(5):
        s.tick(idle)
        r.consume_fx(s.fx)
    px, py = s.player_pos().local()
    s.spawn_pickup(s.player_polygon(), (px + 6, py), "ammo_shell")
    for _ in range(3):
        s.tick(idle)
        r.consume_fx(s.fx)
    # force the guard case: every non-floater pool empty
    r._gibs, r._sparks, r._bolts, r._screams = [], [], [], []
    assert r._floaters, "pickup never produced a floater"
    frame = r.draw(surf)
    bright = int(((frame[:, :, 1] > 200) & (frame[:, :, 0] > 150)).sum())
    assert bright > 100, (
        f"floater text missing with empty effect pools ({bright} px) — "
        "the _draw_effects guard dropped _floaters again")
