"""The Mind Map (design doc 9.2): a graph of concepts the Commando has
room in his soul to metabolize. Nodes are bought with components at seed
stations; every mechanical node is also a philosophical position, and
faith/apostasy is computed from the investment pattern, never shown as a
meter.

Data: data/mindmap.json (committed design, MINDMAP_DESIGN.md). The design
sheet priced nodes in components + data as separate currencies; the shipped
economy has one currency (components, salvaged mass), so a node's price is
the SUM of both columns -- flagged as an open question for the director in
MINDMAP_DESIGN.md 7. Campaign salvage income measured at ~447c across
l01-l10 assuming near-full clears; full map cost at summed prices is 576c,
so a run that also buys chassis/kits/plating affords roughly one region's
spine and change. Scarcity is the point.
"""

from __future__ import annotations

import json
from pathlib import Path

_NODES: dict[str, dict] | None = None

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


def price(node_id: str) -> int:
    n = nodes()[node_id]
    return int(n["cost"]["components"]) + int(n["cost"]["data"])


def available(purchased: set[str], node_id: str) -> bool:
    n = nodes()[node_id]
    return node_id not in purchased and \
        all(p in purchased for p in n["prereqs"])


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
    # stable, cheap-first-within-region ordering for the UI
    for r in out:
        out[r].sort(key=lambda n: (price(n["id"]), n["id"]))
    return out
