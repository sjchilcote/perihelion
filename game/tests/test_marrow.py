"""U9 gate — reserve economy, cost-fair dispatch, breach lifecycle.

Construction: the economy is BLIND (marrow.py cannot import the sim,
the signals, or the senses; the depot's source names no player, no
kills, no difficulty); breaches store no reserve and no other breaches.

Isolated vectors (Sol's numbers): regen 0.10/s full and 0.35/s empty;
the -32 debt repays through zero in ~91s (no timer anywhere); the
payment stall waits for THE SELECTED UNIT (a pending warden at empty
reserve stalls ~23s and nothing cheaper jumps the queue); the scheduler
splits EXPENDITURE with skew bounded by the priciest unit; physical
entry (hub-origin bodies transfer out through a scale-1 gate; nothing
dispatch-tagged is ever created world-side); the closure trio (no-route
12s, idle 45s with a projectile re-arm, exhaustion +10s grace).
"""
from __future__ import annotations

import ast
import inspect
from pathlib import Path

from perihelion.levels import LevelBuilder
from perihelion.marrow import (CORE_KILL_DEBT, DISPATCH_COST,
                               EXHAUST_GRACE_TICKS, GUARDIAN_SHELF,
                               IDLE_CLOSE_TICKS, NO_ROUTE_CLOSE_TICKS,
                               Breach, CostFairScheduler, MarrowController,
                               ReserveDepot)
from perihelion.sim import GameSession, InputFrame


# ---------------------------------------------------------------------------
# blindness, structurally
# ---------------------------------------------------------------------------

def test_marrow_module_is_blind():
    src = (Path(__file__).resolve().parent.parent
           / "perihelion" / "marrow.py").read_text()
    roots = set()
    for node in ast.walk(ast.parse(src)):
        if isinstance(node, ast.ImportFrom):
            roots.add((node.module or "").split(".")[0])
        elif isinstance(node, ast.Import):
            roots.update(a.name.split(".")[0] for a in node.names)
    for forbidden in ("sim", "signals", "senses", "scouts", "audio",
                      "render", "coordination"):
        assert forbidden not in roots, f"marrow.py imports {forbidden}"
    import io
    import tokenize
    depot_src = inspect.getsource(ReserveDepot)
    code = " ".join(tok.string for tok in tokenize.generate_tokens(
        io.StringIO(depot_src).readline)
        if tok.type not in (tokenize.COMMENT, tokenize.STRING, tokenize.NL))
    for word in ("player", "hp", "kill", "difficulty", "distress", "noise"):
        assert word not in code.lower(), (
            f"the depot's CODE names '{word}' — the blindness must be "
            f"structural")


def test_breach_stores_no_reserve_and_no_siblings():
    fields = set(Breach.__dataclass_fields__)
    for forbidden in ("reserve", "depot", "breaches", "marrow"):
        assert not any(forbidden in f for f in fields), fields


# ---------------------------------------------------------------------------
# the economy's exact arithmetic
# ---------------------------------------------------------------------------

def test_regen_rates_full_empty_and_debt():
    d = ReserveDepot(120.0)
    for _ in range(60):
        d.advance(1.0 / 60.0)
    assert abs(d.reserve - 120.0) < 1e-9, "full caps at cap"
    d = ReserveDepot(0.0)
    for _ in range(60):
        d.advance(1.0 / 60.0)
    assert abs(d.reserve - 0.35) < 0.001, d.reserve
    d = ReserveDepot(0.0)
    d.set_debt(CORE_KILL_DEBT)
    for _ in range(90 * 60):
        d.advance(1.0 / 60.0)
    assert -0.6 <= d.reserve <= -0.4, (
        f"after 90s of home resupply the debt should sit near zero, "
        f"got {d.reserve}")
    for _ in range(2 * 60):
        d.advance(1.0 / 60.0)
    assert d.reserve > 0.0, "and cross it within two more seconds"


def test_the_stall_waits_for_the_selected_unit():
    """The gap before a pending Warden IS the reserve gauge: at empty
    reserve it stretches to ~23 seconds, the class never changes, and
    nothing cheaper is substituted meanwhile."""
    m = MarrowController()
    m.depot.reserve = 0.01
    m._shelf_queue = []
    m._pending_kind = "warden"
    br = Breach(breach_id=1, world_chamber=0, hub_chamber=1,
                opened_tick=0, link=None, last_cross_tick=0,
                last_interest_tick=0)
    m.on_breach_opened(1, 0)
    m._next_dispatch = 0
    dispatched_at = None
    for t in range(1, 30 * 60):
        br.note_crossing(t)          # keep closure out of this vector
        br.note_interest(t)
        cmds = m.step(t, None, [br], shelf_census=[])
        for c in cmds:
            assert c.kind != "dispatch" or c.unit_kind == "warden", (
                f"substituted {c.unit_kind} while a warden was pending")
            if c.kind == "dispatch":
                dispatched_at = t
        if dispatched_at:
            break
        assert m._pending_kind == "warden"
    assert dispatched_at is not None
    expect = (DISPATCH_COST["warden"] - 0.01) / 0.35 * 60
    assert abs(dispatched_at - expect) < 120, (
        f"stall {dispatched_at} ticks, expected ~{expect:.0f}")


def test_cost_fair_scheduler_bounds_the_skew():
    s = CostFairScheduler()
    s.add_breach(1)
    s.add_breach(2)
    spent = {1: 0.0, 2: 0.0}
    costs = [8, 1, 1, 2, 2, 3, 1, 4, 2, 1, 3, 8, 1, 2, 1, 4]
    for c in costs:
        s.accrue(1.0)
        bid = s.assign(float(c))
        spent[bid] += c
    assert abs(spent[1] - spent[2]) <= 8.0, spent
    s.add_breach(3)                    # a newcomer starts at the mean
    assert abs(s._credit[3] - (s._credit[1] + s._credit[2]) / 2) < 1e-9


# ---------------------------------------------------------------------------
# the real thing, in the real sim
# ---------------------------------------------------------------------------

def _world():
    b = LevelBuilder("MAR9", 1)
    ra = b.rect(0, 0, 400, 300)
    rb = b.rect(400, 0, 400, 300)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (80, 150))
    return GameSession(b.build(), seed=12), ra, rb


def _call(s, chamber, pos=(0.0, 0.0)):
    """A completed broadcast, through the medium's own API."""
    s.medium.try_lease(99999, s.tick_count)
    s.medium.complete(99999, chamber, pos, s.tick_count, "lacuna")


def test_physical_entry_through_a_scale_1_gate():
    s, ra, rb = _world()
    _call(s, rb)
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    hub_polys = set(s.hub.chambers.values())
    crossed_out = set()
    world_spawned = []
    opened = False
    for t in range(1, 4200):
        s.tick(InputFrame(ax=cx + 120, ay=cy, fire=(t % 25 == 3)))
        s.hp = max(s.hp, 100.0)
        for r in s.trace.drain():
            if r.kind == "breach_lifecycle" and r.data["event"] == "opened":
                opened = True
            if r.kind == "dispatch_decision":
                assert r.data["hub_chamber"] in hub_polys, (
                    "a dispatch was created OUTSIDE the hub")
            if (r.kind == "portal_crossing"
                    and r.data["from_polygon"] in hub_polys
                    and r.data["to_polygon"] not in hub_polys
                    and not r.data["entity_kind"].startswith("bullet")
                    and r.data["entity_kind"] != "other"):
                crossed_out.add(r.data["entity_id"])
        if len(crossed_out) >= 4:
            break
    assert opened, "the call never opened a breach"
    assert len(crossed_out) >= 4, (
        f"only {len(crossed_out)} bodies physically walked out")
    assert not world_spawned
    # and the gate is scale-1 by construction (topology asserts), so a
    # husk that walked out is still husk-sized
    for eid in crossed_out:
        if eid in s.enemies:
            kind = s.enemies[eid]["kind"]
            from perihelion.sim import ENEMIES
            assert abs(s.sim.get_radius(eid) - ENEMIES[kind]["radius"]) \
                < 1e-6, "a body changed size crossing the breach"


def test_closure_no_route_then_idle_rearm_then_exhaustion():
    # (a) nothing ever routes toward it: no_route at 12s. The reserve
    # sits ABOVE the exhaustion floor but below the pending warden's
    # price — a long stall with a healthy-ish depot is exactly the case
    # where a breach nobody routes toward quietly loses its point.
    s, ra, rb = _world()
    s.marrow._shelf_queue = []
    s.marrow.depot.reserve = 1.5
    s.marrow._pending_kind = "warden"
    _call(s, rb)
    sealed = None
    for t in range(1, NO_ROUTE_CLOSE_TICKS + 20 * 60):
        s.marrow.depot.reserve = min(s.marrow.depot.reserve, 1.5)
        s.tick(InputFrame())
        for r in s.trace.drain():
            if r.kind == "breach_lifecycle" and r.data["event"] == "sealed":
                sealed = (t, r.data["detail"])
        if sealed:
            break
    assert sealed is not None and sealed[1] == "no_route", sealed
    # (b) interest held, a PROJECTILE crossing at 44s re-arms the idle
    # clock; the seal comes ~45s after that crossing, not the opening
    s, ra, rb = _world()
    s.marrow._shelf_queue = []
    s.marrow.depot.reserve = 1.5
    s.marrow._pending_kind = "warden"
    _call(s, rb)
    opened_t = None
    sealed = None
    fired = False
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    for t in range(1, IDLE_CLOSE_TICKS * 3):
        s.hp = max(s.hp, 100.0)                # an unkillable observer
        # pin the reserve under the warden's price but over the
        # exhaustion floor: the stall must HOLD without tripping the
        # exhausted closure (regen would eventually pay the warden and
        # its crossing would contaminate the idle clock)
        s.marrow.depot.reserve = min(s.marrow.depot.reserve, 1.5)
        br = s.breaches[0]["obj"] if s.breaches else None
        if br is not None:
            br.note_interest(s.tick_count)     # something hub-side cares
            if opened_t is None:
                opened_t = s.tick_count
        fire = False
        ax_, ay_ = cx + 200, cy
        if opened_t is not None and not fired \
                and s.tick_count - opened_t == IDLE_CLOSE_TICKS - 90:
            # stand in the breach room and put a round THROUGH the hole
            import necore
            bx, by = s.breaches[0]["pos"]
            s.reseat_player(s.breaches[0]["polygon"],
                            (bx * 0.5, by * 0.5))
            ax_, ay_ = necore.mat_apply(s.cam, bx, by)
            fire = True
            fired = True
        s.tick(InputFrame(ax=ax_, ay=ay_, fire=fire))
        for r in s.trace.drain():
            if r.kind == "breach_lifecycle" and r.data["event"] == "sealed":
                sealed = (s.tick_count, r.data["detail"])
        if sealed:
            break
    assert sealed is not None and sealed[1] == "idle", sealed
    assert fired, "the re-arm shot never happened"
    assert sealed[0] - opened_t > IDLE_CLOSE_TICKS + 30 * 60, (
        f"breach sealed at +{sealed[0] - opened_t} — the projectile "
        f"crossing did not re-arm the 45s clock")
    # (c) exhaustion: reserve zeroed with crossings alive -> +10s grace
    s, ra, rb = _world()
    _call(s, rb)
    sealed = None
    zeroed_at = None
    for t in range(1, 90 * 60):
        s.hp = max(s.hp, 100.0)
        s.tick(InputFrame())
        if s.breaches and zeroed_at is None and s.tick_count \
                - s.breaches[0]["obj"].opened_tick > 60:
            s.marrow.depot.reserve = 0.0
            zeroed_at = s.tick_count
        if zeroed_at is not None and s.breaches:
            s.breaches[0]["obj"].note_crossing(s.tick_count)
            s.breaches[0]["obj"].note_interest(s.tick_count)
        if zeroed_at is not None:
            s.marrow.depot.reserve = min(s.marrow.depot.reserve, 0.0)
        for r in s.trace.drain():
            if r.kind == "breach_lifecycle" and r.data["event"] == "sealed":
                sealed = (s.tick_count, r.data["detail"])
        if sealed:
            break
    assert sealed is not None and sealed[1] == "exhausted", sealed
    assert abs((sealed[0] - zeroed_at) - EXHAUST_GRACE_TICKS) <= 5, (
        f"grace was {sealed[0] - zeroed_at} ticks")


def test_first_call_leads_with_the_shelf_later_calls_do_not():
    """The second-ranked tell: a fresh hub answers with its standing
    guardians; once they are spent, later pours are production only."""
    s, ra, rb = _world()
    _call(s, rb)
    cx, cy = s.screen_w / 2.0, s.screen_h / 2.0
    shelf_seen = 0
    produced = 0
    for t in range(1, 60 * 60):
        s.hp = max(s.hp, 100.0)
        s.tick(InputFrame(ax=cx + 120, ay=cy, fire=(t % 25 == 3)))
        for r in s.trace.drain():
            if r.kind == "dispatch_decision":
                if r.data["from_shelf"]:
                    shelf_seen += 1
                else:
                    produced += 1
        if produced >= 3:
            break
    assert shelf_seen == len(GUARDIAN_SHELF), (
        f"the first pour led with {shelf_seen} guardians, "
        f"want the whole shelf of {len(GUARDIAN_SHELF)}")
    assert produced >= 3, "production never took over after the shelf"
