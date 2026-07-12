"""Director-ordered occlusion gate (2026-07-11): "the light will need to
be, you know - occluded." Small, fast, deterministic check derived
straight from tools/playtest/light_occlusion_demo.py's own world and
scripted walk: builds the same handcrafted rooms, runs the SAME input
tape up to each shot's marked tick, and probes the SAME world points the
full capture verifies -- lit points must read bright, dark points must
read near-black, and the contrast ratio must be extreme. No video
encode here (that's the capture tool's job); this is the geometry/render
invariant the demo exists to prove, gated in CI.

Root-cause note for future maintainers of this world: LevelBuilder rooms
authored on a SHARED absolute canvas (so two rooms' walls are exactly
collinear beyond just their doorway) get every coincident wall segment
autoconnected by `resolve()`, not just the intended door -- silently
deleting the walls this test exists to prove light stops at. Every
doorway in the demo world is paired with an explicit `no_connect` to
suppress that trap; `test_no_spurious_autoconnects` below guards the
count directly.
"""
from __future__ import annotations

import importlib.util
import os
import sys
from pathlib import Path

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
os.environ.setdefault("PERIHELION_INTERNAL_RES", "1280x720")

import pygame  # noqa: E402
import pytest  # noqa: E402

_TOOL = Path(__file__).resolve().parents[2] / "tools" / "playtest" / "light_occlusion_demo.py"
_spec = importlib.util.spec_from_file_location("light_occlusion_demo", _TOOL)
locc = importlib.util.module_from_spec(_spec)
sys.modules["light_occlusion_demo"] = locc
_spec.loader.exec_module(locc)

from perihelion.render import INTERNAL_H, INTERNAL_W, Renderer  # noqa: E402
from perihelion.sim import GameSession, InputFrame  # noqa: E402

# One connect per authored doorway (13: A-B, B-C, C-M, D-M, E-M, M-CORR,
# CORR-SD, SD-DS, and 5x SD-SL) -- see the module docstring's root-cause
# note. A regression here means a "solid" wall segment got silently wired
# open again.
EXPECTED_DOOR_COUNT = 13


def test_no_spurious_autoconnects():
    level, _meta = locc.build_world()
    assert len(level.connects) == EXPECTED_DOOR_COUNT, (
        f"{len(level.connects)} connects, expected {EXPECTED_DOOR_COUNT} -- "
        "a room pair on the shared canvas is autoconnecting beyond its "
        "authored doorway (see module docstring)")


def _run_to_marks(marks_needed: set[str]):
    pygame.init()
    level, meta = locc.build_world()
    session = GameSession(level, seed=11, screen=(INTERNAL_W, INTERNAL_H))
    ren = Renderer(session)
    # bright floor albedo, same as the capture: under zero ambient the
    # lightmap MULTIPLIES the world, so the floor color caps every lit
    # pixel -- the default debug-world floor (26,26,33) would make even a
    # saturated wedge read black (see the demo's brightness-chain note)
    locc.apply_demo_floor(ren, level)
    surf = pygame.Surface((INTERNAL_W, INTERNAL_H))
    script = locc.build_script()
    still_ticks = {t: name for name, t in script.marks.items()}
    last_tick = max(t for t, name in still_ticks.items() if name in marks_needed)
    probes_at: dict[str, list] = {}
    for tick in range(1, last_tick + 1):
        mx, my = script.input_at(tick - 1)
        session.tick(InputFrame(mx=mx, my=my, ax=INTERNAL_W / 2, ay=INTERNAL_H / 2,
                                fire=False, alt=False, interact=False, weapon=0))
        ren.consume_fx(session.fx)
        ren.draw(surf)
        if tick in still_ticks:
            name = still_ticks[tick]
            if name in marks_needed and name in locc.PROBES:
                resolved = []
                for label, room_key, wx, wy, expect in locc.PROBES[name]:
                    room = meta[room_key]
                    sxy = locc.screen_xy_for(session, ren, room, wx, wy)
                    resolved.append((label, sxy, expect))
                probes_at[name] = resolved
    return surf, probes_at


def _brightness(surf, sxy, box=4) -> float:
    assert sxy is not None, "probe point not in any visible clip this frame"
    x, y = int(round(sxy[0])), int(round(sxy[1]))
    arr = pygame.surfarray.pixels3d(surf)
    w, h = surf.get_size()
    x0, x1 = max(0, x - box), min(w, x + box + 1)
    y0, y1 = max(0, y - box), min(h, y + box + 1)
    region = arr[x0:x1, y0:y1].astype(float)
    del arr
    return float(region.mean())


@pytest.mark.parametrize("mark", [
    "shot1_start",   # the doorway cone
    "shot3_end",     # the two-hop bend: far corner stays dark
    "shot4_end",     # the two-source cross
])
def test_shot_contrast(mark):
    surf, probes_at = _run_to_marks({mark})
    probes = probes_at[mark]
    lit = [_brightness(surf, sxy) for _label, sxy, expect in probes if expect == "lit"]
    dark = [_brightness(surf, sxy) for _label, sxy, expect in probes if expect == "dark"]
    assert lit and dark
    # absolute gates (director's order after capture 1: 88x ratios of
    # near-nothing certified an all-but-black frame) -- lit must be
    # unmistakably bright, dark must be essentially black; the ratio
    # remains as a third, redundant check.
    assert min(lit) >= locc.LIT_MIN, (
        f"{mark}: a 'lit' probe read {min(lit):.1f}, "
        f"want >= {locc.LIT_MIN} (metric-passes-eye-fails guard)")
    assert max(dark) <= locc.DARK_MAX, (
        f"{mark}: a 'dark' probe read {max(dark):.1f} (light bleed?)")
    ratio = min(lit) / max(0.5, max(dark))
    assert ratio >= 10.0, f"{mark}: contrast ratio {ratio:.1f}x, want >= 10x"
