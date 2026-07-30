"""Gate run 56's carried watch items, pinned as tests.

Each fails on the run-56 build:

  * the flicker branch `continue`s above the march/DELIVERED block with
    no dispatched gate, so a dispatched flicker never marched, never
    shed the tag, and held its breach's route interest open — the exact
    bug gate 55 fixed on the shrieker, still latent here (bounded in the
    run-56 bank only because every dispatched flicker happened to die);
  * a delivered caller kept state=hunt with no path back to rest —
    24,900 phantom shrieker-ticks bank-wide, worst 5707t, each one
    counting as a committed peer in a neighbour's quorum fraction;
  * withdrawal and death were the same entry in the books, so the farm
    reported a body that walked home as a body the player put down.
"""
from __future__ import annotations

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame


def _tick(s, n=1):
    for _ in range(n):
        s.tick(InputFrame())


def _blind_scene(kind, state=None, dispatched=7):
    """One body of `kind` carrying a dispatched tag, standing in the
    world (not the marrow's house), genuinely unable to see the player.

    The L is load-bearing. Sight here is portal-composed, so two
    chambers joined by a doorway are NOT blind however far apart their
    coordinates are — a straight two-chamber scene has the body staring
    down the corridor at the player from tick 0. The player has to be
    around the elbow."""
    b = LevelBuilder("G56", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 200, 300)          # the elbow
    r2 = b.rect(400, -500, 200, 300)       # player, around the corner
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 1, r2, 3)
    b.player(r2, (500, -400))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), kind)
    s.enemies[eid]["dispatched"] = dispatched
    if state is not None:
        s.enemies[eid]["state"] = state
    assert s.senses.sight_of(eid, s.pid) is None, (
        "scene is only meaningful while the body is blind")
    return s, eid, r0


def test_dispatched_flicker_sheds_its_tag():
    """A dispatched flicker standing in the world is DELIVERED: it drops
    the tag like every other kind. Ungated, `_flicker_ai` swallowed the
    tick and the tag lived forever."""
    s, eid, _ = _blind_scene("flicker")
    assert s.enemies[eid].get("dispatched") == 7
    _tick(s, 30)
    assert s.enemies[eid].get("dispatched") is None, (
        "a dispatched flicker in the world must shed the tag — an "
        "un-shed tag pins its breach's route interest open forever")


def test_dispatched_flicker_still_lurks_once_delivered():
    """Shedding hands the body straight back to its OWN machine: the
    gate must not cost the flicker its lurk behaviour, only the tag."""
    s, eid, _ = _blind_scene("flicker")
    _tick(s, 30)
    assert s.enemies[eid].get("dispatched") is None
    assert s.enemies[eid]["state"] == "lurk", (
        "a delivered flicker returns to lurking, not to a generic state")


def test_undispatched_flicker_is_untouched():
    """The gate is exactly one condition: with no tag, nothing changes."""
    b = LevelBuilder("G56", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(900, 0, 200, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (1000, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "flicker")
    _tick(s, 30)
    assert s.enemies[eid].get("dispatched") is None
    assert s.enemies[eid]["state"] == "lurk"


def test_delivered_caller_returns_to_rest():
    """The march's `hunt` is locomotion bookkeeping, not a sighting.
    On delivery, a body that can see nothing goes back to rest instead
    of standing in `hunt` forever inflating everyone else's quorum."""
    s, eid, _ = _blind_scene("shrieker", state="hunt")
    assert s.enemies[eid]["state"] == "hunt"
    _tick(s, 30)
    assert s.enemies[eid].get("dispatched") is None, "tag must shed"
    assert s.enemies[eid]["state"] == "idle", (
        "a delivered caller that sees nothing must return to rest — "
        "state=hunt with no sighting is the phantom-peer bug")


def test_delivered_caller_that_sees_the_player_keeps_hunting():
    """Only the lie is cleared. A delivered body in actual contact is
    still in the fight and must not be handed a free stand-down."""
    b = LevelBuilder("G56", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (100, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "shrieker")
    s.enemies[eid]["dispatched"] = 7
    s.enemies[eid]["state"] = "hunt"
    _tick(s, 2)
    assert s.senses.sight_of(eid, s.pid) is not None, (
        "scene is only meaningful while the body can see the player")
    assert s.enemies[eid]["state"] == "hunt", (
        "a delivered body that can see the player keeps hunting")


def test_kill_and_withdrawal_are_different_entries():
    """Withdrawal is the Adversary's NORMAL outcome and death the
    exceptional one. A single `census0 - census_end` lump cannot tell
    the player's win from the enemy going home on schedule."""
    b = LevelBuilder("G56", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (-100.0, 0.0), "lacuna")
    assert s.adversary_census["lacuna"] == 1
    assert s.adversary_lost["lacuna"] == 0
    assert s.adversary_withdrawn["lacuna"] == 0

    s._damage_enemy(eid, 9999.0, s.sim.get(eid).pos.offset(1.0, 0.0), 0.0, source="test")
    assert s.adversary_census["lacuna"] == 0, "it left the standing count"
    assert s.adversary_lost["lacuna"] == 1, "a kill books as KILLED"
    assert s.adversary_withdrawn["lacuna"] == 0, (
        "a kill must never book as a withdrawal")


def test_withdrawal_books_as_withdrawn_not_killed():
    """Crossing into the marrow's own house is a departure. It leaves
    the standing count exactly like a death does, and it must land in
    the other column."""
    b = LevelBuilder("G56", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(900, 0, 200, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (1000, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
    # declare the scout's own chamber to be the marrow's house, which is
    # the one condition `_scout_ai` reabsorbs on
    s.hub.chambers["_test_withdraw"] = r0
    s.enemies[eid]["scout"] = "flee"
    _tick(s, 30)

    assert eid not in s.enemies, "a reabsorbed scout leaves the world"
    assert s.adversary_census["lacuna"] == 0, "it left the standing count"
    assert s.adversary_withdrawn["lacuna"] == 1, (
        "a departure books as WITHDRAWN")
    assert s.adversary_lost["lacuna"] == 0, (
        "a departure must never book as a kill — that is the whole "
        "point of keeping the two columns apart")
