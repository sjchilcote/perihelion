---
specfile: shell
covers: game/perihelion/app.py, __main__.py, menus.py, hud.py, uievent.py, text.py, telemetry.py
---

# Program interface — window, loop, scenes, HUD, text, input, telemetry

This specfile gives the requirements for the program layer between the OS
and simulation. It
includes the CLI entry, window, frame loop, scene stack, menus, HUD, text
operations, UI events, video record, and telemetry. The file
`game/perihelion/__init__.py` is empty.

This program code does not use `pygame`. The window and the PNG writer come from the `necore` engine. All paint operations write into numpy arrays.

## Unit: CLI entry — `game/perihelion/__main__.py`

### Goal

`PERIHELION` starts from the command line: `uv run python -m perihelion [options]`. The entry point reads the flags, applies the flag defaults, and starts the `App`.

### Invariants

- `--record` without `--bot` and without `--play` selects the `aggro` bot.
- A selected bot always sets `autoplay`.

### Verification

- A run with `--record DIR` and no other flags plays with the `aggro` bot and writes frames to `DIR`.
- A run with `--record DIR --play` keeps person control.
- The help output shows only the listed flags.

### Implementation

`main(argv=None)` assembles the `argparse` flag set with program name
`perihelion`. The parser rejects an incorrect value type or a value that is
not in its stated selection. The flags shown in help are:

- Flag `--level PATH` — one level JSON file. The campaign manifest is not read.
- Flag `--seed N` — the sim random seed.
- Flag `--scale N` — the integer multiplier from the internal framebuffer dimension to the OS window dimension.
- Flag `--mute` — all audio off.

- Flag `--hard` — hard difficulty.
- Flag `--fps` — the fps meter overlay.
- Flag `--play` — person control, also when `--record` is on.
- Flag `--zoom X` — the camera zoom. The default is `0.45`.

- Flag `--music-bank PATH` — a music bank directory.
- Flag `--loadout full` — start with all weapons, deep ammo, and hp 100.
- Flag `--no-music` — the music system off.

The path flags have string values. `--seed`, `--scale`, `--record-every`, and `--start-chunk` have integer values. `--zoom`, `--bot-skill`, and `--record-seconds` have floating-point values. Flags that start an operation have a default of `False`. Defaults stated below replace the `None` default. `--loadout` accepts only `full`.

These flags do not show in the help output: `--autoplay`, `--bot {aggro, explorer, pacifist, human}`, `--bot-skill X`, `--tactician`, `--record DIR`, `--record-every N` (default 2), `--record-seconds X` (default 180), `--start-chunk N` (default 0).

After the parser returns, two defaults apply. If `record` is set without
`bot` or `play`, set `bot` to `"aggro"`. If `bot` is set, set `autoplay` to
`True`. The function then assembles `App(args)` and calls `app.run()`.

### Caveats

- The default seed is 0 and not a time value. Thus two runs without
  `--seed` have the same world.

## Unit: UI event module — `game/perihelion/uievent.py`

### Goal

Scenes use only this module's `Event` objects and constants. They do not
import `pygame`. The constants keep the `pygame-ce 2.5.7` values. Thus the
event comparisons have the same effect as before.

### Invariants

- The module holds event type constants (`QUIT`, `KEYDOWN`, `KEYUP`, `MOUSEMOTION`, `MOUSEBUTTONDOWN`, `MOUSEBUTTONUP`, `MOUSEWHEEL`, `VIDEORESIZE`) and key constants (`K_*`) with `pygame` values.
- A key without a map entry becomes key `-1`. No `K_*` constant is `-1`. Thus a key that does not map to an operation falls through each key test.
- `Key-repeat` events do not become `KEYDOWN` events.

### Verification

- When the user holds `ESC` in play, one pause menu opens, not one for each
  `key-repeat` event.
- When the user holds `B` in play, `PERIHELION` installs one seed kit, not many.

### Implementation

`Event` is a `dataclass` with the fields `type`, `key`, `unicode`, `pos`, `button`, `ch`, `mod`, `x`, `y`, `w`, and `h`. The field names copy the `pygame` event attribute names. `type` has no default. The defaults for `key`, `pos`, `button`, and `ch` are `None`. The default for `unicode` is an empty string. The defaults for `mod`, `x`, `y`, `w`, and `h` are 0.

`from_pygame(ev)` returns `ev` with no change when it is an `Event`. For a
different input, it copies each field through `getattr` with the defaults
above. It changes `type`, `mod`, `x`, `y`, `w`, and `h` to integers. An empty
`unicode` value becomes an empty string. A zero value for `mod`, `x`, `y`,
`w`, or `h` becomes 0. The function does not import `pygame`.

`WINIT_KEYS` maps `winit` key names to the key constants. A loop adds the entries `KeyA` to `KeyZ` and `Digit0` to `Digit9`. Other names are `Escape`, `Space`, `Enter`, `NumpadEnter`, `Backspace`, `Tab`, and `Delete`. The map also has `ArrowLeft`, `ArrowRight`, `ArrowUp`, `ArrowDown`, `ShiftLeft`, `ShiftRight`, `BracketLeft`, and `BracketRight`. The last names are `F3`, `F5`, `F11`, and `F12`. `NumpadEnter` maps to `K_RETURN`, not `K_KP_ENTER`.

`from_platform(ev)` maps a `necore.Window.pump()` tuple `(kind, a, b, c, name, text)` to an `Event`:

- Type 0 — `QUIT`.
- Type 1 — `KEYDOWN`, with the key from `WINIT_KEYS` or `-1` when missing.
  When `a` is nonzero, the event is a `key-repeat` event and the function
  returns `None`.
- Type 2 — `KEYUP`, key as above.
- Type 3 — `MOUSEMOTION` with `pos=(a, b)`.

- Types 4 and 5 — `MOUSEBUTTONDOWN` and `MOUSEBUTTONUP`, `button=a`, `pos=(b, c)`.
- Type 6 — `MOUSEWHEEL` with `x=a`, `y=b`.
- Type 7 — `VIDEORESIZE` with `w=a`, `h=b`.
- An unknown type value returns `None`.

### Caveats

- The `key-repeat` drop corrects a live defect. These events stacked one
  pause menu for each event and installed seed kits while the user held `B`
  (gate run 50).
- Mouse positions come in internal pixels. The engine `present()` path does the scale and border work.
- The `modifier` constants `KMOD_SHIFT`, `KMOD_CTRL`, and `KMOD_META` are
  for other code. No unit in this specfile reads them.

## Unit: bitmap text — `game/perihelion/text.py`

### Goal

The renderer, HUD, and menus use one text path. PIL changes the `PERIHELION` font
`FSEX300` into bitmaps. The module mixes them onto a `(W, H, 3)` NumPy
framebuffer. The buffer uses the `pygame` `surfarray` axis sequence, where
`fb[x, y]` identifies a pixel.

### Invariants

- All strings at one font dimension have the same line box, equal to font
  `ascent` plus `descent`. Thus `"10"` and `"9"` align.
- The cache holds each text bitmap. It has no limit and removes no entry.

### Verification

- The HUD numbers and the menu text show in `FSEX300` at each internal dimension.
- Two number labels on one line have equal height and align.

### Implementation

`_font(size)` reads `assets/fonts/FSEX300.ttf` at `size` and keeps the result in a cache.

`render_alpha(text, size)` returns a `uint8` alpha bitmap with shape `(h, w)`.
Height is `ascent + descent` with a minimum of 1. Width is the right
coordinate `bbox[2]` from `font.getbbox(text)`, also with a minimum of 1.
The code ignores the box's left and top coordinates. It renders at `(0, 0)`
into a PIL `"L"` image with fill 255. It changes the image to NumPy and
caches it below `(text, size)`.

`measure(text, size)` returns `(width, height)` of the `render_alpha` bitmap.

`blit_text(fb, text, x, y, color, size)` mixes the bitmap onto `fb` with its
top left corner at `(x, y)`. It clips the bitmap to the framebuffer. The
bitmap axis sequence is `(row, column)` and the framebuffer axis sequence is
`(x, y)`, thus the code applies `.T`. The mix is
`(color * alpha + frame * (255 - alpha) + 127) // 255` in `uint16`. The
result then changes back to `uint8`.

### Caveats

- Defect: the cache has no limit. With `--fps` on, the meter line changes
  almost each second. The process cache holds one bitmap for each different
  string. Thus memory use increases for the full run.

- A dimension of 0 or less and a font read failure go to PIL and raise its error. The text unit does not catch these errors.

- The bitmap origin follows PIL paint at `(0, 0)`.

  The code ignores a left or top coordinate from `getbbox` that is not 0. Thus the specified origin at the top left does not correct font box offsets.
- The mix adds 127 before the divide. Thus the result is the nearest value.

## Unit: HUD — `game/perihelion/hud.py`

### Goal

A small HUD uses the `PERIHELION` font and paints onto the frame without `pygame`.
It has 3 readouts plus the crosshair. The hp number and bar are at bottom
left, with weapon and ammunition above them. Components are at top left.
The renderer injury vignette shows damage, while the HUD supplies accurate
values.

### Invariants

- Each readout is on an RGB (12, 12, 16) panel. Thus the user can read the
  text on each floor.
- The hp color becomes RGB (214, 96, 84) at low health, when
  `hp / max_hp <= 0.34`.

- Clamp displayed hp to 0 or more and maximum hp to a minimum of 1. The
  filled bar stays a minimum of one internal pixel wide, also at 0 hp.
- The weapon line is above the hp line and does not touch it.

### Verification

- In play, the bottom left corner shows the hp number and bar. The weapon name and ammo count are above them.
- The top left corner shows the component count as `<n>c`.
- With a low hp value, the number and the bar show RGB (214, 96, 84), not
  RGB (150, 210, 160).
- The crosshair is at the mouse position. It starts open after an attack and closes to the center until the weapon can fire again.

### Implementation

`_fill(fb, x, y, w, h, color, alpha=255)` fills a clipped rectangle. At alpha 255 it writes the color. Below 255 it mixes, with the same rounded mix as the text unit.

`HUD.draw(fb, session, mouse_pos)` paints, in sequence: components, hp, weapon, and, when `mouse_pos` is not `None`, the crosshair.

`_plate` paints a panel around the text rectangle. Its margins are `ui(3)` horizontally and `ui(2)` vertically. The color is `(12, 12, 16)`, with alpha 190.

`_draw_salvage` shows `<components>c` at `(ui(6), ui(6))`, dimension
`ui(16)`, and RGB (225, 214, 180).

`_draw_health` shows the hp number at the bottom left, dimension `ui(16)`. It limits the hp fraction to a maximum of 1. The color is `(214, 96, 84)` when the hp fraction is `0.34` or less. Otherwise, it is `(150, 210, 160)`.

Right of the number is a bar, `ui(44)` wide and `ui(3)` high, at the middle of the text height. The bar back color is `(40, 44, 50)`. The filled part is `bar_width * fraction`, minimum `ui(1)`.

`_draw_weapon` shows the weapon name in `uppercase`, with the ammo count in
RGB (150, 196, 220) after it. The ammo count comes from the ammo type of the
weapon. A melee weapon shows no count. The type `components` shows the
component count. All other types show the count in `session.ammo`. The line
is `ui(3)` above the hp line.

`_draw_crosshair` paints 4 thin rectangles around the mouse position (left, right, up, down). The arm length is `(3 + expand) * s` with a distance of `2 * s` from the center, where `s` is the internal dimension scale. For the `lightning` weapon, `expand` is `(1 - charge_fraction) * 4`. For all other weapons, `expand` is `(cooldown / max_cooldown) * 4`.

### Caveats

- When the weapon uses `components`, the ammo readout duplicates the number at top left. The two positions show the same value.

- An unknown weapon name selects an empty weapon record. Its ammo type is `None`. Thus the ammo text is empty. The unknown name continues to show in `uppercase`. The crosshair uses a maximum cooldown of 1.

## Unit: scene base and scene stack — `menus.Scene`, `App.push/pop/pop_to_title/replace/quit`

### Goal

`Scene` is the interface operated by `App`. Only the top scene receives
input, updates, and draw calls. If `App` pushes a different scene above
`GameScene`, the simulation pauses.

### Invariants

- `App` calls `handle_event`, `update`, and `draw_fb` only on the top scene. An overlay can call `GameScene.draw_fb` to paint the play scene below the overlay.
- `push` calls `on_enter` on the new scene. `pop` calls `on_exit` on the removed scene.
- An overlay scene paints the live play scene below its text through `_draw_game_under`.

### Verification

- When the pause menu is open, the simulation does not move and the enemies do not attack.
- When the pause menu closes, play continues from the same state.

### Implementation

`Scene` supplies empty `on_enter`, `on_exit`, `handle_event`, `update`, and `draw_fb` methods. `Scene._draw_game_under(app, fb)` calls `app.game.draw_fb` when `app.game` is not `None`. Overlay scenes set the class attribute `_draws_game_under`.

The stack operations on `App`:

- Method `push(scene)` — adds the scene on top and calls `scene.on_enter(app)`.
- Method `pop()` — removes the top scene and calls its `on_exit(app)`.
- Method `pop()` has no effect when the stack is empty.
- Method `pop_to_title()` — calls `pop()` until the stack is empty, sets `app.game` to `None`, and pushes a new `TitleScene`. Thus it calls `on_exit` on each removed scene.

- Method `replace(scene)` — calls `pop()` until the stack is empty, then pushes `scene`. Thus it calls `on_exit` on each removed scene.
- Method `quit()` — sets `running` to `False`. The frame loop then ends.

### Caveats

- Defect: the module docstring of `menus.py` tells of a `draw(app, surface)` transition method on `Scene`. That method is not in the code. No code reads the `_draws_game_under` attribute, `_FONT_CACHE`, or `_FONT_PATH`. This text and code stay after the `pygame` removal but have no effect.

- `_start_streamed` (campaign unit) writes the scene list directly. It does
  not call `on_exit` on removed scenes. No scene has an `on_exit` body, thus
  this has no effect.

## Unit: menu paint helpers — `menus.font_px/_snap/_load_bg/_blit_bg/_wrap/_blit_centered`

### Goal

Menu-scene helpers supply font dimensions locked to the bitmap grid, scene
images, character-count line division, and centered text. When no image is
on disk, each scene paints a calculated image.

### Invariants

- Font dimensions lock to 16, 32, or 48 pixels, then scale with the internal dimension. `FSEX300` has a bitmap grid, and these dimensions keep glyphs on the pixel grid.
- `PERIHELION` runs with an empty `assets/art/` directory. Each scene with an
  image can paint a calculated image as its alternative.

### Verification

- With the image files removed, the `title` screen, the death screen, and the campaign end screen show their calculated images.
- Menu text is sharp at the default internal dimension.

### Implementation

`_snap(size)` returns 16 when `size <= 24`, 32 when `24 < size <= 40`, and 48 when `size > 40`. `font_px(size)` returns `ui(_snap(size))`.

`_load_bg(name)` reads `assets/art/<name>` as a `(w, h, 3)` `uint8` array in framebuffer axis sequence, through PIL. When the internal width is more than 640, it selects the `<stem>@4x.<ext>` file when that file is on disk. A read failure returns `None`. The result, also `None`, goes into a cache with `name` as key.

`_blit_bg(fb, bg, name)` copies the image into the framebuffer. When the dimensions are different, it scales the image with PIL `BILINEAR`. A cache keeps the scaled copy with key `(name, w, h)`.

`_wrap(text, width)` divides the text into lines with `width` characters or less. It keeps an empty output line for each input line that contains only spaces. It divides at space characters only. Its `strip()` operations remove spaces from the start and end of output lines. Spaces that occur one after the other do not stay in the output.

One text item that is longer than `width` stays on one line. Thus such a
line can have more than `width` characters.

`_blit_centered(fb, s, cx, y, color, size)` renders `s` centered at `cx` and returns its width.

### Caveats

- An image read failure caches `None` for the process life. A file added while `PERIHELION` runs does not show.
- A code comment in `menus.py` names a `480x270` internal dimension. The default internal dimension is `640x360`.

## Unit: `title` screen — `menus.TitleScene`

### Goal

The first screen has the `PERIHELION` name, an image, and the primary menu. The
`station` sound starts here (`the station is never silent`).

### Invariants

- The menu items are `New Game`, `Level Select`, `Settings`, `Quit`. With `ng_plus` in the `save`, `New Game+` is the second item.
- `on_enter` starts the sound `amb_drone_early`.

### Verification

- At start without a `save`, the 4 items show, and `New Game+` does not.
- After a campaign end, the `title` screen shows `New Game+`.
- `W`/`S` and the arrow keys move the selection with wrap-around. `RETURN` or `SPACE` starts the item.

### Implementation

The scene holds time `t`, the selection index, and the item list. It also holds 40 points that move with random positions and rates. `on_enter` sets `t` to 0.
While this scene is on top, `update` adds frame `dt` to `t`. If a different
scene is above it, the `title` animation pauses.

`handle_event`: `DOWN`/`S` and `UP`/`W` move the selection with wrap-around. `RETURN` or `SPACE` starts the selected item. `New Game` pushes `DifficultyScene()`, while `New Game+` pushes `DifficultyScene(plus=True)`. `Level Select` pushes `LevelSelectScene()`, and `Settings` pushes `SettingsScene()`. `Quit` calls `app.quit()`.

`draw_fb`: with `title_bg.png` on disk, the image shows with an RGB (0, 0, 0)
alpha-110 layer on the top `ui(235)` rows. With no image, an RGB field shows.
It is RGB (0, 0, 0) at the bottom, and the top brightness follows
`sin(t * 0.6)`. Each point has a rate from 6 to 18 internal pixels each
second. Its shown vertical position is
`(initial_y + t * rate) % framebuffer_height`. The renderer draws it as a
`ui(1)` square with RGB (95, 75, 62).

The name `PERIHELION` shows at dimension `font_px(40)`, with the line
`a descent into non-Euclidean dark` below it. The item text starts at
`w/2 - ui(60)`. The selected item uses RGB (255, 255, 255) with a `> `
prefix. The other items use RGB (150, 150, 150).

### Caveats

- The menu reads the keyboard only. The mouse does not move or start the selection. This applies to each menu in this file.
- `on_enter` adds `New Game+` at most once. Each return to the `title` screen
  starts a new `TitleScene`. Thus no caller uses the tested second entry
  path.

## Unit: difficulty menu — `menus.DifficultyScene`

### Goal

One selection between `New Game` and the threat level sets how dangerous the
run will be.

### Invariants

- Two items: `NORMAL - the station is hostile` and `HARD - the station is hungry`.
- The selection writes `app.settings["difficulty"]` and starts the new session.

### Verification

- `RETURN` on the `HARD` item starts a session with hard difficulty.
- `ESC` goes back to the `title` screen without a session start.

### Implementation

`W`, `S`, and the up and down arrows change the selection between the two
items. `RETURN` or `SPACE` writes the difficulty, removes the scene, and
calls `app.start_new_game(plus=self.plus)`. `ESC` removes the scene.
`draw_fb` shows `HOW FAR IN ARE YOU?`, the two items with the selection
marker, and an `ESC: back` line.

### Caveats

- The `plus` flag comes from the `title` screen item and selects the `New Game+` path in `start_new_game`.

## Unit: level select menu — `menus.LevelSelectScene`

### Goal

Entry into one unlocked campaign level, with the player state from the
`save` for that level.

### Invariants

- A locked level does not start. Locked items show RGB (90, 90, 90) with a
  `[locked]` suffix.
- The unlocked count comes from the `save` (`unlocked`, default 1).

### Verification

- With a new `save`, only level 1 starts. The other levels show `[locked]`.
- The start of an unlocked level uses the player state in the `save` for
  that level.

### Implementation

`on_enter` reads the campaign paths and unlocked count, then sets selection
to 0. The up and down keys wrap around `max(1, path_count)`. `RETURN` or
`SPACE` calls `app.start_level_index(sel)` when the list has an item and
`sel < unlocked`. `ESC` removes the scene. `draw_fb` displays numbered file
stems, or `(no campaign manifest -- debug level only)` when there is no
campaign manifest.

### Caveats

- The selection moves through locked items too. The start keys have no effect on them, and no message shows.
- With no campaign paths, the selection stays at 0. No row or selection marker shows, and the movement keys continue to calculate 0.

## Unit: configuration menu — `menus.SettingsScene`

### Goal

Runtime configuration includes master volume, mute, screen shake, and
difficulty. Exit writes the values to the `save`.

### Invariants

- `ESC` writes the `save` file before the scene closes. The configuration stays when the program starts again.
- A difficulty change applies at the next new session, not to the active session. The label tells this.
- Volume, mute, and shake changes apply at once. Only `ESC` writes them to the `save` file.

### Verification

- After a volume change, the volume keeps its value when the program starts again.
- The `d` key changes the shown difficulty between `normal` and `hard`.

### Implementation

`handle_event`: `ESC` calls `app._persist_save()` and removes the scene.
`LEFT` and `RIGHT` change the master volume in steps of 0.1. The audio
component limits the value from 0 to 1. `t` changes the shake value between
on and off. `m` changes mute between on and off. `d` changes the difficulty
between `normal` and `hard`.

`draw_fb` shows 4 adjustment lines. Line 5 is `ESC: back`.

### Caveats

- This menu has no selection marker. Each value has its key.
- `ESC` writes the values when the user exits this menu. Program end also
  writes the active values through the frame-loop end path when this menu
  continues to be open.

## Unit: pause menu — `menus.PauseScene`

### Goal

The menu above the stopped play scene: continue, start the level again, open configuration, or exit to the `title` screen.

### Invariants

- The play scene shows below the menu, below an RGB (0, 0, 0) alpha-165 layer.
- The simulation does not tick while this scene is on top (scene stack contract).

### Verification

- `ESC` in play opens the menu. The simulation behind it does not move.
- `Resume` and a second `ESC` continue play.

### Implementation

The items are `Resume`, `Restart Level`, `Settings`, and `Quit to Title`.
`ESC` removes the scene. The up and down keys move the selection with
wrap-around.

`RETURN` or `SPACE` starts the item. `Resume` removes the scene.
`Restart Level` removes the scene and calls `app.restart_level()`.
`Settings` pushes `SettingsScene()`, and `Quit to Title` calls
`app.pop_to_title()`. `draw_fb` paints the play scene below, the RGB (0, 0, 0)
layer, the text `PAUSED`, and the items.

### Caveats

- The `Settings` item opens above the pause menu. Thus the play scene stays two scenes deep and stays stopped.

## Unit: death screen — `menus.DeathScene`

### Goal

The death screen shows `FRAME LOST`, the body count, the `reprint` prompt, and one line of the log of the Commando. The code comment states the goal of the log: `one line of the Commando's log per death, in his own register`.

### Invariants

- The `reprint` keys are `R`, `SPACE`, and `RETURN`. `ESC` exits to the `title` screen.
- The prompt text follows the `chassis` count. With one or more `chassis`, it shows `reprint at the seed`. Without one, it shows `cold restore`.

- The log line index follows the death count. After the list end, the last line shows again.

### Verification

- At the first death, the screen shows `FRAME LOST`, `frames lost: 1`, and the first log line.
- `SPACE` continues play at a seed `station` when one or more `chassis` are available. Without one, it loads the level again or calls `streamer.respawn()`. `ESC` returns to the `title` screen.

### Implementation

The scene receives the death count and the `chassis` count. Its time starts at 0. `update` adds the frame `dt` while this scene is on top. Thus the brightness change stops while a different scene is above the death screen. `handle_event`: `R`, `SPACE`, or `RETURN` removes the scene and calls `app.reprint()`. `ESC` calls `app.pop_to_title()`.

In `draw_fb`, `death_bg.png` shows when it is on disk. Otherwise, the live play scene
stays below. An RGB (40, 0, 0) layer at alpha 190 fills the result. The
brightness of `FRAME LOST` follows `sin(t * 2)`.

Below it: `frames lost: <n>`, then the prompt line for the `chassis` state. The log line is `COMMANDO_LOGS[min(deaths - 1, 5)]`, with index 0 for a death count below 1. The log wraps by pixel width into centered lines in `w - ui(80)`.

`COMMANDO_LOGS` holds 6 constant lines of the log voice of the Commando.

### Caveats

- The prompt names `SPACE` and `ESC` only. `R` and `RETURN` also operate but do not show.
- With `death_bg.png` on disk, the RGB (40, 0, 0) layer applies to the image,
  not to the simulation state at death.

## Unit: campaign end screen — `menus.WinScene`

### Goal

The campaign end shows the `epilogue` above its image. The text moves up from the screen bottom, as in video credits.

### Invariants

- While this scene is on top, its `update` method moves the text at a constant rate. The rate is near 10 internal pixels each second at the default framebuffer dimension.
- `ESC` exits to the `title` screen at all times.

### Verification

- After the last level, the `epilogue` moves up. After the full text, `ESC: title` shows at the bottom.
- `ESC` during the text movement returns to the `title` screen.

### Implementation

The scene receives the full text. `update` adds `dt * 10` to the vertical text position. `handle_event`: `ESC` calls `app.pop_to_title()`.

`draw_fb`: with `win_bg.png` on disk, the image shows below an RGB (0, 0, 0)
alpha-100 layer. With no image, an RGB (0, 0, 0) fill shows. The text wraps
at 56 characters. Each line paints centered when its `y` is in the screen.
When the vertical text distance is more than `line_count * ui(16) + h`, the
`ESC: title` line shows.

### Caveats

- The `ESC: title` line shows only after the full text moves through the top. The key operates from the start.
- The vertical text movement does not stop at the text end. The screen becomes empty and stays empty until the user pushes `ESC`.

## Unit: terminal overlay — `menus.TerminalOverlay`

### Goal

The terminal overlay shows world-terminal text above the paused live scene.
It uses `PHOSPHOR_GREEN` and `DIM_GREEN`. The user can move long text in the
vertical direction.

### Invariants

- The play scene shows below the overlay and does not tick while the overlay is open.
- `E`, `ESC`, and `RETURN` close the overlay. `DOWN` and `UP` move the text.

### Verification

- `E` at a world terminal in play opens the text. A second `E` closes it and play continues.
- `DOWN` moves long text up one line for each push.

### Implementation

`handle_event`: `E`, `ESC`, or `RETURN` removes the scene. `DOWN` adds 1 to the first line index. `UP` subtracts 1, minimum 0.

`draw_fb` paints the play scene below, then an RGB (0, 10, 4) layer at alpha 225,
then a `DIM_GREEN` border rectangle. The text wraps at 62 characters and
paints from the first line index down. Lines stop above `h - ui(30)`. An
`E/ESC: close` line is at the bottom right.

### Caveats

- Defect: the first line index has no maximum. More `DOWN` pushes than lines move through the text end, and the box shows no text. `UP` pushes return the text.

## Unit: game scene — `app.GameScene`

### Goal

This scene operates the simulation. It collects the input frame, processes play keys, and renders the world and HUD. It also renders timed float labels, the level name, objective line, `wreck`-log voice, and starter controls.

### Invariants

- The zoom is `ZOOM_BASE[0] * INTERNAL_RES_ZOOM_SCALE`. `ZOOM_BASE` is
  `0.45` (source instruction, `2026-07-28`:
  `that is the zoom level I want`). `PERIHELION_INTERNAL_RES` changes the
  pixel count, not the world section on screen. Play and video have the same
  zoom. `--zoom` replaces it.

- When a scene is above the play scene, the timed texts do not paint and do not decay. They continue after the scene closes.
- The music `tier` follows the level `tier`.

### Verification

- With `PERIHELION_INTERNAL_RES=1280x720`, the world section on screen is equal to the default, with more pixels.
- A pickup label above a second pickup label stacks up, with no text on text.
- In a pause, the objective line timer does not decrease.

### Implementation

The scene constructor starts a `GameSession` with level, seed,
transferred player state, difficulty, screen dimensions, and zoom. It sets
`session.music_tier` from the level `tier`, with default 1. It then starts
the `Renderer` and `HUD`.

The timed text state starts empty: `objective`, `loc_title`, `logvoice` (each `(text, ticks)` or `None`), `float_texts` (`[x, y, label, ticks]` lists), `shakes`, `show_hints`, `streamer`.

`on_enter` sets the level sound to `None`. The continuous level drones are
removed (source instruction, `2026-07-16`). The music holds the music bed,
and a second drone below it is `mud`.

`_input_frame(app)` assembles the simulation `InputFrame` from active input
state. `W`/`A`/`S`/`D` set `mx` and `my`, and the mouse position sets the
target point. Button 1 fires, button 3 uses `alt` fire, and `E` sets
`interact`. The method reads the weapon request once and then sets it to 0.

`handle_event` processes `KEYDOWN`: `ESC` pushes the pause menu. `F3` changes
`app.debug` between `True` and `False`, and `F12` writes a screenshot. `B`
installs a seed `station`, and `T` uses a `recall`. The keys `1` to `9` set
the weapon request 1 to 9, and the key `0` sets 10. `MOUSEWHEEL` cycles the
weapon. `MOUSEWHEEL` up cycles to the previous weapon, and down cycles
to the next.

`_cycle_weapon` walks `WEAPON_ORDER` from the selected weapon, with wrap-around, to the next weapon that the player holds. It then sets the weapon request.

`_ui_text` paints one UI line onto the frame. It multiplies the color and
the panel color by `alpha / 255`. This operation changes the colors to
RGB (0, 0, 0) because the surface alpha ended with `pygame`. With
`panel=True`, an RGB (10, 10, 14) panel is behind the text.

In `draw_fb`, the renderer returns the world frame. The HUD draws onto it,
and the result copies into the `App` framebuffer. If the play scene is not the top
scene, the method returns at this point. The timed text does not change. If
the play scene is the top scene, the method renders each timed text and decreases
its count.

- Float labels start `14 * scale` above their spawn point and move up `0.35 * scale` pixels each frame. They fade during their last 24 ticks of 66. Labels with `INTEGRITY` show `(150, 225, 150)`. Labels with a `+` prefix show `(210, 185, 125)`, and all others show `(220, 210, 170)`.
- The level name shows centered at the top at dimension 26 and fades in its last 60 ticks.
- The objective line shows on a panel at `ui(62)` in `(235, 205, 130)` and fades in its last 50 ticks of 240.

- The `wreck` log voice shows on a panel at `H - ui(58)` and fades in its last 60 ticks. This height keeps it above the ammo readout. A reader previously found `PISTOL` without its number for 5 seconds while a log line played.
- With `show_hints` on, two lines at dimension 10 show on RGB (10, 10, 14)
  panels. The first is `WASD move    mouse aim    LMB fire`. The second is
  `E terminals + seed stations    B plant seed kit    1-8 weapons    ESC pause`.

  The lines are centered at `H - ui(66)` and 14 internal pixels below it. They show until sim tick 840, fade from tick 660, and do not show after death.

### Caveats

- The level name starts with 240 render ticks and fades during its last 60.
  The float-label collision loop moves a new label up by `11 * scale`. It
  moves the label again until it clears all active labels by the specified distances.
- The float label collision test uses `<` checks on `x` and `y`. An overlap
  occurs when the horizontal distance is less than `46 * scale` and the
  vertical distance is less than `11 * scale`.

  After each move up, the loop tests all active labels again. The test uses
  the painted vertical position of each active label for that frame.

- The timed text counts decrease once for each paint of the play scene, not once
  for each sim tick. At 60 fps the two agree. Some headless runs do not use
  the video mode with one tick for each frame. In those runs, paints can
  occur much faster than ticks. These texts then end too fast. That video
  mode keeps one paint for each tick.


- The starter control text names `1-8 weapons`. Keys `1` to `0` request weapons 1 to 10, and `WEAPON_ORDER` holds 8 weapons. Thus requests 9 and 10 have no effect in the sim.

The input conversion and crosshair have these caveats:

- `handle_event` does not call `uievent.from_pygame` on its events. The menu
  scenes do. The two receive `Event` objects with equal values from the same
  loop.
- A `MOUSEWHEEL` event with `y == 0` cycles to the next weapon, because the
  test is `y > 0` for the previous direction.

The crosshair has these numeric caveats:

- The crosshair calculations do not fully limit their input fractions. Electric arc charge has a maximum limit of 1 in this calculation but no minimum limit. Other weapons use `cooldown / max_cooldown` with no minimum or maximum limit.
- A missing or zero cooldown value selects a maximum cooldown of 1.

## Unit: app construction — `app.App.__init__`, `_start_scene`

### Goal

One object holds the OS window, the framebuffer, the input state, the audio and music systems, and the `save` data. It also holds the bots, the video state, and the scene stack, and starts the correct first scene.

### Invariants

- `SDL_VIDEODRIVER=dummy` is the headless mode of the full tool set. Without
  a window there is no `present()` call and no frame wait. This mode also
  bypasses the `title` screen and starts play immediately.
- The window opens before the level load. The first `pump()` opens the OS
  window and completes OS checks. When this first call was after the level
  load, `KDE` displayed `Not Responding` during long loads.

- The framebuffer is one RGBA byte array. `Window.present` and the PNG path read the bytes. The scenes paint through a `(W, H, 3)` numpy view of the same memory.
- `--fps` is a frame rate meter and not more. The polygon label overlay is
  behind `PERIHELION_DEBUG_ROOMS` and does not show with the fps readout
  (source instruction, `2026-07-28`: `there's labels on every room`).

### Verification

- A run with `SDL_VIDEODRIVER=dummy` opens no window and continues to play, record, and trace.
- A run with `--fps` shows the fps line and the phase line, and no polygon labels.
- A run with `--scale 3` opens a `1920x1080` window at the default internal dimension.

### Implementation

With positive `--scale N`, the window dimensions are `internal * N`. A
negative value selects the internal dimensions because `max(1, N)` returns
1. A value of 0 selects the default `1440x810` window. The Python condition
does not accept 0. With no flag, the window is also `1440x810`. In
`dummy` mode the app opens no window. If not in `dummy` mode, it opens
`necore.Window` with `title` `PERIHELION` and calls `pump()` once.

Framebuffer: a `bytearray` of `W * H * 4`, a `(H, W, 4)` numpy view `_fb_np`, and the paint view `internal = _fb_np[:, :, :3].transpose(1, 0, 2)` with shape `(W, H, 3)`.

Input state: `keys_held` (a set of key codes), `mouse_pos` (internal pixels, start value at the screen center), and `mouse_buttons` (a set). These replace the `pygame` state reads.

Meters: an fps mean with factor 0.1, and a `FrameMeter` for the phase telemetry.

Zoom: with a `--zoom` value, `ZOOM_BASE[0]` becomes that value.

Audio and music: `Audio(mute=args.mute)`. The music banks come from `--music-bank` (one bank directory, or a directory of `album_*` banks for rotation). The release default is the included banks, with no flags. `MusicSystem` starts with `enabled = not --no-music` and `tick_clock = bool(--record)`.

Flags and state: `show_fps` from `--fps`. `debug` from
`PERIHELION_DEBUG_ROOMS`. The `save` reads from disk. The difficulty comes
from `--hard` or the `save`. The master volume and mute come from the `save`,
and `--mute` overrides its mute value. The seed is `--seed` or 0.

Bots: `--bot human` assembles a `HumanBot` with `--bot-skill`, or with the
code default `DEFAULT_SKILL = 4.0`. With `--tactician`, it also assembles a
`Tactician`. The names `aggro`, `explorer`, and `pacifist` select and
assemble the applicable bot class with the seed.

Video: see the video unit. Trace: the writer starts as `None` and follows the session (trace unit).

`_start_scene`: in `dummy` or `autoplay` mode, play starts with no menu.
When `--start-chunk N` is not 0, it starts at chunk `N`. With 0, it calls
`start_new_game()`. Otherwise, the `title` screen pushes.

### Caveats

- `--zoom 0` does not apply. The code tests the value in a Boolean
  condition, and `0` is `False`.

- The framebuffer alpha bytes stay 0. The `present()` path and the PNG path read only the color bytes.

- Two related seed values are in play: `args.seed` is the command seed, and
  `GameScene.seed` is `rng_seed + chunk`. The trace header records only
  `GameScene.seed` in its `seed` field. The recorded `argv` also records a
  supplied command seed. A command seed from the default has no dedicated
  header field.

## Unit: frame loop — `app.App.run`, `_pace`, `_draw_frame`, `_end_frame`, `_shake_offset`, `_toggle_fullscreen`

### Goal

A frame loop with a rate that can change ticks the simulation at a constant 60 Hz.
The display rate does not change this rate. A draw occurs once each loop
frame, also for a headless frame with no display operation. The loop also
operates `pump()`, `autoplay` control, the video path, and the frame meter.

### Invariants

- The sim ticks at 60 Hz on an accumulator. At most 4 ticks run in one
  frame. A frame interval of more than 0.25 seconds does not become a burst of
  many ticks.
- In the video mode with one tick for each frame, each frame runs one tick. The wall clock has no effect.

- The frame rate goal is 60 fps, held with a wait. Headless runs free,
  without this wait.
- Shake moves the image in the OS window by at most 9 OS-window pixels on
  each axis. The internal framebuffer pixels do not move.

### Verification

- On a system that uses more than 4 sim steps of wall time for each frame,
  the loop cannot catch up. The simulation then runs slower than wall time and
  runs no more than 4 simulation steps for each frame.

  A tick ratio near 4 shows that the 4-tick limit is active. The fps value is also necessary to know if the sim keeps up with wall time.
- With shake off in the configuration, hits do not move the image.
- `F11` changes the fullscreen state. `QUIT` from the OS ends the run.

### Implementation

`run()` loops while `running`:

1. `meter.begin()` starts frame measurement. The video mode can use one tick for each frame. In this mode, the loop sets frame `dt` and the accumulator to `DT`. In other modes, wall-clock `dt`, limited to 0.25 seconds, adds to the accumulator.

2. The window `pump()` runs. Each platform tuple maps through `uievent.from_platform`. The state mirrors apply before the app sends the event. Thus the event's frame also sees the updated state. `KEYDOWN` and `KEYUP` change `keys_held`, while `MOUSEMOTION` sets `mouse_pos`. Button events change `mouse_buttons`.

3. Then: `QUIT` stops the loop. `VIDEORESIZE` has no effect (the `present()`
path adapts each frame). `F11` changes the fullscreen state. All other events
go to the top scene.

4. The `autoplay` control: when the top scene is not a `GameScene`, one wait
count increases. The count does not return to 0 when the top scene object
changes. When the count becomes 91, it returns to 0 and sends `SPACE` once
to that top scene. In the same frame, the code tests if the object continues
to be on top and is not a `GameScene`. It then sends `1` to a
`ConversationScene`, or sends `ESC` to the other scene types. A frame with a
`GameScene` on top does not increase or change the count to 0.

5. The tick loop runs at most 4 times while the accumulator holds a `DT`. Each time, it subtracts one `DT` and increases the frame tick count. It calls `_tick_game` only when the top scene is a `GameScene`. Thus menu frames use collected time and cause no tick burst when play continues.

6. The top scene `update(app, frame_dt)` runs. The meter marks `sim`.

7. `_draw_frame()` runs. Then the video path records the frame. It records 1
tick in the video mode that has one tick for each frame. Otherwise, it records
the tick count of this frame.

   The meter marks `record`, then `_pace()`, and then the meter marks `wait`. `_end_frame(ticks)` closes the frame.

After the loop: the video closes, the trace writer closes, and the `save` writes.

`_pace()` waits as necessary for the 60 fps goal when a window is open. Then it updates the fps mean with factor 0.1.

`_draw_frame()` sets the framebuffer to 0 and lets the top scene paint. When
`--fps` is on, it paints the fps line at `ui(4)` and the phase line at
`ui(17)`. The phase line shows `sim`, `draw`, `pres`, `rec`, `idle`, and the
tick ratio. The meter marks `draw`. Then the window shows the bytes with the
shake offset, and the meter marks `present`. The shake offset applies only
when `GameScene` is the top scene and shake is on in the configuration.

`_shake_offset(game)` adds a random value in `[-m, m]` for each active shake and limits each axis to `[-9, 9]`.

`_end_frame(ticks)` sends the frame to the meter. The meter returns one
`FrameTiming` record for each 60-frame window. The app emits it into the
session trace when a session is active. The meter runs in the menus, but the
record does not emit because there is no session to mark.

`_toggle_fullscreen()` changes the window fullscreen state. The engine
`present()` path holds the scale and border work, and this method changes no
other state.

### Caveats

- The phase line is at `ui(17)`, not `ui(14)`. At dimension 11, the glyphs
  are near 11 pixels high. A 10-pixel step painted the two meter lines
  through each other. A reader found it in each frame of a video with a
  duration of 1,440 seconds. No test could see it.
- `QUIT`, `VIDEORESIZE`, and `F11` do not go to the scenes.

- The shake random values come from the module `random`, not from the sim seed. Two equal runs shake differently. The sim state does not read these values.
- The fps phase line shows only after the first full meter window (near one second).

## Unit: game tick — `app.App._tick_game`, `_log_bot_event`

### Goal

One sim tick includes input from a person or bot and the input record. It ticks the sim and streamer, then drains the trace. The app then sends effects and processes audio, music, death, and level end scene changes.

### Invariants

- One `session.tick(input)` for each call.
- Each fx event sends on the tick it occurs. The fx set here: `shake`, `objective`, `terminal`, `pickup_text`, `shop`, `logvoice`, `locname`, `ambience`.
- At death, push the death screen once. At level end, transfer state to the next level or display the campaign-end screen.

### Verification

- With shake on, a hit shakes the view. A pickup shows a float label, a terminal shows the overlay, and death shows its screen.
- After a level end, the next level starts with the moved hp, ammunition, and weapons. It also receives the sorted set from the player state field `mind`.

### Implementation

Input: with a bot, the bot steps on the session snapshot. If a `tactician`
returns a record, the app writes it to the video event log as
`tactician_consult`. Bots do not receive terminal devices. As an alternative,
a terminal in the same polygon in 26 units sets `interact`. Recorded runs
then show its text and `conversations`. Without a bot, `_input_frame` reads
person input.

With video enabled, each tick's input is written to `inputs.jsonl` (source
note, `2026-07-19`: `human play must be studyable`). Rendered frames cannot
run the same session again, but the input stream can.

For each tick, the method records the previous death and level end flags.
It ticks the session and active streamer, and drains the trace. It sends the
effect list to the renderer. Audio processes sounds with
`session.visible(3, 24)` and then processes the heartbeat. Music reads
session state.

The app sends each effect as follows:

- Event `shake` — with shake on, adds `[magnitude, 10]` to the scene shakes.
- Event `objective` — sets the objective line with 240 ticks.
- Event `terminal` — a text with the `__CONV__` prefix pushes the `conversation` between levels with that number. All other texts push a `TerminalOverlay`.

- Event `pickup_text` — the world position maps through the camera to the screen. The test compares other float labels with the new position. A collision occurs below `46 * scale` horizontally and below `11 * scale` vertically. The new label then moves up `11 * scale`. The test uses each label's painted height because labels move up. Then the label spawns with 66 ticks.

- Event `shop` — pushes a `PodScene` when none is on the scene stack.
- Event `logvoice` — reads a `wreck` line from the pool. With a line, the log voice shows for 7 seconds.
- Event `locname` — sets the level name text with 4 seconds.
- Event `ambience` — no effect. Music supplies the music bed.

Shake decay: each shake multiplies by 0.82 each tick and ends below 0.05 or at tick 0.

Death: when `dead` becomes set on this tick, the death screen pushes. It receives the death count and the `chassis` count. The method then returns.

At level end, collect the transferred state and clamp hp to a minimum of 40.
The fields include ammo, holes, the `cloister` flag, weapons, and the selected weapon.
They also include components, `chassis`, `station` kits, `max_hp`, `hp_ups`, and `recalls`.
The remaining fields are `mind`, `think_focus`, `think_progress`, and `think_done`.

In streamed mode, write
`ng_plus + 1` and the transferred state to the `save`. Then replace all
scenes with the `epilogue` screen. Without a streamer, call
`advance_level(transferred)`.

`_log_bot_event(kind, payload)` writes one line to the video event log when video is on.

### Caveats

- When death and level end occur on the same tick, the death path runs and the end path does not. The return comes before the end test.
- The `terminal` fx with the `__CONV__` prefix opens a `conversation` in headless runs too. The `conversation` path in `advance_level` does not open in a headless run. This difference is correct: recorded bot runs must show the terminal `conversations`.

- The `ambience` fx arm has no body. The sim continues to emit the event, and the shell drops it.

## Unit: campaign and level flow — `app.App.campaign_levels`, `_load_level_by_index`, `build_debug_level`, `start_new_game`, `_start_streamed`, `start_level_index`, `_load_and_play`, `advance_level`, `reprint`, `restart_level`

### Goal

The campaign streams the level files from `levels/campaign.json` in
sequence, as one connected world. Player state transfers between levels,
the `save` contains the unlock count, and campaign end sets `New Game+` on. If
a load does not complete, `PERIHELION` must start in the small debug level.

### Invariants

- The level sources, in sequence: `--level PATH`, then the campaign manifest, then none. A level file load failure selects the debug level.
- All streamed starts go through one point, `_start_streamed`. `--loadout full` applies there. Thus each start path (menu, `autoplay`, `--level`) receives the calibration state.

- A chunk entry writes the `save`: the unlock count, the entry state for that chunk, and the configuration. The music turns to the next bank (`a new depth gets a new hymn`).
- `New Game+` sets hard difficulty and moves the state in the campaign-end
  `save`.

### Verification

- Without `levels/campaign.json` `PERIHELION` starts in a debug area with 3 polygons.
- A campaign start with `--loadout full` supplies all weapons and deep ammo on each start path.
- After the campaign end, the `title` screen shows `New Game+`. That start
  moves the weapon set in the `save` and uses hard difficulty.

### Implementation

`campaign_levels()` calculates its result once. With `--level`, it returns
that one path. With no `--level`, it returns the `levels` list from
`levels/campaign.json`. A manifest read failure prints to `stderr` and
returns an empty list.

`_load_level_by_index(idx)` reads the path at `idx` and returns
`(level, path)`. It reads a path that is not absolute from the source root. An index
that is not in the list range or a missing file returns `(debug level,
None)` without a message. Other load errors return the same pair and print
their cause. This fallback applies only to callers of
`_load_level_by_index`.

The caller keeps the requested `idx` as `current_level_index`. The session
seed is `rng_seed + idx`. The level path is `None`, and the trace file uses
the stem `session`.

`build_debug_level()` returns `debug-corridor`, with 3 polygons in a row.
Each polygon is a rectangle. Together they contain the player start, exit,
one `husk`, one `mite`, one ammunition box, and one medkit. They also contain
one terminal with constant log text.

`start_new_game(plus=False)` sets the level index to 0. With `plus` and a
`save` `ng_plus`, the difficulty becomes hard and the moved state comes from
the `save` `ng_state`. The code does not add weapons that are not in that
state. Then `_start_streamed(0, state)`. On a `save` without `ng_plus`, the
new session shows the starter control text.

In `_start_streamed(start_chunk, carried_state)`, `--loadout full` replaces
the transferred state with a copy of `FULL_LOADOUT`. That state has all
weapons, the large ammunition counts used by tests, and hp 100. Without
campaign paths, call `_load_and_play(0, ...)`. With campaign paths, load the
selected chunk. Start `GameScene` with seed `rng_seed + start_chunk`. Then
assemble `WorldStreamer` with the session and all paths.

The renderer's floor texture keys come from the map from engine polygon to
chunk. Each chunk uses its level file. The chunk entry callback sets the
level index and increases the unlock count. It records the entry state,
writes the `save`, and turns the music. The scene list becomes `[game]`
directly.

`start_level_index(idx)` starts a streamed run at `idx` with the entry state
in the `save` for that chunk.

`_load_and_play(idx, carried_state)` is the path without a streamer. It loads
by index, assembles the `GameScene` with seed `rng_seed + idx`, and replaces
the scene stack.

`advance_level(transferred)` is the level end path without a streamer. After
the last level, the `save` records the unlock count, `ng_plus + 1`, and the
moved state. The campaign end screen then shows the `epilogue`. Before the
last level, the next level loads with the moved state. In a windowed run,
the `conversation` for the completed transition pushes above the new level.
The level select path does not play this `conversation`.

`reprint()` controls the respawn after death. When
`session.respawn_at_station()` returns `True`, it clears the objective and
float labels and keeps the world and `wreck`. If the call returns `False`,
`restart_level()` reloads the level or calls `streamer.respawn()`.

`restart_level()`: with a streamer, the streamer respawn runs, and the objective line and the float labels clear. Otherwise, the level loads again with the state it started with.

### Caveats

- `New Game+` uses the state in the campaign-end `save`. A weapon missing from
  that state stays missing. Decision open (see `spec/open-questions.md`, item
  `SHELL-NEW-GAME-PLUS`): a source decision must select if `New Game+` adds the
  full weapon set as an alternative.

- Defect: a nonzero `--start-chunk` bypasses `_load_level_by_index` and
  directly reads `paths[start_chunk]`. A negative value in the Python list
  range selects from the list end. The world streamer and the `save`-state
  flow then use that negative value. A value not in the list range raises
  `IndexError` and stops program start. This does not obey the invariant
  that play always starts after a load failure. An incorrect start chunk
  must start the debug level through the stated fallback.

- When the campaign list is empty, the debug level end calls `advance_level`.
  The empty list selects the campaign end path. This path increases
  `ng_plus`, records the moved state, and shows the `epilogue`.

- Defect: `reprint` and streamed `restart_level` clear the objective line and float labels. They do not clear the log voice or level name text. Those two can play on across a death.
- The campaign path without a streamer (`advance_level` between levels) is complete code, but a normal campaign run always streams. The path runs only when the manifest is empty at a streamed start.

- The two campaign end paths (streamed `complete`, and `advance_level` after
  the last level) increase `ng_plus` and show the same campaign end text.
- The starter control text test reads the `save`, not the menu path. A player
  with `ng_plus` in the `save` who starts a standard `New Game` sees no
  starter control text.

## Unit: `conversations` between levels and `relationship` score — `app.App._push_gap_conversation`, `_add_trust`, `_add_flags`

### Goal

Between two campaign levels, the two characters speak. The `conversation`
lines come from `dialogue` data, `trust_total`, and flags in the `save`. The
`relationship` score changes and flags come back from the scene and go into
the `save`.

### Invariants

- A `dialogue` section between levels shows no scene when it has no lines for the applicable `trust_total` and flags.
- Effects that fire without player selection report once at scene end, as
  selection effects do.
- Changes to the `relationship` score add to `trust_total` in the `save` and
  gate `dialogue` variants deep in the campaign. The `epilogue` reads this
  value.

### Verification

- After a level ends in a windowed campaign run, applicable `dialogue` lines show in a `conversation` scene.
- A `trust_total` change in a `conversation` stays when the program starts again.

### Implementation

`_push_gap_conversation(gap)` calls `conversations.conversation_for(gap, trust_total, flags)`. Here, `gap` is the index of the transition between two levels, and the first index is 0. With lines, a `ConversationScene` pushes. Its report callbacks are `_add_trust` and `_add_flags`, and its start values are `base_trust` and `base_flags` from the result.

`_add_trust(delta)` adds to `trust_total` in the `save` and writes the
`save`. `_add_flags(flags)` updates the sorted `save` flag list with the
input flags and writes the `save`.

### Caveats

- The flag set is open. The previous `dialogue` tool removed the first
  `Faith Mirror` mechanism. A new flag set waits for a source decision about
  the `dialogue`-data loader.

## Unit: `epilogue` and `wreck` voice — `app.epilogue_text`, `corpse_line`

### Goal

Two `epilogue` variants and the `wreck` log voice. The `relationship` score
in `trust_total` selects the middle text part of the `epilogue`. A low score
selects the `letter` text, and a high score selects the `witness` text. A
collected `wreck` speaks one line in the voice of the Commando, or has no
line. `PERIHELION` does not speak text that no one wrote.

### Invariants

- A `trust_total` value of 3 or more selects the `witness` text part. Below 3, the `letter` text part. The head and tail parts are the same.
- Without a line pool, a `wreck` returns no line (`None`) and shows no other text.

### Verification

- A campaign end with `trust_total` of 3 or more shows the `witness` text part. A lower value shows the `letter` text part.
- With `data/corpse_lines.json` removed, a collected `wreck` shows no log voice line.

### Implementation

`epilogue_text(trust)` returns the head, one middle section, and the tail.
It selects `witness` when `trust >= 3`. Otherwise, it selects `letter`. All 4
text parts are module constants.

`corpse_line(idx)` reads `data/corpse_lines.json` once into a module list. A
read or parse failure returns an empty list. The function returns `None` for
an empty pool. For a pool with lines, it selects `idx` with wrap-around by
pool length.

### Caveats

- The pool file holds 24 lines. A text model wrote them in the voice of the character.
- A read failure supplies no message. The docstring states that no line is
  necessary. It must not supply text that is not in the data.

## Unit: video — `app.shutter_blend`, `App._record_frame`, `_record_one_tick`, `_rec_writer_loop`, `_close_record`, `_audio_tap`, and the video setup in `__init__`

### Goal

A frame and event record supplies videos and measurements. At a lower video
frame rate, the recorder calculates the mean of the painted loop frames in
each video interval. Thus a fast object can show a streak when each sim tick
has a different paint. The initial recorder kept one frame from each group and
dropped the remaining frames. It showed a fired projectile as
`damage with no visible threat`, and almost caused an incorrect repair of
correct simulation operation.

### Invariants

- The interval uses the sim clock. The video keeps `60 / every` frames for
  each sim second. When 2 or more sim ticks run before one paint, the
  recorder uses that same painted frame once for each tick. It cannot
  calculate the sim states between those ticks.
- The video mode for bot recordings runs one tick for each frame. `--play` keeps the normal loop — the sim does not become slow because a PNG writes.

- The PNG writes run on a writer thread. The engine writer releases the `GIL`. PNG encoding does not use frame-loop CPU time. Queue `backpressure` can continue to stop the frame loop until the writer removes an item.

- Each output frame writes an event with its sim tick. A reader must not
  calculate the offset between video and trace.
- Audio events write to the same event log. Their time values are
  `record_frame_count / 60`. Thus a mix tool can calculate the soundtrack.

### Verification

- A recording at `--record-every 2` writes 30 frames each simulation second,
  also when the render rate changes.
- In the video mode with one tick for each frame, a fast projectile can cross
  the integrated interval. It then shows as a streak in the output frame.
- `events.jsonl` holds a `frame` event with a `tick` field for each output PNG.

### Implementation

During `__init__`, `--record DIR` opens the output directory. Recorder state
holds that directory, interval `max(1, --record-every)`, and a `uint16`
frame-sum array. The array can hold `255 * every` without overflow through
interval 257. State also holds frame counts, the flag for one tick in each
frame (`not --play`), and the frame limit (`--record-seconds * 60`).

It keeps `events.jsonl` and `inputs.jsonl` open. It starts a queue with
capacity 8 and a `daemon` writer thread. It also connects the audio tap to
`_audio_tap`.

`_audio_tap(kind, name, vol, pan)` writes one event line with the video time
(`frames / 60`), the type, the name, and the rounded volume and pan. Here,
`frames` is the count of sim-clock steps that the recorder processed. It is
not the count of output PNG files. Without video state it has no effect.

`_record_frame(n_ticks)` runs `_record_one_tick` once for each sim tick that
occurred before this frame was painted. When each rendered frame represents
one simulation tick, `n_ticks` is always 1. If the frame includes 2 ticks, the
recorder adds the same painted frame to the accumulation buffer twice. Each
interval boundary writes only the mean frame for the completed interval. This
keeps the video time equal to the sim time.

`_record_one_tick` adds the framebuffer to the sum array. At the interval
boundary, `shutter_blend` returns the interval mean. Interval 1 uses the raw
bytes. The result is added to the writer queue as `frame_<n>.png`. A `frame`
event records video time, output index, and simulation tick. It uses `-1` in
menus without an active session.

With `PERIHELION_VIS_DUMP` set, each output frame writes data for each
result from `session.visible()` to `visdump.jsonl`. These data are the
polygon identifier, recursion depth, entry edge, clip box, and transform.
This is for the flicker
tests. At the frame limit, the mode with one tick in each frame stops the
program. A person run closes the video and plays on.

`shutter_blend(acc, n)` returns `(acc // n)` as `uint8` bytes — the mean of `n` integrated framebuffers. It raises `ValueError` for `n <= 0`.

`_rec_writer_loop` removes `(bytes, path)` items from the queue and writes each PNG through `necore.write_png`. A `None` item ends the thread.

`_close_record` sends the `None` and waits a maximum of 30 seconds for the writer
thread. It closes the two log files and prints the output frame count.

### Caveats

- Defect: `t` uses different clocks in the two log files. In
  `events.jsonl`, `t` is video seconds (`frames / 60`). In `inputs.jsonl`,
  `t` is the sim tick count. The same name holds two clocks.

- The record starts when the program starts. The video runs through the menus and the load, thus `frame * every` is not the tick. Because of this, each `frame` event moves its `tick`.

- The audio tap stays connected after the video closes. The tap tests the video state and then has no effect.
- The queue holds at most 8 frames. If the writer does not progress, the
  frame loop waits at the queue. Thus the record drops no frame. This wait
  can use frame-loop wall time.

- Defect: the sum array has type `uint16`. An interval above 257 can overflow
  the sum and cause incorrect colors.
- A stop before a video frame interval is full discards that interval.
- The close waits at most 30 seconds for the `daemon` thread. It then closes the log files and reports that the close is complete. It does this also when the writer is active after that time.

  The live `daemon` thread does not prevent the process end. It writes PNG files only and does not use the closed log files. An error in the writer thread does not become an error in the frame loop.

## Unit: session trace and build mark — `app.App._drain_session_trace`, `_build_id`

### Goal

The session trace operates for each active play session. The simulation
emits typed events, which the program drains to
`out/sessions/<mark>_<level>.jsonl`. Person and bot runs use the same trace
format. No flag turns the trace off. The code comment states that
`"nothing was watching" must never be the answer again`. Each trace must
identify its source (`A TRACE MUST SAY WHAT PRODUCED IT`).

### Invariants

- Each new session opens a trace path and closes the previous writer.
- The header holds level path, session seed, process `argv`, and build mark.
  These fields identify the source of each measurement. A header with
  only `seed 2` did not identify which of 2 runs supplied the record.

- The build mark is `<git-short-rev>`, or `<git-short-rev>-dirty` when
  tracked files have changes. It becomes `nogit` when `git rev-parse`
  returns an error or a subprocess raises. Files not tracked do not add the
  suffix because the `status` call uses `--untracked-files=no`.

### Verification

- After a person run, `out/sessions/` holds one JSONL file with a header line and the trace records of the session.
- The header of a run with changes in tracked files ends in `-dirty`.

### Implementation

`_drain_session_trace(game)`: when the session is not the one the writer follows, the previous writer closes. A new `TraceWriter` opens at `out/sessions/<YYYYMMDD_HHMMSS>_<level-stem>.jsonl` with the header fields `level`, `seed`, `argv`, and `build`. The timestamp uses local time and has a step of one second.

A second session with the same level stem in the same second opens the same path. This open operation replaces the first file. Then the writer drains the session bus.

`_build_id()` runs `git rev-parse --short HEAD` in the package directory
(limit 5 seconds). On a nonzero result or subprocess failure the result is
`nogit`. Then `git status --porcelain --untracked-files=no` selects the
`-dirty` suffix from its stdout. Defect: the code does not check the return
code of the `status` command. A nonzero result with empty stdout is reported
as a clean build mark.

### Caveats

- The trace drains in `_tick_game`. Thus a menu-only run (no session) writes no session file.

The file-end caveats are:

- The writer close at loop end does not drain the session bus. Records
  emitted after the last `_tick_game` drain are not on disk. This is usually
  less than one active play tick. A pause or overlay scene can
  emit one `FrameTiming` record for each 60 frames without a `_tick_game`
  call. Buffered frame records can stay off disk after exit from that state.

- Defect: two sessions with the same level stem that start in the same local
  time second select the same path. The second open replaces the first file.
  Thus the implementation does not keep one file for each session.

## Unit: music rotation — `app.App.rotate_music`

### Goal

The soundtrack must not play the same material again after a short interval.
A chunk entry turns to the next album bank
(`a new depth gets a new hymn`).

### Invariants

- With less than two banks, no change.
- The rotation keeps the active state and the clock mode of the previous system.

### Verification

- In a campaign run with two or more banks, the music changes character at a chunk entry.

### Implementation

`rotate_music()` increments the bank index with wrap-around and stops active
music. It then starts a new `MusicSystem` with the selected bank first in the
bank list.

### Caveats

- The previous system stops before the new one starts. The change is a hard cut, not a fade.
- Defect: `_music_i` starts at -1. The first call changes it to 0 and turns
  the list from index 0. It restarts the first bank and not the next bank.
  Subsequent calls move to a different bank as specified.

## Unit: screenshot — `app.App.take_screenshot`

### Goal

`F12` writes the internal frame as a PNG, and play continues.

### Invariants

- The output directory is `PERIHELION_SCREENSHOT_DIR` or
  `<save_dir>/screenshots`. The file name contains `int(time.time())`, the
  `Unix` time in seconds with its fractional part removed.
- An `OSError` from `mkdir` or PNG output prints to `stderr` and
  does not stop `PERIHELION`.

### Verification

- `F12` in play prints `[screenshot] saved <path>`, and the file shows the frame at that time.

### Implementation

The method calls `mkdir` for the directory. It writes framebuffer color
bytes through `necore.write_png` as `screenshot_<time>.png` and prints the
path to `stderr`. An `OSError` prints a failure line. Each other writer exception
raises.

### Caveats

- The screenshot is the internal frame, before the `present()` scale and before the shake offset.
- Two screenshots in one second write the same file name, and the second replaces the first.

## Unit: `save` file — `app.save_dir`, `save_path`, `App._load_save`, `_persist_save`

### Goal

One JSON `save` file holds the unlock count and the entry state for each
chunk. It also holds the `New Game+` state, `trust_total`, the flags, and the
configuration values.

### Invariants

- The path is `$XDG_DATA_HOME/perihelion/save.json`, or `~/.local/share/perihelion/save.json` without the environment value.
- Without a `save` file on disk, or after a parse failure, the state becomes `{"unlocked": 1, "states": {}}`. A parse failure prints the cause.
- Each write updates the configuration data (volume, mute, shake,
  difficulty) from the live state.

### Verification

- A first run writes no `save` until a `save` point: configuration-menu
  exit, chunk entry, or run end.
- A `save` file that contains invalid JSON prints a read failure, and `PERIHELION` starts a new session.

### Implementation

`save_dir()` and `save_path()` calculate the location. `_load_save()` reads and parses the file, with the new state on each failure. `_persist_save()` writes the configuration data into the `save` data and writes the file with `indent=1`. A write failure prints to `stderr`.

### Caveats

- The `save` writes after configuration-menu exit, chunk entry, and
  `relationship` score or flag changes. It also writes at the `New Game+`
  write and loop end.
  There is no `save` at intervals in play. Play state in a chunk is in the
  streamer entry states, not in a continuous `save`.
- Defect: Correct JSON that is not an object goes through the read step. Construction then calls `.get()` on it and stops with an error.

## Unit: telemetry records — `telemetry.TraceRecord`, `to_json_line`, and the typed events

### Goal

The typed event set is for the telemetry operations. The sim emits typed records with tick marks. Person and bot runs use one schema by construction. The types are frozen `dataclass` types.

Only `AgentTransition.x` and `AgentTransition.y` have defaults. A call that does not include a necessary field raises `TypeError` at the emit point. Thus a record that is not complete cannot be written.

### Invariants

- The module imports only the standard library: no `pygame`, NumPy, audio,
  renderer, or simulation. A test checks this boundary.
- One output procedure for the program and the `testkit`: `to_json_line` writes `{"seq", "t", "kind", **data}` as one JSON line.

- A value that JSON cannot hold raises. Sets and tuples become lists. All other value types are an error, not a text of unknown shape.
- No event type has a field named `kind`. Such a field can replace the
  record `kind` when the JSON operation adds the data fields.

### Verification

- A session JSONL line holds `seq`, `t`, `kind`, and the event fields, as one JSON line.
- An event call without a necessary field raises at the call point. `AgentTransition.x` and `AgentTransition.y` are the only optional event fields. Each has default 0.

### Implementation

`TraceRecord` is `(seq, tick, kind, data)`. `to_json_line` adds the data
fields to the top level. `_json_default` changes `set`, `frozenset`, and
`tuple` to lists and raises `TypeError` for all other types.

The event types, each with its `KIND` string and tick:

- Record `InputRecord` — fields `mx, my, ax, ay, fire, alt, interact, weapon`. One input frame.
- Record `AgentTransition` — fields `entity_id, agent_kind, from_state, to_state, x, y`. Run 51 added the positions.
- Record `EnemyPositions` — field `positions`, one map for all enemies: id to `[kind, polygon, x, y]`.

- Record `PlayerDeath` — fields `polygon, x, y, source, chassis_left, deaths`. A record type only for death.
- Record `PortalCrossing` — fields `entity_id, entity_kind, from_polygon, to_polygon, edge`.
- Record `DamageApplied` — fields `target_id, target_kind, amount, source`.

- Record `ImpulseApplied` — fields `entity_id, jx, jy, source`. The impulse
  uses mass as its scale.
- Record `FieldSample` — fields `totals, player_polygon, player_own`. Signal field state.
- Record `BreachLifecycle` — fields `breach_id, event, world_chamber, detail`.

- Record `CorePartEvent` — fields `part_id, part_kind, event, detail`. It uses
  `-1` and `""` for events that apply to all `core` parts.
- Record `ReserveSample` — fields `reserve, live_breaches, pending_kind`.
- Record `DispatchDecision` — fields `breach_id, unit_kind, entity_id, from_shelf, knows_position, hub_chamber`.

- Record `PickupTaken` — fields `item, amount`. See the caveat on the field name.
- Record `ShelfReplaced` — fields `unit_kind, entity_id, hub_chamber`.
- Record `EnemyDeath` — fields `entity_id, enemy_kind, polygon`.

- Record `CoordEvent` — fields `entity_id, agent_kind, event, detail`. Holds, `prowls`, and `watchdogs`.
- Record `FrameTiming` — see the frame meter unit. The one record that the program emits.
- Record `TopologyChanged` — fields `op, a_polygon, a_edge, b_polygon, b_edge, source`.

### Caveats

- The field of `PickupTaken` is `item`, not `kind`, and this corrects a live
  defect. A field named `kind` replaced the record `kind` when the operation
  added data fields. Thus each `scan` by `kind` could not find the event.
  After the trace was added, reports of hp increases without a cause that
  the user could see continued.
- Only `AgentTransition.x` and `y` have a default (0).

- Defect: the `TraceEvent` type union does not include `EnemyPositions` and `PlayerDeath`. The two are record classes, and `TraceBus.emit` accepts them at run time. A static type check can reject correct calls that emit one of the two records.

- A comment keeps event names for units that have no code. Thus new code
  can use these names.

## Unit: frame meter — `telemetry.FrameMeter`, `FrameTiming`

### Goal

The frame meter measures each frame's wall-clock time. One fps value cannot
identify record cost, draw cost, or a simulation tick with a high cost. The
meter divides the frame into phases and emits one record for each 60-frame
window. This record replaces reports with no measurements, for example
`unplayably slow`, with measurements.

### Invariants

- The phases are `sim`, `draw`, `present`, `record`, `wait`. An unknown phase name raises.
- Time that is not in a phase stays in the result. `ms_frame` is wall time minus wait, and the phase means show with it. Thus a cost with no phase shows as the difference.

- `sim_ticks / frames` is the health signal: 1.0 is good. A value near 4.0 shows that the loop is at its 4-tick limit — `PERIHELION` runs in slow speed.
- `ms_wait` is idle time. Large is good.

### Verification

- A `frame_timing` record shows in the session trace approximately once each
  second of play.
- On a system that holds 60 fps, `fps` is near 60 and the tick ratio near
  1.0.

### Implementation

`FrameTiming` holds `tick`, `frames`, `fps` (wall clock), `ms_frame` (mean work), `ms_worst` (the largest work time of one frame), the phase means (`ms_sim`, `ms_draw`, `ms_present`, `ms_record`, `ms_wait`), and `sim_ticks`.

`FrameMeter(window=60)` collects measurements. `begin()` records frame
start. `mark(phase)` adds elapsed time since the previous mark to that phase
and to frame work. It does not add `wait` to frame work. If the same phase
is marked again, it adds the next interval to that phase.

A phase with no mark stays at zero. `end(tick, sim_ticks)` counts the frame and the ticks and keeps the largest work value. At the window dimension it calculates the record, sets all sums to zero, and returns the record. Before that it returns `None`.

### Caveats

- A window below 1 raises at construction.
- The class does not check call sequence. If `mark` is called before `begin`,
  it measures from time 0 and can add a very large interval. If `end` is
  called before `begin`, it counts a frame with the active work value, which
  starts at 0.
- The meter is standard library only and does no file work. The emit decision is with the code that calls it.

## Unit: trace bus — `telemetry.TraceBus`

### Goal

The one channel in memory between the sim and the code that drains it. The bus has no query operation that keeps records in the buffer. Its only output operation is `drain()`, which empties the buffer. Thus sim code cannot use its trace as state. Telemetry also cannot become a simulation input.

The renderer must not import the module. A visual signal must read the
system state, not the trace.

### Invariants

- Sequence numbers always increase.
- Tick marks do not decrease. A tick that decreases raises.
- The one exit is `drain()`, which empties the buffer and returns the records.
- An event with a `kind` field raises at emit.

### Verification

- The boundary test holds. There is no import from the closed list and no
  query operation that keeps records in the bus. The renderer does not
  import telemetry.
- `drain()` returns all records since the last drain, and a second drain returns an empty list.

### Implementation

The bus holds a list, a sequence count, and the last tick. `emit(event)` changes the `dataclass` to a `dict` and removes `tick`. It rejects a `kind` field. Then it adds a `TraceRecord` with the type's `KIND`.

`sample(tick, data)` adds a record with `kind` equal to `sample`. This interval state copy lets a reader work without a new sim run. `drain()` returns the buffer and starts an empty one.

### Caveats

- The tick test applies to `emit` and `sample` together, in emit sequence.
- The bus increases without limit between drains. The program drains each tick, thus the buffer stays one tick deep in normal runs.

## Unit: trace writer — `telemetry.TraceWriter`

### Goal

The one JSONL writer for the bus. The program uses it for person sessions, and the `testkit` programs use it for bot runs. It is the same writer, thus the two outputs cannot become different. Failures raise or show errors. A failure does not go to a second log.

### Invariants

- The first line is the header: `{"kind": "header", **header}`.
- A path that cannot open raises at construction. A write failure raises at the drain point.

### Verification

- A session file starts with one header line, then the records in emit sequence.

### Implementation

The constructor calls `mkdir` for the path's directory and opens the file
for write in `UTF-8`. It then writes the header line. `drain_from(bus)` drains
the bus, writes each record through `to_json_line`, and returns the record
count. `close()` flushes and closes.

### Caveats

- The writer does not flush on each drain. A process end without `close()` can drop the last records.
