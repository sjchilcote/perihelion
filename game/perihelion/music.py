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
    """Continuous-value engine + bar-quantized musical application."""

    def __init__(self, audio_bank, enabled: bool = True):
        self.bank = audio_bank
        self.enabled = enabled and BANK_DIR.exists()
        self.vals = (1.0, 0.0, 0.0)
        self.inputs: dict = {}
        self._applied = (1.0, 0.0, 0.0)
        self._last_bar = -1
        self._channels = {}
        self._sting = None
        self._started = False
        self._riser_gain = 0.0
        self._live: dict = {}

    # -- mixer plumbing --------------------------------------------------
    def _ensure_started(self):
        if self._started or not self.enabled:
            return
        self._started = True
        if not getattr(self.bank, "_ready", False):
            return
        import pygame
        try:
            for i, name in enumerate(("prayer", "contempt", "stalwart", "riser")):
                fn = BANK_DIR / f"{name}.wav"
                snd = pygame.mixer.Sound(str(fn))
                ch = pygame.mixer.Channel(4 + i)
                ch.play(snd, loops=-1)
                ch.set_volume(0.0)
                self._channels[name] = ch
            self._sting = pygame.mixer.Sound(str(BANK_DIR / "sting.wav"))
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
        targets = {"prayer": p, "contempt": c, "stalwart": d,
                   "riser": self._riser_gain * 0.85}
        fall_rate = dt / (1.5 * BAR_S)             # full fade ~1.5 bars
        master = getattr(self.bank, "master", 1.0)
        for name in ("prayer", "contempt", "stalwart", "riser"):
            cur = self._live.get(name, targets[name])
            tgt = targets[name]
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
    def update(self, session):
        if not self.enabled:
            return
        self._ensure_started()
        self.inputs = read_inputs(session)
        self.vals = values(self.inputs)
        tension = self.inputs["tension"]

        if tension > self._riser_gain + 1e-6:
            self._riser_gain = tension
            self._tap("music_riser", f"{tension:.2f}", tension)
        elif tension <= 1e-6 and self._riser_gain > 1e-6:
            self._riser_gain = 0.0
            self._tap("music_riser", "0.00", 0.0)
            self._sting_now()                      # release on the pounce

        bar = int((session.tick_count / TICKS_PER_S) / BAR_S)
        if bar != self._last_bar:
            self._last_bar = bar
            prev = self._applied
            self._applied = self.vals
            if (self.vals[2] - prev[2] >= STING_RISE or
                    self.vals[1] - prev[1] >= STING_RISE):
                self._sting_now()                  # hard rise = a wall
            if self._applied != prev:
                p, c, d = self._applied
                self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
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
