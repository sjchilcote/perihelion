"""The seed-pod UI (SEEDPOD_UI_DESIGN.md): page drawing, the expansion
rite's lifecycle (commit-at-start, skip gating, queue chaining), fog of
war, and keyboard navigation -- headless, dummy video driver."""

import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pygame
import pytest

from perihelion import mindmap
from perihelion.levels import LevelBuilder
from perihelion.render import INTERNAL_H, INTERNAL_W
from perihelion.sim import GameSession


@pytest.fixture(scope="module")
def surf():
    pygame.init()
    pygame.display.set_mode((INTERNAL_W, INTERNAL_H))
    return pygame.Surface((INTERNAL_W, INTERNAL_H))


class _StubAudio:
    def __init__(self):
        self.played: list[str] = []
        self.duck = 1.0

    def play(self, name, vol=1.0, pan=0.5):
        self.played.append(name)

    def duck_ambience(self, frac):
        self.duck = frac


class _StubApp:
    def __init__(self):
        self.audio = _StubAudio()
        self.popped = 0

    def pop(self):
        self.popped += 1


def _level():
    b = LevelBuilder("POD", 1)
    r0 = b.rect(0, 0, 260, 180, kind="dock")
    b.player(r0, (60, 90))
    b.exit(r0, (200, 90))
    return b.build()


def _scene(**st):
    from perihelion.podscene import PodScene
    s = GameSession(_level(), seed=1, player_state=st or None)
    return PodScene(s), s, _StubApp()


def _run(sc, app, secs):
    for _ in range(int(secs * 60)):
        sc.update(app, 1 / 60)


def test_pod_opens_on_fabricator_and_heals(surf):
    sc, s, app = _scene(components=20, hp=30)
    sc.on_enter(app)
    assert sc.page == "fabricator"
    assert s.hp == s.max_hp  # entering the pod heals
    sc.draw(app, surf)  # both pages draw without error
    sc.page = "mind"
    sc._ensure_selection()
    sc.draw(app, surf)


def test_fabricator_buys_through_the_pod(surf):
    sc, s, app = _scene(components=20)
    sc.on_enter(app)
    sc.fab_sel = sc.FAB_ORDER.index("chassis")
    ev = pygame.event.Event(pygame.KEYDOWN, key=pygame.K_RETURN)
    sc.handle_event(app, ev)
    assert s.chassis == 1 and sc.flash > 0


def test_hero_panel_prefers_art_else_vector_glyph(surf, tmp_path, monkeypatch):
    from perihelion import podscene
    sc, s, app = _scene(components=20)
    sc.on_enter(app)
    # no art on disk: the fallback (vector glyph) is the live path
    assert sc._hero_art("chassis") is None
    sc.draw(app, surf)
    # with art on disk it is found and cached
    monkeypatch.setattr(podscene, "HERO_DIR", tmp_path)
    art = pygame.Surface((32, 32))
    art.fill((90, 60, 30))
    pygame.image.save(art, str(tmp_path / "chassis.png"))
    sc._hero_cache.clear()
    got = sc._hero_art("chassis")
    assert got is not None and got.get_size() == (32, 32)
    sc.draw(app, surf)


def test_fog_of_war_shows_unlocked_plus_frontier_only():
    sc, s, app = _scene(mind=["vocation-just-war"])
    vis = sc._visible()
    assert "vocation-just-war" in vis
    assert "vocation-doctrine-of-restraint" in vis  # frontier
    assert "vocation-protected-revival" not in vis  # deep fog


def test_rite_commits_unlock_at_start_and_reveals_after(surf):
    sc, s, app = _scene(think_done=["vocation-just-war"])
    sc.on_enter(app)  # a finished thought: the pod opens on MIND, mid-rite
    assert sc.page == "mind" and sc.rite is not None
    assert "vocation-just-war" in s.mind  # committed at rite start
    assert not s.think_done
    # new neighbors are held back until the rite's reveal
    assert "vocation-doctrine-of-restraint" not in sc._visible()
    _run(sc, app, 4.0)
    sc.draw(app, surf)
    assert "vocation-doctrine-of-restraint" in sc._visible()
    _run(sc, app, 1.5)
    assert sc.rite is None  # the rite concluded on its own
    assert app.audio.played  # the ignition cue fired


def test_rite_skippable_only_after_first_beat():
    sc, s, app = _scene(think_done=["vocation-just-war"])
    sc.on_enter(app)
    ev = pygame.event.Event(pygame.KEYDOWN, key=pygame.K_SPACE)
    sc.handle_event(app, ev)
    assert sc.rite is not None  # too early: the first beat must play
    _run(sc, app, 1.5)
    sc.handle_event(app, ev)
    assert sc.rite is None  # skipped after the beat
    assert "vocation-just-war" in s.mind


def test_rite_queue_chains():
    sc, s, app = _scene(
        think_done=["vocation-just-war", "history-the-long-peace"])
    sc.on_enter(app)
    first = sc.rite["node"]
    _run(sc, app, 1.5)
    sc.handle_event(app, pygame.event.Event(pygame.KEYDOWN, key=pygame.K_SPACE))
    assert sc.rite is not None and sc.rite["node"] != first  # the next rite
    _run(sc, app, 1.5)
    sc.handle_event(app, pygame.event.Event(pygame.KEYDOWN, key=pygame.K_SPACE))
    assert sc.rite is None
    assert {"vocation-just-war", "history-the-long-peace"} <= s.mind


def test_corrupted_rite_dips_ambience_and_restores():
    node = "void-arithmetic-of-futility"
    pre = mindmap.nodes()[node]["prereqs"]
    assert mindmap.nodes()[node]["faith"] < 0
    sc, s, app = _scene(mind=pre, think_done=[node])
    sc.on_enter(app)
    assert sc.rite["kind"] == "corrupt"
    _run(sc, app, 2.6)
    assert app.audio.duck < 1.0  # the ambient dips as the bloom sours
    assert "rite_sour" in app.audio.played
    _run(sc, app, 3.0)
    assert sc.rite is None and app.audio.duck == 1.0  # restored


def test_enter_sets_focus_and_nav_walks_edges():
    sc, s, app = _scene()
    sc.on_enter(app)
    sc.page = "mind"
    sc._ensure_selection()
    sc.sel = "vocation-just-war"
    sc.handle_event(app, pygame.event.Event(pygame.KEYDOWN, key=pygame.K_RETURN))
    assert s.think_focus == "vocation-just-war"
    # directional nav lands on some other visible node, deterministically
    before = sc.sel
    sc.handle_event(app, pygame.event.Event(pygame.KEYDOWN, key=pygame.K_LEFT))
    a = sc.sel
    sc.sel = before
    sc.handle_event(app, pygame.event.Event(pygame.KEYDOWN, key=pygame.K_LEFT))
    assert sc.sel == a and a in sc._visible()


def test_escape_seals_the_pod():
    sc, s, app = _scene()
    sc.on_enter(app)
    sc.handle_event(app, pygame.event.Event(pygame.KEYDOWN, key=pygame.K_ESCAPE))
    assert app.popped == 1
