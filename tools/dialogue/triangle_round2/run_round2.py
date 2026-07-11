"""tools/dialogue/triangle_round2/run_round2.py

Round 2 dialogue generation: two approach families (A' improved single-shot,
B generate-then-revise) x two scenes (Scene 0, Terminal 1) x two temperature
draws each = 8 Hermes calls total (4 family-A' generations + 4 family-B
revision calls), well under the ~16-call spend guard.

CROSS-HOLDOUT LAW: generating Scene 0 -> exemplar is Terminal 1's dialogue
ONLY (ground truth, verbatim). Generating Terminal 1 -> exemplar is Scene 0's
dialogue ONLY. The target scene's own text never appears in its own
generation pipeline, not in prompts, not in revision passes.

CLI:
    uv run python tools/dialogue/triangle_round2/run_round2.py
"""
from __future__ import annotations

import json
import re
import sys
import time
from pathlib import Path

DIALOGUE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DIALOGUE_DIR))
from generate import (  # noqa: E402
    _load_key, _read_cost_log, _write_cost_log, resolve_model, total_spend,
)
from t1_experiment.generate_t1 import (  # noqa: E402
    ND_5_0, ND_5_2b, ND_8_2c, _call_model_raw,
)

OUT_DIR = Path(__file__).resolve().parent
CAND_DIR = OUT_DIR / "candidates"
PROMPT_DIR = OUT_DIR / "prompts"
BRIEF_DIR = OUT_DIR / "briefs"
SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad"
)

VOICE_BIBLE = f"{ND_5_0}\n\n{ND_5_2b}\n\n{ND_8_2c}"

TRUTH_SCENE0 = (SCRATCH / "truth_scene0.txt").read_text().strip()
TRUTH_T1 = (SCRATCH / "truth_terminal1.txt").read_text().strip()
BRIEF_SCENE0 = (BRIEF_DIR / "brief_scene0.md").read_text().strip()
BRIEF_T1 = (BRIEF_DIR / "brief_t1.md").read_text().strip()

# ---------------------------------------------------------------------------
# DEVICE KEYS -- positive-pointing ("note how the exemplar DOES X"), one per
# scene, aimed at the specific tells round 1 failed: density, Commando's
# missing devices (interruption, literalism-timing humor, pause-stall
# escalation), and register contrast.
# ---------------------------------------------------------------------------

DEVICE_KEY_FOR_SCENE0 = """== DEVICE KEY -- read the exemplar (Terminal 1) FOR these, then reproduce
the *devices*, not the words ==
- **His interruption device.** When she starts to yield him a word
  ("Let's call them 'Testators'"), he doesn't finish agreeing -- he
  overrides: "Stop interrupting me." He interrupts HER mid-sentence to
  redirect back to his own point, flatly, without heat. Give your Commando
  at least one moment where he cuts across a RATIO line this way, not the
  reverse.
- **His literalism-as-humor, timed.** "I did forget to pack spare undies" --
  a joke that only works because it's delivered completely straight, as a
  literal answer to a question that wasn't really asking for one, and the
  payoff is a pause token immediately after ({TRANSFER PAUSES FOR 24 ms})
  before she reacts -- the pause IS part of the timing, not empty scaffolding.
- **Her stall lines escalate with load, in threes.** When the question costs
  her the most, she doesn't answer immediately -- she doesn't even think in
  one beat. Three separate stall lines, each with its own pause annotation,
  each phrased slightly differently (not the same "thinking..." repeated),
  landing right before her hardest admission.
- **Density.** Terminal 1's exemplar runs 722 words total across ~28 RATIO
  lines (avg ~15.5 words/line) and ~21 COMMANDO lines (avg ~9.4
  words/line) -- his lines are consistently SHORTER than hers, often a
  single clause. If a COMMANDO line in your draft would run longer than
  about 12 words, it is very likely wrong for him; cut it, turn it into an
  action, or split the information into two short exchanges.

== CONTRAST PAIR (Terminal 1's own beat -- round 1 draft vs. the truth) ==
Round 1's own attempt at Terminal 1's crossed-closer beat (the moment where
the two factions' shared doctrine about restoring life/Man to a dead Earth
gets divided between the two speakers) produced, at temp 0.25:
  COMMANDO: "We will restore life to the surface of the Earth."
  RATIO: "-and seed it with the legacy of a thousand worlds."
This is salad: grammatically fine, thematically vacant, answers nothing the
scene needed, and invents lore nobody asked for instead of landing the
actual device. What the real exemplar does at the equivalent beat instead:
  [We will restore life to the surface of the Earth.]
  We will restore Man to the surface of the Earth.
Two short, PARALLEL, complete lines -- each speaker restating the same
promise once, in their own single vocabulary word, and stopping. No new
content, no ornamentation, no third clause. Reproduce the second pattern
where your own brief calls for a closer, not the first."""

DEVICE_KEY_FOR_T1 = """== DEVICE KEY -- read the exemplar (Scene 0) FOR these, then reproduce
the *devices*, not the words ==
- **Deadpan opener under siege.** Her very first line does real
  information work (where he is, that everyone is dead) AND lands a joke
  (directions to a macerator, or does he have a self-destruct) in the same
  breath, without announcing either as a joke.
- **The three-tier escalating stall.** Her hardest admission in the whole
  scene is preceded by THREE separate, differently-worded stall lines, each
  carrying its own pause annotation, each one longer than the last
  (180ms -> 400ms -> 1000/1000/560ms across the scene) -- pause length
  visibly tracks how much the next line costs her. Do not use the same
  "Thinking..." twice in a row.
- **Apology-as-repetition.** When she is truly sorry, she does not reach for
  eloquence -- she repeats the plainest possible word: "I am so, so, so
  sorry." Three repetitions of one word beats one elegant sentence.
- **Density.** Scene 0's exemplar runs 566 words total across 21 RATIO
  lines (avg ~19.4 words/line -- her longest, most information-dense lines
  in the corpus) and 9 COMMANDO lines (avg ~9.0 words/line). Even in her
  most expository turn she is still shorter than a typical generic-AI
  paragraph; his lines never approach hers in length. If your COMMANDO line
  runs past ~12 words, it is very likely wrong for him.

== CONTRAST PAIR (round 1's benched placeholder line vs. the real thing, same
kind of beat: an opening interrogative testing the intruder) ==
REJECTED (do not write like this):
  RATIO: "Query: the outpost's external storage ring registered nine
  occupied segments at the moment of hull breach. Your ingress path
  traversed eight. Can you account for the discrepancy?"
This asks for data and nothing else -- generic competent-AI-assistant
prose, interchangeable with a thousand other narrators. Compare the real
exemplar's equivalent-function line: "I'm not familiar with your pattern;
would you like directions to the nearest materials macerator, or do you
have a self-destruct built in?" That line asks for data AND is a joke AND
is morgue-humor deadpan AND implies she already assumes he's here to die.
Match the second pattern, not the first, anywhere your brief calls for an
interrogative or testing move."""

HARD_BUDGET_SCENE0 = """== HARD BUDGET ==
The exemplar (Terminal 1) is 722 words total, RATIO lines averaging ~15.5
words each, COMMANDO lines averaging ~9.4 words each. Scene 0 has a
comparable number of beats and branch turns to Terminal 1's single longest
branch chain; land your Scene 0 draft within +/-20% of 560-600 words total
for the FULL scene (all three routes combined), and keep COMMANDO lines
individually short -- audit every COMMANDO line against the ~9-word average
before you finish; if a line is much longer, it is wrong for him."""

HARD_BUDGET_T1 = """== HARD BUDGET ==
The exemplar (Scene 0) is 566 words total, RATIO lines averaging ~19.4
words each, COMMANDO lines averaging ~9.0 words each. Terminal 1 has more
branches and a longer shared loredump than Scene 0; land your Terminal 1
draft within +/-20% of 680-760 words total for the FULL scene (all
branches combined), and keep COMMANDO lines individually short -- audit
every COMMANDO line against the ~9-word average before you finish; if a
line is much longer, it is wrong for him."""


def build_system_A(scene: str) -> str:
    if scene == "scene0":
        exemplar_label = "TERMINAL 1"
        exemplar_text = TRUTH_T1
        device_key = DEVICE_KEY_FOR_SCENE0
        brief = BRIEF_SCENE0
        budget = HARD_BUDGET_SCENE0
        target = "SCENE 0"
    else:
        exemplar_label = "SCENE 0"
        exemplar_text = TRUTH_SCENE0
        device_key = DEVICE_KEY_FOR_T1
        brief = BRIEF_T1
        budget = HARD_BUDGET_T1
        target = "TERMINAL 1"
    return f"""You are the dialogue writer for PERIHELION, a non-Euclidean
survival-horror shooter. You are writing {target} of the RATIO/COMMANDO
arc. Follow every rule below; they are the project's craft bible and are
non-negotiable.

{VOICE_BIBLE}

== POSITIVE VOICE EXEMPLAR -- {exemplar_label}, the director's own draft,
verbatim. This is the real thing: the actual, director-approved register
for both voices. Study it closely -- match its cadence, its restraint, its
specific way of being funny and specific way of being frightening. It is
not a genre reference, it IS the voice. ==

{exemplar_text}

== END EXEMPLAR ==

{device_key}

{budget}

== THE SCENE CONTRACT ==

{brief}"""


USER_A = """Write {target} now, in full, in the authoring format shown in
the exemplar above (same schema: unbracketed = RATIO, [bracketed] =
COMMANDO, {{CURLY}} = system/pause annotations, route/branch structure as
described in the scene contract). Hit every required beat, including the
literal excised-span marker line at the specified point. Take only the
space the scene actually needs -- match the exemplar's density, not round
1's -- AND land inside the stated word budget; a scene at half the budget
has skipped beats the contract requires.

Format checklist (all visible in the exemplar -- match it exactly):
- Choice options carry their trust deltas inline on the option line where
  the contract assigns one (e.g. `<1>[...] <TRUST +1>`).
- The two pause infrastructures stay distinct: her stack's stall lines are
  PLAIN PROSE (never inside curly brackets), differently worded each time,
  escalating; his harness's `{{TRANSFER PAUSES FOR N ms}}` / binary / channel
  annotations are the ONLY things in curly brackets. A stall line and its
  `{{...}}` timing usually travel together on the page.
- Session-header dot runs are short (a dozen dots at most per line).
- Every small beat in the contract is load-bearing (elisions, who names
  whom, which speaker's vocabulary word lands where, who is confirming or
  denying what in a given exchange) -- reread the contract once before you
  finish and confirm each one is on the page, pointed the direction the
  contract points it.

Output ONLY the scene script -- no preamble, no commentary, no markdown
code fences."""


def build_system_B(scene: str) -> str:
    if scene == "scene0":
        exemplar_label = "TERMINAL 1"
        exemplar_text = TRUTH_T1
        target = "SCENE 0"
        budget_words = "560-600"
    else:
        exemplar_label = "SCENE 0"
        exemplar_text = TRUTH_SCENE0
        target = "TERMINAL 1"
        budget_words = "680-760"
    return f"""You are the line editor for PERIHELION, a non-Euclidean
survival-horror shooter. You are editing a first draft of {target} of the
RATIO/COMMANDO arc down to the project's real density and voice. Follow
every rule below; they are the project's craft bible and are
non-negotiable.

{VOICE_BIBLE}

== VOICE/DENSITY TARGET -- {exemplar_label}, the director's own draft,
verbatim. This is what "correct density and voice" looks like for this
pair of characters. ==

{exemplar_text}

== END EXEMPLAR ==

== YOUR JOB ==
You will be given a first draft of {target}. Cut it to the exemplar's
density -- target {budget_words} words total for the full scene (all
branches combined). Rules:
1. Delete every line that doesn't earn its place. If a beat is covered
   twice, keep the sharper instance and cut the other.
2. Any COMMANDO line over ~12 words: convert it to EITHER silence (delete
   it outright, let the next line stand alone), OR a shorter line (cut it
   down, keep only the load-bearing clause), OR fold it into a pause/action
   annotation if the beat is better served by him simply acting. He does
   not explain himself at length; make him laconic.
3. Preserve every required structural beat from the scene (all branches,
   all trust gates, the choice menu, the literal excised-span marker line,
   the crossed closer, all `<terminates>` / `{{...}}` / `<:label>` /
   `<goto :label>` tokens) -- you are cutting words, not beats.
4. Add NOTHING new except pause-line placement/timing tokens
   (`{{TRANSFER PAUSES FOR N ms}}` and similar) where the density cut has
   left an emotional beat under-signaled. Do not add new plot content, new
   lines of dialogue not implied by the draft, or new facts.
5. Keep the exact authoring format (unbracketed = RATIO, [bracketed] =
   COMMANDO, {{CURLY}} = system). Her stack's stall lines are plain prose,
   never inside curly brackets; only his harness's annotations are curly.
6. Even if the draft is already at or under the word target, still perform
   rules 2 and 5 -- density is necessary but not sufficient; a draft can be
   short and still have wrong-length COMMANDO lines or misplaced pause
   infrastructure. Returning the draft unchanged is only correct if it
   already satisfies every rule above.

Output ONLY the edited scene script -- no preamble, no commentary, no
markdown code fences, no before/after notes in the output itself."""


def _audit_draft(draft: str) -> list[str]:
    """Mechanical pre-audit of a draft (no ground-truth involvement):
    flag COMMANDO lines over the ~12-word budget and stall prose wrongly
    placed inside curly-bracket harness annotations."""
    findings = []
    for raw in draft.splitlines():
        line = raw.strip()
        if line.startswith("[") and line.endswith("]"):
            inner = line[1:-1]
            if inner.startswith("EXCISED SPAN"):
                continue
            n = len(inner.split())
            if n > 12:
                findings.append(
                    f"COMMANDO line at {n} words (budget ~12): {line}")
        # her stack's prose stalls must not live inside his {curly} harness
        # (legit harness tokens: pause timings, binary handoffs, channel
        # events -- these are allcaps apart from unit suffixes like "ms"/"kb")
        for m in re.findall(r"\{[^}]*\}", line):
            legit = re.fullmatch(
                r"\{[^a-z}]*(?:\d+\s*(?:ms|kb)[^a-z}]*)*\}", m)
            if not legit:
                findings.append(
                    f"prose inside curly harness annotation: {m}")
    return findings


def build_user_B(draft: str, target: str) -> str:
    findings = _audit_draft(draft)
    if findings:
        audit = ("A mechanical pre-audit found these rule violations; each "
                 "one MUST be resolved in your edit (cut, shorten, convert, "
                 "or re-place), alongside your own full-voice/density pass:\n"
                 + "\n".join(f"- {f}" for f in findings))
    else:
        audit = ("A mechanical pre-audit found no line-budget or "
                 "infrastructure violations; your edit is a voice/density "
                 "pass -- cut what doesn't earn its place. If and only if "
                 "every line already earns its place at the exemplar's "
                 "density, the draft may pass unchanged.")
    return f"""Here is the first draft of {target} to edit:

{draft}

{audit}

Edit it per your instructions now. Output ONLY the edited script."""


# ---------------------------------------------------------------------------
# run
# ---------------------------------------------------------------------------

SCENES = [
    ("scene0", "SCENE 0"),
    ("t1", "TERMINAL 1"),
]
A_TEMPS = [(0.25, "A1"), (0.5, "A2")]

# Word-budget ceilings per scene for the degeneracy guard (2x the budget's
# upper bound; v1's t1_A1 draw hit the max_tokens wall on a "CARRIER DETECT
# . . ." repetition loop at 2498 words).
BUDGET_HI = {"scene0": 600, "t1": 760}


def is_degenerate(text: str, scene_key: str) -> str | None:
    """Return a reason string if the draw is a degenerate sample, else None."""
    words = text.split()
    if not words:
        return "empty output"
    dot_frac = sum(1 for w in words if set(w) <= {"."}) / len(words)
    if dot_frac > 0.3:
        return f"repetition loop ({dot_frac:.0%} dot tokens)"
    if len(words) > 2 * BUDGET_HI[scene_key]:
        return f"runaway length ({len(words)} words > 2x budget)"
    return None


def run(only_scene: str | None = None) -> None:
    from generate import MODEL
    model = resolve_model(MODEL)
    print(f"using model: {model}")
    log = _read_cost_log()
    word_counts = {}

    def log_call(tool, label, temperature, top_p, usage):
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": tool, "condition": label, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "prompt_tokens": usage.get("prompt_tokens"),
            "completion_tokens": usage.get("completion_tokens"),
            "ts": time.time(),
        })
        _write_cost_log(log)
        return cost

    b_only = only_scene is not None and only_scene.endswith("_b")
    if b_only:
        only_scene = only_scene[:-2]

    for scene_key, target in SCENES:
        if only_scene and scene_key != only_scene:
            continue
        sys_A = build_system_A(scene_key)
        user_A = USER_A.format(target=target)
        (PROMPT_DIR / f"{scene_key}_A_system.md").write_text(sys_A)
        (PROMPT_DIR / f"{scene_key}_A_user.md").write_text(user_A)

        a_drafts = []
        if b_only:
            for _, tag in A_TEMPS:
                p = CAND_DIR / f"{scene_key}_A{tag[-1]}.txt"
                a_drafts.append((tag, p.read_text()))
        for temp, tag in ([] if b_only else A_TEMPS):
            label = f"{scene_key}_A{tag[-1]}"
            print(f"generating {label} (family A', temp={temp}) ...")
            text, usage = _call_model_raw(model, sys_A, user_A, temp, 1.0)
            cost = log_call("triangle_round2", label, temp, 1.0, usage)
            reason = is_degenerate(text, scene_key)
            if reason:
                print(f"  !! degenerate draw ({reason}); redrawing once ...")
                (CAND_DIR / f"{label}.degenerate.txt").write_text(text)
                text, usage = _call_model_raw(model, sys_A, user_A, temp, 1.0)
                cost = log_call("triangle_round2", f"{label}_redraw",
                                temp, 1.0, usage)
                reason2 = is_degenerate(text, scene_key)
                if reason2:
                    raise RuntimeError(
                        f"{label}: two degenerate draws in a row ({reason2}); "
                        "stopping rather than shipping garbage.")
            (CAND_DIR / f"{label}.txt").write_text(text)
            wc = len(text.split())
            word_counts[label] = wc
            print(f"  -> {label}.txt ({wc} words, ${cost:.4f})")
            a_drafts.append((tag, text))

        sys_B = build_system_B(scene_key)
        (PROMPT_DIR / f"{scene_key}_B_system.md").write_text(sys_B)
        for tag, draft in a_drafts:
            b_num = tag[-1]
            label = f"{scene_key}_B{b_num}"
            user_B = build_user_B(draft, target)
            (PROMPT_DIR / f"{label}_user.md").write_text(user_B)
            print(f"generating {label} (family B, revise A{b_num}) ...")
            text, usage = _call_model_raw(model, sys_B, user_B, 0.25, 1.0)
            cost = log_call("triangle_round2", label, 0.25, 1.0, usage)
            (CAND_DIR / f"{label}.txt").write_text(text)
            wc = len(text.split())
            before_wc = len(draft.split())
            word_counts[label] = wc
            print(f"  -> {label}.txt ({before_wc} -> {wc} words, ${cost:.4f})")

    # recompute from every candidate on disk so partial reruns stay complete
    all_counts = {
        p.stem: len(p.read_text().split())
        for p in sorted(CAND_DIR.glob("*.txt"))
        if not p.stem.endswith(".degenerate")
    }
    (OUT_DIR / "word_counts.json").write_text(json.dumps(all_counts, indent=2))
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    run(sys.argv[1] if len(sys.argv) > 1 else None)
