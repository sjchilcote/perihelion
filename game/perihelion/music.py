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
  CONTEMPT — damage OUTPUT ("ass-kicking music"): the dismissive
             groove rides whenever the Commando is dealing it out.
  STALWART — danger INPUT ("boss music"): doomed odds, hold the line.
  Independent axes (director's base-definition adjustment,
  2026-07-16): a boss fight is BOTH high; trash-mowing is contempt
  alone; being hunted while unable to fight back is stalwart alone.

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

The riser fires ONLY on a sudden intensity rise (a spike the one-bar
filter hasn't absorbed, or a mass-aggro influx): a bounded 2-bar
one-shot arc that releases into a sting quantized to the 8th grid.
It never sustains (director 2026-07-17).

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
# CORPUS-FITTED (task #34, 2026-07-16): 200 farmed runs, 478k rows,
# per-unit ridge coefficients against measured 5s-future damage /
# kill-flow / calm. The surprises the director predicted: an ADJACENT
# hunting warden is ~73% of a co-room one (the old 0.35 discount was
# badly wrong for heavies); inverse-distance CROWD pressure and aggro
# INFLUX are first-class danger terms; a hunting shrieker predicts
# LESS damage (it is running away); being hurt predicts LESS future
# damage (hurt players play safe), so the old x1.2 hurt amplifier is
# gone. Held-out Spearman vs old battery: danger .256/.206,
# mowing .220/.001, calm .254/.178. See tools/musiccal/tune_battery2.py.
# warden weights are DESIGN weights now (director 2026-07-16: wardens
# live only in boss rooms; STALWART is boss music and must clear 0.9
# ONLY there) -- raised from the corpus-fitted 12/8.5 so boss fights
# sit ~2x above the biggest ordinary wave peaks; all other kinds stay
# corpus-fitted.
DANGER_CO = {"warden": 20.0, "brute": 1.0, "flicker": 1.9, "husk": 1.0,
             "mite": 0.8, "spitter": 0.6, "shrieker": 0.15}
DANGER_ADJ = {"warden": 14.0, "brute": 0.3, "flicker": 0.2, "husk": 0.8,
              "mite": 0.3, "spitter": 0.3, "shrieker": 0.1}
CROWD_W = 27.5           # per unit inverse-distance mass (co-room)
INFLUX_W = 3.0           # per newly-aggroed enemy per second (3s EMA)
# (scream term REMOVED, director 2026-07-16: screams correlate with
# danger because they coincide with entering full rooms -- a
# confounder, not a source. A distant off-camera scream carries no
# threat; the influx/count terms carry the real thing when the woken
# wave actually arrives.)
DMG_W = 0.13             # per hp/s taken (3s EMA)
# FIRED_W removed from danger (design override, director 2026-07-17:
# "firing causes CONTEMPT, danger causes STALWART"). The corpus fitted
# 9.96 because firing precedes damage -- but that correlation belongs
# to the enemies present, which the kind/crowd/influx terms already
# count. A poorly-aimed burst at a lone lurker must not read as a
# whole fight (F004235).
FIRED_W = 0.0
DANGER_KNEE = 17.0       # waves cap ~0.88; only boss wardens clear 0.9
# CONTEMPT axis (BASE DEFINITIONS ADJUSTED, director 2026-07-16):
# contempt = damage OUTPUT ("you are doing a lot of damage"), stalwart
# = danger INPUT ("you are doomed, hold out") -- INDEPENDENT axes. A
# boss fight is BOTH high; the old contempt*(1-stalwart) crush (from
# the 2026-07-13 brief) is superseded. Refit vs ungated future
# kill-flow: held-out Spearman 0.471 (old form: 0.068).
KILL_W = 0.37            # per kill/s (3s EMA)
FIRE_MOW_W = 5.65        # trigger duty IS the mow signal (fitted)
TRASH_W = 0.012          # near-zero: bodies standing around are not output
MOW_KNEE = 1.5
ENGAGE_KNEE = 16.0       # rank-preserving rescale (fitted 39.5 left
#                          prayer nearly flat in real fights)
FIRE_PRAY = 0.007
# bass-lane selection only (dominant_kind), NOT danger:
THREAT_WEIGHT = {
    "mite": 0.6, "husk": 1.0, "spitter": 2.0, "shrieker": 0.8,
    "brute": 4.0, "warden": 5.0, "flicker": 3.0,
}
WEAK_KINDS = {"mite", "husk"}
OTHER_ROOM_FACTOR = 0.35     # dominant_kind's room discount only
PRAYER_FLOOR = 0.12          # the urgency pulse never fully stops
STING_RISE = 0.35            # a value jump this big in one bar = a wall
FALL_STEP = 0.65             # per-bar multiplier on a falling lane gain
#   (unified with the judged 0.65x glide -- the old 0.35x fall and the
#   instant "pull" both read as someone hitting NEXT, F003993)
MAX_LANES = 9        # fixed lane-channel span: two banks of lane
#                      channels exist side by side during a rotation
#                      crossfade (A at 4.., B at 4+MAX_LANES..)
XFADE_BARS = 2       # rotation crossfade length (director: base-
#                      melody switches must not hard cut)

# lanes that carry combat material -- the ones a release fades out.
# holy is NEVER here: PRAYER is the one continuous through-line and
# only death stops it (director 2026-07-17).
HEAVY_LANES = ("wall", "boss", "drums", "bass", "lead", "lead2",
               "groove")
# rhythmic lanes EXIT CLEAN on the bar line instead of fading
# (Gemini A/B 2026-07-17, 4/4 consistent rationale: an amplitude-fade
# on an active drum loop reads as a DJ fader, not composition --
# percussion stops at the boundary, sustained material rings out)
CLEAN_EXIT_LANES = ("drums",)
# nonlinear filter (director's rule): MASSIVE spikes pass immediately,
# ambiguous encounters must persist through the one-bar low-pass
SPIKE_JUMP = 0.30            # raw-vs-filtered stalwart gap that snaps
SPIKE_INFLUX = 3.0           # aggro/s that snaps (the scream-wave case)


def read_inputs(session) -> dict:
    """The engine's complete input tuple, from live sim state.

    aggro = enemies whose AI is actively engaged (not idle/waking/lurk).
    """
    proom = session.player_room()
    lf = getattr(session, "last_fire_tick", None)
    player_hot = lf is not None and \
        (session.tick_count - lf) < 3 * TICKS_PER_S
    firing_now = lf is not None and (session.tick_count - lf) < 8
    try:
        px, py = session.player_pos()
    except Exception:
        px = py = None
    aggro = []          # (kind, hops) -- 0 co-room, 1 adjacent, 2 = far
    aggro_ids = []
    crowd = 0.0         # inverse-distance mass of co-room hunters
    tension = 0.0
    for eid, e in session.enemies.items():
        kind = e["kind"]
        state = e["state"]
        if kind == "flicker" and state == "lurk":
            try:
                if session.sim.get_room(eid) == proom:
                    tension = min(1.0, tension + 0.5)
            except Exception:
                pass
            continue
        if state == "idle":
            continue
        if state == "waking" and not player_hot:
            continue    # unaware enemies join the fight only once the
            #             player opens fire (music follows HIS aggression
            #             too, not just the AI's)
        try:
            room = session.sim.get_room(eid)
            hops = 0 if room == proom else \
                session.sim.hop_distance(room, proom)
        except Exception:
            continue
        hops = hops if 0 <= hops <= 1 else 2
        aggro.append((kind, hops))
        aggro_ids.append(eid)
        if hops == 0 and px is not None:
            try:
                import math as _m
                _, ex, ey, *_ = session.sim.get(eid)
                crowd += 1.0 / max(_m.hypot(ex - px, ey - py), 10.0)
            except Exception:
                pass
    # COMPLETE input dict: every key the battery reads exists here
    # (EMA rates are 0.0 until the engine overwrites them) -- so the
    # battery reads strictly, and a missing key is a crash, not a
    # silently becalmed music system
    return dict(
        level=getattr(session, "level_name", "?"),
        weapon=getattr(session, "weapon", None) or
               getattr(session, "current_weapon", "?"),
        aggro=aggro,
        aggro_ids=aggro_ids,
        crowd=round(crowd, 4),
        firing_now=firing_now,
        hp=session.hp,
        tension=tension,
        influx_rate=0.0, dmg_rate=0.0, kill_rate=0.0, fire_duty=0.0,
    )


def battery_terms(inputs: dict) -> tuple[dict, dict]:
    """Named contributions: (danger_terms, mow_terms). The debug DAW
    overlay shows the top-3 of each -- WHY the meters read what they
    read (director 2026-07-17)."""
    danger: dict = {}
    mow: dict = {}
    for kind, hops in inputs["aggro"]:
        if hops == 0:
            danger[f"{kind}"] = danger.get(f"{kind}", 0.0) \
                + DANGER_CO[kind]
        elif hops == 1:
            danger[f"{kind}+1"] = danger.get(f"{kind}+1", 0.0) \
                + DANGER_ADJ[kind]
        else:
            danger[f"{kind}+2"] = danger.get(f"{kind}+2", 0.0) \
                + 0.15 * DANGER_ADJ[kind]
    if inputs["crowd"]:
        danger["crowd"] = CROWD_W * inputs["crowd"]
    if inputs["influx_rate"]:
        danger["influx"] = INFLUX_W * inputs["influx_rate"]
    if inputs["dmg_rate"]:
        danger["dmg"] = DMG_W * inputs["dmg_rate"]
    if inputs["fire_duty"]:
        mow["firing"] = FIRE_MOW_W * inputs["fire_duty"]
    if inputs["kill_rate"]:
        mow["kills"] = KILL_W * inputs["kill_rate"]
    trash = sum(1 for k, h in inputs["aggro"]
                if h == 0 and k in WEAK_KINDS)
    if trash:
        mow["trash"] = TRASH_W * trash
    return danger, mow


def values(inputs: dict) -> tuple[float, float, float]:
    """(prayer, contempt, stalwart), each 0-1, corpus-fitted battery.

    - stalwart = the odds as they measurably ARE: kind-weighted hunters
      (adjacent heavies nearly full weight), crowd pressure, aggro
      influx, damage flow, and the player's own trigger (sustained
      firing measurably precedes damage).
    - contempt = damage OUTPUT, an independent axis (director
      2026-07-16): trigger duty + kill flow. A boss fight reads
      stalwart AND contempt at once; only silence reads neither.
    - prayer = the room the fight leaves over, floored: contemplation
      with the mission clock always running.

    EMA inputs (influx_rate, dmg_rate, kill_rate, fire_duty) are
    engine-tracked; absent keys read 0 so a bare snapshot still works.
    """
    import math
    danger = 0.0
    trash = 0
    for kind, hops in inputs["aggro"]:
        if hops == 0:
            danger += DANGER_CO[kind]
            if kind in WEAK_KINDS:
                trash += 1
        elif hops == 1:
            danger += DANGER_ADJ[kind]
        else:
            danger += 0.15 * DANGER_ADJ[kind]
    danger += CROWD_W * inputs["crowd"]
    danger += INFLUX_W * inputs["influx_rate"]
    danger += DMG_W * inputs["dmg_rate"]
    stalwart = 1.0 - math.exp(-danger / DANGER_KNEE)

    mow = KILL_W * inputs["kill_rate"] \
        + FIRE_MOW_W * inputs["fire_duty"] \
        + TRASH_W * trash
    contempt = 1.0 - math.exp(-mow / MOW_KNEE)

    prayer = max(PRAYER_FLOOR,
                 1.0 - min(1.0, danger / ENGAGE_KNEE
                           + FIRE_PRAY * inputs["fire_duty"]))
    return (round(prayer, 3), round(contempt, 3), round(stalwart, 3))


def dominant_kind(aggro) -> str | None:
    """The enemy kind that owns the bassline: highest total threat
    weight among engaged enemies (same-room weighted up)."""
    totals: dict[str, float] = {}
    for kind, hops in aggro:
        w = THREAT_WEIGHT[kind] * (1.0 if hops == 0
                                            else OTHER_ROOM_FACTOR)
        totals[kind] = totals.get(kind, 0.0) + w
    if not totals:
        return None
    return max(totals, key=totals.get)


# In-level bank rotation (director 2026-07-16: "the engine mixing and
# matching them", not an env var): every ROTATE_BARS bar lines the
# engine hands off to the next album bank ON a bar line. ~44 bars at
# 110bpm is ~96s -- inside the variety law's few-minute window.
ROTATE_BARS = 44


from dataclasses import dataclass  # noqa: E402


@dataclass(frozen=True)
class BankMeta:
    """A rich bank's form, as one immutable value (director 2026-07-17:
    'situations like the clobbered section map should be rendered
    UNREPRESENTABLE'). There is exactly one loader, it validates or
    raises, and MusicSystem exposes the fields through read-only
    properties -- a stray `self.sections = []` is now an AttributeError
    at the assignment site, not a silently dead form-steering system."""
    bar_s: float
    n_bars: int
    sections: tuple      # (("vigil", 0, 8), ...) -- never empty


def load_bank_meta(bank_dir: Path) -> BankMeta:
    """THE loader for bank.json. Required keys, validated ranges, no
    neutral defaults: a missing bpm used to silently run the bank at
    140, missing sections silently disabled form steering."""
    import json
    bj = bank_dir / "bank.json"
    raw = json.loads(bj.read_text())
    try:
        bpm = float(raw["bpm"])
        bars = int(raw["bars"])
        sections = tuple((str(s), int(a), int(b))
                         for s, a, b in raw["sections"])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(f"{bj}: missing/malformed required field "
                         f"({exc!r})") from None
    if bpm <= 0 or bars <= 0 or not sections:
        raise ValueError(f"{bj}: bpm={bpm} bars={bars} "
                         f"sections={sections!r}")
    for s, a, b in sections:
        if not 0 <= a < b <= bars:
            raise ValueError(f"{bj}: section {s!r} [{a},{b}) outside "
                             f"the {bars}-bar form")
    return BankMeta(240.0 / bpm, bars, sections)


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
        self.fade_ticks = 0               # farewell-bar fade-out state
        self.fade_total = 1
        self.fadein_ticks = 0             # arrival fade-in (jumps/rotation)
        self.fadein_total = 1

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

    def seek(self, idx: int):
        """Form jump: the NEXT bar comes from position `idx` -- queue()
        replaces the pending chunk, so the jump lands exactly on the
        next bar line, per the chunk-queue grammar."""
        self.next_idx = idx
        if self.key is not None and self.ch is not None:
            self.ch.queue(self.variants[self.key][idx % self.n])

    def set_gain(self, gain: float, master_vol: float):
        self.gain = gain
        self.ch.set_volume(max(0.0, min(1.0, gain * master_vol)))


class MusicSystem:
    """Continuous-value engine + chunk-queued musical application."""

    def __init__(self, audio_bank, enabled: bool = True, bank_dir=None,
                 tick_clock: bool = False, bank_dirs=None):
        # tick_clock: headless/recording mode — decisions advance on the
        # DETERMINISTIC tick grid and nothing plays (offline rebuild
        # supplies the audio); the live audio-hardware clock would race
        # ahead whenever the recording loop runs slower than realtime
        self.bank = audio_bank
        self.tick_clock = tick_clock
        # the INPUT engine always runs (values, taps, riser logic — the
        # part the director kept); only the MIXER needs stems on disk.
        self.enabled = enabled
        self._bank_dirs = [Path(b) for b in bank_dirs] if bank_dirs else []
        self._bank_i = 0
        if bank_dir is None and self._bank_dirs:
            bank_dir = self._bank_dirs[0]
        self.bank_dir = Path(bank_dir) if bank_dir else BANK_DIR
        # rotation machinery: next bank decodes on a worker thread, then
        # converts to Sounds one stem per tick -- the switch itself is a
        # single-boundary lane restart; nothing ever blocks the frame
        self._decode_thread = None
        self._decoded = None          # {name: [np segment per bar]} + meta
        self._next_chunks = None
        self._next_names = None
        self._bank_bar0 = 0           # tick-clock absolute-bar offset
        self.has_bank = self.bank_dir.exists() \
            and (any(self.bank_dir.glob("*.wav"))
                 or any(self.bank_dir.glob("*.ogg")))
        self.rich = (self.bank_dir / "bank.json").exists()
        # ONE immutable meta value; bar_s/n_bars/sections are read-only
        # properties over it. (Two generations of silent breakage lived
        # here: sections only loaded in the tick-clock rotation branch,
        # then a duplicate `self.sections = []` clobbering the loaded
        # map. Neither state is expressible anymore.)
        self._meta: BankMeta | None = \
            load_bank_meta(self.bank_dir) if self.rich else None
        # manual override for the value triple (the audition instrument's
        # MANUAL mode and scripted scenes); None = heuristic battery
        self.override_vals = None
        self.vals = (1.0, 0.0, 0.0)
        # low-pass on the battery (director 2026-07-16): the music must
        # not wake for a fight shorter than a bar — tau = one bar, so a
        # 0.3s trash pop peaks ~0.1x and decays below threshold before
        # the next boundary, while a real fight reaches ~63% in one bar
        # and the transition controller shapes the arrival from there
        self._lp = (1.0, 0.0, 0.0)
        # engine-side EMA state for the corpus-fitted battery inputs
        self._prev_aggro_ids: set = set()
        self._prev_hp = None
        self._prev_kills = 0
        self._ema_influx = 0.0     # newly-aggroed enemies per second
        self._ema_dmg = 0.0        # hp lost per second
        self._ema_kill = 0.0       # kills per second
        self._ema_fire = 0.0       # trigger duty, 1s EMA
        # dual-lead crossfade (director 2026-07-16: switching weapons
        # crossfades leads SLOWLY with a 50/50 deadzone -- a rail/
        # shotgun fight plays BOTH leads together)
        self._lead_a: str | None = None
        self._lead_b: str | None = None
        self._xfade = 0.0          # 0 = all A, 1 = all B
        self._xfade_tgt = 0.0
        self._xfade_dwelled = False
        # form steering (boss law): position in the form, jumped to the
        # PEAK section at stalwart >= 0.88, back to vigil when becalmed
        self._form_idx = 0
        self._pending_jump = 0        # bars until a riser-led peak jump
        self._lane_ch_base = 4        # flips each rotation (A/B sets)
        self._old_lanes = None        # fading continuation of the
        self._old_ttl = 0             # previous bank during crossfade
        self._jump_target = 0
        self._riser_fade = False
        # COMPLETE initial inputs: _select_content runs at startup
        # before the first read_inputs -- a complete value here lets it
        # read strictly instead of defaulting
        self.inputs: dict = dict(
            level="?", weapon="?", aggro=[], aggro_ids=[], crowd=0.0,
            firing_now=False, hp=100.0, tension=0.0, tier=1,
            influx_rate=0.0, dmg_rate=0.0, kill_rate=0.0, fire_duty=0.0)
        self._applied = (1.0, 0.0, 0.0)
        self._last_bar = -1
        self._started = False
        # riser one-shot envelope (director 2026-07-17: risers ONLY on
        # sudden intensity rises -- a bounded arc, never a sustain)
        self._riser_gain = 0.0
        self._riser_env = 0
        self._riser_total = 1
        self._riser_peak = 0.0
        self._riser_last = -10 ** 9
        self._riser_ch = None
        self._riser_snd = None
        self._calm_bars = 0           # consecutive becalmed boundaries
        self._quiet_ticks = 10 ** 6   # ticks since aggro was last seen
        self._slam_now = False        # an ambush slam is in flight
        self.slam_riser = True        # Gemini-ranked 2/2 (slam_rank):
        #   the half-bar reversed-bell swell JUSTIFIES the instant
        #   wall; a come-up ramp on the slam bar over-smooths it
        self._ambush_window = 0       # ticks left where a spike counts
        #                               as an AMBUSH (threat out of the
        #                               dark), not a watched approach
        self._boss_hot = False        # latched at applied st>=0.75
        self._halted = False          # death: the music dies with him
        self._pending_sting = False
        self._sting = None
        self._stab = None
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

    def _sim_lanes(self) -> dict:
        """Name-only lanes for tick-clock (recording) mode."""
        stems = {q.stem for q in self.bank_dir.glob("*.wav")} | \
            {q.stem for q in self.bank_dir.glob("*.ogg")}

        class _SimLane:
            def __init__(self, variants):
                self.variants = dict.fromkeys(variants | {"silence"})
                self.key = None
                self.gain = 0.0
        return {
            "drums": _SimLane({s for s in stems
                               if s.startswith("drums")}),
            "bed": _SimLane({s for s in stems if s.startswith("bed_")}),
            "holy": _SimLane({"prayer"}),
            "groove": _SimLane({"contempt"}),
            "wall": _SimLane({"stalwart"}),
            "lead": _SimLane({s for s in stems if s.startswith("lead_")}),
            "lead2": _SimLane({s for s in stems
                               if s.startswith("lead_")}),
            "bass": _SimLane({s for s in stems if s.startswith("bass_")}),
            "boss": _SimLane({"overlay_boss"}
                             if "overlay_boss" in stems else set()),
        }

    @property
    def bar_s(self) -> float:
        return self._meta.bar_s if self._meta else BAR_S

    @property
    def n_bars(self) -> int:
        return self._meta.n_bars if self._meta else 0

    @property
    def sections(self) -> tuple:
        return self._meta.sections if self._meta else ()

    def _section_range(self, stype: str):
        for s, a, b in self.sections:
            if s == stype:
                return (a, b)
        return None

    def _section_at(self, pos: int) -> str | None:
        for s, a, b in self.sections:
            if a <= pos < b:
                return s
        return None

    # sections the form may occupy while a fight is live -- the wrap
    # through outro into the composed intro silenced the chant
    # mid-battle (F002291: bar 35 -> 0 with warheads still flying)
    _COMBAT_SECTIONS = ("entry", "develop", "peak")

    def _gate_jump(self, steer, tick: int):
        """Peak jumps are LED by the riser: the engine schedules this
        arrival itself, so it is the ONE place a swell can resolve into
        a known downbeat (director round 2: reactive risers 'rise to
        nothing' by construction -- a causal engine hears the fight
        only after it starts). Arms the reversed-bell one-shot, holds
        the jump for its 2-bar swell, then lands it AS the bell
        strikes. Non-peak steers pass through untouched."""
        st = self._applied[2]
        if self._pending_jump > 0:
            self._pending_jump -= 1
            if st < 0.75:
                self._pending_jump = 0
                # the pounce died mid-swell: a riser without a landing
                # must not complete ("it's a TRANSITION" -- a swell to
                # nothing is worse than no swell). Fade it out fast.
                self._riser_env = min(self._riser_env,
                                      int(0.35 * TICKS_PER_S))
                self._riser_fade = True
                return steer
            if self._pending_jump == 0:
                return (self._jump_target, "jump")
            return None                  # the swell owns this bar
        if steer is not None and steer[1] == "jump" and st >= 0.88:
            self._jump_target = steer[0]
            self._pending_jump = 2
            self._riser_env = int(2.0 * self.bar_s * TICKS_PER_S)
            self._riser_total = self._riser_env
            self._riser_peak = 0.9
            self._riser_last = tick
            if self._riser_ch is not None and \
                    self._riser_snd is not None:
                self._riser_ch.play(self._riser_snd)
            return None
        return steer

    def _steer_form(self) -> int | None:
        """Form steering at a bar line: returns a jump target index or
        None. Boss engagement (stalwart >= 0.88) pulls the form to the
        PEAK section and loops it; live combat keeps the form inside
        combat material; deep calm returns to vigil/ritual once the
        mix has actually settled. Jumps only land on even form
        positions -- half-phrase grain."""
        if not self.sections:
            return None
        p_, c_, st = self._applied
        pos = self._form_idx % max(1, self.n_bars)
        becalmed = st <= 0.25 and c_ <= 0.25 and p_ >= 0.8
        self._calm_bars = self._calm_bars + 1 if becalmed else 0
        peak = self._section_range("peak")
        if st >= 0.88 and peak is not None:
            a, b = peak
            if not (a <= pos < b):
                if pos % 2 == 0:
                    return (a, "jump")
            elif pos == b - 1:
                return (a, "loop")   # loop the peak while the boss lives
            return None
        if max(c_, st) >= 0.35:
            # combat floor: mid-fight the form never drifts into calm
            # or outro material -- loop back into the develop band at
            # the composed section boundary (seamless, no arrival cut)
            dev = self._section_range("develop") or \
                self._section_range("entry")
            if dev is not None:
                if self._section_at(pos) not in self._COMBAT_SECTIONS:
                    return (dev[0], "loop")
                if pos == dev[1] - 1 and st < 0.85:
                    # ordinary fights LOOP develop; walking on into
                    # peak material is reserved for the boss tier
                    # ("save the really hard stuff for when it counts")
                    return (dev[0], "loop")
            return None
        if becalmed:
            vig = self._section_range("vigil") or \
                self._section_range("ritual")
            if vig is not None:
                a, b = vig
                if pos == b - 1:
                    return (a, "loop")   # deep calm LOOPS the vigil --
                    #   walking on into the band sections was the Lama
                    #   dip-cycle (each re-entry jumped home again with
                    #   a fresh arrival fade)
                in_band = not (a <= pos < b)
                # come home ONCE -- but only after the comedown has
                # finished (calm has held for a phrase AND every heavy
                # lane's glide has landed). Jumping while lanes were
                # still exhaling was F003993/F005171: the arrival cut
                # read as someone hitting NEXT mid-release.
                settled = all(self._live.get(n, 0.0) <= 0.25
                              for n in ("wall", "groove", "drums",
                                        "bass", "lead", "lead2"))
                if in_band:
                    if pos % 2 == 0 and settled and \
                            self._calm_bars >= 4:
                        return (a, "jump")
                    # still exhaling: HOLD position -- loop the section
                    # we fought in rather than walking into fresh
                    # (hotter) material at decaying gains (the S1
                    # regression: the form drifted into PEAK mid-
                    # comedown and the release read as a late cut)
                    for s_, aa, bb in self.sections:
                        if aa <= pos < bb and pos == bb - 1:
                            return (aa, "loop")
        return None

    def _lead_split(self, weapon_key, base_gain: float):
        """Advance the dual-lead crossfade one bar; returns
        (key_a, gain_a, key_b, gain_b). Equal-power split with a sticky
        50/50 deadzone: alternating weapons parks BOTH leads on."""
        import math
        if weapon_key is not None:
            if weapon_key == self._lead_a:
                self._xfade_tgt = 0.0
            elif weapon_key == self._lead_b:
                self._xfade_tgt = 1.0
            elif self._lead_a is None or self._xfade <= 0.5:
                if self._lead_a is not None and \
                        self._lead_b not in (None, weapon_key) and \
                        self._xfade > 0.15:
                    self._tap("music_int",
                              f"lead2:{self._lead_b}>{weapon_key}", 1.0)
                self._lead_b = weapon_key if self._lead_a is not None \
                    else self._lead_b
                if self._lead_a is None:
                    self._lead_a = weapon_key
                    self._xfade_tgt = 0.0
                else:
                    self._xfade_tgt = 1.0
            else:
                if self._lead_a not in (None, weapon_key) and \
                        self._xfade < 0.85:
                    self._tap("music_int",
                              f"lead:{self._lead_a}>{weapon_key}", 1.0)
                self._lead_a = weapon_key
                self._xfade_tgt = 0.0
        step = 0.25
        prev = self._xfade
        d = self._xfade_tgt - prev
        if abs(d) > 1e-6:
            nxt = prev + step * (1 if d > 0 else -1)
            crossed = (prev - 0.5) * (nxt - 0.5) < 0 or abs(nxt - 0.5) < 1e-6
            if crossed and not self._xfade_dwelled:
                nxt = 0.5
                self._xfade_dwelled = True    # the 50/50 deadzone bar
            elif crossed:
                self._xfade_dwelled = False
            self._xfade = min(1.0, max(0.0, nxt))
        else:
            self._xfade_dwelled = False
        ga = base_gain * math.cos(self._xfade * math.pi / 2.0)
        gb = base_gain * math.sin(self._xfade * math.pi / 2.0)
        return (self._lead_a or "silence", ga,
                self._lead_b or "silence", gb)

    @staticmethod
    def _lane_defs(chunks: dict) -> dict:
        beds = sorted(k for k in chunks if k.startswith("bed_t"))
        leads = sorted(k for k in chunks if k.startswith("lead_"))
        basses = sorted(k for k in chunks if k.startswith("bass_"))
        sil = {"silence": chunks["silence"]}
        return {
            "drums": ({k: chunks[k] for k in chunks
                       if k.startswith("drums")} | sil)
            if "drums" in chunks else None,
            "bed": {k: chunks[k] for k in beds} | sil,
            "holy": {"prayer": chunks["prayer"]} | sil,
            "groove": {"contempt": chunks["contempt"]} | sil,
            "wall": {"stalwart": chunks["stalwart"]} | sil,
            "lead": {k: chunks[k] for k in leads} | sil,
            "lead2": {k: chunks[k] for k in leads} | sil,
            "bass": {k: chunks[k] for k in basses} | sil,
            "boss": ({"overlay_boss": chunks["overlay_boss"]} | sil)
            if "overlay_boss" in chunks else None,
        }

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
            self._lanes = self._sim_lanes()
            self._boundary_tick = 0
            self._tap("music_bank", self.bank_dir.name, 1.0)
            return
        import pygame
        sting_f = next((self.bank_dir / f"sting.{ext}"
                        for ext in ("wav", "ogg")
                        if (self.bank_dir / f"sting.{ext}").exists()),
                       None)
        self._sting = pygame.mixer.Sound(str(sting_f)) if sting_f \
            else None
        stab_f = next((self.bank_dir / f"stab.{ext}"
                       for ext in ("wav", "ogg")
                       if (self.bank_dir / f"stab.{ext}").exists()),
                      None)
        self._stab = pygame.mixer.Sound(str(stab_f)) if stab_f \
            else None
        if not self.rich:
            self._start_legacy()
            return
        chunks = self._slice_bank()
        lane_defs = self._lane_defs(chunks)
        assert len(lane_defs) <= MAX_LANES, sorted(lane_defs)
        riser_ch_idx = 4 + 2 * MAX_LANES   # room for BOTH lane sets
        if pygame.mixer.get_num_channels() < riser_ch_idx + 13:
            pygame.mixer.set_num_channels(riser_ch_idx + 13)
        # channels 0..riser are MUSIC/system territory: reserve
        # them from SFX auto-allocation (Sound.play() steals the
        # longest-running channel under load -- i.e. a music lane;
        # and one-shots landing on ch2/3 got hard-cut by the next
        # stab/sting). 12 channels remain as the SFX pool.
        pygame.mixer.set_reserved(riser_ch_idx + 1)
        master = self.bank.master_vol
        lane_defs = {k: v for k, v in lane_defs.items()
                     if v is not None}
        for i, (lname, variants) in enumerate(lane_defs.items()):
            lane = ChunkLane(
                pygame.mixer.Channel(self._lane_ch_base + i), variants,
                self.n_bars)
            self._lanes[lname] = lane
        # riser: a reserved channel, TRIGGERED one-shot (the stem is a
        # reversed bell that swells into its own strike; it plays from
        # the top on each sudden-rise event, never loops)
        riser_fn = next((self.bank_dir / f"riser.{e}"
                         for e in ("wav", "ogg")
                         if (self.bank_dir / f"riser.{e}").exists()),
                        self.bank_dir / "riser.wav")
        self._riser_ch = None
        self._riser_snd = None
        if riser_fn.exists():
            self._riser_snd = pygame.mixer.Sound(str(riser_fn))
            self._riser_ch = pygame.mixer.Channel(riser_ch_idx)
            self._riser_ch.set_volume(0.0)
        # first bar's content from current state, all started in one
        # tight pass (everything is pre-sliced by now)
        sel = self._select_content()
        gains = self._bar_gains()
        for lname, lane in self._lanes.items():
            lane.gain = gains[lname]
            lane.start(sel[lname], master)
        self._bar_idx = 0
        self._boundary_tick = tick
        self._tap("music_bank", self.bank_dir.name, 1.0)

    def _select_content(self) -> dict:
        """Which variant each lane queues next — from CURRENT state (a
        re-selection before the boundary replaces the pending chunk, so
        late changes still land on the bar)."""
        p, c, d = self.vals
        tier = max(1, min(4, int(self.inputs["tier"])))
        weapon = str(self.inputs["weapon"])
        combat = max(c, d)
        kind = dominant_kind(self.inputs["aggro"])
        lanes = self._lanes
        st_now = self._applied[2] if hasattr(self, "_applied") else 0.0
        # hysteresis latch (workflow review): a naked 0.8 threshold
        # flipped the whole kit every bar when stalwart hovered there
        if st_now >= 0.8:
            self._kit_boss = True
        elif st_now < 0.7:
            self._kit_boss = False
        drums_key = "drums"
        if getattr(self, "_kit_boss", False) and "drums_boss" in \
                lanes.get("drums", ChunkLane(None, {}, 1)).variants:
            drums_key = "drums_boss"      # 0.8 tier: the serious kit
        # DERIVED from the lanes dict: every existing lane gets a
        # selection BY CONSTRUCTION (a lane the planner forgot cannot
        # be expressed -- a missing 'lead2' key here once KeyError'd
        # _ensure_started and live play silently ran with no music).
        # lead2 stays silent: the crossfade splitter owns it.
        sel = {ln: "silence" for ln in lanes}
        want = {
            "drums": drums_key if max(c, d) > 0.03 else "silence",
            "boss": "overlay_boss" if st_now >= 0.88 else "silence",
            "bed": f"bed_t{tier}",
            "holy": "prayer",
            "groove": "contempt" if c > 0.03 else "silence",
            "wall": "stalwart" if d > 0.03 else "silence",
            "lead": f"lead_{weapon}" if combat > 0.05 else "silence",
            "bass": f"bass_{kind}" if kind is not None else "silence",
        }
        for ln, key in want.items():
            lane = lanes.get(ln)
            if lane is not None and key in lane.variants:
                sel[ln] = key
        return sel

    def _bar_gains(self) -> dict:
        # (boss lane gain handled inline below via _applied stalwart)
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
        # (kind, hops) since the battery refit -- hops==0 is co-room;
        # the old boolean read had this INVERTED for months of minutes
        n_aggro = sum(1.0 if hops == 0 else 0.4 for _, hops in aggro)
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
            if val > 0.15:
                # floor gate raised from 0.05 (stable judge signal:
                # 1-bar blips popped lanes to full floors -- a whisper
                # of threat must not slam the kit in)
                tgt = max(tgt, floor)
            cur = self._live.get(name, 0.0)
            if tgt > cur:
                cur = min(tgt, cur + max_rise)
            else:
                # falls ALWAYS glide (0.65x/bar exhale). The old
                # instant "pull" on hard drops was the NEXT-button
                # sound (F003993) -- rises get walls, falls breathe.
                cur = tgt if cur * FALL_STEP < 0.02 else \
                    max(tgt, cur * FALL_STEP)
            out[name] = min(cur, 1.0)
        self._live = out
        # (riser no longer rides builds -- it is a one-shot envelope
        # on SUDDEN rises only, owned by update(); the old sustain
        # was F002718's 8-second flat noise blast)
        out["boss"] = min(1.0, max(0.0, (self._applied[2] - 0.88)
                                     / 0.10)) * 0.9
        # COMPLETE by construction: one gain per existing lane (lead2
        # is 0.0 until the crossfade splitter fills it) -- consumers
        # index strictly, a forgotten lane is a KeyError not a 0.0
        return {ln: out.get(ln, 0.0) for ln in self._lanes}

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
        master = self.bank.master_vol
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
        if session.hp <= 0.0:
            # death (director 2026-07-17): the music is the Commando's
            # thinking and feeling -- when he dies, it dies. Instantly,
            # all of it, even the chant: the ONE exception to
            # PRAYER-never-stops.
            if not self._halted and self._started:
                self._halted = True
                self._tap("music_halt", "death", 1.0)
                self.stop()
            return
        self._halted = False
        self._ensure_started(session.tick_count)
        self.inputs = read_inputs(session)
        self.inputs["tier"] = session.music_tier
        # engine EMAs (per-second rates; taus: 3s flows, 1s trigger)
        ids = set(self.inputs.pop("aggro_ids", ()))
        new_aggro = len(ids - self._prev_aggro_ids)
        self._prev_aggro_ids = ids
        hp = self.inputs["hp"]
        dmg = max(0.0, (self._prev_hp - hp)) if self._prev_hp is not None \
            else 0.0
        self._prev_hp = hp
        kills = session.metrics["kills"]
        kd = max(0, kills - self._prev_kills)
        self._prev_kills = kills
        a3 = 1.0 / (3.0 * TICKS_PER_S)
        a1 = 1.0 / TICKS_PER_S
        self._ema_influx += a3 * (new_aggro * TICKS_PER_S
                                  - self._ema_influx)
        self._ema_dmg += a3 * (dmg * TICKS_PER_S - self._ema_dmg)
        self._ema_kill += a3 * (kd * TICKS_PER_S - self._ema_kill)
        self._ema_fire += a1 * ((1.0 if self.inputs.get("firing_now")
                                 else 0.0) - self._ema_fire)
        self.inputs["influx_rate"] = round(self._ema_influx, 4)
        self.inputs["dmg_rate"] = round(self._ema_dmg, 4)
        self.inputs["kill_rate"] = round(self._ema_kill, 4)
        self.inputs["fire_duty"] = round(self._ema_fire, 4)
        raw = self.override_vals or values(self.inputs)
        # AMBUSH tracking (director: the slam-cut is ONLY for a boss
        # hurtling out of the dark -- never a normal fight the player
        # can see coming). An ambush = aggro appearing after >=2s of
        # true quiet; the window it opens lasts one bar.
        if self.inputs["aggro"]:
            if self._quiet_ticks >= int(2.0 * TICKS_PER_S):
                self._ambush_window = int(self.bar_s * TICKS_PER_S)
            self._quiet_ticks = 0
        else:
            self._quiet_ticks += 1
        if self._ambush_window > 0:
            self._ambush_window -= 1
        if self.override_vals:
            self.vals = raw                    # manual = direct control
            self._lp = raw
        else:
            a = (1.0 / TICKS_PER_S) / self.bar_s
            lp = [l + a * (r - l) for l, r in zip(self._lp, raw)]
            # NONLINEAR FILTER, ambush-gated (director 2026-07-17
            # overnight): the slam only fires when the threat came OUT
            # OF THE DARK -- sudden heavy contact after real quiet,
            # landing on a calm mix. A watched approach (the player
            # walking at a compound, waves joining an ongoing fight)
            # builds through the one-bar tau like everything else.
            heavy_co = any(h == 0 and DANGER_CO[k] >= 1.9
                           for k, h in self.inputs["aggro"])
            if (raw[2] - self._lp[2] >= SPIKE_JUMP or
                    self._ema_influx >= SPIKE_INFLUX) and                     self._ambush_window > 0 and heavy_co and                     self._applied[2] <= 0.25:
                lp[2] = max(lp[2], raw[2])
                lp[0] = min(lp[0], raw[0])
                self._slam_now = True
                if getattr(self, "slam_riser", False):
                    # half-bar micro-riser bridging detection to the
                    # boundary where the wall lands (variant under
                    # Gemini ranking; the stem is the reversed bell's
                    # final half bar)
                    self._tap("music_riser2", "0.70", 0.7)
                    rc = self._riser_ch
                    if rc is not None and                             getattr(self, "_riser_half_snd", None):
                        rc.play(self._riser_half_snd)
                        rc.set_volume(0.7 * self.bank.master_vol)
            self._lp = tuple(lp)
            self.vals = tuple(round(v, 3) for v in self._lp)
        # 10Hz value telemetry, raw AND filtered (offline overlays --
        # the pre/post-filter meters in playtest videos): fires only
        # when a recorder tap is attached, costs nothing in normal play
        if getattr(self.bank, "tap", None) is not None and \
                session.tick_count % 6 == 0:
            self._tap("music_valsraw",
                      "%.3f,%.3f,%.3f" % tuple(raw), 1.0)
            self._tap("music_valslp",
                      "%.3f,%.3f,%.3f" % tuple(self.vals), 1.0)
            dt_, mt_ = battery_terms(self.inputs)
            top = lambda d: ",".join(
                f"{k}={v:.1f}" for k, v in
                sorted(d.items(), key=lambda q: -q[1])[:3])
            agg = self.inputs.get("aggro", [])
            co = sum(1 for _k, h in agg if h == 0)
            adj = sum(1 for _k, h in agg if h == 1)
            self._tap("music_dbg",
                      f"st:{top(dt_)}|ct:{top(mt_)}"
                      f"|agg:co={co},adj={adj},far={len(agg)-co-adj}"
                      f"|xf:{self._xfade:.2f}"
                      f"|form:{self._form_idx % max(1, self.n_bars)}",
                      1.0)
        # RISER (director 2026-07-17, round 2): a causal engine cannot
        # anticipate a fight -- a spike-reactive swell always finished
        # AFTER the drop it should have led into ("the risers rise to
        # nothing"). The riser now fires ONLY where the engine KNOWS
        # the future: leading its own scheduled boss peak-jump (see
        # _gate_jump). This block just runs the armed envelope.
        if self._riser_env > 0:
            self._riser_env -= 1
            # the stem is self-enveloped (reversed bell): FLAT gain, no
            # attack/release reshaping -- the old release ramp would
            # fade out the swell right at its payoff. EXCEPT a canceled
            # pounce: then this is a quick fade to nothing.
            if getattr(self, "_riser_fade", False):
                self._riser_gain *= 0.90
            else:
                self._riser_gain = self._riser_peak
            if self._riser_env == 0:
                self._riser_gain = 0.0
                self._riser_fade = False
                self._tap("music_riser", "0.00", 0.0)
            elif session.tick_count % 6 == 0:
                self._tap("music_riser", f"{self._riser_gain:.2f}",
                          self._riser_gain)

        if self._lanes:
            self._update_rich(session)
        else:
            self._update_legacy(session)

    def _update_rich(self, session):
        if self.tick_clock:
            t = session.tick_count / TICKS_PER_S
            bar = int(t / self.bar_s)
            if bar != self._bar_idx or self._boundary_tick == 0:
                self._bar_idx = bar
                self._boundary_tick = session.tick_count or 1
                # bar-line bank handoff (engine-owned mixing/matching).
                # Once due, it WAITS for ~100% PRAYER: never switch
                # tracks when tension is high (director 2026-07-17 --
                # the mid-battle dies_irae -> idumea rotation was the
                # buildup-to-letdown at F002718).
                if len(self._bank_dirs) > 1 and \
                        bar - self._bank_bar0 >= ROTATE_BARS and \
                        self.vals[0] >= 0.95 and \
                        max(self.vals[1], self.vals[2]) <= 0.15:
                    self._bank_i = (self._bank_i + 1) % len(self._bank_dirs)
                    self.bank_dir = self._bank_dirs[self._bank_i]
                    self._meta = load_bank_meta(self.bank_dir)
                    self._lanes = self._sim_lanes()
                    self._bank_bar0 = bar
                    self._form_idx = 0
                    self._tap("music_bank", self.bank_dir.name, 1.0)
                prev = self._applied
                self._applied = self.vals
                self._applied_inputs = dict(self.inputs)
                # (value-jump stings removed: the riser one-shot owns
                # sudden rises now and releases into its own sting --
                # double punctuation for the same event was the ~20s
                # sting metronome)
                if self._applied != prev:
                    p, c, d = self._applied
                    self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
                # boss release LATCHES at >=0.75 and fires when the
                # filtered value lands below 0.3 -- the old single-bar
                # cliff test (prev>=0.75 AND cur<0.3) could never
                # trigger through the one-bar low-pass on real decays:
                # music_rel had NEVER fired in a real recording
                if self._applied[2] >= 0.75:
                    self._boss_hot = True
                boss_release = self._boss_hot and self._applied[2] < 0.3
                if boss_release:
                    self._boss_hot = False
                    self._tap("music_rel", "boss_release", 1.0)
                    self._sting_now(force=True)
                self._form_idx += 1
                steer = self._gate_jump(self._steer_form(),
                                        session.tick_count)
                if steer is not None:
                    self._form_idx = steer[0]
                    if steer[1] == "jump":
                        self._tap("music_jump", str(steer[0]), 1.0)
                    else:
                        # seamless loop steer: visible in the debug
                        # ticker, but the mixer must NOT arrival-ramp
                        self._tap("music_jump", f"{steer[0]}~s", 1.0)

                if self._applied[2] >= 0.88 and self._form_idx % 4 == 0:
                    self._stab_now()
                sel = self._select_content()
                gains = self._bar_gains()
                wkey = sel.get("lead")
                ka, ga, kb, gb = self._lead_split(
                    None if wkey in (None, "silence") else wkey,
                    gains["lead"])
                sel["lead"], gains["lead"] = ka, ga
                sel["lead2"], gains["lead2"] = kb, gb
                for lname, lane in self._lanes.items():
                    prev_key = lane.key
                    nk = sel.get(lname, "silence")
                    if boss_release and lname in HEAVY_LANES and \
                            lname not in CLEAN_EXIT_LANES and \
                            lane.key not in (None, "silence") and \
                            lane.gain > 0.02:
                        # ONE-BAR COMEDOWN (F003993): every heavy lane
                        # plays one more bar fading to nothing under
                        # the toll -- never the instant everything-stop
                        # that sounded like someone hitting NEXT
                        lane._tapkey = f"{lane.key}~f"
                        lane._farewelled = True
                        self._live[lname] = 0.0   # rebuilds from silence
                        continue
                    if getattr(lane, "_farewelled", False):
                        lane._farewelled = False
                        lane.gain = 0.0   # the farewell bar landed at 0
                        if nk == "silence":
                            lane.key = "silence"
                            lane._tapkey = None
                            continue
                    if nk == "silence" and \
                            prev_key not in (None, "silence") and \
                            lname in CLEAN_EXIT_LANES:
                        lane.key = "silence"   # percussion exits CLEAN
                        lane.gain = 0.0        # on the bar line
                        lane._tapkey = None
                        self._live[lname] = 0.0
                        continue
                    if nk == "silence" and \
                            prev_key not in (None, "silence") and \
                            lane.gain > 0.05:
                        # HIGH -> LOW glides: decay 0.65x per bar first
                        # (the intense stems 'just fade out slowly',
                        # director); the farewell bar fires only once
                        # the glide reaches the floor
                        if lane.gain > 0.15:
                            lane.gain = round(lane.gain * 0.65, 3)
                            lane.key = prev_key
                            lane._tapkey = None
                            continue
                        lane.key = prev_key
                        lane._tapkey = f"{prev_key}~f"  # ONE farewell
                        lane._farewelled = True
                        continue
                    if nk != prev_key and \
                            prev_key not in (None, "silence") and \
                            nk not in (None, "silence"):
                        # planner-intentional content interrupt: the
                        # debug overlay flashes this lane (director:
                        # 'whether the planner is shutting the drums
                        # down early, or something interrupted playback')
                        self._tap("music_int",
                                  f"{lname}:{prev_key}>{nk}", 1.0)
                    lane.key = nk
                    ng = gains[lname]
                    if ng < lane.gain and lane.gain > 0.1:
                        ng = max(ng, round(lane.gain * 0.65, 3))
                    lane.gain = ng
                    lane._tapkey = None
                detail = f"{self._form_idx % max(1, self.n_bars)}|" + \
                    "|".join(
                        f"{ln}:{getattr(la, '_tapkey', None) or la.key}"
                        f":{la.gain:.3f}"
                        for ln, la in sorted(self._lanes.items()))
                self._tap("music_bar", detail, 1.0)
            return
        master = self.bank.master_vol
        rc = getattr(self, "_riser_ch", None)
        if rc is not None:
            rc.set_volume(max(0.0, min(1.0,
                                       self._riser_gain * 0.85 * master)))
        # keep every lane's queue filled — a re-selection replaces a
        # pending chunk, so a mid-bar state change still lands exactly
        # on the next bar line; each lane keeps its own position
        sel = self._select_content()
        sel_raw = dict(sel)   # planner intent BEFORE the farewell glue
        # farewell-bar law (director 2026-07-16: no hard stops back to
        # calm): a lane whose content would cut to silence instead
        # plays ONE more bar of what it was playing, fading to nothing
        # across that bar -- the fade itself is the release
        for lname, lane in self._lanes.items():
            if sel.get(lname) == "silence" and \
                    lane.key not in (None, "silence"):
                if lname in CLEAN_EXIT_LANES:
                    continue                   # percussion stops clean
                if lane.fade_ticks > 0:
                    sel[lname] = lane.key      # farewell bar in flight
                elif lane.gain > 0.05:
                    sel[lname] = lane.key      # will start fading at
                    #                            the next boundary
        boundary = False
        for lname, lane in self._lanes.items():
            if lane.tickfill(sel[lname]) and lname == "bed":
                boundary = True
        # rotation-crossfade continuation: the previous bank's lanes
        # keep queueing their consecutive bars while their fade-out
        # runs; when the window closes they stop and are dropped
        if self._old_lanes:
            self._old_ttl -= 1
            for lane in self._old_lanes.values():
                if lane.key not in (None, "silence"):
                    lane.tickfill(lane.key)
                if lane.fade_ticks > 0:
                    lane.fade_ticks -= 1
                    f = lane.fade_ticks / max(1, lane.fade_total)
                    lane.ch.set_volume(max(0.0, lane.gain * master * f))
            if self._old_ttl <= 0:
                for lane in self._old_lanes.values():
                    try:
                        lane.ch.stop()
                    except Exception:
                        pass
                self._old_lanes = None
        # per-tick farewell fade-outs and arrival fade-ins
        bar_ticks = max(1, int(self.bar_s * TICKS_PER_S))
        for lane in self._lanes.values():
            if lane.fade_ticks > 0:
                lane.fade_ticks -= 1
                f = lane.fade_ticks / max(1, lane.fade_total)
                lane.ch.set_volume(max(0.0, lane.gain * master * f))
                if lane.fade_ticks == 0:
                    lane.gain = 0.0
            elif lane.fadein_ticks > 0:
                lane.fadein_ticks -= 1
                f = 1.0 - lane.fadein_ticks / max(1, lane.fadein_total)
                lane.ch.set_volume(max(0.0, lane.gain * master * f))
        if boundary:
            # a bar line just sounded: this is the ONLY place values are
            # applied and gains move (the audio is the clock)
            self._bar_idx += 1
            self._form_idx += 1
            self._boundary_tick = session.tick_count
            prev = self._applied
            self._applied = self.vals
            slam_bar = self._slam_now
            self._slam_now = False
            # (value-jump stings removed -- the riser one-shot owns
            # sudden rises and releases into its own sting)
            # BOSS RELEASE, reworked (director's ear over the judge,
            # F003993): a ONE-BAR COMEDOWN under the toll -- every
            # heavy lane plays one farewell bar fading to nothing.
            # The instant everything-stop "sounded like someone
            # accidentally hit NEXT on the music player".
            if self._applied[2] >= 0.75:
                self._boss_hot = True    # latch: see tick-path comment
            boss_release = self._boss_hot and self._applied[2] < 0.3
            if boss_release:
                self._boss_hot = False
                self._tap("music_rel", "boss_release", 1.0)
                self._sting_now(force=True)
            if self._applied != prev:
                p, c, d = self._applied
                self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
            # form steering: boss pull to PEAK / becalmed return
            steer = self._gate_jump(self._steer_form(),
                                    session.tick_count)
            if steer is not None:
                tgt, skind = steer
                self._form_idx = tgt
                if skind == "jump":
                    self._tap("music_jump", str(tgt), 1.0)
                else:
                    self._tap("music_jump", f"{tgt}~s", 1.0)
                for lname, lane in self._lanes.items():
                    lane.seek(tgt)
                    if skind == "jump" and lname not in ("holy", "bed"):
                        # arrival breath: a cross-section jump lands
                        # mid-phrase for composed voices; a same-
                        # section LOOP is a composed boundary and
                        # needs no fade. holy/bed are EXEMPT always:
                        # zeroing the chant for an arrival fade was the
                        # PRAYER hard-stop the director heard at
                        # F003993 -- the through-line never dips.
                        lane.fadein_ticks = bar_ticks
                        lane.fadein_total = bar_ticks
                        lane.ch.set_volume(0.0)   # no first-tick pop
            # boss stabs: a hit on the 4-bar grid while the boss lives
            # (dedicated stab sample -- the sting carries the BELL, and
            # a bell every 4 bars over a full mix read as sample spam)
            if self._applied[2] >= 0.88 and self._form_idx % 4 == 0:
                self._stab_now()
            gains = self._bar_gains()
            # dual-lead crossfade split (bar-stepped, equal power)
            wkey = sel.get("lead")
            ka, ga, kb, gb = self._lead_split(
                None if wkey in (None, "silence") else wkey,
                gains["lead"])
            gains["lead"] = ga
            gains["lead2"] = gb
            if "lead2" in self._lanes:
                sel["lead2"] = kb
                self._lanes["lead2"].tickfill(kb)
            if ka not in (None, "silence"):
                sel["lead"] = ka
                self._lanes["lead"].tickfill(ka)
            for lname, lane in self._lanes.items():
                g = gains[lname]
                if boss_release and lname in HEAVY_LANES and \
                        lname not in CLEAN_EXIT_LANES and \
                        lane.key not in (None, "silence") and \
                        lane.gain > 0.02 and lane.fade_ticks == 0:
                    lane.fade_ticks = bar_ticks    # one-bar comedown
                    lane.fade_total = bar_ticks
                    self._live[lname] = 0.0        # rebuild from silence
                    continue
                if lname in CLEAN_EXIT_LANES and \
                        sel_raw.get(lname) == "silence":
                    self._live[lname] = 0.0        # clean bar-line stop
                    lane.set_gain(0.0, master)
                    continue
                # LIVE dying gate now mirrors tick-clock exactly
                # (workflow review: the old g<=0.02 gate needed values
                # two orders of magnitude lower than the tick path's
                # selection gate -- recordings cut off cleanly where
                # live droned on at 0.05 forever): planner says
                # silence -> glide 0.65x/bar, farewell at <=0.15
                raw_silent = sel_raw.get(lname) == "silence" and \
                    lane.key not in (None, "silence")
                if raw_silent and lane.fade_ticks == 0:
                    if lane.gain > 0.15:
                        lane.set_gain(lane.gain * 0.65, master)
                        continue
                    lane.fade_ticks = bar_ticks    # the farewell bar
                    lane.fade_total = bar_ticks
                    continue                       # fade owns the volume
                if lane.fade_ticks == 0:
                    if g < lane.gain and lane.gain > 0.1:
                        g = max(g, lane.gain * 0.65)   # slow exhale on
                        #                                the way down
                    big_rise = g >= lane.gain + 0.4 and not slam_bar
                    lane.set_gain(g, master)
                    if big_rise:
                        # HALF-BAR COME-UP (director): even the slam
                        # gets a lead-up -- the wall lands within the
                        # bar, but never as a zero-width cliff
                        lane.fadein_ticks = bar_ticks // 2
                        lane.fadein_total = bar_ticks // 2
                        lane.ch.set_volume(0.0)
            # offline-reconstruction tap (mkvideo): the FULL per-bar
            # decision -- position + every lane's content and gain
            # ("~f" key suffix = this bar is a farewell fade-out)
            def _lk(ln, la):
                k = la.key
                if la.fade_ticks > 0:
                    return f"{k}~f", la.gain
                return k, la.gain
            parts = []
            for ln, la in sorted(self._lanes.items()):
                k, g = _lk(ln, la)
                parts.append(f"{ln}:{k}:{g:.3f}")
            detail = f"{self._form_idx % max(1, self.n_bars)}|" + \
                "|".join(parts)
            self._tap("music_bar", detail, 1.0)
        if len(self._bank_dirs) > 1:
            self._rotation_tick(boundary, session)

    # -- in-level bank rotation (live) ---------------------------------

    def _rotation_tick(self, boundary: bool, session) -> None:
        """Bar-line bank handoff with zero frame cost: the next bank
        decodes on a worker thread ~10 bars ahead, converts to Sounds
        one stem per tick, and the switch is a synchronized lane
        restart on the first boundary where everything is ready."""
        import threading
        if self._decode_thread is None and \
                self._bar_idx >= ROTATE_BARS - 10:
            nxt = self._bank_dirs[(self._bank_i + 1)
                                  % len(self._bank_dirs)]

            def _decode(dir_=nxt):
                try:
                    self._decoded = self._decode_bank(dir_)
                except Exception as exc:
                    print(f"[music] rotation decode failed: {exc}",
                          file=sys.stderr)
                    # full reset: retry on a later window instead of
                    # wedging rotation for the rest of the session
                    self._decoded = None
                    self._next_chunks = None
                    self._next_names = None
                    self._decode_thread = None
            self._decode_thread = threading.Thread(target=_decode,
                                                   daemon=True)
            self._decode_thread.start()
        if self._decoded and self._next_names:
            # convert ONE stem's bar segments per tick (main thread owns
            # pygame); ~26 stems finish well inside the 10-bar window
            import pygame
            name = self._next_names.pop()
            self._next_chunks[name] = [pygame.sndarray.make_sound(seg)
                                       for seg in self._decoded[name]]
        if boundary and self._bar_idx >= ROTATE_BARS and \
                self._decoded is not None and self._next_names is not None \
                and not self._next_names and \
                self._applied[0] >= 0.95 and \
                max(self._applied[1], self._applied[2]) <= 0.15:
            # once due, the handoff WAITS for ~100% PRAYER -- never
            # switch tracks when tension is high (director 2026-07-17)
            self._switch_bank(session)

    def _decode_bank(self, dir_) -> dict:
        """Worker-thread half: pure soundfile/numpy, no pygame."""
        import numpy as np
        import soundfile as sf
        n_bars = load_bank_meta(dir_).n_bars   # validated, no defaults
        files = {f.stem: f for f in sorted(dir_.glob("*.wav"))}
        for f in sorted(dir_.glob("*.ogg")):
            files.setdefault(f.stem, f)
        out: dict = {}
        bounds = None
        for name, fn in sorted(files.items()):
            if name in ("sting", "riser"):
                continue
            data, _sr = sf.read(str(fn), dtype="int16")
            if data.ndim == 1:
                data = np.stack([data, data], axis=1)
            if bounds is None:
                per = len(data) / max(1, n_bars)
                bounds = [int(round(k * per)) for k in range(n_bars)] \
                    + [len(data)]
            out[name] = [np.ascontiguousarray(data[bounds[k]:bounds[k + 1]])
                         for k in range(n_bars)]
        out["silence"] = [np.zeros((bounds[k + 1] - bounds[k], 2),
                                   dtype="int16") for k in range(n_bars)]
        out["__meta__"] = (dir_, n_bars)
        # signal the converter which stems remain (LIFO pop, main thread)
        self._next_chunks = {}
        self._next_names = [k for k in out if k != "__meta__"]
        return out

    def _switch_bank(self, session) -> None:
        """The handoff itself, on a just-sounded bar line: every lane
        restarts in the new bank's form at bar 0 -- a track change, on
        the grid, exactly like the chunk-queue promises."""
        import pygame
        dir_, n_bars = self._decoded["__meta__"]
        self._bank_i = self._bank_dirs.index(dir_)
        self.bank_dir = dir_
        self._meta = load_bank_meta(dir_)    # the NEW bank's form
        assert n_bars == self._meta.n_bars, (dir_, n_bars)
        self._form_idx = 0           # mirror the tick-clock handoff
        chunks = self._next_chunks
        lane_defs = {k: v for k, v in self._lane_defs(chunks).items()
                     if v is not None}
        master = self.bank.master_vol
        # ROTATION CROSSFADE (director: base-melody switches must not
        # hard cut): the OLD bank's lanes keep playing their
        # consecutive continuation on their own channels for
        # XFADE_BARS under a fade-out, while the NEW bank's lanes
        # start on the other channel set fading in. The offline mixer
        # synthesizes the identical overlap from the taps.
        xfade_ticks = int(XFADE_BARS * self.bar_s * TICKS_PER_S)
        for lane in self._lanes.values():
            if lane.key not in (None, "silence") and lane.gain > 0.001:
                lane.fade_ticks = xfade_ticks
                lane.fade_total = xfade_ticks
            else:
                try:
                    lane.ch.stop()
                except Exception:
                    pass
        self._old_lanes = self._lanes
        self._old_ttl = xfade_ticks
        new_base = 4 + MAX_LANES if self._lane_ch_base == 4 else 4
        self._lane_ch_base = new_base
        self._lanes = {}
        sel = self._select_content()   # note: sel from OLD lane set is
        #   rebuilt below once lanes exist (variants differ per bank)
        for i, (lname, variants) in enumerate(lane_defs.items()):
            lane = ChunkLane(pygame.mixer.Channel(new_base + i),
                             variants, n_bars)
            self._lanes[lname] = lane
        sel = self._select_content()
        gains = self._bar_gains()
        for lname, lane in self._lanes.items():
            lane.gain = gains[lname]
            lane.fadein_ticks = xfade_ticks   # ALL lanes fade in --
            lane.fadein_total = xfade_ticks   # the old through-line is
            #                                   still sounding beneath
            lane.start(sel[lname], master)
            lane.ch.set_volume(0.0)           # ramp owns the volume
        try:
            sting_f = next((dir_ / f"sting.{ext}"
                            for ext in ("wav", "ogg")
                            if (dir_ / f"sting.{ext}").exists()), None)
            self._sting = pygame.mixer.Sound(str(sting_f)) if sting_f \
                else None
            stab_f = next((dir_ / f"stab.{ext}"
                           for ext in ("wav", "ogg")
                           if (dir_ / f"stab.{ext}").exists()), None)
            self._stab = pygame.mixer.Sound(str(stab_f)) if stab_f \
                else None
            riser_fn = next((dir_ / f"riser.{e}" for e in ("wav", "ogg")
                             if (dir_ / f"riser.{e}").exists()), None)
            if riser_fn is not None and self._riser_ch is not None:
                self._riser_ch.stop()
                self._riser_snd = pygame.mixer.Sound(str(riser_fn))
                self._riser_ch.set_volume(0.0)
        except Exception as exc:
            print(f"[music] rotation sting/riser reload failed: {exc}",
                  file=sys.stderr)
        self._bar_idx = 0
        self._decoded = None
        self._next_chunks = None
        self._next_names = None
        self._decode_thread = None
        self._tap("music_bank", dir_.name, 1.0)

    def _update_legacy(self, session):
        bar = int((session.tick_count / TICKS_PER_S) / self.bar_s)
        if bar != self._last_bar:
            self._last_bar = bar
            self._boundary_tick = session.tick_count
            self._bar_idx = bar
            prev = self._applied
            self._applied = self.vals
            if self._applied != prev:
                p, c, d = self._applied
                self._tap("music_vals", f"{p:.3f},{c:.3f},{d:.3f}", 1.0)
        self._apply_legacy()

    def _stab_now(self):
        self._tap("music_stab", "stab", 1.0)
        if self._stab is not None and self._lanes:
            import pygame
            try:
                pygame.mixer.Channel(2).play(self._stab)
                pygame.mixer.Channel(2).set_volume(
                    0.7 * self.bank.master_vol)
            except Exception:
                pass

    def _sting_now(self, force: bool = False):
        # punctuation, not a metronome: the nonlinear spike-pass made
        # STING_RISE fire on every snapped wave (81 stings in a 259s
        # run). One sting per 8 bars -- except the boss-release toll,
        # which is the ending chord and always sounds.
        tick = self._boundary_tick
        if not force and tick - getattr(self, "_last_sting_tick",
                                        -99999) < \
                8 * self.bar_s * TICKS_PER_S:
            return
        self._last_sting_tick = tick
        self._tap("music_sting", "sting", 1.0)
        if self._sting is not None and (self._lanes or self._channels):
            import pygame
            try:
                pygame.mixer.Channel(3).play(self._sting)
                pygame.mixer.Channel(3).set_volume(
                    0.8 * self.bank.master_vol)
            except Exception:
                pass

    def stop(self):
        for lane in self._lanes.values():
            try:
                lane.ch.stop()
            except Exception:
                pass
        self._lanes.clear()
        if self._old_lanes:
            for lane in self._old_lanes.values():
                try:
                    lane.ch.stop()
                except Exception:
                    pass
            self._old_lanes = None
        if self._sting is not None or self._stab is not None:
            # silence in-flight sting/stab one-shots too (channels 2/3)
            try:
                import pygame
                pygame.mixer.Channel(2).stop()
                pygame.mixer.Channel(3).stop()
            except Exception:
                pass
        self._pending_sting = False
        self._riser_env = 0
        self._riser_gain = 0.0
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
