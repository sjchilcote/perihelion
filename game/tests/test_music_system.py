"""Dynamic music engine — continuous-value properties.

Architecture per the director's ruling: NOT a state machine. PRAYER,
CONTEMPT, STALWART are 0-1 values from a heuristic battery; engine inputs
are the triple + level + weapon + aggro list.

Fail-first evidence (2026-07-13, per the fail-first law):
- bar quantization: mutating update() to apply values every tick makes
  test_application_only_at_bar_boundaries fail (verified, reverted).
- weak-swarm law: mutating WEAK husks' weight to 2.0 makes
  test_weak_swarm_is_contempt_not_stalwart fail (verified, reverted).
"""
from __future__ import annotations

from types import SimpleNamespace

from perihelion.music import (MusicSystem, values, read_inputs,
                              PRAYER_FLOOR, BAR_S, TICKS_PER_S, STING_RISE)


class FakeSim:
    def __init__(self, rooms):
        self._rooms = rooms

    def get_room(self, eid):
        return self._rooms[eid]


def make_session(enemies, rooms, hp=100.0, proom=0, tick=0):
    s = SimpleNamespace()
    s.enemies = enemies
    s.sim = FakeSim(rooms)
    s.hp = hp
    s.tick_count = tick
    s.player_room = lambda: proom
    return s


def awake(kind):
    return dict(kind=kind, state="hunt", trace_intensity=1.0)


def vals_for(enemies, rooms, hp=100.0):
    return values(read_inputs(make_session(enemies, rooms, hp=hp)))


# --- the heuristic battery ---------------------------------------------

def test_empty_room_is_full_prayer():
    p, c, s = vals_for({}, {})
    assert p == 1.0 and c == 0.0 and s < 0.15


def test_weak_swarm_is_contempt_not_stalwart():
    enemies = {i: awake("husk") for i in range(6)}
    rooms = {i: 0 for i in range(6)}
    p, c, s = vals_for(enemies, rooms)
    assert c > 0.5, "mowing trash must read as contempt"
    assert s < 0.6, "trash is not the Test"
    assert c > s


def test_heavies_raise_stalwart():
    enemies = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    p, c, s = vals_for(enemies, rooms)
    assert s > 0.7
    assert s > c


def test_stalwart_monotone_in_threat():
    rooms = {1: 0, 2: 0, 3: 0}
    _, _, s1 = vals_for({1: awake("brute")}, rooms)
    _, _, s2 = vals_for({1: awake("brute"), 2: awake("brute")}, rooms)
    _, _, s3 = vals_for({1: awake("brute"), 2: awake("brute"),
                         3: awake("warden")}, rooms)
    assert s1 < s2 < s3


def test_hurt_amplifies_stalwart():
    enemies = {1: awake("brute"), 2: awake("spitter")}
    rooms = {1: 0, 2: 0}
    _, _, s_healthy = vals_for(enemies, rooms, hp=100)
    _, _, s_hurt = vals_for(enemies, rooms, hp=20)
    assert s_hurt > s_healthy


def test_blends_are_native():
    # a mixed pack: heavies AND trash -> both values live at once
    enemies = {1: awake("brute"), 2: awake("brute"),
               3: awake("husk"), 4: awake("husk"), 5: awake("husk")}
    rooms = {i: 0 for i in enemies}
    p, c, s = vals_for(enemies, rooms)
    assert s > 0.4 and c > 0.05, "blend must be expressible"


def test_prayer_floor_never_breaks():
    enemies = {i: awake("warden") for i in range(8)}
    rooms = {i: 0 for i in range(8)}
    p, _, _ = vals_for(enemies, rooms, hp=5)
    assert p == PRAYER_FLOOR, "the urgency pulse never fully stops"


def test_lurking_flicker_is_tension_not_aggro():
    enemies = {1: dict(kind="flicker", state="lurk")}
    rooms = {1: 0}
    inp = read_inputs(make_session(enemies, rooms))
    assert inp["aggro"] == []
    assert inp["tension"] > 0.0


def test_engine_inputs_complete():
    # the director's input tuple: triple + level + weapon + aggro list
    s = make_session({1: awake("husk")}, {1: 0})
    s.level_name = "l08"
    s.weapon = "shotgun"
    inp = read_inputs(s)
    assert inp["level"] == "l08"
    assert inp["weapon"] == "shotgun"
    assert inp["aggro"] == [("husk", True)]


# --- musical application ------------------------------------------------

def ticks_per_bar():
    return int(BAR_S * TICKS_PER_S) + 1


def _sustain(ms, session_fn, ticks):
    for k in range(ticks):
        ms.update(session_fn(k))


def test_application_only_at_bar_boundaries():
    # contract update 2026-07-16 (director): values are LOW-PASSED with
    # a one-bar tau — the music must not wake for a fight shorter than a
    # bar; SUSTAINED threat drives application
    ms = MusicSystem(audio_bank=SimpleNamespace(_ready=False, tap=None),
                     enabled=True)
    ms.update(make_session({}, {}, tick=1))
    assert ms._applied[0] == 1.0
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    ms.update(make_session(heavy, rooms, tick=2))
    assert ms.vals[2] < 0.15                 # low-pass: no instant wake
    assert ms._applied[2] < 0.15
    # sustain the fight for two bars of ticks -> value risen + applied
    _sustain(ms, lambda k: make_session(heavy, rooms, tick=3 + k),
             2 * ticks_per_bar())
    assert ms.vals[2] > 0.5                  # sustained fight registered
    assert ms._applied[2] > 0.5              # and applied at a bar line


def test_hard_rise_stings():
    taps = []
    bank = SimpleNamespace(_ready=False,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    ms = MusicSystem(audio_bank=bank, enabled=True)
    ms.update(make_session({}, {}, tick=1))
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    # a SUSTAINED heavy assault still stings within ~2 bars (the smoothed
    # rise crosses STING_RISE across a bar boundary)
    _sustain(ms, lambda k: make_session(heavy, rooms, tick=2 + k),
             2 * ticks_per_bar())
    assert any(k == "music_sting" for k, _ in taps)
    assert any(k == "music_vals" for k, _ in taps)


def test_riser_releases_with_sting():
    taps = []
    bank = SimpleNamespace(_ready=False,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    ms = MusicSystem(audio_bank=bank, enabled=True)
    lurk = {1: dict(kind="flicker", state="lurk")}
    rooms = {1: 0}
    ms.update(make_session(lurk, rooms, tick=1))
    assert ms._riser_gain > 0.0
    # pounce clearly mid-8th (an 8th is ~12.9 ticks at 140bpm; tick 6 is
    # ~5 ticks past the tick-1 bar line, outside the on-grid window)
    pounce = {1: dict(kind="flicker", state="hunt")}
    ms.update(make_session(pounce, rooms, tick=6))
    assert ms._riser_gain == 0.0
    # the sting is QUANTIZED: it must NOT fire mid-air, and must land
    # within the next 8th-note of the bar grid
    assert not any(k == "music_sting" for k, _ in taps)
    eighth_ticks = int(round(60.0 * ms.bar_s / 8.0)) + 1
    for t in range(7, 7 + eighth_ticks):
        ms.update(make_session(pounce, rooms, tick=t))
    assert any(k == "music_sting" for k, _ in taps)


def test_deterministic_tap_log():
    def run():
        taps = []
        bank = SimpleNamespace(_ready=False,
                               tap=lambda k, d, v, p: taps.append((k, d, v)))
        ms = MusicSystem(audio_bank=bank, enabled=True)
        heavy = {1: awake("brute"), 2: awake("warden")}
        rooms = {1: 0, 2: 0}
        t = 0
        for step in range(6):
            t += ticks_per_bar() if step % 2 else 7
            ms.update(make_session(heavy if step in (1, 2, 3) else {},
                                   rooms, tick=t))
        return taps
    assert run() == run()
