"""Tutti -> dynamic chunk bank (task 33 core).

    uv run python tools/musicgen/tutti_bank.py [melody]

One lane-collecting compose() pass turns a finished album track into
the bank the in-game chunk-queue engine (music.py rich mode) consumes.
The form position advances through the REAL composition while the
factors gate lanes — the instrument then drives today's generator:

    prayer.wav    holy lane (monk, choir, bells) — the faith, always
    stalwart.wav  drums + wall (stereo) + bass + tells — the Test
    contempt.wav  fm bass + flourish — the dismissive machinery
    bed_t1..4     drone spine (one texture per section already)
    riser/sting   tension effect + accent
    lead_<w>      the lead lane re-voiced per weapon (10 renders)
    bass_<kind>   enemy cells on the recipe's fm voice

Known v1 limitation (logged): drums live in stalwart only, so a
pure-contempt state is drum-less until per-factor drum variants land.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))

import generate_bank as GB          # noqa: E402  (ENEMY_CELLS patterns)
import gordon_chain as gc           # noqa: E402
import harmony                      # noqa: E402
import riffs                        # noqa: E402
import tr909_kit as K               # noqa: E402
import tutti as T                   # noqa: E402
import vital_bank as VB             # noqa: E402
from tutti import BAR, SR, STEP     # noqa: E402


def _write(path, x, trim_n):
    import soundfile as sf
    if x.ndim == 1:
        x = np.stack([x, x], axis=1)
    x = x[:trim_n]
    pk = np.abs(x).max()
    if pk > 1.0:
        x = x / pk
    sf.write(str(path), (np.clip(x, -1, 1) * 32767).astype(np.int16),
             SR, subtype="PCM_16")
    print(f"  {path.name:22s} {len(x)/SR:6.1f}s", flush=True)


def _assert_no_silent_bars(x, total_bars, name, floor_db=-15.0):
    """FAIL FAST at build time: a stem that SUDDENLY GOES SILENT FOR
    MULTIPLE BARS ships a lie -- the engine holds the lane 'on' while
    nothing sounds. A single quiet bar is a breath (director round 2:
    'it doesn't need to be literally constant'); two or more in a row
    crash the build."""
    n_bar = int(BAR * SR)
    rms = np.array([np.sqrt((x[i * n_bar:(i + 1) * n_bar] ** 2).mean()
                            + 1e-12) for i in range(total_bars)])
    med = float(np.median(rms))
    db = 20 * np.log10(rms / med)
    runs, start = [], None
    for i, v in enumerate(db):
        if v < floor_db and start is None:
            start = i
        elif v >= floor_db and start is not None:
            if i - start >= 2:
                runs.append((start, i - 1, round(float(db[start]), 1)))
            start = None
    if start is not None and total_bars - start >= 2:
        runs.append((start, total_bars - 1, round(float(db[start]), 1)))
    if runs:
        raise ValueError(f"{name}: silent for multiple bars at "
                         f"{runs} (below {floor_db}dB of median)")



def _fill_monk_gaps(prayer, monk_far, total_bars, mel):
    """The ONE monk fix the director actually asked for: the composed
    holy lane is kept verbatim ('the monk voice you had was perfect'),
    and any stretch of 2+ quiet bars gets the DISTANT monk drifting in
    -- from his phrase start, faded, never a mid-phrase splice."""
    n_bar = int(BAR * SR)
    out = prayer.copy()
    rms = np.array([np.sqrt((out[i * n_bar:(i + 1) * n_bar] ** 2).mean()
                            + 1e-12) for i in range(total_bars)])
    med = float(np.median(rms))
    quiet = 20 * np.log10(rms / med) < -15.0
    i, fills = 0, 0
    while i < total_bars - 1:
        if quiet[i] and quiet[i + 1]:
            j = i
            while j < total_bars and quiet[j]:
                j += 1
            t0 = i * n_bar
            seg = monk_far[: (j - i) * n_bar + n_bar // 2].copy()
            fade = int(0.5 * SR)
            seg[:fade] *= np.linspace(0.0, 1.0, fade)
            seg[-fade:] *= np.linspace(1.0, 0.0, fade)
            end = min(len(out), t0 + len(seg))
            out[t0:end] += seg[:end - t0] * 0.35
            fills += 1
            i = j
        else:
            i += 1
    if fills:
        print(f"  prayer: filled {fills} silent stretch(es)", flush=True)
    return out


def _f0_hz(x) -> float:
    """Dominant fundamental below 500Hz of a render's first 20s."""
    seg = x[: int(20 * SR)]
    F = np.abs(np.fft.rfft(seg * np.hanning(len(seg))))
    fr = np.fft.rfftfreq(len(seg), 1 / SR)
    F[(fr < 25) | (fr > 500)] = 0.0
    return float(fr[int(F.argmax())])


BASS_BAND = (40.0, 120.0)


def _render_bass_in_band(voice, seq, total_s, tail, name):
    """Render, MEASURE the output, and re-render an octave down until
    the fundamental lands in the bass band (director: the bass stems
    competed with the leads in frequency space -- the PATCH decides
    the sounding octave, not the MIDI note, so the pipeline verifies
    the output and shifts; it CRASHES if no octave lands)."""
    f0 = None
    for shift in (0, -12, -24):
        sq = [(nn + shift, t, d, v) for nn, t, d, v in seq]
        x = VB.render_seq(*voice, sq, total_s, tail)
        f0 = _f0_hz(x)
        if BASS_BAND[0] <= f0 <= BASS_BAND[1]:
            if shift:
                print(f"  {name}: f0 landed {f0:.0f}Hz after "
                      f"{shift} semitones", flush=True)
            return x
    raise ValueError(f"{name}: fundamental {f0:.0f}Hz outside "
                     f"{BASS_BAND}Hz at every octave shift")


def build(mel: str, outdir: Path):
    rec = T.RECIPES[mel]
    total_bars = sum(b for _, b, _ in rec["form"])
    n = int(total_bars * BAR * SR)
    outdir.mkdir(parents=True, exist_ok=True)
    print(f"[{rec['title']}] {total_bars} bars -> {outdir}", flush=True)

    _st, lanes, ctx = T.compose(mel, collect_lanes=True)

    # prayer: the ORIGINAL composed monk/choir/bells, verbatim; the
    # one fix is the gap fill (director: "I just asked you to fix
    # that one thing")
    prayer = _fill_monk_gaps(lanes["holy"] + lanes["spine"] * 0.3,
                             ctx["monk_far"], total_bars, mel)
    _assert_no_silent_bars(prayer[:n], total_bars, f"{mel}/prayer")
    _write(outdir / "prayer.wav", prayer, n)

    # stalwart/contempt: FORM-WIDE renders. The album lanes are
    # section-local (dies_irae's walls are digitally silent through
    # develop -- any fight the steering parked there lost the chug).
    # The engine may gain ANY stem at ANY form position, so every
    # dynamic bank stem must carry content at every position, exactly
    # like the leads and enemy basses always did.
    import synth as sy
    events = GB.MELODIES[mel]
    roots16 = []
    for _stype, sbars, prog in rec["form"]:
        roots16 += harmony.roots_16(prog, sbars)
    riff = riffs.riff_16(events, n_bars=total_bars,
                         accents=T._ACC[rec["accents"][0]],
                         chord_roots=roots16)
    wl = T.wall_take(rec, riff, rec["seeds"][0], 18.0)
    wr = T.wall_take(rec, riff, rec["seeds"][1], 19.0)
    bseq, btot = T._bass_seq_from_riff(riff)
    wb = sy.highpass(T.vb_seq_raw(rec["bass"], bseq, btot, 0.4), 90)
    subl = sy.lowpass(T._sub_layer(bseq, btot), 90)
    m = min(len(wb), len(subl))
    wb = wb[:m] + subl[:m] * 0.55
    L_ = np.zeros(n)
    R_ = np.zeros(n)
    T.place(L_, wl * 0.7, 0)
    T.place(R_, wr * 0.7, 0)
    T.place(L_, wb * 0.6, 0)
    T.place(R_, wb * 0.6, 0)
    _write(outdir / "stalwart.wav", np.stack([L_, R_], axis=1), n)

    r3 = riffs.riff_16(events, n_bars=total_bars,
                       accents=T._ACC[rec["accents"][1]],
                       chord_roots=roots16)
    fseq, ftot = T._bass_seq_from_riff(r3, base=38)
    fm = T.vb_seq_raw(rec["fm"], fseq, ftot, 0.3)
    fl = []
    for bar in range(1, total_bars, 2):
        fl.append((62 + roots16[bar * 16], bar * BAR + 8 * STEP,
                   3 * STEP, 100))
    fx = T.vb_seq_raw(rec["flour"], fl, total_bars * BAR, 0.5)
    C_ = np.zeros(n)
    T.place(C_, fm * 0.6, 0)
    T.place(C_, fx * 0.3, 0)
    _write(outdir / "contempt.wav", C_, n)
    # drums are their OWN lane: any combat tier gets the kit (the v1
    # drums-in-stalwart seam left contempt fights drum-less)
    _write(outdir / "drums.wav", lanes["drums"], n)
    for tier in range(1, 5):
        _write(outdir / f"bed_t{tier}.wav", lanes["spine"], n)

    # sting + riser come from THE bell (bell_sting.py is the single
    # source: deep on-key chapel bell; the riser is the same bell
    # reversed). If the Ylanne sample is missing this CRASHES the
    # build -- the bell is part of the bank, not an optional garnish.
    import bell_sting as BS
    rng = np.random.default_rng(rec["seeds"][0])
    # BARE bell (director, verbatim: 'an on-key sample of a large
    # bell ringing once'): the RISER is the swell now -- a pre-swell
    # on the sting doubled the gesture and left a dead gap when the
    # two chained
    stg = BS.build_sting(rec, rng, "bare")
    _write(outdir / "sting.wav", stg, len(stg))
    rsr = BS.build_riser(rec)
    _write(outdir / "riser.wav", rsr, len(rsr))

    # weapon leads: the develop-lead line re-voiced per weapon across
    # the whole form (same phrase logic as sec_develop)
    events = GB.MELODIES[mel]
    frag = riffs.lead_phrase(
        [(p, d) for p, d in events if p is not None][:8], factor=2)
    lseq = []
    for k in range(total_bars // 4):
        tt = k * 4 * BAR
        for pnote, d in frag:
            lseq.append((62 + pnote, tt, (d + 0.5) * STEP, 108))
            tt += d * STEP
    for w, sel in VB.SLOTS.items():
        if not w.startswith("lead_"):
            continue
        x = VB.render_seq(*sel, lseq, total_bars * BAR, 0.5)
        x = x / (np.abs(x).max() + 1e-9)
        _write(outdir / f"{w}.wav", x * 0.8, n)

    # enemy cells on the recipe's fm voice, over the form's own roots
    roots = []
    for stype, bars, prog in rec["form"]:
        roots += harmony.roots_16(prog, bars)[::16]
    for kind, (cells, _sel) in GB.ENEMY_CELLS.items():
        seq = []
        for bar, r in enumerate(roots):
            for pos, semi, dsteps in cells:
                seq.append((38 + r + semi, bar * BAR + pos * STEP,
                            dsteps * STEP * 0.9, 106))
        x = _render_bass_in_band(rec["fm"], seq, total_bars * BAR,
                                 0.3, f"{mel}/bass_{kind}")
        x = x / (np.abs(x).max() + 1e-9)
        _write(outdir / f"bass_{kind}.wav", x * 0.8, n)

    secs, pos = [], 0
    for stype, bars, _p in rec["form"]:
        secs.append([stype, pos, pos + bars])
        pos += bars
    # sections written AT THE SOURCE: the engine's strict loader
    # refuses a sectionless bank.json, so a bank rebuilt without the
    # boss_stems pass can no longer ship a silently steering-less form
    (outdir / "bank.json").write_text(json.dumps(
        dict(melody=mel, title=rec["title"], bpm=T.BPM, bars=total_bars,
             sections=secs)))
    print("bank complete", flush=True)


if __name__ == "__main__":
    mel = sys.argv[1] if len(sys.argv) > 1 else "dies_irae"
    T.check_uniqueness()
    build(mel, Path("out/banks") / f"album_{mel}")
