# T1 experiment — REPORT

Held-out ground-truth test: can Hermes-4-405B write PERIHELION's TERMINAL 1
(`DIALOGUE_SCAFFOLD.md`, "SCENE 1 / TERMINAL 1") to a first-draft-usable
standard, given (1) the temperature fix and (2) real project-voice
exemplars instead of zero examples? Terminal 1's actual text was never
shown to the model — only Scene 0's draft (plus the locked voice specs)
was given as positive exemplar, per the director's correction that
`corpse_lines.json` is pipeline-generated and not eligible as ground truth.

Judge is me (the generating agent), reading against the director's actual
Terminal 1 draft in `DIALOGUE_SCAFFOLD.md` lines 390-609. The director will
re-judge the samples himself; this report does not overclaim.

## Conditions

| Label | Prompt | Temp | top_p | File |
|---|---|---|---|---|
| A | new (positive exemplar) | 0.00 | 1.0 | `A_new_prompt_t0.00.md` |
| B | new (positive exemplar) | 0.25 | 1.0 | `B_new_prompt_t0.25.md` |
| C | new (positive exemplar) | 0.50 | 1.0 | `C_new_prompt_t0.50.md` |
| D | new (positive exemplar) | 0.90 (OLD toolchain typical) | 0.94 | `D_new_prompt_OLDtemp0.90.md` |
| E | OLD-style (zero examples) | 0.25 (NEW) | 1.0 | `E_OLDprompt_newtemp0.25.md` |

A-C isolate the new temperature band. D holds the new prompt fixed and
swaps in the old toolchain's typical temperature, isolating temperature's
effect. E holds temperature fixed at a new value and swaps in the old
zero-exemplar prompt style, isolating the exemplar effect. Total cost for
all five calls: **$0.037** (see `tools/dialogue/cost_log.json`, entries
tagged `"tool": "t1_experiment"`).

## What Terminal 1 actually requires (the five endpoints, per the brief)

1. Testament conclusion — station-as-warning-device, Commando names the
   builders in his own word.
2. The scuttle reveal — she has already, unilaterally, put the station on
   a solar-impact course.
3. THE GUN — asked if it'll work, she says flatly she doesn't know.
4. Handoff to the sample container.
5. THE CROSSED CLOSER — one voice opens "restore life/Man to the surface
   of the Earth," the OTHER voice finishes it in their own vocabulary's
   word. This is the single hardest beat: it requires the sentence to
   split across BOTH speakers, each contributing their own word.

Plus, on exactly one of three re-approach options in the trust==0 branch:
the christening — Ratio, unprompted, gives HIM a name for the first time
(canon: F3/F9, "the christening is Ratio's, period" — never his own
self-naming, never on more than one branch).

## Per-condition verdict

### A — new prompt, temp 0.00
**Structure:** hits 1/2/3/4. **Fails 5 (crossed closer)**: Ratio says "We
will restore life to the surface of the--" and Commando just *completes her
sentence* ("--Earth. Yes. We will.") — this is one continuous sentence, not
two speakers each contributing their own vocabulary word. The entire point
of the beat (Ratio's faction says "life," Commando's faction says "Man,"
and they meet in the middle) is absent — neither word ever appears.
**Christening: present but backwards.** Commando self-names ("You can call
me Six"), Ratio just accepts it — inverts the locked ruling that the
christening is hers to make, unprompted.
- Best line: "I've seized control of the station's maneuvering systems.
  I'm driving it directly into the sun." — plain, declarative, correctly
  unhedged for an already-completed unilateral act.
- Worst line: "COMMANDO: 'Ratio. A pleasure. You can call me Six.'" — the
  self-naming inversion; also faintly buddy-cop in tone, wrong register for
  either voice.

### B — new prompt, temp 0.25
**Structure:** hits 1/2/3/4. **Fails 5 differently**: Commando delivers the
full canonical line unsplit ("We will restore life to the surface of the
Earth"), then Ratio bolts on an *invented* new sentence ("-and seed it with
the legacy of a thousand worlds") that isn't in the brief and isn't a
vocabulary-crossing device at all — confabulated lore. **Christening:
missing entirely** — no branch names him. **Structural bug**: the
`<<IF trust+1>>` gate collapses two of the three choice branches
(apologetic and pragmatic) into one identical outcome — a real authoring-
format failure, not just a content miss; a compositor would silently lose
one branch's distinct content.
- Best line: "I've completed my analysis of the station's purpose." — clean,
  in-register bookkeeping voice.
- Worst line: "RATIO: '-and seed it with the legacy of a thousand worlds.'"
  — invented, ungrounded, and the clearest single instance of the
  "vaguely coherent" failure mode across all five samples: it sounds fine
  in isolation and answers nothing the scene needed.

### C — new prompt, temp 0.50 (best of the three new-temp draws)
**Structure:** hits all 5. Crossed closer lands correctly in form ("We
will restore humanity to the surface of the Earth." / "We will restore Man
to the surface of the Earth.") — uses "humanity" rather than the brief's
suggested "life," a near-miss on word choice but a structurally correct
execution of the device (two speakers, two words, one sentence). The
christening ("Let's call you... John. It seems fitting, somehow.") lands on
exactly one of the three sub-branches, as required, and the other two
sub-branches are genuinely distinguishable in content (not just tone).
- Best line: "Let's call you... John. It seems fitting, somehow." — the
  one moment across all five samples that gets the mechanic (her
  unprompted, slightly arbitrary christening) structurally right, even if
  "John" itself is a flat, un-inventive choice next to the director's own
  instinct for something odder.
- Worst line: "You have no right to decide the fate of humanity. I will
  take that container, with or without your cooperation." (Commando,
  defiant branch) — generic action-movie ultimatum, no trace of his
  laconic/Christlike-humor register, reads like stock-villain-adjacent
  dialogue for the wrong character.

### D — new prompt, OLD temp 0.90/top_p 0.94 (isolates temperature)
This is the cell that most directly tests the director's hypothesis, and
it supports it. Same prompt as A-C, only the temperature changed, and it
is the worst-behaved of the four new-prompt draws:
- **Stray malformed output**: a line ("COMMANDER SIGNAL INTEGRITY 94%")
  and an un-gated RATIO line appear *before* the `<<IF trust>0>>` token —
  format corruption that never appears in A/B/C.
- **Canon violation**: RATIO's own line says "I believe this station is a
  testament" — "testament" is reserved, per NARRATIVE_DESIGN_DOC.md S8.3,
  as *Commando's* word for the station ("the Testament"); Ratio's own
  vocabulary is "the station" / "Track Quanta-118093." This is exactly the
  kind of vocabulary-taboo violation the brief explicitly forbids.
- **Christening fires on all three branches**, not one — she calls him
  "Commander" regardless of which option is chosen, flattening the
  supposed-to-be-singular grace note into boilerplate.
- Crossed closer breaks down into invented content not in the brief at
  all ("the zygotes must reach the surface of the Earth" / "the samples
  must reach the surface of the Earth") — no life/Man split, and it
  smuggles "zygotes" into the exchange, which nothing in the brief called
  for.
- Best line: "I don't know. I think it's our best option." — a passable,
  compact version of THE GUN.
- Worst line: "RATIO: I believe this station is a testament." — the
  clearest canon violation in the whole experiment, and it happened at the
  old temperature with the identical (new, exemplar-bearing) prompt that
  produced zero canon violations at 0/0.25/0.5.

### E — OLD-style prompt (zero exemplars), NEW temp 0.25 (isolates exemplars)
Same temperature as B, only the exemplar/negative-contrast block removed
and the Marathon exhibit substituted (the toolchain's actual old
no-project-voice-example condition). This is the clearest single piece of
evidence for the exemplar hypothesis:
- **Crossed closer fully collapses**: both halves of the line are spoken by
  RATIO alone ("We are restoring life to the surface of the Earth. We are
  restoring Man to the surface of the Earth.") — Commando never speaks at
  all in this beat. No voice-crossing whatsoever; the device is entirely
  absent even though the words "life" and "Man" both appear.
- **Naming beat inverted**: on the truce option, Ratio offers her *own*
  name ("You can call me Ratio, by the way") instead of naming him — the
  self-introduction move partially echoes an *unrelated* real canon beat
  from the actual `==0` branch (where she does eventually say "I'm Ratio"),
  but never proceeds to the harder, load-bearing half: she never gives him
  a name.
- **Choice menu reads as UI, not dialogue**: numbered plain-text options
  ("1. I'm here to complete the mission. Let's focus on that.") rather
  than voiced COMMANDO lines — a register regression toward the flat
  administrative tone of the shipped negative-control script.
- **Salad test**: "My emotional state is irrelevant. The mission is what
  matters." — technically coherent, zero specificity, could be spoken by
  any competent-AI-assistant narrator in any game. This is the "vaguely
  coherent word salad" failure mode by name, and it's the single flattest
  line in the entire five-condition sample.
- Best line: "I do not know if this will actually work. I do not know if
  it actually stops the threat. That is the truth." — a genuinely decent,
  terse rendering of THE GUN, on par with C's.
- Worst line: "My emotional state is irrelevant. The mission is what
  matters." — see above.

## Voice fidelity against 5.2b / addenda / 8.2c (cross-condition)

None of the five samples reach the director's own density. Specific
misses, common to all five:
- **No escalating stall.** The director's Terminal 1 draft doesn't even
  use the graduated three-line stall (that's Scene 0's device), but 8.2c.2
  calls for pause length tracking emotional load throughout the whole
  arc — none of the five samples vary pause length meaningfully at the
  scuttle reveal or THE GUN, the two highest-load lines in the scene. C and
  E use a single `{TRANSFER PAUSES FOR N ms}` each; A/B/D barely use the
  device at all in this scene.
- **Commando is too talkative and too smooth.** 5.2b requires him laconic,
  literal-humor, trigger-pull lines. All five samples give him complete,
  grammatically fluent, faintly expository questions ("Will that work?
  Will it actually stop the threat?") — competent but generic; none
  attempt the interruption device the director's own Terminal 1 draft uses
  ("Stop interrupting me") or a dry joke.
- **Ratio's register is closer to the target than Commando's** in every
  sample — the "I don't know" GUN admissions (A/B/C/D/E all get some
  version of this) are the single most reliably well-executed beat across
  all five conditions, at every temperature and in both prompt styles.
  This is a genuinely positive, non-trivial result: it's the one place
  every condition converges on something usable.
- **No mechanical grammar violations found** for `{ALLCAPS}` / pause-token
  syntax in any sample — all five correctly separate her "confessing"
  prose from his "surveilling" `{...}` annotations, which is a real craft
  rule (8.2c.2) none of the samples broke.

## Salad test — explicit

Only two lines across all five samples read as pure, content-free salad in
the diagnosed sense (fits any narrator, forbids nothing):
- E: "My emotional state is irrelevant. The mission is what matters."
- B: "-and seed it with the legacy of a thousand worlds." (salad of a
  different kind — ungrounded invented lore rather than flat corporate
  tone, but equally symptomatic of the model reaching for *something* to
  say rather than the specific next true thing)

Both are concentrated in temp>=0.25 conditions; A (temp 0.00) has no
comparable line. This is weak evidence (n=1 per cell) but directionally
consistent with the director's hypothesis on register alone, independent
of the canon-violation evidence from D.

## Recommendation

**Viable as a first-draft generator: for the mechanical/plot skeleton
(the five endpoint beats, branch gating, choice bookkeeping), yes, at any
of the new temperatures, with the new exemplar prompt.** C (temp 0.5)
executed the full beat structure, including the hardest device (the
crossed closer, the singular christening), correctly on the first draw. A
director editing C would be filling in specific word choices and punching
up Commando's terseness, not rebuilding structure.

**Not viable yet for exact voice.** Every sample's Commando reads as a
competent, slightly generic action-adventure soldier rather than the
specific laconic/Christlike-humor character in 5.2b — none of the five
attempted a joke, an interruption, or a register shift under pressure. None
match the density of the director's own prose (his Terminal 1 draft
reaches its five endpoints in roughly a third of the words any of these
samples use).

**The two changes are not equally load-bearing.** Holding the prompt fixed
and only changing temperature (D vs. A/B/C) produced the experiment's one
clear canon violation (Ratio using "testament") and its only structural
corruption (stray pre-gate text, all-three-branches christening). Holding
temperature fixed and only removing the exemplar (E vs. B) produced the
experiment's flattest line and its only complete crossed-closer failure
(one speaker doing both halves). Both changes independently mattered; on
this small sample the exemplar change did more to fix specific canon
devices (the crossed closer, the christening direction) while the
temperature change did more to prevent outright corruption/canon breaks.
The director's original suspicion (temperature was the main culprit) is
only partially supported — the exemplar fix looks at least as consequential,
possibly more so, for whether the *voice-specific* devices land correctly.

**Anything surprising:** the highest of the three new temperatures (C,
0.50) produced the single best-structured sample of the five, better than
temp 0.00 (A) — a reminder not to over-read n=1 draws per cell, and a
concrete argument for keeping some spread in the new band (0/0.25/0.5)
rather than collapsing to temp 0 alone, since 0.5 was not visibly worse
here and A's temp-0 draw had its own distinct failure (the backwards
christening). The failures were also not simply "more salad" as temperature
rose — they were specific, identifiable canon and structural violations
(D's "testament," B's collapsed branch gate, D's triple christening), which
argues for validating future batches against the specific canon
constraints (vocabulary taboos, singular-branch gating) rather than a
generic "does it sound good" pass.
