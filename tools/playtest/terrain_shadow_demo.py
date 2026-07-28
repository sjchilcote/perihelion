"""Walk-mask terrain blocks lamp light -- verification capture (director's
directive, 2026-07-13). THROWAWAY fixture, tooling-only, not part of the
shipped campaign: one bright fixture, terrain rects between it and the
open floor, a bot walking through the resulting shadow band and back out
into the light. Follows the same one-take-ffmpeg tradition as
tools/playtest/light_occlusion_demo.py (world-builder + deterministic
scripted drive, probes sampled from the ENCODED mp4, same-artifact rule).

Usage:
    uv run python tools/playtest/terrain_shadow_demo.py [--out PATH] [--quick]
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
LIT_MIN = 60.0
DARK_MAX = 12.0


FIXTURE = LightSpec(polygon=0, pos=(-230.0, 0.0), color=(255, 225, 180),
                     intensity=1.3, radius=520.0, kind="static")


def build_world():
    """One polygon, one terrain rect (synthetic walk-mask, no PNG on disk
    needed -- this tool installs the rects directly via
    `Sim.set_polygon_terrain`) between the fixture and open floor.

    Deliberately does NOT put `FIXTURE` in `level.lights`: a static light's
    shadow geometry is cached ONCE, at whatever moment it's registered
    with `LightingSystem` (level construction, here `GameSession.__init__`)
    -- caching it before terrain exists on the polygon bakes in an empty
    shadow forever (confirmed fail-first while building this tool: the
    'in_shadow' probe read ~30/255, not black, because the cached instance
    predated `set_polygon_terrain`). The caller must install terrain FIRST,
    then register the fixture via `session.lighting.add_lights(...)`."""
    b = LevelBuilder("TSHADDEMO", 1)
    r0 = b.rect(-260.0, -140.0, 520.0, 280.0)
    b.player(r0, (-230.0, 60.0))
    level = b.build()
    return level, r0


# Close enough to the fixture that the distance-falloff kernel alone still
# leaves plenty of headpolygon between "lit" and "dark" samples -- the light's
# radius (520) makes anything much past ~350 units from the apex read dim
# from distance ALONE, which would make a demo point's dimness ambiguous
# (shadow? or just far away?) instead of a clean binary contrast.
TERRAIN_RECT = (-140.0, -50.0, -60.0, 30.0)  # lo_x, lo_y, hi_x, hi_y


DEMO_FLOOR_ALBEDO = (228, 230, 236)


def apply_demo_floor(ren, level, r0):
    """Bright floor albedo so the multiply-lit shots read clearly on
    camera (same reasoning as light_occlusion_demo.apply_demo_floor:
    zero-ambient multiplies the floor, so a dim default albedo caps every
    lit pixel low regardless of light strength)."""
    for polygon in range(len(level.polygon_verts)):
        ren._floor_color_cache[polygon] = DEMO_FLOOR_ALBEDO


#: waypoints (polygon-local) the player walks to in sequence, and how many
#: ticks to hold once reached before advancing -- polygon-local, chosen from
#: the actual shadow-polygon geometry (verified with `_point_in_polygon`
#: in `lighting.py` while tuning this path, see the module docstring's
#: fail-first note): the terrain rect ((-40,-50)-(40,30)) is SOLID (blocks
#: movement like a wall, per T1), so the walk must go AROUND it (north)
#: before dipping into the shadow band it casts on the far side.
WAYPOINTS = [
    ((-230.0, 60.0), 20),    # start: lit, near the fixture
    ((-150.0, -90.0), 10),   # sweep north, clearing the terrain rect's row
    ((-40.0, -110.0), 10),   # past the rect, still north of its shadow
    ((-30.0, -10.0), 40),    # dip south into the shadow band -- DARK here
    ((-20.0, 128.0), 40),    # loop out south, clear of the shadow -- LIT
]

MARK_NAMES = ["lit_start", "cleared_rect", "past_rect", "in_shadow", "exit_lit"]


def _drive(session):
    """Deterministic waypoint-chase input generator: yields `(mx, my,
    mark_name)` once per tick, advancing through WAYPOINTS. `mark_name` is
    non-None on the LAST tick of a waypoint's hold (the player has been
    stationary there for `hold_ticks` ticks already), not the instant of
    arrival -- an mp4's `-ss` seek is only keyframe/GOP-accurate, not
    frame-exact (confirmed fail-first: marking the ARRIVAL tick produced a
    probe that read correctly in-process but read as if still mid-transit
    when re-sampled from the encoded video, because the seek landed a
    frame or two either side of a single instantaneous tick during motion;
    marking a tick deep into a stationary hold makes neighboring frames
    read identically, so seek slop is harmless). A pure function of
    `session`'s own state, so independent runs with the same seed
    reproduce identical marks/positions."""
    tick = 0
    for name, ((tx, ty), hold_ticks) in zip(MARK_NAMES, WAYPOINTS):
        stall = 0
        while True:
            px, py = session.player_pos()
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
            yield mx, my, mark
            if tick > 4000:
                raise RuntimeError(f"waypoint {name} unreachable")


def probe(png_path, x, y):
    arr = np.asarray(Image.open(png_path).convert("RGB"))  # (h, w, 3)
    h, w = arr.shape[:2]
    return tuple(int(v) for v in
                 arr[max(0, min(h - 1, y)), max(0, min(w - 1, x))])


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str,
                    default=str(ROOT / "media" / "lighting" /
                                "terrain_shadow_proof_2026-07-13.mp4"))
    ap.add_argument("--quick", action="store_true")
    args = ap.parse_args()

    level, r0 = build_world()
    session = GameSession(level, seed=7, screen=(INTERNAL_W, INTERNAL_H))
    session.sim.set_polygon_terrain(r0, [TERRAIN_RECT])  # terrain FIRST
    session.player_light.intensity = 0.0  # isolate the fixture, like the occlusion demo
    fixture = LightSpec(polygon=r0, pos=FIXTURE.pos, color=FIXTURE.color,
                         intensity=FIXTURE.intensity, radius=FIXTURE.radius,
                         kind=FIXTURE.kind)
    session.lighting.add_lights(session.sim, [fixture])  # ...THEN the light
    ren = Renderer(session)
    apply_demo_floor(ren, level, r0)
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
            "-crf", "18", "-preset", "medium", str(out_path),
        ], stdin=subprocess.PIPE)

    waypoint_by_name = {name: pt for name, (pt, _h) in zip(MARK_NAMES, WAYPOINTS)}
    drive = _drive(session)
    tick = 0
    frames = 0
    mark_ticks: dict[int, str] = {}
    positions: dict[str, tuple[float, float]] = {}
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
            tx, ty = waypoint_by_name[mark]
            # Probe the WAYPOINT's own world floor point (offset a touch
            # north to clear the player sprite itself, which would
            # otherwise dominate the sample) -- NOT the player's screen
            # position, which is pinned near screen-center every frame by
            # the follow camera and so is useless as a world-location probe.
            positions[mark] = necore.mat_apply(session.cam, tx, ty - 22.0)
            necore.write_png(str(stills_dir / f"{mark}.png"),
                             INTERNAL_W, INTERNAL_H,
                             np.ascontiguousarray(
                                 frame.transpose(1, 0, 2)).tobytes())

    if ffmpeg is not None:
        ffmpeg.stdin.close()
        ffmpeg.wait()
        print(f"wrote {out_path}: {frames} frames = {frames / FPS:.1f}s")
    else:
        print(f"quick run: {frames} frames, stills in {stills_dir}, "
              f"marks={sorted(mark_ticks.items())}")
        return 0

    # verify from the ENCODED mp4 (same-artifact rule): the player's own
    # world position, reprojected through this same run's camera, IS the
    # probe -- sample a patch above the player sprite (clear floor).
    mp4_stills_dir = out_path.parent / "stills_from_mp4"
    mp4_stills_dir.mkdir(parents=True, exist_ok=True)
    fail = False
    print("\n--- probes (sampled from the encoded MP4) ---")
    expect = {"lit_start": "lit", "cleared_rect": "lit", "past_rect": "lit",
              "in_shadow": "dark", "exit_lit": "lit"}

    for tick, name in sorted(mark_ticks.items()):
        t = (tick - 1) / FPS
        png = mp4_stills_dir / f"{name}.png"
        # `-ss` AFTER `-i` (not before): this video's I-frames are sparse
        # (two-scene GOP structure means keyframes can be 100+ frames
        # apart), and input-side (fast) seeking only guarantees
        # KEYFRAME-accurate, not frame-accurate, positioning -- confirmed
        # fail-first: the in-process render at this exact tick read a lit
        # pixel, but the fast-seeked still came back black because it
        # silently snapped to a keyframe from well inside the `in_shadow`
        # hold. Output-side (`-ss` after `-i`) seeking decodes forward from
        # the nearest keyframe to the exact requested frame.
        subprocess.run([
            "ffmpeg", "-y", "-i", str(out_path), "-ss", f"{t:.4f}",
            "-frames:v", "1", str(png),
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        sx, sy = positions[name]
        rgb = probe(png, int(round(sx)), int(round(sy)))
        brightness = sum(rgb) / 3.0
        want = expect[name]
        print(f"[{name}] t={t:.2f}s screen=({sx:.1f},{sy:.1f}) rgb={rgb} "
              f"mean={brightness:.1f} expect={want}")
        if want == "lit" and brightness < LIT_MIN:
            print(f"    !! expected LIT >= {LIT_MIN}, got {brightness:.1f}")
            fail = True
        if want == "dark" and brightness > DARK_MAX:
            print(f"    !! expected DARK <= {DARK_MAX}, got {brightness:.1f}")
            fail = True

    print(f"\nstills (from mp4): {mp4_stills_dir}")
    if fail:
        print("\nVERIFICATION FAILED")
        return 1
    print("\nVERIFICATION OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
