#!/usr/bin/env python
"""Flicker placement tool -- director's order (2026-07-13): "Have a sonnet
use its judgement to insert flickers wherever it sees fit... they should be
a common annoyance in sections where live Adversary troops (as opposed to
early-game corrupted Testator machines) live."

Ground truth gathered (see report): the campaign's three architectural
strata (NARRATIVE_DESIGN_DOC.md §4) map onto levels as

  l01-l02  Stratum One  (Research Outpost, corrupted outpost security)
  l03-l06  Stratum Two  (Testament -- station's own malfunctioning war
                          machines, still Testator, NOT the Adversary)
  l07-l09  Stratum Three (the Breach -- the invaders themselves, "enemy
                          class 3: the invaders themselves" §4.3)

confirmed independently by tools/levelgen/dense/l0*.py's own docstrings:
"otherworld" cells (the Adversary's non-Euclidean home turf) first appear
in l07 (exactly one, isolated -- the transition), grow to a small cluster
in l08, and dominate l09 (72 of 253 cells). l01-l06 place zero otherworld
cells. So flickers go in l07/l08/l09 only, seasoned to how saturated each
level's Adversary presence is (l07 light, l08 medium, l09 heaviest).

Per-polygon judgment: a polygon is a lurk candidate if
  - it has NO static light fixture reaching it (LightingSystem's static
    cache -- "polygons without light fixtures are dark", director's brief),
  - it isn't a dead end (graph degree >= 2 in the undirected connects
    graph) -- an ambush wants an approach lane, not a cul-de-sac,
  - its bounding-box diagonal clears ambush_radius=70 by a healthy margin
    (>=120u) so there is polygon for LURK repositioning and a real pounce,
    not an instant point-blank commit,
  - it's reachable from the player's spawn polygon over the undirected
    connects graph within a hop budget (the level's "main route"; very
    deep or isolated pockets are skipped -- a flicker no one ever
    encounters teaches nothing).

Terrain-shadow pockets (walk-mask rects, the OTHER kind of good hiding
spot) are not available for l07-l09 yet: no polygon textures/walkmasks are
shipped for these levels (only l01-l03 have assets/textures/lXX/ so far),
so `Sim.polygon_terrain()` returns [] everywhere here. This placement pass
relies on darkness alone; a follow-up pass should reconsider once l07-l09
textures land (recorded in the report, not faked here).

One flicker per selected polygon (never stacked, per the director's brief on
"common annoyance... not a boss"), spaced by a minimum hop count so they
read as seasoning across the level rather than a cluster. Output is
written back into levels/lXX.json (entities list, polygon-local position at
the polygon's centroid-ish "middle" of its dark footprint) AND a sibling
tools/flicker_placement_lXX.json audit log: one line per placement with
polygon index, level id, the polygon's bounding-box, and a plain-English
one-line justification, so the director can audit the judgment calls.

Usage:
    uv run python tools/flicker_placement.py --apply
    uv run python tools/flicker_placement.py --dry-run
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path
from random import Random

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "game"))

import os
os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

from perihelion.levels import load_level  # noqa: E402
from perihelion.sim import GameSession  # noqa: E402

LEVELS_DIR = ROOT / "levels"

# Adversary-territory levels and their seasoning target (director: "common
# annoyance... scale count to section size"). l07 is the transition (one
# isolated otherworld cell -- Adversary just breached, light presence);
# l08 carries a small otherworld cluster; l09 is saturated (72/253 cells
# otherworld) -- heaviest seasoning.
TARGETS = {
    "l07": dict(count=8, min_hop_gap=2),
    "l08": dict(count=11, min_hop_gap=2),
    "l09": dict(count=14, min_hop_gap=1),
}

MIN_DIAGONAL = 120.0   # polygon must be this big (bbox diagonal) for a pounce
MAX_HOPS = 40           # ignore pockets this deep from spawn (unreachable-ish)


def _bbox(verts):
    xs = [v[0] for v in verts]
    ys = [v[1] for v in verts]
    return min(xs), min(ys), max(xs), max(ys)


def _diagonal(verts):
    lox, loy, hix, hiy = _bbox(verts)
    return ((hix - lox) ** 2 + (hiy - loy) ** 2) ** 0.5


def _undirected_adjacency(level):
    adj: dict[int, set[int]] = {i: set() for i in range(len(level.polygon_verts))}
    for a, _ea, b, _eb in level.connects:
        adj[a].add(b)
        adj[b].add(a)
    for a, _ea, b, _eb, _m9 in level.connects_x:
        adj[a].add(b)
        adj[b].add(a)
    for d in level.doors:
        adj[d.a].add(d.b)
        adj[d.b].add(d.a)
    return adj


def _bfs_hops(adj, start):
    hops = {start: 0}
    frontier = [start]
    while frontier:
        nxt = []
        for u in frontier:
            for v in adj[u]:
                if v not in hops:
                    hops[v] = hops[u] + 1
                    nxt.append(v)
        frontier = nxt
    return hops


def analyze(level_id: str):
    """Returns (level, list of candidate dicts) for one level."""
    path = LEVELS_DIR / f"{level_id}.json"
    level = load_level(path)
    session = GameSession(level, seed=0)  # builds sim + static lighting cache
    lit_polygons = set(session.lighting._by_polygon.keys())
    adj = _undirected_adjacency(level)
    hops = _bfs_hops(adj, level.player_polygon)

    candidates = []
    for i, verts in enumerate(level.polygon_verts):
        kind = level.polygon_kinds[i]
        if kind == "otherworld":
            # otherworld cells are the Adversary's OWN turf -- soft-walled,
            # deliberately disorienting connective tissue, not a place a
            # lurker "hides" (it's already unheimlich by construction; the
            # director's brief is about ambush drama in navigable polygons).
            continue
        dark = i not in lit_polygons
        degree = len(adj[i])
        diag = _diagonal(verts)
        reachable = i in hops and hops[i] <= MAX_HOPS
        if dark and degree >= 2 and diag >= MIN_DIAGONAL and reachable:
            candidates.append(dict(
                polygon=i, kind=kind, degree=degree, diagonal=round(diag, 1),
                hops=hops[i], bbox=_bbox(verts),
            ))
    return level, candidates


def select_placements(level_id: str, level, candidates, count: int, min_hop_gap: int):
    """Greedy selection: prefer chokepoints (degree==2) and darker/bigger
    polygons, spread across the route by hop distance so placements read as
    seasoning, not a cluster. Deterministic (seeded RNG, level-id derived)
    per the campaign's determinism law."""
    rng = Random(f"flicker-placement-{level_id}")
    # score: chokepoints first (a pounce at a door-flank is dramatic), then
    # bigger polygons (more polygon to lurk/reposition), tie-broken by a stable
    # deterministic shuffle so re-runs are reproducible without favoring
    # polygon-index order.
    scored = sorted(
        candidates,
        key=lambda c: (0 if c["degree"] == 2 else 1, -c["diagonal"], c["polygon"]),
    )
    rng.shuffle(scored)  # break same-score ties without index bias
    scored.sort(key=lambda c: (0 if c["degree"] == 2 else 1, -c["diagonal"]))

    chosen = []
    used_hops = []
    for c in scored:
        if len(chosen) >= count:
            break
        if any(abs(c["hops"] - h) < min_hop_gap for h in used_hops):
            continue
        chosen.append(c)
        used_hops.append(c["hops"])
    chosen.sort(key=lambda c: c["hops"])
    return chosen


def justification(c: dict) -> str:
    parts = [f"dark (no static fixture reaches polygon {c['polygon']})"]
    if c["degree"] == 2:
        parts.append("chokepoint (degree 2 -- a through-polygon, pounce at the door-flank)")
    else:
        parts.append(f"junction (degree {c['degree']} -- multiple approach lanes)")
    parts.append(f"bbox diagonal {c['diagonal']}u (polygon for LURK repositioning + a real pounce)")
    parts.append(f"{c['hops']} hops from spawn on the main connects graph")
    return "; ".join(parts)


def _point_in_poly(pt, verts) -> bool:
    x, y = pt
    inside = False
    n = len(verts)
    for i in range(n):
        x1, y1 = verts[i]
        x2, y2 = verts[(i + 1) % n]
        if (y1 > y) != (y2 > y):
            xin = x1 + (y - y1) * (x2 - x1) / (y2 - y1 + 1e-300)
            if x < xin:
                inside = not inside
    return inside


MIN_SEPARATION = 26.0  # clear of every other entity's spawn point (largest
                        # enemy radius ~16 (warden) + flicker radius 8.5 +
                        # margin -- no entity spawns overlapping another)


def _find_clear_spot(verts, occupied, cx, cy):
    """Bbox center first choice; if it collides with an existing entity
    (or the polygon is thin enough that the center sits outside the polygon),
    spiral outward on an 8-direction ring at growing radii until a clear,
    in-polygon point is found. Always returns something inside `verts`
    (the polygon's own footprint is the fallback ring bound)."""
    def ok(p):
        if not _point_in_poly(p, verts):
            return False
        return all((p[0] - ox) ** 2 + (p[1] - oy) ** 2 >= MIN_SEPARATION ** 2
                    for ox, oy in occupied)

    if ok((cx, cy)):
        return cx, cy
    lox = min(v[0] for v in verts); hix = max(v[0] for v in verts)
    loy = min(v[1] for v in verts); hiy = max(v[1] for v in verts)
    max_r = max(hix - lox, hiy - loy)
    for step in range(1, 12):
        r = max_r * step / 24.0
        for k in range(8):
            ang = 2 * math.pi * k / 8
            p = (cx + r * math.cos(ang), cy + r * math.sin(ang))
            if ok(p):
                return p
    return cx, cy  # give up gracefully: center, even if snug (never crash)


def apply_placement(level_id: str, chosen: list[dict]) -> list[dict]:
    """Mutates levels/<level_id>.json in place: adds one 'flicker' entity
    per chosen polygon, near the polygon's bbox center (polygon-local coords, same
    space existing entities' `pos` already use in the file -- centroid of
    the authored verts is the safe, always-plausible starting point).
    Nudges off any existing entity in the polygon (spitter/pickup/etc.) so
    nothing spawns stacked exactly on top of something else -- see
    `_find_clear_spot`."""
    path = LEVELS_DIR / f"{level_id}.json"
    data = json.loads(path.read_text())
    log = []
    for c in chosen:
        polygon = data["polygons"][c["polygon"]]
        verts = polygon["verts"]
        cx = sum(v[0] for v in verts) / len(verts)
        cy = sum(v[1] for v in verts) / len(verts)
        occupied = [tuple(e["pos"]) for e in polygon["entities"]]
        px, py = _find_clear_spot(verts, occupied, cx, cy)
        polygon["entities"].append({
            "type": "flicker",
            "pos": [round(px, 1), round(py, 1)],
            "props": {},
        })
        log.append(dict(level=level_id, polygon=c["polygon"], pos=[round(px, 1), round(py, 1)],
                         justification=justification(c)))
    path.write_text(json.dumps(data, indent=1) + "\n")
    return log


def main(argv=None) -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="write placements into levels/*.json")
    ap.add_argument("--dry-run", action="store_true", help="print candidates/choices, write nothing")
    ap.add_argument("--levels", nargs="*", default=list(TARGETS), help="subset of target level ids")
    args = ap.parse_args(argv)

    all_log = []
    for level_id in args.levels:
        cfg = TARGETS[level_id]
        level, candidates = analyze(level_id)
        chosen = select_placements(level_id, level, candidates, cfg["count"], cfg["min_hop_gap"])
        print(f"{level_id}: {len(candidates)} candidate dark/chokepoint polygons, "
              f"choosing {len(chosen)} (target {cfg['count']})")
        for c in chosen:
            print(f"  polygon {c['polygon']:4d}  hops={c['hops']:3d}  deg={c['degree']}  "
                  f"diag={c['diagonal']:.0f}u  -- {justification(c)}")
        if args.apply:
            log = apply_placement(level_id, chosen)
            all_log.extend(log)
            print(f"  -> written into levels/{level_id}.json")

    if args.apply and all_log:
        audit_path = ROOT / "tools" / "flicker_placement_log.json"
        existing = []
        if audit_path.exists():
            existing = json.loads(audit_path.read_text())
        existing = [e for e in existing if e["level"] not in args.levels] + all_log
        audit_path.write_text(json.dumps(existing, indent=1) + "\n")
        print(f"audit log -> {audit_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
