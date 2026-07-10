"""The Mind Map (design doc 9.2): a graph of concepts the Commando has
room in his soul to metabolize. Expansion costs TIME, not components
(SEEDPOD_UI_DESIGN.md, director-directed): at the seed pod you choose ONE
frontier concept to think about; progress accrues in sim ticks during
normal field play (menus never tick), and the node unfolds -- with
ceremony -- when you next open the pod after the thought completes. Every
mechanical node is also a philosophical position, and faith/apostasy is
computed from the investment pattern, never shown as a meter.

Data: data/mindmap.json (committed design, MINDMAP_DESIGN.md). The design
sheet priced nodes in components + data as separate currencies. Those
`cost` fields are NOT deleted -- they are now think-time WEIGHTS: a node's
weight is the sum of both columns, and its think-time is
weight * THINK_SECONDS_PER_WEIGHT (the ONE conversion constant). The old
component-price curve (3..48, total 576 across 33 nodes) therefore becomes
30s..8min per node, ~96 minutes for the whole map -- the progression
curve's shape is preserved in the new currency, and scarcity is still the
point: a full campaign of field time affords roughly the map.
"""

from __future__ import annotations

import json
import math
from pathlib import Path

# ---------------------------------------------------------------------------
# THE conversion constant (price -> time). One design sheet "cost" unit
# (component or data point) = 10 seconds of background thought = 600 ticks.
THINK_SECONDS_PER_WEIGHT = 10
THINK_TICKS_PER_WEIGHT = THINK_SECONDS_PER_WEIGHT * 60  # sim runs at 60Hz

_NODES: dict[str, dict] | None = None
_LAYOUT: dict[str, tuple[float, float]] | None = None

REGION_ORDER = ["vocation", "history", "comprehension", "void"]
REGION_LABELS = {
    "vocation": "VOCATION",
    "history": "HISTORY",
    "comprehension": "COMPREHENSION",
    "void": "THE VOID",
}


def nodes() -> dict[str, dict]:
    global _NODES
    if _NODES is None:
        with open(Path(__file__).parent / "data" / "mindmap.json",
                  encoding="utf-8") as f:
            _NODES = {n["id"]: n for n in json.load(f)}
    return _NODES


def weight(node_id: str) -> int:
    """Design-sheet cost columns summed: the node's think-time weight."""
    n = nodes()[node_id]
    return int(n["cost"]["components"]) + int(n["cost"]["data"])


def think_ticks(node_id: str) -> int:
    """Sim ticks of field time needed to finish thinking this node."""
    return weight(node_id) * THINK_TICKS_PER_WEIGHT


def available(purchased: set[str], node_id: str) -> bool:
    n = nodes()[node_id]
    return node_id not in purchased and \
        all(p in purchased for p in n["prereqs"])


def frontier(purchased: set[str]) -> list[str]:
    """Locked nodes whose prereqs are all met: the thinkable edge of the
    mind. Unlocked + frontier is exactly the fog-of-war visible set."""
    return sorted(nid for nid in nodes() if available(purchased, nid))


def faith_score(purchased: set[str]) -> int:
    tbl = nodes()
    return sum(tbl[i]["faith"] for i in purchased if i in tbl)


def unlocks(purchased: set[str]) -> set[str]:
    tbl = nodes()
    return {tbl[i]["unlock"] for i in purchased
            if i in tbl and tbl[i]["unlock"]}


def by_region() -> dict[str, list[dict]]:
    out: dict[str, list[dict]] = {r: [] for r in REGION_ORDER}
    for n in nodes().values():
        out[n["region"]].append(n)
    # stable, cheap-first-within-region ordering
    for r in out:
        out[r].sort(key=lambda n: (weight(n["id"]), n["id"]))
    return out


# ---------------------------------------------------------------------------
# graph layout: regions as territory (SEEDPOD_UI_DESIGN.md). Authored
# radial-by-region positions, a pure deterministic function of the json --
# zero runtime randomness, identical on every open of the pod.
# ---------------------------------------------------------------------------

# each region owns a compass sector (screen coords: +y is down)
_REGION_ANGLE_DEG = {"vocation": -90.0, "history": 0.0,
                     "comprehension": 180.0, "void": 90.0}
_SECTOR_HALF_DEG = 40.0


def depths() -> dict[str, int]:
    """Prereq depth per node (0 = a region root)."""
    tbl = nodes()
    memo: dict[str, int] = {}

    def d(nid: str) -> int:
        if nid not in memo:
            pre = tbl[nid]["prereqs"]
            memo[nid] = 0 if not pre else 1 + max(d(p) for p in pre)
        return memo[nid]

    for nid in tbl:
        d(nid)
    return memo


def layout() -> dict[str, tuple[float, float]]:
    """node id -> (x, y) in unit space (roughly -1..1 both axes). Nodes
    sit at a radius set by prereq depth, in their region's sector, spread
    evenly (id-sorted) within each (region, depth) ring segment."""
    global _LAYOUT
    if _LAYOUT is None:
        tbl = nodes()
        dep = depths()
        maxd = max(dep.values()) or 1
        groups: dict[tuple[str, int], list[str]] = {}
        for nid in sorted(tbl):
            groups.setdefault((tbl[nid]["region"], dep[nid]), []).append(nid)
        pos: dict[str, tuple[float, float]] = {}
        span = math.radians(2 * _SECTOR_HALF_DEG)
        for (region, d_), ids in groups.items():
            base = math.radians(_REGION_ANGLE_DEG[region])
            r = 0.24 + 0.76 * (d_ / maxd)
            for i, nid in enumerate(ids):
                a = base + span * ((i + 1) / (len(ids) + 1) - 0.5)
                pos[nid] = (r * math.cos(a), r * math.sin(a))
        _LAYOUT = pos
    return _LAYOUT
