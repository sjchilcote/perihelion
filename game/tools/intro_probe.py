#!/usr/bin/env python3
"""game/tools/intro_probe.py

Standalone compositor PROBE (not shipping code) proving out the four
engine-side "impossible light" devices ruled by the director for the
TESTAMENT exterior hero sprite:

  1. window-row light drift along the ring band (palette-cycling style)
  2. the fold-link plate-flow (highlight travels into aperture A, out of
     aperture B, in shared phase)
  3. the stolen sunbeam (static, hard-edged night-side keylight patch
     shaped like an aperture on the sunlit side)
  4. the displaced beacon sweep (rotating beam that vanishes at the fold
     point and reappears, phase-continuous, somewhere a straight line
     cannot reach)

Composites the sprite over a procedural starfield (3 parallax layers,
seeded, slow pan) and renders ~13s at 1280x720 @ 60fps to
media/concepts/testament_exterior_v3/testament_intro_probe.mp4 via a piped
ffmpeg process (no intermediate PNG sequence).

Masks/annotations this script derives or hand-authors are also written
next to the sprite (window_mask.png, foldlink_annotations.json) so a real
intro implementation can reuse them without re-deriving them.

Run:
    SDL_VIDEODRIVER=dummy uv run python game/tools/intro_probe.py
"""
from __future__ import annotations

import json
import math
import os
import subprocess
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")

import numpy as np
from PIL import Image
import pygame

REPO_ROOT = Path(__file__).resolve().parents[2]
SPRITE_DIR = REPO_ROOT / "media/concepts/testament_exterior_v3/foldlink"
SPRITE_PATH = SPRITE_DIR / "foldlink_d_fullres.png"
OUT_DIR = REPO_ROOT / "media/concepts/testament_exterior_v3"
OUT_VIDEO = OUT_DIR / "testament_intro_probe.mp4"
WINDOW_MASK_PATH = SPRITE_DIR / "window_mask.png"
ANNOT_PATH = SPRITE_DIR / "foldlink_annotations.json"

SCREEN_W, SCREEN_H = 1280, 720
FPS = 60
DURATION_S = 13.0
N_FRAMES = int(DURATION_S * FPS)
SEED = 1337

# ---------------------------------------------------------------------------
# Hand-picked annotations on the SPRITE's own pixel coordinates (measured
# directly off media/concepts/testament_exterior_v3/foldlink/foldlink_d_fullres.png,
# 1365x768). See report for how these were derived (grid-overlay inspection).
# ---------------------------------------------------------------------------
APERTURE_A = (735, 245)          # fold-link aperture with the real drawn arc
APERTURE_B = (730, 400)          # fold-link aperture the generation left empty
ARC_A_POLYLINE = [(752, 233), (800, 238), (850, 258), (900, 300), (938, 350), (963, 412)]
# Second arc is PROBE-AUTHORED: the generation (4 attempts: foldlink_a..d)
# never produced a legible second plate arc, only a second empty aperture.
# We hand-paint a short matching-palette stub here so the plate-flow device
# has real pixels to travel along on both ends -- flagged, not shipping art.
ARC_B_POLYLINE = [(722, 393), (690, 372), (662, 335), (645, 290), (636, 250)]
ARC_PLATE_HALF_WIDTH = 15

HUB_CENTER = (700, 270)
BEACON_RADIUS = 520
BEACON_PERIOD_S = 6.0
BEACON_FOLD_TOLERANCE_DEG = 9.0
BEACON_DISPLACED_OFFSET_DEG = 205.0  # where the beam reappears -- NOT the
                                      # radial continuation through aperture B

# Windows: color threshold restricted to hand-identified window-band strips
# (the flat inset rows carrying lit windows; excludes the diamond scale-
# armor texture, which shares the same warm highlight palette and would
# otherwise false-positive under color-key alone).
WINDOW_BAND_RECTS = [
    (280, 65, 650, 120),
    (790, 65, 1010, 165),
    (140, 635, 760, 685),
    (990, 540, 1260, 650),
]

# Stolen sunbeam: night-side patch, silhouette = the left airlock wheel-door
# (radius measured off the sprite), relocated to a dark region of the hull,
# hard edge, no falloff. Sun key color: pale warm gold.
AIRLOCK_LEFT = (245, 605)
AIRLOCK_RADIUS = 42
# Night-side patch: a plain, comparatively dim/cool strut junction on the
# opposite (right) side of the hull from the real left airlock -- distinct
# location from any real aperture, so the keylight reads as "a shaft of
# light shaped like a hatch, where there is no hatch" rather than "this
# real hatch is lit."
SUNBEAM_CENTER = (1030, 275)
SUNBEAM_RADIUS = 34
SUNBEAM_COLOR = (255, 214, 150)
SUNBEAM_BOOST = 1.65

RING_CENTER = (680, 380)  # approximate ellipse center of the ring, for
                           # angular phase (window drift, beacon geometry)


# ---------------------------------------------------------------------------
# window extraction (color-key + connected-component size filter)
# ---------------------------------------------------------------------------

def _label_components(mask: np.ndarray):
    h, w = mask.shape
    ys, xs = np.where(mask)
    visited = np.zeros((h, w), dtype=bool)
    comps = []
    for y0, x0 in zip(ys.tolist(), xs.tolist()):
        if visited[y0, x0]:
            continue
        stack = [(y0, x0)]
        visited[y0, x0] = True
        comp = []
        while stack:
            y, x = stack.pop()
            comp.append((y, x))
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                ny, nx = y + dy, x + dx
                if 0 <= ny < h and 0 <= nx < w and mask[ny, nx] and not visited[ny, nx]:
                    visited[ny, nx] = True
                    stack.append((ny, nx))
        comps.append(comp)
    return comps


def extract_windows(rgb: np.ndarray, min_size=3, max_size=80, max_bbox=16):
    h, w, _ = rgb.shape
    band_mask = np.zeros((h, w), dtype=bool)
    for (x0, y0, x1, y1) in WINDOW_BAND_RECTS:
        band_mask[y0:y1, x0:x1] = True
    r, g, b = rgb[..., 0].astype(np.int32), rgb[..., 1].astype(np.int32), rgb[..., 2].astype(np.int32)
    color_mask = (r > 195) & (g > 165) & (b < 165) & (r - b > 55)
    mask = color_mask & band_mask
    comps = _label_components(mask)
    window_mask = np.zeros((h, w), dtype=bool)
    centers = []
    for comp in comps:
        if not (min_size <= len(comp) <= max_size):
            continue
        ys = [p[0] for p in comp]
        xs = [p[1] for p in comp]
        if max(ys) - min(ys) + 1 > max_bbox or max(xs) - min(xs) + 1 > max_bbox:
            continue
        for y, x in comp:
            window_mask[y, x] = True
        centers.append((sum(xs) / len(xs), sum(ys) / len(ys)))
    return window_mask, centers


# ---------------------------------------------------------------------------
# sprite prep: bake the arc-B stub + the stolen sunbeam into a working copy
# ---------------------------------------------------------------------------

def polyline_avg_color(rgb: np.ndarray, polyline, half_w=6):
    samples = []
    h, w, _ = rgb.shape
    for (x, y) in polyline:
        x0, x1 = max(0, x - half_w), min(w, x + half_w)
        y0, y1 = max(0, y - half_w), min(h, y + half_w)
        patch = rgb[y0:y1, x0:x1].reshape(-1, 3)
        samples.append(patch)
    allp = np.concatenate(samples, axis=0)
    return tuple(int(v) for v in allp.mean(axis=0))


def bake_sprite(rgb: np.ndarray) -> np.ndarray:
    """Return a working copy of the sprite with the arc-B stub painted in
    and the stolen sunbeam patch applied."""
    im = Image.fromarray(rgb.copy())
    surf_color = polyline_avg_color(rgb, ARC_A_POLYLINE)
    dark_edge = tuple(max(0, c - 60) for c in surf_color)

    import PIL.ImageDraw as ImageDraw
    d = ImageDraw.Draw(im)
    # arc-B stub: thick line along the polyline, dark outline + fill, to
    # read as physical plate matching arc A's palette (probe-only art).
    pts = ARC_B_POLYLINE
    d.line(pts, fill=dark_edge, width=ARC_PLATE_HALF_WIDTH * 2 + 4, joint="curve")
    d.line(pts, fill=surf_color, width=ARC_PLATE_HALF_WIDTH * 2, joint="curve")
    for (x, y) in (pts[0], pts[-1]):
        d.ellipse([x - ARC_PLATE_HALF_WIDTH, y - ARC_PLATE_HALF_WIDTH,
                    x + ARC_PLATE_HALF_WIDTH, y + ARC_PLATE_HALF_WIDTH], fill=surf_color)

    arr = np.asarray(im).astype(np.float32)

    # stolen sunbeam: hard-edged circular patch (airlock-hatch silhouette),
    # relocated to the night-side band, boosted brightness, no falloff.
    h, w, _ = arr.shape
    yy, xx = np.mgrid[0:h, 0:w]
    r2 = (xx - SUNBEAM_CENTER[0]) ** 2 + (yy - SUNBEAM_CENTER[1]) ** 2
    patch = r2 <= SUNBEAM_RADIUS ** 2
    boosted = arr.copy()
    key = np.array(SUNBEAM_COLOR, dtype=np.float32)
    boosted[patch] = np.clip(arr[patch] * 0.55 + key * 0.55, 0, 255)
    boosted[patch] = np.clip(boosted[patch] * SUNBEAM_BOOST, 0, 255)
    return boosted.astype(np.uint8)


# ---------------------------------------------------------------------------
# starfield
# ---------------------------------------------------------------------------

def make_starfield_layer(rng, n_stars, w, h, size_range, bright_range):
    xs = rng.uniform(0, w, n_stars)
    ys = rng.uniform(0, h, n_stars)
    sizes = rng.uniform(*size_range, n_stars)
    brights = rng.uniform(*bright_range, n_stars)
    return xs, ys, sizes, brights


def draw_starfield_layer(surface, xs, ys, sizes, brights, offset_x, offset_y, w, h, tint):
    ox = offset_x % w
    oy = offset_y % h
    for x, y, s, b in zip(xs, ys, sizes, brights):
        px = (x - ox) % w
        py = (y - oy) % h
        c = (int(tint[0] * b), int(tint[1] * b), int(tint[2] * b))
        if s <= 1.0:
            surface.set_at((int(px), int(py)), c)
        else:
            pygame.draw.circle(surface, c, (int(px), int(py)), max(1, int(s)))


# ---------------------------------------------------------------------------
# geometry helpers
# ---------------------------------------------------------------------------

def polyline_point(polyline, u):
    """u in [0,1] -> interpolated point along the polyline."""
    n = len(polyline) - 1
    u = max(0.0, min(1.0, u))
    seg = u * n
    i = min(n - 1, int(seg))
    t = seg - i
    x0, y0 = polyline[i]
    x1, y1 = polyline[i + 1]
    return (x0 + (x1 - x0) * t, y0 + (y1 - y0) * t)


def angdiff(a, b):
    d = (a - b + 180) % 360 - 180
    return d


# ---------------------------------------------------------------------------
# main render
# ---------------------------------------------------------------------------

def main():
    pygame.init()
    rng = np.random.default_rng(SEED)

    print(f"loading sprite: {SPRITE_PATH}")
    sprite_rgb = np.asarray(Image.open(SPRITE_PATH).convert("RGB"))
    sw, sh = sprite_rgb.shape[1], sprite_rgb.shape[0]

    window_mask, window_centers = extract_windows(sprite_rgb)
    print(f"windows detected: {len(window_centers)}")
    Image.fromarray((window_mask * 255).astype(np.uint8)).save(WINDOW_MASK_PATH)

    baked_rgb = bake_sprite(sprite_rgb)

    annotations = {
        "sprite": str(SPRITE_PATH.relative_to(REPO_ROOT)),
        "sprite_size": [sw, sh],
        "fold_link": {
            "aperture_a": APERTURE_A,
            "aperture_b": APERTURE_B,
            "arc_a_polyline": ARC_A_POLYLINE,
            "arc_b_polyline": ARC_B_POLYLINE,
            "arc_b_source": (
                "PROBE-AUTHORED: 4 generation attempts (foldlink_a..d) never "
                "produced a legible second plate arc, only a second empty "
                "aperture (foldlink_d). This polyline + its baked plate are "
                "probe-only art, not shipping generation output."
            ),
            "plate_half_width_px": ARC_PLATE_HALF_WIDTH,
        },
        "sunbeam": {
            "center": SUNBEAM_CENTER, "radius": SUNBEAM_RADIUS,
            "key_color": SUNBEAM_COLOR,
            "shape_source": "circular, radius matched to the left airlock wheel-door; "
                             "relocated to a distinct night-side strut junction, not "
                             "overlapping any real aperture",
        },
        "beacon": {
            "hub_center": HUB_CENTER, "radius_px": BEACON_RADIUS,
            "period_s": BEACON_PERIOD_S,
            "fold_tolerance_deg": BEACON_FOLD_TOLERANCE_DEG,
            "displaced_offset_deg": BEACON_DISPLACED_OFFSET_DEG,
        },
        "window_band_rects": WINDOW_BAND_RECTS,
        "window_centers_found": len(window_centers),
        "ring_center_for_phase": RING_CENTER,
    }
    ANNOT_PATH.write_text(json.dumps(annotations, indent=2))
    print(f"wrote {ANNOT_PATH}")

    # scale sprite to fit within the frame with margin
    max_w, max_h = SCREEN_W * 0.86, SCREEN_H * 0.86
    scale = min(max_w / sw, max_h / sh)
    disp_w, disp_h = int(sw * scale), int(sh * scale)
    sprite_surf_full = pygame.image.frombuffer(baked_rgb.tobytes(), (sw, sh), "RGB")
    sprite_surf = pygame.transform.smoothscale(sprite_surf_full, (disp_w, disp_h))
    sprite_origin = ((SCREEN_W - disp_w) // 2, (SCREEN_H - disp_h) // 2)

    def to_screen(pt):
        return (sprite_origin[0] + pt[0] * scale, sprite_origin[1] + pt[1] * scale)

    ap_a_screen = to_screen(APERTURE_A)
    ap_b_screen = to_screen(APERTURE_B)
    hub_screen = to_screen(HUB_CENTER)
    ring_center_screen = to_screen(RING_CENTER)
    arc_a_screen = [to_screen(p) for p in ARC_A_POLYLINE]
    arc_b_screen = [to_screen(p) for p in ARC_B_POLYLINE]
    window_centers_screen = [to_screen(c) for c in window_centers]

    # starfield layers (parallax): far/slow, mid, near/fast
    layer_defs = [
        dict(n=220, size=(0.6, 1.2), bright=(0.25, 0.55), speed=(3, 1), tint=(150, 160, 200)),
        dict(n=120, size=(1.0, 1.8), bright=(0.4, 0.75), speed=(9, 3), tint=(180, 190, 220)),
        dict(n=50, size=(1.4, 2.6), bright=(0.6, 1.0), speed=(20, 7), tint=(210, 215, 255)),
    ]
    layers = []
    for ld in layer_defs:
        xs, ys, sizes, brights = make_starfield_layer(rng, ld["n"], SCREEN_W, SCREEN_H, ld["size"], ld["bright"])
        layers.append((xs, ys, sizes, brights, ld["speed"], ld["tint"]))

    # ffmpeg pipe
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    ffmpeg_cmd = [
        "ffmpeg", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24",
        "-s", f"{SCREEN_W}x{SCREEN_H}", "-r", str(FPS), "-i", "-",
        "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p", "-crf", "18",
        str(OUT_VIDEO),
    ]
    proc = subprocess.Popen(ffmpeg_cmd, stdin=subprocess.PIPE, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    screen = pygame.Surface((SCREEN_W, SCREEN_H))

    print(f"rendering {N_FRAMES} frames...")
    for frame_i in range(N_FRAMES):
        t = frame_i / FPS
        screen.fill((0, 0, 0))

        for xs, ys, sizes, brights, speed, tint in layers:
            draw_starfield_layer(screen, xs, ys, sizes, brights, speed[0] * t, speed[1] * t, SCREEN_W, SCREEN_H, tint)

        screen.blit(sprite_surf, sprite_origin)

        # --- device 1: window-row light drift (palette-cycling along ring) ---
        drift_speed = 0.12  # cycles per second around the ring
        for (sx, sy), (ox, oy) in zip(window_centers_screen, window_centers):
            ang = math.atan2(oy - RING_CENTER[1], ox - RING_CENTER[0]) / (2 * math.pi)
            phase = (ang - t * drift_speed) % 1.0
            b = 0.5 + 0.5 * math.cos(2 * math.pi * phase * 6)  # 6 bright bands traveling the ring
            b = max(0.15, b)
            col = (int(255 * b), int(220 * b), int(120 * b))
            pygame.draw.circle(screen, col, (int(sx), int(sy)), max(2, int(3 * scale)))

        # --- device 2: fold-link plate flow, shared phase A<-, ->B ---
        flow_period = 3.2
        u = (t % flow_period) / flow_period
        pa = polyline_point(arc_a_screen, 1.0 - u)  # travels TOWARD aperture A
        pb = polyline_point(arc_b_screen, u)        # travels AWAY FROM aperture B, same phase
        glow_r = max(4, int(9 * scale))
        for p in (pa, pb):
            pygame.draw.circle(screen, (255, 245, 210), (int(p[0]), int(p[1])), glow_r)
            pygame.draw.circle(screen, (255, 255, 255), (int(p[0]), int(p[1])), max(2, glow_r // 2))

        # --- device 4: displaced beacon sweep ---
        beacon_ang = (t / BEACON_PERIOD_S) * 360.0
        ang_to_a = math.degrees(math.atan2(ap_a_screen[1] - hub_screen[1], ap_a_screen[0] - hub_screen[0]))
        in_fold_window = abs(angdiff(beacon_ang, ang_to_a)) <= BEACON_FOLD_TOLERANCE_DEG
        rad = beacon_ang * math.pi / 180.0
        bx = hub_screen[0] + math.cos(rad) * BEACON_RADIUS * scale
        by = hub_screen[1] + math.sin(rad) * BEACON_RADIUS * scale
        if not in_fold_window:
            pygame.draw.line(screen, (255, 250, 225), hub_screen, (bx, by), max(2, int(3 * scale)))
            pygame.draw.circle(screen, (255, 255, 255), (int(bx), int(by)), max(3, int(5 * scale)))
        else:
            # beam plunges into aperture A ...
            pygame.draw.line(screen, (255, 250, 225), hub_screen, ap_a_screen, max(2, int(3 * scale)))
            pygame.draw.circle(screen, (255, 255, 255), (int(ap_a_screen[0]), int(ap_a_screen[1])), max(3, int(6 * scale)))
            # ... and reappears, phase-continuous, displaced -- from aperture B
            # at an angle a straight line through the hub could never reach.
            disp_rad = math.radians(ang_to_a + BEACON_DISPLACED_OFFSET_DEG)
            ex = ap_b_screen[0] + math.cos(disp_rad) * 140 * scale
            ey = ap_b_screen[1] + math.sin(disp_rad) * 140 * scale
            pygame.draw.line(screen, (255, 250, 225), ap_b_screen, (ex, ey), max(2, int(3 * scale)))
            pygame.draw.circle(screen, (255, 255, 255), (int(ap_b_screen[0]), int(ap_b_screen[1])), max(3, int(6 * scale)))

        frame_bytes = pygame.image.tostring(screen, "RGB")
        proc.stdin.write(frame_bytes)

        if frame_i % (FPS * 2) == 0:
            print(f"  frame {frame_i}/{N_FRAMES} (t={t:.1f}s)")

    proc.stdin.close()
    proc.wait()
    print(f"wrote {OUT_VIDEO}")


if __name__ == "__main__":
    main()
