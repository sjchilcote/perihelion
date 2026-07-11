# Triangle round 3 — fixing the four judged tells (2026-07-11)

Round 2 lost 11/12 blind trials (91.7% identified, decisive fail). This
round targets the four tell categories from
`tools/dialogue/triangle_round2/judging/RESULTS.md`, in the leverage order
the director specified: format parity (code, not prompting), register,
decorrelation, per-speaker density. Judging is NOT run here — that's the
main session's job. This file reports what was built and measured.

## 1. Format parity via code — `format_lint.py`

A deterministic, idempotent post-formatter with three passes:

1. **`normalize_header`** — replaces whatever session-open lines a
   generation wrote with the scene's canonical convention: scene0 gets the
   3-line `CARRIER DETECT` / `ATTEMPTING PROTOCOL NEGOTIATION` / `LIVE
   COMMUNICATION ESTABLISHED` header; t1 gets the single collapsed `LIVE
   COMMUNICATION ESTABLISHED` line only (per the t1 brief's fast-path rule).
2. **`normalize_trust_tags`** — rewrites any `TRUST` delta annotation,
   regardless of the bracket style the model chose, into the scene's own
   convention: scene0 → `<TRUST +N>` (angle brackets, no internal spaces);
   t1 → `[TRUST + N]` (square brackets, spaced). These differ ON PURPOSE
   (matches the truth files) — parity means per-scene matching, not global
   normalization.
3. **`collapse_repeated_blocks`** — line-granularity (not paragraph-
   granularity, see below) anchor-based duplicate detection: finds a block
   of >=30 words that repeats at >=80% similarity elsewhere in the
   document, tags the first occurrence `<:label>`, replaces every later
   occurrence with `<goto :label>`. This directly fixes round 2's biggest
   structural tell — 10/12 judge trials cited gens spelling the shared
   loredump out 2-3x verbatim (and tripling the `[EXCISED SPAN B]` marker
   along with it) instead of using the truth's own macro idiom.

**Bug found and fixed during build**: the first implementation split on
blank-line-delimited paragraphs and used pairwise-greedy match selection.
Both were wrong for the real data. (a) One round-3 generation (`t1_F4`,
the register-expansion editor) wrote each branch as consecutive
single-newline lines with no interior blank lines, so an entire branch
collapsed into one "paragraph" and diluted the match ratio below
threshold — switched to line-level matching, with blank-line-vs-blank-line
treated as a trivial match so runs still align correctly across both
formatting styles. (b) With 3 occurrences of the same block, pairwise
greedy selection (highest first) could select occurrences 1+2, leaving
occurrence 3 an orphan with no anchor — switched to anchor-based
clustering: for each first-occurrence-in-document, find ALL later matches
against that same anchor in one pass, so 3+ duplicates all resolve to the
same `<:label>`.

**Idempotency**: verified mechanically on every file — the tool runs
itself twice on each candidate and asserts the second pass's transformation
log is empty and output is byte-identical. All 16 files (8 round-2 + 8
round-3) pass.

**Applied to all round-2 AND round-3 candidates.** Per-file transformation
counts:

| File | Transformations |
|---|---|
| scene0_A1 | 4 (header + 3 trust-tags) |
| scene0_A2 | 4 |
| scene0_B1 | 4 |
| scene0_B2 | 4 |
| t1_A1 | 6 (3 trust-tags + loredump collapse: tag + 2 gotos) |
| t1_A2 | 6 |
| t1_B1 | 6 |
| t1_B2 | 6 |
| scene0_F1 | 1 (header only — trust tags were already `<TRUST +N>`) |
| scene0_F2 | 4 |
| scene0_F3 | 4 |
| scene0_F4 | 4 |
| t1_F1 | 0 (already canonical) |
| t1_F2 | 3 (trust-tags only) |
| t1_F3 | 0 (already canonical) |
| t1_F4 | 6 (3 trust-tags + loredump collapse: tag + 2 gotos) |

14/16 files needed at least one fix; every round-2 t1 candidate and one
round-3 candidate (`t1_F4`) had the tripled-loredump structural tell,
now collapsed. Two round-3 files (`t1_F1`, `t1_F3`) needed zero
corrections — the improved prompts got the header and tag conventions
right unassisted for those two.

## 2. Register — device key with quoted exemplar lines

Added `REGISTER_KEY_FOR_SCENE0` / `REGISTER_KEY_FOR_T1` in `run_round3.py`:
positively-framed device keys quoting the CROSS-HOLDOUT-legal exemplar's
own crude-wit lines (never the target scene's own truth). For scene0
generation (exemplar = Terminal 1): "It is I, the fucked," the
quote...en-quote scare-quote tic, aimed compound profanity
("christofascist _fucks_"), the "spare undies" deadpan-literalism device.
For t1 generation (exemplar = Scene 0): the macerator-joke double duty,
"I am so, so, so sorry" apology-as-repetition, the "***WE***" escalating-
typography detonation, the half-elided "Track [forget-the-number]" catalog
habit. Each key explicitly instructs: reproduce the DEVICE at the target
scene's own beats, not the exemplar's literal words (plagiarism guard).

## 3. Decorrelate the pair — four genuinely different framings

Per scene, 4 candidates from 4 distinct prompt architectures (not just
temperature draws):

- **F1** device-key single-shot (round 2's family A, carried forward with
  register + per-speaker density folded in), temp 0.3
- **F2** "method actor" — system prompt addressed to the model in 2nd
  person AS Ratio and the Commando (a character-bible framing, not
  writer-instructions framing), temp 0.4
- **F3** beat-order-shuffled brief — identical facts to F1's brief, but
  presented in reordered chunks (edges-inward: shortest routes first,
  endings before openings, loredump beats listed in reverse) so the model
  isn't pattern-completing a memorized beat sequence, temp 0.3
- **F4** revise-for-register — an editor pass over an EXISTING round-2 B
  (cut-for-density) candidate that ADDS wit/expansion instead of cutting;
  round 2's B family only ever cut, this direction was untested, temp 0.3

### Pairwise distance matrix (measured on LINTED candidates — format tells
already removed, so what's left is content/register/word-choice distance)

**scene0 — Jaccard (word-level, 1 = totally disjoint vocabulary)**

| |truth|F1|F2|F3|F4|
|---|---|---|---|---|---|
| **truth** |0.00|0.53|0.53|0.43|0.46|
| **F1** |0.53|0.00|0.49|0.46|0.43|
| **F2** |0.53|0.49|0.00|0.47|0.48|
| **F3** |0.43|0.46|0.47|0.00|0.40|
| **F4** |0.46|0.43|0.48|0.40|0.00|

**t1 — Jaccard**

| |truth|F1|F2|F3|F4|
|---|---|---|---|---|---|
| **truth** |0.00|0.37|0.35|0.49|0.38|
| **F1** |0.37|0.00|0.28|0.44|0.44|
| **F2** |0.35|0.28|0.00|0.43|0.40|
| **F3** |0.49|0.44|0.43|0.00|0.52|
| **F4** |0.38|0.44|0.40|0.52|0.00|

Full matrices (Jaccard + difflib) for both scenes are in
`distance_matrix.json`; `distance_matrix.py` also prints a difflib
(`1 - SequenceMatcher.ratio`) table for both scenes.

**Decorrelation bar** (round 2 failed this: two gens per trial routinely
read as "the same template reskinned," handing the judge the answer by
elimination): flag any gen-vs-gen pair whose distance falls below 60% of
the mean gen-vs-truth distance for that scene.

- scene0: **PASS** — closest gen pair is F3/F4 at 0.40 vs mean
  gen-vs-truth 0.49 (81%, above the 60% floor). No pair reads as a clone.
- t1: **PASS** — closest gen pair is F1/F2 at 0.28 vs mean gen-vs-truth
  0.40 (70%, above the 60% floor) — F1 and F2 are the least-decorrelated
  pair in this round (both are "measured competent-AI" register on t1
  despite different framings) and worth a harder push next round if t1
  fails on a gen-vs-gen mode-collapse tell again, but they clear the bar.

Both scenes clear the bar this round; round 2 would have failed it on
every t1 trial (its A1/A2/B1/B2 were near-duplicates of each other by
construction — B1/B2 are literal edits of A1/A2).

## 4. Per-speaker density — measured targets, not a flat budget

`_speaker_stats()` in `run_round3.py` measures RATIO's and the Commando's
mean words/line directly off the truth files (not the round-2 authors'
hand-counts) and targets each speaker's OWN mean ±25%, plus a total-scene-
length ±20% floor-and-ceiling (not just a ceiling — round 2's failure mode
was compressing everything toward terseness, including RATIO's asides,
which is a tell in the opposite direction).

Measured truth stats (this round's ground source):
- scene0: RATIO mean 17.6 words/line (n=22), Commando mean 9.0 (n=9),
  total 566 words. Target bands: RATIO 13.2–22.0, Commando 6.8–11.2,
  total 453–679.
- t1: RATIO mean 15.1 words/line (n=29), Commando mean 9.4 (n=21), total
  722 words. Target bands: RATIO 11.3–18.9, Commando 7.1–11.8, total
  578–866.

Achieved (measured on linted candidates):

| Candidate | RATIO mean | Commando mean | Total words |
|---|---:|---:|---:|
| scene0_F1 | 22.6 (slightly over) | 12.4 (over) | 570 (in band) |
| scene0_F2 | 13.8 (in band) | 9.0 (in band) | 420 (just under band) |
| scene0_F3 | 10.4 (under band) | 9.5 (in band) | 443 (just under band) |
| scene0_F4 | 16.5 (in band) | 7.5 (in band) | 529 (in band) |
| t1_F1 | 12.5 (in band) | 6.3 (just under band) | 551 (just under band) |
| t1_F2 | 15.2 (in band) | 6.1 (under band) | 623 (in band) |
| t1_F3 | 11.0 (just under band) | 8.4 (in band) | 600 (in band) |
| t1_F4 | 21.4 (over band) | 7.9 (in band) | 854 (in band, near top) |

Real improvement over round 2 (whose candidates ran 420–451 words for
scene0 against a 566-word truth, and 994–1055 for t1 against a 722-word
truth after de-duplication — i.e. t1's word counts were inflated by
tripled content, not real density) but not perfect: the Commando still
runs slightly short on t1 across F1/F2 (machine terseness is an easy
local-minimum the model keeps finding), and F1/F4 on scene0 push RATIO
and/or the Commando past the upper band on their respective scenes.

## Honest tells remaining per candidate (content read, post-lint)

- **scene0_F1**: strong content parity, hits the "christofascist _fucks_"
  device correctly, but the Commando's lines run long for him (12.4
  words/line average, several lines carry two clauses where the truth
  gives him one) — this is the clearest remaining "generic competent AI"
  residue in this batch.
- **scene0_F2** (method-actor): best density fit but noticeably safer
  register than the exemplar — no compound-profanity detonation landed at
  the intended beat, softened to "You don't get to decide that."
- **scene0_F3** (beat-shuffled): RATIO runs terser than target (10.4 vs
  13.2 floor) — the shuffled-brief framing seems to have pushed the model
  toward efficiency rather than her discursive register; still hits the
  scare-quote and profanity devices.
- **scene0_F4** (register-expansion editor): best-balanced density of the
  four; watch for the editor's added material reading as pasted-in rather
  than organic — a close read is warranted before this one is used as-is.
- **t1_F1**: three explicit `{TRANSFER PAUSES FOR N ms}` tokens in a row
  with no accompanying escalating PROSE stall lines (the brief's
  three-tier stall device is only half-implemented — pause tokens present,
  her "Thinking..."-style narration missing).
- **t1_F2** (method-actor): same partial-stall issue as F1; Commando runs
  short (6.1 words/line, well under the 7.1 floor) — closest in raw
  Jaccard to F1 (0.28), the weakest decorrelation pair this round.
  Register itself is good — the profanity/detonation beat and the
  quote-tic both landed.
  For a judge, this is the "same template" panel the round 2 tell would
  have found again.
- **t1_F3** (beat-shuffled): correctly uses `<goto :loredump>` unassisted
  (no lint transformation needed) — cleanest structural output in the
  round; RATIO sits right at the density floor.
- **t1_F4** (register-expansion editor): richest content, best RATIO
  density, but originally over-length (1242 raw words, nearly double
  target) because the editor pass re-wrote the loredump out three times
  under the trust==0 sub-branches instead of reusing the goto label —
  exactly the failure mode `format_lint.py` exists to catch, and it did:
  post-lint the file lands at 854 words, inside the target band.

## Spend

Round 3 generation: **$0.0625** total (8 Hermes-4-405B calls, one per
framing per scene), against the $10 spend guard — nowhere close, confirmed
via `run_round3.py`'s `SPEND_GUARD` check (raises if round-3-only spend
exceeds the guard; never triggered). Per-call costs ranged $0.0057–$0.0108.
Project-total spend after this round: **$2.976** (up from $2.914 before
round 3).

## Deliverables

- `tools/dialogue/triangle_round3/format_lint.py` — the formatter (fix #1).
- `tools/dialogue/triangle_round3/run_round3.py` — round-3 generation (fixes
  #2/#3/#4): register key, 4 decorrelated framings, measured per-speaker
  density targets.
- `tools/dialogue/triangle_round3/distance_matrix.py` — pairwise
  Jaccard/difflib distance measurement + decorrelation-bar check (fix #3
  verification).
- `tools/dialogue/triangle_round3/candidates/{scene0,t1}_F{1,2,3,4}.txt` —
  4 final candidates per scene, raw generation output.
- `tools/dialogue/triangle_round3/candidates/*.linted.txt` — the same
  candidates (plus every round-2 candidate, for a clean before/after) run
  through `format_lint.py`; these linted versions are what should be shown
  to a blind judge.
- `tools/dialogue/triangle_round3/distance_matrix.json` — full pairwise
  distance data backing the tables above.
- `tools/dialogue/triangle_round3/prompts/` — every system/user prompt
  actually sent, one pair per framing per scene.
- `tools/dialogue/triangle_round3/briefs/` — reserved for brief text if a
  future round wants a standalone copy; this round's briefs are generated
  inline in `run_round3.py` (`brief_scene0()` / `brief_t1()`) since two
  variants (canonical + beat-shuffled) exist per scene.

Judging is intentionally NOT run from this tool directory — the main
session runs round-3 blind judging per the same protocol as round 2.
