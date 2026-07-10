"""The rust (necore.Raster display-list) backend is a drop-in replacement
for the pygame backend: same layers, same no-seams entity fold, same
darkness — bit-identical frames.

The comparisons here are exact (`==` on the RGB bytes of every sampled
frame). That works because the rust raster's primitives are pixel-exact
ports of pygame-ce's, all dynamic geometry is emitted pre-rounded, detail
prims are float32-snapped at cache time for both backends, and the OP_CLIP_FILL
floor uses the same f64 polygon the coverage mask is filled from.

Renderer effect pools draw from the module-level `random`; the two
renderers under comparison re-seed it identically before each consume_fx
so their gib/spark pools stay in lockstep.
"""

from __future__ import annotations

import os
import random

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pygame
import pytest

import necore

from perihelion.app import build_debug_level
from perihelion.levels import LevelBuilder
from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer
from perihelion.sim import GameSession, InputFrame

pytestmark = pytest.mark.skipif(
    not hasattr(necore, "Raster"),
    reason="this necore build has no Raster (rust render backend)",
)


@pytest.fixture(scope="module")
def pygame_ready():
    pygame.init()
    yield
    pygame.quit()


def _frames_equal_over_run(level, ticks, input_fn, sample_every,
                           screen=(INTERNAL_W, INTERNAL_H), seed=1234):
    session = GameSession(level, seed=seed, screen=screen)
    ren_rust = Renderer(session, backend="rust")
    ren_pg = Renderer(session, backend="pygame")
    surf_rust = pygame.Surface(screen)
    surf_pg = pygame.Surface(screen)
    mismatched = []
    sampled = 0
    for tick in range(1, ticks + 1):
        session.tick(input_fn(tick))
        # keep the two renderers' effect pools in RNG lockstep
        random.seed(tick)
        ren_rust.consume_fx(session.fx)
        random.seed(tick)
        ren_pg.consume_fx(session.fx)
        if tick % sample_every == 0:
            ren_rust.draw(surf_rust)
            ren_pg.draw(surf_pg)
            sampled += 1
            if pygame.image.tobytes(surf_rust, "RGB") != \
                    pygame.image.tobytes(surf_pg, "RGB"):
                mismatched.append(tick)
        if session.dead:
            break
    assert sampled >= 3, "run ended before sampling enough frames"
    return mismatched


def test_backends_render_identical_frames(pygame_ready):
    """Full live fight on the debug level: floors, details, walls, doors,
    entities, muzzle glows, blood decals, hitflashes — every sampled frame
    byte-identical across backends (the no-seams invariant included: any
    divergence in the entity fold would light this up)."""

    def inp(tick):
        return InputFrame(
            mx=1.0, my=0.15 * ((tick // 40) % 2 * 2 - 1),
            ax=INTERNAL_W * 0.62, ay=INTERNAL_H * 0.5,
            fire=(tick % 20) < 8, alt=False,
            interact=(tick % 97 == 0), weapon=0,
        )

    mism = _frames_equal_over_run(build_debug_level(), 180, inp, 15)
    assert not mism, f"backends diverged at ticks {mism}"


def test_backends_identical_through_otherworld(pygame_ready):
    """Otherworld coverage takes the OTHER compositing path in the rust
    backend (raster darkness off, Python inverse-field blend on the blitted
    frame) — frames must still match the pygame backend exactly."""
    b = LevelBuilder("ow_parity", 1)
    r0 = b.rect(0, 0, 200, 150)
    r1 = b.rect(200, 0, 200, 150, kind="otherworld")
    r2 = b.rect(400, 0, 200, 150, kind="otherworld")
    b.entity(r1, "husk", (300.0, 75.0))
    b.player(r0, (100.0, 75.0))
    mism = _frames_equal_over_run(
        b.build(), 300, lambda t: InputFrame(mx=1.0), 30)
    assert not mism, f"backends diverged in/near otherworld at ticks {mism}"


def test_backends_identical_with_hp_sprites(pygame_ready, monkeypatch):
    """PERIHELION_HP_SPRITES=1 must not break backend parity: the sprite
    queue/flush is one shared code path (Renderer._hp_flush, called once
    from Renderer.draw after both backends have finished compositing and
    darkening `surf`), so turning the flag on should still produce
    byte-identical frames across backends -- same fight, same manifest,
    same fully_inside gating, regardless of which backend built `surf`."""
    monkeypatch.setenv("PERIHELION_HP_SPRITES", "1")

    def inp(tick):
        return InputFrame(
            mx=1.0, my=0.15 * ((tick // 40) % 2 * 2 - 1),
            ax=INTERNAL_W * 0.62, ay=INTERNAL_H * 0.5,
            fire=(tick % 20) < 8, alt=False,
            interact=(tick % 97 == 0), weapon=0,
        )

    mism = _frames_equal_over_run(build_debug_level(), 180, inp, 15)
    assert not mism, f"backends diverged with HP sprites on at ticks {mism}"


def test_backend_selection(pygame_ready):
    level = build_debug_level()
    session = GameSession(level, seed=7, screen=(INTERNAL_W, INTERNAL_H))

    # default prefers rust when Raster exists
    assert Renderer(session).backend == "rust"
    # explicit choice wins
    assert Renderer(session, backend="pygame").backend == "pygame"
    # env var wins over the default
    os.environ["PERIHELION_RENDER_BACKEND"] = "pygame"
    try:
        assert Renderer(session).backend == "pygame"
        # explicit arg still beats the env var
        assert Renderer(session, backend="rust").backend == "rust"
    finally:
        del os.environ["PERIHELION_RENDER_BACKEND"]
    # unknown names fail loudly
    with pytest.raises(ValueError):
        Renderer(session, backend="vulkan")


def test_rust_backend_survives_surface_resize(pygame_ready):
    """The raster re-sizes lazily to the draw surface (tests render at
    480x270, the game at 640x360); both sizes must draw and stay
    backend-identical."""
    b = LevelBuilder("resize", 1)
    r0 = b.rect(0, 0, 220, 160)
    b.player(r0, (110.0, 80.0))
    level = b.build()
    session = GameSession(level, seed=3, screen=(480, 270))
    ren = Renderer(session, backend="rust")
    ren_pg = Renderer(session, backend="pygame")
    session.tick(InputFrame())
    ren.consume_fx(session.fx)
    ren_pg.consume_fx(session.fx)
    for size in ((480, 270), (640, 360), (480, 270)):
        s_rust = pygame.Surface(size)
        s_pg = pygame.Surface(size)
        ren.draw(s_rust)
        ren_pg.draw(s_pg)
        assert pygame.image.tobytes(s_rust, "RGB") == \
            pygame.image.tobytes(s_pg, "RGB"), f"diverged at size {size}"
