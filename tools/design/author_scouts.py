"""Author Adversary scouts into a level (ratified §1b: scouts are
authored into the world at initialization, never produced by the CORE).

Placement is MEASURED, not guessed — the first-pour frame review caught
gauntlet4's own sentries shredding unescorted scouts, so eligibility is
computed from the level itself:

  * hop distance from the player start within a band (default 3..12) —
    close enough to matter, far enough not to die in the opening fight;
  * no sentry in the chamber or any adjacent chamber;
  * at least one raw wall segment long enough to plausibly hold a 96u
    breach seam (the call should be able to LAND where the scout lives);
  * vagrants additionally need broad ground (open-ground infiltrator);
    lacunas take the boundary chambers.

Dormant lacunas go DEEP (hops beyond the active band's midpoint) in the
quietest eligible chambers, with high thresholds — the ratified reserve
spotters.

    uv run python tools/design/author_scouts.py levels/gauntlet4.json \
        [--vagrants 2] [--lacunas 3] [--dormant 2] [--write]

Without --write it prints the plan only.
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from collections import deque
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

SENTRY_TYPES = {"sentry", "turret"}
MIN_SEAM_WALL = 130.0     # raw-edge proxy for "holds a 96u seam"
VAGRANT_MIN_AREA = 45_000.0   # top-quartile ground for this station scale


def polygon_area(verts) -> float:
    s = 0.0
    for (x0, y0), (x1, y1) in zip(verts, verts[1:] + verts[:1]):
        s += x0 * y1 - x1 * y0
    return abs(s) * 0.5


def longest_edge(verts) -> float:
    return max(math.dist(a, b)
               for a, b in zip(verts, verts[1:] + verts[:1]))


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("level")
    ap.add_argument("--vagrants", type=int, default=2)
    ap.add_argument("--lacunas", type=int, default=3)
    ap.add_argument("--dormant", type=int, default=2)
    ap.add_argument("--band", type=str, default="3:12")
    ap.add_argument("--write", action="store_true")
    a = ap.parse_args()
    lo, hi = (int(x) for x in a.band.split(":"))

    path = ROOT / a.level if not Path(a.level).is_absolute() else Path(a.level)
    data = json.loads(path.read_text())
    polys = data["polygons"]
    n = len(polys)

    # adjacency from the connect tables (both styles)
    adj: dict[int, set[int]] = {i: set() for i in range(n)}
    for tbl in ("connects", "connects_x"):
        for c in data.get(tbl, []):
            ra, rb = int(c[0]), int(c[2])
            adj[ra].add(rb)
            adj[rb].add(ra)
    for d_ in data.get("doors", []):
        ra, rb = int(d_[0]), int(d_[2])
        adj[ra].add(rb)
        adj[rb].add(ra)

    start = int(data["player"]["polygon"])
    hops = {start: 0}
    q = deque([start])
    while q:
        r = q.popleft()
        for nb in adj[r]:
            if nb not in hops:
                hops[nb] = hops[r] + 1
                q.append(nb)

    sentry_rooms = {i for i, p in enumerate(polys)
                    for e in p.get("entities", [])
                    if e["type"] in SENTRY_TYPES}
    sentry_shadow = set(sentry_rooms)
    for r in sentry_rooms:
        sentry_shadow |= adj[r]

    def eligible(i: int) -> bool:
        if i not in hops or not (lo <= hops[i] <= hi):
            return False
        if i in sentry_shadow:
            return False
        if longest_edge(polys[i]["verts"]) < MIN_SEAM_WALL:
            return False
        return True

    combat_load = {i: sum(1 for e in polys[i].get("entities", [])
                          if e["type"] not in ("medkit",)
                          and not e["type"].startswith("ammo_"))
                   for i in range(n)}

    cands = sorted((i for i in range(n) if eligible(i)),
                   key=lambda i: (hops[i], i))
    if not cands:
        print("no eligible chambers", file=sys.stderr)
        return 1

    broad = [i for i in cands
             if polygon_area(polys[i]["verts"]) >= VAGRANT_MIN_AREA]
    plan: list[tuple[str, int, dict]] = []
    used: set[int] = set()

    for i in broad:
        if len([p for p in plan if p[0] == "vagrant"]) >= a.vagrants:
            break
        plan.append(("vagrant", i, {}))
        used.add(i)
    for i in cands:
        if len([p for p in plan if p[0] == "lacuna" and not p[2]]) \
                >= a.lacunas:
            break
        if i in used:
            continue
        plan.append(("lacuna", i, {}))
        used.add(i)
    # dormant: the deepest, quietest eligible chambers
    deep = sorted((i for i in cands if i not in used),
                  key=lambda i: (-hops[i], combat_load[i], i))
    for i in deep[:a.dormant]:
        plan.append(("lacuna", i, {"dormant": True,
                                   "dormant_threshold": 0.5}))
        used.add(i)

    for kind, i, props in plan:
        tag = " DORMANT" if props else ""
        print(f"  {kind:8s} polygon {i:3d} hops={hops[i]:2d} "
              f"area={polygon_area(polys[i]['verts']):9.0f} "
              f"load={combat_load[i]}{tag}")

    if not a.write:
        print("(dry run — pass --write to author)")
        return 0

    for kind, i, props in plan:
        verts = polys[i]["verts"]
        cx = sum(v[0] for v in verts) / len(verts)
        cy = sum(v[1] for v in verts) / len(verts)
        ent = {"type": kind, "pos": [cx, cy]}
        if props:
            ent["props"] = props
        polys[i].setdefault("entities", []).append(ent)
    path.write_text(json.dumps(data))
    print(f"authored {len(plan)} scouts into {path.name}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
