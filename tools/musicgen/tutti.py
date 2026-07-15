"""The tutti — one COMPLETE track per STEM_COMPOSITION_DESIGN.

    uv run python tools/musicgen/tutti.py [melody] [out.wav]

Through-composed form (the design's section ladder), every voice from
the director-approved cast: Delay Lama monk, TR-909, chug wall, and the
Vital picks (vital_bank.SLOTS). Harmony from harmony.py progressions;
riffs from riffs.py; the album's stage (wall wide L/R, spine center,
holy wet), pump, binary transitions with authored fills.

Form (110 bpm):
  S1 vigil     8 bars  bed + monk statement (sanctuary) + bells
  S2 entry     8 bars  fill -> half-time drums + wall/bass on 'pressure'
                       + monk held above + defiant organ answers
  S3 develop   8 bars  'swagger' groove: FM bass + lead fragments +
                       busier kit; monk rests (lead carries the tune)
  S4 peak      8 bars  riser -> sting -> 'ratchet' tutti: everything,
                       choir above, lunge bar of aimed dissonance
  S5 outro     4 bars  vacuum: bed + monk tail + bell, ring out

The judge loop (director's directive 2026-07-15): pro-tier Gemini on
the COMPLETE track, "1-10, finished professional piece evoking the
brief? what gaps remain" — iterate on the gaps, nothing locked down.
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))

import generate_bank as G          # noqa: E402
import gordon_chain as gc          # noqa: E402
import harmony                     # noqa: E402
import riffs                       # noqa: E402
import tr909_kit as K              # noqa: E402
import vital_bank as VB            # noqa: E402
import voices                      # noqa: E402
from parts import bell_hit         # noqa: E402

SR = 44100
BPM = 110.0
BAR = 240.0 / BPM
STEP = BAR / 16

# form: (name, bars, progression)
FORM = [("vigil", 8, "vigil"), ("entry", 8, "pressure"),
        ("develop", 8, "swagger"), ("peak", 8, "ratchet"),
        ("outro", 4, "vigil")]


def sec_time(i):
    t = sum(b for _, b, _ in FORM[:i]) * BAR
    return t


def place(buf, x, t_s, g=1.0):
    i = int(t_s * SR)
    if 0 <= i < len(buf):
        seg = x[:len(buf) - i]
        buf[i:i + len(seg)] += seg * g


def drum_bus(d):
    """The album's drum-bus decay signature (v2, judge gaps: thin/dry):
    parallel saturation for weight, subtle bitcrush, short metallic
    space, gentle low emphasis."""
    import synth as sy
    par = np.tanh(d * 4.0)                        # parallel weight
    crush = sy.bitcrush(d, bits=10, rate_divisor=3) * 0.5
    room = gc._spring_reverb(d, mix=1.0) * 0.22   # metallic space
    y = d * 0.9 + par * 0.8 + crush + room
    return y / (np.abs(y).max() + 1e-9) * np.abs(d).max() * 1.15


def _knock():
    m = int(0.28 * SR)
    ph = 2 * np.pi * (52 - 14 * np.arange(m) / m) * np.arange(m) / SR
    return np.sin(np.cumsum(np.diff(ph, prepend=0))) \
        * np.exp(-np.arange(m) / (0.09 * SR))


def drums_half(n_bars, rng, fills_at=()):
    d = np.zeros(int(n_bars * BAR * SR) + SR)
    kick = K.kick_knob(25, 25, 50)
    kick = kick + np.pad(_knock() * 0.9, (0, max(0, len(kick) - int(0.28 * SR))))[:len(kick)]
    for bar in range(n_bars):
        if bar in fills_at:                      # authored fill bar
            for pos in range(8, 16):
                v = 0.4 + 0.6 * (pos - 8) / 7    # crescendo roll
                K.place(d, K.hit("snare", v, rng), bar * BAR + pos * STEP)
            K.place(d, kick, bar * BAR)
            continue
        for pos, vel, inst in [(0, 1.0, "kick"), (8, .95, "snare"),
                               (4, .85, "kick"), (12, .5, "kick")]:
            x = kick * (0.6 + 0.4 * vel) if inst == "kick" \
                else K.hit("snare", vel, rng)
            K.place(d, x, bar * BAR + pos * STEP)
        for pos in range(0, 16, 2):
            acc = .75 if pos % 8 == 4 else (.5 if pos % 4 == 0 else .35)
            acc *= 1 + rng.normal(0, 0.12)        # hat life (judge gap)
            K.place(d, K.hit("chh", max(.15, acc), rng),
                    bar * BAR + pos * STEP)
        if bar % 2 == 1:
            K.place(d, K.hit("ohh", .7, rng), bar * BAR + 14 * STEP)
        if bar % 4 == 2:                          # syncopated kick var
            K.place(d, K.kick_knob(25, 25, 25) * .7,
                    bar * BAR + 10 * STEP)
        if bar >= n_bars // 2:                    # back-half: metal ride
            import synth as sy
            for pos in (2, 6, 10, 14):
                r_hit = sy.bitcrush(K.hit("ride", .5, rng), bits=9)
                K.place(d, r_hit * .5, bar * BAR + pos * STEP)
    return d


def drums_groove(n_bars, rng, fills_at=()):
    d = np.zeros(int(n_bars * BAR * SR) + SR)
    kick = K.kick_knob(25, 25, 25)
    for bar in range(n_bars):
        if bar in fills_at:
            for pos in range(0, 16, 2):
                v = 0.35 + 0.65 * pos / 15
                K.place(d, K.hit("snare", v, rng), bar * BAR + pos * STEP)
            continue
        for pos in (0, 4, 8, 12):
            K.place(d, kick, bar * BAR + pos * STEP)
        for pos in (4, 12):
            K.place(d, K.hit("clap", .8, rng), bar * BAR + pos * STEP)
        for pos in range(16):
            acc = .6 if pos % 4 == 2 else .3
            K.place(d, K.hit("chh", acc, rng), bar * BAR + pos * STEP)
    return d


def wall_take(riff, seed, drive):
    """SYNTH wall (director: chug samples scuffed): the riff through a
    Vital voice into the guitar amp+cab chain. Double-track realism =
    per-take micro-offsets (a second performance), not jitter within
    the groove's feel."""
    import synth as sy
    rng = np.random.default_rng(seed)
    seq = []
    t = 0
    for p, steps, art in riff:
        off = float(rng.normal(0, 0.004)) if seed != 11 else 0.0
        if art == "open":
            for iv, vv in ((12, 118), (19, 104), (24, 88)):
                seq.append((38 + p + iv, max(0.0, t * STEP + off),
                            STEP * steps * 1.6, vv))
        else:
            seq.append((38 + p, max(0.0, t * STEP + off),
                        STEP * 0.9, 96 if t % 16 else 118))
        t += steps
    total = t * STEP
    out = VB.render_seq(*VB.SLOTS["wall"], seq, total, 0.4)
    out = voices.amp(out * 0.6 / (np.abs(out).max() + 1e-9), drive)
    return sy.highpass(out, 120)


def _sub_layer(seq, total_s):
    """Saturated sine sub tracking the bass gates (judge gap: layer
    distorted sub under the weak synth bass)."""
    n = int((total_s + 0.5) * SR)
    out = np.zeros(n)
    for note, t0, d, v in seq:
        f = 440.0 * 2 ** ((note - 12 - 69) / 12.0)
        m = int(d * SR)
        ph = 2 * np.pi * f * np.arange(m) / SR
        env = np.minimum(1, np.arange(m) / (0.005 * SR)) * \
            np.minimum(1, (m - np.arange(m)) / (0.02 * SR))
        place(out, np.tanh(np.sin(ph) * 2.0) * env * (v / 127), t0)
    return out


def vb_seq(slot, seq, total, tail=1.0):
    x = VB.render_seq(*VB.SLOTS[slot], seq, total, tail)
    return x / (np.abs(x).max() + 1e-9)


def _pre_drop_vacuum(bufs, t_s, dur_s=0.55):
    """Duck-to-floor, NOT silence (director: full silence reads as the
    game hitching; the drone spine below survives untouched)."""
    a = int((t_s - dur_s) * SR)
    b = int(t_s * SR)
    fade = np.linspace(1, 0.12, 2000)
    for buf in bufs:
        if 0 <= a < b <= len(buf):
            buf[a - 2000:a] *= fade
            buf[a:b] *= 0.12


def _boundary_tell(C, t_s, rng):
    """The album's seam grammar: a riser that EXITS at the boundary +
    an impact ON it (judge gap: transitions abrupt at every seam)."""
    import synth as sy
    rn = int(1.0 * BAR * SR)
    riser = sy.pink_noise(1.0 * BAR, seed=int(t_s))[:rn] \
        * np.linspace(0.05, 0.9, rn) ** 2
    place(C, sy.highpass(riser, 800) * 0.7, t_s - BAR)
    rev = G.hall(K.hit("crash", 0.8, rng), 1.5).T.mean(axis=1)[::-1]
    place(C, rev[-int(BAR * SR):] * 0.6, t_s - BAR)   # reverse-verb whoosh
    place(C, K.hit("crash", 0.85, rng), t_s, 0.9)
    boom = np.sin(2 * np.pi * 55 * np.arange(int(0.5 * SR)) / SR) \
        * np.exp(-np.arange(int(0.5 * SR)) / (0.12 * SR))
    place(C, boom * 0.9, t_s)


def compose(mel_name: str):
    events = G.MELODIES[mel_name]
    rng = np.random.default_rng(7)
    total_s = sec_time(len(FORM)) + 6.0
    n = int(total_s * SR)
    L = np.zeros(n)
    R = np.zeros(n)
    C = np.zeros(n)                    # mono spine, added to both

    chant_step = 60.0 / 72.0 / 4

    # ---- S1 vigil: bed + monk + bells --------------------------------
    t1 = sec_time(0)
    bed = vb_seq("bed_t2", [(36, 0.0, 16 * BAR, 100),
                            (24, 0.0, 16 * BAR, 90)], 16 * BAR, 0.0)
    duck_env = np.ones(len(bed))
    duck_env[int(8 * BAR * SR):] = 0.45           # bed yields to the band
    place(C, bed * 0.30 * duck_env, t1)
    vows = [None if p is None else (-0.5 if d >= 8 else 0.2)
            for p, d in events]
    monk = G.render_vocal(events, chant_step, base_midi=50, vowels=vows)
    monk /= np.abs(monk).max() + 1e-9
    import synth as sy
    harsh = sy.highpass(sy.lowpass(monk, 4500), 1800)
    monk = monk - 0.8 * harsh                     # tame the pierce
    import synth as sy2
    monk = sy2.lowpass(monk, 5000)                # dark, never harsh
    monk_wet = G.hall(monk, 2.4).T.mean(axis=1)   # deep in the hall
    place(C, monk_wet * 0.5, t1 + BAR)            # spice, not lead
    head = [(pp, d) for pp, d in events if pp is not None][:8]
    cs1 = []
    tt = BAR
    for pp, d in head:
        cs1.append((62 + pp, tt, d * chant_step * 1.1, 96))
        tt += d * chant_step
    ch1 = vb_seq("choir", cs1, 16 * BAR, 1.5)
    place(C, G.hall(ch1, 1.6).T.mean(axis=1) * 0.45, t1)
    bells = np.zeros(int(8 * BAR * SR))
    place(bells, bell_hit(0.6), 2 * BAR)
    place(bells, bell_hit(0.4), 6 * BAR)
    place(C, G.hall(bells, 1.4).T.mean(axis=1) * 0.5, t1)

    # ---- S2 entry: fill -> band on 'pressure', monk above -------------
    t2 = sec_time(1)
    _boundary_tell(C, t2, rng)
    fill = drums_half(1, rng, fills_at=(0,))
    place(C, drum_bus(fill) * 0.7, t2 - BAR)                  # the lead-in bar
    dh = drums_half(8, rng)
    place(C, drum_bus(dh) * 0.7, t2)
    roots = harmony.roots_16("pressure", 8)
    riff = riffs.riff_16(events, n_bars=8, accents=riffs.ACCENTS_A,
                         chord_roots=roots)
    wl = wall_take(riff, 11, 18.0)
    wr = wall_take(riff, 22, 19.0)
    wl = gc.sidechain_duck(wl, dh[:len(wl)], amount=0.35, release_s=0.1)
    wr = gc.sidechain_duck(wr, dh[:len(wr)], amount=0.35, release_s=0.1)
    place(L, wl * 0.7, t2)
    place(R, wr * 0.7, t2)
    bseq = []
    t = 0
    for pp, steps, art in riff:
        bseq.append((26 + pp, t * STEP, STEP * steps *
                     (0.92 if art == "mute" else 1.6),
                     118 if art == "open" else 96))
        t += steps
    import synth as sy
    bass = sy.highpass(vb_seq("bass_deep", bseq, 8 * BAR, 0.4), 90)
    sub = sy.lowpass(_sub_layer(bseq, 8 * BAR), 90)
    m = min(len(bass), len(sub))
    bass = bass[:m] + sub[:m] * 0.55
    bass = gc.sidechain_duck(bass, dh[:len(bass)], amount=0.45,
                             release_s=0.12)
    place(C, bass * 0.85, t2)
    # monk continues over the band (started in S1, runs ~27s = into S2)
    # defiant organ answers in the chant's long rests (S2 only)
    ans = riffs.lead_phrase([(p, d) for p, d in events if p is not None][:6],
                            factor=2)
    oseq = []
    t = 6 * BAR                # answer AFTER the chant's line ends
    #                           (judge: mid-range clash ~0:50)
    for p, d in ans:
        oseq.append((50 + p, t, d * STEP * 1.2, 110))
        t += d * STEP
    organ = vb_seq("organ_defiant", oseq, 8 * BAR, 0.5)
    organ = gc.sidechain_duck(organ, dh[:len(organ)], amount=0.3,
                              release_s=0.1)
    place(C, organ * 0.4, t2)

    # ---- S3 develop: swagger groove, lead carries fragments -----------
    t3 = sec_time(2)
    _boundary_tell(C, t3, rng)
    dg = drums_groove(8, rng, fills_at=(7,))
    place(C, drum_bus(dg) * 0.7, t3)
    roots3 = harmony.roots_16("swagger", 8)
    r3 = riffs.riff_16(events, n_bars=8, accents=riffs.ACCENTS_B,
                       chord_roots=roots3)
    fseq = []
    t = 0
    for pp, steps, art in r3:
        fseq.append((38 + pp, t * STEP, STEP * steps * 0.9,
                     116 if art == "open" else 92))
        t += steps
    fm = vb_seq("bass_fm", fseq, 8 * BAR, 0.3)
    fm = gc.sidechain_duck(fm, dg[:len(fm)], amount=0.4, release_s=0.1)
    place(C, fm * 0.6, t3)
    frag = riffs.lead_phrase(
        [(p, d) for p, d in events if p is not None][:8], factor=2)
    lseq = []
    t = 0.0
    for k in range(2):                              # stated twice
        tt = k * 4 * BAR
        t = tt
        for p, d in frag:
            lseq.append((62 + p, t, (d + 0.5) * STEP, 108))
            t += d * STEP
    lead = vb_seq("lead_rail", lseq, 8 * BAR, 0.5)
    lead = gc.sidechain_duck(lead, dg[:len(lead)], amount=0.3,
                             release_s=0.1)
    place(C, lead * 0.5, t3)
    # the church NEVER leaves (judge: S3 'loses the motif'; the album
    # holds the chant ~84% of runtime): distant choir pedal + a monk
    # phrase echoing far back in the hall
    c3 = vb_seq("choir", [(50, 0.0, 8 * BAR, 90), (57, 0.0, 8 * BAR, 84)],
                8 * BAR, 1.0)
    c3 = G.hall(c3, 1.8).T.mean(axis=1)
    c3 = gc.sidechain_duck(c3, dg[:len(c3)], amount=0.5, release_s=0.1)
    place(C, c3 * 0.3, t3)
    monk_far = G.hall(monk[:int(10 * chant_step * 16 * SR)], 2.5).T.mean(axis=1)
    place(C, monk_far * 0.35, t3 + 3 * BAR)

    # ---- riser into the peak ------------------------------------------
    import synth as sy
    rn = int(2 * BAR * SR)
    riser = sy.pink_noise(2 * BAR, seed=3)[:rn] * np.linspace(0.1, 1, rn) ** 2
    place(C, riser * 0.5, sec_time(3) - 2 * BAR)

    # ---- S4 peak: ratchet tutti ----------------------------------------
    t4 = sec_time(3)
    sting = np.zeros(int(2 * BAR * SR))
    place(sting, K.hit("crash", 1.0, rng), 0)
    place(sting, bell_hit(1.0), 0)
    place(C, sting * 0.8, t4)
    dh4 = drums_half(8, rng, fills_at=(7,))
    place(C, drum_bus(dh4) * 0.75, t4)
    roots4 = harmony.roots_16("ratchet", 8)
    # lunge bar: bar 6 of the peak spends the tritone
    lunge = harmony.roots_16("lunge", 2)
    roots4[6 * 16:8 * 16] = lunge
    r4 = riffs.riff_16(events, n_bars=8, accents=riffs.ACCENTS_C,
                       chord_roots=roots4)
    wl4 = wall_take(r4, 33, 20.0)
    wr4 = wall_take(r4, 44, 21.0)
    wl4 = gc.sidechain_duck(wl4, dh4[:len(wl4)], amount=0.35, release_s=0.1)
    wr4 = gc.sidechain_duck(wr4, dh4[:len(wr4)], amount=0.35, release_s=0.1)
    place(L, wl4 * 0.8, t4)
    place(R, wr4 * 0.8, t4)
    b4 = []
    t = 0
    for pp, steps, art in r4:
        b4.append((26 + pp, t * STEP, STEP * steps *
                   (0.92 if art == "mute" else 1.6),
                   120 if art == "open" else 100))
        t += steps
    bass4 = sy.highpass(vb_seq("bass_deep", b4, 8 * BAR, 0.4), 90)
    sub4 = sy.lowpass(_sub_layer(b4, 8 * BAR), 90)
    m4 = min(len(bass4), len(sub4))
    bass4 = bass4[:m4] + sub4[:m4] * 0.6
    bass4 = gc.sidechain_duck(bass4, dh4[:len(bass4)], amount=0.45,
                              release_s=0.12)
    place(C, bass4 * 0.95, t4)
    # choir + monk held above the peak (melody-continuity law)
    cseq = []
    for bar in range(8):
        root = roots4[bar * 16]
        for nn in (62 + root, 69 + root):
            cseq.append((nn, bar * BAR, BAR * 0.97, 100))
    choir = vb_seq("choir", cseq, 8 * BAR, 1.0)
    choir_wet = G.hall(choir, 1.3).T.mean(axis=1)
    choir_wet = sy.highpass(choir_wet, 300)
    choir_wet = gc.sidechain_duck(choir_wet, dh4[:len(choir_wet)],
                                  amount=0.5, release_s=0.12)
    place(C, choir_wet * 0.5, t4)
    monk2 = G.hall(monk, 2.0).T.mean(axis=1)      # distant even at peak
    monk2 = gc.sidechain_duck(monk2, dh4[:len(monk2)],
                              amount=0.5, release_s=0.12)
    place(C, monk2 * 0.4, t4)

    # ---- S5 outro: vacuum + ring --------------------------------------
    t5 = sec_time(4)
    place(C, K.hit("crash", 0.9, rng), t5)        # choke into the vacuum
    bed5 = vb_seq("bed_t2", [(36, 0.0, 5 * BAR, 90)], 5 * BAR, 0.0)
    place(C, bed5 * 0.3, t5)
    place(C, G.hall(np.concatenate([bell_hit(0.7),
                                    np.zeros(int(BAR * SR))]),
                    1.5).T.mean(axis=1) * 0.5, t5)

    # pre-drop vacuums duck to the floor before the two big drops
    _pre_drop_vacuum([L, R, C], sec_time(1))
    _pre_drop_vacuum([L, R, C], sec_time(3))

    # ---- drone spine: a different texture per section (director:
    # "experiment with drone textures... a lot of dynamic character
    # for cheap"), from the picks' measured top sustainers; survives
    # every vacuum -----------------------------------------------------
    import synth as sy3
    SPINE = [("tngkaos", "Daphne Oram 2", 36, 0.20),
             ("5years", "Faulty Connection", 24, 0.16),
             ("5years", "Taiga", 36, 0.14),
             ("5years", "St. George", 24, 0.18),
             ("tngkaos", "Ether", 36, 0.20)]
    D = np.zeros(n)
    for i, (bank, stem, note, gain) in enumerate(SPINE):
        bars = FORM[i][1]
        dur = bars * BAR
        y = VB.render_seq(bank, stem, [(note, 0.0, dur, 96)],
                          dur, tail_s=1.0)
        y = sy3.lowpass(y / (np.abs(y).max() + 1e-9), 1800)
        e = int(0.4 * SR)
        y[:e] *= np.linspace(0, 1, e)
        place(D, y * gain, sec_time(i))
    C = C + D

    # ---- master: cohesive space (judge gap: flat/dry spatialization) --
    mono = (L + R) * 0.5 + C
    glue = G.hall(mono, 0.5).T.mean(axis=1)       # one shared room
    C = C + 0.38 * glue[:len(C)]
    st = np.stack([L + C, R + C], axis=1)
    import synth as sy
    st[:, 0] = sy.highpass(st[:, 0], 28)
    st[:, 1] = sy.highpass(st[:, 1], 28)
    st = np.tanh(st * 0.6) / np.tanh(0.6)
    g = 10 ** ((-15.0 - voices.lufs(st.mean(axis=1))) / 20.0)
    st *= g
    pk = np.abs(st).max()
    if pk > 10 ** (-1.0 / 20):
        st *= 10 ** (-1.0 / 20) / pk
    return st


def main():
    import soundfile as sf
    mel = sys.argv[1] if len(sys.argv) > 1 else "dies_irae"
    out = sys.argv[2] if len(sys.argv) > 2 else f"out/tutti_{mel}_v1.wav"
    st = compose(mel)
    Path(out).parent.mkdir(exist_ok=True)
    sf.write(out, st.astype(np.float32), SR)
    print(f"{out}: {len(st)/SR:.1f}s")


if __name__ == "__main__":
    main()
