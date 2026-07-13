"""tools/artgen/decal_plan.py

Decal diegesis review (director's order, 2026-07-13, workstream 3):
"every single thing on screen must have an in-world justification."
Audits/plans every wayfinding arrow the pipeline is allowed to place --
each one must point at a REAL destination in the level topology (derived
from the level JSON room graph via BFS to real hub rooms: dock = cargo
egress, transit = lift/junction), not be decorative.

NO_SIGNAGE_LAW in pilot_texture_lib.py already imposes a BLANKET ban on
arrows/chevrons/signage in every room prompt (root-caused 2026-07-11: baked
per-kind material text/arrows repeated at tile period across every room of
a kind). That ban stays -- it is the correct default (an arrow with no
justification is exactly the defect the director is flagging). This module
adds the single narrow, data-driven EXCEPTION: a specific room on a real
route to a real hub may carry exactly one arrow, pointing at the specific
doorway edge that continues toward that hub, with a one-line in-world
justification recorded in the plan. Rooms with no route to a hub, or
outside MIRIAD-reach (TESTATOR_KINDS per authorship-lanes), get none.

Usage:
    uv run python -m tools.artgen.decal_plan --level l01   # print one level's plan
    uv run python -m tools.artgen.decal_plan --all --out tools/artgen/decal_plans.json
"""
from __future__ import annotations

import argparse
import json
import math
from collections import deque
from pathlib import Path

from tools.artgen.pilot_texture_lib import TESTATOR_KINDS, get_level, room_doorway_edges

HUB_KINDS = {"dock", "transit"}  # real navigable destinations an arrow can justify

LEVEL_STEMS = [f"l{n:02d}" for n in range(1, 11)] + ["vigil"]


def _room_graph(level) -> dict[int, list[tuple[int, int, int]]]:
    """room_idx -> [(neighbor_room_idx, my_edge_idx, neighbor_edge_idx), ...]"""
    adj: dict[int, list[tuple[int, int, int]]] = {i: [] for i in range(len(level.room_verts))}
    pairs = list(level.connects) + [(c[0], c[1], c[2], c[3]) for c in level.connects_x]
    pairs += [(d.a, d.ea, d.b, d.eb) for d in level.doors]
    for a, ea, b, eb in pairs:
        adj[a].append((b, ea, eb))
        adj[b].append((a, eb, ea))
    return adj


def build_level_decal_plan(stem: str) -> dict:
    """BFS from every HUB_KINDS room outward (multi-source), recording for
    each non-hub room the next hop back TOWARD its nearest hub. A room on
    that shortest-path tree gets an arrow decal on the edge leading to its
    parent (i.e. pointing further toward the hub), with a justification
    naming the actual hub room and kind. TESTATOR_KINDS rooms never get a
    mark (authorship-lanes: MIRIAD wayfinding signage does not belong in
    Testator-pure space)."""
    level = get_level(stem)
    n = len(level.room_verts)
    adj = _room_graph(level)
    kinds = level.room_kinds

    hubs = [i for i in range(n) if kinds[i] in HUB_KINDS]
    dist = [-1] * n
    parent_edge: dict[int, tuple[int, int]] = {}  # room -> (parent_room, my_edge_to_parent)
    q = deque()
    for h in hubs:
        dist[h] = 0
        q.append(h)
    while q:
        u = q.popleft()
        for v, eu, ev in adj[u]:
            if dist[v] == -1:
                dist[v] = dist[u] + 1
                parent_edge[v] = (u, ev)  # from v, exit via edge ev to reach u
                q.append(v)

    marks = []
    for i in range(n):
        if kinds[i] in HUB_KINDS or kinds[i] in TESTATOR_KINDS:
            continue
        if i not in parent_edge:
            continue  # no route to any hub -- no arrow (nothing real to point at)
        # DECISION-POINT RESTRICTION (director's diegesis complaint, this
        # order: "arrows everywhere don't appear to actually do anything").
        # A straight-through corridor with exactly one way to go needs no
        # sign -- a real wayfinding mark only earns its place where a
        # person actually has to CHOOSE, i.e. a junction with 3+ doorways.
        # Without this, BFS-to-nearest-hub marks nearly every room on the
        # level (measured: 115/120 on l01, the same "everywhere" defect
        # under new data) -- restricting to junctions is what makes the
        # system read as coherent wayfinding instead of wallpaper.
        if len(adj[i]) < 3:
            continue
        parent_room, my_edge = parent_edge[i]
        # walk the parent chain to the actual hub room for the justification text
        hub_room = i
        steps = 0
        while kinds[hub_room] not in HUB_KINDS and hub_room in parent_edge:
            hub_room = parent_edge[hub_room][0]
            steps += 1
            if steps > n:
                break
        door_edges = room_doorway_edges(stem, i)
        if my_edge not in door_edges:
            continue  # defensive: only mark real doorway edges
        marks.append(dict(
            room=i, kind=kinds[i], edge=my_edge,
            hub_room=hub_room, hub_kind=kinds[hub_room] if hub_room < n else "?",
            hops_to_hub=dist[i],
            justification=(
                f"wayfinding arrow at room {i} ({kinds[i]}) points through edge {my_edge} "
                f"toward room {hub_room} ({kinds[hub_room] if hub_room < n else '?'}), "
                f"{dist[i]} doorway(s) away -- the nearest real "
                f"{'cargo dock' if kinds[hub_room] == 'dock' else 'transit lift/junction'} "
                "on this level's own room graph."
            ),
        ))

    unreachable = [i for i in range(n)
                   if i not in parent_edge and kinds[i] not in HUB_KINDS and kinds[i] not in TESTATOR_KINDS]
    return dict(level=stem, n_rooms=n, n_hubs=len(hubs), hub_rooms=hubs,
                n_marks=len(marks), marks=marks,
                n_unreachable_no_mark=len(unreachable), unreachable_rooms=unreachable)


def decal_prompt_note(marks_for_room: list[dict], stem: str, room_idx: int) -> str:
    """Prompt-language override for the ONE narrow exception to
    NO_SIGNAGE_LAW's blanket arrow ban -- only emitted for a room the
    decal plan actually marked. Points at a specific doorway edge, not a
    vague direction, so the arrow is verifiably load-bearing."""
    my_marks = [m for m in marks_for_room if m["room"] == room_idx]
    if not my_marks:
        return ""
    lines = [
        f"- one small worn directional floor arrow/chevron pointing toward doorway "
        f"edge {m['edge']} of this room ({m['justification']})"
        for m in my_marks
    ]
    return (
        "JUSTIFIED WAYFINDING EXCEPTION to the no-signage rule below: this "
        "specific room is on a real route to a real destination in the "
        "level, so exactly this one wayfinding mark is PERMITTED (nothing "
        "else -- still zero text/lettering, zero other arrows):\n"
        + "\n".join(lines) + "\n\n"
    )


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", type=str, default=None)
    ap.add_argument("--all", action="store_true")
    ap.add_argument("--out", type=str, default=None)
    args = ap.parse_args()

    if args.all:
        plans = {stem: build_level_decal_plan(stem) for stem in LEVEL_STEMS}
        total_marks = sum(p["n_marks"] for p in plans.values())
        print(f"total marks across {len(plans)} levels: {total_marks}")
        if args.out:
            Path(args.out).write_text(json.dumps(plans, indent=2))
            print(f"wrote {args.out}")
        return

    stem = args.level or "l01"
    plan = build_level_decal_plan(stem)
    print(json.dumps({k: v for k, v in plan.items() if k not in ("marks",)}, indent=2))
    print(f"\nfirst 5 marks:")
    for m in plan["marks"][:5]:
        print(" ", m["justification"])


if __name__ == "__main__":
    main()
