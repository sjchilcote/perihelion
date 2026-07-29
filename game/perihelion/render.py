"""Immediate-mode renderer: necore draw lists -> a 640x360 numpy framebuffer.

ONE renderer: world/entity/coverage rasterize in Rust via a necore.Raster
display list. Per-polygon detail props are encoded once into cached command
blobs (polygon-local coords; the raster transforms and clips them without the
GIL), everything dynamic is emitted already-rounded in screen space, and the
composed RGBA frame is blitted back. Darkness (including the otherworld
inverse field), deferred glows, bolts, post overlays, and debug text
composite in Python on the blitted frame.

There used to be a second, pure-pygame world renderer behind a `backend`
switch, kept as a "byte-identical" fallback/parity reference. It was deleted
(2026-07-22): two renderers meant tests and frame-reviews could validate the
pygame one while the game shipped rust, and they were NOT identical where it
mattered. There is exactly one renderer now, so what the tests see is what
ships.)

This module contains NO pygame at all: world/entity/coverage rasterize in
Rust (necore.Raster), every composite step (lightmap multiply, glow/light
accumulation, otherworld darkness field, post overlays) is numpy on the
framebuffer, textures load via PIL, and text goes through the bitmap-font
path in `text.py`. `draw()` returns a (W, H, 3) uint8 array (pygame
surfarray axis order); the caller owns whatever display Surface it blits to.
All post/glow buffers are pre-baked numpy arrays; draw() allocates only the
returned snapshot.

Effect pools (gibs, sparks, flashes, lightning, screams, hitflash, hurt/die
overlays) are time-decayed in `consume_fx`, which the caller drives once per
*sim tick* (fixed 60Hz) — not once per display frame — so all "N frames"
durations in the spec are exactly N ticks, keeping presentation state
frame-rate independent like everything else in this engine.
"""

from __future__ import annotations

import json
import math
import os
import random
from pathlib import Path

import numpy as np
from PIL import Image

import necore

from . import texture_geom
from . import text
from .sim import BUILDING_UNPACK_TICKS, CALL_TRANSMIT_TICKS, DT
from .sim import ENEMIES as SIM_ENEMIES
from .sim import SENTRIES as SENTRY_SPECS

_DEFAULT_INTERNAL_W, _DEFAULT_INTERNAL_H = 640, 360


def _parse_internal_res() -> tuple[int, int]:
    """`PERIHELION_INTERNAL_RES=WxH` overrides the internal render
    resolution (default unchanged: 640x360). Malformed values fail loudly
    rather than silently falling back."""
    raw = os.environ.get("PERIHELION_INTERNAL_RES")
    if not raw:
        return _DEFAULT_INTERNAL_W, _DEFAULT_INTERNAL_H
    try:
        w_s, h_s = raw.lower().split("x")
        w, h = int(w_s), int(h_s)
        if w <= 0 or h <= 0:
            raise ValueError
    except ValueError as exc:
        raise ValueError(
            f"PERIHELION_INTERNAL_RES must be WxH (e.g. 1280x720), got {raw!r}"
        ) from exc
    return w, h


INTERNAL_W, INTERNAL_H = _parse_internal_res()

# The camera's baseline zoom (GameSession's default 1.0, sim.py) is
# authored for the 640x360 default internal resolution. Scale it by the
# resolution ratio so the world-space field of view is unchanged when
# PERIHELION_INTERNAL_RES changes the internal render size (ARTSTYLE_DIRECTION.md:
# "at 1280x720 zoom doubles, ~3 px/world-unit territory" -- 1.0 * 2 = 2.0).
INTERNAL_RES_ZOOM_SCALE = INTERNAL_W / _DEFAULT_INTERNAL_W


def ui(px: float) -> int:
    """Scale a screen-space pixel constant tuned for the 640x360 default
    internal resolution to the actual internal resolution, so HUD/menu/toast
    layout occupies the same screen fraction at any PERIHELION_INTERNAL_RES.
    At the default resolution this is the identity on ints (regression bar:
    pixel-identical output at 640x360)."""
    return int(round(px * INTERNAL_RES_ZOOM_SCALE))


TEXTURE_DIR = Path(__file__).resolve().parent / "assets" / "textures"
# how far the entity coverage mask is dilated past the visible world, in
# WORLD units: a hair over the largest body radius (warden 16u), converted
# to screen px per instance by that instance's own transform scale.
# A fixed 18 SCREEN px baked in the shipped zoom here (run 45 era): at
# farm zoom 0.45 a body is ~7px, so bodies and buildings leaked 2.5
# body-widths past the LOS shadow boundary (director 2026-07-27: "not
# correctly cut off ... the renderer assumed a certain zoom level")
ENTITY_SPILL_U = 18.0


def _dilate_poly(pts, px):
    """Push a screen polygon outward from its centroid by `px`. Used only
    to widen the ENTITY coverage mask, never the floor fill."""
    n = len(pts)
    if n < 3:
        return list(pts)
    cx = sum(p[0] for p in pts) / n
    cy = sum(p[1] for p in pts) / n
    out = []
    for x, y in pts:
        dx, dy = x - cx, y - cy
        d = math.hypot(dx, dy)
        if d < 1e-6:
            out.append((x, y))
        else:
            out.append((x + dx / d * px, y + dy / d * px))
    return out

FLOOR_BASE = (104, 104, 132)       # flat-floor ALBEDO (2026-07-13): under zero-ambient
                                   # multiply lighting the floor color is the brightness
                                   # ceiling — at the old (26,26,33) no light could lift a
                                   # bare polygon past ~11%. Scaled x4 into the same albedo
                                   # class as generated textures (measured 100-150) so
                                   # fixtures and the work lamp read on untextured polygons.
                                   # UNLIT floors still render black (the lightmap is the
                                   # sole illumination); this only changes what light finds.
SHADOW_FLOOR = (11, 11, 15)        # known geometry outside line of sight: present, unlit
OW_FLOOR = (52, 64, 58)            # otherworld: the floor itself luminesces, cold
WALL_COLOR = (184, 196, 204)       # 0xb8c4cc
WALL_MIN = (74, 80, 88)            # 0x4a5058 — walls never dim below this (readability skeleton)
DOOR_COLOR = (208, 128, 24)        # 0xd08018
KEY_COLORS = {
    "red": (200, 60, 60),
    "blue": (72, 132, 222),
    "gold": (216, 180, 70),
    "void": (122, 42, 168),
}
BLOOD_COLOR = (64, 12, 15)         # kept below every live-enemy fill: residue never outranks threats
SCORCH_COLOR = (42, 38, 36)
CHIP_COLOR = (150, 150, 140)
EXIT_COLOR = (120, 255, 172)
GIB_COLOR = (94, 16, 16)
SPARK_COLOR = (255, 230, 120)
LIGHTNING_COLOR = (205, 242, 255)
SCREAM_COLOR = (230, 230, 240)

# -- diegetic prop palette -------------------------------------------------
# Desaturated & dark by design: props read below the enemy-color range (the
# brightest enemies run 200+) and above the floor (26,26,33), so furniture
# never competes with a live threat for the eye. Hazard/screen accents are
# the deliberate exceptions -- a lit instrument or caution stripe is meant
# to pop, the way a door key color pops against everything else.
PROP_COLOR = (58, 62, 72)          # structural fill: crates, cots, shelves
PROP_RIM = (90, 96, 108)           # prop edge / rim -- one step brighter
PROP_DARK = (38, 40, 48)           # recessed fill: slabs, lockers, cabinets
HAZARD_COLOR = (150, 112, 40)      # dull amber hazard stripe
HAZARD_COLOR_DIM = (98, 76, 34)
PIPE_COLOR = (70, 80, 92)
PUDDLE_COLOR = (32, 40, 48)
SCREEN_COLOR = (110, 235, 165)     # lit phosphor screen (lab consoles, terminals)
SCREEN_DIM = (46, 96, 78)          # unlit / already-read screen
HYDRO_TRAY = (44, 68, 48)          # planter trough fill: green-tinted, still below screen brightness
HYDRO_RIM = (74, 100, 78)          # trough rim -- one step brighter, same delta as PROP_RIM/PROP_COLOR
HYDRO_STALK = (88, 152, 96)        # growing stalk dot -- dimmer than SCREEN_COLOR, distinct from GROWTH's red rot

# -- the descent arc ---------------------------------------------------------
# One station, falling sunward. `level.polygon_descent` holds a per-polygon scalar
# 0..1: chunk k of N sits at k/(N-1) (stream.py extends the list as chunks
# append; transit spines take the midpoint of the chunks they join; a level
# loaded alone derives it from its tier). Descent drives a palette drift —
# cold industrial grey-blue at the dock, dried-blood warmth through the
# middle decks, deep wrong red with the first suggestion of organic growth
# near the Perihelion Core — plus rising grime and, past ~0.55, per-kind
# prop corruption. Every per-chunk step is deliberately tiny (a full step
# moves the floor ~3 per channel) so no portal crossing ever reads as a
# palette seam: SEAMLESSNESS IS LAW; the drama is cumulative. Ramps below
# are (cold, mid, deep) waypoints sampled piecewise-linearly at d=0/0.5/1.
_FLOOR_RAMP = ((104, 104, 132), (152, 112, 120), (200, 88, 100))  # x4 albedo (deep clamped ~x3.8)
_WALL_RAMP = ((184, 196, 204), (194, 186, 178), (206, 168, 154))
_WALL_MIN_RAMP = ((74, 80, 88), (80, 75, 73), (90, 66, 62))
# The MARROW's own ramp (marrow visual pass 2026-07-28). The cathedral
# does not descend toward the Testament's dried-blood warmth — it
# descends toward the otherworld's cold. Aged bronze and pale bone at
# the receiving apses, verdigris through the trunk, cold green-blue at
# the sources, so the architecture stays legibly Testator handcraft
# under whatever the Adversary has done to it.
_MARROW_FLOOR_RAMP = ((104, 96, 88), (86, 100, 96), (58, 78, 76))
_MARROW_WALL_RAMP = ((184, 178, 151), (150, 168, 158), (104, 132, 128))
_MARROW_WALL_MIN_RAMP = ((78, 74, 64), (66, 78, 74), (52, 66, 64))
_MARROW_KINDS = ("marrow", "otherworld")


def _ow_mix(descent: float) -> float:
    """How much of the otherworld's inverse-darkness lighting model this
    chamber composes under. A hard swap at the kind boundary reads as a
    theme trigger, not as encroaching corruption, so the LIGHTING
    arrives smoothly while the semantic kind still switches at depth 6.

    The consult proposed smoothstep(0.25, 0.85); measured against the
    depth table that is 0.88 at the switch itself, which finishes the
    transition BEFORE the boundary and leaves the whole deep half
    composing alike. Centering the curve on the switch keeps the deep
    chambers differentiated — the first otherworld chamber is half under
    the inverse field and the source cells are wholly under it — while
    the earlier progression is carried by the palette ramp and the prop
    corruption, which start much shallower."""
    d = max(0.0, min(1.0, (descent - 0.45) / 0.55))
    return d * d * (3.0 - 2.0 * d)
_PROP_WARM = (18, -6, -16)         # additive full-descent prop temperature shift

GROWTH_FILL = (44, 14, 16)         # the seed's spread: organic patches
GROWTH_RIM = (92, 34, 28)          # must read against the deepest floor (54,22,26)
TENDRIL_COLOR = (84, 30, 24)       # dimmer than any prop rim, brighter than floor
_GRIME_COLD = (33, 27, 28)
_GRIME_DEEP = (44, 16, 16)
_MARK_COLD = (70, 74, 84)          # Congregation crosses, scratched near walls
_MARK_DEEP = (98, 74, 64)

# accent colors that must keep their pop at every depth: lit phosphor,
# the medbay cross, and the corruption palette (authored at final value)
_DESCENT_KEEP = {SCREEN_COLOR, SCREEN_DIM, (200, 90, 90),
                 GROWTH_FILL, GROWTH_RIM, TENDRIL_COLOR}


def _mix(a, b, t: float):
    return (int(round(a[0] + (b[0] - a[0]) * t)),
            int(round(a[1] + (b[1] - a[1]) * t)),
            int(round(a[2] + (b[2] - a[2]) * t)))


def _ramp(way, d: float):
    """Sample a (cold, mid, deep) waypoint triple at descent d in [0, 1]."""
    if d <= 0.5:
        return _mix(way[0], way[1], d * 2.0)
    return _mix(way[1], way[2], (d - 0.5) * 2.0)


def _warm(color, d: float):
    """Drift a structural prop color toward dried-blood warmth. Accents in
    _DESCENT_KEEP pass through untouched so instruments and growth keep
    their deliberate pop against the drifting floor."""
    if d <= 0.0 or color in _DESCENT_KEEP:
        return color
    return (max(0, min(255, int(round(color[0] + _PROP_WARM[0] * d)))),
            max(0, min(255, int(round(color[1] + _PROP_WARM[1] * d)))),
            max(0, min(255, int(round(color[2] + _PROP_WARM[2] * d)))))


def _corruption(descent: float) -> float:
    """0 until descent 0.55, then ramps to 1.0 at the core: the threshold
    past which props themselves start going wrong."""
    return max(0.0, (descent - 0.55) / 0.45)

PLAYER_SHAPE = [(1.3, 0.0), (-0.8, 0.85), (-0.35, 0.0), (-0.8, -0.85)]
PLAYER_COLOR = (205, 248, 255)


def _regular_lumpy(n, radii, phase=0.0):
    pts = []
    for i in range(n):
        a = phase + i * 2.0 * math.pi / n
        r = radii[i % len(radii)]
        pts.append((math.cos(a) * r, math.sin(a) * r))
    return pts


_CIRCLE_SHAPE = _regular_lumpy(8, [1.0] * 8)

ENEMY_SHAPE = {
    "husk": _regular_lumpy(7, [0.75, 1.0, 0.85, 1.05, 0.7, 0.95, 0.8]),
    "spitter": _regular_lumpy(6, [0.8, 0.95, 0.75, 1.0, 0.8, 0.9]),
    "brute": _regular_lumpy(5, [1.0, 0.95, 1.05, 0.95, 1.0]),
    "warden": _regular_lumpy(9, [0.9, 1.0, 0.85, 1.05, 0.9, 0.95, 1.0, 0.85, 1.0]),
    "shrieker": [(1.4, 0.0), (0.0, 0.28), (-1.4, 0.0), (0.0, -0.28)],
    # low, angular, close to the ground -- reads as something that holds
    # still rather than something that runs (Adversary lane: total chaos
    # in its OWN silhouette, jagged rather than the biological lumpiness
    # the other kinds use).
    "flicker": _regular_lumpy(6, [1.05, 0.55, 0.95, 0.5, 1.0, 0.6], phase=0.4),
    # the Adversary's own geometry: too many sides, none of them agreeing
    # radii kept near 1.0 on purpose: at gameplay scale the old 0.45-1.2
    # spread read as a TRIANGLE from one angle and a DIAMOND from another,
    # so one species looked like two (frame review, 2026-07-21). The
    # never-still quality comes from _boil, not from the base shape.
    "vagrant": _regular_lumpy(8, [1.08, 0.86, 1.0, 0.84, 1.1, 0.88, 0.98,
                                  0.86], phase=0.2),
    "lacuna": _regular_lumpy(10, [1.12, 0.82, 1.04, 0.8, 1.1, 0.84, 1.0,
                                  0.86, 1.06, 0.8], phase=0.55),
}
# Adversary sensor trace: these do not return like a body does. Drawn as an
# unfilled, doubled outline whose vertices are re-solved every frame (see
# _draw_enemy), in a channel colour nothing in the Testator lane uses.
ADVERSARY_TRACE = {"vagrant": (120, 245, 230), "lacuna": (185, 140, 255)}
# how much wider than its hitbox the Adversary's trace is drawn — see
# _draw_adversary. Render-only: the sim never reads this. History: 2.3,
# then 1.5. At the shipped 0.45 zoom (director 2026-07-28: 0.45 IS the
# zoom — play, capture, farm) the ENEMY_MIN_PX floors keep the base body
# legible, and 1.5 keeps the trace clearly larger-than-the-body (the
# "unresolvable return" read) without swallowing close passes.
ADVERSARY_TRACE_SCALE = 1.5


def _boil(pts, tick, eid, amp):
    """Re-solve a silhouette's vertices for this frame: every vertex walks
    its own little orbit, so the outline never settles. Deterministic in
    (tick, eid, vertex) — the same frame always boils the same way."""
    out = []
    for i, (x, y) in enumerate(pts):
        h = ((eid * 2654435761) + i * 40503) % 997 / 997.0
        a = (tick * 0.13) + h * 6.283
        out.append((x + math.cos(a * (1.0 + h)) * amp,
                    y + math.sin(a * (1.6 - h * 0.5)) * amp))
    return out


# Minimum on-screen body radius per kind (screen px). The sentry law
# ("has to read at the shipped 0.45 zoom, not shrink to three dark
# pixels") applied to every combatant, TIERED so threat rank survives
# any camera: a warden must never compress to the same speck as a
# mite — the filmed gate's 'every unit renders as an identical small
# yellow triangle' blocker. If the player later zooms IN (planned
# mousewheel zoom), real sizes exceed these floors and nothing changes.
ENEMY_MIN_PX = {
    "mite": 3.0,
    "husk": 6.0, "spitter": 6.0, "shrieker": 6.0, "flicker": 6.0,
    "vagrant": 7.0, "lacuna": 7.0,
    "brute": 8.0,
    "warden": 10.0,
}

ENEMY_COLOR = {
    "husk": (126, 142, 116),
    "mite": (208, 220, 198),
    "spitter": (128, 140, 74),
    "brute": (158, 80, 64),
    "shrieker": (236, 228, 205),
    "warden": (52, 32, 60),
    "flicker": (150, 60, 150),
    # shadow/silhouette passes only — the Adversary's live trace is drawn
    # by _draw_adversary, which never touches these
    "vagrant": (40, 90, 88),
    "lacuna": (62, 48, 92),
}




# ---------------------------------------------------------------------------
# draw canvases — one drawing interface shared by both backends. Every call
# site passes exactly the (already-rounded) arguments it used to pass to
# pygame.draw; the pygame canvas forwards them verbatim, the rust canvas
# packs the identical values into necore.Raster display-list commands (see
# engine/necore/src/raster.rs for the wire format). Because the raster's
# primitives are pixel-exact ports of pygame-ce's, identical arguments on
# either canvas produce identical pixels.
# ---------------------------------------------------------------------------

_OP_POLY_FILL, _OP_POLY_OUTLINE, _OP_POLYLINE = 0, 1, 2
_OP_CIRCLE_FILL, _OP_CIRCLE_OUTLINE = 3, 4
_OP_RECT_FILL, _OP_RECT_OUTLINE = 5, 6
_OP_CLIP_FILL = 8
_OP_DECALS = 10
_OP_TEX_FILL = 9
_LAYER_WORLD, _LAYER_ENTITY = 0, 1
_CLIP_NONE, _CLIP_GEOM, _CLIP_GATE = 0, 1, 2
_FLAG_CLOSED = 1 << 4
_IDX_NONE = 0xFFFFFFFF


def _flags(layer, clipmode=_CLIP_NONE, closed=False, width=0):
    return ((layer & 3) | ((clipmode & 3) << 2)
            | (_FLAG_CLOSED if closed else 0) | ((width & 0xFF) << 8))


def _rgba(color):
    return ((color[0] & 0xFF) << 24) | ((color[1] & 0xFF) << 16) \
        | ((color[2] & 0xFF) << 8) | 0xFF


class Rect:
    """Minimal screen-space rectangle — the renderer's rectangle datatype,
    replacing pygame.Rect. Iterable as (x, y, w, h) so a canvas.rect() call
    unpacks it directly; exposes the handful of edge/center accessors the
    glyph/prop code reads. Ints throughout (pygame.Rect truncated too)."""

    __slots__ = ("x", "y", "w", "h")

    def __init__(self, x, y=None, w=None, h=None):
        if y is None:  # constructed from a single 4-iterable (x, y, w, h)
            x, y, w, h = x
        self.x, self.y, self.w, self.h = int(x), int(y), int(w), int(h)

    def __iter__(self):
        return iter((self.x, self.y, self.w, self.h))

    @property
    def left(self):
        return self.x

    @property
    def top(self):
        return self.y

    @property
    def right(self):
        return self.x + self.w

    @property
    def bottom(self):
        return self.y + self.h

    @property
    def width(self):
        return self.w

    @property
    def height(self):
        return self.h

    @property
    def centerx(self):
        return self.x + self.w // 2

    @property
    def centery(self):
        return self.y + self.h // 2

    @property
    def topleft(self):
        return (self.x, self.y)

    @property
    def center(self):
        return (self.centerx, self.centery)

    @center.setter
    def center(self, pos):
        cx, cy = pos
        self.x = int(cx) - self.w // 2
        self.y = int(cy) - self.h // 2


def _size_of(surf) -> tuple[int, int]:
    """(w, h) of a draw target, duck-typed so render.py never imports pygame:
    a pygame.Surface (get_size), a numpy frame ((W, H, ...) shape), or a plain
    (w, h) tuple all work. The target is used ONLY for sizing; draw() returns
    the composited framebuffer, it never writes back into `surf`."""
    gs = getattr(surf, "get_size", None)
    if gs is not None:
        return gs()
    if isinstance(surf, np.ndarray):
        return int(surf.shape[0]), int(surf.shape[1])
    w, h = surf
    return int(w), int(h)


def _mult_into(dst: np.ndarray, src) -> None:
    """In-place pygame BLEND_RGB_MULT: dst = (src*dst + 255) >> 8, per channel
    (the exact pygame-ce 2.5.7 multiply). `dst` is a (..., 3) uint8 view;
    `src` is a broadcastable uint8 array or 3-tuple."""
    d = dst.astype(np.uint32)
    s = np.asarray(src, dtype=np.uint32)
    np.copyto(dst, ((s * d + 255) >> 8).astype(np.uint8))


def _add_into(dst: np.ndarray, src) -> None:
    """In-place pygame BLEND_RGB_ADD: dst = min(255, src + dst)."""
    d = dst.astype(np.uint16)
    s = np.asarray(src, dtype=np.uint16)
    np.copyto(dst, np.minimum(d + s, 255).astype(np.uint8))


class _RustCanvas:
    """Packs draw calls into a necore.Raster command stream. World and
    entity canvases share the same `cmds`/`coords` lists so the stream keeps
    submission order (each command routes to its plane by the layer flag).
    All geometry arriving here is screen-space and pre-rounded by the call
    sites (via _pt/_pts/int), exactly as the pygame path receives it."""

    __slots__ = ("layer", "cmds", "coords")

    def __init__(self, layer, cmds, coords):
        self.layer = layer
        self.cmds = cmds
        self.coords = coords

    def polygon(self, color, pts, width=0):
        op = _OP_POLY_FILL if width == 0 else _OP_POLY_OUTLINE
        self.cmds.extend((op, _flags(self.layer, width=width),
                          _IDX_NONE, _IDX_NONE, _rgba(color), len(pts)))
        co = self.coords
        for p in pts:
            co.append(p[0])
            co.append(p[1])

    def line(self, color, a, b, width=1):
        self.cmds.extend((_OP_POLYLINE, _flags(self.layer, width=width),
                          _IDX_NONE, _IDX_NONE, _rgba(color), 2))
        self.coords.extend((a[0], a[1], b[0], b[1]))

    def lines(self, color, closed, pts, width=1):
        self.cmds.extend((_OP_POLYLINE,
                          _flags(self.layer, closed=closed, width=width),
                          _IDX_NONE, _IDX_NONE, _rgba(color), len(pts)))
        co = self.coords
        for p in pts:
            co.append(p[0])
            co.append(p[1])

    def circle(self, color, center, radius, width=0):
        op = _OP_CIRCLE_FILL if width == 0 else _OP_CIRCLE_OUTLINE
        self.cmds.extend((op, _flags(self.layer, width=width),
                          _IDX_NONE, _IDX_NONE, _rgba(color), 0))
        self.coords.extend((center[0], center[1], radius))

    def rect(self, color, r, width=0):
        op = _OP_RECT_FILL if width == 0 else _OP_RECT_OUTLINE
        x, y, w, h = r
        self.cmds.extend((op, _flags(self.layer, width=width),
                          _IDX_NONE, _IDX_NONE, _rgba(color), 0))
        self.coords.extend((x, y, w, h))

    def set_at(self, pos, color):
        # pygame set_at == a clip-checked single-pixel write; a 1x1 rect
        # fill (SDL_FillRect of the clipped rect) lands the same pixel.
        self.rect(color, (pos[0], pos[1], 1, 1))

    def _hspan(self, color, xa, xb, y):
        # drawhorzlineclipbounding: order endpoints, then fill the span.
        if xb < xa:
            xa, xb = xb, xa
        self.rect(color, (xa, y, xb - xa + 1, 1))

    def ellipse(self, color, r):
        """pygame.draw.ellipse(width=0) parity: a line-for-line port of
        pygame-ce 2.5.7 draw_ellipse_filled, emitting its horizontal spans
        as 1px-high rect fills. Only the filled form exists in this
        codebase (draw_key_glyph's signet)."""
        rr = r if isinstance(r, Rect) else Rect(r)
        x0, y0, w, h = rr.x, rr.y, rr.w, rr.h
        if w == 1:
            self.line(color, (x0, y0), (x0, y0 + h - 1), 1)
            return
        if h == 1:
            self._hspan(color, x0, x0 + w - 1, y0)
            return
        cx = x0 + w // 2
        cy = y0 + h // 2
        x_off = (w + 1) % 2
        y_off = (h + 1) % 2
        rx = w // 2
        ry = h // 2
        x, y = 0, ry
        d1 = (ry * ry) - (rx * rx * ry) + 0.25 * rx * rx
        dx = 2 * ry * ry * x
        dy = 2 * rx * rx * y
        while dx < dy:
            self._hspan(color, cx - x, cx + x - x_off, cy - y)
            self._hspan(color, cx - x, cx + x - x_off, cy + y - y_off)
            if d1 < 0:
                x += 1
                dx += 2 * ry * ry
                d1 += dx + ry * ry
            else:
                x += 1
                y -= 1
                dx += 2 * ry * ry
                dy -= 2 * rx * rx
                d1 += dx - dy + ry * ry
        d2 = ((ry * ry) * ((x + 0.5) * (x + 0.5))
              + (rx * rx) * ((y - 1) * (y - 1))
              - rx * rx * ry * ry)
        while y >= 0:
            self._hspan(color, cx - x, cx + x - x_off, cy - y)
            self._hspan(color, cx - x, cx + x - x_off, cy + y - y_off)
            if d2 > 0:
                y -= 1
                dy -= 2 * rx * rx
                d2 += rx * rx - dy
            else:
                y -= 1
                x += 1
                dx += 2 * ry * ry
                dy -= 2 * rx * rx
                d2 += dx - dy + rx * rx


def draw_key_glyph(canvas, item_name, cx, cy, r, color) -> bool:
    """Tiny object silhouette for a diegetic key item; returns False when
    the name matches no known family (caller draws its fallback).

    `canvas` is a renderer draw canvas (_RustCanvas)."""
    name = (item_name or "").upper()
    ix, iy, r = int(cx), int(cy), max(4, int(r))
    if "WHEEL" in name:
        canvas.circle(color, (ix, iy), r, 1)
        for a in (0.0, math.pi / 2, math.pi, 3 * math.pi / 2):
            canvas.line(color, (ix, iy),
                        (ix + int(math.cos(a) * r), iy + int(math.sin(a) * r)), 1)
        canvas.circle(color, (ix, iy), max(1, r // 4))
        return True
    if "CARTRIDGE" in name or "CANISTER" in name:
        w, h = max(4, int(r * 0.9)), max(6, int(r * 1.4))
        rect = Rect(ix - w // 2, iy - h // 2, w, h)
        canvas.rect(color, rect, 1)
        for k in range(3):
            y = rect.top + 2 + k * max(2, h // 4)
            canvas.line(color, (rect.left + 1, y), (rect.right - 2, y), 1)
        canvas.line(color, (ix, rect.top - 2), (ix, rect.top), 2)
        return True
    if "CARD" in name:
        w, h = max(8, int(r * 1.5)), max(5, int(r * 0.9))
        rect = Rect(ix - w // 2, iy - h // 2, w, h)
        canvas.rect(color, rect, 1)
        canvas.line(color, (rect.right - 3, rect.top),
                    (rect.right, rect.top + 3), 1)
        mx, my = rect.left + w // 3, rect.centery
        canvas.line(color, (mx - 2, my), (mx + 2, my), 1)
        canvas.line(color, (mx, my - 2), (mx, my + 2), 1)
        return True
    if "HANDLE" in name or "LEVER" in name:
        canvas.line(color, (ix - r, iy + r // 2), (ix, iy + r // 2), 2)
        canvas.line(color, (ix, iy + r // 2), (ix, iy - r), 2)
        canvas.rect(color, (ix - 2, iy - r - 3, 5, 5), 1)
        return True
    if "STAMP" in name:
        canvas.circle(color, (ix, iy - r // 2), max(2, r // 3))
        canvas.line(color, (ix, iy - r // 4), (ix, iy + r // 4), 2)
        canvas.line(color, (ix - r + 1, iy + r // 2),
                    (ix + r - 1, iy + r // 2), 2)
        return True
    if "TOKEN" in name:
        pts = [(ix + int(math.cos(a) * r), iy + int(math.sin(a) * r))
               for a in [math.pi / 6 + k * math.pi / 3 for k in range(6)]]
        canvas.polygon(color, pts, 1)
        for dx, dy in ((-2, -2), (2, -2), (-2, 2), (2, 2)):
            canvas.set_at((ix + dx, iy + dy), color)
        return True
    if "SIGNET" in name:
        canvas.circle(color, (ix, iy + 1), max(3, int(r * 0.8)), 1)
        canvas.ellipse(color, (ix - r // 2, iy - r + 1, r, max(3, r // 2)))
        return True
    if "KEY" in name:
        canvas.circle(color, (ix - int(r * 0.5), iy), max(2, int(r * 0.45)), 1)
        canvas.line(color, (ix - int(r * 0.1), iy), (ix + r, iy), 1)
        canvas.line(color, (ix + int(r * 0.55), iy),
                    (ix + int(r * 0.55), iy + int(r * 0.45)), 1)
        canvas.line(color, (ix + r - 1, iy), (ix + r - 1, iy + int(r * 0.45)), 1)
        return True
    return False

def _brighten(c, amt: int):
    return (min(255, c[0] + amt), min(255, c[1] + amt), min(255, c[2] + amt))


def _scale_color(c, f: float):
    return (int(c[0] * f), int(c[1] * f), int(c[2] * f))


# Every enemy gets a value-contrast outline (fill +70); these override the
# derived color/width where the archetype's read demands it.
ENEMY_RIM = {"warden": (235, 235, 245)}
ENEMY_RIM_W = {"brute": 2}

BLOOD_BLOB = _regular_lumpy(6, [1.0, 0.7, 0.9, 0.6, 0.85, 0.75])
SPLAT_BLOB = _regular_lumpy(4, [0.8, 0.5, 0.7, 0.5])

GIB_FRICTION = 0.90


def _dim(depth: int) -> float:
    # Depth dimming was a seam: crossing a portal snapped the new polygon's
    # brightness (invariant 5). Distance-to-player lighting replaces it —
    # applied screen-space after the world draw, smooth across portals.
    return 1.0


def _floor_dim(depth: int) -> tuple[float, float, float]:
    return (1.0, 1.0, 1.0)



def _shade(base, dim, tint=(0, 0, 0)):
    if isinstance(dim, tuple):
        dr, dg, db = dim
    else:
        dr = dg = db = dim
    r = min(255, max(0, int((base[0] + tint[0]) * dr)))
    g = min(255, max(0, int((base[1] + tint[1]) * dg)))
    b = min(255, max(0, int((base[2] + tint[2]) * db)))
    return (r, g, b)


def _polygon_tint(polygon: int):
    # Constitution: one continuous space — floor color must never step at a
    # portal. Per-polygon hash tints (up to +20/channel on a 26 base, a 1.8x
    # visible seam) predate the polygon-kind prop language, which now carries
    # all the "this polygon is different" signal. Polygons therefore share one
    # base; variation comes from props, decals, and the darkness field.
    return (0, 0, 0)


def _point_in_poly(x: float, y: float, poly) -> bool:
    """Winding-independent (ray casting) point-in-convex-polygon test.

    Screen-space clip polygons can come out CW instead of CCW when a portal
    xform has a chirality flip, so this must not assume a winding order.
    """
    n = len(poly)
    if n < 3:
        return False
    inside = False
    j = n - 1
    for i in range(n):
        xi, yi = poly[i]
        xj, yj = poly[j]
        if (yi > y) != (yj > y):
            x_at = (xj - xi) * (y - yi) / (yj - yi) + xi
            if x < x_at:
                inside = not inside
        j = i
    return inside


def _xform_pts(points, cx, cy, scale, ang, squash=1.0):
    ca, sa = math.cos(ang), math.sin(ang)
    out = []
    for lx, ly in points:
        ly2 = ly * squash
        rx = lx * ca - ly2 * sa
        ry = lx * sa + ly2 * ca
        out.append((cx + rx * scale, cy + ry * scale))
    return out


def _xform_scale(xform) -> float:
    dx, dy = necore.mat_apply_dir(xform, 1.0, 0.0)
    return math.hypot(dx, dy)


def _pt(p):
    return (int(round(p[0])), int(round(p[1])))


def _pts(poly):
    return [(int(round(x)), int(round(y))) for x, y in poly]


def _f32(v: float) -> float:
    return float(np.float32(v))


def _snap_prims_f32(prims):
    """Quantize detail-prim geometry to float32 — the display list's wire
    precision — at cache time, so BOTH backends transform bit-identical
    inputs and stay pixel-identical. The shift is < 1e-4 px at screen scale;
    it happens once per polygon, before any frame ever samples the prim."""
    out = []
    for prim in prims:
        kind = prim[0]
        if kind == "line":
            (ax, ay), (bx, by) = prim[1], prim[2]
            out.append((kind, (_f32(ax), _f32(ay)), (_f32(bx), _f32(by)))
                       + tuple(prim[3:]))
        elif kind == "dot":
            (x, y) = prim[1]
            out.append((kind, (_f32(x), _f32(y))) + tuple(prim[2:]))
        elif kind in ("stain", "poly", "polyline"):
            pts = [(_f32(x), _f32(y)) for x, y in prim[1]]
            out.append((kind, pts) + tuple(prim[2:]))
        elif kind == "screenglow":
            out.append((kind, _f32(prim[1]), _f32(prim[2]), _f32(prim[3])))
        else:
            out.append(prim)
    return out


# ---------------------------------------------------------------------------
# diegetic prop geometry -- polygon-local coordinate helpers and per-polygon-kind
# prop-set generators. Everything below is pure geometry (no pygame, no
# necore): it produces the same `_get_detail` primitive tuples the old
# grime generator did ("line"/"dot"/"stain"), plus three new kinds
# ("poly", "polyline", "screenglow") that `Renderer._draw_detail` knows how
# to clip and paint. Polygon-local coords are always centroid-at-origin (the
# Level contract), which is what makes "toward the polygon interior" always
# just mean "toward (0, 0)".
# ---------------------------------------------------------------------------


def _rect_local(cx, cy, w, h, ang=0.0):
    hw, hh = w / 2.0, h / 2.0
    ca, sa = math.cos(ang), math.sin(ang)
    corners = [(-hw, -hh), (hw, -hh), (hw, hh), (-hw, hh)]
    return [(cx + x * ca - y * sa, cy + x * sa + y * ca) for x, y in corners]


def _ring_local(cx, cy, r, n=16):
    return [(cx + r * math.cos(2.0 * math.pi * i / n),
             cy + r * math.sin(2.0 * math.pi * i / n)) for i in range(n)]


def _arc_local(cx, cy, r, a0, a1, n=10):
    return [(cx + r * math.cos(a0 + (a1 - a0) * i / n),
             cy + r * math.sin(a0 + (a1 - a0) * i / n)) for i in range(n + 1)]


def _basis_arc_local(cx, cy, r, tx, ty, nx, ny, a0=-math.pi / 2, a1=math.pi / 2, n=8):
    """Arc in the (tangent, normal) basis of a wall: a=0 sits `r` along
    (nx,ny) from (cx,cy); a=+-pi/2 sits `r` along +-(tx,ty). Lets callers
    place a bulge "into the polygon" without caring which way the wall faces
    in world coordinates."""
    pts = []
    for i in range(n + 1):
        a = a0 + (a1 - a0) * i / n
        pts.append((cx + (tx * math.sin(a) + nx * math.cos(a)) * r,
                     cy + (ty * math.sin(a) + ny * math.cos(a)) * r))
    return pts


def _edge_inward_normal(x0, y0, x1, y1):
    """Unit normal of edge (x0,y0)->(x1,y1) pointing toward the polygon
    interior (polygon-local origin)."""
    dx, dy = x1 - x0, y1 - y0
    length = math.hypot(dx, dy) or 1.0
    nx, ny = -dy / length, dx / length
    mx, my = (x0 + x1) / 2.0, (y0 + y1) / 2.0
    if (-mx) * nx + (-my) * ny < 0:
        nx, ny = -nx, -ny
    return nx, ny


def _wall_edges(verts, portal_edges, min_len=16.0):
    """Non-portal edges of `verts` long enough to hang a prop on: dicts with
    endpoints, length, tangent, and inward normal, longest first. Portal
    (and pending-door) edges are excluded so static furniture never blocks
    a passage that is -- or will become, once a door unlocks -- open."""
    n = len(verts)
    out = []
    for i in range(n):
        if i in portal_edges:
            continue
        x0, y0 = verts[i]
        x1, y1 = verts[(i + 1) % n]
        dx, dy = x1 - x0, y1 - y0
        length = math.hypot(dx, dy)
        if length < min_len:
            continue
        tx, ty = dx / length, dy / length
        nx, ny = _edge_inward_normal(x0, y0, x1, y1)
        out.append(dict(i=i, p0=(x0, y0), p1=(x1, y1), len=length,
                         tx=tx, ty=ty, nx=nx, ny=ny,
                         mx=(x0 + x1) / 2.0, my=(y0 + y1) / 2.0))
    out.sort(key=lambda e: -e["len"])
    return out


def _place_along_wall(wall, item_w, gap, inset, margin=6.0):
    """Evenly spaced item centers along `wall`, offset `inset` inward from
    the wall line, each `(cx, cy, ang)` with `ang` = the wall's tangent
    angle (so a rect built at that angle sits flush against the wall)."""
    usable = wall["len"] - 2 * margin
    if usable <= item_w:
        return []
    n = max(1, int((usable + gap) // (item_w + gap)))
    span = n * item_w + (n - 1) * gap
    start = (wall["len"] - span) / 2.0
    ang = math.atan2(wall["ty"], wall["tx"])
    out = []
    for k in range(n):
        t = start + item_w / 2.0 + k * (item_w + gap)
        bx = wall["p0"][0] + wall["tx"] * t
        by = wall["p0"][1] + wall["ty"] * t
        out.append((bx + wall["nx"] * inset, by + wall["ny"] * inset, ang))
    return out


def _crate(cx, cy, w, h, ang, rng, fill=PROP_COLOR, rim=PROP_RIM,
           descent=0.0, crng=None):
    pts = _rect_local(cx, cy, w, h, ang)
    prims = [("poly", pts, fill, rim, 1)]
    strap = tuple(max(0, c - 16) for c in rim)
    if rng.random() < 0.85:
        prims.append(("line", pts[0], pts[2], strap, 1))
    if w > 7 and h > 7 and rng.random() < 0.6:
        prims.append(("line", pts[1], pts[3], strap, 1))
    # deep-station corruption: the seed's tendrils creep out from under a
    # crate corner and wander a few units across the floor
    cor = _corruption(descent)
    if cor > 0.0 and crng is not None and crng.random() < 0.10 + 0.35 * cor:
        px_, py_ = crng.choice(pts)
        a = math.atan2(py_ - cy, px_ - cx) + crng.uniform(-0.6, 0.6)
        tpts = [(px_, py_)]
        for _ in range(crng.randint(2, 3)):
            a += crng.uniform(-0.7, 0.7)
            step = crng.uniform(3.0, 6.0)
            px_ += math.cos(a) * step
            py_ += math.sin(a) * step
            tpts.append((px_, py_))
        prims.append(("polyline", tpts, TENDRIL_COLOR, 1, False))
    return prims


def _vent_grate(cx, cy, ang, wall, w=8.0, h=5.0):
    pts = _rect_local(cx, cy, w, h, ang)
    prims = [("poly", pts, PROP_DARK, PROP_RIM, 1)]
    for k in range(1, 4):
        t = -w / 2.0 + k * (w / 4.0)
        lx = cx + wall["tx"] * t
        ly = cy + wall["ty"] * t
        hx = lx + wall["nx"] * (h * 0.4)
        hy = ly + wall["ny"] * (h * 0.4)
        lx2 = lx - wall["nx"] * (h * 0.4)
        ly2 = ly - wall["ny"] * (h * 0.4)
        prims.append(("line", (lx2, ly2), (hx, hy), PROP_RIM, 1))
    return prims


def _props_dock(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Cargo crates in corner stacks, a hazard-striped strip near one wall,
    mooring rings along another."""
    prims = []
    corners = list(verts)
    rng.shuffle(corners)
    for cx0, cy0 in corners[:2]:
        length = math.hypot(cx0, cy0) or 1.0
        ux, uy = -cx0 / length, -cy0 / length
        base = 10.0
        for k in range(rng.randint(3, 5)):
            w = rng.uniform(9, 15)
            h = rng.uniform(9, 15)
            off = base + k * rng.uniform(6, 9)
            jitter = rng.uniform(-4, 4)
            cx = cx0 + ux * off + uy * jitter
            cy = cy0 + uy * off - ux * jitter
            prims.extend(_crate(cx, cy, w, h, rng.uniform(-0.15, 0.15), rng,
                                descent=descent, crng=crng))
    if walls:
        wall = rng.choice(walls)
        strip_w = min(wall["len"] * 0.6, 60.0)
        strip_d = 10.0
        steps = max(4, int(strip_w / 7))
        t0 = (wall["len"] - strip_w) / 2.0
        for k in range(steps):
            t = t0 + k * (strip_w / steps)
            bx = wall["p0"][0] + wall["tx"] * t
            by = wall["p0"][1] + wall["ty"] * t
            ex = bx + wall["nx"] * strip_d
            ey = by + wall["ny"] * strip_d
            color = HAZARD_COLOR if k % 2 == 0 else HAZARD_COLOR_DIM
            prims.append(("line", (bx, by), (ex, ey), color, 2))
        ring_wall = rng.choice(walls)
        for cx, cy, ang in _place_along_wall(ring_wall, 6.0, 22.0, 6.0):
            prims.append(("polyline", _ring_local(cx, cy, 2.4, 10), PROP_RIM, 1, True))
            hx = cx - ring_wall["nx"] * 4.0
            hy = cy - ring_wall["ny"] * 4.0
            prims.append(("line", (cx, cy), (hx, hy), PROP_RIM, 1))
    return prims


def _props_corridor(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Wall-hugging pipe runs with elbow joints, floor lane chevrons, vent
    grates. Shared by "corridor" and "transit"."""
    prims = []
    for wall in walls[:2]:
        inset = 5.0
        margin = 8.0
        if wall["len"] <= 2 * margin:
            continue
        a = (wall["p0"][0] + wall["nx"] * inset + wall["tx"] * margin,
             wall["p0"][1] + wall["ny"] * inset + wall["ty"] * margin)
        b = (wall["p1"][0] + wall["nx"] * inset - wall["tx"] * margin,
             wall["p1"][1] + wall["ny"] * inset - wall["ty"] * margin)
        prims.append(("line", a, b, PIPE_COLOR, 1))
        run = wall["len"] - 2 * margin
        n_joints = max(1, int(run // 26))
        for k in range(1, n_joints + 1):
            t = margin + k * (run / (n_joints + 1))
            jx = wall["p0"][0] + wall["tx"] * t + wall["nx"] * inset
            jy = wall["p0"][1] + wall["ty"] * t + wall["ny"] * inset
            prims.append(("line", (jx, jy),
                          (jx + wall["nx"] * 3.5, jy + wall["ny"] * 3.5), PIPE_COLOR, 1))
        if rng.random() < 0.7:
            spots = _place_along_wall(wall, 8.0, 20.0, 8.0)
            if spots:
                gx, gy, gang = rng.choice(spots)
                prims.extend(_vent_grate(gx, gy, gang, wall))
    axis_dx, axis_dy = x1 - x0, y1 - y0
    horiz = abs(axis_dx) >= abs(axis_dy)
    for frac in (0.28, 0.72):
        if horiz:
            lx, ly = x0 + axis_dx * frac, (y0 + y1) / 2.0
            tip = (lx + 5, ly)
            prims.append(("line", (lx - 5, ly), tip, PROP_DARK, 1))
            prims.append(("line", tip, (lx, ly - 3), PROP_DARK, 1))
            prims.append(("line", tip, (lx, ly + 3), PROP_DARK, 1))
        else:
            lx, ly = (x0 + x1) / 2.0, y0 + axis_dy * frac
            tip = (lx, ly + 5)
            prims.append(("line", (lx, ly - 5), tip, PROP_DARK, 1))
            prims.append(("line", tip, (lx - 3, ly), PROP_DARK, 1))
            prims.append(("line", tip, (lx + 3, ly), PROP_DARK, 1))
    return prims


def _props_storage(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Dense crate rows with a walkable aisle, shelf lines along the walls."""
    prims = []
    w_span, h_span = x1 - x0, y1 - y0
    horiz = w_span >= h_span
    n_rows = rng.randint(2, 3)
    budget = 70
    if horiz:
        rows_y = [y0 + h_span * (0.22 + 0.56 * k / max(1, n_rows - 1)) for k in range(n_rows)]
        aisle_lo, aisle_hi = x0 + w_span * 0.42, x0 + w_span * 0.58
        for ry in rows_y:
            cx_ = x0 + w_span * 0.12
            limit = x1 - w_span * 0.12
            while cx_ < limit and len(prims) < budget:
                w = rng.uniform(10, 16)
                if not (aisle_lo - w < cx_ < aisle_hi + w):
                    prims.extend(_crate(cx_, ry + rng.uniform(-3, 3), w,
                                        rng.uniform(10, 16), rng.uniform(-0.08, 0.08), rng,
                                        descent=descent, crng=crng))
                cx_ += w + rng.uniform(3, 6)
    else:
        cols_x = [x0 + w_span * (0.22 + 0.56 * k / max(1, n_rows - 1)) for k in range(n_rows)]
        aisle_lo, aisle_hi = y0 + h_span * 0.42, y0 + h_span * 0.58
        for rx in cols_x:
            cy_ = y0 + h_span * 0.12
            limit = y1 - h_span * 0.12
            while cy_ < limit and len(prims) < budget:
                h = rng.uniform(10, 16)
                if not (aisle_lo - h < cy_ < aisle_hi + h):
                    prims.extend(_crate(rx + rng.uniform(-3, 3), cy_, rng.uniform(10, 16),
                                        h, rng.uniform(-0.08, 0.08), rng,
                                        descent=descent, crng=crng))
                cy_ += h + rng.uniform(3, 6)
    for wall in walls[:3]:
        inset = 5.0
        a = (wall["p0"][0] + wall["nx"] * inset, wall["p0"][1] + wall["ny"] * inset)
        b = (wall["p1"][0] + wall["nx"] * inset, wall["p1"][1] + wall["ny"] * inset)
        prims.append(("line", a, b, PROP_RIM, 1))
        a2 = (a[0] + wall["nx"] * 3, a[1] + wall["ny"] * 3)
        b2 = (b[0] + wall["nx"] * 3, b[1] + wall["ny"] * 3)
        prims.append(("line", a2, b2, PROP_COLOR, 1))
    return prims


def _props_pump(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """A large tank ring (sometimes two) with an inflow pipe from the
    nearest wall, plus floor puddle stains."""
    prims = []
    w_span, h_span = x1 - x0, y1 - y0
    r = min(w_span, h_span) * 0.28
    ox = (x0 + x1) / 2.0 + rng.uniform(-w_span, w_span) * 0.08
    oy = (y0 + y1) / 2.0 + rng.uniform(-h_span, h_span) * 0.08
    prims.append(("polyline", _ring_local(ox, oy, r, 20), PROP_RIM, 2, True))
    prims.append(("polyline", _ring_local(ox, oy, r * 0.78, 18), PROP_COLOR, 1, True))
    # corruption: growth patches colonize the tank rim near the core
    cor = _corruption(descent)
    if cor > 0.0 and crng is not None:
        for _ in range(1 + int(round(cor * 2))):
            a = crng.uniform(0.0, 2.0 * math.pi)
            gx, gy = ox + math.cos(a) * r, oy + math.sin(a) * r
            rad = crng.uniform(2.5, 4.5 + 2.0 * cor)
            n = crng.randint(5, 7)
            blob = [(gx + math.cos(2 * math.pi * i / n) * rad * crng.uniform(0.6, 1.0),
                     gy + math.sin(2 * math.pi * i / n) * rad * crng.uniform(0.6, 1.0))
                    for i in range(n)]
            prims.append(("stain", blob, GROWTH_FILL))
            prims.append(("polyline", blob, GROWTH_RIM, 1, True))
            if crng.random() < 0.6:
                ta = a + crng.uniform(-0.5, 0.5)
                tpts = [(gx, gy)]
                tx_, ty_ = gx, gy
                for _ in range(crng.randint(2, 3)):
                    ta += crng.uniform(-0.6, 0.6)
                    step = crng.uniform(3.0, 5.5)
                    tx_ += math.cos(ta) * step
                    ty_ += math.sin(ta) * step
                    tpts.append((tx_, ty_))
                prims.append(("polyline", tpts, TENDRIL_COLOR, 1, False))
    if walls:
        wall = min(walls, key=lambda w: (w["mx"] - ox) ** 2 + (w["my"] - oy) ** 2)
        elbow = (wall["mx"] + wall["nx"] * (r * 0.6), wall["my"] + wall["ny"] * (r * 0.6))
        # aim at the rim point facing the wall (+ jitter), not a random
        # point on the ring -- otherwise the pipe can land on the far side
        # and visually skewer straight through the tank
        base_a = math.atan2(wall["my"] - oy, wall["mx"] - ox)
        a = base_a + rng.uniform(-0.3, 0.3)
        target = (ox + math.cos(a) * r, oy + math.sin(a) * r)
        prims.append(("polyline", [(wall["mx"], wall["my"]), elbow, target], PIPE_COLOR, 2, False))
    if rng.random() < 0.5:
        r2 = r * rng.uniform(0.35, 0.5)
        a = rng.uniform(0, 2 * math.pi)
        ox2, oy2 = ox + math.cos(a) * r * 1.6, oy + math.sin(a) * r * 1.6
        if x0 + r2 < ox2 < x1 - r2 and y0 + r2 < oy2 < y1 - r2:
            prims.append(("polyline", _ring_local(ox2, oy2, r2, 14), PROP_RIM, 1, True))
    for _ in range(rng.randint(2, 4)):
        pcx, pcy = rng.uniform(x0 + 6, x1 - 6), rng.uniform(y0 + 6, y1 - 6)
        rad = rng.uniform(5, 11)
        n = rng.randint(6, 8)
        poly = [(pcx + math.cos(2 * math.pi * i / n + rng.uniform(-0.2, 0.2)) * rad * rng.uniform(0.6, 1.0),
                 pcy + math.sin(2 * math.pi * i / n + rng.uniform(-0.2, 0.2)) * rad * rng.uniform(0.6, 1.0))
                for i in range(n)]
        prims.append(("stain", poly, PUDDLE_COLOR))
    return prims


def _props_lab(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Console blocks (bright screens on dark slabs) along the walls, a
    specimen table center-adjacent."""
    prims = []
    for wall in walls[:3]:
        for cx, cy, ang in _place_along_wall(wall, 12.0, 6.0, 5.0):
            prims.append(("poly", _rect_local(cx, cy, 12.0, 7.0, ang), PROP_DARK, PROP_RIM, 1))
            scr_cx, scr_cy = cx + wall["nx"], cy + wall["ny"]
            # deeper decks are dying decks: fewer screens still lit
            bright = rng.random() < (0.8 - 0.45 * descent)
            prims.append(("poly", _rect_local(scr_cx, scr_cy, 6.5, 4.0, ang),
                          SCREEN_COLOR if bright else SCREEN_DIM, None, 0))
            if bright:
                prims.append(("screenglow", scr_cx, scr_cy, 7.0))
    off = rng.uniform(10, 18)
    a0 = rng.uniform(0, 2 * math.pi)
    tcx = (x0 + x1) / 2.0 + math.cos(a0) * off
    tcy = (y0 + y1) / 2.0 + math.sin(a0) * off
    prims.append(("poly", _rect_local(tcx, tcy, 16.0, 9.0, rng.uniform(-0.2, 0.2)),
                  PROP_COLOR, PROP_RIM, 1))
    prims.append(("dot", (tcx, tcy), PROP_DARK, 2))
    return prims


def _props_hydro(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Planter troughs along the walls (long thin trays, green-tinted fill),
    with occasional stalks poking up out of a trough. A center planter row
    stands in for the lab's specimen table -- this polygon grows things."""
    prims = []
    for wall in walls[:3]:
        for cx, cy, ang in _place_along_wall(wall, 20.0, 6.0, 5.0):
            prims.append(("poly", _rect_local(cx, cy, 20.0, 6.5, ang), HYDRO_TRAY, HYDRO_RIM, 1))
            if rng.random() < 0.6:
                n_stalks = rng.randint(2, 4)
                for s in range(n_stalks):
                    t = (s + 0.5) / n_stalks - 0.5
                    sx = cx + wall["tx"] * t * 16.0
                    sy = cy + wall["ty"] * t * 16.0
                    prims.append(("dot", (sx, sy), HYDRO_STALK, rng.uniform(1.2, 2.2)))
    off = rng.uniform(10, 18)
    a0 = rng.uniform(0, 2 * math.pi)
    tcx = (x0 + x1) / 2.0 + math.cos(a0) * off
    tcy = (y0 + y1) / 2.0 + math.sin(a0) * off
    trough_ang = rng.uniform(-0.2, 0.2)
    prims.append(("poly", _rect_local(tcx, tcy, 22.0, 8.0, trough_ang),
                  HYDRO_TRAY, HYDRO_RIM, 1))
    tx_ = math.cos(trough_ang)
    ty_ = math.sin(trough_ang)
    for s in range(rng.randint(3, 5)):
        t = rng.uniform(-9.0, 9.0)
        prims.append(("dot", (tcx + tx_ * t, tcy + ty_ * t), HYDRO_STALK,
                      rng.uniform(1.4, 2.6)))
    return prims


def _props_quarters(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Cot bays along the walls, each with a pillow and a footlocker.
    Near the core the bays are shoved askew — nobody squared them away."""
    prims = []
    cor = _corruption(descent)
    for wall in walls[:3]:
        for cx, cy, ang in _place_along_wall(wall, 16.0, 8.0, 7.0):
            if cor > 0.0 and crng is not None:
                ang = ang + crng.uniform(-0.4, 0.4) * cor
                cx += crng.uniform(-2.5, 2.5) * cor
                cy += crng.uniform(-2.5, 2.5) * cor
            prims.append(("poly", _rect_local(cx, cy, 16.0, 8.0, ang), PROP_COLOR, PROP_RIM, 1))
            pcx, pcy = cx + wall["tx"] * 5.5, cy + wall["ty"] * 5.5
            prims.append(("poly", _rect_local(pcx, pcy, 4.0, 5.5, ang), PROP_RIM, None, 0))
            lcx = cx - wall["tx"] * 9.5 + wall["nx"] * 1.0
            lcy = cy - wall["ty"] * 9.5 + wall["ny"] * 1.0
            prims.append(("poly", _rect_local(lcx, lcy, 5.0, 4.0, ang), PROP_DARK, PROP_RIM, 1))
    return prims


def _props_chapel(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Pew rows facing one wall (the "front"), a dais arc against it.
    Near the core the rows go askew — knocked, dragged, never restored."""
    prims = []
    if not walls:
        return prims
    front = walls[0]
    pew_half = front["len"] * 0.32
    cor = _corruption(descent)
    for k in range(rng.randint(4, 6)):
        d = 14.0 + k * 9.0
        cx = front["mx"] + front["nx"] * d
        cy = front["my"] + front["ny"] * d
        tx_, ty_ = front["tx"], front["ty"]
        if cor > 0.0 and crng is not None:
            skew = crng.uniform(-0.5, 0.5) * cor
            ca, sa = math.cos(skew), math.sin(skew)
            tx_, ty_ = tx_ * ca - ty_ * sa, tx_ * sa + ty_ * ca
            slide = crng.uniform(-4.0, 4.0) * cor
            cx += front["tx"] * slide
            cy += front["ty"] * slide
        a = (cx - tx_ * pew_half, cy - ty_ * pew_half)
        b = (cx + tx_ * pew_half, cy + ty_ * pew_half)
        prims.append(("line", a, b, PROP_COLOR, 1))
    dcx, dcy = front["mx"] + front["nx"] * 6.0, front["my"] + front["ny"] * 6.0
    prims.append(("polyline",
                  _basis_arc_local(dcx, dcy, pew_half * 0.75, front["tx"], front["ty"],
                                   front["nx"], front["ny"], -1.0, 1.0, 10),
                  PROP_RIM, 1, False))
    return prims


def _props_records(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Shelf stacks: long parallel double-lines filling the polygon in rows."""
    prims = []
    w_span, h_span = x1 - x0, y1 - y0
    horiz = w_span >= h_span
    n_rows = rng.randint(3, 5)
    for k in range(n_rows):
        frac = 0.14 + 0.72 * k / max(1, n_rows - 1)
        if horiz:
            ry = y0 + h_span * frac
            a1, b1 = (x0 + w_span * 0.08, ry), (x1 - w_span * 0.08, ry)
            a2, b2 = (a1[0], ry + 2.4), (b1[0], ry + 2.4)
        else:
            rx = x0 + w_span * frac
            a1, b1 = (rx, y0 + h_span * 0.08), (rx, y1 - h_span * 0.08)
            a2, b2 = (rx + 2.4, a1[1]), (rx + 2.4, b1[1])
        prims.append(("line", a1, b1, PROP_RIM, 1))
        prims.append(("line", a2, b2, PROP_COLOR, 1))
    return prims


def _props_medbay(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Cots with curtain arcs, a cross-marked cabinet."""
    prims = []
    cabinet_done = False
    for wall in walls[:2]:
        for cx, cy, ang in _place_along_wall(wall, 15.0, 10.0, 7.5)[:2]:
            prims.append(("poly", _rect_local(cx, cy, 15.0, 7.5, ang), PROP_COLOR, PROP_RIM, 1))
            prims.append(("polyline",
                          _basis_arc_local(cx, cy, 11.0, wall["tx"], wall["ty"],
                                           wall["nx"], wall["ny"]),
                          PROP_DARK, 1, False))
        if not cabinet_done and wall["len"] > 30:
            cbx = wall["mx"] + wall["nx"] * 6.0 - wall["tx"] * (wall["len"] * 0.32)
            cby = wall["my"] + wall["ny"] * 6.0 - wall["ty"] * (wall["len"] * 0.32)
            cab_ang = math.atan2(wall["ty"], wall["tx"])
            prims.append(("poly", _rect_local(cbx, cby, 7.0, 6.0, cab_ang), PROP_DARK, PROP_RIM, 1))
            prims.append(("line", (cbx - 2.2, cby), (cbx + 2.2, cby), (200, 90, 90), 1))
            prims.append(("line", (cbx, cby - 2.2), (cbx, cby + 2.2), (200, 90, 90), 1))
            cabinet_done = True
    return prims


def _props_core(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Concentric ring inlays, radial conduit spokes, an amber warning ring."""
    prims = []
    r_max = min(x1 - x0, y1 - y0) * 0.42
    n_rings = rng.randint(2, 3)
    for k in range(n_rings):
        r = r_max * (0.35 + 0.6 * k / max(1, n_rings - 1))
        prims.append(("polyline", _ring_local(0.0, 0.0, r, 20), PROP_RIM, 1, True))
    inner = r_max * 0.3
    n_spokes = rng.randint(6, 10)
    for i in range(n_spokes):
        a = 2 * math.pi * i / n_spokes + rng.uniform(-0.05, 0.05)
        p0 = (math.cos(a) * inner, math.sin(a) * inner)
        p1 = (math.cos(a) * r_max * 0.95, math.sin(a) * r_max * 0.95)
        prims.append(("line", p0, p1, PROP_COLOR, 1))
    wr = r_max * 1.05
    prims.append(("polyline", _ring_local(0.0, 0.0, wr, 24), HAZARD_COLOR, 1, True))
    for i in range(0, 24, 2):
        a = 2 * math.pi * i / 24
        ix, iy = math.cos(a) * (wr - 2.5), math.sin(a) * (wr - 2.5)
        ox, oy = math.cos(a) * (wr + 2.5), math.sin(a) * (wr + 2.5)
        prims.append(("line", (ix, iy), (ox, oy), HAZARD_COLOR_DIM, 1))
    return prims


def _props_generic(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """Untagged polygon: subtle plates/rivets + grime, toned down from the old
    always-on abstract-lines-and-dots generator."""
    prims = []
    for _ in range(rng.randint(2, 5)):
        if rng.random() < 0.5:
            yy = rng.uniform(y0, y1)
            prims.append(("line", (rng.uniform(x0, x1), yy), (rng.uniform(x0, x1), yy)))
        else:
            xx = rng.uniform(x0, x1)
            prims.append(("line", (xx, rng.uniform(y0, y1)), (xx, rng.uniform(y0, y1))))
    for _ in range(rng.randint(4, 9)):
        prims.append(("dot", (rng.uniform(x0, x1), rng.uniform(y0, y1))))
    for _ in range(rng.randint(1, 2)):
        cx, cy = rng.uniform(x0, x1), rng.uniform(y0, y1)
        rad = rng.uniform(5, 13)
        n = rng.randint(6, 9)
        poly = [(cx + math.cos(2 * math.pi * i / n + rng.uniform(-0.2, 0.2)) * rad * rng.uniform(0.6, 1.0),
                 cy + math.sin(2 * math.pi * i / n + rng.uniform(-0.2, 0.2)) * rad * rng.uniform(0.6, 1.0))
                for i in range(n)]
        prims.append(("stain", poly))
    for wall in walls[:4]:
        inset, margin = 4.0, 6.0
        if wall["len"] <= 2 * margin + 4:
            continue
        a = (wall["p0"][0] + wall["nx"] * inset + wall["tx"] * margin,
             wall["p0"][1] + wall["ny"] * inset + wall["ty"] * margin)
        b = (wall["p1"][0] + wall["nx"] * inset - wall["tx"] * margin,
             wall["p1"][1] + wall["ny"] * inset - wall["ty"] * margin)
        prims.append(("line", a, b))
        if rng.random() < 0.7:
            prims.append(("dot", a))
            prims.append(("dot", b))
    return prims


def _descent_dressing(crng, descent, walls, x0, y0, x1, y1):
    """Kind-independent descent dressing layered over every polygon's props:
    grime density rising with depth, Congregation crosses scratched near
    the walls from the middle decks down, and — past the corruption
    threshold — the seed's growth crawling in from the polygon's edges. All
    colors sit between floor and prop range so none of it ever competes
    with a live threat for the eye."""
    prims = []
    if descent <= 0.05:
        return prims
    g = descent
    grime = _mix(_GRIME_COLD, _GRIME_DEEP, g)
    for _ in range(int(round(g * 3))):
        cx = crng.uniform(x0 + 8, x1 - 8)
        cy = crng.uniform(y0 + 8, y1 - 8)
        rad = crng.uniform(4.0, 9.0 + 6.0 * g)
        n = crng.randint(6, 8)
        blob = [(cx + math.cos(2 * math.pi * i / n + crng.uniform(-0.2, 0.2))
                 * rad * crng.uniform(0.6, 1.0),
                 cy + math.sin(2 * math.pi * i / n + crng.uniform(-0.2, 0.2))
                 * rad * crng.uniform(0.6, 1.0)) for i in range(n)]
        prims.append(("stain", blob, grime))
    for _ in range(int(round(g * 5))):
        prims.append(("dot", (crng.uniform(x0 + 4, x1 - 4),
                              crng.uniform(y0 + 4, y1 - 4)), grime, 1))
    # streaks bleeding in from the walls
    for wall in walls[:3]:
        if wall["len"] > 24 and crng.random() < 0.25 + 0.5 * g:
            t = crng.uniform(8.0, wall["len"] - 8.0)
            bx = wall["p0"][0] + wall["tx"] * t
            by = wall["p0"][1] + wall["ty"] * t
            run = crng.uniform(4.0, 8.0 + 10.0 * g)
            prims.append(("line", (bx, by),
                          (bx + wall["nx"] * run, by + wall["ny"] * run),
                          grime, 1))
    # Congregation iconography, intensifying with depth: small crosses
    # scratched into the deck near the walls — the faithful went down,
    # and kept writing
    if g > 0.3 and walls:
        mark = _mix(_MARK_COLD, _MARK_DEEP, g)
        n_marks = 1 + (1 if crng.random() < (g - 0.3) else 0)
        for _ in range(n_marks):
            wall = crng.choice(walls)
            if wall["len"] < 30:
                continue
            t = crng.uniform(10.0, wall["len"] - 10.0)
            s = crng.uniform(2.2, 3.4)
            cx = wall["p0"][0] + wall["tx"] * t + wall["nx"] * crng.uniform(4.0, 8.0)
            cy = wall["p0"][1] + wall["ty"] * t + wall["ny"] * crng.uniform(4.0, 8.0)
            nx, ny, tx, ty = wall["nx"], wall["ny"], wall["tx"], wall["ty"]
            prims.append(("line", (cx - nx * s * 1.2, cy - ny * s * 1.2),
                          (cx + nx * s * 1.8, cy + ny * s * 1.8), mark, 1))
            bx, by = cx + nx * s * 0.9, cy + ny * s * 0.9
            prims.append(("line", (bx - tx * s, by - ty * s),
                          (bx + tx * s, by + ty * s), mark, 1))
    # the seed's spread: growth patches anchored to the polygon's edges
    cor = _corruption(descent)
    if cor > 0.0 and walls:
        for _ in range(1 + int(round(cor * 2))):
            wall = crng.choice(walls)
            if wall["len"] < 20:
                continue
            t = crng.uniform(6.0, wall["len"] - 6.0)
            gx = wall["p0"][0] + wall["tx"] * t + wall["nx"] * crng.uniform(2.0, 5.0)
            gy = wall["p0"][1] + wall["ty"] * t + wall["ny"] * crng.uniform(2.0, 5.0)
            rad = crng.uniform(3.0, 6.0 + 3.0 * cor)
            n = crng.randint(5, 7)
            blob = [(gx + math.cos(2 * math.pi * i / n) * rad * crng.uniform(0.55, 1.0),
                     gy + math.sin(2 * math.pi * i / n) * rad * crng.uniform(0.55, 1.0))
                    for i in range(n)]
            prims.append(("stain", blob, GROWTH_FILL))
            prims.append(("polyline", blob, GROWTH_RIM, 1, True))
            for _ in range(crng.randint(1, 2)):
                a = math.atan2(wall["ny"], wall["nx"]) + crng.uniform(-0.9, 0.9)
                tpts = [(gx, gy)]
                tx_, ty_ = gx, gy
                for _ in range(crng.randint(2, 4)):
                    a += crng.uniform(-0.6, 0.6)
                    step = crng.uniform(3.5, 6.5)
                    tx_ += math.cos(a) * step
                    ty_ += math.sin(a) * step
                    tpts.append((tx_, ty_))
                prims.append(("polyline", tpts, TENDRIL_COLOR, 1, False))
    return prims


def _warm_prims(prims, descent):
    """Bake the descent temperature drift into a cached prim list: every
    structural color drifts cold->warm by _warm(); geometry is untouched.
    Runs once per polygon at cache time, so per-frame cost is zero."""
    if descent <= 0.0:
        return prims
    out = []
    for prim in prims:
        kind = prim[0]
        if kind == "line" and len(prim) > 3 and prim[3] is not None:
            out.append((prim[0], prim[1], prim[2], _warm(prim[3], descent))
                       + tuple(prim[4:]))
        elif kind == "dot" and len(prim) > 2 and prim[2] is not None:
            out.append((prim[0], prim[1], _warm(prim[2], descent))
                       + tuple(prim[3:]))
        elif kind == "stain" and len(prim) > 2 and prim[2] is not None:
            out.append((prim[0], prim[1], _warm(prim[2], descent)))
        elif kind == "poly":
            _, pts_local, fill, outline, ow = prim
            out.append(("poly", pts_local,
                        _warm(fill, descent) if fill is not None else None,
                        _warm(outline, descent) if outline is not None else None,
                        ow))
        elif kind == "polyline":
            _, pts_local, color, width, closed = prim
            out.append(("polyline", pts_local, _warm(color, descent),
                        width, closed))
        else:
            out.append(prim)
    return out



def _props_marrow(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """The corrupted Testator cathedral: a consecrated machine seized to
    manufacture war. Machined ribs at unequal spacing, fold notation that
    never closes into a ring, bone-tone memorial inserts, and conduits
    carrying light inward — with the Adversary's growth laid OVER that
    work rather than replacing it, thickening as the chamber descends.
    Nothing here repeats a module: each chamber's seed is its maker's
    idiom."""
    prims = []
    cx, cy = (x0 + x1) / 2.0, (y0 + y1) / 2.0
    w, h = x1 - x0, y1 - y0
    corrupt = _corruption(descent)

    # RIBS: machined wall stiffeners at deliberately unequal spacing.
    # (Even spacing reads industrial-modular; the unevenness is the
    # handcraft law.)
    for wall in walls:
        if wall["len"] < 46:
            continue
        t = wall["len"] * rng.uniform(0.12, 0.24)
        while t < wall["len"] - 12.0:
            bx = wall["p0"][0] + wall["tx"] * t
            by = wall["p0"][1] + wall["ty"] * t
            depth_in = rng.uniform(5.0, 11.0)
            nx, ny = -wall["ty"], wall["tx"]
            if (cx - bx) * nx + (cy - by) * ny < 0:
                nx, ny = -nx, -ny
            half = rng.uniform(2.0, 3.5)
            rib = [(bx - wall["tx"] * half, by - wall["ty"] * half),
                   (bx + wall["tx"] * half, by + wall["ty"] * half),
                   (bx + wall["tx"] * half + nx * depth_in,
                    by + wall["ty"] * half + ny * depth_in),
                   (bx - wall["tx"] * half + nx * depth_in,
                    by - wall["ty"] * half + ny * depth_in)]
            prims.append(("poly", rib, (78, 70, 54), (128, 116, 88), 1))
            t += rng.uniform(26.0, 54.0)

    # FOLD NOTATION: nested rotated polygon fragments — the Testators'
    # own record of a space that folds. Open arcs only; a closed ring is
    # the aggro symbol and belongs to nothing else.
    for i in range(rng.randint(1, 3)):
        n = rng.randint(5, 7)
        rad = min(w, h) * rng.uniform(0.14, 0.26)
        ox = cx + rng.uniform(-w * 0.22, w * 0.22)
        oy = cy + rng.uniform(-h * 0.22, h * 0.22)
        ang0 = rng.uniform(0, 2 * math.pi)
        gap = rng.randint(1, 2)
        pts = [(ox + math.cos(ang0 + 2 * math.pi * j / n) * rad,
                oy + math.sin(ang0 + 2 * math.pi * j / n) * rad)
               for j in range(n - gap)]
        if len(pts) >= 2:
            prims.append(("polyline", pts, (150, 142, 116), 1, False))

    # MEMORIAL INSERTS: pale bone slabs set into the floor, inscribed.
    for _ in range(rng.randint(1, 3)):
        px = cx + rng.uniform(-w * 0.3, w * 0.3)
        py = cy + rng.uniform(-h * 0.3, h * 0.3)
        sw, sh = rng.uniform(6.0, 11.0), rng.uniform(9.0, 15.0)
        a = rng.uniform(0, math.pi)
        ca, sa = math.cos(a), math.sin(a)
        slab = [(px + ca * dx - sa * dy, py + sa * dx + ca * dy)
                for dx, dy in ((-sw, -sh), (sw, -sh), (sw, sh), (-sw, sh))]
        prims.append(("poly", slab, (96, 92, 78), (184, 178, 151), 1))

    # CONDUITS: light-carrying runs pointing inward — the arrival
    # language (deeper is that way).
    for wall in walls[:2]:
        if wall["len"] < 40:
            continue
        t = wall["len"] * rng.uniform(0.3, 0.7)
        bx = wall["p0"][0] + wall["tx"] * t
        by = wall["p0"][1] + wall["ty"] * t
        dx, dy = cx - bx, cy - by
        dl = math.hypot(dx, dy) or 1.0
        run = min(dl * rng.uniform(0.35, 0.6), 70.0)
        prims.append(("line", (bx, by),
                      (bx + dx / dl * run, by + dy / dl * run),
                      (120, 132, 112), 2))

    # THE GROWTH: past the corruption threshold the Adversary's own work
    # crawls along the conduits it found, then departs from them.
    if corrupt > 0.0 and crng is not None:
        for _ in range(int(round(corrupt * 5))):
            bx = cx + crng.uniform(-w * 0.42, w * 0.42)
            by = cy + crng.uniform(-h * 0.42, h * 0.42)
            pts = [(bx, by)]
            ang = crng.uniform(0, 2 * math.pi)
            for _s in range(crng.randint(2, 4)):
                ang += crng.uniform(-0.9, 0.9)
                step = crng.uniform(6.0, 14.0)
                pts.append((pts[-1][0] + math.cos(ang) * step,
                            pts[-1][1] + math.sin(ang) * step))
            prims.append(("polyline", pts, (86, 116, 104), 1, False))
    return prims


def _props_otherworld(rng, verts, walls, x0, y0, x1, y1, descent=0.0, crng=None):
    """The Otherworld: the prop vocabulary with its grammar broken. Familiar
    objects in impossible syntax — a terminal slab floating mid-polygon facing
    nothing, seats at half scale in a perfect ring, hairline afterimages of
    the polygon's own outline. Placement rules everywhere else are law; here
    their violation IS the read."""
    prims = []
    cx = (x0 + x1) / 2.0
    cy = (y0 + y1) / 2.0
    w = x1 - x0
    h = y1 - y0
    # DESCENT drives this generator (marrow visual pass): shallow
    # otherworld keeps its furniture and shows one faint echo; deep
    # otherworld is nearly empty, and the echoes of what the chamber used
    # to be dominate. A generator that ignores its descent parameter
    # produces no progression, which is exactly the defect the pass was
    # called to fix.
    dsc = max(0.0, min(1.0, descent))
    keep = 1.0 - 0.65 * dsc          # how much furniture survives
    # afterimages: the polygon's own outline, shrunk and re-shrunk. Soft polygons
    # deform after caching, so these echo what the polygon USED to be.
    for shrink in ((0.82, 0.62) if dsc > 0.5 else (0.82,)):
        ring = [(cx + (vx - cx) * shrink, cy + (vy - cy) * shrink)
                for vx, vy in verts]
        prims.append(("polyline", ring, (52, 66, 58), 1, True))
    # a floating console slab, mid-polygon, facing a direction that means
    # nothing, screen glowing at nobody.
    if rng.random() < 0.8 * keep and min(w, h) > 60:
        ang = rng.uniform(0, 2 * math.pi)
        sw, sh = 14.0, 9.0
        ca, sa = math.cos(ang), math.sin(ang)
        px, py = cx + rng.uniform(-w * 0.18, w * 0.18), cy + rng.uniform(-h * 0.18, h * 0.18)
        slab = [(px + ca * -sw - sa * -sh, py + sa * -sw + ca * -sh),
                (px + ca * sw - sa * -sh, py + sa * sw + ca * -sh),
                (px + ca * sw - sa * sh, py + sa * sw + ca * sh),
                (px + ca * -sw - sa * sh, py + sa * -sw + ca * sh)]
        prims.append(("poly", slab, (30, 34, 38), (72, 82, 86), 1))
        prims.append(("screenglow", px + ca * 3, py + sa * 3, 7.0))
    # half-scale seats set out for nobody. They were an EVENLY SPACED
    # PERFECT RING, which is both the repetition the handcraft law
    # forbids and a closed circle, which is the aggro symbol and means
    # nothing else. Now: an incomplete golden-angle sequence, each seat
    # its own size and distance, thinning as the chamber descends.
    if rng.random() < 0.6 and min(w, h) > 90:
        n = max(2, int(round(rng.randint(5, 8) * keep)))
        base_rad = min(w, h) * 0.22
        for i in range(n):
            a = 2.39996 * i + rng.uniform(-0.12, 0.12)
            rad = base_rad * rng.uniform(0.72, 1.18)
            bx, by = cx + math.cos(a) * rad, cy + math.sin(a) * rad
            ca2, sa2 = math.cos(a), math.sin(a)
            seat = [(bx + ca2 * -4 - sa2 * -2.5, by + sa2 * -4 + ca2 * -2.5),
                    (bx + ca2 * 4 - sa2 * -2.5, by + sa2 * 4 + ca2 * -2.5),
                    (bx + ca2 * 4 - sa2 * 2.5, by + sa2 * 4 + ca2 * 2.5),
                    (bx + ca2 * -4 - sa2 * 2.5, by + sa2 * -4 + ca2 * 2.5)]
            prims.append(("poly", seat, (36, 40, 42), None, 0))
    # things half-into walls: a crate silhouette centered ON a wall vertex.
    if walls and rng.random() < 0.7 * keep:
        wd = rng.choice(walls)
        (ax_, ay_), (bx_, by_) = wd["p0"], wd["p1"]
        t = rng.random()
        bx = ax_ + (bx_ - ax_) * t
        by = ay_ + (by_ - ay_) * t
        r = rng.uniform(6, 10)
        prims.append(("poly", [(bx - r, by - r), (bx + r, by - r),
                               (bx + r, by + r), (bx - r, by + r)],
                      (32, 36, 40), (60, 66, 70), 1))
    # self-luminous floor speckle (the floor is starting to be sky), and
    # the deeper the chamber the more of the floor is sky
    for _ in range(rng.randint(3, 7) + int(round(dsc * 9))):
        prims.append(("dot", (rng.uniform(x0, x1), rng.uniform(y0, y1))))
    return prims


_POLYGON_PROP_GENERATORS = {
    "dock": _props_dock,
    "corridor": _props_corridor,
    "transit": _props_corridor,
    "storage": _props_storage,
    "pump": _props_pump,
    "lab": _props_lab,
    "hydro": _props_hydro,
    "quarters": _props_quarters,
    "chapel": _props_chapel,
    "records": _props_records,
    "medbay": _props_medbay,
    "core": _props_core,
    "generic": _props_generic,
    "otherworld": _props_otherworld,
    "marrow": _props_marrow,
}


class Renderer:
    """`Renderer(session).draw(surf, debug=False)` paints one frame and
    returns it as a (W, H, 3) uint8 numpy array (pygame surfarray axis order).

    `surf` supplies only the frame size (a pygame.Surface, a numpy frame, or a
    (w, h) tuple -- see `_size_of`); render.py never writes into it and imports
    no pygame. Immediate-mode: nothing is
    retained across frames except the effect pools and the per-polygon detail
    cache (both intentionally persistent — grime is stable per polygon, decals
    live in `session.decals`).
    """

    def __init__(self, session, max_depth: int = 22, max_instances: int = 320):
        self.session = session
        self.max_depth = max_depth
        self.max_instances = max_instances

        # state (raster/framebuffer sized lazily to the draw
        # surface: tests render at 480x270, the game at 640x360)
        self._raster = None
        self._framebuf: "bytearray | None" = None
        # (W, H, 3) uint8 view onto _framebuf's RGB (surfarray axis order);
        # every composite step writes here, draw() returns a copy.
        self._rgb: "np.ndarray | None" = None
        # a second Raster (+ buffer/view) used purely to rasterize light-wedge
        # and otherworld coverage masks with pixel-exact pygame parity.
        self._blob_cache: dict[int, tuple] = {}

        # -- bespoke per-polygon floor textures (ARTSTYLE_DIRECTION.md lever
        # one) -----------------------------------------------------------
        # Optional hook set by streaming code (WorldStreamer): callable
        # polygon:int -> (level_id, local_polygon_index) | None. None (default)
        # falls back to (session.level.level_id, polygon) -- correct for any
        # non-streamed, single-level session.
        self.polygon_texture_lookup = None
        # engine polygon idx -> (rgb uint8 array (h,w,3), bbox_min_x, bbox_min_y)
        # or None (no texture file for this polygon). Cached forever.
        self._polygon_texture: dict[int, tuple | None] = {}
        # rust backend: texture ids already uploaded to the CURRENT Raster
        # instance (cleared whenever _ensure_raster rebuilds the Raster).
        self._uploaded_tex_ids: set[int] = set()

        self._floor_color_cache: dict[int, tuple] = {}
        self._wall_color_cache: dict[int, tuple] = {}
        # (W, H, 3) inverted cold otherworld field; (W, H, 3) per-frame
        # lightmap; both numpy, allocated lazily at frame size.
        self._lightmap: "np.ndarray | None" = None
        self._out_rgb: "np.ndarray | None" = None
        self._out_buf: "bytearray | None" = None
        self._detail_cache: dict[int, list] = {}
        self._pal_cache: dict[int, tuple] = {}
        self._portal_edges: "dict[int, set[int]] | None" = None

        self._gibs: list[dict] = []
        self._corpsefalls: list[dict] = []
        self._attacker_flash: dict[int, int] = {}
        self._sparks: list[dict] = []
        self._bolts: list[dict] = []
        self._screams: list[dict] = []
        self._floaters: list[dict] = []   # pickup text that rises + fades
        self._hitflash: dict[int, int] = {}
        # demo tooling: see the spectate block in draw()
        self.spectate_eid: int | None = None
        # the arrival tint: a returned Adversary's own body flares. Gate
        # 62 proved a coloured LIGHT cannot carry this meaning -- the
        # lighting multiply takes the room's albedo, so the same flare
        # filmed warm-white in pink chambers and green only where the
        # floor happened to cooperate. A symbol whose colour depends on
        # the room is not a symbol. Same lesson _attacker_flash already
        # learned against the breach-magenta wash.
        self._arrival_flash: dict[int, int] = {}
        self._hurt_ticks = 0
        self._death_fade = 0
        self._dying = False

        self._bake_glows()
        self._deferred_bolts: list = []
        self._deferred_screen_glows: list = []
        # bolt glow discs that feed the lightmap (the bright bolt CORE draws
        # straight onto the entity layer in _draw_effects, so it survives the
        # darkness multiply unattenuated, same as every entity sprite).
        self._deferred_bolt_glows: list = []
        self._deferred_floaters: list = []

    # ------------------------------------------------------------------
    # one-time buffer baking (numpy sprites, row=y col=x)
    # ------------------------------------------------------------------

    @staticmethod
    def _radial_sprite(r, rgb):
        """(d, d, 3) uint8 glow disc, radius `r`, premultiplied `a*a` falloff
        (additive blits don't attenuate by alpha, so the falloff lives in the
        RGB). Row=y, col=x, matching the old pygame set_at((x, y)) order."""
        d = r * 2 + 4
        yy, xx = np.mgrid[0:d, 0:d].astype(np.float32)
        c = d / 2.0
        dist = np.hypot(xx - c, yy - c)
        a = np.where(dist <= r, np.clip(1.0 - dist / r, 0.0, 1.0), 0.0)
        aa = a * a
        img = np.empty((d, d, 3), dtype=np.uint8)
        for ch, base in enumerate(rgb):
            img[..., ch] = (base * aa).astype(np.uint8)  # int() truncation
        return img

    def _bake_glows(self):
        sizes = [8, 16, 26, 40, 60, 90]
        self._glow_sizes = sizes
        self._glow_cache = {r: self._radial_sprite(r, (235, 212, 164))
                            for r in sizes}
        # A second, smaller, green-phosphor-tinted glow for lit instruments
        # (lab consoles, wall terminals) -- a separate palette from the warm
        # muzzle/lightning glow above so a screen reads as its own light
        # source, not a gunshot afterimage.
        screen_sizes = [6, 10, 16]
        self._screen_glow_sizes = screen_sizes
        self._screen_glow_cache = {r: self._radial_sprite(r, (70, 200, 150))
                                   for r in screen_sizes}

    # ------------------------------------------------------------------
    # fx ingestion (call once per sim tick, after session.tick())
    # ------------------------------------------------------------------

    def consume_fx(self, fx_list) -> None:
        for g in self._gibs:
            g["x"] += g["vx"] * DT
            g["y"] += g["vy"] * DT
            g["vx"] *= GIB_FRICTION
            g["vy"] *= GIB_FRICTION
            g["life"] -= 1
        self._gibs = [g for g in self._gibs if g["life"] > 0][-400:]

        for cf in self._corpsefalls:
            cf["age"] += 1
        self._corpsefalls = [cf for cf in self._corpsefalls
                             if cf["age"] < cf["maxage"]][-40:]

        for sp in self._sparks:
            sp["life"] -= 1
        self._sparks = [sp for sp in self._sparks if sp["life"] > 0][-200:]


        for b in self._bolts:
            b["life"] -= 1
        self._bolts = [b for b in self._bolts if b["life"] > 0][-30:]

        for sc in self._screams:
            sc["age"] += 1
        self._screams = [sc for sc in self._screams if sc["age"] < sc["maxage"]][-20:]

        for fl in self._floaters:
            fl["age"] += 1
        self._floaters = [fl for fl in self._floaters
                          if fl["age"] < fl["maxage"]][-12:]

        for eid in list(self._hitflash):
            self._hitflash[eid] -= 1
            if self._hitflash[eid] <= 0:
                del self._hitflash[eid]

        for eid in list(self._attacker_flash):
            self._attacker_flash[eid] -= 1
            if self._attacker_flash[eid] <= 0:
                del self._attacker_flash[eid]

        for eid in list(self._arrival_flash):
            self._arrival_flash[eid] -= 1
            if self._arrival_flash[eid] <= 0:
                del self._arrival_flash[eid]

        if self._hurt_ticks > 0:
            self._hurt_ticks -= 1

        for fx in fx_list:
            tag = fx[0]
            if tag == "gib":
                _, polygon, x, y, n, (dx, dy), *rest = fx
                # chunks are pieces of the body that died: the dying kind's
                # own palette, darkened toward blood, never a generic red
                gkind = rest[0] if rest else None
                base = ENEMY_COLOR.get(gkind)
                gcol = (tuple(int(c * 0.7) for c in base) if base
                        else GIB_COLOR)
                base_ang = math.atan2(dy, dx) if (dx or dy) else 0.0
                for _ in range(max(0, int(n))):
                    ang = base_ang + random.uniform(-1.1, 1.1)
                    spd = random.uniform(40.0, 220.0)
                    self._gibs.append(dict(
                        polygon=polygon, x=x, y=y, col=gcol,
                        vx=math.cos(ang) * spd, vy=math.sin(ang) * spd,
                        life=random.randint(18, 34), size=random.uniform(1.5, 3.5),
                    ))
            elif tag == "corpsefall":
                # the death animation: the silhouette itself collapses into
                # the corpse pose over ~a quarter second — same shape, same
                # spot, same final squash/brightness as the persistent
                # corpse decal, so the last frame lands seamlessly on it
                _, polygon, x, y, ekind, rad, cang = fx
                self._corpsefalls.append(dict(
                    polygon=polygon, x=x, y=y, kind=ekind, rad=rad,
                    ang=cang, age=0, maxage=14))
            elif tag == "spark":
                _, polygon, x, y, nx, ny = fx
                self._sparks.append(dict(polygon=polygon, x=x, y=y, nx=nx, ny=ny, life=4))
            # ("flash"/"holemark"/"holeopen" no longer exist: muzzle
            # flashes, discharges and breaches are REAL lights in the sim
            # (muzzle_light / pulse_light) so they cross portals through
            # occlusion wedges — the per-room glow discs these tags fed
            # ended in a hard bright edge at the first portal, the seam
            # the director reported on every shot, 2026-07-22)
            elif tag == "alerted":
                _, polygon, x, y = fx
                self._screams.append(dict(polygon=polygon, x=x, y=y, age=0, maxage=10))
            elif tag == "attacker_mark":
                # the shared incoming-hit language: whatever just hurt
                # the player flashes ITS BODY red for a quarter second —
                # attribution lives on the attacker, never as rings
                # (rings mean 'gained aggro' and nothing else; run 23's
                # magenta-wash invisibility is answered by a blinking
                # red tint, not by spending the aggro vocabulary)
                _, eid = fx
                self._attacker_flash[eid] = 16
            elif tag == "lightning":
                _, polygon, x, y, radius = fx
                segs = []
                for _ in range(random.randint(4, 8)):
                    a = random.uniform(0.0, 2.0 * math.pi)
                    r = radius * random.uniform(0.6, 1.0)
                    mid = (math.cos(a) * r * 0.5 + random.uniform(-6, 6),
                           math.sin(a) * r * 0.5 + random.uniform(-6, 6))
                    end = (math.cos(a) * r, math.sin(a) * r)
                    segs.append([(0.0, 0.0), mid, end])
                self._bolts.append(dict(polygon=polygon, x=x, y=y, radius=radius, life=6, segs=segs))
            elif tag == "marked":
                # marker contact: the glob IS the tell (drawn on the body
                # every frame while the brand holds); here just the hurt
                # blink — NO rings, rings mean aggro
                self._hurt_ticks = 2
            elif tag == "marker_fire":
                _, polygon, x, y, nx, ny = fx
                self._sparks.append(dict(polygon=polygon, x=x, y=y,
                                         nx=nx, ny=ny, life=4))
            elif tag == "scream":
                # a shrieker SCREAMING: its own bone-pale palette, so the
                # wave reads as coming from that body — plain white rings
                # stay reserved for 'gained aggro' ("alerted")
                _, polygon, x, y = fx
                self._screams.append(dict(polygon=polygon, x=x, y=y,
                                          age=0, maxage=16,
                                          col=(236, 228, 150)))
            elif tag == "pickup_text":
                # resource changes must be legible ON the world, not
                # only as a HUD delta (first filmed playtest: hp/ammo
                # jumped 'with no visible cause on screen')
                _, polygon, (x, y), txt = fx
                # stagger: simultaneous toasts stack upward instead of
                # overprinting at one spot (gate run 31)
                live_here = sum(1 for fl in self._floaters
                                if fl["polygon"] == polygon)
                self._floaters.append(dict(
                    polygon=polygon, x=x, y=y - 13.0 * live_here,
                    text=txt, age=0, maxage=55))
            elif tag == "hitflash":
                _, eid = fx
                self._hitflash[eid] = 3
            elif tag == "arrived":
                # long enough to survive a 12fps capture sampling it:
                # gate 62 found a 5-tick light "invisible as a distinct
                # pulse at capture cadence" at every single arrival
                _, eid = fx
                self._arrival_flash[eid] = 26
            elif tag == "playerhurt":
                self._hurt_ticks = 2
            elif tag == "playerdie":
                self._dying = True
            elif tag == "playerreprint":
                # the fade belongs to ONE death: without this reset the
                # latch survived the reprint, so every death after the
                # first cut instantly to a full-black linger (run 42b:
                # s11's second death filmed as 85 identical black
                # frames while s7's first filmed every beat — the
                # 'nondeterminism' was death ordinal)
                self._dying = False
                self._death_fade = 0
            # "sound" / "objective" / "terminal" are consumed by
            # audio.py / app.py, not the renderer.

        if self._dying:
            self._death_fade = min(150, self._death_fade + 1)

    # ------------------------------------------------------------------
    # per-frame draw
    # ------------------------------------------------------------------

    def draw(self, surf, debug: bool = False) -> np.ndarray:
        """Zero ambient (the director's order): the world layer's ONLY
        illumination is the per-frame lightmap -- static/attached world
        lights plus this frame's dynamic point lights (muzzle flashes,
        bolts, lit screens) accumulated additively into one black-by-
        default buffer, then multiplied straight onto the drawn world. A
        pixel no enabled light reaches stays (0, 0, 0). The entity plane
        (enemies/pickups/player/effects -- "stylized sensor traces": the
        frame SEES them by sensor, not by light) is composited ON TOP of
        that multiply, unaffected by it, so it stays visible in the dark.

        Otherworld polygons keep their own established identity (the floor
        IS the light source, self-luminous, sculpted by the inverted
        cold-distance field) -- untouched by this order, which is about
        eliminating a screen-space AMBIENT field for ordinary polygons, not
        otherworld's already-diegetic self-illumination.

        Returns the composited (W, H, 3) uint8 framebuffer (pygame surfarray
        axis order). `surf` is used only to size the frame -- render.py never
        writes back into it; the caller owns whatever it blits the return into.
        The bright bolt CORES already drew onto the entity layer inside
        _draw_effects (so the darkness multiply never dims them)."""
        session = self.session
        self._deferred_bolts = []
        self._deferred_screen_glows = []
        self._deferred_bolt_glows = []
        self._deferred_floaters = []
        # SPECTATE (demo tooling only): render from another body's
        # chamber with the camera locked on it, so a feature that
        # belongs to an enemy can be watched where it happens instead of
        # wherever the player happens to be looking. This is RENDER-ONLY
        # by construction — it passes an explicit root/cam into the
        # query and never moves the session's own camera, because the
        # bot perceives through session.visible() too and moving the
        # real root moved the bot's eyes with it.
        root = cam = apex = None
        eid = getattr(self, "spectate_eid", None)
        if eid is not None and session.sim.exists(eid):
            root = session.sim.get_polygon(eid)
            ex_, ey_ = session.entity_pos(eid)
            apex = (ex_, ey_)
            cam = necore.mat_mul(
                necore.mat_mul(
                    necore.mat_translate(session.screen_w / 2,
                                         session.screen_h / 2),
                    necore.mat_scale(session.zoom, session.zoom)),
                necore.mat_translate(-ex_, -ey_))
        instances = session.visible(self.max_depth, self.max_instances,
                                    root=root, cam=cam, apex=apex)
        size = _size_of(surf)
        self._draw_world_rust(size, instances)
        fb = self._rgb  # (W, H, 3) view of the rust framebuffer
        # else: the raster already multiplied world-by-lightmap and
        # folded entities in unmultiplied on top (see _draw_world_rust)
        self._draw_post(fb)
        if debug:
            self._draw_debug(fb, instances)
        # hand back a PERSISTENT per-renderer snapshot. The copy happens
        # on the CONTIGUOUS raw RGBA bytes (one memcpy, ~0.05 ms) — a
        # np.copyto through the transposed (W, H, 3) view was a strided
        # element copy costing ~0.7 ms/frame. The returned array is a
        # stable view of the snapshot, valid until the NEXT draw();
        # every consumer (app, hud, capture, tests) reads or writes it
        # within the frame.
        if self._out_buf is None or len(self._out_buf) != len(self._framebuf):
            self._out_buf = bytearray(len(self._framebuf))
            w, h = self._raster.width, self._raster.height
            self._out_rgb = (np.frombuffer(self._out_buf, dtype=np.uint8)
                             .reshape(h, w, 4)[:, :, :3].transpose(1, 0, 2))
        self._out_buf[:] = self._framebuf
        return self._out_rgb


    # ------------------------------------------------------------------
    # world pass (necore.Raster display list)
    # ------------------------------------------------------------------

    def _ensure_raster(self, size) -> None:
        if self._raster is not None and \
                (self._raster.width, self._raster.height) == size:
            return
        w, h = size
        self._raster = necore.Raster(w, h)
        self._register_decal_shapes(self._raster)
        self._framebuf = bytearray(w * h * 4)
        # a fresh Raster has an empty texture registry; every polygon texture
        # must be re-uploaded lazily on next use
        self._uploaded_tex_ids.clear()
        # Zero-copy numpy view of the rust framebuffer's RGB channels in
        # (W, H, 3) surfarray order: finish_into writes RGBX row-major (H, W, 4)
        # into _framebuf, and this strided view exposes it as fb[x, y] with no
        # per-frame allocation. Every Python composite step writes through it.
        self._rgb = (np.frombuffer(self._framebuf, dtype=np.uint8)
                     .reshape(h, w, 4)[:, :, :3].transpose(1, 0, 2))
    def _get_blob(self, polygon: int):
        """Per-polygon detail prims encoded once as a display-list blob:
        (uint32 header array, float32 coord array, screenglow tuple).
        Coords stay polygon-local; the raster transforms and clips them per
        instance after the CLIP/XFORM header words (2 and 3 of each
        6-word command) are patched with that instance's table indices.
        Screenglows are excluded — their radius quantization and sprite
        alignment happen per frame in Python (`_glow_region_rust`)."""
        cached = self._blob_cache.get(polygon)
        if cached is not None:
            return cached
        prims = self._get_detail(polygon)
        default_color = _shade(self._polygon_pal(polygon)[0], _floor_dim(0),
                               (18, 18, 18))
        cmds: list[int] = []
        coords: list[float] = []
        glows: list[tuple] = []
        for prim in prims:
            kind = prim[0]
            if kind == "line":
                (ax, ay), (bx, by) = prim[1], prim[2]
                color = prim[3] if len(prim) > 3 and prim[3] is not None else default_color
                width = prim[4] if len(prim) > 4 else 1
                cmds.extend((_OP_POLYLINE,
                             _flags(_LAYER_WORLD, _CLIP_GEOM, width=width),
                             0, 0, _rgba(color), 2))
                coords.extend((ax, ay, bx, by))
            elif kind == "dot":
                x, y = prim[1]
                color = prim[2] if len(prim) > 2 and prim[2] is not None else default_color
                radius = prim[3] if len(prim) > 3 else 1
                cmds.extend((_OP_CIRCLE_FILL,
                             _flags(_LAYER_WORLD, _CLIP_GATE),
                             0, 0, _rgba(color), 0))
                coords.extend((x, y, radius))
            elif kind == "stain":
                color = prim[2] if len(prim) > 2 and prim[2] is not None else default_color
                cmds.extend((_OP_POLY_FILL,
                             _flags(_LAYER_WORLD, _CLIP_GEOM),
                             0, 0, _rgba(color), len(prim[1])))
                for x, y in prim[1]:
                    coords.append(x)
                    coords.append(y)
            elif kind == "poly":
                _, pts_local, fill, outline, ow = prim
                if fill is not None:
                    cmds.extend((_OP_POLY_FILL,
                                 _flags(_LAYER_WORLD, _CLIP_GEOM),
                                 0, 0, _rgba(fill), len(pts_local)))
                    for x, y in pts_local:
                        coords.append(x)
                        coords.append(y)
                if outline is not None and ow > 0:
                    cmds.extend((_OP_POLY_OUTLINE,
                                 _flags(_LAYER_WORLD, _CLIP_GEOM, width=ow),
                                 0, 0, _rgba(outline), len(pts_local)))
                    for x, y in pts_local:
                        coords.append(x)
                        coords.append(y)
            elif kind == "polyline":
                _, pts_local, color, width, closed = prim
                cmds.extend((_OP_POLYLINE,
                             _flags(_LAYER_WORLD, _CLIP_GEOM,
                                    closed=closed, width=width),
                             0, 0, _rgba(color), len(pts_local)))
                for x, y in pts_local:
                    coords.append(x)
                    coords.append(y)
            elif kind == "screenglow":
                glows.append((prim[1], prim[2], prim[3]))
        blob = (np.array(cmds, dtype=np.uint32),
                np.array(coords, dtype=np.float32),
                tuple(glows))
        self._blob_cache[polygon] = blob
        return blob

    def _draw_world_rust(self, size, instances) -> list:
        """One rasterized frame: WORLD commands per instance in submission
        order, ENTITY commands (drawn whole, no clipping) onto the entity
        plane, coverage unioned by add_clip — the no-seams fold then happens in
        Rust (entity.a = min(entity.a, coverage), binary-alpha select). Writes
        the composed frame into _framebuf (visible through self._rgb)."""
        session = self.session
        self._ensure_raster(size)
        r = self._raster
        r.begin(0x000000FF)
        # Dynamic commands accumulate into ONE pair of Python lists (a
        # single numpy conversion per frame); cached polygon blobs interleave
        # as (blob, clip_idx, xform_idx) markers so the final stream keeps
        # exact per-instance submission order. `pieces` alternates
        # ("dyn", cmd_end, coord_end) splice points with blob entries.
        cmds: list[int] = []
        coords: list[float] = []
        pieces: list = []
        world = _RustCanvas(_LAYER_WORLD, cmds, coords)
        ent = _RustCanvas(_LAYER_ENTITY, cmds, coords)
        kinds = session.level.polygon_kinds
        ow_polys = []
        # TWO PASSES over the instance list (director, fifth telling,
        # 2026-07-22: "draw the floors, then everything else on top").
        # Instances arrive far-to-near, and floor fills are opaque, so with
        # a single interleaved pass a nearer instance's floor OVERPAINTED
        # the half of any world-layer sprite (station, repair cabinet,
        # decal, door stroke) that overhung a shared boundary — the
        # building-cut-in-half the frame reviews kept finding. Proven by
        # the seam vectors in test_render_layers.py: a station straddling
        # the portal kept 63% of its pixels from one side and 100% from
        # the other, the signature of draw-order overpaint rather than
        # clipping. Pass A paints every floor; pass B paints everything
        # else, so no floor can ever land on top of a sprite.
        staged = []
        for polygon, xform, depth, clip_screen, walls, entry_edge, ents in instances:
            if len(clip_screen) < 3:
                continue
            clip_idx = r.add_clip(clip_screen, False)
            # coverage-only: the ENTITY mask is dilated by a body's worth
            # of pixels so nothing is ever cut in half at a boundary; the
            # floor fill still uses the exact clip above
            r.add_clip(_dilate_poly(clip_screen,
                                    ENTITY_SPILL_U * _xform_scale(xform)),
                       True)
            xform_idx = r.add_xform(xform)
            # floor: a bespoke texture (OP_TEX_FILL) if this polygon has one,
            # else OP_CLIP_FILL paints the registered clip polygon itself
            # from its f64 points, with no Python-side rounding or payload
            polygon_tex = self._polygon_texture_for_raster(polygon)
            if polygon_tex is not None:
                tex_id, bx, by = polygon_tex
                cmds.extend((_OP_TEX_FILL, _flags(_LAYER_WORLD), clip_idx,
                             xform_idx, tex_id, 0))
                coords.extend((bx, by))
            else:
                cmds.extend((_OP_CLIP_FILL, _flags(_LAYER_WORLD), clip_idx,
                             _IDX_NONE, _rgba(self._floor_color(polygon)), 0))
            if self._polygon_kind(polygon) == "otherworld":
                ow_polys.append(clip_screen)
                # the engine composes the otherworld field itself: its
                # marked clips blend the inverted cold field over the
                # lightmap, AFTER the entity fold (raster.rs compose step
                # 6). The mix is the corruption crossfade, so a chamber
                # at the kind boundary composes mostly ordinary light and
                # the source cells compose almost pure inverse.
                r.mark_otherworld(clip_idx,
                                  _ow_mix(self._polygon_descent(polygon)))
            staged.append((polygon, xform, depth, clip_screen, walls,
                           ents, clip_idx, xform_idx))
        for polygon, xform, depth, clip_screen, walls, ents, clip_idx, \
                xform_idx in staged:
            blob_c, blob_f, glows = self._get_blob(polygon)
            if blob_c.size:
                pieces.append(("dyn", len(cmds), len(coords)))
                pieces.append(("blob", blob_c, blob_f, clip_idx, xform_idx))
            if glows:
                # deferred like _draw_detail's; the glow itself feeds the
                # engine lightmap, same as world
                # lights and muzzle FX
                scale = None
                for gx, gy, grad in glows:
                    sx, sy = necore.mat_apply(xform, gx, gy)
                    if _point_in_poly(sx, sy, clip_screen):
                        if scale is None:
                            scale = _xform_scale(xform)
                        self._deferred_screen_glows.append(
                            (sx, sy, grad * scale, clip_screen))
            self._emit_decals(cmds, polygon, clip_idx, xform_idx)
            self._draw_exit_and_terminals(world, polygon, xform, clip_screen)
            self._draw_walls(world, walls, depth, polygon)
            self._draw_doors(world, polygon, xform, clip_screen)
            self._draw_entities(ent, ents, None)
            self._draw_effects(ent, polygon, xform, clip_screen)
            # the player's kite outline re-strokes ABOVE the effects
            # layer: point-blank muzzle/spark stacks covered the ship
            # for 7 straight frames (run 37 ledger, s7 f705-712)
            for peid, psx, psy, pdx, pdy, psrad, pfin in ents:
                if peid == self.session.pid:
                    pang = math.atan2(pdy, pdx)
                    ppts = _xform_pts(PLAYER_SHAPE, psx, psy,
                                      max(psrad, 7.0), pang)
                    ent.polygon((255, 255, 255), _pts(ppts), 1)
        # assemble the final stream: dynamic slices + patched blob copies
        dyn_c = np.array(cmds, dtype=np.uint32)
        dyn_f = np.array(coords, dtype=np.float32)
        chunks_c: list = []
        chunks_f: list = []
        c_at = f_at = 0
        for piece in pieces:
            if piece[0] == "dyn":
                _, c_end, f_end = piece
                if c_end > c_at:
                    chunks_c.append(dyn_c[c_at:c_end])
                    chunks_f.append(dyn_f[f_at:f_end])
                c_at, f_at = c_end, f_end
            else:
                _, blob_c, blob_f, clip_idx, xform_idx = piece
                hdr = blob_c.copy()
                hdr[2::6] = clip_idx
                hdr[3::6] = xform_idx
                chunks_c.append(hdr)
                chunks_f.append(blob_f)
        if len(dyn_c) > c_at:
            chunks_c.append(dyn_c[c_at:])
            chunks_f.append(dyn_f[f_at:])
        if chunks_c:
            r.draw(np.concatenate(chunks_c), np.concatenate(chunks_f))
        # The frame's lightmap (static/attached world lights + dynamic
        # muzzle/bolt/screen glows) accumulates ENGINE-SIDE — begin()
        # zeroed it, Raster.add_light rasterizes each light with the
        # pygame-parity fill, ONE implementation for every frame kind.
        # Non-otherworld frames: the raster multiplies world-by-lightmap
        # BEFORE folding the entity plane in unmultiplied (raster.rs
        # `compose()` order) — zero ambient, entities stay the
        # always-visible sensor-trace layer. Otherworld frames need the
        # inverse-field compositing that lives in Python, so they come
        # back full-bright and draw() reads the lightmap back.
        self._accumulate_lights_rust(r, session, instances)
        r.set_darkness(True)
        r.finish_into(self._framebuf)
        return ow_polys

    # ------------------------------------------------------------------
    # world lights (levels.LightSpec) -- ENGINE_DESIGN.md Lighting section
    # ------------------------------------------------------------------

    def _accumulate_lights_rust(self, r, session, instances) -> None:
        """The engine lightmap path (non-otherworld frames): same groups,
        same prep, same math — rasterize+accumulate happens in
        `Raster.add_light` instead of numpy (was 4+ ms/frame)."""
        for light, g in self._light_groups(session, instances):
            cone = None
            if g.get("cone_ang") is not None and light.arc > 0.0:
                cone = (g["cone_ang"], light.arc)
            cx, cy = g["apex_sx"], g["apex_sy"]
            radius = g["radius_screen"]
            polys = self._prep_gate_polys(cx, cy, radius, g["polys"], cone)
            if not polys:
                continue
            intensity = light.intensity * self.LIGHT_STRENGTH
            flat: list[float] = []
            lens: list[int] = []
            for poly in polys:
                lens.append(len(poly))
                for p in poly:
                    flat.append(p[0])
                    flat.append(p[1])
            sflat: list[float] = []
            slens: list[int] = []
            for poly in g["shadow_polys"]:
                if len(poly) >= 3:
                    slens.append(len(poly))
                    for p in poly:
                        sflat.append(p[0])
                        sflat.append(p[1])
            r.add_light(cx, cy, radius,
                        min(255, int(light.color[0] * intensity)),
                        min(255, int(light.color[1] * intensity)),
                        min(255, int(light.color[2] * intensity)),
                        flat, lens, sflat, slens)
        # the dynamic glow sprites accumulate into the same engine lightmap
        W = r.width
        H = r.height
        for sx, sy, radius, clip_screen in self._deferred_screen_glows:
            if radius <= 1:
                continue
            best = min(self._screen_glow_sizes, key=lambda r_: abs(r_ - radius))
            self._glow_region_rust(r, self._screen_glow_cache[best],
                                   sx, sy, clip_screen, W, H)
        for glow in self._deferred_bolt_glows:
            if glow is None:
                continue
            sx, sy, radius, clip_screen = glow
            if radius <= 1:
                continue
            best = min(self._glow_sizes, key=lambda r_: abs(r_ - radius))
            self._glow_region_rust(r, self._glow_cache[best],
                                   sx, sy, clip_screen, W, H)

    @staticmethod
    def _glow_region_rust(r, img, sx, sy, clip_screen, W, H) -> None:
        """`_add_sprite`'s window arithmetic, routed into the engine
        lightmap (row-major region, saturating add) instead of numpy."""
        ih, iw, _ = img.shape
        destx, desty = int(sx - iw / 2), int(sy - ih / 2)
        xs = [p[0] for p in clip_screen]
        ys = [p[1] for p in clip_screen]
        cx0, cy0 = int(min(xs)), int(min(ys))
        cx1 = cx0 + int(max(xs) - min(xs)) + 1
        cy1 = cy0 + int(max(ys) - min(ys)) + 1
        x0 = max(0, destx, cx0)
        y0 = max(0, desty, cy0)
        x1 = min(W, destx + iw, cx1)
        y1 = min(H, desty + ih, cy1)
        if x1 <= x0 or y1 <= y0:
            return
        sub = img[y0 - desty:y1 - desty, x0 - destx:x1 - destx]  # (rows=y)
        r.lightmap_add_region(x0, y0, x1 - x0, y1 - y0,
                              np.ascontiguousarray(sub).tobytes())

    def _light_groups(self, session, instances):
        lighting = getattr(session, "lighting", None)
        if lighting is None or not lighting.lights:
            return []
        lookup = lighting.frame_lookup(
            session.sim, getattr(session, 'soft_polygons', None))
        if not lookup:
            return []
        # Group every gated wedge by (light, screen apex, screen radius):
        # the same physical light frequently produces several abutting
        # polygons at the same apex (a wedge split across the doorway the
        # camera also looks through, or duplicate reach-paths to one
        # polygon). Filling the whole group as a UNION into one white mask
        # before the single tint+gradient+add pass means shared polygon
        # boundaries saturate at white instead of double-adding -- the
        # C-blit equivalent of the strict pixel-center ownership a
        # per-pixel coverage test would give. Distinct non-Euclidean
        # appearances of a light (different screen apex) stay separate
        # groups and legitimately add.
        #
        # Grouping is TOLERANCE-based (cluster within GROUP_TOL_PX), not a
        # fixed-grid round(x, 1) key: two polygons an ADJACENT light wedge
        # spans (e.g. a straight corridor doorway) recover their screen
        # apex through two DIFFERENT composed transform chains (this
        # polygon's own vs. the light's original discovery chain, inverted
        # and re-projected -- see lighting.py's ROOT-FRAME INVARIANCE
        # docstring: chain-independent in exact math, not in float64). The
        # two apex values can land a few thousandths of a pixel apart --
        # negligible on its own, but a fixed rounding grid occasionally
        # bisects that gap (641.34999 vs 641.35001 round to different
        # buckets), splitting ONE physical wedge into two independent
        # `_blit_light` calls -- two rasterized polygon edges and two
        # independently-rounded gradient origins meeting at the portal --
        # which is exactly the pixel-visible seam this function exists to
        # prevent. Root-caused 2026-07-13 from a director report of
        # "seams between polygons in the corridor" and "ghost lines";
        # reproduced with a real >100-luminance step at the shared portal
        # column in `test_pixel_composite_seam_freeness_across_corridor_
        # portals` before this fix (see that test's fail-first note).
        GROUP_TOL_PX = 1.0
        groups_by_light: dict[int, list[dict]] = {}
        for polygon, xform, depth, clip_screen, walls, entry_edge, ents in instances:
            if len(clip_screen) < 3:
                continue
            polygon_lights = lookup.get(polygon)
            if not polygon_lights:
                continue
            scale = math.hypot(xform[0], xform[3])
            if scale <= 1e-9:
                continue
            for light_idx, inst in polygon_lights:
                poly_screen = [necore.mat_apply(xform, lx, ly)
                               for lx, ly in inst.clip_local]
                gated = necore.clip_polygon(poly_screen, clip_screen)
                if len(gated) < 3:
                    continue
                apex_sx, apex_sy = necore.mat_apply(xform, *inst.apex_local)
                radius_screen = inst.radius_local * scale
                if radius_screen < 1.0:
                    continue
                # Walk-mask terrain shadows: transform+clip the same way as
                # the gate polygon (identical xform/clip_screen), then punch
                # them out of the union fill in `_blit_light` -- terrain
                # blocks lamp light exactly like a wall, but NEVER touches
                # `visibility.rs`/the entity sensor plane, so an enemy
                # standing in one of these shadows stays fully visible
                # (composited after the lightmap multiply, see `draw()`).
                shadow_gated = []
                for spoly in inst.shadow_local:
                    spoly_screen = [necore.mat_apply(xform, lx, ly)
                                     for lx, ly in spoly]
                    sc = necore.clip_polygon(spoly_screen, clip_screen)
                    if len(sc) >= 3:
                        shadow_gated.append(sc)
                buckets = groups_by_light.setdefault(light_idx, [])
                for g in buckets:
                    if (abs(g["apex_sx"] - apex_sx) <= GROUP_TOL_PX
                            and abs(g["apex_sy"] - apex_sy) <= GROUP_TOL_PX
                            and abs(g["radius_screen"] - radius_screen) <= GROUP_TOL_PX):
                        g["polys"].append(gated)
                        g["shadow_polys"].extend(shadow_gated)
                        # running mean keeps the cluster's reference point
                        # centered as more near-identical instances join,
                        # instead of freezing on the first one seen.
                        n = g["n"] + 1
                        g["apex_sx"] += (apex_sx - g["apex_sx"]) / n
                        g["apex_sy"] += (apex_sy - g["apex_sy"]) / n
                        g["radius_screen"] += (radius_screen - g["radius_screen"]) / n
                        g["n"] = n
                        break
                else:
                    cone = None
                    if inst.dir_local is not None:
                        dsx, dsy = necore.mat_apply_dir(
                            xform, inst.dir_local[0], inst.dir_local[1])
                        dm = math.hypot(dsx, dsy)
                        if dm > 1e-9:
                            cone = math.atan2(dsy / dm, dsx / dm)
                    buckets.append({"apex_sx": apex_sx, "apex_sy": apex_sy,
                                     "radius_screen": radius_screen,
                                     "polys": [gated],
                                     "shadow_polys": list(shadow_gated),
                                     "cone_ang": cone, "n": 1})
        out = []
        for light_idx, buckets in groups_by_light.items():
            light = lighting.lights[light_idx]
            for g in buckets:
                out.append((light, g))
        return out

    # Director-tuned global light strength (2026-07-11): "Triple the
    # strength of all lights, I want them to carry." One knob, applied at
    # the single blit site so fixtures, the work lamp, and dynamic
    # flashes all scale together. Carrying light is also the occlusion
    # proof: at this strength, any wedge leaking through a wall would be
    # unmissable.
    LIGHT_STRENGTH = 3.0

    @staticmethod
    def _cone_wedge(cx, cy, radius, angle, arc, segs=10):
        """Exact convex wedge polygon for a directional light: apex at
        (cx, cy), arc fan of `segs` chords out past `radius`. The cone
        is a CLIP, not a sprite — sprite rotation can never be
        root-frame invariant at the pixel level, and this engine's
        whole look is clipped wedges anyway (arc < pi keeps it
        convex, which Sutherland-Hodgman clipping requires)."""
        half = arc / 2.0
        rr = radius * 1.25
        pts = [(cx, cy)]
        for i in range(segs + 1):
            a2 = angle - half + arc * i / segs
            pts.append((cx + rr * math.cos(a2), cy + rr * math.sin(a2)))
        return pts

    @staticmethod
    def _prep_gate_polys(cx, cy, radius, gate_polys, cone):
        """Shared pre-rasterization pass for one light's wedges — used
        (`Raster.add_light` — the one lightmap implementation).

        Rejects sub-pixel sliver wedges (a far light grazing along a wall
        produces them): pygame.draw.polygon always rasterizes at least
        its 1px OUTLINE, so a polygon with near-zero interior would show
        as a bright streak where per-pixel-center coverage math correctly
        showed nothing. Mean width = 2*area/perim. Then applies the cone
        clip BEFORE coverage so the mask fills the clipped wedge."""
        polys = []
        for poly in gate_polys:
            area2 = 0.0
            perim = 0.0
            n = len(poly)
            for i in range(n):
                ax, ay = poly[i]
                bx, by = poly[(i + 1) % n]
                area2 += ax * by - bx * ay
                perim += math.hypot(bx - ax, by - ay)
            if perim > 1e-9 and abs(area2) / perim >= 0.8:  # width >= ~0.8 px
                polys.append(poly)
        if polys and cone is not None:
            cone_ang, cone_arc = cone
            wedge = Renderer._cone_wedge(cx, cy, radius, cone_ang, cone_arc)
            clipped = []
            for poly in polys:
                cpoly = necore.clip_polygon(poly, wedge)
                if len(cpoly) >= 3:
                    clipped.append(cpoly)
            polys = clipped
        return polys

    # -- (1) floor ------------------------------------------------------

    def _polygon_descent(self, polygon: int) -> float:
        """Per-polygon descent scalar. Polygons the sim added on its own since the
        streamer last extended the list (portable-hole corridors, the
        cloister) clamp to the last known value — they are always carved
        near where the player already is, so the error is at most a chunk
        step, which is invisible by construction."""
        meta = getattr(self.session, "hub_polygon_meta", None)
        if meta:
            got = meta.get(polygon)
            if got is not None:
                return got[1]
        rd = getattr(self.session.level, "polygon_descent", None)
        if not rd:
            return 0.0
        return rd[polygon] if polygon < len(rd) else rd[-1]

    def _polygon_kind(self, polygon: int) -> str:
        """This polygon's function tag. The marrow's chambers carry theirs
        on the SESSION (they belong to no level), so they survive a chunk
        swap; everything else reads the level's own array."""
        meta = getattr(self.session, "hub_polygon_meta", None)
        if meta:
            got = meta.get(polygon)
            if got is not None:
                return got[0]
        kinds = self.session.level.polygon_kinds
        return kinds[polygon] if polygon < len(kinds) else "generic"

    def _polygon_pal(self, polygon: int) -> tuple:
        """(floor, wall, wall_min) for this polygon's descent, cached — descent
        is a per-polygon constant, assigned before the polygon is ever visible."""
        pal = self._pal_cache.get(polygon)
        if pal is None:
            d = self._polygon_descent(polygon)
            if self._polygon_kind(polygon) in _MARROW_KINDS:
                pal = (_ramp(_MARROW_FLOOR_RAMP, d),
                       _ramp(_MARROW_WALL_RAMP, d),
                       _ramp(_MARROW_WALL_MIN_RAMP, d))
            else:
                pal = (_ramp(_FLOOR_RAMP, d),
                       _ramp(_WALL_RAMP, d),
                       _ramp(_WALL_MIN_RAMP, d))
            self._pal_cache[polygon] = pal
        return pal

    def _floor_color(self, polygon: int):
        # Constant per polygon (dim/tint are identity since distance lighting
        # replaced depth dimming), so cache the shaded color — _shade was a
        # measurable per-instance cost at 400 instances.
        color = self._floor_color_cache.get(polygon)
        if color is None:
            if self._polygon_kind(polygon) == "otherworld":
                # the floor is the light source: self-luminous cold base
                # that the inverted darkness field then sculpts (dim near
                # the player, glowing at distance). It arrives on the same
                # crossfade as the lighting model, so the first otherworld
                # chamber is not a different game from the one before it.
                m = _ow_mix(self._polygon_descent(polygon))
                base = self._polygon_pal(polygon)[0]
                color = tuple(int(round(base[i] + (OW_FLOOR[i] - base[i]) * m))
                              for i in range(3))
            else:
                color = _shade(self._polygon_pal(polygon)[0], _floor_dim(0),
                               _polygon_tint(polygon))
            self._floor_color_cache[polygon] = color
        return color

    # -- bespoke floor textures --------------------------------------------

    def _texture_key(self, polygon: int):
        """(level_id, local_polygon_index) for `polygon`'s texture file, or None
        if no level_id is known (never loaded from a levels/*.json path --
        e.g. LevelBuilder.build()'s debug level)."""
        if self.polygon_texture_lookup is not None:
            return self.polygon_texture_lookup(polygon)
        level_id = getattr(self.session.level, "level_id", "") or ""
        if not level_id:
            return None
        return (level_id, polygon)

    def _load_polygon_texture(self, polygon: int):
        """(rgb uint8 array shape (h, w, 3), bbox_min_x, bbox_min_y) for
        `polygon`'s bespoke floor texture, or None if it has none. Cached
        forever per Renderer instance; bbox_min is captured from the
        polygon's CURRENT local verts at first load (matches the static verts
        the generation tool used -- soft/otherworld polygons that deform their
        verts at runtime don't carry textures today)."""
        if polygon in self._polygon_texture:
            return self._polygon_texture[polygon]
        result = None
        key = self._texture_key(polygon)
        if key is not None:
            level_id, local_idx = key
            path = texture_geom.texture_path(TEXTURE_DIR, level_id, local_idx)
            if path.is_file():
                with Image.open(str(path)) as im:
                    arr = np.asarray(im.convert("RGB"), dtype=np.uint8).copy()
                verts = self.session.level.polygon_verts[polygon]
                bx, by, _, _ = texture_geom.polygon_bbox(verts)
                result = (arr, bx, by)
        self._polygon_texture[polygon] = result
        return result

    def _polygon_texture_for_raster(self, polygon: int):
        """(texture_id, bbox_min_x, bbox_min_y) for the rust backend, or
        None. Uploads the texture to the current Raster on first use."""
        tex = self._load_polygon_texture(polygon)
        if tex is None:
            return None
        arr, bx, by = tex
        if polygon not in self._uploaded_tex_ids:
            h, w, _ = arr.shape
            self._raster.set_texture(polygon, w, h, arr.tobytes())
            self._uploaded_tex_ids.add(polygon)
        return polygon, bx, by

    # The floor is emitted straight into the rust command stream by
    # _draw_world_rust (OP_TEX_FILL for a bespoke texture, else OP_CLIP_FILL);
    # there is no Python floor draw. (The old pygame-backend _draw_floor /
    # _draw_floor_textured mirror was deleted with the pygame backend.)

    # -- (2) polygon detail --------------------------------------------------

    def _portal_edges_for(self, polygon: int) -> set:
        """(polygon, edge) pairs that are an open connection, a connect_x
        mirror, or a pending (locked-or-not) door -- computed once for the
        whole level and cached. Polygon verts/edge indices come from the same
        post-doorway-split geometry the engine itself connects, so this
        lines up exactly with what `necore` considers a portal."""
        if self._portal_edges is None:
            level = self.session.level
            edges: dict[int, set] = {}
            for a, ea, b, eb in level.connects:
                edges.setdefault(a, set()).add(ea)
                edges.setdefault(b, set()).add(eb)
            for a, ea, b, eb, _m in level.connects_x:
                edges.setdefault(a, set()).add(ea)
                edges.setdefault(b, set()).add(eb)
            for d in level.doors:
                edges.setdefault(d.a, set()).add(d.ea)
                edges.setdefault(d.b, set()).add(d.eb)
            self._portal_edges = edges
        return self._portal_edges.get(polygon, set())

    def _get_detail(self, polygon: int):
        cached = self._detail_cache.get(polygon)
        if cached is not None:
            return cached
        level = self.session.level
        if polygon >= len(level.polygon_verts):
            return []
        verts = level.polygon_verts[polygon]
        seed = level.polygon_seeds[polygon] if polygon < len(level.polygon_seeds) else polygon * 7919 + 13
        rng = random.Random(seed)
        kind = self._polygon_kind(polygon)
        xs = [v[0] for v in verts]
        ys = [v[1] for v in verts]
        x0, x1 = min(xs), max(xs)
        y0, y1 = min(ys), max(ys)
        walls = _wall_edges(verts, self._portal_edges_for(polygon))
        gen = _POLYGON_PROP_GENERATORS.get(kind, _props_generic)
        # The descent pipeline: the base layout draws from `rng` exactly as
        # it always did (a polygon's furniture is identical at every depth);
        # corruption and dressing draw from a SECOND stream seeded from the
        # same polygon seed, so frames stay deterministic without the additions
        # reshuffling the base. Temperature drift is baked in last, once.
        descent = self._polygon_descent(polygon)
        crng = random.Random(seed ^ 0x5EED5EED)
        prims = list(gen(rng, verts, walls, x0, y0, x1, y1,
                         descent=descent, crng=crng))
        prims.extend(_descent_dressing(crng, descent, walls, x0, y0, x1, y1))
        prims = _warm_prims(prims, descent)
        prims = _snap_prims_f32(prims)
        self._detail_cache[polygon] = prims
        return prims

    def _draw_detail(self, canvas, polygon, xform, clip_screen, depth):
        prims = self._get_detail(polygon)
        if not prims:
            return
        dim = _floor_dim(depth)
        tint = _polygon_tint(polygon)
        default_color = _shade(self._polygon_pal(polygon)[0], dim,
                               (tint[0] + 18, tint[1] + 18, tint[2] + 18))
        scale = None
        for prim in prims:
            kind = prim[0]
            if kind == "line":
                (ax, ay), (bx, by) = prim[1], prim[2]
                color = prim[3] if len(prim) > 3 and prim[3] is not None else default_color
                width = prim[4] if len(prim) > 4 else 1
                sx1, sy1 = necore.mat_apply(xform, ax, ay)
                sx2, sy2 = necore.mat_apply(xform, bx, by)
                for seg in necore.clip_polyline([(sx1, sy1), (sx2, sy2)], clip_screen):
                    if len(seg) >= 2:
                        canvas.line(color, _pt(seg[0]), _pt(seg[-1]), width)
            elif kind == "dot":
                x, y = prim[1]
                color = prim[2] if len(prim) > 2 and prim[2] is not None else default_color
                radius = prim[3] if len(prim) > 3 else 1
                sx, sy = necore.mat_apply(xform, x, y)
                if _point_in_poly(sx, sy, clip_screen):
                    canvas.circle(color, _pt((sx, sy)), radius)
            elif kind == "stain":
                color = prim[2] if len(prim) > 2 and prim[2] is not None else default_color
                spoly = [necore.mat_apply(xform, x, y) for x, y in prim[1]]
                clipped = necore.clip_polygon(spoly, clip_screen)
                if len(clipped) >= 3:
                    canvas.polygon(color, _pts(clipped))
            elif kind == "poly":
                # ("poly", local_pts, fill_or_None, outline_or_None, outline_width)
                _, pts_local, fill, outline, ow = prim
                spoly = [necore.mat_apply(xform, x, y) for x, y in pts_local]
                clipped = necore.clip_polygon(spoly, clip_screen)
                if len(clipped) >= 3:
                    cpts = _pts(clipped)
                    if fill is not None:
                        canvas.polygon(fill, cpts)
                    if outline is not None and ow > 0:
                        canvas.polygon(outline, cpts, ow)
            elif kind == "polyline":
                # ("polyline", local_pts, color, width, closed)
                _, pts_local, color, width, closed = prim
                spts = [necore.mat_apply(xform, x, y) for x, y in pts_local]
                if closed and spts:
                    spts = spts + [spts[0]]
                for seg in necore.clip_polyline(spts, clip_screen):
                    if len(seg) >= 2:
                        canvas.lines(color, False, _pts(seg), width)
            elif kind == "screenglow":
                # ("screenglow", x, y, radius) -- registered as a lightmap
                # contribution, like flashes/bolts (engine lightmap)
                _, x, y, radius = prim
                sx, sy = necore.mat_apply(xform, x, y)
                if _point_in_poly(sx, sy, clip_screen):
                    if scale is None:
                        scale = _xform_scale(xform)
                    self._deferred_screen_glows.append((sx, sy, radius * scale, clip_screen))

    # -- (3) decals -------------------------------------------------------

    # -- retained decals (engine-side replay) ---------------------------
    #
    # Decal geometry lives in the ENGINE: each polygon's decal list is
    # uploaded once per change (`Raster.set_decals`; sim decals are
    # append-mostly, capped at 250) and replayed per frame by one
    # OP_DECALS command per instance — the per-frame Python loop that
    # re-transformed ~220 decal polygons every frame (1.3+ ms) is gone.
    # The record math in raster.rs `exec_decals` is the exact port of
    # the old `_draw_decal` branches; these tables define the records.

    #: shape-template ids for `set_decal_shape` (registered lazily)
    _DECAL_BLOOD, _DECAL_SPLAT, _DECAL_CIRCLE = 1, 2, 3
    _DECAL_CHIP_A, _DECAL_CHIP_B = 4, 5
    _DECAL_LINE_A, _DECAL_LINE_B = 6, 7
    _DECAL_PLAYER = 8
    _DECAL_ENEMY_BASE = 16

    def _register_decal_shapes(self, r) -> None:
        flat = lambda pts: [c for p in pts for c in p]
        r.set_decal_shape(self._DECAL_BLOOD, flat(BLOOD_BLOB))
        r.set_decal_shape(self._DECAL_SPLAT, flat(SPLAT_BLOB))
        r.set_decal_shape(self._DECAL_CIRCLE, flat(_CIRCLE_SHAPE))
        r.set_decal_shape(self._DECAL_CHIP_A, [-1.0, -1.0, 1.0, 1.0])
        r.set_decal_shape(self._DECAL_CHIP_B, [-1.0, 1.0, 1.0, -1.0])
        r.set_decal_shape(self._DECAL_LINE_A, [0.0, 0.0, 0.6, 0.2])
        r.set_decal_shape(self._DECAL_LINE_B, [0.0, 0.0, -0.6, 0.2])
        r.set_decal_shape(self._DECAL_PLAYER, flat(PLAYER_SHAPE))
        self._decal_enemy_ids = {}
        for i, (kind, shape) in enumerate(sorted(ENEMY_SHAPE.items())):
            self._decal_enemy_ids[kind] = self._DECAL_ENEMY_BASE + i
            r.set_decal_shape(self._DECAL_ENEMY_BASE + i, flat(shape))
        self._decal_uploaded = {}

    def _decal_records(self, decals) -> list:
        """Translate sim decals into engine records (12 f64 each:
        [style, x, y, size, angle, squash, eff_mul, r, g, b, shape, rot])
        — the same branch table `_draw_decal` used to draw from."""
        out = []
        add = out.extend
        for kind, x, y, size, angle in decals:
            if kind == "blood":
                c = BLOOD_COLOR
                add((0.0, x, y, size, angle, 1.0, 0.72,
                     c[0], c[1], c[2], self._DECAL_BLOOD, 1.0))
            elif kind == "splat":
                c = BLOOD_COLOR
                add((0.0, x, y, size, angle, 1.0, 0.6,
                     c[0], c[1], c[2], self._DECAL_SPLAT, 1.0))
            elif kind == "chip":
                c = CHIP_COLOR
                for sh in (self._DECAL_CHIP_A, self._DECAL_CHIP_B):
                    add((2.0, x, y, size, angle, 1.0, 1.0,
                         c[0], c[1], c[2], sh, 0.0))
            elif kind == "scorch":
                c = SCORCH_COLOR
                add((1.0, x, y, size, angle, 1.0, 1.0,
                     c[0], c[1], c[2], 0.0, 0.0))
            elif kind.startswith("corpse_"):
                ekind = kind[len("corpse_"):]
                if ekind == "player":
                    shape = self._DECAL_PLAYER
                    base = PLAYER_COLOR
                    mul = 0.4
                else:
                    shape = self._decal_enemy_ids.get(
                        ekind, self._DECAL_CIRCLE)
                    base = ENEMY_COLOR.get(ekind, (90, 90, 90))
                    mul = 0.45
                cr, cg, cb = (int(base[0] * mul), int(base[1] * mul),
                              int(base[2] * mul))
                add((0.0, x, y, size, angle, 0.55, 0.9,
                     cr, cg, cb, shape, 1.0))
                for sh in (self._DECAL_LINE_A, self._DECAL_LINE_B):
                    add((2.0, x, y, size, angle, 0.55, 0.9,
                         cr, cg, cb, sh, 1.0))
        return out

    def _emit_decals(self, cmds, polygon, clip_idx, xform_idx) -> None:
        decals = self.session.decals.get(polygon)
        if not decals:
            return
        v = self.session.decal_versions.get(polygon, 0)
        if self._decal_uploaded.get(polygon) != v:
            self._raster.set_decals(polygon, self._decal_records(decals))
            self._decal_uploaded[polygon] = v
        cmds.extend((_OP_DECALS, _flags(_LAYER_WORLD), clip_idx,
                     xform_idx, polygon, 0))

    def _draw_exit_and_terminals(self, canvas, polygon, xform, clip_screen):
        session = self.session
        if session.exit_polygon == polygon:
            sx, sy = necore.mat_apply(xform, *session.exit_pos)
            if _point_in_poly(sx, sy, clip_screen):
                phase = (session.tick_count % 90) / 90.0
                r = 9 + 4 * math.sin(phase * 2 * math.pi)
                canvas.circle(EXIT_COLOR, _pt((sx, sy)), max(2, int(r)), 1)
                cx, cy = _pt((sx, sy))
                canvas.polygon(EXIT_COLOR,
                               [(cx, cy - 5), (cx - 4, cy + 3), (cx + 4, cy + 3)])
        for t in session.terminals:
            if t["polygon"] != polygon:
                continue
            self._draw_terminal(canvas, polygon, xform, clip_screen, t)
        for st in getattr(session, "stations", ()):
            if st["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, *st["pos"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            ix, iy = _pt((sx, sy))
            # ROOTS: the pod digs into the deck to extract resources, so
            # tendrils crawl out from its foot and lengthen with age up to a
            # cap (~45s to full). The native spawn pod is already dug in
            # (planted_tick << 0 -> instantly full). Drawn before the plate
            # so the chassis sits on top of where they emerge.
            age = session.tick_count - st.get("planted_tick", session.tick_count)
            grow = max(0.0, min(1.0, age / (BUILDING_UNPACK_TICKS * 1.5)))
            if grow > 0.02:
                # roots spread into the DECK, so they fan through the lower
                # hemisphere (down and to the sides), never straight up like
                # spokes; each kinks and forks so it reads organic, not wired.
                nroots = 5
                roff = math.sin(st["pos"][0] * 0.21) * 0.4   # per-pod waver
                pulse = 0.5 + 0.5 * math.sin(
                    (session.tick_count % 120) / 120.0 * 2 * math.pi)
                for r in range(nroots):
                    a = math.pi / 2 + (r / (nroots - 1) - 0.5) * 3.7 + roff
                    rl = (6 + 13 * grow)
                    bxp, byp = ix + math.cos(a) * 4, iy + 8
                    kx = bxp + math.cos(a) * rl * 0.55
                    ky = byp + math.sin(a) * rl * 0.55
                    tx = kx + math.cos(a + 0.25) * rl * 0.5
                    ty = ky + math.sin(a + 0.25) * rl * 0.5
                    canvas.line((36, 54, 46), (int(bxp), int(byp)),
                                (int(kx), int(ky)), 1)
                    canvas.line((30, 46, 40), (int(kx), int(ky)),
                                (int(tx), int(ty)), 1)
                    # a shorter fork off the kink -- rootlets, not a fan
                    fx2 = kx + math.cos(a - 0.5) * rl * 0.4
                    fy2 = ky + math.sin(a - 0.5) * rl * 0.4
                    canvas.line((30, 46, 40), (int(kx), int(ky)),
                                (int(fx2), int(fy2)), 1)
                    # the growing tip glows faintly when nearly extended
                    tipc = int(70 + 60 * grow * pulse)
                    canvas.set_at((int(tx), int(ty)),
                                  (tipc, min(255, tipc + 40), tipc))
            # THE CUCULUS. Not a fixture the player uses — the player
            # IS this, and the thing that walks and shoots is a body it
            # prints and drives (director 2026-07-21). So it reads as a
            # GENERAL-PURPOSE FACTORY seated on the deck: base plate with
            # bolts, ribbed column, a lit core slit, a fabricator arm over
            # an output chute, and a visible rack of the blank bodies it
            # still holds — the number you gamble with every death.
            plate = [(ix - 15, iy + 12), (ix + 15, iy + 12),
                     (ix + 12, iy + 5), (ix - 12, iy + 5)]
            canvas.polygon((24, 36, 32), plate)
            canvas.polygon((92, 150, 120), plate, 1)
            for bx in (-11, 0, 11):                       # deck bolts
                canvas.set_at((ix + bx, iy + 10), (140, 200, 170))
            body = [(ix - 9, iy + 6), (ix + 9, iy + 6),
                    (ix + 7, iy - 15), (ix - 7, iy - 15)]
            canvas.polygon((32, 48, 42), body)
            canvas.polygon((150, 240, 185), body, 1)
            # ribs down the column
            for dy in (-11, -6, -1, 4):
                canvas.line((70, 120, 96), (ix - 6, iy + dy),
                            (ix + 6, iy + dy), 1)
            # the core slit, breathing
            phase = (session.tick_count % 120) / 120.0
            glow = 0.5 + 0.5 * math.sin(phase * 2 * math.pi)
            core = (int(120 + 120 * glow), int(230 + 25 * glow),
                    int(170 + 60 * glow))
            canvas.rect(core, Rect(ix - 2, iy - 12, 4, 9))
            # the fabricator arm: a jointed boom over the output chute,
            # which is what makes it read as a factory and not a monument
            ax0, ay0 = ix + 7, iy - 11
            ax1, ay1 = ix + 13, iy - 4
            canvas.line((120, 190, 155), (ax0, ay0), (ax1, ay1), 2)
            canvas.line((150, 240, 185), (ax1, ay1), (ax1 - 3, iy + 3), 1)
            canvas.rect((60, 96, 82), Rect(ix + 8, iy + 3, 7, 3))
            canvas.rect((150, 240, 185), Rect(ix + 8, iy + 3, 7, 3), 1)
            # THE RACK: one blank body per chassis still stocked, on the
            # plate beside the column. INF (the spawn pod) shows a full
            # rack with a bar over it.
            stock = st.get("stock", 0)
            if st.get("infinite"):
                shown, cap = 3, True
            else:
                shown, cap = max(0, min(3, int(stock))), False
            for k in range(shown):
                bxp = ix - 13 + k * 9
                # on the PLATE, below the column: a slot tucked behind the
                # column reads as no body at all (checked at 3/2/1/0)
                canvas.rect((44, 66, 58), Rect(bxp, iy + 7, 7, 4))
                canvas.rect((160, 245, 195), Rect(bxp, iy + 7, 7, 4), 1)
            if cap:
                canvas.line((160, 245, 195), (ix - 13, iy + 6),
                            (ix + 12, iy + 6), 1)
            elif shown == 0:                       # empty rack reads empty
                canvas.rect((110, 50, 46), Rect(ix - 13, iy + 7, 25, 4), 1)
            rr = 19 + 6 * math.sin(phase * 2 * math.pi)
            canvas.circle((140, 240, 185), (ix, iy), max(2, int(rr)), 1)
            canvas.circle((90, 165, 130), (ix, iy),
                          max(2, int(rr * 0.62)), 1)
            # CONDUIT: a visible feed line from the pod to every turret it
            # supplies in this polygon. Same-polygon is 0 hops, always within
            # SENTRY_SUPPLY_HOPS, so a same-polygon supplied turret is fed by
            # THIS pod. Cross-polygon supply still works mechanically; only
            # the straight-line cable is drawn (no portal to route it through).
            for tid, tur in getattr(session, "sentries", {}).items():
                if not tur.get("supplied"):
                    continue
                if session.sim.get_polygon(tid) != polygon:
                    continue
                _, twx, twy, *_ = session.sim.get(tid)
                tsx, tsy = necore.mat_apply(xform, twx, twy)
                if not _point_in_poly(tsx, tsy, clip_screen):
                    continue
                canvas.line((58, 104, 86), (ix, iy - 2),
                            (int(tsx), int(tsy)), 1)
                # a bright pip flowing pod -> turret reads as feed, not decor
                f = (session.tick_count % 44) / 44.0
                px = ix + (tsx - ix) * f
                py = (iy - 2) + (tsy - (iy - 2)) * f
                canvas.set_at((int(px), int(py)), (150, 240, 185))
        for b in getattr(session, "boosters", ()):
            if b["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, *b["pos"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            ix, iy = _pt((sx, sy))
            # repair station: a low field cabinet on skids, its pool read
            # as a bar across the front. Thin-walled — it LOOKS breakable.
            # A FIELD INFIRMARY: cabinet on skids, hinged lid thrown
            # open, a segmented pool gauge and a red cross on white. Built
            # from real parts rather than a rectangle so it reads as
            # equipment somebody carried in (director 2026-07-21: "the
            # building graphics need work").
            skid = [(ix - 15, iy + 11), (ix + 15, iy + 11),
                    (ix + 12, iy + 8), (ix - 12, iy + 8)]
            canvas.polygon((38, 34, 32), skid)
            canvas.polygon((120, 112, 104), skid, 1)
            body = [(ix - 12, iy + 8), (ix + 12, iy + 8),
                    (ix + 10, iy - 6), (ix - 10, iy - 6)]
            canvas.polygon((58, 54, 52), body)
            canvas.polygon((240, 236, 228), body, 1)
            # lid, hinged back and standing open
            lid = [(ix - 10, iy - 6), (ix + 10, iy - 6),
                   (ix + 7, iy - 14), (ix - 13, iy - 14)]
            canvas.polygon((44, 42, 44), lid)
            canvas.polygon((205, 200, 194), lid, 1)
            # A LATIN CROSS, engraved in bone-ivory (director 2026-07-23:
            # the red medical cross is trademarked and wrong on a robot —
            # "replace it with Christian iconography instead"). The
            # resurrection machine wears the resurrection symbol: long
            # stem, crossbar set high, no red. Reads as devotional, not
            # medical.
            cross = (224, 216, 196)
            canvas.line(cross, (ix, iy - 15), (ix, iy - 5), 2)     # stem
            canvas.line(cross, (ix - 4, iy - 12), (ix + 4, iy - 12), 2)  # bar
            # segmented pool gauge across the front
            frac = max(0.0, min(1.0, b["charge"]
                                / float(session.REPAIR_POOL_MAX)))
            for k in range(6):
                x0 = ix - 9 + k * 3
                on = (k + 0.5) / 6.0 <= frac
                canvas.rect((150, 245, 215) if on else (34, 48, 46),
                            Rect(x0, iy + 1, 2, 5))
            canvas.rect((110, 106, 100), Rect(ix - 10, iy, 20, 7), 1)
            # feet
            canvas.line((120, 112, 104), (ix - 11, iy + 11), (ix - 11, iy + 14), 1)
            canvas.line((120, 112, 104), (ix + 11, iy + 11), (ix + 11, iy + 14), 1)
            # UNPACKING: a closing ring while the station seats over its
            # first 30s -- visibly not yet online (inert + fragile until it
            # is), and no heal aura yet
            if session.tick_count < b.get("ready_at", 0):
                rem = (b["ready_at"] - session.tick_count) \
                    / float(BUILDING_UNPACK_TICKS)
                canvas.circle((205, 200, 194), (ix, iy),
                              max(4, int(6 + 9 * rem)), 1)
            # the aura only once it's seated AND can actually pay out
            elif b["charge"] > 0:
                phase = (session.tick_count % 150) / 150.0
                rr = 20 + 7 * math.sin(phase * 2 * math.pi)
                canvas.circle((225, 220, 212), (ix, iy), max(2, int(rr)), 1)
            hurt = b.get("hp", session.REPAIR_HP) / float(session.REPAIR_HP)
            if hurt < 1.0:
                canvas.rect((44, 20, 18), Rect(ix - 10, iy - 12, 20, 2))
                canvas.rect((235, 110, 80),
                            Rect(ix - 10, iy - 12, int(20 * hurt), 2))
        # BREACHES: deliberately NO floor marker — the carved hole in
        # the wall is a real portal the renderer already draws, and the
        # violet breach-light already washes the chamber. A ring on the
        # floor read as 'a thing on the floor' (director, 2026-07-26).

    def _nearest_wall_point(self, polygon: int, pos):
        """Nearest point on a polygon's wall to `pos` (polygon-local), for
        flush-mounting a fixture. Strongly prefers non-portal edges (a
        console can't hang in a doorway) but falls back to any edge rather
        than returning nothing, since a level always has *some* wall."""
        level = self.session.level
        if polygon >= len(level.polygon_verts):
            return None
        verts = level.polygon_verts[polygon]
        portals = self._portal_edges_for(polygon)
        n = len(verts)
        px, py = pos
        best = None
        best_score = 1e18
        for i in range(n):
            x0, y0 = verts[i]
            x1, y1 = verts[(i + 1) % n]
            dx, dy = x1 - x0, y1 - y0
            length2 = dx * dx + dy * dy
            if length2 < 1e-6:
                continue
            t = max(0.08, min(0.92, ((px - x0) * dx + (py - y0) * dy) / length2))
            cx, cy = x0 + dx * t, y0 + dy * t
            d = (cx - px) ** 2 + (cy - py) ** 2
            score = d * (6.0 if i in portals else 1.0)
            if score < best_score:
                best_score = score
                length = math.sqrt(length2)
                nx, ny = _edge_inward_normal(x0, y0, x1, y1)
                best = dict(cx=cx, cy=cy, nx=nx, ny=ny, tx=dx / length, ty=dy / length)
        return best

    def _draw_terminal(self, canvas, polygon, xform, clip_screen, t):
        """A wall-mounted console slab with an inset phosphor screen
        (Marathon-style wall terminal), flush against the nearest wall
        edge -- not a free-standing glyph."""
        bright = not t["read"]
        screen_color = (100, 255, 140) if bright else (55, 110, 75)
        wall = self._nearest_wall_point(polygon, t["pos"])
        if wall is None:
            # degenerate polygon (no usable edge) -- keep the old free-standing
            # glyph rather than dropping the terminal entirely
            sx, sy = necore.mat_apply(xform, *t["pos"])
            if not _point_in_poly(sx, sy, clip_screen):
                return
            rect = Rect(0, 0, 6, 8)
            rect.center = _pt((sx, sy))
            canvas.rect((20, 30, 24), rect)
            canvas.rect(screen_color, rect, 1)
            return
        cx, cy, nx, ny = wall["cx"], wall["cy"], wall["nx"], wall["ny"]
        ang = math.atan2(wall["ty"], wall["tx"])
        slab_w, slab_d = 13.0, 6.0
        slab_pts = _rect_local(cx + nx * slab_d * 0.5, cy + ny * slab_d * 0.5,
                                slab_w, slab_d, ang)
        spoly = [necore.mat_apply(xform, x, y) for x, y in slab_pts]
        clipped = necore.clip_polygon(spoly, clip_screen)
        if len(clipped) < 3:
            return
        cpts = _pts(clipped)
        canvas.polygon(PROP_DARK, cpts)
        canvas.polygon(PROP_RIM, cpts, 1)
        scr_cx, scr_cy = cx + nx * slab_d * 0.62, cy + ny * slab_d * 0.62
        scr_pts = _rect_local(scr_cx, scr_cy, slab_w * 0.5, slab_d * 0.55, ang)
        sspoly = [necore.mat_apply(xform, x, y) for x, y in scr_pts]
        sclipped = necore.clip_polygon(sspoly, clip_screen)
        if len(sclipped) >= 3:
            canvas.polygon(screen_color, _pts(sclipped))
        if bright:
            ssx, ssy = necore.mat_apply(xform, scr_cx, scr_cy)
            if _point_in_poly(ssx, ssy, clip_screen):
                self._deferred_screen_glows.append(
                    (ssx, ssy, 6.0 * _xform_scale(xform), clip_screen))

    # -- (5) walls + doors --------------------------------------------------

    def _wall_color(self, polygon: int):
        # Walls are the level's readability skeleton: they may dim (via
        # _dim, currently identity — distance lighting replaced depth
        # dimming) but never below the wall-min floor. Both ends of that
        # range drift with the polygon's descent. Constant per polygon -> cached.
        color = self._wall_color_cache.get(polygon)
        if color is None:
            _, wall, wall_min = self._polygon_pal(polygon)
            c = _shade(wall, _dim(0))
            color = (max(c[0], wall_min[0]), max(c[1], wall_min[1]),
                     max(c[2], wall_min[2]))
            self._wall_color_cache[polygon] = color
        return color

    def _draw_walls(self, canvas, walls, depth, polygon):
        color = self._wall_color(polygon)
        for x1, y1, x2, y2, is_portal in walls:
            if is_portal:
                continue  # seamlessness is sacred: never draw a portal edge
            canvas.line(color, _pt((x1, y1)), _pt((x2, y2)), 2)

    def _draw_doors(self, canvas, polygon, xform, clip_screen):
        sim = self.session.sim
        for (r, e), key in self.session.door_edges.items():
            if r != polygon:
                continue
            try:
                x1, y1, x2, y2 = sim.edge_endpoints(r, e)
            except Exception:
                continue
            sx1, sy1 = necore.mat_apply(xform, x1, y1)
            sx2, sy2 = necore.mat_apply(xform, x2, y2)
            if key == "shoot":
                # a secret is a wall that keeps its secret: THIS polygon's wall
                # color (which drifts with descent — a cold grey slab in a
                # warm deep deck would be a tell), one hairline fissure
                for seg in necore.clip_polyline([(sx1, sy1), (sx2, sy2)],
                                                clip_screen):
                    if len(seg) < 2:
                        continue
                    a, b = seg[0], seg[-1]
                    canvas.line(self._wall_color(polygon), _pt(a), _pt(b), 2)
                    fx_ = a[0] + (b[0] - a[0]) * 0.62
                    fy_ = a[1] + (b[1] - a[1]) * 0.62
                    nx_, ny_ = (b[1] - a[1]), -(b[0] - a[0])
                    ln = max(1e-6, (nx_ * nx_ + ny_ * ny_) ** 0.5)
                    canvas.line((90, 96, 104), _pt((fx_, fy_)),
                                _pt((fx_ + 3 * nx_ / ln,
                                     fy_ + 3 * ny_ / ln)), 1)
                continue
            color = KEY_COLORS.get(key, DOOR_COLOR)
            for seg in necore.clip_polyline([(sx1, sy1), (sx2, sy2)], clip_screen):
                if len(seg) < 2:
                    continue
                a, b = seg[0], seg[-1]
                canvas.line(color, _pt(a), _pt(b), 3)
                mx, my = (a[0] + b[0]) / 2.0, (a[1] + b[1]) / 2.0
                rect = Rect(0, 0, 4, 4)
                rect.center = _pt((mx, my))
                canvas.rect(color, rect)

    # -- (6) entities -------------------------------------------------------

    def _role_kind(self, eid: int):
        s = self.session
        if eid == s.pid:
            return "player", None
        e = s.enemies.get(eid)
        if e is not None:
            return "enemy", e["kind"]
        b = s.bullets.get(eid)
        if b is not None:
            return "bullet", b["kind"]
        p = s.pickups.get(eid)
        if p is not None:
            return "pickup", p["kind"]
        t = getattr(s, "sentries", {}).get(eid)
        if t is not None:
            # emplacements were resolving to None here — they shot, killed
            # and blocked, but never drew a single pixel (2026-07-20)
            return "sentry", t["kind"]
        return None, None

    def _draw_entities(self, canvas, ents, clip_screen):
        # NOTE: every call site passes clip_screen=None -- entities always
        # draw WHOLE here; the union coverage mask (BLEND_RGBA_MIN on the
        # entity layer, see _draw_world_pygame/_draw_world_rust) is what
        # actually cuts them at the visible-world boundary, not anything in
        # this function.
        for eid, sx, sy, dirx, diry, srad, fully_inside in ents:
            role, kind = self._role_kind(eid)
            if role is None:
                continue
            ang = math.atan2(diry, dirx) if (dirx or diry) else 0.0
            if role == "player":
                # what the body is hauling reads ON the body (director
                # 2026-07-23: the HUD no longer says "carrying a pod"). Drawn
                # first so the chassis sits on top of its load.
                self._draw_carried(canvas, sx, sy, ang, max(srad, 2.0))
                pts = _xform_pts(PLAYER_SHAPE, sx, sy, max(srad, 7.0), ang)
                if clip_screen is not None and not fully_inside:
                    pts = necore.clip_polygon(pts, clip_screen)
                    if len(pts) < 3:
                        continue
                grace = getattr(self.session, "revival_grace", 0)
                if grace > 0 and (grace // 8) % 2 == 0:
                    # the rite of return: the untouchable fresh frame
                    # pulses solid white ON THE BODY (body events on the
                    # body; rings stay aggro-only)
                    canvas.polygon((255, 255, 255), _pts(pts))
                else:
                    canvas.polygon(PLAYER_COLOR, _pts(pts))
                brand = getattr(self.session, "brand", None)
                marked = brand is not None and brand.active
                # THE MARK is a body event and it owns this colour: the
                # player's own outline goes magenta while the tag holds.
                # Nothing else in the game outlines the player, so there
                # is no symbol to collide with, and it reads at 0.45 from
                # across the chamber where a small glob does not.
                canvas.polygon((255, 90, 220) if marked else (255, 255, 255),
                               _pts(pts), 2 if marked else 1)
                if marked:
                    self._draw_brand(canvas, sx, sy, max(srad, 2.0))
                if getattr(self.session, "snare_t", 0) > 0:
                    self._draw_snared(canvas, sx, sy, max(srad, 2.0))
                rt = getattr(self.session, "recall_t", 0)
                if rt > 0:
                    # recall channel: a ring closing on the frame
                    frac = rt / 90.0
                    canvas.circle((160, 240, 200), _pt((sx, sy)),
                                  max(3, int(9 + 26 * frac)), 1)
            elif role == "enemy":
                self._draw_enemy(canvas, eid, kind, sx, sy, ang, srad, clip_screen, fully_inside)
                self._draw_scan_pips(canvas, eid, sx, sy, srad, clip_screen)
            elif role == "bullet":
                self._draw_bullet(canvas, kind, sx, sy, dirx, diry, clip_screen)
            elif role == "pickup":
                self._draw_pickup(canvas, eid, kind, sx, sy, srad, clip_screen)
            elif role == "sentry":
                self._draw_sentry(canvas, eid, sx, sy, ang, clip_screen)

    def _draw_carried(self, canvas, sx, sy, ang, srad):
        """The load on the body's back. A hauled revival POD reads as a
        mini-CUCULUS sac (the teal factory palette, a breathing core) slung
        opposite the facing; repair/sentry kits read as small crates behind
        it. Multiple pods stack further back and drag it down — which is
        exactly what POD_CARRY_SLOW does to the handling."""
        carried = getattr(self.session, "carried", None)
        if not carried:
            return
        pods = [k for k in carried if k == "pod"]
        kits = [k for k in carried if k != "pod"]
        bx, by = -math.cos(ang), -math.sin(ang)          # straight back
        phase = (self.session.tick_count % 120) / 120.0
        glow = 0.5 + 0.5 * math.sin(phase * 2 * math.pi)
        d = srad * 1.15                                  # first slot's gap
        # a strap from the chassis to the first thing on the rack
        if pods or kits:
            canvas.line((150, 200, 175),
                        _pt((sx + bx * srad * 0.5, sy + by * srad * 0.5)),
                        _pt((sx + bx * d, sy + by * d)), 1)
        pr = max(2, int(round(srad * 0.95)))
        # an OCTAGON body (the CUCULUS silhouette) transformed by the body's
        # facing, so the load turns WITH the chassis -- it reads as a thing
        # strapped to his back, not a sprite trailing him (director 2026-07-24)
        _oct = [(math.cos(i * math.pi / 4.0), math.sin(i * math.pi / 4.0))
                for i in range(8)]
        for _ in pods:
            cx, cy = sx + bx * d, sy + by * d
            body = _xform_pts(_oct, cx, cy, pr, ang)
            canvas.polygon((26, 42, 36), body)                      # sac body
            canvas.polygon((150, 240, 185), body, 1)                # rim
            core = (int(120 + 120 * glow), int(230 + 25 * glow),
                    int(170 + 60 * glow))
            canvas.circle(core, _pt((cx, cy)), max(1, pr // 3))
            d += pr * 1.7
        kr = max(2, int(round(srad * 0.7)))
        _sq = [(1.0, 1.0), (-1.0, 1.0), (-1.0, -1.0), (1.0, -1.0)]
        for _ in kits:
            cx, cy = sx + bx * d, sy + by * d
            crate = _xform_pts(_sq, cx, cy, kr, ang)   # crate turns with the body
            canvas.polygon((48, 48, 54), crate)
            canvas.polygon((150, 160, 170), crate, 1)
            d += kr * 2.1

    def _draw_sentry(self, canvas, eid, sx, sy, ang, clip_screen):
        """A re-sworn guardian on its tripod. Drawn at FIXED pixel size,
        like the revival pod: an emplacement you paid salvage for has to
        read at the shipped 0.45 zoom, not shrink to three dark pixels."""
        if clip_screen is not None and not _point_in_poly(sx, sy, clip_screen):
            return
        t = self.session.sentries.get(eid)
        if t is None:
            return
        ix, iy = _pt((sx, sy))
        # the turret ROTATES to face its target (sim slews t["face"]); the
        # legs stay put, only the head/barrel turn (director 2026-07-23)
        ang = t.get("face", ang)
        tick = self.session.tick_count
        unpacking = tick < t.get("ready_at", 0)
        # AMBER, not blue: at gameplay scale a blue-outlined triangle was
        # indistinguishable from a teal Adversary, so reviewers could not
        # tell a player's gun from the thing attacking it. The gun wears
        # the colour of its own tracers. Built as a real emplacement —
        # three splayed legs, a drum, a turret head and a muzzle — rather
        # than a triangle (director 2026-07-21).
        for leg in (-1.0, 0.0, 1.0):
            la = ang + math.pi + leg * 0.85
            canvas.line((150, 116, 58),
                        (ix, iy + 2),
                        (int(ix + math.cos(la) * 11),
                         int(iy + math.sin(la) * 11)), 2)
        # ammo drum, offset behind the head
        dx = int(ix - math.cos(ang) * 5)
        dy = int(iy - math.sin(ang) * 5)
        canvas.circle((78, 60, 28), (dx, dy), 5)
        canvas.circle((205, 160, 78), (dx, dy), 5, 1)
        # turret head
        head = [(ix, iy - 7), (ix - 7, iy + 3), (ix + 7, iy + 3)]
        canvas.polygon((92, 70, 34), head)
        canvas.polygon((255, 214, 130), head, 1)
        # barrel with a muzzle collar, pointing where it last tracked
        bx = int(ix + math.cos(ang) * 15)
        by = int(iy + math.sin(ang) * 15)
        canvas.line((255, 236, 180), (ix, iy - 1), (bx, by), 2)
        canvas.circle((255, 245, 205), (bx, by), 2, 1)
        # MUZZLE FLASH + FLARE at the barrel: bright for the first ~4 ticks
        # after a shot (director 2026-07-23). The room-lighting flare is a
        # real pulse light from the sim; this is the sprite core.
        since = tick - t.get("fire_tick", -999)
        if 0 <= since < 4:
            fl = 1.0 - since / 4.0
            fx_ = int(ix + math.cos(ang) * 17)
            fy_ = int(iy + math.sin(ang) * 17)
            canvas.circle((255, 240, 200), (fx_, fy_), max(2, int(2 + 4 * fl)))
            canvas.circle((255, 255, 235), (fx_, fy_), max(1, int(1 + 2 * fl)))
            # a short flare streak down the bore
            canvas.line((255, 236, 190), (bx, by),
                        (int(ix + math.cos(ang) * (22 + 6 * fl)),
                         int(iy + math.sin(ang) * (22 + 6 * fl))), 1)
        # UNPACKING: a folding ring closes over the first 30s — the gun is
        # visibly not yet online (and is inert + fragile until it is)
        if unpacking:
            rem = (t["ready_at"] - tick) / float(BUILDING_UNPACK_TICKS)
            canvas.circle((150, 130, 90), (ix, iy),
                          max(4, int(6 + 8 * rem)), 1)
        # DRY: a stranded, spent gun (no pod within supply range) reads
        # cold — an empty drum ring
        elif t.get("ammo", 1) <= 0 and not t.get("supplied", True):
            canvas.circle((90, 70, 40), (dx, dy), 6, 1)
        # damage tell: the frame browns out as the Adversary tears at it
        full = float(SENTRY_SPECS.get(t["kind"], {}).get("hp", 45.0))
        frac = max(0.0, min(1.0, t.get("hp", full) / full))
        if frac < 1.0:
            canvas.rect((40, 20, 18), Rect(ix - 8, iy + 9, 16, 2))
            canvas.rect((225, 110, 80),
                        Rect(ix - 8, iy + 9, int(16 * frac), 2))

    def _draw_scan_pips(self, canvas, eid, sx, sy, srad, clip_screen):
        """Mind map: a deep-scan node renders wounded enemies' integrity as
        a thin pip bar (the surveyors' instruments, running in his head)."""
        u = getattr(self.session, "mind_unlocks", ())
        if "deep_scan_1" not in u and "deep_scan_2" not in u:
            return
        e = self.session.enemies.get(eid)
        if e is None:
            return
        full = SIM_ENEMIES[e["kind"]]["hp"] * self.session._hp_mul
        frac = max(0.0, min(1.0, e["hp"] / full))
        if frac >= 1.0:
            return
        if clip_screen is not None and not _point_in_poly(sx, sy, clip_screen):
            return
        wbar = max(6, int(srad * 1.6))
        x0, y0 = int(sx - wbar // 2), int(sy - srad - 5)
        canvas.rect((22, 26, 30), Rect(x0, y0, wbar, 2))
        canvas.rect((120, 220, 235),
                    Rect(x0, y0, max(1, int(wbar * frac)), 2))

    def _draw_adversary(self, canvas, eid, kind, sx, sy, ang, srad,
                        clip_screen, fully_inside, flashed):
        """The Adversary's sensor trace. Not a body with an outline — a
        return the instrument cannot resolve into an object.

        The first cut drew a stable silhouette with three arcs orbiting it,
        which the director read exactly as it looked: "little satellites
        that spin in a circle" (2026-07-21). Formless horror under other
        physical laws does not orbit. So:

        * the contour NEVER CLOSES. It is drawn as arcs with gaps, and the
          gaps move, so the eye can't seal it into a shape.
        * it is drawn at SEVERAL RADII AT ONCE, each turning at its own
          rate and each solved separately — one object occupying several
          depths, which is what a projection of something with an extra
          dimension looks like from inside three of them.
        * TENDRILS grow and retract from the contour, some crossing the
          interior, so the boundary is not where the thing ends.
        * the interior is darker than the floor and carries chords that
          connect points the outline does not — inside is not enclosed.
        """
        col = ADVERSARY_TRACE[kind]
        # ONE OF THE FINITE ONES IS BACK. It has to be mixed HERE: this
        # path ignores the fill/rim _draw_enemy computes, so the arrival
        # tint (and, it turns out, _attacker_flash) were dead code for
        # lacuna and vagrant — gate 63 proved it with a doused-slot A/B
        # showing zero changed pixels at every blink phase. Every shell,
        # tendril and chord below derives from `col`, so mixing once
        # here flares the whole trace. Spring green: red is "this one
        # hurt you", white is a hit, and it is the complement of the
        # lacuna's own purple trace (185,140,255), the arrival that
        # filmed weakest.
        rf = self._arrival_flash.get(eid, 0)
        if rf > 0 and (rf // 3) % 2 == 0:
            col = _mix(col, (120, 255, 160), 0.85)
        if flashed:
            col = (255, 255, 255)
        if clip_screen is not None and not fully_inside \
                and not _point_in_poly(sx, sy, clip_screen):
            return
        tick = self.session.tick_count
        shape = ENEMY_SHAPE.get(kind, _CIRCLE_SHAPE)
        # A vagrant's body radius is 9.5u, which at the play zoom of 0.45 is
        # about eight pixels — every shell, tendril and chord below landed
        # inside a speck, so the thing read as one more small blob no matter
        # how much structure it had. The trace is not the body: what the
        # instrument fails to resolve is LARGER than what you can collide
        # with. Drawing wider is a render-only change, so the hitbox, the
        # balance and the recorded seeds are all untouched.
        r = max(srad * ADVERSARY_TRACE_SCALE, 7.0)
        h = (eid * 2654435761) % 997 / 997.0
        n = len(shape)

        # SECOND ITERATION (director 2026-07-22: "they just look like a
        # scribble — iterate more"). The scribble came from three shells,
        # three tendrils and two chords ALL drawn as 1px lines of similar
        # brightness: plenty of motion, no hierarchy, nothing for the eye
        # to hold. This pass builds a hierarchy — mass, then a single
        # dominant edge, then accents — while keeping every constraint
        # (contour never closes, no orbiting parts, no vertex ever still).

        # 1) MASS AS ABSENCE: a near-black core, slowly boiling. The old
        #    hole was filled at 0.10 of the trace colour and vanished on
        #    dark floors, leaving only linework. Against the lit floor
        #    the core reads as a BITE out of the world — the instrument
        #    returning nothing at all from the middle of the thing.
        core = _boil(_xform_pts(shape, sx, sy, r * 0.86, ang), tick // 2,
                     eid, max(0.8, r * 0.08))
        if len(core) >= 3:
            canvas.polygon((7, 9, 12), _pts(core))

        # 2) ONE dominant contour: full-brightness, 2px, a single gap that
        #    crawls segment-to-segment. The body SWAYS (bounded sine, a
        #    breathing rock) rather than spinning — rotation is what read
        #    as "little satellites" in the first cut.
        a1 = ang + math.sin(tick * 0.013 + h * 6.283) * 0.35
        rim = _boil(_xform_pts(shape, sx, sy, r * 1.02, a1), tick,
                    eid * 3, max(0.7, r * 0.10))
        gap = (tick // 6 + int(h * n)) % n
        for i in range(n):
            if i == gap:
                continue
            canvas.line(col, _pt(rim[i]), _pt(rim[(i + 1) % n]), 2)

        # 3) a faint counter-shell inside, swaying the other way: depth
        #    without clutter, and its own two moving gaps
        a2 = ang - math.sin(tick * 0.017 + h * 2.0) * 0.5
        inner = _boil(_xform_pts(shape, sx, sy, r * 0.58, a2), tick + 41,
                      eid * 5, max(0.6, r * 0.12))
        shade = _scale_color(col, 0.42)
        skip = (tick // 4 + int(h * 5)) % n
        for i in range(n):
            if i == skip or i == (skip + n // 2) % n:
                continue
            canvas.line(shade, _pt(inner[i]), _pt(inner[(i + 1) % n]), 1)

        # 4) TWO tendrils that reach with intent — long, slow grow/retract,
        #    a whip in the middle — instead of three jittering hairs
        anchor = _xform_pts(shape, sx, sy, r, a1)
        for k in range(2):
            phase = tick * 0.03 + k * 3.1 + h * 6.283
            grow = 0.5 + 0.5 * math.sin(phase)
            i = (int(tick * 0.02) + k * (n // 2)) % n
            bx, by = anchor[i]
            ex = sx + (bx - sx) * (1.0 + 2.2 * grow)
            ey = sy + (by - sy) * (1.0 + 2.2 * grow)
            mx = sx + (bx - sx) * (0.7 + 1.0 * grow)                 + math.cos(phase * 1.9) * r * 0.35
            my = sy + (by - sy) * (0.7 + 1.0 * grow)                 + math.sin(phase * 1.4) * r * 0.35
            faint = _scale_color(col, 0.45 + 0.5 * grow)
            canvas.line(faint, _pt((bx, by)), _pt((mx, my)), 1)
            canvas.line(faint, _pt((mx, my)), _pt((ex, ey)), 1)

        # 5) interior GLINTS that blink — brief bright sparks deep in the
        #    core, mostly dark — instead of two chords always on
        for k in range(2):
            if (tick // 7 + k * 5 + eid) % 3:
                continue
            gi = (int(h * n) + k * 3 + tick // 11) % n
            ax_, ay_ = _xform_pts(shape, sx, sy, r * 0.34, a2)[gi]
            bx_, by_ = _xform_pts(shape, sx, sy, r * 0.5, a2)[(gi + 1) % n]
            canvas.line(_brighten(col, 60), _pt((ax_, ay_)), _pt((bx_, by_)), 1)

    def _draw_caller_tell(self, canvas, sx, sy, srad, call_t):
        """A caller mid-transmit: violet 'signal' rings ping outward from it,
        quicker and brighter as the call nears completion, plus a swelling
        core -- so the transmit is legible from across the room and the
        player can go silence it. Violet, distinct from the player's teal
        structures and the amber sentries."""
        # No caller tell at all (director 2026-07-24: "the swelling core is
        # wrong too -- just the breach itself is plenty"). The transmitting unit
        # renders like any other; the breach opening is the whole tell.
        return


    def _draw_core_part(self, canvas, eid, kind, sx, sy, srad, flashed):
        """The CORE's organ parts (DESIGN_7_25 §1b): one violet family —
        sessile, radially calm, grown rather than mustered — with each
        part's job legible in its silhouette. The Source keeps the old
        hub-heart's beating language (obviously the thing to destroy);
        the Collar is a clamped valve, the Anchor is braced into the
        deck, the Bud a budding nodule, the Caretaker pale and soft,
        the Scriptorium inscribed. All pulse phases are keyed to eid so
        the organ never beats in lockstep."""
        ix, iy = _pt((sx, sy))
        tick = self.session.tick_count
        beat = 0.5 + 0.5 * math.sin(tick * 0.11 + (eid % 97) * 0.31)
        r = max(4, int(srad))
        body = (255, 255, 255) if flashed else (42, 12, 54)
        membrane = (208, 82, 238)
        if kind == "core_source":
            canvas.circle(body, (ix, iy), r)
            canvas.circle(membrane, (ix, iy), r, 1)
            canvas.circle((160, 55, 200), (ix, iy), max(2, r - 2), 1)
            for k in range(8):                             # radiating veins
                a = k * (math.pi / 4.0) + tick * 0.01
                r2 = r + 4 + int(6 * beat)
                canvas.line((150, 55, 190),
                            (ix + int(math.cos(a) * r),
                             iy + int(math.sin(a) * r)),
                            (ix + int(math.cos(a) * r2),
                             iy + int(math.sin(a) * r2)), 1)
            hot = max(2, int(r * (0.32 + 0.26 * beat)))    # the beating heart
            canvas.circle((min(255, int(205 + 50 * beat)),
                           min(255, int(120 + 90 * beat)), 245),
                          (ix, iy), hot)
        elif kind == "core_collar":
            canvas.circle(body, (ix, iy), r)
            canvas.circle(membrane, (ix, iy), r, 1)
            # the valve: a bright inner ring pinched by four clamp ticks
            canvas.circle((226, 96, 150), (ix, iy), max(2, int(r * 0.62)), 1)
            for k in range(4):
                a = k * (math.pi / 2.0) + 0.785
                x0 = ix + int(math.cos(a) * r * 0.62)
                y0 = iy + int(math.sin(a) * r * 0.62)
                canvas.line((226, 96, 150), (x0, y0),
                            (ix + int(math.cos(a) * (r + 2)),
                             iy + int(math.sin(a) * (r + 2))), 1)
            canvas.circle((30, 8, 40), (ix, iy), max(1, int(r * 0.3)))
        elif kind == "core_anchor":
            # braced into the deck: a low dark block with taut guy-lines
            pts = _xform_pts([(1.0, 0.0), (0.35, 0.9), (-1.0, 0.55),
                              (-1.0, -0.55), (0.35, -0.9)], sx, sy, r, 0.0)
            canvas.polygon((30, 10, 40) if not flashed else body, _pts(pts))
            canvas.polygon((160, 80, 200), _pts(pts), 1)
            for side in (-1, 1):
                canvas.line((120, 60, 150), (ix, iy),
                            (ix + side * int(r * 1.6),
                             iy + int(r * 1.1)), 1)
        elif kind == "core_bud":
            canvas.circle((60, 20, 72) if not flashed else body, (ix, iy), r)
            canvas.circle(membrane, (ix, iy), r, 1)
            # the growing nucleus swells with its own slow phase
            canvas.circle((208, 82, 238), (ix - r // 3, iy - r // 3),
                          max(1, int(r * (0.3 + 0.2 * beat))))
        elif kind == "core_caretaker":
            canvas.circle((150, 120, 160) if not flashed else body,
                          (ix, iy), r)
            canvas.circle((230, 200, 240), (ix, iy), r, 1)
            # the suture mark
            canvas.line((230, 200, 240), (ix - r // 2, iy),
                        (ix + r // 2, iy), 1)
            canvas.line((230, 200, 240), (ix, iy - r // 2),
                        (ix, iy + r // 2), 1)
        else:  # core_scriptorium
            canvas.circle((48, 16, 58) if not flashed else body, (ix, iy), r)
            canvas.circle(membrane, (ix, iy), r, 1)
            canvas.circle((235, 225, 150), (ix, iy), max(2, int(r * 0.55)), 1)
            for k in range(6):                    # the script: radial ticks
                a = k * (math.pi / 3.0) + tick * 0.004
                canvas.line((235, 225, 150),
                            (ix + int(math.cos(a) * r * 0.55),
                             iy + int(math.sin(a) * r * 0.55)),
                            (ix + int(math.cos(a) * r * 0.8),
                             iy + int(math.sin(a) * r * 0.8)), 1)

    def _draw_enemy(self, canvas, eid, kind, sx, sy, ang, srad, clip_screen, fully_inside):
        srad = max(srad, ENEMY_MIN_PX.get(kind, 5.0))
        flashed = self._hitflash.get(eid, 0) > 0
        fill = ENEMY_COLOR.get(kind, (150, 150, 150))
        rim = ENEMY_RIM.get(kind) or _brighten(fill, 70)
        # Sensor-trace intensity channel (director's directive, 2026-07-13):
        # while a flicker is DORMANT (LURK, not yet committed) its own
        # sim-side AI state drives a dim/intermittent return instead of the
        # normal full-strength trace -- diegetically "low emission while
        # hiding," never fully invisible (the AI clamps this to a 0.12
        # floor, see `GameSession._flicker_dormant_trace`). Matches the
        # existing entity render style: this only scales the SAME fill/rim
        # colors every other kind already uses, no new draw path, and
        # composites post-lightmap-multiply like every entity does.
        e = self.session.enemies.get(eid)
        intensity = e.get("trace_intensity", 1.0) if e else 1.0
        # CALLER TELL (ADVERSARY_DESIGN): a unit transmitting a fix for the
        # hub reads from across the room -- expanding "signal" rings that
        # quicken and brighten as it nears completion (the window to stop it
        # is closing). Drawn under the body so the body stays legible on top.
        if e is not None and e.get("state") == "call":
            self._draw_caller_tell(canvas, sx, sy, srad,
                                   e.get("call_t", CALL_TRANSMIT_TICKS))
        if intensity < 0.999 and not flashed:
            fill = _scale_color(fill, intensity)
            rim = _scale_color(rim, intensity)
        elif intensity > 1.001 and not flashed:
            # above 1.0 the channel BRIGHTENS: the engulf charge tell —
            # the body itself flashes toward white, driven by the sim's
            # own wind-up state (never a free-running animation timer)
            t_ = min(1.0, intensity - 1.0)
            fill = _mix(fill, (255, 255, 255), t_)
            rim = _mix(rim, (255, 255, 255), t_)
        af = self._attacker_flash.get(eid, 0)
        if af > 0 and not flashed and (af // 2) % 2 == 0:
            # the just-hurt-you flash: a blinking red tint on the
            # attacker's own body — hue + blink chosen to survive the
            # breach-magenta wash that dissolved the plain white flash
            fill = _mix(fill, (255, 60, 45), 0.75)
            rim = _mix(rim, (255, 120, 90), 0.9)
        rf = self._arrival_flash.get(eid, 0)
        if rf > 0 and not flashed and (rf // 3) % 2 == 0:
            # ONE OF THE FINITE ONES IS BACK. On the body, not on the
            # room: an emissive tint keeps its hue through the lightmap
            # the way the attacker flash does. Spring green is unclaimed
            # -- red is "this one hurt you", white is a hit, and it is
            # the complement of the lacuna's purple body (62,48,92),
            # which is the arrival that filmed weakest.
            fill = _mix(fill, (120, 255, 160), 0.85)
            rim = _mix(rim, (205, 255, 220), 0.95)
        if flashed:
            fill = rim = (255, 255, 255)
        if kind.startswith("core_"):
            self._draw_core_part(canvas, eid, kind, sx, sy, srad, flashed)
            return
        gripping = (kind == "warden" and self.session.captures.held_by(
            self.session.pid) == eid)
        if gripping:
            # the swallow must read as A WARDEN eating you: the dark
            # 9-gon silhouette survives every overlay (run 37 ledger:
            # whiten + white rings + white hit-flash dissolved it into
            # 'HP drains in red haze'). No whiten, no full-white flash
            # during the grip, and NO rings (rings mean aggro, nothing
            # else — run 46 blocker: this branch also overwrote the red
            # attacker-blink, making attribution dead code in exactly
            # the deadliest case it exists for). The RIM is the signal
            # channel: it blinks red while the grip grinds you (the
            # attacker flash, kept from above) and flashes white the
            # frame your shot lands; the dark body never changes.
            fill = ENEMY_COLOR["warden"]
            rim = ENEMY_RIM["warden"]
            if flashed:
                rim = (255, 255, 255)
            elif af > 0 and (af // 2) % 2 == 0:
                rim = (255, 70, 50)
            flashed = False
        if kind == "mite":
            if clip_screen is not None and not fully_inside \
                    and not _point_in_poly(sx, sy, clip_screen):
                return
            r = max(1, int(round(srad * 0.85)))
            canvas.circle(fill, _pt((sx, sy)), r)
            canvas.circle(rim, _pt((sx, sy)), r, 1)
            return
        if kind in ADVERSARY_TRACE:
            self._draw_adversary(canvas, eid, kind, sx, sy, ang, srad,
                                 clip_screen, fully_inside, flashed)
            return
        shape = ENEMY_SHAPE.get(kind, _CIRCLE_SHAPE)
        pts = _xform_pts(shape, sx, sy, max(srad, 2.0), ang)
        if clip_screen is not None and not fully_inside:
            pts = necore.clip_polygon(pts, clip_screen)
            if len(pts) < 3:
                return
        canvas.polygon(fill, _pts(pts))
        if not flashed:
            # two-tone body: a shadow core trailing the facing plus a lit
            # brow toward it — volume instead of a flat cutout
            r = max(srad, 2.0)
            bx = sx - math.cos(ang) * r * 0.22
            by = sy - math.sin(ang) * r * 0.22
            body = _xform_pts(shape, bx, by, r * 0.62, ang)
            if clip_screen is not None and not fully_inside:
                body = necore.clip_polygon(body, clip_screen)
            if len(body) >= 3:
                canvas.polygon(_scale_color(fill, 0.72), _pts(body))
            hx = sx + math.cos(ang) * r * 0.42
            hy = sy + math.sin(ang) * r * 0.42
            if clip_screen is None or fully_inside or _point_in_poly(hx, hy, clip_screen):
                if kind == "spitter":
                    canvas.circle((140, 205, 60), _pt((hx, hy)),
                                  max(1, int(r * 0.24)))
                elif kind != "shrieker":
                    canvas.circle(_brighten(fill, 36), _pt((hx, hy)),
                                  max(1, int(r * 0.26)))
            if kind == "brute":
                for side in (-1, 1):
                    ta = ang + side * 0.55
                    x0 = sx + math.cos(ta) * r * 0.7
                    y0 = sy + math.sin(ta) * r * 0.7
                    x1 = sx + math.cos(ta) * r * 1.15
                    y1 = sy + math.sin(ta) * r * 1.15
                    if clip_screen is None or fully_inside or (
                            _point_in_poly(x0, y0, clip_screen)
                            and _point_in_poly(x1, y1, clip_screen)):
                        canvas.line((228, 210, 190),
                                    _pt((x0, y0)), _pt((x1, y1)), 2)
            elif kind == "warden":
                if clip_screen is None or fully_inside or _point_in_poly(sx, sy, clip_screen):
                    canvas.circle((140, 110, 170), _pt((sx, sy)),
                                  max(2, int(r * 0.5)), 1)
        canvas.polygon(rim, _pts(pts), ENEMY_RIM_W.get(kind, 1))
        if kind == "husk" and not flashed:
            canvas.circle((66, 78, 62), _pt((sx, sy)), max(1, int(srad * 0.22)))

    def _draw_brand(self, canvas, sx, sy, srad):
        """The MARK: a wobbling magenta glob stuck to the player's body,
        dribbling a trail down his travel — the scent tag's instantly
        obvious visual (director's standing requirement for U10)."""
        s = self.session
        tick = s.tick_count
        try:
            _, _, _, vx, vy, _, _ = s.sim.get(s.pid)
        except Exception:
            vx = vy = 0.0
        vmag = math.hypot(vx, vy)
        # the glob rides the body, offset toward his back (opposite travel)
        ox, oy = (-vx / vmag, -vy / vmag) if vmag > 6.0 else (0.0, -1.0)
        gx, gy = sx + ox * srad * 0.6, sy + oy * srad * 0.6
        # the trail dribbles FROM the glob down his travel
        if vmag > 6.0:
            ux, uy = vx / vmag, vy / vmag
            for i in range(1, 7):
                fx, fy = gx - ux * i * 4.0, gy - uy * i * 4.0
                canvas.circle((235, 70, 185), _pt((fx, fy)),
                              max(1, 3 - i // 3))
        # sized to READ, not to decorate: at 0.45 zoom the body is ~9px
        # and a 0.7-radius glob changed 8 pixels, which is not the
        # "instantly obvious" the mark was ordered to be. It sits at
        # body scale, wobbling, with a bright core.
        wob = 1.0 + 0.18 * math.sin(tick * 0.4)
        gr = max(3, int(srad * 1.05 * wob))
        canvas.circle((255, 80, 210), _pt((gx, gy)), gr)
        canvas.circle((255, 170, 235), _pt((gx, gy)), max(1, gr - 2))
        canvas.circle((255, 232, 250), _pt((gx, gy)), max(1, gr // 3))

    def _draw_snared(self, canvas, sx, sy, srad):
        """The snare, drawn ON THE PLAYER — cause, duration and release
        all visible where the effect is felt.

        Gate 67 blocked the first cut for painting nothing at all: the
        player steered like mud for 75-90 ticks with no indication of
        onset, persistence or release. Same law the brand and the
        pod-carry slow already obey. Filaments pinned to the body, and
        they THIN as the hold runs out, so the release is legible before
        it happens rather than being noticed afterwards."""
        s = self.session
        left = max(0, getattr(s, "snare_t", 0))
        k = min(1.0, left / 90.0)
        n = 6
        base = s.tick_count * 0.06
        for i in range(n):
            a = base + i * (2.0 * math.pi / n)
            r0 = srad * 0.9
            r1 = srad * (1.7 + 0.5 * k)
            x0, y0 = sx + math.cos(a) * r0, sy + math.sin(a) * r0
            x1, y1 = sx + math.cos(a) * r1, sy + math.sin(a) * r1
            canvas.line((205, 190, 240), _pt((x0, y0)), _pt((x1, y1)),
                        2 if k > 0.4 else 1)
        canvas.circle((235, 225, 255), _pt((sx, sy)),
                      max(2, int(srad * 0.5)), 1)

    def _draw_bullet(self, canvas, kind, sx, sy, dirx, diry, clip_screen):
        if clip_screen is not None and not _point_in_poly(sx, sy, clip_screen):
            return
        if kind == "marker":
            # a shrieker's tag round: a vivid magenta mote with a streak
            # so its flight is unmistakable
            color = (255, 90, 220)
            tx, ty = sx - dirx * 11, sy - diry * 11
            canvas.line(color, _pt((sx, sy)), _pt((tx, ty)), 2)
            canvas.circle(color, _pt((sx, sy)), 3)
            canvas.circle((255, 215, 245), _pt((sx, sy)), 1)
        elif kind == "spit":
            # a glob STREAKS: the tail multiplies its on-frame presence
            # so ranged pressure is visible in flight, not only on the
            # hit (three-seed gate: 'invisible spitter hits' confirmed)
            tx_, ty_ = sx - dirx * 14, sy - diry * 14
            canvas.line((90, 140, 40), _pt((tx_, ty_)), _pt((sx, sy)), 2)
            canvas.circle((140, 205, 60), _pt((sx, sy)), 3)
            canvas.circle((220, 255, 140), _pt((sx, sy)), 1)
        elif kind == "dart":
            color = (120, 240, 255)
            base_ang = math.atan2(diry, dirx) if (dirx or diry) else 0.0
            for a in range(4):
                ang = base_ang + a * math.pi / 2.0
                ex, ey = sx + math.cos(ang) * 4, sy + math.sin(ang) * 4
                canvas.line(color, _pt((sx, sy)), _pt((ex, ey)), 1)
            canvas.circle(color, _pt((sx, sy)), 2)
        elif kind == "turret":
            # a structure's round, in the player-structure teal — the
            # scoreboard question "who killed that?" must be answerable
            # from the tracer alone (run 46: turret bolts were pixel-
            # identical to the player's own fire)
            color = (150, 240, 205)
            tx, ty = sx - dirx * 10, sy - diry * 10
            canvas.line(color, _pt((sx, sy)), _pt((tx, ty)), 1)
            canvas.circle(color, _pt((sx, sy)), 2)
        elif kind == "shove":
            # the Adversary's close tool. Run 46's law: an enemy round
            # must never be pixel-identical to the player's own fire.
            # Blunt and hot, with a THICK short streak — it reads as
            # mass arriving, which is what it delivers.
            tx_, ty_ = sx - dirx * 9, sy - diry * 9
            canvas.line((255, 120, 50), _pt((tx_, ty_)), _pt((sx, sy)), 3)
            canvas.circle((255, 90, 30), _pt((sx, sy)), 4)
            canvas.circle((255, 210, 160), _pt((sx, sy)), 2)
        elif kind == "snare":
            # ...and the mid tool, which must not read as the shove:
            # one damages, one slows. SHAPE carries it — a long dotted
            # filament instead of every other round's solid streak — so
            # the two stay apart even where the palette crowds.
            col = (205, 190, 240)
            for i in range(5):
                fx_, fy_ = sx - dirx * (5 + i * 6), sy - diry * (5 + i * 6)
                canvas.circle(col, _pt((fx_, fy_)), max(1, 2 - i // 2))
            canvas.circle((235, 225, 255), _pt((sx, sy)), 3)
            canvas.circle(col, _pt((sx, sy)), 1)
        else:  # "bullet" / "tracer"
            color = (255, 245, 180)
            tx, ty = sx - dirx * 12, sy - diry * 12
            canvas.line(color, _pt((sx, sy)), _pt((tx, ty)), 1)
            canvas.circle(color, _pt((sx, sy)), 2)

    def _draw_pickup(self, canvas, eid, kind, sx, sy, srad, clip_screen):
        if clip_screen is not None and not _point_in_poly(sx, sy, clip_screen):
            return
        r = max(2.5, srad)
        ix, iy = _pt((sx, sy))
        if kind == "ammo_9mm":
            rect = Rect(0, 0, int(r * 1.6), int(r * 1.2))
            rect.center = (ix, iy)
            canvas.rect((200, 150, 40), rect)
        elif kind == "ammo_shell":
            rect = Rect(0, 0, int(r * 1.6), int(r * 1.2))
            rect.center = (ix, iy)
            canvas.rect((180, 60, 50), rect)
        elif kind == "ammo_cell":
            canvas.circle((60, 200, 220), (ix, iy), max(2, int(r * 0.8)))
            canvas.circle((200, 250, 255), (ix, iy), max(2, int(r * 0.8)), 1)
        elif kind == "medkit":
            rect = Rect(0, 0, int(r * 1.8), int(r * 1.8))
            rect.center = (ix, iy)
            canvas.rect((40, 40, 44), rect)
            canvas.line((235, 235, 235),
                        (ix - int(r * 0.6), iy), (ix + int(r * 0.6), iy), 2)
            canvas.line((235, 235, 235),
                        (ix, iy - int(r * 0.6)), (ix, iy + int(r * 0.6)), 2)
        elif kind == "turret":
            # a re-sworn guardian: squat tripod, thin bright rim
            pts = [(ix, iy - int(r)), (ix - int(r * 0.9), iy + int(r * 0.7)),
                   (ix + int(r * 0.9), iy + int(r * 0.7))]
            canvas.polygon((46, 58, 66), pts)
            canvas.polygon((150, 220, 235), pts, 1)
            canvas.circle((150, 220, 235), (ix, iy), 2)
        elif kind == "safe_polygon_core":
            canvas.circle((30, 26, 44), (ix, iy), max(3, int(r)))
            canvas.circle((170, 140, 255), (ix, iy), max(3, int(r)), 1)
            canvas.circle((220, 205, 255), (ix, iy), 1)
        elif kind.startswith("weapon_"):
            canvas.rect((190, 195, 200),
                        Rect(ix - int(r), iy - 1, int(r * 2), 2))
            canvas.rect((190, 195, 200),
                        Rect(ix - int(r * 0.3), iy - int(r * 0.7),
                                    max(1, int(r * 0.4)), int(r * 0.7)))
        elif kind == "components":
            # salvaged mass: a small scatter of scrap facets
            canvas.polygon((150, 130, 90),
                           [(ix - 3, iy + 2), (ix, iy - 3), (ix + 3, iy + 1)])
            canvas.rect((110, 100, 80),
                        Rect(ix - 1, iy + 1, 3, 2))
            canvas.polygon((190, 170, 120),
                           [(ix - 3, iy + 2), (ix, iy - 3), (ix + 3, iy + 1)], 1)
        elif kind == "corpse_frame":
            # a wrecked frame, prone; the faint pulse marks it recoverable
            canvas.rect((40, 44, 50), Rect(ix - int(r), iy - 3,
                                                  int(r * 2), 6))
            canvas.circle((40, 44, 50), (ix + int(r), iy), 3)
            phase = (self.session.tick_count % 90) / 90.0
            a = 0.5 + 0.5 * math.sin(phase * 2 * math.pi)
            rim = (int(90 + 90 * a), int(160 + 60 * a), int(120 + 60 * a))
            canvas.rect(rim, Rect(ix - int(r), iy - 3, int(r * 2), 6), 1)
        elif kind == "dropped_pod":
            # the seed obelisk, undeployed and lying on its side in its
            # carry crate — same green pod palette as the planted fixture
            crate = [(ix - int(r * 1.4), iy - int(r * 0.7)),
                     (ix + int(r * 1.4), iy - int(r * 0.7)),
                     (ix + int(r * 1.1), iy + int(r * 0.8)),
                     (ix - int(r * 1.1), iy + int(r * 0.8))]
            canvas.polygon((30, 46, 40), crate)
            canvas.polygon((150, 240, 185), crate, 1)
            for dx in (-int(r * 0.5), 0, int(r * 0.5)):
                canvas.line((90, 165, 130), (ix + dx, iy - int(r * 0.6)),
                            (ix + dx, iy + int(r * 0.7)), 1)
            phase = (self.session.tick_count % 120) / 120.0
            a = 0.5 + 0.5 * math.sin(phase * 2 * math.pi)
            canvas.circle((int(90 + 60 * a), int(200 + 40 * a),
                           int(150 + 40 * a)), (ix, iy), 2)
        elif kind == "dropped_repair":
            # the repair cabinet, folded down onto its skids
            crate = [(ix - int(r * 1.3), iy - int(r * 0.5)),
                     (ix + int(r * 1.3), iy - int(r * 0.5)),
                     (ix + int(r * 1.1), iy + int(r * 0.7)),
                     (ix - int(r * 1.1), iy + int(r * 0.7))]
            canvas.polygon((28, 34, 44), crate)
            canvas.polygon((120, 200, 235), crate, 1)
            canvas.line((150, 245, 220), (ix - int(r * 0.5), iy),
                        (ix + int(r * 0.5), iy), 1)
        elif kind == "dropped_sentry":
            # a gun folded onto its tripod, muzzle down
            pts = [(ix, iy + int(r * 0.8)), (ix - int(r), iy - int(r * 0.6)),
                   (ix + int(r), iy - int(r * 0.6))]
            canvas.polygon((72, 56, 28), pts)
            canvas.polygon((235, 190, 110), pts, 1)
            canvas.line((235, 190, 110), (ix, iy - int(r * 0.6)),
                        (ix, iy + int(r * 0.4)), 1)
        elif kind == "implant_lightning":
            pts = [(ix, iy - r), (ix + r, iy), (ix, iy + r), (ix - r, iy)]
            canvas.polygon((90, 220, 255), [(int(x), int(y)) for x, y in pts])
        elif kind.startswith("key_"):
            col = KEY_COLORS.get(kind[4:], DOOR_COLOR)
            meta = self.session.pickups.get(eid, {}).get("meta")
            item = getattr(meta, "item_name", None)
            if not draw_key_glyph(canvas, item, ix, iy, int(r * 0.9), col):
                canvas.circle(col, (ix - int(r * 0.3), iy), max(1, int(r * 0.5)), 1)
                canvas.line(col, (ix, iy), (ix + int(r), iy), 1)
                canvas.line(col, (ix + int(r * 0.6), iy),
                            (ix + int(r * 0.6), iy + int(r * 0.4)), 1)

    # -- (7) particles / effects pools --------------------------------------

    def _draw_effects(self, canvas, polygon, xform, clip_screen):
        if not (self._gibs or self._sparks or self._corpsefalls
                or self._bolts or self._screams or self._floaters):
            # nothing pooled: skip the per-instance scale hypot.
            # _floaters MUST be in this guard: without it, pickup text
            # rendered only while some other pool happened to be non-
            # empty — quiet out-of-combat pickups, the exact case the
            # legibility law targets, showed nothing (run 44 confirmed
            # blocker, causation proven by guard bypass)
            return
        scale = _xform_scale(xform)

        for cf in self._corpsefalls:
            if cf["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, cf["x"], cf["y"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            ddx, ddy = necore.mat_apply_dir(xform, math.cos(cf["ang"]),
                                            math.sin(cf["ang"]))
            sang = math.atan2(ddy, ddx) if (ddx or ddy) else 0.0
            k = cf["age"] / cf["maxage"]           # 0 = alive, 1 = corpse
            shape = ENEMY_SHAPE.get(cf["kind"]) or _CIRCLE_SHAPE
            base = ENEMY_COLOR.get(cf["kind"], (90, 90, 90))
            bright = 1.0 - 0.55 * k                # full color -> decal's 0.45
            col = tuple(int(c * bright) for c in base)
            s = max(1.0, cf["rad"] * scale)
            pts = _xform_pts(shape, sx, sy, s * (1.0 - 0.1 * k), sang,
                             squash=1.0 - 0.45 * k)
            canvas.polygon(col, _pts(pts))

        for g in self._gibs:
            if g["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, g["x"], g["y"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            r = max(1, int(g["size"] * scale * 0.5))
            canvas.circle(g.get("col", GIB_COLOR), _pt((sx, sy)), r)

        for sp in self._sparks:
            if sp["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, sp["x"], sp["y"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            ndx, ndy = necore.mat_apply_dir(xform, sp["nx"], sp["ny"])
            nl = math.hypot(ndx, ndy) or 1.0
            ex, ey = sx + ndx / nl * 5, sy + ndy / nl * 5
            canvas.line(SPARK_COLOR, _pt((sx, sy)), _pt((ex, ey)), 1)

        for b in self._bolts:
            if b["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, b["x"], b["y"])
            if b["life"] % 2 == 0:
                # the bright bolt CORE goes straight onto the entity layer, so
                # the darkness multiply never dims it (same footing as every
                # entity sprite); its glow feeds the lightmap below.
                for seg in b["segs"]:
                    spts = []
                    for dx, dy in seg:
                        wdx, wdy = necore.mat_apply_dir(xform, dx, dy)
                        spts.append((sx + wdx, sy + wdy))
                    for piece in necore.clip_polyline(spts, clip_screen):
                        if len(piece) >= 2:
                            canvas.lines(LIGHTNING_COLOR, False, _pts(piece), 1)
            self._deferred_bolt_glows.append(
                (sx, sy, b["radius"] * scale * 0.6, clip_screen))

        for sc in self._screams:
            if sc["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, sc["x"], sc["y"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            t = sc["age"] / sc["maxage"]
            col = sc.get("col", SCREAM_COLOR)
            for ring_off in (0, 6):
                rad = int((6 + ring_off) + t * 20)
                canvas.circle(col, _pt((sx, sy)), rad, 1)

        for fl in self._floaters:
            if fl["polygon"] != polygon:
                continue
            sx, sy = necore.mat_apply(xform, fl["x"], fl["y"])
            if not _point_in_poly(sx, sy, clip_screen):
                continue
            t = fl["age"] / fl["maxage"]
            # rises and fades; drawn OVER the lightmap pass via the
            # deferred queue so pickups read even in a dim room. Full
            # brightness holds through the first half of the rise —
            # an immediate fade left 0/4 seeds with legible pickups
            # on film (run 43, 18-27 pickups per session)
            self._deferred_floaters.append(
                (fl["text"], int(sx), int(sy - 10 - t * 22),
                 1.0 if t < 0.5 else max(0.25, 1.0 - (t - 0.5) * 1.5)))

    # -- (8) post -------------------------------------------------------

    def _draw_post(self, fb):
        session = self.session
        w, h, _ = fb.shape
        # breach opens are announced by the tear's own REAL light
        # surging (sim drives the attached LightSpec) — no full-frame
        # overlay: a flash with no source is noise, not information
        # (director, 2026-07-27)
        # pickup floaters: post-lightmap so the text reads in dim rooms
        placed_ = []
        for txt, sx, sy, alpha in sorted(self._deferred_floaters,
                                         key=lambda f_: f_[2]):
            # de-overlap on SCREEN: the 13u world-space stagger is ~6px
            # at 0.45 zoom, under the glyph height, so simultaneous
            # pickups overprinted at one spot (run 44 rider). Topmost
            # first; each collider is pushed above the one before it.
            for ox_, oy_ in placed_:
                if abs(sx - ox_) < 64 and abs(sy - oy_) < 18:
                    sy = oy_ - 18
            placed_.append((sx, sy))
            col = (int(200 * alpha + 55), int(230 * alpha + 25),
                   int(190 * alpha + 30))
            if 0 <= sx < w and 0 <= sy < h:
                # shadowed 16px: bare 12px pale-on-bright was pixel-
                # confirmed illegible at the shipped 0.45 zoom in every
                # run-43 seed — the shadow buys contrast on any wash
                x0 = max(2, sx - 4 * len(txt))
                y0 = max(2, sy)
                text.blit_text(fb, txt, x0 + 1, y0 + 1, (0, 0, 0), 16)
                text.blit_text(fb, txt, x0, y0, col, 16)
        # full-frame overlays run in the ENGINE (Raster.apply_post, over
        # the framebuf the floaters just drew into — same order as the
        # old numpy passes, which were 3-6 ms on exactly the low-hp
        # heavy-fight frames where p99 lives). Python only decides the
        # pass list.
        passes = []
        if session.hp < 35 and not session.dead:
            pulse = 0.55 + 0.45 * math.sin(session.tick_count * 0.25)
            # capped: at full saturation the vignette washed out the
            # warden/flicker shapes at exactly the chained-engulf moment
            # readability matters most (three-seed gate, confirmed P1).
            # The edge-falloff field keeps the center clear; the CAP
            # keeps the edges from swallowing the fight.
            a = max(0, min(255, int(95 * pulse)))
            passes.append((160, 8, 8, a, True))
        if self._hurt_ticks > 0:
            # pain reads at the screen edges (red vignette) + a faint cast;
            # the center of the world must stay readable through the flash
            k = self._hurt_ticks / 2.0
            passes.append((160, 8, 8, int(150 * k), True))
            passes.append((190, 26, 26, int(24 * k), False))
        if session.dead and self._death_fade > 0:
            # the kill reads before the dark: a red surge that decays
            # while the black rises over 2.5s — no more hard cut to a
            # black frame between two judge/blink samples
            df = self._death_fade
            red = int(170 * max(0.0, 1.0 - df / 60.0))
            if red > 2:
                passes.append((200, 16, 16, red, False))
            passes.append((0, 0, 0, min(255, int(255 * df / 150)), False))
        if passes:
            self._raster.apply_post(self._framebuf, passes)

    # -- debug ------------------------------------------------------------

    def _draw_debug(self, fb, instances):
        for polygon, xform, depth, clip_screen, walls, entry_edge, ents in instances:
            if not clip_screen:
                continue
            cx = sum(p[0] for p in clip_screen) / len(clip_screen)
            cy = sum(p[1] for p in clip_screen) / len(clip_screen)
            text.blit_text(fb, f"r{polygon} d{depth}",
                           int(cx - 12), int(cy - 6), (255, 0, 255), ui(12))
