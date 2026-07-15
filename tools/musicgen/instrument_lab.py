"""Instrument lab — audition every part slot's instrument + planned material.

    uv run python tools/musicgen/instrument_lab.py

Left: melody menu. Rows: one per part slot of STEM_COMPOSITION_DESIGN —
concept, the preset that plays it, and what it plays. Click a row (or
press its key) to hear that instrument performing its planned material
from the selected melody. Renders are cached per (melody, slot) in the
scratchpad; first click on a row renders in the background (row shows
"rendering..."), then plays.

Slots and their planned material:
  monk        Delay Lama            the chant itself (free 72bpm grid)
  choir       Odin2 Choir Aahs      chord tones of the pedal/progression
  organ_holy  Odin2 Church Organ    progression, with 16' low octave
  organ_def   Odin2 666-001-Organ   defiant stabs in the chant's rests
  bell        authored bell         phrase-end tolls
  wall        chug kit (samples)    pedal-point 8ths on bar roots
  drums       TR-909 (real)         half-time backbone
  bass_deep   Odin2 DeepBass        pedal whole notes
  bass_fm     Odin2 Growly FM       driving 8ths on the pedal
  bed_t1..t4  Odin2 Drones          stage drones by descent
  lead_*      per-weapon presets    call-and-response ANSWER: the chant's
                                    opening figure, up an octave, placed
                                    in the first rest window
  cell_*      per-enemy patterns    that enemy's bassline cell
"""
from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "soundgen"))

import generate_bank as G                     # noqa: E402
import riffs                                  # noqa: E402

SR = 44100
CACHE = Path("/tmp/claude-1000/-home-login-PycharmProjects-"
             "noneuclideantopdownshooter/6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b"
             "/scratchpad/musicgen/lab_cache")
CACHE.mkdir(parents=True, exist_ok=True)


def _mono(x):
    return x.mean(axis=1) if x.ndim == 2 else x


def _chant_head(events, n_notes=8):
    out = []
    for p, d in events:
        out.append((p, d))
        if p is not None and sum(1 for q, _ in out if q is not None) >= n_notes:
            break
    return out


def _first_rest_answer(events):
    """The lead's planned material: the chant's opening figure, one
    octave up, as the ANSWER placed after the first breath (design law:
    counter-melody lives in the chant's rest windows)."""
    head = [(p + 12, max(d // 2, 1)) for p, d in _chant_head(events, 6)
            if p is not None]
    return head


# ---- slot renderers: (melody events) -> mono/stereo float array -----------

def r_monk(ev):
    step = 60.0 / 72.0 / 4
    vows = [None if p is None else (-0.5 if d >= 8 else 0.2)
            for p, d in _chant_head(ev, 16)]
    x = G.render_vocal(_chant_head(ev, 16), step, base_midi=50, vowels=vows)
    x = x / (np.abs(x).max() + 1e-9)
    return G.hall(x, 1.4).T


def r_choir(ev):
    roots = G.bar_roots(ev, 4)
    x = G.phrase_on([(r, 16) for r in roots], lambda p, d: G.o2.render_notes(
        G._odin_patch(G.CHOIR), [50 + p, 57 + p], d, tail_s=1.5), gap=0.1)
    return G.hall(x / (np.abs(x).max() + 1e-9), 1.3).T


def r_organ_holy(ev):
    roots = G.bar_roots(ev, 4)
    x = G.phrase_on([(r, 16) for r in roots], lambda p, d: G.o2.render_notes(
        G._odin_patch(G.ORGAN_HOLY), [26 + p, 38 + p, 45 + p], d,
        tail_s=1.0), gap=0.1)
    return G.hall(x / (np.abs(x).max() + 1e-9), 1.1).T


def r_organ_def(ev):
    """Defiant organ: melody accents only (the riff's open slots),
    stabbed dry — the machine shouting the tune's skeleton."""
    riff = riffs.riff_16(ev, n_bars=4, accents=riffs.ACCENTS_B, pedal=0)
    x = np.zeros(int(4 * G.BAR * SR) + SR)
    p = G._odin_patch(G.ORGAN_DEFIANT)
    t = 0
    for pp, steps, art in riff:
        if art == "open":
            y = G.o2.render_notes(p, [50 + pp, 57 + pp],
                                  G.STEP * steps * 1.4, tail_s=0.3)
            G.place_mono(x, y, t * G.STEP)
        t += steps
    return x / (np.abs(x).max() + 1e-9) * 0.9


def r_bell(ev):
    x = np.zeros(int(SR * 5))
    G.place_mono(x, G.bell_hit(0.8), 0.2)
    G.place_mono(x, G.bell_hit(0.5), 2.4)
    return G.hall(x, 1.3).T


def r_wall(ev):
    """The RIFF: 16th pedal motor, melody pitches as open accents."""
    rng = np.random.default_rng(11)
    riff = riffs.riff_16(ev, n_bars=4, accents=riffs.ACCENTS_A, pedal=0)
    out = np.zeros(int(4 * G.BAR * SR) + SR)
    t = 0
    for p, steps, art in riff:
        if art == "open":
            # melody accent = POWER CHORD an octave up (root+5th+8ve),
            # open strings — the approved wall voicing (parts.render_wall)
            for iv, g in ((12, 1.0), (19, 0.8), (24, 0.55)):
                h = G.voices.chug_note(rng, p + iv,
                                       G.STEP * steps * 1.8, 0.0,
                                       g * (1 + rng.normal(0, .04)))
                G.place_mono(out, h, t * G.STEP)
        else:
            # let the mute ring its natural decay (probe: hard gating
            # cut string/cab resonance)
            h = G.voices.chug_note(rng, p, G.STEP * 2.2, 0.85,
                                   .5 * (1 + rng.normal(0, .05)))
            G.place_mono(out, h, t * G.STEP + rng.normal(0, .002))
        t += steps
    # the approved chain: amp (distortion + cab IR), then HP 120 — the
    # grit and body live here, raw chug samples read as sub-bass pillow.
    # feed the amp conservatively: a 1.0-peak input at 20dB drive clips
    # digitally (probe: "fizzy... severe digital clipping")
    import synth as sy
    out = G.voices.amp(out * 0.75 / (np.abs(out).max() + 1e-9), 18.0)
    out = sy.highpass(out, 120)
    return out / (np.abs(out).max() + 1e-9) * 0.9


def r_drums(ev):
    rng = np.random.default_rng(5)
    d = np.zeros(int(4 * G.BAR * SR) + SR)
    kick = G.K.kick_knob(25, 25, 50)
    for bar in range(4):
        for pos, vel, inst in [(0, 1.0, "kick"), (8, .95, "snare"),
                               (4, .85, "kick"), (12, .5, "kick")]:
            x = kick * (0.6 + 0.4 * vel) if inst == "kick" \
                else G.K.hit("snare", vel, rng)
            G.K.place(d, x, bar * G.BAR + pos * G.STEP)
        for pos in range(0, 16, 2):
            acc = .75 if pos % 8 == 4 else (.5 if pos % 4 == 0 else .35)
            G.K.place(d, G.K.hit("chh", acc, rng),
                      bar * G.BAR + pos * G.STEP)
    return d / (np.abs(d).max() + 1e-9) * 0.9


def r_bass_deep(ev):
    roots = G.bar_roots(ev, 4)
    x = np.zeros(int(4 * G.BAR * SR) + SR)
    for bar, r in enumerate(roots):
        y = G.o2.render_notes(G._odin_patch(G.BASS_DEEP), [26 + r],
                              G.BAR * 0.95, tail_s=0.3)
        G.place_mono(x, y, bar * G.BAR)
    return x / (np.abs(x).max() + 1e-9) * 0.9


def r_bass_fm(ev):
    """Locks the wall's riff at bass register: same accent template,
    melody pitches on the accents, pedal drive between."""
    riff = riffs.riff_16(ev, n_bars=4, accents=riffs.ACCENTS_A, pedal=0)
    x = np.zeros(int(4 * G.BAR * SR) + SR)
    p = G._odin_patch(G.BASS_FM)
    t = 0
    for pp, steps, art in riff:
        vel = 110 if art == "open" else 78
        y = G.o2.render_notes(p, [38 + pp], G.STEP * steps * 0.9,
                              velocity=vel, tail_s=0.15)
        G.place_mono(x, y, t * G.STEP)
        t += steps
    return x / (np.abs(x).max() + 1e-9) * 0.9


def _mk_bed(tier):
    def r(ev):
        y = G.o2.render_notes(G._odin_patch(G.BEDS[tier]),
                              [38 - 2 * (tier - 1)], 5.0, tail_s=2.0)
        return y / (np.abs(y).max() + 1e-9) * 0.85
    return r


def _mk_lead(wname):
    kind, sel, oct_shift = G.WEAPON_LEADS[wname]

    def r(ev):
        line = riffs.lead_phrase(_chant_head(ev, 12), factor=2)
        if kind == "odin":
            patch = G._odin_patch(sel)
            x = G.phrase_on(line, lambda p, d: G.o2.render_notes(
                patch, [62 + p + oct_shift], d, tail_s=0.4))
        else:
            x = G.phrase_on(line, lambda p, d: G.dx.render_notes(
                sel, [62 + p + oct_shift], d, tail_s=0.4))
        return x / (np.abs(x).max() + 1e-9) * 0.9
    return r


def _mk_cell(ename):
    cells, patch_sel = G.ENEMY_CELLS[ename]

    def r(ev):
        roots = G.bar_roots(ev, 4)
        p = G._odin_patch(patch_sel)
        x = np.zeros(int(4 * G.BAR * SR) + SR)
        for bar, rt in enumerate(roots):
            for pos, semi, dsteps in cells:
                y = G.o2.render_notes(p, [38 + rt + semi],
                                      dsteps * G.STEP * 0.9, tail_s=0.25)
                G.place_mono(x, y, bar * G.BAR + pos * G.STEP)
        return x / (np.abs(x).max() + 1e-9) * 0.9
    return r


def build_slots():
    slots = [
        ("monk", "Delay Lama (the album's voice)", "the chant, free grid",
         r_monk),
        ("choir", "Odin2 'Choir Aahs 1 [RS]'", "chord tones over pedal",
         r_choir),
        ("organ_holy", "Odin2 'Church Organ' +16'", "progression, sanctuary",
         r_organ_holy),
        ("organ_defiant", "Odin2 '666-001-Organ'", "stabs in chant rests",
         r_organ_def),
        ("bell", "authored bell", "phrase-end tolls", r_bell),
        ("wall", "chug kit (real samples)", "pedal 8ths on bar roots",
         r_wall),
        ("drums", "TR-909 (real machine)", "half-time backbone", r_drums),
        ("bass_deep", "Odin2 'DeepBass [Photonic]'", "pedal whole notes",
         r_bass_deep),
        ("bass_fm", "Odin2 'Growly FM Bass [XR]'", "driving 8ths",
         r_bass_fm),
    ]
    for t in range(1, 5):
        nm = G.BEDS[t][1]
        slots.append((f"bed_t{t}", f"Odin2 '{nm}'", f"stage {t} drone",
                      _mk_bed(t)))
    for w, (kind, sel, _o) in G.WEAPON_LEADS.items():
        pname = sel[1] if kind == "odin" else f"Dexed voice {sel}"
        slots.append((f"lead_{w}", pname, "answer in the rest window",
                      _mk_lead(w)))
    for e in G.ENEMY_CELLS:
        slots.append((f"cell_{e}", G.ENEMY_CELLS[e][1][1],
                      "that enemy's bass cell", _mk_cell(e)))
    return slots


def main():
    import pygame
    pygame.init()
    pygame.mixer.pre_init(44100, -16, 2, 512)
    pygame.mixer.init(44100, -16, 2, 512)
    W, H = 1240, 760
    screen = pygame.display.set_mode((W, H))
    pygame.display.set_caption("PERIHELION instrument lab")
    font = pygame.font.SysFont("monospace", 14)
    big = pygame.font.SysFont("monospace", 17, bold=True)

    melodies = list(G.MELODIES)
    slots = build_slots()
    state = dict(mel_i=0, status={}, playing=None)
    # Single-threaded by design: renders happen synchronously, one per
    # frame-loop pass, with a visible banner. No queue, no worker — the
    # only states are "missing", "ready", "ERR". Nothing can get stuck
    # (the one hang-capable subprocess, wine, has its own hard timeout).
    pending: list[int] = []

    def cache_path(mel, slot):
        return CACHE / f"{mel}__{slot}.wav"

    def play_once(cp, slot_name):
        snd = pygame.mixer.Sound(str(cp))
        pygame.mixer.stop()
        snd.play()                       # loops=0: exactly one pass
        state["playing"] = slot_name

    def render_now(mel, i):
        import soundfile as sf
        name, _p, _m, fn = slots[i]
        cp = cache_path(mel, name)
        if cp.exists():
            state["status"][(mel, name)] = "ready"
            return cp
        try:
            x = fn(G.MELODIES[mel])
            if x.ndim == 1:
                x = np.stack([x, x], axis=1)
            sf.write(str(cp), (np.clip(x, -1, 1) * 32767)
                     .astype(np.int16), SR, subtype="PCM_16")
            state["status"][(mel, name)] = "ready"
            return cp
        except Exception as exc:
            state["status"][(mel, name)] = f"ERR {exc}"[:60]
            print(f"[lab] {name}: {exc}", file=sys.stderr)
            return None

    def select_melody(i):
        state["mel_i"] = i
        mel = melodies[i]
        pending.clear()
        for k, (name, _p, _m, _f) in enumerate(slots):
            if cache_path(mel, name).exists():
                state["status"][(mel, name)] = "ready"
            else:
                pending.append(k)

    def click_slot(i):
        mel = melodies[state["mel_i"]]
        name = slots[i][0]
        cp = cache_path(mel, name)
        if cp.exists():
            play_once(cp, name)
        elif i in pending:               # render this one next
            pending.remove(i)
            pending.insert(0, i)

    select_melody(0)

    rows_top = 46
    row_h = 21
    clock = pygame.time.Clock()
    running = True
    while running:
        for ev in pygame.event.get():
            if ev.type == pygame.QUIT:
                running = False
            elif ev.type == pygame.KEYDOWN:
                if ev.key == pygame.K_ESCAPE:
                    running = False
                elif ev.key == pygame.K_UP:
                    select_melody((state["mel_i"] - 1) % len(melodies))
                elif ev.key == pygame.K_DOWN:
                    select_melody((state["mel_i"] + 1) % len(melodies))
            elif ev.type == pygame.MOUSEBUTTONDOWN:
                x, y = ev.pos
                if x < 220:
                    i = (y - rows_top) // 25
                    if 0 <= i < len(melodies):
                        select_melody(i)
                elif x > 240:
                    i = (y - rows_top) // row_h
                    if 0 <= i < len(slots):
                        click_slot(i)

        screen.fill((15, 15, 19))

        def txt(s, x, y, c=(200, 200, 200), f=font):
            screen.blit(f.render(s, True, c), (x, y))

        txt("MELODY (up/down)", 12, 20, (240, 220, 160), big)
        for i, m in enumerate(melodies):
            sel = i == state["mel_i"]
            if sel:
                pygame.draw.rect(screen, (85, 65, 35),
                                 (10, rows_top + i * 25 - 2, 205, 22))
            txt(m, 14, rows_top + i * 25,
                (255, 240, 200) if sel else (170, 170, 170))
        txt("SLOT              INSTRUMENT                     MATERIAL"
            "                    (click to hear)", 250, 20,
            (240, 220, 160), big)
        mel = melodies[state["mel_i"]]
        for i, (name, preset, mat, _fn) in enumerate(slots):
            y = rows_top + i * row_h
            stat = state["status"].get((mel, name), "")
            col = (190, 190, 190)
            if stat.startswith("ERR"):
                col = (240, 110, 110)
            elif stat == "ready" and state["playing"] == name:
                col = (140, 230, 140)
            elif stat != "ready":
                col = (110, 110, 120)
            txt(f"{name:16s}  {preset:30.30s} {mat:26.26s} {stat}",
                250, y, col)
        if pending:
            nm = slots[pending[0]][0]
            txt(f"rendering {nm} ... ({len(pending)} to go)",
                250, H - 30, (240, 220, 120), big)
        pygame.display.flip()
        clock.tick(30)
        # render ONE missing clip per pass, synchronously, banner already
        # on screen; ESC/clicks handled between renders
        if pending:
            render_now(mel, pending.pop(0))
    pygame.quit()


if __name__ == "__main__":
    main()
