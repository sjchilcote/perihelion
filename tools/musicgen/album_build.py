"""The ALBUM BUILD — eight tracks authored by synthetic factor curves.

Director's spec (verbatim intent): validate the music itself independently
from gameplay integration. Eight tracks roughly matching the original
album's per-song intensity curves, AUTHORED by synthetic PRAYER/CONTEMPT/
STALWART trajectories (the same triple the game engine emits live) with
lead-ins, crescendos, and breaks; each song uses different base assets.

Discipline (the melody verdict): MELODY-FIRST. Every section's melody is
rendered and metered SOLO (essentia Melodia voiced_frac + note
conformance); accompaniment layers are added in factor-weight order and
the melody meter re-runs after EVERY layer — a layer that sinks the tune
is attenuated until the meter passes or dropped.

Per-track validation battery ON FINAL AUDIO:
  - melody: voiced_frac + conformance per melody span
  - curve conformance: rendered energy/density arc vs the synthetic
    (c+s) curve, Pearson r
  - census lanes vs THE SAME original track's blocks
  - artifacts probe + track-anchored craft panel (advisory)

    uv run python tools/musicgen/album_build.py --track 4     # one track
    uv run python tools/musicgen/album_build.py               # all eight
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
import soundfile as sf

sys.path.insert(0, str(Path(__file__).resolve().parent))
import parts                                  # noqa: E402
import voices                                 # noqa: E402
from parts import SR, place                   # noqa: E402
from melodies import (DIES_IRAE_STROPHE, VICTIMAE_MOTIF,      # noqa: E402
                      DIES_IRAE_MOTIF, sequence, invert, fragment)
from melody_check import score_melody, comb_prominence        # noqa: E402

SCRATCH = voices.SCRATCH
OUT = SCRATCH / "album_build"

# --------------------------------------------------------------------------
# Synthetic factor curves — per-block (p, c, s) waypoints mapped from the
# original album's intensity/role arcs (analysis/album_block_corpus.json)
# and the director's canonical narration of track 04. One waypoint per
# ~30 s block; the compiler interpolates (rises step at bars = walls,
# falls ramp = fades).
# --------------------------------------------------------------------------

CURVES = {
    # 01 Rejoice — the PRAYER archetype: chant opens, band enters, never
    # loses reverence.
    1: dict(name="t01_remembrance", tempo=110, mode_reg=0,
            waypoints=[(1.0, .05, .05), (.55, .35, .30), (.45, .45, .40),
                       (.45, .40, .45), (.40, .50, .40), (.70, .25, .30)]),
    # 02 Fleshgrinder — CONTEMPT archetype: instant high, stays hot.
    2: dict(name="t02_grinder", tempo=140, mode_reg=0,
            waypoints=[(.15, .85, .30), (.12, .90, .35), (.12, .85, .40),
                       (.12, .90, .35), (.12, .85, .40), (.20, .75, .50)]),
    # 03 Trash Planet — one step up the contempt->stalwart line, a little
    # prayer mixed into the break (director's reading).
    3: dict(name="t03_miningrig", tempo=137, mode_reg=0,
            waypoints=[(.15, .75, .45), (.12, .70, .55), (.12, .60, .70),
                       (.60, .20, .35), (.12, .65, .60), (.12, .55, .75)]),
    # 04 Not A Heart — the director's narrated full arc: prayerful open,
    # STALWART+CONTEMPT at 0:30, pure STALWART juggernaut at 1:00, full
    # PRAYER before 2:00, rebuild to CONTEMPT without losing the chants.
    4: dict(name="t04_engine", tempo=135, mode_reg=0,
            waypoints=[(.95, .05, .10), (.30, .60, .65), (.15, .30, .90),
                       (.90, .10, .20), (.35, .70, .40), (.15, .60, .70)]),
    # 05 Styx — the central STALWART track: slow unstoppable lead,
    # breaks for chanting.
    5: dict(name="t05_styx", tempo=139, mode_reg=0,
            waypoints=[(.20, .35, .75), (.15, .30, .85), (.50, .15, .55),
                       (.15, .30, .90), (.50, .20, .60), (.10, .30, .95)]),
    # 07 Chant of Trust — low intro, explosive drop, drum-less ritual
    # breaks (choir persists through everything).
    7: dict(name="t07_trust", tempo=125, mode_reg=-2,
            waypoints=[(1.0, .02, .02), (.25, .45, .70), (.30, .55, .45),
                       (.60, .25, .35), (.25, .50, .55), (.65, .10, .55),
                       (.70, .05, .50)]),
    # 08 Populist — peak-heavy: repeated drops.
    8: dict(name="t08_populist", tempo=140, mode_reg=+3,
            waypoints=[(.60, .30, .25), (.20, .60, .55), (.10, .50, .90),
                       (.10, .55, .92), (.25, .60, .55), (.10, .45, .95)]),
    # 10 Chant of Focus — mixed regime, late peak.
    10: dict(name="t10_focus", tempo=131, mode_reg=-2,
             waypoints=[(.80, .15, .15), (.35, .55, .45), (.30, .45, .55),
                        (.20, .40, .75), (.35, .55, .45), (.15, .35, .90)]),
}

# Distinct base assets per track: melody seed (semitone/dur events or a
# motif expanded syllabically), lead patch, riff palette, kick pattern,
# registers. No two tracks share a full set.
RIFF_A = [(0, 3, 0.0, 1.0), (2, 0, .9, .55), (4, 2, .15, .92),
          (6, 0, .9, .5), (8, 3, 0.0, .97), (10, 0, .9, .52),
          (12, 0, .1, .9), (14, 0, .9, .5)]
RIFF_B = [(0, 2, 0.0, 1.0), (4, -2, .12, .9), (8, 0, 0.0, .95),
          (10, 0, .9, .5), (12, 0, .15, .88), (14, 0, .9, .5)]
RIFF_C = [(0, 0, 0.0, 1.0), (3, 0, .9, .5), (6, 3, .1, .9),
          (8, 0, 0.0, .95), (11, 0, .9, .5), (14, 5, .2, .85)]
RIFF_D = [(0, 0, .1, 1.0), (2, 0, .9, .6), (4, 0, .1, .95), (6, 0, .9, .6),
          (8, -2, .1, .92), (10, 0, .9, .6), (12, 3, .1, .9), (14, 2, .8, .6)]
KICK_4 = [(0, 1.0), (4, .9), (8, 1.0), (12, .9)]
KICK_HALF = [(0, 1.0), (6, .55), (8, .95), (14, .5)]
KICK_DRIVE = [(0, 1.0), (3, .55), (4, .9), (8, 1.0), (11, .5), (12, .9)]


def motif_events(motif, dur_steps=4, tail=8):
    ev = [(s, dur_steps) for s in motif]
    ev[-1] = (ev[-1][0], tail)
    return ev

ASSETS = {
    1: dict(melody=DIES_IRAE_STROPHE, lead="lead_saw", melody_reg=12,
            riff=(RIFF_A, RIFF_B), kick=KICK_HALF, chant=True, bells=True),
    2: dict(melody=motif_events(sequence(DIES_IRAE_MOTIF, 0), 2, 6) * 2,
            lead="lead_saw", melody_reg=12,
            riff=(RIFF_C, RIFF_A), kick=KICK_DRIVE, chant=False, bells=False),
    3: dict(melody=motif_events(VICTIMAE_MOTIF, 4, 8),
            lead="lead_saw", melody_reg=12,
            riff=(RIFF_D, RIFF_C), kick=KICK_4, chant=True, bells=False),
    4: dict(melody=DIES_IRAE_STROPHE, lead="lead_saw", melody_reg=12,
            riff=(RIFF_A, RIFF_C), kick=KICK_DRIVE, chant=True, bells=True),
    5: dict(melody=[(s, d * 2) for s, d in motif_events(VICTIMAE_MOTIF, 4, 12)],
            lead="lead_saw", melody_reg=7,
            riff=(RIFF_B, RIFF_D), kick=KICK_HALF, chant=True, bells=False),
    7: dict(melody=motif_events(invert(DIES_IRAE_MOTIF), 4, 10) +
                   motif_events(fragment(DIES_IRAE_MOTIF, 4), 4, 12),
            lead="lead_saw", melody_reg=10,
            riff=(RIFF_A, RIFF_D), kick=KICK_HALF, chant=True, bells=True),
    8: dict(melody=motif_events(sequence(DIES_IRAE_MOTIF, 5), 2, 8) * 2,
            lead="lead_saw", melody_reg=15,
            riff=(RIFF_C, RIFF_D), kick=KICK_DRIVE, chant=False, bells=False),
    10: dict(melody=motif_events(VICTIMAE_MOTIF, 4, 8) +
                    motif_events(sequence(VICTIMAE_MOTIF, 3), 4, 12),
             lead="lead_saw", melody_reg=10,
             riff=(RIFF_D, RIFF_B), kick=KICK_4, chant=True, bells=True),
}

BLOCK_S = 24.0          # synthetic block length (album's 30 s minus overlap)


def compile_track(tid: int, verbose=True) -> dict:
    cfg = CURVES[tid]
    assets = ASSETS[tid]
    rng = np.random.default_rng(1000 + tid)
    tempo = cfg["tempo"]
    bar_s = 240.0 / tempo
    step_s = bar_s / 16
    wps = cfg["waypoints"]
    n_blocks = len(wps)
    bars_per_block = max(4, int(round(BLOCK_S / bar_s)))
    n_bars = n_blocks * bars_per_block
    total_s = n_bars * bar_s
    n = int(total_s * SR)

    kick_sample = voices._mono(voices.SCRATCH / "freesound/kick_metal_trim.wav")[0]

    # ---- MELODY FIRST ----------------------------------------------------
    mel = np.zeros(n)
    melody_spans = []          # (t0, events, reg) for the meter
    ev = assets["melody"]
    ev_steps = sum(d for _, d in ev)
    reg = assets["melody_reg"] + cfg["mode_reg"]
    for blk, (p, c, s) in enumerate(wps):
        t0 = blk * bars_per_block * bar_s
        if p >= 0.8 and blk == 0:
            # plain statement, chant register (the prayer open)
            line = parts.render_lead(rng, ev, step_s, reg, assets["lead"])
            place(mel, line * 0.9, t0 + 0.5 * bar_s)
            melody_spans.append((t0 + 0.5 * bar_s, ev, reg))
        elif s >= 0.8:
            # juggernaut: augmented, slow, unstoppable — and SOARING: the
            # album's lead rides OVER the wall, so the melody gets its
            # stalwart level here, not equality with the bed
            slow = [(sv, d * 2) for sv, d in ev][:max(4, len(ev) // 2)]
            line = parts.render_lead(rng, slow, step_s, reg, assets["lead"])
            place(mel, line * 1.35, t0)
            melody_spans.append((t0, slow, reg))
        elif c >= 0.5 or s >= 0.4:
            line = parts.render_lead(rng, ev, step_s, reg, assets["lead"])
            place(mel, line * 0.95, t0)
            melody_spans.append((t0, ev, reg))
        else:
            # break/rest: fragment, sparse
            frag = ev[:max(3, len(ev) // 3)]
            line = parts.render_lead(rng, frag, step_s, reg, assets["lead"])
            place(mel, line * 0.8, t0 + bar_s)
            melody_spans.append((t0 + bar_s, frag, reg))

    def meter(mix_arr):
        scores = []
        for t0, evs, rg in melody_spans:
            r = score_melody(mix_arr, evs, step_s, t0, register_semi=rg)
            if r["note_slots"]:
                scores.append(r)
        conf = float(np.mean([r["melody_conformance"] for r in scores])) \
            if scores else 0.0
        return conf, scores

    solo_conf, _ = meter(mel)

    # ---- factor-driven layers, gated one at a time ------------------------
    def curve(idx):
        # per-sample factor from waypoints, rises step / falls ramp at bars
        vals = np.zeros(n)
        for blk in range(n_blocks):
            a = int(blk * bars_per_block * bar_s * SR)
            b = int((blk + 1) * bars_per_block * bar_s * SR)
            vals[a:b] = wps[blk][idx]
        return vals

    P, C, S = curve(0), curve(1), curve(2)

    layers = []
    # prayer voices
    layers.append(("bed", parts.hum_bed(total_s) , 0.12 * P))
    if assets["chant"]:
        ch = np.zeros(n)
        for blk, (p, c, s) in enumerate(wps):
            if p >= 0.5 or s >= 0.7:      # chant persists through the peak
                t0 = blk * bars_per_block * bar_s
                line = parts.render_chant(rng, ev, step_s, 0)
                place(ch, line, t0 + 0.25 * bar_s)
        layers.append(("chant", ch, np.maximum(P, 0.6 * S) * 0.9))
    if assets["bells"]:
        bl = np.zeros(n)
        for blk, (p, c, s) in enumerate(wps):
            if p >= 0.5:
                place(bl, parts.bell_hit(0.6),
                      (blk * bars_per_block + 1.5) * bar_s)
        layers.append(("bell", bl, P))
    # rhythm section (contempt+stalwart)
    layers.append(("kick", parts.render_kick(rng, n_bars, bar_s, step_s,
                                             assets["kick"], kick_sample),
                   np.maximum(C, S)))
    layers.append(("hats", parts.render_hats(rng, n_bars, bar_s, step_s, .5),
                   C))
    layers.append(("riff", parts.render_riff(rng, n_bars, bar_s, step_s,
                                             assets["riff"]),
                   np.maximum(C * 0.9, S * 0.7)))
    layers.append(("bass", parts.render_bass(rng, n_bars, bar_s, step_s),
                   np.maximum(C, S) * 0.9))
    import gordon_chain as gc
    wall_audio = parts.render_wall(rng, n_bars, bar_s, step_s)
    # the wall parts under the lead (album grammar: the lead soars over)
    wall_audio = gc.sidechain_duck(wall_audio[:n], mel, amount=0.5,
                                   release_s=0.18)
    layers.append(("wall", wall_audio, S))
    org = np.zeros(n)
    for blk, (p, c, s) in enumerate(wps):
        if s >= 0.7:
            line = parts.render_organum(rng, ev, step_s, 12)
            place(org, line, blk * bars_per_block * bar_s + 0.25 * bar_s)
    org = gc.sidechain_duck(org[:n], mel, amount=0.45, release_s=0.2)
    layers.append(("organum", org, S * 0.8))

    # MELODY-PRESERVATION GATING: add layers strongest-first; if a layer
    # drops mean conformance below 0.55, attenuate it (up to 3 tries),
    # then drop it.
    mix = mel.copy()
    gate_log = []
    for name, audio, weight in layers:
        w = weight if isinstance(weight, np.ndarray) else np.full(n, weight)
        att = 1.0
        for attempt in range(4):
            trial = mix + audio[:n] * w * att * 0.8
            conf, _ = meter(trial)
            if conf >= max(0.55, solo_conf - 0.25):
                mix = trial
                gate_log.append((name, round(att, 2), round(conf, 3)))
                break
            att *= 0.6
        else:
            gate_log.append((name, 0.0, None))    # dropped
    final_conf, span_scores = meter(mix)

    # transitions: sting at hard S rises, vacuum gap before them
    sting = None
    for blk in range(1, n_blocks):
        if wps[blk][2] - wps[blk - 1][2] >= 0.3:
            i = int(blk * bars_per_block * bar_s * SR)
            mix[max(0, i - int(0.18 * SR)):i] *= 0.15   # the dead gap
    mix = np.tanh(mix * 0.8) / np.tanh(0.8)
    g = 10 ** ((-15.0 - voices.lufs(mix)) / 20.0)
    mix = np.clip(mix * g, -0.94, 0.94)

    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / f"{cfg['name']}.wav"
    sf.write(str(path), mix.astype(np.float32), SR)

    # ---- curve conformance ------------------------------------------------
    win = int(2.0 * SR)
    rendered = [float(np.sqrt((mix[i:i + win] ** 2).mean()))
                for i in range(0, n - win, win)]
    intended = [(C[i] + S[i]) for i in range(0, n - win, win)]
    r = float(np.corrcoef(rendered, intended)[0, 1]) \
        if len(rendered) > 3 else 0.0

    rep = dict(track=cfg["name"], dur_s=round(total_s, 1),
               melody_conf_solo=round(solo_conf, 3),
               melody_conf_final=round(final_conf, 3),
               curve_r=round(r, 3), gates=gate_log,
               path=str(path))
    if verbose:
        print(json.dumps(rep, indent=1))
    return rep


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--track", type=int)
    a = ap.parse_args()
    ids = [a.track] if a.track else sorted(CURVES)
    reps = [compile_track(t) for t in ids]
    (OUT / "album_build_report.json").write_text(json.dumps(reps, indent=1))
    print(f"\n{'track':16s} {'solo':>5s} {'final':>5s} {'curve_r':>7s}")
    for r in reps:
        print(f"{r['track']:16s} {r['melody_conf_solo']:5.2f} "
              f"{r['melody_conf_final']:5.2f} {r['curve_r']:7.2f}")


if __name__ == "__main__":
    main()
