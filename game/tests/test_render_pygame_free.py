"""U0 construction gate: the render path is pygame-free, permanently.

The reverted base shipped a pygame renderer; the ratified correction
(DESIGN_7_25.md, IMPLEMENTATION CORRECTIONS #1) is that the render path
imports no pygame and there is exactly one shipping renderer. This gate
makes silent reintroduction impossible: it walks the AST of every
render-path module, so a `import pygame` smuggled inside a function body
or a `from pygame import Rect` both fail, not just top-level imports.

Fail-first evidence: this test fails on the parent of the commit that
introduced it (render.py at d85d3765 imports pygame at module top).
"""
from __future__ import annotations

import ast
from pathlib import Path

import pytest

PKG = Path(__file__).resolve().parent.parent / "perihelion"

# The render path: everything between GameSession state and the pixels.
RENDER_PATH_MODULES = ["render.py", "hud.py", "text.py"]


def _imported_roots(path: Path) -> set[str]:
    tree = ast.parse(path.read_text(), filename=str(path))
    roots: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for a in node.names:
                roots.add(a.name.split(".")[0])
        elif isinstance(node, ast.ImportFrom):
            if node.module is not None and node.level == 0:
                roots.add(node.module.split(".")[0])
    return roots


@pytest.mark.parametrize("modname", RENDER_PATH_MODULES)
def test_render_path_module_imports_no_pygame(modname):
    roots = _imported_roots(PKG / modname)
    assert "pygame" not in roots, (
        f"{modname} imports pygame — the render path must stay pygame-free "
        f"(DESIGN_7_25 IMPLEMENTATION CORRECTIONS #1)")


def test_exactly_one_renderer_backend():
    """No second backend may reappear: one canonical renderer, no
    backend= selection, no _PygameCanvas twin."""
    src = (PKG / "render.py").read_text()
    assert "_PygameCanvas" not in src, "the deleted pygame canvas is back"
    tree = ast.parse(src)
    for node in ast.walk(tree):
        if isinstance(node, ast.ClassDef) and node.name == "Renderer":
            init = next((n for n in node.body
                         if isinstance(n, ast.FunctionDef) and n.name == "__init__"),
                        None)
            assert init is not None
            argnames = [a.arg for a in init.args.args + init.args.kwonlyargs]
            assert "backend" not in argnames, (
                "Renderer grew a backend selector — one shipping renderer only")
            break
    else:
        pytest.fail("class Renderer not found in render.py")


def test_draw_returns_numpy_frame():
    """draw() must hand back the (W, H, 3) uint8 framebuffer — callers blit
    the RETURN VALUE; a renderer that draws onto a hidden surface and
    returns None would pass imports while being unusable."""
    import numpy as np
    from perihelion.levels import LevelBuilder
    from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer
    from perihelion.sim import GameSession, InputFrame

    b = LevelBuilder("PYGFREE", 1)
    r0 = b.rect(-120.0, -120.0, 240.0, 240.0)
    b.player(r0, (0.0, 0.0))
    session = GameSession(b.build(), seed=7, screen=(INTERNAL_W, INTERNAL_H))
    ren = Renderer(session)
    session.tick(InputFrame())
    ren.consume_fx(session.fx)
    frame = ren.draw((INTERNAL_W, INTERNAL_H))
    assert isinstance(frame, np.ndarray)
    assert frame.shape == (INTERNAL_W, INTERNAL_H, 3)
    assert frame.dtype == np.uint8
