"""Minimalist lo-fi HUD: HP (bottom-left), weapon/ammo (bottom-right), keys
(top-right), crosshair. Pure pygame.draw + small bitmap font, no Surface
allocation beyond what pygame.font.render necessarily returns per string.
"""

from __future__ import annotations

import math

import pygame

from .sim import WEAPONS, LIGHTNING_RECHARGE_TICKS, PLAYER_HP
from .render import KEY_COLORS

_FONT_CACHE: dict[int, "pygame.font.Font"] = {}


def _font(size: int) -> "pygame.font.Font":
    from .menus import get_font
    return get_font(size)


AMMO_LABEL = {"pistol": "9mm", "smg": "9mm", "shotgun": "shell", "rail": "cell", "tau": "cell"}


class HUD:
    def draw(self, surf: "pygame.Surface", session, mouse_pos=None) -> None:
        w, h = surf.get_size()
        if getattr(session.level, "vigil", False):
            img = _font(11).render(f"WAVE {session.metrics.get('wave', 0)}",
                                   True, (200, 190, 170))
            surf.blit(img, (6, 24))
        self._draw_hp(surf, session, h)
        self._draw_economy(surf, session)
        self._draw_weapon(surf, session, w, h)
        self._draw_keys(surf, session, w)
        if mouse_pos is not None:
            self._draw_crosshair(surf, session, mouse_pos)

    def _draw_hp(self, surf, session, h):
        # top-left, clear of the bottom-right weapon/ammo cluster
        bar_w, bar_h = 70, 5
        x, y = 6, 12
        low = session.hp < 35 and not session.dead
        pulse = 0.5 + 0.5 * math.sin(session.tick_count * 0.35) if low else 1.0
        # pulse floor stays readable: at the old floor the digit hit
        # (40,40,40) mid-pulse — invisible exactly when hp matters most
        color = (int(120 * pulse) + 115, 45, 45) if low else (235, 235, 235)
        # backing plate: combat debris/glyphs behind the corner otherwise
        # render right through the digits
        img = _font(11).render(f"{max(0, int(session.hp))}", True, color)
        plate_w = bar_w + 12 + img.get_width()
        pygame.draw.rect(surf, (12, 12, 16), (x - 3, y - 8, plate_w, 18))
        pygame.draw.rect(surf, (40, 40, 40), (x, y, bar_w, bar_h))
        frac = max(0.0, min(1.0, session.hp / PLAYER_HP))
        pygame.draw.rect(surf, color, (x, y, int(bar_w * frac), bar_h))
        pygame.draw.rect(surf, (90, 90, 90), (x, y, bar_w, bar_h), 1)
        surf.blit(img, (x + bar_w + 6, y - 6))

    def _draw_economy(self, surf, session):
        # under the hp bar: salvage and racked hulls (only once either
        # exists -- the HUD stays clean until the economy is live)
        comp = getattr(session, "components", 0)
        chas = getattr(session, "chassis", 0)
        kits = getattr(session, "station_kits", 0)
        if not (comp or chas or kits):
            return
        text = f"{comp}c"
        if chas:
            text += f"  {chas} chassis"
        if kits:
            text += f"  {kits} kit"
        # Void node: the count that will not stop being counted
        if "loss_ledger_display" in getattr(session, "mind_unlocks", ()):
            text += f"  {session.metrics.get('deaths', 0)} lost"
        y = 38 if getattr(session.level, "vigil", False) else 24
        img = _font(11).render(text, True, (170, 200, 180))
        pygame.draw.rect(surf, (12, 12, 16),
                         (3, y - 2, img.get_width() + 6, 14))
        surf.blit(img, (6, y))

    def _draw_weapon(self, surf, session, w, h):
        name = session.weapon
        f = _font(11)
        if name == "lightning":
            frac = min(1.0, session.lightning_charge / LIGHTNING_RECHARGE_TICKS)
            cx, cy, r = w - 16, h - 20, 9
            pygame.draw.circle(surf, (40, 40, 50), (cx, cy), r, 1)
            if frac > 0.0:
                start = -math.pi / 2
                end = start + frac * 2 * math.pi
                steps = max(1, int(frac * 24))
                pts = [(cx, cy)]
                for i in range(steps + 1):
                    a = start + (end - start) * (i / max(1, steps))
                    pts.append((cx + math.cos(a) * r, cy + math.sin(a) * r))
                if len(pts) >= 3:
                    color = (120, 240, 255) if frac >= 1.0 else (70, 130, 150)
                    pygame.draw.polygon(surf, color, [(int(px), int(py)) for px, py in pts])
            label = f.render("LIGHTNING", True, (200, 235, 255))
            surf.blit(label, (w - 16 - label.get_width() - 16, h - 34))
        else:
            ammo_t = AMMO_LABEL.get(name)
            if name == "hole":
                count = str(getattr(session, "holes", 0))
                if session.hole_mark is not None:
                    count += "*"  # one wall marked
            elif name == "lightning":
                ready = session.lightning_charge >= LIGHTNING_RECHARGE_TICKS
                count = "RDY" if ready else                     f"{int(100 * session.lightning_charge / LIGHTNING_RECHARGE_TICKS)}%"
            elif ammo_t is None:
                count = "∞"
            else:
                count = str(session.ammo.get(ammo_t, 0))
                if name == "tau" and session.tau_charge > 0:
                    count += f" [{min(100, int(100 * session.tau_charge / 80))}%]"
            label = f.render(f"{name.upper()}  {count}", True, (230, 230, 230))
            surf.blit(label, (w - label.get_width() - 8, h - 16))

    def _draw_keys(self, surf, session, w):
        from .render import draw_key_glyph
        x = w - 12
        y = 8
        for key in sorted(session.keys):
            color = KEY_COLORS.get(key, (200, 170, 60))
            meta = getattr(session, "held_key_meta", {}).get(key)
            item = getattr(meta, "item_name", None)
            if not draw_key_glyph(surf, item, x, y + 5, 5, color):
                pygame.draw.circle(surf, color, (x, y + 4), 4)
                pygame.draw.circle(surf, (0, 0, 0), (x, y + 4), 4, 1)
            x -= 16

    def _draw_crosshair(self, surf, session, mouse_pos):
        mx, my = mouse_pos
        weapon = WEAPONS.get(session.weapon, {})
        if session.weapon == "lightning":
            frac_ready = min(1.0, session.lightning_charge / LIGHTNING_RECHARGE_TICKS)
            expand = (1.0 - frac_ready) * 4.0
        else:
            maxcd = weapon.get("cd") or 1
            expand = (session.cooldown / maxcd) * 4.0 if maxcd else 0.0
        size = 3 + expand
        color = (220, 240, 240)
        pygame.draw.line(surf, color, (mx - size, my), (mx - 2, my), 1)
        pygame.draw.line(surf, color, (mx + 2, my), (mx + size, my), 1)
        pygame.draw.line(surf, color, (mx, my - size), (mx, my - 2), 1)
        pygame.draw.line(surf, color, (mx, my + 2), (mx, my + size), 1)
