"""The crossing has to reach the screen, for the kinds that cross.

Gate 73 failed on this exact hole: the tint was applied in
`_draw_enemy`, but lacuna and vagrant — the only kinds that ever cross —
are drawn by `_draw_adversary`, so the 48-tick "crossing built to be
seen" rendered zero pixels. It was the third time that function has
silently dropped a body tint (gates 63 and 67 were the others), which is
why this is a test and not a comment.

The method is the doused-slot A/B the gate itself used: render the same
frame twice, once with the flash live and once without, and require the
picture to actually differ.
"""
from __future__ import annotations

import os

import numpy as np

os.environ.setdefault("PERIHELION_INTERNAL_RES", "640x360")

from perihelion.levels import LevelBuilder            # noqa: E402
from perihelion.render import Renderer                # noqa: E402
from perihelion.sim import GameSession, InputFrame    # noqa: E402

SCREEN = (640, 360)


def _scene(kind):
    b = LevelBuilder("CROSSVIS", 1)
    r0 = b.rect(0, 0, 900, 700)
    b.player(r0, (450, 350))
    s = GameSession(b.build(), seed=4, screen=SCREEN, zoom=0.45)
    s.tick(InputFrame())
    eid = s.spawn_enemy(r0, (90.0, 0.0), kind)
    s.tick(InputFrame())
    return s, eid


def _frame(ren, s):
    return np.ascontiguousarray(np.asarray(ren.draw(SCREEN))).copy()


def _differs(kind, flash_attr):
    """Most pixels any single flash value changes.

    Sampled across a span rather than at one value because the ARRIVAL
    tint BLINKS — `(rf // 3) % 2 == 0` — so a single probe lands in an
    off frame half the time and reports a live tint as dead. (It did:
    this test's first cut failed its own control at rf=40.)"""
    s, eid = _scene(kind)
    ren = Renderer(s)
    base = _frame(ren, s).astype(np.int16)
    best = 0
    for v in range(36, 48):
        getattr(ren, flash_attr)[eid] = v
        lit = _frame(ren, s).astype(np.int16)
        best = max(best, int((np.abs(base - lit) > 6).sum()))
    return best


def test_the_crossing_tint_reaches_the_screen():
    """For BOTH kinds that can cross. A crossing nobody can see is the
    despawn this whole feature exists to abolish."""
    for kind in ("lacuna", "vagrant"):
        px = _differs(kind, "_crossing_flash")
        assert px > 0, (
            f"{kind}: the crossing tint changed {px} pixels — it is not "
            f"reaching the screen, so the departure reads as a pop")


def test_the_arrival_tint_still_reaches_the_screen():
    """The control, and a guard on the same function: gate 63 lost the
    ARRIVAL tint here in exactly this way."""
    for kind in ("lacuna", "vagrant"):
        px = _differs(kind, "_arrival_flash")
        assert px > 0, f"{kind}: arrival tint is dead ({px} px)"
