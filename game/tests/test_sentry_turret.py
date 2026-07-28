"""Friendly defensive sentry turret (director's directive, 2026-07-13):
"let's put friendly turrets in the safe-polygon corridors." The calibration
farm (tools/musiccal) measured loot/rest polygons as the DEADLIEST zone class
in the gauntlet -- 2.2x combat polygons -- because standard enemies have no
de-aggro path and simply follow a hurt player to the medkits
(FITTING_REPORT.md finding #1). Covers `GameSession.spawn_sentry` /
`_sentry_tick` (sim.py) + the engine's `sentry_acquire` LOS/terrain gate and
their data-driven placement in levels/gauntlet_cal.json via
tools/musiccal/build_gauntlet.py.

These unit tests build their own throwaway worlds (same convention as
test_flicker_lurker.py / test_cloister.py) to isolate the mechanic from
gauntlet geometry; the final test drives the real, shipped
levels/gauntlet_cal.json end to end.
"""
from __future__ import annotations

import json
import math
from pathlib import Path

from perihelion.levels import LevelBuilder, load_level
from perihelion.sim import GameSession, InputFrame, ENEMIES, SENTRIES
from perihelion.testkit.bots import nav_to_point

ROOT = Path(__file__).resolve().parents[2]
LEVEL_PATH = ROOT / "levels" / "gauntlet_cal.json"
META_PATH = ROOT / "tools" / "musiccal" / "gauntlet_meta.json"

SENTRY_RANGE = SENTRIES["sentry"]["range"]


def _one_husk(s: GameSession) -> int:
    return next(eid for eid, e in s.enemies.items() if e["kind"] == "husk")


# ---------------------------------------------------------------------
# 1. damages enemies in range + LOS
# ---------------------------------------------------------------------

def test_sentry_damages_enemy_in_range_and_los():
    """Fail-first: before `spawn_sentry`/`_sentry_tick` existed, a `"sentry"`
    entity type raised `ValueError: unknown entity type 'sentry'` at level
    load (`_spawn_from_spec`'s final `else` branch) -- there was no path
    that could ever deal damage on the player's behalf. A husk sitting
    well inside range or a clear line must now die to turret fire alone,
    with no player input at all."""
    b = LevelBuilder("sentry_range_los", 1)
    r0 = b.rect(0, 0, 300, 300)
    b.player(r0, (20, 20))  # far from both -- never in the fight itself
    b.entity(r0, "sentry", (150, 150))
    b.entity(r0, "husk", (200, 150))  # 50 units away, dead ahead: in range+LOS
    b.exit(r0, (280, 280))
    s = GameSession(b.build(), seed=1)
    assert len(s.sentries) == 1
    husk_id = _one_husk(s)
    hp0 = s.enemies[husk_id]["hp"]
    for _ in range(400):
        s.tick(InputFrame())
        if husk_id not in s.enemies:
            break
    assert husk_id not in s.enemies, \
        f"turret failed to kill an in-range, unobstructed enemy (hp0={hp0})"
    assert s.hp == 100 and not s.dead, "player must be untouched by this fight"


def test_sentry_ignores_enemy_out_of_range():
    """Fail-first companion to the test above: the SAME husk, placed just
    past SENTRIES['sentry']['range'], must never take damage -- proves
    'in range' is an active gate, not a no-op (a turret with an unbounded
    engagement radius would also pass the in-range test above)."""
    b = LevelBuilder("sentry_out_of_range", 1)
    r0 = b.rect(0, 0, 2000, 2000)
    b.player(r0, (20, 20))
    b.entity(r0, "sentry", (1000, 1000))
    far = SENTRY_RANGE + 60.0
    b.entity(r0, "husk", (1000 + far, 1000))
    b.exit(r0, (1980, 1980))
    s = GameSession(b.build(), seed=1)
    husk_id = _one_husk(s)
    tid = next(iter(s.sentries))
    _, hx, hy, *_ = s.sim.get(husk_id)
    for _ in range(200):
        s.tick(InputFrame())
        if husk_id in s.enemies:
            s.sim.set_pos(husk_id, hx, hy)  # pin: isolate range, not AI wander
            s.sim.set_vel(husk_id, 0.0, 0.0)
    assert husk_id in s.enemies and s.enemies[husk_id]["hp"] == ENEMIES["husk"]["hp"], \
        "an enemy beyond the sentry's range must never be engaged"


# ---------------------------------------------------------------------
# 2. never damages the player
# ---------------------------------------------------------------------

def test_sentry_never_damages_player():
    """Fail-first: turret bullets are spawned GROUP_PBULLET, the same
    group the player's own shots use, and `set_collision_pair(PBULLET,
    PLAYER, True)` is intentionally on ('your own rounds CAN come back').
    Without `_contact`'s explicit `kind == 'turret': pass`, a bullet this
    close to the player's own hitbox WOULD have hit them (that guard is
    pre-existing, shared with the cloister guardians -- this test pins
    the *new* call site to it).

    Geometry matters here: the player stands BETWEEN the sentry and its
    target (not merely 'colinear' on the far side of the sentry, which
    the first version of this test got wrong -- caught by deliberately
    breaking the bullet's `kind` tag during review and finding the
    'player never touched' result held for the wrong reason, because the
    bullet never actually traveled anywhere near the player). `_sentry_
    los_clear` only ever checks walk-mask TERRAIN, never other entities,
    so the sentry keeps firing at the husk straight through the player's
    own hitbox -- every one of those shots must physically contact the
    player (proven below: the husk, entirely un-occluded and in range,
    still survives, because the player's own body -- not a targeting
    exclusion -- absorbs every round before it gets there) with zero
    damage, tick after tick."""
    b = LevelBuilder("sentry_never_hits_player", 1)
    r0 = b.rect(0, 0, 400, 400)
    b.entity(r0, "sentry", (150, 250))
    b.player(r0, (150, 150))               # directly between sentry and husk
    b.entity(r0, "husk", (150, 50))
    b.exit(r0, (380, 380))
    s = GameSession(b.build(), seed=7)
    husk_id = _one_husk(s)
    _, hx0, hy0, *_ = s.sim.get(husk_id)
    tid = next(iter(s.sentries))
    _, tx0, ty0, *_ = s.sim.get(tid)
    px0, py0 = s.player_pos()
    # sanity: player strictly between sentry and husk on that line, and
    # well outside the husk's own melee-touch reach (~14.5u)
    assert math.hypot(tx0 - px0, ty0 - py0) < math.hypot(tx0 - hx0, ty0 - hy0)
    assert math.hypot(px0 - hx0, py0 - hy0) > 90.0

    # count shots by the ROUNDS the sentry actually spawns ("turret"-kind
    # bullets), not by fx: the old "flash" fx tag died when muzzle flashes
    # became real lights (2026-07-22), and bullets are the more direct
    # observable anyway
    shots_fired = 0
    seen_bullets: set[int] = set()
    for _ in range(600):
        s.tick(InputFrame())
        for bid, b_ in s.bullets.items():
            if b_.get("kind") == "turret" and bid not in seen_bullets:
                seen_bullets.add(bid)
                shots_fired += 1
        assert s.hp == 100 and not s.dead, "sentry fire must never touch the player"
        if husk_id in s.enemies:
            s.sim.set_pos(husk_id, hx0, hy0)
            s.sim.set_vel(husk_id, 0.0, 0.0)
    assert shots_fired >= 10, "test never exercised repeated sentry fire through the player"
    assert husk_id in s.enemies and s.enemies[husk_id]["hp"] == ENEMIES["husk"]["hp"], \
        ("setup sanity: the husk is un-occluded and in range, so it surviving "
         "proves every shot was consumed by the player's own hitbox, not a miss")


# ---------------------------------------------------------------------
# 3. respects walls/terrain -- fail-first with a wall between
# ---------------------------------------------------------------------

def _terrain_los_scenario(seed: int, block: bool):
    """Sentry + husk on a fixed line; the husk is pinned every tick (it
    would otherwise beeline for the player through/around any terrain --
    `tether` only holds ground across a POLYGON CHANGE, not within one, so it
    cannot be used to hold a still target here) so only the LOS check
    itself is under test, never AI pathing."""
    b = LevelBuilder("sentry_terrain_los", 1)
    r0 = b.rect(0, 0, 300, 300)
    b.player(r0, (20, 280))  # far corner: never enters this fight
    b.entity(r0, "sentry", (150, 150))
    b.entity(r0, "husk", (150, 40))
    b.exit(r0, (280, 20))
    s = GameSession(b.build(), seed=seed)
    tid = next(iter(s.sentries))
    _, tx, ty, *_ = s.sim.get(tid)
    husk_id = _one_husk(s)
    _, hx, hy, *_ = s.sim.get(husk_id)
    if block:
        mx, my = (tx + hx) / 2.0, (ty + hy) / 2.0
        s.sim.set_polygon_terrain(0, [(mx - 40.0, my - 25.0, mx + 40.0, my + 25.0)])
    for _ in range(250):
        s.tick(InputFrame())
        if husk_id in s.enemies:
            s.sim.set_pos(husk_id, hx, hy)
            s.sim.set_vel(husk_id, 0.0, 0.0)
        else:
            return "died"
    return s.enemies[husk_id]["hp"]


def test_sentry_blocked_by_terrain_between_it_and_target():
    """Fail-first: before the terrain LOS gate existed (or if it were a
    no-op, as `necore.raycast` alone would be -- it has no notion of
    walk-mask terrain; the gate is the Liang-Barsky test inside the
    engine's `sentry_acquire`),
    this asserts != 'died' and would fail against that reverted state,
    since the earlier `_turret_tick` pattern this was modeled on has no
    range/LOS gate whatsoever."""
    result = _terrain_los_scenario(seed=3, block=True)
    assert result == ENEMIES["husk"]["hp"], \
        f"a walk-mask terrain rect between the sentry and its target must " \
        f"block the shot entirely (got {result!r}, expected full, untouched hp)"


def test_sentry_kills_same_target_once_terrain_is_removed():
    """Positive control for the test above, same seed/geometry minus the
    terrain rect -- proves the 'blocked' result isn't a tautology (e.g. a
    sentry that never fires at all would also read 'undamaged')."""
    result = _terrain_los_scenario(seed=3, block=False)
    assert result == "died", \
        f"without terrain in the way the same target must die (got {result!r})"


def test_sentry_prefers_farther_visible_target_over_nearer_occluded_one():
    """The walk-mask physics collision (terrain-solid by default for every
    group, see physics.rs) already stops a fired bullet from ever tunneling
    through terrain on its own -- so a single-candidate 'blocked' test
    above passes even with the terrain gate stubbed to always return
    True (checked by hand while writing this). What that redundancy does
    NOT cover is TARGET SELECTION: without an explicit LOS check gating
    which candidate counts as 'nearest', a naive nearest-only sentry would
    keep re-selecting an occluded-but-closer enemy every cooldown cycle --
    wasting every shot against the terrain -- and would never engage a
    farther enemy standing in full view. Two pinned husks: A is nearer but
    behind terrain, B is farther with a clear line. Only a real LOS gate
    on candidate selection (not just the physics backstop) makes B die
    while A survives."""
    b = LevelBuilder("sentry_target_select", 1)
    r0 = b.rect(0, 0, 400, 400)
    b.player(r0, (20, 20))
    b.entity(r0, "sentry", (200, 200))
    b.entity(r0, "husk", (200, 250))  # A: 50u away, straight down -- occluded
    b.entity(r0, "husk", (350, 200))  # B: 150u away, straight right -- clear
    b.exit(r0, (380, 380))
    s = GameSession(b.build(), seed=9)
    tid = next(iter(s.sentries))
    _, tx, ty, *_ = s.sim.get(tid)
    husks = [eid for eid, e in s.enemies.items() if e["kind"] == "husk"]
    pos = {}
    for eid in husks:
        _, ex, ey, *_ = s.sim.get(eid)
        pos[eid] = (ex, ey)
    a_id = min(husks, key=lambda e: math.hypot(pos[e][0] - tx, pos[e][1] - ty))
    b_id = max(husks, key=lambda e: math.hypot(pos[e][0] - tx, pos[e][1] - ty))
    ax, ay = pos[a_id]
    mx, my = (tx + ax) / 2.0, (ty + ay) / 2.0
    s.sim.set_polygon_terrain(0, [(mx - 30.0, my - 15.0, mx + 30.0, my + 15.0)])

    for _ in range(400):
        s.tick(InputFrame())
        for eid in husks:
            if eid in s.enemies:
                ex, ey = pos[eid]
                s.sim.set_pos(eid, ex, ey)
                s.sim.set_vel(eid, 0.0, 0.0)

    assert a_id in s.enemies and s.enemies[a_id]["hp"] == ENEMIES["husk"]["hp"], \
        "the nearer, occluded husk must never be damaged"
    assert b_id not in s.enemies, \
        "the farther, clearly-visible husk must still be engaged and killed"


# ---------------------------------------------------------------------
# 4. deterministic
# ---------------------------------------------------------------------

def test_sentry_is_deterministic():
    def run(seed):
        b = LevelBuilder("sentry_determinism", 1)
        r0 = b.rect(0, 0, 300, 300)
        b.player(r0, (150, 150))
        b.entity(r0, "sentry", (150, 100))
        b.entity(r0, "husk", (150, 220))
        b.entity(r0, "husk", (100, 220))
        b.entity(r0, "husk", (200, 220))
        b.exit(r0, (280, 280))
        s = GameSession(b.build(), seed=seed)
        trace = []
        for i in range(250):
            s.tick(InputFrame(mx=0.3 if i % 40 < 20 else -0.3, my=0.1))
            trace.append((
                s.hp, s.dead,
                sorted(round(e["hp"], 4) for e in s.enemies.values()),
                tuple(round(c, 4) for c in s.player_pos()),
            ))
        return trace

    t1 = run(11)
    t2 = run(11)
    assert t1 == t2, "identically seeded sentry runs must produce identical trajectories"


# ---------------------------------------------------------------------
# 5. gauntlet-level integration: pursued into the loot polygon dies to the sentry
# ---------------------------------------------------------------------

def _go_to(s: GameSession, polygon_target: int, point, max_ticks: int) -> bool:
    for _ in range(max_ticks):
        px, py = s.player_pos()
        if s.player_polygon() == polygon_target and abs(px - point[0]) + abs(py - point[1]) < 20:
            return True
        if s.player_polygon() == polygon_target:
            mx, my = nav_to_point(s, px, py, point)
        else:
            e = s.sim.next_edge(s.player_polygon(), polygon_target)
            if e < 0:
                return False
            mx, my = nav_to_point(s, px, py, s.sim.edge_midpoint(s.player_polygon(), e))
        s.tick(InputFrame(mx=mx, my=my))
        if s.dead:
            return False
    return False


def test_gauntlet_pursued_into_loot_polygon_dies_to_sentry():
    """The literal scenario the director's remedy targets: walk into the
    nearest combat segment, get noticed, retreat the whole way back to the
    corridor's loot polygon (standard enemies have no de-aggro path -- see
    FITTING_REPORT.md finding #1 -- so the pursuer follows all the way
    in), and the loot polygon's own sentry must finish it off. Polygon ids are
    derived from the real level + its zone metadata, never hardcoded, so
    this survives a future re-tuning of the gauntlet's density/segments."""
    assert LEVEL_PATH.exists(), "run: uv run python tools/musiccal/build_gauntlet.py"
    assert META_PATH.exists(), "run: uv run python tools/musiccal/build_gauntlet.py"
    level = load_level(LEVEL_PATH)
    meta = json.loads(META_PATH.read_text())
    zones = meta["zones"]
    s = GameSession(level, seed=1)

    loot_polygons = {int(r) for r, z in zones.items() if z["zone"] == "loot"}
    start_loot = min(loot_polygons,
                     key=lambda r: s.sim.hop_distance(level.player_polygon, r))
    assert next(iter(s.sentries.values()), None) is not None, \
        "the real gauntlet must actually carry sentries (build_gauntlet.py regen)"

    combat_polygons_with_enemies = sorted(
        {polygon for polygon, spec in level.entities if spec.type in ENEMIES},
        key=lambda r: s.sim.hop_distance(level.player_polygon, r))
    assert combat_polygons_with_enemies, "gauntlet has zero enemies at the tuned density"
    target_polygon = combat_polygons_with_enemies[0]
    pursuer_id = next(eid for eid, e in s.enemies.items()
                      if s.sim.get_polygon(eid) == target_polygon)

    assert _go_to(s, target_polygon, (0, 0), max_ticks=1500), \
        "could not reach the nearest combat segment"
    for _ in range(60):  # let it notice and start hunting
        s.tick(InputFrame())
    assert pursuer_id in s.enemies and s.enemies[pursuer_id]["state"] != "idle", \
        "the enemy never noticed the player -- test setup didn't aggro it"

    assert _go_to(s, start_loot, (0, 0), max_ticks=1600), \
        "could not retreat to the loot polygon"
    assert not s.dead, "player died during the retreat"

    for _ in range(600):
        s.tick(InputFrame())
        if pursuer_id not in s.enemies:
            break
    assert pursuer_id not in s.enemies, \
        "the pursuer must die to the loot polygon's sentry once it follows the player in"
    assert not s.dead, "player must survive the encounter (that's the whole point)"
