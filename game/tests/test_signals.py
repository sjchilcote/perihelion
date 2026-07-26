"""U4 gate — the nine-field signal substrate.

Construction: exactly nine kinds; time never runs backwards; unknown
chambers raise; sampling deeper than one hop raises.

Isolated vectors: the ratified half-lives land exactly (Trail 0.80 →
0.400/0.200/0.100 at 12/24/36s; Danger 0.40 → 0.200/0.100 at 180/360s);
decay is update-frequency invariant to 1e-9; spread moves mass at the
stated per-door rates and STOPS when a portal is disconnected; Danger
never spreads; the Garrison-Interior two-front rule sends single-path
flow to Reach instead; the doorway trail is a separate directed
pheromone; the scrubber sink drains a SHARED capacity across all nine
fields. Then the sim wiring: gunfire→Noise, harm→Distress, death→Danger,
passage→Trail, standing agents→Kin.
"""
from __future__ import annotations

import pytest

from perihelion.signals import (SPREAD_DT, SignalField, SignalKind)

T = 60  # ticks per second


class StubWorld:
    """Portal adjacency only — what the substrate is allowed to know."""

    def __init__(self, adj):
        self.adj = [list(x) for x in adj]

    def num_polygons(self):
        return len(self.adj)

    def polygon_portals(self, r):
        return [None if t is None else (t, 0) for t in self.adj[r]]


def _pair():
    w = StubWorld([[1], [0]])
    return w, SignalField(w, tick=0)


# ---------------------------------------------------------------------------
# construction
# ---------------------------------------------------------------------------

def test_exactly_nine_kinds():
    assert len(SignalKind) == 9


def test_time_backwards_and_unknown_chamber_raise():
    w, f = _pair()
    f.emit(SignalKind.NOISE, 0, 1.0, tick=100)
    with pytest.raises(ValueError):
        f.sample(SignalKind.NOISE, 0, tick=50)
    with pytest.raises(ValueError):
        f.sample(SignalKind.NOISE, 99, tick=100)


def test_neighborhood_deeper_than_one_hop_raises():
    w, f = _pair()
    with pytest.raises(ValueError):
        f.neighborhood(0, 0, depth=2)


# ---------------------------------------------------------------------------
# decay: the ratified half-lives, exactly
# ---------------------------------------------------------------------------

def test_trail_half_life_is_12s():
    w, f = _pair()
    f.emit(SignalKind.TRAIL, 0, 0.80, tick=0)
    assert abs(f.sample(SignalKind.TRAIL, 0, 12 * T) - 0.400) < 0.002
    assert abs(f.sample(SignalKind.TRAIL, 0, 24 * T) - 0.200) < 0.002
    assert abs(f.sample(SignalKind.TRAIL, 0, 36 * T) - 0.100) < 0.002


def test_danger_half_life_is_180s():
    w, f = _pair()
    f.emit(SignalKind.DANGER, 0, 0.40, tick=0)
    assert abs(f.sample(SignalKind.DANGER, 0, 180 * T) - 0.200) < 0.002
    assert abs(f.sample(SignalKind.DANGER, 0, 360 * T) - 0.100) < 0.002


def test_decay_is_update_frequency_invariant():
    """A chamber sampled every tick and one sampled once must read the
    same value to 1e-9 — decay comes from the stored tick delta, never
    from how often anyone looks."""
    w1, f1 = _pair()
    w2, f2 = _pair()
    f1.emit(SignalKind.DISTRESS, 0, 1.0, tick=0)
    f2.emit(SignalKind.DISTRESS, 0, 1.0, tick=0)
    for t in range(1, 10 * T + 1):
        f1.step_to(t)
        f1.sample(SignalKind.DISTRESS, 0, t)   # constant observation
        f1.neighborhood(0, t)
    f2.step_to(10 * T)                          # never observed until now
    a = f1.sample(SignalKind.DISTRESS, 0, 10 * T)
    b = f2.sample(SignalKind.DISTRESS, 0, 10 * T)
    assert abs(a - b) < 1e-9, f"observation changed the value: {a} vs {b}"


# ---------------------------------------------------------------------------
# spread
# ---------------------------------------------------------------------------

def _run_spread(f, kind, seconds):
    f.emit(kind, 0, 1.0, tick=0)
    f.step_to(int(seconds * T))
    return f.sample(kind, 1, int(seconds * T))


def test_distress_spreads_at_its_stated_rate():
    w, f = _pair()
    got = _run_spread(f, SignalKind.DISTRESS, 1.0)
    # 0.12/s per door in 0.25s chunks -> analytically ~0.105 after 1s
    assert 0.095 <= got <= 0.115, got


def test_noise_spreads_fast_and_wide():
    w, f = _pair()
    got = _run_spread(f, SignalKind.NOISE, 1.0)
    assert 0.30 <= got <= 0.42, got
    # and it is LOUD then GONE: three seconds later it has halved twice+
    later = f.sample(SignalKind.NOISE, 1, 7 * T)
    assert later < got * 0.30


def test_danger_never_spreads():
    w, f = _pair()
    got = _run_spread(f, SignalKind.DANGER, 5.0)
    assert got == 0.0, "Danger is chamber-bound by design"


def test_disconnect_stops_transfer_immediately():
    w, f = _pair()
    f.emit(SignalKind.NOISE, 0, 1.0, tick=0)
    f.step_to(T // 2)
    before = f.sample(SignalKind.NOISE, 1, T // 2)
    assert before > 0.0
    w.adj[0] = [None]
    w.adj[1] = [None]
    f.on_topology_changed()
    f.step_to(3 * T)
    # B only decays after the cut — no arrival can exceed pure decay
    residual = f.sample(SignalKind.NOISE, 1, 3 * T)
    pure_decay = before * 0.5 ** (2.5 / 3.0)
    assert residual <= pure_decay + 1e-9


def test_muster_attenuates_steeply_per_hop():
    w = StubWorld([[1], [0, 2], [1]])   # A-B-C chain
    f = SignalField(w, tick=0)
    f.emit(SignalKind.MUSTER, 0, 1.0, tick=0)
    f.step_to(SPREAD_DT)
    b = f.sample(SignalKind.MUSTER, 1, SPREAD_DT)
    f.step_to(2 * SPREAD_DT)
    c = f.sample(SignalKind.MUSTER, 2, 2 * SPREAD_DT)
    assert b > 0.0
    assert c < b * 0.40, (b, c)          # each crossing eats >60%


def test_one_hop_neighborhood_never_shows_two_hops():
    w = StubWorld([[1], [0, 2], [1]])
    f = SignalField(w, tick=0)
    f.emit(SignalKind.DISTRESS, 2, 1.0, tick=0)
    nb = f.neighborhood(0, 0)
    seen = {r for r, _ in nb.adjacent} | {nb.center}
    assert seen == {0, 1}, "chamber C leaked into A's one-hop view"


def test_garrison_interior_needs_two_fronts():
    #     A - B - C      two fronts meet at B -> interior
    #         |
    #         D          single path from B -> reach, not interior
    w = StubWorld([[1], [0, 2, 3], [1], [1]])
    f = SignalField(w, tick=0)
    for chunk in range(1, 9):
        t = chunk * SPREAD_DT
        f.emit(SignalKind.GARRISON_INTERIOR, 0, 0.5, tick=t - 1)
        f.emit(SignalKind.GARRISON_INTERIOR, 2, 0.5, tick=t - 1)
        f.step_to(t)
    t = 8 * SPREAD_DT
    assert f.sample(SignalKind.GARRISON_INTERIOR, 1, t) > 0.0, \
        "two fronts met at B; it must read interior"
    assert f.sample(SignalKind.GARRISON_INTERIOR, 3, t) == 0.0, \
        "D is reached by a single path; interior must not spread there"
    assert f.sample(SignalKind.GARRISON_REACH, 3, t) > 0.0, \
        "the single-path flow converts to Reach"


def test_doorway_trail_is_directed_capped_and_fades():
    w, f = _pair()
    for _ in range(10):
        f.deposit_doorway_trail(0, 2, 2.0, tick=0)
    assert f.doorway_trail(0, 2, 0) == 8.0          # cap
    assert f.doorway_trail(0, 3, 0) == 0.0          # directed: other edge dry
    assert f.doorway_trail(0, 2, 11 * T) < 4.3      # ~11s half-life


def test_drain_capacity_is_shared_across_all_nine():
    w, f = _pair()
    for k in SignalKind:
        f.emit(k, 0, 1.0, tick=0)
    removed = f.drain({0: 1.0}, capacity=1.2, tick=0)
    assert abs(removed - 1.2) < 0.02, removed
    vals = [f.sample(k, 0, 0) for k in SignalKind]
    assert max(vals) - min(vals) < 1e-6, "equal fields must lose equally"
    assert abs(sum(vals) - (9.0 - 1.2)) < 0.05


# ---------------------------------------------------------------------------
# sim wiring
# ---------------------------------------------------------------------------

def test_sim_emissions_follow_the_fight():
    from perihelion.levels import LevelBuilder
    from perihelion.sim import GameSession, InputFrame
    b = LevelBuilder("SIGSIM", 1)
    ra = b.rect(0, 0, 400, 200)
    rb = b.rect(400, 0, 200, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (330, 100))
    s = GameSession(b.build(), seed=4)
    eid = s.spawn_enemy(ra, (-150.0, 0.0), "husk")
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    for t in range(1, 90):
        s.tick(InputFrame(ax=cx - 140.0, ay=cy, fire=(t == 6)))
    tk = s.tick_count
    pp = s.player_polygon()
    assert s.signals.sample(SignalKind.NOISE, pp, tk) > 0.0, \
        "gunfire must write Noise"
    assert s.signals.sample(SignalKind.TRAIL, pp, tk) >= 0.5, \
        "the intruder's chamber must carry his Trail"
    epoly = s.sim.get_polygon(eid) if eid in s.enemies else pp
    assert s.signals.sample(SignalKind.DISTRESS, epoly, tk) > 0.0, \
        "a harmed agent must write Distress"
    assert s.signals.sample(SignalKind.KIN, epoly, tk) > 0.0, \
        "a standing agent must thicken Kin"
    # kill it: Danger appears exactly where it died and nowhere else
    s._damage_enemy(eid, 999.0, (1.0, 0.0), 0.0, source="test")
    tk = s.tick_count
    assert s.signals.sample(SignalKind.DANGER, epoly, tk) >= 0.40 - 1e-6
    assert s.signals.sample(SignalKind.DANGER, rb, tk) == 0.0
