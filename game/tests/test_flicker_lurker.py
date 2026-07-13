"""Adversary-lane ambush predator (director's directive, 2026-07-13):
"add an enemy that deliberately keeps to the shadows until the player
gets close, then ambushes." Covers the light-level query
(`lighting.light_level_at`), the flicker's LURK/AMBUSH/hunt state machine
(`GameSession._flicker_ai`), and the sensor-trace intensity channel
(`enemies[eid]["trace_intensity"]`, consumed by `render.py._draw_enemy`).

Lurkers are now placed in the Adversary-territory campaign levels (l07-l09
only -- director's order 2026-07-13, "common annoyance... in sections
where live Adversary troops... live"; see tools/flicker_placement.py and
test_flicker_campaign_placement.py for the placement judgment and its
invariant checks). These unit tests still build their own throwaway
worlds, same as `test_terrain_light_shadows.py`, to isolate the mechanic
from any one level's geometry.
"""
from __future__ import annotations

import math
import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

from perihelion.levels import LevelBuilder, LightSpec
from perihelion.lighting import compute_light_instances, light_level_at
from perihelion.sim import GameSession, InputFrame


def _idle_input():
    return InputFrame(mx=0, my=0, ax=240, ay=135, fire=False, alt=False,
                       interact=False, weapon=0)


# ---------------------------------------------------------------------
# 1. light-level query correctness
# ---------------------------------------------------------------------

def test_light_level_at_lit_point_vs_shadow_point():
    """Fail-first note: before `light_level_at` existed, there was no
    game-side 'how lit is this point' query at all -- an AI wanting this
    had nothing to call. With a fixture at one end of a room and a
    terrain rect between it and a point directly behind it, the lit point
    (same distance, clear of the shadow) must read meaningfully higher
    than the shadowed one, and the shadowed point must read exactly 0."""
    b = LevelBuilder("FLICKQUERY", 1)
    r0 = b.rect(-200.0, -100.0, 400.0, 200.0)
    b.player(r0, (-190.0, 0.0))
    level = b.build()
    session = GameSession(level, seed=1)
    session.sim.set_room_terrain(r0, [(0.0, -20.0, 40.0, 20.0)])
    session.lighting.add_lights(session.sim, [
        LightSpec(room=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                  intensity=1.0, radius=500.0, kind="static")])
    light_map = session.lighting.frame_lookup(session.sim)
    behind = light_level_at(light_map, session.lighting.lights, r0, 60.0, 0.0)
    beside = light_level_at(light_map, session.lighting.lights, r0, 60.0, 70.0)
    assert behind == 0.0, f"expected fully shadowed, got {behind}"
    assert beside > 0.1, f"expected a clearly lit comparison point, got {beside}"


def test_light_level_at_zero_with_no_lights():
    """A room with no lights at all (and no player worklight registered
    in `light_map`, e.g. a static-only query) reads exactly 0 everywhere
    -- no fabricated illumination."""
    b = LevelBuilder("FLICKQUERYNONE", 1)
    r0 = b.rect(-100.0, -100.0, 200.0, 200.0)
    b.player(r0, (0.0, 0.0))
    level = b.build()
    session = GameSession(level, seed=1)
    session.player_light.intensity = 0.0
    light_map = session.lighting.frame_lookup(session.sim)
    assert light_level_at(light_map, session.lighting.lights, r0, 0.0, 0.0) == 0.0


# ---------------------------------------------------------------------
# 2. LURK holds in darkness under a moving light
# ---------------------------------------------------------------------

def test_lurk_holds_low_light_position_under_moving_worklight():
    """A flicker spawned far from a STATIONARY player, with an
    independently-moving light (an `attached`-kind `LightSpec` whose
    `.pos` this test itself drives -- `frame_lookup()` recomputes an
    attached light fresh from its live `.pos` every tick, so it behaves
    exactly like a worklight without needing to actually move the player
    and risk tripping `ambush_radius`) sweeping directly over its spawn
    point, must keep its OWN position's light level below the lamp-pool
    gate on average -- it actively repositions to stay dark rather than
    sitting still and getting lit up.

    Fail-first note: with `_flicker_ai`'s reposition step short-circuited
    (`if False:` in place of the retarget condition, LURK holding its
    spawn position unconditionally), the sampled-lit fraction jumped from
    ~0 to over 0.9 as the light swept directly across the held spawn
    point. Reverted before committing.

    A separate, REAL bug (not a test-code mutation) was caught fail-first
    while building `tools/playtest/flicker_lurker_demo.py`: the original
    reposition condition retargeted on a periodic cooldown even while
    ALREADY dark, and once fully outside every light's radius
    (`light_level_at` returns exactly 0.0, not just low) all 8 sampled
    candidate directions tie at 0.0 -- Python's `min()` first-seen
    tie-break then always picked the same candidate angle, so a lurker
    that had already reached true darkness kept "repositioning" in a
    fixed direction forever with no bound (confirmed: the demo's lurker
    walked ~150 units off its intended shadow spot over one capture run).
    Fixed in `_flicker_ai` (retarget only while actually in a lamp pool,
    plus a randomized angle-sweep phase as a second line of defense
    against the same tie-break class); see that function's own comment.
    """
    b = LevelBuilder("FLICKLURK", 1)
    r0 = b.rect(-220.0, -220.0, 440.0, 440.0)
    b.player(r0, (-200.0, -200.0))  # far corner -- stays put, never threatens ambush
    level = b.build()
    session = GameSession(level, seed=5)
    session.player_light.intensity = 0.0  # isolate the swept light below
    eid = session.spawn_enemy(r0, (100.0, 100.0), "flicker")
    sweep_light = LightSpec(room=r0, pos=(100.0, 100.0), color=(255, 255, 255),
                            intensity=1.0, radius=140.0, kind="attached")
    session.lighting.lights.append(sweep_light)

    n_ticks = 500
    lit_samples = 0
    total_samples = 0
    for i in range(n_ticks):
        # sweep back and forth directly across the lurker's spawn point
        sweep_light.pos = (100.0 + 130.0 * math.sin(i * 0.05), 100.0)
        session.tick(InputFrame(mx=0, my=0, ax=240, ay=135, fire=False, alt=False,
                                interact=False, weapon=0))
        e = session.enemies.get(eid)
        assert e is not None, "lurker died/despawned unexpectedly"
        assert e["state"] == "lurk", (
            "lurker left LURK even though the (stationary) player never "
            "entered its ambush_radius -- geometry regression")
        total_samples += 1
        light_map = session._room_light_map()
        _, ex, ey, *_ = session.sim.get(eid)
        level_here = light_level_at(light_map, session.lighting.lights, r0, ex, ey)
        if level_here > session.LURK_MAX_LIGHT:
            lit_samples += 1
    assert total_samples > 100, "test didn't run long enough to be meaningful"
    frac_lit = lit_samples / total_samples
    assert frac_lit < 0.25, (
        f"lurker sat in a lit spot {frac_lit:.0%} of the time while "
        f"LURKing -- it isn't actively avoiding the worklight sweep")


# ---------------------------------------------------------------------
# 3. AMBUSH triggers at radius, not before
# ---------------------------------------------------------------------

def _spawn_flicker_facing_player(dist: float, seed: int = 9):
    b = LevelBuilder(f"FLICKAMBUSH{int(dist)}", 1)
    r0 = b.rect(-300.0, -150.0, 600.0, 300.0)
    b.player(r0, (200.0, 0.0))
    level = b.build()
    session = GameSession(level, seed=seed)
    eid = session.spawn_enemy(r0, (200.0 - dist, 0.0), "flicker")
    return session, eid, r0


def test_ambush_does_not_trigger_outside_radius():
    """Fail-first note: with the proximity check's `<` accidentally
    flipped to `<=` a hair past the radius (a plausible off-by-one), a
    point exactly one unit outside `ambush_radius` would still trigger --
    this test's job is to catch exactly that class of bug by holding the
    player stationary well outside the radius and asserting LURK never
    breaks."""
    from perihelion.sim import ENEMIES
    radius = ENEMIES["flicker"]["ambush_radius"]
    session, eid, r0 = _spawn_flicker_facing_player(radius + 40.0)
    for _ in range(180):
        session.tick(_idle_input())
        if eid not in session.enemies:
            break
    assert eid in session.enemies
    assert session.enemies[eid]["state"] == "lurk", (
        "flicker ambushed a player well outside its ambush_radius")


def test_ambush_triggers_within_radius():
    """A stationary player just inside `ambush_radius` -- the lurker must
    commit (state -> 'ambush' -> 'hunt') within a reasonable number of
    ticks, and its trace must go solid (>= 0.99) the instant it commits,
    matching the sensor-trace dramaturgy in the same tick."""
    from perihelion.sim import ENEMIES
    radius = ENEMIES["flicker"]["ambush_radius"]
    session, eid, r0 = _spawn_flicker_facing_player(radius - 15.0)
    triggered = False
    for _ in range(240):
        session.tick(_idle_input())
        e = session.enemies.get(eid)
        assert e is not None
        if e["state"] in ("ambush", "hunt"):
            triggered = True
            assert e["trace_intensity"] >= 0.99, (
                "trace didn't go solid the tick it committed")
            break
    assert triggered, "flicker never ambushed a stationary player inside its radius"


# ---------------------------------------------------------------------
# 4. trace-intensity channel follows AI state
# ---------------------------------------------------------------------

def test_trace_intensity_dim_while_lurking_solid_while_committed():
    from perihelion.sim import ENEMIES
    radius = ENEMIES["flicker"]["ambush_radius"]
    session, eid, r0 = _spawn_flicker_facing_player(radius + 200.0)
    lurk_intensities = []
    for _ in range(120):
        session.tick(_idle_input())
        e = session.enemies[eid]
        assert e["state"] == "lurk"
        lurk_intensities.append(e["trace_intensity"])
    # never fully invisible (a floor above 0), but also never anywhere
    # near the full-commit value while dormant.
    assert min(lurk_intensities) > 0.0
    assert max(lurk_intensities) < 0.99
    assert len(set(lurk_intensities)) > 1, "trace never actually flickers (no variation)"

    # now close the distance so it commits, and confirm the channel snaps
    # to full strength.
    session2, eid2, r02 = _spawn_flicker_facing_player(radius - 15.0, seed=9)
    for _ in range(240):
        session2.tick(_idle_input())
        e2 = session2.enemies[eid2]
        if e2["state"] in ("ambush", "hunt"):
            assert e2["trace_intensity"] >= 0.99
            return
    raise AssertionError("never committed")


# ---------------------------------------------------------------------
# 5. determinism: same seed -> identical AI trajectory (existing RNG
#    streams, not wall clock)
# ---------------------------------------------------------------------

def test_flicker_ai_is_deterministic_given_seed_and_inputs():
    b = LevelBuilder("FLICKDET", 1)
    r0 = b.rect(-220.0, -220.0, 440.0, 440.0)
    b.player(r0, (0.0, 0.0))
    level = b.build()

    def run():
        session = GameSession(level, seed=17)
        eid = session.spawn_enemy(r0, (150.0, -150.0), "flicker")
        trace = []
        for i in range(300):
            mx = math.sin(i * 0.05)
            my = math.cos(i * 0.03)
            session.tick(InputFrame(mx=mx, my=my, ax=240, ay=135, fire=False,
                                    alt=False, interact=False, weapon=0))
            e = session.enemies.get(eid)
            if e is None:
                trace.append(None)
                continue
            _, ex, ey, *_ = session.sim.get(eid)
            trace.append((round(ex, 6), round(ey, 6), e["state"],
                          round(e["trace_intensity"], 6)))
        return trace

    t1 = run()
    t2 = run()
    assert t1 == t2, "flicker AI diverged across two identically-seeded runs"
