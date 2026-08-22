# Audio and music

This specfile tells the operation of `game/perihelion/audio.py` and `game/perihelion/music.py`. It is a warm-start specfile: it tells the code as it IS, defects included.

## The sound bank

### Goal

`PERIHELION` reads each sound effect from `game/assets/sfx/<name>.wav` on first use. The bank can contain only some sounds because the `tools/soundgen` toolchain supplies it in a different process. A missing file causes one line on stderr, and play continues without that sound.

### Invariants

- Each sound file must hold audio at 44100 Hz with 2-byte samples.

- The engine mixer receives each sound as stereo `float32` sample data.

- A missing file or a file with incorrect data causes no more than one stderr line for its name.

- The code reads each named sound from disk only once. The bank keeps its correct result or `None`.

### Verification

- A name with no file returns no sound id, and play continues.

- The code rejects a file with a different sample rate or sample width and reports the error on stderr.

- A mono file plays with the same signal on the two sides.

- A second play of the same name does not read the disk again.

### Implementation

`_wav_to_f32_stereo(path)` opens the `.wav` file. `Audio._load` catches errors from `wave.open`, `readframes`, numpy, and the array shape change. A frame rate of 44100 and a sample width of 2 bytes are necessary. If one value is different, the function reports the error on stderr and returns `None`. It reads all frames as native `int16` values.

A stereo file keeps its two channels. A mono file copies its one channel to the two output channels. The function divides by 32768.0, changes the samples to `float32`, and returns the bytes.

A file with a channel count other than 2 follows the mono path. The function uses all interleaved samples as one sequence and copies each sample to the two output channels. A source with `C` channels and `F` frames thus becomes `C * F` stereo frames. The engine accepts the result when its byte count is divisible by one 8-byte stereo frame.

`_Bank` maps each name to an engine sound id or `None`. `alloc()` returns 1, then 2, then 3. Music and sound effects use the same bank and mixer, and thus the same master mix.

`Audio._load(name)` returns the kept id when the name is known. For a new name, it reads and decodes `game/assets/sfx/<name>.wav`. Then `alloc()` supplies an id, and the method sends the data to `mixer.load_sound`. A missing path reports `[audio] missing sfx: <name>.wav (skipping)`. An error reports `[audio] failed to load <name>.wav: <error>`.

A rate or width error reports the necessary and measured formats. The bank keeps `None` after each failure. Subsequent calls do not read or report that name again. When the `Audio` object has no bank, `_load` returns `None` without output.

### Caveats

- A file that `_wav_to_f32_stereo` rejects does not go into `_missing_logged`. The bank keeps `None`, and the message does not occur again. The two error paths use different records.

- Defect: the function does not reject a WAV file with more than 2 channels or supply a correct stereo mix. Samples in channel sequence become stereo frames one after the other.

- The bank does not remove or free a sound. A name with one failure stays without sound for the session.

## `Audio` construction and no-sound mode

### Goal

`Audio` holds the engine mixer, the master volume, and the sound position model of `PERIHELION`. The program runs with no sound when no audio device is available. A backend failure has the same result as the previous `pygame.mixer` failure.

### Invariants

- A mixer failure does not stop the program, and all sound calls then do no work. An exception during the `AudioMixer()` call causes one stderr line. A mixer assembled with `ready=False` causes no output.

- With `mute=True` at construction, the code does not call `necore.AudioMixer()`.

- The `tap` callback receives each sound event, with events while muted or after a mixer failure. Thus headless recordings log all audio.

### Verification

- Cause mixer construction to raise: the program continues, stderr shows one mixer line, and `play` returns `False`. Return a mixer with `ready=False`: the program continues without a mixer line, and `play` returns `False`.

- Start with `mute=True`: the code opens no device.

- A headless record operation with a tap set logs all sound events.

### Implementation

Construction sets `master_vol=1.0`, `sfx_vol=1.0`, `ambience_vol=0.35`, `muted=mute`, `tap=None`, and `culled_silent=0`. When sound is not muted, it calls `necore.AudioMixer()`. `_ready` receives the mixer `ready` flag. An exception reports `[audio] mixer init failed, running silent: <error>`.

An object with `ready=False` causes no output. In the two failure conditions, the code discards the mixer and `_ready` stays `False`. With a live mixer, it calls `_Bank()`.

Engine channel numbers: the music system uses 0..63 (lanes, riser, tails). The ambience loop uses channel 1000, and the heartbeat loop uses channel 1001.

### Caveats

- `_ready` is set only during construction. The code does not use a device that becomes available in the middle of a session.

- Defect: an object assembled with `mute=True` has no mixer or bank. A subsequent `set_mute(False)` changes the mute flag but does not call `necore.AudioMixer()`. That object has no sound for the session. This construction path does not obey the goal of a run-time mute control.

- Decision open (see `spec/open-questions.md`, item `AUDIO-CONSTRUCTION-MUTE`): select if mute during construction selects a permanent headless mode. Or select if subsequent removal of mute calls `necore.AudioMixer()`.

## Play one sound

### Goal

`Audio.play(name, vol, pan)` plays one sound effect once with a stereo position. The mixer has 24 `sfx` voices. The code does the cull before voice selection. A send with gain below 0.006 receives no voice.

### Invariants

- The tap, when set, fires for each call, before the mute and cull checks.

- A send with gain below `INAUDIBLE` (0.006, about -44 dB) does not receive a mixer voice. The `culled_silent` count increases by 1.

- The return value is `True` only when the mixer gave a voice.

- At 24 active voices, the mixer compares left gain plus right gain. It compares the new sound with the active sound that has the lowest sum. It drops the new sound when its sum is equal or lower. If its sum is higher, it removes the voice with the lowest gain and starts the new sound.

### Verification

- With a tap set and `muted=True`, the tap fires and the function returns `False`.

- A far send with a gain below 0.006 increases `culled_silent` and plays no sound.

- A usual send returns `True`, and the player can hear it.

### Implementation

The function first fires the tap with `("sfx", name, vol, pan)`. When muted or not `_ready`, it returns `False`. It limits `vol` to 0..1 and multiplies by `sfx_vol` and `master_vol`. Below `INAUDIBLE`, it counts the cull and returns `False`. It loads the sound id, limits `pan` to 0..1, and calls `mixer.sfx_play(sid, (1-pan)*v, pan*v)`.

The limits use Python `min` and `max`. `float("inf")` becomes 1.0, `float("-inf")` becomes 0.0, and a `NaN` argument becomes 1.0 in these calls. The same requirement applies to `set_master` and `duck_ambience`. The code does not check that `sfx_vol` is finite.

### Caveats

- The tap receives the arguments before the limits and gain changes. Thus its tuple can be different from the values that the mixer receives.

- The pan calculation is linear. A middle send puts 0.5 of the gain on each side, about -6 dB for each side. The arithmetic sum of left and right gain stays equal to the input gain. But squared gain and heard loudness are lower at the middle.

## Sound position in the level

### Goal

`Audio.handle_sounds(session, sounds, visible_instances)` uses the `("sound", name, polygon, x, y, vol)` events from the simulation. The sound level decreases by one step for each portal hop between the source and the player. Tension must increase gradually, as given in `ENGINE_DESIGN` section 3.4. The player hears a threat before the threat comes into view.

A source on the screen receives an accurate stereo position. A source out of view plays at the center. Its sound does not show a screen position that the player cannot see.

### Invariants

- The code drops a source in a polygon with no portal path to the player.

- The volume is `vol * 0.55^hops` (`HOP_ATTENUATION` = 0.55).

- Only a polygon in `visible_instances` receives a pan that is not at the center.

### Verification

- A sound 2 hops out plays at `0.55^2` of its volume, at middle pan.

- A source in view at the left screen edge pans fully left.

- A sound in a sealed polygon does not play.

### Implementation

The function returns immediately when the event list is empty. It maps each polygon in view to its transform and uses the first instance of a polygon. For each `"sound"` event, it calls `session.sim.hop_distance(polygon, player_polygon)`. A result below zero drops the event.

It decreases the volume by hops. When the polygon is in view, it transforms `(x, y)` with `necore.mat_apply`. It divides the screen `x` by `max(1.0, float(session.screen_w))`, and limits the result to 0..1 as the pan. The first item for a polygon is used in the supplied `visible_instances` sequence. It then calls `self.play`.

### Caveats

- None.

## The ambience loop

### Goal

Each area selects a continuous ambience loop by name. The `corrupted` display lowers the loop volume while the bloom changes its sound. `duck_ambience` does this operation.

### Invariants

- A call with the set name again changes no state.

- A name change stops the previous loop before the new one starts.

- The loop volume is `ambience_vol * master_vol * duck`, equal on the two sides.

- The tap, when set, logs each ambience change.

### Verification

- Two calls with the same name start only one loop.

- `ambience(None)` stops the loop.

- `duck_ambience(0.3)` lowers the loop immediately, and `duck_ambience(1.0)` sets it back.

### Implementation

`ambience(name)` returns when the name equals the kept name. For a different name, it keeps the name and sends the tap tuple `("ambience", name, ambience_vol, 0.5)`. When a loop runs, it stops channel 1000. If sound is muted, `_ready` is not set, or the name is empty, the method ends there. Otherwise, it loads the sound, plays it on channel 1000 with loop count -1, and sets the volume.

`duck_ambience(frac)` limits the value to 0..1, keeps it, and updates the channel volume when the loop runs.

### Caveats

- `set_mute(True)` stops all channels but `_ambience_on` stays `True`. After `set_mute(False)`, the loop has no sound until the next name change. Defect: the goal of a continuous area loop is not obeyed across a mute cycle.

- `set_master` does not update the volume of an active loop. The new master applies at the next `ambience` or `duck_ambience` call.

## The heartbeat loop

### Goal

A heartbeat loop plays while the player is below 30 hp and `session.dead == False`. It stops when hp is 30 or more, or at death.

### Invariants

- The loop starts only when the state changes, not on each tick.

- The tap logs the `heartbeat_on` and `heartbeat_off` changes when muted too.

- The loop volume is `0.5 * master_vol`.

### Verification

- Fall below 30 hp: the loop starts once.

- The loop stops when hp is 30 or more, or when `session.dead` becomes set. The death transition must set `session.dead`. An hp value of zero does not stop the loop when `session.dead` is not set.

- With a tap set, the state changes go into the record.

### Implementation

`update_heartbeat(session)` calculates `want = session.hp < 30 and not session.dead`. Thus 30 hp stops the loop. When `want` equals the kept flag, the method returns. For a different value, it keeps the flag and sends `("heartbeat_on", "heartbeat", 0.5, 0.5)` or `("heartbeat_off", "heartbeat", 0.5, 0.5)`.

To start, the method returns when sound is muted or `_ready` is not set. Otherwise, it loads `heartbeat`, plays it on channel 1001 with loop count -1, and sets the volume. To stop, it stops channel 1001 when a mixer is available.

### Caveats

- The same mute defect as the ambience loop applies. After mute goes off, the loop has no sound until hp goes across 30 again. The kept flag has the incorrect state.

- The loop volume reads `master_vol` only when the loop starts. A subsequent master change does not change the active loop.

## Master volume and mute

### Goal

The adjustment menu sets the master volume and the mute state at run time.

### Invariants

- `set_master` limits to 0..1.

- `set_mute(True)` stops all mixer channels immediately.

### Verification

- Volume steps from the menu change the level of new sends.

- Mute stops all sound from `PERIHELION` immediately.

### Implementation

`set_master(v)` keeps the limited value. `set_mute(muted)` keeps the flag. When it mutes a live mixer, it calls `mixer.stop_all()`.

### Caveats

- `set_mute(False)` starts no loop again. See the ambience and heartbeat defects above.

- A master change comes to a loop only when that loop next updates its volume. A sound effect send reads the change immediately.

## `EngineSound`

### Goal

`EngineSound` is one loaded engine sound with a known length. It supplies part of the native-engine interface for the music system. It replaces the part of the previous `pygame.mixer` sound model that `music.py` calls.

### Invariants

- `get_length()` returns frames / 44100 seconds.

- Construction from an array accepts `int16` data, mono or stereo. Mono copies to the two channels.

- Construction from a file accepts `.wav` and `.ogg` through `soundfile`, only at 44100 Hz.

- With no bank on the audio object, `from_array` returns an object with no sound id and `from_file` returns `None`.

### Verification

- An array of 44100 frames results in `get_length() == 1.0`.

- The code rejects a 48000 Hz file and reports the error on stderr.

- The music system runs against a stub audio object with no bank.

### Implementation

`from_array` checks for a bank before it examines the array. Without a bank, it returns an object with `sid=None` and `len(seg)` frames. With a bank, `np.asarray(seg, dtype=np.int16)` accepts each shape that numpy can change to that type. A one-dimensional array of length `N` becomes an `(N, 2)` array with two copies of each value. An array with two or more dimensions keeps its shape.

The function records the first array dimension as the frame count. It changes all values into one adjacent `float32` array, divides by 32768.0, and sends the bytes to the mixer. The mixer accepts the bytes only when their total length is divisible by 8. Other lengths cause `load_sound` to raise `ValueError`.

`from_file` checks for a bank, then reads the file as `float32` through `soundfile`. It catches each error from `soundfile.read`, reports `[audio] failed to load <path>: <error>`, and returns `None`. For a rate other than 44100, it reports the necessary and measured rates and returns `None`. Mono becomes stereo. Other array shapes stay the same.

The function records the first array dimension as the frame count. `load_sound` can raise `ValueError` when the byte count is not divisible by 8. This call does not catch that error.

For an array or file with more than 2 channels, the code keeps all channels. It sends the samples in channel sequence to the mixer. It does not reject the data or supply a stereo mix.

`free()` calls `mixer.free_sound(sid)` and then sets `sid` to `None` only when the id and mixer are not `None`. A subsequent call does no work. If the mixer is `None`, the id stays set.

### Caveats

- The bank check reads the attribute with `getattr`. This is correct: tests operate the music system with a stub object.

- Defect: `from_array` and `from_file` do not supply stereo data from input with more than 2 channels. This does not obey the stereo mixer-data invariant.

- Decision open (see `spec/open-questions.md`, item `AUDIO-MULTICHANNEL`): select the necessary operation for input with more than two channels. Reject it, select two channels, or supply a stereo mix.

## `EngineChannel`

### Goal

`EngineChannel` is one numbered mixer channel. It supplies these `pygame` calls to `music.py`: play, queue, `get_queue`, volume, stop, fadeout, and `get_busy`. The engine mixer replaced the previous Pygame layer. The channel numbers and calls used by `music.py` stay the same.

### Invariants

- Each method does no work when the audio object has no mixer.

- `queue` starts the queued sound at the end of the active sound, with no silence between them. The device keeps accurate time.

- `get_queue()` returns `True` when a chunk waits behind the active chunk. If no chunk waits, it returns `None`.

### Verification

- All methods run without error against a stub audio object.

- Two queued chunks play in sequence with no silence between them.

- `get_queue()` turns `None` when the queued chunk starts.

### Implementation

Each method reads `audio.mixer` through `getattr` and returns when the value is `None`. `play(snd, loops)` and `queue(snd)` also return when the sound or its id is `None`. `play` starts the sound and clears the queued sound and active fade. `queue` starts the sound when the channel has no active sound. With an active sound, it replaces the queued sound.

`get_queue` returns `True` only while that queued sound waits. `set_volume(l, r)` uses `l` for the two sides when `r` is not given. `stop` removes the active sound, the queued sound, and the fade. `fadeout(ms)` changes the value to `int`. The Python binding then must have a value that fits its unsigned argument. `get_busy()` returns `True` only when the channel has an active sound.

### Caveats

- `get_queue` returns only `True` or `None`, not the queued sound. The lanes only compare it with `None`.

## Music banks on disk

### Goal

An album bank is a directory of stem files (`.wav`, `.ogg`) and a `bank.json` file with form data. `shipped_banks()` lists the album banks below `game/assets/music/album_*`. These banks supply the default music without flags or test paths.

### Invariants

- `shipped_banks` returns only directories with a `bank.json`, in sorted sequence.

- `load_bank_meta` is the only loader for `bank.json`. It checks the fields or raises an exception. There are no neutral defaults.

- `BankMeta` cannot change after construction. The loader sets `bar_s`, `n_bars`, and `sections`.

- Each section `[a, b)` must be in the `bars` range, with `a < b`. The section list must not be empty.

### Verification

- A bank without `bpm` in `bank.json` raises `ValueError`. It does not use 140 without an error message.

- A section out of the form range raises `ValueError`.

- `tools/musicgen/check_bank.py` uses the same loader.

### Implementation

`shipped_banks` returns an empty list when `game/assets/music` is not on disk. It examines only paths directly below that directory. A path name must agree with `album_*`, and the path is included when it contains `bank.json`. The code does no different directory check. Python puts these `Path` objects in sequence by their full path components.

Each item in `sections` must contain 3 values in this sequence: name, start, and end. The loader changes the name with `str` and the two limits with `int`. Thus it accepts number strings, Boolean values, and fractional numbers when `int` accepts them. The limits after this operation are integers.

The loader does not catch errors from `read_text` or `json.loads`. Its `except` block catches `KeyError`, `TypeError`, and `ValueError` from field access and conversion. It changes them to `ValueError` with the file path. Tuple construction raises `ValueError` for an item of incorrect length. The same `except` block catches that error and adds the file path. It also catches `TypeError` from an item that is not a sequence.

The loader checks `bpm > 0`, `bars > 0`, a section sequence with one or more items, and a correct range for each section. It does not reject Boolean values, duplicate names, ranges that include the same bars, or bars in no range. `float("nan")` goes through the `bpm <= 0` check and results in `bar_s=nan`. `float("inf")` also goes through it and results in `bar_s=0.0`. The loader returns `BankMeta(240/bpm, bars, sections)`.

A comment in the code logs two previous defects. With a missing `bpm`, the code before this loader played the bank at 140. With a missing section list, form control turned off with no text line.

### Caveats

- Defect: the module default `BANK_DIR` points to `game/perihelion/assets/music/hymn01`, and that directory is not on disk. The banks are below `game/assets/music`. A `MusicSystem` assembled without bank inputs thus finds no bank and plays no music. `PERIHELION` always supplies `shipped_banks()`, and does not use this default path.

## The music inputs

### Goal

`read_inputs(session)` returns the complete music-engine input `dict` from live simulation state. It contains these keys: `level`, `weapon`, `aggro`, `aggro_ids`, `crowd`, and `firing_now`. It also contains `hp`, `tension`, `influx_rate`, `dmg_rate`, `kill_rate`, and `fire_duty`. The music follows the player when the player starts combat. Thus an enemy in the `waking` state goes into the list only after player fire in the previous 3 seconds.

### Invariants

- The `dict` contains each key that the music input calculation reads. The EMA rates start at 0.0, and the engine updates them. The calculation reads each key without a default. A missing key raises an error and does not return a result without sound.

- An `idle` enemy does not go into the list.

- Each entry is `(kind, hops)` with hops 0 (same polygon), 1 (adjacent polygon), or 2 (far).

- An enemy in view at less than 60 units counts as hops 0 in all polygons. Contact receives the same weight as an enemy in the player polygon.

### Verification

- A snapshot from a session with no aggro has an empty `aggro` list and rates at 0.0.

- An enemy entity shape against the player through a portal has hops 0.

- A `flicker` in the `lurk` state in the polygon of the player increases `tension` and stays out of `aggro`.

### Implementation

The function reads the player polygon and then the fire state. `player_hot` means fire in 3 seconds, and `firing_now` means fire in 8 ticks. A `flicker` in `lurk` state in the player polygon adds 0.5 to `tension`, limited to 1.0. The function then does not include that enemy. It also does not include each `idle` enemy or each `waking` enemy without `player_hot`.

It calculates hops through `session.sim.hop_distance` and keeps only 0 and 1. All other results become 2. A negative result that shows no path also becomes 2. Thus an engaged enemy with no portal path stays in the music inputs as a far enemy.

A view record nearer than 60 sets hops 0. An enemy at hops 0 with a view record adds `1/max(distance, 10)` to `crowd`.

The reads of `kind` and `state` occur before the `except` blocks. A missing key or incorrect enemy value thus stops the function. For a `flicker` in the `lurk` state, one `except` block catches each error from `get_polygon`. That enemy then adds no tension. For all other included enemies, a second `except` block catches each error from `get_polygon` and `hop_distance`.

An enemy caught by the second `except` block does not go into `aggro` or `aggro_ids`. The subsequent `sight_of` call has no `except` block. The function returns these keys: `level`, `weapon`, `aggro`, `aggro_ids`, `crowd`, `firing_now`, `hp`, and `tension`. It also returns `influx_rate`, `dmg_rate`, `kill_rate`, and `fire_duty`. The 4 rate values start at 0.0.

A comment on a removed test states that `hop_distance` returns 0 when the two arguments identify the same polygon. Thus the removed test changed no result.

### Caveats

- The crowd value counts only enemies with a view record. An enemy in the same polygon but out of view adds no crowd.

- The weapon key uses `session.weapon` first. If `not session.weapon`, it uses `session.current_weapon`. The `getattr` default is `"?"`.

- An unreachable enemy receives hop class 2 because each hop result not in 0..1 becomes 2. The input calculation thus gives it the same weight as each other far enemy.

- Decision open (see `spec/open-questions.md`, item `AUDIO-UNREACHABLE-ENEMY`): must an unreachable engaged enemy stay in the music input as a far enemy? Or must the system ignore it?

## The music input calculation

### Goal

The music is NOT a state model. A decision dated 2026-07-13 sets this property. `Prayer`, `Contempt`, and `Stalwart` are continuous values in 0..1:

- `Prayer` — the player in `prayer` and thought, but `the urgency pulse never fully stops`. The floor is 0.12.

- `Contempt` — a value that estimates the player's damage output (`ass-kicking music`). The input calculation does not measure damage directly. It uses the fire rate, kill flow, and the count of weak enemies in contact. The `groove` lane sounds while those measurements show damage output.

- `Stalwart` — the weighted enemy threat against the player.

One value does not decrease the other two. A decision dated 2026-07-16 sets this property. Combat with a boss is high on `contempt` and `stalwart` together. Kills of `mite` and `husk` enemies are only `contempt`. An enemy procedure in which the player cannot attack in return is only `stalwart`.

The weights come from a corpus fit (task #34) with 200 recorded runs and 478000 rows. A `ridge` fit used the measured damage during the next 5 seconds. It also used kill flow and the low threat value. The fit score uses `held-out Spearman`. Compared with the previous input calculation, enemy threat is `.256` against `.206`. Kills are `.220` against `.001`, and low threat is `.254` against `.178`.

### Invariants

- `values` returns `(prayer, contempt, stalwart)`, each rounded to 0.001, each in 0..1.

- `Prayer` does not go below `PRAYER_FLOOR` (0.12).

- `Stalwart` follows `1 - exp(-enemy_sum/17)`. The formula has no group limit for enemies that are not bosses. Thus a sufficiently large group can be more than 0.9. In the measured corpus, typical groups without a boss were near or below 0.88. The specified `warden` weights are above the fit.

- Fire adds no enemy weight. `FIRED_W` is 0.0. The decision dated 2026-07-17 gives fire to `Contempt`.

- The `scream` sound adds no enemy weight. It occurs with enemy weight but does not cause it. The `influx` and count weights apply when the enemy group comes to the player.

- `battery_terms` names each part of the sums for the debug overlay. The overlay shows the 3 largest rows of each sum. This lets the meter show its causes, as necessary in the 2026-07-17 decision.

### Verification

- An empty snapshot gives values near `(1.0, 0.0, 0.0)`.

- One `warden` in the same polygon, with no other enemy, pushes `stalwart` above 0.6. Combat with a boss with adjacent `warden` enemies pushes it above 0.9.

- An attack that hits no enemy, with one far enemy, does not read as a full combat (`F004235`).

- `tools/musiccal/collect_corpus.py` processes the corpus through these functions again.

### Implementation

The enemy-weight sum uses `DANGER_CO[kind]` at hops 0, `DANGER_ADJ[kind]` at hops 1, and `0.15 * DANGER_ADJ[type]` at hops 2, plus `27.5*crowd`, `3.0*influx_rate`, and `0.13*dmg_rate`. `Stalwart` is `1 - exp(-enemy_sum/17)`.

The kill sum is `0.37*kill_rate + 5.65*fire_duty + 0.012*weak_count`, where `weak_count` counts `mite` and `husk` in the same polygon. `Contempt` is `1 - exp(-sum/1.5)`.

`Prayer` is `max(0.12, 1 - min(1, enemy_sum/16 + 0.007*fire_duty))`.

`battery_terms` calculates the same sums as named dicts. The keys are `kind`, `kind+1`, `kind+2`, `crowd`, `influx`, `dmg`, `firing`, `kills`, and `trash`.

Key weights: `warden` 20 and 14 (same polygon and adjacent, as specified), `brute` 1.0 and 0.3, `flicker` 1.9 and 0.2, `husk` 1.0 and 0.8, and `shrieker` 0.15 and 0.1. The `shrieker` runs from the player. The scout types `vagrant` and `lacuna` read 0.15 and 0.1 in the same polygon — scouts run, they do not attack. An adjacent `warden` is about 73 percent of one in the same polygon. The previous 0.35 weight was very incorrect for heavy types.

### Caveats

- The docstring of `values` names the fire of the player as a `stalwart` source. The code removed that weight (`FIRED_W = 0.0`). The docstring is out of date.

- `battery_terms` and `values` calculate the same sums in two copies. A weight change must touch the two, and no check compares them.

- The previous 1.2 weight on damage in is gone. A player with damage plays safe, thus damage in points to LESS subsequent damage.

## The bass type

### Goal

`dominant_kind(aggro)` selects the enemy type that controls the bass lane. It selects the type with the largest total weight in the engaged enemies. Enemies in the same polygon weigh more.

### Invariants

- The weights are `THREAT_WEIGHT`, not the enemy-weight weights. They only select the bass lane.

- An enemy out of the player polygon counts at 0.35 (`OTHER_POLYGON_FACTOR`).

- An empty list returns `None`.

### Verification

- With one `warden` and 3 `mite` enemies in the polygon, the `warden` controls the bass lane (5.0 against 1.8).

- An empty aggro list selects `silence` for the bass lane.

### Implementation

For each type, the function sums `THREAT_WEIGHT[kind]` at hops 0 and `0.35 * THREAT_WEIGHT[type]` at other hops. It returns the type with the largest total. When two totals are equal, the type put into the map first is used.

### Caveats

- A type missing from `THREAT_WEIGHT` raises `KeyError`. The music input functions also raise `KeyError` for a type missing from their weight maps.

- Decision open (see `spec/open-questions.md`, item `AUDIO-UNKNOWN-ENEMY`): select the result for an incorrect or unknown enemy record. The alternatives are stop, ignore without text, or report it.

## `ChunkLane`

### Goal

`ChunkLane` is one voice of the mix. It extends the `ChunkedMusicPlayer` mechanism from `pyweek-28` to `N` lanes. A channel plays equal bar chunks in sequence through `queue()`, and the audio device keeps accurate time. Music changes through the selection of the variant queued for the next bar. A new selection before the boundary replaces the queued chunk. Thus a change in the middle of a bar starts on the next bar line that the player hears.

### Invariants

- Each lane holds its position in the form (`next_idx`).

- `tickfill` returns `True` only when this lane went across a boundary since the last call. An empty queue shows that the queued chunk started.

- `seek(idx)` selects position `idx` for the NEXT bar at the bar line, not in the middle of a bar.

- The lane volume is `gain * master_vol`, limited to 0..1.

### Verification

- A variant change in the middle of a bar sounds only from the next bar line.

- A new position selected in the middle of a bar starts the transition on the next bar line.

- With no state change, the chunks of one variant play in sequence, in a loop.

### Implementation

`start(key, master_vol)` plays chunk 0 of the variant, queues chunk `1 % n`, sets `next_idx=1`, and sets the volume. In `tickfill(sel_key)`, an empty queue shows that a boundary occurred. The function then increases `next_idx`, keeps the key, and queues chunk `next_idx % n` of the selection. If the queue is not empty but the selection changed, it replaces the queued chunk at the same position. `seek(idx)` keeps the position and queues the new chunk when a key is set. `set_gain` keeps the gain and sets the volume.

`n` must be more than zero. With `n == 0`, a modulo operation raises `ZeroDivisionError`. A missing selection key raises `KeyError`. A variant without the selected chunk raises `IndexError`. `seek(idx)` keeps the input value as `next_idx` and uses `idx % n` only to select the queued chunk.

The lane state also holds fade-out fields (`fade_ticks`, `fade_total`) and fade-in fields (`fadein_ticks`, `fadein_total`). The music system moves them each tick.

### Caveats

- With one chunk (`n == 1`), `start` queues chunk 0 behind chunk 0.

## `MusicSystem` construction

### Goal

`MusicSystem` is the continuous value engine and the chunk-queue music system. The input engine always calculates values, taps, and riser control. Stems on disk are necessary only for the mixer. `tick_clock=True` selects headless record mode.

Decisions move forward on the tick count and are the same in all runs, while no sound plays. Offline gain calculation supplies the audio. The live audio clock is in front of a record loop that runs slower than playback speed.

### Invariants

- `bar_s`, `n_bars`, and `sections` are read-only properties that read one `BankMeta` value. The write `self.sections = []` raises `AttributeError`. Form control cannot stop without an error message. Two previous defects caused that result.

- A bank with form data has a `bank.json`. `has_bank` is `True` only when the bank directory contains one or more `.wav` or `.ogg` files.

- The first `inputs` dict is complete. Thus `_select_content` reads each key during the start without a default.

- `override_vals`, when set, replaces the input calculation. That is the MANUAL mode of the music test tool (`tools/musicgen/instrument.py`) and of scripted scenes.

### Verification

- `MusicSystem(audio, bank_dirs=[...])` with a good bank starts and plays at the first update.

- A bad `bank.json` raises at construction, not in the session.

- With `tick_clock=True` no channel plays, and the tap stream logs each decision.

### Implementation

Construction keeps the audio object, flags, and bank directory list. Without a `bank_dir` value, it uses the first list entry or the module default `BANK_DIR`. It loads `BankMeta` when the bank has form data. It sets the initial filter values to `(1.0, 0.0, 0.0)` and sets the EMA rates.

It sets the lead crossfade, form position, and first lane channel number 4. It also sets the riser and tail voices. Last, it sets the low threat counts, ambush window, boss latch, gain state, lane dict, and legacy channel dict.

Before the first live call to `read_inputs`, the complete input dict contains level `"?"` and weapon `"?"`. It contains empty aggro and aggro-id lists. It also contains crowd 0.0, `firing_now=False`, hp 100.0, `tension=0.0`, and level class 1. All 4 rates are 0.0. `_ensure_started` selects and starts the first bar from these values. The same update reads the live session only after that start.

`_sim_lanes` adds lanes without channels for `tick_clock` mode from the stem names on disk. It always adds `drums`, `bed`, `holy`, `groove`, `wall`, `lead`, `lead2`, `bass`, and `boss`. Each lane keeps variants, a key, and a gain. For a bank without `overlay_boss`, the simulated `boss` lane contains only its added `silence` variant. The live lane builder does not add `boss` when the bank has no such stem.

Constants: `MAX_LANES` is 9, because two sets of lane channels run side by side in a bank change crossfade (set A at 4.., set `B` at 13..). `XFADE_BARS` is 2. `ROTATE_BARS` is 44, about 96 seconds at 110 bpm. Thus one bank does not play for a long time.

### Caveats

- `slam_riser` is a flag available to callers, and it is `True` during play. `tools/musicgen/slam_rank.py` sets it for each test variant.

- `_pending_sting` has no use. The code sets it `False` at construction and in `stop`, and no code sets it `True`. A test checks that it stays `False`.

## The mixer start

### Goal

`_ensure_started` starts the mixer only during the first update with a bank on disk. The audio object must have `_ready=True` in live and record modes. The path with form data cuts each stem into bar chunks and adds the lanes. It starts the first bar from the kept state.

### Invariants

- The start occurs only with `enabled`, a bank on disk, and a `_ready` audio object.

- All stems use one boundary list, with a rounded sample position for each bar. Position errors do not add up across bars. Chunk `k` has equal sample counts across lanes only if all stems extend through its end boundary.

- The riser channel is 22 (`4 + 2*MAX_LANES`), for the two lane sets. The tail channel of `holy` is 23.

- `_slice_bank` does not use the `sting` and `riser` stems.

- `_slice_bank` adds a `silence` variant with one chunk for each chunk length.

- The lane count must not go above `MAX_LANES` (an `assert`).

### Verification

- The first update after construction starts all lanes in one call and taps `music_bank`.

- All stems must extend through all boundaries in the boundary list. The lanes then stay aligned to the same sample positions across a long session.

- A bank without a `riser` stem starts with no riser voice, without error.

### Implementation

The method returns when `_started=True`, when the system is not enabled, or when there is no bank. Otherwise, it marks the system started. When the audio object is not `_ready`, the method ends there. In `tick_clock` mode with form data, it calls `_sim_lanes`, taps `music_bank`, and returns.

In live mode, it loads the optional `sting` and `stab` stems as full sounds. A bank without `bank.json` follows the legacy path. For a bank with form data, `_slice_bank` reads each stem other than `sting` and `riser`. It reads `.wav` first and reads `.ogg` when no `.wav` has that name.

It also cuts `stab` and `prayer_tail`. It changes mono data to stereo and does not check the sample rate. For `N` bars and initial stem length `L`, boundary `k` is `round(k * L / N)`, and boundary `N` is `L`.

Each subsequent stem uses the initial stem's boundary list. Samples after `L` are ignored. A shorter stem gives short or empty last chunks. A different sample rate receives no conversion and plays at 44100 Hz. A file with more than two channels follows the `EngineSound.from_array` operation. Without a cut stem, silence construction uses `limits=None` and raises `TypeError`.

`_lane_defs` connects the chunk names to lanes. It connects `drums*` to `drums`, `bed_t*` to `bed`, and `prayer` to `holy`. It connects `contempt` to `groove` and `stalwart` to `wall`. It also connects `lead_*` to `lead` and `lead2`, and `bass_*` to `bass`.

Last, it connects `overlay_boss` to `boss`. Each lane also contains `silence`. The code adds the `drums` and `boss` lanes only when the bank has their stems.

It calls `ChunkLane` on channel `_lane_ch_base + i` for each lane. It loads the optional riser stem on channel 22 at volume 0 and the `holy` tail voice on channel 23. The tail comes from the `prayer_tail` stem, not chunk 0. With chunk 0, the voice played twice at each return to bar 0. The method then selects a variant, calculates gains, starts each lane, and taps `music_bank`.

The `sfx` voices of the engine mixer are a different voice set by construction. No sound can remove a numbered channel, thus the channel allocation code of `pygame` is gone.

### Caveats

- Defect: the boundary list comes from the first stem in name sequence. A stem with a smaller sample count gives short or empty chunks for the last bars without an error message. Such lanes do not stay aligned to the same sample positions.

- When the audio object is not `_ready` at the first update, `_started` is `True` at that point. The system does not try the start again.

- Defect: record mode also must have `_ready=True`. An `Audio` object with no mixer has no simulated lanes. The same applies to a stub without that flag. It records no bar decisions. This does not obey the headless record mode goal.

- The lane count `assert` is not active with `python -O`.

## Lane variant selection

### Goal

`_select_content` names the variant that each lane queues next from the active state. The level class selects the `bed` variant. The weapon selects the lead voice. The bass type selects the bass variant, and the 3 values gate the other lanes.

### Invariants

- The selection dict comes from the lane dict. Thus each mixer lane receives a selection by construction. A missing `lead2` key previously raised `KeyError` in `_ensure_started`. Live play then continued without music or an error message.

- A selected variant that a lane does not hold falls to `silence`.

- `lead2` always selects `silence` here. Only the crossfade code writes it.

- The boss drum kit has a latch: on at applied `stalwart` 0.8 or more, off below 0.7. One limit with no latch turned the full kit on and off each bar when `stalwart` stays near it.

### Verification

- With `prayer` 1.0, `contempt` and `stalwart` 0.0, and an empty aggro list, only `bed` and `holy` are not `silence`.

- With `contempt` above 0.03, `groove` and `drums` come in. With `stalwart` above 0.03, `wall` comes in.

- At applied `stalwart` 0.88 the `overlay_boss` variant comes in, and the kit changes to `drums_boss` when the bank has one.

### Implementation

The limits read the filtered values `vals` (`p`, `c`, `d`) and the applied `stalwart`. `drums` plays above `max(c,d) > 0.03`, with the `drums_boss` variant when the latch is on. `boss` plays `overlay_boss` at applied `stalwart` 0.88 or more. `bed` plays `bed_t<tier>`, with the level class limited to 1..4.

`holy` always plays `prayer`. `groove` plays `contempt` above `c > 0.03`. `wall` plays `stalwart` above `d > 0.03`. `lead` plays `lead_<weapon>` above `max(c,d) > 0.05`. `bass` plays `bass_<kind>` from `dominant_kind`, or `silence`.

### Caveats

- The boss overlay limit (0.88) and the kit latch (0.8 on, 0.7 off) are not equal. The two come from different decisions, not from one requirement.

- An unknown weapon or enemy type falls to `silence` through the variants check, with no text line.

## Bar gains

### Goal

`_bar_gains` controls gain without kept programs (`v2`). The gain-change programs in `v1` moved too slowly during short combat. They did not set a new target when the target changed. Taps showed the `wall` at 0.47.

The increase speed follows the value change. An increase of `STING_RISE` or more applies the full `wall` target on this bar. Other increases occur across 2 or 3 bars and always use the active target. Decreases decrease gain gradually. `F003993` recorded a gain decrease that occurred immediately and sounded the same as use of the `NEXT` control.

### Invariants

- The increase for each bar is at most 0.35, or 1.0 when the value change comes to `STING_RISE` (0.35).

- While the value of a lane is live (above 0.15 at the gate), its gain floor holds: drums 0.5, `groove`, `wall`, and `lead` 0.4, bass 0.45. It is necessary that the player can hear small fights clearly. The gain change shapes the entry, and the lane sounds from the first bar.

- Falls use a glide factor of 0.65 for each bar (`FALL_STEP`). They go to the target when the result drops below 0.02.

- The `holy` voice does not step. At 0.3 or more, it increases by no more than 0.12 for each bar. It falls by no more than 0.08 for each bar. This is a slow fall, not a stop.

- `THE MONK IS NEVER BURIED`. The full mix `Gemini` listen check of 2026-07-17 checks this decision. The combat has the `holy` voice as counterpoint. Its target is the largest of `p**0.5`, `0.7*combat**0.5`, and the `war chant`.

- The `war chant` increases from `stalwart` 0.60 to the full 0.85 at 0.95. The 0.85 limit keeps the `monk` as `a defiant and EQUAL voice`. The chant must not include the lead melody. A start at 0.75 caused a step down in the middle of combat.

- The gain dict is complete by construction: one gain for each lane of the mixer. Callers index the dict with no default, thus a lane that is not in the dict raises `KeyError`, not 0.0.

### Verification

- An increase of `STING_RISE` or more puts the full `wall` target on one bar.

- A short contact with `mite` or `husk` below the floor gate (0.15) does not raise the drums. The 0.5 minimum does not apply. The drums can select their variants above a combat value of 0.03. They can then play at their calculated gain.

- In the full mix check the chant stays through the combat — no cycles out and in.

### Implementation

Targets: drums `0.9*combat**0.5`, `bed` `0.55 + 0.35*p`, `holy` as above, `groove` `c**0.5`, `wall` `d**0.5`, `lead` `0.9*combat**0.5`. Bass: `0.8*min(1, n/2)**0.5`, where `n` counts aggro at 1.0 in the same polygon and 0.4 other. `combat` is `max(c, d)` on the applied values. The change `dp` is the largest increase of `contempt` or `stalwart` since the previous bar.

For each lane the code applies its minimum gain only when its gate value is more than 0.15. A value at or below 0.15 does not set the lane to no sound. It only removes the minimum gain. The lane can play at its calculated target when its selected variant is not `silence`.

The code applies the increase limit or fall glide against the kept live gain. It limits the result to 1.0. The boss lane uses a different gain: `0.9 * limit((applied stalwart - 0.88)/0.10)`. The result contains each mixer lane, with 0.0 for a missing lane. The crossfade fills `lead2`, which starts at 0.0.

### Caveats

- The riser does not follow increases. That was the previous defect: the 8-second flat noise of `F002718`. The riser uses one playback envelope that `update` moves forward.

- A previous read of the same polygon state used the opposite test for a long time. The aggro count here reads `hops == 0` correctly.

## Form control

### Goal

The form follows the combat. Boss contact at `Stalwart` 0.88 or more pulls the form to the `peak` section and loops it. A dated decision selects the hardest music for this condition. While combat is active, the form stays in combat material. In `F002291`, movement through `outro` into `intro` stopped the chant during combat.

Deep low threat returns to `vigil` when the mix gain is low. The riser starts before each peak transition and ends on the target bar start. The engine schedules this transition and knows its target time. A riser that starts after combat starts cannot lead that combat.

### Invariants

- A transition starts only when `form_idx % n_bars` is divisible by 2.

- The combat sections are `entry`, `develop`, and `peak`. Above `max(c, st) >= 0.35` the form stays in them, and it loops `develop` at the section end when `stalwart` is below 0.85.

- The low threat return to the `vigil` has two conditions. Low threat must hold for 4 boundaries. Also, the glide of each heavy lane must end with live gains at 0.25 or less. A transition in the middle of a release was `F003993` and `F005171`. The entry cut read as a push of the `NEXT` control.

- Deep low threat LOOPS the `vigil`. A walk out of the `vigil` was the `Lama` cycle: each return started a new entry fade.

- A peak transition arms the riser for a swell of 2 bars. It holds the transition through the swell. It then starts the transition AS the bell hits.

- A transition that goes into death in the swell (`stalwart` below 0.75) is canceled, and the riser fades fast. `A swell to nothing is worse than no swell.`

- A loop steer causes no seam. The tap identifies it with a `~s` suffix. The mixer must NOT apply an entry fade to it.

### Verification

- A boss contact transitions to the peak after the riser swell of 2 bars.

- During combat, the form position does not go into the `outro` or the low threat sections.

- After combat, the form returns to `vigil` once and does not return while a heavy lane sounds above 0.25.

- A canceled transition shows a fast riser fade and no transition.

### Implementation

`_steer_form` runs at a boundary and returns `(target, "jump")`, `(target, "loop")`, or `None`. Low threat is `stalwart` and `contempt` at 0.25 or less with `prayer` at 0.8 or more. The code counts low threat boundaries in sequence.

At `stalwart` 0.88 or more, the form can transition if a `peak` section is available. It can transition from each second position that is not in the peak. At the last peak bar, it loops to the peak start. During combat, it loops into `develop` or `entry` when the position goes out of the combat sections. It also loops at the end of `develop` below `stalwart` 0.85.

In low threat, the last `vigil` bar loops back to the start of `vigil`. `ritual` replaces `vigil` only when no section has the name `vigil`. A return transition can start only when `pos % 2 == 0` and the mix gains are low. Also, 4 or more boundary calls in sequence must report low threat. If these conditions do not agree, the last bar of the active section loops. A position in no section has no loop requirement.

`_gate_jump` receives the steer. The first applicable call sets the count to 2 and returns no steer. The next call changes it to 1 and returns no steer. The call after that changes it to 0 and returns `(target, "jump")`.

Thus the active form continues through two boundary intervals before the transition. A `stalwart` fall below 0.75 after the count change cancels the transition. It also starts a fast riser fade. On that call, the function returns the new steer from the same bar.

A new peak transition waits for 2 bars. It sets the riser envelope to 2 bars at a peak of 0.9 and plays the riser sound from its start. A steer that is not a peak transition goes through without a change.

### Caveats

- On the cancel path, `_gate_jump` returns the steer given to it on that same bar, without change. Thus a loop steer of the same bar applies.

- `vigil` falls to `ritual`, and `develop` falls to `entry`, when a bank uses those section names.

## The lead crossfade

### Goal

A weapon change crossfades the two lead lanes SLOWLY, with a hold at 50/50. The decision dated 2026-07-16 sets this operation. A player who changes between `rail` and `shotgun` parks the two leads on together.

### Invariants

- The two gains are `cos(x*pi/2)` and `sin(x*pi/2)` times the lead gain. Their squared gain sum equals the square of the lead gain. Their amplitude sum is not constant. Its maximum is `sqrt(2)` times the lead gain at `x=0.5`.

- The crossfade steps 0.25 for each bar.

- The first move to or across 0.5 holds at 0.5 for one bar.

- A new weapon replaces the far side of the fade, not the near side.

### Verification

- One weapon change uses about 4 bars end to end, with the hold in the middle.

- Change between two weapons fast: the fade stays at 0.5 and the two leads sound.

- The sum of the squared gains stays equal to the square of the lead gain across the fade.

### Implementation

`_lead_split(weapon_key, base_gain)` runs once for each bar. A key equal to lead A sets a target of 0.0. A key equal to lead `B` sets a target of 1.0. A new key goes into the empty slot or replaces the slot from which the fade moves. The fade then moves to that key.

A change on a side that the player can hear taps `music_int` with the lane and the two keys. The fade holds for one bar on its first move to or across 0.5. It returns `(key_a, gain_a, key_b, gain_b)`, with `silence` for an empty slot.

The step is 0.25. On its first move to or across 0.5, the fade stops at 0.5. It also sets the dwell flag. On the next move across 0.5, the code clears the flag and continues by 0.25.

When the target equals the active position, the code clears the flag. At 0.5, a new unknown key replaces lead `B`. It sets the target to 1.0 because the `<= 0.5` path is used.

### Caveats

- With no weapon key (low threat), the fade holds its position, and the lead gain (usually 0) multiplies the two sides.

- Decision open (see `spec/open-questions.md`, item `AUDIO-CROSSFADE-LAW`): select if the crossfade must keep squared gain, amplitude sum, or loudness for correlated lead stems.

## The tick update

### Goal

`MusicSystem.update(session)` runs each tick. It is the input engine. Its work includes the death stop, the EMA rates, and the input calculation. It also includes the value filter, ambush slam, riser envelope, and value taps.

The music is the `Commando` state, and death stops it immediately with the chant. Only death stops `Prayer`, as set by the decision dated 2026-07-17.

### Invariants

- When hp first changes to 0 or less, the system taps `music_halt` and stops all sound. It stays without sound until hp increases above 0.

- The EMA time constants are 3 seconds for `influx`, damage, and kills, and 1 second for `fire_duty`.

- The filter time constant is one bar. A contact with `mite` or `husk` of 0.3 seconds tops near 0.1 and decreases before the boundary. Combat that continues comes to about 63 percent in one bar.

- The ambush slam fires only after 2 seconds or more with no engaged enemy. The raw increase must be 0.30 or more, or `influx` must be 3.0 enemies each second or more. The test occurs in the 0.3-second window after aggro starts. A heavy type must be in the player polygon, and applied `Stalwart` must be at most 0.25. A slam bypasses the filter interval for an increase.

- A threat that the player sees before contact increases through the filter, as all other input does. A window of one bar let a far `spitter` open it. A slam then fired 1.8 seconds into combat in view, in a record from 2026-07-17.

- `override_vals` replaces the input calculation and the filter.

- The riser envelope holds a FLAT gain. The stem contains bell audio, and its samples start at the end. The stem has a complete shape. Only a canceled transition fades it, at 0.90 for each tick.

- With a tap attached, the raw and filtered values tap at 10 Hz. The 3 largest input calculation rows and the mix state also tap.

### Verification

- Death stops all music in one tick, also the chant.

- A `warden` contact after 2 seconds with no aggro slams the `wall` in on the next boundary.

- The same `warden`, seen before contact, increases the music values across bars.

- A record with a tap holds `music_valsraw`, `music_valslp`, and `music_dbg` rows at 10 Hz.

### Implementation

The method returns when it is not enabled. It processes the death stop, calls `_ensure_started`, and then reads the inputs and `session.music_tier`. It removes `aggro_ids` from the inputs and changes it to a set. `new_aggro` counts ids that were not in the previous set. `dmg` is `max(0, previous_hp - hp)`, or 0 on the first update. `kd` is `max(0, kills - previous_kills)`.

For `influx`, damage, and kills, each tick applies `ema += (target - ema) / 180`. Each target is the tick count times 60. Fire applies `ema += (target - ema) / 60`. Its target is 1.0 when `firing_now` is set and 0.0 if not. The 4 input rates use `round(value, 4)`.

An update with aggro after 120 ticks or more with an empty list sets `_ambush_window` to 18. The same update decreases it to 17 before the test. Each subsequent update decreases it by 1 while it is more than zero. The test must have a remaining value more than zero.

The test also must have one of two rate conditions. The raw `Stalwart` increase must be 0.30 or more, or the `influx` EMA must be 3.0 or more. A hop-0 type must have `DANGER_CO[type] >= 1.9`. Applied `Stalwart` must be at most 0.25. A result does not let filtered `Stalwart` fall below raw `Stalwart`. It sets filtered `Prayer` to at most raw `Prayer` and sets `_slam_now=True`.

Without an override, the filter first calculates `new = previous + (raw - previous) / (60 * bar_s)` for each value. It then applies the ambush changes and keeps each result rounded to 0.001.

With an override, it gives the override object directly to `vals` and `_lp`. It does not limit, apply rounding, copy, or check the type. The value taps then fire, and the riser envelope moves forward. At the end, the update calls `_update_rich` when lanes are available. When no lanes are available, it calls `_update_legacy`.

### Caveats

- Defect: no code sets `_riser_half_snd`. This 0.5-bar bell audio has the opposite sample sequence. It does not sound during the slam. Only the `music_riser2` tap fires. A source comment identifies this swell as the cause of the `wall` gain that applies immediately. `PERIHELION` does not play the sound.

- Only `warden` (20.0) and `flicker` (1.9) agree with the heavy gate `DANGER_CO >= 1.9`. A `brute` ambush (1.0) does not slam.

- `read_inputs` runs after `_ensure_started`. Thus the selected variants of the first bar come from the complete start inputs. They do not come from the session.

## Bank-with form data mode, record path

### Goal

In record mode, the bar count comes from the tick count and no sound plays. The tap stream shows each bar decision. `tools/playtest/mkvideo.py` calculates the same mix offline. The tap stream is the only source. It contains the position, selected variant, and gain of each lane. It uses `~f` for a last fade bar.

### Invariants

- The bar index is `int((tick / 60) / bar_s)`. For nonnegative ticks, `int` removes the fractional part.

- After 44 bars, the bank change waits for almost full `Prayer` in the filtered values. `Prayer` must be 0.95 or more. Each combat value must be at most 0.15. This decision is necessary: `Never switch tracks when tension is high`.

- The bar steps agree with the live path after the bank-change check. Each bar applies values, boss state, form steer, and stab position. It then calculates selections, gains, the lead crossfade, and the last fade state.

- The boss release latches at applied `stalwart` 0.75 or more and fires below 0.3. The previous test of one bar could not fire through the filter. No record contains `music_rel`.

### Verification

- Two recordings of the same session give equal tap streams.

- The `music_bar` rows apply each lane at each bar.

- A bank change in a record occurs only on a low threat bar.

### Implementation

On a bar change, the bank-change check uses the filtered values before they become the applied values. At 44 bars after `_bank_bar0`, it checks the values. `Prayer` must be 0.95 or more. The other two values must be at most 0.15. It then moves `bank_dir` to the next bank.

It loads `BankMeta` again and replaces the simulated lanes immediately. It sets `_bank_bar0` to the total bar and sets the form to 0. The applied values then copy from the filtered values. A change sends a `music_vals` tap. The boss latch and release run, with `music_rel` and a necessary sting on the release.

The form steer goes through `_gate_jump`, with `music_jump` taps. The stab fires at `stalwart` 0.88 or more when `form_idx % 4 == 0`. The code calculates the selection and gains, and the lead crossfade fills `lead` and `lead2`.

Lane state without audio: a boss release marks each heavy lane `~f` for one last fade bar. A lane that changes to `silence` glides at 0.65 for each bar until 0.15. It then uses its one last fade bar. `drums` exits clean on the bar line. A variant change between two variants that are not `silence` taps `music_int`. The `music_bar` tap writes the full row.

### Caveats

- The sim lanes are objects without channels. The last fade fields go on them as new attributes at run time.

- A bad `bank.json` in a subsequent bank raises in the middle of a record operation. The loader checks it and has no defaults.

- Defect: record mode has no 2-bar overlap at a bank change. It replaces the previous simulated lanes on one bar. The tap stream contains only `music_bank` and the new `music_bar` rows, without the subsequent live bars from the previous bank. Thus the offline result cannot calculate the necessary live overlap from these rows.

## Bank-with form data mode, live path

### Goal

The audio is the clock. Queue use on the `bed` lane marks a boundary. Gains step only at boundaries. The live path with form data has no free loop and no tick counter bar count. Between boundaries, the queue of each lane stays full. Last fades, entry fades, and the `holy` gain glide move each tick.

### Invariants

- Values apply, gains move, and the form steps only at a boundary that the player heard.

- The requirement for the last fade comes from the 2026-07-16 decision: no hard stops back to low threat. A lane with a selection that turns `silence` first glides down at 0.65 for each bar. Then it plays an additional bar with a fade to zero across it. The fade is the release.

- The live silence gate agrees with the record path (glide, then a last fade at 0.15 or less). The previous gate at 0.02 let live lanes hold at 0.05 without end, while recordings cut clean.

- `drums` exits on the bar line without a fade. The `Gemini A/B` check found that a gain fade on active drums sounds the same as a manual volume change. Long voices use fades, and drums stop at the boundary.

- A boss release fades each heavy lane across one bar while the release sting sounds. `holy` is not a heavy lane: `Prayer` is the through line, and only death stops it.

- A transition across sections applies an entry fade of one bar to each lane other than `holy` and `bed`. A loop steer has no entry fade. In `F003993`, a zero chant gain during entry caused a hard `Prayer` stop.

- The `holy` voice does not step in the middle of a music line. A gain change from the input calculation glides across the full bar. An entry from silence keeps its attack.

- On a `holy` position change, the tail channel plays the sound that the previous position selected for the next bar. The code starts no new tail while `tail_channel.get_busy()` is set.

- When a transition starts the new position, the tail starts at the set `holy` gain. It calls `fadeout(int(0.5 * bar_s * 1000))`. At the same time, the new `holy` chunk starts at zero. It increases to the same gain across 0.5 bar. The engine fade is linear and stops the tail when that 0.5 bar ends.

- When the position moves from the last bar to bar 0, the `prayer_tail` stem continues into bar 0 at the lane gain.

- A gain step of 0.4 or more comes up across 0.5 bar, not across zero time. This fade does not occur on a slam bar. There the wall comes with no fade.

- The `music_bar` tap writes the full bar decision for the offline gain change.

### Verification

- An enemy-weight change in the middle of a bar sounds at the next bar line, not in the bar.

- The combat release glides down, then one last fade bar, then silence — no cut.

- The drums stop on the boundary.

- The chant continues across a form transition without a level drop. The tail voice plays across the seam.

- When no bank-change overlap is active, offline gain changes calculated from taps equal the live lane decisions. The bank-change defect prevents full offline/live equality during the overlap window.

### Implementation

During each tick, the riser channel volume follows the envelope. Selection runs, and a copy keeps its result before the last fade changes. The last fade code keeps the previous variant for a lane during its fade. `tickfill` runs on each lane, and a boundary reported by the `bed` lane marks the bar line.

During a bank change, the lanes of the previous bank keep their queues full while their fades continue. They stop when the window closes. The `holy` glide, last fades, and entry fades move forward each tick.

At a boundary, the bar and form positions move forward and the armed `holy` tail fires. For a transition entry, the code also applies a 0.5-bar fade-in from 0 to the `holy` lane. This crossfades against the tail, and the summed voice does not fall. The tail for a return to bar 0 plays when the gain at that return is above 0.1.

Then the applied values copy, and the boss latch and release run. The steer runs, with `lane.seek` on each lane and entry fades on a transition. The `holy` tail arms on a steer that changes the `holy` position, when no tail sounds. The stab fires at `form_idx % 4 == 0` at `stalwart` 0.88 or more. The gains calculate, and the lead crossfade fills the two lead lanes and queues them again.

For each lane at the boundary, the boss-release fade occurs first. Its duration is one bar, and it sets live gain to 0. Next are the clean drums exit and the silence gate. The silence gate has a glide and then a last fade.

Then come the `holy` glide, the floor `0.65 * gain` for the fall glide, and `set_gain`. The `holy` glide uses the full bar. Last is a fade-in of 0.5 bar on a gain step of 0.4 or more. The `music_bar` tap writes the position and each lane as `name:key:gain`. It uses `~f` on a lane that fades.

### Caveats

- One fade-in comment states that the slam also receives an entry fade. But the code does not apply that fade on slam bars (`not slam_bar`). The `slam_riser` comment states that this is correct because the swell causes the wall to occur immediately. The two comments do not agree, and the bell does not sound (see the `_riser_half_snd` defect).

- The code finds boundaries only on the `bed` lane. That lane is always available and plays `silence` chunks when no bed variant fits. Thus the clock stays stable.

- A form change while the tail channel is active does not arm a new tail. The new position continues.

- Decision open (see `spec/open-questions.md`, item `AUDIO-HOLY-TAIL`): select the tail response to a new form change. Replace it, queue it, or do not start the new tail.

## Bank change

### Goal

A bank can change while a level is active. This is the 2026-07-16 decision: `the engine mixing and matching them`, not a flag.

After each 44 bars, the engine moves to the next album bank on a bar line. The boundary bank change does not decode the full bank in that frame. A second thread decodes the next bank about 10 bars before the change. During each tick, the primary thread changes one stem into sounds. The change restarts the lanes at one boundary.

A melody change between banks must not hard cut. The lanes of the previous bank play their next bars with a fade-out of 2 bars. The new lanes fade in on the other channel set.

### Invariants

- The decode thread does not touch the mixer. It only reads data with `soundfile` and numpy. The primary thread changes one stem into sounds during each tick.

- The bank change uses the same numeric low threat limits as the record path. It reads the values applied at the boundary. `Prayer` must be 0.95 or more, and each combat value must be at most 0.15.

- The first lane channel number changes between 4 and 13 at each bank change. Thus the two lane sets run side by side in the crossfade.

- A decode failure sets the bank change state fully back and writes stderr. A subsequent window tries again — the bank change does not stay broken for the remaining part of the session.

- The form of the new bank starts at bar 0. Its sting, stab, riser, and tail sounds replace the previous sounds.

- The offline mixer must calculate the same overlap from the taps. Defect: the active record path does not include the previous lanes during a bank change. Thus it cannot calculate the live overlap of two bars.

### Verification

- A long low threat session does a bank change near bar 44, on the bar line. The player can hear an overlap of 2 bars, and no cut.

- A session in constant combat does no bank change.

- Break the decode (a bad file): the bank change tries again in a subsequent window, and the session continues.

### Implementation

`_rotation_tick` runs each tick in live mode with more than one bank. At bar 34 or more, it can start the decode thread. It starts only when `_decode_thread`, `_decoded`, and `_next_chunks` are all `None`. `_decode_bank` loads checked `BankMeta`. It reads each stem but not `sting` and `riser`.

It cuts on the same boundary list and adds the silence chunks. It then sends a list of names to the primary thread. The primary thread removes names from the end of the list. It changes one stem into `EngineSound` chunks during each tick. If conversion is not complete at bar 44, the bank change waits.

The thread catches each error from `_decode_bank`. It reports `[music] rotation decode failed: <error>` and sets `_decoded`, `_next_chunks`, `_next_names`, and `_decode_thread` to `None`. Because the bar stays at 34 or more, the next tick can try again. The primary thread calls `EngineSound` for each chunk. An error during that call is not caught here.

During `_switch_bank`, sting, stab, and riser reload use the same `except` block. It catches each error and reports `[music] rotation sting/riser reload failed: <error>`. Tail reload occurs after that `except` block and can raise.

`_switch_bank` runs on a low threat boundary at bar 44 or more, when the chunks are complete. It sets the new directory and `BankMeta`. It applies a 2-bar fade to each audible lane and stops each other lane. It keeps the previous lane dict for the overlap window. Then it changes the first channel number and calls the live lane builder.

It selects, calculates gains, and starts each lane with a fade-in of 2 bars from volume 0. It loads the sting, the stab, the riser, and the tail again. It sets the bar and form positions to 0, clears the decode state, and taps `music_bank`.

### Caveats

- No code frees a sound. Each bank change loads a full bank of chunks into the engine mixer. The sounds of the previous bank stay loaded. Defect: engine sound memory increases without limit across bank changes in one level. `EngineSound.free` is available, and only the tools call it.

- `_switch_bank` calls `_select_content` twice. The code drops the first result, and a comment notes it.

- `App.rotate_music` starts a new `MusicSystem` for a level change. It does not use the bank-change operation of the active system. That path cuts the first bank again and causes the same memory increase.

- The bar count `assert` in `_switch_bank` is not active with `python -O`.

- Defect: `stop()` does not cancel the decode thread and does not clear `_decoded`, `_next_chunks`, `_next_names`, or `_decode_thread`. A thread from the previous state can set its result after the stop. A restarted system can continue to change or use that result. The code has no state number check or other check for a result from a previous state.

## The legacy mixer

### Goal

A bank without `bank.json` plays the legacy mixer: the `prayer`, `contempt`, `stalwart`, and `riser` loops with value gains. No chunks, no form, no lanes.

### Invariants

- Each loop plays without end from the start, and only its volume moves.

- The gains: `value**0.5` for the 3 voices, `riser_gain * 0.85` for the riser, all times 0.8 and the master.

- An increase applies immediately. A fall glides at `dt / (1.5 * bar_s)`.

- The bar count comes from the tick count, and the applied values change on the bar.

### Verification

- A directory with only `prayer.wav` plays only the `prayer` loop.

- Combat lifts the `stalwart` loop in one bar.

### Implementation

`_start_legacy` loads each of the 4 loop files that are on disk. It plays each on channels 4 through 7, with loop count -1 and volume 0. `_update_legacy` calculates the bar from the tick count. On a bar change, it applies the values with a `music_vals` tap. It calls `_apply_legacy` each tick. `_apply_legacy` moves each gain to its target and writes the volumes.

### Caveats

- `_apply_legacy` runs with the default `dt` of 1/60 seconds. This is correct at 60 ticks each second.

## Music tap records

### Goal

Each music tap uses the audio callback contract `(kind, detail, volume, pan)`. Music always sends pan 0.5.

### Invariants

- Each tap has 4 fields in callback sequence.

- The `kind` selects the record grammar. The `detail` field has no escaping mechanism for `:`, `>`, `|`, `,`, or `=`.

- Tap emission records a music decision when audio is muted or no sound sample is available.

### Verification

- Record a run. Make sure that each music tap has 4 fields and pan 0.5.

- Parse each `detail` value with the set format for its `kind`. Include an empty row group and a `music_bar` variant of `None`.

- With muted audio, decision taps stay in the record.

### Implementation

The records with constant fields are `("music_bank", bank_directory_name, 1.0, 0.5)`, `("music_halt", "death", 1.0, 0.5)`, `("music_rel", "boss_release", 1.0, 0.5)`, `("music_stab", "stab", 1.0, 0.5)`, and `("music_sting", "sting", 1.0, 0.5)`. A transition uses decimal target text. A loop uses the same text with `~s`. The two use `kind="music_jump"` and volume 1.0.

`music_valsraw`, `music_valslp`, and `music_vals` use `"p.ppp,c.ccc,s.sss"` and volume 1.0. `music_riser2` uses `detail="0.70"` and volume 0.7. `music_riser` uses its gain with 2 numeric characters after the decimal point as its `detail` and volume. Its end record uses `detail="0.00"` and volume 0.0.

`music_int` uses `"lane:previous>new"` and volume 1.0. The lead lanes use `lead` or `lead2` as the lane name. `music_bar` uses `<form>|<lane>:<variant>:<gain>|...`, with lane names in sorted sequence and gain with 3 numeric characters after the decimal point. A variant with a last fade has the suffix `~f`. The record path can write the Python text `None` as the variant before a lane receives a key.

`music_dbg` uses `st:<three rows>|ct:<three rows>|agg:co=<n>,adj=<n>,far=<n>|xf:<x.xx>|form:<n>`. Each row is `name=value` with one numeric character after the decimal point. Rows go from high value to low value and keep input sequence for equal values. A `,` character is between adjacent rows. A group with no rows is empty.

### Caveats

- The tap `detail` fields use `:`, `>`, `|`, `,`, `=`, and the suffixes without an encoding requirement. File names, lane names, and enemy types do not contain these characters.

## Stab and sting

### Goal

A mark, not a beat. The stab is a hit at `form_idx % 4 == 0` while the boss lives. It uses a different sample. A bell in each 4 bars above a full mix read as `sample spam`.

The sting is the release chord and usually sounds no more than once in 8 bars. The boss release always sounds because it is the end chord. A previous raw-increase filter fired the sting for each new enemy group. This caused 81 stings in a 259-second run.

### Invariants

- The stab fires only at applied `stalwart` 0.88 or more, at `form_idx % 4 == 0`.

- The sting rate limit lets one sting occur in each 8 bars. A call with `force=True`, used for a boss release, bypasses the limit.

- The stab plays on channel 2 at 0.7 master. The sting plays on channel 3 at 0.8 master.

- The two functions always tap, also when no sample is loaded.

### Verification

- Combat with a boss has one stab in each 4 bars.

- A boss release always sounds, also in the 8 bars after a sting.

- Two stings do not sound nearer than 8 bars, but the release sting can.

### Implementation

`_stab_now` taps `music_stab` and plays the stab sample when the bank contains one and lanes are active. `_sting_now(force)` lets its first call run because the missing previous tick reads as -99999. Without `force`, it returns when `boundary_tick - last_sting_tick < 8 * bar_s * 60`. Thus equality lets a sting occur.

A call that the limit lets through keeps the boundary tick and taps `music_sting`. It plays the sting when the bank contains one and a mixer path is active. The play and volume block catches each error without output. The tap occurs before that block.

### Caveats

- The rate limit clock is the boundary tick, not the wall clock.

## Stop and music time

### Goal

`stop()` stops all music and lets the start procedure run during a subsequent live update. It clears only the playback fields listed below and does not set all state to its initial value. `music_time(tick)` has the goal to return seconds of music time for synchronized visuals. The items below give its operation before the start, while stopped, and at boundaries calculated from ticks.

### Invariants

- After `stop`, no music channel sounds.

- `stop` clears `_started`. Thus a subsequent update runs the start procedure again. It does not set all bar or decision state to its initial value.

- In live form data mode, `music_time` calculates from the last boundary that the `bed` queue reports. The same formula is used in all other states, also where there is no heard boundary.

### Verification

- Death stops all music channels. After respawn, a form data mixer starts its lanes and bar clock at bar 0. Its kept form, value, and decision state do not agree with those of a new `MusicSystem`.

- In live form data mode, examine `music_time` before and after a heard boundary. It uses the new bar index and active tick at the reported boundary. Modes that calculate boundaries from ticks can have a small step. This occurs because an integer tick usually does not agree with the fractional bar duration.

### Implementation

`stop` tries to stop each active lane channel and then clears `_lanes`. It tries to stop each previous lane and sets `_old_lanes=None`, but does not set `_old_ttl` to its initial value. When a sting or stab object is available, it tries to stop channels 2 and 3. It sets `_pending_sting=False`, `_riser_env=0`, and `_riser_gain=0`.

It tries to stop the riser and tail channels. It sets `_holy_tail_arm=None`, `_holy_glide=None`, and `_riser_ch=None`. It tries to stop each legacy channel and clears `_channels`, then sets `_started=False`. Each block catches each error without output.

It does not clear the loaded sting, stab, riser sound, tail sound, or tail channel. The clear of `_lanes` drops the Python references to active chunk objects. But no call frees their sound ids from the engine mixer. The code keeps the form position, bar position, boundary tick, filtered values, applied values, and EMA state.

The lead slots, lead fade, boss latch, low threat count, and ambush state also stay. The code keeps the bank index, bank directory, decoded bank-change state, conversion state, decode thread, and `_old_ttl`.

`music_time` always returns `bar_idx * bar_s + (tick - boundary_tick) / 60`. It has no different branch for live, record, legacy, state before start, or stopped state. Construction sets the two kept tick values to 0. Before the first start, the function returns `tick / 60`. After `stop`, it keeps the last bar index and boundary tick. It continues from that kept time until a different path changes them.

In `tick_clock` record mode, `_update_rich` updates `_boundary_tick` at each bar change that it finds. At tick 0, that path keeps boundary tick 1 (`session.tick_count or 1`). As a result, `music_time(0)` immediately after the first update returns `-1/60`.

Subsequent record boundaries use the active integer tick. The result of `bar_s * 60` is not usually an integer. A new bar index can move the boundary forward by more or less than 1/60 second.

Legacy mode also calculates its bar index and boundary tick from the absolute session tick. The first `music_time` value uses this session-wide tick grid if the system starts after tick 0. It does not give the time since the mixer started. A form-data restart sets `_bar_idx=0` and `_boundary_tick` to the restart tick. A legacy restart immediately calculates them from the absolute session tick again.

### Caveats

- `stop` frees no sound. The chunks of the bank stay loaded in the engine mixer.

- Defect: `stop` does not end a live decode thread or discard its result. See the bank-change defect.

- Defect: the tick-0 initialization in `tick_clock` mode causes `music_time(0)` to be negative by one tick immediately after the first update.

- Defect: before start, `music_time` increases when no music is active. After `stop`, it continues from kept state. Thus it does not always mean elapsed audible music time when the system is not active.

- Defect: record and legacy boundaries calculated from ticks can cause a small discontinuity in `music_time`. Legacy mode also does not measure from engine start as its source docstring states.

- Defect: `stop` does not set the decision state to its initial value. A form-data restart sets its lane bar clock to 0. But it keeps the form, values, lead state, latches, and previous rate state. A legacy restart uses the absolute session bar again.

- Decision open (see `spec/open-questions.md`, item `AUDIO-RESET-STATE`): select which music state must return to its initial value. Also select which state must continue after death or `stop`. That item gives an initial value for transient playback and decision state before a subsequent change. It does not give the active operation above.
