# Triangle round 2 — blind judging results (2026-07-11)

Judges: 4 fresh Sonnet subagents, 3 trials each, texts fully inlined, no tools,
no repo/pipeline/director contamination in prompts. Odd-one-out framing per
protocol; correct answer = the director's text (truth).

## Administration notes (deviations)

- Trial prompts were assembled with the truth position shuffled per trial;
  the candidate PAIRS in trials 2, 4, 6, 8, 9 deviated from the planned
  all-6-unordered-pairs schedule (assembly error). key.json records what was
  actually sent; pair coverage is uneven (A1/A2 over-represented, some pairs
  repeated) but every scored trial contains exactly one truth + two gens.
- Trial 5 as originally sent accidentally contained three generations and no
  truth (invalid; that judge's answer discarded). Trial 5 was rerun with a
  corrected prompt (B2 + A2 + truth) on a fresh judge; the rerun is scored.

## Per-trial results

| Trial | Scene  | Truth at | Gens shown | Judge pick | Correct? | Conf | Tell (abridged) |
|------:|--------|----------|------------|------------|----------|-----:|-----------------|
| 1  | scene0 | X | A2, A1 | X | YES | 88 | Truth's unique header ("Track [forget-the-number]"), `<TRUST +N>` angle tags vs gens' square tags + terser voice |
| 2  | scene0 | Y | A1, A2 | Y | YES | 88 | Same header/bracket tell + "florid, rambling AI opening" vs gens' terseness |
| 3  | scene0 | Z | A1, B2 | Z | YES | 85 | Same header/bracket tell; gens "show matching abridgement/trimming of shared lines" |
| 4  | scene0 | Z | B2, A2 | Z | YES | 88 | Truth "thick with asides, italics markup, verbose editorializing voice ('christofascist fucks')"; gens "near-identical" to each other |
| 5* | scene0 | Z | B2, A2 | Y | no  | 65 | Judge grouped truth+B2 as "draft and disciplined rewrite," read A2's small insertions as the second hand |
| 6  | scene0 | X | A1, B1 | X | YES | 85 | "Track" framing device, macerator joke, italics + profanity escalation absent from the "near-identical RATIO texts" |
| 7  | t1     | X | A2, A1 | X | YES | 88 | Truth's `<:loredump>`/`<goto>` macros + crude wit ("the fucked," "spare undies") vs gens spelling the loredump out three times verbatim |
| 8  | t1     | Y | A1, A2 | Y | YES | 88 | Same: goto macros, underscore emphasis, profane banter vs gens' repeated-full-text structure |
| 9  | t1     | Z | A1, B1 | Z | YES | 88 | Same macro/register tell ("batshit insanity"); gens share "copy-pasted full loredump" |
| 10 | t1     | Z | B2, B1 | Z | YES | 78 | Crude register + "quote…en-quote" tics; gens are "the same measured phrasing template differing only in proper-noun reskins" |
| 11 | t1     | Y | A1, A2 | Y | YES | 74 | The CUCULUS/undies/GUID/loredump fingerprint "absent from X and Z even though those two picked up a few borrowed lines" |
| 12 | t1     | Z | B1, A1 | Z | YES | 80 | Same fingerprint; gens are "the same tight template merely reskinned (Testament/Alari/pants vs Ark/First Ones/helmet)" |

\* Trial 5 is the corrected rerun; the original send was invalid (no truth).

## Accuracy

- Overall: **11/12 correct (91.7%)** vs chance 1/3 (4/12 expected).
  One-sided binomial: P(>=11 | p=1/3) ~= 4.7e-5. Far above chance — the
  pipeline round-2 candidates FAIL the indistinguishability goal decisively.
- Scene 0: **5/6** (only miss: trial 5, and it was the lowest-confidence pick).
- Terminal 1: **6/6**.
- Mean confidence on correct picks: ~84.5; the single wrong pick was 65.

## Tell categories (primary drivers, iteration signal)

| Category | Trials citing it | Notes |
|----------|------------------|-------|
| **format / markup fingerprints** | 1, 2, 3, 6, 7, 8, 9, 10, 11, 12 (10) | Dominant. Session header ("CARRIER DETECT… Track [forget-the-number]" vs gens' "Quanta-118093"), `<TRUST +N>` angle vs `[TRUST +N]` square brackets, `<:loredump>`/`<goto>` label macros vs gens inlining the loredump 3x verbatim, underscore/asterisk emphasis. |
| **voice-register** | 4, 6, 7, 8, 9, 10, 11, 12 (8) | Director's crude, quippy, editorializing register ("christofascist fucks," "It is I, the fucked," "spare undies," "batshit insanity," "quote…en-quote") vs gens' measured, sanitized tone. |
| **density / compression** | 2, 3, 4, 5 (4) | Director florid and verbose; gens terse and trimmed. The one judge miss (trial 5) came from reading this as draft-vs-rewrite and grouping truth with a gen. |
| **gen-vs-gen mode collapse** | 3, 4, 5, 6, 10, 12 (6) | Not a truth-tell per se but the mechanism that makes the test trivial: judges repeatedly noted the two generations are "near-identical" / "the same template merely reskinned," so the truth pops as odd by elimination. |
| **structure** | 7, 8, 9 (3) | Repetition-vs-macro is both format and structure: gens duplicate the whole loredump block per branch instead of using the script's goto idiom. |
| **canon-leak** | 0 | No judge cited invented proper nouns (Ark / First Ones / Alari / Perihelion Station / Outpost Lighthaven) as the deciding tell, though they noticed them as reskin evidence. |

## What to fix next round

1. **Format parity first (cheapest, biggest)**: gens must reproduce the truth's
   surface conventions exactly — full session header incl. CARRIER DETECT lines,
   angle-bracket TRUST tags, `<:label>`/`<goto :label>` macros instead of
   duplicating blocks, underscore/asterisk emphasis. Most trials were decided
   before a judge read a single line of dialogue.
2. **Register**: the gens sand off the profane, over-specific wit. The voice
   spec needs the crude-comedy register stated positively with examples
   (undies line, "It is I, the fucked") rather than left to the model.
3. **Decorrelate generations**: two gens per trial that are near-clones of each
   other hand the judge the answer by elimination. Vary seeds/temps/prompt
   framings enough that gen-vs-gen distance is comparable to gen-vs-truth
   distance, or the triangle can never pass regardless of quality.
4. **Density**: stop compressing. The director rambles on purpose; "disciplined
   rewrite" is a tell, not an improvement.
