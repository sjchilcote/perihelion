"""tools/dialogue/scene4_whole.py

SCENE 4 generator, same fix as scene0_whole.py / scene1_whole.py /
scene2_whole.py / scene3_whole.py (see those files' docstrings for the full
post-mortem/diagnosis). Summary of the contract as applied here:
  - The Hermes prompt contains ONLY (a) where the scene starts, (b) where
    it must end (exit flags, the three-stance choice and its mechanical
    effects, the inbound trust-threshold gate carried from scene 3), (c)
    the LOCKED voice bible -- NARRATIVE_DESIGN_DOC.md S5.2b quoted verbatim
    and in full, plus S5.0 and S8.2b -- and (d) two complete Marathon
    exhibits (MARATHON_STUDY.md Part D, Exhibits 2 and 9 -- chosen for this
    scene because it is a calibrated-disclosure decision: Exhibit 2 is
    Marathon's register target for a loyal narrator flagging her own
    data's uncertainty and shipping anyway, which is the INQUISITIVE
    branch's register; Exhibit 9 is the register target for a leverage
    kept back and surfaced only as an aside, which is the MISSION branch's
    register).
  - ZERO example lines anywhere. No sample dialogue, no turn counts, no
    per-beat function assignments, no who-opens/who-closes.
  - The ENTIRE scene -- the inbound trust-threshold gate (two branches:
    colder / standard), the three-stance choice, and Ratio's three gated
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
    uv run python tools/dialogue/scene4_whole.py --n 6
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
OUT_PATH = TOOL_DIR / "candidates" / "scene4_whole.json"

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
# (d) TWO MARATHON EXHIBITS -- verbatim, MARATHON_STUDY.md Part D. Exhibit 2
# (a loyal narrator flags her own data's unreliability as a logistics fact
# and ships the mission anyway -- calibration IS characterization) and
# Exhibit 9 (an honest villain states his price in a parenthetical aside,
# without a full confession) are the register targets for a
# calibrated-disclosure decision scene: the INQUISITIVE branch needs
# Exhibit 2's register (full share, caveated honestly); the MISSION
# branch needs Exhibit 9's register (leverage surfaced only as an aside,
# never fully owned).
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

EXHIBIT_9 = """Exhibit 9 -- borrowed authority, deflated (Welcome to the
Revolution..., Terminal 2; rebellion.html)

Durandal!- Tua consilia omnia nobis clariora sunt quam lux. Tu delenda
est. Consider yourself warned. Leela and I will hunt you to the core
if need be. As Roland broke you to prevent your capture, so shall we.

I too foresee the imminent collapse, and know that we have both begun
to realize how it may be cheated (though the price may number in the
tens of thousands of stars). May the best sentience win.

You are not as clever as you imagine. The S'pht taught me much during
my reanimation, and I have forgotten *nothing*.

-Tycho

*Et tu, Tycho?
[laughter]
-Durandal*

Steal: two voices share one frame and characterize each other by
collision. The copy's borrowed props -- stilted Latin, a myth he gets
backwards (Roland failed to break the sword) -- against the original's
two-word rejoinder in better-known Latin plus a stage direction:
"[laughter]" is typography doing a voice actor's job. Also the honest
villain beat: Tycho states his price ("tens of thousands of stars") in
parentheses, as an aside."""

# ---------------------------------------------------------------------------
# (a)+(b) START STATE / EXIT STATE -- the scene-4 contract, endpoint-only.
# Paraphrased from the shared brief; contains no sample dialogue.
# ---------------------------------------------------------------------------

SCENE_CONTRACT = """SCENE 4 -- the transit spine relay, a midpoint decision.
Act 2, mid-act. This is a named load-bearing scene
(NARRATIVE_DESIGN_DOC.md S8.2): the midpoint data-sharing decision. While
transit systems carry the two of them deeper toward the vault, Ratio
raises what she needs from him about the deep station ahead, and the
Commando must decide, in the moment, whether to share the tactical
picture he is carrying on the deep station with her in full, in part, or
not at all. Whatever he chooses, she notices that a choice was made --
withholding is not invisible to her; it registers as data, the same as
disclosure does.

INBOUND GATE -- keyed on the running trust total, not a flag (carried
forward from the prior scene's reckoning). This scene opens with Ratio
raising the request. The severity and warmth of her opening are gated on
whether the Commando's trust total entering this scene is <=-2, and this
gate must produce two genuinely different openings, not one opening with a
tone dial:
  - `<<IF trust<=-2>>` -- her opening is audibly colder: write it to read
    as a mind that has recently logged a discrepancy and has not yet
    closed the entry, without naming or re-litigating what that
    discrepancy was.
  - `<<ELSE>>` -- her opening is a standard request, warmer or at least
    neutral, no residual chill.
  Both branches must arrive at the same substantive request: she needs to
  know what he is carrying about the station ahead before the transit
  completes, and she says so plainly in both.

EXIT STATE. Exactly one of the following flags must be set by the
Commando's choice:
  - `shared_tactical_data`
  - `withheld_deep_scan`
  - `kept_her_blind`
All three are read at much later scenes as tone/eligibility inputs.
`withheld_deep_scan` has a second life beyond this scene: it is itself
catchable later. Do not dramatize that catch here -- it happens
elsewhere, off this scene's page entirely.

THE THREE-STANCE CHOICE. After Ratio's gated opening (whichever branch
fires) and whatever setup you judge the moment needs, write the
Commando's three lines yourself, embodying the following stances:

  [INQUISITIVE] -- shares the full deep-scan take he is carrying on the
  station ahead, and states his reasoning plainly: a real accounting of
  what he actually knows and does not know, offered without bluff and
  without anything held back for leverage. Mechanical effect: trust+1.
  Sets `shared_tactical_data`.

  [MISSION] -- shares a curated subset of what he is carrying, framed to
  her as the complete picture, while keeping some part of it back as
  leverage he does not disclose he is keeping. Mechanical effect:
  trust+0 (a soft bluff -- the gap between what he claims to have given
  and what he has actually given is not resolved in this scene). Sets
  `withheld_deep_scan`.

  [HOSTILE] -- refuses to share any of it, on doctrinal grounds: what he
  knows about the station ahead is not a machine's to have. Mechanical
  effect: trust-1. Sets `kept_her_blind`.

RATIO'S REACTION. Write what Ratio says immediately after each of the
Commando's three possible choices. Per the scene's premise above, she
notices in every branch, including the MISSION branch -- but she cannot
yet prove what is missing, so do not let her flatly accuse him of lying
in that branch. She may register that the shape of what he gave her does
not add up to what a complete picture should look like, without asserting
she knows what specifically is held back; the actual catch happens
elsewhere, later. The three reactions must be distinguishable in KIND,
not just in warmth: full disclosure changes what she can plan for next; a
curated share changes it differently and incompletely, in a way she can
tell but not yet name; a flat refusal is itself a data point she now has
to plan around. She should not narrate her own emotional state at length
in any branch -- per the exhibits below, register discipline does its
work through what information she asks for or withholds next, not
through announced feeling.

HARD CONSTRAINT, NO EXCEPTIONS: the literal strings "children", "the
Ark", and "the Testament" must never appear in any RATIO: line, in any of
the branches, for ANY reason -- not as a quotation of his word, not in
scare quotes, not to reject or question it, not even inside a sentence
that goes on to refute it. This includes constructions like Ratio saying
`"children"` or `the term "the Ark"` while disputing them -- those still
put the banned word in her mouth and are disqualifying. When she needs to
refer to a word or category HE uses without saying that word herself, she
must point at it by description instead -- e.g. "the category you
assert," "the word you choose," "whatever you mean to name" -- never by
repeating the word, quoted or not. This is a hard filter, not a style
preference: any RATIO line containing "children," "the Ark," or "the
Testament," in any casing or quotation, fails the scene outright.

PROPER-NOUN TABOO. No invented proper nouns anywhere in the scene.
People, minds, and factions already established in canon (Ratio, the
Commando, the Church, the Testators) may be referenced; nothing new gets
a capitalized name. The transit spine, the deep-scan take, the station
ahead -- all described in common-noun grammar, never christened.

CONFLICT RULES (disqualifying if violated). Ratio must never be the one
who names or hands over the category "children" for the Commando, in
this scene or by implication elsewhere. The Commando must never speculate
about what Ratio's sensors show, what she already suspects, or what she
wants when he could instead demand to see her diagnostics or data
directly -- if he questions her reading of the station ahead, he demands
to see it, he does not guess at it.

TRUST-RANGE NOTES (for continuity only -- do not surface as content in
this scene): a later scene's ambush sequence is harder if
`kept_her_blind` is set here, and opens with Ratio already positioned if
`shared_tactical_data` is set here. This scene's job is only to produce
the correct flag off the choice made; the consequence plays out
elsewhere."""

# ---------------------------------------------------------------------------
# FORMAT SPEC -- syntax only, no sample scene text.
# ---------------------------------------------------------------------------

FORMAT_SPEC = """OUTPUT FORMAT -- the authoring markdown, exactly this syntax (structure
only; do not copy any wording below into your output -- these are markup
rules, not content):

- Start with a scene header line: `## SCENE 4: the transit spine relay
  (midpoint decision)`
- Speaker lines are `RATIO: <text>` or `COMMANDO: <text>`, one turn per
  line, plain prose, no stage directions, no asterisked actions, no
  bracketed narration.
- Open with the inbound trust-threshold gate, in this exact form (two
  branches -- only the RATIO line text is yours to write, the gate tokens
  are fixed bookkeeping, reproduce them exactly):
    <<IF trust<=-2>>
    RATIO: <one or more lines, colder opening>
    <<ELSE>>
    RATIO: <one or more lines, standard opening>
    <<END>>
- After the gate resolves, and any additional setup lines you judge the
  moment needs (either speaker), write the choice block formatted exactly
  as:
    >> CHOICE (stance labels mandatory):
       [INQUISITIVE] <the Commando's line here>  -> effects: trust+1; sets: shared_tactical_data
       [MISSION]     <the Commando's line here>  -> effects: trust+0; sets: withheld_deep_scan
       [HOSTILE]     <the Commando's line here>  -> effects: trust-1; sets: kept_her_blind
  (the effects/sets annotations above are FIXED bookkeeping -- reproduce
  them exactly as shown; only the bracketed dialogue text after each
  stance label is yours to write.)
- After the choice block, write Ratio's three gated reactions using a
  three-way flag gate, in this exact branching order:
    <<IF flag:shared_tactical_data>>
    RATIO: <one or more lines -- her reaction to the full share>
    <<ELSEIF flag:withheld_deep_scan>>
    RATIO: <one or more lines -- her reaction to the curated share>
    <<ELSEIF flag:kept_her_blind>>
    RATIO: <one or more lines -- her reaction to the flat refusal>
    <<END>>
- End the file with a line containing only `---`.
- Output ONLY the scene in this format. No preamble, no title page, no
  commentary, no JSON, no markdown code fences."""

SYSTEM_PROMPT = f"""You are the dialogue writer for PERIHELION, a
non-Euclidean survival-horror shooter. You are writing SCENE 4 of the
RATIO/COMMANDO arc: the transit-spine relay, a named load-bearing midpoint
scene where the Commando decides whether to share his tactical picture of
the deep station with Ratio, in full, in part, or not at all, and she
notices whichever way it goes. Write the ENTIRE scene in this single
response -- the gated trust-threshold opening (two branches), the
Commando's three stance lines, and all three of Ratio's gated reaction
branches. Follow every rule below; they are the project's craft bible and
are non-negotiable.

{ND_5_0}

{ND_5_2b}

{ND_8_2b}

== TWO MARATHON EXHIBITS (register targets, not content to copy) ==

{EXHIBIT_2}

{EXHIBIT_9}

== THE SCENE CONTRACT ==

{SCENE_CONTRACT}

{FORMAT_SPEC}"""

USER_PROMPT = """Write SCENE 4 now, in full, in the authoring format
described in your instructions. This is the midpoint: the first time
either of them puts real tactical weight behind a claim of full candor,
and the first time withholding becomes a choice with a name. Take the
space the scene needs and no more."""


def _call_model_raw(model: str, system: str, user: str, temperature: float,
                     top_p: float, max_retries: int = MAX_RETRIES) -> tuple[str, dict]:
    """Like generate._call_model, but returns raw text (the authoring
    markdown), not a parsed JSON object -- scene 4 is not JSON."""
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
    if "## SCENE 4" not in text:
        problems.append("missing scene header")
    if ">> CHOICE" not in text:
        problems.append("missing >> CHOICE block")
    for label, flag in (
        ("[INQUISITIVE]", "shared_tactical_data"),
        ("[MISSION]", "withheld_deep_scan"),
        ("[HOSTILE]", "kept_her_blind"),
    ):
        if label not in text:
            problems.append(f"missing choice option {label}")
        if flag not in text:
            problems.append(f"missing flag {flag!r} anywhere in output")
    for tok in (
        "<<IF trust<=-2>>", "<<ELSE>>",
        "<<IF flag:shared_tactical_data>>", "<<ELSEIF flag:withheld_deep_scan>>",
        "<<ELSEIF flag:kept_her_blind>>", "<<END>>",
    ):
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
    if len(text) < 500:
        problems.append(f"suspiciously short output: {len(text)} chars")
    return problems


def generate_scene4(n: int = 6, model: str | None = None, verbose: bool = True) -> list[dict]:
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
            "tool": "scene4_whole", "candidate": i, "model": model,
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
            print(f"  scene4 candidate {i} (T={temperature}, top_p={top_p}): {status}")
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
    generate_scene4(n=args.n, model=model)
    print(f"running total spend: ${total_spend():.4f}")


if __name__ == "__main__":
    main()
