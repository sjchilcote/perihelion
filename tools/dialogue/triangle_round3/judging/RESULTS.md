# Triangle round 3 — blind judging results (2026-07-11)

Judges: 4 fresh Sonnet subagents, 3 trials each, texts fully inlined, no
tools, no repo/pipeline/director contamination in prompts. Odd-one-out
framing per protocol; correct answer = the director's text (truth).
Candidates: the LINTED round-3 variants (`*_F1..F4.linted.txt`) per
`tools/dialogue/triangle_round3/RUN.md`.

## Administration (fixes applied, verified against round 2's mistakes)

Round 2 had two administration failures: the pair schedule drifted from
all-6-unordered-pairs (assembly error, some pairs repeated/skipped), and
one trial was sent with no truth text at all (caught only after the judge
answered, forcing a rerun).

This round both are fixed at the source, not patched after the fact:

- **Schedule generated programmatically.** `judging/build_trials.py`
  enumerates `itertools.combinations` over the 4 candidates per scene,
  producing exactly the 6 unordered pairs per scene (12 trials total, no
  repeats, no gaps). Truth position within each 3-slot trial is drawn from
  `random.Random(trial_index)` — seed = trial index, so the schedule is
  reproducible from the trial number alone.
- **Every assembled prompt validated before any judge saw it.** A
  `validate()` step asserts, per trial: exactly 3 texts present, exactly 1
  of the 3 is byte-identical to the truth file (after whitespace strip),
  the recorded `truth_label` actually points at that text, and none of the
  candidate filenames / round-number / pipeline-vendor terms leak into the
  shown text (word-boundary regex, since a GUID hex string in one
  candidate coincidentally contains the substring "F2" — a false positive
  the first version of the check caught and had to be relaxed to
  word-boundary matching). All 12 trials passed validation before dispatch.
- Full schedule + ground-truth key: `judging/schedule.json` /
  `judging/key.json`. Assembled per-trial prompts (for audit): `judging/prompts/`.

One judge-reasoning anomaly worth flagging for future rounds (not an
administration bug): in trial01, the judge's stated tell claimed "X and Z
are character-for-character identical." This was checked directly against
the assembled prompt file — false; X (3312 chars) and Z (2411 chars) are
distinct texts. The judge reached the correct final answer anyway via the
TRUST-tag/register signal also cited, but the false sub-claim is a
reliability caveat on that judge's transcript, not a schedule/validation
defect (the file `trial01_scene0_F1vF2.txt` was directly diffed to confirm
X != Z).

## Per-trial results

| Trial | Scene | Pair (candidates) | Truth at | Judge pick | Correct? | Conf | Tell (abridged) |
|------:|--------|-------------------|----------|------------|----------|-----:|-----------------|
| 01 | scene0 | F1 v F2 | Y | Y | YES | 98 | TRUST-tag menu convention + reworded prose vs the two candidates (tell also included a false "X/Z identical" sub-claim, see note above) |
| 02 | scene0 | F1 v F3 | X | Z | no  | 78 | Judge grouped X+Y on shared "moderate confidence...disconfirmatory evidence" hedging jargon, called Z (the true text) the outlier |
| 03 | scene0 | F1 v F4 | X | Z | no  | 85 | Judge grouped X+Y on a verbatim shared clause ("arrived, _destructively_...armed and unannounced") + TRUST-tag menus, called Z (the true text) the outlier |
| 04 | scene0 | F2 v F3 | X | X | YES | 85 | X's exposition is plain vs Y/Z's shared "moderate confidence...disconfirmatory evidence" jargon |
| 05 | scene0 | F2 v F4 | X | X | YES | 82 | X's menu options uniquely reworded vs Y/Z's shared phrasing + "Ratio is taking a long time to think" flavor text |
| 06 | scene0 | F3 v F4 | Z | X | no  | 85 | Same hedging-jargon tell as 02/04, but here it misfired: judge called X odd, truth was Z |
| 07 | t1     | F1 v F2 | Z | Z | YES | 85 | Truth uses "Quanta-118093"/CUCULUS naming + heavier crude humor; both candidates share "Perihelion Station"/FABER naming |
| 08 | t1     | F1 v F3 | Y | Z | no  | 85 | Judge misattributed which text carried which station name; called Z odd, truth was Y |
| 09 | t1     | F1 v F4 | X | X | YES | 85 | Same Quanta/CUCULUS-vs-Perihelion/FABER naming tell, correctly applied |
| 10 | t1     | F2 v F3 | Y | X | no  | 90 | Judge cited a shared loredump-passage match between the wrong pair; missed the true text |
| 11 | t1     | F2 v F4 | Z | Z | YES | 82 | Same naming tell (Quanta/CUCULUS vs Perihelion/FABER), correctly applied |
| 12 | t1     | F3 v F4 | Y | Y | YES | 82 | Same naming tell, correctly applied |

## Accuracy

- **Overall: 7/12 correct (58.3%)** vs chance 1/3 (4/12 expected).
  One-sided binomial P(>=7 correct | n=12, p=1/3) ~= 0.066 — no longer
  significant at the conventional 5% threshold (round 2 was P ~= 4.7e-5).
- **Scene 0: 3/6 (50%)**, P(>=3 | n=6, p=1/3) ~= 0.32 — statistically
  indistinguishable from chance.
- **Terminal 1: 4/6 (66.7%)**, P(>=4 | n=6, p=1/3) ~= 0.10 — still above
  chance but not significant at 5%.
- Mean confidence on correct picks: 85.6. Mean confidence on wrong picks:
  84.6. Confidence is **not calibrated to correctness this round** — in
  round 2 the single miss carried visibly lower confidence (65 vs 84.5
  mean-correct); this round judges were just as confident when wrong.

## Tell categories

| Category | Trials citing it | Notes |
|----------|------------------|-------|
| **register / word-choice jargon** | 01, 02, 03, 04, 06, 07, 09 (7) | Dominant this round. Mostly the shared "moderate confidence...strong confidence...disconfirmatory evidence" hedging phrase, present (in exact or paraphrased form) in more than one candidate per scene0 trial — this pattern misfired twice (02, 06), correctly discriminated once (04). |
| **canon-leak (invented proper nouns)** | 07, 08, 09, 11, 12 (5) | New this round — round 2 saw zero canon-leak citations. All 4 t1 candidates independently converged on "Perihelion Station" / "FABER" naming, while truth uses "Quanta-118093" / "CUCULUS" — a universal, structural leak (see below), correctly exploited in 4/5 citing trials, misattributed once (08). |
| **structure (shared passage / menu wording)** | 03, 05, 10 (3) | Verbatim or near-verbatim shared clauses between two of the three texts; correctly used in 05, misfired in 03 and 10. |
| **format (TRUST-tag convention, flavor text)** | 01, 05, 10 (3) | The round-2-dominant category is nearly gone — `format_lint.py` did its job. Only survives as a secondary signal. |
| **density / compression** | 0 | Not cited this round. |
| **mode-collapse (gen-vs-gen near-duplicate claim)** | 01 (1, and factually false — see administration note) | Round 2's biggest mechanism (6/12 trials) is essentially absent — the 4-framing decorrelation held. |

### The canon-leak finding is structural, not noise

Checked directly against the candidate files: **every one of scene0_F1
through F4 opens with "Quanta-118093"**, while truth_scene0 opens with
"Track [forget-the-number]." **Every one of t1_F1 through F4 uses
"Perihelion Station"/"FABER,"** while truth_terminal1 uses
"Quanta-118093"/"CUCULUS." This is not sampling noise across 4 decorrelated
framings — it is a consistent, scene-wide default the model reverts to
regardless of prompt architecture (device-key single-shot, method-actor,
beat-shuffled, or register-editor). In t1 this is a strong, mostly-correct
discriminator (4/5 citing trials right). In scene0 it should be an even
stronger signal (all 4 candidates share a name truth never uses) but
judges did not weight it — the register-jargon tell dominated their
reasoning instead and led them astray twice.

## Comparison to round 2 (11/12, 91.7%, P ~= 4.7e-5)

Round 2 was a decisive, near-unanimous fail: judges cited format/markup
fingerprints (header conventions, TRUST-tag bracket style, spelled-out vs.
macro'd loredump) in 10/12 trials, and 6/12 trials were effectively decided
by elimination because the two generations were near-clones of each other.
Round 3's fixes (format_lint.py, register key, 4 decorrelated framings,
measured density targets) removed both of those mechanisms almost
entirely — format tells collapsed from 10/12 to a secondary role in 3/12,
and the gen-vs-gen mode-collapse mechanism that made round 2 "trivial by
elimination" is gone (the one citation this round was itself a
misobservation). Accuracy dropped from 91.7% to 58.3%, and the round is no
longer statistically significant overall (P ~= 0.066 vs P ~= 4.7e-5) — a
genuine, large step toward indistinguishability, not just a smaller margin
of the same failure.

## Read: fixable-by-iteration vs structural

**Fixable by iteration, cheaply:**
- The universal "Perihelion Station"/"FABER" (t1) and "Quanta-118093"
  (scene0) naming convergence across all 4 candidates is a one-directive
  fix — forbid the model's default canon term in the brief, or force
  per-framing distinct invented names, the same way `format_lint.py` forced
  header/tag parity. This is squarely a prompt-completeness gap, not a
  capability limit: the model has a strong naming prior (plausibly the
  project's own working title bleeding into generation) and nothing in the
  round-3 briefs told it not to use it.
- The shared hedging-jargon phrase ("moderate confidence...strong
  confidence...disconfirmatory evidence") recurring near-verbatim across
  scene0 candidates suggests the brief itself over-specifies this
  formulation rather than describing the underlying fact loosely enough
  for the model to phrase it differently per framing — also a brief-text
  fix.

**More structural, needs a different lever:**
- Confidence miscalibration (85.6 correct vs 84.6 wrong — no separation)
  is not a content property of the candidates; it is a judge-behavior
  property. Round 2 didn't need to solve this because the accuracy gap
  did the work. As accuracy keeps closing, calibrated confidence becomes
  load-bearing for anyone using these judgments to decide "is this good
  enough" — and nothing in round 3's design targeted it. Worth an explicit
  ask-for-calibration instruction next round, but that is a judging-protocol
  change, not a generation-pipeline one.
- Scene0's near-chance result (50%, P~=0.32) despite candidates sharing an
  even *stronger* naming tell than t1's suggests the remaining gap there
  isn't about signal availability but signal salience/weighting in a
  single read-through — a genuinely harder problem than "the text leaks
  a fact," since the fact was present and still missed twice.
