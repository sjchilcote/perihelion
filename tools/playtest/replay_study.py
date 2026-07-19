"""replay_study — re-simulate a recorded HUMAN run and quantify how it
was played, in the doctrine's own terms.

    uv run python tools/playtest/replay_study.py --rec out/director_fc/attempt_04 \
        [--level levels/gauntlet4.json] [--seed 2200] [--json OUT.json]

Needs the recording's inputs.jsonl (captured by `--play --record` since
2026-07-19). The sim is deterministic: level + seed + loadout + the
per-tick InputFrame stream reproduces the run exactly. Parity is
verified against the recording's own events.jsonl music lines before
any numbers are reported.

Reported, per run:
  - survival, outcome, kills, wardens down, hp timeline
  - damage intake ledger: every hp drop with context (nearest threat
    kind/distance, player speed, in-shadow-of-ranged?)
  - engagement ranges while firing, per weapon
  - warden encounters: first-perception -> resolution, duration, hp
    cost, range profile, kill or disengage
  - movement: speed profile, stationarity episodes
  - cover usage: of the time a ranged hunter had the player in its
    sight (renderer sight_map), what fraction the player spent in
    shadow, and the median exposure burst length
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import os
os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rec", required=True)
    ap.add_argument("--level", default="levels/gauntlet4.json")
    ap.add_argument("--seed", type=int, default=2200)
    ap.add_argument("--json", default=None)
    ap.add_argument("--parity-lines", type=int, default=40)
    a = ap.parse_args()

    from perihelion.levels import load_level
    from perihelion.sim import GameSession, InputFrame
    from perihelion.testkit.loadouts import FULL_LOADOUT

    rec = Path(a.rec)
    inputs_path = rec / "inputs.jsonl"
    if not inputs_path.exists():
        sys.exit(f"{inputs_path} missing — this recording predates input "
                 f"capture and cannot be re-simulated")
    inputs = [json.loads(l) for l in open(inputs_path)]
    print(f"[replay] {len(inputs)} input ticks from {rec}")

    # recorded music lines for parity
    rec_music = []
    ev_path = rec / "events.jsonl"
    if ev_path.exists():
        for l in open(ev_path):
            d = json.loads(l)
            if d.get("kind") == "music_dbg":
                rec_music.append(d["name"])
            if len(rec_music) >= a.parity_lines:
                break

    # mirror the APP's session construction exactly — inputs are in
    # SCREEN space, so camera geometry (screen size, zoom) is part of
    # replay determinism, not cosmetics
    import copy
    from perihelion.render import (INTERNAL_H, INTERNAL_RES_ZOOM_SCALE,
                                   INTERNAL_W)
    from perihelion.app import ZOOM_BASE
    state = copy.deepcopy(FULL_LOADOUT)
    level = load_level(ROOT / a.level)
    session = GameSession(level, seed=a.seed, player_state=state,
                          screen=(INTERNAL_W, INTERNAL_H),
                          zoom=ZOOM_BASE[0] * INTERNAL_RES_ZOOM_SCALE)
    session.music_tier = getattr(level, "tier", 1)

    live_music = []
    if rec_music:
        from perihelion.audio import Audio
        from perihelion.music import MUSIC_ROOT, MusicSystem
        audio = Audio(mute=True)

        def tap(kind, name, vol, pan):
            if kind == "music_dbg" and len(live_music) < a.parity_lines:
                live_music.append(name)
        audio.tap = tap
        banks = sorted(p for p in MUSIC_ROOT.glob("album_*")
                       if (p / "bank.json").exists())
        music = MusicSystem(audio, enabled=True, bank_dirs=banks or None,
                            tick_clock=True)
    else:
        music = None

    hp_prev = state["hp"]
    kills_prev = 0
    ledger = []           # damage intake events
    fire_ranges = defaultdict(list)
    warden_enc = []
    cur_enc = None
    speed_hist = Counter()
    stationary = 0
    pos_prev = None
    ranged_los_ticks = 0
    ranged_shadow_ticks = 0
    exposure_burst = 0
    exposure_bursts = []
    hp_series = []
    sight_cache = {}

    def in_shadow_of(e_pol, e_x, e_y, p_pol, p_x, p_y, tick):
        key = (e_pol, round(e_x, -1), round(e_y, -1), tick // 6)
        sm = sight_cache.get(key)
        if sm is None:
            sm = session.sight_map(e_pol, e_x, e_y)
            sight_cache.clear()
            sight_cache[key] = sm
        return not session.point_in_sight(sm, p_pol, p_x, p_y)

    n = 0
    for row in inputs:
        if session.dead or session.complete:
            break
        inp = InputFrame()
        inp.mx, inp.my = row["mx"], row["my"]
        inp.ax, inp.ay = row["ax"], row["ay"]
        inp.fire = row["fire"]
        inp.alt = row["alt"]
        inp.weapon = row["weapon"]
        if row.get("interact"):
            inp.interact = True
        snap = session.snapshot()
        px, py = snap["pos"]
        ppol = snap["polygon"]

        threats = [e for e in snap["enemies"]
                   if e["polygon"] == ppol]
        nearest = min(threats,
                      key=lambda e: math.hypot(e["pos"][0] - px,
                                               e["pos"][1] - py),
                      default=None)

        if pos_prev is not None:
            sp = math.hypot(px - pos_prev[0], py - pos_prev[1]) * 60.0
            speed_hist[min(int(sp // 20) * 20, 160)] += 1
            if sp < 8.0 and threats:
                stationary += 1
        pos_prev = (px, py)

        if inp.fire and nearest is not None:
            fire_ranges[snap["weapon"]].append(
                round(math.hypot(nearest["pos"][0] - px,
                                 nearest["pos"][1] - py)))

        # ranged-threat LOS / shadow accounting (every 6th tick: the
        # sight query is the renderer's, not free)
        if n % 6 == 0:
            rng_th = [e for e in snap["enemies"]
                      if e.get("kind") in ("spitter", "warden")
                      and e.get("state") == "hunt"]
            exposed = False
            for e in rng_th[:3]:
                epol = e["polygon"]
                if session.sim.hop_distance(epol, ppol) > 3:
                    continue
                if not in_shadow_of(epol, e["pos"][0], e["pos"][1],
                                    ppol, px, py, n):
                    exposed = True
                    break
            if rng_th:
                ranged_los_ticks += 6
                if exposed:
                    ranged_shadow_ticks += 0
                    exposure_burst += 6
                else:
                    ranged_shadow_ticks += 6
                    if exposure_burst:
                        exposure_bursts.append(exposure_burst)
                        exposure_burst = 0

        # warden encounter tracking
        wds = [e for e in snap["enemies"] if e["kind"] == "warden"
               and session.sim.hop_distance(e["polygon"], ppol) <= 1]
        if wds and cur_enc is None:
            cur_enc = dict(t0=n, hp0=snap["hp"], ranges=[])
        if cur_enc is not None:
            if wds:
                w0 = min(wds, key=lambda e: math.hypot(
                    e["pos"][0] - px, e["pos"][1] - py))
                cur_enc["ranges"].append(round(math.hypot(
                    w0["pos"][0] - px, w0["pos"][1] - py)))
                cur_enc["last"] = n
            elif n - cur_enc.get("last", n) > 300:
                cur_enc["dur"] = (cur_enc["last"] - cur_enc["t0"]) / 60
                cur_enc["hp_cost"] = cur_enc["hp0"] - snap["hp"]
                warden_enc.append(cur_enc)
                cur_enc = None

        session.tick(inp)
        if music is not None:
            music.update(session)
        hp = session.hp
        if hp < hp_prev:
            ledger.append(dict(
                t=round(n / 60, 1), dmg=round(hp_prev - hp, 1),
                near=(nearest["kind"] if nearest else None),
                near_d=(round(math.hypot(nearest["pos"][0] - px,
                                         nearest["pos"][1] - py))
                        if nearest else None)))
        hp_prev = hp
        if n % 6 == 0:
            hp_series.append((round(n / 60), round(hp)))
        kills_prev = session.metrics.get("kills", kills_prev)
        n += 1

    outcome = ("complete" if session.complete
               else "dead" if session.dead else "input-end")
    parity = None
    if rec_music:
        m = sum(1 for x, y in zip(rec_music, live_music) if x == y)
        parity = f"{m}/{len(rec_music)}"
        if m < len(rec_music):
            print(f"[replay] PARITY IMPERFECT ({parity}) — treat numbers "
                  f"as approximate; sim/config drift since recording")

    wardens0 = sum(1 for k in getattr(level, "polygon_kinds", []) if False)
    print(f"[replay] outcome={outcome} t={n/60:.0f}s kills="
          f"{session.metrics.get('kills')} parity={parity}")
    print(f"  damage events: {len(ledger)}, total "
          f"{sum(d['dmg'] for d in ledger):.0f}hp; by nearest kind: "
          f"{Counter(d['near'] for d in ledger).most_common(6)}")
    for w, rs in sorted(fire_ranges.items()):
        rs.sort()
        print(f"  fire ranges {w:9s}: n={len(rs):5d} median="
              f"{rs[len(rs)//2] if rs else 0}u")
    tot_move = sum(speed_hist.values()) or 1
    fast = sum(v for k, v in speed_hist.items() if k >= 100)
    print(f"  movement: {100*fast/tot_move:.0f}% of ticks at >=100u/s; "
          f"stationary-under-threat {stationary/60:.1f}s")
    if ranged_los_ticks:
        print(f"  cover: ranged hunter present {ranged_los_ticks/60:.0f}s; "
              f"in-shadow {100*ranged_shadow_ticks/ranged_los_ticks:.0f}%"
              f"; exposure bursts median "
              f"{(sorted(exposure_bursts)[len(exposure_bursts)//2]/60 if exposure_bursts else 0):.1f}s")
    print(f"  warden encounters: {len(warden_enc)}")
    for i, e in enumerate(warden_enc):
        rs = sorted(e["ranges"])
        print(f"    #{i+1}: t0={e['t0']/60:.0f}s dur={e.get('dur',0):.1f}s "
              f"hp_cost={e.get('hp_cost',0):.0f} range med={rs[len(rs)//2]}u "
              f"min={rs[0]}u")

    if a.json:
        json.dump(dict(outcome=outcome, t=n / 60, parity=parity,
                       ledger=ledger, warden_enc=warden_enc,
                       fire_ranges={k: sorted(v) for k, v in
                                    fire_ranges.items()},
                       hp_series=hp_series), open(a.json, "w"))
        print(f"[replay] json -> {a.json}")


if __name__ == "__main__":
    main()
