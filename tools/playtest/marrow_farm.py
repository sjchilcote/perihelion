"""U16 acceptance farm — ordinary sessions, measured, no harness help.

Runs K seeds of the shipping gauntlet4 headless with the HumanBot and
reports the reinforcement loop's observable numbers per seed and in
aggregate: when the first call lands, how many breaches open/dry/seal,
pour size and the ~10% knowledge split, shelf replacements, census
attrition, and survival. This is the instrument for the OPEN question
"what does the marrow do to difficulty" — the answer must come from
here, not from anyone's impression.

    uv run python tools/playtest/marrow_farm.py [--seeds 16] \
        [--ticks 24000] [--out out/marrow_farm.json]
"""
from __future__ import annotations

import argparse
import json
import statistics
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

from perihelion.levels import load_level  # noqa: E402
from perihelion.sim import GameSession  # noqa: E402
from perihelion.testkit import HumanBot  # noqa: E402


def run_seed(level, seed: int, ticks: int) -> dict:
    s = GameSession(level, seed=seed, difficulty="hard")
    bot = HumanBot(seed)
    census0 = dict(s.adversary_census)
    m = dict(seed=seed, opened=0, dry=0, sealed=0, dispatches=0,
             knowers=0, replacements=0, first_breach=None,
             breach_ticks=[], kills=0, dry_no_seam=0, dry_no_wall=0,
             dry_wall_chambers={})
    for _ in range(ticks):
        if s.dead or s.complete:
            break
        snap = s.snapshot()
        s.tick(bot.step(snap, s))
        for r in s.trace.drain():
            if r.kind == "breach_lifecycle":
                ev = r.data["event"]
                if ev == "opened":
                    m["opened"] += 1
                    m["breach_ticks"].append(r.tick)
                    if m["first_breach"] is None:
                        m["first_breach"] = r.tick
                elif ev.startswith("dry"):
                    m["dry"] += 1
                    detail = r.data.get("detail", "")
                    if "apse seam" in detail:
                        m["dry_no_seam"] += 1
                    elif "96u seam" in detail:
                        m["dry_no_wall"] += 1
                        ch = str(r.data.get("world_chamber"))
                        m["dry_wall_chambers"][ch] = \
                            m["dry_wall_chambers"].get(ch, 0) + 1
                elif ev == "sealed":
                    m["sealed"] += 1
            elif r.kind == "dispatch_decision":
                m["dispatches"] += 1
                m["knowers"] += bool(r.data.get("knows_position"))
            elif r.kind == "shelf_replaced":
                m["replacements"] += 1
    m["survived_ticks"] = s.tick_count
    m["dead"] = s.dead
    m["complete"] = s.complete
    m["kills"] = s.metrics["kills"]
    m["census_start"] = census0
    m["census_end"] = dict(s.adversary_census)
    m["scouts_killed"] = (sum(census0.values())
                          - sum(s.adversary_census.values()))
    return m


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--seeds", type=int, default=16)
    ap.add_argument("--seed-start", type=int, default=1)
    ap.add_argument("--ticks", type=int, default=24000)
    ap.add_argument("--level", default="levels/gauntlet4.json")
    ap.add_argument("--out", default="out/marrow_farm.json")
    a = ap.parse_args()

    level = load_level(ROOT / a.level)
    rows = []
    for seed in range(a.seed_start, a.seed_start + a.seeds):
        m = run_seed(level, seed, a.ticks)
        rows.append(m)
        fb = m["first_breach"]
        print(f"seed {seed:3d}: {'DIED' if m['dead'] else 'alive':5s} "
              f"t={m['survived_ticks']:6d} breaches={m['opened']} "
              f"dry={m['dry']} sealed={m['sealed']} "
              f"pour={m['dispatches']:3d} know={m['knowers']} "
              f"repl={m['replacements']:2d} "
              f"first={fb if fb is not None else '-':>6} "
              f"scouts-{m['scouts_killed']}", flush=True)

    survived = [r for r in rows if not r["dead"]]
    died = [r for r in rows if r["dead"]]
    firsts = [r["first_breach"] for r in rows
              if r["first_breach"] is not None]
    agg = dict(
        seeds=a.seeds, seed_start=a.seed_start, ticks=a.ticks,
        survival_rate=len(survived) / len(rows),
        death_tick_mean=(statistics.mean(r["survived_ticks"]
                                         for r in died) if died else None),
        first_breach_mean=(statistics.mean(firsts) if firsts else None),
        first_breach_min=(min(firsts) if firsts else None),
        opened_total=sum(r["opened"] for r in rows),
        dry_total=sum(r["dry"] for r in rows),
        no_loop_seeds=sum(1 for r in rows if r["opened"] == 0),
        dry_no_seam_total=sum(r["dry_no_seam"] for r in rows),
        dry_no_wall_total=sum(r["dry_no_wall"] for r in rows),
        dispatch_mean=statistics.mean(r["dispatches"] for r in rows),
        knower_fraction=(sum(r["knowers"] for r in rows)
                         / max(1, sum(r["dispatches"] for r in rows))),
        scouts_killed_mean=statistics.mean(r["scouts_killed"]
                                           for r in rows),
    )
    wall_rooms: dict[str, int] = {}
    for r in rows:
        for ch, n in r["dry_wall_chambers"].items():
            wall_rooms[ch] = wall_rooms.get(ch, 0) + n
    agg["geometry_migration_worklist"] = dict(
        sorted(wall_rooms.items(), key=lambda kv: -kv[1]))
    print("\naggregate:", json.dumps(agg, indent=2))
    out = ROOT / a.out
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(dict(aggregate=agg, seeds=rows), indent=1))
    print(f"wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
