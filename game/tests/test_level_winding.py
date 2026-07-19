"""ENGINE_INVARIANTS.md L1 (wave-1): the level-schema winding-violation
reject path.

`level_from_dict` (levels.py) raises `ValueError` for a polygon whose
authored vertices wind the wrong way (positive shoelace / clockwise in
y-down space), specifically BECAUSE letting the engine silently rewind
would renumber that polygon's edges out from under every authored connection
index (doors, connects, connects_pts) -- a whole-level corruption class.
Before this file, that reject path had ZERO test coverage anywhere: only
the correct-construction path (via LevelBuilder, which always emits
canonical winding) was exercised.

Adversarial dimensions (hypothesis): arbitrary convex polygon shape (n-gon,
3-8 sides, varying radius) and, separately, WHICH polygon in a multi-polygon
level is the malformed one (first, middle, last) -- the guard must fire
per-polygon, not just for polygon 0.
"""

from __future__ import annotations

from hypothesis import given, settings
from hypothesis import strategies as st

import pytest

from perihelion.levels import LevelBuilder, level_from_dict

EXAMPLES = 40


def _valid_level_dict(n_sides: int, radius: float) -> dict:
    b = LevelBuilder("WIND", 1)
    r0 = b.ngon(0, 0, radius, n_sides)
    b.player(r0, (0, 0))
    b.exit(r0, (radius * 0.5, 0))
    return b.to_dict()


@settings(max_examples=EXAMPLES, deadline=None)
@given(n_sides=st.integers(min_value=3, max_value=8), radius=st.floats(30.0, 300.0))
def test_well_wound_polygon_loads_cleanly(n_sides, radius):
    """Control case: LevelBuilder.ngon's construction comment claims its
    angle-decreasing loop always yields negative (canonical) shoelace
    area. Confirm that claim holds across the shape space before trusting
    the reject-path test below to mean anything.
    """
    d = _valid_level_dict(n_sides, radius)
    level_from_dict(d)  # must not raise


@settings(max_examples=EXAMPLES, deadline=None)
@given(n_sides=st.integers(min_value=3, max_value=8), radius=st.floats(30.0, 300.0))
def test_reversed_winding_polygon_is_rejected_loudly(n_sides, radius):
    """Reverse polygon 0's vertex order (canonical CCW -> wrong-way CW) and
    confirm level_from_dict refuses to load it, across arbitrary convex
    shapes -- not silently rewinding and desyncing connection indices.

    Verified fail-first: temporarily replaced the `if _shoelace(verts) > 0:
    raise ValueError(...)` guard in level_from_dict with a silent
    `verts = list(reversed(verts))` rewind (mimicking what an unguarded
    engine add_polygon would effectively hide) and reran -- the level loaded
    without error on every generated example, confirming the guard is
    load-bearing and this test would catch its removal. Reverted before
    committing.
    """
    d = _valid_level_dict(n_sides, radius)
    d["polygons"][0]["verts"] = list(reversed(d["polygons"][0]["verts"]))
    with pytest.raises(ValueError, match="wind the wrong way"):
        level_from_dict(d)


@settings(max_examples=EXAMPLES, deadline=None)
@given(bad_index=st.integers(min_value=0, max_value=2))
def test_reversed_winding_is_caught_in_any_polygon_position(bad_index):
    """The guard must fire per-polygon: a malformed polygon buried in the
    middle or at the end of a multi-polygon level must be caught just as
    reliably as polygon 0 -- a loop that only checked the first polygon would
    pass this level-shape family's every other case silently.
    """
    b = LevelBuilder("WIND-MULTI", 1)
    polygons = [b.rect(i * 250, 0, 200, 140) for i in range(3)]
    b.player(polygons[0], (100, 70))
    b.exit(polygons[2], (200 * 2 + 250 * 2, 70))
    d = b.to_dict()
    d["polygons"][bad_index]["verts"] = list(reversed(d["polygons"][bad_index]["verts"]))
    with pytest.raises(ValueError, match=f"polygon {bad_index}:"):
        level_from_dict(d)
