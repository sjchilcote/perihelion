"""Diegetic lo-fi HUD, drawn straight onto the renderer's numpy framebuffer
(no pygame). Three readouts in the game's own typeface (FSEX300, via
`text.py` -- the same path menus use), plus the aiming crosshair:

    * health         -- number + thin bar, bottom-left, reddening as it drops
    * weapon + ammo  -- current weapon and its remaining rounds, bottom-left
    * salvage        -- banked components, top-left

Kept minimal and monochrome-warm to sit in the Marathon register: small dark
backing plates for legibility over floor debris, no banners, no chrome. The
hurt vignette still carries the "you are bleeding" read (render's _draw_post);
this HUD is the exact numeric state.
"""

from __future__ import annotations

import numpy as np

from .sim import WEAPONS, LIGHTNING_RECHARGE_TICKS
from .render import INTERNAL_RES_ZOOM_SCALE, ui
from . import text

_INK = (225, 214, 180)        # warm parchment, the HUD's default type color
_PLATE = (12, 12, 16)         # near-black backing plate
_HP_OK = (150, 210, 160)
_HP_LOW = (214, 96, 84)
_AMMO = (150, 196, 220)
_CROSS = (220, 240, 240)


def _fill(fb, x, y, w, h, color, alpha=255):
    """Fill (or alpha-blend) a screen-space rect on the (W, H, 3) frame."""
    W, H, _ = fb.shape
    x0, y0 = max(0, int(x)), max(0, int(y))
    x1, y1 = min(W, int(x + w)), min(H, int(y + h))
    if x1 <= x0 or y1 <= y0:
        return
    region = fb[x0:x1, y0:y1]
    if alpha >= 255:
        region[...] = np.asarray(color, dtype=np.uint8)
    else:
        col = np.asarray(color, dtype=np.uint16)
        d = region.astype(np.uint16)
        region[...] = ((col * alpha + d * (255 - alpha) + 127) // 255).astype(np.uint8)


class HUD:
    def draw(self, fb, session, mouse_pos=None) -> None:
        """Paint the HUD onto `fb` (the renderer's (W, H, 3) numpy frame).
        `mouse_pos` is the aim point in internal-resolution pixels."""
        self._draw_salvage(fb, session)
        self._draw_health(fb, session)
        self._draw_weapon(fb, session)
        if mouse_pos is not None:
            self._draw_crosshair(fb, session, mouse_pos)

    # -- readouts -------------------------------------------------------

    def _plate(self, fb, x, y, w, h):
        _fill(fb, x - ui(3), y - ui(2), w + ui(6), h + ui(4), _PLATE, alpha=190)

    def _draw_salvage(self, fb, session) -> None:
        comp = int(getattr(session, "components", 0))
        s = f"{comp}c"
        size = ui(16)
        tw, th = text.measure(s, size)
        x, y = ui(6), ui(6)
        self._plate(fb, x, y, tw, th)
        text.blit_text(fb, s, x, y, _INK, size)

    def _draw_health(self, fb, session) -> None:
        W, H, _ = fb.shape
        hp = max(0, int(getattr(session, "hp", 0)))
        maxhp = max(1, int(getattr(session, "max_hp", 100)))
        frac = min(1.0, hp / maxhp)
        col = _HP_LOW if frac <= 0.34 else _HP_OK
        size = ui(16)
        label = f"{hp}"
        tw, th = text.measure(label, size)
        x = ui(6)
        y = H - ui(6) - th
        self._plate(fb, x, y, tw + ui(5) + ui(44), th)
        text.blit_text(fb, label, x, y, col, size)
        # thin bar to the right of the number
        bx = x + tw + ui(5)
        bw = ui(44)
        by = y + th // 2 - ui(1)
        _fill(fb, bx, by, bw, ui(3), (40, 44, 50))
        _fill(fb, bx, by, max(ui(1), int(bw * frac)), ui(3), col)

    def _draw_weapon(self, fb, session) -> None:
        W, H, _ = fb.shape
        name = getattr(session, "weapon", "")
        spec = WEAPONS.get(name, {})
        atype = spec.get("ammo")
        if atype is None:
            ammo_str = ""            # melee: no ammo readout
        elif atype == "components":
            ammo_str = f"{int(getattr(session, 'components', 0))}"
        else:
            ammo_str = f"{int(getattr(session, 'ammo', {}).get(atype, 0))}"
        size = ui(16)
        label = name.upper()
        tw, th = text.measure(label, size)
        # sits just above the health line
        _, hh = text.measure("0", ui(16))
        y = H - ui(6) - hh - ui(3) - th
        x = ui(6)
        aw = 0
        if ammo_str:
            aw = text.measure(ammo_str, size)[0] + ui(6)
        self._plate(fb, x, y, tw + aw, th)
        text.blit_text(fb, label, x, y, _INK, size)
        if ammo_str:
            text.blit_text(fb, ammo_str, x + tw + ui(6), y, _AMMO, size)

    # -- crosshair ------------------------------------------------------

    def _draw_crosshair(self, fb, session, mouse_pos) -> None:
        mx, my = mouse_pos
        weapon = WEAPONS.get(session.weapon, {})
        if session.weapon == "lightning":
            frac_ready = min(1.0, session.lightning_charge / LIGHTNING_RECHARGE_TICKS)
            expand = (1.0 - frac_ready) * 4.0
        else:
            maxcd = weapon.get("cd") or 1
            expand = (session.cooldown / maxcd) * 4.0 if maxcd else 0.0
        s = INTERNAL_RES_ZOOM_SCALE
        size = (3 + expand) * s
        gap = 2 * s
        wdt = max(1, ui(1))
        cx, cy = int(mx), int(my)
        h = wdt // 2
        # four axis-aligned ticks (filled thin rects, so no line rasterizer)
        _fill(fb, cx - size, cy - h, size - gap, wdt, _CROSS)          # left
        _fill(fb, cx + gap, cy - h, size - gap, wdt, _CROSS)           # right
        _fill(fb, cx - h, cy - size, wdt, size - gap, _CROSS)          # up
        _fill(fb, cx - h, cy + gap, wdt, size - gap, _CROSS)           # down
