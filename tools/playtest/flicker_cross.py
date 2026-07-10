"""Flicker cross harness (director-ordered minimal reproduction rig).

A square room with four square neighbors, high-contrast chip decals in
every neighbor: pixel ground truth for the decor-flicker defect. Every
tick renders through the REAL game path (GameSession.visible -> Renderer)
and probes the decal pixels per neighbor. Any tick where a neighbor's ink
collapses while the player barely moved is a flicker event: the offending
frame pair is dumped as PNGs for eye verification, alongside the visible
instance sets at those ticks.

Two worlds:
  cross    -- pure 4-neighbor cross (single chain to every neighbor)
  braided  -- same cross plus ring connections between the neighbors
              (two+ chains reach every room; exercises dedup/traversal
              churn and the max_instances=96 cap, the prime suspects)

Usage:
  uv run python tools/playtest/flicker_cross.py [--world cross|braided]
      [--ticks N] [--out DIR]
Exit code 1 if any flicker event was detected.
"""
from __future__ import annotations

import argparse
import json
import math
import os
import random
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

sys.path.insert(0, str(Path(__file__).resolve().parents[2] / "game"))

import pygame  # noqa: E402

import necore  # noqa: E402
from perihelion.levels import LevelBuilder  # noqa: E402
from perihelion.render import Renderer, INTERNAL_W, INTERNAL_H  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402

S = 120.0          # room side, world units
DOOR = 24.0        # doorway width
NEIGHBORS = {"N": (0.0, -1.0), "S": (0.0, 1.0), "E": (1.0, 0.0), "W": (-1.0, 0.0)}


def _room_with_doors(b: LevelBuilder, x: float, y: float, kind: str) -> int:
    """Square room with a centered DOOR-length collinear segment on every
    side (the campaign's carved-doorway shape, not a full open edge)."""
    lo = (S - DOOR) / 2.0
    hi = (S + DOOR) / 2.0
    verts = [
        (x, y), (x, y + lo), (x, y + hi), (x, y + S),
        (x + lo, y + S), (x + hi, y + S), (x + S, y + S),
        (x + S, y + hi), (x + S, y + lo), (x + S, y),
        (x + hi, y), (x + lo, y),
    ]
    return b.room(verts, detail_seed=int(x * 7 + y * 13) & 0xFFFF, kind=kind)


def build_world(braided: bool):
    b = LevelBuilder("flicker-cross" + ("-braided" if braided else ""),
                     tier=1, ambience="amb_drone_early")
    rooms = {"C": _room_with_doors(b, 0, 0, "corridor")}
    offs = {"N": (0, -S), "S": (0, S), "E": (S, 0), "W": (-S, 0)}
    for name, (dx, dy) in offs.items():
        rooms[name] = _room_with_doors(b, dx, dy, "corridor")
        # connect by shared-door midpoint (safe across the splitter)
        mid = (dx / 2 + S / 2 + (dx / 2), dy / 2 + S / 2 + (dy / 2))
        mx = S / 2 + dx / 2 * 1.0 + (dx and (dx / abs(dx)) * 0 or 0)
        # midpoint of the shared edge in authored coords:
        emx = S / 2 + (dx / 2 if dx else 0) + (S / 2 * (dx / S) if dx else 0)
        # keep it simple: shared edge midpoint
        ex = S / 2 + (S / 2) * (dx / S) if dx else S / 2
        ey = S / 2 + (S / 2) * (dy / S) if dy else S / 2
        b.connect_pts(rooms["C"], (ex, ey), rooms[name], (ex, ey))
    if braided:
        # ring: N-E, E-S, S-W, W-N via diagonal corner rooms so every
        # neighbor is reachable by 2+ chains of different depth
        diag = {"NE": (S, -S), "SE": (S, S), "SW": (-S, S), "NW": (-S, -S)}
        ring = {}
        for name, (dx, dy) in diag.items():
            ring[name] = _room_with_doors(b, dx, dy, "corridor")
        pairs = [("N", "NE", "E"), ("E", "SE", "S"), ("S", "SW", "W"), ("W", "NW", "N")]
        for a, d, c in pairs:
            (ax, ay), (dx_, dy_) = offs[a], diag[d]
            # shared edge midpoint between neighbor a and diagonal d
            exm = (max(ax, dx_) if ax != dx_ else ax + S / 2)
            eym = (max(ay, dy_) if ay != dy_ else ay + S / 2)
            if ax == dx_:
                exm = ax + S / 2
                eym = max(ay, dy_) if ay != dy_ else ay
                eym = (ay + dy_) / 2 + S
                eym = max(ay, dy_)
            else:
                exm = max(ax, dx_)
                eym = ay + S / 2
            b.connect_pts(rooms[a], (exm, eym), ring[d], (exm, eym))
            (cx2, cy2) = offs[c]
            if cx2 == dx_:
                ex2, ey2 = cx2 + S / 2, max(cy2, dy_)
            else:
                ex2, ey2 = max(cx2, dx_), cy2 + S / 2
            b.connect_pts(ring[d], (ex2, ey2), rooms[c], (ex2, ey2))
    b.player(rooms["C"], (S / 2, S / 2))
    b.exit(rooms["N"], (S / 2, -S / 2))
    return b.build(), rooms


def build_grid(n: int = 7):
    """n x n fully-doorwayed grid -- from the center the visible set can
    legitimately exceed the max_instances=96 cap, like the campaign's
    open sightline runs. Every room carries probe decals."""
    b = LevelBuilder("flicker-grid", tier=1, ambience="amb_drone_early")
    rooms = {}
    for i in range(n):
        for j in range(n):
            rooms[f"r{i}_{j}"] = _room_with_doors(b, j * S, i * S, "corridor")
    for i in range(n):
        for j in range(n):
            if j + 1 < n:
                b.connect_pts(rooms[f"r{i}_{j}"], ((j + 1) * S, i * S + S / 2),
                              rooms[f"r{i}_{j + 1}"], ((j + 1) * S, i * S + S / 2))
            if i + 1 < n:
                b.connect_pts(rooms[f"r{i}_{j}"], (j * S + S / 2, (i + 1) * S),
                              rooms[f"r{i}_{j + 1 - 1}"] if False else rooms[f"r{i + 1}_{j}"],
                              (j * S + S / 2, (i + 1) * S))
    c = n // 2
    b.player(rooms[f"r{c}_{c}"], (c * S + S / 2, c * S + S / 2))
    b.exit(rooms["r0_0"], (S / 2, S / 2))
    return b.build(), rooms, f"r{c}_{c}"


ARROW = [(0.0, 0.0), (14.0, 0.0), (9.0, -5.0), (9.0, 5.0)]  # shaft+head pts


def plant_decals(session, rooms, probe_rooms=None):
    """Chip decals in a plus/arrow pattern at each probe room's local
    center. Chips draw as bright X marks -- ideal pixel probes. Positions
    are in the room's CENTERED local frame."""
    targets = probe_rooms if probe_rooms is not None else \
        {k: rooms[k] for k in NEIGHBORS}
    for name, r in targets.items():
        pts = [(0.0, 0.0), (14.0, 0.0), (-14.0, 0.0), (0.0, 14.0), (0.0, -14.0),
               (26.0, 0.0), (-26.0, 0.0)]
        session.decals[r] = [("chip", x, y, 5.0, 0.0) for x, y in pts]


def _xform_of(inst):
    for e in inst:
        if isinstance(e, (tuple, list)) and len(e) == 9 \
                and all(isinstance(v, float) for v in e):
            return tuple(e)
    raise RuntimeError(f"no 9-float xform in instance: {inst!r}")


def probe_ink(surf, xform, decal_pts) -> int:
    """Count bright pixels in 9x9 boxes at each decal's screen position."""
    w, h = surf.get_size()
    ink = 0
    for (x, y) in decal_pts:
        sx, sy = necore.mat_apply(xform, x, y)
        sx, sy = int(sx), int(sy)
        for py in range(max(0, sy - 4), min(h, sy + 5)):
            for px in range(max(0, sx - 4), min(w, sx + 5)):
                r, g, bl, *_ = surf.get_at((px, py))
                if r > 85 and g > 85:
                    ink += 1
    return ink


def movement(tick: int) -> tuple[float, float]:
    """Deterministic tour: stand, then approach/strafe at each doorway."""
    if tick < 120:
        return 0.0, 0.0
    t = tick - 120
    phase, local = divmod(t, 300)
    d = "NESW"[phase % 4]
    dx, dy = NEIGHBORS[{"N": "N", "E": "E", "S": "S", "W": "W"}[d]]
    if local < 100:                       # walk toward the doorway
        return dx, dy
    if local < 220:                       # strafe oscillation at the threshold
        s = math.sin(local * 0.31)
        return (s * -dy * 0.9, s * dx * 0.9)
    return -dx, -dy                       # walk back to center


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--world", choices=("cross", "braided", "grid"), default="cross")
    ap.add_argument("--ticks", type=int, default=1400)
    ap.add_argument("--grid-n", type=int, default=7)
    ap.add_argument("--out", type=str, default=None)
    args = ap.parse_args()

    out = Path(args.out) if args.out else Path(
        os.environ.get("FLICKER_OUT", "/tmp/flicker_cross")) / args.world
    out.mkdir(parents=True, exist_ok=True)

    pygame.init()
    if args.world == "grid":
        level, rooms, center = build_grid(args.grid_n)
        probe_rooms = {k: v for k, v in rooms.items() if k != center}
    else:
        level, rooms = build_world(args.world == "braided")
        probe_rooms = {k: rooms[k] for k in NEIGHBORS}
    session = GameSession(level, seed=7, screen=(INTERNAL_W, INTERNAL_H))
    plant_decals(session, rooms, probe_rooms)
    ren = Renderer(session)
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    prev_surf = pygame.Surface((INTERNAL_W, INTERNAL_H))

    decal_local = {name: [(x, y) for _, x, y, _, _ in session.decals[r]]
                   for name, r in probe_rooms.items()}

    log = []
    events = []
    prev = None
    prev_pos = None
    for tick in range(1, args.ticks + 1):
        mx, my = movement(tick)
        session.tick(InputFrame(mx=mx, my=my, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                                fire=False, alt=False, interact=False, weapon=0))
        random.seed(tick)
        ren.consume_fx(session.fx)
        prev_surf.blit(surf, (0, 0))
        ren.draw(surf)

        vis = session.visible()
        by_room: dict[int, list] = {}
        for inst in vis:
            by_room.setdefault(inst[0], []).append(inst)

        px, py = session.player_pos()
        moved = 0.0 if prev_pos is None else math.hypot(px - prev_pos[0], py - prev_pos[1])
        prev_pos = (px, py)

        row = {"tick": tick, "n_inst": len(vis), "moved": round(moved, 3)}
        for name, r in probe_rooms.items():
            insts = by_room.get(r, [])
            ink = 0
            if insts:
                ink = max(probe_ink(surf, _xform_of(i), decal_local[name])
                          for i in insts)
            row[name] = {"inst": len(insts), "ink": ink}
        log.append(row)

        if prev is not None:
            for name in probe_rooms:
                a, b_ = prev[name], row[name]
                if (a["inst"] > 0 and a["ink"] >= 15 and moved < 3.0
                        and (b_["inst"] == 0 or b_["ink"] < 0.3 * a["ink"])):
                    ev = {"tick": tick, "room": name, "before": a, "after": b_,
                          "moved": round(moved, 3), "n_inst": row["n_inst"]}
                    events.append(ev)
                    if len(events) <= 20:
                        pygame.image.save(prev_surf, str(out / f"ev{len(events):03d}_t{tick - 1}.png"))
                        pygame.image.save(surf, str(out / f"ev{len(events):03d}_t{tick}.png"))
        prev = row

    (out / "log.json").write_text(json.dumps(log))
    (out / "events.json").write_text(json.dumps(events, indent=2))
    n_cap = sum(1 for r in log if r["n_inst"] >= 96)
    print(f"world={args.world} ticks={args.ticks} events={len(events)} "
          f"ticks_at_instance_cap={n_cap} "
          f"max_inst={max(r['n_inst'] for r in log)} out={out}")
    for ev in events[:12]:
        print("  ", json.dumps(ev))
    return 1 if events else 0


if __name__ == "__main__":
    raise SystemExit(main())
