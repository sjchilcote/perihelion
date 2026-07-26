"""U7 gate — the call medium and the finite scouts.

Construction: one lease in the world; the imprint schema carries
chamber/position/tick/class and NOTHING else (no reserve, no hub, no
composition); scouts.py imports only its legal substrate; the census
only decreases after build.

Isolated vectors (Sol's numbers): lease exclusivity with same-tick
bracing and holder-death handoff; the weakest-CLASS rule (lacuna before
vagrant; exactly one of two lacunae); rooted-broadcast timing (vagrant
360 root / 480 total, lacuna 480/600) with sub-1e-6 displacement; the
dry call (one imprint, consumed once, no retry, no failure signal); the
lacuna's imprint always names the chamber its body occupies.
"""
from __future__ import annotations

import dataclasses
import math

from perihelion.callmedium import IMPRINT_TTL_TICKS, CallImprint, CallMedium
from perihelion.levels import LevelBuilder
from perihelion.signals import SignalKind
from perihelion.sim import GameSession, InputFrame
from perihelion import scouts


# ---------------------------------------------------------------------------
# construction
# ---------------------------------------------------------------------------

def test_imprint_carries_nothing_for_the_marrow():
    names = {f.name for f in dataclasses.fields(CallImprint)}
    assert names == {"chamber", "position", "tick", "caller_class",
                     "expires_tick"}
    for forbidden in ("reserve", "hub", "mix", "composition", "demand"):
        assert not any(forbidden in n for n in names)


def test_one_lease_and_holder_death_handoff():
    m = CallMedium()
    assert m.try_lease(7, 0) is not None
    assert m.try_lease(9, 0) is None, "the channel is single"
    assert m.try_lease(7, 5) is not None, "the holder keeps its own lease"
    m.release(7)                        # the holder died
    assert m.holder() is None
    assert m.try_lease(9, 6) is not None, "the channel frees immediately"


def test_dry_call_is_consumed_once_never_queued():
    m = CallMedium()
    m.try_lease(7, 0)
    imp = m.complete(7, chamber=4, position=(1.0, 2.0), tick=10,
                     caller_class="lacuna")
    assert imp is not None and imp.chamber == 4
    assert m.pending(11) == 1
    got = m.consume_one(11)
    assert got == imp
    assert m.consume_one(12) is None, "a consumed call never returns"
    # expiry: an unconsumed imprint evaporates on its own
    m.try_lease(7, 20)
    m.complete(7, chamber=4, position=(0, 0), tick=20, caller_class="lacuna")
    assert m.consume_one(20 + IMPRINT_TTL_TICKS + 1) is None


def test_scouts_module_boundary():
    import ast
    from pathlib import Path
    src = (Path(__file__).resolve().parent.parent
           / "perihelion" / "scouts.py").read_text()
    roots = set()
    for node in ast.walk(ast.parse(src)):
        if isinstance(node, ast.ImportFrom):
            roots.add((node.module or "").split(".")[0])
        elif isinstance(node, ast.Import):
            roots.update(a.name.split(".")[0] for a in node.names)
    for forbidden in ("sim", "marrow", "breach", "hub", "audio", "render",
                      "app"):
        assert forbidden not in roots, f"scouts.py imports {forbidden}"


# ---------------------------------------------------------------------------
# sim vectors
# ---------------------------------------------------------------------------

def _warm_pair():
    """Two rooms; the scout's room is warm enough to plant a contact
    call (the player fought here recently)."""
    b = LevelBuilder("SCOUT", 1)
    ra = b.rect(0, 0, 300, 200)
    rb = b.rect(300, 0, 300, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (60, 100))
    return b.build(), ra, rb


def _warm(s, chamber, hot=0.20):
    s.signals.emit_at_least(SignalKind.TRAIL, chamber, hot, s.tick_count)


def test_weakest_class_calls_first():
    level, ra, rb = _warm_pair()
    s = GameSession(level, seed=8)
    vag = s.spawn_enemy(rb, (0.0, -40.0), "vagrant")
    lac = s.spawn_enemy(rb, (0.0, 40.0), "lacuna")
    for t in range(1, 400):
        _warm(s, rb)
        s.tick(InputFrame())
        if s.enemies[lac].get("scout") in ("brace", "transmit"):
            break
    assert s.enemies[lac].get("scout") in ("brace", "transmit"), (
        "the lacuna (weakest class) must take the caller duty")
    assert s.enemies[vag].get("scout") is None, (
        "the vagrant must keep fighting while a weaker class is present")


def test_two_lacunae_only_one_ever_transmits():
    """Tasking is per-room, but the MEDIUM is the world's one channel:
    at no instant may two scouts be braced-or-broadcasting."""
    level, ra, rb = _warm_pair()
    s = GameSession(level, seed=8)
    a = s.spawn_enemy(rb, (0.0, -40.0), "lacuna")
    b_ = s.spawn_enemy(rb, (0.0, 40.0), "lacuna")
    someone_broadcast = False
    for t in range(1, 1200):
        _warm(s, rb)
        s.tick(InputFrame())
        live = [s.enemies[x].get("scout") for x in (a, b_)
                if x in s.enemies]
        on_air = sum(1 for st in live if st in ("brace", "transmit"))
        assert on_air <= 1, f"two on the channel at t={t}: {live}"
        someone_broadcast = someone_broadcast or on_air == 1
    assert someone_broadcast, "nobody ever braced at all"


def test_rooted_broadcast_timing_and_stillness():
    level, ra, rb = _warm_pair()
    for kind, root in (("vagrant", 360), ("lacuna", 480)):
        s = GameSession(level, seed=8)
        eid = s.spawn_enemy(rb, (0.0, 0.0), kind)
        brace_at = transmit_at = done_at = None
        pos_at_root = None
        max_disp = 0.0
        for t in range(1, 1400):
            _warm(s, rb)
            s.tick(InputFrame())
            e = s.enemies[eid]
            st = e.get("scout")
            if st == "brace" and brace_at is None:
                brace_at = t
            if st == "transmit":
                if transmit_at is None:
                    transmit_at = t
                    pos_at_root = s.sim.get(eid)[1:3]
                else:
                    x, y = s.sim.get(eid)[1:3]
                    max_disp = max(max_disp,
                                   math.hypot(x - pos_at_root[0],
                                              y - pos_at_root[1]))
            if st == "observe" and done_at is None:
                done_at = t
                break
        assert brace_at and transmit_at and done_at, (kind, brace_at,
                                                      transmit_at, done_at)
        assert transmit_at - brace_at == scouts.BRACE_TICKS
        assert done_at - transmit_at == root, (
            f"{kind} rooted {done_at - transmit_at}, want {root}")
        assert max_disp < 1e-6, f"{kind} moved {max_disp} while rooted"
        assert s.medium.pending(s.tick_count) == 1, "the imprint exists"
        imp = s.medium.consume_one(s.tick_count)
        assert imp.caller_class == kind and imp.chamber == rb


def test_imprint_names_the_body_chamber():
    """The lacuna may probe the next chamber through the portal, but a
    call lands where its BODY stands — probing through a cordon must not
    let it call past one."""
    level, ra, rb = _warm_pair()
    s = GameSession(level, seed=8)
    eid = s.spawn_enemy(rb, (0.0, 0.0), "lacuna")
    for t in range(1, 1400):
        _warm(s, rb)
        _warm(s, ra, 0.6)              # the NEXT chamber smells hotter
        s.tick(InputFrame())
        if s.medium.pending(s.tick_count):
            break
    imp = s.medium.consume_one(s.tick_count)
    assert imp is not None
    assert imp.chamber == s.sim.get_polygon(eid), (
        "the imprint must name the chamber the body occupies")


def test_damage_interrupts_and_census_is_permanent():
    level, ra, rb = _warm_pair()
    s = GameSession(level, seed=8)
    eid = s.spawn_enemy(rb, (0.0, 0.0), "lacuna")
    assert s.adversary_census["lacuna"] == 1
    for t in range(1, 900):
        _warm(s, rb)
        s.tick(InputFrame())
        if s.enemies[eid].get("scout") == "transmit":
            break
    assert s.enemies[eid].get("scout") == "transmit"
    s._damage_enemy(eid, 5.0, (1.0, 0.0), 0.0, source="test")
    s.tick(InputFrame())
    assert s.enemies[eid].get("scout") == "flee", "damage must interrupt"
    assert s.medium.holder() is None, "interruption frees the channel"
    assert s.medium.pending(s.tick_count) == 0, "no imprint from a cut call"
    s._damage_enemy(eid, 999.0, (1.0, 0.0), 0.0, source="test")
    assert s.adversary_census["lacuna"] == 0, "every death is permanent"
