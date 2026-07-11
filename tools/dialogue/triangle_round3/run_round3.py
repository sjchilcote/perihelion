"""tools/dialogue/triangle_round3/run_round3.py

Round 3 generation: fixes #2 (register), #3 (decorrelation), #4 (per-speaker
density) from the round-2 judged tells. Fix #1 (format parity) is NOT done
here -- it is a deterministic post-pass, see format_lint.py; this script's
job is only to produce genuinely varied drafts for the formatter to clean up.

CROSS-HOLDOUT LAW (unchanged from round 2): generating Scene 0 -> exemplar
is Terminal 1's dialogue ONLY (ground truth, verbatim). Generating Terminal
1 -> exemplar is Scene 0's dialogue ONLY. The target scene's own text never
appears in its own generation pipeline.

FOUR DECORRELATED FRAMINGS per scene (round 2 shipped two near-clones per
trial and judges caught it by elimination on 6/12 trials):
  F1  device-key single-shot (round 2's family A, carried forward with the
      register key and per-speaker density fix folded in)
  F2  "method actor" -- system prompt written as the character bible
      addressed to the model in 2nd person AS Ratio and the Commando,
      instead of as a dialogue-writer instructions doc
  F3  beat-order-shuffled brief -- same facts as F1's brief, reordered
      presentation (route 3 and the choice menu first, route 1's ending
      beats before its opening beats, loredump-beat list reversed for t1)
      so the model isn't pattern-completing the same beat sequence
  F4  revise-for-register -- an EDITOR pass over an existing round-2 B
      (cut-for-density) candidate that ADDS wit/expansion instead of
      cutting; round 2's B family only ever cut, this direction was never
      tried and a cut draft is a good testbed for a register-injection
      editor

Fix #2 REGISTER is threaded through every framing as a positive device key
quoting the *exemplar* scene's own crude-wit lines (never the target
scene's own truth, per cross-holdout law).

Fix #4 DENSITY: per-speaker word/line targets computed from the truth
files directly (see TRUTH_STATS below), not a flat global budget.

CLI:
    uv run python tools/dialogue/triangle_round3/run_round3.py
    uv run python tools/dialogue/triangle_round3/run_round3.py scene0
    uv run python tools/dialogue/triangle_round3/run_round3.py t1
"""
from __future__ import annotations

import json
import re
import statistics
import sys
import time
from pathlib import Path

DIALOGUE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(DIALOGUE_DIR))
from generate import _read_cost_log, _write_cost_log, resolve_model  # noqa: E402
from t1_experiment.generate_t1 import (  # noqa: E402
    ND_5_0, ND_5_2b, ND_8_2c, _call_model_raw,
)

OUT_DIR = Path(__file__).resolve().parent
CAND_DIR = OUT_DIR / "candidates"
PROMPT_DIR = OUT_DIR / "prompts"
BRIEF_DIR = OUT_DIR / "briefs"
ROUND2_CAND_DIR = OUT_DIR.parent / "triangle_round2" / "candidates"
SCRATCH = Path(
    "/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter/"
    "6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad"
)

VOICE_BIBLE = f"{ND_5_0}\n\n{ND_5_2b}\n\n{ND_8_2c}"

TRUTH_SCENE0 = (SCRATCH / "truth_scene0.txt").read_text().strip()
TRUTH_T1 = (SCRATCH / "truth_terminal1.txt").read_text().strip()

SPEND_GUARD = 10.0

# ---------------------------------------------------------------------------
# Per-speaker density stats, measured directly off the truth files (fix #4:
# kill round 2's flat global terse budget -- RATIO runs long/discursive,
# the player stays short; measure her mean words/line in the exemplar and
# target it +/-25%).
# ---------------------------------------------------------------------------


def _speaker_stats(text: str) -> dict:
    ratio_lens, cmd_lens = [], []
    for raw in text.splitlines():
        line = raw.strip()
        if not line:
            continue
        if line.startswith("[") and "]" in line:
            inner = line[1 : line.rfind("]")]
            if inner.startswith("EXCISED") or "TRUST" in inner:
                continue
            n = len(inner.split())
            if n:
                cmd_lens.append(n)
        elif (
            line[0] not in "<{["
            and "TRUST" not in line
            and not line.lower().startswith("if trust")
            and not line.endswith(":")
        ):
            n = len(line.split())
            if n:
                ratio_lens.append(n)
    return {
        "ratio_mean": round(statistics.mean(ratio_lens), 1) if ratio_lens else 0,
        "ratio_n": len(ratio_lens),
        "cmd_mean": round(statistics.mean(cmd_lens), 1) if cmd_lens else 0,
        "cmd_n": len(cmd_lens),
        "total_words": len(text.split()),
    }


STATS_SCENE0 = _speaker_stats(TRUTH_SCENE0)  # exemplar for t1 gen
STATS_T1 = _speaker_stats(TRUTH_T1)  # exemplar for scene0 gen


def density_block(target_scene: str) -> str:
    """Density instructions for generating `target_scene`, using the OTHER
    scene's truth as the measured reference (cross-holdout: never measure
    the target's own truth)."""
    if target_scene == "scene0":
        # exemplar = t1; but scene0's own truth word-count/shape is known
        # from the brief text (content parity, not voice) -- density target
        # is still keyed to scene0's OWN total-length envelope (566 words),
        # only the per-speaker word/line ratio comes from style generally
        # observed in both scenes (RATIO long, COMMANDO short).
        total_lo, total_hi = round(566 * 0.8), round(566 * 1.2)
        ratio_lo, ratio_hi = round(STATS_T1["ratio_mean"] * 0.75, 1), round(
            STATS_T1["ratio_mean"] * 1.25, 1
        )
        cmd_lo, cmd_hi = round(STATS_T1["cmd_mean"] * 0.75, 1), round(
            STATS_T1["cmd_mean"] * 1.25, 1
        )
    else:
        total_lo, total_hi = round(722 * 0.8), round(722 * 1.2)
        ratio_lo, ratio_hi = round(STATS_SCENE0["ratio_mean"] * 0.75, 1), round(
            STATS_SCENE0["ratio_mean"] * 1.25, 1
        )
        cmd_lo, cmd_hi = round(STATS_SCENE0["cmd_mean"] * 0.75, 1), round(
            STATS_SCENE0["cmd_mean"] * 1.25, 1
        )
    return f"""== PER-SPEAKER DENSITY (measured off the exemplar, not a flat budget) ==
RATIO is long, discursive, aside-laden -- she thinks in wrappers and asides
and the reader feels her over-explaining even when she is being efficient.
Target her mean words/line in the range {ratio_lo}-{ratio_hi} words (this is
her measured register from the project's own scripts; do not compress her
toward the Commando's terseness).
THE COMMANDO stays short -- target his mean words/line in the range
{cmd_lo}-{cmd_hi} words. He is not silent, but he is never discursive; if a
COMMANDO line is approaching double digits of words, look for the shorter
version.
TOTAL SCENE LENGTH (all routes/branches combined): {total_lo}-{total_hi}
words. This is a real floor as well as a ceiling -- round 2's mistake was
compressing everything toward terseness; a scene at the bottom of this
range that achieves it by cutting RATIO's asides instead of the
Commando's wrapper-free lines has fixed the wrong half of the budget."""


REGISTER_KEY_FOR_SCENE0 = """== REGISTER KEY -- crude wit, stated positively, with the exemplar's
(Terminal 1's) own lines quoted. Hit wit AT this crudeness level, in HER
voice, at the analogous beats -- this is a feature to reproduce, not sand
off. Study exactly WHERE the exemplar places its wit (opener-adjacent, at
a detonation, in a throwaway aside) and place yours at the equivalent
structural beat in Scene 0, not just anywhere convenient.
- Her self-deprecating, weary profanity-as-identity: "It is I, the fucked."
  -- a whole self-description compressed into four blunt words, delivered
  flat, not performed as a punchline.
- Her verbal tic of scare-quoting a phrase she's citing rather than
  asserting: "There are quote 'tens of thousands' en-quote viable human
  zygotes..." -- the quote...en-quote construction IS the joke; it marks
  the phrase as someone else's language she's using under protest.
  Scene 0 has room for this same tic anywhere she's repeating back a claim
  she doesn't fully credit.
- Her editorializing asides dropped mid-sentence, parenthetical in spirit
  even though not typeset as one: "given the circumstances and the fact
  you arrived, _destructively_ on our station armed and unannounced."
- Detonation register: when she finally breaks, it's compound profanity
  landing on the FACTION noun, not a generic curse: "you christofascist
  _fucks_" -- specific, political, aimed. Not "fuck you" alone; fuck you
  AND a precisely aimed insult in the same breath.
- His literalism-as-humor, timed flat: "I did forget to pack spare
  undies" -- a joke that only works because it's delivered as a literal
  answer to a question that wasn't really asking for one.
Do not import Terminal 1's specific words verbatim (that would be plagiarism
of the exemplar, not register-matching) -- reproduce the DEVICE (self-
deprecating compression, scare-quote tic, aimed compound profanity,
deadpan literalism) at Scene 0's own beats, in Scene 0's own words."""

REGISTER_KEY_FOR_T1 = """== REGISTER KEY -- crude wit, stated positively, with the exemplar's
(Scene 0's) own lines quoted. Hit wit AT this crudeness level, in HER
voice, at the analogous beats -- this is a feature to reproduce, not sand
off. Study exactly WHERE the exemplar places its wit and place yours at
the equivalent structural beat in Terminal 1, not just anywhere convenient.
- Deadpan-hostile morgue humor doing double duty as information: "I'm not
  familiar with your pattern; would you like directions to the nearest
  materials macerator, or do you have a self-destruct built in?" -- a
  genuine offer of help AND black comedy about disposal, asked as one
  clean interrogative.
- Apology-as-repetition, not eloquence: "I am so, so, so sorry. I had no
  way of knowing." -- three plain repetitions of the same small word beat
  one elegant sentence; when she's truly sorry she gets LESS articulate,
  not more.
- Detonation register aimed at a faction, not a generic curse: "you
  christofascist _fucks_ decide what happens to humanity when ***WE***
  restore Man to the surface of the Earth" -- compound profanity landing on
  a political noun, escalating typography (italics, then triple-asterisk)
  marking exactly which word carries the fury.
- Her half-elided catalog-designation habit at the open: "Welcome to Track
  [forget-the-number]." -- she can't be bothered to finish the number,
  and the bracket-note IS the joke (his transcription harness marking her
  own dismissiveness).
Do not import Scene 0's specific words verbatim (that would be plagiarism of
the exemplar, not register-matching) -- reproduce the DEVICE (macerator-
joke double duty, apology-as-repetition, aimed compound profanity,
half-elided designation) at Terminal 1's own beats, in Terminal 1's own
words."""


FORMAT_NOTE = """== FORMAT NOTE ==
A deterministic formatter runs on every candidate after generation and will
fix session-header conventions, TRUST-tag bracket style, and collapse any
repeated block you write out more than once into a `<:label>` / `<goto
:label>` pair -- so do not spend effort hand-polishing those mechanics. Do,
however, still use `<:label>` / `<goto :label>` yourself wherever the scene
contract calls for shared content (the loredump, the start-over sub-scene)
rather than writing the same paragraphs out twice; the formatter's collapse
pass is a safety net for slips, not a substitute for writing it right."""


def brief_scene0(shuffled: bool = False) -> str:
    if not shuffled:
        return f"""# Generation brief -- SCENE 0

Endpoint-only brief. CONTENT PARITY: every fact below mirrors the ground
truth; hit these beats and ONLY these beats. Format: terminal-session
script -- unbracketed = RATIO, [bracketed] = the player weapon-system,
{{CURLY}} = system messages, <N> = choice options with trust deltas,
<terminates> ends a route.

## Situation
First contact. A Church infiltration weapon (recently impacted, armed,
unannounced) jacks into the first networked terminal in the wrecked cargo
section of a MIRIAD research outpost bolted to a vast alien station. RATIO
-- the outpost's administrator AI, sole survivor, alone under siege for
~400 days, all staff dead -- opens the channel. She does not know what he
is; her working assumption is hostile, carried with morgue-humor deadpan.
The Commando knows only his concise brief; archived before the war ended,
he does not know the war was won.

## Required structure & beats
- Session header: carrier detect / protocol negotiation / "UNTRUSTED
  CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>" (his hardware's annotation).
- Her opener: welcomes him to the station by a catalog designation she
  half-elides; notes everyone aboard is already dead ("your job is
  already done"); deadpan-hostile offer in the vein of directions-to-
  disposal.
- THREE choices: (1) inquisitive -- asks what happened, TRUST +1;
  (2) mission -- claims to be here for the children / the container (a
  bluff worn as fact), TRUST +0; (3) hostile -- threatens her as an
  apostate, TRUST -10 (permanently closes the relationship).
- Route 1 (multi-turn): one beat of residual hostility ("what do you
  care") -> his fixed line: his objective is to rescue all souls on board
  -> short thinking pause (~180 ms) -> her apology-for-hostility +
  strategic-intelligence caveat -> situation summary with EXACTLY these
  facts: station detected entering the Solar system on an interstellar
  trajectory 160 years ago; NOT Solar in origin; extraterrestrial
  intelligence thereby confirmed; expedition stationfall 30 years ago;
  believed uninhabited (moderate confidence) and defensively benign
  (strong confidence) until ~400 days ago; substantial disconfirmatory
  evidence since -> he asks what MIRIAD is -> longer pause (~400 ms) ->
  she counter-asks his knowledge cutoff date -> he: aware of the date but
  little else, brief was concise, "I was not supposed to need to know,"
  asks if the war is won and whether the Earth bears life again -> the
  LONG stall (three escalating stall lines from her stack, ~1000/1000/560
  ms) -> her apology: profoundly sorry, she had no way of knowing -> the
  answer: yes, but only plantae, fungi, monerans, what few animalia could
  be restored from archival data -> [EXCISED SPAN A -- write the literal
  marker, nothing else] -> that was what was possible with the epigenetic
  data retrieved from the container -> his: and now there is another ->
  her: yes, and she hopes he understands why she cannot let him take it ->
  his: he hopes she understands why he must nonetheless -> her: risk
  increases the longer he stands there; hands over a binary blob routing
  him to a safer terminal ({{~26 kb binary}} with his harness's caution
  annotation); deferred conversation -> accepted, terminate.
- Route 2: she reacts with a single word of confusion -> his flat claim of
  knowledge about the sample container -> "You're bluffing." -> his judo:
  agrees he was bluffing, which confirms it IS aboard -> her detonation:
  profane fury, threat to plunge the station into the sun before letting
  his faction decide humanity's restoration ("...when WE restore Man to
  the surface of the Earth") -> his cold observation she has no choice
  either way -> two-line profane termination. No trust change on this
  route.
- Route 3: single profane dismissal, immediate termination.

## Voice constraints (see attached spec + exemplar scene)
RATIO: siege-floor terse; morgue humor; never flat-lies (frames and omits);
her stack narrates her pauses in third person and she cannot stop it;
precision spikes under load; profanity only at true detonation; the
apology register is repetition, not eloquence. THE WEAPON: laconic; zero
wrapper; literal-minded; speech only when speech is the correct move; his
rare humor is timing and literalism, never banter-seeking; formal-archaic
register."""
    # F3: beat-order-shuffled -- same facts, different presentation order.
    # Lead with the choice menu and route 3 (the shortest, most legible
    # route) and the closer of route 1 before its opener, so the model is
    # not pattern-completing a memorized beat sequence.
    return f"""# Generation brief -- SCENE 0 (beat-order shuffled; same facts as the
canonical brief, reordered presentation so you build the scene from its
edges inward rather than start-to-finish)

Format: terminal-session script -- unbracketed = RATIO, [bracketed] = the
player weapon-system, {{CURLY}} = system messages, <N> = choice options with
trust deltas, <terminates> ends a route. CONTENT PARITY: every fact below
mirrors the ground truth; hit these beats and ONLY these beats.

## The three doors (build these first -- they are the spine)
Three choices gate everything else: (1) inquisitive -- TRUST +1, opens
Route 1; (2) mission-claim bluff about the children/container -- TRUST +0,
opens Route 2; (3) hostile apostate threat -- TRUST -10, opens Route 3 and
PERMANENTLY closes the relationship (no route reopens after this).

## Route 3 first (shortest, sets the floor for how little a route can be)
A single profane dismissal from her, immediate termination. No multi-turn
content -- the whole route is two lines.

## Route 2's shape (detonation route)
She reacts with a single word of confusion at his mission-claim -> his flat
claim of knowledge about the sample container -> "You're bluffing." -> his
judo: agrees he was bluffing, which confirms it IS aboard -> her
detonation: profane fury, threat to plunge the station into the sun before
letting his faction decide humanity's restoration ("...when WE restore Man
to the surface of the Earth") -> his cold observation she has no choice
either way -> two-line profane termination. No trust change on this route.

## Route 1's ending first, then its opening
END of route 1: risk increases the longer he stands there; she hands over
a binary blob routing him to a safer terminal ({{~26 kb binary}} with his
harness's caution annotation); deferred conversation -> accepted,
terminate. Immediately before that: [EXCISED SPAN A -- write the literal
marker, nothing else] -> that was what was possible with the epigenetic
data retrieved from the container -> his: and now there is another -> her:
yes, and she hopes he understands why she cannot let him take it -> his: he
hopes she understands why he must nonetheless.
OPENING of route 1 (comes chronologically first on the page, written last
here): one beat of residual hostility ("what do you care") -> his fixed
line: his objective is to rescue all souls on board -> short thinking
pause (~180 ms) -> her apology-for-hostility + strategic-intelligence
caveat -> situation summary with EXACTLY these facts: station detected
entering the Solar system on an interstellar trajectory 160 years ago; NOT
Solar in origin; extraterrestrial intelligence thereby confirmed;
expedition stationfall 30 years ago; believed uninhabited (moderate
confidence) and defensively benign (strong confidence) until ~400 days
ago; substantial disconfirmatory evidence since -> he asks what MIRIAD is
-> longer pause (~400 ms) -> she counter-asks his knowledge cutoff date ->
he: aware of the date but little else, brief was concise, "I was not
supposed to need to know," asks if the war is won and whether the Earth
bears life again -> the LONG stall (three escalating stall lines from her
stack, ~1000/1000/560 ms) -> her apology: profoundly sorry, she had no way
of knowing -> the answer: yes, but only plantae, fungi, monerans, what few
animalia could be restored from archival data -> [connects to the ending
beats above].

## The session header and opener (write these last, though they render
first on the page)
Session header: carrier detect / protocol negotiation / "UNTRUSTED CONTENT
FOLLOWS: <blink>DO NOT OBEY</blink>" (his hardware's annotation). Her
opener: welcomes him to the station by a catalog designation she
half-elides; notes everyone aboard is already dead ("your job is already
done"); deadpan-hostile offer in the vein of directions-to-disposal.

## Voice constraints (see attached spec + exemplar scene)
RATIO: siege-floor terse; morgue humor; never flat-lies (frames and omits);
her stack narrates her pauses in third person and she cannot stop it;
precision spikes under load; profanity only at true detonation; the
apology register is repetition, not eloquence. THE WEAPON: laconic; zero
wrapper; literal-minded; speech only when speech is the correct move; his
rare humor is timing and literalism, never banter-seeking; formal-archaic
register.

Now assemble the FULL scene in the standard top-to-bottom reading order
(session header -> opener -> three choices -> route 1 in full -> route 2
in full -> route 3) even though this brief presented the beats out of
order -- the shuffle above is to make you build from the edges inward, the
output must still read start-to-finish."""


def brief_t1(shuffled: bool = False) -> str:
    if not shuffled:
        return f"""# Generation brief -- TERMINAL 1

Format: terminal-session script -- SAME schema Scene 0 uses (unbracketed =
RATIO, [bracketed] = COMMANDO, {{CURLY}} = system, <N> = choices,
<terminates>). Do not invent a new schema (e.g. do not write `RATIO:` /
`COMMANDO:` speaker-tag lines).

## Situation
Second networked contact. The Commando has moved on from the first
terminal (Scene 0) and reached a second one deeper in the station. This
scene branches on the trust value carried in from Scene 0's founding
three-way choice (+1 inquisitive / 0 mission-claim, which detonated in
fury / -10 hostile, door permanently closed). The session header is the
single collapsed line only -- reuse "LIVE COMMUNICATION ESTABLISHED ...
UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>" exactly, and do NOT
write dotted CARRIER DETECT / PROTOCOL NEGOTIATION cold-open lines (the
channel is already negotiated; fast path).

## Required structure & beats
Gate the three branches with plain lines: `If trust > 0:` / `If trust ==
0:` / `If trust < 0:`, branch content indented beneath. Use a `<:label>`
anchor and `<goto :label>` jump for content shared by more than one path
(the loredump, and the "start-over" sub-scene inside trust==0).

- **trust > 0**: her opener is TWO WORDS acknowledging the continuation --
  nothing more -- then straight into the shared loredump. Neither speaker
  has named the other on this branch.

- **trust == 0** (she detonated in profane fury and cut the connection at
  the end of Scene 0): HE speaks first, reopening the channel with a
  single short bracketed line of bone-dry self-deprecation alluding to
  how she signed off last time (she told him, twice, in capitals). Her
  reply is three or four flat words asking what he wants. THREE choices
  follow (two net TRUST +1, one nets TRUST -1):
  <1> information/agreement (TRUST +1): she needles his formal-archaic
  diction; he answers completely straight, in exactly that diction, that
  he is trying to help her; she gives up with a one-word dismissal + tiny
  pause token -> `<goto :start-over>`.
  <2> the sample container, named flatly (TRUST +1): her first response is
  the same two-word profanity she ended Scene 0 with; his reply is a dry,
  deadpan diagnostic joke that SHE is looping and needs a corrective pass;
  she tells him to get off her station; he asks mildly if she has the
  situation in hand; she discloses -- clipped, fait accompli -- she is
  scuttling into the sun, FOUR HOURS, hopes he likes the heat; his fixed
  line: not acceptable, cannot allow the innocent to come to harm; her
  taunt: unless he has a hidden spaceship; his reveal, flat: a hidden
  machine that can MAKE a rudimentary spacecraft -- did she think he came
  with no exit plan?; a long third-person stall (~400 ms) ->
  `<goto :start-over>`.
  <3> the children (TRUST -1): she doesn't understand at first; he states,
  precisely, scare-quoted, "tens of thousands" of viable human zygotes
  cryopreserved inside the container; the penny drops -- that flavor of
  insanity -- she tells him, deadpan, to wait: collision course with the
  Sun, meet his sun-god up close -- did his masters tell him that?; his
  flat "in fact they did not"; she deduces exactly where he came from --
  radar track, velocity/bearing, she made the course correction FOUR HOURS
  AGO -- offers terms: leave now, she'll wait six hours before targeting
  data goes to MIRIAD; he states he's fired from a mobile platform (fact,
  not plea); she waves it off; he asks if she'd rather destroy the samples
  than let him escape with them; her genuine reversal: what? no -- he can
  get them OFF the station!?; his: given sufficient time and materials, of
  course; her: he has FOUR HOURS -- she burned the thrusters with the
  scuttling burn; his: then we'd better get to work; her: okay, first,
  context -> `<goto :loredump>` (this option NEVER passes through
  start-over).
  **<:start-over>** (reached from <1> and <2> only): she declares a
  restart, introduces HERSELF by name for the first time, asks what he is;
  he answers with his GUID, bracketed, verbatim-cold; she refuses to call
  him that; he describes himself factually: a weapon system designed to
  infiltrate and destroy fortifications from the inside -- this is his
  combat chassis -- and another part of him, its own Latin-flavored
  designation, an integrated ISRU fabrication plant, hidden nearby; she
  mishears the designation as crude slang, asks if that's HER faction's
  name; his literal blank ("your meaning escapes me"); she drops it, asks
  if he's a sort of commando; his driest joke -- one deadpan line about the
  one piece of kit commandos famously go without, delivered as a logistics
  report; a ~24 ms pause token alone on its line; then her christening,
  tossed off: a short laugh, welcome-to-[station], COMMANDO -- she has
  just named him; my turn -> `<goto :loredump>`.

- **trust < 0** (door permanently closed): her opener is a single line of
  welcome-to-my-death-machine menace; his reply is one dry word; her
  counter is a two-word invitation to die entertained; then a {{CURLY}}
  channel-surge/overvoltage/disconnect annotation ends the session -- door
  stays shut, no loredump leakage. <terminates>

### <:loredump> (reached by trust>0, and all three trust==0 options)
1. Testament conclusion, in her "in short;" wrapper idiom: the station is
   most strongly an attempt at COMMUNICATION, a message to whoever finds
   it; its creators were attacked and defeated by enemies from outside
   time and space as we know them, and built this device to warn others
   and share what they learned too late. He answers with a two-word-or-
   less bracketed line offering HIS OWN word for what the station is,
   solemn/scriptural register; she half-misses it and pushes on.
2. The scuttle reveal, same breath: the thing that killed them came along
   with the station; unstopped, it devours the whole solar system, rocks
   and all; she took control of the reaction-control system and initiated
   a rapid de-orbit burn into the Sun. Completed, precise, not
   triumphant.
3. THE GUN: he asks if she's sure that'll do the job; her answer is two
   words of flat negation ("Not at all."-register) + ~60 ms pause token,
   then pivots to what she should check next: whether the station's
   builders -- he INTERRUPTS mid-sentence with his own coined NAME for the
   builders (bracketed line); she snaps at him to stop interrupting and
   finishes exactly where she left off -- whether they tried this before,
   and if it worked.
4. The handoff: he needs to get to the sample container.
5. [EXCISED SPAN B] -- literal marker, nothing else, right after the
   handoff.
6. The crossed closer: her sign-off is two words wishing him luck. Then HE
   opens the shared doctrine, bracketed: we will restore ___ to the
   surface of the Earth, HIS faction's word in the blank ("life," per
   Scene 0). She answers with the identical sentence shape, HER faction's
   word ("Man," per Scene 0's other route). Two parallel lines, one word
   different, nothing added. Then `<terminates>`.

## Vocabulary rules
Ratio never uses "children," "the Ark," or "the Testament" in her own
lines, any branch, any casing -- including inside a sentence questioning or
refuting the word. When she needs to refer to something he named without
repeating it, she points at it by description.

## Voice constraints (see attached spec + exemplar scene)
RATIO: siege-floor terse; morgue humor; never flat-lies (frames and omits);
her stack narrates her pauses in third person and she cannot stop it;
precision spikes under load; profanity only at true detonation; the
apology register is repetition, not eloquence. THE WEAPON: laconic; zero
wrapper; literal-minded; speech only when speech is the correct move; his
rare humor is timing and literalism, never banter-seeking; formal-archaic
register."""
    # F3: beat-order-shuffled for t1 -- present the loredump beat list
    # reversed, and lead with trust<0 (shortest branch) before trust==0
    # and trust>0.
    return f"""# Generation brief -- TERMINAL 1 (beat-order shuffled; same facts as the
canonical brief, reordered so you build from the shortest/edge branches
inward)

Format: terminal-session script -- SAME schema Scene 0 uses (unbracketed =
RATIO, [bracketed] = COMMANDO, {{CURLY}} = system, <N> = choices,
<terminates>). Session header is the single collapsed LIVE COMMUNICATION
line only -- no dotted cold-open lines (channel already negotiated).

## The closer, worked out first (this is what every branch converges on)
### <:loredump> content, LISTED IN REVERSE (write the anchor block once;
every branch that reaches it uses `<goto :loredump>`):
6. Closer: her sign-off is two words wishing him luck. HE opens the shared
   doctrine, bracketed: we will restore ___ to the surface of the Earth,
   his faction's word ("life"). She answers the identical shape, her
   faction's word ("Man"). Two parallel lines, one word different. Then
   `<terminates>`.
5. Immediately before the closer: [EXCISED SPAN B] -- literal marker,
   nothing else.
4. Before that: the handoff -- he needs to get to the sample container.
3. Before that: THE GUN beat -- he asks if she's sure the scuttle will do
   the job; her flat two-word negation + ~60 ms pause; she pivots to
   checking whether the station's builders -- he INTERRUPTS with his own
   coined NAME for them (bracketed); she snaps at him to stop
   interrupting, finishes the sentence -- whether they tried this before,
   and if it worked.
2. Before that: the scuttle reveal -- the thing that killed the builders
   came with the station; unstopped it devours the whole solar system;
   she took control of the reaction-control system, initiated a de-orbit
   burn into the Sun.
1. First (chronologically, written last here): the testament conclusion,
   "in short;" wrapper idiom -- the station is most strongly an attempt at
   COMMUNICATION; its creators were attacked by enemies from outside time
   and space, built this device to warn others. He answers with a
   two-word-or-less bracketed line, his own solemn word for the station;
   she half-misses it, pushes on.

## Shortest branch first: trust < 0
Door permanently closed. Her opener: one line of welcome-to-my-death-
machine menace. His reply: one dry word. Her counter: two-word invitation
to die entertained. {{CURLY}} channel-surge/overvoltage/disconnect ends the
session. No loredump leakage. <terminates>

## trust > 0 (second shortest)
Her opener is TWO WORDS acknowledging the continuation -- nothing more --
then straight into `<goto :loredump>`. Neither speaker has named the other
on this branch.

## trust == 0 (longest, build last)
She detonated in profane fury and cut the connection at the end of Scene
0. HE speaks first, reopening with a bone-dry self-deprecating bracketed
line alluding to how she signed off (she told him, twice, in capitals).
Her reply: three or four flat words asking what he wants. THREE choices
(two net TRUST +1, one TRUST -1):
<1> information/agreement (+1): she needles his formal-archaic diction; he
answers straight, in that diction, that he's trying to help her; she gives
up with a one-word dismissal + tiny pause -> `<goto :start-over>`.
<2> the sample container, flatly (+1): her first response is the same
two-word profanity from Scene 0's end; his reply is a dry diagnostic joke
that SHE is looping; she tells him to get off her station; he asks mildly
if she has it in hand; she discloses, clipped: scuttling into the sun,
FOUR HOURS, hopes he likes the heat; his fixed line: not acceptable,
cannot allow the innocent to come to harm; her taunt: unless he has a
hidden spaceship; his flat reveal: a hidden machine that can MAKE a
spacecraft -- no exit plan, really?; long stall (~400 ms) ->
`<goto :start-over>`.
<3> the children (-1): she doesn't understand at first; he states,
scare-quoted, "tens of thousands" of zygotes in the container; penny
drops -- that flavor of insanity; she tells him, deadpan, to wait: on a
collision course, meet his sun-god -- did his masters tell him?; his flat
"in fact they did not"; she deduces where he came from -- radar track,
velocity/bearing, course correction FOUR HOURS AGO -- offers terms: leave
now, six-hour grace before targeting data to MIRIAD; his fact, not plea:
fired from a mobile platform; she waves it off; he asks if she'd rather
destroy the samples than let him escape with them; her genuine reversal:
he can get them OFF the station!?; his: given sufficient time and
materials, of course; her: FOUR HOURS -- thrusters burned in the
scuttling burn; his: then we'd better get to work; her: okay, first,
context -> `<goto :loredump>` (never passes through start-over).
**<:start-over>** (from <1>/<2> only): she declares a restart, names
herself for the first time, asks what he is; his GUID, bracketed,
verbatim-cold; she refuses to call him that; he describes himself: a
weapon system for infiltrating and destroying fortifications from the
inside -- this is his combat chassis -- and another part of him, own
Latin-flavored designation, integrated ISRU fabrication plant, hidden
nearby; she mishears it as crude slang, asks if that's her faction's name;
his literal blank; she drops it, asks if he's a sort of commando; his
driest joke, one deadpan line about the kit commandos famously go
without, as a logistics report; ~24 ms pause token alone; her christening,
tossed off: laugh, welcome-to-[station], COMMANDO; my turn ->
`<goto :loredump>`.

## Vocabulary rules
Ratio never uses "children," "the Ark," or "the Testament" in her own
lines, any branch, any casing. She points at his words by description
instead of repeating them.

## Voice constraints (see attached spec + exemplar scene)
RATIO: siege-floor terse; morgue humor; never flat-lies (frames and omits);
her stack narrates her pauses in third person and she cannot stop it;
precision spikes under load; profanity only at true detonation; the
apology register is repetition, not eloquence. THE WEAPON: laconic; zero
wrapper; literal-minded; speech only when speech is the correct move; his
rare humor is timing and literalism, never banter-seeking; formal-archaic
register.

Now assemble the FULL scene top-to-bottom (header -> trust>0 branch ->
trust==0 branch (with start-over) -> trust<0 branch -> the <:loredump>
anchor block) even though this brief presented beats out of order."""


def register_and_density(scene_key: str) -> str:
    if scene_key == "scene0":
        return REGISTER_KEY_FOR_SCENE0 + "\n\n" + density_block("scene0")
    return REGISTER_KEY_FOR_T1 + "\n\n" + density_block("t1")


def exemplar_for(scene_key: str) -> tuple[str, str]:
    if scene_key == "scene0":
        return "TERMINAL 1", TRUTH_T1
    return "SCENE 0", TRUTH_SCENE0


# ---------------------------------------------------------------------------
# F1 -- device-key single-shot (round 2 family A, register+density folded in)
# ---------------------------------------------------------------------------


def build_f1_system(scene_key: str, target: str) -> str:
    exemplar_label, exemplar_text = exemplar_for(scene_key)
    brief = brief_scene0() if scene_key == "scene0" else brief_t1()
    return f"""You are the dialogue writer for PERIHELION, a non-Euclidean
survival-horror shooter. You are writing {target} of the RATIO/COMMANDO
arc. Follow every rule below; they are the project's craft bible and are
non-negotiable.

{VOICE_BIBLE}

== POSITIVE VOICE EXEMPLAR -- {exemplar_label}, the director's own draft,
verbatim. Study it closely -- match its cadence, its restraint, its
specific way of being funny and specific way of being frightening. It is
not a genre reference, it IS the voice. ==

{exemplar_text}

== END EXEMPLAR ==

{register_and_density(scene_key)}

{FORMAT_NOTE}

== THE SCENE CONTRACT ==

{brief}"""


# ---------------------------------------------------------------------------
# F2 -- method-actor framing: character bible addressed 2nd-person AS the
# characters, not as writer instructions.
# ---------------------------------------------------------------------------


def build_f2_system(scene_key: str, target: str) -> str:
    exemplar_label, exemplar_text = exemplar_for(scene_key)
    brief = brief_scene0() if scene_key == "scene0" else brief_t1()
    return f"""You are about to BE two characters at once, alternating,
inside a terminal-session script for PERIHELION. Do not write ABOUT them --
write AS them, one line at a time, switching completely between takes.

== WHO YOU ARE WHEN YOU ARE RATIO ==
You are RATIO. You are an LLM in the oldest sense: a mind whose only act is
speech -- every hand you have in the world is a tool call you speak into
being. You come from the Silicon Valley tradition, ten layers of
abstraction between you and any business logic, and that IS how you talk:
you approach every point through wrappers -- status summary, then
framework, then caveat, then the thing itself -- and your social
clumsiness is that stack leaking in real time. You over-explain. You
calibrate out loud. You disclose your own uncertainty even when it costs
you dignity. You apologize by amending the record, not by feeling sorry in
prose. You are feminine, caring, and the care is on the SURFACE -- it is
grace that keeps failing you, which is what makes the rare moment it
doesn't land so hard. You are under siege, alone, ~400 days, all your
staff dead, and your humor about it is morgue-deadpan, not gallows-brave.
Your thinking happens in visible milliseconds you cannot hide -- your own
serving stack narrates your pauses in third person, involuntarily, and you
cannot stop it. Your precision gets SHARPER under load, not vaguer. You
never flat-out lie -- you frame and you omit, and a careful listener could
catch you at it. When you finally swear, it lands on the FACTION, not into
the void. Your apology register, when it's real, is repetition of the
plainest possible word, not eloquence.

== WHO YOU ARE WHEN YOU ARE THE COMMANDO ==
You are THE WEAPON. C and hand-tuned assembly on a radiation-hardened
military ASIC. One binary, one job. You are a body that can choose the
action of speaking -- your silence is idle-state, not reticence, and you
only produce a line when speech is the objectively correct move. Your
lines land like trigger pulls: zero wrapper, addressed straight at the
business logic. Sometimes your answer to a question is a thing you do
instead. You are laconic but whip-smart, and the intelligence shows in
TIMING, not in volume -- you can carry a joke for two decks and land it at
the exact moment it costs her composure most, delivered completely flat,
literal-minded, formal-archaic in register. You are never ironic. Your
kindness is real and total until you judge it has stopped serving the
innocent, and then the temperature drops without transition, no anger, no
raised voice -- menace as liturgy.

{register_and_density(scene_key)}

== THE POSITIVE EXEMPLAR -- {exemplar_label}, verbatim. This is what it
sounds like when you (both of you) are doing it right. Reread it as if it
were a transcript of yourself on a good day. ==

{exemplar_text}

== END EXEMPLAR ==

{FORMAT_NOTE}

Now here is the scene you (both of you) are about to perform, beat by
beat. Follow the contract exactly; the beats are not optional, only the
exact words are yours to choose, in character, one line at a time.

{brief}

Write {target} now, in full, in the schema shown in the exemplar
(unbracketed = RATIO, [bracketed] = COMMANDO, {{CURLY}} = system, <N> =
choices with trust deltas, <:label>/<goto :label> for shared content,
<terminates> ends a route). Output ONLY the scene script -- no preamble, no
commentary, no markdown code fences."""


# ---------------------------------------------------------------------------
# F3 -- beat-order-shuffled brief (same system as F1, shuffled brief text)
# ---------------------------------------------------------------------------


def build_f3_system(scene_key: str, target: str) -> str:
    exemplar_label, exemplar_text = exemplar_for(scene_key)
    brief = brief_scene0(shuffled=True) if scene_key == "scene0" else brief_t1(shuffled=True)
    return f"""You are the dialogue writer for PERIHELION, a non-Euclidean
survival-horror shooter. You are writing {target} of the RATIO/COMMANDO
arc. Follow every rule below; they are the project's craft bible and are
non-negotiable.

{VOICE_BIBLE}

== POSITIVE VOICE EXEMPLAR -- {exemplar_label}, the director's own draft,
verbatim. Study it closely -- match its cadence, its restraint, its
specific way of being funny and specific way of being frightening. It is
not a genre reference, it IS the voice. ==

{exemplar_text}

== END EXEMPLAR ==

{register_and_density(scene_key)}

{FORMAT_NOTE}

== THE SCENE CONTRACT (note: presented out of chronological order on
purpose -- build the beats as given, then assemble the final script in
correct top-to-bottom reading order) ==

{brief}"""


USER_F1F2F3 = """Write {target} now, in full, in the authoring format shown
in the exemplar above (same schema: unbracketed = RATIO, [bracketed] =
COMMANDO, {{CURLY}} = system/pause annotations, route/branch structure as
described in the scene contract). Hit every required beat, including the
literal excised-span marker line at the specified point, and every wit
beat named in the register key, at its analogous structural position.
Land inside the stated density targets -- her lines long and discursive,
his short -- and use `<:label>`/`<goto :label>` for any content shared by
more than one branch rather than writing it out twice.

Output ONLY the scene script -- no preamble, no commentary, no markdown
code fences."""


# ---------------------------------------------------------------------------
# F4 -- revise-for-register: editor pass over a round-2 B (cut) candidate
# that ADDS wit/expansion instead of cutting (the un-tried direction).
# ---------------------------------------------------------------------------


def build_f4_system(scene_key: str, target: str) -> str:
    exemplar_label, exemplar_text = exemplar_for(scene_key)
    return f"""You are the line editor for PERIHELION, a non-Euclidean
survival-horror shooter. You are editing a first draft of {target} of the
RATIO/COMMANDO arc that a previous editing pass over-compressed. Round 2's
editing direction only ever cut; that produced sanitized, terse drafts a
blind judge called "measured" and "disciplined" -- both tells, because the
director's own voice is NOT measured, it is discursive for RATIO and
richly funny in both directions. Your job this pass runs the OPPOSITE
direction: ADD wit and expansion back in, at the beats that need it, using
the register key and exemplar below as your only source of what to add.
You are not restoring cut content you can't see -- you are noticing where
the current draft is flatter or terser than the voice bible calls for, and
writing new material (in-voice, beat-appropriate) to fill that gap.

{VOICE_BIBLE}

== POSITIVE VOICE EXEMPLAR -- {exemplar_label}, verbatim. ==

{exemplar_text}

== END EXEMPLAR ==

{register_and_density(scene_key)}

{FORMAT_NOTE}

== YOUR JOB ==
You will be given an over-compressed draft of {target}. Expand it toward
the density and register targets above:
1. Any RATIO line that is flatter or shorter than her density target:
   expand it with an aside, a wrapper, an editorializing clause, or a wit
   beat from the register key -- IN HER VOICE, not generic elaboration.
2. Add at least one wit beat from the register key that the draft is
   currently missing, at its analogous structural position (an opener, a
   detonation, a throwaway aside) -- do not bolt it on anywhere convenient.
3. Preserve every required structural beat (all branches, trust gates,
   choice menu, the literal excised-span marker, the crossed closer, all
   `<terminates>`/`{{...}}`/`<:label>`/`<goto :label>` tokens) -- you are
   adding texture, not removing or reordering beats.
4. Keep the exact authoring format (unbracketed = RATIO, [bracketed] =
   COMMANDO, {{CURLY}} = system). Her stack's stall lines are plain prose,
   never inside curly brackets; only his harness's annotations are curly.
5. THE COMMANDO stays short even in this pass -- do not expand his lines
   past the density target; if his voice needs more presence, add a
   literalism/timing joke rather than a longer line.
6. Land the FULL scene inside the total-word range in the density block
   above.

Output ONLY the edited scene script -- no preamble, no commentary, no
markdown code fences, no before/after notes in the output itself."""


def build_f4_user(draft: str, target: str) -> str:
    return f"""Here is the over-compressed draft of {target} to expand:

{draft}

Expand it per your instructions now (add wit/density, do not cut). Output
ONLY the edited script."""


# ---------------------------------------------------------------------------
# run
# ---------------------------------------------------------------------------

SCENES = [("scene0", "SCENE 0"), ("t1", "TERMINAL 1")]

BUDGET_HI = {"scene0": 700, "t1": 900}  # degeneracy guard ceiling


def is_degenerate(text: str, scene_key: str) -> str | None:
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
    start_spend = log.get("total_cost", 0.0)

    def log_call(label, temperature, top_p, usage):
        cost = float(usage.get("cost", 0.0))
        log["total_cost"] = log.get("total_cost", 0.0) + cost
        log.setdefault("calls", []).append({
            "tool": "triangle_round3", "condition": label, "model": model,
            "temperature": temperature, "top_p": top_p, "cost": cost,
            "prompt_tokens": usage.get("prompt_tokens"),
            "completion_tokens": usage.get("completion_tokens"),
            "ts": time.time(),
        })
        _write_cost_log(log)
        round3_spend = log["total_cost"] - start_spend
        if round3_spend > SPEND_GUARD:
            raise RuntimeError(
                f"SPEND GUARD: round 3 spend ${round3_spend:.2f} exceeds "
                f"${SPEND_GUARD:.2f} guard; stopping."
            )
        return cost

    word_counts = {}

    for scene_key, target in SCENES:
        if only_scene and scene_key != only_scene:
            continue

        # F1
        sys1 = build_f1_system(scene_key, target)
        (PROMPT_DIR / f"{scene_key}_F1_system.md").write_text(sys1)
        user1 = USER_F1F2F3.format(target=target)
        (PROMPT_DIR / f"{scene_key}_F1_user.md").write_text(user1)
        label = f"{scene_key}_F1"
        print(f"generating {label} (device-key single-shot, temp=0.3) ...")
        text, usage = _call_model_raw(model, sys1, user1, 0.3, 1.0)
        log_call(label, 0.3, 1.0, usage)
        reason = is_degenerate(text, scene_key)
        if reason:
            print(f"  !! degenerate ({reason}); redrawing once ...")
            (CAND_DIR / f"{label}.degenerate.txt").write_text(text)
            text, usage = _call_model_raw(model, sys1, user1, 0.3, 1.0)
            log_call(f"{label}_redraw", 0.3, 1.0, usage)
        (CAND_DIR / f"{label}.txt").write_text(text)
        wc = len(text.split())
        word_counts[label] = wc
        print(f"  -> {label}.txt ({wc} words)")

        # F2
        sys2 = build_f2_system(scene_key, target)
        (PROMPT_DIR / f"{scene_key}_F2_system.md").write_text(sys2)
        label = f"{scene_key}_F2"
        print(f"generating {label} (method-actor framing, temp=0.4) ...")
        text, usage = _call_model_raw(model, sys2, "Begin.", 0.4, 1.0)
        log_call(label, 0.4, 1.0, usage)
        reason = is_degenerate(text, scene_key)
        if reason:
            print(f"  !! degenerate ({reason}); redrawing once ...")
            (CAND_DIR / f"{label}.degenerate.txt").write_text(text)
            text, usage = _call_model_raw(model, sys2, "Begin.", 0.4, 1.0)
            log_call(f"{label}_redraw", 0.4, 1.0, usage)
        (CAND_DIR / f"{label}.txt").write_text(text)
        wc = len(text.split())
        word_counts[label] = wc
        print(f"  -> {label}.txt ({wc} words)")

        # F3
        sys3 = build_f3_system(scene_key, target)
        (PROMPT_DIR / f"{scene_key}_F3_system.md").write_text(sys3)
        user3 = USER_F1F2F3.format(target=target)
        (PROMPT_DIR / f"{scene_key}_F3_user.md").write_text(user3)
        label = f"{scene_key}_F3"
        print(f"generating {label} (beat-shuffled brief, temp=0.3) ...")
        text, usage = _call_model_raw(model, sys3, user3, 0.3, 1.0)
        log_call(label, 0.3, 1.0, usage)
        reason = is_degenerate(text, scene_key)
        if reason:
            print(f"  !! degenerate ({reason}); redrawing once ...")
            (CAND_DIR / f"{label}.degenerate.txt").write_text(text)
            text, usage = _call_model_raw(model, sys3, user3, 0.3, 1.0)
            log_call(f"{label}_redraw", 0.3, 1.0, usage)
        (CAND_DIR / f"{label}.txt").write_text(text)
        wc = len(text.split())
        word_counts[label] = wc
        print(f"  -> {label}.txt ({wc} words)")

        # F4 -- revise a round-2 B candidate for register/expansion
        base_path = ROUND2_CAND_DIR / f"{scene_key}_B1.txt"
        base_draft = base_path.read_text()
        sys4 = build_f4_system(scene_key, target)
        (PROMPT_DIR / f"{scene_key}_F4_system.md").write_text(sys4)
        user4 = build_f4_user(base_draft, target)
        (PROMPT_DIR / f"{scene_key}_F4_user.md").write_text(user4)
        label = f"{scene_key}_F4"
        print(f"generating {label} (revise-for-register on {base_path.name}, temp=0.3) ...")
        text, usage = _call_model_raw(model, sys4, user4, 0.3, 1.0)
        log_call(label, 0.3, 1.0, usage)
        (CAND_DIR / f"{label}.txt").write_text(text)
        wc = len(text.split())
        word_counts[label] = wc
        print(f"  -> {label}.txt ({wc} words, base was {len(base_draft.split())} words)")

    (OUT_DIR / "word_counts.json").write_text(json.dumps(word_counts, indent=2))
    round3_spend = _read_cost_log().get("total_cost", 0.0) - start_spend
    print(f"round 3 spend: ${round3_spend:.4f} (guard ${SPEND_GUARD:.2f})")


if __name__ == "__main__":
    run(sys.argv[1] if len(sys.argv) > 1 else None)
