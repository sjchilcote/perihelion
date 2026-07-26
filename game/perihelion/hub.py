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

Every internal glue goes through TopologyManager.connect_equal — the
scale-1 guard is exercised ~26 times in every world build, so the
lens-portal bug class dies at construction, not in playtest.
"""
from __future__ import annotations

from dataclasses import dataclass

from .topology import EdgeHandle, TopologyManager

DOOR_W = 70.0
BREACH_W = 96.0

# (name, width, height) — bands 0-2 (apses, courts, transepts) carry
# ~52% of the floor area, per the ratified depth distribution
_ROOMS = {
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


def build_hub(session, topo: TopologyManager) -> HubLayout:
    s = session.sim
    idx: dict[str, int] = {}
    for name, (w, h) in _ROOMS.items():
        r = s.add_polygon([(0.0, 0.0), (0.0, float(h)),
                           (float(w), float(h)), (float(w), 0.0)])
        idx[name] = r
        # every rendered polygon needs its detail seed (the paid-for
        # lesson: growing the world without growing the seed list is a
        # renderer crash later)
        session.level.polygon_seeds.append(r * 7919 + 13)

    # door placement: spread carve anchors along each room's perimeter
    # so multiple doors into one room land on different walls/segments
    used: dict[str, int] = {}
    for a, b in _LINKS:
        ha = _carve_spread(topo, session, idx[a], _ROOMS[a], used, a, DOOR_W)
        hb = _carve_spread(topo, session, idx[b], _ROOMS[b], used, b, DOOR_W)
        topo.connect_equal(ha, hb)

    # the three breach seams: BREACH_W cuts in the apses' outer walls,
    # adopted but UNCONNECTED — U9's dispatch glues the world side in
    seams = []
    for name in ("A1", "A2", "A3"):
        w, h = _ROOMS[name]
        hseam = topo.carve(idx[name], (w / 2.0 - _center(w, h)[0],
                                       0.0 - _center(w, h)[1]), BREACH_W)
        if hseam is None:
            raise RuntimeError(f"apse {name} cannot hold its breach seam")
        seams.append(hseam)

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


def _center(w, h):
    return (w / 2.0, h / 2.0)


def _carve_spread(topo, session, polygon, size, used, name, width):
    """Carve the next door for `name` on a fresh stretch of wall: cycle
    the four walls, offsetting along each so repeated doors into the
    same room never fight for one segment."""
    w, h = size
    cx, cy = _center(w, h)
    n = used.get(name, 0)
    used[name] = n + 1
    # anchor points in polygon-local (centered) coords, cycling walls;
    # generous insets keep the carve span legal after earlier splits
    anchors = [
        (0.0 - cx + w * 0.25 + (n // 4) * 10.0, cy),          # bottom wall
        (cx, 0.0 - cy + h * 0.30),                            # right wall
        (0.0 - cx + w * 0.70, -cy),                           # top wall
        (-cx, 0.0 - cy + h * 0.70),                           # left wall
    ]
    for k in range(4):
        hnd = topo.carve(polygon, anchors[(n + k) % 4], width)
        if hnd is not None:
            return hnd
    raise RuntimeError(f"no wall of {name} can hold door {n}")
