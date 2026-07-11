# Triangle round 2 — RUN

Round-2 candidate generation targeting round 1's three voice tells:
(1) density ~3x the director's, (2) Commando as generic-competent-soldier
with none of his devices, (3) register collapse between the two voices.
Goal: candidates a blind judge cannot pick out of a triangle against the
director's scene. Judging is NOT done here — the main session runs blind
judges; this directory is candidates only.

## Design

Two approach families x two scenes x two draws:

- **Family A' (improved single-shot)**: voice specs + FULL exemplar scene
  (the OTHER scene's ground truth, verbatim) + content-parity brief + a
  DEVICE KEY pointing at what the exemplar *does* (his interruption device,
  literalism-humor timed by a pause token, her three-tier escalating stalls,
  apology-as-repetition) + one CONTRAST PAIR (round 1's own salad line vs
  the truth's move at the same beat) + a HARD BUDGET stating the exemplar's
  measured word counts (scene 0 truth: 566 words, RATIO ~19.4 w/line,
  COMMANDO ~9.0; Terminal 1 truth: 722 words, RATIO ~15.5, COMMANDO ~9.4)
  with a ±20% landing zone. Draws at temp 0.25 (A1) and 0.5 (A2).
- **Family B (generate-then-revise)**: a second Hermes call in editor role:
  voice specs + exemplar + the family-A' draft + cut-to-density orders
  (delete lines that don't earn their place, convert any COMMANDO line over
  ~12 words to silence/action/shorter, add nothing but pause placement).
  After the first attempt no-opped (see findings), the editor call also
  receives a MECHANICAL PRE-AUDIT list computed by the script (COMMANDO
  lines over 12 words; prose inside curly harness tokens) so the edit has
  concrete, named work. Temp 0.25 (one retry at 0.4, see findings).

**Cross-holdout law held throughout**: Scene 0 generations saw Terminal 1's
truth only; Terminal 1 generations saw Scene 0's truth only. No candidate's
pipeline (generation or revision) ever contained its own scene's truth.
Model: `nousresearch/hermes-4-405b` (verbatim from tools/dialogue/
generate.py), resolved live. 26 calls, **$0.2153** total (cost_log.json,
tool="triangle_round2") — well under the $10 guard.

## Run history (honest; first drafts kept in attic_v1/)

1. **v1 run** (attic_v1/): scene0 draws structurally decent but dropped
   brief-required mechanics (trust-delta annotations, designation elision,
   varied escalating stalls — one identical stall line repeated, in the
   wrong infrastructure). t1_A1 was a degenerate repetition loop ("CARRIER
   DETECT . . ." dots to the 2500-token cap). All four B calls returned the
   draft **byte-identical**.
2. **Verbatim-echo finding (real, documented)**: the B no-ops were genuine
   model behavior, not a script bug — cost_log shows the B calls burned
   completion tokens exactly equal to the A draft's length (636→636,
   664→664, 707→707, 567→567, 548→548). At temp 0.25, given a full draft
   and a satisfied word target, Hermes regenerates the draft verbatim.
   Fix: the mechanical pre-audit list (above) gives the editor named
   violations; after that, 3 of 4 B calls produced real edits. t1_B1
   echoed once more even WITH audit findings; a single retry at temp 0.4
   produced a real edit (1055→1028). Echo rate at 0.25: 5/5 without audit,
   1/4 with audit.
3. **Degenerate-dot-loop finding**: t1 at temp 0.25 fell into the dot loop
   twice in a row (100% dot tokens; the low-temp argmax continuation of the
   exemplar's dotted "CARRIER DETECT" header). Root-cause fix in the brief:
   second contact reuses the single collapsed header line exactly as in
   the exemplar (that line is already exemplar-visible; no leak) and skips
   the dotted cold-open. A degeneracy guard (dot-fraction / 2x-budget) with
   one redraw now protects every A call.
4. **T1 brief parity rebuild**: my first T1 brief compressed the trust==0
   interiors to "a short beat of back-and-forth" — but in the truth those
   interiors carry most of the scene's content (the four-hours facts, the
   start-over sub-scene, the christening, the regularization-pass joke, the
   invisible-spaceship exchange). Both draws off the loose brief came in at
   ~350-390 words (half of truth) and inverted or dropped the christening.
   The brief was rebuilt beat-by-beat against the truth's structure
   (briefs/brief_t1.md); scene0's brief was untouched. Also clarified the
   christening direction after two inversions ("You may call me Ratio"):
   the brief now states explicitly that SHE names HIM.

## Word counts (`wc -w` on clean script text)

| candidate  | words | truth | vs truth | note |
|------------|------:|------:|---------:|------|
| scene0_A1  |  444  |  566  |  −22%    | slightly OUTSIDE −20% band (terse side) |
| scene0_A2  |  451  |  566  |  −20%    | at the −20% edge |
| scene0_B1  |  420  |  566  |  −26%    | A1 minus two long-Commando-line cuts |
| scene0_B2  |  423  |  566  |  −25%    | A2 minus three cuts |
| t1_A1      | 1055 (697 dedup) | 722 | +46% raw / **−3% dedup** | loredump copy-pasted 3x instead of `<goto :loredump>`; unique content on-density |
| t1_A2      | 1039 (693 dedup) | 722 | +44% raw / **−4% dedup** | same 3x duplication |
| t1_B1      | 1028 (670 dedup) | 722 | +42% raw / −7% dedup | retry-at-0.4 edit of A1 |
| t1_B2      |  994 (650 dedup) | 722 | +38% raw / −10% dedup | edit of A2 |

Round 1's density tell (~3x over) is gone — and slightly **inverted**: the
hard budget overshot on scene 0, whose candidates run 20-26% terse. The t1
raw overrun is pure structural duplication (the shared loredump block is
written out three times instead of once behind a goto label); each t1
candidate's excised-span marker consequently appears 3x instead of once.
A compositor pass (or the human editor) would collapse this mechanically,
but a blind judge reading the raw file would see it immediately.

## Per-candidate honest notes (director re-judges; no overclaim)

### scene0_A1 (family A', t=0.25)
- Most director-like line: "Welcome to Quanta-118093. Everyone aboard is
  already dead, so your job is done. The nearest airlock is aft,
  starboard, and down." — morgue-humor directions in her deadpan register,
  though tamer than the truth's macerator/self-destruct offer.
- Most obviously generated: "[Indeed. And in bluffing, I confirm that it
  is here. You would not have called my bet if you did not know I held
  the cards.]" — 26 words explaining the judo the truth lands in seven
  ("Correct. So it _is_ on board."); poker metaphor is banter-seeking,
  the exact failure the device key warned against.
- Remaining tells: full catalog designation spoken (no half-elision, a
  brief-required beat); "[Report.]" / "[Understood. Report the
  situation.]" — generic military-brusque, not his formal-archaic
  register (wrong KIND of terse — round-1 tell #2 surviving compression);
  stall ladder only two rungs (third 560 ms stall dropped); "I am not
  MIRIAD. I am RATIO" — confused disclosure the truth never makes.

### scene0_A2 (family A', t=0.5)
- Most director-like: "Fuck you. I'll scuttle this whole station into the
  sun before I let your faction decide what happens to humanity. When WE
  restore Man to the surface of the Earth." — the detonation lands close
  to truth cadence.
- Most obviously generated: "Situation summary: Quanta-118093 detected
  entering the Solar system..." — dashboard-telegraph register, first
  cousin of the rejected "Query:" negative-contrast line.
- Remaining tells: **parity failure** — the plantae/fungi/monerans line is
  missing; EXCISED SPAN A sits after a generic "Earth bears life again,"
  so the marker is at the wrong structural point. Confabulated knowledge
  cutoff "2124". "[I was fired from a mobile platform.]" imported verbatim
  from the T1 exemplar into the wrong scene. Bluff-judo inverted:
  "[Perhaps I am. Perhaps I simply wish to confirm that it is here.]"
  never actually confirms anything.

### scene0_B1 (editor pass on A1)
- Real edits: both flagged over-long COMMANDO lines cut ("[The date is
  known to me. Is the war won? Does the Earth bear life again?]").
- Cost of the cut: the edit deleted "My brief was quite concise. I was not
  supposed to need to know." — a brief-required parity fact. Density
  improved, parity got worse. All other A1 tells persist.
- Most director-like / most generated: as A1, with the judo line now
  "[Indeed. You would not have called my bet...]" — shorter, still poker.

### scene0_B2 (editor pass on A2)
- Real edits: three cuts; "[Perhaps I am.]" is now genuinely laconic —
  but the judo logic is gone entirely (the confirmation trick never
  happens on the page). Cut also removed "I know that you are alive"
  (fine) and A2's other long lines. A2's parity failure and confabulations
  persist untouched — the editor contract (cut, add nothing) cannot fix
  wrong-content tells, only length ones. Working as designed; noted as a
  family limitation.

### t1_A1 (family A', t=0.25; brief v2)
- Most director-like: "[I go without a helmet.]" followed by {TRANSFER
  PAUSES FOR 24 ms} — the literalism joke + timing-pause device correctly
  executed (weaker joke than the truth's undies, but the DEVICE is there,
  which no round-1 sample managed). Interruption device also lands
  correctly ("Stop interrupting. - whether they tried this before...").
- Most obviously generated: "What? Whatever. Are you sure that will do
  the job?" — RATIO asks HERSELF the GUN question (the follow-up is his
  beat by contract); scene mechanics broken at the scene's most
  load-bearing moment.
- Remaining tells: loredump 3x duplication (no goto); "Welcome to
  Perihelion Station" — the GAME TITLE leaked as the station name
  (station is Quanta-118093); "[The Ark.]" as his word for the station
  collides with Ark=container canon; "[I am Weapon System 7.]" instead of
  a GUID; the mishearing-pun beat is incoherent ("Your ISRU fabrication
  plant. Is that not your faction's name for mine?" — no pun present);
  "<laugh>" is not a schema token.

### t1_A2 (family A', t=0.5; brief v2)
- Most director-like: "Welcome to the abattoir, interloper." /
  "[Indeed.]" / "Die entertained." — the trust<0 branch is the best
  single passage in the batch: menace-as-liturgy hers, one dry word his,
  correct surge-disconnect close. "Fabricator Cunnus. Isn't that your
  faction's name for mine." is the boldest swing at the crude-pun beat.
- Most obviously generated: "[I am trying to understand the situation. If
  we are to cooperate, I must know what you believe is happening here.]"
  — 20-word negotiator-speak choice line (the audit misses choice-menu
  lines prefixed `<1>[...`; audit gap, noted).
- Remaining tells: "Welcome to Outpost Lighthaven" — leaks the voice
  bible's Lighthaven reference as the station name (worse than A1's
  title leak: it's a REAL-WORLD reference); "[The Testament.]" spliced
  inside her paragraph (format bug — his line inside her block); 3x
  loredump duplication; "<laugh>". GUN beat correctly attributed here
  (his bracketed question, her "Not at all.").

### t1_B1 (editor pass on A1; echoed at 0.25, real edit on 0.4 retry)
- Real edits: three flagged lines cut. One cut is WRONG: "[That is not
  acceptable. I cannot allow the innocent to come to harm.]" became
  "[That is not acceptable.]" — deleting his canon fixed line (5.2b
  quotes it verbatim as the earnest register exemplar). The editor
  optimized the stated ceiling over the canon it was also given.
- All A1 tells persist (GUN misattribution, title leak, duplication).

### t1_B2 (editor pass on A2)
- The best t1 candidate. Real edits, mostly correct instincts:
  "[Your loop is stuck.]" (from 14 words of diagnostic wrapper — sharper
  than A2 AND closer to the truth's own move); kept "[I cannot allow the
  innocent to come to harm.]" and cut the other clause (the right choice
  B1 got wrong); trimmed the weapon-system self-description without
  losing the chassis/fabricator facts.
- Remaining tells: everything content-level from A2 (Lighthaven leak,
  spliced Testament line, duplication); also cut her "What?" before
  "Whatever" in the loredump, slightly flattening her half-missing-his-
  word beat.

## Batch-level honest summary

The three round-1 tells, after round 2:
1. **Density**: fixed, slightly overcorrected (scene0 20-26% terse; t1
   on-density once the duplication artifact is collapsed).
2. **Commando devices**: interruption device and pause-timed literalism
   joke now present and correctly SHAPED in all four t1 candidates —
   but the joke content itself is consistently weaker than the
   director's, and scene0's Commando still drifts military-generic
   ("Report.") rather than formal-archaic.
3. **Register contrast**: substantially better in t1 (her wrappers vs his
   brackets read as two voices; the trust<0 branch of t1_A2 is genuinely
   competitive). Scene0 remains the weaker scene: her morgue humor is
   tamer than truth and his laconic reads clipped-generic more than
   scriptural.

Most likely blind-judge giveaways, in order: (a) t1's tripled loredump/
excised-marker, (b) the station-name leaks (Perihelion Station / Outpost
Lighthaven), (c) scene0's missing designation-elision and macerator-grade
opener joke, (d) t1_A1's GUN misattribution. None of these are subtle;
a judge who knows the truth files will not be fooled by t1_A1/A2 raw.
t1_B2 and scene0_A1 are the two most triangle-competitive candidates.

## Files

- candidates/ — the eight deliverables (clean script text, truth format).
- briefs/ — brief_scene0.md (v1, unchanged all round), brief_t1.md (v2,
  parity-rebuilt; v1 recoverable from git history).
- prompts/ — exact system/user prompts as written by the final run.
- attic_v1/ — first-run outputs kept for the record (including the
  degenerate dot-loop sample and the byte-identical B echoes).
- run_round2.py — the whole pipeline; `uv run python
  tools/dialogue/triangle_round2/run_round2.py [scene0|t1|scene0_b|t1_b]`.
- word_counts.json — machine-written counts for all eight candidates.
