"""PERIHELION session DAW — the winning run as a scrub-able project.

    uv run python tools/musicgen/daw.py                # the winning session
    uv run python tools/musicgen/daw.py REC_DIR        # any taps recording

Opens gauntlet_winning_session_v1 (649s, full 4-boss clear) as a DAW
project window: video monitor, transport, section/bank ruler, the three
value automation curves, one track strip per lane with its gain
automation and clip content, and event markers (jumps, risers, slams,
stings, death halts).

The mix is rebuilt from the recording's decision log by the SAME
offline mixer that renders the shipped videos, reading the SAME bank
folders the game reads — what you hear is what the game plays.

REPLACE-AND-HEAR: the tool watches every bank folder this session
uses. Overwrite any stem file (drop a new prayer.wav into the bank
folder) and the mix rebuilds in ~1-2s at the same playhead — scrub
back, listen again, iterate. WAV beats OGG on the same name in the
same folder, so dropping `prayer.wav` next to `prayer.ogg` auditions
your replacement without deleting the original.

Transport / controls
  SPACE        play / pause (or click the transport glyph)
  click/drag   seek / scrub (anywhere in the timeline)
  LEFT/RIGHT   nudge one bar    (SHIFT: 10 s)
  HOME / END   start / end
  M / S boxes  mute / solo a track (click; rebuild is ~1 s)
  track name   click selects a track; M / S keys then mute/solo it
  time readout click, type mm:ss (or seconds), ENTER jumps
  bank title   click: audition a different bank over this session
  video        click: enlarge / shrink
  P/C/S labels click: show / hide that curve
  CLIP         click: reset the clip latch
  R            force rebuild
  ESC          close overlay / cancel entry / quit
Hover any control for a tooltip.
"""
from __future__ import annotations

import argparse
import io
import json
import subprocess
import sys
import threading
import time
from pathlib import Path

import numpy as np
import pygame

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/playtest"))
import mkvideo as MK                                    # noqa: E402

DEFAULT_REC = ROOT / "out/winning_session_v1_rec"
DEFAULT_VIDEO = ROOT / "out/gauntlet_winning_session_v1.mp4"

RATE = MK.RATE
CHUNK_S = 0.2
CHUNK = int(CHUNK_S * RATE)

LANES = ["holy", "bed", "drums", "wall", "groove", "lead", "lead2",
         "bass", "boss"]
FX = "fx"          # riser / riser_half / sting / stab as one mute group
LANE_COL = {
    "holy": (212, 175, 96), "bed": (110, 110, 140),
    "drums": (200, 120, 70), "wall": (200, 80, 80),
    "groove": (220, 160, 90), "lead": (120, 200, 160),
    "lead2": (90, 160, 130), "bass": (140, 110, 200),
    "boss": (230, 70, 110), FX: (170, 170, 170),
}
SECT_COL = {
    "vigil": (60, 80, 110), "ritual": (70, 70, 110),
    "entry": (110, 100, 60), "develop": (120, 80, 50),
    "peak": (130, 50, 50), "outro": (60, 90, 70),
    "rebuild": (70, 90, 90),
}
VAL_COL = ((120, 170, 220), (220, 160, 90), (200, 80, 80))  # P/C/S

# cross-rebuild stem cache keyed by (path, mtime): a rebuild after one
# replaced file re-decodes ONLY that file (~1s total instead of ~9s)
_stem_cache: dict = {}
_orig_load_stem = MK._load_stem


def _cached_load_stem(p):
    key = (str(p), p.stat().st_mtime_ns)
    v = _stem_cache.get(key)
    if v is None:
        v = _orig_load_stem(p)
        for k in [k for k in _stem_cache if k[0] == key[0]]:
            del _stem_cache[k]
        _stem_cache[key] = v
    return v


MK._load_stem = _cached_load_stem


def _apply_mutes(events: list, muted: set) -> list:
    """Mute/solo happens in the DECISION LOG, not the mixer: a muted
    lane's bar entries are rewritten to silence and the mixer renders
    them exactly as if the engine had never played that lane."""
    if not muted:
        return events
    out = []
    for e in events:
        k = e["kind"]
        if FX in muted and k in ("music_riser", "music_riser2",
                                 "music_sting", "music_stab"):
            continue
        if k == "music_bar":
            parts = e["name"].split("|")
            new = [parts[0]]
            for lane in parts[1:]:
                ln = lane.rsplit(":", 2)[0]
                new.append(f"{ln}:silence:0.000" if ln in muted else lane)
            e = dict(e, name="|".join(new))
        out.append(e)
    return out


class Project:
    """The recording, parsed once for display."""

    def __init__(self, rec: Path, use: str | None = None):
        evfile = rec / "events.jsonl" if rec.is_dir() else rec
        self.events = [json.loads(l)
                       for l in evfile.read_text().splitlines()]
        if use:
            # audition ONE bank under this session's decisions: every
            # bank-rotation event is remapped to the named bank (the
            # mixer wraps form positions by the bank's own bar count)
            if MK._resolve_bank(use) is None:
                raise SystemExit(f"--use {use}: no such bank under "
                                 f"{[str(r) for r in MK.MUSIC_ROOTS]}")
            self.events = [dict(e, name=use)
                           if e["kind"] == "music_bank" else e
                           for e in self.events]
        self.dur = max(e["t"] for e in self.events) + 2.0
        self.bars = []          # (t, form_idx, {lane: (key, gain)})
        for e in self.events:
            if e["kind"] != "music_bar":
                continue
            parts = e["name"].split("|")
            lanes = {}
            for lane in parts[1:]:
                ln, key, g = lane.rsplit(":", 2)
                lanes[ln] = (key, float(g))
            self.bars.append((e["t"], int(parts[0]), lanes))
        self.vals = [(e["t"],
                      tuple(float(v) for v in e["name"].split(",")))
                     for e in self.events if e["kind"] == "music_valslp"]
        bank_evs = [e for e in self.events if e["kind"] == "music_bank"]
        self.banks = []         # (t0, t1, name, meta|None, dir|None)
        for i, e in enumerate(bank_evs):
            t1 = bank_evs[i + 1]["t"] if i + 1 < len(bank_evs) \
                else self.dur
            d = MK._resolve_bank(e["name"])
            meta = json.loads((d / "bank.json").read_text()) \
                if d else None
            self.banks.append((e["t"], t1, e["name"], meta, d))
        self.marks = [(e["t"], e["kind"], str(e["name"]))
                      for e in self.events
                      if e["kind"] in ("music_jump", "music_halt",
                                       "music_sting", "music_stab",
                                       "music_riser2")]
        r_on, prev = [], 0.0
        for e in self.events:
            if e["kind"] == "music_riser":
                v = float(e["name"])
                if v > 0.01 and prev <= 0.01:
                    r_on.append((e["t"], "music_riser", ""))
                prev = v
        self.marks += r_on
        ts = [b[0] for b in self.bars]
        self.bar_s = float(np.median(np.diff(ts))) if len(ts) > 2 else 2.18

    def bank_at(self, t):
        for t0, t1, name, meta, d in self.banks:
            if t0 <= t < t1:
                return name, meta, d
        if self.banks:
            return self.banks[-1][2], self.banks[-1][3], self.banks[-1][4]
        return None, None, None

    def bar_at(self, t):
        lo, hi = 0, len(self.bars) - 1
        while lo < hi:
            mid = (lo + hi + 1) // 2
            if self.bars[mid][0] <= t:
                lo = mid
            else:
                hi = mid - 1
        return self.bars[lo] if self.bars else (0.0, 0, {})

    def section_at(self, t):
        _, meta, _ = self.bank_at(t)
        if not meta:
            return ""
        idx = self.bar_at(t)[1] % int(meta["bars"])
        for s, a, b in meta["sections"]:
            if a <= idx < b:
                return s
        return ""

    def watch_dirs(self):
        """Every folder whose files can change this mix — both music
        roots for each bank name, so a change to a SHADOWED copy can
        be flagged instead of silently ignored."""
        dirs = []
        for _, _, name, _, _ in self.banks:
            for root in MK.MUSIC_ROOTS:
                d = root / name
                if d.exists() and d not in dirs:
                    dirs.append(d)
        return dirs


class Player:
    """Chunk-streamed playback with instant seek (the engine's own
    queue trick, pointed at the rendered session mix)."""

    def __init__(self):
        self.ch = pygame.mixer.Channel(0)
        self.buf = None                # int16 (N, 2)
        self.playing = False
        self.t = 0.0
        self._idx = 0
        self._wall = 0.0
        self._sounds = (None, None)

    def set_buffer(self, buf):
        was = self.playing
        t = self.playhead()
        self.buf = buf
        self.seek(t)
        if was:
            self.play()

    def _chunk(self, i):
        a = i * CHUNK
        if self.buf is None or a >= len(self.buf):
            return None
        seg = self.buf[a:a + CHUNK]
        if len(seg) < CHUNK:
            seg = np.vstack([seg, np.zeros((CHUNK - len(seg), 2),
                                           np.int16)])
        return pygame.mixer.Sound(buffer=np.ascontiguousarray(seg)
                                  .tobytes())

    def playhead(self):
        if not self.playing:
            return self.t
        return min(self._idx * CHUNK_S + (time.time() - self._wall),
                   len(self.buf) / RATE if self.buf is not None else 0)

    def seek(self, t):
        self.t = max(0.0, t)
        if self.playing:
            self._start()

    def _start(self):
        self._idx = int(self.t / CHUNK_S)
        c0, c1 = self._chunk(self._idx), self._chunk(self._idx + 1)
        if c0 is None:
            self.pause()
            return
        self.ch.play(c0)
        if c1 is not None:
            self.ch.queue(c1)
        self._sounds = (c0, c1)
        self._wall = time.time()

    def play(self):
        if self.buf is None:
            return
        self.playing = True
        self._start()

    def pause(self):
        self.t = self.playhead()
        self.playing = False
        self.ch.stop()

    def poll(self):
        if not self.playing:
            return
        if self.ch.get_queue() is None:
            self._idx += 1
            self._wall = time.time()
            nxt = self._chunk(self._idx + 1)
            if nxt is not None:
                self.ch.queue(nxt)
                self._sounds = (self._sounds[1], nxt)
            elif not self.ch.get_busy():
                self.pause()


class VideoMonitor:
    """Frame-at-playhead from the rendered mp4 (ffmpeg seek, async)."""

    def __init__(self, video: Path | None, size=(320, 180),
                 big=(640, 360)):
        self.video = video if video and video.exists() else None
        self.size = size
        self.big_size = big             # the mp4's native resolution
        self.cache: dict = {}
        self.native: dict = {}          # big-mode frames, small cap
        self.want = None
        self.cur = None
        self._cv = threading.Condition()
        if self.video:
            threading.Thread(target=self._worker, daemon=True).start()

    def request(self, t, big: bool = False):
        if not self.video:
            return None
        q = round(t * 2) / 2
        store = self.native if big else self.cache
        if q in store:
            self.cur = store[q]
            return self.cur
        with self._cv:
            self.want = (q, big)
            self._cv.notify()
        if big and q in self.cache:     # upscale small while native
            return pygame.transform.smoothscale(self.cache[q],
                                                self.big_size)
        return self.cur                 # last frame while seeking

    def _worker(self):
        while True:
            with self._cv:
                while self.want is None:
                    self._cv.wait()
                (q, big), self.want = self.want, None
            store = self.native if big else self.cache
            if q in store:
                continue
            try:
                out = subprocess.run(
                    ["ffmpeg", "-v", "error", "-ss", f"{q:.2f}",
                     "-i", str(self.video), "-frames:v", "1",
                     "-f", "image2pipe", "-vcodec", "bmp", "-"],
                    capture_output=True, timeout=10).stdout
                img = pygame.image.load(io.BytesIO(out), "f.bmp")
                surf = pygame.transform.smoothscale(
                    img, self.big_size if big else self.size)
            except Exception:
                continue
            cap = 60 if big else 400
            if len(store) > cap:
                store.pop(next(iter(store)))
            store[q] = surf


class App:
    def __init__(self, rec: Path, video: Path | None,
                 headless: bool = False, use: str | None = None):
        if headless:
            import os
            os.environ["SDL_VIDEODRIVER"] = "dummy"
            os.environ["SDL_AUDIODRIVER"] = "dummy"
        pygame.mixer.pre_init(RATE, -16, 2, 512)
        pygame.init()
        self.W, self.H = 1280, 720
        self.screen = pygame.display.set_mode((self.W, self.H))
        pygame.display.set_caption("PERIHELION session DAW")
        self.font = pygame.font.SysFont("monospace", 13)
        self.big = pygame.font.SysFont("monospace", 17, bold=True)
        self.rec = rec
        self._use = use
        self.proj = Project(rec, use=use)
        self.player = Player()
        self.video = VideoMonitor(video)
        # interaction state (affordance-audit pass, 2026-07-18)
        self._goto = None           # typed go-to buffer, None = inactive
        self.video_big = False
        self.picker = False         # bank-picker overlay open
        self._picker_rows = []      # (rect, bank-name-or-None)
        self.curve_off: set = set() # hidden P/C/S curves (indices)
        self.sel = None             # selected track (keyboard M/S)
        self._hit = {}              # element -> rect, rebuilt per draw
        self._hover = (None, 0.0)   # (element, hover-start wall time)
        self.muted: set = set()
        self.solo: set = set()
        self.status = "rendering…"
        self.clip = False
        self.scale = None           # fixed across rebuilds: a louder
        #                             replacement must SOUND louder
        self.overview = None
        self._gen = 0
        self._lock = threading.Lock()
        self._mtimes = self._scan()
        self._shadow_note = ""
        # timeline geometry
        self.x0, self.x1 = 128, self.W - 12
        self.rows = {}
        y = 236
        self.y_ruler = y; y += 20
        self.y_sect = y; y += 14
        self.y_wave = y; y += 64
        self.y_vals = y; y += 56
        for ln in LANES + [FX]:
            self.rows[ln] = y
            y += 26
        self.y_marks = y
        self.rebuild()
        threading.Thread(target=self._watch, daemon=True).start()

    # ---- render pipeline -------------------------------------------------
    def rebuild(self, note="rebuilding…"):
        self._gen += 1
        gen = self._gen
        self.status = note
        evs = _apply_mutes(self.proj.events, self._effective_mutes())
        threading.Thread(target=self._render, args=(evs, gen),
                         daemon=True).start()

    def _effective_mutes(self):
        if self.solo:
            return (set(LANES) | {FX}) - self.solo
        return set(self.muted)

    def _render(self, evs, gen):
        t0 = time.time()
        mix = np.zeros((int(self.proj.dur * RATE) + RATE, 2), np.float32)
        ok = MK._mix_music_rich(mix, evs, self.proj.dur)
        if gen != self._gen:
            return                      # superseded by a newer rebuild
        if not ok:
            self.status = "NO MUSIC TAPS in this recording"
            return
        pk = float(np.abs(mix).max()) or 1.0
        if self.scale is None:
            self.scale = 0.9 / pk
        out = mix * self.scale
        self.clip = bool(np.abs(out).max() > 1.0)
        buf = (np.clip(out, -1, 1) * 32767).astype(np.int16)
        ov = self._overview(buf)
        with self._lock:
            if gen != self._gen:
                return
            self.player.set_buffer(buf)
            self.overview = ov
            self.status = f"ready ({time.time() - t0:.1f}s)"

    def _overview(self, buf):
        w = self.x1 - self.x0
        mono = buf[:, 0].astype(np.float32) / 32767.0
        n = len(mono) // w * w
        bins = np.abs(mono[:n].reshape(w, -1)).max(axis=1)
        return bins

    # ---- file watcher ----------------------------------------------------
    def _scan(self):
        mt = {}
        for d in self.proj.watch_dirs():
            for f in list(d.glob("*.wav")) + list(d.glob("*.ogg")) + \
                    [d / "bank.json"]:
                if f.exists():
                    mt[str(f)] = f.stat().st_mtime_ns
        return mt

    def _watch(self):
        while True:
            time.sleep(0.7)
            mt = self._scan()
            changed = [p for p in mt
                       if mt[p] != self._mtimes.get(p)] + \
                      [p for p in self._mtimes if p not in mt]
            if not changed:
                continue
            self._mtimes = mt
            names = ", ".join(Path(p).name for p in changed[:3])
            # shadow check: does the changed file actually win
            # resolution? (wav beats ogg in-folder; first MUSIC_ROOT
            # wins across folders)
            self._shadow_note = ""
            for p in changed:
                pp = Path(p)
                d = MK._resolve_bank(pp.parent.name)
                if d is not None and d != pp.parent:
                    self._shadow_note = (f"⚠ {pp.name} changed in a "
                                         f"SHADOWED copy — {d} wins")
            time.sleep(0.3)             # let the writer finish
            self.rebuild(f"reload: {names}")

    # ---- bank switching (in-app --use) -----------------------------------
    def available_banks(self):
        names, seen = [], set()
        for root in MK.MUSIC_ROOTS:
            for d in sorted(root.glob("album_*")):
                if (d / "bank.json").exists() and d.name not in seen:
                    seen.add(d.name)
                    names.append(d.name)
        return names

    def set_bank(self, name):
        """Re-score the whole session with one bank (None = original)."""
        t = self.player.playhead()
        self.player.pause()
        self._use = name
        self.proj = Project(self.rec, use=name)
        self._mtimes = self._scan()
        self.scale = None           # fresh loudness anchor per score
        self.player.t = min(t, self.proj.dur - 1.0)
        self.rebuild(f"scoring with {name or 'session banks'}…")

    def _goto_commit(self):
        txt = (self._goto or "").strip()
        self._goto = None
        if not txt:
            return
        try:
            if ":" in txt:
                m, s = txt.split(":", 1)
                t = int(m) * 60 + float(s or 0)
            else:
                t = float(txt)
            self.player.seek(t)
        except ValueError:
            self.status = f"can't read '{txt}' — use mm:ss or seconds"

    # ---- interaction -----------------------------------------------------
    def handle(self, ev):
        if ev.type == pygame.KEYDOWN:
            if self._goto is not None:      # time-entry mode owns keys
                if ev.key == pygame.K_ESCAPE:
                    self._goto = None
                elif ev.key == pygame.K_RETURN:
                    self._goto_commit()
                elif ev.key == pygame.K_BACKSPACE:
                    self._goto = self._goto[:-1]
                elif ev.unicode and ev.unicode in "0123456789:.":
                    self._goto += ev.unicode
                return True
            if ev.key == pygame.K_ESCAPE:
                if self.picker:
                    self.picker = False
                elif self.video_big:
                    self.video_big = False
                else:
                    return False
            elif ev.key == pygame.K_SPACE:
                (self.player.pause if self.player.playing
                 else self.player.play)()
            elif ev.key == pygame.K_r:
                _stem_cache.clear()
                self.rebuild("full reload")
            elif ev.key == pygame.K_m and self.sel:
                self.muted ^= {self.sel}
                self.rebuild()
            elif ev.key == pygame.K_s and self.sel:
                self.solo ^= {self.sel}
                self.rebuild()
            elif ev.key in (pygame.K_LEFT, pygame.K_RIGHT):
                step = 10.0 if ev.mod & pygame.KMOD_SHIFT \
                    else self.proj.bar_s
                d = step if ev.key == pygame.K_RIGHT else -step
                self.player.seek(self.player.playhead() + d)
            elif ev.key == pygame.K_HOME:
                self.player.seek(0.0)
            elif ev.key == pygame.K_END:
                self.player.seek(self.proj.dur - 5.0)
        elif ev.type == pygame.MOUSEBUTTONDOWN and ev.button == 1:
            x, y = ev.pos
            if self.picker:
                for r, name in self._picker_rows:
                    if r.collidepoint(x, y):
                        self.picker = False
                        self.set_bank(name)
                        return True
                self.picker = False
                return True
            if self.video_big:
                self.video_big = False
                return True
            for el, r in self._hit.items():
                if not r.collidepoint(x, y):
                    continue
                if el == "play_glyph":
                    (self.player.pause if self.player.playing
                     else self.player.play)()
                elif el == "time_readout":
                    self._goto = ""
                elif el == "clip_chip":
                    self.clip = False
                elif el == "bank_title":
                    self.picker = True
                elif el == "video_monitor":
                    self.video_big = True
                elif el.startswith("curve:"):
                    self.curve_off ^= {int(el.split(":")[1])}
                elif el.startswith("name:"):
                    ln = el.split(":")[1]
                    self.sel = None if self.sel == ln else ln
                elif el.startswith("mute:"):
                    self.muted ^= {el.split(":")[1]}
                    self.rebuild()
                elif el.startswith("solo:"):
                    self.solo ^= {el.split(":")[1]}
                    self.rebuild()
                return True
            if self.x0 <= x <= self.x1 and \
                    self.y_ruler <= y <= self.y_marks + 22:
                self._drag_seek(x)
                self.dragging = True
        elif ev.type == pygame.MOUSEBUTTONUP:
            self.dragging = False
        elif ev.type == pygame.MOUSEMOTION and \
                getattr(self, "dragging", False):
            self._drag_seek(ev.pos[0])
        return True

    def _drag_seek(self, x):
        f = (x - self.x0) / (self.x1 - self.x0)
        self.player.seek(max(0.0, min(1.0, f)) * self.proj.dur)

    # ---- drawing ----------------------------------------------------------
    def _tx(self, t):
        return self.x0 + int((self.x1 - self.x0) * t / self.proj.dur)

    def txt(self, s, x, y, c=(200, 200, 200), f=None):
        self.screen.blit((f or self.font).render(s, True, c), (x, y))

    def draw(self):
        scr = self.screen
        scr.fill((18, 18, 22))
        self._hit = {}
        t = self.player.playhead()
        # transport bar
        pygame.draw.rect(scr, (28, 28, 34), (0, 0, self.W, 36))
        self.txt(">" if not self.player.playing else "||", 14, 8,
                 (240, 220, 160), self.big)
        self._hit["play_glyph"] = pygame.Rect(8, 2, 34, 30)
        bar_t, bar_idx, _ = self.proj.bar_at(t)
        name, meta, d = self.proj.bank_at(t)
        sect = self.proj.section_at(t)
        if self._goto is not None:
            pygame.draw.rect(scr, (50, 50, 30), (44, 6, 130, 24))
            pygame.draw.rect(scr, (240, 220, 160), (44, 6, 130, 24), 1)
            self.txt(f"{self._goto}_", 50, 10, (255, 255, 200), self.big)
        else:
            mm, ss = divmod(int(t), 60)
            self.txt(f"{mm:02d}:{ss:02d}.{int((t % 1) * 10)}", 48, 10,
                     (255, 255, 255), self.big)
        self._hit["time_readout"] = pygame.Rect(44, 6, 130, 24)
        self.txt(f"bar {bar_idx % (meta['bars'] if meta else 1):>2}"
                 f"  {sect:<8}", 180, 10, (240, 220, 160), self.big)
        title = meta.get("title", name) if meta else str(name)
        self.txt(f"{title}", 350, 10, (200, 200, 220), self.big)
        self._hit["bank_title"] = pygame.Rect(346, 4, 300, 28)
        st_col = (140, 220, 140) if self.status.startswith("ready") \
            else (240, 200, 100)
        self.txt(self.status, 700, 12, st_col)
        if self.clip:
            self.txt("CLIP", 900, 12, (255, 80, 80), self.big)
            self._hit["clip_chip"] = pygame.Rect(896, 8, 62, 24)
        if self._shadow_note:
            self.txt(self._shadow_note, 320, 40, (255, 160, 80))
        # info panel
        self.txt("SESSION  gauntlet_winning_session_v1 — seed 7095, "
                 "full clear", 12, 60, (240, 220, 160))
        self.txt(f"length {int(self.proj.dur // 60)}:"
                 f"{int(self.proj.dur % 60):02d}   "
                 f"{len(self.proj.bars)} bars   "
                 f"{len(self.proj.banks)} bank passes", 12, 80)
        self.txt("banks read from:", 12, 104, (170, 170, 190))
        yy = 122
        seen = set()
        for _, _, nm, _, dd in self.proj.banks:
            if nm in seen:
                continue
            seen.add(nm)
            self.txt(f"{nm:<22} {dd}", 12, yy, (150, 150, 160))
            yy += 16
        self.txt("replace any stem file there -> auto-reload at the "
                 "same playhead", 12, min(yy + 4, 210), (170, 190, 170))
        self.txt("SPACE play . click/drag scrub . arrows bar (shift "
                 "10s) . M/S . click clock to type a time . R rebuild "
                 ". ESC . hover any control for tips",
                 128, self.y_marks + 28, (120, 120, 135))
        # video monitor
        fr = self.video.request(t)
        if fr is not None:
            scr.blit(fr, (self.W - 332, 44))
        if self.video.video is not None:
            pygame.draw.rect(scr, (70, 70, 80),
                             (self.W - 332, 44, 320, 180), 1)
            self._hit["video_monitor"] = pygame.Rect(self.W - 332, 44,
                                                     320, 180)
        # ruler
        pygame.draw.rect(scr, (26, 26, 32),
                         (self.x0, self.y_ruler, self.x1 - self.x0, 16))
        for m in range(0, int(self.proj.dur) + 1, 30):
            x = self._tx(m)
            pygame.draw.line(scr, (80, 80, 95), (x, self.y_ruler),
                             (x, self.y_ruler + 16))
            self.txt(f"{m // 60}:{m % 60:02d}", x + 3, self.y_ruler + 1,
                     (140, 140, 155))
        # sections + bank spans
        for t0, t1, nm, meta, _ in self.proj.banks:
            pygame.draw.line(scr, (240, 220, 160),
                             (self._tx(t0), self.y_sect),
                             (self._tx(t0), self.y_marks + 14))
        for (bt, bidx, _), nxt in zip(
                self.proj.bars, self.proj.bars[1:] + [(self.proj.dur,
                                                       0, {})]):
            sec = self.proj.section_at(bt + 0.01)
            x, xe = self._tx(bt), self._tx(nxt[0])
            pygame.draw.rect(scr, SECT_COL.get(sec, (50, 50, 60)),
                             (x, self.y_sect, max(1, xe - x), 10))
        # waveform overview
        pygame.draw.rect(scr, (24, 24, 30),
                         (self.x0, self.y_wave, self.x1 - self.x0, 58))
        ov = self.overview
        if ov is not None:
            mid = self.y_wave + 29
            for i, v in enumerate(ov):
                h = int(v * 28)
                pygame.draw.line(scr, (90, 130, 110),
                                 (self.x0 + i, mid - h),
                                 (self.x0 + i, mid + h))
        # value automation (P/C/S)
        pygame.draw.rect(scr, (24, 24, 30),
                         (self.x0, self.y_vals, self.x1 - self.x0, 50))
        for vi, vname in enumerate(("PRAYER", "CONTEMPT", "STALWART")):
            col = tuple(c // 3 for c in VAL_COL[vi]) \
                if vi in self.curve_off else VAL_COL[vi]
            self.txt(vname, 50, self.y_vals + 2 + vi * 15, col)
            self._hit[f"curve:{vi}"] = pygame.Rect(
                46, self.y_vals + vi * 15, 80, 15)
        for vi in range(3):
            if vi in self.curve_off:
                continue
            pts = [(self._tx(vt), self.y_vals + 48 - int(v[vi] * 46))
                   for vt, v in self.proj.vals[::3]]
            if len(pts) > 1:
                pygame.draw.lines(scr, VAL_COL[vi], False, pts)
        # lane tracks
        for ln in LANES + [FX]:
            ry = self.rows[ln]
            eff_muted = ln in self._effective_mutes()
            hcol = (255, 240, 200) if ln in self.solo else \
                (110, 110, 120) if eff_muted else (200, 200, 210)
            pygame.draw.rect(scr, (60, 40, 40) if ln in self.muted
                             else (36, 36, 44), (4, ry, 18, 16))
            self.txt("M", 8, ry + 1, (255, 150, 150) if ln in self.muted
                     else (150, 150, 160))
            self._hit[f"mute:{ln}"] = pygame.Rect(4, ry, 18, 16)
            pygame.draw.rect(scr, (60, 60, 30) if ln in self.solo
                             else (36, 36, 44), (26, ry, 18, 16))
            self.txt("S", 31, ry + 1, (255, 240, 140) if ln in self.solo
                     else (150, 150, 160))
            self._hit[f"solo:{ln}"] = pygame.Rect(26, ry, 18, 16)
            if self.sel == ln:
                pygame.draw.rect(scr, (70, 65, 40), (46, ry, 80, 19))
            self.txt(ln, 50, ry + 2, hcol)
            self._hit[f"name:{ln}"] = pygame.Rect(46, ry, 80, 19)
            pygame.draw.rect(scr, (24, 24, 29),
                             (self.x0, ry, self.x1 - self.x0, 22))
            if ln == FX:
                continue
            col = LANE_COL[ln]
            dim = 0.25 if eff_muted else 1.0
            for (bt, bidx, lanes), nxt in zip(
                    self.proj.bars,
                    self.proj.bars[1:] + [(self.proj.dur, 0, {})]):
                key, g = lanes.get(ln, ("silence", 0.0))
                if g <= 0.001 or key == "silence":
                    continue
                x, xe = self._tx(bt), self._tx(nxt[0])
                h = max(2, int(20 * min(1.0, g)))
                c = tuple(int(v * (0.35 + 0.65 * g) * dim) for v in col)
                pygame.draw.rect(scr, c, (x, ry + 21 - h,
                                          max(1, xe - x), h))
        # FX / event markers
        ry = self.rows[FX]
        for mt_, kind, nm in self.proj.marks:
            x = self._tx(mt_)
            if kind == "music_halt":
                pygame.draw.line(scr, (255, 70, 70), (x, ry),
                                 (x, ry + 20), 2)
            elif kind == "music_sting":
                pygame.draw.circle(scr, (240, 220, 160), (x, ry + 10), 4)
            elif kind == "music_riser":
                pygame.draw.polygon(scr, (200, 120, 220),
                                    [(x, ry + 18), (x - 4, ry + 4),
                                     (x + 4, ry + 4)])
            elif kind == "music_riser2":
                pygame.draw.polygon(scr, (255, 120, 80),
                                    [(x, ry + 18), (x - 3, ry + 8),
                                     (x + 3, ry + 8)])
            elif kind == "music_jump" and not nm.endswith("~s"):
                pygame.draw.polygon(scr, (240, 200, 100),
                                    [(x, ry + 4), (x - 3, ry + 14),
                                     (x + 3, ry + 14)])
        # playhead
        px = self._tx(t)
        pygame.draw.line(scr, (255, 255, 255), (px, self.y_ruler),
                         (px, self.y_marks + 22))
        # ---- overlays --------------------------------------------------
        if self.video_big:
            fr = self.video.request(t, big=True)
            bw, bh = self.video.big_size
            bx, by = (self.W - bw) // 2, (self.H - bh) // 2
            dim = pygame.Surface((self.W, self.H), pygame.SRCALPHA)
            dim.fill((0, 0, 0, 170))
            scr.blit(dim, (0, 0))
            if fr is not None:
                scr.blit(fr, (bx, by))
            pygame.draw.rect(scr, (200, 200, 210), (bx, by, bw, bh), 2)
            self.txt("click or ESC to close", bx + 4, by + bh + 6,
                     (170, 170, 180))
        if self.picker:
            names = [None] + self.available_banks()
            ph = 24 * len(names) + 36
            prc = pygame.Rect(350, 40, 340, ph)
            pygame.draw.rect(scr, (30, 30, 38), prc)
            pygame.draw.rect(scr, (240, 220, 160), prc, 1)
            self.txt("score this session with:", prc.x + 10, prc.y + 8,
                     (240, 220, 160))
            self._picker_rows = []
            yy = prc.y + 30
            for nm in names:
                r = pygame.Rect(prc.x + 6, yy, prc.w - 12, 22)
                cur = (nm == self._use)
                if cur:
                    pygame.draw.rect(scr, (60, 55, 35), r)
                label = nm or "(this session's own banks)"
                self.txt(label, r.x + 6, r.y + 3,
                         (255, 240, 200) if cur else (200, 200, 210))
                self._picker_rows.append((r, nm))
                yy += 24
        self._draw_tooltip()
        pygame.display.flip()

    TOOLTIPS = {
        "play_glyph": "Play / pause (SPACE)",
        "time_readout": "Click, type a time (mm:ss or seconds), ENTER jumps",
        "bank_title": "Click: score this session with a different bank",
        "clip_chip": "Mix hit full scale — click to reset",
        "video_monitor": "Click: enlarge video",
        "curve:0": "PRAYER value - click to show/hide the curve",
        "curve:1": "CONTEMPT value - click to show/hide the curve",
        "curve:2": "STALWART value - click to show/hide the curve",
    }

    def _tooltip_for(self, el):
        if el in self.TOOLTIPS:
            return self.TOOLTIPS[el]
        if el.startswith("mute:"):
            return f"Mute '{el[5:]}' (re-mixes in ~1s)"
        if el.startswith("solo:"):
            return f"Solo '{el[5:]}' (re-mixes in ~1s)"
        if el.startswith("name:"):
            return (f"Click: select '{el[5:]}' — M/S keys then "
                    f"mute/solo it")
        return None

    def _draw_tooltip(self):
        if self.picker or self.video_big or self._goto is not None:
            return
        mx, my = pygame.mouse.get_pos()
        over = next((el for el, r in self._hit.items()
                     if r.collidepoint(mx, my)), None)
        if over != self._hover[0]:
            self._hover = (over, time.time())
            return
        if over is None or time.time() - self._hover[1] < 0.45:
            return
        tip = self._tooltip_for(over)
        if not tip:
            return
        surf = self.font.render(tip, True, (20, 20, 24))
        w, h = surf.get_size()
        tx = min(mx + 14, self.W - w - 14)
        ty = min(my + 18, self.H - h - 12)
        pygame.draw.rect(self.screen, (235, 225, 180),
                         (tx - 6, ty - 4, w + 12, h + 8))
        pygame.draw.rect(self.screen, (120, 110, 80),
                         (tx - 6, ty - 4, w + 12, h + 8), 1)
        self.screen.blit(surf, (tx, ty))

    def step(self):
        self.player.poll()

    def run(self):
        clock = pygame.time.Clock()
        running = True
        while running:
            for ev in pygame.event.get():
                if ev.type == pygame.QUIT:
                    running = False
                elif not self.handle(ev):
                    running = False
            self.step()
            self.draw()
            clock.tick(60)
        pygame.quit()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("rec", nargs="?", default=str(DEFAULT_REC),
                    help="recording dir (events.jsonl) or the file")
    ap.add_argument("--video", default=None,
                    help="mp4 for the frame monitor (default: the "
                         "winning-session video when rec is default)")
    ap.add_argument("--use", default=None, metavar="BANK",
                    help="audition ONE bank (e.g. album_mytrack) under "
                         "this session's decisions, replacing all the "
                         "session's banks")
    a = ap.parse_args()
    rec = Path(a.rec)
    video = Path(a.video) if a.video else \
        (DEFAULT_VIDEO if Path(a.rec) == DEFAULT_REC else None)
    App(rec, video, use=a.use).run()


if __name__ == "__main__":
    main()
