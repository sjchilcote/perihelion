#!/usr/bin/env python3
"""Doused-slot A/B probe (gate-63 instrument): does each body tint
actually change pixels for adversary kinds, at every blink phase?

Draw the same live frame twice per phase — slot set vs. slot doused —
and count changed pixels. Run BEFORE believing any body-tint claim.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np

from perihelion.levels import LevelBuilder
from perihelion.render import Renderer
from perihelion.sim import GameSession, InputFrame


def diff_px(renderer, slot, eid, value):
    d = getattr(renderer, slot)
    d.clear()
    a = renderer.draw((640, 360)).copy()
    d[eid] = value
    b = renderer.draw((640, 360)).copy()
    d.clear()
    return int((a != b).any(axis=-1).sum())


def probe(kind):
    b = LevelBuilder("PROBE", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (200.0, 150.0), kind)
    s.tick(InputFrame())
    r = Renderer(s)
    r.consume_fx(s.fx)
    print(f"--- {kind} (eid {eid}) ---")
    # arrival flash blinks on (rf//3)%2==0: probe every phase 1..26
    for slot, values in [("_arrival_flash", [26, 25, 24, 23, 22, 21, 4, 3, 1]),
                         ("_attacker_flash", [16, 8, 1]),
                         ("_hitflash", [3])]:
        px = {v: diff_px(r, slot, eid, v) for v in values}
        lit = {v: n for v, n in px.items() if n > 0}
        print(f"{slot:16s} {px}  -> {'LIVE' if lit else 'DEAD'}")


for k in ("lacuna", "vagrant", "grunt"):
    probe(k)
