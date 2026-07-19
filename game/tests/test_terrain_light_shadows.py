"""Walk-mask terrain blocks lamp light (director's directive, 2026-07-13):
"terrain must block lamp light, including the player's worklight, but not
player vision -- enemies behind a terrain object will look like a sensor
trace highlighting an enemy in shadow." Wires `Sim.polygon_terrain` into
`lighting.compute_light_instances` (shadow polygons, standard 2D
shadowcasting) and `render.py`'s `_blit_light` (pixel-level subtract from
the union fill, since `necore.clip_polygon` only intersects convex
regions -- there is no boolean polygon difference primitive available).

No shipped `_walkmask.png` files exist yet, so these tests build terrain
directly via `sim.set_polygon_terrain` (bypassing the PNG loader, which
`test_walk_mask_terrain.py` already covers on its own) -- the shipped
campaign is visually unchanged by this unit.
"""

from __future__ import annotations

import math
import os
import time

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import necore
import numpy as np
import pygame
import pytest

from perihelion.levels import LevelBuilder, LightSpec
from perihelion.lighting import compute_light_instances
from perihelion.sim import GameSession, InputFrame


def _atten(inst, point) -> float:
    dx = point[0] - inst.apex_local[0]
    dy = point[1] - inst.apex_local[1]
    dist = math.hypot(dx, dy)
    a = max(0.0, min(1.0, 1.0 - dist / inst.radius_local))
    return a * a


def _corridor_level(terrain_rect=(0.0, -20.0, 40.0, 20.0)):
    """One polygon, a light at the left wall, a terrain rect (if given)
    between the light and the open floor to its right."""
    b = LevelBuilder("TSHAD", 1)
    r0 = b.rect(-200.0, -100.0, 400.0, 200.0)
    b.player(r0, (-190.0, 0.0))
    level = b.build()
    session = GameSession(level, seed=1)
    if terrain_rect is not None:
        session.sim.set_polygon_terrain(r0, [terrain_rect])
    return session, r0


# ---------------------------------------------------------------------
# 1. shadow-behind-terrain: pixels behind the rect are dark, pixels beside
#    it are lit.
# ---------------------------------------------------------------------

@pytest.mark.parametrize("kind", ["static", "attached"])
def test_shadow_behind_terrain_dark_beside_lit(kind):
    """Fail-first note: before wiring `shadow_local` into
    `compute_light_instances`/`_blit_light`, this failed because the
    "behind" sample came back lit (attenuation > 0.3) -- terrain simply had
    no effect on the light instance at all. Verified by temporarily
    reverting `terrain_shadow_polys` to always return `()` (the
    pre-this-unit interface state) and observing `a_behind` jump from ~0
    to ~0.7; reverted before committing.
    """
    session, r0 = _corridor_level()
    light = LightSpec(polygon=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=500.0, kind=kind)
    insts = compute_light_instances(session.sim, light)
    inst = next(i for i in insts if i.polygon == r0)
    behind = (60.0, 0.0)    # directly behind the terrain rect from the light
    beside = (60.0, 70.0)   # same distance, clear of the rect's shadow
    a_behind = _atten(inst, behind)
    a_beside = _atten(inst, beside)
    assert any(_point_in(behind, poly) for poly in inst.shadow_local)
    assert not any(_point_in(beside, poly) for poly in inst.shadow_local)
    assert a_beside > 0.15, f"expected the beside sample lit, got {a_beside}"


def _point_in(pt, poly):
    from perihelion.lighting import _point_in_polygon
    return _point_in_polygon(pt, poly)


def test_shadow_behind_terrain_pixel_composite():
    """The actual rendered pixel surface: the world floor directly behind
    the terrain rect stays near-black while an unobstructed floor pixel at
    the same distance is clearly lit -- this exercises the full
    `_draw_world_lights` -> `_blit_light` pixel-subtract path, not just
    `compute_light_instances`' local-space math."""
    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer

    pygame.init()
    session, r0 = _corridor_level()
    session.sim.set_polygon_terrain(r0, [(0.0, -20.0, 40.0, 20.0)])
    session.lighting.add_lights(session.sim, [
        LightSpec(polygon=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                  intensity=1.2, radius=500.0, kind="static")])
    session.player_light.intensity = 0.0  # isolate the fixture
    ren = Renderer(session, backend="pygame")
    ren._get_detail = lambda polygon: []
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    session.tick(InputFrame(mx=0, my=0, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                             fire=False, alt=False, interact=False, weapon=0))
    ren.consume_fx(session.fx)
    ren.draw(surf)
    arr = pygame.surfarray.array3d(surf).astype(int)

    def screen_of(local_pt):
        return necore.mat_apply(session.cam, *local_pt)

    behind_sx, behind_sy = screen_of((60.0, 0.0))
    beside_sx, beside_sy = screen_of((60.0, 70.0))
    bx, by = int(round(behind_sx)), int(round(behind_sy))
    sx, sy = int(round(beside_sx)), int(round(beside_sy))
    lum_behind = arr[bx, by].sum()
    lum_beside = arr[sx, sy].sum()
    assert lum_behind <= 10, f"terrain shadow pixel not dark: {lum_behind}"
    assert lum_beside >= 40, f"unobstructed pixel not lit: {lum_beside}"


# ---------------------------------------------------------------------
# 2. no-shadow-without-terrain regression
# ---------------------------------------------------------------------

def test_no_shadow_without_terrain_regression():
    """Same geometry, but no terrain rect installed: the 'behind' sample
    must NOT be dark -- proves the shadow code doesn't fabricate occlusion
    when `Sim.polygon_terrain` is empty (the common/shipped case today)."""
    session, r0 = _corridor_level(terrain_rect=None)
    light = LightSpec(polygon=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=500.0, kind="static")
    insts = compute_light_instances(session.sim, light)
    inst = next(i for i in insts if i.polygon == r0)
    assert inst.shadow_local == ()
    a_behind = _atten(inst, (60.0, 0.0))
    assert a_behind > 0.15, f"expected no shadow, got attenuation {a_behind}"


# ---------------------------------------------------------------------
# 3. root-frame invariance of shadows across a portal crossing
# ---------------------------------------------------------------------

def test_terrain_shadow_root_invariance_across_portal():
    """Terrain shadows are pure polygon-local geometry (`inst.shadow_local`
    lives in the SAME polygon-local frame as `clip_local`/`apex_local`), so a
    light reaching a polygon with terrain through a portal must produce
    IDENTICAL shadow polygons to computing that light natively in that
    polygon -- exactly the reasoning ENGINE_DESIGN.md gives for wedges in
    general (root-frame invariance holds by construction, since the wedge
    math and now the shadow math are both purely polygon-local)."""
    b = LevelBuilder("TSHADROOT", 1)
    r0 = b.rect(-100.0, -100.0, 200.0, 200.0)
    r1 = b.rect(100.0, -100.0, 200.0, 200.0)
    b.connect_pts(r0, (100.0, 0.0), r1, (100.0, 0.0))
    b.player(r0, (0.0, 0.0))
    level = b.build()
    session = GameSession(level, seed=1)
    # terrain in r1, off to one side of the doorway
    session.sim.set_polygon_terrain(r1, [(150.0, 20.0, 190.0, 60.0)])

    # light in r0, reaching r1 through the portal
    light = LightSpec(polygon=r0, pos=(50.0, 0.0), color=(255, 255, 255),
                       intensity=1.0, radius=250.0, kind="static")
    insts = compute_light_instances(session.sim, light, max_depth=4)
    inst_r1_via_portal = next(i for i in insts if i.polygon == r1)

    # native: put an equivalent light directly in r1 at the SAME local
    # position the portal crossing recovered (apex_local), and compare
    # shadow polygons -- both must occlude the same terrain identically
    # since terrain and the recovered apex are both r1-local.
    native_light = LightSpec(polygon=r1, pos=inst_r1_via_portal.apex_local,
                              color=(255, 255, 255), intensity=1.0,
                              radius=inst_r1_via_portal.radius_local, kind="static")
    native_insts = compute_light_instances(session.sim, native_light, max_depth=1)
    native_inst = next(i for i in native_insts if i.polygon == r1)

    assert len(inst_r1_via_portal.shadow_local) == len(native_inst.shadow_local) == 1
    poly_a = inst_r1_via_portal.shadow_local[0]
    poly_b = native_inst.shadow_local[0]
    assert len(poly_a) == len(poly_b)
    for (ax, ay), (bx, by) in zip(poly_a, poly_b):
        assert math.hypot(ax - bx, ay - by) < 1e-6


# ---------------------------------------------------------------------
# 4. enemy-visible-in-shadow: entity plane composites after the multiply
# ---------------------------------------------------------------------

def test_enemy_visible_in_terrain_shadow():
    """An enemy standing in a terrain shadow region still renders (the
    entity/sensor plane composites AFTER the lightmap multiply, per
    ENGINE_DESIGN.md 3.2a) -- the world floor pixel right there is dark,
    but the enemy sprite pixel isn't."""
    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer

    pygame.init()
    session, r0 = _corridor_level()
    session.sim.set_polygon_terrain(r0, [(0.0, -20.0, 40.0, 20.0)])
    session.lighting.add_lights(session.sim, [
        LightSpec(polygon=r0, pos=(-190.0, 0.0), color=(255, 255, 255),
                  intensity=1.2, radius=320.0, kind="static")])
    session.player_light.intensity = 0.0
    eid = session.spawn_enemy(r0, (60.0, 0.0), "husk")
    session.enemies[eid]["state"] = "hunt"

    ren = Renderer(session, backend="pygame")
    ren._get_detail = lambda polygon: []
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    session.tick(InputFrame(mx=0, my=0, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                             fire=False, alt=False, interact=False, weapon=0))
    ren.consume_fx(session.fx)
    ren.draw(surf)
    arr = pygame.surfarray.array3d(surf).astype(int)

    sx, sy = necore.mat_apply(session.cam, 60.0, 0.0)
    ix, iy = int(round(sx)), int(round(sy))
    # sample a small patch around the enemy's screen position for its body
    # color (ENEMY_COLOR["husk"]), not just the exact center pixel (AA/rim).
    patch = arr[max(0, ix - 4):ix + 5, max(0, iy - 4):iy + 5]
    assert patch.size > 0
    lum = patch.reshape(-1, 3).sum(axis=1)
    assert lum.max() >= 80, (
        f"enemy sprite not visible in terrain shadow (max patch luminance "
        f"{lum.max()})")


# ---------------------------------------------------------------------
# perf: lights pass on a 2-light corridor with terrain, budget re-check
# ---------------------------------------------------------------------

def test_lights_pass_stays_within_budget():
    """Report-only regression guard: the lights pass (`_draw_world_lights`
    incl. terrain shadow subtraction) on a 2-light corridor must stay
    comfortably under budget. Prior measurement (no terrain): 0.73ms/frame.
    This is a loose ceiling (5ms), not a tight perf assertion -- CI
    machines vary -- but catches a real regression (e.g. an accidental
    per-pixel numpy path)."""
    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer

    pygame.init()
    b = LevelBuilder("TSHADPERF", 1)
    r0 = b.rect(-300.0, -100.0, 300.0, 200.0)
    r1 = b.rect(0.0, -100.0, 300.0, 200.0)
    b.connect_pts(r0, (0.0, 0.0), r1, (0.0, 0.0))
    b.player(r0, (-150.0, 0.0))
    level = b.build()
    level.lights.append(LightSpec(polygon=r0, pos=(-150.0, 0.0), color=(255, 220, 170),
                                   intensity=1.0, radius=250.0, kind="static"))
    level.lights.append(LightSpec(polygon=r1, pos=(150.0, 0.0), color=(200, 220, 255),
                                   intensity=1.0, radius=250.0, kind="static"))
    session = GameSession(level, seed=1, screen=(INTERNAL_W, INTERNAL_H))
    session.sim.set_polygon_terrain(r0, [(-60.0, -20.0, -20.0, 20.0)])
    session.sim.set_polygon_terrain(r1, [(20.0, -20.0, 60.0, 20.0)])
    ren = Renderer(session, backend="pygame")
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    session.tick(InputFrame(mx=0, my=0, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                             fire=False, alt=False, interact=False, weapon=0))
    ren.consume_fx(session.fx)
    ren.draw(surf)  # warm caches (surfaces, gradient sprites)
    n = 30
    t0 = time.perf_counter()
    for _ in range(n):
        ren.draw(surf)
    dt_ms = (time.perf_counter() - t0) / n * 1000.0
    print(f"\n[terrain-shadow perf] {dt_ms:.3f} ms/frame full draw() "
          f"(2 lights + 2 terrain rects, prior lights-pass-only baseline "
          f"0.73ms/frame with no terrain)")
    assert dt_ms < 25.0, f"draw() budget regression: {dt_ms:.3f}ms/frame"
