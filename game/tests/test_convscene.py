"""ConversationScene machinery (kept for the director's hand-written
scenes) + the blanked-placeholder contract: no gap plays any placeholder
conversation, and the App's gap hook is a clean no-op."""
from __future__ import annotations

import os

os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
os.environ.setdefault("SDL_AUDIODRIVER", "dummy")

import pygame
import pytest

from perihelion.conversations import COMMANDO, RATIO, conversation_for
from perihelion.convscene import ConversationScene


class _StubAudio:
    def play(self, name, vol=1.0):
        pass


class _StubApp:
    def __init__(self):
        self.audio = _StubAudio()
        self.popped = 0

    def pop(self):
        self.popped += 1


@pytest.fixture(scope="module")
def surf():
    pygame.init()
    return pygame.Surface((480, 270))


def test_every_gap_is_silent_until_the_directors_scripts():
    for gap in range(-1, 12):
        for trust in (-14, -1, 0, 3):
            assert conversation_for(gap, trust, []) is None


def test_scene_rejects_empty_or_unknown_speaker():
    with pytest.raises(ValueError):
        ConversationScene([])
    with pytest.raises(ValueError):
        ConversationScene([("NARRATOR", "hi")])


def test_scene_plays_synthetic_lines_to_completion(surf):
    trust_seen = []
    sc = ConversationScene(
        [(RATIO, "Line one."), (COMMANDO, "Line two."), (RATIO, "Line three.")],
        on_trust=trust_seen.append)
    app = _StubApp()
    for _ in range(60 * 60):
        sc.update(app, 1 / 60)
        sc.draw(app, surf)
        if app.popped:
            break
        # idle-advance: scene must complete without input
    assert app.popped == 1
    assert trust_seen == [0]
