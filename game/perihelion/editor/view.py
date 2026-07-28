"""Drafting-canvas view + input handling for the level editor.

All actual level-editing logic lives in `model.EditorModel` (no pygame
there); this module is purely: camera transform, drawing (fb2d onto a
numpy framebuffer), and translating mouse/keyboard gestures (uievent
events) into model calls. Kept separate on purpose so
`game/tests/test_editor.py` can exercise the model headlessly with zero
window-system surface area. Only `run()`'s window/event pump still
touches pygame, lazily, until app.py's loop dies.
"""

from __future__ import annotations

import math
import os
import subprocess
import tempfile
from pathlib import Path

from .. import fb2d, text, uievent
from ..menus import font_px
from ..render import ENEMY_COLOR, KEY_COLORS
from . import model as M

REPO_ROOT = Path(__file__).resolve().parents[3]

WINDOW_W, WINDOW_H = 1440, 900
STATUS_H = 22

BG = (16, 18, 22)
GRID_COLOR = (32, 36, 44)
GRID_AXIS = (52, 58, 70)
POLYGON_FILL = (30, 46, 56)
POLYGON_FILL_SEL = (44, 70, 62)
POLYGON_EDGE = (150, 205, 225)
POLYGON_ID_COLOR = (120, 150, 165)
VERTEX_COLOR = (215, 225, 235)
VERTEX_SEL = (255, 220, 80)
VERTEX_BAD = (255, 70, 70)
CONNECT_NORMAL = (80, 225, 225)
CONNECT_X = (225, 100, 225)
CONNECT_DOOR = (216, 160, 60)
CONNECT_SELF = (235, 70, 70)
CONNECT_SEL = (255, 255, 255)
WARN_COLOR = (255, 205, 40)
PLAYER_COLOR = (140, 230, 255)
EXIT_COLOR = (120, 255, 172)
TERMINAL_COLOR = (150, 210, 255)
LORE_POLYGON_TINT = (60, 90, 60)
STATUS_BG = (10, 11, 13)
STATUS_OK = (120, 230, 140)
STATUS_ERR = (255, 110, 110)
STATUS_TEXT = (210, 214, 220)
PREVIEW_COLOR = (255, 255, 255)
DIRTY_DOT = (255, 200, 60)

PICKUP_COLORS = {
    "ammo_9mm": (210, 200, 110), "ammo_shell": (210, 170, 100),
    "ammo_cell": (140, 210, 220), "medkit": (120, 220, 140),
    "weapon_smg": (200, 200, 210), "weapon_shotgun": (200, 200, 210),
    "weapon_rail": (200, 200, 210), "implant_lightning": (205, 242, 255),
}
GLYPH = {
    "husk": "H", "mite": "m", "spitter": "S", "brute": "B",
    "shrieker": "K", "warden": "W",
    "ammo_9mm": "9", "ammo_shell": "8", "ammo_cell": "c", "medkit": "+",
    "weapon_smg": "g", "weapon_shotgun": "G", "weapon_rail": "R",
    "implant_lightning": "L",
    "key_red": "k", "key_blue": "k", "key_gold": "k", "key_void": "k",
    "terminal": "T", "player": "P", "exit": "X",
}

KEYBIND_HELP = (
    "MMB/arrows pan  wheel zoom  G grid  S snap  I indices | "
    "click select  RMB/M drag polygon  DEL delete  ^Z/^Y undo/redo | "
    "R rect  P poly(Enter)  E entity([ ] cycle) | "
    "C connect(+Shift=door)  X del-connect | "
    "^S save  ^O info  ^N new  F5 playtest"
)


def _lerp(a, b, t):
    return a + (b - a) * t


def _quad_bezier_pts(p0, p1, p2, n=10):
    pts = []
    for i in range(n + 1):
        t = i / n
        x = (1 - t) ** 2 * p0[0] + 2 * (1 - t) * t * p1[0] + t * t * p2[0]
        y = (1 - t) ** 2 * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1]
        pts.append((x, y))
    return pts


def _text(fb, s: str, x: float, y: float, color, size: int = 13) -> None:
    text.blit_text(fb, s, int(x), int(y), color, font_px(size))


def _text_centered(fb, s: str, cx: float, cy: float, color, size: int = 13) -> None:
    tw, th = text.measure(s, font_px(size))
    text.blit_text(fb, s, int(cx - tw / 2), int(cy - th / 2), color, font_px(size))


class TextPrompt:
    """Single-line text entry overlay (terminal text)."""

    def __init__(self, label: str, initial: str, on_submit):
        self.label = label
        self.text = initial
        self.on_submit = on_submit

    def handle_key(self, event) -> bool:
        if event.key in (uievent.K_RETURN, uievent.K_KP_ENTER):
            self.on_submit(self.text)
            return True
        if event.key == uievent.K_ESCAPE:
            self.on_submit(None)
            return True
        if event.key == uievent.K_BACKSPACE:
            self.text = self.text[:-1]
            return True
        if event.unicode and event.unicode.isprintable():
            self.text += event.unicode
            return True
        return True  # swallow everything else while active

    def draw_fb(self, fb) -> None:
        w, h = fb.shape[:2]
        box = fb2d.Rect(w // 2 - 320, h // 2 - 40, 640, 80)
        fb2d.rect(fb, (20, 22, 26), box)
        fb2d.rect(fb, (120, 160, 200), box, 1)
        _text(fb, self.label, box.x + 10, box.y + 8, (180, 200, 220), 14)
        _text(fb, self.text + "_", box.x + 10, box.y + 34, (255, 255, 255), 14)
        _text(fb, "Enter=ok  Esc=cancel", box.x + 10, box.y + 58, (120, 130, 140), 14)


class KeyPrompt:
    """Preset-list overlay for picking a door key id."""

    def __init__(self, on_submit):
        self.on_submit = on_submit

    def handle_key(self, event) -> bool:
        for i, k in enumerate(M.KEY_PRESETS):
            if event.key == uievent.K_1 + i:
                self.on_submit(k)
                return True
        if event.key == uievent.K_ESCAPE:
            self.on_submit(None)
            return True
        return True

    def draw_fb(self, fb) -> None:
        w, h = fb.shape[:2]
        box = fb2d.Rect(w // 2 - 160, h // 2 - 50, 320, 100)
        fb2d.rect(fb, (20, 22, 26), box)
        fb2d.rect(fb, (200, 160, 60), box, 1)
        _text(fb, "door key (1-4, Esc=cancel):", box.x + 10, box.y + 8,
              (220, 200, 160), 14)
        for i, k in enumerate(M.KEY_PRESETS):
            color = KEY_COLORS.get(k, (200, 200, 200))
            _text(fb, f"{i + 1}: {k}", box.x + 10, box.y + 32 + i * 16, color, 14)


class EditorApp:
    def __init__(self, level_path: str | None = None):
        self.size = (WINDOW_W, WINDOW_H)
        self.screen = None  # created lazily by run(); draw_fb needs no window

        self.model = M.EditorModel()
        self.status_msg = ""
        self.status_is_error = False
        if level_path:
            errs = self.model.load(level_path)
            if errs:
                self.status_msg = "; ".join(errs)
                self.status_is_error = True
            else:
                self.status_msg = f"loaded {level_path}"

        self.cam_x, self.cam_y = 0.0, 0.0
        self.zoom = 1.0
        self._fit_camera()

        self.grid_size = 10
        self.snap = True
        self.show_grid = True
        self.show_indices = True

        self.mode = "select"  # select | rect | poly | entity | connect | move
        self.poly_pts: list[tuple[float, float]] = []
        self.connect_first = None  # (ri, ei) | None
        self.entity_idx = 0

        self.drag = None  # dict describing an in-progress gesture
        self.overlay = None  # TextPrompt | KeyPrompt | None

        self.play_proc: subprocess.Popen | None = None

        # input state mirrored from the event stream (the handlers and
        # draw code never query the window system directly)
        self.mouse_pos = (0, 0)
        self._held: set[int] = set()
        self._resized = False

        self.running = True

    # ------------------------------------------------------------------
    # camera
    # ------------------------------------------------------------------

    def _fit_camera(self) -> None:
        polygons = self.model.data.get("polygons", [])
        xs, ys = [], []
        for r in polygons:
            for v in r.get("verts", []):
                xs.append(v[0])
                ys.append(v[1])
        if not xs:
            self.cam_x, self.cam_y, self.zoom = 0.0, 0.0, 1.0
            return
        x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
        self.cam_x, self.cam_y = (x0 + x1) / 2.0, (y0 + y1) / 2.0
        w, h = max(1.0, x1 - x0), max(1.0, y1 - y0)
        self.zoom = max(0.05, min(3.0, min(WINDOW_W / w, (WINDOW_H - STATUS_H) / h) * 0.85))

    def world_to_screen(self, x: float, y: float) -> tuple[float, float]:
        sw, sh = self.size
        return (sw / 2.0 + (x - self.cam_x) * self.zoom,
                (sh - STATUS_H) / 2.0 + (y - self.cam_y) * self.zoom)

    def screen_to_world(self, sx: float, sy: float) -> tuple[float, float]:
        sw, sh = self.size
        return (self.cam_x + (sx - sw / 2.0) / self.zoom,
                self.cam_y + (sy - (sh - STATUS_H) / 2.0) / self.zoom)

    def snap_pt(self, x: float, y: float) -> tuple[float, float]:
        if not self.snap:
            return (x, y)
        g = self.grid_size
        return (round(x / g) * g, round(y / g) * g)

    def pick_tol(self) -> float:
        return 8.0 / self.zoom

    # ------------------------------------------------------------------
    # main loop
    # ------------------------------------------------------------------

    def run(self) -> None:
        # TRANSITION SHIM: dies with app.py's pygame loop. The window +
        # event pump are the ONLY pygame left in the editor; every
        # handler/draw below is already framebuffer/uievent-native.
        import pygame
        pygame.init()
        pygame.display.set_caption("PERIHELION -- Level Editor")
        self.screen = pygame.display.set_mode(self.size, pygame.RESIZABLE)
        clock = pygame.time.Clock()
        while self.running:
            for event in pygame.event.get():
                self._handle_event(uievent.from_pygame(event))
                if self._resized:
                    self._resized = False
                    self.screen = pygame.display.set_mode(self.size, pygame.RESIZABLE)
            self._pan_keys()
            fb = pygame.surfarray.pixels3d(self.screen)
            self.draw_fb(fb)
            del fb
            pygame.display.flip()
            clock.tick(60)
        if self.play_proc is not None and self.play_proc.poll() is None:
            self.play_proc.terminate()
        pygame.quit()

    def _pan_keys(self) -> None:
        speed = 14.0 / self.zoom
        if uievent.K_LEFT in self._held:
            self.cam_x -= speed
        if uievent.K_RIGHT in self._held:
            self.cam_x += speed
        if uievent.K_UP in self._held:
            self.cam_y -= speed
        if uievent.K_DOWN in self._held:
            self.cam_y += speed

    # ------------------------------------------------------------------
    # events
    # ------------------------------------------------------------------

    def _handle_event(self, event) -> None:
        event = uievent.from_pygame(event)
        if event.type == uievent.KEYDOWN and event.key is not None:
            self._held.add(event.key)
        elif event.type == uievent.KEYUP and event.key is not None:
            self._held.discard(event.key)
        if event.type == uievent.MOUSEMOTION and event.pos is not None:
            self.mouse_pos = event.pos

        if event.type == uievent.QUIT:
            self.running = False
            return
        if event.type == uievent.VIDEORESIZE:
            self.size = (event.w, event.h)
            self._resized = True  # run() recreates the window
            return

        if self.overlay is not None:
            # TextPrompt/KeyPrompt on_submit callbacks clear self.overlay
            # themselves once the user commits or cancels.
            if event.type == uievent.KEYDOWN:
                self.overlay.handle_key(event)
            return

        if event.type == uievent.KEYDOWN:
            self._handle_keydown(event)
        elif event.type == uievent.MOUSEBUTTONDOWN:
            self._handle_mousedown(event)
        elif event.type == uievent.MOUSEBUTTONUP:
            self._handle_mouseup(event)
        elif event.type == uievent.MOUSEMOTION:
            self._handle_motion(event)
        elif event.type == uievent.MOUSEWHEEL:
            self._handle_wheel(event)

    def _set_status(self, msg: str, is_error: bool = False) -> None:
        self.status_msg = msg
        self.status_is_error = is_error

    def _handle_keydown(self, event) -> None:
        ctrl = event.mod & (uievent.KMOD_CTRL | uievent.KMOD_META)

        if event.key == uievent.K_ESCAPE:
            self.mode = "select"
            self.poly_pts = []
            self.connect_first = None
            return

        if ctrl and event.key == uievent.K_s:
            errs = self.model.save()
            if errs:
                self._set_status("save refused: " + "; ".join(errs), True)
            else:
                self._set_status(f"saved {self.model.path}")
            return
        if ctrl and event.key == uievent.K_o:
            self._set_status("load via CLI arg only: uv run python -m perihelion.editor <file.json>")
            return
        if ctrl and event.key == uievent.K_n:
            self.model.new()
            self._fit_camera()
            self._set_status("new level")
            return
        if ctrl and event.key == uievent.K_z:
            self._set_status("undo" if self.model.undo() else "nothing to undo")
            return
        if ctrl and event.key == uievent.K_y:
            self._set_status("redo" if self.model.redo() else "nothing to redo")
            return

        if event.key == uievent.K_g:
            self.show_grid = not self.show_grid
        elif event.key == uievent.K_s:
            self.snap = not self.snap
        elif event.key == uievent.K_i:
            self.show_indices = not self.show_indices
        elif event.key == uievent.K_r:
            self.mode = "rect"
        elif event.key == uievent.K_p:
            self.mode = "poly"
            self.poly_pts = []
        elif event.key == uievent.K_e:
            self.mode = "entity"
        elif event.key == uievent.K_c:
            self.mode = "connect"
            self.connect_first = None
        elif event.key == uievent.K_m:
            self.mode = "move"
        elif event.key in (uievent.K_RETURN, uievent.K_KP_ENTER) and self.mode == "poly":
            self._commit_poly()
        elif event.key in (uievent.K_DELETE, uievent.K_BACKSPACE):
            self.model.delete_selected()
        elif event.key == uievent.K_x and self.model.selection and self.model.selection[0] == "connect":
            self.model.delete_connection(self.model.selection[1], self.model.selection[2])
            self.model.selection = None
        elif event.key == uievent.K_LEFTBRACKET:
            self.entity_idx = (self.entity_idx - 1) % len(M.ENTITY_PALETTE)
        elif event.key == uievent.K_RIGHTBRACKET:
            self.entity_idx = (self.entity_idx + 1) % len(M.ENTITY_PALETTE)
        elif event.key == uievent.K_F5:
            self._test_play()

    def _commit_poly(self) -> None:
        if len(self.poly_pts) >= 3:
            ri = self.model.add_poly_polygon(self.poly_pts)
            self.model.selection = ("polygon", ri)
            self._set_status(f"polygon {ri} created")
        self.poly_pts = []

    def _handle_wheel(self, event) -> None:
        if self.mode == "entity":
            step = -1 if event.y > 0 else 1
            self.entity_idx = (self.entity_idx + step) % len(M.ENTITY_PALETTE)
            return
        mx, my = self.mouse_pos
        before = self.screen_to_world(mx, my)
        factor = 1.1 ** event.y
        self.zoom = max(0.02, min(20.0, self.zoom * factor))
        after = self.screen_to_world(mx, my)
        self.cam_x -= (after[0] - before[0])
        self.cam_y -= (after[1] - before[1])

    def _handle_mousedown(self, event) -> None:
        wx, wy = self.screen_to_world(*event.pos)
        tol = self.pick_tol()

        if event.button == 2:
            self.drag = {"kind": "pan", "start": event.pos, "cam0": (self.cam_x, self.cam_y)}
            return

        if event.button == 3:
            ri = self.model.nearest_polygon(wx, wy)
            if ri is not None:
                self.model.selection = ("polygon", ri)
                self.drag = {"kind": "polygon", "ri": ri, "anchor": (wx, wy), "dx": 0.0, "dy": 0.0}
            return

        if event.button != 1:
            return

        if self.mode == "rect":
            sx, sy = self.snap_pt(wx, wy)
            self.drag = {"kind": "rect_draw", "x0": sx, "y0": sy, "x1": sx, "y1": sy}
            return

        if self.mode == "poly":
            self.poly_pts.append(self.snap_pt(wx, wy))
            return

        if self.mode == "entity":
            self._place_entity(*self.snap_pt(wx, wy))
            return

        if self.mode == "connect":
            edge = self.model.nearest_edge(wx, wy, tol)
            if edge is None:
                return
            if self.connect_first is None:
                self.connect_first = edge
                self._set_status(f"connect: polygon {edge[0]} edge {edge[1]} -> click second edge "
                                  f"(hold Shift for a door)")
            else:
                ra, ea = self.connect_first
                rb, eb = edge
                shift = self._held & {uievent.K_LSHIFT, uievent.K_RSHIFT}
                if shift:
                    def submit(key):
                        if key is not None:
                            self.model.connect_door(ra, ea, rb, eb, key)
                            self._set_status(f"door polygon{ra}#{ea} <-> polygon{rb}#{eb} ({key})")
                        self.overlay = None
                    self.overlay = KeyPrompt(submit)
                else:
                    self.model.connect_edges(ra, ea, rb, eb)
                    kind = "mirror" if (ra, ea) == (rb, eb) else "connect"
                    self._set_status(f"{kind} polygon{ra}#{ea} <-> polygon{rb}#{eb}")
                self.connect_first = None
            return

        if self.mode == "move":
            ri = self.model.nearest_polygon(wx, wy)
            if ri is not None:
                self.model.selection = ("polygon", ri)
                self.drag = {"kind": "polygon", "ri": ri, "anchor": (wx, wy), "dx": 0.0, "dy": 0.0}
            return

        # select mode
        sel = self.model.pick(wx, wy, tol)
        self.model.selection = sel
        if sel is None:
            return
        if sel[0] == "vertex":
            ri, vi = sel[1], sel[2]
            orig = tuple(self.model.data["polygons"][ri]["verts"][vi])
            self.drag = {"kind": "vertex", "ri": ri, "vi": vi, "orig": orig, "live": orig}
        elif sel[0] == "entity":
            ri, ei = sel[1], sel[2]
            orig = tuple(self.model.data["polygons"][ri]["entities"][ei]["pos"])
            self.drag = {"kind": "entity", "ri": ri, "ei": ei, "orig": orig, "live": orig}
        elif sel[0] == "terminal":
            ti = sel[1]
            orig = tuple(self.model.data["lore"]["terminals"][ti]["pos"])
            self.drag = {"kind": "terminal", "ti": ti, "orig": orig, "live": orig}

    def _place_entity(self, x: float, y: float) -> None:
        t = M.ENTITY_PALETTE[self.entity_idx]
        ri = self.model.nearest_polygon(x, y)
        if t == "player":
            if ri is None:
                self._set_status("place player inside a polygon", True)
                return
            self.model.set_player(ri, x, y)
            self._set_status(f"player spawn -> polygon {ri}")
        elif t == "exit":
            if ri is None:
                self._set_status("place exit inside a polygon", True)
                return
            self.model.set_exit(ri, x, y)
            self._set_status(f"exit -> polygon {ri}")
        elif t == "terminal":
            if ri is None:
                self._set_status("place terminal inside a polygon", True)
                return
            def submit(text):
                if text is not None:
                    self.model.add_terminal(ri, x, y, text)
                    self._set_status("terminal placed")
                self.overlay = None
            self.overlay = TextPrompt("terminal text:", "", submit)
        else:
            if ri is None:
                self._set_status(f"place {t} inside a polygon", True)
                return
            self.model.add_entity(ri, t, x, y)
            self._set_status(f"{t} -> polygon {ri}")

    def _handle_mouseup(self, event) -> None:
        d = self.drag
        if d is None:
            return
        if d["kind"] == "pan":
            self.drag = None
            return
        if d["kind"] == "rect_draw" and event.button == 1:
            x0, y0, x1, y1 = d["x0"], d["y0"], d["x1"], d["y1"]
            x, y = min(x0, x1), min(y0, y1)
            w, h = abs(x1 - x0), abs(y1 - y0)
            self.drag = None
            if w >= 4 and h >= 4:
                ri = self.model.add_rect_polygon(x, y, w, h)
                self.model.selection = ("polygon", ri)
                self._set_status(f"polygon {ri} created")
            return
        if d["kind"] == "vertex" and event.button == 1:
            self.drag = None
            lx, ly = d["live"]
            if (lx, ly) != d["orig"]:
                self.model.set_vertex(d["ri"], d["vi"], lx, ly)
            return
        if d["kind"] == "entity" and event.button == 1:
            self.drag = None
            lx, ly = d["live"]
            if (lx, ly) != d["orig"]:
                self.model.move_entity(d["ri"], d["ei"], lx, ly)
            return
        if d["kind"] == "terminal" and event.button == 1:
            self.drag = None
            lx, ly = d["live"]
            if (lx, ly) != d["orig"]:
                self.model.move_terminal(d["ti"], lx, ly)
            return
        if d["kind"] == "polygon" and event.button == 3:
            self.drag = None
            if d["dx"] or d["dy"]:
                self.model.move_polygon(d["ri"], d["dx"], d["dy"])
            return
        if d["kind"] == "polygon" and event.button == 1:  # move-tool (M) drag
            self.drag = None
            if d["dx"] or d["dy"]:
                self.model.move_polygon(d["ri"], d["dx"], d["dy"])
            return

    def _handle_motion(self, event) -> None:
        d = self.drag
        if d is None:
            return
        if d["kind"] == "pan":
            sx0, sy0 = d["start"]
            self.cam_x = d["cam0"][0] - (event.pos[0] - sx0) / self.zoom
            self.cam_y = d["cam0"][1] - (event.pos[1] - sy0) / self.zoom
            return
        wx, wy = self.screen_to_world(*event.pos)
        if d["kind"] == "rect_draw":
            d["x1"], d["y1"] = self.snap_pt(wx, wy)
        elif d["kind"] in ("vertex", "entity", "terminal"):
            d["live"] = self.snap_pt(wx, wy)
        elif d["kind"] == "polygon":
            ax, ay = d["anchor"]
            d["dx"], d["dy"] = wx - ax, wy - ay

    # ------------------------------------------------------------------
    # test play
    # ------------------------------------------------------------------

    def _test_play(self) -> None:
        if self.play_proc is not None and self.play_proc.poll() is None:
            try:
                self.play_proc.terminate()
                self.play_proc.wait(timeout=2)
            except Exception:
                try:
                    self.play_proc.kill()
                except Exception:
                    pass
        self.play_proc = None

        tmp_path = os.path.join(tempfile.gettempdir(),
                                 f"perihelion_editor_playtest_{os.getpid()}.json")
        errs = self.model.export(tmp_path)
        if errs:
            self._set_status("playtest refused: " + "; ".join(errs), True)
            return
        try:
            self.play_proc = subprocess.Popen(
                ["uv", "run", "python", "-m", "perihelion", "--level", tmp_path, "--autoplay"],
                cwd=str(REPO_ROOT),
            )
            self._set_status(f"test play launched (pid {self.play_proc.pid})")
        except Exception as exc:
            self._set_status(f"test play failed to launch: {exc}", True)

    # ------------------------------------------------------------------
    # drawing
    # ------------------------------------------------------------------

    def draw_fb(self, fb) -> None:
        fb2d.fill(fb, BG)
        self._draw_grid(fb)
        self._draw_lore_highlights(fb)
        self._draw_connections(fb)
        self._draw_polygons(fb)
        self._draw_entities(fb)
        self._draw_player_exit(fb)
        self._draw_in_progress(fb)
        self._draw_palette_hud(fb)
        if self.overlay is not None:
            self.overlay.draw_fb(fb)
        self._draw_status_bar(fb)

    def _draw_grid(self, fb) -> None:
        if not self.show_grid:
            return
        sw, sh = fb.shape[:2]
        g = self.grid_size
        step = g * self.zoom
        if step < 4:
            return
        x0, y0 = self.screen_to_world(0, 0)
        x1, y1 = self.screen_to_world(sw, sh - STATUS_H)
        start_gx = math.floor(x0 / g) * g
        gx = start_gx
        while gx <= x1:
            sx, _ = self.world_to_screen(gx, 0)
            color = GRID_AXIS if abs(gx) < 1e-6 else GRID_COLOR
            fb2d.vline(fb, color, int(sx), 0, sh - STATUS_H)
            gx += g
        start_gy = math.floor(y0 / g) * g
        gy = start_gy
        while gy <= y1:
            _, sy = self.world_to_screen(0, gy)
            color = GRID_AXIS if abs(gy) < 1e-6 else GRID_COLOR
            fb2d.hline(fb, color, 0, sw, int(sy))
            gy += g

    def _polygon_lore_flags(self):
        """polygons containing a terminal or referenced by an enter_polygon radio
        trigger -> highlighted (spec item 1: 'terminals/radio polygon highlights')."""
        flagged = set()
        for t in self.model.data.get("lore", {}).get("terminals", []):
            flagged.add(t.get("polygon"))
        for r in self.model.data.get("lore", {}).get("radio", []):
            m = M._ENTER_POLYGON_RE.match(r.get("trigger", ""))
            if m:
                flagged.add(int(m.group(1)))
        return flagged

    def _draw_lore_highlights(self, fb) -> None:
        flagged = self._polygon_lore_flags()
        polygons = self.model.data.get("polygons", [])
        for ri in flagged:
            if not (isinstance(ri, int) and 0 <= ri < len(polygons)):
                continue
            verts = polygons[ri].get("verts", [])
            if len(verts) < 3:
                continue
            pts = [self.world_to_screen(*v) for v in verts]
            glow = fb2d.overlay(*fb.shape[:2])
            fb2d.polygon(glow, (*LORE_POLYGON_TINT, 70), pts)
            fb2d.blit(fb, glow)

    def _draw_polygons(self, fb) -> None:
        polygons = self.model.data.get("polygons", [])
        sel = self.model.selection
        sel_ri = sel[1] if sel and sel[0] in ("polygon", "vertex") else None
        drag_ri = self.drag["ri"] if self.drag and self.drag.get("kind") == "polygon" else None
        for ri, polygon in enumerate(polygons):
            verts = [list(v) for v in polygon.get("verts", [])]
            if len(verts) < 3:
                continue
            if ri == drag_ri:
                dx, dy = self.drag["dx"], self.drag["dy"]
                verts = [[v[0] + dx, v[1] + dy] for v in verts]
            live_verts = verts
            if self.drag and self.drag.get("kind") == "vertex" and self.drag["ri"] == ri:
                live_verts = list(verts)
                live_verts[self.drag["vi"]] = list(self.drag["live"])
            pts = [self.world_to_screen(*v) for v in live_verts]
            fill = POLYGON_FILL_SEL if ri == sel_ri else POLYGON_FILL
            fb2d.polygon(fb, fill, pts)
            fb2d.polygon(fb, POLYGON_EDGE, pts, 2 if ri == sel_ri else 1)

            flags = M.convex_flags(live_verts)
            n = len(live_verts)
            for vi, v in enumerate(live_verts):
                sx, sy = self.world_to_screen(*v)
                if flags[vi]:
                    color = VERTEX_BAD
                elif sel and sel[0] == "vertex" and sel[1] == ri and sel[2] == vi:
                    color = VERTEX_SEL
                else:
                    color = VERTEX_COLOR
                r = 4 if color is VERTEX_SEL else 3
                fb2d.circle(fb, color, (sx, sy), r)

            if self.show_indices:
                for ei in range(n):
                    a, b = live_verts[ei], live_verts[(ei + 1) % n]
                    mx = _lerp(a[0], b[0], 0.5)
                    my = _lerp(a[1], b[1], 0.5)
                    sx, sy = self.world_to_screen(mx, my)
                    _text_centered(fb, str(ei), sx, sy, (120, 150, 140), 11)

            cx = sum(v[0] for v in live_verts) / n
            cy = sum(v[1] for v in live_verts) / n
            sx, sy = self.world_to_screen(cx, cy)
            _text_centered(fb, f"#{ri}", sx, sy, POLYGON_ID_COLOR, 13)

    def _conn_endpoints(self, ri, ei, rj, ej):
        try:
            p1 = self.model.edge_midpoint(ri, ei)
            p2 = self.model.edge_midpoint(rj, ej)
        except (IndexError, TypeError):
            return None
        return p1, p2

    def _draw_connections(self, fb) -> None:
        sel = self.model.selection
        groups = [
            ("connect", self.model.data.get("connects", []), CONNECT_NORMAL, None),
            ("connect_x", self.model.data.get("connects_x", []), CONNECT_X, None),
            ("door", self.model.data.get("doors", []), CONNECT_DOOR, None),
        ]
        for kind, entries, base_color, _ in groups:
            for idx, e in enumerate(entries):
                if kind == "door":
                    ra, ea, rb, eb, key = e.get("a"), e.get("ea"), e.get("b"), e.get("eb"), e.get("key", "")
                else:
                    ra, ea, rb, eb = e[0], e[1], e[2], e[3]
                    key = ""
                pts = self._conn_endpoints(ra, ea, rb, eb)
                if pts is None:
                    continue
                p1, p2 = pts
                is_self = (ra == rb and ea == eb)
                color = CONNECT_SELF if is_self else base_color
                selected = sel and sel[0] == "connect" and sel[1] == kind and sel[2] == idx
                draw_color = CONNECT_SEL if selected else color
                s1 = self.world_to_screen(*p1)
                if is_self:
                    fb2d.circle(fb, draw_color, s1, 10, 2)
                else:
                    s2 = self.world_to_screen(*p2)
                    dx, dy = p2[0] - p1[0], p2[1] - p1[1]
                    length = math.hypot(dx, dy) or 1.0
                    nx, ny = -dy / length, dx / length
                    bulge = min(28.0, length * 0.18)
                    mx, my = _lerp(p1[0], p2[0], 0.5) + nx * bulge, _lerp(p1[1], p2[1], 0.5) + ny * bulge
                    sc = self.world_to_screen(mx, my)
                    curve = _quad_bezier_pts(s1, sc, s2, 14)
                    fb2d.lines(fb, draw_color, False, curve, 2 if selected else 1)

                    try:
                        la = self.model.edge_length(ra, ea)
                        lb = self.model.edge_length(rb, eb)
                        if max(la, lb) > 1e-6 and abs(la - lb) / max(la, lb) > 0.02:
                            wx, wy = _lerp(p1[0], p2[0], 0.5), _lerp(p1[1], p2[1], 0.5)
                            wsx, wsy = self.world_to_screen(wx, wy)
                            fb2d.polygon(fb, WARN_COLOR, [
                                (wsx, wsy - 6), (wsx - 6, wsy + 5), (wsx + 6, wsy + 5)])
                    except (IndexError, TypeError):
                        pass

                if key:
                    wsx, wsy = self.world_to_screen(*p1) if is_self else sc
                    _text(fb, key, wsx + 6, wsy - 6, CONNECT_DOOR, 11)

    def _draw_entities(self, fb) -> None:
        polygons = self.model.data.get("polygons", [])
        sel = self.model.selection
        for ri, polygon in enumerate(polygons):
            offset = (0.0, 0.0)
            if self.drag and self.drag.get("kind") == "polygon" and self.drag["ri"] == ri:
                offset = (self.drag["dx"], self.drag["dy"])
            for ei, e in enumerate(polygon.get("entities", [])):
                if (self.drag and self.drag.get("kind") == "entity"
                        and self.drag["ri"] == ri and self.drag["ei"] == ei):
                    pos = self.drag["live"]
                else:
                    pos = (e["pos"][0] + offset[0], e["pos"][1] + offset[1])
                t = e.get("type", "?")
                color = ENEMY_COLOR.get(t) or PICKUP_COLORS.get(t) or (
                    KEY_COLORS.get(t[4:], (200, 200, 200)) if t.startswith("key_") else (200, 200, 200))
                sx, sy = self.world_to_screen(*pos)
                selected = sel and sel[0] == "entity" and sel[1] == ri and sel[2] == ei
                r = 7 if selected else 5
                fb2d.circle(fb, color, (sx, sy), r)
                if selected:
                    fb2d.circle(fb, VERTEX_SEL, (sx, sy), r + 2, 1)
                _text_centered(fb, GLYPH.get(t, "?"), sx, sy, (10, 10, 12), 11)

        for ti, t in enumerate(self.model.data.get("lore", {}).get("terminals", [])):
            if self.drag and self.drag.get("kind") == "terminal" and self.drag["ti"] == ti:
                pos = self.drag["live"]
            else:
                pos = t["pos"]
            sx, sy = self.world_to_screen(*pos)
            selected = sel and sel[0] == "terminal" and sel[1] == ti
            r = 8 if selected else 6
            fb2d.rect(fb, TERMINAL_COLOR, (sx - r, sy - r, r * 2, r * 2),
                      0 if selected else 1)
            _text_centered(fb, "T", sx, sy,
                           (10, 10, 12) if selected else TERMINAL_COLOR, 11)

    def _draw_player_exit(self, fb) -> None:
        sel = self.model.selection
        player = self.model.data.get("player")
        if player:
            sx, sy = self.world_to_screen(*player["pos"])
            selected = sel and sel[0] == "player"
            fb2d.circle(fb, PLAYER_COLOR, (sx, sy), 8 if selected else 6, 0 if selected else 2)
            _text_centered(fb, "P", sx, sy,
                           (10, 10, 12) if selected else PLAYER_COLOR, 11)
        exit_ = self.model.data.get("exit")
        if exit_:
            sx, sy = self.world_to_screen(*exit_["pos"])
            selected = sel and sel[0] == "exit"
            pts = [(sx, sy - 9), (sx - 8, sy + 6), (sx + 8, sy + 6)]
            fb2d.polygon(fb, EXIT_COLOR, pts, 0 if selected else 2)
            label = "EXIT"
            if exit_.get("key"):
                label += f"+{exit_['key']}"
            if exit_.get("gate_kind"):
                label += f"/{exit_['gate_kind']}"
            _text(fb, label, sx + 10, sy - 6, EXIT_COLOR, 11)

    def _draw_in_progress(self, fb) -> None:
        if self.drag and self.drag.get("kind") == "rect_draw":
            d = self.drag
            p0 = self.world_to_screen(d["x0"], d["y0"])
            p1 = self.world_to_screen(d["x1"], d["y1"])
            rect = (min(p0[0], p1[0]), min(p0[1], p1[1]),
                    abs(p1[0] - p0[0]), abs(p1[1] - p0[1]))
            fb2d.rect(fb, PREVIEW_COLOR, rect, 1)
        if self.mode == "poly" and self.poly_pts:
            pts = [self.world_to_screen(*p) for p in self.poly_pts]
            if len(pts) > 1:
                fb2d.lines(fb, PREVIEW_COLOR, False, pts, 1)
            for p in pts:
                fb2d.circle(fb, PREVIEW_COLOR, p, 3)
            mx, my = self.mouse_pos
            fb2d.line(fb, (120, 120, 120), pts[-1], (mx, my), 1)
        if self.mode == "connect" and self.connect_first is not None:
            ri, ei = self.connect_first
            try:
                mid = self.model.edge_midpoint(ri, ei)
                sx, sy = self.world_to_screen(*mid)
                fb2d.circle(fb, PREVIEW_COLOR, (sx, sy), 8, 2)
            except (IndexError, TypeError):
                pass

    def _draw_palette_hud(self, fb) -> None:
        t = M.ENTITY_PALETTE[self.entity_idx]
        lines = [f"mode: {self.mode.upper()}"]
        if self.mode == "entity":
            lines.append(f"palette: {t}  ([ ] or wheel to cycle)")
        for i, line in enumerate(lines):
            _text(fb, line, 8, 8 + i * 16, (200, 210, 220), 13)

    def _draw_status_bar(self, fb) -> None:
        sw, sh = fb.shape[:2]
        fb2d.rect(fb, STATUS_BG, (0, sh - STATUS_H, sw, STATUS_H))

        errs = self.model.validate()
        ok = len(errs) == 0
        name = self.model.path.name if self.model.path else "<unsaved>"
        dot = "*" if self.model.dirty else " "
        sel = self.model.selection
        sel_txt = "none" if sel is None else "/".join(str(s) for s in sel)

        left = f"{name}{dot}  sel:{sel_txt}  snap:{'on' if self.snap else 'off'} grid:{'on' if self.show_grid else 'off'}  zoom:{self.zoom:.2f}"
        _text(fb, left, 6, sh - STATUS_H + 4, STATUS_TEXT, 13)

        status_color = STATUS_ERR if (self.status_is_error or not ok) else STATUS_OK
        msg = self.status_msg
        if not ok:
            msg = f"INVALID ({len(errs)}): {errs[0]}"
        mw, _ = text.measure(msg, font_px(13)) if msg else (0, 0)
        _text(fb, msg, max(6, sw // 2 - mw // 2), sh - STATUS_H + 4,
              status_color, 13)


def run(level_path: str | None = None) -> None:
    EditorApp(level_path).run()
