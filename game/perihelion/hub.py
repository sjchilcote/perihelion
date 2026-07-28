"""The marrow hub — a corrupted Testator cathedral (U8, DESIGN_7_25 §1b).

Built at initialization, NEVER None: every world has one. 24 chambers,
kept OFF the reachable map (no connection to the world — hop distance
from anywhere is -1 until a live breach exists). The shape is the
ratified one: three Receiving Apses whose seams are where breaches
attach, Guardian Courts behind them, a shallow transept LOOP for early
flanking (the loop closes across a fold — adjacency is the portal
graph, not geometry), the Rood Gatehouse, one axial trunk with Collar
and Anchor chapels and the Scriptorium off it, a Long Exposed Connector
as the final commitment, a vestibule, and three separate Source Cells,
pairwise nonadjacent, 10-11 crossings deep depending on the apse.

MARROW VISUAL PASS (Sol consult 2026-07-28, director: "polygons are
just that — individual polygons... not constrained to square rooms"):
every chamber is a one-off convex biogenic shell — 5-9 unequal facets,
grown proportions, machined edges — with each doorway carved into an
authored flat PALATE facet long enough to seat it (>=94u for the 70u
doors, >=128u for the 96u breach seams). The portal graph, degree
sequence, apse-to-Source depths, resident posts, organ anchors, and
the light plan are all UNCHANGED — build-time validators below refuse
any shell that would move them.

Every internal glue goes through TopologyManager.connect_equal — the
scale-1 guard is exercised ~26 times in every world build, so the
lens-portal bug class dies at construction, not in playtest.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

from .topology import EdgeHandle, TopologyManager

DOOR_W = 70.0
BREACH_W = 96.0

# the authored shells (marrow visual pass, Sol consult 2026-07-28),
# derived and checked by tools/design/author_hub_shells.py: convex,
# 5-9 facets, every doorway on its own >=94u palate (breach >=128u),
# no facet under 22u or corner under 32 degrees, area within 8% of
# the rectangles these replace, and every organ/resident/light anchor
# inside with 16u of wall clearance. Verts are authored coordinates;
# the engine re-centers each polygon on its area centroid, so the
# seat anchors below are already in that ENGINE frame.
# name: (verts, door_seats, breach_seat_or_None)
CHAMBER_SHELLS = {
    "A1": (
        ((155.2, -48.6), (141.7, -70.6), (126.4, -86.7),
         (-121.2, -59.5), (6.2, 144.3), (121.9, 87.8)),
        ((-90.5, 31.8),),
        (-30.4, -83.7)),
    "A2": (
        ((111.3, -86.2), (94.4, -105.6), (-106.1, -115.0),
         (-123.5, -99.8), (-9.6, 132.3), (118.7, 55.2)),
        ((-18.0, -96.7),),
        (-78.7, 29.9)),
    "A3": (
        ((80.1, -74.5), (-111.1, -94.8), (-114.2, 76.5),
         (-94.0, 93.4), (38.4, 122.6), (115.0, 66.0)),
        ((-104.5, -21.3),),
        (-7.4, -96.8)),
    "G1": (
        ((101.1, -57.6), (-8.0, -123.7), (-98.6, -85.0),
         (-86.1, 68.5), (42.5, 95.8), (112.6, 17.6)),
        ((-93.4, 3.2), (-22.9, 93.6),),
        None),
    "G2": (
        ((120.7, -13.5), (27.2, -96.3), (-52.2, -89.6),
         (-137.3, 47.7), (-28.1, 112.0), (65.7, 82.0)),
        ((-88.5, -28.9), (-76.5, 71.9),),
        None),
    "G3": (
        ((107.7, -3.1), (67.7, -83.0), (-30.6, -115.2),
         (-125.3, -36.7), (-72.7, 88.2), (40.5, 100.8)),
        ((-91.2, 30.6), (81.9, 53.7),),
        None),
    "T1": (
        ((84.0, -77.6), (37.4, -96.9), (-94.0, -75.1),
         (-119.8, -42.3), (-72.9, 66.0), (-40.0, 76.4),
         (104.8, 51.5), (118.7, 32.9)),
        ((31.8, 74.4), (-28.9, -75.6), (-97.0, 22.3), (100.7, -11.9),),
        None),
    "T2": (
        ((33.5, -91.6), (-0.7, -95.6), (-103.0, -15.9),
         (-107.2, 10.0), (-36.9, 111.9), (-5.3, 118.9),
         (103.3, 59.5), (115.0, 6.1)),
        ((-56.6, -68.4), (69.5, -55.4), (-76.8, 48.3), (44.3, 76.6),),
        None),
    "T3": (
        ((116.7, -27.0), (91.6, -60.5), (-53.7, -73.5),
         (-77.4, -63.5), (-120.1, 47.7), (-101.3, 73.9),
         (25.4, 100.6), (70.8, 82.2)),
        ((21.0, -77.5), (-35.9, 76.7), (-96.7, -18.4), (95.8, 17.1),),
        None),
    "R": (
        ((53.1, -75.8), (4.4, -91.0), (-72.7, -59.8),
         (-85.2, 63.5), (-2.4, 91.7), (62.2, 51.0)),
        ((67.3, -13.1), (-69.3, 1.2),),
        None),
    "C1": (
        ((38.6, -70.9), (-87.5, 11.4), (-78.2, 40.6),
         (-60.5, 68.3), (62.4, 88.8)),
        ((54.1, -11.5),),
        None),
    "C2": (
        ((36.5, -72.8), (-50.2, -79.8), (-73.0, -57.3),
         (-46.9, 69.6), (70.4, 17.8)),
        ((-52.6, 19.2),),
        None),
    "N1": (
        ((94.4, -23.1), (54.1, -60.6), (-80.7, -35.8),
         (-89.7, -12.7), (-19.4, 78.9), (33.4, 82.5)),
        ((-17.9, -53.5), (59.3, 24.4), (-59.2, 27.8),),
        None),
    "N2": (
        ((20.0, -78.9), (-53.6, -76.4), (-87.8, 39.3),
         (-67.4, 55.9), (85.2, 32.4), (93.8, 9.6)),
        ((12.9, 52.3), (-66.7, -10.4), (60.9, -26.5),),
        None),
    "N3": (
        ((40.8, -77.2), (-23.8, -86.9), (-84.9, 19.8),
         (-53.8, 51.8), (84.8, 42.3), (95.0, 22.8)),
        ((10.7, 55.6), (-59.1, -25.0), (63.1, -18.7),),
        None),
    "N4": (
        ((89.6, -1.0), (73.9, -38.6), (-71.6, -51.4),
         (-88.3, -22.1), (-77.9, 45.8), (57.5, 73.2)),
        ((1.7, -51.6), (-9.6, 52.9),),
        None),
    "AN1": (
        ((47.2, -57.9), (-69.2, -63.3), (-91.0, -30.5),
         (-72.1, 37.3), (26.6, 64.0)),
        ((56.7, 10.1),),
        None),
    "AN2": (
        ((91.2, -14.9), (-56.3, -69.9), (-69.7, 38.3),
         (-21.8, 60.3), (21.1, 63.9)),
        ((20.7, -44.0),),
        None),
    "SC": (
        ((85.8, -40.6), (-50.3, -49.8), (-62.8, 63.4),
         (-23.6, 85.9), (18.9, 84.6), (51.5, 68.9)),
        ((12.7, -60.3),),
        None),
    "L": (
        ((166.1, -36.2), (8.3, -55.4), (-209.5, -34.7),
         (-125.5, 55.9), (-0.7, 56.2), (98.5, 49.4)),
        ((-81.8, -45.0), (106.0, -45.7),),
        None),
    "V": (
        ((181.9, -53.5), (19.5, -98.4), (-128.6, -98.0),
         (-224.5, -62.3), (-233.2, 43.6), (-44.6, 91.1),
         (104.4, 86.4), (202.0, 49.0)),
        ((-120.4, 71.2), (119.2, -72.1), (48.4, 92.6), (-36.0, -94.3),),
        None),
    "S1": (
        ((-55.0, -42.5), (-69.2, 43.5), (-55.6, 63.9),
         (10.8, 84.8), (73.6, 1.7)),
        ((18.0, -42.2),),
        None),
    "S2": (
        ((54.1, -65.3), (-73.4, -6.9), (-27.6, 64.8),
         (4.5, 68.0), (61.2, 31.6)),
        ((-13.8, -42.3),),
        None),
    "S3": (
        ((38.0, -67.7), (-7.0, -79.2), (-44.9, -68.3),
         (-62.3, 24.8), (84.8, 22.2)),
        ((7.3, 43.7),),
        None),
}


# the portal graph (each pair carved at DOOR_W on both sides and glued
# scale-1). T3-T1 closes the transept loop across a fold.
_LINKS = [
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


# the RESIDENT population (ratified composition: the hub is not what
# comes through the gate — residents read 60% screen / 18% ranged /
# 10% mobility / 12% breaker, visibly LIGHTER than the 35/25/15/25
# strike package it dispatches). 18 bodies, authored by chamber:
# screen holds the transept loop, the trunk mixes in ranged and the
# lurkers, the breakers stand at the last commitments. Organ rooms
# (C*, SC, S*) keep no residents — the organ is its own tenant.
RESIDENT_PLACEMENT = (
    ("T1", "mite"), ("T1", "husk"),
    ("T2", "mite"), ("T2", "husk"),
    ("T3", "mite"), ("T3", "husk"),
    ("R", "husk"), ("R", "spitter"),
    ("N1", "mite"), ("N1", "flicker"),
    ("N2", "spitter"),
    ("N3", "mite"), ("N3", "shrieker"),
    ("N4", "husk"),
    ("L", "flicker"),
    ("V", "brute"), ("V", "mite"),
    ("AN1", "brute"),
)


# the cathedral's own light (ratified arrival language: 'conduits
# carrying light inward and agents arriving from deeper say THAT WAY
# IS DEPTH'). Cold violet at the receiving apses, blackened-brass
# station light in the courts, processional inlays around the
# transept, and a warmth/reach ramp down the nave trunk toward the
# vestibule; the source cells burn reliquary violet-white — the prize
# reads from the doorway. Colored architectural lights hold intensity
# 1/3 (the hue clamp: above it the dominant channels whiten); only
# the reliquaries and thresholds run hot on purpose.
# (room, (dx, dy) from chamber center, color, intensity, radius)
HUB_LIGHT_PLAN = (
    ("A1", (0.0, 0.0), (150, 90, 190), 0.33, 150.0),
    ("A2", (0.0, 0.0), (150, 90, 190), 0.33, 150.0),
    ("A3", (0.0, 0.0), (150, 90, 190), 0.33, 150.0),
    ("G1", (0.0, -20.0), (200, 140, 80), 0.33, 130.0),
    ("G2", (0.0, -20.0), (200, 140, 80), 0.33, 130.0),
    ("G3", (0.0, -20.0), (200, 140, 80), 0.33, 130.0),
    ("T1", (0.0, 0.0), (140, 150, 200), 0.33, 120.0),
    ("T2", (0.0, 0.0), (140, 150, 200), 0.33, 120.0),
    ("T3", (0.0, 0.0), (140, 150, 200), 0.33, 120.0),
    ("R", (0.0, 0.0), (220, 170, 110), 0.40, 140.0),
    ("C1", (0.0, 0.0), (160, 100, 200), 0.30, 100.0),
    ("C2", (0.0, 0.0), (160, 100, 200), 0.30, 100.0),
    # the trunk: reach grows with depth — the conduit ramp
    ("N1", (0.0, 0.0), (170, 130, 90), 0.33, 110.0),
    ("N2", (0.0, 0.0), (170, 130, 90), 0.33, 120.0),
    ("N3", (0.0, 0.0), (170, 130, 90), 0.33, 130.0),
    ("N4", (0.0, 0.0), (170, 130, 90), 0.33, 140.0),
    ("AN1", (0.0, 0.0), (160, 100, 200), 0.30, 100.0),
    ("AN2", (0.0, 0.0), (160, 100, 200), 0.30, 100.0),
    ("SC", (0.0, 0.0), (235, 225, 150), 0.33, 110.0),
    ("L", (-120.0, 0.0), (120, 120, 150), 0.30, 100.0),
    ("L", (120.0, 0.0), (120, 120, 150), 0.30, 100.0),
    ("V", (-100.0, 0.0), (230, 180, 120), 0.40, 160.0),
    ("V", (100.0, 0.0), (230, 180, 120), 0.40, 160.0),
    ("S1", (0.0, 0.0), (235, 160, 255), 0.45, 120.0),
    ("S2", (0.0, 0.0), (235, 160, 255), 0.45, 120.0),
    ("S3", (0.0, 0.0), (235, 160, 255), 0.45, 120.0),
)


# THE CORRUPTION GRADIENT (marrow visual pass, Sol consult 2026-07-28).
# Depth is minimum crossings from a Receiving Apse — the portal graph,
# never euclidean distance. Corruption rises the whole way in; the
# SEMANTIC kind switches at depth 6, about three fifths of the way down,
# while the lighting model arrives on a crossfade (render._ow_mix) so
# the switch never reads as a theme trigger. The apses are already
# touched (0.10) because a breach opens there; the source cells are
# gone (1.00).
_DESCENT_BY_DEPTH = (0.10, 0.18, 0.28, 0.40, 0.50, 0.60,
                     0.72, 0.82, 0.90, 0.96, 1.00)
OTHERWORLD_DEPTH = 6


def chamber_depths() -> dict[str, int]:
    """Crossings from the nearest Receiving Apse, over _LINKS."""
    adj: dict[str, list[str]] = {name: [] for name in CHAMBER_SHELLS}
    for a, b in _LINKS:
        adj[a].append(b)
        adj[b].append(a)
    depth = {"A1": 0, "A2": 0, "A3": 0}
    frontier = ["A1", "A2", "A3"]
    while frontier:
        nxt = []
        for name in frontier:
            for other in adj[name]:
                if other not in depth:
                    depth[other] = depth[name] + 1
                    nxt.append(other)
        frontier = nxt
    missing = set(CHAMBER_SHELLS) - set(depth)
    if missing:
        raise RuntimeError(f"hub chambers unreachable from any apse: {missing}")
    return depth


@dataclass(frozen=True, slots=True)
class HubLayout:
    chambers: dict          # name -> polygon index
    receiving_apses: tuple[int, int, int]
    guardian_courts: tuple[int, ...]
    collar_chapels: tuple[int, int]
    anchor_chapels: tuple[int, ...]
    scriptorium: int
    gatehouse: int
    source_cells: tuple[int, int, int]
    breach_edges: tuple[EdgeHandle, ...]   # carved BREACH_W apse seams


def _expected_degrees() -> dict[str, int]:
    d: dict[str, int] = {name: 0 for name in CHAMBER_SHELLS}
    for a, b in _LINKS:
        d[a] += 1
        d[b] += 1
    return d


def build_hub(session, topo: TopologyManager) -> HubLayout:
    s = session.sim
    depths = chamber_depths()
    idx: dict[str, int] = {}
    door_queue: dict[str, list] = {}
    for name, (verts, door_seats, breach_seat) in CHAMBER_SHELLS.items():
        r = s.add_polygon([(float(x), float(y)) for x, y in verts])
        idx[name] = r
        door_queue[name] = list(door_seats)
        # every rendered polygon needs its detail seed (the paid-for
        # lesson: growing the world without growing the seed list is a
        # renderer crash later) — and its KIND and DESCENT, or it falls
        # off the end of both lists and renders as a generic chamber at
        # whatever descent the world's last polygon happened to have
        session.level.polygon_seeds.append(r * 7919 + 13)
        d = depths[name]
        # kind and descent go on the SESSION, not the level: the hub
        # belongs to no level (every world has one, and a world can swap
        # levels underneath it). Parked in the level's arrays they vanish
        # the moment a chunk swap replaces `session.level`, and the
        # cathedral silently renders as generic rooms again.
        session.hub_polygon_meta[r] = (
            "otherworld" if d >= OTHERWORLD_DEPTH else "marrow",
            _DESCENT_BY_DEPTH[min(d, len(_DESCENT_BY_DEPTH) - 1)])

    # each link consumes one authored palate seat on each side
    for a, b in _LINKS:
        ha = _carve_seat(topo, idx[a], door_queue[a], a, DOOR_W)
        hb = _carve_seat(topo, idx[b], door_queue[b], b, DOOR_W)
        topo.connect_equal(ha, hb)

    # the three breach seams: BREACH_W cuts on the apses' authored
    # breach palates, adopted but UNCONNECTED — U9's dispatch glues the
    # world side in
    seams = []
    for name in ("A1", "A2", "A3"):
        seat = CHAMBER_SHELLS[name][2]
        hseam = topo.carve(idx[name], seat, BREACH_W)
        if hseam is None:
            raise RuntimeError(f"apse {name} cannot hold its breach seam")
        seams.append(hseam)

    _validate(session, idx, seams)

    # the cathedral lights itself — registered against the static cache
    # AFTER the doors are carved, so every wedge sees its doorways
    from .levels import LightSpec
    session.lighting.add_lights(s, [
        LightSpec(polygon=idx[name], pos=pos, color=color,
                  intensity=inten, radius=radius, kind="static")
        for name, pos, color, inten, radius in HUB_LIGHT_PLAN])

    return HubLayout(
        chambers=dict(idx),
        receiving_apses=(idx["A1"], idx["A2"], idx["A3"]),
        guardian_courts=(idx["G1"], idx["G2"], idx["G3"]),
        collar_chapels=(idx["C1"], idx["C2"]),
        anchor_chapels=(idx["AN1"], idx["AN2"]),
        scriptorium=idx["SC"],
        gatehouse=idx["R"],
        source_cells=(idx["S1"], idx["S2"], idx["S3"]),
        breach_edges=tuple(seams),
    )


def _carve_seat(topo, polygon, queue, name, width) -> EdgeHandle:
    if not queue:
        raise RuntimeError(f"{name}: more links than authored door seats")
    seat = queue.pop(0)
    hnd = topo.carve(polygon, seat, width)
    if hnd is None:
        raise RuntimeError(f"{name}: authored palate at {seat} cannot "
                           f"hold a {width}u door")
    return hnd


def _validate(session, idx, seams) -> None:
    """The preservation contract (Sol consult §1.4): the reshape must not
    silently relocate landed systems. Loud failure at construction."""
    s = session.sim
    # 1. degree sequence: exactly the ratified graph, no new one-door
    #    chambers beyond the authored ones
    expect = _expected_degrees()
    for name, r in idx.items():
        prt = s.polygon_portals(r)
        live = sum(1 for p in prt if p is not None)
        if live != expect[name]:
            raise RuntimeError(
                f"hub degree drift: {name} has {live} portals, "
                f"ratified graph says {expect[name]}")
    # 2. apse-to-Source topological depth: 10-11 crossings by apse
    for sname in ("S1", "S2", "S3"):
        d = min(s.hop_distance(idx[a], idx[sname])
                for a in ("A1", "A2", "A3"))
        if d not in (10, 11):
            raise RuntimeError(
                f"hub depth drift: {sname} at {d} crossings (want 10-11)")
    # 3. every light and organ/resident anchor INSIDE its shell with
    #    clearance (the generator asserted this on the authored verts;
    #    this re-checks the ENGINE's own geometry after carving)
    anchors: dict[str, list] = {name: [] for name in idx}
    for name, pos, _c, _i, _r in HUB_LIGHT_PLAN:
        anchors[name].append(pos)
    for name in idx:
        anchors[name].append((0.0, 0.0))
    for name, pts in anchors.items():
        r = idx[name]
        n = len(s.polygon_portals(r))
        edges = [s.edge_endpoints(r, e) for e in range(n)]
        for (qx, qy) in pts:
            sign = None
            for (x1, y1, x2, y2) in edges:
                cr = (x2 - x1) * (qy - y1) - (y2 - y1) * (qx - x1)
                sg = cr > 0
                if sign is None:
                    sign = sg
                elif sg != sign:
                    raise RuntimeError(
                        f"hub anchor drift: ({qx},{qy}) of {name} fell "
                        f"outside its shell")
    # 3b. the corruption gradient reached every chamber: a hub polygon
    #     with no metadata renders as a generic room at whatever descent
    #     the world's last polygon happened to carry
    meta = session.hub_polygon_meta
    for name, r in idx.items():
        if r not in meta:
            raise RuntimeError(
                f"hub chamber {name} has no kind/descent — it would render "
                f"as a generic chamber")
        if meta[r][0] not in ("marrow", "otherworld"):
            raise RuntimeError(f"hub chamber {name} is kind {meta[r][0]!r}")
    # 4. every breach seam is exactly BREACH_W
    for h, name in zip(seams, ("A1", "A2", "A3")):
        polygon, edge = session.topology.current_edge(h)
        x1, y1, x2, y2 = s.edge_endpoints(polygon, edge)
        ln = math.hypot(x2 - x1, y2 - y1)
        if abs(ln - BREACH_W) > 1e-6:
            raise RuntimeError(f"{name} breach seam is {ln}, not {BREACH_W}")
