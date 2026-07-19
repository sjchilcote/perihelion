"""Light occlusion proof (director-ordered): "the light will need to be,
you know - occluded." A handcrafted world + a scripted, deterministic
walk (input frames, not a bot) through the REAL game path (GameSession ->
Renderer, lighting v2: zero ambient, lightmap-multiply, per-light wedges
from necore.visible_set, LIGHT_STRENGTH=3.0), captured in one continuous
ffmpeg take -- study tools/playtest/flicker_cross.py (world-builder +
deterministic drive) and game/tools/capture_mindmap_demo.py (one-take
ffmpeg capture) for the tradition this follows.

Shots, in sequence:
  1. The doorway cone       -- a hard-edged wedge through a single doorway
  2. The wall cut           -- the wedge's boundary swept by the player's
                                own movement, right at the door jamb
  3. The two-hop bend       -- light reaches a far polygon ONLY through two
                                doorways in sequence; the far corner stays
                                black even at LIGHT_STRENGTH 3.0
  4. The two-source cross   -- two colored fixtures on opposite sides of a
                                doorwayed polygon, wedges overlapping (additive
                                mix) in the middle, each cut off by its OWN
                                occlusion
  5. The many-slit wall     -- five doorways in one wall: five independent
                                wedges with genuinely dark bands between
                                them (wedges are per-doorway, not a shared
                                glow leaking around the wall)
  6. The non-Euclidean bend -- the same doorway-cone phenomenon through a
                                connect_x portal with an injected 90-degree
                                twist: the destination polygon's geometry (and
                                the light wedge cast through it) is rotated
                                relative to the corridor's own axis, proving
                                the occlusion math holds under an arbitrary
                                (non-rigid) portal transform, not just plain
                                translation

ROOT CAUSE FIXED DURING BUILD: authoring two adjacent polygons on a shared
absolute-canvas wall (so only ONE segment of that wall is the intended
doorway) causes LevelBuilder.resolve()'s autoconnect pass to ALSO wire the
solid segments on either side of the door open (it matches ANY exactly-
coincident edge pair, not just the one you connect_pts'd) -- deleting the
very walls this demo exists to prove light stops at. Every doorway below is
paired with `no_connect(ra, rb)` immediately after its `connect_pts` to
suppress that autoconnect once the intended door edge is already reserved.

Usage:
    uv run python tools/playtest/light_occlusion_demo.py [--out PATH]
        [--quick]   # short smoke run, no video, prints probe numbers only
"""
from __future__ import annotations

import argparse
import math
import os
import subprocess
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "game"))

import numpy as np  # noqa: E402
import pygame  # noqa: E402

import necore  # noqa: E402
from perihelion.levels import LevelBuilder  # noqa: E402
from perihelion.render import Renderer, INTERNAL_W, INTERNAL_H  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402

DOOR = 24.0
OUT_W, OUT_H = 1280, 720
FPS = 60


def door(b: LevelBuilder, ra: int, pa, rb: int, pb) -> None:
    """A single doorway between two polygons authored on a shared canvas, with
    the autoconnect trap (see module docstring) suppressed immediately."""
    b.connect_pts(ra, pa, rb, pb)
    b.no_connect(ra, rb)


def slit_wall_run(x0: float, x1: float, y: float, centers: list[float],
                   width: float) -> list[tuple[float, float]]:
    """INTERIOR verts (no endpoints) for a horizontal wall run from
    (x0,y) to (x1,y), with a pair of notch markers at each slit center
    (width `width`). Walks centers in the x0->x1 direction regardless of
    which is larger, so the same helper builds a wall's verts from either
    side of it (a polygon's own winding direction may need either)."""
    ordered = sorted(centers, reverse=(x1 < x0))
    pts = []
    for c in ordered:
        lo, hi = c - width / 2.0, c + width / 2.0
        a, b_ = (lo, hi) if x1 > x0 else (hi, lo)
        pts.append((a, y))
        pts.append((b_, y))
    return pts


# ---------------------------------------------------------------------
# world
# ---------------------------------------------------------------------

# THE BRIGHTNESS CHAIN (director's "metric passes, eye fails" catch, round
# 2 of this demo): under zero ambient the lightmap MULTIPLIES the world
# layer, so a pixel's final value is floor_albedo * lightmap / 255. The
# campaign's l01 dock reads bright because its polygons carry bespoke floor
# TEXTURES with albedo ~100-150; a LevelBuilder debug world falls back to
# the flat corridor floor color (26, 26, 33) -- which caps EVERY lit pixel
# at 26/255 no matter how strong the light is. The first capture's 88x
# contrast ratios were ratios of near-nothing. The demo therefore sets a
# bright flat floor albedo on its own polygons (the demo's parameter, not the
# global palette), sized so a saturated lightmap reads near-white.
DEMO_FLOOR_ALBEDO = (228, 230, 236)


def apply_demo_floor(ren: Renderer, level) -> None:
    """Pre-fill the renderer's per-polygon floor-color cache with the demo's
    bright albedo (both backends read _floor_color through this cache).
    Applies to every polygon -- the demo world has no textured polygons, so
    nothing legitimate is overridden."""
    for polygon in range(len(level.polygon_verts)):
        ren._floor_color_cache[polygon] = DEMO_FLOOR_ALBEDO


def build_world():
    b = LevelBuilder("light-occlusion-proof", tier=1, ambience="amb_drone_early")
    meta: dict = {}

    # -- Polygon A: fixture polygon (warm white), shots 1 & 2's light source ---
    vA = [(0, -140), (0, -20), (48, -20), (72, -20), (120, -20), (120, -140)]
    rA = b.polygon(vA, detail_seed=1, kind="corridor")

    # -- Polygon B: dark polygon, shots 1 & 2 -----------------------------------
    # Two doors: north (to A) and south (to C, offset -- the bend). Both
    # markers on the SAME wall pair (north/south) rather than north/east:
    # a light's cast wedge widens with distance from its own doorway (the
    # divergence half-angle is atan(door_half_width / throw)), and this
    # fixture -- 60 units back from its own door -- only fans out to
    # +-36 local units by B's FAR wall (verified via
    # lighting.compute_light_instances), never reaching B's east wall at
    # all. It comfortably covers the western 2/3 of B's SOUTH wall,
    # though, which is where the bend doorway to C lives instead.
    vB = [(48, -20), (0, -20), (0, 100), (66, 100), (90, 100), (120, 100),
          (120, -20), (72, -20)]
    rB = b.polygon(vB, detail_seed=2, kind="corridor")

    # -- Polygon C: dark bend polygon, shot 3 (south of B, offset in x) --------
    vC = [(66, 100), (20, 100), (20, 220), (88, 220), (112, 220), (140, 220),
          (140, 100), (90, 100)]
    rC = b.polygon(vC, detail_seed=3, kind="corridor")

    door(b, rA, (60, -20), rB, (60, -20))
    door(b, rB, (78, 100), rC, (78, 100))

    # intensity well above the other fixtures: this one light alone has to
    # read clearly in THREE places -- shot 1's crisp doorway cone, shot 2's
    # wall cut, and (much further downstream, after a long geometric
    # throw through two doorways) shot 3's two-hop bend into C, where
    # radial falloff over that distance otherwise leaves the lightmap
    # under 10/255 even at the doorway threshold, unreadable once
    # multiplied by C's floor albedo and video-compressed.
    b.light(rA, (60, -80), color=(255, 225, 180), intensity=2.0, radius=700)

    # -- Polygon M: two-source cross meeting polygon, shot 4 (south of C) ------
    vM = [(88, 220), (20, 220), (20, 268), (20, 292), (20, 340), (68, 340),
          (92, 340), (140, 340), (140, 292), (140, 268), (140, 220), (112, 220)]
    rM = b.polygon(vM, detail_seed=4, kind="corridor")

    # -- Polygon D: amber fixture --------------------------------------------
    vD = [(20, 268), (-100, 268), (-100, 340), (-20, 340), (20, 340), (20, 292)]
    rD = b.polygon(vD, detail_seed=5, kind="corridor")

    # -- Polygon E: verdigris fixture -----------------------------------------
    vE = [(140, 268), (140, 292), (140, 340), (220, 340), (260, 340),
          (260, 268)]
    rE = b.polygon(vE, detail_seed=6, kind="corridor")

    door(b, rC, (100, 220), rM, (100, 220))
    door(b, rD, (20, 280), rM, (20, 280))
    door(b, rE, (140, 280), rM, (140, 280))
    # COLOR-PRESERVING intensity: _blit_light's tint is
    # min(255, channel * intensity * LIGHT_STRENGTH) PER CHANNEL, so any
    # intensity above 1/LIGHT_STRENGTH clamps a colored light's dominant
    # channels flat and whitens the hue (the first capture's "amber" was
    # (255,165,55)*6.0 -> every channel clamped -> pure white). At exactly
    # 1/3 the tint IS the authored color. Brightness then comes from the
    # gradient term alone -- so these fixtures sit CLOSE to their doorways
    # (short throw, high a^2 at the probes) with a wide radius.
    # Throw distances also set each wedge's fan half-angle
    # (atan(12/throw)): amber at 40u and verdigris at 60u keep both fans
    # narrow enough that M's north-west corner (the dead_corner probe) has
    # line-of-sight to NEITHER door aperture -- moving verdigris closer
    # (tried at 25u) fanned its wedge ~180 degrees and legitimately lit
    # that corner. Radii compensate for the throw so the lit probes still
    # clear the absolute gate.
    b.light(rD, (-20, 280), color=(255, 180, 80), intensity=1 / 3.0, radius=500)
    b.light(rE, (200, 280), color=(80, 235, 170), intensity=1 / 3.0, radius=600)

    # -- corridor down to the slit wall, shot 5 ---------------------------
    vCORR = [(68, 340), (68, 380), (92, 380), (92, 340)]
    rCORR = b.polygon(vCORR, detail_seed=7, kind="corridor")
    door(b, rM, (80, 340), rCORR, (80, 340))

    slit_centers = [-40.0, 30.0, 100.0, 170.0, 240.0]
    slit_w = 20.0
    # SLIT_DARK: north door (to CORR) at [68,92]; south wall (y=500) is
    # the 5-slit wall, walked west->east here (x=-80 -> x=260).
    vSD = ([(68, 380), (-80, 380), (-80, 500)] +
           slit_wall_run(-80, 260, 500, slit_centers, slit_w) +
           [(260, 500), (260, 380), (92, 380)])
    rSD = b.polygon(vSD, detail_seed=8, kind="corridor")
    door(b, rCORR, (80, 380), rSD, (80, 380))

    # SLIT_LIGHT: north wall (y=500, shared with SD's south wall) -- doors
    # are point-resolved (nearest_edge), so this run's direction only needs
    # to keep SL's own polygon simple and correctly wound, not mirror SD's.
    vSL = list(reversed(
        [(-80, 500)] + slit_wall_run(-80, 260, 500, slit_centers, slit_w) +
        [(260, 500), (260, 620), (-80, 620)]))
    rSL = b.polygon(vSL, detail_seed=9, kind="corridor")
    for c in slit_centers:
        door(b, rSD, (c, 500), rSL, (c, 500))
    b.light(rSL, (90, 560), color=(255, 245, 230), intensity=2.2, radius=700)

    # -- non-Euclidean stub + rotated portal, shot 6 -----------------------
    # a corridor stub off SLIT_DARK's west wall; its FAR (untouched) edge
    # connects via connect_x with an injected 90-degree twist into a
    # fixture polygon authored far away on the canvas (coordinates don't need
    # to line up -- connect_x's m9 is arbitrary, see module docstring and
    # levels.py's resolve(); keeping it far away just avoids accidental
    # collinear-edge overlap with the rest of the world, which would let
    # the doorway-splitter silently touch it and invalidate the raw edge
    # index this depends on).
    vDS = [(-160, 428), (-160, 452), (-80, 452), (-80, 428)]
    rDS = b.polygon(vDS, detail_seed=10, kind="corridor")
    door(b, rSD, (-80, 440), rDS, (-80, 440))
    ea_stub = 0  # (-160,428)-(-160,452): untouched, full 24-long west edge

    vNE = [(1000, 1000), (1000, 1120), (1120, 1120), (1120, 1000)]
    rNE = b.polygon(vNE, detail_seed=11, kind="corridor")
    eb_ne = 0  # (1000,1000)-(1000,1120): untouched west edge
    # hue-preserving 1/3 intensity (see the D/E fixtures' note) -- the cold
    # blue is the point of this polygon reading as somewhere ELSE
    b.light(rNE, (1060, 1060), color=(150, 180, 255), intensity=1 / 3.0,
            radius=500)

    theta = math.pi / 2.0
    # local (centroid-relative) coords: D_stub is 80x24, centroid (-120,440)
    # -> its west edge e0 spans local (-40,-12)-(-40,12), midpoint (-40,0).
    # NE is 120x120, centroid (1060,1060) -> its west edge e0 spans local
    # (-60,-60)-(-60,60); rotated by theta it spans (60,-60)-(-60,-60),
    # midpoint (0,-60). Translate that midpoint onto D_stub's aperture.
    rot = necore.mat_rotate(theta)
    mx, my = necore.mat_apply_dir(rot, 0.0, -60.0)
    tx, ty = -40.0 - mx, 0.0 - my
    m9 = necore.mat_mul(necore.mat_translate(tx, ty), rot)
    b.connect_x(rDS, ea_stub, rNE, eb_ne, m9)

    b.player(rB, (60, 30))
    b.exit(rSL, (90, 560))

    meta.update(rA=rA, rB=rB, rC=rC, rM=rM, rD=rD, rE=rE, rCORR=rCORR,
                rSD=rSD, rSL=rSL, rDS=rDS, rNE=rNE, slit_centers=slit_centers,
                slit_w=slit_w)
    return b.build(), meta


# ---------------------------------------------------------------------
# scripted, deterministic walk
# ---------------------------------------------------------------------

class Script:
    """Accumulates (mx, my, ticks) segments -- a fixed, hand-authored input
    tape, not a bot: every tick's input is decided here, not by any
    feedback from the sim."""

    def __init__(self):
        self.segs: list[tuple[float, float, int]] = []
        self.marks: dict[str, int] = {}

    def hold(self, ticks: int, mx=0.0, my=0.0):
        self.segs.append((mx, my, ticks))
        return self

    def mark(self, name: str):
        self.marks[name] = sum(t for _, _, t in self.segs)
        return self

    def total(self) -> int:
        return sum(t for _, _, t in self.segs)

    def input_at(self, tick: int) -> tuple[float, float]:
        t = 0
        for mx, my, n in self.segs:
            if tick < t + n:
                return mx, my
            t += n
        return 0.0, 0.0


def build_script() -> Script:
    s = Script()
    # --- Shot 1: the doorway cone. Stand in B, strafe across it. --------
    s.hold(30)
    s.mark("shot1_start")
    s.hold(50, mx=1.0, my=0.0)     # strafe east: enters, crosses, exits
    s.hold(20)
    s.hold(90, mx=-1.0, my=0.0)    # strafe back west, all the way across
    s.hold(20)
    s.mark("shot1_end")

    # --- Shot 2: the wall cut. Walk up near the shared wall, along the
    # door jamb, so the wedge boundary sweeps across the floor as the
    # PLAYER's own position crosses it (not the light, which is static).
    s.hold(40, mx=-0.3, my=-1.0)   # approach the north wall, west of center
    s.mark("shot2_start")
    s.hold(70, mx=1.0, my=0.05)    # walk laterally right along the wall,
                                    # crossing from behind the jamb into the
                                    # doorway's own span and back out
    s.hold(30)
    s.mark("shot2_end")

    # --- transit: B's south door -> C -------------------------------------
    # from shot2_end (~113.5,-5.8) to B's south/bend door (78,100):
    # dx=-35.5, dy=105.8, dist=111.6, unit=(-0.318,0.948)
    s.hold(70, mx=-0.318, my=0.948)
    s.hold(50)
    s.hold(30, mx=0.0, my=1.0)     # straight south, through the door
    s.mark("shot3_start")
    s.hold(50, mx=0.959, my=0.282)  # walk toward C's far (dark) corner --
                                      # heads mostly east, clamps on C's
                                      # own east wall well before drifting
                                      # anywhere near the C-M doorway
    s.hold(80)
    s.mark("shot3_end")

    # --- transit: C's south door -> M ---------------------------------
    # C's far corner (~133.5,217) -> the door column at x=100. NOTE: the
    # settle-stop itself carries on ~19 more units of drift (the friction
    # model decays over ~50 ticks, not instantly) -- a 15-tick drive
    # (position ~121 mid-drive) settles to x~100 AFTER the stop.
    s.hold(15, mx=-1.0, my=0.0)
    s.hold(50)                      # full stop -- let residual drift decay
    s.hold(35, mx=0.0, my=1.0)     # south, through the door, into M
    s.mark("shot4_start")
    s.hold(70, mx=-1.0, my=0.0)    # sweep west into D's wedge
    s.hold(40)
    s.hold(110, mx=1.0, my=0.0)    # sweep east across the overlap into E's
    s.hold(40)
    s.mark("shot4_end")

    # --- transit: south to the slit corridor -------------------------------
    # Axis-aligned legs, each measured empirically against a wall clamp
    # (deterministic stopping point) rather than dead-reckoned: south to
    # M's wall, west to the CORR door column (x~80), then south straight
    # through CORR and into SD, on toward the slit wall.
    # Brief stops (zero input) between direction changes: residual velocity
    # blends diagonally for a few ticks across an abrupt direction switch
    # (measured: a west leg immediately followed by a south leg let the
    # player drift another ~15 units west during the "south" ticks,
    # missing a 24-wide door it had otherwise correctly reached) -- a short
    # coast to a full stop makes each leg's start position deterministic.
    s.hold(19, mx=0.0, my=1.0)     # south, onto M's south wall
    s.hold(21, mx=-1.0, my=0.0)    # west, toward the CORR door column
                                     # (settles to x~85 after the stop --
                                     # see the friction-decay note above)
    s.hold(50)                      # let the westward drift fully decay
    s.hold(95, mx=0.0, my=1.0)     # south: through CORR, into SD, toward
                                     # the slit wall
    s.hold(50)
    s.hold(120, mx=-1.0, my=0.0)   # west, to the wall's far end
    s.mark("shot5_start")
    s.hold(210, mx=1.0, my=0.0)       # sweep east across all five slits
    s.hold(20)
    s.mark("shot5_end")

    # --- transit: to the non-Euclidean stub -------------------------------
    s.hold(175, mx=-0.988, my=-0.158)  # back to SD's own west-wall door
    s.hold(12)                          # kill momentum right at the door
    s.mark("shot6_start")
    s.hold(3, mx=-1.0, my=0.0)     # through the SD-DS door, into the stub,
                                     # up close to the portal's aperture
    s.hold(60)                      # hold at the threshold: the rotated
                                     # polygon's wedge, seen through the
                                     # portal, occlusion-clipped and twisted
    s.mark("shot6_threshold")
    s.hold(50, mx=-1.0, my=0.0)    # cross through into the rotated polygon
    s.hold(90)                      # hold, looking around inside it
    s.mark("shot6_end")
    return s


# ---------------------------------------------------------------------
# probes: (label, polygon-key-into-meta, world_x, world_y, expect)
# world coords are the SAME authoring-canvas coords used in build_world()
# (LightSpec/entity positions get recentered per-polygon internally, but the
# camera xform for a polygon instance maps THESE authoring coords straight to
# screen space -- see the note in main() where they're transformed).
# ---------------------------------------------------------------------

# Absolute luminance gates (mean RGB over the probe box, 0-255), applied
# to frames decoded from the ENCODED mp4. Ratios alone are insufficient
# by order: capture 1 passed 88x ratios on frames whose "lit" side peaked
# barely above black.
LIT_MIN = 110.0
DARK_MAX = 8.0

PROBES: dict[str, list[tuple[str, str, float, float, str]]] = {
    "shot1_start": [
        ("inside_cone", "rB", 60.0, 8.0, "lit"),
        ("outside_cone_far_corner", "rB", 15.0, 92.0, "dark"),
    ],
    # Sampled at shot2_END, not shot2_start: the player's OWN attached
    # work lamp (radius 85, always on) travels with them, so a "dark"
    # probe close to where they're currently standing gets contaminated
    # by their own light, not the fixture's. By shot2_end the player has
    # walked to world x~113.5 -- far enough from the jamb probe (x=15,
    # ~98 units) to isolate the fixture's wedge, while still close enough
    # to the doorway probe (x=60) that the fixture keeps it lit either way.
    "shot2_end": [
        ("in_doorway_span", "rB", 60.0, -16.0, "lit"),
        ("behind_wall_jamb", "rB", 15.0, -16.0, "dark"),
    ],
    "shot3_end": [
        ("lit_near_bend_door", "rC", 82.0, 112.0, "lit"),
        ("dark_far_corner", "rC", 30.0, 215.0, "dark"),
    ],
    "shot4_end": [
        ("amber_only", "rM", 28.0, 280.0, "lit"),
        ("verdigris_only", "rM", 132.0, 280.0, "lit"),
        ("overlap_mixed", "rM", 80.0, 280.0, "lit"),
        ("dead_corner", "rM", 26.0, 226.0, "dark"),
    ],
    "shot5_end": [
        ("slit1", "rSD", -46.0, 494.0, "lit"),
        ("slit3", "rSD", 100.0, 492.0, "lit"),
        ("slit5", "rSD", 240.0, 492.0, "lit"),
        ("between_1_2", "rSD", -5.0, 492.0, "dark"),
        ("between_3_4", "rSD", 135.0, 492.0, "dark"),
    ],
    "shot6_threshold": [
        ("through_portal", "rDS", -128.0, 440.0, "lit"),
    ],
}


def probe(png_path: Path, x: int, y: int, box: int = 4) -> tuple[float, float, float]:
    """Mean RGB over a small box, in image pixel coordinates."""
    surf = pygame.image.load(str(png_path))
    arr = pygame.surfarray.pixels3d(surf)
    w, h = surf.get_size()
    x0, x1 = max(0, x - box), min(w, x + box + 1)
    y0, y1 = max(0, y - box), min(h, y + box + 1)
    region = arr[x0:x1, y0:y1].astype(np.float64)
    del arr
    return tuple(region.mean(axis=(0, 1)).round(1))


def _point_in_poly(x: float, y: float, poly) -> bool:
    inside = False
    n = len(poly)
    for i in range(n):
        x0, y0 = poly[i]
        x1, y1 = poly[(i + 1) % n]
        if (y0 > y) != (y1 > y):
            xin = x0 + (y - y0) * (x1 - x0) / (y1 - y0)
            if x < xin:
                inside = not inside
    return inside


def screen_xy_for(session: GameSession, ren: Renderer, polygon: int,
                   wx: float, wy: float) -> tuple[float, float] | None:
    """World (authoring-canvas) point -> current-frame screen pixel, by
    finding the camera instance for `polygon` this tick and inverting its
    centroid offset (LightSpec/entities go through the same `local()`
    recentering in levels.level_from_dict; camera xforms operate on THAT
    recentered local frame, so subtract the polygon's own centroid first).
    Returns None if the point isn't actually inside any of this polygon's
    visible-this-frame clip polygons (e.g. it's real geometry, but off the
    edge of the camera's current field of view) -- silently sampling void
    for an out-of-frame probe would be worse than flagging it."""
    cx, cy = session.level.polygon_centroids[polygon]
    lx, ly = wx - cx, wy - cy
    # A non-Euclidean chain can put more than one camera instance of the
    # SAME polygon on screen at once (different portal paths reaching it).
    # Take every instance whose polygon actually contains the point, and
    # prefer the shallowest (fewest portal hops -- the "main" view a
    # player would read this shot by), not just the first one iterated.
    candidates = []
    for inst_polygon, xform, depth, clip_screen, walls, entry_edge, ents in \
            session.visible(ren.max_depth, ren.max_instances):
        if inst_polygon == polygon and len(clip_screen) >= 3:
            sx, sy = necore.mat_apply(xform, lx, ly)
            if _point_in_poly(sx, sy, clip_screen):
                candidates.append((depth, sx, sy))
    if not candidates:
        return None
    candidates.sort(key=lambda c: c[0])
    return candidates[0][1], candidates[0][2]


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=str,
                    default=str(ROOT / "media" / "lighting" /
                               "occlusion_proof_2026-07-11.mp4"))
    ap.add_argument("--quick", action="store_true",
                    help="no video, just build + a few probe frames")
    args = ap.parse_args()

    pygame.init()
    level, meta = build_world()
    session = GameSession(level, seed=11, screen=(INTERNAL_W, INTERNAL_H))
    ren = Renderer(session)
    apply_demo_floor(ren, level)
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    script = build_script()

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

    total = script.total()
    still_ticks = {t: name for name, t in script.marks.items()}
    # screen coords for each mark's probes, captured live (same tick the
    # still/video frame is written for) -- the SAMPLING happens later, on
    # the encoded artifact, but the coordinate-to-probe-at is a property of
    # this frame's camera, computed once here rather than re-derived.
    probe_screen: dict[str, list[tuple[str, float, float, str]]] = {}
    frames = 0
    for tick in range(1, total + 1):
        mx, my = script.input_at(tick - 1)
        session.tick(InputFrame(mx=mx, my=my, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                                fire=False, alt=False, interact=False, weapon=0))
        ren.consume_fx(session.fx)
        ren.draw(surf)
        if tick in still_ticks:
            name = still_ticks[tick]
            if name in PROBES:
                resolved = []
                for label, polygon_key, wx, wy, expect in PROBES[name]:
                    polygon = meta[polygon_key]
                    sxy = screen_xy_for(session, ren, polygon, wx, wy)
                    if sxy is not None:
                        resolved.append((label, sxy[0], sxy[1], expect))
                    else:
                        print(f"!! probe {name}/{label} at world "
                              f"({wx},{wy}) is not in this frame's visible "
                              f"clip for polygon {polygon} -- dropped")
                probe_screen[name] = resolved
        if ffmpeg is not None:
            frame = surf if surf.get_size() == (OUT_W, OUT_H) else \
                pygame.transform.smoothscale(surf, (OUT_W, OUT_H))
            ffmpeg.stdin.write(pygame.image.tobytes(frame, "RGB"))
        frames += 1
        if tick in still_ticks:
            pygame.image.save(surf, str(stills_dir / f"{still_ticks[tick]}.png"))

    if ffmpeg is not None:
        ffmpeg.stdin.close()
        ffmpeg.wait()
        print(f"wrote {out_path}: {frames} frames = {frames / FPS:.1f}s, one take")
    else:
        print(f"quick run: {frames} frames, stills in {stills_dir}")
        return 0

    # -------------------------------------------------------------------
    # verification: extract stills FROM THE ENCODED MP4 (same-artifact
    # rule) at each mark's timestamp, then probe pixel brightness there.
    # -------------------------------------------------------------------
    mp4_stills_dir = out_path.parent / "stills_from_mp4"
    mp4_stills_dir.mkdir(parents=True, exist_ok=True)
    fail = False
    print("\n--- probes (sampled from the encoded MP4) ---")
    for tick, name in still_ticks.items():
        if name not in probe_screen:
            continue
        t = (tick - 1) / FPS
        png = mp4_stills_dir / f"{name}.png"
        subprocess.run([
            "ffmpeg", "-y", "-ss", f"{t:.4f}", "-i", str(out_path),
            "-frames:v", "1", str(png),
        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(f"[{name}] t={t:.2f}s")
        lit_vals = []
        dark_vals = []
        for label, sx, sy, expect in probe_screen[name]:
            rgb = probe(png, int(round(sx)), int(round(sy)))
            brightness = sum(rgb) / 3.0
            print(f"    {label:26s} screen=({sx:6.1f},{sy:6.1f}) "
                  f"rgb={rgb} mean={brightness:5.1f} expect={expect}")
            if expect == "lit":
                lit_vals.append(brightness)
                # ABSOLUTE gate (director's order after capture 1: ratios
                # alone certified an all-but-black frame): a lit probe
                # must be unmistakably bright in the encoded video, not
                # merely brighter than the void next to it.
                if brightness < LIT_MIN:
                    print(f"    !! {label} expected LIT >= {LIT_MIN} but "
                          f"measured {brightness:.1f} -- too dim to read")
                    fail = True
            else:
                dark_vals.append(brightness)
                if brightness > DARK_MAX:
                    print(f"    !! {label} expected DARK <= {DARK_MAX} but "
                          f"measured {brightness:.1f} -- possible light bleed")
                    fail = True
        if lit_vals and dark_vals:
            ratio = min(lit_vals) / max(0.5, max(dark_vals))
            print(f"    contrast ratio (min lit / max dark) = {ratio:.1f}x")
            if ratio < 10.0:
                print(f"    !! contrast ratio below 10x threshold")
                fail = True

    print(f"\nstills (from mp4): {mp4_stills_dir}")
    if fail:
        print("\nVERIFICATION FAILED: see !! lines above")
        return 1
    print("\nVERIFICATION OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
