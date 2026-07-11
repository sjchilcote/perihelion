"""Synthetic mind-map graphs at TARGET scale (director's round-2 brief,
verbatim: "hundreds, maybe _thousands_ of vertices"). The real
data/mindmap.json is a 33-node sparse early-game state of that same
design; the local-camera framing (mindmap.LOCAL_ZOOM, the label LOD law)
must be PROVEN against the scale it is designed for, not just the current
data. This generator is the design/test fixture for that proof: a
deterministic (seeded), mindmap-shaped DAG -- regions, rooted prereq
forests, realistic label lengths, a real depth distribution -- NOT fake
game data (it never touches data/, never masquerades as real nodes).
"""

from __future__ import annotations

import random

# the same register the real map's labels speak: short noun phrases,
# 1-4 words, weighted toward the 2-3 word lengths the real data has
_WORDS = [
    "the", "watch", "liturgy", "kernel", "constraint", "organ",
    "harvesting", "adversary", "biology", "survey", "comprehension",
    "spatial", "fold", "cartography", "resonance", "mapping", "testator",
    "engineering", "connection", "space", "hollow", "litany",
    "arithmetic", "futility", "unit", "remembers", "name", "count",
    "second", "discarded", "protected", "revival", "psalm", "loop",
    "kin", "war", "designation", "remembered", "restraint", "doctrine",
    "diagrams", "peace", "record", "vigil", "orbit", "perihelion",
    "descent", "charter", "frame", "socket",
]

_REGIONS = ["vocation", "history", "comprehension", "void"]


def synthetic_mindmap(n_nodes: int = 400, seed: int = 20260711,
                      regions: list[str] | None = None) -> dict[str, dict]:
    """A mindmap-shaped graph of `n_nodes` nodes: per-region rooted DAGs
    (every non-root has 1-2 prereqs among earlier SAME-REGION nodes, so
    regions read as territory at scale exactly like the real map's), a
    preferential-recency parent pick that grows real depth (~8-12 levels
    at 400 nodes) instead of a shallow star, and labels drawn from the
    real map's register. Pure function of (n_nodes, seed): identical
    graph on every machine, every run."""
    rng = random.Random(seed)
    regs = regions if regions is not None else _REGIONS
    graph: dict[str, dict] = {}
    by_region: dict[str, list[str]] = {r: [] for r in regs}
    for i in range(n_nodes):
        nid = f"s{i:04d}"
        region = regs[i % len(regs)] if i < len(regs) else rng.choice(regs)
        pool = by_region[region]
        if not pool:
            prereqs: list[str] = []
        else:
            # recency bias: parent drawn from the last ~35% of the
            # region's nodes most of the time -- this is what grows a
            # real depth distribution (chains) rather than a hub
            if rng.random() < 0.7 and len(pool) > 3:
                parent = rng.choice(pool[-max(2, len(pool) * 35 // 100):])
            else:
                parent = rng.choice(pool)
            prereqs = [parent]
            if rng.random() < 0.2 and len(pool) > 1:
                other = rng.choice(pool)
                if other != parent:
                    prereqs.append(other)
        n_words = rng.choices([1, 2, 3, 4], weights=[1, 4, 4, 2])[0]
        label = " ".join(rng.choice(_WORDS) for _ in range(n_words))
        graph[nid] = {
            "id": nid, "region": region, "label": label,
            "prereqs": prereqs, "cost": {"components": 1, "data": 0},
            "faith": 0, "unlock": None, "blurb": "", "brief": "",
        }
        by_region[region].append(nid)
    return graph
