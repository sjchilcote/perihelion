"""Anchored critic — the only model-eared score allowed to matter, and even
then only as ADVISORY under the director's ear.

Adapted line-for-line in spirit from ../johnny/tools/boot_critic.py after its
"calibrate the grader before trusting a single number" lesson: unanchored
"P(shippable)" is noise in BOTH directions (johnny: shipped TV promos scored
0.10; here: a condemned demo scored 0.85). So:

- Clip A = a REAL album block (shipped, defines the bar), Clip B = ours.
- Rotate >=3 anchors, median verdict.
- Persona: the Mick Gordon first-draft bar, judging execution of the positive
  spec ("Church music made by posthuman industrial machines that genuinely
  believe, meaningful musical symbolism").
- Known ear blind spots (johnny §4): AUDIO-ONLY framing; sub-bass claims are
  noise (verify by FFT, never by model ear); timestamps unreliable; mono-
  delivery means NO stereo judgments; last-position bias -> a comparative
  verdict counts only if it survives clip-order swap.
- FIXTURES FIRST: `--fixtures` must pass before any score of ours is real:
  a held-out album block as B must read comparable (median p >= 0.6, never
  "clearly worse"), and the condemned round-2 demo as B must read clearly
  worse (median p <= 0.35). If fixtures fail, the critic refuses to score.

    uv run python tools/musicgen/anchored_critic.py --fixtures
    uv run python tools/musicgen/anchored_critic.py our_piece.wav -n 3
    uv run python tools/musicgen/anchored_critic.py our_piece.wav --probes
"""
from __future__ import annotations

import argparse
import json
import statistics
import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "playtest"))
import audio_judge  # noqa: E402  (key, transcode, cost log, JSON parse)

SCRATCH = Path("/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter"
               "/6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/musicgen")
BLOCKS = SCRATCH / "blocks"

# Rotating anchors: high/full-kit, peak, restrained chant, guitar+choir.
ANCHORS = [
    "02_fleshgrinder_blk02.wav",
    "04_not_a_heart__but_an_engine_blk07.wav",
    "01_rejoice__for_we_were_once_blessed__chant_of_remembrance_blk00.wav",
    "05_styx_floods_with_souls_blk03.wav",
]

# Director's canonical track->state mapping (DIRECTOR_FEEDBACK.md): each
# emotional state judges against ITS archetype's blocks.
STATE_ANCHORS = {
    "prayer": [
        "01_rejoice__for_we_were_once_blessed__chant_of_remembrance_blk00.wav",
        "01_rejoice__for_we_were_once_blessed__chant_of_remembrance_blk05.wav",
        "07_i_swear_to_protect__chant_of_trust_blk00.wav",
    ],
    "contempt": [
        "02_fleshgrinder_blk01.wav",
        "02_fleshgrinder_blk02.wav",
        "02_fleshgrinder_blk03.wav",
    ],
    "stalwart": [
        "05_styx_floods_with_souls_blk00.wav",
        "05_styx_floods_with_souls_blk03.wav",
        "04_not_a_heart__but_an_engine_blk07.wav",
    ],
}
# Held-out fixture blocks (never used as anchors).
FIXTURE_GOOD = "03_trash_planet_mining_rig_blk03.wav"
FIXTURE_BAD = "demo_piece_v8.wav"          # condemned by the director's ear

CRAFT = """AUDIO-ONLY task: both clips are mono audio; judge only what you
hear. Do not comment on stereo width. Do not penalize sub-bass weight (your
audio frontend under-reports it; we verify low end by FFT separately). Do
not trust your own absolute timestamps.

You are a veteran heavy-electronic/industrial producer doing quality control.
Clip A is from a commercial album that shipped and is loved — by definition
Clip A meets the professional bar. Clip B may be from a different project
with different style goals: DO NOT judge stylistic match between A and B.
Judge only CRAFT, calibrated so Clip A = professional:

- Sound sources: do instruments read as real/intentional (an aggressive
  guitar reads as one; drums have weight) or as toy/GM-MIDI/laser timbres?
- Writing: do riffs and melodies have intent — phrases with contour and
  cadence, development, a groove that locks — or aimless noodling / one or
  two notes repeated / random-feeling sequences?
- Performance: per-hit dynamics and articulation, or flat quantized
  wallpaper?
- Arrangement/mix: punch-and-space dynamics, deliberate transitions, or mud
  and monotony?

"First-draft-grade shippable" means: the SOUND IDENTITY and the WRITING are
already right; only polish (mix detail, mastering) remains. If the core
timbres sound like toys, or the writing sounds unintentional, it is NOT
first-draft-grade, no matter how rough-mix-tolerant you are.

Return STRICT JSON only:
{"p_ship_first_draft": 0.x,  // P(a pro producer calls Clip B shippable
                             // first-draft-grade, calibrated Clip A = pro)
 "originality": 0.x,         // P(a veteran listener says of B: "I haven't
                             // quite heard this before")
 "better_or_worse": "B clearly worse | comparable craft | B better",
 "biggest_fix": "the single highest-impact change to B",
 "amateur_tells": ["..."],
 "summary": "2-3 sentences"}"""

SPEC = """AUDIO-ONLY task: one mono clip. Do not comment on stereo width or
sub-bass; do not trust your own absolute timestamps.

A game project has this brief for its music: "Church music made by posthuman
industrial machines that genuinely believe — with MEANINGFUL musical
symbolism." That means liturgical FORMS in the music's bones (chant phrase
grammar with breaths and held cadence tones, modal melody, antiphony/call-
and-response, organum-style parallel motion, bells, choir), performed by
MACHINE timbres (industrial sources as voices), SINCERELY — reverent, not
spooky-horror irony, not church-flavored pads over a generic metal template,
not religious samples pasted on top.

Listen to the clip and report what is ACTUALLY THERE:

Return STRICT JSON only:
{"church_forms_audible": 0.x,   // P(a listener who knows liturgical music
                                // hears real liturgical form in the bones)
 "church_forms_heard": ["name each one you genuinely hear"],
 "machine_performers": 0.x,     // P(the timbres read as industrial/machine
                                // sources performing, vs conventional
                                // instruments or cheap synths)
 "sincere_not_ironic": 0.x,     // P(it reads as reverent belief, not horror
                                // pastiche or irony)
 "template_pastiche": 0.x,      // P(it reads as a genre template with
                                // borrowed religious dressing) — high is BAD
 "symbolism_note": "anything that reads as deliberate, meaningful musical
                    symbolism, or null",
 "summary": "2 sentences"}"""

ARTIFACTS = """AUDIO-ONLY task: one mono clip from a work-in-progress
render. Your ONLY job is to find AUDIO DEFECTS — technical brokenness, not
taste. Listen adversarially, like a mastering engineer doing QC. For each
category report what you actually hear (null if genuinely absent):

Return STRICT JSON only:
{"clicks_pops": "any clicks, pops, digital ticks — where/how often, or null",
 "cutoff_decays": "any sounds whose natural decay is chopped before it
                   finishes (bells, cymbals, tails) — describe, or null",
 "timbre_discontinuity": "does any single voice CHANGE CHARACTER between
                          consecutive notes (different texture per note,
                          as if each note is a different sample)? or null",
 "mechanical_rearticulation": "does any sustained/vocal line re-attack
                               every note identically like 'ah-ah-ah-ah'
                               instead of phrasing legato? or null",
 "loop_seams": "audible loop restart points / abrupt repeats, or null",
 "broken_voices": "any voice that sounds glitchy, malfunctioning, or like
                   a corrupted render rather than an intended instrument —
                   name and describe each, or null",
 "sounds_like_finished_music": true/false,
 "worst_defect": "the single worst technical problem",
 "summary": "2 sentences, defects only"}"""

PROBES = """AUDIO-ONLY task: one mono clip. Do not comment on stereo width or
sub-bass weight; do not trust your own absolute timestamps. Answer with
OBSERVABLES, not opinions.

Return STRICT JSON only:
{"sounds_in_order": ["each distinct sound event/section as you hear it"],
 "melody_instrument": "what carries the melody, described by timbre",
 "melody_shape": "does the melody move in phrases with contour and cadence,
                  or repeat one or two notes? describe its actual motion",
 "guitar_reads_as": "real aggressive guitar | processed guitar | synth
                     imitating guitar | toy/laser | no guitar present",
 "low_hit_rhythm": "transcribe the kick/low-hit rhythm as text (e.g.
                    x..x..x. per beat), best effort",
 "liturgical_elements": ["any church-music elements you genuinely hear:
                          chant phrasing, modal melody, antiphony, organum,
                          bells, choir — name only what is actually there"],
 "tempo_bpm_estimate": 0}"""


def _call(content: list, tag: str) -> dict:
    import urllib.request
    body = {"model": audio_judge.MODEL,
            "messages": [{"role": "user", "content": content}],
            "temperature": 0.2}
    req = urllib.request.Request(
        audio_judge.OPENROUTER_URL, data=json.dumps(body).encode(),
        headers={"Authorization": f"Bearer {audio_judge.openrouter_key()}",
                 "Content-Type": "application/json"})
    import urllib.error
    with urllib.request.urlopen(req, timeout=300) as resp:
        payload = json.load(resp)
    usage = payload.get("usage", {})
    audio_judge._log_call({"tool": tag, "model": audio_judge.MODEL,
                           "prompt_tokens": usage.get("prompt_tokens"),
                           "completion_tokens": usage.get("completion_tokens")},
                          float(usage.get("cost", 0.0) or 0.0))
    return audio_judge._parse_json_response(
        payload["choices"][0]["message"]["content"])


def _mp3(src: Path, work: Path, max_s: float = 45.0) -> Path:
    out = work / (src.stem + ".mp3")
    if not out.exists():
        audio_judge.to_mp3(src, out, max_s=max_s)
    return out


def _snd(mp3: Path) -> dict:
    import base64
    return {"type": "input_audio", "input_audio": {
        "data": base64.b64encode(mp3.read_bytes()).decode(), "format": "mp3"}}


def anchored_once(ours: Path, anchor: Path, work: Path,
                  swap: bool = False) -> dict:
    a, b = _mp3(anchor, work), _mp3(ours, work)
    first, second = (b, a) if swap else (a, b)
    lbl1 = "Clip B (under review):" if swap else "Clip A (the shipped reference):"
    lbl2 = "Clip A (the shipped reference):" if swap else "Clip B (under review):"
    content = [{"type": "text", "text": CRAFT},
               {"type": "text", "text": lbl1}, _snd(first),
               {"type": "text", "text": lbl2}, _snd(second)]
    r = _call(content, "musicgen.anchored_critic")
    r["anchor"] = anchor.stem
    r["swapped_order"] = swap
    return r


def spec_once(ours: Path, work: Path) -> dict:
    content = [{"type": "text", "text": SPEC}, _snd(_mp3(ours, work))]
    return _call(content, "musicgen.anchored_critic.spec")


def run_spec_panel(ours: Path, n: int, work: Path) -> dict:
    rs = []
    for _ in range(n):
        try:
            rs.append(spec_once(ours, work))
        except Exception as e:  # noqa: BLE001
            print(f"spec call failed: {e}", file=sys.stderr)
    if not rs:
        return {"error": "all spec calls failed"}
    med = lambda k: statistics.median([r.get(k, 0.0) for r in rs])  # noqa: E731
    return {"n_calls": len(rs),
            "church_forms_audible": med("church_forms_audible"),
            "machine_performers": med("machine_performers"),
            "sincere_not_ironic": med("sincere_not_ironic"),
            "template_pastiche": med("template_pastiche"),
            "forms_heard": sorted({f for r in rs
                                   for f in r.get("church_forms_heard", [])}),
            "symbolism_notes": [r.get("symbolism_note") for r in rs],
            "raw": rs}


def probe(ours: Path, work: Path) -> dict:
    content = [{"type": "text", "text": PROBES}, _snd(_mp3(ours, work))]
    return _call(content, "musicgen.anchored_critic.probe")


def run_panel(ours: Path, n: int, work: Path, state: str | None = None) -> dict:
    rs = []
    anchor_set = STATE_ANCHORS[state] if state else ANCHORS
    for k in range(n):
        anchor = BLOCKS / anchor_set[k % len(anchor_set)]
        for swap in (False, True):
            try:
                rs.append(anchored_once(ours, anchor, work, swap=swap))
            except Exception as e:  # noqa: BLE001 - surfaced, never faked
                print(f"call failed ({anchor.name}, swap={swap}): {e}",
                      file=sys.stderr)
    if not rs:
        return {"error": "all critic calls failed"}
    ps = [r.get("p_ship_first_draft", 0.0) for r in rs]
    orig = [r.get("originality", 0.0) for r in rs]
    verdicts = [r.get("better_or_worse", "") for r in rs]
    # position-swap discipline: worse/comparable verdict must be stable
    stable = len({v for v in verdicts}) == 1 if len(verdicts) >= 2 else False
    return {"n_calls": len(rs),
            "p_median": statistics.median(ps), "p_all": ps,
            "originality_median": statistics.median(orig),
            "verdicts": verdicts, "verdict_stable_under_swap": stable,
            "spec_reads": [r.get("spec_read") for r in rs],
            "biggest_fixes": [r.get("biggest_fix") for r in rs],
            "amateur_tells": sorted({t for r in rs
                                     for t in r.get("amateur_tells", [])}),
            "raw": rs}


def fixtures(work: Path) -> bool:
    ok = True
    good = BLOCKS / FIXTURE_GOOD
    bad = SCRATCH / FIXTURE_BAD
    print("fixture 1 (craft): held-out REAL album block as Clip B -> comparable")
    rg = run_panel(good, 3, work)
    n_worse = sum(v.startswith("B clearly worse") for v in rg["verdicts"])
    print(f"  p_median={rg['p_median']}  verdicts={rg['verdicts']}")
    if rg["p_median"] < 0.6 or n_worse > 1:
        print("  FIXTURE FAIL: craft critic rejects real album material")
        ok = False
    print("fixture 2 (craft): condemned round-2 demo as Clip B -> clearly worse")
    rb = run_panel(bad, 3, work)
    n_worse_b = sum(v.startswith("B clearly worse") for v in rb["verdicts"])
    print(f"  p_median={rb['p_median']}  verdicts={rb['verdicts']}")
    if rb["p_median"] > 0.35 or n_worse_b < len(rb["verdicts"]) - 1:
        print("  FIXTURE FAIL: craft critic passes director-condemned material")
        ok = False
    print("fixture 3 (spec): condemned demo must NOT read as executing the brief")
    rs = run_spec_panel(bad, 3, work)
    print(f"  church={rs['church_forms_audible']} machines={rs['machine_performers']}"
          f" pastiche={rs['template_pastiche']}")
    if min(rs["church_forms_audible"], rs["machine_performers"]) > 0.4 \
            and rs["template_pastiche"] < 0.5:
        print("  FIXTURE FAIL: spec panel credits the condemned demo with the brief")
        ok = False
    (Path(__file__).parent / "analysis/critic_fixtures.json").write_text(
        json.dumps({"good": rg, "bad": rb, "bad_spec": rs, "pass": ok},
                   indent=1))
    print("FIXTURES PASS" if ok else "FIXTURES FAIL — critic scores are void")
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("wav", nargs="?", type=Path)
    ap.add_argument("-n", type=int, default=3, help="anchors to rotate")
    ap.add_argument("--probes", action="store_true")
    ap.add_argument("--spec", action="store_true",
                    help="absolute brief-execution panel (no anchor)")
    ap.add_argument("--state", choices=list(STATE_ANCHORS),
                    help="judge against this emotional state's archetype blocks")
    ap.add_argument("--fixtures", action="store_true")
    a = ap.parse_args()
    work = Path(tempfile.mkdtemp(prefix="critic_", dir=str(SCRATCH)))

    if a.fixtures:
        sys.exit(0 if fixtures(work) else 1)

    if not a.wav:
        ap.error("wav required unless --fixtures")

    fx = Path(__file__).parent / "analysis/critic_fixtures.json"
    if not fx.exists() or not json.loads(fx.read_text()).get("pass"):
        print("Refusing to score: fixtures not passed. Run --fixtures first.")
        sys.exit(2)

    if a.probes:
        print(json.dumps(probe(a.wav, work), indent=1))
        return
    if a.spec:
        r = run_spec_panel(a.wav, a.n, work)
    else:
        r = run_panel(a.wav, a.n, work, state=a.state)
    slim = {k: v for k, v in r.items() if k != "raw"}
    print(json.dumps(slim, indent=1))


if __name__ == "__main__":
    main()
