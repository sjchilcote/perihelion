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
    # middle piece = 90 | 170 | 90 so the alcove portal is 170<->170
    # (rigid — no scaled seams anywhere authored)
    m0 = x0 + seg_len
    b1 = b.rect(m0, y, 90, LANE_W,
                seed=LEVEL_SEED + 7010 + idx, kind="corridor")
    b2 = b.rect(m0 + 90, y, ALCOVE, LANE_W,
                seed=LEVEL_SEED + 7011 + idx, kind="corridor")
    b3 = b.rect(m0 + 90 + ALCOVE, y, seg_len - 90 - ALCOVE, LANE_W,
                seed=LEVEL_SEED + 7012 + idx, kind="corridor")
    Cc = b.rect(x0 + 2 * seg_len, y, seg_len, LANE_W,
                seed=LEVEL_SEED + 7020 + idx, kind="corridor")
    b.connect(A, E_EDGE, b1, W_EDGE)
    b.connect(b1, E_EDGE, b2, W_EDGE)
    b.connect(b2, E_EDGE, b3, W_EDGE)
    b.connect(b3, E_EDGE, Cc, W_EDGE)
    Bm = b2
    ax = m0 + 90
    alc = b.rect(ax, y - ALCOVE, ALCOVE, ALCOVE,
                 seed=LEVEL_SEED + 7100 + idx, kind="storage")
    b.connect(b2, 3, alc, 1)      # north edge 170 <-> alcove south 170
    seg = seg_len
    bmx = ax + ALCOVE / 2
    # NO sentries in the lane pieces (director 2026-07-16: "there needs
    # to be, like, 5x as much material between the safe rooms" -- with a
    # gun in every lane room, kiting-to-turrets was optimal everywhere.
    # The safe strongpoints per segment are the ALCOVE and the CHOKE
    # pair only; the lane itself is open ground you fight across).
    b.entity(A, "medkit", (x0 + seg * 0.3, y + LANE_W * 0.5))
    b.entity(Bm, "medkit", (bmx, y + LANE_W * 0.5))
    b.entity(Cc, "medkit", (x0 + 2 * seg + seg * 0.7, y + LANE_W * 0.5))
    b.entity(Bm, "ammo_9mm", (bmx - 30, y + LANE_W * 0.3))
    b.entity(Bm, "ammo_shell", (bmx + 30, y + LANE_W * 0.7))
    b.entity(Bm, "ammo_cell", (bmx, y + LANE_W * 0.65))
    # the alcove is the segment's ONE strong lure pocket now that the
    # lane pieces are gunless -- rare but genuinely strong (director:
    # kite-to-turrets stays a valid strat, just not free everywhere)
    b.entity(alc, "sentry", (ax + ALCOVE * 0.3, y - ALCOVE * 0.65))
    b.entity(alc, "sentry", (ax + ALCOVE * 0.7, y - ALCOVE * 0.65))
    b.entity(alc, "sentry", (ax + ALCOVE * 0.5, y - ALCOVE * 0.8))
    b.entity(alc, "medkit", (ax + ALCOVE * 0.5, y - ALCOVE * 0.35))
    b.entity(alc, "ammo_9mm", (ax + ALCOVE * 0.25, y - ALCOVE * 0.4))
    b.entity(alc, "ammo_shell", (ax + ALCOVE * 0.75, y - ALCOVE * 0.4))
    b.entity(alc, "ammo_cell", (ax + ALCOVE * 0.5, y - ALCOVE * 0.5))
    b.connect(Cc, S_EDGE, A, S_EDGE)      # the fold: 350<->350, rigid
    for r, rx in ((A, x0 + seg_len * 0.5), (b2, bmx),
                  (Cc, x0 + 2 * seg_len + seg_len * 0.5)):
        b.light(r, (rx, y + LANE_W / 2),
                color=(170, 185, 210), intensity=0.8, radius=240.0)
    b.light(alc, (ax + ALCOVE / 2, y - ALCOVE / 2),
            color=(120, 220, 150), intensity=1.0, radius=200.0)
    return dict(west_room=A, east_room=Cc, alc=alc,
                pieces=(A, b1, b2, b3, Cc))


def trapezoid(b: LevelBuilder, x0: float, yc: float, length: float,
              w_in: float, w_out: float, seed: int,
              kind: str = "corridor") -> tuple[int, int, int]:
    """Convex taper: west edge w_in, east edge w_out; the width change
    happens in the WALLS, both portals stay rigid (equal edge lengths).
    Returns (room, west_edge_idx, east_edge_idx)."""
    x1 = x0 + length
    verts = [(x0, yc - w_in / 2), (x0, yc + w_in / 2),
             (x1, yc + w_out / 2), (x1, yc - w_out / 2)]
    r = b.room(verts, detail_seed=seed, kind=kind)
    return r, 0, 2


def hourglass(b: LevelBuilder, x0: float, yc: float, length: float,
              w_in: float, w_out: float, waist: float, seed: int,
              kind: str = "corridor") -> tuple[int, int, int]:
    """Engine rooms are CONVEX: the pinch is TWO trapezoids whose shared
    portal IS the waist (waist<->waist, rigid). The choke is literally
    the doorway. Returns (west room used only for entry bookkeeping is
    not needed) -> (in_room, west_edge, out_room|east_edge packing):
    returns (in_room, in_west_edge, out_room, out_east_edge)."""
    half = length / 2
    r1, w1, e1 = trapezoid(b, x0, yc, half, w_in, waist, seed, kind)
    r2, w2, e2 = trapezoid(b, x0 + half, yc, half, waist, w_out,
                           seed + 1, kind)
    b.connect(r1, e1, r2, w2)
    return r1, w1, r2, e2


def choke(b: LevelBuilder, idx: int, w_in: float, w_out: float) -> tuple:
    yc = BAND_Y + idx * BAND_SPACING + LANE_W / 2
    x0 = idx * 4000.0 + LANE_LEN + 250.0
    r1, we, r2, ee = hourglass(b, x0, yc, CHOKE_LEN * 2, w_in, w_out,
                               CHOKE_W, LEVEL_SEED + 7200 + idx * 2)
    b.light(r1, (x0 + CHOKE_LEN * 0.5, yc),
            color=(210, 160, 130), intensity=0.9, radius=150.0)
    b.light(r2, (x0 + CHOKE_LEN * 1.5, yc),
            color=(210, 160, 130), intensity=0.9, radius=150.0)
    b.entity(r1, "sentry", (x0 + CHOKE_LEN * 0.45, yc - 14))
    b.entity(r1, "sentry", (x0 + CHOKE_LEN * 0.45, yc + 14))
    b.entity(r2, "sentry", (x0 + CHOKE_LEN * 1.55, yc))
    b.entity(r1, "medkit", (x0 + CHOKE_LEN * 0.3, yc))
    return r1, we, r2, ee


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
    # (tried pushing wardens to the back third, 2026-07-16: pass rate
    # went 6/20 -> 0/20 -- concentrating the heavies is strictly worse
    # than the Gauntlet-II spread; keep DEPTH_MIN as measured)
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


def _edge_len_of(b: LevelBuilder, room: int, edge: int) -> float:
    vs = b.data["rooms"][room]["verts"]
    import math as _m
    x1, y1 = vs[edge % len(vs)]
    x2, y2 = vs[(edge + 1) % len(vs)]
    return _m.hypot(x2 - x1, y2 - y1)


def _rigidify(level: dict) -> int:
    """Force EVERY portal rigid (equal edge lengths -> pure isometry m9;
    director: 'get rid of all the scaling transforms'). The lane/choke/
    adapter chain is authored rigid; the residual mismatches live INSIDE
    the copied source arenas. Fix: stretch the shorter edge symmetrically
    about its midpoint to the longer length — only on a side whose
    neighboring edges carry no portal (so no other seam changes), and
    only if the room stays convex. Returns seams fixed; raises if any
    seam is left scaled."""
    rooms = level["rooms"]
    conns = level["connects"] + level.get("connects_x", [])

    def edge_vec(r, e):
        vs = rooms[r]["verts"]
        (x1, y1), (x2, y2) = vs[e], vs[(e + 1) % len(vs)]
        return x1, y1, x2, y2, math.hypot(x2 - x1, y2 - y1)

    portal_edges = set()
    for r1, e1, r2, e2 in conns:
        portal_edges.add((r1, e1))
        portal_edges.add((r2, e2))

    def convex(vs):
        n = len(vs)
        sign = 0.0
        for i in range(n):
            ax, ay = vs[i]
            bx, by = vs[(i + 1) % n]
            cx, cy = vs[(i + 2) % n]
            cr = (bx - ax) * (cy - by) - (by - ay) * (cx - bx)
            if abs(cr) < 1e-9:
                continue
            if sign == 0.0:
                sign = cr
            elif sign * cr < 0:
                return False
        return True

    def try_stretch(r, e, target):
        """Re-length edge e of room r to `target` by moving only
        endpoints whose OTHER edge is not a portal: symmetric when both
        neighbors are free, else slide the single free endpoint."""
        vs = rooms[r]["verts"]
        n = len(vs)
        start_free = (r, (e - 1) % n) not in portal_edges
        end_free = (r, (e + 1) % n) not in portal_edges
        if not (start_free or end_free):
            return False
        x1, y1, x2, y2, ln = edge_vec(r, e)
        ux, uy = (x2 - x1) / ln, (y2 - y1) / ln
        new = [list(v) for v in vs]
        if start_free and end_free:
            mx, my = (x1 + x2) / 2, (y1 + y2) / 2
            new[e] = [mx - ux * target / 2, my - uy * target / 2]
            new[(e + 1) % n] = [mx + ux * target / 2,
                                my + uy * target / 2]
        elif start_free:      # slide the start vertex away from the end
            new[e] = [x2 - ux * target, y2 - uy * target]
        else:                 # slide the end vertex away from the start
            new[(e + 1) % n] = [x1 + ux * target, y1 + uy * target]
        if not convex(new):
            return False
        rooms[r]["verts"] = new
        return True

    fixed = 0
    for r1, e1, r2, e2 in conns:
        l1 = edge_vec(r1, e1)[4]
        l2 = edge_vec(r2, e2)[4]
        if abs(l2 / l1 - 1.0) <= 0.005:
            continue
        (rs, es), tgt = ((r1, e1), l2) if l1 < l2 else ((r2, e2), l1)
        (rl, el) = (r2, e2) if l1 < l2 else (r1, e1)
        if try_stretch(rs, es, tgt) or \
                try_stretch(rl, el, min(l1, l2)):
            fixed += 1
        else:
            raise ValueError(
                f"cannot rigidify seam {r1}:{e1}<->{r2}:{e2} "
                f"({l1:.1f} vs {l2:.1f}) without touching another portal")
    for r1, e1, r2, e2 in conns:
        l1 = edge_vec(r1, e1)[4]
        l2 = edge_vec(r2, e2)[4]
        if abs(l2 / l1 - 1.0) > 0.005:
            raise ValueError(f"seam still scaled: {r1}:{e1}<->{r2}:{e2}")
    return fixed


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
    lane_rooms = set()
    for i, seg in enumerate(SEGMENTS):
        ln = lane_with_alcove(b, i)
        lane_rooms.update(ln.get("pieces", ()))
        protected.add(ln["alc"])
        b.connect(prev_room, prev_edge, ln["west_room"], W_EDGE)
        # arena first: the choke's east portal must MATCH the arena's
        # entry edge length exactly (rigid m9 — no scaling transforms)
        BG.TEXTURE_MAP.clear()
        info = add_segment(b, seg, (i + 1) * 20000.0, 0.0,
                           keep=set(), seg_idx=i)
        for nr, sv in BG.TEXTURE_MAP.items():
            texture_map[str(nr)] = sv
        entry_len = _edge_len_of(b, info["entry"][0], info["entry"][1])
        ck1, ck_w, ck2, ck_e = choke(b, i, LANE_W, entry_len)
        protected.add(ck1)
        protected.add(ck2)
        b.connect(ln["east_room"], E_EDGE, ck1, ck_w)
        b.connect(ck2, ck_e, info["entry"][0], info["entry"][1])
        # adapter after the arena: exit edge length -> LANE_W, rigid
        exit_len = _edge_len_of(b, info["exit"][0], info["exit"][1])
        yc = BAND_Y + i * BAND_SPACING + LANE_W / 2
        ad, ad_w, ad_e = trapezoid(
            b, i * 4000.0 + LANE_LEN + 900.0, yc, 160.0, exit_len,
            LANE_W, LEVEL_SEED + 7300 + i)
        protected.add(ad)
        b.connect(info["exit"][0], info["exit"][1], ad, ad_w)
        prev_room, prev_edge = ad, ad_e

    out = b.rect(30 * 4000.0, BAND_Y, 260, LANE_W,
                 seed=LEVEL_SEED + 8999, kind="storage")
    b.connect(prev_room, prev_edge, out, W_EDGE)
    b.exit(out, (30 * 4000.0 + 130, BAND_Y + LANE_W / 2))
    b.light(out, (30 * 4000.0 + 130, BAND_Y + LANE_W / 2),
            color=(150, 200, 160), intensity=1.0, radius=220.0)
    protected.add(out)

    b.build()                   # validates winding/schema/spawn/exit
    level = b.to_dict()
    level["alert_hops"] = 1
    level["texture_map"] = texture_map
    n_rigid = _rigidify(level)
    print(f"rigidified {n_rigid} residual scaled seams "
          f"(all portals now pure isometries)")
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
