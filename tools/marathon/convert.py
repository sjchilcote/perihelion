"""Marathon level -> PERIHELION level JSON.

The two formats are the same shape: Marathon's polygon mesh (convex <=8-vert
polygons, lines shared by exactly two polygons) IS our polygon graph (convex
polygons, portals on shared edges). Conversion is therefore mostly bookkeeping:

- polygon -> polygon, vertices scaled by SCALE (80 u per WU, see stats.py) and
  REVERSED (Marathon winds positive-shoelace in y-down screen coords; our
  engine requires negative / visually-CCW).
- walkable shared line (two owner polygons, not SOLID) -> connect, authored
  as `connect_pts` (edge midpoints), which survives LevelBuilder.resolve()'s
  doorway-splitting pass unchanged since exactly-shared edges never split.
- SOLID shared line (thin double-sided wall) -> `no_connect`, else the
  builder's autoconnect would helpfully open a doorway through it.
- plan-overlapping but unconnected polygons (Marathon "5D space", which
  Arrival's east maze uses heavily) -> also `no_connect` defensively for any
  edge-coincident pair; the engine does not care that polygons overlap on the
  authoring canvas.
- floor/ceiling heights don't exist here; they're preserved per polygon under a
  "marathon" key (ignored by the loader) and folded into the kind heuristic
  (platform polys = Marathon doors -> corridor kind).

Demo dressing (--demo, default): player at the map's player-start object,
exit in the farthest big polygon by portal BFS, a light sprinkle of husks/
mites/pickups scaled to hop distance. This is a geometry study, not a tuned
encounter.

Usage:
    uv run python tools/marathon/convert.py                 # Arrival ->
        levels/marathon_arrival.json
    uv run python tools/marathon/convert.py m1 3 out.json   # any level
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(REPO / "game"))

from mapread import GAMES, WU, MapFile, MarathonLevel  # noqa: E402
from perihelion.levels import LevelBuilder, save_level  # noqa: E402

SCALE = 80.0 / WU  # 1 WU -> 80 u (median M1 door -> our 80 u doorway)


def _polygon_kind(lvl: MarathonLevel, pi: int) -> str:
    p = lvl.polygons[pi]
    area_wu2 = lvl.poly_area(pi) / (WU * WU)
    deg = lvl.poly_degree(pi)
    if p.type == 5:  # platform: Marathon's doors/lifts are polygons
        return "corridor"
    if area_wu2 >= 10.0:
        return "dock"        # hangar-scale chamber
    if deg >= 5 and area_wu2 >= 4.0:
        return "core"        # radial hub (Arrival's rotunda)
    if area_wu2 <= 1.7:
        return "transit" if deg >= 3 else "corridor"
    return "generic"


def _bfs_hops(lvl: MarathonLevel, start: int) -> dict[int, int]:
    hops = {start: 0}
    frontier = [start]
    while frontier:
        nxt = []
        for pi in frontier:
            for li in lvl.polygons[pi].lines:
                ln = lvl.lines[li]
                if not ln.is_portal:
                    continue
                other = ln.cw_poly if ln.ccw_poly == pi else ln.ccw_poly
                if other not in hops:
                    hops[other] = hops[pi] + 1
                    nxt.append(other)
        frontier = nxt
    return hops


def _coincident_unconnected_pairs(lvl: MarathonLevel) -> set[tuple[int, int]]:
    """Polygon pairs that share (or nearly share, within the builder's 0.5 u
    tolerance at our scale) an anti-parallel collinear edge without being
    Marathon-adjacent — thin solid walls and 5D flush contacts. These must
    be no_connect'ed or resolve() would auto-open doorways through them."""
    tol = 0.5 / SCALE  # builder tol in internal units
    adjacent = {tuple(sorted(ln.polys)) for ln in lvl.lines
                if len(ln.polys) == 2}
    edges = []  # (poly, p0, p1)
    for pi, p in enumerate(lvl.polygons):
        vs = lvl.poly_verts(pi)
        for k in range(len(vs)):
            edges.append((pi, vs[k], vs[(k + 1) % len(vs)]))
    out: set[tuple[int, int]] = set()
    for i in range(len(edges)):
        pi, a0, a1 = edges[i]
        ax, ay = a1[0] - a0[0], a1[1] - a0[1]
        alen = math.hypot(ax, ay)
        if alen < tol:
            continue
        ux, uy = ax / alen, ay / alen
        for j in range(len(edges)):
            pj, b0, b1 = edges[j]
            if pj <= pi or tuple(sorted((pi, pj))) in adjacent:
                continue
            bx, by = b1[0] - b0[0], b1[1] - b0[1]
            if bx * ux + by * uy >= 0:  # need opposite-ish direction
                continue
            d0 = abs((b0[0] - a0[0]) * uy - (b0[1] - a0[1]) * ux)
            d1 = abs((b1[0] - a0[0]) * uy - (b1[1] - a0[1]) * ux)
            if d0 > tol or d1 > tol:
                continue
            t0 = (b0[0] - a0[0]) * ux + (b0[1] - a0[1]) * uy
            t1 = (b1[0] - a0[0]) * ux + (b1[1] - a0[1]) * uy
            lo, hi = min(t0, t1), max(t0, t1)
            if hi < -tol or lo > alen + tol:
                continue  # collinear but disjoint spans
            out.add(tuple(sorted((pi, pj))))
    return out


def convert(game: str, index: int, name: str | None = None,
            demo: bool = True, seed: int = 5) -> dict:
    mf = MapFile(GAMES[game])
    lvl = mf.level(index)
    b = LevelBuilder(name or f"{lvl.name} (M{game[-1] if game != 'm1' else '1'})",
                     tier=1, ambience="amb_drone_early")

    # polygons ---------------------------------------------------------------
    for pi in range(len(lvl.polygons)):
        verts = [(x * SCALE, y * SCALE) for x, y in lvl.poly_verts(pi)]
        verts.reverse()  # positive -> negative shoelace (engine canonical)
        ri = b.polygon(verts, detail_seed=pi * 7919 + 13,
                    kind=_polygon_kind(lvl, pi))
        assert ri == pi
        p = lvl.polygons[pi]
        b.data["polygons"][ri]["marathon"] = dict(
            floor=p.floor_height, ceil=p.ceiling_height, type=p.type)

    # portals -> connects (midpoint-addressed; robust through resolve()) ---
    n_portals = 0
    for ln in lvl.lines:
        if not ln.is_portal:
            continue
        (x0, y0), (x1, y1) = lvl.points[ln.e0], lvl.points[ln.e1]
        mid = ((x0 + x1) * 0.5 * SCALE, (y0 + y1) * 0.5 * SCALE)
        a, c = ln.polys
        b.connect_pts(a, mid, c, mid)
        n_portals += 1

    # walls that must stay walls -------------------------------------------
    for ln in lvl.lines:
        if len(ln.polys) == 2 and ln.solid:
            b.no_connect(*ln.polys)
    for pair in _coincident_unconnected_pairs(lvl):
        b.no_connect(*pair)

    # demo dressing ---------------------------------------------------------
    starts = lvl.player_starts()
    if starts and 0 <= starts[0].polygon < len(lvl.polygons):
        start_poly = starts[0].polygon
        start_pos = (starts[0].x * SCALE, starts[0].y * SCALE)
    else:
        start_poly = 0
        start_pos = tuple(
            v * SCALE for v in lvl.poly_centroid(0))
    b.player(start_poly, start_pos)

    hops = _bfs_hops(lvl, start_poly)
    big_far = [pi for pi in hops
               if lvl.poly_area(pi) / (WU * WU) >= 2.0]
    exit_poly = (max(big_far, key=lambda pi: hops[pi]) if big_far
                 else max(hops, key=hops.get))
    b.exit(exit_poly, tuple(v * SCALE for v in lvl.poly_centroid(exit_poly)))

    if demo:
        import random

        rng = random.Random(seed)
        reachable = sorted(pi for pi, h in hops.items() if h >= 2)
        rng.shuffle(reachable)
        n_husks = 22
        n_mites = 8
        for pi in reachable[:n_husks]:
            b.entity(pi, "husk", tuple(v * SCALE for v in lvl.poly_centroid(pi)))
        small = [pi for pi in reachable[n_husks:]
                 if lvl.poly_area(pi) / (WU * WU) <= 1.0]
        for pi in small[:n_mites]:
            b.entity(pi, "mite", tuple(v * SCALE for v in lvl.poly_centroid(pi)))
        for kind, count in (("ammo_9mm", 6), ("medkit", 3), ("ammo_shell", 2)):
            pool = [pi for pi in reachable if 2 <= hops[pi]]
            for pi in rng.sample(pool, count):
                b.entity(pi, kind, tuple(v * SCALE for v in lvl.poly_centroid(pi)))
        b.intro(f"M1 {lvl.name.upper()} - GEOMETRY RECOVERED FROM UESC "
                "MARATHON SURVEY ARCHIVE")

    data = b.resolve()
    # the whole point: every Marathon portal became exactly one connect and
    # nothing else got helpfully autoconnected
    got = len(data["connects"])
    if got != n_portals:
        raise AssertionError(
            f"connect count {got} != Marathon portal count {n_portals}")
    return data


if __name__ == "__main__":
    args = sys.argv[1:]
    game = args[0] if args else "m1"
    index = int(args[1]) if len(args) > 1 else 0
    out = Path(args[2]) if len(args) > 2 else (
        REPO / "levels" / "marathon_arrival.json")
    data = convert(game, index)
    save_level(data, out)
    print(f"{out}: {len(data['polygons'])} polygons, "
          f"{len(data['connects'])} connects")
