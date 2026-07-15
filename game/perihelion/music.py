"""Dynamic music — the Commando's emotional state, illustrated.

NOT a state machine (director's architecture ruling, 2026-07-13):
PRAYER, CONTEMPT, STALWART are continuous VALUES in [0,1], each computed
by a battery of heuristics, and the engine's inputs are exactly:

    (prayer, contempt, stalwart) + current level + current weapon
    + the list of enemies currently with aggro

Level selects the rhythm bed, weapon selects the lead voice, the aggro
list selects bassline cells (the director's dynamic spec); the triple
drives stem gains. Blends are native — 04's STALWART+CONTEMPT moment is
just (0.7, 0.6, ...) — and the emotional spec still holds:

  PRAYER   — praying/contemplating/processing, but the urgency pulse
             never fully stops (floor never reaches zero).
  CONTEMPT — mowing down weak enemies: confident dismissive groove; the
             chant does not pause for trash.
  STALWART — overwhelming odds: the prayer for vengeance; the harmonic
             floor holds; the cantus firmus persists through the peak.

Musical APPLICATION stays album-grammar (bar-quantized gain moves; large
value jumps land as walls/vacuums; a sting marks hard rises), but the
values themselves ride continuously every tick. The Shepard riser follows
TENSION (dormant flickers the sensors barely show) and releases with a
sting the instant the threat commits — tension resolving on gameplay's
schedule.

Deterministic given a recording; logged through the audio tap stream so
tools/playtest/mkvideo.py rebuilds the exact mix offline.
"""
from __future__ import annotations

import sys
from pathlib import Path

BANK_DIR = Path(__file__).resolve().parent / "assets/music/hymn01"
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


class MusicSystem:
    """Continuous-value engine + bar-quantized musical application.

    Two bank shapes:
    - legacy: prayer/contempt/stalwart/riser loops + sting.wav
    - rich (bank.json present, generated by tools/musicgen/generate_bank):
      adds bed_t1..t4 (stage), lead_<weapon> (10), bass_<enemy> (7).
      ALL loops start together at volume 0 and stay running — weapon or
      enemy changes are pure bar-quantized gain moves, so every lane
      stays phase-locked (the album's wall/vacuum grammar, never a
      mid-phrase restart).
    """

    def __init__(self, audio_bank, enabled: bool = True, bank_dir=None):
        self.bank = audio_bank
        # the INPUT engine always runs (values, taps, riser logic — the
        # part the director kept); only the MIXER needs stems on disk.
        self.enabled = enabled
        self.bank_dir = Path(bank_dir) if bank_dir else BANK_DIR
        self.has_bank = self.bank_dir.exists() \
            and any(self.bank_dir.glob("*.wav"))
        self.rich = (self.bank_dir / "bank.json").exists()
        self.bar_s = BAR_S
        if self.rich:
            import json
            meta = json.loads((self.bank_dir / "bank.json").read_text())
            self.bar_s = 240.0 / float(meta.get("bpm", BPM))
        # manual override for the value triple (the audition instrument's
        # MANUAL mode and scripted scenes); None = heuristic battery
        self.override_vals = None
        self.vals = (1.0, 0.0, 0.0)
        self.inputs: dict = {}
        self._applied = (1.0, 0.0, 0.0)
        # inputs snapshotted at the bar line — the ONLY inputs the rich
        # lanes may read (Tower-of-Torment law: nothing enters except on
        # a bar; a mid-bar aggro waits for the next bar line)
        self._applied_inputs: dict = {}
        self._last_bar = -1
        self._channels = {}
        self._sting = None
        self._pending_sting = False
        self._started = False
        self._t0_tick = None      # tick when the loops actually started —
        #                           the audio's bar 0; the bar clock is
        #                           anchored HERE, not at tick 0
        self._riser_gain = 0.0
        self._live: dict = {}

    # -- mixer plumbing --------------------------------------------------
    def _loop_names(self):
        names = ["prayer", "contempt", "stalwart", "riser"]
        if self.rich:
            names += [p.stem for p in sorted(self.bank_dir.glob("bed_t*.wav"))]
            names += [p.stem for p in sorted(self.bank_dir.glob("lead_*.wav"))]
            names += [p.stem for p in sorted(self.bank_dir.glob("bass_*.wav"))]
        return names

    def _ensure_started(self, tick: int = 0):
        if self._started or not self.enabled or not self.has_bank:
            return
        self._started = True
        if not getattr(self.bank, "_ready", False):
            return
        import pygame
        try:
            names = self._loop_names()
            if pygame.mixer.get_num_channels() < 8 + len(names):
                pygame.mixer.set_num_channels(8 + len(names))
            # load EVERYTHING first: decode time between play() calls
            # would stagger the loops' bar 0 (they must start inside the
            # same mixer buffer to stay phase-locked)
            sounds = []
            for i, name in enumerate(names):
                fn = self.bank_dir / f"{name}.wav"
                if fn.exists():
                    sounds.append((name, pygame.mixer.Channel(4 + i),
                                   pygame.mixer.Sound(str(fn))))
            for name, ch, snd in sounds:
                ch.play(snd, loops=-1)
                ch.set_volume(0.0)
                self._channels[name] = ch
            self._sting = pygame.mixer.Sound(str(self.bank_dir / "sting.wav"))
            self._t0_tick = tick
        except Exception as exc:
            print(f"[music] start failed, logging only: {exc}",
                  file=sys.stderr)
            self._channels = {}

    def _apply(self, dt: float = 1.0 / 60.0):
        """Derivative-aware gain application (director's transition ruling):
        RISES land as walls (immediate — the album's binary entry), FALLS
        fade with musical timing (~1.5 bars to silence) so nothing is cut
        off mid-ring. self._applied holds bar-quantized TARGETS; _live
        holds what the channels actually sit at this frame."""
        p, c, d = self._applied
        # perceptual mapping: equal-power-ish curve — a 0.3 VALUE should be
        # clearly audible, not volume 0.3 (judge heard small skirmishes as
        # ignored)
        targets = {"prayer": p ** 0.5, "contempt": c ** 0.5,
                   "stalwart": d ** 0.5,
                   "riser": self._riser_gain * 0.85}
        if self.rich:
            combat = max(c, d) ** 0.5
            snap = self._applied_inputs or self.inputs
            tier = int(snap.get("tier", 1))
            weapon = str(snap.get("weapon", "?"))
            kinds = {}
            for kind, same_room in snap.get("aggro", []):
                kinds[kind] = kinds.get(kind, 0) + (1.0 if same_room
                                                    else 0.4)
            for name in self._channels:
                if name.startswith("bed_t"):
                    on = name == f"bed_t{max(1, min(4, tier))}"
                    targets[name] = (0.55 + 0.35 * p) if on else 0.0
                elif name.startswith("lead_"):
                    targets[name] = 0.8 * combat \
                        if name == f"lead_{weapon}" else 0.0
                elif name.startswith("bass_"):
                    kind = name[5:]
                    targets[name] = 0.75 * min(1.0, kinds.get(kind, 0.0)
                                               / 2.0) ** 0.5
        fall_rate = dt / (1.5 * self.bar_s)        # full fade ~1.5 bars
        master = getattr(self.bank, "master", 1.0)
        for name in self._channels if self.rich else (
                "prayer", "contempt", "stalwart", "riser"):
            cur = self._live.get(name, targets.get(name, 0.0))
            tgt = targets.get(name, 0.0)
            if tgt >= cur:
                cur = tgt                          # rise = wall
            else:
                cur = max(tgt, cur - fall_rate)    # fall = musical fade
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
        """Seconds since the loops' bar 0 (the audio's own clock)."""
        t0 = self._t0_tick if self._t0_tick is not None else 0
        return (tick - t0) / TICKS_PER_S

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

        # the bar clock counts from when the AUDIO started, so every
        # quantized move lands on an audible bar line
        t = self.music_time(session.tick_count)
        bar = int(t / self.bar_s)
        if bar != self._last_bar:
            self._last_bar = bar
            prev = self._applied
            self._applied = self.vals
            self._applied_inputs = dict(self.inputs)
            if (self.vals[2] - prev[2] >= STING_RISE or
                    self.vals[1] - prev[1] >= STING_RISE):
                self._pending_sting = True         # hard rise = a wall
            if self._applied != prev:
                p, c, d = self._applied
                self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
        # stings land on the 8th grid, never mid-air
        if self._pending_sting:
            eighth = self.bar_s / 8.0
            if t % eighth < (1.5 / TICKS_PER_S):
                self._pending_sting = False
                self._sting_now()
        self._apply()

    def _sting_now(self):
        self._tap("music_sting", "sting", 1.0)
        if self._channels and self._sting is not None:
            import pygame
            try:
                pygame.mixer.Channel(3).play(self._sting)
                pygame.mixer.Channel(3).set_volume(
                    0.8 * getattr(self.bank, "master", 1.0))
            except Exception:
                pass

    def stop(self):
        for ch in self._channels.values():
            try:
                ch.stop()
            except Exception:
                pass
        self._channels.clear()
        self._started = False
