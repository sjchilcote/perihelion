"""Gate run 65 audio forensics: adversary_return firing, window context, pathology scan."""
import json
from collections import Counter, defaultdict
from pathlib import Path

BASE = Path("/home/login/PycharmProjects/noneuclideantopdownshooter/out/eval_gate")
RETURNS = {  # seed -> tick list
    2: [5491, 10770],
    4: [],
    7: [4780, 9896, 12917],
    11: [4683, 5204, 7105, 8574, 11421, 14018],
}
NAME = "adversary_return"


def load(seed):
    ev = []
    p = BASE / f"run_s{seed}" / "events.jsonl"
    for i, line in enumerate(p.read_text().splitlines()):
        line = line.strip()
        if not line:
            continue
        e = json.loads(line)
        if e.get("kind") == "sfx":
            ev.append(e)
    ev.sort(key=lambda e: e["t"])
    return ev


for seed, ticks in RETURNS.items():
    ev = load(seed)
    dur = ev[-1]["t"] if ev else 0.0
    print(f"\n{'='*72}\nSEED {seed}  events={len(ev)}  span={dur:.1f}s ({dur/60:.2f} min)")

    # --- check 1: firing accounting
    fires = [e for e in ev if e["name"] == NAME]
    expected = [t / 60.0 for t in ticks]
    print(f"-- CHECK 1: {NAME} fires={len(fires)} expected={len(expected)}")
    matched = set()
    for et, tick in zip(expected, ticks):
        near = [(i, f) for i, f in enumerate(fires) if abs(f["t"] - et) <= 0.5]
        for i, _ in near:
            matched.add(i)
        stat = "OK" if len(near) == 1 else ("MISSING" if not near else f"DUP x{len(near)}")
        offs = ", ".join(f"{f['t']-et:+.3f}s vol={f['vol']:.3f} pan={f['pan']:.2f}" for _, f in near)
        print(f"   tick {tick:>6} (t={et:8.3f}s): {stat}  [{offs}]")
    phantoms = [f for i, f in enumerate(fires) if i not in matched]
    print(f"   PHANTOM fires (no listed return within 0.5s): {len(phantoms)}")
    for f in phantoms:
        print(f"      t={f['t']:.3f}s (tick {f['t']*60:.0f}) vol={f['vol']:.3f} pan={f['pan']:.2f}")

    # --- check 2: +-0.5s context
    print(f"-- CHECK 2: +-0.5s context around each listed return")
    for et, tick in zip(expected, ticks):
        win = [e for e in ev if abs(e["t"] - et) <= 0.5]
        c = Counter(e["name"] for e in win)
        ret_vol = max((e["vol"] for e in win if e["name"] == NAME), default=None)
        others = [e for e in win if e["name"] != NAME]
        louder = [e for e in others if ret_vol is not None and e["vol"] >= ret_vol]
        print(f"   t={et:8.3f}s: {len(win)} sounds ({len(others)} others), "
              f"return_vol={ret_vol}, others_at_or_louder={len(louder)}")
        for n, k in c.most_common(10):
            vols = [e["vol"] for e in win if e["name"] == n]
            print(f"        {n:28s} x{k:<3d} vol max={max(vols):.3f}")
        # tightest window: +-0.15s
        tight = [e for e in ev if abs(e["t"] - et) <= 0.15 and e["name"] != NAME]
        print(f"        [+-0.15s] {len(tight)} other sounds: {dict(Counter(e['name'] for e in tight))}")

    # --- check 3: pathology
    print(f"-- CHECK 3: pathology scan")
    c = Counter(e["name"] for e in ev)
    total = len(ev)
    for n, k in c.most_common(15):
        print(f"   {n:30s} {k:6d}  {100*k/total:5.1f}%  {k/max(dur,1)*60:7.1f}/min")
    # machine-gun: max count of same name in any 1s sliding window
    by = defaultdict(list)
    for e in ev:
        by[e["name"]].append(e["t"])
    print("   machine-gun (max same-name count in any 1.0s window, >5 flagged):")
    rows = []
    for n, ts in by.items():
        best, bi = 0, 0
        j = 0
        for i in range(len(ts)):
            while ts[i] - ts[j] > 1.0:
                j += 1
            if i - j + 1 > best:
                best, bi = i - j + 1, ts[j]
        rows.append((best, n, bi, len(ts)))
    rows.sort(reverse=True)
    for best, n, at, k in rows[:12]:
        flag = "  <<< FLAG" if best > 5 else ""
        print(f"      {n:30s} max={best:4d}/s at t={at:8.2f}s  total={k}{flag}")
