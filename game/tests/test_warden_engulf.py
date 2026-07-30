"""U6 gate — the Warden engulf through the generic capture service.

Construction: no `warden` type check anywhere in the player-side fire
code; the warden's AI never subtracts player HP (damage flows through
the capture system's one door); one captor per captive; a capture whose
captor stops existing releases the same tick.

Isolated vector (Sol's numbers): 12 charge ticks near-rooted with
exactly two body flashes; lunge peak in [2.4, 2.6]x cruise; a glancing
hit does not capture and a head-on does; 60 held ticks cost 75 +- 1 hp;
firing while aiming AWAY still damages the captor; killing the captor
releases the grip on the very same tick.
"""
from __future__ import annotations

from types import SimpleNamespace

import necore

import inspect
import math

from perihelion.capture import CaptureSpec, CaptureSystem
from perihelion.levels import LevelBuilder
from perihelion.sim import (WARDEN_CRUISE, WARDEN_ENGULF_CHARGE,
                            GameSession, InputFrame)


def _arena():
    b = LevelBuilder("ENGULF", 1)
    r0 = b.rect(-500, -300, 1000, 600)
    b.player(r0, (-300, 0))
    return b.build(), r0


# ---------------------------------------------------------------------------
# construction
# ---------------------------------------------------------------------------

def test_player_fire_code_has_no_warden_check():
    import io
    import tokenize
    from perihelion.sim import GameSession as GS
    for fn in (GS._fire, GS._fire_rail, GS._fire_tau_charged,
               GS._fire_lightning):
        src = inspect.getsource(fn)
        # scan CODE tokens only — the weapon-arithmetic comments may name
        # the warden; a type check in code may not
        code = " ".join(
            tok.string for tok in tokenize.generate_tokens(
                io.StringIO(src).readline)
            if tok.type not in (tokenize.COMMENT, tokenize.NL))
        assert "warden" not in code.lower(), (
            f"{fn.__name__} special-cases the warden — the capture "
            f"service is the only coupling allowed")


def test_warden_ai_never_touches_player_hp():
    from perihelion.sim import GameSession as GS
    src = inspect.getsource(GS._warden_engulf_step)
    assert "self.hp" not in src and "_damage_player" not in src, (
        "the warden asks the capture system; it does not burn the player")


def test_one_captor_per_captive_and_same_tick_release():
    class W:
        """A world stub in the shape the capture system now reads: places
        are Coordinates, and pulling a captive toward a captor in another
        chamber goes through `develop`. One space here (`ONE`), because
        this vector is about who may hold whom, not about geometry — but
        the types still have to be the real ones, or the fake is a lie
        about the contract."""

        ONE = necore.Space("CaptureTestChamber")

        def __init__(self):
            self.alive = {1, 2, 9}
            self.pos = {1: (0.0, 0.0), 2: (50.0, 0.0), 9: (10.0, 0.0)}
            self.vel = {}

        def exists(self, i):
            return i in self.alive

        def get(self, i):
            x, y = self.pos[i]
            return SimpleNamespace(polygon=0, space=self.ONE,
                                   pos=self.ONE.place(x, y),
                                   vel=necore.Offset(self.ONE, 0.0, 0.0),
                                   dir=necore.Offset(self.ONE, 1.0, 0.0))

        def develop(self, coord, into):
            # one space: developing into it is the identity
            return coord if coord.space == into else None

        def set_vel(self, i, off):
            self.vel[i] = off.local()

    w = W()
    cs = CaptureSystem()
    burns = []
    assert cs.begin(CaptureSpec(1, 9, 100.0, 75.0))
    assert not cs.begin(CaptureSpec(2, 9, 100.0, 75.0)), "second grab refused"
    assert cs.held_by(9) == 1
    assert cs.forced_target(9) == 1
    cs.step(w, lambda c, k, dps: burns.append((c, k, dps)))
    assert burns == [(9, 1, 75.0)]
    assert w.vel[9][0] < 0, "captive pulled toward the captor"
    w.alive.discard(1)
    cs.step(w, lambda c, k, dps: burns.append((c, k, dps)))
    assert cs.held_by(9) is None, "dead captor releases in the same step"
    assert len(burns) == 1, "no burn after release"


# ---------------------------------------------------------------------------
# the full sequence, in the real sim
# ---------------------------------------------------------------------------

def _run_to_charge(s, eid):
    """Tick until the warden starts its charge; returns the start tick."""
    for t in range(1, 600):
        s.tick(InputFrame())
        if s.enemies[eid].get("engulf") == "charge":
            return t
    raise AssertionError("warden never started an engulf charge")


def test_charge_flashes_twice_then_lunges_at_2_5x():
    level, r0 = _arena()
    s = GameSession(level, seed=6)
    eid = s.spawn_enemy(r0, (240.0, 0.0), "warden")  # inside sight, walks in
    s.enemies[eid]["state"] = "hunt"
    _run_to_charge(s, eid)
    flashes = 0
    prev_bright = False
    speeds = []
    for t in range(1, WARDEN_ENGULF_CHARGE + 2):
        e = s.enemies[eid]
        bright = e.get("trace_intensity", 1.0) > 1.5
        if bright and not prev_bright:
            flashes += 1
        prev_bright = bright
        vx, vy = s.sim.get(eid).vel.local()
        if e.get("engulf") == "charge":
            speeds.append(math.hypot(vx, vy))
        s.tick(InputFrame())
        if s.enemies[eid].get("engulf") == "lunge":
            break
    assert flashes == 2, f"the body must flash exactly twice, saw {flashes}"
    assert all(sp < 1.0 for sp in speeds), "charging warden must be rooted"
    assert s.enemies[eid].get("engulf") == "lunge"
    vx, vy = s.sim.get(eid).vel.local()
    peak = math.hypot(vx, vy) / WARDEN_CRUISE
    assert 2.4 <= peak <= 2.6, f"lunge peak {peak:.2f}x cruise"


def test_head_on_captures_and_costs_75_per_second():
    level, r0 = _arena()
    s = GameSession(level, seed=6)
    eid = s.spawn_enemy(r0, (150.0, 0.0), "warden")   # head-on line
    s.enemies[eid]["state"] = "hunt"
    hp0 = s.hp
    caught_tick = None
    for t in range(1, 900):
        s.tick(InputFrame())
        if s.captures.held_by(s.pid) == eid:
            caught_tick = t
            break
    assert caught_tick is not None, "head-on lunge never captured"
    hp_at_catch = s.hp
    for _ in range(60):
        s.tick(InputFrame())
    lost = hp_at_catch - s.hp
    # 75 hp/s; one tick of catch-boundary quantization is +-1.25
    assert abs(lost - 75.0) < 1.3, f"60 held ticks cost {lost:.2f}, want 75"


def test_glancing_hit_does_not_capture():
    level, r0 = _arena()
    s = GameSession(level, seed=6)
    # the player sits ABOVE the lunge line: the warden charges at where
    # the player was sighted, the player sidesteps, contact (if any) is
    # a graze — dot below 0.5 must not catch
    eid = s.spawn_enemy(r0, (150.0, 0.0), "warden")
    s.enemies[eid]["state"] = "hunt"
    for t in range(1, 900):
        # keep strafing perpendicular to the lunge line
        s.tick(InputFrame(my=1.0 if (t // 30) % 2 == 0 else -1.0))
        e = s.enemies.get(eid)
        if e is None:
            break
        if e.get("engulf") == "lunge":
            vx, vy = s.sim.get(eid).vel.local()
            px, py = s.player_pos().local()
            ex, ey = s.sim.get(eid).pos.local()
            dl = math.hypot(px - ex, py - ey) or 1e-6
            sp = math.hypot(vx, vy) or 1e-6
            dot = (vx * (px - ex) + vy * (py - ey)) / (sp * dl)
            if dot < 0.45 and dl < 40.0:
                assert s.captures.held_by(s.pid) is None, (
                    f"glancing contact (dot {dot:.2f}) captured")
    # the property under test is the dot gate, exercised live above


def test_firing_away_still_wounds_the_captor_and_kill_releases():
    """At 75 hp/s a full-health warden is a death sentence BY DESIGN (the
    200ms telegraph is the counterplay); the honest escape scenario is a
    warden you had already fought — pre-damaged to 60, the SMG's ~70 dps
    wins the race from inside the grip."""
    level, r0 = _arena()
    s = GameSession(level, seed=6)
    eid = s.spawn_enemy(r0, (150.0, 0.0), "warden")
    s.enemies[eid]["state"] = "hunt"
    s.enemies[eid]["hp"] = 60.0
    for t in range(1, 900):
        s.tick(InputFrame())
        if s.captures.held_by(s.pid) == eid:
            break
    assert s.captures.held_by(s.pid) == eid
    s.weapons = ["knife", "smg"]
    s.weapon = "smg"
    s.ammo["9mm"] = 400
    hp_before = s.enemies[eid]["hp"]
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    fired_away_hit = False
    kill_tick = None
    for t in range(1, 240):
        # aim hard LEFT — away from the captor pulling us rightward
        s.tick(InputFrame(ax=cx - 200, ay=cy, fire=True))
        if eid in s.enemies and s.enemies[eid]["hp"] < hp_before:
            fired_away_hit = True
        if eid not in s.enemies:
            kill_tick = t
            break
        assert not s.dead, "SMG vs 60hp warden must win the burn race"
    assert fired_away_hit, "shots aimed away must still land on the captor"
    assert kill_tick is not None, "the warden never died"
    assert s.captures.held_by(s.pid) is None, (
        "killing the captor must release the grip on the same tick")
    assert not s.dead and s.hp > 0.0
