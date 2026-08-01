"""A warden eating you must be visible while it eats you.

Nine independent reviewers watched a real 24-minute session; the death
at 02:12 was reported as "arbitrary-feeling and unfair to watch" because
nothing on screen showed an attacker. The mechanism, once found, was
entirely in the colour budget:

    background            luma   0
    warden body           luma  38   (darkest in the palette, ON PURPOSE:
                                      run 37 found overlays dissolved a
                                      light body into a red haze)
    warden rim            luma 236   <- the ONLY legible thing about it
    grip blink            RED        <- rim replaced, exactly during the
                                      grip, while the hurt vignette
                                      floods the screen red

So the signal was painted in the noise's own colour, over a body that is
15% bright, on black. This file guards the colour budget rather than the
pixels of one frame, because the failure is arithmetic: a tell whose
luminance or hue collapses into what covers it is not a tell.
"""

from __future__ import annotations

from perihelion.render import ENEMY_COLOR, ENEMY_RIM, GRIP_RIM


def _luma(c) -> float:
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2]


def _is_red(c) -> bool:
    """Dominantly red — the hurt vignette's channel (160,8,8 / 190,26,26)."""
    return c[0] > 2.0 * max(c[1], c[2])


def test_the_warden_body_is_dark_on_purpose_and_stays_that_way():
    """If this ever brightens, run 37's failure returns instead — the
    guard below only makes sense while the body is this dark."""
    assert _luma(ENEMY_COLOR["warden"]) < 60.0, (
        "the warden body brightened; re-read run 37 before changing the "
        "rim rules, because the two decisions are coupled")


def test_the_grip_signal_is_not_painted_in_the_vignettes_colour():
    """THE DEFECT. A grip drains HP, draining HP floods the screen red,
    so a red grip tell is invisible precisely when it is load-bearing."""
    assert not _is_red(GRIP_RIM), (
        f"the grip blink {GRIP_RIM} is dominantly red, the same channel "
        f"as the hurt vignette it is itself causing")


def test_the_grip_signal_survives_a_black_background():
    """A 38-luma body on a 0-luma floor leaves the rim carrying the whole
    read. It has to be genuinely bright, not merely different."""
    assert _luma(GRIP_RIM) > 150.0, (
        f"grip blink luma {_luma(GRIP_RIM):.0f} is too dim to read "
        f"against a black chamber")


def test_the_grip_signal_is_distinguishable_from_the_resting_rim():
    """It must also not be the SAME as the idle rim, or the grip has no
    tell at all — only a body that stopped moving."""
    rest = ENEMY_RIM["warden"]
    dist = sum(abs(a - b) for a, b in zip(rest, GRIP_RIM))
    assert dist > 120, (
        f"grip rim {GRIP_RIM} is nearly the resting rim {rest}; nothing "
        f"about the picture changes when it takes hold of you")


def test_the_warden_rim_is_what_makes_it_legible_at_all():
    rim, body = ENEMY_RIM["warden"], ENEMY_COLOR["warden"]
    assert _luma(rim) - _luma(body) > 150.0, (
        "the warden's contrast lives entirely in its rim; if that gap "
        "closes the body is unreadable in every state, not just the grip")
