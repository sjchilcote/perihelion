"""ENGINE_INVARIANTS.md SIM7 (wave-1): death/respawn economy conservation.

`GameSession._drop_corpse` (sim.py) either zeros the player's components
into a `corpse_frame` pickup (normal case) or, under the protected-revival
mind unlock, preserves components live and drops only station_kits. Both
branches are documented in the function's own docstring as conserving
("nothing is lost until then, and nothing is lost after retrieval (9.1)")
but that conservation claim had ZERO test coverage before this file --
existing coverage (test_stream.py's respawn test) only checks hp floors
and enemy reseeding, never touches loot at all.

This is exactly the class of bug the director's directive is aimed at:
state/economy corruption (duplicated or vanished components) is
player-visible and silent -- nothing crashes, a number is just wrong.

Adversarial dimensions (hypothesis): arbitrary nonnegative component/kit
counts (including zero, which takes the "nothing dropped" no-pickup-
spawned early-out), both `_protected_revival` states, and the full
drop -> retrieve round trip (not just the drop half).
"""

from __future__ import annotations

from hypothesis import given, settings
from hypothesis import strategies as st

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame

EXAMPLES = 60


def _level():
    b = LevelBuilder("CORPSE-ECON", 1)
    r0 = b.rect(0, 0, 200, 140)
    b.player(r0, (40, 70))
    b.exit(r0, (180, 70))
    return b.build()


def _session(components: int, station_kits: int, protected: bool) -> GameSession:
    s = GameSession(_level(), seed=3)
    s.components = components
    s.station_kits = station_kits
    s._protected_revival = protected
    return s


@settings(max_examples=EXAMPLES, deadline=None)
@given(
    components=st.integers(min_value=0, max_value=500),
    station_kits=st.integers(min_value=0, max_value=50),
)
def test_drop_conserves_totals_normal_case(components, station_kits):
    """Non-protected death: both components and station_kits move from
    the live session onto the corpse frame -- zero created, zero lost.

    Verified fail-first: temporarily changed `_drop_corpse`'s
    `contents = dict(components=self.components, station_kits=...)` to
    `dict(components=self.components + 1, station_kits=...)` (simulating
    a one-component duplication bug) and reran -- failed immediately on
    every nonzero-components example. Reverted before committing.
    """
    s = _session(components, station_kits, protected=False)
    polygon = s.level.player_polygon
    px, py = s.player_pos()

    s._drop_corpse(polygon, (px, py))

    assert s.components == 0
    assert s.station_kits == 0

    total_dropped = components + station_kits
    if total_dropped == 0:
        # Nothing to drop: no pickup spawned (dict(components=0,
        # station_kits=0) is falsy under `any(contents.values())`).
        assert len(s.pickups) == 0
        return

    assert len(s.pickups) == 1
    rec = next(iter(s.pickups.values()))
    assert rec["kind"] == "corpse_frame"
    contents = rec["contents"]
    assert contents["components"] == components
    assert contents["station_kits"] == station_kits


@settings(max_examples=EXAMPLES, deadline=None)
@given(
    components=st.integers(min_value=0, max_value=500),
    station_kits=st.integers(min_value=0, max_value=50),
)
def test_drop_conserves_totals_protected_revival(components, station_kits):
    """Protected-revival death: components stay live (banked), only
    station_kits ride the corpse. Neither figure may be duplicated or
    lost across the drop.
    """
    s = _session(components, station_kits, protected=True)
    polygon = s.level.player_polygon
    px, py = s.player_pos()

    s._drop_corpse(polygon, (px, py))

    # Components are preserved live under protected revival.
    assert s.components == components
    assert s.station_kits == 0

    if station_kits == 0:
        assert len(s.pickups) == 0
        return

    assert len(s.pickups) == 1
    rec = next(iter(s.pickups.values()))
    contents = rec["contents"]
    assert contents["components"] == 0
    assert contents["station_kits"] == station_kits


@settings(max_examples=EXAMPLES, deadline=None)
@given(
    components=st.integers(min_value=1, max_value=500),
    station_kits=st.integers(min_value=1, max_value=50),
)
def test_drop_then_retrieve_round_trips_exactly(components, station_kits):
    """The full economy round trip: die with loot, walk onto the corpse,
    and recover EXACTLY what was dropped -- not more (duplication), not
    less (loss). This drives `_pickup_scan`'s real corpse_frame retrieval
    branch (sim.py), not just the drop half `_drop_corpse` covers alone.

    Verified fail-first: temporarily commented out the two accumulation
    lines in `_pickup_scan`'s corpse_frame branch
    (`self.components += c.get(...)`) and reran -- failed (retrieved
    totals stayed at zero) on every example. Reverted before committing.
    """
    s = _session(components, station_kits, protected=False)
    polygon = s.level.player_polygon
    px, py = s.player_pos()

    s._drop_corpse(polygon, (px, py))
    assert s.components == 0 and s.station_kits == 0

    # Walk the player onto the corpse frame (spawned at the player's own
    # position) and let one tick's pickup scan run.
    s.tick(InputFrame())

    assert s.components == components, (
        f"components not conserved through retrieval: expected {components}, "
        f"got {s.components}"
    )
    assert s.station_kits == station_kits, (
        f"station_kits not conserved through retrieval: expected {station_kits}, "
        f"got {s.station_kits}"
    )
    assert len(s.pickups) == 0, "corpse frame must be consumed exactly once"
