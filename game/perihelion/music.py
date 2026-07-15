"""Dynamic music — the Commando's emotional state, illustrated.

NOT a state machine (director's architecture ruling, 2026-07-13):
PRAYER, CONTEMPT, STALWART are continuous VALUES in [0,1], each computed
by a battery of heuristics, and the engine's inputs are exactly:

    (prayer, contempt, stalwart) + current level + current weapon
    + the list of enemies currently with aggro

Level selects the rhythm bed, weapon selects the lead voice, the aggro
list selects bassline cells (the director's dynamic spec); the triple
drives lane gains. Blends are native — 04's STALWART+CONTEMPT moment is
just (0.7, 0.6, ...) — and the emotional spec still holds:

  PRAYER   — praying/contemplating/processing, but the urgency pulse
             never fully stops (floor never reaches zero).
  CONTEMPT — mowing down weak enemies: confident dismissive groove; the
             chant does not pause for trash.
  STALWART — overwhelming odds: the prayer for vengeance; the harmonic
             floor holds; the cantus firmus persists through the peak.

MIXER ARCHITECTURE (the Tower-of-Torment mechanism — the director's own
ChunkedMusicPlayer from pyweek-28, generalized to N lanes):

    Every lane is a pygame channel playing equal BAR CHUNKS back-to-back
    via channel.queue(), so the audio device itself keeps sample-exact
    time. ALL musical change is WHICH variant's chunk gets queued for
    the next bar: bed_t<tier>, lead_<weapon>, bass_<dominant enemy>,
    or silence. A state change arriving mid-bar REPLACES the queued
    chunk (same position in the form), so it lands exactly on the next
    audible bar line. The audio is the clock: bar boundaries are
    detected as queue consumption on the master lane, and gains step
    only at those boundaries (rise = wall, fall = stepped fade). There
    is no free-running loop and no tick-derived bar counter in the rich
    path.

The Shepard riser follows TENSION continuously (dormant flickers the
sensors barely show) and releases with a sting quantized to the 8th
grid the instant the threat commits.

Deterministic given a recording; logged through the audio tap stream so
tools/playtest/mkvideo.py rebuilds the exact mix offline.
"""
from __future__ import annotations

import sys
from pathlib import Path

BANK_DIR = Path(__file__).resolve().parent / "assets/music/hymn01"
MUSIC_ROOT = Path(__file__).resolve().parents[1] / "assets/music"


def shipped_banks() -> list:
    """All shipped album banks — the game's default soundtrack; no
    flags, no dev paths (releasable-game law, 2026-07-15)."""
    if not MUSIC_ROOT.exists():
        return []
    return sorted(p for p in MUSIC_ROOT.glob("album_*")
                  if (p / "bank.json").exists())
BPM = 140.0
BAR_S = 240.0 / BPM
TICKS_PER_S = 60.0

# Heuristic battery weights ------------------------------------------------
THREAT_WEIGHT = {
    "mite": 0.6, "husk": 1.0, "spitter": 2.0, "shrieker": 2.5,
    "brute": 4.0, "warden": 5.0, "flicker": 3.0,
}
WEAK_KINDS = {"mite", "husk"}
OTHER_ROOM_FACTOR = 0.35
STALWART_KNEE = 8.0          # weighted threat where stalwart ~ 0.63
HURT_HP = 40.0
PRAYER_FLOOR = 0.12          # the urgency pulse never fully stops
STING_RISE = 0.35            # a value jump this big in one bar = a wall
FALL_STEP = 0.35             # per-bar multiplier on a falling lane gain


def read_inputs(session) -> dict:
    """The engine's complete input tuple, from live sim state.

    aggro = enemies whose AI is actively engaged (not idle/waking/lurk).
    """
    proom = session.player_room()
    aggro = []
    tension = 0.0
    for eid, e in session.enemies.items():
        kind = e.get("kind")
        state = e.get("state", "idle")
        if kind == "flicker" and state == "lurk":
            try:
                if session.sim.get_room(eid) == proom:
                    tension = min(1.0, tension + 0.5)
            except Exception:
                pass
            continue
        if state in ("idle", "waking"):
            continue
        try:
            room = session.sim.get_room(eid)
        except Exception:
            continue
        aggro.append((kind, room == proom))
    return dict(
        level=getattr(session, "level_name", "?"),
        weapon=getattr(session, "weapon", None) or
               getattr(session, "current_weapon", "?"),
        aggro=aggro,
        hp=getattr(session, "hp", 100.0),
        tension=tension,
    )


def values(inputs: dict) -> tuple[float, float, float]:
    """(prayer, contempt, stalwart), each 0-1, from the heuristic battery.

    - stalwart rises with WEIGHTED threat (soft knee at STALWART_KNEE),
      amplified when hurt: the odds as the Commando reads them.
    - contempt rises with engaged WEAK enemies while stalwart stays low
      and he is healthy: trash being mowed, pride and impatience.
    - prayer is the room left by the fight, never below PRAYER_FLOOR:
      contemplation with the mission clock always running.
    """
    import math
    threat = 0.0        # engagement pressure (everything counts)
    test_threat = 0.0   # what reads as the Test (weak kinds discounted:
    #                     a swarm of trash is work, not a trial)
    weak_n = 0
    for kind, same_room in inputs["aggro"]:
        w = THREAT_WEIGHT.get(kind, 1.0)
        rf = 1.0 if same_room else OTHER_ROOM_FACTOR
        threat += w * rf
        test_threat += w * rf * (0.25 if kind in WEAK_KINDS else 1.0)
        if kind in WEAK_KINDS and same_room:
            weak_n += 1
    hp = inputs["hp"]
    hurt = max(0.0, (HURT_HP - hp) / HURT_HP)
    stalwart = 1.0 - math.exp(-(test_threat * (1.0 + 1.2 * hurt))
                              / STALWART_KNEE)
    contempt = (1.0 - math.exp(-weak_n / 2.5)) * (1.0 - stalwart) \
        * (0.5 + 0.5 * min(1.0, hp / 100.0))
    engaged = min(1.0, threat / 2.0)
    prayer = max(PRAYER_FLOOR, 1.0 - engaged)
    return (round(prayer, 3), round(contempt, 3), round(stalwart, 3))


def dominant_kind(aggro) -> str | None:
    """The enemy kind that owns the bassline: highest total threat
    weight among engaged enemies (same-room weighted up)."""
    totals: dict[str, float] = {}
    for kind, same_room in aggro:
        w = THREAT_WEIGHT.get(kind, 1.0) * (1.0 if same_room
                                            else OTHER_ROOM_FACTOR)
        totals[kind] = totals.get(kind, 0.0) + w
    if not totals:
        return None
    return max(totals, key=totals.get)


class ChunkLane:
    """One voice of the arrangement — the director's ChunkedMusicPlayer
    mechanism (pyweek-28 musicplayer.queue_chunk, generalized): a channel
    playing bar chunks back-to-back via queue(); each lane owns its own
    position in the form; content selection chooses which variant's
    chunk gets queued, and re-selecting REPLACES a still-pending chunk
    so late changes still land exactly on the next bar line."""

    def __init__(self, channel, variants: dict, n_chunks: int):
        self.ch = channel
        self.variants = variants          # key -> [Sound per bar]
        self.n = n_chunks
        self.key = None                   # variant selected for the queue
        self.next_idx = 0                 # position the queued chunk holds
        self.gain = 0.0

    def start(self, key: str, master_vol: float):
        self.key = key
        self.next_idx = 1
        self.ch.play(self.variants[key][0])
        self.ch.queue(self.variants[key][1 % self.n])
        self.ch.set_volume(max(0.0, min(1.0, self.gain * master_vol)))

    def tickfill(self, sel_key: str) -> bool:
        """Keep the queue full; returns True when a bar boundary was
        consumed on this lane since the last call (his queue_chunk: an
        empty queue means the pending chunk started playing)."""
        crossed = False
        if self.ch.get_queue() is None:
            crossed = True
            self.next_idx += 1
            self.key = sel_key
            self.ch.queue(self.variants[sel_key][self.next_idx % self.n])
        elif self.key != sel_key:
            self.key = sel_key            # replace the pending chunk
            self.ch.queue(self.variants[sel_key][self.next_idx % self.n])
        return crossed

    def set_gain(self, gain: float, master_vol: float):
        self.gain = gain
        self.ch.set_volume(max(0.0, min(1.0, gain * master_vol)))


class MusicSystem:
    """Continuous-value engine + chunk-queued musical application."""

    def __init__(self, audio_bank, enabled: bool = True, bank_dir=None,
                 tick_clock: bool = False):
        # tick_clock: headless/recording mode — decisions advance on the
        # DETERMINISTIC tick grid and nothing plays (offline rebuild
        # supplies the audio); the live audio-hardware clock would race
        # ahead whenever the recording loop runs slower than realtime
        self.bank = audio_bank
        self.tick_clock = tick_clock
        # the INPUT engine always runs (values, taps, riser logic — the
        # part the director kept); only the MIXER needs stems on disk.
        self.enabled = enabled
        self.bank_dir = Path(bank_dir) if bank_dir else BANK_DIR
        self.has_bank = self.bank_dir.exists() \
            and (any(self.bank_dir.glob("*.wav"))
                 or any(self.bank_dir.glob("*.ogg")))
        self.rich = (self.bank_dir / "bank.json").exists()
        self.bar_s = BAR_S
        self.n_bars = 0
        if self.rich:
            import json
            meta = json.loads((self.bank_dir / "bank.json").read_text())
            self.bar_s = 240.0 / float(meta.get("bpm", BPM))
            self.n_bars = int(meta.get("bars", 0))
        # manual override for the value triple (the audition instrument's
        # MANUAL mode and scripted scenes); None = heuristic battery
        self.override_vals = None
        self.vals = (1.0, 0.0, 0.0)
        self.inputs: dict = {}
        self._applied = (1.0, 0.0, 0.0)
        self._last_bar = -1
        self._started = False
        self._riser_gain = 0.0
        self._pending_sting = False
        self._sting = None
        # transition controller (STEM_COMPOSITION_DESIGN §4): per-lane
        # build programs — {lane: [gain_step_per_bar..., target]}; the
        # derivative of the value triple picks the program length
        self._programs: dict = {}
        self._prev_vals = (1.0, 0.0, 0.0)
        # rich mixer state
        self._lanes: dict[str, ChunkLane] = {}
        self._bar_idx = 0                 # position in the form
        self._boundary_tick = 0           # tick at the last heard boundary
        self._live: dict = {}             # lane -> stepped gain
        # legacy mixer state
        self._channels = {}

    # -- rich mixer: chunk slicing + lanes --------------------------------
    def _slice_bank(self):
        """Slice every stem into per-bar Sound chunks on one shared
        boundary table (round-per-boundary: no cumulative drift, every
        lane's chunk k has the identical sample length)."""
        import numpy as np
        import pygame
        import soundfile as sf
        chunks: dict[str, list] = {}
        n_total = None
        bounds = None
        files = {f.stem: f for f in sorted(self.bank_dir.glob("*.wav"))}
        for f in sorted(self.bank_dir.glob("*.ogg")):
            files.setdefault(f.stem, f)
        for name, fn in sorted(files.items()):
            if name in ("sting", "riser"):
                continue
            data, sr = sf.read(str(fn), dtype="int16")
            if data.ndim == 1:
                data = np.stack([data, data], axis=1)
            if n_total is None:
                n_total = len(data)
                per = n_total / max(1, self.n_bars)
                bounds = [int(round(k * per)) for k in range(self.n_bars)] \
                    + [n_total]
            lst = []
            for k in range(self.n_bars):
                seg = np.ascontiguousarray(data[bounds[k]:bounds[k + 1]])
                lst.append(pygame.sndarray.make_sound(seg))
            chunks[name] = lst
        # a silence variant, one per distinct chunk length
        sil = []
        for k in range(self.n_bars):
            z = np.zeros((bounds[k + 1] - bounds[k], 2), dtype=np.int16)
            sil.append(pygame.sndarray.make_sound(z))
        chunks["silence"] = sil
        return chunks

    def _ensure_started(self, tick: int = 0):
        if self._started or not self.enabled or not self.has_bank:
            return
        self._started = True
        if not getattr(self.bank, "_ready", False):
            return
        if self.rich and self.tick_clock:
            stems = {q.stem for q in self.bank_dir.glob("*.wav")} | \
                {q.stem for q in self.bank_dir.glob("*.ogg")}

            class _SimLane:
                def __init__(self, variants):
                    self.variants = dict.fromkeys(variants | {"silence"})
                    self.key = None
                    self.gain = 0.0
            self._lanes = {
                "drums": _SimLane({"drums"} if "drums" in stems
                                  else set()),
                "bed": _SimLane({s for s in stems if s.startswith("bed_")}),
                "holy": _SimLane({"prayer"}),
                "groove": _SimLane({"contempt"}),
                "wall": _SimLane({"stalwart"}),
                "lead": _SimLane({s for s in stems
                                  if s.startswith("lead_")}),
                "bass": _SimLane({s for s in stems
                                  if s.startswith("bass_")}),
            }
            self._boundary_tick = 0
            return
        import pygame
        try:
            sting_f = next((self.bank_dir / f"sting.{ext}"
                            for ext in ("wav", "ogg")
                            if (self.bank_dir / f"sting.{ext}").exists()),
                           None)
            self._sting = pygame.mixer.Sound(str(sting_f)) if sting_f \
                else None
            if not self.rich:
                self._start_legacy()
                return
            chunks = self._slice_bank()
            beds = sorted(k for k in chunks if k.startswith("bed_t"))
            leads = sorted(k for k in chunks if k.startswith("lead_"))
            basses = sorted(k for k in chunks if k.startswith("bass_"))
            lane_defs = {
                "drums": ({"drums": chunks["drums"]}
                          | {"silence": chunks["silence"]})
                if "drums" in chunks else None,
                "bed": {k: chunks[k] for k in beds} | {"silence": chunks["silence"]},
                "holy": {"prayer": chunks["prayer"],
                         "silence": chunks["silence"]},
                "groove": {"contempt": chunks["contempt"],
                           "silence": chunks["silence"]},
                "wall": {"stalwart": chunks["stalwart"],
                         "silence": chunks["silence"]},
                "lead": {k: chunks[k] for k in leads} | {"silence": chunks["silence"]},
                "bass": {k: chunks[k] for k in basses} | {"silence": chunks["silence"]},
            }
            if pygame.mixer.get_num_channels() < 8 + len(lane_defs) + 1:
                pygame.mixer.set_num_channels(8 + len(lane_defs) + 1)
            master = getattr(self.bank, "master", 1.0)
            lane_defs = {k: v for k, v in lane_defs.items()
                         if v is not None}
            for i, (lname, variants) in enumerate(lane_defs.items()):
                lane = ChunkLane(pygame.mixer.Channel(4 + i), variants,
                                 self.n_bars)
                self._lanes[lname] = lane
            # riser: continuous tension effect on its own loop channel
            riser_fn = next((self.bank_dir / f"riser.{e}"
                             for e in ("wav", "ogg")
                             if (self.bank_dir / f"riser.{e}").exists()),
                            self.bank_dir / "riser.wav")
            self._riser_ch = None
            if riser_fn.exists():
                snd = pygame.mixer.Sound(str(riser_fn))
                self._riser_ch = pygame.mixer.Channel(4 + len(lane_defs))
                self._riser_ch.play(snd, loops=-1)
                self._riser_ch.set_volume(0.0)
            # first bar's content from current state, all started in one
            # tight pass (everything is pre-sliced by now)
            sel = self._select_content()
            gains = self._bar_gains()
            for lname, lane in self._lanes.items():
                lane.gain = gains.get(lname, 0.0)
                lane.start(sel[lname], master)
            self._bar_idx = 0
            self._boundary_tick = tick
        except Exception as exc:
            print(f"[music] start failed, logging only: {exc}",
                  file=sys.stderr)
            self._lanes = {}
            self._channels = {}

    def _select_content(self) -> dict:
        """Which variant each lane queues next — from CURRENT state (a
        re-selection before the boundary replaces the pending chunk, so
        late changes still land on the bar)."""
        p, c, d = self.vals
        tier = max(1, min(4, int(self.inputs.get("tier", 1))))
        weapon = str(self.inputs.get("weapon", "?"))
        combat = max(c, d)
        kind = dominant_kind(self.inputs.get("aggro", []))
        lanes = self._lanes
        sel = {
            "drums": "drums" if max(c, d) > 0.03 else "silence",
            "bed": f"bed_t{tier}"
            if f"bed_t{tier}" in lanes.get("bed", ChunkLane(None, {}, 1)
                                           ).variants else "silence",
            "holy": "prayer",
            "groove": "contempt" if c > 0.03 else "silence",
            "wall": "stalwart" if d > 0.03 else "silence",
            "lead": f"lead_{weapon}"
            if combat > 0.05 and
            f"lead_{weapon}" in lanes.get("lead", ChunkLane(None, {}, 1)
                                          ).variants else "silence",
            "bass": f"bass_{kind}"
            if kind is not None and
            f"bass_{kind}" in lanes.get("bass", ChunkLane(None, {}, 1)
                                        ).variants else "silence",
        }
        return sel

    def _bar_gains(self) -> dict:
        """Transition controller, stateless slew form (v2 — the stored
        build-programs crawled through short skirmishes and never
        re-targeted; taps showed the wall peaking at 0.47):

        - rise SPEED follows the value derivative: spike >= STING_RISE
          lands the full wall this bar; otherwise gains rise <= 0.35/bar
          (a natural 2-3 bar build) — always toward the CURRENT target;
        - presence floor: while a lane's value is live (> 0.05) its gain
          never sits below 0.4 — small skirmishes are clearly audible
          (director's standing ruling), the build shapes the arrival,
          never the existence;
        - falls: hard drop (>= 0.5) = the pull, one bar; soft = stepped
          fade (FALL_STEP)."""
        p, c, d = self._applied
        dp = max(c - self._prev_vals[1], d - self._prev_vals[2])
        self._prev_vals = self._applied
        aggro = self.inputs.get("aggro", [])
        n_aggro = sum(1.0 if sr else 0.4 for _, sr in aggro)
        combat = max(c, d)
        want = {
            "drums": 0.9 * combat ** 0.5,
            "bed": 0.55 + 0.35 * p,
            "holy": p ** 0.5,
            "groove": c ** 0.5,
            "wall": d ** 0.5,
            "lead": 0.9 * combat ** 0.5,
            "bass": 0.8 * min(1.0, n_aggro / 2.0) ** 0.5,
        }
        FLOOR = {"drums": (combat, 0.5),
                 "groove": (c, 0.4), "wall": (d, 0.4),
                 "lead": (combat, 0.4), "bass": (n_aggro / 4.0, 0.45)}
        out = {}
        max_rise = 1.0 if dp >= STING_RISE else 0.35
        for name, tgt in want.items():
            val, floor = FLOOR.get(name, (1.0, 0.0))
            if val > 0.05:
                tgt = max(tgt, floor)
            cur = self._live.get(name, 0.0)
            if tgt > cur:
                cur = min(tgt, cur + max_rise)
            elif cur - tgt >= 0.5:
                cur = tgt                           # the pull
            else:
                cur = tgt if cur * FALL_STEP < 0.02 else \
                    max(tgt, cur * FALL_STEP)
            out[name] = min(cur, 1.0)
        self._live = out
        # riser rides an in-flight build
        building = any(out[n] < want.get(n, 0) - 0.05 for n in out)
        if building and self._riser_gain < 0.6:
            self._riser_gain = max(self._riser_gain, 0.45)
        elif not building and self.inputs.get("tension", 0) <= 1e-6:
            self._riser_gain = 0.0
        return out

    # -- legacy 4-loop mixer (pre-rich banks) ------------------------------
    def _start_legacy(self):
        import pygame
        for i, name in enumerate(("prayer", "contempt", "stalwart",
                                  "riser")):
            fn = self.bank_dir / f"{name}.wav"
            if not fn.exists():
                continue
            snd = pygame.mixer.Sound(str(fn))
            ch = pygame.mixer.Channel(4 + i)
            ch.play(snd, loops=-1)
            ch.set_volume(0.0)
            self._channels[name] = ch

    def _apply_legacy(self, dt: float = 1.0 / 60.0):
        p, c, d = self._applied
        targets = {"prayer": p ** 0.5, "contempt": c ** 0.5,
                   "stalwart": d ** 0.5,
                   "riser": self._riser_gain * 0.85}
        fall_rate = dt / (1.5 * self.bar_s)
        master = getattr(self.bank, "master", 1.0)
        for name in ("prayer", "contempt", "stalwart", "riser"):
            cur = self._live.get(name, targets[name])
            tgt = targets[name]
            cur = tgt if tgt >= cur else max(tgt, cur - fall_rate)
            self._live[name] = cur
            ch = self._channels.get(name)
            if ch is not None:
                ch.set_volume(max(0.0, min(1.0, cur * 0.8 * master)))

    def _tap(self, kind: str, detail: str, vol: float):
        tap = getattr(self.bank, "tap", None)
        if tap is not None:
            tap(kind, detail, vol, 0.5)

    # -- per-tick update --------------------------------------------------
    def music_time(self, tick: int) -> float:
        """Seconds of musical time, interpolated from the last HEARD bar
        boundary (rich mode) or from engine start (legacy)."""
        return self._bar_idx * self.bar_s \
            + (tick - self._boundary_tick) / TICKS_PER_S

    def update(self, session):
        if not self.enabled:
            return
        self._ensure_started(session.tick_count)
        self.inputs = read_inputs(session)
        self.inputs["tier"] = getattr(session, "music_tier", 1)
        self.vals = self.override_vals or values(self.inputs)
        tension = self.inputs["tension"]

        if tension > self._riser_gain + 1e-6:
            self._riser_gain = tension
            self._tap("music_riser", f"{tension:.2f}", tension)
        elif tension <= 1e-6 and self._riser_gain > 1e-6:
            self._riser_gain = 0.0
            self._tap("music_riser", "0.00", 0.0)
            self._pending_sting = True             # release on the pounce

        if self._lanes:
            self._update_rich(session)
        else:
            self._update_legacy(session)

        # stings land on the 8th grid, never mid-air
        if self._pending_sting:
            t = self.music_time(session.tick_count)
            eighth = self.bar_s / 8.0
            if t % eighth < (1.5 / TICKS_PER_S):
                self._pending_sting = False
                self._sting_now()

    def _update_rich(self, session):
        if self.tick_clock:
            t = session.tick_count / TICKS_PER_S
            bar = int(t / self.bar_s)
            if bar != self._bar_idx or self._boundary_tick == 0:
                self._bar_idx = bar
                self._boundary_tick = session.tick_count or 1
                prev = self._applied
                self._applied = self.vals
                self._applied_inputs = dict(self.inputs)
                if (self.vals[2] - prev[2] >= STING_RISE or
                        self.vals[1] - prev[1] >= STING_RISE):
                    self._pending_sting = True
                if self._applied != prev:
                    p, c, d = self._applied
                    self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
                sel = self._select_content()
                gains = self._bar_gains()
                for lname, lane in self._lanes.items():
                    lane.key = sel[lname]
                    lane.gain = gains.get(lname, 0.0)
                detail = f"{self._bar_idx}|" + "|".join(
                    f"{ln}:{la.key}:{la.gain:.3f}"
                    for ln, la in sorted(self._lanes.items()))
                self._tap("music_bar", detail, 1.0)
            return
        master = getattr(self.bank, "master", 1.0)
        rc = getattr(self, "_riser_ch", None)
        if rc is not None:
            rc.set_volume(max(0.0, min(1.0,
                                       self._riser_gain * 0.85 * master)))
        # keep every lane's queue filled — a re-selection replaces a
        # pending chunk, so a mid-bar state change still lands exactly
        # on the next bar line; each lane keeps its own position
        sel = self._select_content()
        boundary = False
        for lname, lane in self._lanes.items():
            if lane.tickfill(sel[lname]) and lname == "bed":
                boundary = True
        if boundary:
            # a bar line just sounded: this is the ONLY place values are
            # applied and gains move (the audio is the clock)
            self._bar_idx += 1
            self._boundary_tick = session.tick_count
            prev = self._applied
            self._applied = self.vals
            if (self.vals[2] - prev[2] >= STING_RISE or
                    self.vals[1] - prev[1] >= STING_RISE):
                self._pending_sting = True         # hard rise = a wall
            if self._applied != prev:
                p, c, d = self._applied
                self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
            gains = self._bar_gains()
            for lname, lane in self._lanes.items():
                lane.set_gain(gains.get(lname, 0.0), master)
            # offline-reconstruction tap (mkvideo): the FULL per-bar
            # decision — position + every lane's content and gain
            detail = f"{self._bar_idx}|" + "|".join(
                f"{ln}:{la.key}:{la.gain:.3f}"
                for ln, la in sorted(self._lanes.items()))
            self._tap("music_bar", detail, 1.0)

    def _update_legacy(self, session):
        bar = int((session.tick_count / TICKS_PER_S) / self.bar_s)
        if bar != self._last_bar:
            self._last_bar = bar
            self._boundary_tick = session.tick_count
            self._bar_idx = bar
            prev = self._applied
            self._applied = self.vals
            if (self.vals[2] - prev[2] >= STING_RISE or
                    self.vals[1] - prev[1] >= STING_RISE):
                self._pending_sting = True
            if self._applied != prev:
                p, c, d = self._applied
                self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
        self._apply_legacy()

    def _sting_now(self):
        self._tap("music_sting", "sting", 1.0)
        if self._sting is not None and (self._lanes or self._channels):
            import pygame
            try:
                pygame.mixer.Channel(3).play(self._sting)
                pygame.mixer.Channel(3).set_volume(
                    0.8 * getattr(self.bank, "master", 1.0))
            except Exception:
                pass

    def stop(self):
        for lane in self._lanes.values():
            try:
                lane.ch.stop()
            except Exception:
                pass
        self._lanes.clear()
        rc = getattr(self, "_riser_ch", None)
        if rc is not None:
            try:
                rc.stop()
            except Exception:
                pass
            self._riser_ch = None
        for ch in self._channels.values():
            try:
                ch.stop()
            except Exception:
                pass
        self._channels.clear()
        self._started = False
