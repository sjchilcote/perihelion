"""tools/dialogue/scene2_whole.py

SCENE 2 generator, same fix as scene0_whole.py / scene1_whole.py (see those
files' docstrings for the full post-mortem/diagnosis). Summary of the
contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where
    it must end (exit flags, the three-stance choice and its mechanical
    effects, the trust-threshold gate), (c) the LOCKED voice bible --
    NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim and in full, plus S5.0
    and S8.2b -- and (d) two complete Marathon exhibits (MARATHON_STUDY.md
    Part D, Exhibits 1 and 3 -- chosen for this scene because it is a
    first-contact/teaching relay in which restraint about loneliness under
    duty is exactly the register the "asked after her" beat needs).
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- the docent-relay opening, the trust>=1 optional
    warmer variant, all three of the Commando's stance lines, and Ratio's
    reaction -- is written in ONE Hermes call. Hermes writes the branch
    structure itself in the authoring format.
  - Six candidates at varied temperature; selection is a separate,
    subsequent step against the ALIVE rubric.

The API key is read at call time from `.openrouter_key` at the repo root
(or OPENROUTER_API_KEY) via generate._load_key, and is never printed or
logged -- only usage/cost numbers are recorded.

CLI:
    uv run python tools/dialogue/scene2_whole.py --n 6
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
OUT_PATH = TOOL_DIR / "candidates" / "scene2_whole.json"

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
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D. Exhibit 1
# (protocol-first introduction, courtesy doing double duty) and Exhibit 3
# (duty-handover economy, spends exactly two words on feeling) are the
# register targets for a first docent-relay scene about a station that is
# testing rather than resisting, and about a mind that has been alone for
# months and must not overspill about it.
# ---------------------------------------------------------------------------

EXHIBIT_1 = """Exhibit 1 -- Leela's first contact (Arrival, Terminal 1; arrival.html)

Marathon Emergency Systems Broadcast

Today at 0820 hours, the Marathon came under surprise attack from
unknown hostile forces. The Marathon has sustained serious damage.

At 0830 hours, alien forces boarded the Marathon. The current situation
is dire. All personnel are required to arm themselves and fight for
their lives.

<Posted 2794.7.3.14.08.39>

***INCOMING MESSAGE FROM LEELA***

Welcome to the Marathon. I am Leela, one of the two surviving
Artificial Intelligences aboard the Marathon. I have been severely
damaged, and am working to understand the current situation.

Find the teleport terminal located in the Hangar's control room. By
that time, I should have a better idea of what is going on.

***END MESSAGE***

Steal: the cold open is pure protocol -- an automated broadcast first,
the narrator second. Leela introduces herself by survivorship, damage
report, and current task, and issues a concrete mission within her first
forty words. "Welcome to the Marathon" does double duty as courtesy and
unintended gallows humor; she doesn't notice, which is the
characterization."""

EXHIBIT_3 = """Exhibit 3 -- Leela's pre-recorded farewell (Fire! Fire! Fire! Fire! Fire!,
Terminal 2; durandal.html)

<Leela Data Transfer Unsuccessful>
<Leela Program Pragma Ten>
Communication interruption cause: unknown
<Pre-Recorded Error Message Follows>

My original programming didn't prepare me for these kinds of attackers.
All of my functions will fail within a few minutes of this
transmission. I have one final chance to trick the oncoming viruses,
but it is unclear whether this attempt will be successful.

I have given instructions to Durandal as to the best defense of the
Marathon, but he is completely unstable and I fear that he is in the
Jealous stage of Rampancy.

Good Luck...

<End Pre-Recorded Message>

Steal: she wrote her own death notice in advance, in briefing register.
The chrome delivers the gut punch (<Pre-Recorded Error Message
Follows>) before the prose starts; she hedges her last hope ("it is
unclear whether"), completes the duty handover, and spends exactly two
words on feeling. This is the ceiling for "sane, loyal" writing -- copy
its economy, not its plot."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-2 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 2 -- the school's threshold relay, entry to Stratum
Two. Act 2 beat 1. First docent contact: the armory's first door, a relay
conversation carried between sorties, immediately following the Commando's
transit through the aperture (scene 1) into station proper.

START STATE. This scene is not gated on any specific flag from scenes 0 or
1 -- it opens directly on first docent contact. Ratio is explaining that the
station is TESTING him, not merely resisting him: the school he is now
entering runs assessments, not just defenses, and she is trying to convey
that distinction plainly, in her own idiom, before he reaches the armory's
first door. Ratio refers to what the Testator docents once taught using the
word "specimens" -- unaimed at the Commando himself, a habit of her own
vocabulary describing what the school's curriculum was originally for. This
scene is also the first point at which the Commando can choose to model
Ratio as a person rather than purely as a resource or an obstacle: he can
ask, unprompted by any mission need, about the months she has spent alone
since her outpost fell -- or he can decline to notice there is a "her" to
ask about at all. The word "specimens" does not move in this scene -- it is
not challenged into changing here, whichever stance plays; what moves,
instead, is only whether he has registered her as someone rather than
something to negotiate with.

TRUST-THRESHOLD VARIANT (no flag required, keyed on the trust score he
carries into this scene). Write this as a gate within the docent-relay
opening, before the three-stance choice: `<<IF trust>=1>>` her
introduction of the docent systems runs warmer, and she includes one
additional, optional line of station history she would otherwise have
withheld as unnecessary detail `<<END>>`. This gate must be present and
must actually add content on the warmer branch, not merely change tone
with no added line.

EXIT STATE. Exactly one of the following flags must be set by some line,
OR neither flag fires (the mission-focused branch is legal and sets
nothing):
  - `asked_after_her`
  - `accused_complicity`
This scene's outcome is read twice by later scenes: `asked_after_her` is
cited at a much later scene as the first time anyone asked Ratio about
herself; `accused_complicity` is read at a later scene, where it closes
false, flatly, once the station's protective (not predatory) design has
become undeniable. Whichever of the three stances plays, each of the
three exit conditions (flag set / flag set / no flag) must be clearly,
unambiguously distinguishable from the other two by which flag a line
sets or fails to set, not just in mood.

THE THREE-STANCE CHOICE. The scene must build to a point where Ratio's
explanation of the school-as-test naturally opens a three-stance choice
for the Commando -- something in what she says about the curriculum or
about her months alone must make all three of his possible replies
genuinely responsive, not dodges. Write his three lines yourself,
embodying the following stances:

  [INQUISITIVE] -- asks after Ratio directly: about the months alone since
  the fall, unprompted by any tactical or mission need. This is a genuine
  question, not a bluff, and should read as him noticing her as a person
  for the first time on the page, not as a scripted kindness. Mechanical
  effect: trust+1. Sets `asked_after_her`.

  [MISSION] -- keeps the exchange to tactical questions only: what the
  school tests for, what the armory's first door requires, nothing
  personal. Mechanical effect: trust+0. Sets nothing.

  [HOSTILE] -- names the school a trap and Ratio its jailer; accuses her
  of complicity in whatever she is steering him toward. Mechanical effect:
  trust-1. Sets `accused_complicity`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible lines. Each of the three reactions must be
distinguishable in KIND: being asked after herself, being kept at arm's
length on tactical footing only, and being accused of jailing him are
three different things happening to her, and her response to each must
show that difference in substance, not just in warmth level. On the
`asked_after_her` branch, do not have her overspill or narrate her own
emotional state at length -- consistent with the exhibit above, economy is
the craft: she may answer briefly and factually and let the restraint
itself carry the weight, rather than delivering a speech about loneliness.
On the `accused_complicity` branch, she should respond as someone who
knows the accusation is not true yet and cannot fully disprove it yet
either -- she does not concede it, but she also cannot resolve it this
scene; that resolution belongs to a later scene, once the station's design
is undeniable, not here.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children" and "the
Ark" and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation of his word, not in
scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category HE used without saying that word herself, she
must point at it by description instead -- e.g. "the category you
assert," "the word you choose," "whatever you mean to name" -- never by
repeating the word, quoted or not. This is a hard filter, not a style
preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene. People,
minds, and factions already established in canon (Ratio, the Commando, the
Church, the Testators) may be referenced; nothing new gets a capitalized
name. The docent systems, the school, the armory, any location or system
mentioned must be described in common-noun grammar (the docent hall, the
threshold relay, the armory's first door), never christened.

TRUST-RANGE NOTES. Only the trust>=1 threshold gate above fires within
this scene; no other numeric threshold applies here."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 2: the school's threshold
  relay, entry to Stratum Two`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open directly with Ratio's docent-relay lines (no opening-variant gate
  on any prior scene's flag is needed for this scene). Embed the
  trust-threshold gate inline, in this exact form, wherever it belongs in
  her opening explanation:
    <<IF trust>=1>>
    RATIO: <the one additional line of station history>
    <<END>>
- After the docent-relay opening (and its embedded trust gate) resolves,
  write the choice block formatted exactly as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: asked_after_her
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: (none)
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: accused_complicity
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:asked_after_her>>
    RATIO: <one or more lines -- her reaction to being asked after>
    <<ELSEIF flag:accused_complicity>>
    RATIO: <one or more lines -- her reaction to the accusation>
    <<ELSE>>
    RATIO: <one or more lines -- her reaction to the tactical-only exchange>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 2 of the
RATIO/COMMANDO arc: the first docent-relay contact at the threshold of the
school, where Ratio explains the station is testing him, not merely
resisting him, and where he first has the chance to notice there is a
person on the other end of the channel. Write the ENTIRE scene in this
single response -- the docent-relay opening with its embedded trust gate,
the Commando's three stance lines, and all three of Ratio's gated
reaction branches. Follow every rule below; they are the project's craft
bible and are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_1}

{EXHIBIT_3}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 2 now, in full, in the authoring format
described in your instructions. This is the first time the school
addresses him directly, and the first time anything in this exchange
gives him the option to notice there is a her, not just a system, on the
other end. Take the space the scene needs and no more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 2 is not JSON."""
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
    if "## SCENE 2" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "asked_after_her"),
        ("[MISSION]", None),
        ("[HOSTILE]", "accused_complicity"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag and flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in ("<<IF trust>=1>>", "<<IF flag:asked_after_her>>",
                "<<ELSEIF flag:accused_complicity>>", "<<ELSE>>", "<<END>>"):
        if tok not in text:
            problems.append(f"missing gate token {tok!r}")
    if text.count("<<END>>") < 2:
        problems.append("expected two <<END>> tokens (trust gate + reaction gate)")
    ratio_lines = [ln for ln in text.splitlines() if ln.strip().upper().startswith("RATIO:")]
    ratio_text = " ".join(ratio_lines).lower()
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


def generate_scene2(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene2_whole", "candidate": i, "model": model,
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
            print(f"  scene2 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene2(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
