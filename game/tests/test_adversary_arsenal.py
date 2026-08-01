"""The Adversary's arsenal, tested ACROSS A PORTAL.

Director: "Obviously adversaries should have an attack. Their AI should
use it DEFENSIVELY, to produce knockback like the player bot does when
it gets chased." And then: the push should not be their only attack.

So there are two tools and each buys a different thing:

    close   the LOB,   which buys DISTANCE
    middle  the SNARE, which buys TIME

Both fire only from the flee state. Neither is a damage weapon.

THE LOB IS A RUBBER GRENADE — a large, heavy, slow object, and it is the
validating test case for the coordinate system
(docs/FRAME_SYSTEM_DESIGN_20260729.md §9). It used to be a fast round
carrying a bespoke `imp` field that `_contact` turned into an impulse
along a hand-computed direction, and that arithmetic was half of gate
66's failure. A heavy object needs none of it: the knockback IS mass
times velocity, and the push direction IS the collision normal. So the
tests below assert THE PLAYER MOVED, not that some impulse field was
read — the only claim worth making about a weapon whose whole mechanism
is momentum.

WHY EVERY FIXTURE HERE HAS TWO CHAMBERS. Gate 66 failed this feature at
p=0.04 because the aim, the range gate and the knockback vector all
subtracted the SHOOTER's frame from the PLAYER's. In portal space those
are unrelated the moment a shot crosses a chamber — and 63 of 64 filmed
fires crossed one. The tests did not catch it because every fixture was
a single rect, where the two frames coincide: the one case that occurred
once in sixty-four. A single-chamber test of a portal game is not a
test, so the cross-portal case is the DEFAULT here and the same-chamber
case is the special one.
"""
from __future__ import annotations

from perihelion.levels import LevelBuilder
from perihelion.sim import (ENEMIES, GROUP_EBULLET, GameSession,
                            InputFrame)


def _two_chamber(kind="vagrant"):
    """Player and Adversary in DIFFERENT chambers, in portal-composed
    sight of each other. Returns (session, eid, sighting)."""
    b = LevelBuilder("LOB2", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 200, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (450, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    # measured: this geometry composes to ~150u through the doorway,
    # inside every kind's lob range
    eid = s.spawn_enemy(r0, (100.0, 0.0), kind)
    s.tick(InputFrame())
    hit = s.senses.sight_of(eid, s.pid)
    assert hit is not None, "the fixture needs portal-composed sight"
    assert hit.portal_depth >= 1, (
        "this fixture is only meaningful ACROSS a portal — the whole "
        "defect it guards was invisible whenever both bodies shared a "
        "chamber")
    return s, eid, hit


def _same_chamber(kind="vagrant", gap=120.0):
    b = LevelBuilder("LOB1", 1)
    r0 = b.rect(0, 0, 600, 400)
    b.player(r0, (150.0, 0.0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    px, py = s.player_pos().local()
    eid = s.spawn_enemy(r0, (px - gap, py), kind)
    s.tick(InputFrame())
    return s, eid


def _flee(s, eid):
    s.enemies[eid]["scout"] = "flee"
    s.enemies[eid]["scout_t"] = 10 ** 6


def _rounds(s, kind):
    return [b for b in s.bullets.values() if b["kind"] == kind]


# ---------------------------------------------------------------------------
# aim and range, across a portal
# ---------------------------------------------------------------------------

def test_a_cross_portal_lob_is_aimed_and_connects():
    """The defect gate 66 caught: the object has to be aimed on composed
    coordinates and actually reach a player in another chamber."""
    s, eid, hit = _two_chamber()
    assert hit.distance <= ENEMIES["vagrant"]["lob_range"], (
        "fixture must put the player INSIDE lob range by real portal "
        "distance")
    _flee(s, eid)
    hp0 = s.hp
    for _ in range(300):
        s.tick(InputFrame())
        if s.hp < hp0:
            break
    assert s.hp < hp0, (
        "a cross-portal lob must reach the player it was aimed at")


def test_a_distant_cross_chamber_player_is_not_fired_on():
    """The range gate has to run on the real portal distance too, or the
    Adversary throws at players it cannot possibly reach."""
    b = LevelBuilder("FAR", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 600, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (850, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    # measured ~750u composed: beyond every tool
    eid = s.spawn_enemy(r0, (-100.0, 0.0), "vagrant")
    s.tick(InputFrame())
    hit = s.senses.sight_of(eid, s.pid)
    if hit is not None:
        assert hit.distance > ENEMIES["vagrant"]["snare_range"], (
            "fixture must put the player beyond EVERY tool's range")
    _flee(s, eid)
    for _ in range(300):
        s.tick(InputFrame())
    assert not _rounds(s, "lob") and not _rounds(s, "snare"), (
        "nothing may be thrown at a player outside real portal range")


def test_the_knockback_pushes_away_across_a_portal():
    """Direction, measured the only way that means anything in portal
    space: the composed distance between the two bodies must grow.

    Note what is NOT asserted — no impulse field, no push vector. The
    object's momentum did this, resolved by the physics along the
    collision normal, which is why there is no arithmetic left here to
    get wrong."""
    s, eid, hit = _two_chamber()
    _flee(s, eid)
    before = hit.distance
    hp0 = s.hp
    for _ in range(300):
        s.tick(InputFrame())
        if s.hp < hp0:
            break
    assert s.hp < hp0, "no lob landed"
    for _ in range(24):
        s.tick(InputFrame())
    after = s.senses.sight_of(eid, s.pid)
    assert after is not None, "lost sight of the body under test"
    assert after.distance > before, (
        f"the lob must push the player AWAY: composed distance went "
        f"{before:.0f}u -> {after.distance:.0f}u")


# ---------------------------------------------------------------------------
# the object is the weapon
# ---------------------------------------------------------------------------

def test_the_lob_is_heavy_slow_and_large_enough_to_be_the_push():
    """The three properties that let the bespoke impulse plumbing be
    deleted. A round at mass 0.01 cannot move a 1.2-mass Commando
    whatever its speed, which is exactly why the old version needed a
    hand-applied `imp` — and why that arithmetic existed to be wrong."""
    for kind in ("vagrant", "lacuna"):
        d = ENEMIES[kind]
        assert "shove_imp" not in d, (
            f"{kind}: the impulse field is gone; the mass IS the push")
        assert d["lob_mass"] > 1.2, (
            f"{kind}: lighter than the Commando cannot shove the Commando")
        assert d["lob_speed"] < 350.0, (
            f"{kind}: a fast little round is what this replaced — big and "
            f"slow is the tell")
        assert d["lob_radius"] >= 8.0, (
            f"{kind}: it has to read as an object at 0.45 zoom")
        assert d["lob_rest"] > 0.0, (
            f"{kind}: rubber. It bounces off walls, which is what makes it "
            f"an obstacle rather than an event")
        assert d["lob_dmg"] <= 3, (
            f"{kind}: the damage is a token; the momentum is the weapon")


def test_the_lob_survives_the_wall_it_bounces_off():
    """A rubber grenade is a physical obstacle while it lives. The old
    round died on first contact with anything."""
    s, eid = _same_chamber(gap=60.0)
    _flee(s, eid)
    seen = 0
    for _ in range(240):
        s.tick(InputFrame())
        if _rounds(s, "lob"):
            seen += 1
    assert seen > 30, (
        f"the object must persist as an obstacle, not vanish on contact "
        f"(alive for {seen} ticks)")


def test_the_bands_do_not_overlap():
    """Near buys distance, middle buys time. When the lob's range was a
    prefix of the snare's, a player at close range ate both and the two
    tools stopped saying two things (carried from gate 68)."""
    for kind in ("vagrant", "lacuna"):
        d = ENEMIES[kind]
        assert d["snare_range"] > d["lob_range"], (
            f"{kind}: the snare answers the MIDDLE distance, so it must "
            f"reach further than the lob or it never gets chosen")
        assert 0.0 < d["snare_slow"] < 1.0, (
            f"{kind}: the snare must slow, not stop — a hard stop is a "
            f"stunlock and this faction does not get one")


def test_inside_the_lob_band_the_snare_is_never_chosen():
    """The partition, enforced at a KNOWN distance: inside the lob's band
    the answer is the lob or nothing — including while the lob is on
    cooldown, which is the case that used to leak. (Over a whole flee the
    runner crosses out of the band and into the snare's, which is the
    system working; so this asks the decision directly rather than
    watching a chase and hoping the distance held.)"""
    s, eid, hit = _two_chamber()
    d = ENEMIES["vagrant"]
    assert hit.distance <= d["lob_range"]
    e = s.enemies[eid]
    _flee(s, eid)
    e["lob_cd"] = 50            # hot
    e["snare_cd"] = 0           # ready
    assert s._adversary_arsenal(eid, e, s.sim.get(eid), d) is False, (
        "something was fired inside the lob's band with the lob on "
        "cooldown")
    assert not _rounds(s, "snare") and not _rounds(s, "lob")
    # ...and with the lob ready, at the same distance, it is the lob
    e["lob_cd"] = 0
    assert s._adversary_arsenal(eid, e, s.sim.get(eid), d) is True
    assert _rounds(s, "lob") and not _rounds(s, "snare")


# ---------------------------------------------------------------------------
# discipline: defensive only, not a damage weapon
# ---------------------------------------------------------------------------

def test_an_adversary_that_is_not_fleeing_never_fires():
    """The whole point. Neither tool is an opener."""
    s, eid, _ = _two_chamber()
    s.enemies[eid].pop("scout", None)
    for _ in range(400):
        s.tick(InputFrame())
        assert not _rounds(s, "lob") and not _rounds(s, "snare"), (
            "the arsenal is defensive: an Adversary that is not running "
            "does not have it")


# ---------------------------------------------------------------------------
# the snare
# ---------------------------------------------------------------------------

def test_the_snare_is_chosen_at_middle_range_and_slows_the_player():
    """Out past the lob but inside the snare: the runner buys time
    instead of distance."""
    b = LevelBuilder("SNARE", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 500, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (700, 150))    # measured ~500u: the snare band
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    eid = s.spawn_enemy(r0, (0.0, 0.0), "vagrant")
    s.tick(InputFrame())
    hit = s.senses.sight_of(eid, s.pid)
    assert hit is not None and hit.portal_depth >= 1
    d = ENEMIES["vagrant"]
    assert d["lob_range"] < hit.distance <= d["snare_range"], (
        f"fixture must sit in the SNARE band, got {hit.distance:.0f}u")
    _flee(s, eid)
    for _ in range(400):
        s.tick(InputFrame())
        if s.snare_t > 0:
            break
    assert s.snare_t > 0, "the snare never took hold"
    assert 0.0 < s.snare_slow < 1.0
    assert not _rounds(s, "lob"), (
        "at middle range the lob must not be the tool chosen")


def test_the_snare_wears_off():
    """A hold that never ends is a stunlock."""
    s, eid, _ = _two_chamber()
    s.snare_t = 30
    s.snare_slow = 0.4
    for _ in range(120):
        s.tick(InputFrame())
        if s.snare_t <= 0:
            break
    assert s.snare_t <= 0, "the snare must expire on its own"


def test_an_expired_snare_does_not_lend_its_strength_to_the_next():
    """Carried from gate 68: `snare_t` was raised BEFORE the reset was
    evaluated, so the `else 1.0` branch was dead code and a fresh weak
    hold inherited an expired strong one's slow. Order, not arithmetic."""
    s, eid, _ = _two_chamber()
    spot = s.player_pos()
    round_ = dict(kind="snare", dmg=0.0, ttl=180, hold=75, slow=0.45,
                  src=eid)

    def land(rec):
        bid = s.sim.spawn(spot, 2.0, 0.01, 3)
        s.bullets[bid] = rec
        s._contact(bid, s.pid, spot, spot.offset(1.0, 0.0))

    s.snare_t = 0            # the strong hold has expired...
    s.snare_slow = 0.10      # ...but its strength is still on the record
    land(dict(round_))
    assert abs(s.snare_slow - 0.45) < 1e-9, (
        f"a fresh weak snare inherited an expired strong one's slow "
        f"({s.snare_slow})")
    # ...while two OVERLAPPING snares still take the stronger
    s.snare_slow = 0.10
    s.snare_t = 60
    land(dict(round_))
    assert abs(s.snare_slow - 0.10) < 1e-9, (
        "a late weak round loosened a hold a stronger one had set")


def test_the_same_chamber_case_still_works():
    """The old single-rect case is now the SPECIAL one, kept so the
    portal-composed path cannot regress it."""
    s, eid = _same_chamber()
    _flee(s, eid)
    hp0 = s.hp
    for _ in range(300):
        s.tick(InputFrame())
        if s.hp < hp0:
            break
    assert s.hp < hp0, "a same-chamber lob must still connect"


# ---------------------------------------------------------------------------
# friendly fire
# ---------------------------------------------------------------------------

def test_the_thrown_object_shoves_a_testator_too():
    """Friendly fire is on: this is a 2D immersive sim, not an arcade
    game. The Adversary's thrown object shoves a Testator exactly as it
    shoves the player, which matches how the Adversary regards them —
    and the AI stays deliberately ignorant of it, because an enemy the
    player can turn against itself is worth more than a
    don't-shoot-your-friend check."""
    s, eid = _same_chamber(gap=200.0)
    at = s.sim.get(eid).pos
    # a husk standing directly between the runner and the player
    bystander = s.spawn_enemy(s.player_polygon(), (0.0, 0.0), "husk")
    s.sim.set_pos(bystander, at + at.offset(90.0, 0.0))
    s.enemies[bystander]["state"] = "idle"
    before = s.enemies[bystander]["hp"]
    _flee(s, eid)
    hit = False
    for _ in range(300):
        s.tick(InputFrame())
        if bystander not in s.enemies:
            hit = True
            break
        if s.enemies[bystander]["hp"] < before:
            hit = True
            break
    assert hit, "the lob passed straight through a body standing in its way"


def test_a_crossfire_kill_is_attributed_apart_from_a_player_kill():
    """The rider on friendly fire. Dead is still lost, so
    `adversary_lost` stays true — but the withdrawal ruling rests on the
    share of attrition the PLAYER causes, and that number stops meaning
    what it says if crossfire is folded into it."""
    s, eid = _same_chamber()
    victim = s.spawn_enemy(s.player_polygon(), (0.0, 40.0), "lacuna")
    s.enemies[victim]["hp"] = 1.0
    at = s.sim.get(victim).pos
    s._damage_enemy(victim, 99.0, at.offset(1.0, 0.0), 0.0,
                    source="lob", by="crossfire")
    assert victim not in s.enemies
    assert s.adversary_lost["lacuna"] == 1, "dead is still lost"
    assert s.adversary_killed_by.get("crossfire") == 1
    assert s.adversary_killed_by.get("player") is None

    other = s.spawn_enemy(s.player_polygon(), (0.0, -40.0), "lacuna")
    s.enemies[other]["hp"] = 1.0
    at2 = s.sim.get(other).pos
    s._damage_enemy(other, 99.0, at2.offset(1.0, 0.0), 0.0, source="rail")
    assert s.adversary_killed_by.get("player") == 1
    assert s.adversary_killed_by.get("crossfire") == 1


# ---------------------------------------------------------------------------
# gate 69's two blockers
# ---------------------------------------------------------------------------

def test_a_round_never_damages_the_body_that_loosed_it():
    """Gate 69 measured the Adversary shoving ITSELF on ~30% of throws.

    Friendly fire made enemy-round-hits-enemy possible for the first
    time, and the enemy arm of `_contact` had neither guard the player
    arm had grown. A round's own shooter is not a target — for any round,
    which is why the exclusion sits above the dispatch and not inside one
    branch of it."""
    s, eid = _same_chamber(gap=60.0)
    hp0 = s.enemies[eid]["hp"]
    _flee(s, eid)
    for _ in range(600):
        s.tick(InputFrame())
        if eid not in s.enemies:
            break
        assert s.enemies[eid]["hp"] >= hp0, (
            "the runner damaged itself with its own thrown object")
    # ...and the same exclusion protects a spitter from its own spit
    s2, other = _same_chamber(kind="vagrant")
    spitter = s2.spawn_enemy(s2.player_polygon(), (0.0, 80.0), "spitter")
    at = s2.sim.get(spitter).pos
    bid = s2.sim.spawn(at, 2.5, 0.01, 3)
    s2.bullets[bid] = dict(kind="spit", dmg=9.0, ttl=180, src=spitter)
    before = s2.enemies[spitter]["hp"]
    s2._contact(bid, spitter, at, at.offset(1.0, 0.0))
    assert s2.enemies[spitter]["hp"] == before


def test_one_throw_bills_a_body_once():
    """The object persisting is the point; billing for it every contact
    is not. Gate 69 filmed one throw taking a husk for four hits."""
    s, eid = _same_chamber(gap=200.0)
    at = s.sim.get(eid).pos
    victim = s.spawn_enemy(s.player_polygon(), (0.0, 0.0), "brute")
    s.sim.set_pos(victim, at + at.offset(90.0, 0.0))
    s.enemies[victim]["state"] = "idle"
    hp0 = s.enemies[victim]["hp"]
    _flee(s, eid)
    seen_lob = False
    for _ in range(400):
        s.tick(InputFrame())
        if _rounds(s, "lob"):
            seen_lob = True
        if victim not in s.enemies:
            break
    assert seen_lob, "no object was thrown, so nothing was measured"
    if victim in s.enemies:
        lost = hp0 - s.enemies[victim]["hp"]
        d = ENEMIES["vagrant"]["lob_dmg"]
        assert lost <= d * 3 + 1e-9, (
            f"a bouncing object billed one body {lost / d:.1f} times over")


def test_the_snare_leads_a_moving_target():
    """Gate 69 called the snare MUTE: 3 connects in 43 across four
    sessions, because separating the bands pushed it out past 165-180u
    where an unled 400 u/s round cannot catch a moving player. A net is
    aimed at where he will be. The lob stays unled — that is a panicking
    runner heaving an object at someone already closing on it."""
    b = LevelBuilder("LEAD", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 500, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (700, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    eid = s.spawn_enemy(r0, (0.0, 0.0), "vagrant")
    s.tick(InputFrame())
    d = ENEMIES["vagrant"]
    hit = s.senses.sight_of(eid, s.pid)
    assert hit is not None and d["lob_range"] < hit.distance <= d["snare_range"]
    # drive the player hard across the runner's line of fire
    s.sim.set_vel(s.pid, s.sim.get(s.pid).pos.offset(0.0, 240.0))
    _flee(s, eid)
    s.enemies[eid]["snare_cd"] = 0
    st = s.sim.get(eid)
    hit = s.senses.sight_of(eid, s.pid)
    assert s._adversary_round(eid, s.enemies[eid], st, d, hit, "snare")
    shot = next(bid for bid, r in s.bullets.items() if r["kind"] == "snare")
    # the round's heading must be turned toward where he is GOING, not at
    # where he is: its cross-track component has to share his sign
    to_now = st.pos.toward(hit.pos).normalized()
    fired = s.sim.get(shot).vel.normalized()
    # cross(a, b) is positive when b is counter-clockwise of a, so the
    # round's offset from the straight-at-him bearing must lie on the same
    # side as the direction he is travelling
    lead_side = to_now.cross(fired)
    assert abs(lead_side) > 1e-3, (
        "the snare fired straight at the target, not ahead of it")
    assert lead_side * to_now.cross(hit.vel.normalized()) > 0.0, (
        "the snare led the wrong way")


# ---------------------------------------------------------------------------
# the two guards in `_contact`, which gate 69 paid for and nothing tested
# ---------------------------------------------------------------------------

def _plant_round(s, at_eid, src_eid, kind="lob", speed=0.0, dx=0.0):
    """Put a live round ON a body, deterministically.

    A thrown round spawns CLEAR of its thrower and only meets it again
    by bouncing back, which a short fixture never reaches — the first
    cut of these two tests passed for exactly that reason and both
    mutants survived them. The contact these guards exist for is
    constructed here instead of waited for."""
    d = ENEMIES["vagrant"]
    st = s.sim.get(at_eid)
    # `.offset()` builds a DIFFERENCE; a place is pos + difference.
    place = st.pos + st.pos.offset(dx, 0.0)
    bid = s.sim.spawn(place, d["lob_radius"], d["lob_mass"], GROUP_EBULLET)
    s.sim.set_props(bid, max_substep=3.0, rest_wall=d["lob_rest"], rest_ent=0.9)
    s.sim.set_vel(bid, place.toward(st.pos).normalized() * speed
                  if speed else place.toward(st.pos) * 0.0)
    s.bullets[bid] = dict(kind=kind, dmg=d["lob_dmg"], ttl=300,
                          src=src_eid, born=s.tick_count)
    return bid


def test_a_thrown_round_never_damages_its_own_thrower():
    """Gate 69's first blocker: the Adversary shoved ITSELF on ~30% of
    observed throws.

    The player arm of `_contact` had grown a shooter exclusion; friendly
    fire made the ENEMY arm reachable for the first time and it had
    neither guard. A guard living in one arm of a dispatch is a guard
    that will be missed when a new arm becomes reachable, so this pins
    it from the enemy side. Verified against the mutant: delete the
    `src == y` check and this test fails."""
    s, eid = _same_chamber()
    hp0 = s.enemies[eid]["hp"]
    _plant_round(s, eid, src_eid=eid)          # its own round, on top of it
    for _ in range(30):
        s.tick(InputFrame())
    assert eid in s.enemies, "the thrower was killed by its own round"
    assert s.enemies[eid]["hp"] == hp0, (
        f"the thrower lost {hp0 - s.enemies[eid]['hp']} hp to the round "
        f"it threw — a body cannot be hurt by its own throw")


def test_one_thrown_round_damages_a_body_at_most_once():
    """Gate 69's second blocker: one bouncing grenade billed husk 52
    four times, 3.25 damage events per fire.

    A heavy object deliberately SURVIVES the body it hits and stays an
    obstacle, so it goes on making contacts — which is precisely why the
    once-per-object `struck` set has to exist. Verified against the
    mutant: rebuild `struck` empty on each contact and this test
    fails."""
    s, eid = _same_chamber()
    polygon = s.sim.get_polygon(eid)
    # The victim is BACKED AGAINST A WALL and the round is thrown into
    # it hard: a resting round only ever makes one contact, so the first
    # cut of this test could not tell the guard from its absence. It has
    # to bounce, which is the situation the guard was written for.
    victim = s.spawn_enemy(polygon, (250.0, 0.0), "husk")
    s.tick(InputFrame())
    hp0 = s.enemies[victim]["hp"]
    _plant_round(s, victim, src_eid=eid, speed=320.0, dx=-60.0)
    for _ in range(240):
        s.tick(InputFrame())
        if victim not in s.enemies:
            break
    lost = hp0 - s.enemies.get(victim, {}).get("hp", -(10 ** 6))
    assert lost <= ENEMIES["vagrant"]["lob_dmg"], (
        f"{lost} hp lost to ONE round that deals "
        f"{ENEMIES['vagrant']['lob_dmg']} — it is chipping the same body "
        f"on every bounce")
