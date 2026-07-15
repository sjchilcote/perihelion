"""build_gauntlet2 — the DENSE calibration gauntlet, done right.

Director 2026-07-16: the original calibration gauntlet had 10 enemies
(9 husk, 1 spitter — five kinds never calibrated) and the horde variant
stacked packs on the same 10 spawn points ("walks into a wall of 50
enemies and gets crushed like an empty beer can"). This builder:

- keeps gauntlet_cal.json's GEOMETRY/lights/textures verbatim (the
  rooms, connects, doors, exit are untouched);
- SPREADS a full enemy population across all rooms: placement by room
  area, minimum separation, interior sampling with wall margin;
- represents EVERY enemy kind at meaningful share;
- parameterized (--n, --min-sep, --seed) for the 50%-pass-rate tuning
  loop (tune_pass_rate.py); tuning moves/spreads enemies and buffs the
  player, never thins the population.

    uv run python tools/musiccal/build_gauntlet2.py --n 180 --min-sep 60
"""
from __future__ import annotations

import argparse
import json
import math
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

# every kind well represented (director's order)
MIX = {"husk": 0.30, "mite": 0.20, "spitter": 0.15, "shrieker": 0.10,
       "brute": 0.10, "warden": 0.05, "flicker": 0.10}

SAFE_ROOM_RADIUS = 260.0     # no spawns near the player start

# heavy kinds keep out of the early run and out of packs (tuning law:
# deaths clustered at early rooms with warden packs — move, don't thin)
DEPTH_MIN = {"warden": 0.55, "brute": 0.40, "shrieker": 0.30}
KIND_SEP_MULT = {"warden": 3.0, "brute": 2.0, "shrieker": 1.5}
ROOM_CAP = {"warden": 1, "brute": 1}


def poly_area(vs):
    s = 0.0
    for i in range(len(vs)):
        x1, y1 = vs[i]
        x2, y2 = vs[(i + 1) % len(vs)]
        s += x1 * y2 - x2 * y1
    return abs(s) / 2


def point_in_poly(x, y, vs):
    inside = False
    j = len(vs) - 1
    for i in range(len(vs)):
        xi, yi = vs[i]
        xj, yj = vs[j]
        if (yi > y) != (yj > y) and \
                x < (xj - xi) * (y - yi) / (yj - yi + 1e-12) + xi:
            inside = not inside
        j = i
    return inside


def dist_to_edges(x, y, vs):
    d = float("inf")
    for i in range(len(vs)):
        x1, y1 = vs[i]
        x2, y2 = vs[(i + 1) % len(vs)]
        dx, dy = x2 - x1, y2 - y1
        t = max(0.0, min(1.0, ((x - x1) * dx + (y - y1) * dy)
                         / (dx * dx + dy * dy + 1e-12)))
        px, py = x1 + t * dx, y1 + t * dy
        d = min(d, math.hypot(x - px, y - py))
    return d


def build(n_total: int, min_sep: float, seed: int, margin: float = 22.0):
    src = json.loads((ROOT / "levels/gauntlet_cal.json").read_text())
    rng = random.Random(seed)
    rooms = src["rooms"]
    player_room = src["player"]["room"]
    ppos = src["player"]["pos"]

    # strip old enemies, keep non-enemy entities (pickups etc.)
    kinds = set(MIX)
    for r in rooms:
        r["entities"] = [e for e in r.get("entities", [])
                         if e["type"] not in kinds]

    # area-weighted room allocation (player room excluded)
    areas = []
    for i, r in enumerate(rooms):
        a = poly_area(r["verts"]) if i != player_room else 0.0
        areas.append(a)
    total_area = sum(areas)

    # kind counts (largest-remainder rounding to hit n_total exactly)
    counts = {k: int(n_total * f) for k, f in MIX.items()}
    while sum(counts.values()) < n_total:
        k = max(MIX, key=lambda q: n_total * MIX[q] - counts[q])
        counts[k] += 1

    # shuffle a flat kind list, deal onto rooms by area weight
    pool = [k for k, c in counts.items() for _ in range(c)]
    rng.shuffle(pool)

    placed_pts: dict[int, list] = {i: [] for i in range(len(rooms))}
    placed = 0
    fails = 0
    kind_pts: dict[str, list] = {k: [] for k in kinds}
    kind_rooms: dict[int, dict] = {i: {} for i in range(len(rooms))}
    n_rooms = len(rooms)
    for kind in pool:
        dmin = DEPTH_MIN.get(kind, 0.0)
        # allowed rooms for this kind (depth gradient), area-weighted
        allowed = [i for i in range(n_rooms)
                   if i / max(1, n_rooms - 1) >= dmin and areas[i] > 0]
        aw = [areas[i] for i in allowed]
        sep_scale = 1.0
        placed_this = False
        for _attempt in range(600):
            if _attempt and _attempt % 150 == 0:
                sep_scale *= 0.75            # NEVER drop an enemy: relax
                #                              separation instead (move,
                #                              don't thin — director)
            ri = rng.choices(allowed, weights=aw)[0]
            if kind_rooms[ri].get(kind, 0) >= ROOM_CAP.get(kind, 99):
                continue
            vs = rooms[ri]["verts"]
            xs = [v[0] for v in vs]
            ys = [v[1] for v in vs]
            x = rng.uniform(min(xs), max(xs))
            y = rng.uniform(min(ys), max(ys))
            if not point_in_poly(x, y, vs):
                continue
            if dist_to_edges(x, y, vs) < margin:
                continue
            if ri == player_room or \
                    math.hypot(x - ppos[0], y - ppos[1]) < SAFE_ROOM_RADIUS:
                continue
            if any(math.hypot(x - qx, y - qy) < min_sep * sep_scale
                   for qx, qy in placed_pts[ri]):
                continue
            ksep = min_sep * KIND_SEP_MULT.get(kind, 1.0) * sep_scale
            if any(math.hypot(x - qx, y - qy) < ksep
                   for qx, qy in kind_pts[kind]):
                continue                     # same heavies never pack
            rooms[ri]["entities"].append(dict(type=kind, pos=[x, y]))
            placed_pts[ri].append((x, y))
            kind_pts[kind].append((x, y))
            kind_rooms[ri][kind] = kind_rooms[ri].get(kind, 0) + 1
            placed += 1
            placed_this = True
            break
        if not placed_this:
            fails += 1

    src["alert_hops"] = 1     # dense population: fights stay LOCAL or
    #   the whole level chain-alerts into one endless convergence (and
    #   calibration loses distinct-encounter structure)
    src["name"] = "GAUNTLET II — DENSE CALIBRATION"
    return src, placed, fails, counts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=180)
    ap.add_argument("--min-sep", type=float, default=60.0)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--out", type=Path,
                    default=ROOT / "levels/gauntlet_cal2.json")
    a = ap.parse_args()
    lv, placed, fails, counts = build(a.n, a.min_sep, a.seed)
    a.out.write_text(json.dumps(lv))
    print(f"placed {placed}/{a.n} (fails {fails}) min_sep {a.min_sep} "
          f"-> {a.out}")
    print("mix:", counts)


if __name__ == "__main__":
    main()
