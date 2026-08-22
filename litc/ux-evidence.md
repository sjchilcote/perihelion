# UX evidence ledger

Date: 2026-08-03

## Scope

PERIHELION is a real-time game. The applicable evidence form in the UX standard is a timestamped recording of a cold session through the shipped entry point. The command below used the shipped module, the shipped `gauntlet4` level, the production update and draw paths, and the standard aggro bot. It did not seed a demo fixture or call the simulation directly.

```text
uv run python tools/playtest/submit.py \
  -o /home/login/PycharmProjects/noneuclideantopdownshooter/out/litc-ux-ledger \
  --seeds 2 --ticks 600
```

The first attempt used a relative output directory. Capture wrote its frames relative to `game`, while the video step looked for that directory relative to the repository root. The tool reported `no frames` and returned nonzero. The submission tool now resolves its output directory before it changes the child process directory. A repeat run with `-o out/litc-relative-proof` produced 20 frames and a one-second video, which discharges the path defect.

## Human-path observations

| Point | Evidence | Observed result |
|---|---|---|
| Entry | `out/litc-ux-ledger/run_s2/frame_000000.png` | The shipped entry point loaded the authored level. The player, weapon, ammunition, health, level geometry, enemies, pickups, and effects were visible. |
| Core loop | `out/litc-ux-ledger/run_s2/frame_000099.png` | The bot moved through the level and fired. The camera followed it, visibility changed with position, ammunition decreased, and enemies and projectiles remained legible. |
| Combat state | `out/litc-ux-ledger/run_s2/frame_000199.png` | The run reached a crowded combat state. Enemy silhouettes, projectiles, damage numbers, the player marker, health, and ammunition were visible. |
| Continuous record | `out/litc-ux-ledger/run_s2.mp4` | The encoder produced seven seconds of continuous source footage from 200 recorded frames. |
| Machine record | `out/litc-ux-ledger/run_s2/events.jsonl` | The recorder produced a frame-to-tick event stream for the same run. |
| Manifest | `out/litc-ux-ledger/manifest.json` | The manifest names build `1ca2168-dirty`, seed 2, 600 ticks, zoom 0.45, the level path, the video, the event stream, and the session trace. |

## Menu and terminal-state walkthrough

A synthetic-input walkthrough used the production `App`, framebuffer, scene stack, scene event handlers, level loader, and renderer. SDL used its dummy video and audio drivers, so the walkthrough did not depend on unavailable window or audio hardware. The already-recorded shipped-entry-point run supplies the continuous real-time evidence that this harness does not.

The walkthrough started with a clean temporary data directory. It selected Settings from the title screen, changed a setting, returned to the title, selected New Game, selected Hard, entered the authored `l01` level, opened Pause, opened Settings from Pause, and returned to Pause. Fourteen screenshots record the path in `out/litc-ux-ledger/menu-path`.

| Step | Evidence | Observed result |
|---|---|---|
| Cold title | `01-title.png` | The title, product subtitle, current selection, New Game, Level Select, Settings, and Quit are visible. |
| Settings | `02-settings.png`, `03-settings-changed.png` | Volume, mute, screen shake, difficulty, keys, and the back action are visible. The selected value changes after input. |
| Return | `04-title-return.png` | Escape returns to the same title choices without a dead end. |
| Difficulty | `05-difficulty.png`, `06-hard-selected.png` | The two difficulty choices and the back action are visible. The selection marker moves to Hard. |
| Game entry | `07-gameplay-entry.png` | Confirming difficulty loads the authored level and exposes movement, aim, fire, interaction, station, weapon, and pause controls. |
| Pause | `08-pause.png` | Pause visibly freezes the game under a dark overlay and offers Resume, Restart Level, Settings, and Quit to Title. |
| Pause settings | `09-pause-settings.png`, `10-pause-return.png` | Settings opens from Pause with Hard shown as the next-game difficulty. Escape returns to Pause. |
| Forced death | `11-death-fault.png`, `12-death-to-title.png` | Fault injection shows a distinct FRAME LOST state, restart and title actions, then confirms Escape reaches the title. |
| Forced completion | `13-win-terminal.png`, `14-win-to-title.png` | Fault injection exercises the production completion scene and confirms Escape reaches the title. The first completion frame intentionally begins with the scrolling text below the viewport. |

The synthetic harness also tried to launch an explicitly missing level. The command returned nonzero and exposed a Python traceback. This is acceptable for the developer-only `--level` override, but it is not polished diagnostic output.

## Gate assessment

- Rung 0, Builds: the repository check builds the native extension and passes all selected tests.
- Rung 1, Completes: the shipped entry point reaches the combat loop, and the production scene path reaches both game entry and terminal states.
- Rung 2, Honest: selection markers, settings values, HUD values, pause state, death state, and completion state agree with the underlying scene or session state in the observed path.
- Rung 3, Operable: every observed step exposes its available keyboard actions before input.
- Rung 4, Legible: every input has a visible selection, scene, value, or game-state response.
- Rung 5, Robust: the walkthrough covers return, pause, settings, forced death, forced completion, and a missing developer-supplied level.
- Rung 6, Calibrated: success, pause, death, completion, and launch failure have distinct visible or process results.
- Rung 7, Evidenced: the continuous combat recording and the production-scene screenshots together cover entry, configuration, game start, core play, pause, settings, death, completion, and return to title.

The human-path gate passes for the keyboard-operated game flow on the current tree. Hardware-backed audio and a real OS window were unavailable, so the evidence does not claim those platform capabilities.
