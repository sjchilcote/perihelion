"""U1 gate — the instrumentation spine.

Layer 1 (construction): typed events reject missing fields, the bus has
no read/query surface, sequence numbers strictly increase, ticks never
decrease.

Layer 2 (isolated vector): a 120-tick two-room run with one shot and one
portal crossing produces EXACTLY the expected records — 120 input
records, 8 samples on the 15-tick cadence, one damage_applied, at least
one impulse_applied, exactly one player portal_crossing — and the app
writer and harness writer emit byte-compatible schemas (they are the
same writer; this pins that they stay so).
"""
from __future__ import annotations

import json

import pytest

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame
from perihelion.telemetry import (DamageApplied, InputRecord, TraceBus,
                                  TraceWriter, to_json_line)

def _center(session):
    """Aim coordinates are screen pixels; the camera centers the player,
    so the screen midpoint aims 'at my own feet' and offsets aim true."""
    return session.screen_w / 2.0, session.screen_h / 2.0


# ---------------------------------------------------------------------------
# Layer 1: construction
# ---------------------------------------------------------------------------

def test_events_reject_missing_fields():
    with pytest.raises(TypeError):
        InputRecord(tick=1)                      # everything else missing
    with pytest.raises(TypeError):
        DamageApplied(tick=1, target_id=2)       # amount/kind/source missing


def test_bus_has_no_query_surface():
    """Telemetry can never become a gameplay input: the only way data
    leaves the bus is drain(), which empties it."""
    public = {n for n in dir(TraceBus) if not n.startswith("_")}
    assert public == {"emit", "sample", "drain"}, (
        f"TraceBus grew a read/query surface: {public}")


def test_seq_strictly_increases_and_tick_never_decreases():
    bus = TraceBus()
    bus.sample(5, {"a": 1})
    bus.sample(5, {"a": 2})      # same tick fine
    bus.sample(9, {"a": 3})
    with pytest.raises(ValueError):
        bus.sample(8, {"a": 4})  # backwards tick refused at the emit site
    recs = bus.drain()
    assert [r.seq for r in recs] == [1, 2, 3]
    assert bus.drain() == []     # drain empties


# ---------------------------------------------------------------------------
# Layer 2: the 120-tick vector
# ---------------------------------------------------------------------------

def _two_room_level():
    b = LevelBuilder("TRACEVEC", 1)
    ra = b.rect(0, 0, 480, 200)
    rb = b.rect(480, 0, 320, 200)
    b.connect(ra, 2, rb, 0)
    b.player(ra, (440, 100))     # 40u left of the portal edge
    return b.build(), ra, rb


def _run_vector(session):
    """Tick 1-5 idle; tick 6 one pistol shot left at the husk; tick 20+
    walk right through the portal; 120 ticks total."""
    cx, cy = _center(session)
    for t in range(1, 121):
        fire = (t == 6)
        mx = 1.0 if 20 <= t <= 80 else 0.0
        ax = cx - 140.0 if t <= 10 else cx
        session.tick(InputFrame(mx=mx, my=0.0, ax=ax, ay=cy,
                                fire=fire, alt=False, interact=False,
                                weapon=0))


def test_120_tick_vector_exact_counts(tmp_path):
    level, ra, rb = _two_room_level()
    session = GameSession(level, seed=11)
    session.spawn_enemy(ra, (0.0, 0.0), "husk")   # 200u left of the player
    _run_vector(session)

    recs = session.trace.drain()
    by_kind: dict[str, list] = {}
    for r in recs:
        by_kind.setdefault(r.kind, []).append(r)

    assert len(by_kind["input"]) == 120
    hud_ticks = [r.tick for r in by_kind["sample"]
                 if "warden" not in r.data]
    assert hud_ticks == [15, 30, 45, 60, 75, 90, 105, 120]
    # the warden track (verifiability of 'stationary warden' claims)
    # samples every 60 ticks per live warden
    wtrack = [r.tick for r in by_kind["sample"] if "warden" in r.data]
    assert all(t % 60 == 0 for t in wtrack)

    dmg = by_kind["damage_applied"]
    assert len(dmg) == 1, f"expected exactly one damage event, got {dmg}"
    assert dmg[0].data["target_kind"] == "husk"
    assert dmg[0].data["source"] == "bullet"

    imp = by_kind.get("impulse_applied", [])
    assert len(imp) >= 1
    assert imp[0].data["entity_id"] == dmg[0].data["target_id"]

    player_crossings = [r for r in by_kind.get("portal_crossing", [])
                        if r.data["entity_kind"] == "player"]
    assert len(player_crossings) == 1
    assert player_crossings[0].data["from_polygon"] == ra
    assert player_crossings[0].data["to_polygon"] == rb

    # the shot woke the husk: its transitions were traced
    kinds = {(r.data["from_state"], r.data["to_state"])
             for r in by_kind.get("agent_transition", [])}
    assert ("idle", "hunt") in kinds or ("idle", "waking") in kinds

    # do NOT assert full event-stream determinism across runs — the trace
    # is evidence, not part of replay equality.


def test_app_and_harness_schemas_identical(tmp_path):
    """Both drain through TraceWriter; the JSONL key sets per kind must
    match exactly between a directly-driven session and a harness bot run."""
    level, ra, rb = _two_room_level()
    session = GameSession(level, seed=11)
    session.spawn_enemy(ra, (0.0, 0.0), "husk")
    w = TraceWriter(tmp_path / "direct.jsonl", header=dict(level="x", seed=11))
    cx, cy = _center(session)
    for t in range(1, 121):
        session.tick(InputFrame(mx=0.0, my=0.0, ax=cx - 140.0, ay=cy,
                                fire=(t == 6), alt=False, interact=False,
                                weapon=0))
        w.drain_from(session.trace)
    w.close()

    from perihelion.testkit.bots import PacifistBot
    from perihelion.testkit.harness import run_bot
    run_bot(level, PacifistBot(3), seed=3, max_ticks=120,
            trace_path=tmp_path / "bot.jsonl")

    def keysets(path):
        out: dict[str, frozenset] = {}
        for line in open(path, encoding="utf-8"):
            rec = json.loads(line)
            k = rec["kind"]
            if k in ("header", "sample"):
                continue  # header/sample payloads vary by context
            out.setdefault(k, frozenset(rec.keys()))
            assert frozenset(rec.keys()) == out[k], f"schema drift within {k}"
        return out

    ka, kb = keysets(tmp_path / "direct.jsonl"), keysets(tmp_path / "bot.jsonl")
    for kind in ka.keys() & kb.keys():
        assert ka[kind] == kb[kind], (
            f"{kind} schema differs between app-style and harness-style: "
            f"{ka[kind]} vs {kb[kind]}")
    assert "input" in ka and "input" in kb


def test_writer_output_parses_and_orders(tmp_path):
    level, ra, rb = _two_room_level()
    session = GameSession(level, seed=5)
    w = TraceWriter(tmp_path / "t.jsonl", header=dict(level="x", seed=5))
    for t in range(1, 31):
        session.tick(InputFrame())
        w.drain_from(session.trace)
    w.close()
    lines = open(tmp_path / "t.jsonl", encoding="utf-8").read().splitlines()
    assert json.loads(lines[0])["kind"] == "header"
    seqs = [json.loads(ln)["seq"] for ln in lines[1:]]
    assert seqs == sorted(seqs) and len(set(seqs)) == len(seqs)
    ticks = [json.loads(ln)["t"] for ln in lines[1:]]
    assert all(b >= a for a, b in zip(ticks, ticks[1:]))
