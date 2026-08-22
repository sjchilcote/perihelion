# Standards manifest

This file lists the standards files that apply to `PERIHELION`. A standards file does not apply from a different location.

| Standards file | Version | Scope |
|---|---|---|
| `litc-clear-technical-prose.md` | 2026-08-04 | All agent text: Implementation sections, warm-start specfiles, comments, and prompts. The checks do not parse comments. |
| `ux-principles-interactable-software.md` | copied 2026-08-03 | The standard scope below. |

`ste-simplified-technical-english.md` is a pinned source for the writing system. It is not an applied compliance standard.

### Scope of the standard

The standard applies to all runtime surfaces and outputs of `PERIHELION`. This includes its window, input, audio, rendered feedback, menus, and scenes. Section 0 selects the applicable sections for library and data units connected to these surfaces.

The standard does not apply to internal tests, probes, editors, calibration tools, tools in `tools/playtest/`, or asset tools. These are not part of the released program. This list includes `intro-probe.md`, `testkit.md`, `tests.md`, `tools-levelgen.md`, `tools-playtest.md`, and `tools-sound-art.md`. In `levels.md`, it applies to level operation during play but not to the internal level tool.

The engine specfiles (`engine-core.md`, `engine-binding.md`) and the music toolchain specfile (`tools-music.md`) moved to the engine's home repository with their code (separation of 2026-08-22; see that repository's `litc/separation-plan.md`). This corpus references the engine as a dependency.
