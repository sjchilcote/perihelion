"""Walk-mask CLEARANCE gate (director's stop-the-line order, 2026-07-13):
room 112 (l01)'s shipped walk-mask passed the plain portal-connectivity BFS
in tools/artgen/walkmask.py but left only a ~13-unit-wide bottom channel --
too narrow for the player's own collision circle. Reachable != traversable.

This exercises tools.artgen.walkmask.check_room_portal_clearance /
erode_walkable directly on synthesized arrays -- no image generation, no
API calls, no engine session.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from tools.artgen.walkmask import (
    CLEARANCE_RADIUS_UNITS,
    check_room_portal_clearance,
    check_room_portal_connectivity,
    clearance_radius_px,
    erode_walkable,
)
from perihelion.sim import PLAYER_RADIUS


def _dumbbell(gap_width_px: int, h: int = 220, w: int = 300) -> np.ndarray:
    """Two wide walkable rooms (left/right) joined by a narrow horizontal
    channel `gap_width_px` tall through the middle -- exactly the room 112
    shape (two open areas pinched by a narrow bottom channel)."""
    walk = np.zeros((h, w), dtype=bool)
    walk[20:h - 20, 20:110] = True   # left room
    walk[20:h - 20, w - 110:w - 20] = True  # right room
    mid_y0 = h // 2 - gap_width_px // 2
    mid_y1 = mid_y0 + gap_width_px
    walk[mid_y0:mid_y1, 90:w - 90] = True  # connecting channel
    return walk


def _portal_pts(h: int, w: int):
    # one portal sample well inside the left room, one well inside the
    # right room -- mirrors portal_points_px's "sample point just inside
    # the doorway edge" convention. col=65 is the center of each room's
    # [20, 110) span (45px from either wall), comfortably clear of the
    # clearance radius itself so only the CONNECTING CHANNEL's width
    # governs pass/fail, not the portal point's proximity to its own
    # room's outer wall.
    return [(0, h // 2, 65), (1, h // 2, w - 65)]


def test_clearance_radius_is_at_least_one_player_radius_margin():
    # config sanity: director's explicit floor ("margin >= 1 player
    # radius") -- if this regresses, everything downstream is silently
    # under-gating.
    assert CLEARANCE_RADIUS_UNITS >= 2 * PLAYER_RADIUS


def test_narrow_channel_passes_plain_connectivity_but_fails_clearance():
    # A channel narrower than the required clearance diameter: reachable
    # (thin thread of walkable cells connects both portals) but not
    # traversable by a player-sized disc. This is the exact room-112
    # failure mode -- the plain BFS gate shipped it, the bot got stuck.
    narrow_px = 6  # far below 2 * clearance_radius_px()
    walk = _dumbbell(narrow_px)
    pts = _portal_pts(220, 300)

    plain = check_room_portal_connectivity(walk, pts)
    assert plain["ok"], "fixture must reproduce the room-112 shape: reachable under plain BFS"

    clearance = check_room_portal_clearance(walk, pts)
    assert not clearance["ok"], (
        "clearance gate must fail a channel narrower than the player "
        "collision diameter + comfort margin -- reachable is not traversable"
    )


def test_wide_channel_passes_both_gates():
    # A channel comfortably wider than 2x the clearance radius must pass
    # both gates -- proves the gate isn't just failing everything.
    wide_px = int(clearance_radius_px() * 2) + 20
    walk = _dumbbell(wide_px, h=wide_px + 100, w=300)
    pts = _portal_pts(wide_px + 100, 300)

    plain = check_room_portal_connectivity(walk, pts)
    assert plain["ok"]

    clearance = check_room_portal_clearance(walk, pts)
    assert clearance["ok"], "a route with 2x+ clearance radius width must survive erosion"


def test_erode_walkable_shrinks_and_never_grows():
    walk = np.zeros((50, 50), dtype=bool)
    walk[10:40, 10:40] = True
    eroded = erode_walkable(walk, radius_px=5)
    # erosion only removes cells, never adds
    assert not (eroded & ~walk).any()
    assert eroded.sum() < walk.sum()


def test_erode_walkable_zero_radius_is_identity():
    walk = np.zeros((20, 20), dtype=bool)
    walk[5:15, 5:15] = True
    eroded = erode_walkable(walk, radius_px=0)
    assert np.array_equal(eroded, walk)


def test_erode_walkable_all_false_stays_false():
    walk = np.zeros((20, 20), dtype=bool)
    eroded = erode_walkable(walk, radius_px=5)
    assert not eroded.any()
