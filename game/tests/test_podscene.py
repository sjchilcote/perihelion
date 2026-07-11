"""The seed-pod UI (SEEDPOD_UI_DESIGN.md): page drawing, the expansion
rite's lifecycle (commit-at-start, skip gating, queue chaining), fog of
war, and keyboard navigation -- headless, dummy video driver."""

import math
import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pygame
import pytest

from perihelion import mindmap
from perihelion.levels import LevelBuilder
from perihelion.podscene import CAM_GLIDE_DUR
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


# ---------------------------------------------------------------------------
# the camera glide (director's hybridization, superseding the earlier
# "yanked to the center...drifted back...when released" pin): selection
# now moves podscene's CAMERA to frame the selected node's ring, never the
# node itself -- no node is ever exempt from its own depth-annulus band,
# selected or not. These tests exercise the WIRING (page/settle/rite
# precedence, selection-change starts a glide, the node stays confined to
# its band throughout) rather than re-deriving the physics bounds -- see
# test_mindmap_layout.py's annulus/camera_glide properties for those.
# Physics mode is the only one with live node motion (rings mode glides
# the camera over STATIC node positions, already covered by
# test_mindmap_rings.py), so these tests pin the mode explicitly instead
# of inheriting PERIHELION_MINDMAP_LAYOUT from the environment.
# ---------------------------------------------------------------------------

@pytest.fixture(autouse=False)
def _physics_mode(monkeypatch):
    from perihelion import podscene
    monkeypatch.setattr(podscene, "MINDMAP_LAYOUT", "physics")


def test_selecting_a_node_glides_the_camera_toward_it(_physics_mode):
    sc, s, app = _scene()
    sc.on_enter(app)
    sc.page = "mind"
    sc._ensure_selection()
    _run(sc, app, 1.0)  # past the open-settle; camera already at initial sel
    sc._nav(1, 0)
    assert sc.sel != sc._cam_sel  # the glide hasn't started ticking yet
    sc.update(app, 1 / 60)
    assert sc._cam_sel == sc.sel  # update() latches the new target...
    assert sc._cam["dur"] > 0.0   # ...and animates toward it, not a snap
    _run(sc, app, CAM_GLIDE_DUR + 0.5)
    camx, camy = sc._cam_pos()
    tx, ty = sc.layout[sc.sel]
    assert math.hypot(camx - tx, camy - ty) < 1e-6  # exact finite-time arrival


def test_node_never_leaves_its_band_while_selected(_physics_mode):
    """The director's hard law: selection may move the CAMERA, but no
    node -- selected or not -- may ever cross its own depth-ring boundary.
    Selection sweeps across several nodes while the live physics keeps
    ticking; every node's position is checked against its OWN band on
    every tick."""
    from perihelion import mindmap
    sc, s, app = _scene()
    sc.on_enter(app)
    sc.page = "mind"
    sc._ensure_selection()
    bands = mindmap.node_bands()
    vis = sorted(sc._visible())
    for i in range(90):  # 1.5s: several settle/glide cycles
        if i % 20 == 0:
            sc._nav(1, 0) if (i // 20) % 2 else sc._nav(-1, 0)
        sc.update(app, 1 / 60)
        for nid in vis:
            x, y = sc._node_pos(nid)
            r = math.hypot(x, y)
            lo, hi = bands[nid]
            assert lo - 1e-6 <= r <= hi + 1e-6, (nid, r, lo, hi)


def test_label_renders_fit_canonical_boxes(surf):
    """The bridge between mindmap.py's pygame-free label geometry (the
    measured Plex advance table) and the ACTUAL renderer: every real-map
    label, rendered exactly the way podscene renders it (same face, same
    pt formula), must fit inside its canonical layout box scaled to the
    surface -- at the default internal width and at 2x (1280) -- otherwise
    the non-occlusion proof would be about boxes the renderer ignores.
    1px slack per axis for integer rounding of the blit rect."""
    from perihelion.podscene import _label_img, label_pt
    lay = mindmap.layout()
    labels = mindmap.label_layout(lay)
    tbl = mindmap.nodes()
    for k in (1.0, 2.0):  # 640-wide and 1280-wide surfaces
        for nid, info in labels.items():
            l, t, r, b = info["box"]
            font_px = info["font_px"]
            img = _label_img(tbl[nid]["label"], label_pt(font_px, k),
                             (200, 200, 200))
            assert img.get_width() <= (r - l) * k + 1.0, (
                nid, k, img.get_width(), (r - l) * k)
            assert img.get_height() <= (b - t) * k + 1.0, (
                nid, k, img.get_height(), (b - t) * k)


def test_region_headers_render_at_reserved_width(surf):
    """The header draw (per-char, letterspaced) must stay inside the
    width region_header_size_px reserved for it -- sum the same advances
    the draw steps by and compare against a real render of each glyph."""
    from perihelion.podscene import _label_img
    for region, info in mindmap.region_header_layout().items():
        label = info["label"]
        w_reserved, h_reserved = mindmap.region_header_size_px(label)
        scale = mindmap.HEADER_CELL_PX / mindmap.LABEL_H_PX
        pt = mindmap.LABEL_FONT_PT * scale
        x = 0.0
        max_right = 0.0
        for ch in label:
            img = _label_img(ch, pt, (200, 200, 200), "medium")
            max_right = max(max_right, x + img.get_width())
            x += mindmap.text_width_px(ch, "medium") * scale + mindmap.HEADER_TRACK_PX
        assert max_right <= w_reserved + 1.0, (region, max_right, w_reserved)


def test_camera_suspended_during_rite(_physics_mode):
    sc, s, app = _scene(think_done=["vocation-just-war"])
    sc.on_enter(app)
    assert sc.rite is not None
    # force a selection the camera has NOT yet glided to, simulating a
    # mid-ceremony change -- the rite's own camera math (_to_screen) owns
    # the view regardless, so this must never start a selection glide
    sc.sel = next(nid for nid in sc._visible() if nid != sc._cam_sel)
    for _ in range(120):  # 2s mid-ceremony
        sc.update(app, 1 / 60)
    assert sc._cam["dur"] == 0.0  # no glide ever started
    assert sc._cam_sel != sc.sel  # update() never latched the new target
