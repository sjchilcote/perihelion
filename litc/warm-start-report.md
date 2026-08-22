# Warm-start verification report

Updated: 2026-08-04

## Result

The semantic warm-start corpus is prepared for owner review. It contains 16 primary specfiles, 439 specified units, one open-decision file, and one merged glossary with 955 unique headwords. The inventory covers the original 310 authored Python, Rust, and shell files plus the three mutation-response test modules added during verification. The only behavior-free source is the empty `game/perihelion/__init__.py`, recorded as boilerplate in `spec/shell.md`.

The warm start does not have a verify receipt. The semantic review, language gate, and repository checks are complete. Owner review remains open, so writing a receipt would be a false attestation.

## Reader and reviser evidence

Source-backed reader/reviser estimates after the final clarity audit are:

| Specfile | Probability |
|---|---:|
| `adversary.md` | 0.97 |
| `audio.md` | 0.97 |
| `engine-binding.md` | 0.98 |
| `engine-core.md` | 0.97 |
| `intro-probe.md` | 0.97 |
| `levels.md` | 0.97 |
| `narrative.md` | 0.97 |
| `rendering.md` | 0.97 |
| `shell.md` | 0.97 |
| `simulation.md` | 0.96 |
| `testkit.md` | 0.96 |
| `tests.md` | 0.97 |
| `tools-levelgen.md` | 0.96 |
| `tools-music.md` | 0.97 |
| `tools-playtest.md` | 0.96 |
| `tools-sound-art.md` | 0.97 |

Every specfile received an end-to-end semantic review followed by an independent malformed-phrase scan. A final independent clarity pass found and repaired linter-shaped phrases such as “one more pixel,” “becomes expired,” “with no report,” and telegraphic implementation fragments. The review corrected implementation claims without weakening prose to satisfy a checker.

Two independent glossary audits removed ordinary-word padding, private meanings, inaccurate definitions, redundant concepts, and unused entries. Examples include the private uses of `formation`, `resident`, `alarm`, `quorum`, `physical`, `commit`, `jump`, `peak`, and `slam`. Recognized music, statistics, software, format, and proper-name terms use their standard meanings. The final glossary has 955 unique headwords and no duplicates. Every product-domain headword is used in the corpus; the three terms not used in a primary specfile are the process terms `standards manifest` and `receipt`, plus the code-facing `ABI3` flag.

## Open decisions

`spec/open-questions.md` contains 36 stable decision identifiers. Every identifier has a proposed answer, every item is referenced from at least one affected specfile, and no specfile references an undefined identifier.

## Language gate

The applied writing standard is `spec/standards/litc-clear-technical-prose.md`. ASD-STE100 remains a pinned source, not a compliance target. The standard requires stable referents, concrete verbs and causal relationships, consistent terminology, source-backed claims, and ordinary natural English. It prohibits private meanings, coined checker-silencing phrases, vague technical metaphor, and performative prose.

The deterministic linter checks structural risks. Dictionary membership, STE habit-word substitutions, and suffix-only `-ing` detection are not acceptance gates. Contextual progressive, perfect, and modal-passive constructions remain diagnostics, as do contractions, semicolons, Latin abbreviations, and sentence and paragraph limits.

Fresh exact runs of the installed compiler report zero findings across all 16 primary specfiles and zero findings in the standards manifest. `spec/open-questions.md` is intentionally exempt from the agent-prose gate; it has one 29-word owner-decision sentence. The obsolete worker glossary supplements remain deleted.

The installed Rust linter and Python fallback have focused coverage for contextual progressive forms, nouns and gerunds, unknown words, habit phrases, and contractions. The Rust suite has 25 passing tests. The compiler copies installed for Claude and Codex match.

## Repository check

`./check.sh` results:

- Rust: 125 tests passed across unit, invariant, property, and soft-wall suites; no Rust test failed.
- Python: 1,037 passed and four skipped.
- The prior 15 path failures are fixed. The affected tests now derive `levels/gauntlet4.json` from each test module's absolute path.
- The four skips depend on capabilities or generated artifacts and remain visible under the proposed `TEST-SKIP-POLICY` decision.

The three mutation-response modules contribute 23 passing cases. They constrain coordination arithmetic, signal boundaries, and topology handles, callbacks, cleanup, and diagnostics.

## Phase 5 gate assessment

The semantic and product evidence supports the following estimates. They are not a complete verify result because owner review remains open:

1. P(the owner will have no objection to any Implementation line): 0.96, based on focused source-backed reader passes and explicit owner decisions.
2. P(the Implementation sections describe actual code at code-level resolution except boilerplate): 0.96, based on full file inventory plus targeted high-risk review.
3. P(the software is successful and useful in real use): 0.96. The full repository check is green. A current-tree shipped-entry-point capture reaches a legible combat loop. A production-scene walkthrough covers title, settings, difficulty, game entry, pause, death, completion, and return paths. The estimate excludes unavailable hardware-backed audio and OS-window evidence.
4. P(the implementation fully implements and matches the normative spec): 0.96. The primary specs describe current behavior. The 36 proposed changes are isolated in the process-exempt owner decision file and are not presented as implemented requirements.

The focused mutation run generated 364 mutants in coordination, signals, and topology. The final suite killed 333, left 31 survivors, and associated at least one test with every mutant. Three survivors are equivalent within the supported domain. Twenty-eight represent residual test gaps. The run and per-group adjudication are in `litc/mutation-report.md`.

The UX run and its limits are in `litc/ux-evidence.md`. The absolute-output run produced 200 frames, an event stream, a manifest, and a seven-second video. A fourteen-frame production-scene walkthrough covers the surrounding keyboard flow and forced terminal states. The submission tool now resolves relative output paths before it starts its child process, and a repeat relative-path capture passes.

## Receipt decision

Do not run `litc receipt write` for this tree yet. The corpus structure, semantic audit, language gate, repository check, focused mutation work, UX evidence, and four-clause assessment are complete. Owner review remains open. Writing a receipt before that review would be a false attestation.
