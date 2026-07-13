"""Dynamic music — the Commando's emotional state, illustrated.

The states are EMOTIONAL, not threat meters (tools/musicgen/
DIRECTOR_FEEDBACK.md, the emotional spec):

  PRAYER   — calm: praying, contemplating, processing — over a pulse that
             never stops (the mission's urgency).
  CONTEMPT — weak enemies: confident, dismissive groove; the chant does
             not pause for trash.
  STALWART — overwhelming odds: the prayer for vengeance; the harmonic
             floor holds; the cantus firmus persists through the peak.

Mechanism is deliberately DOOM-simple (GORDON_METHOD.md §7, pyweek-28
lineage): four always-looping stems (prayer/contempt/stalwart/riser) with
bar-quantized BINARY gain moves (walls and vacuums, not crossfades —
ALBUM_TECHNIQUES.md §5), one sting one-shot on hard entries, and the
Shepard riser whose tension releases on gameplay's schedule (a dormant
flicker the player can't see; the music can).

The classifier models how the Commando READS the fight (weight class, HP,
his own room vs elsewhere) — many weak enemies is still CONTEMPT
(director: "the classifier rides a line, not discrete buckets"; state
blends are expressed by stem layering, chant continuity preserved).

All decisions are functions of sim state on the sim's tick clock —
deterministic given a recording, and logged through the same audio tap
stream events.jsonl carries, so tools/playtest/mkvideo.py can rebuild the
exact music mix offline for captures (headless runs have no live mixer).
"""
from __future__ import annotations

import sys
from pathlib import Path

BANK_DIR = Path(__file__).resolve().parent / "assets/music/hymn01"
BPM = 140.0
BAR_S = 240.0 / BPM                       # 4 beats
TICKS_PER_S = 60.0

# How the Commando reads each enemy kind (weight class, not body count).
THREAT_WEIGHT = {
    "mite": 0.6, "husk": 1.0, "spitter": 2.0, "shrieker": 2.5,
    "brute": 4.0, "warden": 5.0, "flicker": 3.0,   # flicker counts once REVEALED
}
OTHER_ROOM_FACTOR = 0.35                  # awake threats elsewhere weigh less

STALWART_AT = 8.0                         # weighted threat that reads "test"
STALWART_HURT_AT = 3.0                    # ...or this much while badly hurt
HURT_HP = 35.0
DOWNSHIFT_CLEAN_BARS = 2                  # hysteresis: calm must hold

# Stem gain tables per state (binary moves; chant continuity built in:
# prayer never fully leaves under contempt — the chants persist).
GAINS = {
    "prayer":   {"prayer": 1.0, "contempt": 0.0, "stalwart": 0.0},
    "contempt": {"prayer": 0.25, "contempt": 1.0, "stalwart": 0.0},
    "stalwart": {"prayer": 0.0, "contempt": 0.35, "stalwart": 1.0},
}
RISER_MAX = 0.85


def classify(session) -> tuple[str, float]:
    """(state, tension) from sim state. Pure; unit-tested.

    tension drives the riser: dormant lurking flickers near the player —
    danger the sensors barely show. Revealed/attacking flickers are
    ordinary threat instead."""
    proom = session.player_room()
    threat = 0.0
    tension = 0.0
    for eid, e in session.enemies.items():
        kind = e.get("kind")
        w = THREAT_WEIGHT.get(kind, 1.0)
        try:
            room = session.sim.get_room(eid)
        except Exception:
            continue
        state = e.get("state", "idle")
        if kind == "flicker" and state == "lurk":
            if room == proom:
                tension = min(1.0, tension + 0.5)
            return_state = None  # lurking flickers add tension, not threat
            continue
        if state in ("idle", "waking"):
            continue
        threat += w if room == proom else w * OTHER_ROOM_FACTOR
    hp = getattr(session, "hp", 100.0)
    if threat >= STALWART_AT or (hp < HURT_HP and threat >= STALWART_HURT_AT):
        return "stalwart", tension
    if threat > 0.0:
        return "contempt", tension
    return "prayer", tension


class MusicSystem:
    """Bar clock + stem channels + the state machine. App-layer only."""

    def __init__(self, audio_bank, enabled: bool = True):
        self.bank = audio_bank                    # perihelion.audio.AudioBank
        self.enabled = enabled and BANK_DIR.exists()
        self.state = "prayer"
        self.tension = 0.0
        self._pending: str | None = None
        self._calm_bars = 0
        self._last_bar = -1
        self._channels = {}
        self._sounds = {}
        self._sting = None
        self._started = False
        self._gains = dict(GAINS["prayer"])
        self._riser_gain = 0.0

    # -- mixer plumbing ------------------------------------------------
    def _ensure_started(self):
        if self._started or not self.enabled:
            return
        self._started = True
        if not getattr(self.bank, "_ready", False):
            return                                 # headless: log-only
        import pygame
        try:
            for i, name in enumerate(("prayer", "contempt", "stalwart",
                                      "riser")):
                snd = pygame.mixer.Sound(str(BANK_DIR / f"{name}.wav"))
                ch = pygame.mixer.Channel(4 + i)   # SFX use low channels
                ch.play(snd, loops=-1)
                ch.set_volume(0.0)
                self._sounds[name] = snd
                self._channels[name] = ch
            self._sting = pygame.mixer.Sound(str(BANK_DIR / "sting.wav"))
        except Exception as exc:                   # never kill the game loop
            print(f"[music] start failed, logging only: {exc}",
                  file=sys.stderr)
            self._channels = {}

    def _apply_gains(self):
        master = getattr(self.bank, "master", 1.0)
        for name, ch in self._channels.items():
            g = self._riser_gain * RISER_MAX if name == "riser" \
                else self._gains.get(name, 0.0)
            ch.set_volume(max(0.0, min(1.0, g * 0.8 * master)))

    def _tap(self, kind: str, detail: str, vol: float):
        tap = getattr(self.bank, "tap", None)
        if tap is not None:
            tap(kind, detail, vol, 0.5)

    # -- per-tick update -----------------------------------------------
    def update(self, session):
        if not self.enabled:
            return
        self._ensure_started()
        want, tension = classify(session)
        self.tension = tension

        # riser follows tension immediately (it's the unseen threat), and
        # releases with a sting the instant the threat commits
        if tension > self._riser_gain + 1e-6:
            self._riser_gain = tension
            self._tap("music_riser", f"{tension:.2f}", tension)
        elif tension <= 1e-6 and self._riser_gain > 1e-6:
            self._riser_gain = 0.0
            self._tap("music_riser", "0.00", 0.0)
            if self.state != "prayer" or want != "prayer":
                self._sting_now()

        bar = int((session.tick_count / TICKS_PER_S) / BAR_S)
        new_bar = bar != self._last_bar
        self._last_bar = bar

        if want != self.state:
            up = (("prayer", "contempt", "stalwart").index(want)
                  > ("prayer", "contempt", "stalwart").index(self.state))
            if up:
                self._pending = want
                self._calm_bars = 0
            else:
                # downshift needs clean bars (hysteresis), counted at bars
                if new_bar:
                    self._calm_bars += 1
                    if self._calm_bars >= DOWNSHIFT_CLEAN_BARS:
                        self._pending = want
        else:
            self._calm_bars = 0

        if new_bar and self._pending:
            prev = self.state
            self.state = self._pending
            self._pending = None
            self._gains = dict(GAINS[self.state])
            if ("prayer", "contempt", "stalwart").index(self.state) > \
                    ("prayer", "contempt", "stalwart").index(prev):
                self._sting_now()                  # entry is a WALL
            self._tap("music_state", self.state, 1.0)
        self._apply_gains()

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
