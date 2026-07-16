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

    def hop_distance(self, a, b):
        return abs(a - b)


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
    # corpus contract (2026-07-16): contempt is mowing HAPPENING -- kill
    # flow + trigger duty -- not trash merely standing there. Simulate
    # an active mow via the engine-EMA inputs values() consumes.
    enemies = {i: awake("husk") for i in range(6)}
    rooms = {i: 0 for i in range(6)}
    inp = read_inputs(make_session(enemies, rooms))
    inp.update(fire_duty=0.9, kill_rate=1.5, influx_rate=0.0)
    p, c, s = values(inp)
    assert c > 0.15, "mowing trash must read as contempt"
    assert s < 0.75, "trash is not the Test"


def test_heavies_raise_stalwart():
    enemies = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    p, c, s = vals_for(enemies, rooms)
    assert s > 0.55        # corpus weights: warden dominates, brutes
    assert s > c           # are slow and rate low against 5s damage


def test_adjacent_warden_is_nearly_coroom():
    # THE corpus surprise (2026-07-16): a hunting warden one room over
    # is ~73% of a co-room one; the old 0.35 discount was badly wrong
    rooms_co, rooms_adj = {1: 0}, {1: 1}
    _, _, s_co = vals_for({1: awake("warden")}, rooms_co)
    _, _, s_adj = vals_for({1: awake("warden")}, rooms_adj)
    assert s_adj > 0.6 * s_co
    assert s_adj < s_co


def test_stalwart_monotone_in_threat():
    rooms = {1: 0, 2: 0, 3: 0}
    _, _, s1 = vals_for({1: awake("brute")}, rooms)
    _, _, s2 = vals_for({1: awake("brute"), 2: awake("brute")}, rooms)
    _, _, s3 = vals_for({1: awake("brute"), 2: awake("brute"),
                         3: awake("warden")}, rooms)
    assert s1 < s2 < s3


def test_hurt_does_not_amplify_stalwart():
    # contract REVERSED by the corpus (2026-07-16): being hurt predicts
    # LESS future damage (hurt players play safe), so hp no longer
    # amplifies the danger read -- it only dampens contempt
    enemies = {1: awake("brute"), 2: awake("spitter")}
    rooms = {1: 0, 2: 0}
    _, _, s_healthy = vals_for(enemies, rooms, hp=100)
    _, _, s_hurt = vals_for(enemies, rooms, hp=20)
    assert abs(s_hurt - s_healthy) < 1e-9


def test_blends_are_native():
    # a mixed pack: heavies AND trash -> both values live at once
    enemies = {1: awake("brute"), 2: awake("brute"),
               3: awake("husk"), 4: awake("husk"), 5: awake("husk")}
    rooms = {i: 0 for i in enemies}
    inp = read_inputs(make_session(enemies, rooms))
    inp.update(fire_duty=0.8, kill_rate=1.0)
    p, c, s = values(inp)
    # threshold recalibrated 2026-07-17: firing no longer feeds danger
    # (firing -> CONTEMPT, danger -> STALWART), so the same pack reads
    # ~0.26 stalwart from the enemies alone -- the blend law is that
    # BOTH axes are live at once, not a specific magnitude
    assert s > 0.2 and c > 0.03, "blend must be expressible"


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
    assert inp["aggro"] == [("husk", 0)]   # (kind, hops)


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
    ms = MusicSystem(audio_bank=SimpleNamespace(_ready=False, master_vol=1.0, tap=None),
                     enabled=True)
    ms.update(make_session({}, {}, tick=1))
    assert ms._applied[0] == 1.0
    # a SMALL skirmish must persist through the one-bar tau...
    small = {1: awake("husk"), 2: awake("husk")}
    rooms2 = {1: 0, 2: 0}
    ms.update(make_session(small, rooms2, tick=2))
    assert ms.vals[2] < 0.15                 # low-pass: no instant wake
    assert ms._applied[2] < 0.15
    _sustain(ms, lambda k: make_session(small, rooms2, tick=3 + k),
             2 * ticks_per_bar())
    assert ms.vals[2] > 0.10                 # sustained fight registered


def test_massive_spike_passes_immediately():
    # the NONLINEAR filter (director's rule, task #34): a heavy wave
    # appearing at once snaps stalwart through the low-pass on the spot
    ms = MusicSystem(audio_bank=SimpleNamespace(_ready=False, master_vol=1.0, tap=None),
                     enabled=True)
    ms.update(make_session({}, {}, tick=1))
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    ms.update(make_session(heavy, rooms, tick=2))
    assert ms.vals[2] > 0.5, "a massive spike must pass immediately"


def test_hard_rise_stings():
    # new grammar (director 2026-07-17): a sudden heavy rise fires the
    # riser one-shot, whose release IS the sting -- within ~3 bars of
    # the wave appearing
    taps = []
    bank = SimpleNamespace(_ready=False, master_vol=1.0,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    ms = MusicSystem(audio_bank=bank, enabled=True)
    ms.update(make_session({}, {}, tick=1))
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    _sustain(ms, lambda k: make_session(heavy, rooms, tick=2 + k),
             3 * ticks_per_bar())
    assert any(k == "music_sting" for k, _ in taps)
    assert any(k == "music_vals" for k, _ in taps)


def test_riser_only_on_sudden_rise():
    # director 2026-07-17: risers fire ONLY on sudden intensity rises
    # -- a lurking flicker is a sustain and must NOT hold one up
    # (F002718: the 8-second flat pink-noise blast)
    taps = []
    bank = SimpleNamespace(_ready=False, master_vol=1.0,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    ms = MusicSystem(audio_bank=bank, enabled=True)
    lurk = {1: dict(kind="flicker", state="lurk")}
    ms.update(make_session(lurk, {1: 0}, tick=1))
    assert ms._riser_gain == 0.0
    # a heavy wave appearing at once IS sudden: a bounded one-shot arc
    heavy = {1: awake("brute"), 2: awake("brute"), 3: awake("warden")}
    rooms = {1: 0, 2: 0, 3: 0}
    ms.update(make_session(heavy, rooms, tick=2))
    assert ms._riser_env > 0
    peak_seen = 0.0
    for t in range(3, 3 + int(2.3 * ticks_per_bar())):
        ms.update(make_session(heavy, rooms, tick=t))
        peak_seen = max(peak_seen, ms._riser_gain)
    # the arc completed (no sustain) and released into the sting
    assert ms._riser_env == 0 and ms._riser_gain == 0.0
    assert peak_seen > 0.4
    assert any(k == "music_riser" and d == "0.00" for k, d in taps)
    assert any(k == "music_sting" for k, _ in taps)


def test_death_halts_music():
    # "the music is the Commando's thinking and feeling -- when he
    # dies, it dies" (director 2026-07-17)
    taps = []
    bank = SimpleNamespace(_ready=False, master_vol=1.0,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    ms = MusicSystem(audio_bank=bank, enabled=True)
    heavy = {1: awake("brute"), 2: awake("warden")}
    rooms = {1: 0, 2: 0}
    _sustain(ms, lambda k: make_session(heavy, rooms, tick=1 + k),
             ticks_per_bar())
    ms._started = True          # unit stand-in for a running mixer
    n_before = len(taps)
    ms.update(make_session(heavy, rooms, hp=0.0,
                           tick=1 + ticks_per_bar()))
    assert ("music_halt", "death") in taps[n_before:]
    assert ms._riser_gain == 0.0 and not ms._pending_sting
    # dead stays silent: no further taps of any kind
    n_halt = len(taps)
    ms.update(make_session(heavy, rooms, hp=0.0,
                           tick=2 + ticks_per_bar()))
    assert len(taps) == n_halt


def test_deterministic_tap_log():
    def run():
        taps = []
        bank = SimpleNamespace(_ready=False, master_vol=1.0,
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


# --- form/release grammar (tick-clock, real shipped bank) ---------------

def _rich_ms(taps):
    from pathlib import Path
    bank_dir = (Path(__file__).resolve().parents[1]
                / "assets/music/album_dies_irae")
    bank = SimpleNamespace(_ready=True, master_vol=1.0,
                           tap=lambda k, d, v, p: taps.append((k, d)))
    return MusicSystem(bank, enabled=True, bank_dirs=[bank_dir],
                       tick_clock=True)


def _drive(ms, vals, bars, t0):
    ms.override_vals = vals
    bar_ticks = int(ms.bar_s * TICKS_PER_S)
    t = t0
    for _ in range(bars * bar_ticks):
        t += 1
        ms.update(make_session({}, {}, tick=t))
    return t


def test_boss_release_is_one_bar_comedown():
    # F003993 (director 2026-07-17): the end of a boss fight is a
    # one-bar farewell fade under the toll -- never an instant
    # everything-stop -- and the chant NEVER stops
    taps = []
    ms = _rich_ms(taps)
    t = _drive(ms, (0.12, 0.6, 0.95), 8, 0)
    t = _drive(ms, (1.0, 0.0, 0.0), 4, t)
    assert any(k == "music_rel" for k, _ in taps)
    rel_i = next(i for i, (k, _) in enumerate(taps) if k == "music_rel")
    bar_after = next(d for k, d in taps[rel_i:] if k == "music_bar")
    assert "~f" in bar_after, "heavy lanes take a farewell bar"
    assert ">RELEASE" not in " ".join(
        d for k, d in taps if k == "music_int")
    for k, d in taps:
        if k != "music_bar":
            continue
        holy = next(p for p in d.split("|")[1:] if p.startswith("holy:"))
        _, key, gain = holy.rsplit(":", 2)
        assert key.startswith("prayer") and float(gain) > 0.3, \
            f"PRAYER never stops: {d}"


def test_combat_keeps_form_out_of_calm_sections():
    # F002291: mid-fight the form wrapped through outro into the
    # composed intro and the chant fell silent; combat must keep the
    # form inside entry/develop/peak
    taps = []
    ms = _rich_ms(taps)
    t = _drive(ms, (0.3, 0.55, 0.5), 44, 0)     # a long fight
    bars = [d for k, d in taps if k == "music_bar"]
    combat_ok = range(8, 32)                     # entry+develop+peak
    for d in bars[3:]:                           # skip the spin-up
        pos = int(d.split("|")[0])
        assert pos in combat_ok, f"form drifted to calm bar {pos}"
    # and deep calm comes home to the vigil once settled
    taps.clear()
    _drive(ms, (1.0, 0.0, 0.0), 24, t)
    last = [int(d.split("|")[0]) for k, d in taps if k == "music_bar"]
    assert any(p in range(0, 8) for p in last[-6:]), \
        "becalmed music returns to the vigil"


# --- unrepresentable-state contracts (director 2026-07-17) --------------

def _shipped(name="album_dies_irae"):
    from pathlib import Path
    return (Path(__file__).resolve().parents[1] / "assets/music" / name)


def test_bank_meta_is_read_only():
    # "situations like the clobbered section map should be rendered
    # unrepresentable": meta is one frozen value behind read-only
    # properties -- the historical `self.sections = []` clobber is now
    # an AttributeError at the assignment site
    import pytest
    taps = []
    ms = _rich_ms(taps)
    assert ms.sections, "rich bank must load a section map at init"
    for attr, val in (("sections", []), ("bar_s", 1.0), ("n_bars", 0)):
        with pytest.raises(AttributeError):
            setattr(ms, attr, val)


def test_all_shipped_banks_valid_and_tiled():
    from perihelion.music import shipped_banks, load_bank_meta
    banks = shipped_banks()
    assert banks, "no shipped banks found"
    for d in banks:
        meta = load_bank_meta(d)
        spans = sorted((a, b) for _s, a, b in meta.sections)
        assert spans[0][0] == 0 and spans[-1][1] == meta.n_bars, d.name
        for (a1, b1), (a2, b2) in zip(spans, spans[1:]):
            assert b1 == a2, f"{d.name}: gap/overlap at bar {b1}"


def test_bank_meta_missing_fields_raise(tmp_path):
    import json
    import pytest
    from perihelion.music import load_bank_meta
    (tmp_path / "bank.json").write_text(json.dumps(
        {"bpm": 110.0, "bars": 32}))          # no sections
    with pytest.raises(ValueError):
        load_bank_meta(tmp_path)
    (tmp_path / "bank.json").write_text(json.dumps(
        {"bars": 32, "sections": [["vigil", 0, 32]]}))   # no bpm
    with pytest.raises(ValueError):
        load_bank_meta(tmp_path)


def test_live_start_contract():
    # the regression net for the lead2 KeyError: a REAL rich-mixer
    # start under the dummy audio driver. Any exception propagates
    # (the blanket except that turned 'no music at all' into one
    # stderr line is gone) and every lane must come up selected.
    import os
    os.environ.setdefault("SDL_AUDIODRIVER", "dummy")
    os.environ.setdefault("SDL_VIDEODRIVER", "dummy")
    import pygame
    pygame.mixer.pre_init(44100, -16, 2)
    pygame.mixer.init()
    try:
        bank = SimpleNamespace(_ready=True, master_vol=1.0, tap=None)
        ms = MusicSystem(bank, enabled=True, bank_dirs=[_shipped()],
                         tick_clock=False)
        ms._ensure_started(0)
        assert ms._lanes, "rich live start must build lanes"
        assert "lead2" in ms._lanes
        for ln, lane in ms._lanes.items():
            assert lane.key is not None, f"lane {ln} never started"
        assert pygame.mixer.get_num_channels() >= 4 + len(ms._lanes) + 13
        ms.stop()
    finally:
        pygame.mixer.quit()
