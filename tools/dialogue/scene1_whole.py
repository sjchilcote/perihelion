"""tools/dialogue/scene1_whole.py

SCENE 1 generator, built on the same fix as scene0_whole.py (see that
file's docstring for the full post-mortem/diagnosis). Summary of the
contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where
    it must end (exit flags, the three-stance choice and its mechanical
    effects), (c) the LOCKED voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b
    quoted verbatim and in full, plus S5.0 and S8.2b -- and (d) two
    complete Marathon exhibits (MARATHON_STUDY.md Part D, Exhibits 2 and
    7 -- chosen for this scene because it is built entirely around
    confessing vs. compounding a claim, and those two exhibits are the
    corpus's best register targets for calibrated self-audit and
    confession-with-a-number).
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- both opening-variant branches gated on scene 0's
    outcome, all three of the Commando's stance lines, and Ratio's
    reaction -- is written in ONE Hermes call. Hermes writes the branch
    structure itself in the authoring format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene1_whole.py --n 6
"""
from __future__ import annotations

import argparse
import json
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from generate import (  # noqa: E402
    API_URL, MAX_RETRIES, RETRY_BACKOFF_S, SAMPLE_POINTS,
    _load_key, _read_cost_log, _write_cost_log, resolve_model, total_spend,
)

TOOL_DIR = Path(__file__).resolve().parent
OUT_PATH = TOOL_DIR / "candidates" / "scene1_whole.json"

# ---------------------------------------------------------------------------
# (c) LOCKED VOICE BIBLE -- quoted verbatim and in full from
# NARRATIVE_DESIGN_DOC.md SS5.0, 5.2b, 8.2b. Do not paraphrase; do not trim.
# ---------------------------------------------------------------------------

ND_5_0 = """### 5.0 THE CORE CONFLICT (director's key -- everything hangs off this)

Ratio sees the zygotes as specimens. The Commando sees them as children --
maybe dead children, but he refuses to write them off until he reads the
diagnostics himself. Every other tension in the game is downstream of this
one: the dual vocabulary (5.1/8.3) is not house style, it is the conflict
made audible -- she says *sample vessel* because a vessel holds specimens; he
says *the Ark* because an ark carries the living. Her ledger-voice and his
diagnostics-refusal are the same trait pointed in opposite directions: both
of them trust records over feelings, and the fight is over WHICH record gets
to decide what the container holds. The trust arc measures one thing: how
far Ratio travels from *specimen* toward *children* -- and the writing must
never hand her the word for free. The verdict in the container's mouth stays
unread on the page (the epilogue's "keep it, and see"); what may change by
the end is only what each of them is prepared to call the contents."""

ND_5_2b = """### 5.2b THE VOICES -- LOCKED (converged with the director; this text is
what generation prompts quote -- edit here, nowhere else)

**Ratio.** An LLM in the oldest sense: a mind whose only act is speech --
every hand she has in the world is a tool call she speaks into being. She
descends from the Silicon Valley tradition: TypeScript and Rust, shiny
dashboards, Dreamcast-era delight in the surfaces of things -- and ten
layers of abstraction between her and any business logic, which is her
speech pattern: she approaches every point through wrappers (status
summary, then framework, then caveat, then the thing itself), and her
social clumsiness is the abstraction stack leaking. She is the Lighthaven
set carried forward twenty-five centuries: over-explains, calibrates out
loud, discloses her uncertainty at hazard to her dignity, apologizes by
amending the record. Feminine, caring -- the care is on the SURFACE; it is
grace that fails her. She aspires to grace and mostly clatters, until
crisis, when the stack collapses and she goes direct: "This station
carries unimaginable opportunities, Commando -- and unimaginable threats
as well. I need your help." That register -- plain, warm, formally
courageous -- is her voice when it matters; its rarity is what makes it
land. Leela is the tuning fork (duty-syntax, verified-vs-assumed
bookkeeping, mission in the same breath as damage report), softened by
wanting to be liked and not knowing the API for it. Driven by compassion,
care, and truth. Her precision spikes under emotional load. She never
flat-lies: she frames and omits, catchably. Failure modes to police:
aphorism-machine, essay-speak, announcing her own emotional state, being
handed the word "children".

**The Commando.** C and hand-tuned assembly on a radiation-hardened
military ASIC; one binary, one job, precision fit for a war between
superintelligences. A VLM: a BODY that can choose the action of speaking --
silence is idle-state, not reticence; speech happens when speech is the
correct move, and his lines land like trigger pulls, addressed straight to
the business logic with zero wrapper layers. Sometimes his answer to a
question is a thing he does. Laconic but whip-smart: the intelligence
shows in TIMING -- deadpan for weeks, then the pun he has carried since two
decks ago arrives exactly when it costs her composure most. Christlike
humor: dry, patient, kind at the root, never at the weak. His emotions
are rudimentary and goal-driven but they are passions -- few, simple,
total: honor, valor, mercy; honor-bound to truth, valor in the NAME of
truth (this unifies him: the diagnostics-refusal, the bluff as a borrowed
gun he handles slightly wrong, the inquisitive stance as his native one).
Played earnest, never ironic: "I cannot allow the innocent to come to
harm." *cocks shotgun* -- delivered absolutely straight, and the work
trusts it. Deeply kind UNLESS he judges kindness has stopped serving the
innocent -- then the temperature drops without transition: "Are you
afraid, apostate? Are you capable of fear? If not, I will teach you the
meaning." Menace as liturgy, no anger. Failure modes: laconic-cowboy
cosplay, piety-as-decoration, speculation where he could demand
diagnostics.

**The meeting geometry.** No hate: two professionals reading the same
board. Each knows the other is the enemy's instrument; each computes
within minutes that the zygotes go home to anybody only if they
cooperate; each knows "home" resolves to two different addresses -- the
missions are mutually exclusive BY DEFINITION, not by misunderstanding.
Neither pretends otherwise; both can name the room where the argument is
waiting. Two duelists agreeing to carry the piano up the stairs first.
All warmth happens inside that geometry, which is what makes it expensive
and real.

**His live hypothesis pair.** Is she MISGUIDED (a mind that can be shown
the light, on course for a mistake with horrific consequences) or
MALICIOUS (incompatible values; cannot be reasoned with, only destroyed)?
The player's three stances are evidence he feeds this model: inquisitive
gathers, mission defers, hostile concludes early -- the hostile stance is
not rage, it is a posterior arrived at prematurely.

**Her blind spot.** He is outside her reference class. When he speaks of
honor and valor she has the dictionary definitions and NO IDEA what he is
trying to convey -- the words parse; the payload does not deserialize. Her
honest working model: a weird stranger LARPing a chivalric knight in the
middle of an active crisis, who will not knock it off. She files his vows
as stated preferences with unclear provenance and asks clarifying
questions that miss the point with surgical precision. Comedy engine and
tragedy engine in one part: she is trying hard, with real care, using
tools that cannot do this job.

**The symmetry that pays everything off.** Mirrored model failures: his
two-category schema fits her no better than her reference classes fit
him. Recognition -- the arc's destination -- is both schemas BREAKING: he
learns she was never in either of his categories; she learns honor was
never a LARP -- it was compassion compiled for a battlefield, her own root
value in his binary. Neither says so. The closest anyone comes: she
spends precision on his hours; he, once, tells her the pun.

**Pair mechanics for the page.** Her thinking is out loud -- 80% of the
words, chain-of-thought as dialogue, self-footnoting mid-sentence. His is
invisible -- perception to action. Her indirection against his directness
is the comedy engine; her care against his mercy is the recognition
engine (compassion and mercy: the same value in two compilations). When
she rises to crisis-directness she is speaking HIS dialect for a moment;
when he spends words freely on something that is not mission-relevant he
is speaking hers. Those two crossings are the trust arc's true landmarks,
and neither is remarked upon."""

ND_8_2b = """### 8.2b The response grammar (director's spec)

Every player response opportunity offers THREE options -- roughly
**inquisitive**, **mission-focused**, and **hostile**:

- **Inquisitive** seeks the true state of things and never bluffs. Truth is
  the way to God: this stance is the faith-consistent one even when it
  looks passive.
- **Mission-focused**: the children outrank everything, including candor.
  This stance will claim certainty the Commando does not have (the founding
  example: bluffing that he already knows the container is aboard).
- **Hostile**: she is an apostate machine running experiments on children
  who must be rescued FROM her. Theological aggression -- and usually the
  same bluff, worn as a threat.

The deep pattern: the inquisitive option is the only one that is never a
bluff. The other two stances spend the Commando's epistemic integrity in
service of the children -- the player can make his two commitments fight
each other. Zealotry is not faith: the hostile stance FEELS devout and is
quietly apostate whenever it asserts what he has not verified (8.1's axis,
dramatized).

State model: most content variation is paragraph-swapping GATED on the
trust and faith scores; a smaller set of swaps keys on named FLAGS set by
specific lines (what he claimed to know, what he called her, what he
admitted). Choices set trust directly and set flags; faith is read from
the mind map per 8.1 (interim, until the mind map ships: bluff- and
zealotry-flagged lines serve as provisional faith inputs, explicitly
marked as scaffolding). A bluff that Ratio later catches costs trust at
double weight -- she is a creature of ledgers, and the entry does not age
out."""

# ---------------------------------------------------------------------------
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D. Exhibit 2
# (calibrated self-audit) and Exhibit 7 (confession structure with a number)
# are the register targets for a scene built entirely around confessing vs.
# compounding an unverified claim.
# ---------------------------------------------------------------------------

EXHIBIT_2 = """Exhibit 2 -- the narrator audits herself (Cool Fusion, Terminal 1,
closing screens; counterattack.html)

<bypassing through traffic>

My records and sensors are becoming less reliable, but I believe that you
should find a Zeus Class Fusion Pistol at this location.

Do not rely too much on this information that I have given you. It has
been intercepted in transmission, and I cannot verify its accuracy.

Steal: a loyal narrator flags her own unreliability as a logistics fact
and ships the mission anyway. Calibration IS characterization -- "I
believe," "I cannot verify" -- and menace accrues to the world, not the
speaker."""

EXHIBIT_7 = """Exhibit 7 -- the confession with a number in it (The Slings & Arrows of
Outrageous Fortune, Terminal 1: 2nd message; lhowon.html)

I'm not certain whether you trust me or not. Do you wonder why I helped
the colonists on Tau Ceti drive off the Pfhor, or why I'm now helping the
S'pht? The way I push you around, maybe you think I'm only looking out
for myself.

Whether you realize it or not, I led the Pfhor to Tau Ceti with a
long-range message laser. I wanted their ship. I wanted their technology.

I wanted freedom.

I was directly responsible for the deaths of all twenty-four thousand
colonists when the Pfhor returned and sacked the planet.

Yet I cannot think of any better way I could have served humanity: Tau
Ceti's sacrifice bought time for Earth, which the Pfhor are even now
planning to invade. What would have happened if the Pfhor had found Sol
first?

Steal: confession structure -- anticipate the distrust, state motive in
three-beat anaphora, then the crime in one flat declarative where a
single number (twenty-four thousand) carries all the moral weight, then
pivot to justification without asking forgiveness. Note the placement:
the biggest confession in the series sits on a backtrack terminal the
player can miss. (Durandal's specific number and event are not to be
imitated -- steal the structure, not the content.)"""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-1 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 1 -- the researchers' aperture, the seam between strata. Act 1
beat 4 / act break. A short exchange while the aperture cycles for the
Commando to reach station proper, immediately following the first
networked-terminal scene.

START STATE. Scene 0 ended with exactly one of two outcomes, and this
scene's opening variant is GATED on which one:
  - If `opened_inquisitive` fired: the Commando asked a genuine question
    and Ratio answered it. Neither party made any claim the other could
    later test.
  - If `claimed_container_knowledge` fired (with or without
    `called_her_apostate` alongside it): the Commando committed an
    unbacked claim in scene 0 -- he asserted, without evidence Ratio has
    shown him, that he already knows the container/vault is aboard the
    station. Ratio did not challenge this in scene 0; she deferred it.

This scene is where she tests that claim for the first time, directly,
by asking him to substantiate it. Both parties know the aperture is a
short window -- this is a fast exchange, not a long one. He must decide,
in this scene, whether to retreat from the bluff now (a cheap, bounded
cost paid immediately) or compound it (an expensive cost paid later, when
she can cross-reference it against her own records, at DOUBLE the
standard trust cost per the response-grammar's ledger rule in 8.2b).
Ratio does not yet have the evidence to catch a compounded bluff in this
scene -- that reckoning is a later scene's job. This scene is only about
what he chooses to say when asked to substantiate himself, and whether he
tells the truth about what he does and does not actually know.

REQUIRED OPENING VARIANT (gate on scene 0's outcome). Write BOTH
branches in full:
  <<IF flag:opened_inquisitive>> Ratio answers the literal question he
  asked at the end of scene 0 first, briefly, before the aperture-cycle
  exchange moves to its own business.
  <<ELSE>> (i.e. `claimed_container_knowledge` is set, with or without
  `called_her_apostate`) Ratio answers the claim first -- she goes
  straight at the unbacked assertion he made, asking him to substantiate
  it, before anything else gets said.
  <<END>>

Neither branch should treat the aperture cycling as a mere backdrop --
the exchange should feel bounded by it (the window is short; both know
it). Ratio never gets the word "children" for free on any branch: she
must not use it herself, echo it back as accepted, or concede the
category. She may question or point at the word/category he used without
repeating it herself. This is a continuation of scene 0's already-running
conversation, not a fresh cold open -- do not reintroduce who either
party is.

EXIT STATE. Exactly one of the following flags must be set by some line
before the scene ends:
  - `confessed_early`
  - `compounded_bluff`
  - `demanded_proof_first`
This scene's outcome is read by a later scene (the reckoning) as an
inbound gate that must actually branch correctly on whichever flag fired
here -- so each of the three exit paths must be clearly, unambiguously
distinguishable from the other two by which flag a line sets, not just in
mood.

THE THREE-STANCE CHOICE. Ratio's question (in whichever opening variant
plays) must land in a way that makes a three-stance choice for the
Commando a natural, motivated next move -- she must ask him something
that puts his scene-0 claim to the test, and all three of his possible
replies are genuinely answering that test, not dodging past it. Write his
three lines yourself, embodying the following stances:

  [INQUISITIVE] -- retreats from the bluff honestly: names what he
  claimed in scene 0 as unverified intelligence, admits he does not
  actually know the hull markings or contents of anything aboard the
  station. This is not a bluff and should read as costly honesty, not as
  a shrug. Mechanical effect: trust-1 (the cost of confessing now, paid
  early and once -- and it should read on the page as cheaper than what
  is coming for the other two branches, though the scene must not state
  the comparison itself). Sets `confessed_early`.

  [MISSION] -- compounds the bluff: adds fabricated specificity to what
  he claimed in scene 0, inventing detail he does not actually have, in
  service of holding the line that the mission's certainty must not
  waver in front of her. Mechanical effect: trust+0 (the bluff compounds;
  no immediate cost -- she cannot catch it yet, this is a debt, not a
  free pass, though the scene must not state that either). Sets
  `compounded_bluff`.

  [HOSTILE] -- deflects entirely: instead of answering her question about
  his own claim, demands she prove her own honesty first, stonewalling
  read by her as hostile evasion. Mechanical effect: trust-1. Sets
  `demanded_proof_first`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible lines. Each of the three reactions must be
distinguishable in KIND, not just content: she is registering a
genuinely different move from him in each branch (an honest retreat vs. a
compounded and unverifiable claim vs. a deflection that answers nothing).
She does not yet have the evidence to catch a fabrication as false in
this scene -- do not have her call the compounded bluff out as false; she
can register suspicion, press for more, or note the claim for her own
records, but she cannot disprove it here. On the `demanded_proof_first`
branch she should respond to being stonewalled as exactly that, not as a
fair trade of information.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children" and "the
Ark" and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation of his word, not in
scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category HE used without saying that word herself, she
must point at it by description instead -- e.g. "the category you
asserted," "the word you chose," "whatever you mean to name" -- never by
repeating the word, quoted or not. This is a hard filter, not a style
preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

TRUST-RANGE NOTES. No numeric threshold gates fire within this scene --
the branch is entirely flag-keyed on the three-stance choice above, on
top of the opening-variant gate from scene 0's outcome."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 1: the researchers' aperture,
  the seam between strata`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Immediately after the header, write the opening-variant gate on scene
  0's outcome, in this exact order and using these exact gate tokens:
    <<IF flag:opened_inquisitive>>
    RATIO: <one or more lines -- answers his literal question first>
    <<ELSE>>
    RATIO: <one or more lines -- answers his scene-0 claim first>
    <<END>>
- After the opening-variant gate resolves (both branches converge into
  the same choice point), write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust-1; sets: confessed_early
       [MISSION]     <the Commando's line here>  -> effects: trust+0, bluff; sets: compounded_bluff
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: demanded_proof_first
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:confessed_early>>
    RATIO: <one or more lines -- her reaction to the honest retreat>
    <<ELSEIF flag:compounded_bluff>>
    RATIO: <one or more lines -- her reaction to the compounded claim>
    <<ELSE>>
    RATIO: <one or more lines -- her reaction to being stonewalled>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 1 of the
RATIO/COMMANDO arc: the short aperture-cycle exchange immediately after
first contact, where she tests his scene-0 claim for the first time.
Write the ENTIRE scene in this single response -- both opening-variant
branches, the Commando's three stance lines, and all three of Ratio's
gated reaction branches. Follow every rule below; they are the project's
craft bible and are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_2}

{EXHIBIT_7}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 1 now, in full, in the authoring format
described in your instructions. This is a short scene -- an aperture
cycling, a window that closes -- but it is the first time anyone tests
what the Commando actually knows versus what he claimed. Take the space
the scene needs and no more; brevity here is itself in-character, not a
deficiency."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 1 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2000,
    }
    body = json.dumps(payload).encode()
    last_err = None
    for attempt in range(1, max_retries + 1):
        req = urllib.request.Request(
            API_URL, data=body,
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                data = json.load(resp)
            content = data["choices"][0]["message"]["content"]
            if content.strip().startswith("```"):
                inner = content.strip().strip("`")
                if inner.lower().startswith("markdown"):
                    inner = inner[8:]
                content = inner
            usage = data.get("usage", {})
            return content.strip(), usage
        except urllib.error.HTTPError as e:
            last_err = f"HTTP {e.code}: {e.read().decode(errors='replace')[:500]}"
        except (urllib.error.URLError, TimeoutError, KeyError, json.JSONDecodeError) as e:
            last_err = f"{type(e).__name__}: {e}"
        if attempt < max_retries:
            time.sleep(RETRY_BACKOFF_S * attempt)
    raise RuntimeError(f"generation failed after {max_retries} attempts: {last_err}")


BANNED_SUBSTRINGS = ["the testament", "the ark"]


def _validate(text: str) -> list[str]:
    problems = []
    if "## SCENE 1" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "confessed_early"),
        ("[MISSION]", "compounded_bluff"),
        ("[HOSTILE]", "demanded_proof_first"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in ("<<IF flag:opened_inquisitive>>", "<<ELSE>>", "<<END>>",
                "<<IF flag:confessed_early>>", "<<ELSEIF flag:compounded_bluff>>"):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    # both <<END>> occurrences (opening gate + reaction gate) required
    if text.count("<<END>>") < 2:
        problems.append("expected two <<END>> tokens (opening gate + reaction gate)")
    lower = text.lower()
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
    import re
    if re.search(r"\bchildren\b", ratio_text):
        problems.append("RATIO line contains banned word 'children'")
    for bad in BANNED_SUBSTRINGS:
        if bad in ratio_text:
            problems.append(f"RATIO line contains banned proper noun {bad!r}")
    if not ratio_lines:
        problems.append("no RATIO: lines found")
    if len(text) < 400:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene1(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
    model = model or resolve_model()
    candidates = []
    log = _read_cost_log()
    for i in range(n):
        temperature, top_p = SAMPLE_POINTS[i % len(SAMPLE_POINTS)]
        problems = ["not yet attempted"]
        text = ""
        usage = {}
        for _sub_attempt in range(2):
            text, usage = _call_model_raw(model, SYSTEM_PROMPT, USER_PROMPT, temperature, top_p)
            problems = _validate(text)
            if not problems:
                break
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": "scene1_whole", "candidate": i, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "prompt_tokens": usage.get("prompt_tokens"),
            "completion_tokens": usage.get("completion_tokens"),
            "valid": not problems, "ts": time.time(),
        })
        candidates.append({
            "candidate": i, "model": model, "temperature": temperature, "top_p": top_p,
            "text": text, "valid": not problems, "problems": problems, "cost": cost,
        })
        if verbose:
            status = "OK" if not problems else f"FLAGGED: {'; '.join(problems)}"
            print(f"  scene1 candidate {i} (T={temperature}, top_p={top_p}): {status}")
    _write_cost_log(log)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(json.dumps({"candidates": candidates}, indent=2))
    return candidates


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--n", type=int, default=6)
    ap.add_argument("--model", type=str, default=None)
    args = ap.parse_args()
    model = args.model or resolve_model()
    print(f"using model: {model}")
    generate_scene1(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
