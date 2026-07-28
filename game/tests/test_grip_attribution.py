"""Run-46 confirmed blocker, pinned: the gripping-warden branch is the
ONE place attribution matters most (the grip is the deadliest sustained
damage in the game), and it reassigns fill/rim — any ordering slip makes
the red attacker-blink dead code exactly there.

The engulf vignette tints the whole frame, so bit-exact colors don't
survive to the composite; these are DIFFERENTIAL measurements instead:
flip exactly one signal (blink phase / hitflash) and require the frame
to change at the warden with the right hue.
"""
from __future__ import annotations

import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import numpy as np
import pygame

from perihelion.capture import CaptureSpec
from perihelion.levels import LevelBuilder
from perihelion.render import Renderer
from perihelion.sim import GameSession, InputFrame


def _gripping_scene():
    pygame.init()
    b = LevelBuilder("GRIP", 1)
    room = b.rect(0, 0, 400, 300)
    b.player(room, (200, 150))
    s = GameSession(b.build(), seed=5, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(room, (215, 150), "warden")
    s.enemies[eid]["engulf"] = "hold"
    s.captures.begin(CaptureSpec(captor_id=eid, captive_id=s.pid,
                                 pull_speed=0.0, damage_per_second=0.0))
    r = Renderer(s)
    for _ in range(2):
        s.tick(InputFrame())
        r.consume_fx(s.fx)
    assert s.captures.held_by(s.pid) == eid, "grip did not take"
    return s, r, eid


def _changed(r, eid, key, on, off):
    surf = pygame.Surface((640, 360))
    getattr(r, key)[eid] = on
    a = r.draw(surf).astype(int)
    getattr(r, key)[eid] = off
    b = r.draw(surf).astype(int)
    diff = np.abs(a - b).sum(axis=2)
    ys, xs = np.where(diff > 10)
    return a[ys, xs]


def test_gripping_warden_rim_blinks_red_while_it_grinds():
    s, r, eid = _gripping_scene()
    # af=16 -> (16//2)%2==0 -> blink ON; af=14 -> OFF
    px = _changed(r, eid, "_attacker_flash", 16, 14)
    assert len(px) > 20, (
        f"blink phase flip changed only {len(px)}px on a gripping "
        "warden — the grip branch is overwriting the attribution "
        "channel again (run 46 blocker)")
    red = (px[:, 0] > 200) & (px[:, 1] < 110) & (px[:, 2] < 110)
    assert red.sum() > 10, (
        f"blink-on pixels are not red-dominant ({px[:8].tolist()}...)")


def test_gripping_warden_rim_flashes_bright_on_the_players_hit():
    s, r, eid = _gripping_scene()
    r._attacker_flash.pop(eid, None)
    px = _changed(r, eid, "_hitflash", 3, 0)
    assert len(px) > 20, (
        f"hitflash flip changed only {len(px)}px on a gripping warden — "
        "the your-shot-landed signal is missing during the grip")
    bright = px.sum(axis=1) > 450
    assert bright.sum() > 10, (
        f"hit pixels are not bright ({px[:8].tolist()}...)")
