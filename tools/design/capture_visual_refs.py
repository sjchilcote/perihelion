#!/usr/bin/env python3
"""Capture the reference frames for the marrow visual-pass consult.

Three worlds, same renderer, same 0.45 zoom, same 640x360:
  ow_ref.png      -- an OTHERWORLD-kind chamber (irregular polygon, lit),
                     the register the marrow should transition into
  ow_rect.png     -- the same kind in a plain rectangle, for comparison
  world_ref.png   -- an ordinary gauntlet-style chamber (dock kind)

The hub-as-built frames come from out/organ_visual/ (in-situ captures).
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np

import necore

from perihelion.levels import LevelBuilder
from perihelion.render import Renderer
from perihelion.sim import GameSession, InputFrame

OUT = ROOT / "out" / "consult_visual_refs"
OUT.mkdir(parents=True, exist_ok=True)


def shoot(name, build):
    b = LevelBuilder(name.upper(), 1)
    pid_polygon = build(b)
    level = b.build()
    s = GameSession(level, seed=11, screen=(640, 360), zoom=0.45)
    r = Renderer(s)
    for _ in range(3):
        s.tick(InputFrame())
    r.consume_fx(s.fx)
    frame = r.draw((640, 360))
    necore.write_png(str(OUT / f"{name}.png"), 640, 360,
                     np.ascontiguousarray(frame.transpose(1, 0, 2)).tobytes())
    print(f"wrote {OUT / (name + '.png')}")


def ow_irregular(b):
    # an irregular convex chamber — six unequal edges, nothing square
    verts = [(0, 60), (80, 220), (300, 200), (360, 40), (260, -30), (90, 0)]
    c = b.polygon(verts, kind="otherworld")
    b.player(c, (180, 100))
    b.exit(c, (300, 160))
    b.light(c, (180, 90), color=(160, 200, 255), intensity=0.9, radius=240.0)
    return c


def ow_rect(b):
    c = b.rect(0, 0, 360, 240, kind="otherworld")
    b.player(c, (180, 120))
    b.exit(c, (320, 200))
    b.light(c, (180, 110), color=(160, 200, 255), intensity=0.9, radius=240.0)
    return c


def world(b):
    c = b.rect(0, 0, 360, 240, kind="dock")
    b.player(c, (180, 120))
    b.exit(c, (320, 200))
    b.light(c, (180, 110), color=(255, 240, 220), intensity=1.0, radius=260.0)
    return c


shoot("ow_ref", ow_irregular)
shoot("ow_rect", ow_rect)
shoot("world_ref", world)
