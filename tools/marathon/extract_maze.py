"""Generate tools/levelgen/arrival_maze.py from the Marathon 1 map.

Extracts the east maze of M1 level 0 "Arrival" — the dense 66-cell corridor
grid between the Observation Deck and the final chamber, the section of the
1994 game that shipped genuinely overlapping ("5D") space — and bakes it
into a standalone LevelBuilder stamp with no runtime dependency on the
Steam files.

Selection rule (see the exploration notes in git history / the render in
scratchpad): portal-BFS from cell 150 restricted to polygons with centroid
inside x 22800-32700, y 13000-24500 internal units and area < 2 WU². That
yields exactly the brown maze cells and excludes the wide green transit
corridor (polys 230/160) that crosses OVER the maze without connecting —
Marathon's own 5D trick, preserved here because polygons may overlap on our
authoring canvas too (only connects define adjacency).

Rerun after changing the selection:
    uv run python tools/marathon/extract_maze.py
"""

from __future__ import annotations

import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from convert import _coincident_unconnected_pairs  # noqa: E402
from mapread import GAMES, WU, MapFile  # noqa: E402

OUT = REPO / "tools" / "levelgen" / "arrival_maze.py"

BOX = (22800, 32700, 13000, 24500)
SEED_POLY = 150
MAX_AREA_WU2 = 2.0

# named graft edges: marathon (inside_poly, outside_poly) -> name
GRAFT_NAMES = {
    (111, 114): "entry",        # from the Observation Deck junction
    (127, 234): "exit",         # south door into the final chamber
    (194, 234): "exit2",        # second south door
    (165, 166): "north",        # corridor on toward the rotunda
    (192, 189): "west",         # toward the SW corridor network
    (190, 188): "west2",
}


def select() -> tuple[list[int], "MarathonLevel"]:
    mf = MapFile(GAMES["m1"])
    lvl = mf.level(0)

    def inbox(pi):
        cx, cy = lvl.poly_centroid(pi)
        return BOX[0] <= cx <= BOX[1] and BOX[2] <= cy <= BOX[3]

    sel = {SEED_POLY}
    queue = [SEED_POLY]
    while queue:
        pi = queue.pop()
        for li in lvl.polygons[pi].lines:
            ln = lvl.lines[li]
            if not ln.is_portal:
                continue
            other = ln.cw_poly if ln.ccw_poly == pi else ln.ccw_poly
            if other in sel or not inbox(other):
                continue
            if lvl.poly_area(other) / (WU * WU) >= MAX_AREA_WU2:
                continue
            sel.add(other)
            queue.append(other)
    return sorted(sel), lvl


def main() -> None:
    sel, lvl = select()
    index_of = {mi: i for i, mi in enumerate(sel)}

    # local origin: min corner of the selection, in internal units
    all_pts = [v for mi in sel for v in lvl.poly_verts(mi)]
    ox = min(p[0] for p in all_pts)
    oy = min(p[1] for p in all_pts)

    polygons = []
    for mi in sel:
        verts = [(x - ox, y - oy) for x, y in lvl.poly_verts(mi)]
        verts.reverse()  # engine-canonical winding (negative shoelace)
        polygons.append((mi, verts))

    connects = []   # (i, j, midpoint) internal-unit midpoint, local frame
    grafts = {}     # name -> (i, midpoint) graft edge midpoints, local frame
    for ln in lvl.lines:
        if not ln.is_portal:
            continue
        a, b = ln.polys
        (x0, y0), (x1, y1) = lvl.points[ln.e0], lvl.points[ln.e1]
        mid = ((x0 + x1) / 2 - ox, (y0 + y1) / 2 - oy)
        if a in index_of and b in index_of:
            connects.append((index_of[a], index_of[b], mid))
        elif a in index_of or b in index_of:
            inside, outside = (a, b) if a in index_of else (b, a)
            name = GRAFT_NAMES.get((inside, outside))
            if name:
                grafts[name] = (index_of[inside], mid)

    # 5D flush contacts inside the selection: pairs the builder's
    # autoconnect would otherwise weld shut
    no_connect = sorted(
        (index_of[a], index_of[b])
        for a, b in _coincident_unconnected_pairs(lvl)
        if a in index_of and b in index_of)

    missing = [n for n in GRAFT_NAMES.values() if n not in grafts]
    if missing:
        raise AssertionError(f"graft edges not found: {missing}")

    w = max(p[0] for p in all_pts) - ox
    h = max(p[1] for p in all_pts) - oy

    def fmt_polygons():
        out = []
        for mi, verts in polygons:
            vs = ", ".join(f"({x}, {y})" for x, y in verts)
            out.append(f"    ({mi}, [{vs}]),")
        return "\n".join(out)

    def fmt_connects():
        return "\n".join(
            f"    ({i}, {j}, ({mx:g}, {my:g}))," for i, j, mx_my in
            [(i, j, m) for i, j, m in connects]
            for mx, my in [mx_my])

    def fmt_grafts():
        return "\n".join(
            f'    "{name}": ({i}, ({mx:g}, {my:g})),'
            for name, (i, (mx, my)) in sorted(grafts.items()))

    body = TEMPLATE.format(
        n=len(polygons), n_conn=len(connects), n_nc=len(no_connect),
        w_wu=w / WU, h_wu=h / WU,
        polygons=fmt_polygons(), connects=fmt_connects(),
        no_connect=",\n".join(f"    ({a}, {b})" for a, b in no_connect),
        grafts=fmt_grafts())
    OUT.write_text(body)
    print(f"{OUT}: {len(polygons)} polygons, {len(connects)} connects, "
          f"{len(no_connect)} no_connects, grafts: {sorted(grafts)}")


TEMPLATE = '''"""Arrival's maze, as a LevelBuilder stamp — the Marathon homage.

This is the east maze of Marathon 1 level 0 "Arrival" (1994), cell for
cell: {n} convex polygons portal-BFS-extracted from the shipped Map.scen
(see tools/marathon/extract_maze.py, which generated this file — do not
hand-edit the data tables; rerun the extractor). It is the earliest piece
of genuinely non-Euclidean space Bungie ever shipped: several of its
corridors overlap in plan without touching, and a wide transit hall
(Marathon polys 230/160, deliberately NOT extracted) crosses straight over
its middle. Our engine reproduces that for free — polygons may overlap on the
authoring canvas; only connects define adjacency — so the stamp keeps the
original plan coordinates and the original overlaps.

Coordinates are Marathon internal units (1024 per WU) relative to the
maze's own min corner; `build_maze` scales them by `scale`/WU. At the
canonical scale=80 (1 WU -> 80 u, tools/marathon/stats.py) the maze covers
~{w_wu:.1f}x{h_wu:.1f} WU = ~775x900 u and its doors are 40-80 u wide.

Graft points (returned dict, authoring-canvas coords ready for
`connect_pts`):
    entry  - NW vestibule (Marathon 111; Arrival enters here from the
             Observation Deck junction)
    exit   - south door (127) into Arrival's final chamber
    exit2  - second south door (194)
    north  - corridor stub (165) that led on toward the rotunda
    west / west2 - links (192/190) into Arrival's SW corridor network

Usage (see tools/levelgen/INTEGRATION.md):
    maze = build_maze(b, origin=(2600.0, 400.0), scale=80.0)
    b.connect_pts(hall, hall_door_pt, maze["entry"][0], maze["entry"][1])
    b.connect_pts(maze["exit"][0], maze["exit"][1], vault, vault_door_pt)
"""

from __future__ import annotations

WU = 1024  # marathon internal units per world unit

# (marathon_poly_index, verts) - engine-canonical winding, local frame
_POLYGONS = [
{polygons}
]

# (polygon_i, polygon_j, edge midpoint) - every walkable Marathon portal
_CONNECTS = [
{connects}
]

# plan-flush but unconnected pairs (Marathon 5D space): the builder's
# autoconnect must not weld these shut
_NO_CONNECT = [
{no_connect}
]

# name -> (polygon index, edge midpoint in local frame)
_GRAFTS = {{
{grafts}
}}


def build_maze(b, origin: tuple, scale: float = 80.0) -> dict:
    """Stamp Arrival's maze into LevelBuilder `b` at `origin`.

    `scale` is PERIHELION units per Marathon WU; 80.0 is the canonical
    mapping (median Marathon door -> our 80 u doorway). Returns a dict:
    "polygons" (marathon poly index -> builder polygon id), plus a graft point
    per name above: (builder_polygon_id, (x, y) authoring coords) — feed
    each straight into `b.connect_pts` / `b.door_pts`. Polygons are tagged
    corridor/transit by adjacency degree; retag freely.
    """
    s = scale / WU
    ox, oy = origin

    def pt(p):
        return (ox + p[0] * s, oy + p[1] * s)

    deg = [0] * len(_POLYGONS)
    for i, j, _ in _CONNECTS:
        deg[i] += 1
        deg[j] += 1

    ids = []
    for k, (mi, verts) in enumerate(_POLYGONS):
        kind = "transit" if deg[k] >= 3 else "corridor"
        ids.append(b.polygon([pt(v) for v in verts],
                          detail_seed=mi * 7919 + 13, kind=kind))
    for i, j, mid in _CONNECTS:
        b.connect_pts(ids[i], pt(mid), ids[j], pt(mid))
    for i, j in _NO_CONNECT:
        b.no_connect(ids[i], ids[j])

    out = {{"polygons": {{mi: ids[k] for k, (mi, _) in enumerate(_POLYGONS)}}}}
    for name, (i, mid) in _GRAFTS.items():
        out[name] = (ids[i], pt(mid))
    return out
'''


if __name__ == "__main__":
    main()
