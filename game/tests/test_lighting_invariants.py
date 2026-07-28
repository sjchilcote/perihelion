"""ENGINE_INVARIANTS.md lighting properties (new subsystem: `lighting.py` /
render.py `_draw_world_lights`). Lights are world objects: `compute_light_
instances` runs the engine's own `visible_set` from the light's apex (the
director's law -- "lighting is literally just running our visibility
engine again but from the perspective of the light") and recovers each
reached polygon's OWN local lit polygon by inverting the returned transform.
Nothing here was covered before this file: lighting did not exist.

Properties covered, each with a fail-first verification note:

  1. occlusion       -- a point with no straight-line-through-portals path
                         to a light gets zero contribution from it
                         (wall-behind / around-a-corner case).
  2. falloff          -- monotonically non-increasing along an unobstructed
                         ray from the apex.
  3. cache coherence  -- LightingSystem's cached instances equal a fresh
                         `compute_light_instances` call on the same world.
  4. seam-freeness    -- the lit intensity is continuous across a portal
                         the light shines through (no step at the doorway).
  5. backend parity   -- lighting composites identically regardless of
                         which backend rendered the floor underneath, since
                         `_draw_world_lights` runs post-hoc on the pixel
                         surface for both (skipped if this necore build has
                         no Raster backend to compare against).

All test worlds author every polygon as a rect CENTERED ON ITS OWN CANVAS
ORIGIN (x=-w/2, y=-h/2). `LevelBuilder` polygons may overlap freely on the
authoring canvas -- only connections define adjacency -- and centering
each polygon means its centroid is (0,0), so authored canvas coordinates and
the engine's post-centroid-subtraction LOCAL coordinates are identical
numbers. That sidesteps a whole class of off-by-centroid test bugs when
hand-authoring light/sample positions in polygon-local units.

Adversarial dimensions (hypothesis): sample distance for falloff; polygon
count/topology for cache coherence; straddle offset for seam-freeness.
"""

from __future__ import annotations

import math
import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

from hypothesis import given, settings
from hypothesis import strategies as st

import necore
import numpy as np
import pytest

from perihelion.levels import LevelBuilder, LightSpec
from perihelion.lighting import compute_light_instances
from perihelion.sim import GameSession, InputFrame

EXAMPLES = 30


def _atten(inst, point) -> float:
    """The exact falloff kernel `render.py:_blit_light` uses: clamp(1 -
    dist/radius, 0, 1) squared -- smooth-to-zero at the radius."""
    dx = point[0] - inst.apex_local[0]
    dy = point[1] - inst.apex_local[1]
    dist = math.hypot(dx, dy)
    a = max(0.0, min(1.0, 1.0 - dist / inst.radius_local))
    return a * a


class _Slotter:
    """Places each polygon in its own 100000-unit-wide canvas slot, centered
    on the slot (so a polygon's LOCAL frame -- post centroid-subtraction --
    is just its authored point minus the slot center, i.e. plain centered
    coordinates) while keeping every polygon's absolute canvas verts far
    apart. This matters: `LevelBuilder.resolve()` autoconnects ANY pair of
    exactly-coincident edges across the whole level, not just the ones an
    explicit `connect_pts` call names -- so two same-shape polygons centered
    on the SAME canvas origin (the natural "centroid = local" shortcut)
    would silently auto-wire on every side, not just the one intended.
    """

    def __init__(self, b: LevelBuilder):
        self.b = b
        self.n = 0
        self.centers: dict[int, tuple[float, float]] = {}

    def rect(self, w: float, h: float) -> int:
        cx = self.n * 100000.0
        self.n += 1
        idx = self.b.rect(cx - w / 2.0, -h / 2.0, w, h)
        self.centers[idx] = (cx, 0.0)
        return idx

    def anchor(self, polygon: int, local_pt) -> tuple[float, float]:
        cx, cy = self.centers[polygon]
        return (cx + local_pt[0], cy + local_pt[1])


@settings(max_examples=EXAMPLES, deadline=None)
@given(n_islands=st.integers(min_value=1, max_value=4),
       radius=st.floats(50.0, 5000.0))
def test_occlusion_zero_contribution_across_disconnected_polygons(n_islands, radius):
    """The strongest occlusion case: a light in r0, and one or more polygons
    with NO connection to r0 at all (not through any portal chain, at any
    depth) -- i.e. no straight-line-through-portals path exists by
    construction, regardless of `radius`. Those polygons must never appear
    in the light's reached-polygon set, however large the radius.

    Note on scope: whether a wedge correctly stops at an actual WALL
    (partial doorway / corner occlusion) is `visibility.rs`'s own job and
    already covered by its existing tests (ENGINE_INVARIANTS.md section
    4) -- `compute_light_instances` calls the identical `visible_set` the
    camera uses, so it inherits that guarantee for free. This test's job
    is the NEW code's own risk surface: that caching/recovering local
    coordinates from the light's query never spuriously reports a polygon
    the visibility pass never actually reached.

    Verified fail-first: iterated over ALL of `sim.world`'s polygons and
    fabricated a `LightInstance` for any polygon absent from the real result
    (as a "what if a caching bug unioned in every known polygon" mutation) --
    every island polygon then showed up lit and the test failed. Reverted
    before committing (the fabrication was never actually wired into
    `compute_light_instances`, only exercised standalone to confirm the
    assertion is load-bearing).
    """
    b = LevelBuilder("ISLE", 1)
    slots = _Slotter(b)
    r0 = slots.rect(150, 150)
    b.player(r0, slots.anchor(r0, (0, 0)))
    islands = [slots.rect(120, 120) for _ in range(n_islands)]
    level = b.build()
    session = GameSession(level, seed=1)
    light = LightSpec(polygon=r0, pos=(0.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=radius, kind="static")
    insts = compute_light_instances(session.sim, light, max_depth=10, max_instances=64)
    reached = {inst.polygon for inst in insts}
    for isl in islands:
        assert isl not in reached, (
            f"light reached polygon {isl}, which has no connection at all")


@settings(max_examples=EXAMPLES, deadline=None)
@given(frac=st.floats(0.02, 0.98))
def test_falloff_monotonic_along_unobstructed_ray(frac):
    """Along an unobstructed ray from the light's own polygon's apex, the
    attenuation kernel must be non-increasing with distance: sample two
    points at distances `frac*R` and `(frac+eps)*R` and require the closer
    one at least as bright.

    Verified fail-first: dropped the `1.0 -` in a local copy of the
    kernel (`dist/radius` directly, i.e. increasing with distance) --
    failed on every generated example. Reverted before committing.
    """
    b = LevelBuilder("FALL", 1)
    r0 = b.rect(-200, -50, 400, 100)
    b.player(r0, (-190, 0))
    level = b.build()
    session = GameSession(level, seed=1)
    radius = 300.0
    light = LightSpec(polygon=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=radius, kind="static")
    insts = compute_light_instances(session.sim, light)
    inst = next(i for i in insts if i.polygon == r0)
    eps = 0.01
    frac2 = min(0.999, frac + eps)
    p_near = (-190.0 + frac * radius, 0.0)
    p_far = (-190.0 + frac2 * radius, 0.0)
    a_near = _atten(inst, p_near)
    a_far = _atten(inst, p_far)
    assert a_near >= a_far - 1e-9


@settings(max_examples=EXAMPLES, deadline=None)
@given(n_polygons=st.integers(min_value=2, max_value=5),
       radius=st.floats(60.0, 900.0))
def test_cache_matches_fresh_computation(n_polygons, radius):
    """LightingSystem's cache (built once at construction) must equal a
    fresh `compute_light_instances` call against the same world: same set
    of reached polygons, and matching apex/radius per polygon (the render-
    critical scalars derived from the clip polygon).

    Verified fail-first: had the cache-building call pass `max_depth=2`
    while this test's fresh call used the default (6) -- for `n_polygons=5`
    chains the cache came back missing polygons the fresh call found, and the
    test failed. Reverted before committing.
    """
    b = LevelBuilder("COH", 1)
    slots = _Slotter(b)
    polygons = [slots.rect(160, 160) for _ in range(n_polygons)]
    for i in range(n_polygons - 1):
        b.connect_pts(polygons[i], slots.anchor(polygons[i], (80, 0)),
                      polygons[i + 1], slots.anchor(polygons[i + 1], (-80, 0)))
    b.player(polygons[0], slots.anchor(polygons[0], (0, 0)))
    level = b.build()
    light = LightSpec(polygon=polygons[0], pos=(0.0, 0.0), color=(255, 220, 170),
                       intensity=1.0, radius=radius, kind="static")
    level.lights.append(light)
    session = GameSession(level, seed=1)
    fresh = compute_light_instances(session.sim, light)
    cached_insts = [inst for polygon_list in session.lighting._by_polygon.values()
                    for idx, inst in polygon_list if idx == 0]
    cached_by_polygon = {i.polygon: i for i in cached_insts}
    fresh_by_polygon = {i.polygon: i for i in fresh}
    assert set(cached_by_polygon) == set(fresh_by_polygon)
    for polygon, fi in fresh_by_polygon.items():
        ci = cached_by_polygon[polygon]
        assert math.isclose(ci.radius_local, fi.radius_local, rel_tol=1e-6)
        assert math.hypot(ci.apex_local[0] - fi.apex_local[0],
                           ci.apex_local[1] - fi.apex_local[1]) < 1e-6


def _octagon_portal_world():
    """Octagon r0 joined to a rect r1 along one of the octagon's genuinely
    SLANTED edges -- ported from test_root_invariance.py's `_octagon_level`
    construction. The resulting portal transform carries a real ROTATION
    (not just a translation), which matters here: every OTHER world in
    this file connects axis-aligned rects along parallel edges, so their
    portal transforms are pure translations, and `mat_inv` of a pure
    translation preserves every relative distance -- a bug that silently
    used the forward transform instead of its inverse would be
    UNDETECTABLE in those worlds (translation and its inverse differ only
    by a sign, not a shape). Only a rotated portal actually exercises
    whether the inversion is real. Returns (level, r0, r1, doorway_mid_r0,
    doorway_mid_r1, normal, tangent) all in each polygon's own LOCAL
    (centroid-subtracted) frame."""
    b = LevelBuilder("OCT", 1)
    r0 = b.ngon(100, 75, 100, 8)  # regular octagon: area centroid == (100, 75)
    ex0, ey0 = 200.0, 75.0
    ex1, ey1 = 170.71067811865476, 4.289321881345259
    mx, my = (ex0 + ex1) / 2.0, (ey0 + ey1) / 2.0
    elen = math.hypot(ex1 - ex0, ey1 - ey0)
    # inward normal (points from the door toward r0's interior/center;
    # verified empirically -- moving `+` along it stays inside r0, `-`
    # immediately exits the polygon)
    nx, ny = (ey1 - ey0) / elen, -(ex1 - ex0) / elen
    tx, ty = (ex1 - ex0) / elen, (ey1 - ey0) / elen   # tangent along the edge
    r1 = b.rect(1000, 1000, elen, 120)
    r1_cx, r1_cy = 1000 + elen / 2.0, 1000 + 60.0  # rect(x,y,w,h) centroid
    r1_mid = (1000 + elen / 2.0, 1000)
    b.connect_pts(r0, (mx, my), r1, r1_mid)
    b.player(r0, (mx + nx * 20, my + ny * 20))
    level = b.build()
    door_r0 = (mx - 100.0, my - 75.0)          # r0-local
    door_r1 = (r1_mid[0] - r1_cx, r1_mid[1] - r1_cy)  # r1-local
    return level, r0, r1, door_r0, door_r1, (nx, ny), (tx, ty)


@settings(max_examples=EXAMPLES, deadline=None)
@given(straddle=st.floats(0.1, 4.0))
def test_seam_freeness_across_a_portal(straddle):
    """A light in r0 (the octagon) shines through its slanted-edge doorway
    into r1 (a rect, reached via a genuinely ROTATED portal transform, see
    `_octagon_portal_world`). Two points a hair apart (`straddle` world
    units) straddling the shared doorway threshold -- one just inside r0,
    one just inside r1 -- must show near-equal attenuation: the lit
    gradient must not step at the seam.

    Verified fail-first: perturbed `apex_local`/`clip_local` recovery in
    `compute_light_instances` to use `xform` instead of `mat_inv(xform)`
    -- with THIS rotated-portal world (unlike the axis-aligned worlds
    elsewhere in this file, where forward/inverse translation are
    indistinguishable by relative distance) the r1-side attenuation came
    from a rotated/mislocated apex and diverged from the r0 side by more
    than an order of magnitude at every generated `straddle`. Reverted
    before committing.
    """
    level, r0, r1, door_r0, door_r1, (nx, ny), _tan = _octagon_portal_world()
    session = GameSession(level, seed=1)
    lx, ly = door_r0[0] + nx * 20.0, door_r0[1] + ny * 20.0  # a bit inside r0
    light = LightSpec(polygon=r0, pos=(lx, ly), color=(255, 255, 255),
                       intensity=1.0, radius=250.0, kind="static")
    insts = compute_light_instances(session.sim, light, max_depth=4, max_instances=8)
    inst0 = next(i for i in insts if i.polygon == r0)
    inst1 = next((i for i in insts if i.polygon == r1), None)
    assert inst1 is not None, "light did not reach through the doorway at all"
    # Direct sanity check (catches divergence the attenuation comparison
    # below can miss when a wrong-frame apex lands so far away that BOTH
    # sides clamp to zero attenuation and trivially "agree"): the light's
    # own polygon's apex_local must equal its authored local position exactly.
    assert math.hypot(inst0.apex_local[0] - lx, inst0.apex_local[1] - ly) < 1e-6
    p0 = (door_r0[0] + nx * straddle, door_r0[1] + ny * straddle)  # just inside r0
    p1 = (door_r1[0], door_r1[1] + straddle)  # just inside r1 (its near edge is local y=-60)
    a0 = _atten(inst0, p0)
    a1 = _atten(inst1, p1)
    # Not pixel-exact: p0/p1 are parametrized along each polygon's OWN local
    # axis into the polygon (r0: the door's inward normal; r1: local +y),
    # which only coincide with the same physical ray to within the
    # octagon's real (non-axis-aligned) geometry -- a few hundredths of
    # slop at `straddle` up to 4 units is expected sampling noise, not a
    # seam step. The mutation this test guards against (wrong apex frame)
    # produces order-of-magnitude divergence, well outside this budget.
    assert abs(a0 - a1) < 0.06, f"seam step: r0 side {a0:.4f} vs r1 side {a1:.4f}"


@settings(max_examples=15, deadline=None)
@given(polygon_w=st.floats(220.0, 420.0), radius=st.floats(300.0, 700.0),
       light_dx=st.floats(-60.0, 60.0))
def test_pixel_composite_seam_freeness_across_corridor_portals(polygon_w, radius, light_dx):
    """Director-reported ("there are ALSO seams between the polygons in the
    corridor now, that's new with the lighting stuff"): a straight 3-polygon
    corridor (translation-only portals, the common case) with one static
    light in the middle polygon whose wedge reaches both neighbors through
    their doorways. This exercises the ACTUAL PIXEL COMPOSITE path
    (`Renderer.draw` -> `_draw_world_lights` -> `_blit_light`'s union-fill
    grouping by rounded (light, screen-apex, screen-radius)) that
    `test_seam_freeness_across_a_portal` above does NOT cover -- that test
    only checks `compute_light_instances`' polygon-local attenuation math,
    never the rendered surface. Nothing exercised the union-fill grouping
    or the gradient-sprite blit at pixel granularity before this test.

    Property: sampling a horizontal scanline across a UNIFORM-ALBEDO floor
    (per the design brief's property (i): "for a light shining through a
    doorway onto uniform-albedo floor" -- polygon decoration is seeded per
    polygon and legitimately produces its own faint tint lines/props unrelated
    to lighting, see the module-docstring-adjacent finding below, so this
    test disables `_get_detail` to isolate the lighting composite alone),
    well clear of the player sprite/reticle, the max adjacent-pixel
    luminance delta anywhere on the lit floor -- including directly on
    both portal-boundary columns -- must stay small. A step at a boundary
    would mean the same light's wedge in the two polygons landed in different
    `_blit_light` groups (independent gradient origins/rasterized polygon
    edges meeting instead of unioning).

    Root-cause note for future maintainers: a "ghost line" at a FIXED
    screen position, present regardless of the light's world position and
    still present when the composited lightmap is forced flat white
    (bypassing `_draw_world_lights` entirely), is NOT this bug -- it is a
    `_draw_detail` decorative floor prop (a `("line", ...)` primitive,
    default color = floor albedo + 18/channel) that is simply invisible
    under the old ambient-lit floor and newly visible now that zero-ambient
    lighting actually multiplies the floor up. Diagnosed exactly this way
    2026-07-13 while investigating the director's "ghost lines" report:
    the specific line reproduced there traced to `_get_detail`, not to
    `_blit_light`/the lightmap. Disabling `_get_detail` here keeps this
    test honest about which subsystem it exercises.

    Verified fail-first: temporarily perturbed the group key in
    `_draw_world_lights` (rounding `apex_sx`/`apex_sy` to a coarser unit
    tied to `polygon`, i.e. `key = (light_idx, polygon, round(radius_screen, 1))`
    -- forcing every polygon's wedge into its own group even when the apex
    genuinely coincides) and this test failed with a >100-luminance step
    at the shared portal column on every generated example. Reverted
    before committing.
    """
    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer
    b = LevelBuilder("CORRSEAM", 1)
    r0 = b.rect(-polygon_w - 100.0, -100.0, polygon_w, 200.0)
    r1 = b.rect(-100.0, -100.0, 200.0, 200.0)
    r2 = b.rect(100.0, -100.0, polygon_w, 200.0)
    b.connect_pts(r0, (-100.0, 0.0), r1, (-100.0, 0.0))
    b.connect_pts(r1, (100.0, 0.0), r2, (100.0, 0.0))
    b.player(r1, (0.0, 0.0))
    level = b.build()
    level.lights.append(LightSpec(polygon=r1, pos=(light_dx, 0.0),
                                   color=(255, 220, 170), intensity=1.2,
                                   radius=radius, kind="static"))
    session = GameSession(level, seed=1, screen=(INTERNAL_W, INTERNAL_H))
    session.douse_player_lights()  # isolate the static light's own composite
    ren = Renderer(session)
    ren._get_detail = lambda polygon: []  # isolate lighting from polygon decoration (see docstring)

    surf = (INTERNAL_W, INTERNAL_H)
    session.tick(InputFrame(mx=0, my=0, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                             fire=False, alt=False, interact=False, weapon=0))
    ren.consume_fx(session.fx)
    frame = ren.draw(surf)

    # Each polygon's own screen clip span, read from the renderer's own
    # visibility set (backend-independent — the same instances the draw pass
    # consumes) rather than a pygame-only draw hook. The assertion below
    # targets the two shared PORTAL columns specifically: this property is
    # about portal continuity, not the level's outer walls, where a real
    # floor-to-void step is expected and not a "seam".
    spans: dict[int, tuple[float, float]] = {}
    for polygon, xform, depth, clip_screen, walls, entry_edge, ents in \
            session.visible(ren.max_depth, ren.max_instances):
        if len(clip_screen) < 3:
            continue
        xs = [p[0] for p in clip_screen]
        spans[polygon] = (min(xs), max(xs))
    assert set(spans) >= {r0, r1, r2}, f"not all 3 polygons rendered: {spans}"
    portal_xs = sorted({round(spans[r0][1]), round(spans[r1][0]),
                         round(spans[r1][1]), round(spans[r2][0])})
    # r0's right edge == r1's left edge, r1's right edge == r2's left edge
    # (touching axis-aligned rects): exactly 2 distinct shared columns.
    assert len(portal_xs) == 2, f"expected 2 portal columns, got {portal_xs}"

    arr = frame.astype(int)
    # A row well below the player sprite/reticle (they sit on the polygon's
    # vertical center) but still inside every polygon's floor extent.
    y = INTERNAL_H // 2 + 60
    lum = arr[:, y, :].sum(axis=1)
    jumps = np.abs(np.diff(lum))
    for px in portal_xs:
        x = int(round(px))
        window = jumps[max(0, x - 2):x + 2]
        assert window.max() <= 12, (
            f"seam at portal column x={x}: max adjacent-pixel luminance "
            f"jump {window.max()} (polygon_w={polygon_w}, radius={radius}, "
            f"light_dx={light_dx})")


@settings(max_examples=25, deadline=None)
@given(radius=st.floats(150.0, 400.0))
def test_no_ghost_pixel_at_light_radius_edge(radius):
    """Design brief property (ii), "no-ghost-edges": for a single light in
    a plain convex polygon with an oversized radius (so the disc's own edge,
    not a wall or portal, is what bounds the lit area on-screen), no pixel
    outside the true falloff -- i.e. no lone bright pixel sitting one
    column/row past where the light's own radial gradient sprite stops --
    may exceed a small epsilon above its neighbors.

    Root-cause covered: `_blit_light` computed the rect clamp radius as
    `ir = ceil(radius)` but sized/positioned the gradient sprite from
    `_light_gradient`'s own `round(radius)` -- these disagree whenever
    frac(radius) < 0.5 (about half of all radii), leaving the rect's
    outermost column/row OUTSIDE the gradient blit's coverage. That strip
    kept its raw white-polygon-fill*tint value (never multiplied down)
    and got ADDed at full strength: a single full-brightness pixel sitting
    right at the light's radius edge, deep inside an otherwise near-black
    polygon.

    Verified fail-first: reverted `ir` to `int(math.ceil(radius))` (the
    pre-fix form) in a local copy -- this test failed with a lone
    full-albedo pixel roughly `ceil(radius) - round(radius)` columns
    outside the true lit disc on every generated example where
    frac(radius) < 0.5. Reverted before committing.
    """
    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer
    b = LevelBuilder("GHOSTEDGE", 1)
    r0 = b.rect(-500.0, -500.0, 1000.0, 1000.0)  # big enough the disc never hits a wall
    b.player(r0, (0.0, 0.0))
    level = b.build()
    level.lights.append(LightSpec(polygon=r0, pos=(0.0, 0.0), color=(255, 255, 255),
                                   intensity=1.2, radius=radius, kind="static"))
    session = GameSession(level, seed=1, screen=(INTERNAL_W, INTERNAL_H))
    session.douse_player_lights()
    ren = Renderer(session)
    ren._get_detail = lambda polygon: []
    surf = (INTERNAL_W, INTERNAL_H)
    session.tick(InputFrame(mx=0, my=0, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                             fire=False, alt=False, interact=False, weapon=0))
    ren.consume_fx(session.fx)
    arr = ren.draw(surf).astype(int)
    y = INTERNAL_H // 2 + 60  # clear of the player sprite/reticle at polygon center
    lum = arr[:, y, :].sum(axis=1)
    jumps = np.abs(np.diff(lum))
    assert jumps.max() <= 12, (
        f"ghost pixel: max adjacent-pixel luminance jump {jumps.max()} at "
        f"x={int(jumps.argmax())} (radius={radius})")


# (test_lighting_backend_parity deleted 2026-07-22 with the pygame render
# backend — there is only one renderer now, so there is nothing to compare.)


def test_muzzle_flash_lights_across_the_portal_without_a_seam():
    """Director 2026-07-22: "Muzzle flash causes room seams. Rework it to
    use the actual lighting system. It should light up the whole room."

    Fire a shot right beside an open portal and diff the frame against the
    identical no-fire frame, isolating the shot's illumination. Two
    properties, calibrated against measured pre/post-fix values:

    * the flash must CROSS the portal (pre-fix the per-room glow disc put
      mean 2.4 luminance into the neighbor strip; the real light puts >200)
    * no portal-aligned cliff: pre-fix every lit row fell to EXACTLY ZERO
      at the portal column (per-column means ...14, 12, 11, 0, 0, 0); a
      real light's wedge continues through the doorway.
    """
    import numpy as np

    from perihelion.render import Renderer

    def shot_frame(fire):
        b = LevelBuilder("MZSEAM", 1)
        r0 = b.rect(0, 0, 160, 160, kind="dock")
        r1 = b.rect(160, 0, 160, 160, kind="dock")
        b.connect(r0, 2, r1, 0)
        b.player(r0, (140, 80))
        b.exit(r1, (300, 80))
        s = GameSession(b.build(), seed=5, screen=(640, 360), zoom=1.0)
        s.weapons = ["smg"]
        s.weapon = "smg"
        s.ammo["9mm"] = 99
        s._shake = lambda *a, **k: None   # camera shake would smear the diff
        r = Renderer(s)
        surf = (640, 360)
        for t in range(3):
            s.tick(InputFrame(ax=440.0, ay=180.0, fire=(fire and t == 2)))
        r.consume_fx(s.fx)
        # sprite fx (muzzle sparks, gibs) are not illumination; drop them so
        # the diff below measures LIGHT alone
        r._sparks.clear()
        r._gibs.clear()
        return r.draw(surf).astype(np.int32)

    d = np.abs(shot_frame(True) - shot_frame(False)).sum(axis=2)

    # (a) the shot's light reaches the neighboring room
    r1_strip = float(d[345:420, 150:210].mean())
    assert r1_strip > 40.0, (
        f"muzzle flash does not light the neighboring room: mean diff "
        f"{r1_strip:.1f} in the strip past the portal (pre-fix: 2.4)")

    # (b) no row's illumination collapses AT the portal column. The old
    # per-room disc was clipped at x=340 for every row it spanned; a wedge
    # shadow edge is diagonal and cannot zero a whole band of rows at one
    # column. Rows around the tracer line are excluded.
    rows = [y for y in range(120, 240) if not 170 <= y <= 190]
    cliffs = 0
    for y in rows:
        before = float(d[335:339, y].mean())
        after = float(d[341:345, y].mean())
        if before > 8.0 and after < 0.25 * before:
            cliffs += 1
    assert cliffs == 0, (
        f"{cliffs} rows lose their illumination exactly at the portal "
        f"column — the per-room glow-disc seam (pre-fix: every lit row)")
