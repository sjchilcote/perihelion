"""Scene stack widgets: title/menu screens, pause/death/win, and the
terminal overlay widget (TerminalOverlay) that GameScene drives.

`Scene` is the interface `App` drives: only the top of the stack receives
input/update/draw, which is also how pausing works for free -- GameScene
stops ticking the moment anything is pushed above it.

Pygame-free: scenes draw onto (W, H, 3) uint8 numpy framebuffers via
`draw_fb` (fb2d primitives + text.py's FSEX300 path) and consume
`uievent.Event`s. The old `draw(app, surface)` entry point survives as a
transition shim on `Scene` that wraps the pygame surface's pixel array.
"""

from __future__ import annotations

import math
import random
from pathlib import Path

import numpy as np

from . import fb2d, text, uievent
from .render import INTERNAL_W, INTERNAL_H, ui

PHOSPHOR_GREEN = (90, 240, 140)
DIM_GREEN = (40, 110, 70)

_FONT_CACHE: dict[int, object] = {}

# Fixedsys Excelsior 3.01 — the game's typeface. It is a bitmap-grid design
# meant to be rendered at 16px vertical; sizes snap to multiples of 16 so
# every glyph stays on the pixel grid at the 480x270 internal resolution.
_FONT_PATH = Path(__file__).resolve().parent.parent / "assets" / "fonts" / "FSEX300.ttf"


def _snap(size: int) -> int:
    if size <= 24:
        return 16
    if size <= 40:
        return 32
    return 48


def font_px(size: int) -> int:
    """The pixel size a legacy `get_font(size)` request renders at: snap
    to the bitmap grid, then scale with the internal resolution so text
    occupies the same screen fraction at any PERIHELION_INTERNAL_RES."""
    return ui(_snap(size))


def get_font(size: int):
    # TRANSITION SHIM: dies with app.py's pygame loop (app.py still
    # renders a few labels through pygame.font; every scene in this
    # module uses text.py instead).
    import pygame
    size = font_px(size)
    f = _FONT_CACHE.get(size)
    if f is None:
        if not pygame.font.get_init():
            pygame.font.init()
        try:
            f = pygame.font.Font(str(_FONT_PATH), size)
        except (FileNotFoundError, pygame.error):
            f = pygame.font.Font(None, size)
        _FONT_CACHE[size] = f
    return f


# Generated-art menu backgrounds (tools/artgen). Every scene that draws one
# falls back to its original procedural background if the file is missing
# or fails to load -- the game must run with an empty assets/art/ dir.
_ART_DIR = Path(__file__).resolve().parent.parent / "assets" / "art"
_BG_CACHE: dict[str, "np.ndarray | None"] = {}
_BG_SCALED_CACHE: dict[tuple[str, int, int], np.ndarray] = {}


def _load_bg(name: str) -> "np.ndarray | None":
    """Background art as a (w, h, 3) uint8 array in fb axis order."""
    if name in _BG_CACHE:
        return _BG_CACHE[name]
    arr = None
    stem, dot, ext = name.rpartition(".")
    # prefer the @4x sibling only when the internal resolution actually
    # exceeds the default -- at 640x360 the original stays byte-for-byte
    hi = _ART_DIR / f"{stem}@4x.{ext}" if (dot and INTERNAL_W > 640) \
        else _ART_DIR / name
    try:
        from PIL import Image
        with Image.open(str(hi if hi.exists() else _ART_DIR / name)) as img:
            arr = np.asarray(img.convert("RGB"), dtype=np.uint8).transpose(1, 0, 2)
    except (FileNotFoundError, OSError):
        arr = None
    _BG_CACHE[name] = arr
    return arr


def _blit_bg(fb: np.ndarray, bg: np.ndarray, name: str) -> None:
    w, h = fb.shape[:2]
    if bg.shape[:2] != (w, h):
        key = (name, w, h)
        scaled = _BG_SCALED_CACHE.get(key)
        if scaled is None:
            from PIL import Image
            img = Image.fromarray(bg.transpose(1, 0, 2))
            img = img.resize((w, h), Image.BILINEAR)
            scaled = np.asarray(img, dtype=np.uint8).transpose(1, 0, 2)
            _BG_SCALED_CACHE[key] = scaled
        bg = scaled
    fb[...] = bg


def _wrap(text: str, width: int) -> list[str]:
    lines: list[str] = []
    for para in text.split("\n"):
        if not para.strip():
            lines.append("")
            continue
        cur = ""
        for word in para.split(" "):
            candidate = (cur + " " + word).strip()
            if len(candidate) > width and cur:
                lines.append(cur)
                cur = word
            else:
                cur = candidate
        if cur:
            lines.append(cur)
    return lines or [""]


def _blit_centered(fb, s: str, cx: int, y: int, color, size: int) -> int:
    """Blit `s` centered on x=cx; returns the text width."""
    tw, _ = text.measure(s, size)
    text.blit_text(fb, s, cx - tw // 2, y, color, size)
    return tw


class Scene:
    # scenes that render the running game underneath themselves
    # (pause/death/terminal overlays) set this so the transition shim can
    # pre-draw GameScene onto the pygame surface before wrapping it
    _draws_game_under = False

    def on_enter(self, app) -> None: ...
    def on_exit(self, app) -> None: ...
    def handle_event(self, app, event) -> None: ...
    def update(self, app, dt: float) -> None: ...
    def draw_fb(self, app, fb) -> None: ...

    def draw(self, app, surf) -> None:
        # TRANSITION SHIM: dies with app.py's pygame loop
        import pygame
        game = getattr(app, "game", None)
        if self._draws_game_under and game is not None \
                and not _fb_native(game):
            game.draw(app, surf)  # today's GameScene: pygame surface path
        fb = pygame.surfarray.pixels3d(surf)
        self.draw_fb(app, fb)
        del fb

    def _draw_game_under(self, app, fb) -> None:
        """The fb-native game underlay (no-op under the transition shim,
        which already drew a pygame-era GameScene onto the surface)."""
        game = getattr(app, "game", None)
        if game is not None and _fb_native(game):
            game.draw_fb(app, fb)


def _fb_native(game) -> bool:
    """True when `game` actually overrides draw_fb (the inherited Scene
    stub does not count -- app.py's current GameScene only has the pygame
    `draw`)."""
    fn = getattr(type(game), "draw_fb", None)
    return fn is not None and fn is not Scene.draw_fb


# ---------------------------------------------------------------------------


class TitleScene(Scene):
    def __init__(self):
        self.t = 0.0
        self.sel = 0
        self.items = ["New Game", "Level Select", "Settings", "Quit"]
        self.dust = [(random.uniform(0, INTERNAL_W), random.uniform(0, INTERNAL_H),
                      random.uniform(6, 18)) for _ in range(40)]

    def on_enter(self, app) -> None:
        self.t = 0.0
        app.audio.ambience("amb_drone_early")  # the station is never silent
        if app.save_data.get("ng_plus") and "New Game+" not in self.items:
            self.items.insert(1, "New Game+")

    def update(self, app, dt: float) -> None:
        self.t += dt

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        if event.key in (uievent.K_DOWN, uievent.K_s):
            self.sel = (self.sel + 1) % len(self.items)
        elif event.key in (uievent.K_UP, uievent.K_w):
            self.sel = (self.sel - 1) % len(self.items)
        elif event.key in (uievent.K_RETURN, uievent.K_SPACE):
            self._activate(app)

    def _activate(self, app) -> None:
        item = self.items[self.sel]
        if item == "New Game":
            app.push(DifficultyScene())
        elif item == "New Game+":
            app.push(DifficultyScene(plus=True))
        elif item == "Level Select":
            app.push(LevelSelectScene())
        elif item == "Settings":
            app.push(SettingsScene())
        elif item == "Quit":
            app.quit()

    def draw_fb(self, app, fb) -> None:
        w, h = fb.shape[:2]
        bg = _load_bg("title_bg.png")
        if bg is not None:
            _blit_bg(fb, bg, "title_bg.png")
            fb2d.alpha_fill(fb, (0, 0, 0), 110, (0, 0, w, ui(235)))
        else:
            pulse = 0.5 + 0.5 * math.sin(self.t * 0.6)
            top = (int(14 + 16 * pulse), 4, 6)
            k = np.arange(h, dtype=np.float32) / h
            grad = np.stack([(top[0] * (1 - k)), (top[1] * (1 - k)),
                             (top[2] * (1 - k))], axis=-1).astype(np.uint8)
            fb[...] = grad[None, :, :]
        for x, y, spd in self.dust:
            y2 = (y + self.t * spd) % h
            fb2d.fill(fb, (95, 75, 62), (int(x), int(y2), ui(1), ui(1)))
        _blit_centered(fb, "PERIHELION", w // 2, ui(55), (235, 225, 210), font_px(40))
        _blit_centered(fb, "a descent into non-Euclidean dark", w // 2, ui(98),
                       (150, 120, 110), font_px(12))
        mfs = font_px(16)
        for i, item in enumerate(self.items):
            selected = i == self.sel
            color = (255, 255, 255) if selected else (150, 150, 150)
            prefix = "> " if selected else "  "
            text.blit_text(fb, prefix + item, w // 2 - ui(60),
                           ui(150) + i * ui(20), color, mfs)


class DifficultyScene(Scene):
    """One question between 'New Game' and the dark."""

    def __init__(self, plus: bool = False):
        self.plus = plus
        self.sel = 0
        self.items = [("normal", "NORMAL - the station is hostile"),
                      ("hard", "HARD - the station is hungry")]

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        if event.key in (uievent.K_DOWN, uievent.K_s, uievent.K_UP, uievent.K_w):
            self.sel = 1 - self.sel
        elif event.key in (uievent.K_RETURN, uievent.K_SPACE):
            app.settings["difficulty"] = self.items[self.sel][0]
            app.pop()
            app.start_new_game(plus=self.plus)
        elif event.key == uievent.K_ESCAPE:
            app.pop()

    def draw_fb(self, app, fb) -> None:
        w, h = fb.shape[:2]
        fb2d.fill(fb, (6, 6, 10))
        _blit_centered(fb, "HOW FAR IN ARE YOU?", w // 2, ui(70),
                       (230, 230, 230), font_px(18))
        mfs = font_px(12)
        for i, (_, label) in enumerate(self.items):
            selected = i == self.sel
            color = (255, 255, 255) if selected else (150, 150, 150)
            prefix = "> " if selected else "  "
            _blit_centered(fb, prefix + label, w // 2, ui(130) + i * ui(22),
                           color, mfs)
        text.blit_text(fb, "ESC: back", ui(10), h - ui(16), (110, 110, 110),
                       font_px(10))


class LevelSelectScene(Scene):
    def __init__(self):
        self.sel = 0
        self.levels: list[str] = []
        self.unlocked = 1

    def on_enter(self, app) -> None:
        self.levels = app.campaign_levels()
        self.unlocked = app.save_data.get("unlocked", 1)
        self.sel = 0

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        n = max(1, len(self.levels))
        if event.key in (uievent.K_DOWN, uievent.K_s):
            self.sel = (self.sel + 1) % n
        elif event.key in (uievent.K_UP, uievent.K_w):
            self.sel = (self.sel - 1) % n
        elif event.key in (uievent.K_RETURN, uievent.K_SPACE):
            if self.levels and self.sel < self.unlocked:
                app.start_level_index(self.sel)
        elif event.key == uievent.K_ESCAPE:
            app.pop()

    def draw_fb(self, app, fb) -> None:
        w, h = fb.shape[:2]
        fb2d.fill(fb, (6, 6, 10))
        _blit_centered(fb, "LEVEL SELECT", w // 2, ui(20), (230, 230, 230),
                       font_px(18))
        mfs = font_px(12)
        if not self.levels:
            text.blit_text(fb, "(no campaign manifest -- debug level only)",
                           ui(30), ui(50), (140, 140, 140), mfs)
        for i, path in enumerate(self.levels):
            locked = i >= self.unlocked
            selected = i == self.sel
            color = (90, 90, 90) if locked else ((255, 255, 255) if selected else (170, 170, 170))
            name = f"{i + 1}. {Path(path).stem}" + ("  [locked]" if locked else "")
            text.blit_text(fb, name, ui(40), ui(50) + i * ui(16), color, mfs)
        text.blit_text(fb, "ESC: back", ui(10), h - ui(16), (110, 110, 110),
                       font_px(10))


class SettingsScene(Scene):
    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        if event.key == uievent.K_ESCAPE:
            app._persist_save()  # volume/mute/shake/difficulty survive relaunch
            app.pop()
        elif event.key == uievent.K_LEFT:
            app.audio.set_master(app.audio.master_vol - 0.1)
        elif event.key == uievent.K_RIGHT:
            app.audio.set_master(app.audio.master_vol + 0.1)
        elif event.key == uievent.K_t:
            app.settings["shake"] = not app.settings.get("shake", True)
        elif event.key == uievent.K_m:
            app.audio.set_mute(not app.audio.muted)
        elif event.key == uievent.K_d:
            cur = app.settings.get("difficulty", "normal")
            app.settings["difficulty"] = "hard" if cur == "normal" else "normal"

    def draw_fb(self, app, fb) -> None:
        w, h = fb.shape[:2]
        fb2d.fill(fb, (6, 6, 10))
        _blit_centered(fb, "SETTINGS", w // 2, ui(20), (230, 230, 230),
                       font_px(18))
        mfs = font_px(12)
        lines = [
            f"Master volume: {app.audio.master_vol:.1f}   (left/right)",
            f"Muted: {'yes' if app.audio.muted else 'no'}   (m)",
            f"Screenshake: {'on' if app.settings.get('shake', True) else 'off'}   (t)",
            f"Difficulty: {app.settings.get('difficulty', 'normal')}   (d, next new game)",
            "ESC: back",
        ]
        for i, line in enumerate(lines):
            text.blit_text(fb, line, ui(40), ui(60) + i * ui(18),
                           (180, 180, 180), mfs)


class PauseScene(Scene):
    _draws_game_under = True

    def __init__(self):
        self.sel = 0
        self.items = ["Resume", "Restart Level", "Settings", "Quit to Title"]

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        if event.key == uievent.K_ESCAPE:
            app.pop()
        elif event.key in (uievent.K_DOWN, uievent.K_s):
            self.sel = (self.sel + 1) % len(self.items)
        elif event.key in (uievent.K_UP, uievent.K_w):
            self.sel = (self.sel - 1) % len(self.items)
        elif event.key in (uievent.K_RETURN, uievent.K_SPACE):
            item = self.items[self.sel]
            if item == "Resume":
                app.pop()
            elif item == "Restart Level":
                app.pop()
                app.restart_level()
            elif item == "Settings":
                app.push(SettingsScene())
            elif item == "Quit to Title":
                app.pop_to_title()

    def draw_fb(self, app, fb) -> None:
        self._draw_game_under(app, fb)
        fb2d.alpha_fill(fb, (0, 0, 0), 165)
        w, h = fb.shape[:2]
        _blit_centered(fb, "PAUSED", w // 2, ui(80), (230, 230, 230),
                       font_px(22))
        mfs = font_px(14)
        for i, item in enumerate(self.items):
            selected = i == self.sel
            color = (255, 255, 255) if selected else (150, 150, 150)
            prefix = "> " if selected else "  "
            text.blit_text(fb, prefix + item, w // 2 - ui(60),
                           ui(120) + i * ui(20), color, mfs)


# The cheapest characterization channel in the game: one line of the
# Commando's log per death, in his own register.
COMMANDO_LOGS = [
    "LOG: Stripped the old frame for parts. Prayed the De Profundis "
    "over it first. It is not a body, whatever it feels like. It is not a body.",
    "LOG: Death count rising. The rite does not say how often a man "
    "may be buried. I have started abbreviating.",
    "LOG: I no longer look at the old frames' faces. This is either "
    "mercy or discipline. The hours continue on schedule.",
    "LOG: Lauds, on the internal clock. The clock does not know what "
    "deck I died on. Neither, anymore, do I.",
    "LOG: The seed prints the frames faster now. It has learned my "
    "sizes. I try not to think about what else it is learning.",
    "LOG: Ratio asked if dying hurts. I said the rules require me "
    "not to check. She did not laugh. Neither did I.",
]


class DeathScene(Scene):
    _draws_game_under = True

    def __init__(self, deaths: int, chassis: int = 0):
        self.deaths = deaths
        self.chassis = chassis
        self.t = 0.0

    def update(self, app, dt: float) -> None:
        self.t += dt

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        if event.key in (uievent.K_r, uievent.K_SPACE, uievent.K_RETURN):
            app.pop()
            app.reprint()
        elif event.key == uievent.K_ESCAPE:
            app.pop_to_title()

    def draw_fb(self, app, fb) -> None:
        w, h = fb.shape[:2]
        bg = _load_bg("death_bg.png")
        if bg is not None:
            _blit_bg(fb, bg, "death_bg.png")
        else:
            self._draw_game_under(app, fb)
        fb2d.alpha_fill(fb, (40, 0, 0), 190)
        pulse = 0.6 + 0.4 * math.sin(self.t * 2.0)
        color = (min(255, int(200 * pulse) + 40), 20, 20)
        _blit_centered(fb, "FRAME LOST", w // 2, ui(100), color, font_px(26))
        mfs = font_px(12)
        deaths_text = f"frames lost: {self.deaths}"
        _blit_centered(fb, deaths_text, w // 2, ui(140), (190, 150, 150), mfs)
        if self.chassis > 0:
            rise = (f"SPACE: reprint at the seed"
                    f"   ({self.chassis} chassis racked)    ESC: title")
        else:
            rise = ("SPACE: cold restore - the seed reprints the chunk"
                    "    ESC: title")
        _blit_centered(fb, rise, w // 2, ui(160), (170, 130, 130), mfs)
        log = COMMANDO_LOGS[min(self.deaths - 1, len(COMMANDO_LOGS) - 1)] \
            if self.deaths >= 1 else COMMANDO_LOGS[0]
        y = ui(196)
        words = log.split()
        line = ""
        for word in words + [""]:
            trial = (line + " " + word).strip()
            if word and text.measure(trial, mfs)[0] < w - ui(80):
                line = trial
                continue
            if line:
                _blit_centered(fb, line, w // 2, y, (150, 140, 120), mfs)
                y += ui(16)
            line = word


class WinScene(Scene):
    def __init__(self, text: str):
        self.text = text
        self.scroll_y = 0.0

    def update(self, app, dt: float) -> None:
        self.scroll_y += dt * 10.0

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type == uievent.KEYDOWN and event.key == uievent.K_ESCAPE:
            app.pop_to_title()

    def draw_fb(self, app, fb) -> None:
        w, h = fb.shape[:2]
        bg = _load_bg("win_bg.png")
        if bg is not None:
            _blit_bg(fb, bg, "win_bg.png")
            fb2d.alpha_fill(fb, (0, 0, 0), 100)
        else:
            fb2d.fill(fb, (0, 0, 0))
        fs = font_px(13)
        lines = _wrap(self.text, 56)
        y0 = h - self.scroll_y * (ui(16) / 16.0)
        for i, line in enumerate(lines):
            y = y0 + i * ui(16)
            if -ui(16) <= y <= h:
                _blit_centered(fb, line, w // 2, int(y), (225, 225, 225), fs)
        if self.scroll_y * (ui(16) / 16.0) > len(lines) * ui(16) + h:
            _blit_centered(fb, "ESC: title", w // 2, h - ui(16),
                           (120, 120, 120), font_px(10))


class TerminalOverlay(Scene):
    _draws_game_under = True

    def __init__(self, text: str):
        self.text = text
        self.scroll = 0

    def handle_event(self, app, event) -> None:
        event = uievent.from_pygame(event)
        if event.type != uievent.KEYDOWN:
            return
        if event.key in (uievent.K_e, uievent.K_ESCAPE, uievent.K_RETURN):
            app.pop()
        elif event.key == uievent.K_DOWN:
            self.scroll += 1
        elif event.key == uievent.K_UP:
            self.scroll = max(0, self.scroll - 1)

    def draw_fb(self, app, fb) -> None:
        self._draw_game_under(app, fb)
        w, h = fb.shape[:2]
        fb2d.alpha_fill(fb, (0, 10, 4), 225)
        fb2d.rect(fb, DIM_GREEN,
                  (ui(16), ui(16), w - ui(32), h - ui(32)), max(1, ui(1)))
        fs = font_px(11)
        y = ui(26)
        for line in _wrap(self.text, 62)[self.scroll:]:
            text.blit_text(fb, line, ui(26), y, PHOSPHOR_GREEN, fs)
            y += ui(14)
            if y > h - ui(30):
                break
        hs = font_px(9)
        hw, _ = text.measure("E/ESC: close", hs)
        text.blit_text(fb, "E/ESC: close", w - hw - ui(20), h - ui(26),
                       DIM_GREEN, hs)
