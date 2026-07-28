"""Gate run 50's six blockers, pinned. Every one lived in a path the
films and the old suite never walked (live UI text, live mixer behavior,
live input) — these are the contracts that keep them dead.
"""
from __future__ import annotations

import struct

import numpy as np
import pytest

import necore

from perihelion import uievent
from perihelion.levels import LevelBuilder
from perihelion.render import INTERNAL_H, INTERNAL_W
from perihelion.sim import GameSession, InputFrame


# --- B0: plated UI text must draw, not crash -----------------------------

def test_plated_ui_text_draws_on_a_live_game_scene():
    from perihelion.app import GameScene

    b = LevelBuilder("UIPLATE", 1)
    room = b.rect(0, 0, 400, 300)
    b.player(room, (200, 150))
    level = b.build()

    class _App:
        scenes = []
        debug = False
        mouse_pos = (320.0, 180.0)
        game = None

    sc = GameScene.__new__(GameScene)
    sc.session = GameSession(level, seed=1,
                             screen=(INTERNAL_W, INTERNAL_H), zoom=0.45)
    from perihelion.hud import HUD
    from perihelion.render import Renderer
    sc.renderer = Renderer(sc.session)
    sc.hud = HUD()
    sc.objective = ("SENTRY TORN DOWN - TEST OBJECTIVE", 100)
    sc.logvoice = ("a recovered voice line", 100)
    sc.loc_title = ("THE MARROW", 100)
    sc.float_texts = [[320.0, 180.0, "+3c", 30]]
    sc.show_hints = True
    app = _App()
    app.game = sc
    fb = np.zeros((INTERNAL_W, INTERNAL_H, 3), dtype=np.uint8)
    sc.session.tick(InputFrame())
    sc.renderer.consume_fx(sc.session.fx)
    sc.draw_fb(app, fb)          # crashed with TypeError before the fix
    assert int((fb.max(axis=2) > 60).sum()) > 500, "UI text never drew"


# --- B1: the SFX voice pool is capped ------------------------------------

def _mixer_or_skip():
    m = necore.AudioMixer()
    if not m.ready:
        pytest.skip("no audio device")
    return m


def _beep(m, sid, frames=44100):
    data = b"".join(struct.pack("<ff", 0.01, 0.01) for _ in range(frames))
    m.load_sound(sid, data)


def test_sfx_pool_is_capped_at_twelve_voices():
    m = _mixer_or_skip()
    _beep(m, 1)
    for _ in range(40):
        m.sfx_play(1, 0.1, 0.1)
    assert m.sfx_active() <= 12, (
        f"{m.sfx_active()} concurrent SFX voices — the unbounded pool "
        "clipped 124-445 bursts per session (gate run 50)")
    m.stop_all()


# --- B2: queue on an idle channel starts playback ------------------------

def test_queue_on_idle_channel_starts_playing():
    m = _mixer_or_skip()
    _beep(m, 2)
    assert not m.ch_busy(9)
    m.ch_queue(9, 2)             # music lanes ONLY ever queue
    assert m.ch_busy(9), (
        "queued chunk on an idle channel never promoted — PRAYER dies "
        "after any stop/underrun (gate run 50, PRAYER-never-stops law)")
    m.stop_all()


def test_queue_after_stop_all_restarts():
    m = _mixer_or_skip()
    _beep(m, 3)
    m.ch_play(9, 3, 0)
    m.stop_all()
    assert not m.ch_busy(9)
    m.ch_queue(9, 3)
    assert m.ch_busy(9)
    m.stop_all()


# --- B3: OS auto-repeat KEYDOWNs are dropped ------------------------------

def test_auto_repeat_keydowns_are_dropped():
    fresh = uievent.from_platform((1, 0, 0, 0, "Escape", ""))
    repeat = uievent.from_platform((1, 1, 0, 0, "Escape", ""))
    assert fresh is not None and fresh.type == uievent.KEYDOWN
    assert repeat is None, (
        "auto-repeat delivered as a fresh KEYDOWN — holding ESC stacked "
        "a pause menu per repeat (gate run 50)")


# --- B4: mouse-button events carry a position ----------------------------

def test_button_events_carry_cursor_position():
    ev = uievent.from_platform((4, 1, 123, 45, "", ""))
    assert ev.type == uievent.MOUSEBUTTONDOWN and ev.button == 1
    assert ev.pos == (123, 45), (
        "button event without pos — the editor crashed on first click "
        "(gate run 50)")
