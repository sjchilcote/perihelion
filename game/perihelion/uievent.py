"""Pygame-free UI event vocabulary for the scene layer.

Scenes consume `Event` objects and these integer constants ONLY -- never
pygame. The values are copied verbatim from pygame-ce 2.5.7 (SDL2
keycodes), so `from_pygame` is a field copy, not a translation table, and
call sites read identically to their pygame-era selves.
"""

from __future__ import annotations

from dataclasses import dataclass, field

# -- event types ------------------------------------------------------------
QUIT = 256
KEYDOWN = 768
KEYUP = 769
MOUSEMOTION = 1024
MOUSEBUTTONDOWN = 1025
MOUSEBUTTONUP = 1026
MOUSEWHEEL = 1027
VIDEORESIZE = 32769

# -- key constants ----------------------------------------------------------
K_BACKSPACE = 8
K_TAB = 9
K_RETURN = 13
K_ESCAPE = 27
K_SPACE = 32
K_0 = 48
K_1 = 49
K_2 = 50
K_3 = 51
K_4 = 52
K_5 = 53
K_6 = 54
K_7 = 55
K_8 = 56
K_9 = 57
K_LEFTBRACKET = 91
K_RIGHTBRACKET = 93
K_a = 97
K_b = 98
K_c = 99
K_d = 100
K_e = 101
K_f = 102
K_g = 103
K_h = 104
K_i = 105
K_j = 106
K_k = 107
K_l = 108
K_m = 109
K_n = 110
K_o = 111
K_p = 112
K_q = 113
K_r = 114
K_s = 115
K_t = 116
K_u = 117
K_v = 118
K_w = 119
K_x = 120
K_y = 121
K_z = 122
K_DELETE = 127
K_F5 = 1073741886
K_LEFT = 1073741904
K_RIGHT = 1073741903
K_UP = 1073741906
K_DOWN = 1073741905
K_KP_ENTER = 1073741912
K_KP1 = 1073741913
K_KP2 = 1073741914
K_KP3 = 1073741915
K_LSHIFT = 1073742049
K_RSHIFT = 1073742053

# -- modifier masks ---------------------------------------------------------
KMOD_SHIFT = 3
KMOD_CTRL = 192
KMOD_META = 3072


@dataclass
class Event:
    """One UI event. Field names mirror pygame's event attributes 1:1 so
    converted call sites read the same (`event.key`, `event.pos`, ...)."""
    type: int
    key: int | None = None
    unicode: str = ""
    pos: tuple[int, int] | None = None
    button: int | None = None
    ch: str | None = None
    mod: int = 0          # KEYDOWN/KEYUP modifier bitmask
    x: int = 0            # MOUSEWHEEL horizontal
    y: int = 0            # MOUSEWHEEL vertical
    w: int = 0            # VIDEORESIZE
    h: int = 0            # VIDEORESIZE


def from_pygame(ev) -> Event:
    """Map a pygame event object to an `Event` by duck-typed attribute
    reads (no pygame import -- works on anything event-shaped)."""
    if isinstance(ev, Event):
        return ev
    g = lambda name, default: getattr(ev, name, default)
    return Event(
        type=int(g("type", 0)),
        key=g("key", None),
        unicode=g("unicode", "") or "",
        pos=g("pos", None),
        button=g("button", None),
        ch=g("ch", None),
        mod=int(g("mod", 0) or 0),
        x=int(g("x", 0) or 0),
        y=int(g("y", 0) or 0),
        w=int(g("w", 0) or 0),
        h=int(g("h", 0) or 0),
    )
