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
    """Player starts in an empty polygon; a husk sits in the second polygon,
    invisible (different polygon) until the player crosses the portal. This
    is the scenario the perception-honesty test needs: an enemy that goes
    from "not in the player's polygon" to "in the player's polygon" on a single
    tick, with no gradual approach to mask the reaction-latency window."""
    b = LevelBuilder("ambush")
    r0 = b.rect(0, 0, 200, 200)
    r1 = b.rect(300, 0, 200, 200)
    b.connect(r0, 2, r1, 0)
    b.entity(r1, "husk", (420, 100))
    b.player(r0, (100, 100))
    b.exit(r1, (480, 180))
    return b.build()


def _run_until_copolygon(bot, level: Level, seed: int, max_ticks: int = SMOKE_MAX_TICKS):
    """Drive `bot` directly against a fresh `GameSession`, returning
    (first_copolygon_tick, first_fire_tick_after_copolygon) -- the tick the enemy
    first shares the player's polygon, and the first tick afterward the bot's
    own InputFrame requests fire. `first_fire_tick_after_copolygon` is None if
    the bot never fired by `max_ticks`."""
    session = GameSession(level, seed=seed)
    first_copolygon = None
    first_fire = None
    for tick in range(max_ticks):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        in_polygon = [e for e in snap["enemies"] if e["polygon"] == snap["polygon"]]
        if in_polygon and first_copolygon is None:
            first_copolygon = tick
        inp = bot.step(snap, session)
        if first_copolygon is not None and inp.fire and first_fire is None:
            first_fire = tick
        session.tick(inp)
        if first_fire is not None:
            break
    return first_copolygon, first_fire


def _run_until_perceivable(bot, level: Level, seed: int, max_ticks: int = SMOKE_MAX_TICKS):
    """Like `_run_until_copolygon`, but measured from the tick the enemy FIRST
    becomes a perception candidate at all -- polygon-local OR visible through
    a portal (`PerceptionModel`'s `visible_ids`, fed by `HumanBot`'s own
    `_visible_enemy_screens`) -- rather than from co-polygon. HumanBot-only
    (reads `bot.perception`)."""
    session = GameSession(level, seed=seed)
    enemy_id = None
    first_candidate = None
    first_fire = None
    for tick in range(max_ticks):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        if enemy_id is None and snap["enemies"]:
            enemy_id = snap["enemies"][0]["id"]
        inp = bot.step(snap, session)
        if enemy_id is not None and first_candidate is None \
                and bot.perception.ticks_perceivable(enemy_id, tick) >= 0:
            first_candidate = tick
        if first_candidate is not None and inp.fire and first_fire is None:
            first_fire = tick
        session.tick(inp)
        if first_fire is not None:
            break
    return first_candidate, first_fire


# ---------------------------------------------------------------------------
# perception honesty
# ---------------------------------------------------------------------------


def test_aggro_bot_fires_on_the_same_tick_the_enemy_becomes_copolygon():
    """Documents the baseline this suite supersedes: AggroBot reads
    `snapshot['enemies']` directly with no latency model, so once an enemy
    shares its polygon it can fire the very same tick (its aim jitter starts
    at 0.0). This is the omniscient behavior the perception-honesty test
    below must NOT reproduce."""
    level = build_ambush_level()
    bot = AggroBot(7)
    first_copolygon, first_fire = _run_until_copolygon(bot, level, 7)
    assert first_copolygon is not None
    assert first_fire is not None
    assert first_fire - first_copolygon <= 1


def test_human_bot_never_fires_before_perception_latency_elapses():
    """Fail-first: run against `AggroBot` above shows 0-tick reaction is
    possible. `HumanBot` must not fire until its `PerceptionModel`-sampled
    latency (>= ~0.18s = 11 ticks at 60Hz, even in the anticipated/fast
    case) has elapsed since the enemy first became perceivable.

    Measured from first-perceivable, not first-co-polygon (retuned
    2026-07-13 alongside the absolute-priority/viewport-perception fix):
    `build_ambush_level`'s husk sits close enough to the shared portal
    that it is a perception candidate -- on screen through the doorway,
    see `HumanBot._visible_enemy_screens` -- before the player ever
    crosses into its polygon, so first-fire can now land on the SAME tick as
    first-co-polygon while still honestly waiting out the full latency
    window from the moment it actually became perceivable. That's the fix
    working, not a regression: an enemy plainly on screen is no longer
    invisible just because a polygon-index hasn't flipped yet. First-co-polygon
    stopped being the right reference point for "when could the bot have
    reacted"; `test_aggro_bot_fires_on_the_same_tick_the_enemy_becomes_copolygon`
    above still uses it deliberately, to characterize the omniscient
    baseline this suite supersedes."""
    level = build_ambush_level()
    bot = HumanBot(7)
    first_candidate, first_fire = _run_until_perceivable(bot, level, 7)
    assert first_candidate is not None
    MIN_LATENCY_TICKS = 0.18 * 60  # fastest possible sampled latency
    if first_fire is not None:
        assert first_fire - first_candidate >= MIN_LATENCY_TICKS


def test_perception_model_releases_entity_only_after_sampled_latency():
    """Direct unit check of `PerceptionModel`: an entity entering the
    player's polygon is withheld from `perceive()`'s return until its sampled
    latency has elapsed, and released exactly once elapsed."""
    model = PerceptionModel(seed=42)
    snap = dict(polygon=0, enemies=[dict(id=1, kind="husk", polygon=0, pos=(0, 0))])
    latency_ticks = None
    for tick in range(60):
        visible = model.perceive(snap, tick)
        if visible and latency_ticks is None:
            latency_ticks = tick
    assert latency_ticks is not None
    assert latency_ticks >= 0.18 * 60 - 1  # sampled from >= 180ms


def test_perception_model_widens_to_visible_ids_not_just_polygon_local():
    """Direct unit test of the `visible_ids` widening (BOT_REALISM_DESIGN.md
    §1: perception should be "entities inside the rendered viewport," which
    for this seamless-portal engine is wider than polygon-membership -- see
    `HumanBot._visible_enemy_screens`, which feeds this from
    `session.visible()`, the renderer's own portal-visibility query).

    Fail-first: pre-fix, `perceive` took no `visible_ids` parameter at all
    -- a different-polygon entity could never be released no matter how
    visible it was on screen (director's verdict, 2026-07-13: this was the
    confirmed root cause of the bot running right past enemies it hadn't
    polygon-crossed into range of yet). Confirms both halves: polygon-only
    (`visible_ids` omitted) never releases a different-polygon entity no
    matter how long it's watched; naming its id in `visible_ids` releases
    it after the same sampled latency as any polygon-local entity."""
    model = PerceptionModel(seed=42)
    snap = dict(polygon=0, enemies=[dict(id=1, kind="husk", polygon=1, pos=(0, 0))])
    ever_released_polygon_only = any(
        model.perceive(snap, tick) for tick in range(120))
    assert not ever_released_polygon_only, (
        "a different-polygon entity was released without being named in "
        "visible_ids -- the polygon-membership gate is not being enforced")

    model2 = PerceptionModel(seed=42)
    latency_ticks = None
    for tick in range(120):
        visible = model2.perceive(snap, tick, visible_ids=frozenset({1}))
        if visible and latency_ticks is None:
            latency_ticks = tick
    assert latency_ticks is not None, (
        "visible_ids did not widen perceivability to a different-polygon entity")
    assert latency_ticks >= 0.18 * 60 - 1, (
        "visible_ids bypassed the reaction-latency sampling")


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
        snap = dict(polygon=0, enemies=[dict(id=1, kind="husk", polygon=0, pos=(0, 0))])
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


# ---------------------------------------------------------------------------
# flanked-choke disengage (design doc §5)
# ---------------------------------------------------------------------------


def build_flanked_choke_level() -> Level:
    """Player mid-way down a NARROW corridor polygon (80 units tall -- no
    strafe space, like the l01 doorway from the 2026-07-13 demo) with husk
    trios closing from BOTH ends. The naive dist<60 backpedal is defeated
    here: backpedaling from one side walks into the other, and there is no
    perpendicular polygon to jockey in. A competent human breaks contact
    through the weaker side or fights through; they do not stand on the
    tile until dead. Scenario calibrated empirically: at DEFAULT_SKILL the
    pre-fix bot dies in this polygon on seed 16 without ever leaving it."""
    b = LevelBuilder("flank_choke")
    r0 = b.rect(0, 0, 200, 200)
    r1 = b.rect(300, 60, 200, 80)
    r2 = b.rect(600, 0, 200, 200)
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 2, r2, 0)
    # the flankers are already in the player's polygon, opposite ends
    for i in range(3):
        b.entity(r1, "husk", (330 + 12 * i, 90 + 10 * (i % 2)))
        b.entity(r1, "husk", (470 - 12 * i, 110 - 10 * (i % 2)))
    b.entity(r0, "husk", (150, 100))
    b.entity(r2, "husk", (650, 100))
    b.player(r1, (400, 100))
    b.exit(r2, (780, 180))
    return b.build()


def test_flank_escape_commits_through_the_weaker_side():
    """Mechanism unit test -- this is the discriminating check (the
    integration scenario below turned out NOT to discriminate: an ablated
    never-escape bot survives it too once nav humanization landed, see the
    2026-07-13 ablation note in the scenario test). Flanked at low HP by a
    near group and a far single, the escape must (a) engage and (b) point
    through the FARTHER (weaker) side, not backpedal from the nearest into
    the near group."""
    bot = HumanBot(3)
    px, py = 400.0, 100.0
    perceived = [
        dict(id=1, kind="husk", polygon=1, pos=(460.0, 100.0), hp=15),  # near, right
        dict(id=2, kind="husk", polygon=1, pos=(465.0, 110.0), hp=15),  # near, right
        dict(id=3, kind="husk", polygon=1, pos=(300.0, 100.0), hp=15),  # far, left
    ]
    bot._update_flank_escape(perceived, hp=50.0, px=px, py=py)
    assert bot._escape_ticks > 0, "flank at low HP did not trigger escape"
    edx, edy = bot._escape_dir
    assert edx < -0.5, (
        f"escape dir {bot._escape_dir} does not point through the weaker "
        f"(far-left) side")

    # healthy bot in the same geometry: no escape (it can still win the fight)
    healthy = HumanBot(3)
    healthy._update_flank_escape(perceived, hp=100.0, px=px, py=py)
    assert healthy._escape_ticks == 0


def test_flanked_choke_is_survived_and_escape_engages():
    """Integration guard for the l01-demo failure ("holds a flanked
    doorway until death"). Honest scope note (2026-07-13 ablation): with
    nav humanization landed, an ablated never-escape bot ALSO survives
    this exact scenario -- survival here no longer discriminates the
    escape policy (the unit test above does). What this test pins: on a
    real flanked choke the escape policy ENGAGES under fire, and the bot
    gets out of the choke polygon alive. This is a fight-trajectory pin, not
    a mechanism pin -- it has been re-scanned three times now as unrelated
    humanization work shuffled the bot's RNG consumption order and moved
    which seeds happen to cross FLANK_HP in this polygon (13..32 -> seed 13;
    the absolute-priority/viewport-perception retune -> seed 18; the
    distant-threat glance-wander retune -> seed 16; the motor-schema
    arbitration rework, 2026-07-16 -> seed 8; the arbitration gain
    retune (pace policy + co-polygon damping) -> seed 4; the hold-the-
    trigger fire policy -> seed 1; the contact-evasion reflex -> seed
    4; the flinch-decay fix, 2026-07-17 -> seed 12; the cross-polygon
    engagement rework, 2026-07-18 (enemies fight through portals
    instead of going inert off-polygon; 9/79) -> seed 21; the NPC-
    internals purge, 2026-07-18 (perception returns inferred
    `active` from movement, no state/hp; 12/79) -> seed 3; the
    combat-canon kinematics inversion, 2026-07-26 (every kind faster
    than the Commando, heavier, turn-limited; 17/40) -> seed 1; the
    U5 coordination rewire, 2026-07-26 (fractional quorum draws two
    extra rng values per spawn; field-hunt replaces omniscient
    pursuit; 11/40) -> seed 3; the U8/U9 marrow era, 2026-07-26 (ten
    shelf guardians spawn per session and the snapshot scopes to the
    playable world; 5/24) -> seed 5; the U11 core organ, 2026-07-26
    (twenty-six part bodies embodied per session; 7/24) -> seed 2,
    current). Each
    time, the mechanism itself remained intact and fires on a
    fraction of a fresh 79-seed scan (18/79, 20/79, 46/79, 72/79,
    50/79 -- then 6/79 after the contact-evasion reflex landed, 4/79
    after the flinch-decay fix (true aim after flinch expiry resolves
    more chokes by gunfire before FLANK_HP is crossed): the
    LOWER layer now prevents most of the emergencies the escape used
    to cure, which is subsumption working as intended; the mechanism
    still fires when genuinely boxed).
    If this breaks again, re-scan rather than assume the escape policy
    regressed."""
    level = build_flanked_choke_level()
    bot = HumanBot(2)
    session = GameSession(level, seed=2, difficulty="hard")
    start_polygon = session.player_polygon()
    left_polygon = escape_engaged = False
    for tick in range(60 * 40):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        if snap["polygon"] != start_polygon:
            left_polygon = True
        inp = bot.step(snap, session)
        if bot._escape_ticks > 0:
            escape_engaged = True
        session.tick(inp)
    assert not session.dead, "bot held the flanked choke until death"
    assert left_polygon, "bot never escaped the choke polygon"
    assert escape_engaged, "flank escape never engaged during the choke fight"


# ---------------------------------------------------------------------------
# navigation humanization (design doc §3/§4)
# ---------------------------------------------------------------------------


def build_corridor_level() -> Level:
    """Empty 3-polygon corridor for pure-navigation properties."""
    b = LevelBuilder("nav_corridor")
    r0 = b.rect(0, 0, 200, 200)
    r1 = b.rect(300, 0, 200, 200)
    r2 = b.rect(600, 0, 200, 200)
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 2, r2, 0)
    b.player(r0, (60, 100))
    b.exit(r2, (740, 100))
    return b.build()


def _nav_trace(bot, level: Level, seed: int, max_ticks: int = 60 * 60):
    """Returns per-tick (polygon, pos, (mx, my)) until completion."""
    session = GameSession(level, seed=seed)
    trace = []
    for _ in range(max_ticks):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        inp = bot.step(snap, session)
        trace.append((snap["polygon"], snap["pos"], (inp.mx, inp.my)))
        session.tick(inp)
    return trace, session


def test_human_bot_pauses_at_the_threshold_of_an_unexplored_polygon():
    """Fail-first (2026-07-13): pre-§3 HumanBot walked portal centerlines
    at full speed exactly like AggroBot. Polygon-entry protocol requires a
    pause at the threshold of unexplored territory: some ticks of
    near-zero commanded movement while in the origin polygon, before the
    first polygon transition.

    Threshold retuned down from 10 to 5 (2026-07-13 pm, director's verdict
    "way too hesitant to move"): `PAUSE_TICKS` shrank from (28, 55) to
    (8, 16) ticks so the ritual reads as a beat, not a dither -- 10 was
    only ever a "did a pause happen at all" proxy sized to the old range,
    not a requirement on duration. Seed 17 now deterministically draws 8;
    5 keeps a comfortable margin under that while still being well above
    what any single non-ritual slow tick could produce by chance."""
    level = build_corridor_level()
    bot = HumanBot(17)
    trace, session = _nav_trace(bot, level, 17)
    assert session.complete, "bot failed to finish the empty corridor"
    first_cross = next(i for i, (polygon, _, _) in enumerate(trace) if polygon != trace[0][0])
    slow_ticks = sum(1 for polygon, _, (mx, my) in trace[:first_cross]
                     if math.hypot(mx, my) < 0.15)
    assert slow_ticks >= 5, (
        f"no threshold pause before entering new polygon ({slow_ticks} slow ticks)")


def test_human_bot_heading_wobbles_but_aggro_bot_does_not():
    """Fail-first (2026-07-13): both bots produced ruler-straight move
    vectors down the corridor. Human movement needs heading wobble --
    variance in the commanded move angle -- while staying far short of
    drunk (bounded spread, and it still finishes the level)."""
    level = build_corridor_level()

    def heading_spread(bot, seed):
        trace, session = _nav_trace(bot, level, seed)
        assert session.complete
        angles = [math.atan2(my, mx) for _, _, (mx, my) in trace
                  if math.hypot(mx, my) > 0.5]
        mean = sum(angles) / len(angles)
        var = sum((a - mean) ** 2 for a in angles) / len(angles)
        return math.sqrt(var)

    aggro_spread = heading_spread(AggroBot(19), 19)
    human_spread = heading_spread(HumanBot(19), 19)
    assert human_spread > aggro_spread + 0.02, (
        f"human heading spread {human_spread:.4f} not above aggro baseline "
        f"{aggro_spread:.4f}")
    assert human_spread < 0.6, f"too drunk: heading spread {human_spread:.4f}"


def test_human_bot_sweeps_aim_at_the_threshold():
    """During the threshold pause the aim point must sweep (lamp-sweep of
    the polygon beyond), not sit frozen: across the pause ticks the aim
    x-coordinate should cover a meaningful screen span."""
    level = build_corridor_level()
    bot = HumanBot(23)
    # zoom pinned: the 30px sweep-span threshold is a screen-space
    # number authored at 1.35 (the same world sweep is ~1/3 the px
    # span at 0.45); the sweep behavior itself is zoom-free
    session = GameSession(level, seed=23, zoom=1.35)
    aims_during_pause = []
    start_polygon = session.player_polygon()
    for _ in range(60 * 60):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        inp = bot.step(snap, session)
        if snap["polygon"] == start_polygon and math.hypot(inp.mx, inp.my) < 0.15:
            aims_during_pause.append((inp.ax, inp.ay))
        session.tick(inp)
    assert len(aims_during_pause) >= 10
    xs = [a[0] for a in aims_during_pause]
    assert max(xs) - min(xs) > 30.0, (
        f"aim did not sweep during threshold pause (x span "
        f"{max(xs) - min(xs):.1f}px)")


# ---------------------------------------------------------------------------
# absolute threat priority / viewport perception (director's verdict,
# 2026-07-13: "it's way too hesitant to move, and will run right past
# enemies coming at it instead of shooting them ... a human player who
# sees an enemy ... is going to act to neutralize the threat immediately")
# ---------------------------------------------------------------------------


def build_portal_runpast_level() -> Level:
    """A husk sits just past a doorway, off the direct line from the
    player's spawn to the exit -- the collision-path scenario the director
    described: the player's own route runs right past it. Empty-polygon-then-
    portal geometry like `build_ambush_level`, but positioned close enough
    to the shared portal that it is confirmed (see the fixture-validity
    test below) to be in the renderer's own portal-visibility set well
    before the player ever shares its polygon -- exactly the gap the
    absolute-priority fix closes."""
    b = LevelBuilder("portal_runpast")
    r0 = b.rect(0, 0, 200, 200)
    r1 = b.rect(300, 0, 260, 200)
    b.connect(r0, 2, r1, 0)
    b.entity(r1, "husk", (330, 70))
    b.player(r0, (100, 100))
    b.exit(r1, (540, 100))
    return b.build()


def test_husk_is_viewport_visible_through_the_portal_before_copolygon():
    """Fixture-validity guard for the two tests below: confirms the level
    actually exercises the portal-visibility gap -- `session.visible()`
    (the renderer's own query) sees the husk while the player is still in
    polygon 0 -- rather than the assertions below happening to pass for some
    unrelated reason."""
    level = build_portal_runpast_level()
    session = GameSession(level, seed=1)
    snap = session.snapshot()
    assert snap["polygon"] == 0
    husk = snap["enemies"][0]
    assert husk["polygon"] != snap["polygon"], "fixture bug: husk already co-polygon"
    visible_ids = {eid for _r, _x, _d, _c, _w, _e, ents in session.visible()
                   for eid, *_ in ents}
    assert husk["id"] in visible_ids, (
        "fixture bug: husk is not actually visible through the portal -- "
        "the tests below would not be exercising the gap they claim to")


def test_human_bot_does_not_run_past_an_enemy_seen_through_a_doorway():
    """THE fail-first for the director's verdict. Root cause: HumanBot's
    perception previously gated strictly on `enemy["polygon"] == player_polygon`
    -- narrower than what the seamless-portal renderer actually draws (this
    level's husk IS on screen through the doorway before co-polygon, per the
    fixture-validity test above). A human reacts to an enemy the instant
    it's visible, portal or not; the pre-fix bot could not.

    Measured pre-fix (by forcing `_visible_enemy_screens` to return `{}`,
    identical to the old behavior -- the fix is a strict widening with
    exactly that as its polygon-only fallback) on this level, seed 1: the
    threshold-pause ritual fired despite the husk being plainly visible,
    and once the player finally reached co-polygon the bot still waited out a
    fresh "surprise" latency from scratch on top of that -- fire lagged
    co-polygon by 101 ticks (1.68s), and the kill didn't land until 125 ticks
    (2.1s) after co-polygon. That is "running past": full nav speed through a
    polygon with a visible threat, no reaction until physically level with
    it, then a slow reacquire.

    Post-fix, same level and seed: no ritual ever fires, and because the
    bot had already been tracking the husk through the doorway, its
    perception latency had already elapsed BY co-polygon -- fire starts the
    same tick (lag=0) and the kill lands 22 ticks (0.37s) later. Assertion
    margins below are generous over those measured numbers so the test
    isn't pinned to one exact trajectory."""
    level = build_portal_runpast_level()
    bot = HumanBot(1)
    session = GameSession(level, seed=1)
    first_copolygon = first_fire = kill_tick = None
    pause_ticks_seen = lookaround_ticks_seen = 0
    for tick in range(60 * 15):
        if session.dead or session.complete:
            break
        snap = session.snapshot()
        if not snap["enemies"]:
            kill_tick = tick
            break
        if snap["enemies"][0]["polygon"] == snap["polygon"] and first_copolygon is None:
            first_copolygon = tick
        inp = bot.step(snap, session)
        pause_ticks_seen = max(pause_ticks_seen, bot._pause_ticks)
        lookaround_ticks_seen = max(lookaround_ticks_seen, bot._lookaround_ticks)
        if inp.fire and first_fire is None:
            first_fire = tick
        session.tick(inp)
    assert not session.dead
    assert pause_ticks_seen == 0, (
        "threshold-pause ritual fired while the husk was on screen through "
        "the doorway -- rituals must never fire while a threat is perceived")
    assert lookaround_ticks_seen == 0, (
        "curiosity-sweep ritual fired while a threat was perceived")
    assert first_fire is not None, "bot never fired at all"
    # Contract evolved with the fire doctrine (director 2026-07-16:
    # bullets are physics bodies and cross portals -- visible on screen
    # means shootable). "Does not run past" now means the husk gets
    # ENGAGED FROM VISIBILITY and dies promptly, whether or not the
    # player ever shares its polygon polygon (it usually dies through the
    # doorway before co-polygon happens; first_copolygon may stay None).
    assert kill_tick is not None, "husk survived the whole window"
    assert kill_tick <= 60 * 8, (
        f"husk not killed until tick {kill_tick} -- engagement from "
        f"visibility should resolve this fight within seconds")

    # "resumes ... once every perceived threat is dead": after the kill,
    # nav toward the objective picks back up rather than staying stalled.
    snap = session.snapshot()
    inp = bot.step(snap, session)
    assert inp.mx or inp.my, "bot did not resume its route after the kill"


def test_rituals_never_fire_while_any_threat_is_perceived():
    """General check of the director's law ("does not resume any other
    activity ... until every perceived threat is dead") across several
    seeds of the portal scenario: at no tick where anything is perceived
    -- co-polygon or only visible through a portal -- may a threshold pause
    or curiosity sweep be active. `perceive()` is idempotent for
    inspection here (per-id latency is memoized on first sight; a same-
    tick re-call neither draws a new sample nor changes state)."""
    for seed in range(1, 6):
        level = build_portal_runpast_level()
        bot = HumanBot(seed)
        session = GameSession(level, seed=seed)
        for tick in range(60 * 15):
            if session.dead or session.complete:
                break
            snap = session.snapshot()
            if not snap["enemies"]:
                break
            inp = bot.step(snap, session)
            visible_ids = frozenset(bot._visible_enemy_screens(session))
            perceived = bot.perception.perceive(snap, snap["tick"],
                                                 visible_ids=visible_ids)
            if perceived:
                assert bot._pause_ticks == 0, (
                    f"seed={seed} tick={tick}: threshold pause active "
                    f"while a threat was perceived")
                assert bot._lookaround_ticks == 0, (
                    f"seed={seed} tick={tick}: curiosity sweep active "
                    f"while a threat was perceived")
            session.tick(inp)


# ---------------------------------------------------------------------------
# honest-game doctrine pins (2026-07-18): MECHANISM tests, not trajectory
# pins — each checks one load-bearing behavior of the siege/kite doctrine
# directly, so future changes can't silently regress it. (The flanked-choke
# trajectory test above documents why trajectory pins churn; these don't.)
# ---------------------------------------------------------------------------


def test_perception_returns_no_npc_internals():
    """Director's ruling: the bot knows nothing about NPC internals.
    Perceived entries carry observed fields plus the movement-inferred
    `active` flag — never `state`, never `hp`."""
    model = PerceptionModel(seed=7)
    snap = dict(polygon=0, enemies=[dict(id=1, kind="warden", polygon=0,
                                      pos=(50, 50), hops=0,
                                      state="hunt", hp=520)])
    out = None
    for tick in range(120):
        vis = model.perceive(snap, tick)
        if vis:
            out = vis[0]
            break
    assert out is not None
    assert "state" not in out and "hp" not in out
    assert set(out) == {"id", "kind", "polygon", "pos", "hops", "active"}


def test_perception_activity_inferred_from_movement():
    """`active` flips on sustained motion above the idle-drift band and
    stays sticky briefly through a pause — never read from state flags."""
    model = PerceptionModel(seed=7)
    x = 0.0
    became_active = None
    for tick in range(240):
        snap = dict(polygon=0, enemies=[dict(id=1, kind="mite", polygon=0,
                                          pos=(x, 0), hops=0)])
        vis = model.perceive(snap, tick)
        if tick < 60:
            pass            # stationary: must stay inactive
        elif tick < 180:
            x += 2.0        # 120 u/s: clearly moving
        if vis and vis[0]["active"] and became_active is None:
            became_active = tick
        if tick == 59:
            assert not (vis and vis[0]["active"]), \
                "stationary enemy read as active"
    assert became_active is not None and became_active < 120, \
        "moving enemy never read as active"


def test_first_sight_recoil_fires_once_per_warden():
    """Single-pull siege: the first perception of a NEW warden id trips
    one withdrawal latch; the same id seen continuously does not re-trip
    (uncapped re-trips measured as a 4-minute doorway loop)."""
    bot = HumanBot(5)
    assert bot._warden_seen == set()
    bot._warden_seen.add(41)
    bot._warden_recoils[41] = 1
    # simulate the re-arm bookkeeping: id under the cap gets cleared
    # after quiet, id at the cap stays latched
    bot._warden_recoils[42] = 2
    bot._warden_seen.add(42)
    kept = {i for i in bot._warden_seen
            if bot._warden_recoils.get(i, 0) >= 2}
    assert kept == {42}
