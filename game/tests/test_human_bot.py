"""Tests for the human-realistic marketing bot (BOT_REALISM_DESIGN.md):
perception honesty, mouse trajectory realism, reaction-time asymmetry,
determinism, and flinch-on-damage.

Each test documents, in its docstring, what it demonstrated failing against
the *prior* state of the world before being made to pass -- design doc's
"Verification" section explicitly asks for the perception-honesty test to
fail against the existing (omniscient) bot.
"""

from __future__ import annotations

import math

from perihelion.levels import Level, LevelBuilder
from perihelion.sim import GameSession, InputFrame
from perihelion.testkit import AggroBot, HumanBot, run_bot
from perihelion.testkit.mouse_model import MouseModel
from perihelion.testkit.perception import PerceptionModel

SMOKE_MAX_TICKS = 60 * 60


def build_ambush_level() -> Level:
    """Player starts in an empty room; a husk sits in the second room,
    invisible (different room) until the player crosses the portal. This
    is the scenario the perception-honesty test needs: an enemy that goes
    from "not in the player's room" to "in the player's room" on a single
    tick, with no gradual approach to mask the reaction-latency window."""
    b = LevelBuilder("ambush")
    r0 = b.rect(0, 0, 200, 200)
    r1 = b.rect(300, 0, 200, 200)
    b.connect(r0, 2, r1, 0)
    b.entity(r1, "husk", (420, 100))
    b.player(r0, (100, 100))
    b.exit(r1, (480, 180))
    return b.build()


def _run_until_coroom(bot, level: Level, seed: int, max_ticks: int = SMOKE_MAX_TICKS):
    """Drive `bot` directly against a fresh `GameSession`, returning
    (first_coroom_tick, first_fire_tick_after_coroom) -- the tick the enemy
    first shares the player's room, and the first tick afterward the bot's
    own InputFrame requests fire. `first_fire_tick_after_coroom` is None if
    the bot never fired by `max_ticks`."""
    session = GameSession(level, seed=seed)
    first_coroom = None
    first_fire = None
    for tick in range(max_ticks):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        in_room = [e for e in snap["enemies"] if e["room"] == snap["room"]]
        if in_room and first_coroom is None:
            first_coroom = tick
        inp = bot.step(snap, session)
        if first_coroom is not None and inp.fire and first_fire is None:
            first_fire = tick
        session.tick(inp)
        if first_fire is not None:
            break
    return first_coroom, first_fire


# ---------------------------------------------------------------------------
# perception honesty
# ---------------------------------------------------------------------------


def test_aggro_bot_fires_on_the_same_tick_the_enemy_becomes_coroom():
    """Documents the baseline this suite supersedes: AggroBot reads
    `snapshot['enemies']` directly with no latency model, so once an enemy
    shares its room it can fire the very same tick (its aim jitter starts
    at 0.0). This is the omniscient behavior the perception-honesty test
    below must NOT reproduce."""
    level = build_ambush_level()
    bot = AggroBot(7)
    first_coroom, first_fire = _run_until_coroom(bot, level, 7)
    assert first_coroom is not None
    assert first_fire is not None
    assert first_fire - first_coroom <= 1


def test_human_bot_never_fires_before_perception_latency_elapses():
    """Fail-first: run against `AggroBot` above shows 0-tick reaction is
    possible. `HumanBot` must not fire until its `PerceptionModel`-sampled
    latency (>= ~0.18s = 11 ticks at 60Hz, even in the anticipated/fast
    case) has elapsed since the enemy first became room-local."""
    level = build_ambush_level()
    bot = HumanBot(7)
    first_coroom, first_fire = _run_until_coroom(bot, level, 7)
    assert first_coroom is not None
    MIN_LATENCY_TICKS = 0.18 * 60  # fastest possible sampled latency
    if first_fire is not None:
        assert first_fire - first_coroom >= MIN_LATENCY_TICKS


def test_perception_model_releases_entity_only_after_sampled_latency():
    """Direct unit check of `PerceptionModel`: an entity entering the
    player's room is withheld from `perceive()`'s return until its sampled
    latency has elapsed, and released exactly once elapsed."""
    model = PerceptionModel(seed=42)
    snap = dict(room=0, enemies=[dict(id=1, kind="husk", room=0, pos=(0, 0))])
    latency_ticks = None
    for tick in range(60):
        visible = model.perceive(snap, tick)
        if visible and latency_ticks is None:
            latency_ticks = tick
    assert latency_ticks is not None
    assert latency_ticks >= 0.18 * 60 - 1  # sampled from >= 180ms


# ---------------------------------------------------------------------------
# mouse trajectory
# ---------------------------------------------------------------------------


def test_mouse_model_never_teleports_velocity_and_accel_are_bounded():
    mouse = MouseModel(0.0, 0.0, seed=3)
    dt = 1.0 / 60.0
    prev_x, prev_y = mouse.x, mouse.y
    prev_vx, prev_vy = 0.0, 0.0
    max_speed_seen = 0.0
    for _ in range(120):
        x, y = mouse.step(400.0, 250.0, dt)
        speed = math.hypot(x - prev_x, y - prev_y) / dt
        accel = math.hypot(mouse.vx - prev_vx, mouse.vy - prev_vy) / dt
        assert speed <= 2300.0  # MAX_SPEED + slop
        assert accel <= 27000.0  # MAX_ACCEL + slop
        max_speed_seen = max(max_speed_seen, speed)
        prev_x, prev_y = x, y
        prev_vx, prev_vy = mouse.vx, mouse.vy
    assert max_speed_seen > 50.0  # it actually moved, not frozen


def test_mouse_model_overshoots_on_large_flicks():
    """A big flick (well past the overshoot distance floor) should carry
    the cursor's x-coordinate past the target before it settles back --
    the design doc's "overshoot-and-correct" signature."""
    mouse = MouseModel(0.0, 135.0, seed=9)
    dt = 1.0 / 60.0
    target = (450.0, 135.0)
    max_x = 0.0
    for _ in range(90):
        x, _ = mouse.step(target[0], target[1], dt)
        max_x = max(max_x, x)
    assert max_x > target[0], (
        f"expected overshoot past {target[0]}, cursor peaked at {max_x}")


def test_mouse_model_settles_near_target_and_drifts_at_rest():
    mouse = MouseModel(0.0, 135.0, seed=11)
    dt = 1.0 / 60.0
    target = (450.0, 135.0)
    for _ in range(240):
        x, y = mouse.step(target[0], target[1], dt)
    assert math.hypot(x - target[0], y - target[1]) < 15.0
    # idle drift: continuing to step at the same target should not freeze
    # the cursor to a single pixel
    positions = set()
    for _ in range(60):
        x, y = mouse.step(target[0], target[1], dt)
        positions.add((round(x, 2), round(y, 2)))
    assert len(positions) > 1


# ---------------------------------------------------------------------------
# reaction-time asymmetry
# ---------------------------------------------------------------------------


def test_anticipated_reactions_are_faster_than_surprise_reactions():
    """Pre-aimed (anticipated) threats must, on average, be released to the
    reactive layer sooner than surprise threats -- the single most
    human-looking property per design doc §3."""
    anticipated_latencies = []
    surprise_latencies = []
    for seed in range(30):
        snap = dict(room=0, enemies=[dict(id=1, kind="husk", room=0, pos=(0, 0))])
        m_fast = PerceptionModel(seed=seed)
        for tick in range(60):
            if m_fast.perceive(snap, tick, anticipated_ids=frozenset({1})):
                anticipated_latencies.append(tick)
                break
        m_slow = PerceptionModel(seed=seed + 1000)
        for tick in range(60):
            if m_slow.perceive(snap, tick):
                surprise_latencies.append(tick)
                break
    avg_fast = sum(anticipated_latencies) / len(anticipated_latencies)
    avg_slow = sum(surprise_latencies) / len(surprise_latencies)
    assert avg_fast < avg_slow


# ---------------------------------------------------------------------------
# determinism
# ---------------------------------------------------------------------------


def test_two_identical_human_bot_runs_are_bit_identical():
    level = build_ambush_level()
    res1 = run_bot(level, HumanBot(21), 21, max_ticks=SMOKE_MAX_TICKS)
    res2 = run_bot(level, HumanBot(21), 21, max_ticks=SMOKE_MAX_TICKS)
    assert res1.outcome == res2.outcome
    assert res1.ticks_alive == res2.ticks_alive
    assert res1.events == res2.events
    assert res1.hp_timeline == res2.hp_timeline


def test_different_seeds_produce_different_human_bot_runs():
    """Sanity companion to the determinism test: without this, an
    always-identical-output bug (e.g. RNG never actually consumed) would
    pass the identical-runs test vacuously."""
    level = build_ambush_level()
    res1 = run_bot(level, HumanBot(21), 21, max_ticks=SMOKE_MAX_TICKS)
    res2 = run_bot(level, HumanBot(22), 22, max_ticks=SMOKE_MAX_TICKS)
    assert res1.hp_timeline != res2.hp_timeline or res1.events != res2.events


# ---------------------------------------------------------------------------
# flinch on damage
# ---------------------------------------------------------------------------


def build_flinch_level() -> Level:
    """Player boxed in with a melee husk adjacent -- guarantees the player
    takes damage almost immediately so the flinch response is observable
    within a short tick budget."""
    b = LevelBuilder("flinch_box")
    r0 = b.rect(0, 0, 200, 200)
    b.entity(r0, "husk", (110, 100))
    b.player(r0, (100, 100))
    b.exit(r0, (190, 190))
    return b.build()


def test_aim_deviates_after_taking_damage_then_recovers():
    level = build_flinch_level()
    bot = HumanBot(5)
    session = GameSession(level, seed=5)
    prev_hp = None
    hit_tick = None
    flinch_angles = []
    for tick in range(180):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        if prev_hp is not None and snap["hp"] < prev_hp and hit_tick is None:
            hit_tick = tick
        prev_hp = snap["hp"]
        inp = bot.step(snap, session)
        if hit_tick is not None:
            flinch_angles.append(bot._flinch_angle if bot._flinch_ticks > 0 else 0.0)
        session.tick(inp)
        if hit_tick is not None and tick - hit_tick > 20:
            break
    assert hit_tick is not None, "player never took damage in this scenario"
    assert any(abs(a) > 0.01 for a in flinch_angles), "flinch never kicked aim off"
    assert flinch_angles[-1] == 0.0, "flinch did not recover"
