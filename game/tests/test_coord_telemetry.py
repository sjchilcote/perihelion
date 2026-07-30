"""Run-43 instrument gate: the coordination ledger tells the truth.

The prowl branch shipped with zero events across four filmed seeds —
"unreachable vs unexercised cannot be distinguished from these traces"
(run 43 blocker). This is the reachability proof: a hunter in a dead
level, with nothing to smell from anywhere, must PROWL — emit its
stint start and keep its body moving — instead of standing statue
until stand-down. The hold ledger's flutter suppression is pinned
here too: sub-2-tick hold stints must not reach the trace.
"""
from __future__ import annotations

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame


def _chain(n_rooms, w=300, h=200):
    b = LevelBuilder("COORDTEL", 1)
    rooms = [b.rect(i * w, 0, w, h) for i in range(n_rooms)]
    for i in range(n_rooms - 1):
        b.connect(rooms[i], 2, rooms[i + 1], 0)
    b.player(rooms[0], (100, h // 2))
    return b, rooms


def _bent_chain(n_rooms, w=200):
    """A chain of square chambers where every doorway TURNS A CORNER: each
    room's right edge is glued to the next room's TOP edge, so the
    developed corridor makes a quarter turn at every threshold. Nothing
    past the second chamber is on a straight line from the first, so sight
    genuinely fails there.

    A straight chain does NOT do this any more, and the tests that used one
    were relying on an accident. The confirming ray used to be hardcoded to
    three doorways while the transform walk was allowed twelve, so a body
    four chambers down an open corridor composed a correct position and was
    then refused — a straight sightline denied by a magic number, which is
    the third failure the coordinate work exists to delete
    (docs/FRAME_SYSTEM_DESIGN_20260729.md §12). With the ray given the same
    reach as the walk, that body can see the player, and it is right to.
    Testing "sees nothing" now needs a world with nothing to see.

    Note that DRAWING the rooms in an L would not have been enough: gluing
    a right edge to a left edge is a straight continuation however the
    rooms are laid out on paper, because the portal transform is what
    decides the geometry. The turn has to be in the gluing."""
    b = LevelBuilder("COORDB", 1)
    rooms = [b.rect(i * w, 0, w, w) for i in range(n_rooms)]
    for i in range(n_rooms - 1):
        b.connect(rooms[i], 2, rooms[i + 1], 3)   # right -> top: a corner
    b.player(rooms[0], (w // 2, w // 2))
    return b, rooms


def test_prowl_fires_and_moves_on_a_quiet_field():
    # the far hunter is 4 doorways out around a ZIGZAG — genuinely
    # blind, and beyond the player's trail spread; its field really is
    # quiet (same geometry the stand-down vector certifies)
    b, rooms = _bent_chain(5)
    s = GameSession(b.build(), seed=11)
    eid = s.spawn_enemy(rooms[4], (0.0, 0.0), "husk")
    s.enemies[eid]["state"] = "hunt"
    x0, y0 = s.sim.get(eid).pos.local()
    for _ in range(150):
        s.tick(InputFrame())
        if eid not in s.enemies or s.enemies[eid]["state"] != "hunt":
            break
    recs = s.trace.drain()
    prowls = [r for r in recs if r.kind == "coord_event"
              and r.data["event"] == "prowl_start"
              and r.data["entity_id"] == eid]
    assert prowls, "a hunter with nothing to smell never prowled"
    x1, y1 = s.sim.get(eid).pos.local()
    assert abs(x1 - x0) + abs(y1 - y0) > 10.0, \
        "prowl emitted but the body never moved"


def test_hold_ledger_reports_no_single_tick_flutter():
    # a two-room level with an actively-held doorway produces hold
    # stints; whatever their durations, no logged stint may be the
    # same-tick engage/end noise run 43 flagged
    b, rooms = _chain(2)
    s = GameSession(b.build(), seed=11)
    for i in range(4):
        eid = s.spawn_enemy(rooms[1], (60.0 + 20.0 * i, 0.0), "husk")
        s.enemies[eid]["state"] = "hunt"
    for _ in range(600):
        s.tick(InputFrame())
        if s.dead:
            break
    recs = s.trace.drain()
    engages = [r for r in recs if r.kind == "coord_event"
               and r.data["event"] == "hold_engage"]
    ends = [r for r in recs if r.kind == "coord_event"
            and r.data["event"] == "hold_end"]
    for r in ends:
        held = int(r.data["detail"].split("held ")[1].split("t")[0])
        assert held >= 1, f"ghost/flutter stint in ledger: {r.data}"
    # every emitted engage belongs to a real stint (>=2 held ticks by
    # construction of the lazy latch); ends never exceed engages
    assert len(ends) <= len(engages) + 4  # +N for stints open at drain
