"""The objective prompt: the only in-combat text channel. Spoken narrative
lives solely in relay conversations (convscene) and wall terminals; the sim
emits terse ("objective", text) fx for functional state. Radio was
eliminated outright: LevelBuilder.radio() raises rather than staging dead
data, and no radio strip exists.
"""

from __future__ import annotations

import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pytest

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


def test_exit_locked_prompt_uses_key_metadata():
    b = LevelBuilder("t", 1)
    r = b.rect(0, 0, 200, 200)
    b.key_meta("gold", "VALVE WHEEL", "PRESSURE HATCH",
               "PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED",
               "ACQUIRED: VALVE WHEEL")
    b.player(r, (100, 100))
    b.exit(r, (110, 100), key="gold")
    s = GameSession(b.build(), seed=1)
    seen = []
    for _ in range(30):
        s.tick(InputFrame())
        seen += _objectives(s.fx)
    assert seen == ["PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED"]


def test_key_pickup_with_metadata_names_the_object():
    b = LevelBuilder("t", 1)
    r = b.rect(0, 0, 200, 200)
    b.key_meta("red", "VALVE WHEEL", "PRESSURE HATCH",
               "PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED",
               "ACQUIRED: VALVE WHEEL")
    b.player(r, (100, 100))
    b.entity(r, "key_red", (104, 100))  # inside pickup reach
    b.exit(r, (180, 180))
    s = GameSession(b.build(), seed=1)
    s.tick(InputFrame())
    assert "ACQUIRED: VALVE WHEEL" in _objectives(s.fx)
    floats = [ev[3] for ev in s.fx if ev[0] == "pickup_text"]
    assert floats == ["VALVE WHEEL"]
    assert "red" in s.keys


def test_key_pickup_without_metadata_falls_back_to_seal():
    b = LevelBuilder("t", 1)
    r = b.rect(0, 0, 200, 200)
    b.player(r, (100, 100))
    b.entity(r, "key_red", (104, 100))
    b.exit(r, (180, 180))
    s = GameSession(b.build(), seed=1)
    s.tick(InputFrame())
    floats = [ev[3] for ev in s.fx if ev[0] == "pickup_text"]
    assert floats == ["RED SEAL"]
    assert _objectives(s.fx) == []  # generic keys stay silent on the channel


def _door_bump_session(with_meta: bool) -> GameSession:
    b = LevelBuilder("t", 1)
    a = b.rect(0, 0, 200, 200)
    c = b.rect(200, 0, 200, 200)
    b.door_pts(a, (200, 100), c, (200, 100), "red")
    b.no_connect(a, c)
    if with_meta:
        b.key_meta("red", "VALVE WHEEL", "PRESSURE HATCH",
                   "PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED",
                   "ACQUIRED: VALVE WHEEL")
    b.player(a, (150, 100))
    b.exit(c, (300, 100))
    return GameSession(b.build(), seed=1)


def test_locked_door_bump_shows_gate_prompt_once():
    s = _door_bump_session(with_meta=True)
    seen = []
    for _ in range(120):  # shove east into the locked door
        s.tick(InputFrame(mx=1.0))
        seen += _objectives(s.fx)
    assert seen == ["PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED"]


def test_locked_door_bump_without_metadata_falls_back():
    s = _door_bump_session(with_meta=False)
    seen = []
    for _ in range(120):
        s.tick(InputFrame(mx=1.0))
        seen += _objectives(s.fx)
    assert seen == ["DOOR SEALED - RED SEAL REQUIRED"]


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


def test_radio_authoring_raises():
    # radio was eliminated outright: the authoring API itself refuses to
    # stage dead data, rather than silently accepting lines the sim would
    # never surface.
    b = LevelBuilder("t", 1)
    with pytest.raises(RuntimeError):
        b.radio("start", "Ratio: this should never be authored again.")


def test_no_radio_strip_surface_exists():
    import pygame

    from perihelion import menus
    from perihelion.app import GameScene, build_debug_level

    assert not hasattr(menus, "RadioBar")
    pygame.init()  # no quit: font objects are cached across test modules
    scene = GameScene(build_debug_level(), seed=1)
    assert not hasattr(scene, "radio")
    assert scene.objective is None
