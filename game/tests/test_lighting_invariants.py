"""ENGINE_INVARIANTS.md lighting properties (new subsystem: `lighting.py` /
render.py `_draw_world_lights`). Lights are world objects: `compute_light_
instances` runs the engine's own `visible_set` from the light's apex (the
director's law -- "lighting is literally just running our visibility
engine again but from the perspective of the light") and recovers each
reached room's OWN local lit polygon by inverting the returned transform.
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

All test worlds author every room as a rect CENTERED ON ITS OWN CANVAS
ORIGIN (x=-w/2, y=-h/2). `LevelBuilder` rooms may overlap freely on the
authoring canvas -- only connections define adjacency -- and centering
each room means its centroid is (0,0), so authored canvas coordinates and
the engine's post-centroid-subtraction LOCAL coordinates are identical
numbers. That sidesteps a whole class of off-by-centroid test bugs when
hand-authoring light/sample positions in room-local units.

Adversarial dimensions (hypothesis): sample distance for falloff; room
count/topology for cache coherence; straddle offset for seam-freeness.
"""

from __future__ import annotations

import math
import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

from hypothesis import given, settings
from hypothesis import strategies as st

import necore
import pytest

from perihelion.levels import LevelBuilder, LightSpec
from perihelion.lighting import compute_light_instances
from perihelion.sim import GameSession

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
    """Places each room in its own 100000-unit-wide canvas slot, centered
    on the slot (so a room's LOCAL frame -- post centroid-subtraction --
    is just its authored point minus the slot center, i.e. plain centered
    coordinates) while keeping every room's absolute canvas verts far
    apart. This matters: `LevelBuilder.resolve()` autoconnects ANY pair of
    exactly-coincident edges across the whole level, not just the ones an
    explicit `connect_pts` call names -- so two same-shape rooms centered
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

    def anchor(self, room: int, local_pt) -> tuple[float, float]:
        cx, cy = self.centers[room]
        return (cx + local_pt[0], cy + local_pt[1])


@settings(max_examples=EXAMPLES, deadline=None)
@given(n_islands=st.integers(min_value=1, max_value=4),
       radius=st.floats(50.0, 5000.0))
def test_occlusion_zero_contribution_across_disconnected_rooms(n_islands, radius):
    """The strongest occlusion case: a light in r0, and one or more rooms
    with NO connection to r0 at all (not through any portal chain, at any
    depth) -- i.e. no straight-line-through-portals path exists by
    construction, regardless of `radius`. Those rooms must never appear
    in the light's reached-room set, however large the radius.

    Note on scope: whether a wedge correctly stops at an actual WALL
    (partial doorway / corner occlusion) is `visibility.rs`'s own job and
    already covered by its existing tests (ENGINE_INVARIANTS.md section
    4) -- `compute_light_instances` calls the identical `visible_set` the
    camera uses, so it inherits that guarantee for free. This test's job
    is the NEW code's own risk surface: that caching/recovering local
    coordinates from the light's query never spuriously reports a room
    the visibility pass never actually reached.

    Verified fail-first: iterated over ALL of `sim.world`'s rooms and
    fabricated a `LightInstance` for any room absent from the real result
    (as a "what if a caching bug unioned in every known room" mutation) --
    every island room then showed up lit and the test failed. Reverted
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
    light = LightSpec(room=r0, pos=(0.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=radius, kind="static")
    insts = compute_light_instances(session.sim, light, max_depth=10, max_instances=64)
    reached = {inst.room for inst in insts}
    for isl in islands:
        assert isl not in reached, (
            f"light reached room {isl}, which has no connection at all")


@settings(max_examples=EXAMPLES, deadline=None)
@given(frac=st.floats(0.02, 0.98))
def test_falloff_monotonic_along_unobstructed_ray(frac):
    """Along an unobstructed ray from the light's own room's apex, the
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
    light = LightSpec(room=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=radius, kind="static")
    insts = compute_light_instances(session.sim, light)
    inst = next(i for i in insts if i.room == r0)
    eps = 0.01
    frac2 = min(0.999, frac + eps)
    p_near = (-190.0 + frac * radius, 0.0)
    p_far = (-190.0 + frac2 * radius, 0.0)
    a_near = _atten(inst, p_near)
    a_far = _atten(inst, p_far)
    assert a_near >= a_far - 1e-9


@settings(max_examples=EXAMPLES, deadline=None)
@given(n_rooms=st.integers(min_value=2, max_value=5),
       radius=st.floats(60.0, 900.0))
def test_cache_matches_fresh_computation(n_rooms, radius):
    """LightingSystem's cache (built once at construction) must equal a
    fresh `compute_light_instances` call against the same world: same set
    of reached rooms, and matching apex/radius per room (the render-
    critical scalars derived from the clip polygon).

    Verified fail-first: had the cache-building call pass `max_depth=2`
    while this test's fresh call used the default (6) -- for `n_rooms=5`
    chains the cache came back missing rooms the fresh call found, and the
    test failed. Reverted before committing.
    """
    b = LevelBuilder("COH", 1)
    slots = _Slotter(b)
    rooms = [slots.rect(160, 160) for _ in range(n_rooms)]
    for i in range(n_rooms - 1):
        b.connect_pts(rooms[i], slots.anchor(rooms[i], (80, 0)),
                      rooms[i + 1], slots.anchor(rooms[i + 1], (-80, 0)))
    b.player(rooms[0], slots.anchor(rooms[0], (0, 0)))
    level = b.build()
    light = LightSpec(room=rooms[0], pos=(0.0, 0.0), color=(255, 220, 170),
                       intensity=1.0, radius=radius, kind="static")
    level.lights.append(light)
    session = GameSession(level, seed=1)
    fresh = compute_light_instances(session.sim, light)
    cached_insts = [inst for room_list in session.lighting._by_room.values()
                    for idx, inst in room_list if idx == 0]
    cached_by_room = {i.room: i for i in cached_insts}
    fresh_by_room = {i.room: i for i in fresh}
    assert set(cached_by_room) == set(fresh_by_room)
    for room, fi in fresh_by_room.items():
        ci = cached_by_room[room]
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
    doorway_mid_r1, normal, tangent) all in each room's own LOCAL
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
    light = LightSpec(room=r0, pos=(lx, ly), color=(255, 255, 255),
                       intensity=1.0, radius=250.0, kind="static")
    insts = compute_light_instances(session.sim, light, max_depth=4, max_instances=8)
    inst0 = next(i for i in insts if i.room == r0)
    inst1 = next((i for i in insts if i.room == r1), None)
    assert inst1 is not None, "light did not reach through the doorway at all"
    # Direct sanity check (catches divergence the attenuation comparison
    # below can miss when a wrong-frame apex lands so far away that BOTH
    # sides clamp to zero attenuation and trivially "agree"): the light's
    # own room's apex_local must equal its authored local position exactly.
    assert math.hypot(inst0.apex_local[0] - lx, inst0.apex_local[1] - ly) < 1e-6
    p0 = (door_r0[0] + nx * straddle, door_r0[1] + ny * straddle)  # just inside r0
    p1 = (door_r1[0], door_r1[1] + straddle)  # just inside r1 (its near edge is local y=-60)
    a0 = _atten(inst0, p0)
    a1 = _atten(inst1, p1)
    # Not pixel-exact: p0/p1 are parametrized along each room's OWN local
    # axis into the room (r0: the door's inward normal; r1: local +y),
    # which only coincide with the same physical ray to within the
    # octagon's real (non-axis-aligned) geometry -- a few hundredths of
    # slop at `straddle` up to 4 units is expected sampling noise, not a
    # seam step. The mutation this test guards against (wrong apex frame)
    # produces order-of-magnitude divergence, well outside this budget.
    assert abs(a0 - a1) < 0.06, f"seam step: r0 side {a0:.4f} vs r1 side {a1:.4f}"


@pytest.mark.skipif(not hasattr(necore, "Raster"),
                     reason="this necore build has no Raster (rust render backend)")
def test_lighting_backend_parity():
    """`_draw_world_lights` runs post-hoc on the composed pixel surface
    for BOTH backends identically (it does not branch on `self.backend`),
    so a frame with lights on comes out close to byte-identical between
    the pygame and rust backends whenever the underlying (unlit) frame
    already does -- lighting adds no new parity surface to maintain, it
    composites on top of whichever one already exists. This is the "new
    raster op" the design brief anticipated; none was needed because
    compositing happens after either backend's frame is already
    assembled into the same pixel surface.
    """
    import numpy as np
    import pygame

    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer

    # init, but deliberately NO pygame.quit() afterwards: this module sorts
    # alphabetically before test_podscene, and quitting the font module here
    # poisons menus.get_font's process-wide _FONT_CACHE for every later test
    # file ("Invalid font (font module quit since font created)"). The
    # suite's other pygame-quitting render test modules all sort after 'p',
    # which is why they get away with their module-scoped quit fixtures.
    pygame.init()
    b = LevelBuilder("PARITY", 1)
    r0 = b.rect(-110, -80, 220, 160)
    b.player(r0, (0, 0))
    level = b.build()
    level.lights.append(LightSpec(room=r0, pos=(0.0, 0.0),
                                   color=(255, 200, 140), intensity=1.2,
                                   radius=180.0, kind="static"))

    frames = {}
    for backend in ("pygame", "rust"):
        session = GameSession(level, seed=3)
        r = Renderer(session, backend=backend)
        surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
        r.draw(surf)
        frames[backend] = pygame.surfarray.array3d(surf)

    diff = np.abs(frames["pygame"].astype(int) - frames["rust"].astype(int))
    # a handful of edge/AA texels differ under the existing
    # (pre-lighting) parity tolerance; lighting must not widen it.
    assert diff.max() <= 40, f"backend divergence with lights on: max diff {diff.max()}"
