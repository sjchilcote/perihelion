"""Dynamic music system — classifier + state machine properties.

Fail-first evidence (2026-07-13, recorded here per the fail-first law):
- bar-quantization: with `new_bar` forced True every update (mutation),
  test_state_changes_only_at_bar_boundaries fails (state flips mid-bar).
- hysteresis: with DOWNSHIFT_CLEAN_BARS mutated to 0, the flap test fails
  (state chatters on alternating threat).
- contempt-not-stalwart: with THREAT weights mutated so husk=2.0, the
  weak-swarm test fails (a trash mob would read as the Test).
All mutations reverted; tests green against the real module.
"""
from __future__ import annotations

from types import SimpleNamespace

from perihelion.music import (MusicSystem, classify, GAINS,
                              DOWNSHIFT_CLEAN_BARS, BAR_S, TICKS_PER_S)


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


# --- classifier -------------------------------------------------------

def test_weak_swarm_is_contempt_not_stalwart():
    # six husks in the player's room: trash, not the Test (emotional spec:
    # "many weak enemies is still CONTEMPT")
    enemies = {i: awake("husk") for i in range(6)}
    rooms = {i: 0 for i in range(6)}
    state, _ = classify(make_session(enemies, rooms))
    assert state == "contempt"


def test_heavies_are_stalwart():
    enemies = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    state, _ = classify(make_session(enemies, rooms))
    assert state == "stalwart"


def test_hurt_and_pressed_is_stalwart():
    enemies = {1: awake("brute")}
    rooms = {1: 0}
    state, _ = classify(make_session(enemies, rooms, hp=20.0))
    assert state == "stalwart"


def test_idle_enemies_are_prayer():
    enemies = {1: dict(kind="brute", state="idle"),
               2: dict(kind="husk", state="waking")}
    rooms = {1: 0, 2: 0}
    state, tension = classify(make_session(enemies, rooms))
    assert state == "prayer" and tension == 0.0


def test_lurking_flicker_is_tension_not_threat():
    enemies = {1: dict(kind="flicker", state="lurk")}
    rooms = {1: 0}
    state, tension = classify(make_session(enemies, rooms))
    assert state == "prayer"
    assert tension > 0.0


def test_other_room_threat_discounted():
    # one brute in another room: awake but elsewhere -> contempt-level
    enemies = {1: awake("brute"), 2: awake("brute"), 3: awake("brute")}
    rooms = {1: 5, 2: 5, 3: 5}
    state, _ = classify(make_session(enemies, rooms))
    assert state == "contempt"


# --- state machine ----------------------------------------------------

def ticks_per_bar():
    return int(BAR_S * TICKS_PER_S) + 1


def run_updates(ms, sessions):
    for s in sessions:
        ms.update(s)


def test_state_changes_only_at_bar_boundaries():
    ms = MusicSystem(audio_bank=SimpleNamespace(_ready=False, tap=None),
                     enabled=True)
    calm = make_session({}, {}, tick=1)
    ms.update(calm)
    assert ms.state == "prayer"
    # threat appears mid-bar: state must NOT flip until the next bar tick
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    mid = make_session(heavy, rooms, tick=2)
    ms.update(mid)
    assert ms.state == "prayer"          # pending, not applied
    nxt = make_session(heavy, rooms, tick=ticks_per_bar())
    ms.update(nxt)
    assert ms.state == "stalwart"        # applied at the bar line


def test_downshift_needs_clean_bars():
    ms = MusicSystem(audio_bank=SimpleNamespace(_ready=False, tap=None),
                     enabled=True)
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    t = 1
    ms.update(make_session(heavy, rooms, tick=t))
    t = ticks_per_bar()
    ms.update(make_session(heavy, rooms, tick=t))
    assert ms.state == "stalwart"
    # threat gone: one bar of calm is NOT enough
    t += ticks_per_bar()
    ms.update(make_session({}, {}, tick=t))
    assert ms.state == "stalwart"
    for _ in range(DOWNSHIFT_CLEAN_BARS + 1):
        t += ticks_per_bar()
        ms.update(make_session({}, {}, tick=t))
    assert ms.state == "prayer"


def test_chant_continuity_gains():
    # the chants persist under contempt (director: "without losing the
    # chants"); prayer stem keeps nonzero gain in the contempt table
    assert GAINS["contempt"]["prayer"] > 0.0
    # and the cantus firmus survives the peak: contempt layer stays under
    # stalwart rather than everything-but-one-stem going silent
    assert GAINS["stalwart"]["contempt"] > 0.0


def test_riser_releases_with_sting():
    taps = []
    bank = SimpleNamespace(_ready=False,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    ms = MusicSystem(audio_bank=bank, enabled=True)
    lurk = {1: dict(kind="flicker", state="lurk")}
    rooms = {1: 0}
    ms.update(make_session(lurk, rooms, tick=1))
    assert ms._riser_gain > 0.0
    # the flicker commits: lurking ends, threat appears -> riser drops,
    # sting fires
    pounce = {1: dict(kind="flicker", state="hunt")}
    ms.update(make_session(pounce, rooms, tick=2))
    assert ms._riser_gain == 0.0
    assert any(k == "music_sting" for k, _ in taps)


def test_deterministic_tap_log():
    def run():
        taps = []
        bank = SimpleNamespace(_ready=False,
                               tap=lambda k, d, v, p: taps.append((k, d, v)))
        ms = MusicSystem(audio_bank=bank, enabled=True)
        heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
        rooms = {1: 0, 2: 0, 3: 0}
        t = 0
        for step in range(6):
            t += ticks_per_bar() if step % 2 else 7
            s = make_session(heavy if step in (1, 2, 3) else {}, rooms,
                             tick=t)
            ms.update(s)
        return taps
    assert run() == run()
