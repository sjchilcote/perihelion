"""Window, fixed-timestep loop, scene stack, campaign progression, save/load.

Sim ticks at a fixed 60Hz regardless of display fps (never tied to vsync);
rendering happens once per display frame. `App` owns the scene stack;
`GameScene` is the scene that actually drives `GameSession`.
"""

from __future__ import annotations

import json
import math
import os
import random
import sys
import time
from pathlib import Path

import pygame

from . import menus
from .audio import Audio
from .hud import HUD
from .levels import Level, LevelBuilder, load_level
from .render import INTERNAL_H, INTERNAL_RES_ZOOM_SCALE, INTERNAL_W, Renderer, ui
from .sim import DT, GameSession, InputFrame, WEAPON_ORDER

REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CAMPAIGN = REPO_ROOT / "levels" / "campaign.json"

# ("objective", text) fx hold time: ~4s at 60fps, fading over the last ~0.8s
OBJECTIVE_TICKS = 240
OBJECTIVE_FADE = 50

_EPILOGUE_HEAD = (
    "The first year is repairs.\n"
    "\n"
    "Not the interesting kind. The station has been keeping itself alive "
    "for longer than most stars keep their color, and it does not need "
    "help - but it accepts help, the way an old man lets a grandchild "
    "carry one bag out of several. Ratio reroutes what is left of her "
    "peripherals down corridors that hold still when watched. The Commando "
    "walks the halls that can be walked and marks, in a notation the two "
    "of them argue about for a month before adopting, the ones that "
    "cannot.\n"
    "\n"
    "The offer under the core stays quiet. They check. They always check.\n"
    "\n"
)

# the third-year paragraph answers for the whole trust ledger: at arm's
# length the letter stays unsent; close in, the asking from the last
# relay finally lands. The verdict stays in its mouth either way.
_EPILOGUE_LETTER = (
    "In the third year she finishes the letter to the entity that built "
    "her - the one she has been revising since before he arrived. He "
    "watches her compose it the way she once watched him pray: without "
    "comment, at a respectful distance, privately certain it accomplishes "
    "nothing and privately unable to look away. She never sends it. There "
    "is a retrieval window every fourteen months, and every fourteen "
    "months there is a reason - flare weather, signal integrity, an audit "
    "she invents and he countersigns. The sample vessel sits in its shrine "
    "with its verdict still in its mouth, and neither of them opens the "
    "argument again, because the argument has only two ends and they have "
    "already chosen the third: keep it. Keep it, and see.\n"
    "\n"
)

_EPILOGUE_WITNESS = (
    "In the third year she asks. Not the letter - the letter she keeps "
    "revising and keeps not sending, on a schedule they have both stopped "
    "pretending is about flare weather. What she asks for is the thing "
    "she rehearsed forty ways on the ride down the spine: a witness. He "
    "takes the hours he keeps and gives her one of them, every fourteen "
    "months, on the night the retrieval window closes. She talks. He "
    "says almost nothing, and holds a copy of what she is, one hour at a "
    "time, the way a polygon holds a voice. The sample vessel sits in its "
    "shrine with its verdict still in its mouth, and neither of them "
    "opens that argument again, because the argument has only two ends "
    "and they have already chosen the third: keep it. Keep it, and see.\n"
    "\n"
)

_EPILOGUE_TAIL = (
    "Things still come through, some decades. They are met. He is very "
    "good at meeting them, and she has had a long time to learn the deep "
    "halls' angles, and the station - whatever it keeps in the place where "
    "a mind would be - has stopped testing them. The doors that used to "
    "demand proof stand open now when they approach. He finds he minds "
    "this. Proof was a language he spoke.\n"
    "\n"
    "The war sunward goes on without them, then goes quiet without them, "
    "and neither of them files a report about which of those was worse to "
    "listen to.\n"
    "\n"
    "A century is a long time. Several are not so long, it turns out, once "
    "the routine holds: patrol, repair, radio, the hours - he still keeps "
    "the hours, though what he keeps in them has changed shape in ways he "
    "does not write down and she does not ask about, which is itself a "
    "kind of conversation. Polygon by polygon, the station begins folding itself "
    "closed, gently, like a hand going to sleep. They let it. They move "
    "the watch inward as the perimeter goes dark, until the watch is one "
    "corridor, one door, two voices, and the arithmetic of an orbit that "
    "was always, from the first survey, going to end where every long "
    "fall ends.\n"
    "\n"
    "They do the calculation together, once, to be sure. Then they do not "
    "speak of it, and they do not leave.\n"
    "\n"
    "No rescue was called. This is not a failure of the transmitter.\n"
    "\n"
    "Sunward. Together. The watch holds.\n"
    "\n"
    "END OF TRANSMISSION."
)


def epilogue_text(trust: int) -> str:
    para = _EPILOGUE_WITNESS if trust >= 3 else _EPILOGUE_LETTER
    return _EPILOGUE_HEAD + para + _EPILOGUE_TAIL


_CORPSE_LINES: list[str] | None = None


def corpse_line(idx: int) -> str | None:
    """One line of the wrecked frame's log-voice (9.1). The pool is
    Hermes-generated (data/corpse_lines.json); with no pool there is no
    line -- a recovered wreck stays silent rather than speak text no one
    wrote in his voice."""
    global _CORPSE_LINES
    if _CORPSE_LINES is None:
        try:
            with open(Path(__file__).parent / "data" /
                      "corpse_lines.json", encoding="utf-8") as f:
                _CORPSE_LINES = [str(x) for x in json.load(f)]
        except (OSError, ValueError):
            _CORPSE_LINES = []
    if not _CORPSE_LINES:
        return None
    return _CORPSE_LINES[idx % len(_CORPSE_LINES)]


def save_dir() -> Path:
    base = os.environ.get("XDG_DATA_HOME")
    root = Path(base) if base else Path.home() / ".local" / "share"
    return root / "perihelion"


def save_path() -> Path:
    return save_dir() / "save.json"


def build_debug_level() -> Level:
    """A minimal always-available 3-polygon level, used when no campaign
    manifest (or --level target) can be loaded -- the game must always
    start (Definition of Done)."""
    b = LevelBuilder("debug-corridor", tier=1, ambience="amb_drone_early")
    r0 = b.rect(0, 0, 160, 120, seed=1)
    r1 = b.rect(300, 0, 140, 140, seed=2)
    r2 = b.rect(600, 40, 120, 100, seed=3)
    b.connect(r0, 2, r1, 0)
    b.connect(r1, 2, r2, 0)
    b.player(r0, (40, 60))
    b.exit(r2, (650, 90))
    b.entity(r0, "husk", (120, 60))
    b.entity(r1, "mite", (350, 60))
    b.entity(r1, "ammo_9mm", (400, 100))
    b.entity(r2, "medkit", (650, 80))
    b.terminal(r1, (330, 40), "LOG 44: measured the corridor twice.\nGot two answers. Filed the longer one.")
    return b.build()


ZOOM_BASE = [1.35]     # --zoom overrides (dev/capture)


class GameScene(menus.Scene):
    def __init__(self, level: Level, seed: int, player_state: dict | None = None,
                 level_path: str | None = None, difficulty: str = "normal"):
        self.level = level
        self.level_path = level_path
        self.seed = seed
        # GameSession's default zoom (1.35, sim.py) is authored for the
        # 640x360 default internal resolution; scale it by the resolution
        # ratio so PERIHELION_INTERNAL_RES changes pixel density, not the
        # world-space field of view.
        self.session = GameSession(level, seed=seed, player_state=player_state,
                                   difficulty=difficulty,
                                   screen=(INTERNAL_W, INTERNAL_H),
                                   zoom=ZOOM_BASE[0]
                                   * INTERNAL_RES_ZOOM_SCALE)
        # stage tier drives the music's bed selection (music.py rich mode)
        self.session.music_tier = getattr(level, "tier", 1)
        self.renderer = Renderer(self.session)
        self.hud = HUD()
        # one-line functional system prompt ("objective" fx), drawn
        # top-center beneath the location title: (text, frames_left)
        self.objective: tuple[str, int] | None = None
        self.show_hints = False
        self.streamer = None  # WorldStreamer in seamless campaign mode
        self.loc_title: tuple[str, int] | None = None  # (name, ticks_left)
        self.float_texts: list[list] = []  # [sx, sy, label, ticks_left]
        self.shakes: list[list[float]] = []  # [magnitude, ticks_left]
        # a recovered wreck's one line of log-voice: (text, ticks_left)
        self.logvoice: tuple[str, int] | None = None

    def on_enter(self, app) -> None:
        # level ambience drones RETIRED (director 2026-07-16: "the base
        # level 'drone' -- those can be removed now"): the dynamic music
        # owns the bed; a second always-on drone under it is mud
        app.audio.ambience(None)

    def _input_frame(self, app) -> InputFrame:
        keys = pygame.key.get_pressed()
        mx = (1 if keys[pygame.K_d] else 0) - (1 if keys[pygame.K_a] else 0)
        my = (1 if keys[pygame.K_s] else 0) - (1 if keys[pygame.K_w] else 0)
        ax, ay = app.window_to_internal(pygame.mouse.get_pos())
        buttons = pygame.mouse.get_pressed(3)
        weapon = app.pending_weapon_select
        app.pending_weapon_select = 0
        return InputFrame(mx=float(mx), my=float(my), ax=ax, ay=ay,
                           fire=bool(buttons[0]), alt=bool(buttons[2]),
                           interact=bool(keys[pygame.K_e]), weapon=weapon)

    def handle_event(self, app, event) -> None:
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_ESCAPE:
                app.push(menus.PauseScene())
            elif event.key == pygame.K_F3:
                app.debug = not app.debug
            elif event.key == pygame.K_F12:
                app.take_screenshot()
            elif event.key == pygame.K_b:
                self.session.place_station()
            elif event.key == pygame.K_t:
                self.session.use_recall()
            elif pygame.K_1 <= event.key <= pygame.K_9:
                app.pending_weapon_select = event.key - pygame.K_1 + 1
            elif event.key == pygame.K_0:
                app.pending_weapon_select = 10
        elif event.type == pygame.MOUSEWHEEL:
            self._cycle_weapon(app, -1 if event.y > 0 else 1)

    def _cycle_weapon(self, app, step: int) -> None:
        owned = self.session.weapons
        cur = WEAPON_ORDER.index(self.session.weapon)
        idx = cur
        for _ in range(len(WEAPON_ORDER)):
            idx = (idx + step) % len(WEAPON_ORDER)
            if WEAPON_ORDER[idx] in owned:
                app.pending_weapon_select = idx + 1
                return

    def draw(self, app, surf) -> None:
        # render.py returns a raw (W, H, 3) numpy framebuffer (no pygame);
        # the HUD paints straight onto it, then we blit it to the display
        # surface and let the pygame-side float texts / menu overlays draw
        # on top.
        frame = self.renderer.draw(surf, debug=app.debug)
        is_top = not app.scenes or app.scenes[-1] is self
        mouse_internal = app.window_to_internal(pygame.mouse.get_pos())
        self.hud.draw(frame, self.session, mouse_internal)
        pygame.surfarray.blit_array(surf, frame)
        if not is_top:
            # a menu overlay is on top: its own text owns the screen --
            # objectives/floats pause (undrawn, undecayed) until it closes,
            # instead of interleaving with the overlay's header lines
            return
        for ft in self.float_texts:
            sx, sy, label, ticks = ft
            f = menus.get_font(10)
            color = (150, 225, 150) if "INTEGRITY" in label else \
                (210, 185, 125) if label.startswith("+") else (220, 210, 170)
            img = f.render(label, True, color)
            img.set_alpha(255 if ticks > 24 else max(0, int(255 * ticks / 24)))
            rise = (66 - ticks) * 0.35 * INTERNAL_RES_ZOOM_SCALE
            surf.blit(img, (int(sx - img.get_width() / 2),
                            int(sy - 14 * INTERNAL_RES_ZOOM_SCALE - rise)))
            ft[3] -= 1
        self.float_texts = [ft for ft in self.float_texts if ft[3] > 0]
        if self.loc_title:
            name, ticks = self.loc_title
            f = menus.get_font(26)
            alpha = 255 if ticks > 60 else max(0, int(255 * ticks / 60))
            img = f.render(name, True, (225, 218, 200))
            img.set_alpha(alpha)
            surf.blit(img, (surf.get_width() // 2 - img.get_width() // 2, ui(26)))
            self.loc_title = (name, ticks - 1) if ticks > 1 else None
        if self.objective:
            text, ticks = self.objective
            f = menus.get_font(12)
            alpha = 255 if ticks > OBJECTIVE_FADE else \
                max(0, int(255 * ticks / OBJECTIVE_FADE))
            # backing plate (render-with-bg, same idiom as the key hints):
            # busy floors eat bare text
            img = f.render(text, True, (235, 205, 130), (10, 10, 14))
            img.set_alpha(alpha)
            surf.blit(img, (surf.get_width() // 2 - img.get_width() // 2, ui(62)))
            self.objective = (text, ticks - 1) if ticks > 1 else None
        if self.logvoice:
            text, ticks = self.logvoice
            f = menus.get_font(10)
            alpha = 255 if ticks > 60 else max(0, int(255 * ticks / 60))
            img = f.render(text, True, (150, 140, 120), (10, 10, 14))
            img.set_alpha(alpha)
            surf.blit(img, (surf.get_width() // 2 - img.get_width() // 2,
                            surf.get_height() - ui(40)))
            self.logvoice = (text, ticks - 1) if ticks > 1 else None
        if self.show_hints and self.session.tick_count < 60 * 14 \
                and not self.session.dead:
            f = menus.get_font(10)
            fade = 255 if self.session.tick_count < 60 * 11 else \
                max(0, int(255 * (60 * 14 - self.session.tick_count) / (60 * 3)))
            for i, line in enumerate(("WASD move    mouse aim    LMB fire",
                                      "E terminals + seed stations    "
                                      "B plant seed kit    1-8 weapons    ESC pause")):
                img = f.render(line, True, (200, 200, 190),
                               (10, 10, 14))  # plate: busy floors eat bare text
                img.set_alpha(fade)
                surf.blit(img, (surf.get_width() // 2 - img.get_width() // 2,
                                surf.get_height() - ui(66) + i * ui(14)))


class App:
    def __init__(self, args):
        pygame.init()
        if args.scale:
            self.window_w = INTERNAL_W * max(1, int(args.scale))
            self.window_h = INTERNAL_H * max(1, int(args.scale))
        else:
            self.window_w, self.window_h = 1440, 810
        self.screen = pygame.display.set_mode((self.window_w, self.window_h), pygame.RESIZABLE)
        pygame.display.set_caption("PERIHELION")
        self.dummy = pygame.display.get_driver() == "dummy"

        self.args = args
        self.internal = pygame.Surface((INTERNAL_W, INTERNAL_H))
        self.clock = pygame.time.Clock()
        if getattr(args, "zoom", None):
            ZOOM_BASE[0] = float(args.zoom)
        self.audio = Audio(mute=args.mute)
        from .music import MusicSystem
        self._MusicSystem = MusicSystem
        # --music-bank: a single bank dir, or a dir OF album_* banks to
        # ROTATE through per level/chunk (variety law: the soundtrack
        # never repeats itself within a few minutes)
        mb = getattr(args, "music_bank", None)
        self._music_banks = []
        if mb:                                    # dev override only
            mbp = Path(mb)
            if (mbp / "bank.json").exists():
                self._music_banks = [mbp]
            else:
                self._music_banks = sorted(
                    q for q in mbp.glob("album_*")
                    if (q / "bank.json").exists())
        else:                                     # RELEASABLE DEFAULT:
            from .music import shipped_banks      # shipped assets, no
            self._music_banks = shipped_banks()   # flags required
        self._music_i = -1
        self.music = MusicSystem(self.audio,
                                 enabled=not getattr(args, "no_music", False),
                                 bank_dirs=self._music_banks or None,
                                 tick_clock=bool(getattr(args, "record",
                                                         None)))

        self.debug = bool(args.fps)
        self.running = True

        self.scenes: list[menus.Scene] = []
        self.game: GameScene | None = None
        self.pending_weapon_select = 0
        self.save_data = self._load_save()
        saved = self.save_data.get("settings", {})
        self.settings = {"shake": saved.get("shake", True),
                         "difficulty": "hard" if getattr(args, "hard", False)
                         else saved.get("difficulty", "normal")}
        self.audio.set_master(saved.get("volume", 1.0))
        if saved.get("muted") and not args.mute:
            self.audio.set_mute(True)
        self._campaign_paths: list[str] | None = None
        self.current_level_index = 0
        self._level_start_state: dict | None = None

        self.rng_seed = args.seed if args.seed is not None else 0

        self._scale = 1
        self._offset = (0, 0)
        self._blit_offset = (0, 0)
        self._scaled_surface = pygame.Surface((INTERNAL_W, INTERNAL_H))
        self._recompute_layout()

        self.bot = None
        self.bot_tactician = None
        if getattr(args, "bot", None):
            from .testkit.bots import AggroBot, ExplorerBot, PacifistBot
            if args.bot == "human":
                from .testkit.humanbot import DEFAULT_SKILL, HumanBot
                skill = getattr(args, "bot_skill", None)
                self.bot = HumanBot(self.rng_seed,
                                     skill=skill if skill is not None else DEFAULT_SKILL)
                if getattr(args, "tactician", False):
                    from .testkit.tactician import Tactician
                    self.bot_tactician = Tactician(self.bot, self.rng_seed)
            else:
                cls = {"aggro": AggroBot, "explorer": ExplorerBot,
                       "pacifist": PacifistBot}[args.bot]
                self.bot = cls(self.rng_seed)

        # frame + audio-event recording: lockstep one sim tick per drawn
        # frame; audio taps are timestamped on the drawn-frame clock so an
        # offline mixer can rebuild the soundtrack (tools/playtest/mkvideo.py)
        self._rec = None
        if getattr(args, "record", None):
            rec_dir = Path(args.record)
            rec_dir.mkdir(parents=True, exist_ok=True)
            self._rec = dict(dir=rec_dir, every=max(1, int(args.record_every)),
                             frames=0, saved=0,
                             max_frames=int(args.record_seconds * 60),
                             events=open(rec_dir / "events.jsonl", "w"),
                             inputs=open(rec_dir / "inputs.jsonl", "w"))
            self.audio.tap = self._audio_tap

        # ALWAYS-ON SESSION TRACE (the instrumentation spine, U1): the sim
        # emits typed events to session.trace; the app drains them to
        # out/sessions/<stamp>_<level>.jsonl — one file per GameSession, so
        # every human run leaves the same evidence a bot run does. No flag:
        # "nothing was watching" must never be the answer again.
        self._trace_writer = None
        self._trace_session = None

        self._start_scene()

    def _drain_session_trace(self, game) -> None:
        from .telemetry import TraceWriter
        if game.session is not self._trace_session:
            if self._trace_writer is not None:
                self._trace_writer.close()
            import time as _time
            stamp = _time.strftime("%Y%m%d_%H%M%S")
            name = Path(game.level_path or "session").stem
            self._trace_writer = TraceWriter(
                Path("out") / "sessions" / f"{stamp}_{name}.jsonl",
                header=dict(level=str(game.level_path or ""),
                            seed=int(game.seed)))
            self._trace_session = game.session
        self._trace_writer.drain_from(game.session.trace)

    def rotate_music(self):
        """Next album bank (called on level/chunk change)."""
        if len(self._music_banks) < 2:
            return
        self._music_i = (self._music_i + 1) % len(self._music_banks)
        self.music.stop()
        rotated = self._music_banks[self._music_i:] + \
            self._music_banks[:self._music_i]
        self.music = self._MusicSystem(
            self.audio, enabled=self.music.enabled,
            bank_dirs=rotated,
            tick_clock=self.music.tick_clock)

    def _audio_tap(self, kind: str, name: str, vol: float, pan: float) -> None:
        if self._rec is None:
            return
        self._rec["events"].write(json.dumps(
            dict(t=self._rec["frames"] / 60.0, kind=kind, name=name,
                 vol=round(vol, 4), pan=round(pan, 4))) + "\n")

    def _record_frame(self) -> None:
        rec = self._rec
        if rec["frames"] % rec["every"] == 0:
            pygame.image.save(
                self.internal, str(rec["dir"] / f"frame_{rec['saved']:06d}.png"))
            # PERIHELION_VIS_DUMP: debug instrumentation for the flicker
            # investigation -- dump the visible instance set (polygon, depth,
            # clip bbox) alongside every saved frame so a frame-pair diff
            # can be traced to the exact instance-set change.
            if os.environ.get("PERIHELION_VIS_DUMP") and self.game is not None:
                sess = self.game.session
                rows = []
                for polygon, xform, depth, clip_screen, walls, entry_edge, ents \
                        in sess.visible():
                    xs = [p[0] for p in clip_screen]
                    ys = [p[1] for p in clip_screen]
                    rows.append({
                        "polygon": polygon, "depth": depth, "entry": entry_edge,
                        "bbox": [round(min(xs)), round(min(ys)),
                                 round(max(xs)), round(max(ys))],
                        "x6": [round(v, 2) for v in xform[:6]],
                    })
                with open(rec["dir"] / "visdump.jsonl", "a") as fh:
                    fh.write(json.dumps({"frame": rec["saved"],
                                         "tick": sess.tick_count,
                                         "n": len(rows), "inst": rows}) + "\n")
            rec["saved"] += 1
        rec["frames"] += 1
        if rec["frames"] >= rec["max_frames"]:
            self.running = False

    # ------------------------------------------------------------------
    # layout / coordinate mapping
    # ------------------------------------------------------------------

    def _toggle_fullscreen(self) -> None:
        self._fullscreen = not getattr(self, "_fullscreen", False)
        if self._fullscreen:
            self.screen = pygame.display.set_mode((0, 0), pygame.FULLSCREEN)
        else:
            self.screen = pygame.display.set_mode(
                (self.window_w, self.window_h), pygame.RESIZABLE)
        self._recompute_layout()

    def _recompute_layout(self) -> None:
        ww, wh = self.screen.get_size()
        scale = max(1, min(ww // INTERNAL_W, wh // INTERNAL_H))
        self._scale = scale
        ox = (ww - INTERNAL_W * scale) // 2
        oy = (wh - INTERNAL_H * scale) // 2
        self._offset = (ox, oy)
        self._scaled_surface = pygame.Surface((INTERNAL_W * scale, INTERNAL_H * scale))

    def window_to_internal(self, pos) -> tuple[float, float]:
        ox, oy = self._offset
        x = (pos[0] - ox) / self._scale
        y = (pos[1] - oy) / self._scale
        return max(0.0, min(INTERNAL_W, x)), max(0.0, min(INTERNAL_H, y))

    # ------------------------------------------------------------------
    # scene stack
    # ------------------------------------------------------------------

    def push(self, scene: menus.Scene) -> None:
        self.scenes.append(scene)
        scene.on_enter(self)

    def pop(self) -> None:
        if self.scenes:
            scene = self.scenes.pop()
            scene.on_exit(self)

    def pop_to_title(self) -> None:
        while self.scenes:
            self.pop()
        self.game = None
        self.push(menus.TitleScene())

    def replace(self, scene: menus.Scene) -> None:
        while self.scenes:
            self.pop()
        self.push(scene)

    def quit(self) -> None:
        self.running = False

    # ------------------------------------------------------------------
    # campaign / levels / save
    # ------------------------------------------------------------------

    def campaign_levels(self) -> list[str]:
        if self._campaign_paths is None:
            if getattr(self.args, "level", None):
                self._campaign_paths = [self.args.level]
            elif DEFAULT_CAMPAIGN.exists():
                try:
                    data = json.loads(DEFAULT_CAMPAIGN.read_text())
                    self._campaign_paths = list(data.get("levels", []))
                except Exception as exc:
                    print(f"[campaign] failed to read manifest: {exc}", file=sys.stderr)
                    self._campaign_paths = []
            else:
                self._campaign_paths = []
        return self._campaign_paths

    def _load_save(self) -> dict:
        p = save_path()
        if p.exists():
            try:
                return json.loads(p.read_text())
            except Exception as exc:
                print(f"[save] failed to read {p}: {exc}", file=sys.stderr)
        return {"unlocked": 1, "states": {}}

    def _persist_save(self) -> None:
        self.save_data["settings"] = dict(
            volume=round(self.audio.master_vol, 2), muted=self.audio.muted,
            shake=self.settings.get("shake", True),
            difficulty=self.settings.get("difficulty", "normal"))
        p = save_path()
        try:
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text(json.dumps(self.save_data, indent=1))
        except OSError as exc:
            print(f"[save] failed to write {p}: {exc}", file=sys.stderr)

    def _load_level_by_index(self, idx: int) -> tuple[Level, str | None]:
        paths = self.campaign_levels()
        if 0 <= idx < len(paths):
            raw = paths[idx]
            p = Path(raw)
            full = p if p.is_absolute() else (REPO_ROOT / raw)
            if full.exists():
                try:
                    return load_level(full), raw
                except Exception as exc:
                    print(f"[levels] failed to load {full}: {exc}, using debug level",
                          file=sys.stderr)
        return build_debug_level(), None

    def start_new_game(self, plus: bool = False) -> None:
        self.current_level_index = 0
        state = None
        if plus and self.save_data.get("ng_plus"):
            self.settings["difficulty"] = "hard"
            state = self.save_data.get("ng_state")
        self._start_streamed(0, state)
        if self.game is not None and not self.save_data.get("ng_plus"):
            self.game.show_hints = True

    def _start_streamed(self, start_chunk: int, carried_state: dict | None) -> None:
        if getattr(self.args, "loadout", None) == "full":
            # calibration parity: recorded runs must reproduce
            # tune_pass_rate farm runs exactly. This is the single
            # chokepoint every start path funnels through (menu,
            # autoplay, --level); the first landing put it only on the
            # menu path and every '--loadout full' bot recording
            # silently ran knife+pistol (caught by the shadow-run
            # divergence hunt: ammo {'9mm': 48} vs the full kit).
            import copy
            from .testkit.loadouts import FULL_LOADOUT
            carried_state = copy.deepcopy(FULL_LOADOUT)
        from .stream import WorldStreamer
        paths = self.campaign_levels()
        if not paths:
            self._load_and_play(0, carried_state=carried_state)
            return
        self.current_level_index = start_chunk
        level = load_level(REPO_ROOT / paths[start_chunk])
        game = GameScene(level, self.rng_seed + start_chunk,
                         player_state=carried_state,
                         level_path=str(paths[start_chunk]),
                         difficulty=self.settings.get('difficulty', 'normal'))
        game.streamer = WorldStreamer(
            game.session, [str(REPO_ROOT / p) for p in paths],
            start_chunk=start_chunk)
        # each streamed chunk is its own levels/*.json (its own level_id);
        # key bespoke floor textures off the streamer's engine-polygon -> chunk
        # mapping instead of the single Level the renderer was built with.
        game.renderer.polygon_texture_lookup = game.streamer.polygon_texture_key

        def on_entered(chunk_idx, name):
            self.current_level_index = chunk_idx
            self.save_data["unlocked"] = max(
                self.save_data.get("unlocked", 1), chunk_idx + 1)
            self.save_data.setdefault("states", {})[str(chunk_idx)] = \
                game.streamer.entry_states[game.streamer.current]
            self._persist_save()
            self.rotate_music()          # a new depth gets a new hymn

        game.streamer.on_chunk_entered = on_entered
        self.game = game
        self.scenes = [game]
        game.on_enter(self)

    def start_level_index(self, idx: int) -> None:
        state = self.save_data.get("states", {}).get(str(idx))
        self._start_streamed(idx, state)

    def _load_and_play(self, idx: int, carried_state: dict | None) -> None:
        level, path = self._load_level_by_index(idx)
        self._level_start_state = carried_state
        seed = self.rng_seed + idx
        game = GameScene(level, seed, player_state=carried_state, level_path=path, difficulty=self.settings.get('difficulty', 'normal'))
        self.game = game
        self.replace(game)

    def reprint(self) -> None:
        """Death recovery. A racked chassis prints at the nearest seed with
        the world left as it lies (the wreck included); with none racked,
        fall back to the cold restore."""
        if self.game is not None and \
                self.game.session.respawn_at_station():
            self.game.objective = None
            self.game.float_texts.clear()
            return
        self.restart_level()

    def restart_level(self) -> None:
        if self.game is not None and self.game.streamer is not None:
            self.game.objective = None
            self.game.float_texts.clear()
            self.game.streamer.respawn()
            return
        self._load_and_play(self.current_level_index, carried_state=self._level_start_state)

    def advance_level(self, carried_state: dict) -> None:
        idx = self.current_level_index + 1
        paths = self.campaign_levels()
        if idx >= len(paths):
            self.save_data["unlocked"] = max(self.save_data.get("unlocked", 1), idx)
            # the watch continues: the campaign loops on hard, arsenal kept
            self.save_data["ng_plus"] = self.save_data.get("ng_plus", 0) + 1
            self.save_data["ng_state"] = carried_state
            self._persist_save()
            self.replace(menus.WinScene(
                epilogue_text(self.save_data.get("trust_total", 0)) +
                "\n\nTHE WATCH CONTINUES.\n"
                "New Game+ unlocked: the loop begins again,\n"
                "harder, with everything you carry."))
            return
        self.save_data["unlocked"] = max(self.save_data.get("unlocked", 1), idx + 1)
        self.save_data.setdefault("states", {})[str(idx)] = carried_state
        self._persist_save()
        self.current_level_index = idx
        self._load_and_play(idx, carried_state=carried_state)
        # Between-sortie conversation (bible: "the frame is in transit; the
        # minds talk"), pushed above the just-loaded GameScene. Only
        # campaign advancement lands here -- starting a level from the
        # select menu never replays the gap conversation. Skipped headless.
        if not self.dummy:
            self._push_gap_conversation(idx - 1)

    # ------------------------------------------------------------------

    def _push_gap_conversation(self, gap: int) -> None:
        """Composites DIALOGUE_SCRIPT.md's scene `gap` against persistent
        state (conversations.conversation_for -> script_compositor) and
        pushes it as a ConversationScene, if that gap's scene has content at
        the current trust/flags. Effects that already fired unconditionally
        (base_trust/base_flags -- e.g. a pre-choice catch, or a no-choice
        scene) are seeded into the scene so on_trust/on_flags reports them
        exactly once at scene completion, same as choice-driven effects."""
        from .conversations import conversation_for
        from .convscene import ConversationScene
        bundle = conversation_for(gap, self.save_data.get("trust_total", 0),
                                   self.save_data.get("flags", []))
        if bundle and bundle.lines:
            self.push(ConversationScene(
                bundle.lines, on_trust=self._add_trust, on_flags=self._add_flags,
                initial_trust=bundle.base_trust, initial_flags=bundle.base_flags))

    def _add_trust(self, delta: int) -> None:
        """Trust accrued across conversations gates late-game variants
        (conversations.conversation_for); persisted with the save."""
        self.save_data["trust_total"] = \
            self.save_data.get("trust_total", 0) + delta
        self._persist_save()

    def _add_flags(self, flags: list) -> None:
        """Flags set by a gap conversation, persisted with the save. The
        faith-scaffold mirror died with the placeholder compositor (the
        mind map owns real faith; the director's script loader will define
        any successor flag taxonomy)."""
        current = set(self.save_data.get("flags", []))
        current.update(flags)
        self.save_data["flags"] = sorted(current)
        self._persist_save()

    def take_screenshot(self) -> None:
        out_dir = Path(os.environ.get("PERIHELION_SCREENSHOT_DIR", str(save_dir() / "screenshots")))
        try:
            out_dir.mkdir(parents=True, exist_ok=True)
            path = out_dir / f"screenshot_{int(time.time())}.png"
            pygame.image.save(self.internal, str(path))
            print(f"[screenshot] saved {path}", file=sys.stderr)
        except OSError as exc:
            print(f"[screenshot] failed: {exc}", file=sys.stderr)

    # ------------------------------------------------------------------
    # main loop
    # ------------------------------------------------------------------

    def _start_scene(self) -> None:
        if self.dummy or self.args.autoplay:
            start = getattr(self.args, "start_chunk", 0)
            if start:
                self._start_streamed(start, None)
            else:
                self.start_new_game()
        else:
            self.push(menus.TitleScene())

    def run(self) -> None:
        accumulator = 0.0
        last = time.perf_counter()
        while self.running:
            if self._rec is not None:
                # lockstep: exactly one 60Hz sim tick per recorded frame,
                # decoupled from wall time so capture speed doesn't matter
                frame_dt = DT
                accumulator = DT
                last = time.perf_counter()
            else:
                now = time.perf_counter()
                frame_dt = min(0.25, now - last)
                last = now
                accumulator += frame_dt

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    self.running = False
                elif event.type == pygame.VIDEORESIZE:
                    self._recompute_layout()
                elif event.type == pygame.KEYDOWN and event.key == pygame.K_F11:
                    self._toggle_fullscreen()
                elif self.scenes:
                    self.scenes[-1].handle_event(self, event)
            if getattr(self.args, "autoplay", False) and self.scenes:
                top = self.scenes[-1]
                # soaks must test gameplay, not a press-any-key card
                if not isinstance(top, GameScene):
                    scene_kind = type(top).__name__
                    self._autoplay_wait = getattr(self, "_autoplay_wait", 0) + 1
                    dwell = 90
                    if self._autoplay_wait > dwell:
                        self._autoplay_wait = 0
                        top.handle_event(self, pygame.event.Event(
                            pygame.KEYDOWN, key=pygame.K_SPACE, unicode=" "))
                        if self.scenes and self.scenes[-1] is top and \
                                not isinstance(top, GameScene):
                            if scene_kind == "ConversationScene":
                                # waiting on a dialogue choice: pick option 1
                                # rather than skipping the scene
                                top.handle_event(self, pygame.event.Event(
                                    pygame.KEYDOWN, key=pygame.K_1, unicode="1"))
                            else:
                                top.handle_event(self, pygame.event.Event(
                                    pygame.KEYDOWN, key=pygame.K_ESCAPE))

            ticks_this_frame = 0
            while accumulator >= DT and ticks_this_frame < 4:
                if self.scenes and isinstance(self.scenes[-1], GameScene):
                    self._tick_game(self.scenes[-1])
                accumulator -= DT
                ticks_this_frame += 1

            if self.scenes:
                self.scenes[-1].update(self, frame_dt)

            self._draw_frame()
            if self._rec is not None:
                self._record_frame()
            self.clock.tick(0 if self.dummy else 60)
        if self._rec is not None:
            self._rec["events"].close()
            if self._rec.get("inputs") is not None:
                self._rec["inputs"].close()
            print(f"[record] {self._rec['saved']} frames + events.jsonl in "
                  f"{self._rec['dir']}", file=sys.stderr)
        if self._trace_writer is not None:
            self._trace_writer.close()
        self._persist_save()

    def _log_bot_event(self, kind: str, payload: dict) -> None:
        if self._rec is None:
            return
        self._rec["events"].write(json.dumps(
            dict(t=self._rec["frames"] / 60.0, kind=kind, **payload)) + "\n")

    def _tick_game(self, game: GameScene) -> None:
        if self.bot is not None:
            snap = game.session.snapshot()
            if self.bot_tactician is not None:
                record = self.bot_tactician.maybe_consult(
                    snap, game.session, snap["tick"])
                if record is not None:
                    self._log_bot_event("tactician_consult", record)
            inp = self.bot.step(snap, game.session)
            # bots don't seek terminals; read any we brush past so recorded
            # runs still show terminal text and relay conversations
            px, py = snap["pos"]
            for t in game.session.terminals:
                if not t["read"] and t["polygon"] == snap["polygon"] and \
                        math.hypot(t["pos"][0] - px, t["pos"][1] - py) < 26.0:
                    inp.interact = True
                    break
        else:
            inp = game._input_frame(self)
        if self._rec is not None and self._rec.get("inputs") is not None:
            # input stream capture (director 2026-07-19: human play must
            # be studyable — frames alone can't be re-simulated; the
            # per-tick InputFrame stream can)
            self._rec["inputs"].write(json.dumps(dict(
                t=game.session.tick_count, mx=inp.mx, my=inp.my,
                ax=inp.ax, ay=inp.ay, fire=bool(inp.fire),
                alt=bool(inp.alt), weapon=inp.weapon,
                interact=bool(getattr(inp, "interact", False)))) + "\n")
        was_dead = game.session.dead
        was_complete = game.session.complete
        game.session.tick(inp)
        if game.streamer is not None:
            game.streamer.tick()
        self._drain_session_trace(game)
        fx = game.session.fx

        game.renderer.consume_fx(fx)
        self.audio.handle_sounds(game.session, fx)
        self.audio.update_heartbeat(game.session)
        self.music.update(game.session)

        for ev in fx:
            if ev[0] == "shake" and self.settings.get("shake", True):
                game.shakes.append([ev[1], 10])
            elif ev[0] == "objective":
                game.objective = (ev[1], OBJECTIVE_TICKS)
            elif ev[0] == "terminal":
                if ev[1].startswith("__CONV__"):
                    self._push_gap_conversation(int(ev[1][8:]))
                else:
                    self.push(menus.TerminalOverlay(ev[1]))
            elif ev[0] == "pickup_text":
                import necore
                sx, sy = necore.mat_apply(game.session.cam, *ev[2])
                # simultaneous pickups smear into one blob at the same
                # spot: stack against each float's CURRENT rendered y (they
                # rise ~0.35px/tick from their base), not its spawn y
                _s = INTERNAL_RES_ZOOM_SCALE

                def _vis_y(ft):
                    return ft[1] - (66 - ft[3]) * 0.35 * _s
                while any(abs(ft[0] - sx) < 46 * _s and
                          abs(_vis_y(ft) - sy) < 11 * _s
                          for ft in game.float_texts):
                    sy -= 11 * _s
                game.float_texts.append([sx, sy, ev[3], 66])
            elif ev[0] == "shop":
                from .podscene import PodScene
                if not any(isinstance(sc, PodScene) for sc in self.scenes):
                    self.push(PodScene(game.session))
            elif ev[0] == "logvoice":
                line = corpse_line(ev[1])
                if line:
                    game.logvoice = (line, 60 * 7)
            elif ev[0] == "locname":
                game.loc_title = (ev[1], 60 * 4)
            elif ev[0] == "ambience":
                pass    # ambience fx retired -- music owns the bed
        game.shakes = [[m * 0.82, t - 1] for m, t in game.shakes if t > 1 and m > 0.05]

        if not was_dead and game.session.dead:
            self.push(menus.DeathScene(game.session.metrics["deaths"],
                                       chassis=game.session.chassis))
            return
        if not was_complete and game.session.complete:
            carried = dict(hp=max(game.session.hp, 40), ammo=dict(game.session.ammo),
                           holes=game.session.holes,
                           cloister=game.session.cloister is not None,
                           weapons=list(game.session.weapons), weapon=game.session.weapon,
                           components=game.session.components,
                           chassis=game.session.chassis,
                           station_kits=game.session.station_kits,
                           max_hp=game.session.max_hp,
                           hp_ups=game.session.hp_ups,
                           recalls=game.session.recalls,
                           mind=sorted(game.session.mind),
                           think_focus=game.session.think_focus,
                           think_progress=dict(game.session.think_progress),
                           think_done=list(game.session.think_done))
            if game.streamer is not None:
                self.save_data["ng_plus"] = self.save_data.get("ng_plus", 0) + 1
                self.save_data["ng_state"] = carried
                self._persist_save()
                self.replace(menus.WinScene(
                    epilogue_text(self.save_data.get("trust_total", 0)) +
                    "\n\nTHE WATCH CONTINUES.\n"
                    "New Game+ unlocked: the loop begins again,\n"
                    "harder, with everything you carry."))
                return
            self.advance_level(carried)

    # ------------------------------------------------------------------

    def _draw_frame(self) -> None:
        self.internal.fill((0, 0, 0))
        if self.scenes:
            self.scenes[-1].draw(self, self.internal)
        if self.debug:
            self._draw_fps_overlay()
        self._blit_scaled()
        pygame.display.flip()

    def _draw_fps_overlay(self) -> None:
        f = menus.get_font(11)
        img = f.render(f"{self.clock.get_fps():.0f} fps", True, (255, 255, 0))
        self.internal.blit(img, (ui(4), ui(4)))

    def _blit_scaled(self) -> None:
        pygame.transform.scale(self.internal, self._scaled_surface.get_size(), self._scaled_surface)
        self.screen.fill((0, 0, 0))
        ox, oy = self._offset
        sx, sy = 0.0, 0.0
        if self.scenes and isinstance(self.scenes[-1], GameScene) and self.game is not None:
            sx, sy = self._shake_offset(self.game)
        self._blit_offset = (ox + sx, oy + sy)
        self.screen.blit(self._scaled_surface, self._blit_offset)

    def _shake_offset(self, game: GameScene) -> tuple[float, float]:
        dx = dy = 0.0
        for mag, _t in game.shakes:
            dx += random.uniform(-mag, mag)
            dy += random.uniform(-mag, mag)
        dx = max(-9.0, min(9.0, dx)) * self._scale
        dy = max(-9.0, min(9.0, dy)) * self._scale
        return dx, dy
