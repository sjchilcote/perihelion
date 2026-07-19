"""Build levels/maze_demo.json: Arrival's maze, playable, standalone.

A spawn hall is welded onto the maze's `entry` graft edge and an exit
chamber onto its `exit` (south) door, both by exact edge coincidence so
the builder's autoconnect does the joining — the same thing a campaign
graft does with `connect_pts` (see tools/levelgen/INTEGRATION.md).

    uv run python tools/marathon/make_maze_demo.py
"""

from __future__ import annotations

import math
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(REPO / "game"))
sys.path.insert(0, str(REPO / "tools" / "levelgen"))

from arrival_maze import build_maze  # noqa: E402
from perihelion.levels import LevelBuilder, save_level  # noqa: E402

OUT = REPO / "levels" / "maze_demo.json"


def _polygon_centroid(b: LevelBuilder, rid: int) -> tuple[float, float]:
    vs = b.data["polygons"][rid]["verts"]
    return (sum(v[0] for v in vs) / len(vs), sum(v[1] for v in vs) / len(vs))


def _edge_at(b: LevelBuilder, rid: int, mid: tuple[float, float]):
    """The (p0, p1) edge of polygon `rid` whose midpoint is nearest `mid`."""
    vs = b.data["polygons"][rid]["verts"]
    best, bd = None, 1e18
    for i in range(len(vs)):
        p0, p1 = vs[i], vs[(i + 1) % len(vs)]
        mx, my = (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2
        d = (mx - mid[0]) ** 2 + (my - mid[1]) ** 2
        if d < bd:
            best, bd = (tuple(p0), tuple(p1)), d
    return best


def _extrude(b: LevelBuilder, rid: int, mid, depth: float, widen: float = 0.0,
             kind: str = "generic", seed: int | None = None) -> int:
    """New polygon sharing the graft edge exactly, extruded outward from the
    maze (autoconnect welds the shared edge into a doorway)."""
    p0, p1 = _edge_at(b, rid, mid)
    cx, cy = _polygon_centroid(b, rid)
    ex, ey = p1[0] - p0[0], p1[1] - p0[1]
    elen = math.hypot(ex, ey)
    ux, uy = ex / elen, ey / elen
    # outward = away from the maze polygon's centroid
    nx, ny = -uy, ux
    mx, my = (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2
    if (cx - mx) * nx + (cy - my) * ny > 0:
        nx, ny = -nx, -ny
    q0 = (p0[0] - ux * widen + nx * depth, p0[1] - uy * widen + ny * depth)
    q1 = (p1[0] + ux * widen + nx * depth, p1[1] + uy * widen + ny * depth)
    return b.poly([p0, p1, q1, q0], seed=seed), (mx + nx * depth * 0.5,
                                                 my + ny * depth * 0.5)


def main() -> None:
    b = LevelBuilder("The Maze From Arrival", tier=1,
                     ambience="amb_drone_early")
    maze = build_maze(b, origin=(400.0, 300.0), scale=80.0)

    hall, hall_c = _extrude(b, *maze["entry"], depth=140.0, widen=40.0)
    b.set_kind(hall, "dock")
    vault, vault_c = _extrude(b, *maze["exit"], depth=150.0, widen=60.0)
    b.set_kind(vault, "storage")

    b.player(hall, hall_c)
    b.exit(vault, vault_c)

    polygons = maze["polygons"]  # marathon poly index -> polygon id
    c = lambda mi: _polygon_centroid(b, polygons[mi])  # noqa: E731

    # a light patrol: husks at maze crossings, mites in the tight loops
    for mi in (150, 218, 159, 199, 128):
        b.entity(polygons[mi], "husk", c(mi))
    for mi in (144, 156, 176, 132):
        b.entity(polygons[mi], "mite", c(mi))
    # supplies in dead-end alcoves (Marathon's 10%-alcove rule)
    for mi, kind in ((155, "ammo_9mm"), (135, "ammo_9mm"), (134, "medkit"),
                     (197, "ammo_9mm")):
        b.entity(polygons[mi], kind, c(mi))

    b.intro("SURVEY SECTION 7 - CORRIDOR GRID PREDATES THE OUTPOST")

    level = b.build()  # loud validation before writing
    assert len(level.polygon_verts) == 68, len(level.polygon_verts)
    save_level(b.to_dict(), OUT)
    print(f"{OUT}: {len(level.polygon_verts)} polygons, "
          f"{len(level.connects)} connects")


if __name__ == "__main__":
    main()
