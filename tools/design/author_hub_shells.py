#!/usr/bin/env python3
"""Author the marrow hub's 24 chamber shells (marrow visual pass, Sol
consult docs/consults/marrow_visual_20260728).

The director, 2026-07-28: "Remember polygons are just that - individual
polygons. This engine is not constrained to square rooms by any means."

Every chamber was an axis-aligned rectangle. This tool derives a one-off
convex biogenic shell for each, then CHECKS it against the preservation
contract; the checked-in literal in game/perihelion/hub.py is its output,
so the shapes are authored data and this is the reproducible derivation.

Grammar (hard — a shell failing any of these is rejected and re-seeded):
  * convex, 5-9 facets, winding matching the engine's y-down convention
  * every doorway gets its own flat PALATE facet long enough to seat it:
    >=94u for a 70u door (12u of intact wall each side), >=128u for the
    96u breach seam (16u each side)
  * no facet under 22u and no corner under 32 degrees (nothing invisible
    or needle-thin at 0.45 zoom)
  * floor area within 8% of the rectangle it replaces, bounding box
    within +-38% per axis, so the depth-band area distribution holds
  * every organ anchor, resident spawn corner, and light position stays
    inside with 16u of wall clearance

    uv run python tools/design/author_hub_shells.py           # report
    uv run python tools/design/author_hub_shells.py --emit    # literal
"""
from __future__ import annotations

import math
import random
import sys
import zlib

DOOR_W, BREACH_W = 70.0, 96.0
HOST_DOOR, HOST_BREACH = 94.0, 128.0
MIN_EDGE = 22.0
MIN_CORNER_DEG = 32.0
AREA_TOL = 0.08
BBOX_LO, BBOX_HI = 0.72, 1.38
CLEAR = 16.0

# the rectangles being replaced — their areas are the ratified depth-band
# distribution and must survive the reshape
ROOMS = {
    "A1": (220, 180), "A2": (220, 180), "A3": (220, 180),
    "G1": (200, 170), "G2": (200, 170), "G3": (200, 170),
    "T1": (190, 160), "T2": (190, 160), "T3": (190, 160),
    "R": (150, 140),
    "C1": (120, 120), "C2": (120, 120),
    "N1": (140, 120), "N2": (140, 120), "N3": (140, 120), "N4": (140, 120),
    "AN1": (120, 110), "AN2": (120, 110),
    "SC": (130, 120),
    "L": (340, 90),
    "V": (420, 160),
    "S1": (110, 100), "S2": (110, 100), "S3": (110, 100),
}

LINKS = [
    ("A1", "G1"), ("A2", "G2"), ("A3", "G3"),
    ("G1", "T1"), ("G2", "T2"), ("G3", "T3"),
    ("T1", "T2"), ("T2", "T3"), ("T3", "T1"),
    ("C1", "T1"), ("C2", "T3"),
    ("T2", "R"),
    ("R", "N1"), ("N1", "N2"), ("N2", "N3"), ("N3", "N4"),
    ("AN1", "N1"), ("AN2", "N2"), ("SC", "N3"),
    ("N4", "L"), ("L", "V"),
    ("V", "S1"), ("V", "S2"), ("V", "S3"),
]

# role -> (min facets, max facets, min radial irregularity, max)
ROLE = {
    "A": (6, 7, 0.18, 0.24), "G": (6, 8, 0.15, 0.22),
    "T": (7, 9, 0.18, 0.25), "R": (6, 7, 0.15, 0.20),
    "C": (5, 8, 0.16, 0.24), "N": (6, 8, 0.12, 0.20),
    "AN": (5, 8, 0.16, 0.24), "SC": (6, 8, 0.18, 0.24),
    "L": (6, 8, 0.10, 0.16), "V": (8, 10, 0.15, 0.22),
    "S": (5, 8, 0.16, 0.24),
}

# interior points that MUST stay inside the shell with wall clearance, in
# the ENGINE frame (the engine re-centers every polygon on its area
# centroid): organ part offsets (sim._embody_core), the corners of the
# resident spawn box (sim spawns residents in +-35 x +-30), the
# HUB_LIGHT_PLAN light positions, and the blackout reform spawn sites
RESIDENT_BOX = [(-36.0, -31.0), (36.0, -31.0), (-36.0, 31.0), (36.0, 31.0)]
REQUIRED = {
    "S1": [(0, 0)], "S2": [(0, 0)], "S3": [(0, 0)],
    "C1": [(0, -20)], "C2": [(0, -20)],
    "AN1": [(-25, 20), (25, 20)] + RESIDENT_BOX,
    "AN2": [(-25, 20), (25, 20)],
    "SC": [(0, 0)],
    "R": [(18, -18), (0, 0)] + RESIDENT_BOX,
    "N1": [(-30, -25), (30, 25)] + RESIDENT_BOX,
    "N2": [(18, -18), (-30, -25), (30, 25)] + RESIDENT_BOX,
    "N3": [(-30, -25), (30, 25)] + RESIDENT_BOX,
    "N4": [(-30, -25), (30, 25), (-60, 0), (0, 0)] + RESIDENT_BOX,
    "L": [(18, -18), (-120, 0), (120, 0)] + RESIDENT_BOX,
    "V": ([(18, -18), (-120, -40), (-40, -40), (40, -40), (120, -40),
           (-100, 0), (100, 0)] + RESIDENT_BOX),
    "G1": [(0, -20)], "G2": [(0, -20)], "G3": [(0, -20)],
    "A1": [(0, 0)], "A2": [(0, 0)], "A3": [(0, 0)],
    "T1": RESIDENT_BOX, "T2": RESIDENT_BOX, "T3": RESIDENT_BOX,
}


def role_of(name: str) -> str:
    return "".join(c for c in name if not c.isdigit())


def door_needs(name: str) -> list[float]:
    """Host-facet length for every doorway this chamber must seat."""
    needs = [HOST_DOOR] * sum(1 for a, b in LINKS if name in (a, b))
    if name in ("A1", "A2", "A3"):
        needs.append(HOST_BREACH)
    return needs


def shoelace(v) -> float:
    return sum(v[i][0] * v[(i + 1) % len(v)][1]
               - v[(i + 1) % len(v)][0] * v[i][1]
               for i in range(len(v))) / 2.0


def centroid(v):
    a = shoelace(v)
    n = len(v)

    def acc(sel):
        return sum((v[i][sel] + v[(i + 1) % n][sel])
                   * (v[i][0] * v[(i + 1) % n][1] - v[(i + 1) % n][0] * v[i][1])
                   for i in range(n)) / (6 * a)
    return acc(0), acc(1)


def convex(v) -> bool:
    n = len(v)
    sign = None
    for i in range(n):
        ax, ay = v[i]
        bx, by = v[(i + 1) % n]
        cx, cy = v[(i + 2) % n]
        cr = (bx - ax) * (cy - ay) - (by - ay) * (cx - ax)
        if abs(cr) < 1e-9:
            return False
        s = cr > 0
        if sign is None:
            sign = s
        elif s != sign:
            return False
    return True


def _edge_dist(px, py, ax, ay, bx, by) -> float:
    ex, ey = bx - ax, by - ay
    t = max(0.0, min(1.0, ((px - ax) * ex + (py - ay) * ey) / (ex * ex + ey * ey)))
    return math.hypot(px - (ax + ex * t), py - (ay + ey * t))


def inside_with_clearance(v, px, py, clear) -> bool:
    n = len(v)
    sign = None
    for i in range(n):
        ax, ay = v[i]
        bx, by = v[(i + 1) % n]
        cr = (bx - ax) * (py - ay) - (by - ay) * (px - ax)
        s = cr > 0
        if sign is None:
            sign = s
        elif s != sign:
            return False
        if _edge_dist(px, py, ax, ay, bx, by) < clear:
            return False
    return True


def shell(name: str, seed_off: int = 0):
    """One candidate shell, or None if it fails the grammar."""
    w, h = ROOMS[name]
    nlo, nhi, ilo, ihi = ROLE[role_of(name)]
    needs = sorted(door_needs(name), reverse=True)
    rng = random.Random(zlib.crc32(name.encode()) + seed_off * 7919)
    a0, b0 = w / 2.0, h / 2.0
    target_area = w * h

    # two low-order radial harmonics: grown proportions, machined facets
    a1 = rng.uniform(ilo, ihi) * 0.5
    a2 = rng.uniform(ilo, ihi) * 0.35
    p1 = rng.uniform(0, math.tau)
    p2 = rng.uniform(0, math.tau)

    def radius(th):
        e = (a0 * b0) / math.hypot(b0 * math.cos(th), a0 * math.sin(th))
        return e * (1.0 + a1 * math.cos(th + p1) + a2 * math.cos(2 * th + p2))

    # every doorway claims an angular chord wide enough for its palate;
    # filler facets take the arcs between
    k = len(needs)
    n = max(nlo, min(nhi, k + rng.randrange(1, 4)))
    base = rng.uniform(0, math.tau)
    dirs = [base + i * math.tau / k + rng.uniform(-0.25, 0.25) for i in range(k)]
    if name in ("A1", "A2", "A3"):
        # the breach palate faces outward, away from the cathedral
        dirs[0] = -math.pi / 2 + rng.uniform(-0.1, 0.1)

    pts, spans = [], []
    for th, need in zip(dirs, needs):
        half = math.asin(min(0.95, (need * 1.06) / (2 * radius(th))))
        spans.append((th - half, th + half))
        pts += [th - half, th + half]
    nfill = n - 2 * k
    if nfill > 0:
        ss = sorted(spans)
        gaps = []
        for i in range(len(ss)):
            lo = ss[i][1]
            hi = ss[(i + 1) % len(ss)][0] + (math.tau if i == len(ss) - 1 else 0)
            gaps.append((hi - lo, lo, hi))
        gaps.sort(reverse=True)
        for i in range(nfill):
            glen, lo, _hi = gaps[i % len(gaps)]
            pts.append(lo + glen * rng.uniform(0.3, 0.7))

    pts = sorted(th % math.tau for th in pts)
    verts = [(radius(th) * math.cos(th), radius(th) * math.sin(th))
             for th in pts]
    sc = math.sqrt(target_area / abs(shoelace(verts)))
    # quantize HERE, to the precision the literal is emitted at: every
    # check below must measure the vertices that actually ship. (A 22.04u
    # facet passed the minimum and shipped as 21.94.)
    verts = [(round(x * sc, 1), round(y * sc, 1)) for x, y in verts]

    # the engine's winding convention, taken from the rectangle it replaces
    canon = shoelace([(0, 0), (0, h), (w, h), (w, 0)])
    if (shoelace(verts) > 0) != (canon > 0):
        verts = list(reversed(verts))
    if not convex(verts):
        return None

    m = len(verts)
    edges = [math.hypot(verts[(i + 1) % m][0] - verts[i][0],
                        verts[(i + 1) % m][1] - verts[i][1]) for i in range(m)]
    if min(edges) < MIN_EDGE:
        return None
    if abs(abs(shoelace(verts)) - target_area) / target_area > AREA_TOL:
        return None
    xs = [x for x, _ in verts]
    ys = [y for _, y in verts]
    if not (BBOX_LO * w <= max(xs) - min(xs) <= BBOX_HI * w
            and BBOX_LO * h <= max(ys) - min(ys) <= BBOX_HI * h):
        return None
    for i in range(m):
        ax, ay = verts[(i - 1) % m]
        bx, by = verts[i]
        cx, cy = verts[(i + 1) % m]
        v1, v2 = (ax - bx, ay - by), (cx - bx, cy - by)
        l1 = math.hypot(*v1) or 1e-9
        l2 = math.hypot(*v2) or 1e-9
        dot = (v1[0] * v2[0] + v1[1] * v2[1]) / (l1 * l2)
        if math.acos(max(-1.0, min(1.0, dot))) < math.radians(MIN_CORNER_DEG):
            return None

    ccx, ccy = centroid(verts)
    for qx, qy in REQUIRED.get(name, []):
        if not inside_with_clearance(verts, qx + ccx, qy + ccy, CLEAR):
            return None

    # seat each doorway on the longest facet still free
    order = sorted(range(m), key=lambda i: -edges[i])
    seats, used = [], set()
    for need in needs:
        got = next((ei for ei in order if ei not in used and edges[ei] >= need),
                   None)
        if got is None:
            return None
        used.add(got)
        seats.append((need,
                      ((verts[got][0] + verts[(got + 1) % m][0]) / 2 - ccx,
                       (verts[got][1] + verts[(got + 1) % m][1]) / 2 - ccy)))
    return verts, seats


def author_all(tries: int = 20000):
    out = {}
    for name in ROOMS:
        for off in range(tries):
            got = shell(name, off)
            if got is not None:
                out[name] = (got[0], got[1], off)
                break
        else:
            raise SystemExit(f"{name}: no shell satisfied the grammar in "
                             f"{tries} seeds")
    return out


def emit(table) -> str:
    lines = [
        "# the authored shells (marrow visual pass, Sol consult 2026-07-28),",
        "# derived and checked by tools/design/author_hub_shells.py: convex,",
        "# 5-9 facets, every doorway on its own >=94u palate (breach >=128u),",
        "# no facet under 22u or corner under 32 degrees, area within 8% of",
        "# the rectangles these replace, and every organ/resident/light anchor",
        "# inside with 16u of wall clearance. Verts are authored coordinates;",
        "# the engine re-centers each polygon on its area centroid, so the",
        "# seat anchors below are already in that ENGINE frame.",
        "# name: (verts, door_seats, breach_seat_or_None)",
        "CHAMBER_SHELLS = {",
    ]
    for name, (verts, seats, _off) in table.items():
        doors = [p for need, p in seats if need < HOST_BREACH]
        breach = [p for need, p in seats if need >= HOST_BREACH]
        vs = ",\n         ".join(
            ", ".join(f"({x:.1f}, {y:.1f})" for x, y in verts[i:i + 3])
            for i in range(0, len(verts), 3))
        ds = ", ".join(f"({x:.1f}, {y:.1f})" for x, y in doors)
        bs = f"({breach[0][0]:.1f}, {breach[0][1]:.1f})" if breach else "None"
        lines += [f'    "{name}": (',
                  f"        ({vs}),",
                  f"        ({ds}{',' if doors else ''}),",
                  f"        {bs}),"]
    lines.append("}")
    return "\n".join(lines) + "\n"


def main() -> int:
    table = author_all()
    if "--emit" in sys.argv:
        sys.stdout.write(emit(table))
        return 0
    for name, (verts, seats, off) in table.items():
        w, h = ROOMS[name]
        edges = [math.hypot(verts[(i + 1) % len(verts)][0] - verts[i][0],
                            verts[(i + 1) % len(verts)][1] - verts[i][1])
                 for i in range(len(verts))]
        print(f"{name:>3}: {len(verts)}v  seed+{off:<5} "
              f"area {abs(shoelace(verts)):>6.0f}/{w * h:<6} "
              f"facets {min(edges):>5.1f}-{max(edges):<5.1f} "
              f"seats {[round(n) for n, _ in seats]}")
    print(f"\n{len(table)} shells, all within the grammar. "
          f"--emit prints the hub.py literal.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
