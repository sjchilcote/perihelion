"""The UI/scene layer is pygame-free: every scene draws onto a plain
(W, H, 3) numpy framebuffer via draw_fb (fb2d + text.py) and consumes
uievent.Events. No module in the package may import pygame at ANY scope
-- the transition shims are gone; the whole package is converted."""

from __future__ import annotations

import ast
import re
from pathlib import Path

import numpy as np
import pytest

from perihelion import convscene, fb2d, menus, uievent
from perihelion.levels import LevelBuilder
from perihelion.render import INTERNAL_H, INTERNAL_W
from perihelion.sim import GameSession

PKG = Path(__file__).resolve().parent.parent / "perihelion"

CONVERTED = sorted(
    p.relative_to(PKG).as_posix() for p in PKG.rglob("*.py")
    if "__pycache__" not in p.parts)


# ---------------------------------------------------------------------------
# structure: no pygame import anywhere in the package, at any scope
# ---------------------------------------------------------------------------

@pytest.mark.parametrize("rel", CONVERTED)
def test_no_pygame_import_at_any_scope(rel):
    src = (PKG / rel).read_text()
    assert not re.search(r"^import pygame|^from pygame", src, re.M), (
        f"{rel} imports pygame at module level")
    # AST double-check: no Import/ImportFrom of pygame anywhere -- not even
    # lazily inside a function body (the transition shims are gone)
    tree = ast.parse(src)
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            names = [a.name.split(".")[0] for a in node.names]
        elif isinstance(node, ast.ImportFrom):
            names = [(node.module or "").split(".")[0]]
        else:
            continue
        assert "pygame" not in names, (
            f"{rel}: pygame import (line {node.lineno})")


# ---------------------------------------------------------------------------
# behavior: scenes draw real pixels onto a bare numpy fb, no pygame init
# ---------------------------------------------------------------------------

class _StubAudio:
    master_vol = 0.7
    muted = False

    def play(self, name, vol=1.0, pan=0.5): ...
    def ambience(self, name): ...
    def duck_ambience(self, frac): ...


class _StubApp:
    def __init__(self):
        self.audio = _StubAudio()
        self.save_data = {}
        self.settings = {}
        self.game = None
        self.popped = 0

    def pop(self):
        self.popped += 1


def _fb() -> np.ndarray:
    return np.zeros((INTERNAL_W, INTERNAL_H, 3), dtype=np.uint8)


def _pod_scene():
    from perihelion.podscene import PodScene
    b = LevelBuilder("POD", 1)
    r0 = b.rect(0, 0, 260, 180, kind="dock")
    b.player(r0, (60, 90))
    b.exit(r0, (200, 90))
    s = GameSession(b.build(), seed=1)
    return PodScene(s)


def test_title_scene_draws_on_numpy_fb():
    app = _StubApp()
    sc = menus.TitleScene()
    sc.on_enter(app)
    sc.update(app, 0.25)
    fb = _fb()
    sc.draw_fb(app, fb)
    assert int((fb.sum(axis=2) > 0).sum()) > 1000


def test_pause_scene_draws_on_numpy_fb():
    app = _StubApp()
    sc = menus.PauseScene()
    fb = _fb()
    sc.draw_fb(app, fb)
    assert int((fb.sum(axis=2) > 0).sum()) > 500  # PAUSED + menu items


def test_conversation_scene_draws_on_numpy_fb():
    app = _StubApp()
    sc = convscene.ConversationScene(
        [("RATIO", "Signal check."), ("COMMANDO", "Copy.")])
    sc.shown = 6.0
    fb = _fb()
    sc.draw_fb(app, fb)
    assert int((fb.sum(axis=2) > 0).sum()) > 1000


def test_pod_scene_both_pages_draw_on_numpy_fb():
    app = _StubApp()
    sc = _pod_scene()
    sc.on_enter(app)
    fb = _fb()
    sc.draw_fb(app, fb)          # fabricator page
    n_fab = int((fb.sum(axis=2) > 0).sum())
    assert n_fab > 1000
    sc.handle_event(app, uievent.Event(type=uievent.KEYDOWN, key=uievent.K_TAB))
    sc.update(app, 0.9)          # settle underway
    fb2 = _fb()
    sc.draw_fb(app, fb2)         # mind page
    assert int((fb2.sum(axis=2) > 0).sum()) > 1000


def test_scenes_consume_uievent_and_duck_typed_pygame_events():
    app = _StubApp()
    sc = menus.TitleScene()
    sc.on_enter(app)
    sc.handle_event(app, uievent.Event(type=uievent.KEYDOWN, key=uievent.K_DOWN))
    assert sc.sel == 1

    class _FakePygameEvent:  # duck-typed: no pygame involved
        type = uievent.KEYDOWN
        key = uievent.K_UP
    sc.handle_event(app, _FakePygameEvent())
    assert sc.sel == 0


def test_fb2d_primitives_write_expected_pixels():
    fb = np.zeros((40, 30, 3), dtype=np.uint8)
    fb2d.rect(fb, (255, 0, 0), (2, 3, 10, 5))
    assert tuple(fb[2, 3]) == (255, 0, 0) and tuple(fb[11, 7]) == (255, 0, 0)
    assert tuple(fb[12, 3]) == (0, 0, 0)
    fb2d.rect(fb, (0, 255, 0), (20, 3, 8, 8), 1)          # outline only
    assert tuple(fb[20, 3]) == (0, 255, 0)
    assert tuple(fb[23, 6]) == (0, 0, 0)                  # hollow center
    fb2d.line(fb, (0, 0, 255), (0, 20), (39, 20))
    assert tuple(fb[15, 20]) == (0, 0, 255)
    fb2d.circle(fb, (255, 255, 0), (10, 25), 3)
    assert tuple(fb[10, 25]) == (255, 255, 0)
    ov = fb2d.overlay(40, 30)
    fb2d.polygon(ov, (100, 100, 100, 128), [(30, 20), (38, 20), (34, 28)])
    fb2d.blit(fb, ov)
    assert tuple(fb[34, 22]) == (50, 50, 50)              # 128/255 blend
