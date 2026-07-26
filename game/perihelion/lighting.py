"""World lights: real objects the visibility engine casts light from --
NOT a screen-space glow. Per the director: "lighting is literally just
running our visibility engine again but from the perspective of the light
and applying color to the areas visible to the light, with realistic
falloff." See ENGINE_DESIGN.md's Lighting section for the full design.

Static-light caching exploits ROOT-FRAME INVARIANCE (ENGINE_INVARIANTS
R1: re-rooting the portal-chain anchor has zero pixel consequence): a
polygon's own local geometry -- and therefore any wedge cast into it -- looks
identical no matter which portal chain reached it. So a static light's lit
polygon in polygon R, computed once from the light's own visibility pass, is
valid for ANY camera instance of polygon R forever; no camera-relative or
chain-relative keying is needed. This is the "per-POLYGON caching" fallback
the design brief allows for when chain-keying is intractable -- here it is
*exact*, not an approximation, precisely because R1 already guarantees it.

No engine (rust) changes were needed to build this: `necore.visible_set`
already returns everything required (each reached polygon's screen-space clip
polygon plus the polygon-local -> screen transform); the polygon's OWN local
polygon and the light's virtual local position are recovered by inverting
that transform. See `compute_light_instances` below.
"""
from __future__ import annotations

import math
from dataclasses import dataclass

import necore

from .levels import LightSpec

__all__ = ["LightInstance", "compute_light_instances", "LightingSystem",
           "terrain_shadow_polys", "light_level_at"]


@dataclass(frozen=True)
class LightInstance:
    """One wedge a light casts into one polygon, expressed entirely in that
    POLYGON's OWN local frame (chain-independent -- see module docstring)."""
    polygon: int
    clip_local: tuple[tuple[float, float], ...]
    apex_local: tuple[float, float]  # the light's virtual position, R-local units
    radius_local: float              # light.radius converted to R-local units
    # cone direction in the RECEIVING polygon's local frame (None = omni);
    # the arc lives on the LightSpec
    dir_local: tuple[float, float] | None = None
    # Walk-mask terrain shadows this light casts INTO this polygon-local
    # instance, polygon-local coords, one convex-ish polygon per occluding
    # rect (see `_shadow_poly_for_rect`). Empty for a polygon with no
    # terrain. Computed once here (same call site the static cache
    # already runs through) so the shadow geometry rides the SAME
    # per-polygon cache static lights already get -- no extra cost per
    # frame for fixtures, only the worklight (attached, recomputed every
    # tick anyway) pays this every frame.
    shadow_local: tuple[tuple[tuple[float, float], ...], ...] = ()


# --- terrain shadow geometry (director's directive, 2026-07-13: walk-mask
# terrain blocks lamp light, never player vision) -----------------------
#
# Standard 2D point-light shadowcasting against an axis-aligned rect
# occluder: walk the rect's 4 corners (consistent CCW winding), classify
# each edge as "front" (the apex is outside/left of it, i.e. that face is
# lit) or "back" (occluded, facing away from the light) via the edge's
# cross-product sign, then trace the contiguous run of BACK edges -- its
# two endpoints are exactly the silhouette vertices a general (non-axis-
# aligned-apex) shadow needs, and any interior back vertices keep the
# umbra hugging the rect's true silhouette instead of a straight (and
# sometimes wrong, for a diagonal view) chord between the two extremes.
# The two silhouette vertices are then projected away from the apex out
# to `reach` (well beyond the light's radius) to close the shadow
# polygon. This mirrors the geometry `query::terrain_light_segments`
# exposes (rect edges as segments) but works from the rect corners
# directly since that's what `Sim.polygon_terrain` already returns.

def _rect_corners(lo: tuple[float, float], hi: tuple[float, float]
                   ) -> list[tuple[float, float]]:
    return [(lo[0], lo[1]), (hi[0], lo[1]), (hi[0], hi[1]), (lo[0], hi[1])]


def _project_away(apex: tuple[float, float], pt: tuple[float, float],
                   dist: float) -> tuple[float, float]:
    dx, dy = pt[0] - apex[0], pt[1] - apex[1]
    d = math.hypot(dx, dy)
    if d < 1e-9:
        return pt
    k = dist / d
    return (apex[0] + dx * k, apex[1] + dy * k)


def _shadow_poly_for_rect(apex: tuple[float, float],
                           corners: list[tuple[float, float]],
                           reach: float) -> list[tuple[float, float]] | None:
    """One shadow polygon for a single convex (rect) occluder as seen from
    `apex`, or None if the apex is degenerate (on an edge/colinear with
    the whole rect -- no clean silhouette, treated as no occlusion rather
    than guessing). See module-level note above for the algorithm."""
    n = len(corners)
    front = []
    for i in range(n):
        a, b = corners[i], corners[(i + 1) % n]
        ex, ey = b[0] - a[0], b[1] - a[1]
        ax, ay = apex[0] - a[0], apex[1] - a[1]
        front.append((ex * ay - ey * ax) > 0)
    if all(front) or not any(front):
        return None
    start = next(i for i in range(n) if not front[i])
    while not front[(start - 1) % n]:
        start -= 1
    seq = [corners[start % n]]
    i = start
    steps = 0
    while not front[i % n] and steps < n:
        i += 1
        seq.append(corners[i % n])
        steps += 1
    c1, c2 = seq[0], seq[-1]
    far1 = _project_away(apex, c1, reach)
    far2 = _project_away(apex, c2, reach)
    return seq + [far2, far1]


def terrain_shadow_polys(sim, polygon: int, apex_local: tuple[float, float],
                          reach: float) -> tuple[tuple[tuple[float, float], ...], ...]:
    """Shadow polygons (polygon-local) that walk-mask terrain in `polygon` casts
    from a light at `apex_local`, each extended `reach` units past the
    apex (comfortably beyond any light's radius -- callers pass a multiple
    of `radius_local`). Empty for a terrain-free polygon (the common case, one
    `Sim.polygon_terrain` call)."""
    try:
        rects = sim.polygon_terrain(polygon)
    except Exception:
        return ()
    polys = []
    for lox, loy, hix, hiy in rects:
        corners = _rect_corners((lox, loy), (hix, hiy))
        poly = _shadow_poly_for_rect(apex_local, corners, reach)
        if poly is not None:
            polys.append(tuple(poly))
    return tuple(polys)


def _point_in_polygon(pt: tuple[float, float],
                       poly: tuple[tuple[float, float], ...]) -> bool:
    """Standard ray-casting point-in-polygon (even-odd rule); good enough
    for the shadow polygons above (simple, non-self-intersecting)."""
    x, y = pt
    inside = False
    n = len(poly)
    for i in range(n):
        x1, y1 = poly[i]
        x2, y2 = poly[(i + 1) % n]
        if (y1 > y) != (y2 > y):
            xin = x1 + (y - y1) * (x2 - x1) / (y2 - y1 + 1e-300)
            if x < xin:
                inside = not inside
    return inside


def light_level_at(light_map: dict[int, list[tuple[int, "LightInstance"]]],
                    lights: list, polygon: int, x: float, y: float) -> float:
    """How lit is polygon-local point `(x, y)` in `polygon`, 0 (dark) .. 1 (full),
    per the LURK/AMBUSH AI's "how lit is this spot" query. `light_map` is a
    `LightingSystem.frame_lookup()` result (computed ONCE per tick by the
    caller, not per query -- see `sim.py`'s `_enemy_ai`, which only pays
    for this at all when a LURK-capable enemy is present). Sums each
    reaching light's falloff kernel (same `(1-dist/r)^2` law `_blit_light`
    uses) unless the point falls inside that light's terrain shadow, then
    clamps to [0, 1]."""
    total = 0.0
    for light_idx, inst in light_map.get(polygon, ()):
        if inst.polygon != polygon:
            continue
        if any(_point_in_polygon((x, y), poly) for poly in inst.shadow_local):
            continue
        dx, dy = x - inst.apex_local[0], y - inst.apex_local[1]
        dist = math.hypot(dx, dy)
        a = max(0.0, min(1.0, 1.0 - dist / max(1e-6, inst.radius_local)))
        if a <= 0.0:
            continue
        lt = lights[light_idx] if light_idx < len(lights) else None
        intensity = lt.intensity if lt is not None else 1.0
        if inst.dir_local is not None and lt is not None and lt.arc > 0.0 \
                and dist > 1e-6:
            cosang = (dx * inst.dir_local[0] + dy * inst.dir_local[1]) / dist
            half = lt.arc / 2.0
            ang = math.acos(max(-1.0, min(1.0, cosang)))
            feather = max(0.05, half * 0.35)
            if ang > half + feather:
                continue
            if ang > half:
                a *= 1.0 - (ang - half) / feather
        total += a * a * intensity
    return max(0.0, min(1.0, total))


def compute_light_instances(sim, light: LightSpec, max_depth: int = 6,
                             max_instances: int = 12) -> list[LightInstance]:
    """Run the engine's own visibility pass from the light's apex -- exactly
    the camera code path, with the light standing in as the "camera" -- and
    recover each reached polygon's own local lit polygon plus the light's
    virtual local position there, purely by inverting the returned
    transforms.

    `cam` here is a pure translation (linear_scale 1) that centers the
    query window on the light so a light anywhere in its polygon's local
    coordinates gets a correctly-sized frustum; because it carries no
    rotation/scale, inverting the RETURNED per-instance transform and
    composing it against `cam`'s own inverse cleanly separates "where is
    this point in polygon R's own frame" from "how zoomed is my query window."
    """
    radius = max(1.0, light.radius)
    pad = radius * 0.15
    win = 2.0 * (radius + pad)
    lx, ly = light.pos
    cam = necore.mat_translate(radius + pad - lx, radius + pad - ly)
    apex_screen = necore.mat_apply(cam, lx, ly)
    raw = sim.visible_set(light.polygon, cam, lx, ly, win, win,
                           max_depth, max_instances)
    out: list[LightInstance] = []
    for polygon, xform, _depth, clip_screen, _walls, _entry, _ents in raw:
        if len(clip_screen) < 3:
            continue
        try:
            inv = necore.mat_inv(xform)
        except ValueError:
            continue  # degenerate instance (zero-area chain) -- skip, not fatal
        scale = math.hypot(xform[0], xform[3])
        if scale <= 1e-9:
            continue
        clip_local = tuple(necore.mat_apply(inv, px, py) for px, py in clip_screen)
        apex_local = necore.mat_apply(inv, apex_screen[0], apex_screen[1])
        radius_local = radius / scale
        # Walk-mask terrain shadows (director's directive, 2026-07-13):
        # reach well past the light's own radius so the shadow polygon's
        # far edge is never the thing that clips it short -- the actual
        # falloff/gate clipping happens downstream (radial kernel, camera
        # clip polygon), this only needs to fully cover the dark region.
        shadow_local = terrain_shadow_polys(sim, polygon, apex_local, radius_local * 4.0)
        dir_local = None
        if light.dir is not None:
            # the query cam is translate-only, so screen dir == light.dir;
            # map it into the receiving polygon's frame like the apex
            dlx, dly = necore.mat_apply_dir(inv, light.dir[0], light.dir[1])
            dm = math.hypot(dlx, dly)
            if dm > 1e-9:
                dir_local = (dlx / dm, dly / dm)
        out.append(LightInstance(polygon, clip_local, apex_local, radius_local,
                                  dir_local=dir_local,
                                  shadow_local=shadow_local))
    return out


class LightingSystem:
    """Owns the static-light cache for a session's (possibly streamed-in)
    level and the per-frame lookup used by the renderer. One instance per
    GameSession."""

    def __init__(self, sim, level=None):
        self.lights: list[LightSpec] = []
        self._by_polygon: dict[int, list[tuple[int, LightInstance]]] = {}
        if level is not None:
            self.add_lights(sim, level.lights)

    def add_lights(self, sim, lights: list[LightSpec]) -> None:
        """Register new lights (fresh level load, or a streamed chunk whose
        polygon indices are already offset). Static lights are cached now;
        attached lights are recomputed every frame in `frame_lookup`."""
        base = len(self.lights)
        self.lights.extend(lights)
        for j, lt in enumerate(lights):
            if lt.kind != "static":
                continue
            i = base + j
            for inst in compute_light_instances(sim, lt):
                self._by_polygon.setdefault(inst.polygon, []).append((i, inst))

    def attached_lights(self) -> list[tuple[int, LightSpec]]:
        # intensity 0 contributes nothing but would still burn a full
        # visibility pass per frame — the muzzle flash and the pulse-light
        # pool sit at 0 almost always, so the gate is what makes a pool of
        # transient real lights affordable at all
        return [(i, lt) for i, lt in enumerate(self.lights)
                if lt.kind == "attached" and lt.intensity > 0.0]

    def frame_lookup(self, sim) -> dict[int, list[tuple[int, LightInstance]]]:
        """Call once per frame: static cache plus freshly recomputed
        attached lights (e.g. the player's own light), merged into a
        polygon -> [(light_index, instance)] map for that frame's compositing
        pass."""
        by_polygon: dict[int, list[tuple[int, LightInstance]]] = {
            polygon: list(insts) for polygon, insts in self._by_polygon.items()
        }
        for i, lt in self.attached_lights():
            for inst in compute_light_instances(sim, lt, max_instances=24):
                by_polygon.setdefault(inst.polygon, []).append((i, inst))
        return by_polygon

    def cache_count(self) -> int:
        return sum(len(v) for v in self._by_polygon.values())
