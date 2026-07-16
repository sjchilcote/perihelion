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


def build(mel: str, outdir: Path):
    rec = T.RECIPES[mel]
    total_bars = sum(b for _, b, _ in rec["form"])
    n = int(total_bars * BAR * SR)
    outdir.mkdir(parents=True, exist_ok=True)
    print(f"[{rec['title']}] {total_bars} bars -> {outdir}", flush=True)

    _st, lanes, ctx = T.compose(mel, collect_lanes=True)

    # prayer = the form-locked holy accents (choir + bells) + spine
    # share; it may legitimately fall silent in sections -- the MONK
    # lane carries the never-silent through-line now, on its own
    # free-running clock, and IT gets the dropout validator
    prayer = lanes["holy"] + lanes["spine"] * 0.3
    _write(outdir / "prayer.wav", prayer, n)
    monk = lanes["monk"]
    _assert_no_silent_bars(monk[:n], total_bars, f"{mel}/monk")
    _write(outdir / "monk.wav", monk, n)
    stal = np.stack([lanes["wall_L"] + lanes["bass"] + lanes["tells"],
                     lanes["wall_R"] + lanes["bass"] + lanes["tells"]],
                    axis=1)
    _write(outdir / "stalwart.wav", stal, n)
    _write(outdir / "contempt.wav", lanes["fm"] + lanes["flour"], n)
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
        x = VB.render_seq(*rec["fm"], seq, total_bars * BAR, 0.3)
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
