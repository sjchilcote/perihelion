"""Light-authoring preview: render in-game stills of a level from chosen
rooms, through the REAL render path (zero ambient, lightmap multiply,
floor textures, per-light occluded wedges) -- the visual-iteration loop
for placing `lights` in levels/*.json.

    uv run python tools/playtest/light_preview.py --level levels/l02.json \
        --rooms 0,7,23 [--out /tmp/l02_preview]
    uv run python tools/playtest/light_preview.py --level levels/l02.json \
        --sweep 12          # every 12th room
    uv run python tools/playtest/light_preview.py --level levels/l02.json \
        --list              # rooms, kinds, sizes, current lights; no render

Each still is rendered with the player reseated at that room's local
center (work lamp ON, exactly as in play -- what you see is what ships).
Files land as <out>/room_NNN.png at the 1280x720 internal res.

Authoring facts the JSON author needs (the hard-won ones):

  * `lights` entries: {"room": int, "pos": [x, y], "color": [r, g, b],
    "intensity": float, "radius": float, "kind": "static"}.
    `pos` is in the SAME authoring-canvas coordinates as that room's
    "verts" in the JSON (the loader recenters both together).
  * BRIGHTNESS CHAIN: zero ambient means the lightmap MULTIPLIES the
    world layer -- final pixel = floor_albedo x tint x falloff^2. Rooms
    with bespoke floor textures (all campaign levels) have albedo
    ~100-150, so a saturated lightmap reads bright; there is no ambient
    to hide a weak light.
  * HUE CLAMP: the render tint is min(255, channel * intensity *
    LIGHT_STRENGTH) per channel with LIGHT_STRENGTH = 3.0. A COLORED
    light above intensity 1/3 clamps its dominant channels and whitens
    toward pure white. intensity == 1/3 reproduces the authored color
    exactly; brightness beyond that comes from radius (falloff is
    (1 - dist/radius)^2, so a wide radius keeps the core near-full).
    White/near-white fixtures can run higher intensity freely -- there
    is no hue to lose, and the saturated core reads as a hot center.
  * THROW = FAN ANGLE: a light's wedge through a doorway fans with
    half-angle atan(half_door_width / distance-to-door). Close to a
    door: wide dramatic spill. Far from it: a narrow beam.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import pygame  # noqa: E402

from perihelion.levels import load_level  # noqa: E402
from perihelion.render import Renderer, INTERNAL_W, INTERNAL_H  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--level", required=True)
    ap.add_argument("--rooms", type=str, default=None,
                    help="comma-separated room indices to render from")
    ap.add_argument("--sweep", type=int, default=None,
                    help="render every Nth room")
    ap.add_argument("--list", action="store_true",
                    help="print rooms (kind, centroid, #verts) and lights")
    ap.add_argument("--out", type=str, default=None)
    ap.add_argument("--settle", type=int, default=5,
                    help="ticks to run before each still")
    args = ap.parse_args()

    level_path = ROOT / args.level if not os.path.isabs(args.level) else Path(args.level)
    level = load_level(level_path)
    n = len(level.room_verts)

    if args.list:
        raw = json.loads(Path(level_path).read_text())
        print(f"{level.name}: {n} rooms, {len(level.lights)} lights, "
              f"tier {level.tier}")
        for i in range(n):
            cx, cy = level.room_centroids[i]
            kind = level.room_kinds[i]
            print(f"  room {i:3d} kind={kind:12s} centroid=({cx:7.1f},{cy:7.1f}) "
                  f"verts={len(level.room_verts[i])}")
        for li, lt in enumerate(raw.get("lights", [])):
            print(f"  light {li}: room {lt['room']} pos={lt['pos']} "
                  f"color={lt.get('color')} intensity={lt.get('intensity')} "
                  f"radius={lt.get('radius')}")
        return 0

    if args.rooms:
        rooms = [int(r) for r in args.rooms.split(",")]
    elif args.sweep:
        rooms = list(range(0, n, args.sweep))
    else:
        ap.error("need --rooms, --sweep, or --list")
        return 2

    out = Path(args.out) if args.out else \
        Path("/tmp") / f"light_preview_{Path(args.level).stem}"
    out.mkdir(parents=True, exist_ok=True)

    pygame.init()
    session = GameSession(level, seed=1, screen=(INTERNAL_W, INTERNAL_H))
    ren = Renderer(session)
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    idle = InputFrame(mx=0, my=0, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                      fire=False, alt=False, interact=False, weapon=0)
    for room in rooms:
        if room < 0 or room >= n:
            print(f"  !! room {room} out of range, skipped")
            continue
        session.reseat_player(room, (0.0, 0.0))
        for _ in range(args.settle):
            session.tick(idle)
        ren.consume_fx(session.fx)
        ren.draw(surf)
        p = out / f"room_{room:03d}.png"
        pygame.image.save(surf, str(p))
        print(f"  wrote {p}")
    print(f"done: {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
