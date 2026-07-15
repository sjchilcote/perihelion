"""build_gauntlet3 — GAUNTLET III: tactical geometry, HP 100.

Director 2026-07-16: buff the player with GEOMETRY, not hit points —
"chokes and environmental hazards (safe-room turrets) to lure enemies
to, long open corridors to kite them through mowing them down,
non-euclidean double-backs the player can use to escape". Target 50%
bot pass at HP 100, no armor.

Chain per combat segment (six source arenas keep their rooms):

  ... -> KITE LANE (long+open: backpedal and mow; SENTRY ALCOVE with 2
  friendly sentries + ammo + medkit hangs off mid-lane as a lure/fallback;
  a NON-EUCLIDEAN DOUBLE-BACK portals the lane's far end to its start —
  flee "forward" and come out behind the chase) -> CHOKE (narrow
  antechamber funneling the arena spill) -> ARENA -> next lane ... -> EXIT

Population = the Gauntlet II spread discipline (all 7 kinds, depth
gradient, kind anti-packing, min separation) over ARENAS + LANES only;
chokes/alcoves/spawn stay clear. alert_hops=1. Texture provenance
carried directly from the segment copies.

    uv run python tools/musiccal/build_gauntlet3.py --n 180 --min-sep 90
"""
from __future__ import annotations

import argparse
import json
import math
import random
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))
sys.path.insert(0, str(Path(__file__).parent))

from perihelion.levels import LevelBuilder             # noqa: E402
import build_gauntlet as BG                            # noqa: E402
from build_gauntlet import SEGMENTS, add_segment, LEVEL_SEED  # noqa: E402
from build_gauntlet2 import (MIX, DEPTH_MIN, KIND_SEP_MULT,   # noqa: E402
                             ROOM_CAP, poly_area, point_in_poly,
                             dist_to_edges)

LANE_LEN = 1050.0
LANE_W = 150.0
CHOKE_LEN = 120.0
CHOKE_W = 64.0
ALCOVE = 170.0
BAND_Y = 60000.0
BAND_SPACING = 3000.0
W_EDGE, E_EDGE = 0, 2      # rect edge indices (see add_corridor)


S_EDGE = 1                 # rect edge order: W, S, E, N (y-down)


def lane_with_alcove(b: LevelBuilder, idx: int) -> dict:
    """Three-piece kite lane A-B-C; alcove north of B; the impossible
    loop folds C's south edge onto A's south edge (flee forward, come
    out behind the chase)."""
    y = BAND_Y + idx * BAND_SPACING
    x0 = idx * 4000.0
    seg_len = LANE_LEN / 3
    A = b.rect(x0, y, seg_len, LANE_W,
               seed=LEVEL_SEED + 7000 + idx, kind="corridor")
    Bm = b.rect(x0 + seg_len, y, seg_len, LANE_W,
                seed=LEVEL_SEED + 7010 + idx, kind="corridor")
    Cc = b.rect(x0 + 2 * seg_len, y, seg_len, LANE_W,
                seed=LEVEL_SEED + 7020 + idx, kind="corridor")
    b.connect(A, E_EDGE, Bm, W_EDGE)
    b.connect(Bm, E_EDGE, Cc, W_EDGE)
    ax = x0 + seg_len + (seg_len - ALCOVE) / 2
    alc = b.rect(ax, y - ALCOVE, ALCOVE, ALCOVE,
                 seed=LEVEL_SEED + 7100 + idx, kind="storage")
    b.connect_pts(Bm, (ax + ALCOVE / 2, y), alc, (ax + ALCOVE / 2, y))
    seg = seg_len
    b.entity(A, "sentry", (x0 + seg * 0.5, y + 18))
    b.entity(Bm, "sentry", (x0 + seg * 1.5, y + 18))
    b.entity(Cc, "sentry", (x0 + 2 * seg + seg * 0.5, y + 18))
    b.entity(A, "medkit", (x0 + seg * 0.3, y + LANE_W * 0.5))
    b.entity(Bm, "medkit", (x0 + seg * 1.5, y + LANE_W * 0.5))
    b.entity(Cc, "medkit", (x0 + 2 * seg + seg * 0.7, y + LANE_W * 0.5))
    b.entity(Bm, "ammo_9mm", (x0 + seg * 1.5, y + LANE_W * 0.3))
    b.entity(Bm, "ammo_shell", (x0 + seg * 1.5, y + LANE_W * 0.7))
    b.entity(Bm, "ammo_cell", (x0 + seg * 1.4, y + LANE_W * 0.5))
    b.entity(alc, "sentry", (ax + ALCOVE * 0.5, y - ALCOVE * 0.65))
    b.entity(alc, "medkit", (ax + ALCOVE * 0.5, y - ALCOVE * 0.35))
    b.entity(alc, "ammo_9mm", (ax + ALCOVE * 0.25, y - ALCOVE * 0.4))
    b.entity(alc, "ammo_shell", (ax + ALCOVE * 0.75, y - ALCOVE * 0.4))
    b.entity(alc, "ammo_cell", (ax + ALCOVE * 0.5, y - ALCOVE * 0.5))
    b.connect(Cc, S_EDGE, A, S_EDGE)      # the non-Euclidean fold
    for r, fx in ((A, 0.5), (Bm, 0.5), (Cc, 0.5)):
        rx = {A: x0, Bm: x0 + seg_len, Cc: x0 + 2 * seg_len}[r]
        b.light(r, (rx + seg_len * fx, y + LANE_W / 2),
                color=(170, 185, 210), intensity=0.8, radius=240.0)
    b.light(alc, (ax + ALCOVE / 2, y - ALCOVE / 2),
            color=(120, 220, 150), intensity=1.0, radius=200.0)
    return dict(west_room=A, east_room=Cc, alc=alc, pieces=(A, Bm, Cc))


def choke(b: LevelBuilder, idx: int) -> int:
    y = BAND_Y + idx * BAND_SPACING + (LANE_W - CHOKE_W) / 2
    x0 = idx * 4000.0 + LANE_LEN + 250.0
    r = b.rect(x0, y, CHOKE_LEN, CHOKE_W,
               seed=LEVEL_SEED + 7200 + idx, kind="corridor")
    b.light(r, (x0 + CHOKE_LEN / 2, y + CHOKE_W / 2),
            color=(210, 160, 130), intensity=0.9, radius=150.0)
    b.entity(r, "sentry", (x0 + CHOKE_LEN * 0.2, y + CHOKE_W * 0.3))
    b.entity(r, "sentry", (x0 + CHOKE_LEN * 0.2, y + CHOKE_W * 0.7))
    b.entity(r, "sentry", (x0 + CHOKE_LEN * 0.8, y + CHOKE_W * 0.5))
    b.entity(r, "medkit", (x0 + CHOKE_LEN * 0.7, y + CHOKE_W * 0.5))
    return r


def populate(level: dict, spawn_free: set, n_total: int, min_sep: float,
             seed: int, margin: float = 22.0, boost: set | None = None,
             room_total_cap: int = 6):
    """Gauntlet II spread discipline + anti-clump: hard per-room total
    cap pushes the population OUT of the big arenas and into the lane
    stream (director's lever: spread more, never thin); lane rooms get
    a placement weight boost."""
    rng = random.Random(seed)
    rooms = level["rooms"]
    n_rooms = len(rooms)
    areas = [poly_area(r["verts"]) if i not in spawn_free else 0.0
             for i, r in enumerate(rooms)]
    if boost:
        for i in boost:
            areas[i] *= 0.25   # lanes are the PLAYER'S tool: a trickle
            #                    only — packed lanes defeat kiting
    room_totals = [0] * n_rooms
    counts = {k: int(n_total * f) for k, f in MIX.items()}
    while sum(counts.values()) < n_total:
        k = max(MIX, key=lambda q: n_total * MIX[q] - counts[q])
        counts[k] += 1
    pool = [k for k, c in counts.items() for _ in range(c)]
    rng.shuffle(pool)
    placed_pts = {i: [] for i in range(n_rooms)}
    kind_pts = {k: [] for k in MIX}
    kind_rooms = {i: {} for i in range(n_rooms)}
    placed = fails = 0
    for kind in pool:
        dmin = DEPTH_MIN.get(kind, 0.0)
        allowed = [i for i in range(n_rooms)
                   if areas[i] > 0 and i / max(1, n_rooms - 1) >= dmin]
        if not allowed:
            allowed = [i for i in range(n_rooms) if areas[i] > 0]
        aw = [areas[i] for i in allowed]
        sep_scale = 1.0
        ok = False
        for att in range(600):
            if att and att % 150 == 0:
                sep_scale *= 0.75          # relax, never drop (move,
                #                            don't thin — director)
            ri = rng.choices(allowed, weights=aw)[0]
            if room_totals[ri] >= room_total_cap:
                continue
            if kind_rooms[ri].get(kind, 0) >= ROOM_CAP.get(kind, 99):
                continue
            vs = rooms[ri]["verts"]
            xs = [v[0] for v in vs]
            ys = [v[1] for v in vs]
            x = rng.uniform(min(xs), max(xs))
            yy = rng.uniform(min(ys), max(ys))
            if not point_in_poly(x, yy, vs):
                continue
            if dist_to_edges(x, yy, vs) < margin:
                continue
            if any(math.hypot(x - qx, yy - qy) < min_sep * sep_scale
                   for qx, qy in placed_pts[ri]):
                continue
            ksep = min_sep * KIND_SEP_MULT.get(kind, 1.0) * sep_scale
            if any(math.hypot(x - qx, yy - qy) < ksep
                   for qx, qy in kind_pts[kind]):
                continue
            rooms[ri]["entities"].append(dict(type=kind, pos=[x, yy]))
            placed_pts[ri].append((x, yy))
            kind_pts[kind].append((x, yy))
            kind_rooms[ri][kind] = kind_rooms[ri].get(kind, 0) + 1
            room_totals[ri] += 1
            placed += 1
            ok = True
            break
        if not ok:
            fails += 1
    return placed, fails, counts


def build(n_total: int, min_sep: float, seed: int):
    b = LevelBuilder("GAUNTLET III — TACTICAL CALIBRATION", tier=3,
                     ambience="amb_drone_late")
    texture_map = {}
    protected = set()          # rooms that stay enemy-free

    spawn = b.rect(-600, BAND_Y, 220, LANE_W,
                   seed=LEVEL_SEED + 7999, kind="storage")
    b.player(spawn, (-490, BAND_Y + LANE_W / 2))
    b.light(spawn, (-490, BAND_Y + LANE_W / 2),
            color=(150, 170, 200), intensity=1.0, radius=220.0)
    protected.add(spawn)

    prev_room, prev_edge = spawn, E_EDGE
    last_exit = None
    lane_rooms = set()
    for i, seg in enumerate(SEGMENTS):
        ln = lane_with_alcove(b, i)
        lane_rooms.update(ln.get("pieces", ()))
        protected.add(ln["alc"])
        b.connect(prev_room, prev_edge, ln["west_room"], W_EDGE)
        ck = choke(b, i)
        protected.add(ck)
        b.connect(ln["east_room"], E_EDGE, ck, W_EDGE)
        BG.TEXTURE_MAP.clear()
        info = add_segment(b, seg, (i + 1) * 20000.0, 0.0,
                           keep=set(), seg_idx=i)
        for nr, sv in BG.TEXTURE_MAP.items():
            texture_map[str(nr)] = sv
        b.connect(ck, E_EDGE, info["entry"][0], info["entry"][1])
        prev_room, prev_edge = info["exit"]
        last_exit = info["exit"]

    out = b.rect(30 * 4000.0, BAND_Y, 260, LANE_W,
                 seed=LEVEL_SEED + 8999, kind="storage")
    b.connect(last_exit[0], last_exit[1], out, W_EDGE)
    b.exit(out, (30 * 4000.0 + 130, BAND_Y + LANE_W / 2))
    b.light(out, (30 * 4000.0 + 130, BAND_Y + LANE_W / 2),
            color=(150, 200, 160), intensity=1.0, radius=220.0)
    protected.add(out)

    b.build()                   # validates winding/schema/spawn/exit
    level = b.to_dict()
    level["alert_hops"] = 1
    level["texture_map"] = texture_map
    placed, fails, counts = populate(level, protected, n_total, min_sep,
                                     seed, boost=lane_rooms)
    return level, placed, fails, counts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=180)
    ap.add_argument("--min-sep", type=float, default=90.0)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--out", type=Path,
                    default=ROOT / "levels/gauntlet_cal3.json")
    a = ap.parse_args()
    level, placed, fails, counts = build(a.n, a.min_sep, a.seed)
    a.out.write_text(json.dumps(level))
    print(f"placed {placed}/{a.n} (fails {fails}) -> {a.out}")
    print("mix:", counts)


if __name__ == "__main__":
    main()
