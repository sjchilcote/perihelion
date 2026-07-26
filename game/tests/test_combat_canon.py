"""U2 gate — engine impulse + the ratified combat canon (DESIGN_7_25).

Construction: every damaging weapon carries an impulse; no damage path
writes velocity; the Warden is a normal 168-HP enemy with no brood or
enrage machinery anywhere in the source.

Isolated vectors: the impulse mass law at f64 exactness; the weapon
arithmetic the design quantizes everything to (4 rail / 2 full-charge
tau kill a Warden); full-charge tau detonates on impact with a 48u AoE
that reaches 20u and not 60u; every kind's measured terminal speed beats
the Commando's by its ratified ratio; every kind turns worse than the
Commando, and the Warden turns worse than a mite.
"""
from __future__ import annotations

import inspect
import math

import pytest

from perihelion.levels import LevelBuilder
from perihelion.sim import (DT, ENEMIES, PLAYER_MASS, TAU_AOE_RADIUS,
                            TAU_CHARGE_FULL, WEAPONS, GameSession, InputFrame)

# ratified first-pass minimum speed ratios vs the un-upgraded Commando
SPEED_RATIOS = {
    "warden": 1.15, "brute": 1.18, "spitter": 1.20, "husk": 1.25,
    "shrieker": 1.45, "flicker": 1.50, "mite": 1.55,
}


def _arena(size=3200.0):
    b = LevelBuilder("CANON", 1)
    r0 = b.rect(-size / 2, -400, size, 800)
    b.player(r0, (-size / 2 + 100, 0))
    return b.build(), r0


# ---------------------------------------------------------------------------
# Construction
# ---------------------------------------------------------------------------

def test_every_damaging_weapon_pushes():
    for name, w in WEAPONS.items():
        if name == "hole":
            continue
        assert w.get("imp", 0.0) > 0.0, f"{name} has no impulse entry"


def test_no_velocity_writes_in_damage_paths():
    """Knockback is force through the physics — a set_vel in any damage
    path is the forbidden direct velocity write."""
    for fn in (GameSession._damage_enemy, GameSession._detonate_dart,
               GameSession._detonate_tau, GameSession._contact,
               GameSession._apply_impulse):
        src = inspect.getsource(fn)
        assert "set_vel" not in src, f"velocity write in {fn.__name__}"


def test_warden_is_a_normal_enemy():
    import perihelion.sim as sim_mod
    src = inspect.getsource(sim_mod)
    d = ENEMIES["warden"]
    assert d["hp"] == 168
    for forbidden in ("WARDEN_ADDS", "_boss_adds", 'e["enraged"]',
                      "WARDEN_ENRAGE"):
        assert forbidden not in src, f"boss machinery survives: {forbidden}"


def test_every_kind_heavier_and_turn_limited():
    for kind, d in ENEMIES.items():
        assert d["mass"] > PLAYER_MASS, f"{kind} lighter than the Commando"
        assert d.get("turn", 0.0) > 0.0, f"{kind} has no turn model"


# ---------------------------------------------------------------------------
# Impulse mass law (through the real engine binding)
# ---------------------------------------------------------------------------

def test_impulse_mass_law_exact():
    level, r0 = _arena(800.0)
    s = GameSession(level, seed=3)
    husk = s.spawn_enemy(r0, (100.0, 100.0), "husk")      # mass 1.6
    warden = s.spawn_enemy(r0, (100.0, -100.0), "warden")  # mass 12.0
    s.sim.apply_impulse(husk, 400.0, 0.0)
    s.sim.apply_impulse(warden, 400.0, 0.0)
    dv_h = s.sim.get(husk)[3]
    dv_w = s.sim.get(warden)[3]
    assert abs(dv_h - 400.0 / 1.6) < 1e-9
    assert abs(dv_w - 400.0 / 12.0) < 1e-9
    assert abs(dv_h / dv_w - 12.0 / 1.6) < 1e-9
    with pytest.raises(ValueError):
        s.sim.apply_impulse(999999, 1.0, 0.0)


# ---------------------------------------------------------------------------
# Weapon arithmetic
# ---------------------------------------------------------------------------

def test_four_rail_shots_kill_a_warden():
    level, r0 = _arena(800.0)
    s = GameSession(level, seed=3)
    eid = s.spawn_enemy(r0, (60.0, 0.0), "warden")
    px, py = s.player_pos()
    for i in range(3):
        s._fire_rail(s.player_polygon(), px, py, 1.0, 0.0)
        assert eid in s.enemies, f"warden died on rail hit {i + 1}"
    assert abs(s.enemies[eid]["hp"] - 42.0) < 1e-9, "3 rails must leave 42"
    s._fire_rail(s.player_polygon(), px, py, 1.0, 0.0)
    assert eid not in s.enemies, "4 rails must kill a 168 warden"


def _fire_full_tau(s):
    """Hold a full tau charge and release it east THROUGH the sim's own
    tick (releasing alt with charge held is how the weapon really fires —
    calling the internal directly would leave the charge set and the next
    tick would fire a second round)."""
    if "tau" not in s.weapons:
        s.weapons.append("tau")
    s.weapon = "tau"
    s.ammo["cell"] = 10
    s.tau_charge = TAU_CHARGE_FULL
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    s.tick(InputFrame(ax=cx + 120.0, ay=cy))


def test_two_full_charge_tau_kill_a_warden():
    level, r0 = _arena(1200.0)
    s = GameSession(level, seed=3)
    eid = s.spawn_enemy(r0, (250.0, 0.0), "warden")
    _fire_full_tau(s)
    for _ in range(40):
        s.tick(InputFrame())
        if not s.bullets:
            break
    assert eid in s.enemies, "one full tau must not kill a warden"
    assert abs(s.enemies[eid]["hp"] - 84.0) < 1e-9, (
        f"one full tau must leave exactly 84, got {s.enemies[eid]['hp']}")
    _fire_full_tau(s)
    for _ in range(40):
        s.tick(InputFrame())
        if not s.bullets:
            break
    assert eid not in s.enemies, "two full tau must kill a 168 warden"


def test_full_tau_aoe_reaches_20u_not_60u():
    level, r0 = _arena(1200.0)
    s = GameSession(level, seed=3)
    target = s.spawn_enemy(r0, (250.0, 0.0), "warden")  # 168hp: survives 84
    near = s.spawn_enemy(r0, (250.0, 20.0), "husk")
    far = s.spawn_enemy(r0, (250.0, TAU_AOE_RADIUS + 12.0), "husk")
    hp_near0 = s.enemies[near]["hp"]
    hp_far0 = s.enemies[far]["hp"]
    _fire_full_tau(s)
    for _ in range(40):
        s.tick(InputFrame())
        if not s.bullets:
            break
    assert abs(s.enemies[target]["hp"] - 84.0) < 1e-9, "direct hit is 84"
    hit = (near not in s.enemies) or s.enemies[near]["hp"] < hp_near0
    assert hit, "20u neighbor must take AoE damage"
    if near in s.enemies:
        vy = s.sim.get(near)[4]
        assert vy > 0.0, "20u neighbor must be pushed outward"
    assert far in s.enemies and s.enemies[far]["hp"] == hp_far0, (
        "60u body must be unaffected by the 48u burst")


def test_bullet_weapons_carry_their_impulse():
    level, r0 = _arena(800.0)
    for wname in ("pistol", "smg", "shotgun", "tau"):
        s = GameSession(level, seed=3)
        s.weapons = list(WEAPONS)
        s.weapon = wname
        s.ammo = {"9mm": 99, "shell": 99, "cell": 99}
        cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
        s.tick(InputFrame(ax=cx + 100, ay=cy, fire=True))
        imps = {b.get("imp") for b in s.bullets.values()}
        assert imps == {WEAPONS[wname]["imp"]}, (
            f"{wname} rounds carry {imps}, want {WEAPONS[wname]['imp']}")


# ---------------------------------------------------------------------------
# Kinematics: measured, not asserted from the table
# ---------------------------------------------------------------------------

def _player_terminal(level):
    s = GameSession(level, seed=5)
    top = 0.0
    for _ in range(600):
        s.tick(InputFrame(mx=1.0))
        vx, vy = s.sim.get(s.pid)[3:5]
        top = max(top, math.hypot(vx, vy))
    return top


def _enemy_terminal(level, r0, kind):
    """Top pursuit speed with the target always held 800u ahead, so
    keep-band kinds (spitter, warden) never brake into their hold range."""
    s = GameSession(level, seed=5)
    eid = s.spawn_enemy(r0, (-300.0, 0.0), kind)
    s.enemies[eid]["state"] = "hunt"
    top = 0.0
    for _ in range(600):
        _, ex, ey, *_ = s.sim.get(eid)
        s.sim.set_pos(s.pid, min(1450.0, ex + 800.0), 0.0)
        s.tick(InputFrame())
        if eid not in s.enemies or not s.sim.exists(eid):
            break
        vx, vy = s.sim.get(eid)[3:5]
        top = max(top, math.hypot(vx, vy))
    return top


def test_every_kind_outruns_the_commando_by_its_ratio():
    level, r0 = _arena()
    p = _player_terminal(level)
    assert 100.0 < p < 200.0, f"player terminal {p} looks wrong"
    for kind, ratio in SPEED_RATIOS.items():
        e = _enemy_terminal(level, r0, kind)
        assert e >= p * ratio * 0.95, (
            f"{kind} terminal {e:.0f} < {ratio}x player {p:.0f} "
            f"(min {p * ratio * 0.95:.0f})")
        assert e > p, f"{kind} does not outrun the player at all"


def _reversal_ticks_enemy(level, r0, kind):
    """Ticks for a hunting enemy at eastward speed to swing its velocity
    to within 30 degrees of north when the target moves north."""
    s = GameSession(level, seed=5)
    eid = s.spawn_enemy(r0, (0.0, 0.0), kind)
    s.enemies[eid]["state"] = "hunt"
    s.sim.set_pos(s.pid, 600.0, 0.0)
    for _ in range(240):
        s.tick(InputFrame())
    s.sim.set_pos(s.pid, *_north_of(s, eid))
    for t in range(1, 601):
        s.tick(InputFrame())
        s.sim.set_pos(s.pid, *_north_of(s, eid))
        vx, vy = s.sim.get(eid)[3:5]
        sp = math.hypot(vx, vy)
        if sp > 30.0 and vy < 0 and abs(vx) < -vy * math.tan(math.radians(30)):
            return t
    return 600


def _north_of(s, eid):
    _, ex, ey, *_ = s.sim.get(eid)
    return ex, max(-380.0, ey - 500.0)


def _reversal_ticks_player(level):
    s = GameSession(level, seed=5)
    for _ in range(240):
        s.tick(InputFrame(mx=1.0))
    for t in range(1, 601):
        s.tick(InputFrame(my=-1.0))
        vx, vy = s.sim.get(s.pid)[3:5]
        sp = math.hypot(vx, vy)
        if sp > 30.0 and vy < 0 and abs(vx) < -vy * math.tan(math.radians(30)):
            return t
    return 600


def test_everything_turns_worse_than_the_commando():
    level, r0 = _arena()
    p = _reversal_ticks_player(level)
    mite = _reversal_ticks_enemy(level, r0, "mite")
    warden = _reversal_ticks_enemy(level, r0, "warden")
    assert mite > p, f"mite reverses in {mite} ticks vs player {p}"
    assert warden > mite, (
        f"warden ({warden} ticks) must turn worse than a mite ({mite})")
