"""The Adversary's arsenal, tested ACROSS A PORTAL.

Director: "Obviously adversaries should have an attack. Their AI should
use it DEFENSIVELY, to produce knockback like the player bot does when
it gets chased." And then: the push should not be their only attack.

So there are two tools and each buys a different thing:

    close   SHOVE   buys DISTANCE
    middle  SNARE   buys TIME

Both fire only from the flee state. Neither is a damage weapon.

WHY EVERY FIXTURE HERE HAS TWO CHAMBERS. Gate 66 failed this feature at
p=0.04 because the aim, the range gate and the knockback vector all
subtracted the SHOOTER's frame from the PLAYER's frame. In portal space
those are unrelated the moment a shot crosses a chamber — and 63 of 64
filmed fires crossed one. The tests did not catch it because every
fixture was a single rect, where the two frames coincide: the one case
that occurred once in sixty-four. A single-chamber test of a portal game
is not a test, so the cross-portal case is the DEFAULT here and the
same-chamber case is the special one.
"""
from __future__ import annotations

from perihelion.levels import LevelBuilder
from perihelion.sim import ENEMIES, GameSession, InputFrame


def _two_chamber(kind="vagrant", gap=120.0):
    """Player and Adversary in DIFFERENT chambers, in portal-composed
    sight of each other. Returns (session, eid, sighting)."""
    b = LevelBuilder("SHOVE2", 1)
    r0 = b.rect(0, 0, 400, 300)
    r1 = b.rect(400, 0, 200, 300)
    b.connect(r0, 2, r1, 0)
    b.player(r1, (500, 150))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    # measured: this geometry composes to ~200u through the portal,
    # inside every kind's shove range
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
    b = LevelBuilder("SHOVE1", 1)
    r0 = b.rect(0, 0, 600, 400)
    b.player(r0, (150.0, 0.0))
    s = GameSession(b.build(), seed=4, screen=(640, 360), zoom=0.45)
    s.tick(InputFrame())
    px, py = s.player_pos()
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

def test_a_cross_portal_shove_is_aimed_and_connects():
    """The defect gate 66 caught: the round has to be aimed on composed
    coordinates and actually reach a player in another chamber."""
    s, eid, hit = _two_chamber()
    assert hit.distance <= ENEMIES["vagrant"]["shove_range"], (
        "fixture must put the player INSIDE shove range by real portal "
        "distance")
    _flee(s, eid)
    hp0 = s.hp
    for _ in range(240):
        s.tick(InputFrame())
        if s.hp < hp0:
            break
    assert s.hp < hp0, (
        "a cross-portal shove must reach the player it was aimed at")


def test_a_distant_cross_chamber_player_is_not_fired_on():
    """The range gate has to run on the real portal distance too, or the
    Adversary shoots at players it cannot possibly reach."""
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
    assert not _rounds(s, "shove") and not _rounds(s, "snare"), (
        "nothing may be fired at a player outside real portal range")


def test_the_knockback_pushes_away_across_a_portal():
    """Direction, measured the only way that means anything in portal
    space: the composed distance between the two bodies must grow."""
    s, eid, hit = _two_chamber()
    _flee(s, eid)
    before = hit.distance
    hp0 = s.hp
    for _ in range(240):
        s.tick(InputFrame())
        if s.hp < hp0:
            break
    assert s.hp < hp0, "no shove landed"
    for _ in range(24):
        s.tick(InputFrame())
    after = s.senses.sight_of(eid, s.pid)
    assert after is not None, "lost sight of the body under test"
    assert after.distance > before, (
        f"the shove must push the player AWAY: composed distance went "
        f"{before:.0f}u -> {after.distance:.0f}u")


# ---------------------------------------------------------------------------
# discipline: defensive only, not a damage weapon
# ---------------------------------------------------------------------------

def test_an_adversary_that_is_not_fleeing_never_fires():
    """The whole point. Neither tool is an opener."""
    s, eid, _ = _two_chamber()
    s.enemies[eid].pop("scout", None)
    for _ in range(400):
        s.tick(InputFrame())
        assert not _rounds(s, "shove") and not _rounds(s, "snare"), (
            "the arsenal is defensive: an Adversary that is not running "
            "does not have it")


def test_neither_tool_is_a_damage_weapon():
    for kind in ("vagrant", "lacuna"):
        d = ENEMIES[kind]
        assert d["shove_dmg"] <= 3, (
            f"{kind}: the shove buys spacing, it does not trade")
        assert d["shove_imp"] >= 200.0, (
            f"{kind}: too weak to move the player, which is its purpose")
        assert 0.0 < d["snare_slow"] < 1.0, (
            f"{kind}: the snare must slow, not stop — a hard stop is a "
            f"stunlock and this faction does not get one")
        assert d["snare_range"] > d["shove_range"], (
            f"{kind}: the snare answers the MIDDLE distance, so it must "
            f"reach further than the shove or it never gets chosen")


# ---------------------------------------------------------------------------
# the snare
# ---------------------------------------------------------------------------

def test_the_snare_is_chosen_at_middle_range_and_slows_the_player():
    """Out past the shove but inside the snare: the runner buys time
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
    assert d["shove_range"] < hit.distance <= d["snare_range"], (
        f"fixture must sit in the SNARE band, got {hit.distance:.0f}u")
    _flee(s, eid)
    for _ in range(400):
        s.tick(InputFrame())
        if s.snare_t > 0:
            break
    assert s.snare_t > 0, "the snare never took hold"
    assert 0.0 < s.snare_slow < 1.0
    assert not _rounds(s, "shove"), (
        "at middle range the shove must not be the tool chosen")


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


def test_the_same_chamber_case_still_works():
    """The old single-rect case is now the SPECIAL one, kept so the
    portal-composed path cannot regress it."""
    s, eid = _same_chamber()
    _flee(s, eid)
    hp0 = s.hp
    for _ in range(240):
        s.tick(InputFrame())
        if s.hp < hp0:
            break
    assert s.hp < hp0, "a same-chamber shove must still connect"
