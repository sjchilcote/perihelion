"""The objective prompt: the only in-combat text channel. Spoken narrative
lives solely in relay conversations (convscene) and wall terminals; the sim
emits terse ("objective", text) fx for functional state, and authored
level.radio triggers are consumed as nothing. No radio strip exists.
"""

from __future__ import annotations

import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

from perihelion.levels import LevelBuilder
from perihelion.sim import GameSession, InputFrame


def _objectives(fx) -> list[str]:
    return [ev[1] for ev in fx if ev[0] == "objective"]


def _locked_exit_session() -> GameSession:
    b = LevelBuilder("t", 1)
    r = b.rect(0, 0, 200, 200)
    b.player(r, (100, 100))  # local (0, 0) after re-centering
    b.exit(r, (110, 100), key="gold")  # local (10, 0): inside the 18u radius
    return GameSession(b.build(), seed=1)


def test_exit_locked_shows_seal_prompt_once_while_standing():
    s = _locked_exit_session()
    seen = []
    for _ in range(60):
        s.tick(InputFrame())
        seen += _objectives(s.fx)
    assert seen == ["EXIT SEALED - GOLD SEAL REQUIRED"]
    assert not s.complete


def test_exit_locked_prompt_rearms_after_walking_away():
    s = _locked_exit_session()
    s.tick(InputFrame())
    assert _objectives(s.fx) == ["EXIT SEALED - GOLD SEAL REQUIRED"]
    for _ in range(90):  # walk west, well out of the exit radius
        s.tick(InputFrame(mx=-1.0))
    seen = []
    for _ in range(240):  # walk back east across the exit pad
        s.tick(InputFrame(mx=1.0))
        seen += _objectives(s.fx)
        if seen:
            break
    assert seen == ["EXIT SEALED - GOLD SEAL REQUIRED"]


def test_exit_gated_by_warden_names_the_holder():
    b = LevelBuilder("t", 1)
    r0 = b.rect(0, 0, 200, 200)
    r1 = b.rect(200, 0, 200, 200)
    b.player(r0, (100, 100))
    b.exit(r0, (110, 100), gate_kind="warden")
    b.entity(r1, "warden", (300, 100))
    s = GameSession(b.build(), seed=1)
    seen = []
    for _ in range(10):
        s.tick(InputFrame())
        seen += _objectives(s.fx)
    assert "EXIT SEALED - THE WARDEN HOLDS THE DOOR" in seen
    assert not s.complete


def test_weapon_pickup_emits_acquired_prompt():
    b = LevelBuilder("t", 1)
    r = b.rect(0, 0, 200, 200)
    b.player(r, (100, 100))
    b.entity(r, "weapon_tau", (104, 100))  # inside pickup reach
    b.exit(r, (180, 180))
    s = GameSession(b.build(), seed=1)
    s.tick(InputFrame())
    assert "ACQUIRED: TAU CANNON" in _objectives(s.fx)
    assert "tau" in s.weapons


def test_authored_radio_triggers_are_consumed_as_nothing():
    # the debug level still authors a "start" radio line (the authoring API
    # is intact) -- the game must never surface it as fx
    from perihelion.app import build_debug_level

    level = build_debug_level()
    assert level.radio, "debug level should still author radio data"
    s = GameSession(level, seed=1)
    tags = set()
    for _ in range(120):
        s.tick(InputFrame(mx=1.0))
        tags |= {ev[0] for ev in s.fx}
    assert "radio" not in tags


def test_no_radio_strip_surface_exists():
    import pygame

    from perihelion import menus
    from perihelion.app import GameScene, build_debug_level

    assert not hasattr(menus, "RadioBar")
    pygame.init()  # no quit: font objects are cached across test modules
    scene = GameScene(build_debug_level(), seed=1)
    assert not hasattr(scene, "radio")
    assert scene.objective is None
