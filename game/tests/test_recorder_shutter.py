"""The recorder integrates its window; it does not sample it.

Telemetry capture runs below sim rate. Done by decimation — keep one
frame in three, drop the rest — everything that existed only in the
dropped frames is gone from the record, and its absence there gets read
as absence from the GAME. That is not hypothetical: a round the player
fired, looping back through a portal to hit him in the back, was
reviewed as "damage with no visible threat" and came within an inch of
having a working mechanic "fixed", because the reviewer sampled every
two seconds and a tracer crosses in far less.

A lower frame rate is a longer shutter, not a smaller sample.
"""

from __future__ import annotations

import numpy as np
import pytest

from perihelion.app import shutter_blend

H, W = 8, 32


def _fb_with_dot(x: int, value: int = 255) -> np.ndarray:
    fb = np.zeros((H, W, 4), dtype=np.uint8)
    fb[4, x] = (value, value, value, 255)
    return fb


def _blend(frames) -> np.ndarray:
    acc = np.zeros((H, W, 4), dtype=np.uint16)
    for f in frames:
        acc += f
    raw = shutter_blend(acc, len(frames))
    return np.frombuffer(raw, dtype=np.uint8).reshape(H, W, 4)


def test_a_moving_dot_survives_at_every_position_it_occupied():
    """THE LAW. Decimation would leave exactly one of these."""
    out = _blend([_fb_with_dot(x) for x in (2, 10, 20)])
    lit = [x for x in range(W) if out[4, x, 0] > 0]
    assert lit == [2, 10, 20], (
        f"a dot at 2, 10 and 20 recorded as lit columns {lit} — the "
        f"shutter is dropping frames instead of integrating them")


def test_a_still_scene_is_unchanged_by_the_blend():
    """Integrating must not dim or smear what did not move, or every
    static frame pays for the moving ones."""
    fb = _fb_with_dot(7)
    out = _blend([fb, fb, fb])
    assert np.array_equal(out, fb), "a motionless scene was altered"


def test_brightness_is_shared_across_the_positions_it_visited():
    """A thing present for one of three ticks reads at a third of its
    brightness — that IS the information: how long it was there."""
    out = _blend([_fb_with_dot(5), np.zeros((H, W, 4), np.uint8),
                  np.zeros((H, W, 4), np.uint8)])
    assert 60 <= int(out[4, 5, 0]) <= 100, (
        f"a one-in-three appearance recorded at {out[4, 5, 0]}, not ~85")


def test_a_full_frame_is_a_full_frame():
    """every=1 is an open shutter for exactly one tick: no change."""
    fb = _fb_with_dot(11)
    out = _blend([fb])
    assert np.array_equal(out, fb)


def test_blending_nothing_is_refused_rather_than_dividing_by_zero():
    with pytest.raises(ValueError):
        shutter_blend(np.zeros((H, W, 4), dtype=np.uint16), 0)


def test_the_accumulator_cannot_overflow_at_realistic_cadences():
    """uint16 holds 255*n up to n=257; the recorder's cadence is single
    digits. This guards the type choice, not the arithmetic."""
    acc = np.zeros((H, W, 4), dtype=np.uint16)
    white = np.full((H, W, 4), 255, dtype=np.uint8)
    for _ in range(60):
        acc += white
    out = np.frombuffer(shutter_blend(acc, 60), dtype=np.uint8).reshape(H, W, 4)
    assert out.min() == 255, "the accumulator wrapped"
