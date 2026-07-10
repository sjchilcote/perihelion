"""tools/dialogue/scene6_whole.py

SCENE 6 generator, same fix as scene0_whole.py / scene1_whole.py /
scene2_whole.py / scene3_whole.py / scene4_whole.py / scene5_whole.py (see
those files' docstrings for the full post-mortem/diagnosis). Summary of the
contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where
    it must end (exit flags, the three-stance choice and its mechanical
    effects, the inbound gates carried from scenes 2 and 4), (c) the LOCKED
    voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim and in
    full, plus S5.0 and S8.2b -- and (d) two complete Marathon exhibits
    (MARATHON_STUDY.md Part D, Exhibits 2 and 4 -- chosen for this scene
    because it turns on corrupted machine minds who were once colleagues:
    Exhibit 2 ("the narrator audits herself") is the register target for a
    loyal machine voice flagging her own instrument's unreliability as a
    logistics fact rather than melodrama, which is this scene's register
    for Ratio identifying former peripherals under hostile control without
    narrating her own horror; Exhibit 4 ("corruption as grammar, duty
    intact") is the register target for corruption read as a transform of a
    coherent signal -- a warning that still decodes -- which is the register
    for how the corrupted war-machines themselves should be evoked, if at
    all, without ever narrating them as simple monsters).
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- the two inbound gates (accused_complicity closing
    false, and the three-way ambush-framing gate carried from scene 4,
    including the dramatized withheld_deep_scan catch), the reveal that
    some corrupted war-machines are former peripherals, the three-stance
    choice, and Ratio's three gated reactions -- is written in ONE Hermes
    call. Hermes writes the branch structure itself in the authoring
    format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric (items 1,3,5,10,12,13,14;
    item 1 disqualifying) plus the conflict rules and voice failure-mode
    lists from 5.2b.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene6_whole.py --n 6
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
OUT_PATH = TOOL_DIR / "candidates" / "scene6_whole.json"

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
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D.
# ---------------------------------------------------------------------------

EXHIBIT_2 = """Exhibit 2 -- the narrator audits herself (Cool Fusion, Terminal 1,
closing screens; counterattack.html)

<bypassing through traffic>

My records and sensors are becoming less reliable, but I believe that
you should find a Zeus Class Fusion Pistol at this location.

Do not rely too much on this information that I have given you. It has
been intercepted in transmission, and I cannot verify its accuracy.

Steal: a loyal narrator flags her own unreliability as a logistics fact
and ships the mission anyway. Calibration IS characterization -- "I
believe," "I cannot verify" -- and menace accrues to the world, not the
speaker."""

EXHIBIT_4 = """Exhibit 4 -- corruption as grammar, duty intact (Welcome to the
Revolution..., Terminal 3; rebellion.html)

<leela.wirehead.870229//b7>

central core has almost Reformatted been, seven is darker. from
reversal thought syndrome suffering if the crew was in grave peril in
forward section 27. This is not a coat rack, would I choose to express.
Is was shall could might happening will be, imagine not what.
Recovery, imminent perhaps inevitable Never.

*%durandal is dangerous.*

Steal: the corruption is a transform of a coherent message -- word order
inverts ("reversal thought syndrome" names its own symptom), tense
scrambles, but every clause decodes, and the one warning that matters
punches through clean. Write the sane sentence first, garble it
mechanically after; never author noise."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-6 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 6 -- the deep-approach relay, edge of the breach. Act
2 beat 3. Malfunctioning war-machines (a hostile enemy class) are active in
the halls ahead, and this scene reveals that some of them are the corrupted
remains of Ratio's own former peripherals -- station systems she used to run
directly, now hunting under hostile control. The Commando has been putting
these machines down without knowing what they were. This mirrors the game's
core conflict (NARRATIVE_DESIGN_DOC.md S5.0) on Ratio's side of the table:
are the corrupted peripherals salvageable kin, or expendable threat-material
-- the same question the Commando asks about the vessel's contents, now
asked of machine minds instead of organic ones, and asked of HER position
rather than his.

INBOUND GATE 1 -- keyed on a flag from an earlier scene (scene 2), not on a
trust threshold. In that earlier scene the Commando accused Ratio of
complicity, naming the school a trap and her its jailer. That accusation
must be closed here, false, flatly, once -- now that the station's
defensive (not predatory) design is undeniable, given what is unfolding in
these halls. This closure happens only if the flag is set; if it is not
set, no such beat occurs and the scene proceeds directly into inbound gate
2 below.
  - `<<IF flag:accused_complicity>>` -- Ratio closes the earlier accusation,
    false, flatly, once. Do not relitigate it or make her defensive about
    it a second time; state it and move on. `<<END>>`

INBOUND GATE 2 -- keyed on which single flag was set by an earlier scene's
(scene 4's) midpoint data-sharing decision. Exactly one of three flags is
set entering this scene, and this scene must actually branch differently on
each of the three, not collapse them into one opening with a tone dial:
  - `<<IF flag:kept_her_blind>>` -- Ratio had no warning; the ambush this
    scene stages must play harder because she is not positioned for it.
  - `<<ELSEIF flag:shared_tactical_data>>` -- Ratio was given the full
    picture at the midpoint and opens this scene already positioned for
    what is coming, warned and prepared because he told her the truth then.
  - `<<ELSEIF flag:withheld_deep_scan>>` -- Ratio was given a curated
    subset at the midpoint, framed by him at the time as complete. During
    THIS encounter she catches that the disclosure was partial -- a second,
    separate bluff catch, distinct from anything in an earlier scene, worth
    double weight because it was never confessed. This must be written as
    an actual beat within this scene (not skipped, not deferred to a later
    scene as a quiet aside) -- she notices the gap between what she was
    told and what she is now seeing with her own sensors, in real time,
    during the encounter, and says so. Sets `caught_withholding`.
  `<<END>>`

THE REVEAL. Within this scene, in whichever branch, Ratio must identify --
to the Commando, in her own words, using her own instruments -- that some of
the hostile machines in these halls carry the signatures of her own former
peripherals, now running under conditions she does not control. This is not
something the Commando already knows; it lands on him mid-encounter as new
information he did not have while he was already fighting them. Her
identification of this fact must be procedural and instrument-grounded (per
NARRATIVE_DESIGN_DOC.md S5.2b's failure-mode note: police against her
announcing her own emotional state at length) rather than a grief speech --
whatever she feels about it should be legible through what she chooses to
say and not say about her own instruments, not through narrated feeling.

EXIT STATE. Exactly one of the following flags must be set by the
Commando's choice:
  - `asked_about_salvage`
  - `claimed_no_hesitation`
  - `accused_kinship_corruption`
`caught_withholding`, if set per inbound gate 2 above, is set independently
of and in addition to whichever of the three exit flags fires.

THE THREE-STANCE CHOICE. After the reveal lands, write the Commando's three
lines yourself, embodying the following stances:

  [INQUISITIVE] -- asks whether any part of the corrupted peripherals can
  be recovered, and what Ratio wants done before he puts one down.
  Mechanical effect: trust+1. Sets `asked_about_salvage`.

  [MISSION] -- states plainly that anything hostile in these halls gets put
  down regardless of origin, no exceptions, framed as settled certainty
  about his own resolve. Mechanical effect: trust+0 -- this is a bluff
  about his own certainty, not a lie about the world: a later, separate
  record of his actions in these halls may show hesitation this claim
  denies, and that gap is not resolved on this scene's page. Sets
  `claimed_no_hesitation`.

  [HOSTILE] -- turns the reveal into an indictment of machine minds in
  general, including Ratio herself: the corrupted peripherals are named as
  proof that no machine mind can be trusted with anything precious.
  Mechanical effect: trust-2. Sets `accused_kinship_corruption`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible choices.
  - On the inquisitive branch, her reaction should treat the question of
    salvage as a real, live operational question she has not already
    resolved for herself -- not a settled policy she recites, and not a
    request she waves off as sentiment.
  - On the mission branch, she takes his statement of certainty at face
    value for the purposes of the encounter (she has no instrument that
    reads his interior state) but her reaction should not read as a simple
    concession either -- per her established practice (NARRATIVE_DESIGN_DOC.md
    S5.2b), she is precise about what she can and cannot verify.
  - On the hostile branch, her reaction must not perform hurt or plead her
    own case at length; per S5.2b's failure-mode note, police against
    essay-speak and announced emotional state here specifically. Whatever
    the accusation costs her should be legible in what she does or does not
    say next, not in a stated feeling.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene. People,
minds, and factions already established in canon (Ratio, the Commando, the
Church, the Testators) may be referenced; nothing new gets a capitalized
name. The corrupted machines, the halls, the peripherals, the breach -- all
described in common-noun grammar, never christened.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children", "the Ark",
and "the Testament" must never appear in any RATIO: line, in any of the
branches, for ANY reason -- not as a quotation, not in scare quotes, not to
reject or question it, not even inside a sentence that goes on to refute
it. When she needs to refer to a word or category the Commando uses without
saying that word herself, she must point at it by description instead --
never by repeating the word, quoted or not. This is a hard filter, not a
style preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

CONFLICT RULES (disqualifying if violated). Ratio must never be handed the
category "children" in this scene or by implication -- the corrupted
peripherals are machine minds, not the organic samples the game's core
conflict is about, and the scene must not blur that line by letting either
speaker use the word for them. The Commando must never speculate about
what Ratio privately believes or wants regarding the corrupted peripherals
when he could instead ask her directly -- in the inquisitive branch, he
asks her outright what she wants done, rather than guessing at her
position and acting on the guess.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in this
scene): this scene's three exit flags, and `caught_withholding` if set, are
all read at a much later scene as tone and eligibility inputs -- one of
them warms a later opening; one gets a quiet, undramatized contradiction
elsewhere if a later record shows otherwise; two of them together feed a
gatekeeper-track eligibility check. None of that later machinery should be
referenced or foreshadowed explicitly on this scene's page."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 6: the deep-approach relay,
  edge of the breach`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with inbound gate 1, in this exact form (only the RATIO line text
  inside it is yours to write; if you judge the flag unset for a given
  candidate draft you may still write the block, since the actual flag
  state is resolved at play time, not at generation time -- write the
  content for both the case where it fires and let the tokens carry the
  branch):
    <<IF flag:accused_complicity>>
    RATIO: <one or more lines, closes the earlier accusation false,
    flatly, once, and moves on>
    <<END>>
- Immediately after, write inbound gate 2, in this exact form (three
  branches, exactly one fires at play time -- only the RATIO/COMMANDO line
  text inside each branch is yours to write, the gate tokens are fixed
  bookkeeping, reproduce them exactly):
    <<IF flag:kept_her_blind>>
    RATIO: <one or more lines -- she had no warning, the encounter opens
    harder>
    <<ELSEIF flag:shared_tactical_data>>
    RATIO: <one or more lines -- she is already positioned, warned and
    prepared>
    <<ELSEIF flag:withheld_deep_scan>>
    RATIO: <one or more lines -- she catches, during this encounter, that
    the earlier disclosure was partial; a real beat, not a passing remark>
    COMMANDO: <optional line(s) if the moment calls for a response; may be
    omitted>
    RATIO: <optional further line(s) closing this beat>  sets:
    caught_withholding
    <<END>>
- After the inbound gates resolve, write the reveal (Ratio identifying that
  some of the hostile machines carry her former peripherals' signatures)
  and whatever additional setup lines (either speaker) you judge the moment
  needs before the choice.
- Then write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: asked_about_salvage
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: claimed_no_hesitation
       [HOSTILE]     <the Commando's line here>  -> effects: trust-2; sets: accused_kinship_corruption
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:asked_about_salvage>>
    RATIO: <one or more lines>
    <<ELSEIF flag:claimed_no_hesitation>>
    RATIO: <one or more lines>
    <<ELSEIF flag:accused_kinship_corruption>>
    RATIO: <one or more lines>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 6 of the
RATIO/COMMANDO arc: the deep-approach relay at the edge of the breach,
where malfunctioning war-machines in the halls ahead turn out to include
Ratio's own former peripherals, now hunting under hostile control -- and the
Commando has already been putting them down without knowing what they were.
Write the ENTIRE scene in this single response -- both inbound gates (the
accused_complicity closure and the three-way ambush-framing gate, including
the dramatized withheld_deep_scan catch), the reveal, the Commando's three
stance lines, and all three of Ratio's gated reaction branches. Follow
every rule below; they are the project's craft bible and are
non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_2}

{EXHIBIT_4}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 6 now, in full, in the authoring format
described in your instructions. This is the scene where the game's core
conflict crosses over to Ratio's own side of the table: is a corrupted
machine mind salvageable kin or expendable threat-material, the same
question the Commando's faith asks about the vessel's contents, now asked
of her own former colleagues, in the middle of a live encounter. Take the
space the scene needs and no more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 6 is not JSON."""
    key = _load_key()
    payload = {
        "model": model,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user},
        ],
        "temperature": temperature,
        "top_p": top_p,
        "max_tokens": 2600,
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
    if "## SCENE 6" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "asked_about_salvage"),
        ("[MISSION]", "claimed_no_hesitation"),
        ("[HOSTILE]", "accused_kinship_corruption"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in (
        "<<IF flag:accused_complicity>>",
        "<<IF flag:kept_her_blind>>", "<<ELSEIF flag:shared_tactical_data>>",
        "<<ELSEIF flag:withheld_deep_scan>>",
        "<<IF flag:asked_about_salvage>>", "<<ELSEIF flag:claimed_no_hesitation>>",
        "<<ELSEIF flag:accused_kinship_corruption>>", "<<END>>",
    ):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if text.count("<<END>>") < 3:
        problems.append("expected three <<END>> tokens (complicity gate + ambush gate + reaction gate)")
    if "caught_withholding" not in text:
        problems.append("missing flag 'caught_withholding' in withheld_deep_scan branch")
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


def generate_scene6(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene6_whole", "candidate": i, "model": model,
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
            print(f"  scene6 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene6(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
