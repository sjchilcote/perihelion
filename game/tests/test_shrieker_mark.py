"""U10: the shrieker mark FSM (salvaged b2c27600) and the Brand.

Every scream is first-hand by construction (WARNING requires a sighting),
the marker is a real led projectile, and the MARK drives the existing
field systems: doorway trail on his crossings, presence pour in place.
"""
from __future__ import annotations

import numpy as np

from perihelion.levels import LevelBuilder
from perihelion.render import Renderer
from perihelion.signals import SignalKind
from perihelion.sim import BRAND_DURATION, GameSession, InputFrame


def _arena(player_pos=(320.0, 90.0), wide=True):
    b = LevelBuilder("MARK", 1)
    # both glued edges the same length: a mismatched glue makes the
    # engine derive a LENS, which is a different test than this one
    r0 = b.rect(0, 0, 400 if wide else 200, 180, kind="dock")
    r1 = b.rect(400 if wide else 200, 0, 160, 180, kind="corridor")
    b.connect(r0, 2, r1, 0)
    b.player(r0, player_pos)
    b.exit(r1, (480 if wide else 280, 90))
    return GameSession(b.build(), seed=9, screen=(640, 360), zoom=0.45)


def _tick(s, n=1, **kw):
    for _ in range(n):
        s.tick(InputFrame(**kw))


def test_a_sentinel_screams_only_after_it_has_seen_the_intruder():
    """The alarm is first-hand by construction: nothing in this machine
    screams before its own sighting. (A patrolling sentinel WILL find
    the player eventually — the contract is the ordering, not silence.)"""
    s = _arena()
    eid = s.spawn_enemy(1, (80.0, 0.0), "shrieker")
    first_sight = None
    screams_before = 0
    for t in range(900):
        seen = (s.sim.get_polygon(eid) == s.player_polygon()
                or s.senses.sight_of(eid, s.pid) is not None)
        if seen and first_sight is None:
            first_sight = t
        _tick(s)
        n = sum(1 for f in s.fx if f and f[0] == "scream")
        if first_sight is None:
            screams_before += n
        elif n:
            break
    assert screams_before == 0, (
        f"{screams_before} screams before the sentinel ever saw anything")
    assert first_sight is not None, "the sentinel never found the player"


def test_sighting_starts_warning_and_first_hand_screams():
    s = _arena()
    eid = s.spawn_enemy(0, (200.0, 90.0), "shrieker")
    e = s.enemies[eid]
    husk = s.spawn_enemy(0, (60.0, 30.0), "husk")
    screams = 0
    _tick(s)
    screams += sum(1 for f in s.fx if f and f[0] == "scream")
    assert e.get("phase") == "warning", (
        f"sighting did not start the warning ({e.get('phase')})")
    for _ in range(3):
        _tick(s)
        screams += sum(1 for f in s.fx if f and f[0] == "scream")
    assert screams >= 1, "the sighting raised no scream"
    assert s.enemies[husk]["state"] in ("hunt", "waking"), \
        "the rouse did not raise the squad"


def test_rouse_leaves_other_shriekers_alone():
    """Mutual-rescream latching is unrepresentable: screams never touch
    other shriekers (they run their own machine)."""
    s = _arena()
    a = s.spawn_enemy(0, (200.0, 90.0), "shrieker")
    other = s.spawn_enemy(0, (200.0, 30.0), "shrieker")
    s._shrieker_rouse(a, 0)
    assert s.enemies[other]["state"] == "idle"


def test_marking_locks_and_fires_a_marker_that_brands():
    s = _arena()
    eid = s.spawn_enemy(0, (200.0, 90.0), "shrieker")
    e = s.enemies[eid]
    e["phase"] = "marking"
    s.trace.drain()
    assert not s.brand.active
    snds = []
    for _ in range(60 * 8):
        _tick(s)
        snds += [(s.tick_count, f[1]) for f in s.fx if f[0] == "sound"]
        if s.brand.active:
            break
    assert s.brand.active, "the marker never landed a brand"
    assert s.brand.source_eid == eid
    assert e["phase"] == "rally"
    # the launch has its OWN voice (gate 54 blocker: it played the
    # scream -- one sound, two meanings -- so the dodge cue was
    # indistinguishable from the alarm). The RALLY scream that follows
    # is a different, legitimate event (the caller raising the squad
    # while the dart flies); the law binds at the launch tick.
    names = [n for _, n in snds]
    assert "marker_launch" in names, "the launch made no sound of its own"
    launch_t = next(t for t, n in snds if n == "marker_launch")
    assert not any(n == "shrieker_scream" and t == launch_t
                   for t, n in snds), (
        "the launch still borrows the alarm's voice")
    assert "mark_hit" in names
    # and the whole exchange is on the record (gate 54: both filmed
    # marks were orphan sounds; phase tenure was unmeasurable)
    recs = [r for r in s.trace.drain() if r.kind == "coord_event"]
    events = [r.data["event"] for r in recs]
    assert "marker_fire" in events, "the shot left no trace record"
    assert "brand_renew" in events, "the brand landed off the record"
    renew = next(r for r in recs if r.data["event"] == "brand_renew")
    assert renew.data["detail"].startswith("fresh"), (
        "a first brand must file as fresh, not renew")
    phases = [r.data["detail"] for r in recs
              if r.data["event"] == "shrieker_phase"]
    assert "marking->rally" in phases, (
        "the phase transition never reached the bus")


def test_brand_decays_on_its_own():
    s = _arena()
    s.trace.drain()
    s.brand.renew(42)
    _tick(s, BRAND_DURATION + 5)
    assert not s.brand.active
    ends = [r for r in s.trace.drain() if r.kind == "coord_event"
            and r.data["event"] == "brand_expired"]
    assert len(ends) == 1, (
        f"expiry must hit the record exactly once, got {len(ends)}")
    assert ends[0].data["detail"] == "src 42"


def test_branded_crossing_lays_the_doorway_trail():
    s = _arena()
    s.brand.renew(42)
    before = s.signals.doorway_trail(0, 2, s.tick_count)
    # walk him through the r0->r1 portal under his own power
    for _ in range(240):
        _tick(s, mx=1.0)
        s.brand.renew(42)          # hold the mark for the whole walk
        if s.player_polygon() == 1:
            break
    assert s.player_polygon() == 1, "the crossing never happened"
    after = s.signals.doorway_trail(0, 2, s.tick_count)
    assert after > before + 1.0, (
        f"branded crossing laid no follow-me lane ({before} -> {after})")


def _brand_diff(s, r, moving):
    surf = (640, 360)
    if moving:
        s.sim.set_vel(s.pid, s.sim.get(s.pid).pos.offset(120.0, 40.0))
    base = r.draw(surf).astype(np.int32)
    s.brand.renew(1)
    branded = r.draw(surf).astype(np.int32)
    diff = np.abs(branded - base).sum(axis=2)
    ys, xs = np.where(diff > 20)
    return branded[ys, xs]


def test_the_glob_reads_on_a_standing_body():
    """The scent tag's instantly obvious visual (director, U10 standing
    requirement). At body scale it changes tens of pixels even on a
    player who has stopped moving; the first draft managed 8, which is
    not obvious at all."""
    s = _arena()
    r = Renderer(s)
    _tick(s, 2)
    r.consume_fx(s.fx)
    px = _brand_diff(s, r, moving=False)
    assert len(px) >= 40, f"the standing mark drew {len(px)}px"
    magenta = (px[:, 0] > 180) & (px[:, 2] > 140) & (px[:, 1] < px[:, 0] - 40)
    assert magenta.sum() >= 8, f"glob pixels not magenta ({px[:6].tolist()})"


def test_the_glob_trails_behind_a_moving_body():
    """It dribbles down his travel — the swarm is following THAT, so a
    marked runner must read as MORE than a marked stander."""
    still = _arena()
    rs = Renderer(still)
    _tick(still, 2)
    rs.consume_fx(still.fx)
    standing = len(_brand_diff(still, rs, moving=False))

    s = _arena()
    r = Renderer(s)
    _tick(s, 2)
    r.consume_fx(s.fx)
    running = len(_brand_diff(s, r, moving=True))
    assert running > standing * 1.5, (
        f"a marked runner drew {running}px against a stander's {standing}px "
        "— the trail is not reading")


# ---------------------------------------------------------------------------
# gate 53: the machine's dead arcs. Every test below fails on the run-53
# build — WARNING collapsed to one tick, APPROACH had no exit but LOS or
# death, and the caller was deaf to a firefight in the next chamber.
#
# These need a caller that genuinely CANNOT see the player: down the
# straight two-chamber arena a shrieker sights him through the doorway on
# tick one and is already past SENTINEL before the stimulus lands.
# ---------------------------------------------------------------------------

def _blind_arena():
    """An L: r0 (player) -> r1 -> r2 around a right-angle corner, so a
    body in r2 has no sightline to r0."""
    b = LevelBuilder("MARKL", 1)
    r0 = b.rect(0, 0, 400, 180, kind="dock")
    r1 = b.rect(400, 0, 160, 180, kind="corridor")
    r2 = b.rect(400, 180, 160, 180, kind="corridor")
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 1, r2, 3)
    b.player(r0, (60.0, 90.0))
    b.exit(r2, (480, 270))
    return GameSession(b.build(), seed=9, screen=(640, 360), zoom=0.45)


def _phase(e):
    """SENTINEL is the machine's resting phase and writes no key — the
    absence IS the state (only transitions record one)."""
    return e.get("phase", "sentinel")


def _blind_sentinel(s):
    eid = s.spawn_enemy(2, (0.0, 0.0), "shrieker")
    _tick(s)
    assert s.senses.sight_of(eid, s.pid) is None, (
        "the arena is not blind — this test would measure nothing")
    assert _phase(s.enemies[eid]) == "sentinel"
    return eid


def _draw_it_out(s, eid, e, limit=60 * 120):
    """Pull the caller off its post with a real firefight in the player's
    chamber and run until it lays eyes on him — no injected state: the
    quorum wakes it, the fields carry it, its own sightline stops it."""
    for _ in range(limit):
        pp = s.player_polygon()
        s.signals.emit(SignalKind.NOISE, pp, 0.9, s.tick_count)
        s.signals.emit(SignalKind.DISTRESS, pp, 0.9, s.tick_count)
        _tick(s)
        if _phase(e) == "warning" and s.sim.get_polygon(eid) != e["home"]:
            return True
    return False


def test_home_is_the_post_not_wherever_it_happened_to_see_him():
    """The ratified arc is 'shriek + Distress, run home to raise the
    squad'. Assigning home at the SIGHTING made 'polygon == home' true on
    the next tick, so the run home — a third of the machine — never
    executed, and the old unit test hid it by pre-setting home."""
    s = _blind_arena()
    eid = _blind_sentinel(s)
    e = s.enemies[eid]
    assert e["home"] == 2, "home was not the post"
    assert _draw_it_out(s, eid, e), "the caller never sighted the player"
    assert e["home"] == 2, (
        "the sighting overwrote the post — the run home is dead code")


def test_warning_actually_travels_home_before_approaching():
    s = _blind_arena()
    eid = _blind_sentinel(s)
    e = s.enemies[eid]
    assert _draw_it_out(s, eid, e), "the caller never sighted the player"
    warning_ticks = 0
    for _ in range(60 * 120):
        _tick(s)
        if _phase(e) != "warning":
            break
        warning_ticks += 1
    assert warning_ticks > 1, (
        f"warning lasted {warning_ticks} ticks — the arc is still dead")
    assert s.sim.get_polygon(eid) == e["home"], (
        "it left WARNING without ever reaching its post")


def test_a_firefight_next_door_sends_it_looking_but_never_screaming():
    """The quorum door: a caller deaf to the fight it exists to report is
    a mechanic that never plays (measured: 6214 sentinel ticks, 0 marks).
    It commits UNCRIED — Distress can move it, never make it scream."""
    s = _blind_arena()
    eid = _blind_sentinel(s)
    e = s.enemies[eid]
    for _ in range(60 * 30):
        polygon = s.sim.get_polygon(eid)
        s.signals.emit(SignalKind.NOISE, polygon, 0.9, s.tick_count)
        s.signals.emit(SignalKind.DISTRESS, polygon, 0.9, s.tick_count)
        _tick(s)
        if _phase(e) != "sentinel":
            break
    assert _phase(e) == "approach", (
        f"the fields made it {_phase(e)} — only first-hand contact may cry")
    assert not e.get("cried"), "it screamed for a fight it never saw"


def test_the_door_hears_gunfire_not_cries():
    """Gate 54, s4 e406: 'nothing calls' at 7310, max-quorum re-commit at
    7414 — standing in its own 104-tick-old cry. Distress is the caller
    guild's own channel (WARNING is its heavy emitter) and lives 45s; a
    commit door that samples it re-arms the unit off its own residue, so
    the door hears the world's gunfire only — the MUSTER stand-down
    exclusion, same law. Noise lives 3s and cannot latch anything."""
    # a BIG bent arena: the patrol legitimately wanders into sight
    # eventually (no leash, and an unreachable island gets no AI at all
    # under ACTIVE_HOPS), so each arm runs on a fresh session and the
    # hold-arm ends exactly at first sight — big rooms buy the door
    # many decision ticks before then
    def door_arena():
        b = LevelBuilder("DOOR", 1)
        r0 = b.rect(0, 0, 400, 360, kind="dock")
        r1 = b.rect(400, 0, 400, 360, kind="corridor")
        r2 = b.rect(400, 360, 400, 360, kind="corridor")
        b.connect(r0, 2, r1, 0)
        b.connect(r1, 1, r2, 3)
        b.player(r0, (60.0, 180.0))
        b.exit(r2, (780.0, 700.0))
        s = GameSession(b.build(), seed=9, screen=(640, 360), zoom=0.45)
        eid = s.spawn_enemy(2, (780.0, 700.0), "shrieker")
        _tick(s)
        assert s.senses.sight_of(eid, s.pid) is None, "arena is not blind"
        return s, eid, s.enemies[eid]

    # arm 1: while cries alone fill the field — its own or anyone's —
    # nothing but its own eyes may move it. Hold until first sight.
    s, eid, e = door_arena()
    doors = 0
    for _ in range(60 * 60):
        if s.senses.sight_of(eid, s.pid) is not None:
            break
        polygon = s.sim.get_polygon(eid)
        s.signals.emit(SignalKind.DISTRESS, polygon, 0.9, s.tick_count)
        if (s.tick_count + 1 + eid) % 10 == 0:
            doors += 1          # decision ticks lived through, saturated
        _tick(s)
        assert _phase(e) == "sentinel", (
            f"cries alone committed it at t={s.tick_count} — the "
            f"self-excitation latch is back")
    assert doors >= 12, (
        f"the arena gave the door only {doors} saturated decision ticks "
        f"before first sight — this run proved nothing")
    # arm 2: gunfire alone still slams the door open — the fix must not
    # re-deafen the caller to the fight it exists to report. Fresh
    # session: the sighting that ended arm 1 legitimately took that
    # unit to WARNING, so it is no longer a resting sentinel.
    s, eid, e = door_arena()
    for _ in range(60 * 20):
        if s.senses.sight_of(eid, s.pid) is not None:
            break
        polygon = s.sim.get_polygon(eid)
        s.signals.emit(SignalKind.NOISE, polygon, 0.9, s.tick_count)
        _tick(s)
        if _phase(e) != "sentinel":
            break
    assert _phase(e) == "approach", (
        f"gunfire never moved it (still {_phase(e)}) — the door is deaf")
    assert not e.get("cried")


def test_a_crowd_alone_is_not_a_call():
    """Seed 4's flap, in miniature: every fast re-commit measured
    committed==peers (3/3, 5/5) with noise 0.000-0.015 — a caller posted
    in a garrison re-armed off the CROWD, and that door's 12661 ticks of
    approach tenure bought zero markers all session. The cry recruits
    the husks (their door rightly hears Distress); the caller holds its
    post until something actually FIGHTS nearby (Noise above the same
    floor that defines 'faint' for stand-down)."""
    b = LevelBuilder("CROWD", 1)
    r0 = b.rect(0, 0, 400, 360, kind="dock")
    r1 = b.rect(400, 0, 400, 360, kind="corridor")
    r2 = b.rect(400, 360, 400, 360, kind="corridor")
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 1, r2, 3)
    b.player(r0, (60.0, 180.0))
    b.exit(r2, (780.0, 700.0))
    s = GameSession(b.build(), seed=9, screen=(640, 360), zoom=0.45)
    eid = s.spawn_enemy(2, (780.0, 700.0), "shrieker")
    for i in range(3):
        s.spawn_enemy(2, (700.0 + 24.0 * i, 640.0), "husk")
    _tick(s)
    assert s.senses.sight_of(eid, s.pid) is None, "arena is not blind"
    e = s.enemies[eid]
    committed_seen = 0
    for _ in range(60 * 60):
        if s.senses.sight_of(eid, s.pid) is not None:
            break
        polygon = s.sim.get_polygon(eid)
        s.signals.emit(SignalKind.DISTRESS, polygon, 0.9, s.tick_count)
        _tick(s)
        committed_seen = max(committed_seen, sum(
            1 for oid, oe in s.enemies.items()
            if oid != eid and oe["state"] in ("waking", "hunt")))
        assert _phase(e) == "sentinel", (
            f"the crowd committed it at t={s.tick_count} with "
            f"{committed_seen} peers hunting — the garrison flap is back")
    assert committed_seen >= 2, (
        f"only {committed_seen} husks ever hunted — the crowd this test "
        f"exists to resist never formed, so it proved nothing")


def test_a_dispatched_caller_marches_delivers_and_only_then_posts():
    """Gate 55 (FAIL p=0.93): the shrieker branch ran BEFORE the
    dispatched-march/DELIVERED block and `continue`d past it — a
    dispatched caller never marched to its breach, never shed the tag,
    so route interest pinned the breach open forever (13/13 seams
    across seeds; every s4 seam ended permanently pinned). Dispatch
    transit is generic locomotion; the caller's machine begins at the
    POST, and for a dispatched caller the post is the delivery ground."""
    from types import SimpleNamespace
    b = LevelBuilder("DISPATCH", 1)
    r0 = b.rect(0, 0, 400, 300, kind="dock")
    b.player(r0, (60.0, 150.0))
    b.exit(r0, (380.0, 150.0))
    s = GameSession(b.build(), seed=5, screen=(640, 360), zoom=0.45)
    s._open_breach(SimpleNamespace(chamber=0, position=(200.0, 0.0)))
    assert s.breaches, "no breach opened — this harness proves nothing"
    bid = s.breaches[0]["obj"].breach_id
    s._dispatch_unit(bid, "shrieker")
    eid = next(i for i, e in s.enemies.items() if e["kind"] == "shrieker")
    e = s.enemies[eid]
    assert e.get("dispatched") is not None, "dispatch never tagged it"
    for _ in range(60 * 30):
        _tick(s)
        if e.get("dispatched") is None:
            break
    assert e.get("dispatched") is None, (
        "the caller never delivered — the sentinel machine is eating "
        "the march and the tag again, and its breach can never seal")
    assert s.sim.get_polygon(eid) not in s._hub_chamber_set, (
        "the tag shed while the body is still in the hub")
    _tick(s, 20)
    assert e.get("home") is not None \
        and e["home"] not in s._hub_chamber_set, (
        "the post must be the DELIVERY ground, not the hub court")


def test_being_shot_is_first_hand_and_does_cry():
    s = _blind_arena()
    eid = _blind_sentinel(s)
    s._damage_enemy(eid, 1.0, s.sim.get(eid).pos.offset(1.0, 0.0), 0.0, source="test")
    _tick(s)
    e = s.enemies[eid]
    assert _phase(e) == "warning", "a shot sentinel did not raise the alarm"
    # and the cry itself must leave it — WARNING does not hand off until
    # it does, even standing on its own post
    for _ in range(600):
        _tick(s)
        if e.get("cried"):
            break
    assert e.get("cried"), "a shot caller never screamed"


def test_approach_stands_down_when_its_patience_runs_out():
    """Gate 53: 26 hunt entries, 0 exits, seven callers stuck in hunt for
    the rest of the session, each holding its chamber active forever."""
    from perihelion.sim import SHRIEK_APPROACH_PATIENCE
    s = _blind_arena()
    eid = _blind_sentinel(s)
    e = s.enemies[eid]
    e["phase"] = "approach"
    e["approach_t"] = s.tick_count
    e["cried"] = True
    s._set_enemy_state(eid, e, "hunt")
    for _ in range(SHRIEK_APPROACH_PATIENCE + 240):
        _tick(s)
        if _phase(e) == "sentinel":
            break
    assert _phase(e) == "sentinel", "the search never gave up"
    assert e["state"] == "idle", "it stood down but stayed in the census"
    assert not e.get("cried"), "the cry flag survived the stand-down"
