"""Measurable level-design standards from the classic Marathon maps.

Per solo level: polygon count, polygon-area distribution, vertex-count
distribution, adjacency degree (walkable portals per polygon), portal
widths, and — the number the director cares about — how many polygons are
*potentially visible* from a sample point: an exact 2-D portal flood
(angular-wedge clipping through walkable/transparent shared edges, depth
<= 15), which is the plan-view analog of the engine's 3-half-plane portal
visibility. Because it walks portals rather than plan geometry, it is
correct in Marathon's overlapping "5D" regions too (each overlap counts as
its own instance, exactly like our engine's DrawInstances).

Scale mapping: 1 Marathon WU = 1024 internal units; the measured median
walkable-portal width across M1 solo levels is exactly 1.00 WU (the
canonical Marathon door). PERIHELION doors/corridors run 70-90 u, so
SCALE_DEFAULT = 80/1024 = 0.078125 u per internal unit: 1 WU -> 80 u,
median Marathon door -> our standard 80 u doorway. (M2 median door is
1.28 WU, Infinity 1.12 WU — M1 is the cleanest reference.)

Usage:
    uv run python tools/marathon/stats.py             # all three games
    uv run python tools/marathon/stats.py m1          # one game
    uv run python tools/marathon/stats.py --ours      # our levels, engine
                                                      # visible() during a
                                                      # 30 s bot walk
"""

from __future__ import annotations

import math
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from mapread import GAMES, WU, MapFile, MarathonLevel  # noqa: E402

SCALE_DEFAULT = 80.0 / WU  # = 0.078125 PERIHELION u per internal unit
FLOOD_DEPTH = 15
FLOOD_CAP = 400          # instance cap per sample (engine uses 96)
NEAR_RANGE = 8 * WU      # "roughly on screen" radius: 8 WU ~= 820 u at 0.1
TWO_PI = 2.0 * math.pi


def _sightline(ln) -> bool:
    """Sight passes a line if it joins two polygons and is walkable
    (not solid) or an explicit window (solid + transparent)."""
    return len(ln.polys) == 2 and (not ln.solid or ln.transparent)


def visible_flood(lvl: MarathonLevel, start: int,
                  max_depth: int = FLOOD_DEPTH,
                  cap: int = FLOOD_CAP) -> tuple[int, int, int]:
    """Exact angular portal flood from the centroid of polygon `start`.

    Returns (instances, unique_polygons, instances_within_NEAR_RANGE).
    An "instance" is one polygon reached via one portal chain — the same
    polygon reached along two chains (5D space) counts twice, matching the
    engine's DrawInstance semantics.
    """
    ox, oy = lvl.poly_centroid(start)
    pts = lvl.points

    def ang(p) -> float:
        return math.atan2(p[1] - oy, p[0] - ox)

    def wedge_of(li) -> tuple[float, float] | None:
        ln = lvl.lines[li]
        a, b = ang(pts[ln.e0]), ang(pts[ln.e1])
        w = (b - a) % TWO_PI
        if w > math.pi:
            a, w = b, TWO_PI - w
        return (a, w) if w > 1e-7 else None

    def intersect(w1, w2):
        a1, s1 = w1
        a2, s2 = w2
        d = (a2 - a1) % TWO_PI
        if d > math.pi:
            d -= TWO_PI
        lo, hi = max(0.0, d), min(s1, d + s2)
        if hi - lo <= 1e-7:
            return None
        return (a1 + lo, hi - lo)

    def near(pi) -> bool:
        return any(math.hypot(x - ox, y - oy) <= NEAR_RANGE
                   for x, y in lvl.poly_verts(pi))

    instances = 0
    near_instances = 0
    uniq: set[int] = set()
    stack: list[tuple[int, int, tuple | None, int]] = [(start, -1, None, 0)]
    while stack and instances < cap:
        pi, in_line, wedge, depth = stack.pop()
        instances += 1
        uniq.add(pi)
        if near(pi):
            near_instances += 1
        if depth >= max_depth:
            continue
        for li in lvl.polygons[pi].lines:
            if li == in_line:
                continue
            ln = lvl.lines[li]
            if not _sightline(ln):
                continue
            w = wedge_of(li)
            if w is None:
                continue
            if wedge is not None:
                w = intersect(wedge, w)
                if w is None:
                    continue
            other = ln.cw_poly if ln.ccw_poly == pi else ln.ccw_poly
            stack.append((other, li, w, depth + 1))
    return instances, len(uniq), near_instances


def _dist(vals, scale=1.0):
    v = sorted(x * scale for x in vals)
    if not v:
        return dict(n=0)
    return dict(
        n=len(v),
        min=v[0],
        p10=v[len(v) // 10],
        med=statistics.median(v),
        p90=v[(9 * len(v)) // 10],
        max=v[-1],
        mean=statistics.fmean(v),
    )


def level_stats(lvl: MarathonLevel, samples: int = 40) -> dict:
    n = len(lvl.polygons)
    areas_wu2 = [lvl.poly_area(i) / (WU * WU) for i in range(n)]
    vcounts = [p.vertex_count for p in lvl.polygons]
    degrees = [lvl.poly_degree(i) for i in range(n)]
    pwidths = []
    for ln in lvl.lines:
        if ln.is_portal:
            (x0, y0), (x1, y1) = lvl.points[ln.e0], lvl.points[ln.e1]
            pwidths.append(math.hypot(x1 - x0, y1 - y0) / WU)

    # deterministic sample of polygons (plus the player-start polygon)
    step = max(1, n // samples)
    sample = sorted({i for i in range(0, n, step)}
                    | {o.polygon for o in lvl.player_starts()
                       if 0 <= o.polygon < n})
    inst, uq, nearby = [], [], []
    for s in sample:
        a, b, c = visible_flood(lvl, s)
        inst.append(a)
        uq.append(b)
        nearby.append(c)

    return dict(
        index=lvl.index,
        name=lvl.name,
        polys=n,
        points=len(lvl.points),
        lines=len(lvl.lines),
        portals=sum(1 for ln in lvl.lines if ln.is_portal),
        area_wu2=_dist(areas_wu2),
        vertex_counts=_dist(vcounts),
        degree=_dist(degrees),
        deg_hist={d: degrees.count(d) for d in sorted(set(degrees))},
        portal_w_wu=_dist(pwidths),
        vis_instances=_dist(inst),
        vis_unique=_dist(uq),
        vis_near=_dist(nearby),
        n_samples=len(sample),
    )


def _fmt(d, nd=1):
    if d.get("n", 0) == 0:
        return "-"
    return f"{d['med']:.{nd}f}/{d['p90']:.{nd}f}/{d['max']:.{nd}f}"


def report_game(key: str) -> list[dict]:
    mf = MapFile(GAMES[key])
    solo = mf.solo_indices()
    print(f"\n=== {key}: {mf.path.name}  wad v{mf.header.version}  "
          f"{len(mf.directory)} levels ({len(solo)} solo) ===")
    print(f"{'lvl':>3} {'name':32s} {'poly':>4} {'portal':>6} "
          f"{'area med/p90/max':>17} {'deg':>11} {'doorWU':>6} "
          f"{'vis med/p90/max':>16} {'near':>9}")
    rows = []
    for i in solo:
        lvl = mf.level(i)
        st = level_stats(lvl)
        rows.append(st)
        print(f"{i:3d} {st['name'][:32]:32s} {st['polys']:4d} "
              f"{st['portals']:6d} "
              f"{st['area_wu2']['med']:5.2f}/{st['area_wu2']['p90']:5.2f}/"
              f"{st['area_wu2']['max']:6.1f} "
              f"{_fmt(st['degree'], 0):>11} "
              f"{st['portal_w_wu']['med']:6.2f} "
              f"{_fmt(st['vis_instances'], 0):>16} "
              f"{_fmt(st['vis_near'], 0):>9}")

    def agg(pick):
        vals = [pick(r) for r in rows]
        return (f"med {statistics.median(vals):.2f}  "
                f"p90 {sorted(vals)[(9 * len(vals)) // 10]:.2f}  "
                f"max {max(vals):.2f}")

    print(f"-- {key} aggregate over {len(rows)} solo levels --")
    print("   polys/level:        ", agg(lambda r: r["polys"]))
    print("   poly area med (WU2):", agg(lambda r: r["area_wu2"]["med"]))
    print("   degree mean:        ", agg(lambda r: r["degree"]["mean"]))
    print("   portal width (WU):  ", agg(lambda r: r["portal_w_wu"]["med"]))
    print("   vis instances med:  ", agg(lambda r: r["vis_instances"]["med"]))
    print("   vis instances max:  ", agg(lambda r: r["vis_instances"]["max"]))
    print("   vis near med:       ", agg(lambda r: r["vis_near"]["med"]))
    print("   vis near max:       ", agg(lambda r: r["vis_near"]["max"]))
    allw = [w for r in rows for w in [r["portal_w_wu"]["med"]]]
    medw = statistics.median(allw)
    print(f"   scale for 80u door: {80.0 / (medw * WU):.4f} u/internal "
          f"(median door {medw:.2f} WU = {medw * WU:.0f} internal)")
    return rows


def report_ours(level_paths: list[Path], ticks: int = 1800,
                sample_every: int = 30) -> None:
    """Engine ground truth for OUR levels: len(session.visible()) sampled
    while an AggroBot walks for `ticks` (default 30 s)."""
    from perihelion.levels import load_level
    from perihelion.sim import GameSession
    from perihelion.testkit.bots import AggroBot

    print(f"\n=== ours: engine visible() during {ticks / 60:.0f}s "
          f"AggroBot walk ===")
    print(f"{'level':24s} {'polygons':>5} {'inst med/p90/max':>18}")
    for path in level_paths:
        level = load_level(path)
        session = GameSession(level, seed=7)
        bot = AggroBot(seed=7)
        counts = []
        for t in range(ticks):
            snap = session.snapshot()
            session.tick(bot.step(snap, session))
            if session.dead or session.complete:
                break
            if t % sample_every == 0:
                counts.append(len(session.visible()))
        d = _dist(counts)
        print(f"{path.stem:24s} {len(level.polygon_verts):5d} "
              f"{_fmt(d, 0):>18}")


if __name__ == "__main__":
    args = [a for a in sys.argv[1:]]
    if "--ours" in args:
        root = Path(__file__).resolve().parents[2]
        paths = sorted((root / "levels").glob("l*.json"))
        report_ours(paths)
        sys.exit(0)
    keys = [a for a in args if a in GAMES] or list(GAMES)
    for k in keys:
        report_game(k)
