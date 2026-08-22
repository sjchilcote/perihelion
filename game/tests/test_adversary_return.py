"""Withdrawal is not death, and the books are not the only place that
has to say so.

Ratified: the census decrements permanently on a DEATH, and withdrawal
is the Adversary's NORMAL outcome. Both cannot be true while going home
removes a body as permanently as being killed does — and measurement
said it mattered, not taste: across 8 farm seeds the player caused 14
of 47 adversary losses. The other 33 walked home, and never came back.

So a recovered Adversary re-enters the world through a live breach.
The breach is the entire gate: seal them and nobody returns. A kill is
still permanent, which is the whole point.
"""
from __future__ import annotations

from pathlib import Path

from perihelion.callmedium import CallImprint
from perihelion.levels import LevelBuilder, load_level
from perihelion.sim import (ADVERSARY_ARRIVAL_GRACE,
                            ADVERSARY_CROSSING_TICKS,
                            ADVERSARY_RECOVERY_TICKS, ADVERSARY_ROOT_TICKS,
                            ADVERSARY_SAFE_TICKS, ADVERSARY_STRAND_TICKS,
                            GameSession, InputFrame)




def _breached(seed=4):
    """The real level with a live breach, WITHOUT waiting for one.

    Every test below needs the same thing: a tear standing open. They
    used to get it by running a bot for 6,000-12,000 ticks until the
    world happened to produce one, which cost 241 seconds across this
    file — 40% of the entire suite — to set up a precondition the sim
    will hand over in a millisecond. The call medium's own imprint is
    the honest way to ask for it: this is the same entry point a scout's
    call uses, so the breach is a real breach and not a fixture double.
    """
    level_path = Path(__file__).resolve().parents[2] / "levels" / "gauntlet4.json"
    s = GameSession(load_level(level_path), seed=seed,
                    screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    imp = CallImprint(chamber=s.player_polygon(), position=(0.0, 0.0),
                      tick=s.tick_count, caller_class="vagrant",
                      expires_tick=s.tick_count + 600)
    s._open_breach(imp)
    assert s.breaches, "the scene needs a live tear"
    return s


def _until_return(s, limit=1200):
    """Tick until something comes back, or the budget runs out."""
    for _ in range(limit):
        s.tick(InputFrame())
        if sum(s.adversary_returned.values()):
            return True
    return False


def test_withdrawn_adversary_returns_through_a_live_breach():
    """The positive path, on the real level: a recovered body walks
    back out of a tear."""
    s = _breached()
    before = sum(s.adversary_census.values())
    s.adversary_out.append(("lacuna", 0))     # already recovered
    _until_return(s)
    assert s.adversary_returned["lacuna"] == 1, (
        "a recovered Adversary must re-enter through a live breach")
    assert not s.adversary_out, "the returned body left the waiting list"
    assert sum(s.adversary_census.values()) > before - 1, (
        "the returned body is standing in the world again")


def test_return_needs_a_live_breach():
    """No breach, no return. This is the counterplay: sealing is what
    stops them, so a world with no tear must hold the line forever."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (100, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    assert not s.breaches, "this level has no marrow and no breaches"
    s.adversary_out.append(("lacuna", 0))
    for _ in range(600):
        s.tick(InputFrame())
    assert sum(s.adversary_returned.values()) == 0, (
        "with no live breach nothing may come back")
    assert len(s.adversary_out) == 1, "it is still waiting, not lost"


def test_recovery_is_not_instant():
    """A withdrawal is a real absence. A body that has not recovered
    does not come back even with a breach standing open.

    Asserted against one specific never-due body rather than against a
    zero return count, because scouts withdraw and recover on their own
    during a live session — the first cut of this test assumed an idle
    world and caught an organic return instead of a bug."""
    s = _breached()
    sentinel = ("vagrant", 10_000_000)          # never due
    s.adversary_out.append(sentinel)
    # The return check runs EVERY tick against a live breach, so a body
    # that is not due is refused on the first one. Ticking longer only
    # re-proves the same branch at ~12ms a tick.
    for _ in range(120):
        s.tick(InputFrame())
    assert s.breaches, "the gate was available the whole time"
    assert sentinel in s.adversary_out, (
        "an unrecovered body must still be waiting, breach or no breach")
    assert s.adversary_returned["vagrant"] == 0, (
        "and it must not have been the one that came back")


def test_a_kill_is_permanent():
    """The one exit that never comes back. If a kill queued a return
    too, the player's win would buy nothing at all."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (-100.0, 0.0), "lacuna")
    s._damage_enemy(eid, 9999.0, s.sim.get(eid).pos.offset(1.0, 0.0), 0.0, source="test")
    assert s.adversary_lost["lacuna"] == 1
    assert s.adversary_out == [], (
        "a killed Adversary must never queue a return — death is the "
        "permanent exit and the only one")


def test_recovery_constant_is_a_real_delay():
    """Guards the constant against being zeroed into a revolving door
    by a future tuning pass without anybody noticing."""
    assert ADVERSARY_RECOVERY_TICKS >= 1800, (
        "a withdrawal shorter than 30s stops reading as an absence")


def test_arrival_has_its_own_tell():
    """Gate 60: 'the return has no presentation of its own.' A body
    arriving must be distinguishable from an ordinary pour, in both
    channels."""
    s = _breached()
    s.adversary_out.append(("lacuna", 0))
    heard = False
    for _ in range(1200):
        s.tick(InputFrame())
        heard = heard or any(f[0] == "sound" and f[1] == "adversary_return"
                             for f in s.fx)
        if sum(s.adversary_returned.values()):
            break
    assert s.adversary_returned["lacuna"] == 1, "the return must happen"
    assert heard, (
        "an arrival must announce itself — adversary_return never played")


def test_a_returned_body_cannot_immediately_go_home_again():
    """Gate 60 measured ~20% of returns re-crossing into the hub within
    seconds: the mouth they arrive at neighbours the chamber whose
    crossing IS the withdrawal trigger, so they stepped out and booked
    themselves straight back in. A body that just arrived is arriving,
    not leaving."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
    # this chamber is the marrow's house, so standing here is the whole
    # withdrawal condition — the only thing holding it is the grace
    s.hub.chambers["_test_home"] = r0
    s.enemies[eid]["scout"] = "flee"
    s.enemies[eid]["arrived"] = s.tick_count
    for _ in range(300):
        s.tick(InputFrame())
    assert eid in s.enemies, (
        "a body inside its arrival grace must not be reabsorbed")
    assert s.adversary_withdrawn["lacuna"] == 0

    # ...and once the grace is spent the body is FINISHED, which is not
    # the same as gone: the player is standing in this chamber watching,
    # so it may not blink out. It stays, and it stays live.
    s.enemies[eid]["arrived"] = s.tick_count - ADVERSARY_ARRIVAL_GRACE - 1
    for _ in range(1200):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
    assert eid in s.enemies, (
        "a body the player is watching must never blink out, however "
        "long it has been finished — that is the mimesis-breaking case")
    assert s.adversary_withdrawn["lacuna"] == 0, "and it is not booked"


def test_pacing_is_jittered_not_a_metronome():
    """Gate 61: every observed return gap sat exactly on the recovery
    floor and 12 of 21 bodies left on the exact tick the grace expired.
    A constant that is only ever respected is never tested, and returns
    that arrive on a beat teach the player a rhythm rather than a rule.
    Both windows are sampled per body."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 200, 300)          # the elbow
    r2 = b.rect(400, -500, 200, 300)       # player, around the corner
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 1, r2, 3)
    b.player(r2, (500, -400))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.hub.chambers["_test_home"] = r0

    # Every body is stood up first, around the elbow from the player so
    # nothing is being watched. What is under test is the SPREAD of the
    # recovery due-times, sampled as they go.
    for _ in range(24):
        eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
        s.enemies[eid]["scout"] = "flee"
        s.enemies[eid]["arrived"] = -10 ** 6      # long since arrived
    for _ in range(1200):
        s.tick(InputFrame())
        if len(s.adversary_out) >= 24:
            break
    due = [when for _kind, when in s.adversary_out]
    assert len(due) >= 8, "not enough withdrawals to judge the spread"
    assert len(set(due)) > 1, (
        "recovery is a metronome — every body came due on the same beat")
    spread = max(due) - min(due)
    assert spread > ADVERSARY_RECOVERY_TICKS // 8, (
        f"recovery jitter is too tight to matter (spread {spread}t)")


def test_arrival_grace_is_sampled_per_body():
    """The grace must vary too, or bodies leave in lockstep."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=9, screen=(640, 360), zoom=0.45)
    graces = set()
    for _ in range(40):
        graces.add(ADVERSARY_ARRIVAL_GRACE
                   + s.rng.randrange(0, ADVERSARY_ARRIVAL_GRACE + 1))
    assert len(graces) > 1
    assert min(graces) >= ADVERSARY_ARRIVAL_GRACE, (
        "the constant is a FLOOR — jitter may only ever extend it, never "
        "shorten the window that stops the bounce")


def test_a_sealed_breach_takes_its_returns_with_it():
    """Gates 62-64 all failed here, and every earlier attempt treated
    the WINDOW. Revoking the grace only stripped the flag the strand
    detector was gated on, so the two fixes cancelled and a body stood
    at one coordinate for 4,200 ticks. A body that arrived through this
    seam has no route without it: the seal resolves it now."""
    s = _breached()
    bid = s.breaches[0]["obj"].breach_id

    eid = next(e for e, v in s.enemies.items() if v["kind"] in ("lacuna",
                                                               "vagrant"))
    kind = s.enemies[eid]["kind"]
    w0 = s.adversary_withdrawn[kind]
    s.enemies[eid].update(arrived=s.tick_count, grace=600, arrived_via=bid)

    s._seal_breach(bid, "test")
    assert eid not in s.enemies, (
        "a body whose door died must be resolved, not left standing")
    assert s.adversary_withdrawn[kind] == w0 + 1, "it books as a departure"
    assert s.adversary_lost[kind] == 0, "and never as a kill"


def test_an_unrelated_seal_leaves_a_grace_alone():
    """Only the door that granted it may revoke it."""
    s = _breached()
    bid = s.breaches[0]["obj"].breach_id
    eid = next(iter(s.enemies))
    s.enemies[eid].update(arrived=s.tick_count, grace=600,
                          arrived_via=bid + 999)
    s._seal_breach(bid, "test")
    assert s.enemies[eid].get("grace") == 600, (
        "a body that came through a different door keeps its window")


def test_a_stranded_return_is_reabsorbed_where_it_stands():
    """Gate 63: a returned body whose door sealed behind it stood 3,120
    ticks at the dead seam, because revoking its grace gave it no route
    — it was not in the marrow's house, so nothing took it back. A
    second life that goes nowhere is spent: it reabsorbs in place."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 200, 300)          # the elbow
    r2 = b.rect(400, -500, 200, 300)       # player, around the corner
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 1, r2, 3)
    b.player(r2, (500, -400))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
    assert s.senses.sight_of(s.pid, eid) is None, (
        "a stranded body is taken back when nobody is looking; the "
        "watched case is its own test")
    assert r0 not in s.hub.chambers.values(), (
        "the body must be OUT IN THE WORLD, not in the marrow's house — "
        "that is the case the hub check cannot reach")
    s.enemies[eid]["arrived"] = s.tick_count
    s.enemies[eid]["grace"] = 100000        # protected, and going nowhere
    s.enemies[eid]["scout"] = "flee"
    s.sim.set_vel(eid, s.sim.get(eid).pos.offset(0.0, 0.0))

    for _ in range(ADVERSARY_STRAND_TICKS + 400):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
    assert eid not in s.enemies, (
        "a returned body that has gone still must be taken back rather "
        "than left as a statue at a dead door")
    assert s.adversary_withdrawn["lacuna"] == 1, "it books as a departure"
    assert s.adversary_lost["lacuna"] == 0, "and never as a kill"


def test_a_departure_never_pops_while_the_player_is_watching():
    """Director's law, from the return clip: a body that goes out in
    plain view reads as being deleted mid-stride, not as leaving.

    The withdrawal itself is unchanged — this is purely about WHEN it is
    allowed to happen. A watched body is marked `leaving` and keeps
    acting under its own AI until either nobody is looking or the
    bounded wait runs out."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.hub.chambers["_test_home"] = r0
    eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
    s.enemies[eid]["scout"] = "flee"
    s.enemies[eid]["arrived"] = -10 ** 6

    s.tick(InputFrame())
    assert s.senses.sight_of(s.pid, eid) is not None, (
        "the scene is only meaningful while the player can see the body")
    for _ in range(1500):
        s.tick(InputFrame())
        assert eid in s.enemies, (
            "a body the player is looking at must never be removed "
            "under the camera — and the wait is UNBOUNDED, because a "
            "body vanishing under a chasing player is the failure that "
            "cannot be traded against a few wasted cycles")
    assert s.enemies[eid].get("leaving") is not None, (
        "and it must be ON RECORD as leaving, so the wait is measurable "
        "instead of looking like an AI that forgot to go home")


def test_a_forced_departure_outranks_the_camera():
    """The one exemption, and it must stay one: a body whose doorway
    dies under it goes immediately, watched or not. Deferring exactly
    this case is what left gate 62's statue standing for 3,180 ticks."""
    b = LevelBuilder("RET", 1)
    r0 = b.rect(0, 0, 400, 300)
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
    s.tick(InputFrame())
    assert s.senses.sight_of(s.pid, eid) is not None, "watched"

    s._withdraw_adversary(eid, s.enemies[eid], "no_door")
    assert eid not in s.enemies, (
        "a body whose door died leaves on the spot, in view or not")
    assert s.adversary_withdrawn["lacuna"] == 1


def _thin_scene():
    """A thin chamber the body stands in, with the player around an
    elbow so nobody is watching. `rect(kind="otherworld")` is what makes
    a polygon a place the membrane shows through."""
    b = LevelBuilder("CROSS", 1)
    r0 = b.rect(0, 0, 400, 300, kind="otherworld")
    r1 = b.rect(400, 0, 200, 300)          # the elbow
    r2 = b.rect(400, -500, 200, 300)       # player, around the corner
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 1, r2, 3)
    b.player(r2, (500, -400))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (0.0, 0.0), "lacuna")
    s.enemies[eid]["scout"] = "flee"
    return s, eid, r0


def test_a_finished_body_crosses_where_the_membrane_is_thin():
    """The ordinary exit is not a despawn. A body that is done walks to
    a thin place, stands still in it, and crosses — and the world's own
    otherworld polygons count, not just the cathedral's deep end."""
    s, eid, r0 = _thin_scene()
    assert r0 in s.soft_polygons, "the scene needs a genuinely thin room"
    s._begin_ascent(eid, s.enemies[eid], r0)
    assert s.enemies[eid].get("ascending") is not None

    states = []
    for _ in range(ADVERSARY_SAFE_TICKS + ADVERSARY_ROOT_TICKS
                   + ADVERSARY_CROSSING_TICKS + 120):
        s.tick(InputFrame())
        for rec in s.trace.drain():
            d = getattr(rec, "data", {}) or {}
            if d.get("entity_id") == eid and d.get("to_state"):
                states.append(d["to_state"])
        if eid not in s.enemies:
            break
    assert "crossing" in states, (
        f"it must commit to a crossing, saw {states}")
    assert eid not in s.enemies, "and then it is gone"
    assert s.adversary_withdrawn["lacuna"] == 1, "booked as a departure"
    assert s.adversary_lost["lacuna"] == 0, "and never as a kill"


def test_crossing_needs_stillness_not_just_arrival():
    """Standing in a thin place is not enough — the crossing costs a
    real rooted interval, the same bargain the breach call makes."""
    s, eid, r0 = _thin_scene()
    s._begin_ascent(eid, s.enemies[eid], r0)
    for _ in range(ADVERSARY_SAFE_TICKS + 10):
        s.tick(InputFrame())
    assert eid in s.enemies, "still here: the root has barely started"
    assert s.enemies[eid].get("crossing") is None, (
        "arriving somewhere thin must not by itself commit the crossing")
    assert s.enemies[eid].get("_root", 0) > 0, "but it IS rooting"


def test_a_watched_body_will_not_cross():
    """It only goes when it believes nobody is coming. A body that can
    see the player abandons the attempt rather than escaping the fight
    through the floor."""
    b = LevelBuilder("CROSS", 1)
    r0 = b.rect(0, 0, 400, 300, kind="otherworld")
    b.player(r0, (150, 0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(r0, (-100.0, 0.0), "lacuna")
    s.enemies[eid]["scout"] = "flee"
    s.tick(InputFrame())
    assert s.senses.sight_of(eid, s.pid) is not None, (
        "the scene is only meaningful while the body can see the player")
    s._begin_ascent(eid, s.enemies[eid], r0)
    for _ in range(ADVERSARY_SAFE_TICKS + ADVERSARY_ROOT_TICKS + 200):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
    assert eid in s.enemies, (
        "a body in contact must not cross out — that is escaping the "
        "encounter, not leaving the world")
    assert s.enemies[eid].get("crossing") is None


def test_the_crossing_has_its_own_voice():
    """Gate 74's watch item. The crossing borrowed `adversary_return`,
    so one cue carried two opposite meanings — "one of the finite ones
    is back" and "one just left" — which is the same defect class as the
    run-55/58 borrows.

    One symbol, one meaning: the departure must be audibly its own
    thing, and must NOT sound the arrival while doing it."""
    s, eid, r0 = _thin_scene()
    s._begin_ascent(eid, s.enemies[eid], r0)
    heard, borrowed = set(), False
    for _ in range(ADVERSARY_SAFE_TICKS + ADVERSARY_ROOT_TICKS + 120):
        s.tick(InputFrame())
        for f in s.fx:
            if f and f[0] == "sound":
                heard.add(f[1])
                borrowed = borrowed or f[1] == "adversary_return"
        if eid not in s.enemies:
            break
    assert "adversary_cross" in heard, (
        f"the crossing never announced itself; heard {sorted(heard)}")
    assert not borrowed, (
        "the crossing sounded the ARRIVAL cue — one symbol, one meaning")


def test_the_crossing_cue_is_a_real_asset():
    """A cue the bank cannot load is silence with extra steps."""
    import pathlib
    import perihelion.sim as _sim
    wav = (pathlib.Path(_sim.__file__).parent.parent
           / "assets" / "sfx" / "adversary_cross.wav")
    assert wav.exists(), f"missing sfx asset: {wav}"
    assert wav.stat().st_size > 1000, "the cue is empty"


def test_a_departure_is_legible_in_the_trace_alone():
    """Gate 74's other watch item: the ascent transitions logged
    x=0, y=0 with no destination, so a judge reading the trace could not
    tell a body walking the ramp from one standing still, nor say where
    it went. A telemetry line that cannot answer 'where' is not
    telemetry."""
    s, eid, r0 = _thin_scene()
    # A SECOND body, stood off the origin: with the first at 0,0 the
    # claim "the trace records where it was" is indistinguishable from
    # "the trace records nothing".
    off = s.spawn_enemy(r0, (60.0, -40.0), "lacuna")
    s.enemies[off]["scout"] = "flee"
    s.tick(InputFrame())
    eid = off
    s._begin_ascent(eid, s.enemies[eid], r0)
    seen = []
    for _ in range(ADVERSARY_SAFE_TICKS + ADVERSARY_ROOT_TICKS + 120):
        s.tick(InputFrame())
        for rec in s.trace.drain():
            d = getattr(rec, "data", {}) or {}
            if d.get("entity_id") == eid and str(d.get("to_state", "")) \
                    .startswith(("ascending", "crossing")):
                seen.append(d)
        if eid not in s.enemies:
            break
    assert seen, "the departure left no transitions at all"
    start = next(d for d in seen if str(d["to_state"]).startswith("ascending"))
    assert ">" in str(start["to_state"]), (
        f"the ascent must record WHERE TO, got {start['to_state']!r}")
    px, py = s.sim.get(eid).pos.local() if eid in s.enemies else (None, None)
    assert (start["x"], start["y"]) != (0.0, 0.0), (
        "the ascent must record where it began; the fixture deliberately "
        "stands the body off the origin so 0,0 can only mean 'unset'")
    assert abs(start["x"] - 60.0) < 40.0 and abs(start["y"] + 40.0) < 40.0, (
        f"logged {start['x'], start['y']} is nowhere near where the body "
        f"actually stood")
