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


def drums_half(n_bars, rng, fills_at=()):
    d = np.zeros(int(n_bars * BAR * SR) + SR)
    kick = K.kick_knob(25, 25, 50)
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
            K.place(d, K.hit("chh", acc, rng), bar * BAR + pos * STEP)
        if bar % 2 == 1:
            K.place(d, K.hit("ohh", .7, rng), bar * BAR + 14 * STEP)
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
    import synth as sy
    rng = np.random.default_rng(seed)
    total = sum(s for _, s, _ in riff)
    out = np.zeros(int(total * STEP * SR) + SR)
    t = 0
    for p, steps, art in riff:
        if art == "open":
            for iv, g in ((12, 1.0), (19, 0.8), (24, 0.55)):
                place(out, voices.chug_note(rng, p + iv,
                                            STEP * steps * 1.8, 0.0, g),
                      t * STEP)
        else:
            h = voices.chug_note(rng, p, STEP * 1.05, 0.85,
                                 1.0 if t % 16 == 0 else 0.62)
            n_gate = int(STEP * 0.92 * SR)
            if len(h) > n_gate:
                h = h[:n_gate].copy()
                h[-132:] *= np.linspace(1, 0, 132)
            place(out, h, t * STEP)
        t += steps
    out = voices.amp(out * 0.75 / (np.abs(out).max() + 1e-9), drive)
    return sy.highpass(out, 120)


def vb_seq(slot, seq, total, tail=1.0):
    x = VB.render_seq(*VB.SLOTS[slot], seq, total, tail)
    return x / (np.abs(x).max() + 1e-9)


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
    place(C, bed * 0.30, t1)           # bed runs S1+S2, fades later
    vows = [None if p is None else (-0.5 if d >= 8 else 0.2)
            for p, d in events]
    monk = G.render_vocal(events, chant_step, base_midi=50, vowels=vows)
    monk /= np.abs(monk).max() + 1e-9
    monk_wet = G.hall(monk, 1.6).T.mean(axis=1)
    place(C, monk_wet * 0.9, t1 + BAR)
    bells = np.zeros(int(8 * BAR * SR))
    place(bells, bell_hit(0.6), 2 * BAR)
    place(bells, bell_hit(0.4), 6 * BAR)
    place(C, G.hall(bells, 1.4).T.mean(axis=1) * 0.5, t1)

    # ---- S2 entry: fill -> band on 'pressure', monk above -------------
    t2 = sec_time(1)
    fill = drums_half(1, rng, fills_at=(0,))
    place(C, fill * 0.8, t2 - BAR)                  # the lead-in bar
    dh = drums_half(8, rng)
    place(C, dh * 0.85, t2)
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
    bass = vb_seq("bass_deep", bseq, 8 * BAR, 0.4)
    bass = gc.sidechain_duck(bass, dh[:len(bass)], amount=0.45,
                             release_s=0.12)
    place(C, bass * 0.65, t2)
    # monk continues over the band (started in S1, runs ~27s = into S2)
    # defiant organ answers in the chant's long rests (S2 only)
    ans = riffs.lead_phrase([(p, d) for p, d in events if p is not None][:6],
                            factor=2)
    oseq = []
    t = 4 * BAR                                     # answer late in S2
    for p, d in ans:
        oseq.append((50 + p, t, d * STEP * 1.2, 110))
        t += d * STEP
    organ = vb_seq("organ_defiant", oseq, 8 * BAR, 0.5)
    organ = gc.sidechain_duck(organ, dh[:len(organ)], amount=0.3,
                              release_s=0.1)
    place(C, organ * 0.4, t2)

    # ---- S3 develop: swagger groove, lead carries fragments -----------
    t3 = sec_time(2)
    dg = drums_groove(8, rng, fills_at=(7,))
    place(C, dg * 0.85, t3)
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
    place(C, dh4 * 0.9, t4)
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
    bass4 = vb_seq("bass_deep", b4, 8 * BAR, 0.4)
    bass4 = gc.sidechain_duck(bass4, dh4[:len(bass4)], amount=0.45,
                              release_s=0.12)
    place(C, bass4 * 0.7, t4)
    # choir + monk held above the peak (melody-continuity law)
    cseq = []
    for bar in range(8):
        root = roots4[bar * 16]
        for nn in (62 + root, 69 + root):
            cseq.append((nn, bar * BAR, BAR * 0.97, 100))
    choir = vb_seq("choir", cseq, 8 * BAR, 1.0)
    choir_wet = G.hall(choir, 1.3).T.mean(axis=1)
    choir_wet = gc.sidechain_duck(choir_wet, dh4[:len(choir_wet)],
                                  amount=0.3, release_s=0.12)
    place(C, choir_wet * 0.5, t4)
    monk2 = G.hall(monk, 0.6).T.mean(axis=1)
    place(C, monk2 * 0.55, t4)

    # ---- S5 outro: vacuum + ring --------------------------------------
    t5 = sec_time(4)
    bed5 = vb_seq("bed_t2", [(36, 0.0, 5 * BAR, 90)], 5 * BAR, 0.0)
    place(C, bed5 * 0.3, t5)
    place(C, G.hall(np.concatenate([bell_hit(0.7),
                                    np.zeros(int(BAR * SR))]),
                    1.5).T.mean(axis=1) * 0.5, t5)

    # ---- master --------------------------------------------------------
    st = np.stack([L + C, R + C], axis=1)
    st = np.tanh(st * 0.9) / np.tanh(0.9)
    g = 10 ** ((-14.0 - voices.lufs(st.mean(axis=1))) / 20.0)
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
