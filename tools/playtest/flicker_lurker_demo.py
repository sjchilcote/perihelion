"""Shadow-lurker enemy -- verification capture (director's directive,
2026-07-13): "add an enemy that deliberately keeps to the shadows until
the player gets close, then ambushes." THROWAWAY fixture, tooling-only,
not placed in any shipped campaign level (director's placement call):
dark polygon, terrain (synthetic walk-mask), one flicker holding in the
terrain's shadow with a flickering trace, a bot walking past and
triggering the pounce. Follows the same one-take-ffmpeg tradition as
tools/playtest/terrain_shadow_demo.py / light_occlusion_demo.py.

Usage:
    uv run python tools/playtest/flicker_lurker_demo.py [--out PATH] [--quick]
"""
from __future__ import annotations

import argparse
import os
import subprocess
import sys
from pathlib import Path

os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402

import necore  # noqa: E402
from perihelion.levels import LevelBuilder, LightSpec  # noqa: E402
from perihelion.render import Renderer, INTERNAL_W, INTERNAL_H  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402

OUT_W, OUT_H = 1280, 720
FPS = 60

TERRAIN_RECT = (-40.0, -50.0, 40.0, 30.0)  # lo_x, lo_y, hi_x, hi_y
FIXTURE = LightSpec(polygon=0, pos=(-230.0, 40.0), color=(210, 220, 255),
                     intensity=1.1, radius=340.0, kind="static")
LURKER_SPAWN = (100.0, -10.0)  # in the terrain rect's cast shadow


def build_world():
    """One dim polygon: a single dim fixture near the entrance (leaves most
    of the polygon dark, per the director's "dark polygon" ask), one terrain
    rect casting a shadow, the flicker holds inside that shadow."""
    b = LevelBuilder("FLICKDEMO", 1)
    r0 = b.rect(-260.0, -140.0, 520.0, 280.0)
    b.player(r0, (-230.0, 60.0))
    level = b.build()
    return level, r0


DEMO_FLOOR_ALBEDO = (150, 150, 158)  # dim, not the bright verification albedo


def apply_demo_floor(ren, level):
    for polygon in range(len(level.polygon_verts)):
        ren._floor_color_cache[polygon] = DEMO_FLOOR_ALBEDO


#: waypoints (polygon-local): approach along the north side (like the terrain
#: demo), then walk PAST the lurker's shadow position closely enough to
#: cross its ambush_radius and trigger the pounce.
WAYPOINTS = [
    ((-230.0, 60.0), 15),
    ((-140.0, -90.0), 8),
    ((20.0, -90.0), 8),
    ((60.0, -30.0), 30),    # closes to within ambush_radius of the lurker
    ((150.0, 40.0), 60),    # continue past -- lets the pounce play out on camera
]
MARK_NAMES = ["start", "cleared_rect", "approach", "trigger_zone", "aftermath"]


def _drive(session):
    """Waypoint-chase, same pattern as `terrain_shadow_demo.py`, but with a
    PER-WAYPOINT (not just global) timeout that gives up and moves on
    instead of hanging: once the lurker commits, it rams the player
    (contact knockback) on every touch, which can keep the player just
    outside a 6-unit arrival radius indefinitely -- a real gameplay
    outcome (a fight in progress), not a bug in this tool, so the capture
    should keep rolling through it rather than crash."""
    tick = 0
    for name, ((tx, ty), hold_ticks) in zip(MARK_NAMES, WAYPOINTS):
        stall = 0
        waypoint_ticks = 0
        while True:
            px, py = session.player_pos().local()
            dx, dy = tx - px, ty - py
            dist = (dx * dx + dy * dy) ** 0.5
            mark = None
            if dist < 6.0:
                stall += 1
                mx = my = 0.0
                if stall == hold_ticks:
                    mark = name
                if stall > hold_ticks:
                    break
            else:
                mx, my = dx / dist, dy / dist
            tick += 1
            waypoint_ticks += 1
            yield mx, my, mark
            if waypoint_ticks > 500:
                # give up on precise arrival for this waypoint (a fight in
                # progress can keep shoving the player around); still fire
                # its mark once so the capture has a still for it.
                yield 0.0, 0.0, name
                tick += 1
                break
            if tick > 6000:
                raise RuntimeError(f"waypoint {name} unreachable")


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str,
                    default=str(ROOT / "media" / "enemies" /
                                "flicker_lurker_proof_2026-07-13.mp4"))
    ap.add_argument("--quick", action="store_true")
    args = ap.parse_args()

    level, r0 = build_world()
    session = GameSession(level, seed=13, screen=(INTERNAL_W, INTERNAL_H))
    session.sim.set_polygon_terrain(r0, [TERRAIN_RECT])  # terrain FIRST
    fixture = LightSpec(polygon=r0, pos=FIXTURE.pos, color=FIXTURE.color,
                         intensity=FIXTURE.intensity, radius=FIXTURE.radius,
                         kind=FIXTURE.kind)
    session.lighting.add_lights(session.sim, [fixture])  # ...THEN the light
    lurker = session.spawn_enemy(r0, LURKER_SPAWN, "flicker")
    ren = Renderer(session)
    apply_demo_floor(ren, level)
    size = (INTERNAL_W, INTERNAL_H)

    out_path = Path(args.out)
    stills_dir = out_path.parent / "stills"
    stills_dir.mkdir(parents=True, exist_ok=True)

    ffmpeg = None
    if not args.quick:
        out_path.parent.mkdir(parents=True, exist_ok=True)
        ffmpeg = subprocess.Popen([
            "ffmpeg", "-y", "-f", "rawvideo", "-pixel_format", "rgb24",
            "-video_size", f"{OUT_W}x{OUT_H}", "-framerate", str(FPS),
            "-i", "-", "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p",
            "-crf", "18", "-preset", "medium", "-g", "15", str(out_path),
        ], stdin=subprocess.PIPE)

    drive = _drive(session)
    tick = 0
    frames = 0
    mark_ticks: dict[int, str] = {}
    states: dict[str, str] = {}
    while True:
        try:
            mx, my, mark = next(drive)
        except StopIteration:
            break
        tick += 1
        session.tick(InputFrame(mx=mx, my=my, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                                fire=False, alt=False, interact=False, weapon=0))
        ren.consume_fx(session.fx)
        frame = ren.draw(size)
        if ffmpeg is not None:
            rows = np.ascontiguousarray(frame.transpose(1, 0, 2))
            if (INTERNAL_W, INTERNAL_H) != (OUT_W, OUT_H):
                rows = np.asarray(Image.fromarray(rows).resize(
                    (OUT_W, OUT_H), Image.BILINEAR))
            ffmpeg.stdin.write(rows.tobytes())
        frames += 1
        if mark is not None:
            mark_ticks[tick] = mark
            e = session.enemies.get(lurker)
            states[mark] = e["state"] if e else "dead"
            necore.write_png(str(stills_dir / f"{mark}.png"),
                             INTERNAL_W, INTERNAL_H,
                             np.ascontiguousarray(
                                 frame.transpose(1, 0, 2)).tobytes())
        # keep capturing a bit past the last scripted waypoint so the
        # pounce/commit itself (which may trail the "trigger_zone" mark by
        # a handful of ticks) is fully on camera.
        if mark == "aftermath":
            for _ in range(60):
                session.tick(InputFrame(mx=0, my=0, ax=INTERNAL_W / 2,
                                        ay=INTERNAL_H / 2, fire=False, alt=False,
                                        interact=False, weapon=0))
                ren.consume_fx(session.fx)
                frame = ren.draw(size)
                if ffmpeg is not None:
                    rows = np.ascontiguousarray(frame.transpose(1, 0, 2))
                    if (INTERNAL_W, INTERNAL_H) != (OUT_W, OUT_H):
                        rows = np.asarray(Image.fromarray(rows).resize(
                            (OUT_W, OUT_H), Image.BILINEAR))
                    ffmpeg.stdin.write(rows.tobytes())
                frames += 1

    if ffmpeg is not None:
        ffmpeg.stdin.close()
        ffmpeg.wait()
        print(f"wrote {out_path}: {frames} frames = {frames / FPS:.1f}s")
    else:
        print(f"quick run: {frames} frames, stills in {stills_dir}, "
              f"marks={sorted(mark_ticks.items())}, states={states}")
        return 0

    print("\n--- lurker state at each mark ---")
    fail = False
    for tick, name in sorted(mark_ticks.items()):
        print(f"[{name}] t={(tick - 1) / FPS:.2f}s state={states[name]}")
    if states.get("start") != "lurk" or states.get("cleared_rect") != "lurk" \
            or states.get("approach") != "lurk":
        print("!! lurker left LURK before the player got close -- unexpected")
        fail = True
    if states.get("trigger_zone") not in ("ambush", "hunt") \
            and states.get("aftermath") not in ("ambush", "hunt"):
        print("!! lurker never committed even after the player closed in")
        fail = True
    print(f"\nstills: {stills_dir}")
    if fail:
        print("\nVERIFICATION FAILED")
        return 1
    print("\nVERIFICATION OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
