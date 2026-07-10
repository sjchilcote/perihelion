"""Full-campaign streamed soak: AggroBot plays the seamless ten-chunk
campaign end to end with cold-restore respawns, exactly the gate the
difficulty floors were tuned against.

Usage:
    uv run python tools/playtest/stream_soak.py [--seeds 2175,23,7] \
        [--hard] [--max-ticks 200000]

Prints one line per seed: outcome, ticks, deaths, kills, components
banked (the economy's income counter rides the same run for free).
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "game"))

from perihelion.levels import load_level  # noqa: E402
from perihelion.sim import GameSession  # noqa: E402
from perihelion.stream import WorldStreamer  # noqa: E402
from perihelion.testkit.bots import AggroBot  # noqa: E402


def campaign_paths() -> list[str]:
    import json
    man = json.load(open(REPO / "levels" / "campaign.json"))
    return [str(REPO / p) for p in man["levels"]]


def run_seed(seed: int, hard: bool, max_ticks: int) -> dict:
    paths = campaign_paths()
    s = GameSession(load_level(paths[0]), seed=seed,
                    difficulty="hard" if hard else "normal")
    ws = WorldStreamer(s, paths)
    bot = AggroBot(seed)
    salvage_seen = 0
    while s.tick_count < max_ticks and not s.complete:
        if s.dead:
            ws.respawn()
            continue
        snap = s.snapshot()
        salvage_seen = max(salvage_seen, snap["components"])
        s.tick(bot.step(snap, s))
        ws.tick()
    return dict(
        outcome="complete" if s.complete else "timeout",
        ticks=s.tick_count, deaths=s.metrics["deaths"],
        kills=s.metrics["kills"], chunk=ws.current,
        components_final=s.components, components_peak=salvage_seen)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seeds", default="23,2175,7,101,4242")
    ap.add_argument("--hard", action="store_true")
    ap.add_argument("--max-ticks", type=int, default=200_000)
    args = ap.parse_args()
    fails = 0
    for seed in [int(x) for x in args.seeds.split(",")]:
        r = run_seed(seed, args.hard, args.max_ticks)
        print(f"seed {seed}: {r['outcome']} t={r['ticks']} "
              f"deaths={r['deaths']} kills={r['kills']} chunk={r['chunk']} "
              f"salvage peak={r['components_peak']} "
              f"final={r['components_final']}", flush=True)
        if r["outcome"] != "complete":
            fails += 1
    print(f"{'PASS' if fails == 0 else 'FAIL'} ({fails} incomplete)")
    sys.exit(1 if fails else 0)


if __name__ == "__main__":
    main()
