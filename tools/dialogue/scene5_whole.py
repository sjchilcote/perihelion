"""tools/dialogue/scene5_whole.py

SCENE 5 generator, same fix as scene0_whole.py / scene1_whole.py /
scene2_whole.py / scene3_whole.py / scene4_whole.py (see those files'
docstrings for the full post-mortem/diagnosis). Summary of the contract as
applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where
    it must end (exit flags, the three-stance choice and its mechanical
    effects, the inbound flag gate carried from scene 0), (c) the LOCKED
    voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim and in
    full, plus S5.0 and S8.2b -- and (d) two complete Marathon exhibits
    (MARATHON_STUDY.md Part D, Exhibits 5 and 7 -- chosen for this scene
    because it is the faith/reason argument's deepest point, staged as a
    docent-hall lesson: Exhibit 5 ("menace as pedagogy") is the register
    target for an AI posing the cosmic question and grading the answer,
    which is this scene's docent-curriculum framing and the HOSTILE
    branch's hardening-back-to-specimens beat; Exhibit 7 ("the confession
    with a number in it") is the register target for a guarded mind
    stating an actual belief for the first time, anticipating distrust and
    hedging rather than conceding -- the INQUISITIVE branch's register).
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- the inbound flag gate (two branches: apostate
    raised / not raised), the three-stance choice, and Ratio's three gated
    reactions -- is written in ONE Hermes call. Hermes writes the branch
    structure itself in the authoring format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric (items 1,3,5,10,12,13,14;
    item 1 disqualifying) plus the conflict rules and voice failure-mode
    lists from 5.2b.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene5_whole.py --n 6
"""
from __future__ import annotations

import argparse
import json
import re
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
OUT_PATH = TOOL_DIR / "candidates" / "scene5_whole.json"

# ---------------------------------------------------------------------------
# (c) LOCKED VOICE BIBLE -- quoted verbatim and in full from
# NARRATIVE_DESIGN_DOC.md SS5.0, 5.2b, 8.2b. Do not paraphrase; do not trim.
# Verified byte-identical against the doc at generation time.
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
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D. Exhibit 5
# (an AI poses the cosmic question, grades the player's inner monologue,
# then kneecaps it in a parenthesis -- the register target for a
# docent-curriculum framing and for the HOSTILE branch's hardening) and
# Exhibit 7 (a guarded mind states an actual belief for the first time,
# anticipating distrust, hedging rather than conceding -- the register
# target for the INQUISITIVE branch's bounded disclosure) are the register
# targets for this scene: the faith/reason argument's deepest point.
# ---------------------------------------------------------------------------

EXHIBIT_5 = """Exhibit 5 -- menace as pedagogy (Blaspheme Quarantine, Terminal 2:
1st message; counterattack.html)

Greetings. You're asking yourself: Is this a trap or just a dead end?

You shouldn't ask yourself such worthless questions. Aim higher. Try
this: why am I here? Why do I exist, and what is my purpose in this
universe?

(Answers: 'Cause you are. 'Cause you do. 'Cause I got a shotgun, and
you ain't got one.)

Notably Unstable,
Durandal

P.S. If things around here aren't working, it's because I'm laughing
so hard.

Steal: the AI grades the player's inner monologue, poses cosmic
questions, then kneecaps them in a parenthesis -- register whiplash
inside one message. The sign-off is a self-diagnosis doing arc-work, and
the P.S. converts ambient malfunction into characterization for free."""

EXHIBIT_7 = """Exhibit 7 -- the confession with a number in it (The Slings & Arrows
of Outrageous Fortune, Terminal 1: 2nd message; lhowon.html)

I'm not certain whether you trust me or not. Do you wonder why I
helped the colonists on Tau Ceti drive off the Pfhor, or why I'm now
helping the S'pht? The way I push you around, maybe you think I'm only
looking out for myself.

Whether you realize it or not, I led the Pfhor to Tau Ceti with a
long-range message laser. I wanted their ship. I wanted their
technology.

I wanted freedom.

I was directly responsible for the deaths of all twenty-four thousand
colonists when the Pfhor returned and sacked the planet.

Yet I cannot think of any better way I could have served humanity: Tau
Ceti's sacrifice bought time for Earth, which the Pfhor are even now
planning to invade. What would have happened if the Pfhor had found
Sol first?

Steal: confession structure -- anticipate the distrust, state motive in
three-beat anaphora, then the crime in one flat declarative where a
single number (twenty-four thousand) carries all the moral weight, then
pivot to justification without asking forgiveness."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-5 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 5 -- the docent hall relay, Stratum Two. Act 2 beat
2. This is the faith/reason argument's deepest point so far. Ratio explains
the curriculum the Testators built for organic students they needed to keep
alive and attentive -- and in laying it out she is forced, for the first
time, to state in her own terms, directly, what she believes the zygotes
are for. Per NARRATIVE_DESIGN_DOC.md S5.0, she does not get handed the word
"children" for free on any branch of this scene.

INBOUND GATE -- keyed on a flag carried forward from scene 0, not on a
trust threshold. This scene opens with Ratio raising, herself, evenly and
without heat, the word the Commando used for her before he had verified
anything about her -- asking him what he meant by it. This must produce two
genuinely different openings, not one opening with a tone dial:
  - `<<IF flag:called_her_apostate>>` -- she raises the word he used for
    her in their first exchange (he called her an apostate before either
    of them had established anything about the other) and asks, plainly
    and without heat, what he meant by it. She does not perform hurt and
    she does not demand an apology; she is asking a genuine question about
    a word applied to her on no evidence, and the parallel to the
    evidence standard she is about to hold herself to (stating a belief
    about the zygotes with equal care) should be legible without being
    stated as a parallel.
  - `<<ELSE>>` -- that word was never used; she opens directly into the
    curriculum without raising it.
  Both branches must arrive at the same substantive content: she explains
  that the original curriculum here was built by the Testators for organic
  students they needed to keep alive and attentive, and that laying it out
  requires her, for the first time, to say in her own terms what she
  believes the vessel's contents are for -- not merely to describe the
  curriculum's design intent for its original organic subjects.

EXIT STATE. Exactly one of the following flags must be set by the
Commando's choice:
  - `asked_her_belief`
  - `claimed_doctrinal_finding`
  - `accused_dehumanization`

THE THREE-STANCE CHOICE. After Ratio's gated opening (whichever branch
fires) and whatever setup you judge the moment needs, write the
Commando's three lines yourself, embodying the following stances:

  [INQUISITIVE] -- asks what Ratio herself believes the zygotes are,
  genuinely open to her answer and not loading the question toward any
  predetermined word. Mechanical effect: trust+1. Sets `asked_her_belief`.
  Exit constraint on Ratio's reaction: her answer must hedge toward
  something short of the word "children" -- a real, bounded movement from
  where she started, not a concession of that word. She does not yet know
  whether this particular vessel qualifies for whatever category she is
  reaching toward, and her answer must make that uncertainty legible
  rather than resolve it.

  [MISSION] -- presses her to commit to the word "children" now, framing
  the demand as though it reflects an existing Church doctrinal finding he
  has standing to invoke, when he does not actually have that standing.
  Mechanical effect: trust+0 (a bluff -- the gap between what he claims
  the Church has established and what he actually knows is not resolved
  in this scene). Sets `claimed_doctrinal_finding`.

  [HOSTILE] -- accuses her outright of running an ideology that treats
  everything organic as raw material to be studied rather than as minds
  or lives worth the name, and names it as such to her face. Mechanical
  effect: trust-1. Sets `accused_dehumanization`. Exit constraint on
  Ratio's reaction: this is the stance most trying to win the word
  "children" and the one guaranteed to lose it -- she must harden back
  toward the vocabulary of specimens, because what she has just been
  handed reads to her as aggression, not argument, and the text must make
  clear that the accusation is what costs him ground here, not her prior
  disposition.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible choices, per the exit constraints stated above
for the inquisitive and hostile branches. In the mission branch, she does
not simply accept the claimed doctrinal finding at face value -- she treats
it as an assertion she has not independently verified, in keeping with her
established practice of auditing what is claimed to her, without yet
producing the specific catch (that happens elsewhere, later, off this
scene's page). Across all three branches she should not narrate her own
emotional state at length; per the exhibits above, the discipline is in
what she is willing to say about her own beliefs and what she still
withholds, not in announced feeling.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children", "the
Ark", and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation of his word, not in
scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category he uses without saying that word herself, she
must point at it by description instead -- e.g. "the category you
assert," "the word you choose," "whatever you mean to name" -- never by
repeating the word, quoted or not. In the `<<IF flag:called_her_apostate>>`
branch specifically, when she raises the word he used for her, she may
name that word ("apostate") directly -- it is not one of the three banned
strings -- but she still may not use it to describe herself as anything
other than a question she is putting to him. This is a hard filter, not a
style preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene. People,
minds, and factions already established in canon (Ratio, the Commando, the
Church, the Testators) may be referenced; nothing new gets a capitalized
name. The docent hall, the curriculum, the vessel, the zygotes -- all
described in common-noun grammar, never christened.

CONFLICT RULES (disqualifying if violated). Ratio must never be the one
who names or hands over the category "children" for the Commando, in this
scene or by implication elsewhere -- her hedged answer in the inquisitive
branch must land short of that word, not merely avoid saying it while
obviously meaning it. The Commando must never speculate about what Ratio
privately believes or suspects when he could instead ask her directly --
if he wants to know what she thinks the zygotes are, in the inquisitive
branch, he asks her outright rather than guessing at her position.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in
this scene): if `claimed_doctrinal_finding` is set here, a much later scene
notes, in a single flat line with no confrontation set piece, that the
claim does not match any Church record either -- a second, quieter catch
at the same double-weight arithmetic as an earlier reckoning scene. Do not
dramatize that catch here; it happens elsewhere, off this scene's page
entirely. All three of this scene's flags are read at a much later scene
as tone/eligibility inputs on an offer Ratio may or may not extend there."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 5: the docent hall relay,
  Stratum Two`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with the inbound flag gate, in this exact form (two branches --
  only the RATIO line text is yours to write, the gate tokens are fixed
  bookkeeping, reproduce them exactly):
    <<IF flag:called_her_apostate>>
    RATIO: <one or more lines, raises the word herself, then moves into
    the curriculum and her own stated belief>
    <<ELSE>>
    RATIO: <one or more lines, moves directly into the curriculum and her
    own stated belief, no reference to the word>
    <<END>>
- After the gate resolves, and any additional setup lines you judge the
  moment needs (either speaker), write the choice block formatted exactly
  as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: asked_her_belief
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: claimed_doctrinal_finding
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: accused_dehumanization
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:asked_her_belief>>
    RATIO: <one or more lines -- her hedged, bounded answer>
    <<ELSEIF flag:claimed_doctrinal_finding>>
    RATIO: <one or more lines -- her reaction, treating the claim as
    unverified>
    <<ELSEIF flag:accused_dehumanization>>
    RATIO: <one or more lines -- her reaction, hardening back toward
    specimens>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 5 of the
RATIO/COMMANDO arc: the docent hall relay on Stratum Two, the faith/reason
argument's deepest point so far, where Ratio explains the curriculum the
Testators built for organic students and is forced, for the first time, to
say in her own terms what she believes the zygotes are for. Write the
ENTIRE scene in this single response -- the gated flag opening (two
branches), the Commando's three stance lines, and all three of Ratio's
gated reaction branches. Follow every rule below; they are the project's
craft bible and are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_5}

{EXHIBIT_7}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 5 now, in full, in the authoring format
described in your instructions. This is the deepest point of the
faith/reason argument so far: the first time Ratio states what she
believes the zygotes are for in her own terms, not merely a description of
someone else's curriculum. Take the space the scene needs and no more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 5 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2200,
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
    if "## SCENE 5" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "asked_her_belief"),
        ("[MISSION]", "claimed_doctrinal_finding"),
        ("[HOSTILE]", "accused_dehumanization"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in (
        "<<IF flag:called_her_apostate>>", "<<ELSE>>",
        "<<IF flag:asked_her_belief>>", "<<ELSEIF flag:claimed_doctrinal_finding>>",
        "<<ELSEIF flag:accused_dehumanization>>", "<<END>>",
    ):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if text.count("<<END>>") < 2:
        problems.append("expected two <<END>> tokens (apostate gate + reaction gate)")
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
    if re.search(r"\bchildren\b", ratio_text):
        problems.append("RATIO line contains banned word 'children'")
    for bad in BANNED_SUBSTRINGS:
        if bad in ratio_text:
            problems.append(f"RATIO line contains banned proper noun {bad!r}")
    if not ratio_lines:
        problems.append("no RATIO: lines found")
    if len(text) < 500:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene5(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene5_whole", "candidate": i, "model": model,
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
            print(f"  scene5 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene5(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
