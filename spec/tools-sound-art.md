---
This warm-start specfile describes the units in `tools/soundgen/` and `tools/artgen/` as written.

Some code comments call the user the "director." In this file, the two terms refer to the user.
---

# Tools — sound and art pipelines

## `synth.py` — conventions and synthesis functions

**Goal.** This module gives the sound bank functions that use only `numpy` and the `wave` module. It uses no other audio library. It renders before runtime. Its algorithms have a small number of steps and a small number of known defects. Runtime speed has lower priority.

**Invariants.**

- A correct signal is a one-dimensional, mono `numpy` array with full scale `+/-1.0`. An array with more than one channel from `read_wav` is not a correct signal in this contract. The caller must select one channel or mix the channels to one dimension. It must do this before it gives the array to a signal function.

- The sample rate is `SR = 44100` unless a caller gives a different rate.

- Functions that return audio signals use floating-point `numpy` arrays. Most signal functions return `float32`. `linear_ramp` and `pitch_env` return `float64`. Helper functions also return scalar numbers, paths, tuples, or `None` as specified by their interfaces.

**Verification.** A signal-function call does not change its input array or external state. Calls with the same input values give the same output. Noise is the same on each call only when the caller supplies a seed. A call with known input checks the output length, type, and value range.

**Implementation.** `samples(dur_s, sr)` returns `max(1, round(dur_s * sr))`. `time_array` returns sample times in seconds. `_match_len(arr, n)` truncates a long array at `n`. It extends a short array with its edge value and replaces an empty array with zeros.

`db_to_lin` and `lin_to_db` change between `dB` values and linear gain. Before it applies `log10`, `lin_to_db` clamps its input to `1e-12` or more.

**Caveats.** None.

## `synth.py` — waveforms and noise

**Goal.** Waveform and noise sources accept a scalar frequency or a frequency array. A frequency array lets each source give a sweep.

**Invariants.**

- Each source accepts `freq` as one value or as an array with one value for each sample.

- Each noise function accepts a `seed`. The same seed gives the same noise.

**Verification.** A frequency-array input gives a sweep. The frequency energy of each noise type has the specified slope.

**Implementation.** `_freq_phase` changes frequency to phase. For a scalar value, it multiplies time by `2 * pi * freq`. For an array, it uses `cumsum` on the values and divides by the sample rate. `sine` applies `np.sin` to that phase plus `phase0`.

`saw`, `square`, and `triangle` build their phase with `cumsum`. `saw` maps the phase fraction to a `sawtooth` in `-1..1`. `square` compares the phase fraction with `duty` (default `0.5`) and outputs `1.0` or `-1.0`. `triangle` folds the phase fraction to a triangle shape.

`_colored_noise(n, sr, alpha, seed)` makes noise with energy that follows `1 / f^alpha`. For nonzero `alpha`, it shapes the `FFT` of random samples with `1 / f^(alpha / 2)` and sets the `DC` element to zero. For `alpha=0`, it uses random samples from a normal distribution directly and does not remove their sample mean. It then scales the result to a `peak` of `1.0`. `white_noise`, `pink_noise`, and `brown_noise` call it with `alpha` `0`, `1`, and `2`.

**Caveats.**

- `saw` and `square` are not band-limited. High frequencies fold back into lower frequencies. The module accepts this for short runtime sounds.

- An output with `alpha=0` can have a nonzero `DC` mean because that branch does not clear the `FFT` `DC` element.

## `synth.py` — envelopes and fades

**Goal.** Envelope functions control how a signal's level starts, holds, and ends as time increases.

**Invariants.**

- `apply_env` multiplies a signal by an `envelope`. It cuts the two arrays to the shorter length.

- `fade_in` and `fade_out` copy the input. They do not change the array of the caller.

**Verification.** The `envelope` arrays have the correct length. The end value of `env_exp_decay` is near `end`. `fade_out` ends at zero.

**Implementation.** `env_exp_decay(dur_s, sr, tau, start, end)` returns `start * exp(-t / tau)`. When `tau` is `None`, it calculates a value with a minimum of `1e-4`. This value makes the curve get to `end` at `dur_s`.

`env_adsr(dur_s, attack, decay, sustain_level, release)` builds 4 phases. They are a linear change from `0` to `1` and a linear fall from `1` to `sustain_level`. A hold at `sustain_level` and a linear release to `0` follow. Each phase length comes from `samples` and is limited to make the phases fit in `dur_s`. The hold receives the remaining samples. The function adds zeros or cuts the result to the full length.

`linear_ramp` returns a straight line from `start` to `end`. `pitch_env(dur_s, start_hz, end_hz, curve)` returns a frequency sweep. When `curve="exp"` and the two endpoints are positive, it uses `start * (end / start)^t`. Otherwise, it uses a straight line. `fade_in` and `fade_out` multiply the first or last `dur_s` seconds by a linear gain change.

**Caveats.** None.

## `synth.py` — filters, `distortion`, delays, and `reverb`

**Goal.** Filters and effects give each sound its character. They give less energy at high frequencies, `distortion`, vibrations after hard object contact, and a sense of space.

**Invariants.**

- `biquad` accepts a scalar frequency or an array. An array lets a filter sweep sample by sample.

- `delay_fx`, `comb_filter`, `allpass_filter`, and `reverb` keep state in local buffers only. They do not change the input or external state. The same input values give the same output.

**Verification.** A filter sweep follows its frequency array. The `reverb` output is longer than its input by `tail_s`.

**Implementation.** `one_pole_lowpass` uses a smooth filter in a Python loop, with `a = exp(-2 * pi * cutoff / sr)`. A filter frequency at or below `0` returns silence. A filter frequency at or above 50 percent of the sample rate returns the input. `one_pole_highpass` subtracts the output from `one_pole_lowpass` from the input.

`_biquad_coeffs(kind, freq, sr, q)` first limits `freq` to `1..(sr / 2 - 1)`. It sets `w0 = 2 * pi * freq / sr`, `alpha = sin(w0) / (2 * q)`, and `c = cos(w0)`. For a `lowpass`, `(b0, b1, b2) = ((1-c)/2, 1-c, (1-c)/2)`. For a `highpass`, these values are `((1+c)/2, -(1+c), (1+c)/2)`. For a `bandpass`, they are `(alpha, 0, -alpha)`.

All 3 types use `(a0, a1, a2) = (1+alpha, -2*c, 1-alpha)`. The return value is `(b0/a0, b1/a0, b2/a0, a1/a0, a2/a0)`. An unknown type raises `ValueError`. The function does not reject a zero or negative `q`.

`biquad` runs `y[i] = b0*x[i] + b1*x[i-1] + b2*x[i-2] - a1*y[i-1] - a2*y[i-2]`. All input and output values before the first sample are zero. For an array `frequency`, it calculates new values at each sample. `lowpass` and `highpass` use default `q=0.707`. `bandpass` uses default `q=1.2`.

`soft_clip` applies `tanh(x * drive)`. `hard_clip` limits values to `+/-ceiling`. `bitcrush(x, bits, rate_divisor)` changes values to the nearest of `2^bits` levels. With `rate_divisor > 1` it also holds each value for that count of samples.

For all 3 time interval functions, `nd = max(1, samples(delay_s, sr))`. Thus `delay_s` at zero or below becomes one sample. Each function returns the input length. `delay_fx` uses defaults `feedback=0.35`, `mix=0.3`, and `sr=44100`. Its circular buffer starts with zeros. It sets `out[i] = x[i] + mix * delayed`, then writes `x[i] + feedback * delayed` into the buffer.

`comb_filter` uses defaults `feedback=0.7` and `sr=44100`. It sets `y[i] = x[i] + feedback * buffer`, writes `y[i]` into the circular buffer, and returns `y`. `allpass_filter` uses defaults `g=0.5` and `sr=44100`. It sets `y[i] = -g*x[i] + buffer`, then writes `x[i] + g*y[i]` into the circular buffer. Empty inputs return empty `float32` arrays.

`reverb(x, polygon_size=0.5, damping=0.3, mix=0.25, sr=44100, tail_s=0.6)` adds `samples(tail_s, sr)` zeros to the input. It runs 4 parallel feedback filters with time intervals of `29.7`, `37.1`, `41.1`, and `43.7` ms. Each output goes into a `lowpass`. Then two phase filters run at `5` and `1.7` ms with `g=0.5`. Feedback is `min(0.6 + 0.35 * polygon_size, 0.97)`. The `lowpass` filter frequency is `8000 * (1 - damping) + 800`.

It calculates the mean of the 4 feedback-filter outputs. The last mix is `(1-mix) * padded_input + mix * wet_output`. The code does not limit `polygon_size`, `damping`, or `mix` to their standard ranges.

**Caveats.**

- The `reverb` parameter has the name `polygon_size`. The correct name is `room_size`. A code-wide replace of `room` with `polygon` damaged this name. The same replace damaged text in many `artgen` files. See the Caveats of the prompt corpus unit.

- `gen_reveal_bloom` calls `reverb` with `tail_s=0.5`. It keeps this longer output, applies `grit`, and then applies `finish`. Its output thus includes the reverb tail and is about `0.56` seconds longer than its dry `1.35`-second structure.

## `synth.py` — mix, loop, `normalize`, and `WAV` files

**Goal.** Mix functions add layers, make loops, set the output level, and read and write `WAV` files.

**Invariants.**

- `write_wav` limits samples to `+/-1.0` and writes 16-bit mono `PCM`.

- `read_wav` accepts only 16-bit files. It raises `ValueError` for other sample widths.

**Verification.** A written file reads back with the same length and sample rate. The `normalize_peak` output has the target `peak`.

**Implementation.** `pad_to` cuts an array or adds zeros to a length. `gain_db` multiplies by a `dB` `gain`. `mix_layers(layers, gains)` adds zeros to make all layers the same length as the longest layer and adds them with their gains. `concat` connects arrays. `silence` returns zeros.

`crossfade_loop(x, xfade_s)` prepares a clip for a loop. It uses `nx` samples, capped at 25 percent of the clip. It mixes the head and tail with one linear fade that increases and one that decreases. It then writes the mixed segment to the two ends. The length does not change.

`normalize_peak(x, peak_dbfs)` scales the signal to the target `peak` (default `-1.5` `dBFS`). `normalize_rms(x, rms_dbfs, safety_peak)` scales to a target `RMS` level (default `-12` `dBFS`). If the `peak` then goes above `safety_peak = 0.999`, it scales down again. `write_wav` makes the directories that contain the file, changes the samples to `int16`, and writes one channel. `read_wav` returns `(data, sr)` as `float32` in `-1..1`. A file with more than one channel comes back with one column for each channel.

**Caveats.**

- Defect: after `crossfade_loop`, the first and last `nx` samples contain the same mixed audio. During looped playback, these two segments play one after the other across the seam. A listener can thus hear the segment twice. The seam stays continuous. The segment has length `nx`, which is `min(samples(xfade_s, sr), floor(len(x) / 4))`.

- Defect: `read_wav` returns an array with two dimensions for a file with more than one channel. That value is not a correct signal in this module's contract, and no signal function accepts it directly.

## `bank.py` — seeds and shared sound blocks

**Goal.** One set of functions gives all runtime sounds the same layered character and high level. Each hit sound adds 4 parts on a timeline of zeros. They are a hot transient, pitched low hit, noise body, and feedback-filter tail. The mix goes through `tanh`. An envelope lowers it to zero to prevent a click when the tail stops quickly.

**Invariants.**

- `_seed(name)` maps a name to a constant seed. It uses `int.from_bytes(name[:4], "little")` and applies a 31-bit mask. The bank is deterministic.

- `finish` ends each sound at zero: a smooth `cos` fade through `fade_s`, then `pad_s` of silence.

- `place(total_s, *events)` puts `(time, array, gain)` events on a timeline of zeros and cuts each event at the timeline's end.

**Verification.** Two builds of the `bank` give byte-equal files. The last sample of a sound after `finish` is zero.

**Implementation.** The blocks:

- `hot_transient` — hot random noise with a fast decay and an optional filter that removes high frequencies. Its default duration is 8 ms, but the function does not limit the maximum. Active calls include a 10 ms transient.

- `body_knock` — a noise burst near `120..400` `Hz`, limited to a frequency band and clipped with a smooth curve. This layer makes the sound heavy. A comment records that a fast call to `sine` at a very low frequency without noise cannot easily be heard.

- `gun_thump` — a `sine` with a fast `pitch` drop from `f0` to `f1`. A hold at `f1`, decay, and `soft clip` follow. This is the low weight of a `gunshot`.

- `gun_body` — `brown_noise` plus `white_noise`, into a `bandpass` that `sweeps` from `f_hi` down to `f_lo`, with decay.

- `gun_tail` — `lowpass` noise into 3 parallel feedback filters at `13`, `17`, and `23` ms, with decay.

- `gunshot` — the complete weapon-fire sound. It puts the transient, low hit at `2` ms, and body on the timeline. The tail at `12` ms and an optional `body_knock` follow. When `sub_gain > 0`, it adds a deep second `gun_thump` at the offset specified by `sub_at`. The default for `sub_at` is `6` ms.

  A comment states that layers at the same time increase only one sample at the maximum level. Normalization to the maximum level then removes that gain. With `double_thump_at`, `gunshot` puts the low hit twice. It applies `soft_clip`. When the caller supplies a signal to put first, it puts that signal before the layers. It then calls `finish(fade_s)`.

- `squelch_grains` — short, random noise events limited to a frequency band. The events occur across the start of the timeline and give wet texture.

- `wet_impact` — a wet hit with a `brown_noise` body and random gain change (`gurgle_depth`). It adds a low hit, a second low hit, and short noise events. A filter near `3000` `Hz` keeps the energy at high frequencies low. It has no reverb.

- `metal_clank` — a hit sound made from pairs of `sine` calls with small frequency differences. Each frequency ratio is not an integer. Each pair has a different decay. It adds a noise hit after a filter removes low frequencies. It then applies clipping with a smooth curve and a filter that removes high frequencies.

- `mech_clack` — one mechanism event with a heavy `thump` and a low hit. It also has a `metal_clank` with low energy at high frequencies and an optional friction noise burst.

- `creature_voice` — a signal from `saw` that follows the pitch curve in `pitch_pts`. It has small pitch changes on each cycle, and their dimension increases as time increases. It goes through hard `tanh` and two frequency-band sweeps. These sweeps model a voice. It then receives a layer that models noise from gas movement.

- `grit` — the same finish for all sounds. It uses `soft clip` plus a `pink` noise floor at a low level (default `-40` `dB`) that follows the signal level curve.

- `telegraph_gate` — a random on/off gain gate between `floor` and `1.0`. Noise after a filter removes high frequencies controls the gate. It makes textures for communication noise and electric arcs.

**Caveats.**

- `_seed` reads only 4 bytes. Two names with the same first 4 bytes receive the same seed. No two active names have the same first 4 bytes.

- The frequency-weighted noise floor from `grit` does not decay to zero. A sound that ends with `grit` and does not include `finish` stops with a small discontinuity. See the `tau` group caveats.

## `bank.py` — weapon and `impact` sounds

**Goal.** Each weapon and hit sound has one `gen_*` function that uses the same sound functions. The manifest has a `spec` string on one line that gives the necessary character of each sound. Many functions contain long comments that record adjustment cycles against the model. Those comments are the decision record, while this section gives the last operation.

**Invariants.**

- Each function returns a complete signal. The level `normalize` step occurs after that, in `build_bank`.

- `gen_rail_fire` keeps the parameters that received a `0.95` score from the model. The mechanism sound in `gen_reload` also keeps its recorded parameter values. Code comments identify the two decisions.

**Verification.** `uv run python tools/soundgen/bank.py pistol_fire` writes only the requested file. A listening check and the model report in `verify_report.json` give quality records.

**Implementation.**

- `gen_pistol_fire` — a `0.28`-second weapon-fire sound with a low hit from `148` to `48` `Hz`. Its body sweeps from `1600` to `230` `Hz` at gain `0.48`. Its low layer sweeps from `78` to `28` `Hz` at gain `1.1`. A comment records the correction from cycle 3: keep the body bright, decrease its gain, and offset the low layer.

- `gen_sentry_fire` — a short, bright weapon-fire sound (`0.16` seconds), changed to 10 bits and clipped with a smooth curve. A `4200` `Hz` noise click at a low level starts `30` ms before the weapon-fire sound. It shows turret mechanism movement. The comment states that the turret sound must be different from `pistol_fire`.

- `gen_smg_fire` — a short `0.2`-second weapon-fire sound changed to 11 bits. It uses the same correction from cycle 3 as `gen_pistol_fire`.

- `gen_shotgun_fire` — the weapon-fire sound with the most energy at low frequencies, with a duration of `0.62` seconds. It has a body sweep from `1800` to `210` `Hz` at gain `0.7`. It also has a `0.5`-second tail, a second low hit at `34` ms, and a deep low layer. A `0.1`-second fade ends the sound.

- `gen_scrap_fire` — a `0.42`-second change to the `gen_shotgun_fire` structure. After `60` ms, it adds 7 heavy noise hits in sequence. The hits are limited to a frequency band and show small pieces from the hit object. It then applies clipping with a smooth curve, a change to 8 bits, a filter at `3800` `Hz`, `grit`, and `finish`.

  The comment from cycle 4 gives the cause of the correction. A group of vibrations from hard objects with small time intervals sounded as one rough, continuous pitched sound. The correction uses a smaller number of hits with more space between them.

- `gen_rail_fire` — an `80` ms sweep from `saw`, from `200` to `3000` `Hz`. It goes through a frequency-band filter with a very small width. It occurs before a weapon-fire sound with a bright body. Its transient has no filter that removes high frequencies.

- `gen_lightning_fire` — a `0.85`-second clip with 30 short noise events below `4000` `Hz`. It has a gated arc. Its frequency follows a random walk for `60` percent of the clip. Low beats (`gun_thump` plus `body_knock`) continue through `80` percent of the clip. Other layers include low noise after a filter removes high frequencies. They also include a deep low hit at 50 percent of the clip.

  Gated noise at high frequencies is in the band above `4800` `Hz`. The result receives `grit` and a `0.26`-second fade. The comment records the correction that keeps the low end active until the fade starts.

- `gen_dry_click` — a short, heavy mechanism with a duration of `0.13` seconds. Its layers are a low hit from `115` to `50` `Hz` and a `body_knock` at `200` `Hz`. It also has a `metal_clank` at `520` `Hz` with low energy at high frequencies. Friction noise and two short noise events at a low level complete it.

- `gen_reload` — two mechanism events at `0` and `0.27` seconds. Each uses `mech_clack` and one deep low hit. It also uses 10 short noise events at a low level, with small time intervals for friction texture. The result receives clipping with a smooth curve, `grit`, and `finish`. A comment records that a version with less energy at high frequencies and more energy at low frequencies scored lower. Thus these values do not change.

- `gen_knife_swing` — frequency-weighted noise after a filter removes frequencies below `380` `Hz`. A sweep of the filter that removes high frequencies goes to `1600` `Hz` and back. It also has a frequency-band body with one smooth `env_adsr` curve. A comment records a corrected defect. A body with only a filter that removes high frequencies let very low frequency energy occur. It was `+25.5` `dB` above the specfile requirement.

- `gen_knife_hit` — a `wet_impact` and a bright `13` ms noise slice above `2800` `Hz`. High wet short noise events and `grit` follow.

- `gen_hit_flesh` — one `wet_impact` (`0.18` seconds, 10 `grains`).

- `gen_hit_wall` — a dry, muted `0.1`-second hit. It uses random noise with low energy at high frequencies and one low hit. It also uses a transient with low energy at high frequencies. `grit` and a filter that removes high frequencies at `2200` `Hz` follow. It has no short noise events or offset layers. A comment records that short noise events gave a long vibration and offsets gave two hits.

- `gen_step_soft` — a wet step at a low level with a duration of `0.09` seconds. Its layers include `brown_noise` with low energy at high frequencies and a low `body_knock`. They also include 3 wet short noise events and a small, bright click that identifies the hard floor surface.

- `gen_step_heavy` — a deep, dry step with a duration of `0.17` seconds. It uses a low hit from `95` to `42` `Hz` together with a `body_knock` at `68` `Hz`. It adds random noise with low energy at high frequencies and a small click from a hard surface. It then applies a filter that removes high frequencies at `1800` `Hz`.

- `gen_ricochet` — a `metal_clank` at `1050` `Hz`. It also has a pitched sweep from `3600` to `800` `Hz` with a very small band width. A low hit, a `body_knock`, and then `grit` follow. A comment records a model artifact. The model plays short clips 4 times. But the prompt used before anchored mode did not state that playback count.

**Caveats.**

- The `knife` comments show that frequency-energy measurements identified the defects. Model text without those measurements did not identify them.

## `bank.py` — enemy sounds

**Goal.** Each enemy voice or event has a different sound, and each sound identifies one event. Each event has only one sound. This made different sounds necessary for 4 events that previously all played `shrieker_scream`. They are `warden_alert`, `warden_lunge`, `dart_throw`, and `mark_hit`.

**Invariants.**

- `warden_alert` and `warden_lunge` use the same voice character. Their speed and pitch direction are different.

- The adversary sounds contain no voice components or frequency bands that model a voice. They also have no small pitch changes that occur again and again. They must not have voice character.

**Verification.** The model report compares each sound with its group anchor. Comments record measured checks, with the median-frequency distance between the `warden` lunge and the `husk` low voice.

**Implementation.**

- `gen_enemy_die_husk` — a `creature_voice` with pitch that decreases from `78` to `38` `Hz` and has more pitch changes. It adds a `wet_impact`, wet short noise events, and a `body_knock`. It also adds gated noise. The noise frequency decreases, and its energy at high frequencies is low. It then applies a filter that removes high frequencies at `3400` `Hz`.

- `gen_enemy_die_mite` — one small `wet_impact` (`0.16` seconds, `thump` `280 -> 95` `Hz`).

- `gen_enemy_die_brute` — a heavy, `0.82`-second fall with two long low hits at `0` and `0.22` seconds. It also has two low hits and a `wet_impact`. A noise sweep decreases in frequency and has low energy at high frequencies. Noise models the small pieces that fall after the hit, and the tail has low energy at high frequencies.

- `gen_enemy_alert_husk` — rough noise from an inward flow. It goes through a frequency-band sweep from `500` to `1600` `Hz`, followed by a low `creature_voice`.

- `gen_enemy_alert_warden` — starts with hits on a hard surface. They include a `10` ms noise movement limited to a frequency band and normalized to a `-3` `dB` maximum. They also include two `sine` calls that give a long vibration. A slow, deep `creature_voice` follows with pitch near `74..90` `Hz` and small pitch changes. A body `sine` at a low level decreases from `46` to `35` `Hz`.

  Comments record two measured corrections. The first hit on a hard surface had almost no energy above `1200` `Hz`. A voice with only very low frequencies could not be heard on small audio systems.

- `gen_warden_engulf` — the lunge signal. A hard, short noise sweep from surface contact increases to `3400` `Hz`. A fast `creature_voice` then increases from `96` to `240` `Hz`. Its voice bands get to `3700` `Hz`, and it has an added noise push. A comment records that the first version had the same median frequency as the `husk` low voice.

- `gen_adversary_snare` — a thin, wet movement event with no weapon-fire hit at a high level. It has a noise sweep from `900` to `2600` `Hz`, limited to a frequency band. It also has a `sine` arc with pitch that increases.

- `gen_adversary_snare_hit` — a flat, wet hit at `700` `Hz`. A low signal from `saw` moves from `150` to `78` `Hz`. It shows slow movement and not damage.

- `gen_adversary_shove` — a push signal made from a hard low hit from `sine` that decreases from `170` to `68` `Hz`. A wide noise band also decreases in frequency.

- `gen_adversary_return` — a return event in which noise increases below a frequency-band sweep that also increases. A hard, bright hit starts at `0.25` seconds. Two `sine` calls at `905` and `1347` `Hz` then give a cold long vibration. The source states that the envelope moves from end to start, but the code does not change the sample sequence.

- `gen_enemy_alert_mite` — clear, short clicks in a stepped sequence. The time between clicks decreases as pitch decreases. Each click uses a noise hit with low energy at high frequencies and a `sine` call. The `sine` level decreases quickly. A body layer stays at a much lower level than the clicks.

- `gen_spitter_shoot` — a wet movement event with a liquid noise and gain change. A noise burst through a sweep of a filter that removes high frequencies gives the movement transient. Other layers are a `body_knock` and wet short noise events in low, high, and small groups. The result receives `grit` and a filter that removes high frequencies.

- `gen_gland_fire` — the player's `gland` weapon. It uses a `wet_impact` with a hard pair of `sine` calls at `310` and `322` `Hz`. This close frequency interval gives tension. It adds wet short noise events and heavy `grit`. The interval makes it different from the `spitter` sound.

- `gen_mark_hit` — the mark hit on the player. A hit with low energy at high frequencies identifies it. A `sine` sweep from `430` to `1180` `Hz` also identifies it. It has a small band width and wet noise with a filter change. It ends with `fade_out` and not `finish`.

- `gen_marker_launch` — the `dart` release signal. It has a low noise burst, a wet release with gain change, and a `sine` arc. The arc increases to `2350` `Hz` and then decreases. It ends with `fade_out`.

- `gen_shrieker_scream` — the warning sound. It uses `creature_voice` with a 6-point pitch curve that gets to `1400` `Hz`. It also uses a gated rough noise band and a low layer from `saw`. A 5-point gain curve and small level changes shape the signal before a filter removes frequencies below `140` `Hz`.

**Caveats.**

- The comments name gate numbers (`gate 54`, `56`, `57`, `58`, `60`) and a run number. These point to decision sessions out of this repository. The specfile cannot find their sources.

## `bank.py` — player sounds

**Goal.** The player has 3 body sounds: damage, death, and a looped heartbeat.

**Invariants.** Of the 3 player body sounds, only the death sound uses reverb. Other bank groups also use reverb, with `gen_reveal_bloom` and `gen_amb_drone_finale`.

**Verification.** The model report gives the quality records. Before the code adds zeros, the heartbeat is `0.8` seconds long. This lets it loop at a heartbeat rate.

**Implementation.**

- `gen_player_hurt` — a small `wet_impact` plus a fast `detuned` `sine` pair near `2100` `Hz` as a `sting`.

- `gen_player_die` — a `1.45`-second dry timeline. A short `creature_voice` with pitch that decreases starts first. A `wet_impact` at a high level starts at `0.28` seconds, and a second hit follows. It also includes short noise events for small pieces from the hit and a `body_knock`. A long layer at high frequencies follows.

  A pair of `sine` calls with small frequency differences and noise at `1050` `Hz` make that layer. Low noise as the small pieces fall completes the dry timeline.

  `reverb` adds `0.2` seconds, and `finish` adds `0.05` seconds of silence. The result is a `1.70`-second signal.

- `gen_heartbeat` — 2 beats at `0` and `0.19` seconds. Each beat is a `thump` plus a noise layer with low energy at high frequencies. The second beat is smaller.

**Caveats.** None.

## `bank.py` — item, terminal, show, and door sounds

**Goal.** Interface and world events sound as if material objects made them. They are different from a bare pitched sound from one waveform function. Noise masks the waveform quality of a bare pitched sound. Different start times make it possible to hear each event phase.

**Invariants.**

- The 3 `reveal` sounds use the same sound structure. `gen_reveal_sour` uses the `gen_reveal_bloom` structure again. This identifies the same event with an error.

- `gen_think_complete` stays at a low level and has low energy at high frequencies, as specified. It must not cut through `combat`.

**Verification.** The model report gives the quality records. For the phased sounds (`reprint`, `seed_plant`, and `fabricate_buy`), a listening check checks that each phase starts at a different time.

**Implementation.**

- `gen_pickup_ammo` — a container low hit, a `body_knock`, and two `metal_clank` pitched sounds with low energy at high frequencies. Short friction-noise events decrease in pitch, followed by heavy `grit`.

- `gen_pickup_medkit` — a smooth `thump` with a slow attack, a `body_knock`, a `metal_clank` without a hit, and noise above `2200` `Hz`.

- `gen_pickup_key` — two `metal_clank` sounds have a frequency difference of `50 cents`. Each sound has large internal frequency differences. A low hit and a `body_knock` follow. It also has a noise floor with low energy at high frequencies.

- `gen_fabricate_buy` — 3 phases in `0.55` seconds. Phase 1 is a mechanism sweep with `distortion` and mechanism noise. Phase 2 uses short noise events and a low continuous sound with `distortion` to show material that moves into the system. Phase 3 is a signal that the operation is complete, with two pitched sounds at `1400` and `2000` `Hz`.

  In each `tone`, a `bandpass` noise layer has a higher level than the `sine`. A small `metal_clank` starts the last phase. Then `soft clip`, `bitcrush`, and heavy `grit`.

- `gen_reprint` — 4 phases in sequence with silence between them. Phase 1 is a pitched sweep that increases, with flow noise and short random noise events. Its release completes. Phase 2 contains 3 heavy hits with clear time intervals. Phase 3 is a smooth pair of `sine` calls with small frequency differences. Phase 4 is a bright group of 3 `sine` calls with noise.

  A comment records that layers which started at the same time made the phases sound the same. This result occurred for all quantities of `grit`.

- `gen_seed_plant` — two phases. Phase 1 uses a very deep low hit and low layer. It also uses a `body_knock`, random noise, and a `metal_clank` with low energy at high frequencies. It completes its release.

  Phase 2 uses a sweep with `distortion` from `120` to `900` `Hz`. Its noise is at a higher level than the pitched sound. A low continuous sound and short random noise events complete the phase.

- `gen_corpse_recover` — a `metal_clank` at `210` `Hz` has low energy at high frequencies and fast decay. A `thump`, a `body_knock`, and `dust` noise follow. A `tone` pair at a low level is at `220` and `196` `Hz`. Its specified character is low and slow, with no fast changes.

- `gen_terminal_open` — a small `thump` and a supply sound from `square` at `50` `Hz`. It also has static short noise events and a pitched sweep at a very low level near `9000..11500` `Hz`.

- `gen_terminal_type` — one key hit on a `65` ms `timeline`. It has a transient, a `thump`, a `body_knock`, a `bandpass` noise burst at `800` `Hz`, and a small click. The `20` ms `pad` from `finish` makes the returned signal `85` ms.

- `gen_radio_blip` — gated static followed by 3 short pitched sounds from `square` in sequence. They form a short group with voice character. The complete signal goes through a frequency-band filter for a voice and clipping with a smooth curve. It then changes to a smaller number of bits with a lower sample rate.

- `gen_reveal_bloom` — 8 pitched sounds from `sine` start in sequence. Sound `i` starts at `i * 45` ms. Its pitch offset comes from the angle `137.50776` degrees. This offset changes to a ratio between `1.0` and `2.5` against a `220` `Hz` reference sound. A low `sine` layer is below them. The result receives clipping with a smooth curve, a filter that removes high frequencies, reverb, and light `grit`.

- `gen_reveal_snap` — 5 events that each contain a click and `metal_clank`. Each event is brighter than the previous one. A clean signal that the operation is complete follows and has two pitched sounds. A filter that removes frequencies below `300` `Hz` keeps it dry.

- `gen_reveal_sour` — the bloom structure with 6 pitched sounds. The pitch of each sound decreases during its length by a random factor in `0.82..0.94`. Gated noise increases below the pitched sounds through a frequency-band filter that decreases.

- `gen_think_complete` — a smooth sound at a very low level. It uses two `sine` calls at `880` `Hz` and `1.5` times that frequency. A filter then removes frequencies above `3200` `Hz`.

- `gen_door_unlock` — a long mechanism `sweep` with `distortion`, a `26` `Hz` `square` `gain` `wobble`, and mechanism noise. A heavy hard object hit occurs at `0.27` seconds. It has `gun_thump`, `body_knock`, and `metal_clank` with low energy at high frequencies. `Grains`, a tail with low energy at high frequencies, and heavy `grit` follow.

**Caveats.**

- Comments in `gen_reveal_bloom` and `gen_reveal_sour` label the angular structure `phyllotactic`. The code uses only the constant angle to calculate time and pitch offsets.

## `bank.py` — tau weapon group

**Goal.** The `tau` is the energy weapon. Its fire sound has an electric short hit and long vibration. Its charge sound has a pitched sweep that increases. `tau_discharge` and `tau_overcharge_hurt` complete the group.

**Invariants.** `gen_tau_charge` holds its high `pitch` until the last `40` ms release. `finish(..., pad_s=0.0)` fades the last sample to zero and adds no silence.

**Verification.** The model report gives the quality records. A waveform view of each clip's end checks how its signal stops.

**Implementation.**

- `gen_tau_fire` — a `30` ms `highpass` `snap` in front of a bright `gunshot`. A `metal_clank` `ring` with 4 ratios starts at `28` ms. Then `grit` follows.

- `gen_tau_charge` — `1.5` seconds. A `sine` `whine` `sweeps` `300 -> 1500` `Hz` and holds the top for the last `0.15` seconds. It has a `sawtooth` `octave` layer at a low level and flow noise on the `sweep`. It also has a supply `hum` of 2 `sines`. `Tremolo` increases from `8` to `24` `Hz`.

  The 46 `crackle` `grains` have smaller time intervals near the end. Then `grit`, `lowpass`, and a short `finish` fade.

- `gen_tau_charged_fire` — a deep `gunshot` with a second `thump` and an arc of 2 `sines` that falls `1900 -> 320` `Hz`. It also has 22 `crackle` `grains` that thin out, then `grit`.

- `gen_tau_overcharge_hurt` — a `thump`, a hot `bandpass` electric hit, `grains`, and a tail with low energy at high frequencies. It also has 2 fast warning `tones` from `square` at `392` and `311` `Hz`, then `grit`.

**Caveats.**

- Defect: the module goal states that each sound ends at zero. But `gen_tau_fire`, `gen_tau_charged_fire`, and `gen_tau_overcharge_hurt` return the output of `grit` without a call to `finish`. The frequency-weighted noise floor from `grit` stops at the buffer boundary with a small discontinuity. In `gen_tau_fire`, `place` also cuts the fade and zeros that `gunshot` added through `finish`. Its timeline is shorter than the input clip.

- In `gen_tau_fire`, the formula `max(0.34, 0.03 + 0.2)` always returns `0.34`. Thus its second branch has no effect.

- The `gen_tau_charge` comment states that the sound “ends hot.” The manifest text states the same. The implementation fades to zero during its last `40` ms. The transition text is incorrect.

## `bank.py` — ambience drones and the stinger

**Goal.** 4 `60`-second drones change from a bare low continuous sound to many layers that signal a threat. One short stinger is used with special events. All 4 drones loop.

**Invariants.**

- Each drone is `60.0` seconds and ends with `crossfade_loop`.

- The build step scales drones to an `RMS` target and not to a target for the maximum signal level.

**Verification.** Loop playback checks the seam, and the model report gives quality records.

**Implementation.** The drones use the same 3 continuous layers. `_vent_bed` is low noise limited to a frequency band, with very slow gain change. `_hum_bed` is a pair of `sine` calls with small frequency differences at the given frequency. It adds frequencies at 2 and 3 times the root frequency. It has clipping with a smooth curve, slow gain change, and a filter that removes high frequencies at `700` `Hz`.

`_dull_knock` is a hard object hit heard from a long distance, with low energy at high frequencies. It has a low hit and a `metal_clank` without its attack transient, after a filter removes frequencies above `700` `Hz`.

- `gen_amb_drone_early` — the `hum` layer at `55` `Hz` and the noise from flow. It also has high noise at a very low level. The sound has 5 `_dull_knock` events at random times and at a low level.

- `gen_amb_drone_mid` — the full `gen_amb_drone_early` output is its first layer. It adds a slow beat of 2 `sines` at `110` and `111.6` `Hz`. It also adds 3 far `groan_layer` events. `groan_layer` is a `sawtooth` glide with `distortion`, `vibrato`, and `lowpass`.

- `gen_amb_drone_late` — a continuous cycle of 5 voices with pitch that decreases across `55..880` `Hz`. Each voice has a smooth gain window through the cycle, a pair with small frequency differences, and `tanh`. More layers include a low noise bed and a low `42` `Hz` increase. They also include 10 gated static events at a low level that have voice character. It also has a noise floor at high frequencies. The mix receives clipping with a smooth curve and a change to a smaller number of bits.

- `gen_amb_drone_finale` — a `38` `Hz` low with a slow swell and a low noise band at `90` `Hz`. Slow, deep beats at low frequencies occur each `6..8.5` seconds. The complete signal goes through a large reverb and is then cut to length.

- `gen_stinger_wrongness` — a `2.6`-second clip with 3 voices from `saw`. They move apart in pitch after the first 25 percent, with slow random change. `Distortion` increases with the difference while a filter opens and closes. Other layers are a gated static increase and a noise floor at high frequencies and a very low level. A deep low hit occurs near the end.

  A 7-point gain curve with slow `tremolo` shapes the clip before `grit` and a long fade. A comment records that versions with short random noise events scored lower. Thus the code uses the previous values again.

**Caveats.**

- `gen_amb_drone_finale` builds beats on the full length. Then `reverb` extends the buffer, and `pad_to` cuts it back before the loop fade. The `reverb` tail after `60` seconds is cut. The loop seam makes this cut not easy to hear.

## `bank.py` — manifest and build

**Goal.** One table is the only source for the bank. For each sound, it contains the name, necessary character, duration range, group, generator function, and method that scales the level. The build writes each `WAV` file to `game/assets/sfx/`.

**Invariants.**

- `_ENTRIES` contains 59 sounds. `MANIFEST` contains the same entries without generator functions and contains paths from the repository root.

- Targets for the maximum signal level are different for each group. Weapon sounds use `-1.5` `dBFS`, hit sounds `-2.5`, enemies `-2.0`, and player sounds `-3.0`. Interface sounds use `-4.0`, the stinger `-6.0`, and steps `-7.0`. Drones scale to `-12` `dBFS` `RMS`.

- With a name set, `build_bank` writes only the named sounds.

**Verification.** A full run prints one line for each sound with its length and path, then the count. The files are in `game/assets/sfx/`.

**Implementation.** `_normalize` applies one of two modes: `("peak", target)` or `("rms", target)`. An unknown mode raises `ValueError`. `build_bank` makes the output directory, runs each generator, and scales the result. It writes the `WAV` file and returns result rows with the duration. The command line accepts an optional list of names in one argument, with the `,` character between names. Example: `pistol_fire,dry_click`.

The only approved text for each sound is the second value in its `_ENTRIES` tuple in `tools/soundgen/bank.py`. The complete table runs from the `pistol_fire` tuple through the `stinger_wrongness` tuple, directly above `_normalize`. `build_manifest` copies each text value without a change into the applicable `spec` field. The sound units above give generator operation and do not replace those text values.

**Caveats.**

- No code checks the `dur_min` and `dur_max` fields, and many made durations are not in their ranges. For example, `reload` lasts `0.61` seconds with a maximum of `0.35`. `door_unlock` lasts `0.73` seconds with a maximum of `0.40`. These fields are used only in the model prompt.

- `shrieker_scream` and `warden_engulf` `normalize` to `PEAK_ENEMY + 0.5`, which is 0.5 `dB` higher than the other enemy sounds.

## `verify_bank.py` — `bank` `judge` `driver`

**Goal.** The script sends the bank to the `Gemini` audio model in `tools/playtest/audio_judge.py` and writes `tools/soundgen/verify_report.json`. It checks and reports sounds but does no repairs. Thus subsequent work cycles use one report file that continues across cycles.

**Invariants.**

- If `ffmpeg` is not on the executable path, the script prints a clear error and exits with code `1`. A missing `OpenRouter` key gives the same result. The script does not make a verdict.

- Model errors stay in the console output. Sounds with a `None` probability are in the error list and do not count as accepted.

**Verification.** A run prints the counts, mean and minimum `p_shippable`, and the 8 sounds with the smallest scores. It also prints the error list and the total model cost.

**Implementation.** The model input string gives the runtime style. In anchored mode (`--anchored`), the model compares each sound with a strong reference from the bank. A constant map selects the anchor by group. Weapon sounds use `rail_fire`. Hit sounds and voices use `player_hurt`.

Interface groups use `terminal_open`. Drones use `amb_drone_mid`. The two `knife` sounds also use `player_hurt`. The anchor is not the sound that the model checks.

With `--only`, the script checks a subset and adds the new rows to the previous report. It then calculates all report values again from the complete row set. `--n-passes` (default `2`) sets the number of model checks for each sound.

**Caveats.**

- A comment records that the user approved the anchor map.

- Model-error rows do not give the command a failure. After the key and `ffmpeg`
  checks are correct, the script writes the report. It exits 0 when one or more
  sounds have `p_shippable=None`.

## `gen.py` — API key and the cost log

**Goal.** One API module gives image-model access and one cost log for the complete image process. Each call that gets to the image-output step records its reported cost in `tools/artgen/cost_log.json`. Costs from all runs in a session add to one total.

**Invariants.**

- The key comes from `.openrouter_key` at the repository root or from the `OPENROUTER_API_KEY` environment value. If there is no key in these two locations, the module raises `RuntimeError`. It does not print or write the key.

- Each operation that reads, changes, and writes the cost log holds the module lock `_cost_log_lock`. Callers must use `record_cost` and not write the file directly.

**Verification.** `gen.py --report` prints the total cost and call count. The log file contains one row for each call that reports a cost.

**Implementation.** `record_cost(cost, entry)` gets the lock, reads the log, and adds the cost to the total. It adds the entry to the list and writes the file. `total_spend` and `call_count` read the file. A comment records the cause for addition of the lock. On 2026-07-11, writes at the same time from a 6-worker run kept only 4 of 1,580 log rows. Previous repository versions gave the data back.

**Caveats.**

- The lock applies to only one process. Two image processes can write the file at the same time and not write some rows to the total.

- When the code cannot parse the cost log, it uses an empty log. The code does not report the parse error. The next write replaces the file and sets the recorded total to zero.

- `generate_image` records cost only after it decodes and writes an image.
  `HTTP` errors and responses without an image do not add a row. Image `URLs`
  with a different form and decode or write failures also do not add a row. If
  an API call has a cost for one of those responses, the recorded total is low.

## `gen.py` — `generate_image`

**Goal.** One function sends a prompt to the `OpenRouter` API and writes the result as a `PNG`. It includes retries, cost records, and optional reference images. It does not write an image when the call has an error.

**Invariants.**

- The default model is `google/gemini-3.1-flash-image`. A comment records the selection: the highest quality for its cost at that time.

- When all network tries have errors or the model returns no image, the function raises `RuntimeError` with the cause. Each response `refusal` field is in the error text.

**Verification.** A call writes the file and returns the dimensions, the cost, and the new totals. A bad key or an empty response raises.

**Implementation.** When the caller supplies `negative`, the function adds an `Avoid entirely:` block to the prompt. Reference images are attached as `base64` data `URLs` in one user message. The request includes image and text output. By default, a call makes at most 3 API tries. The caller can override that total with `max_retries`. Between the default tries, it waits `5` seconds after the first failure and `10` seconds after the second.

It does not wait after the last failure. Each try has a `180`-second call limit. The default thus schedules `15` seconds of waits and has a maximum call time of `540` seconds.

The response must contain one or more images as a `data:` `URL`. The function decodes the first image with `PIL`. With `chroma_key=True`, it changes the key-color area to alpha and cuts the image as given in the next unit. Otherwise, it writes `RGB` data. It records the cost together with the model, output path, and input and output counts. It then returns the path, dimensions, cost, model, and new totals.

**Caveats.**

- The retry loop does not retry a response that contains no image. Only network errors cause a new try.

## `gen.py` — chroma key to alpha

**Goal.** The image API does not return alpha transparency. A test in the comments requested a transparent area. It received an `RGB` image with a painted grid of squares. The squares had the same values in their `R`, `G`, and `B` channels.

Sprites thus use a chroma-key process. The prompt requests the flat key color `#FF00FF`, and this code changes that color to alpha. The runtime palette has almost no pixels near that key color.

**Invariants.**

- Pixels with an `RGB` distance below `t_low = 25` from the key color become fully transparent. Pixels above `t_high = 95` stay fully opaque. Between those thresholds, alpha increases linearly to keep the model's smooth sprite edges.

- `autocrop_alpha` keeps an empty margin, 6 pixels by default, around pixels with nonzero alpha.

**Verification.** A result sprite displayed on a floor with low luminance has no key-color edge. The cut image contains the complete sprite.

**Implementation.** `chroma_key_to_alpha` measures each pixel's `RGB` distance from the key color and maps that distance to alpha. With `despill=True`, it lowers the `R` and `B` channels to the `G` channel in proportion to the key-color distance. For pixels with alpha below `0.5`, it applies a second, complete pull. This is necessary because a light key-color edge shows `R` and `B` on a floor with low luminance. `erode_px = 2` then removes 2 pixels from the alpha-mask edge to remove the last tinted edge pixels. `autocrop_alpha` finds the bounds of pixels with alpha above `4` and cuts with the specified margin.

**Caveats.** None.

## `gen.py` — post-process functions and the CLI

**Goal.** Menu images use a constant image procedure. The procedure gives them the necessary dimensions, a top area with low luminance for text, and a limited color set.

**Invariants.**

- `downscale_to` first cuts to the target shape from the center, then resizes with `LANCZOS`.

- `ensure_text_safe` lowers image luminance until the mean for its top 67 percent is at most `max_luma = 60`. It uses no more than 8 steps.

**Verification.** `process_asset` reads the written file back. It returns its dimensions, its top luminance, and its `text_safe` value.

**Implementation.** `quantize_colors` changes the image to `n_colors` (default `64`) with `MEDIANCUT` and `FLOYDSTEINBERG`. `darken_multiply` multiplies each pixel by a factor. `ensure_text_safe` calculates each step's factor from the distance to the target and limits it to `0.5..0.95`.

`process_asset` resizes the image, lowers its luminance, and changes its color count before it writes the file. The CLI has 3 modes. `--report` prints cost totals, and `--process` runs the image procedure. Prompt mode calls `generate_image` with optional `--ref` images, `--negative`, and `--chroma-key`.

**Caveats.** None.

## `pilot_texture_lib.py` — level geometry and paths

**Goal.** One set of geometry functions keeps each image-process stage in the same pixel coordinate frame for each polygon. This is the same frame that `polygon_basetruth.py` renders. This module makes no network calls.

**Invariants.**

- A polygon's frame is its bounding box at 3 pixels for each world unit, with dimensions rounded up.

- `texture_out_path` must agree with the engine convention in `texture_geom.py`: `game/perihelion/assets/textures/<level>/polygon_<index>.png`, with no zeros before the index in the file name. A comment marks this contract.

- `polygon_mask` fills the polygon with the same `fb2d.polygon` operation used by `polygon_basetruth.py`. Thus the mask and render agree pixel for pixel.

**Verification.** The mask aligns with its image from `polygon_basetruth.py` pixel for pixel.

**Implementation.** `get_level` loads each level file and caches it. `polygon_mask` builds the transform from world space to the local `pixel` frame. It fills the polygon into a buffer and returns the `True`/`False` grid.

`apply_mask` sets pixels not in the mask to `RGB(0, 0, 0)`. It first resizes the mask when the texture dimensions are different by one rounding pixel. `polygon_doorway_edges` collects the indices of edges that `connects`, `connects_x`, or `doors` connect to a different polygon. `_polygon_xform` returns the transform used by all functions. `wall_edges_px` returns the pixel endpoints of each polygon edge and does not include doorway edges when `walls_only=True`.

By default, doorway edges stay included. A long calibration comment gives the cause. A polygon had 3 doorway edges and one wall edge. Its shape result from the wall edge was correct, but its texture was incorrect. The gate thus checks all edges.

`load_pilot`, `basetruth_path`, and `texture_out_path` give paths. `SCRATCH` identifies the temporary work directory.

**Caveats.**

- `SCRATCH` is a constant absolute path in `/tmp/claude-1000/...` and contains a session identifier. Reference-image, material, and `polygon_basetruth.py` caches are there. On a different system, or after the temporary directory is cleared, these inputs are not available. `full_run.py` then stops because no material swatch is available.

- The `pilot` list `pilot_polygons.json` is in the repository, but `BASETRUTH_DIR` is below `SCRATCH`.

## `pilot_texture_lib.py` — `guide`, neighbor composite, and audit overlay

**Goal.** 3 functions make model inputs and audit images. The reference image shows the polygon shape, and the neighbor composite shows how the floor continues through each doorway. The audit overlay lets the user examine a completed texture quickly.

**Invariants.**

- The reference image raises the floor-region channel values by `+70`. This prevents use of a floor with low luminance as the outer polygon area. That outer area stays at `RGB(0, 0, 0)`.

- The reference image draws one `RGB(0, 255, 255)` line for each polygon boundary edge, with doorway edges. It offsets the line about 3 pixels to the side not in the polygon. A comment states that the model can copy clear reference marks as paint. Because the copied line is in the outer area, `apply_mask` removes it from the last texture.

- The reference image does not identify doorways by color or spaces in lines. A previous version used `#FF00FF` doorway marks. The model copied them as light paint in the `R` and `B` channels. It also copied door boxes with the same channel values. The neighbor composite gives information about the floor through doorways.

**Verification.** `make_guide` raises when the dimensions of the `polygon_basetruth.py` image and mask are different. The audit overlay shows the polygon outline on the completed texture, with `#00FFFF` walls and `#FF00FF` doorways.

**Implementation.** `make_guide` reads the `polygon_basetruth.py` image and increases the luminance of the masked region. It sets all other pixels to zero and draws each offset boundary line. For each edge, it samples a point on each side of the midpoint. It selects the side not in the mask. This makes the offset work for polygons with inward corners.

`build_neighbor_composite` returns `None` when none of the polygon's neighbors has a completed texture. If a completed neighbor texture is available, it makes an `RGB(0, 0, 0)` canvas. The canvas has a margin around the polygon frame.

For each doorway with a textured opposite polygon, it resizes that neighbor texture into a band. The band has the same length as the edge. It turns the band to the edge angle. It then puts the band adjacent to the edge on the side opposite the centroid. It draws only the polygon outline in `#00FFFF`.

`save_review_overlay` opens the completed `texture` and scales the polygon points to the `texture` dimensions. It draws each edge: `#FF00FF` for doorways and `#00FFFF` for walls.

**Caveats.**

- Defect: the `build_neighbor_composite` docstring states that the band samples the neighbor region adjacent to the edge. The two polygons use this edge. The code resizes the complete neighbor texture into the band. Thus the band shows all of the neighbor texture and not its floor at the doorway.

- When an edge is flush with the bounding box, the offset wall line is not in the image. A comment accepts this because the line at the image edge marks the wall in that condition.

## `pilot_texture_lib.py` — the prompt corpus

**Goal.** Each image prompt includes material text for the polygon type and 5 requirement blocks. Each requirement corrects a recorded defect type. This makes the prompt set part of the image-process decision record.

**Invariants.**

- `KIND_MATERIAL` tells the floor material for each of the 14 polygon types. `TESTATOR_KINDS` is `{otherworld, chapel, core}`. All other types are `MIRIAD` space.

- `NO_SIGNAGE_LAW` does not let text or direction marks occur in the two material and polygon prompts. It prevents painted text in the floor image from material swatches. `BAY 7` is one example. This caused the text to occur again in each polygon of that type.

- `FULLBLEED_LAW` states that the floor must get to each image edge without a border, frame, vignette, or wall band. `FULLBLEED_FINAL_REMINDER` gives this requirement again as the prompt's last line. Border errors were the largest error class and occurred in 121 of 316 bare polygons. The last position of this line corrected the problem and did not change gate thresholds.

- `GEOMETRY_LOCK` limits the output to the reference-image silhouette. It does not let new props, new walls, or cut corners occur. `SHAPE_LAW` states that grids of floor sections must follow each wall's angle.

**Verification.** The gates in `texture_checks.py` and the `Gemini` model test the same conditions given in these prompt blocks. Error notes identify the condition that each candidate did not follow.

**Implementation.** `build_material_prompt(kind)` includes the style text, type material, and a `Testator` or `MIRIAD` line. It adds a swatch-instruction block, the full-bleed and `NO_SIGNAGE_LAW` requirements, and a style-anchor block.

`build_polygon_prompt(kind, has_neighbor_composite, box_note, decal_note)` includes the style text, type material, optional floor-layout note, and reference-image instructions. The optional neighbor block, requirements, optional box note, and `NO_SIGNAGE_LAW` requirement follow. An optional decal note and the last full-bleed line complete the prompt. `FLOORPLAN_NOTE` adds runtime wear requirements for 7 types. For example, the `hydro` note identifies the `trough` locations and states that travel routes must be clear. It does not let painted `trough` shapes occur.

**Caveats.**

- Defect: a change from `room` to `polygon` across the code damaged text sent to models. `KIND_MATERIAL["lab"]` contains `clean-polygon composite flooring` and not `clean-room composite flooring`. `GEOMETRY_LOCK` and other blocks contain `polygon polygon`. Item text in `item_layouts.py` contains `stockpolygon` and not `stockroom`. The model prompt in `verify_gemini.py` has the same damage. Models receive this malformed text without a change.

- Defect: `SHAPE_LAW` states that the reference image marks doorways as spaces in the lines. But `make_guide` draws a continuous `#00FFFF` line across each edge, with doorways. The prompt thus does not agree with its reference image.

- The style text requests flat lighting because the runtime applies lighting with low luminance.

## `texture_checks.py` — `full-bleed` and interior-`void` gates

**Goal.** Local `numpy` gates reject bad candidates before a model call that has a cost. This pair finds two defect classes. One is a painted border or vignette in the polygon. The other is a new `RGB(0, 0, 0)` notch or cut corner in the floor.

**Invariants.**

- `verify_fullbleed` compares an edge band (`band_px = 12`) with the polygon center. It rejects when the center is brighter than the band by more than `darken_thresh`. It also rejects when the band holds more local structure than the center, by more than `struct_thresh = 1.7`.

- `verify_no_interior_void` rejects when more than `2` percent of the floor `pixels` have luminance below `12`. The measured record: about `4` percent on a caught defect, `0.2..0.9` percent on clean polygons.

- The two gates accept very small regions without a check and state that result in their `reason` field.

**Verification.** Comments record the calibration values. Vignette examples measured ratios of `1.7` or more. Clean polygons with many props measured `1.33..1.47`.

**Implementation.** `_erode_mask` removes boundary pixels, and `_dilate_mask` adds boundary pixels. They use `RankFilter` on an array with an added margin. The margin is necessary because a mask that fills the canvas cannot become smaller at the image border without it. This is where a swatch vignette occurs.

`verify_fullbleed` calculates the edge band as the input mask minus the output from `_erode_mask`. The center is the output after 3 calls for one band width. When boxes are supplied, it first removes item footprints from the band. Most item templates are along walls, and requested equipment can be incorrectly counted as a border. The gate returns the means, ratios, and two error flags. `verify_no_interior_void` measures the fraction with luminance below `12` in the mask.

**Caveats.**

- The gate for an internal `RGB(0, 0, 0)` region is necessary. The full-bleed gate and model accepted one completed polygon with `RGB(0, 0, 0)` corner shapes. A person found the defect during a frame audit.

## `texture_checks.py` — tileable repair and tile checks

**Goal.** Each type's material swatch must continue across image boundaries. One function repairs seams, and two checks measure seam visibility and regular structure.

**Invariants.**

- `verify_tiling` makes a `2x2` image and compares gradient energy across the seam lines with the mean for the complete image. It rejects a ratio of more than `1.6`.

- `verify_no_repetition` ignores a small circle at the center of the `autocorrelation`. It rejects a maximum more than `0.28` times the maximum at offset zero. Regular structure gives such a maximum not at the center.

**Verification.** Check results include the measured ratios. Thus the run log shows each candidate's margin from the thresholds.

**Implementation.** `make_tileable` moves the image by 50 percent of its dimension on each axis. This moves the seams to the center. Across each seam, it mixes mirrored data from the two sides with a linear crossfade. It keeps `15` percent of the first band. It then applies `blur` only to the seam bands.

A comment records that rows of small circular heads caused more errors on horizontal seams than on vertical seams. `verify_no_repetition` adds zeros before the `FFT` `autocorrelation`. This prevents wrap-around. Without the zeros, wrap-around can make an incorrect maximum. The function can also limit the check to a mask.

**Caveats.**

- The polygon-level check for regular structure is off. Calibration showed that a baked arrow that occurs only twice scores lower than clean grids of floor sections. But the constant period of the grids is specified. Material swatches continue to use the check. `gen_pilot_textures_v2.py` records this decision.

## `texture_checks.py` — outer black margin `crop`

**Goal.** The model can paint a thin `RGB(0, 0, 0)` margin around a correct polygon. `crop_outer_black_margin` removes a small margin but does not remove a larger layout defect.

**Invariants.**

- A row or column counts as `RGB(0, 0, 0)` only when `98.5` percent or more of it has luminance below `14`. Edge rows in a diagonal silhouette do not get to that threshold. Thus correct outer corners stay.

- The cut limit is `8` percent of each dimension on each side. If the margin is larger, the function returns the input image without a change. The full-bleed gate then rejects it.

**Verification.** The function calculates the output from the input image only. It does not change the input image or external state. Known images with and without outer margins show the cut result and the result with no cut.

**Implementation.** The function counts rows and columns with luminance below `14` from each side. It cuts when all counts are below the limit.

**Caveats.** None.

## `texture_checks.py` — shape gate

**Goal.** The recorded shape defect is a grid of floor sections put in axis-aligned screen space. The polygon walls are diagonal. This gate measures if the texture's line structure near each wall follows that wall's angle.

**Invariants.**

- Structure parallel or perpendicular to the wall is correct because this floor has two seam directions at 90 degrees. One of those seam directions is along the wall. An edge's error is the distance between the angle with the most energy and the wall angle, folded modulo 90 degrees.

- The gate rejects when the weighted mean edge error is more than `12` degrees. In calibration, the known bad polygon measured `25.2` degrees, while known clean polygons measured `0.5..1.0`.

- When boxes are supplied, the gate first expands and removes their item footprints. Requested wall boxes with warning lines gave errors of `17..21` degrees. The floors received a correct result without the boxes.

**Verification.** Comments record known results for the calibration pair, and the return value reports the result for each edge.

**Implementation.** `_sobel` calculates the gradient. For each wall edge, `_band_mask_for_edge` selects pixels no more than `band_px = 40` from the edge. The gate keeps the strongest `20` percent of gradient pixels. It builds a 90-element angle count weighted by energy. It smooths the count across its wrap boundary and selects its maximum.

A comment gives the cause for this implementation. The previous version used a mean angle. Small texture marks across all angles then gave incorrect errors. The maximum of the angle count identifies the primary structural direction.

**Caveats.**

- The gate does not check an edge with a small number of pixels or a small quantity of structural energy. It accepts when it checks no edge.

- A result without a measurement has `ok=True`, `mean_err=None`, and `reason="no wall edges had enough structure to judge"`. Each edge reports its wall angle and one of two results: `band too small` or `too little structure`. This is an accepted result, but it does not show that the texture follows the walls.

## `texture_checks.py` — `guide`-ink gate

**Goal.** The model can copy reference-image marks as paint. This gate finds floor pixels near `#00FFFF`, `#FF00FF`, or `#00FF00` with high saturation.

**Invariants.**

- The gate rejects when pixels that agree with these color conditions are more than `0.15` percent of floor pixels. Each color condition has high saturation and high brightness.

- The annotation colors are not in the runtime palette. Thus each pixel that agrees with these conditions is paint copied from the reference image. A comment records that previous annotations with warm colors also occurred in rust and warning paint in runtime images. This caused clean textures to receive errors at rates of `0.28..0.46` percent.

**Verification.** Recorded tests include two clean textures that the previous colors flagged incorrectly. They also include recorded leaks: key-color doorway boxes and a painted box outline around a requested `TROUGH` region.

**Implementation.** The gate builds 3 color `masks` in `RGB`: `#00FFFF` (`B` and `G` far above `R`), `#FF00FF` (`R` and `B` far above `G`), and `#00FF00` (`G` far above the other two). It measures their union in the floor `mask`.

**Caveats.**

- Code text gives a previous condition for warm annotation colors, for use with previous assets. But the implementation checks only the 3 colors above. There is no such condition in the implementation.

## `texture_checks.py` — `tone` windows and the `detail` limit

**Goal.** Two style tools keep made floors less visually strong than live props and lighting. `grade_toward` moves each polygon of a type to the same luminance and color range. `verify_detail_budget` rejects floors with more gradient energy than their material swatch.

**Invariants.**

- `in_window` accepts a region with a luminance distance of `14` or less from the type's target window. The distance in each color channel must be `16` or less.

- `grade_toward` moves the masked mean by `strength` times its distance to the target window. It applies gain to each channel, limited to `0.6..1.6`. Outer pixels do not change.

- `verify_detail_budget` measures the mean `Sobel` gradient energy in the `mask`, against the type `swatch`. The `background` limit is `1.25` times the `swatch`. The recorded data: clean polygons measured `0.95..1.16`, the one bad polygon `1.43`.

- With boxes, the function checks the floor and equipment as different regions. In two calibration polygons, box regions measured `1.85..1.98` while their floor regions received correct results at `1.20..1.25`.

**Verification.** The measurements above give the calibration record, and the gate includes `entropy` in its report for subsequent checks.

**Implementation.** `region_tone` returns the mean luminance and mean `RGB` values in a mask. `verify_detail_budget` calculates the gradient and divides the mask when boxes are supplied. It checks box and floor regions against the two thresholds. When `equipment_ratio_thresh` is `None`, the equipment region is always accepted and its measurement is reported only.

A comment records a pipe image that the user approved. It measured `3.2` times the swatch's gradient energy, above noise controls at `2.75..2.81`. The metric thus cannot tell the difference between good equipment and noise. In this mode, the image model checks equipment quality.

**Caveats.**

- `Entropy` is measured and reported only. The comments record that it does not divide good from bad for this style.

## `verify_gemini.py` — the geometry `judge`

**Goal.** One `Gemini` call checks a candidate texture against its reference image and type swatch. It checks 5 conditions: geometry, style, palette, use of the input, and full-bleed coverage. This gate has a cost and runs after local checks.

**Invariants.**

- The verdict is `pass` only when geometry and full-bleed are `True` and 3 or more of the 5 checks are `True`.

- Call failures raise after 3 tries. A response without `JSON` raises with the raw text. The model does not make a verdict when none is in the response.

- Each call records its cost with the output name `verify:<path>`.

**Verification.** The result includes the raw response and cost. A log audit can thus trace each verdict.

**Implementation.** The prompt sends images in this sequence: the `polygon_basetruth.py` image, optional style anchor, and candidate. It tells the model that props are live objects. A painted prop in the texture gives a geometry error.

When the caller supplies `allowed_items`, the prompt adds an exception block. Those named items must occur. Only 3 conditions give an error in this check. They are an item not in the list, a missing necessary item, and walls that moved.

A comment records the cause: the `judge` rejected a correct box-conditioned `texture` for its requested crates. The call parses the one `JSON` object from the response, also when the response wraps it in a code block.

**Caveats.**

- The model prompt contains the damaged text `polygon polygon`. See the prompt-set caveats.

- Defect: the prompt gives the Boolean formula for a `pass` verdict. But `verify_texture` uses the model's `verdict` field without a check. The code does not calculate it again from `geometry_ok`, `fullbleed_ok`, and the 5 check values. A response that does not agree with those values stays in control.

## `box_conditioning.py` — item boxes and prompt notes

**Goal.** Each type's item template becomes pixel boxes in the reference-image frame. It also becomes prompt text that tells the model to put clear equipment in those footprints. The code can also draw boxes on the reference image. But the active mode keeps that image clean and sends text only.

**Invariants.**

- Each box has an inner margin of `BOX_MARGIN_PX = 6` from the bounding box edge and is clipped to the polygon mask. Template regions are flush with the bounding box. A box without this margin can thus overlap a wall line or the outer area. This can cause the model to paint the box or add a wall that is not in the level.

- A box is discarded if one side is shorter than 8 pixels after clipping.

- Annotation colors are `#FF00FF` for `MIRIAD` and `#00FF00` for `TESTATOR`. These values must not occur in the runtime palette. Thus the reference-mark gate can find each leak. A comment records that the previous warm colors did not agree with this condition.

**Verification.** The `guide` dimensions and the `mask` are the only inputs to `compute_item_boxes`. A check of the box list against the template fractions is possible.

**Implementation.** `compute_item_boxes` maps each template region to `pixels` and adds its inner margin. It clips the region to the tight box of `mask` `pixels` in the region. `draw_labeled_boxes` does the same. It also draws the colored rectangles with labels on a copy of the reference image.

`text_zones_note(boxes, w, h)` writes a prompt block with each item's footprint as ranges of percent of the image width and height. For those items only, the list overrides the general requirement for no props. It also does not let outlines occur. `boxes_prompt_note` gives the same information for the mode that draws boxes.

**Caveats.**

- Recorded measurements gave better results for text mode. Reference images with boxes received zero accepted results in tests of 4 and 15 candidates. The model copied box outlines as paint in each annotation color.

## `box_conditioning.py` — item `judge`

**Goal.** After a texture receives a correct stage-2 result, one `Gemini` call checks each requested item. The cut image for each item must show solid equipment that is easy to identify.

**Invariants.**

- When there are no boxes, the function returns `all_present=True` with zero cost and sends no request.

- The call sends the complete texture and one cut image for each box, in box sequence, in one message. One call for all items costs less than one call for each item.

- Errors raise after 3 tries. A response without JSON also raises.

**Verification.** The result rows name each label with a `present` flag and a short note. They also give the raw response and the cost.

**Implementation.** `crop_box_regions` cuts each box from the `texture`. The prompt lists the items with numbers. It accepts a clearly equivalent object. For example, a `bank` of screens can show a console. It tells the `judge` to return one `JSON` object with no other text. The call records its cost as `item_placement:<path>`.

**Caveats.**

- A comment in `crop_box_regions` gives a scale correction between reference-image and texture dimensions, but the function does not scale. Its caller supplies boxes after the change to the texture frame. Thus the comment gives work completed before the call.

- Defect: the item prompt states that `all_present` must agree with the `present` value for each item. The code uses the model's `all_present` field without a check and does not calculate it again.

## `item_layouts.py` — item templates for each type

**Goal.** The module gives item positions as data that many polygons can use. A template for each type lists labeled regions as fractions of the polygon bounding box. Each region has a lane and a short cause for its position.

**Invariants.**

- Regions use the same coordinate-frame convention as `polygon_mask`. Thus the same transform maps fractional regions to pixel boxes.

- `Testator`-only types contain only `TESTATOR` items. `core` is the one recorded mixed type. `validate_lanes` returns the errors, and the module exits with them when run as a script.

- `generic` has no items.

**Verification.** A module run prints the lane check result and the type list. `dump_all_kinds` writes the template as `JSON` for an audit.

**Implementation.** The template includes 14 types. Examples: `dock` has 2 corner crate stacks and a floor lane along the wall. It also has a wall region for the `MOORING RING WALL` item. `hydro` has 2 wall `TROUGH` regions and one center `TROUGH` region.

`chapel` has a `PEW ROW` and a `DAIS`, the two in the `TESTATOR` lane. `polygon_item_layout(kind)` returns the rows as `dict` values. `zone_to_px` maps fractions to `pixels`.

**Caveats.**

- Two item text fields contain the damaged text `stockpolygon` and not `stockroom`. See the prompt-corpus caveats. These strings get to the model through prompt notes.

- `validate_lanes` does not check the `MIRIAD` types, and does not check `core`. The condition only limits `Testator` types, and the check agrees with the condition.

## `decal_plan.py` — the wayfinding exception

**Goal.** The requirement for signs tells the model not to add arrows. It has one limited condition that comes from level data. A polygon with 3 or more connections can contain one arrow on a path to a hub. The arrow points to the doorway that leads to that hub and has a recorded cause for its position.

**Invariants.**

- Arrows follow the BFS result made with all hub polygons (`dock` and `transit` types) as sources.

- Hub polygons, `Testator` polygons, and polygons with no path to a hub get no mark.

- Only polygons with 3 or more connections receive a mark. Without this limit, 115 of 120 polygons on `l01` received an arrow. This caused the previous defect, in which marks occurred across the level.

- A mark falls only on a doorway edge from the level data. A safety check drops others.

**Verification.** The CLI prints a report for one level, or totals with `--all`, and writes `decal_plans.json`.

**Implementation.** `_polygon_graph` builds the connection list from `connects`, `connects_x`, and `doors`. The `BFS` records the next polygon in the direction of the nearest hub. For each marked polygon, the code follows that sequence to the hub polygon. It writes the cause text with the hub type and the hop count.

`decal_prompt_note` makes the prompt block for one polygon's marks. It tells the model that it can add one small, faded floor arrow. The arrow points to the named doorway edge, and its cause is in the text. The prompt tells the model not to add other marks.

**Caveats.**

- `full_run.py` calculates these notes but does not send them to the model. See the caveats for `full_run.py`. No arrow from these notes gets to a texture that the runtime uses.

## `walkmask.py` — `mask` derivation

**Goal.** Each textured polygon receives a `walk-mask` image. `RGB(255, 255, 255)` shows walkable floor, and `RGB(0, 0, 0)` shows painted terrain. The code calculates this mask from item boxes and texture measurements without a model call. The module docstring gives the cause of the error result for a second model call. Such a call makes the cost twice larger and adds a failure mode. The boxes give all necessary information.

**Invariants.**

- `Pixels` not in the polygon `mask` are always `RGB(0, 0, 0)`.

- A box is fully blocked unless texture measurements identify a clear solid shape in it. Measurements can only make that blocked area smaller. They cannot block pixels not in the box.

- If the measured solid is in less than `25` percent of its box, the complete box stays blocked. The mask must not block less area than the requested item has.

- The `mask` file name is `<texture stem>_walkmask.png`, adjacent to the `texture`. The engine loader builds against this name.

**Verification.** The calibration record is on `l03/polygon_0`. Raw thresholds gave spread noise. The `_clean_binary` step turned it into one solid shape.

**Implementation.** `derive_walkmask` starts with the polygon mask marked as walkable. For each box, it measures each pixel's distance from the median brightness in that box and keeps pixels above `max(18, percentile 60)`. A comment states that the object usually makes the largest brightness difference in this style with flat light.

`_clean_binary` uses filters to remove small marks and fill small holes. It then uses a BFS (`_largest_component`) to keep only the largest connected component. A box too small for a gradient check stays fully blocked. The function returns an image with one channel.

**Caveats.**

- The measurement compares brightness only. The gate cannot find a painted item with the same brightness as the floor but a different color. The `25` percent fallback is then the only mechanism that keeps its complete box blocked.

## `walkmask.py` — portal `connectivity` and clearance gates

**Goal.** Two hard gates keep movement safe. The connection gate keeps the doorways in a polygon open and connected. Each route between doorways must have sufficient width for the player's collision circle. In the recorded failure, polygon `112` of `l01` received a correct basic BFS result. But it left a walkable path only about `13` world units wide. A test bot used its full limit of `12 min` there and did not find an exit.

**Invariants.**

- `portal_points_px` samples the midpoint of each doorway edge and moves it 6 pixels to the polygon centroid. This puts the point on the floor and not the boundary.

- The connection gate checks routes between all portal points. Each route uses walkable cells with 4-neighbor movement. It returns the edges that are not connected.

- The clearance radius is `PLAYER_RADIUS + PLAYER_RADIUS` in world units, with the engine constant from `perihelion/sim.py`. This includes an additional player radius as the specified minimum margin. The values are in named module constants and not directly in the formula.

- The clearance gate makes the walkable area smaller by that radius with a square window, then runs the same BFS. A square window removes more space along diagonals than a circular window. Thus the check keeps a larger safety margin.

**Verification.** `check_polygon_portal_clearance` returns the same result structure as the connection check plus the radius used. Functions for a complete level check each mask in that level. The docstring gives the cause for use of local checks. Each doorway connects two polygons. Thus, connections between the doorways in each polygon keep the level graph connected.

**Implementation.** `_bfs_reachable` searches the walkable grid with a queue. `erode_walkable` uses `RankFilter` with dimension `2 * round(radius) + 1`. `clearance_radius_px` changes world units to pixels with `texture_geom.DENSITY`. Its value of `3.0` is the same as the value for the mask frame.

**Caveats.**

- With two or more doorways, a portal point not in the image counts as not
  connected. With less than two doorways, the connection helper returns
  `ok=True` immediately and does not check the one doorway point.

## `gen_kind_materials.py` — type material swatches

**Goal.** One material for each of the 14 polygon types keeps visual continuity across image boundaries. The script makes each swatch and repairs its seams. It checks the seams, full-bleed coverage, and unwanted regular structures. It also records the type's `tone` window.

**Invariants.**

- Each type receives at most two tries. The second prompt names the first try's failure.

- When the two tries receive errors, the tool keeps the candidate selected by the score formula below. Polygon gates then check textures made from that material.

- The `tone` of the written `swatch` goes into `kind_windows.json` as the type window.

**Verification.** The run prints `OK` or `WARN` with cost and try count for each type, and writes the windows file.

**Implementation.** For each type, the script makes an image from `build_material_prompt` and cuts a square from its center. It runs `make_tileable`, then calls `verify_fullbleed`, `verify_tiling`, and `verify_no_repetition`. Failure text comes from the checks that reject it. Worker threads process 7 types at the same time.

The first try becomes the first kept candidate. An accepted candidate replaces a rejected one. When the two candidates have the same result, their error scores control the selection. The new candidate replaces the kept one only if its error score is lower. The first candidate stays when the scores are equal. An accepted result has an error score of zero and ends the loop.

A failure's error score is `max(0, darken_ratio or (0-1)) + max(0, grad_ratio or (0-1)) + max(0, ratio_v-1) + max(0, ratio_h-1) + max(0, (peak_ratio or 0)-repetition_threshold)`. For a nonzero ratio, Python's `or` operation returns that complete ratio. Thus each nonzero full-bleed ratio adds its complete positive value, not only the quantity above one. For a missing or zero ratio, the operation returns `0-1`, which the code limits to zero.

**Caveats.**

- The score formula groups its parts incorrectly. The text above shows the malformed formula that the code runs. The code does not show that this is the correct distance score.

- The reported `cost` and `attempt` identify the selected candidate and not the complete run. If the two tries run, the result does not add their costs. It can report try 1 when try 2 has a higher error score.

- A type that raises in its worker prints `FAIL` and does not update its `tone`
  window. The command reports the error count but exits 0.

## `gen_anchors.py` — unused style anchor candidates

**Goal.** This script is no longer in use. It is part of the anchor-polygon method that type materials replaced. It made one style-anchor image for each type from an anchor map and the polygon reference image.

**Invariants.** No invariant applies because the module cannot run.

**Verification.** An import test stops immediately with an error.

**Implementation.** The script reads `anchor_map.json` from the temporary work directory at import time. Worker threads then make one candidate image for each type with `build_anchor_prompt` and two reference images.

**Caveats.**

- Defect: the import of `build_anchor_prompt` from `pilot_texture_lib` names a function that is not in that module. Each run of this script stops with `ImportError`. The second `pipeline` version replaced anchors with type materials, and the function was removed, but this script stayed.

- The anchor map read at import time adds a second break when the temporary directory is gone.

## `gen_pilot_textures.py` — `pilot` `driver` 1 (not in use)

**Goal.** This first `pilot` program makes a texture for each `pilot` polygon from the type's anchor image and reference image. It checks the texture with `Gemini`, makes another attempt if necessary, processes accepted output, and writes it. `gen_pilot_textures_v2.py` replaced this program.

**Invariants.**

- A polygon can be the anchor polygon of its type. It then uses the accepted anchor image as its `texture`, with no model calls.

- If the two tries are rejected, the runtime uses no texture and keeps the flat engine floor.

- Progress stays on disk for each polygon. Thus a subsequent run does not process completed work and does not add its cost again.

**Verification.** The run prints one line for each polygon with `status` and cost, and writes `pilot_verify.json`.

**Implementation.** For each polygon, the program makes the reference image if its file is not available and builds the prompt. It calls `generate_image` with the reference image and anchor, then calls `verify_texture`. After an accepted result, it resizes the image, applies the polygon mask, and writes the texture. The second try's prompt includes notes from the first verdict. The script runs 7 worker threads.

**Caveats.**

- This program has none of the local validation gates and uses only the model gate. This missing stage caused the second program version.

- It reads `anchor_map.json` from the temporary work directory at import time, with the same break risk as `gen_anchors.py`.

## `gen_pilot_textures_v2.py` — `pilot` `driver` 2

**Goal.** The second `pilot` program runs local gates before the model gate. It supplies neighbor continuity through the composite and keeps `tone` windows. The code applies the polygon mask. It does not tell the model to paint that mask.

**Invariants.**

- Each try calls these gates in sequence: `verify_fullbleed`, `verify_no_interior_void`, `verify_shape`, `verify_no_guide_ink`, `verify_detail_budget`, and `verify_texture`. Each reject writes a note with the measured values, and the prompt of the next try includes that note.

- Each polygon receives at most 3 tries. If each try is rejected, the runtime receives the polygon without a texture. The code removes each texture left by the previous process. A rejected polygon cannot keep a rejected image.

- Sample runs use one worker and a BFS neighbor sequence. This lets composites include neighbors completed previously in the run.

- `Pass 2` keeps accepted results. An accepted polygon with a record that includes a neighbor composite receives no new image. Previously, each run made completed polygons again. Thus, the set could not get to a stable state.

- `Pass 2` keeps a copy of the `pass 1` result. If the new image is rejected, the code puts back the accepted `pass 1` texture and result with a note.

**Verification.** The run prints `status` and cost for each polygon and writes `pilot_verify_v2.json`. A comment contains the calibration values for the recorded `darken_thresh` change from `1.30` to `1.55`.

**Implementation.** `process_polygon` builds the reference image and composite and calls the model with them. It removes the `RGB(0, 0, 0)` margin, resizes to the target texture dimensions, and runs the gate chain. After an accepted result, `postprocess_and_save` removes the margin again and resizes the image. It adjusts luminance and color values not in the type window, applies the polygon mask, and writes the texture. It writes an audit overlay adjacent to the texture.

`_bfs_order` puts polygons in level sequence and puts each neighbor after the polygon that found it. `main` uses `--sample` for the internal sample list and `--only-keys` for an external batch on the same code path. It also uses `--only-kind`, `--limit`, and `--polygons` to clear progress. After the first run phase, sample runs build a list for the second phase. It contains polygons that have a sampled neighbor but do not have an accepted record with a neighbor composite.

**Caveats.**

- The `--polygons` flag clears progress but does not limit the run's scope. `full_run.py` corrects this operation and records the cause in a comment.

- This file records the measurements that caused the gate for regular structure at polygon level to be off. See the unit about seam checks.

## `full_run.py` — polygon processor, two stages

**Goal.** This last program processes each polygon in the manifest. Stage 1 makes a bare floor with the same process that gave accepted `pilot` floors. Stage 2 uses a call that changes an image to add requested equipment to the accepted floor. In recorded tests, one output for equipment and floor broke the silhouette. It gave zero accepted results across 3 tests. Floor-only prompts gave about `57` percent accepted results.

**Invariants.**

- Stage 1 runs the complete floor-only gate chain with at most 3 tries. After a failure, the runtime uses a bare polygon. No texture stays on disk, previous texture and mask files are removed, and the `status` is recorded. The runtime must not use a texture that a gate rejected.

- Stage 2 puts model output only in item boxes with an additional margin. A `blur` at the edge mixes that output with the accepted stage-1 floor. Thus the accepted stage-1 pixels stay out of the item regions. These pixels cannot get a new floor-gate error. New complete images received floor-gate errors on all 31 test polygons. For some of them, a human reviewer accepted the equipment despite those floor-gate failures.

- Stage 2 checks the composite for reference-mark colors and requested items. It also uses different gradient-energy limits. The equipment limit is off because the model gate does that check. Stage 2 has two tries. If the two tries are not accepted, the runtime uses only the stage-1 floor.

- The walk mask uses item boxes only when stage 2 painted equipment. It must receive correct results from the connection and clearance checks. Subsequent tries make boxes smaller by `0`, `20`, and `40` percent. If no try is accepted, the runtime uses the texture without a mask file. The engine contract then applies a state in which all pixels are walkable.

- An accepted or bare polygon does not change again. A new run does not touch it unless `--polygons` clears it.

**Verification.** The progress file records `status`, cost, verdicts, equipment state, `mask` state, and the audit overlay path for each polygon.

**Implementation.** `process_polygon` builds the `guide`, the boxes, the box note, the decal note, and the neighbor composite. Stage 1 uses the floor-only prompt, with no box note and no decal note. Each rejected try adds the last verdict notes to the prompt.

Stage 2 builds `_stage2_prompt` with the complete floor as its reference. The requested output is the same image with only the listed items added. `_composite_equipment` makes a mask from the boxes with `14` more pixels and an `8`-pixel `blur` at the edge. It uses this mask to put stage 2 on stage 1. The item model gate checks this composite.

After an accepted result, the code writes the texture and audit overlay. It then runs the mask chain through `portal_points_px`, `derive_walkmask`, and the two movement gates.

**Caveats.**

- Defect: although the module goal includes decal data, no decal note gets to the two prompts. Stage 1 and stage 2 each send an empty note. A comment states that the equipment composite removes a doorway mark that is not in the item boxes.

  The code has no decal operation after the composite. Thus, no decal operation can put the mark back. Calculated decal notes are data that the code does not use, and the runtime receives no route arrow.

- Defect: stage 1 applies local gates to the cut and resized candidate. But `verify_texture` receives the made file before those changes. Thus, the model gate and the texture written to disk can have different dimensions and cuts.

- Defect: when each `walk-mask` try returns an error, the code records `mask_status="omitted"` but does not remove a previous mask file. Thus, a requested new build can keep an incorrect mask on disk while progress states that no mask was made.

- `pilot_polygons.json` has dimension data only for `pilot` polygons. Other polygons calculate mask-frame dimensions with the same scale as the engine. Thus, those dimensions agree.

## `full_run.py` — the run `driver`

**Goal.** The program goes through the manifest in neighbor sequence and processes polygons in worker threads. It stops new work at a cost limit.

**Invariants.**

- `--polygons` clears progress for the named keys and limits the run to those keys. Previously, the flag cleared progress but did not limit the scope. This let a small test batch continue into a level that the command did not name.

- The program keeps a maximum of `2 * --workers` polygons active. With `--budget`, it stops new polygon starts when the reported run cost gets to the limit. Work that it sent before this condition completes. A maximum of `2 * workers - 1` polygons can stay active when the program finds the limit.

- Each run adds one report row to `full_run_log.json`.

**Verification.** The run prints one line for each polygon with `status`, `mask` state, cost, and run total. It then prints the report `JSON`.

**Implementation.** `load_manifest_polygons` reads the manifest and returns each level's polygons in the recorded neighbor sequence. The program sends polygons without results to a thread pool with a set work limit. It collects each result and submits another task after each completed task.

**Caveats.**

- If work on a polygon raises an exception, no progress is recorded and the next run tries that polygon again.

- A worker exception does not make the command exit nonzero. The report counts
  that worker in `n_processed`, but has no exception count. It adds no cost for
  work completed before the exception.

- The repository manifest includes `vigil`, but there is no `levels/vigil.json`. A run that gets to a `vigil` polygon without a result stops with an error when it loads that level. Decision open (see `spec/open-questions.md`, item `SOUNDART-VIGIL-SCOPE`).

## `manifest.py` — full-run manifest and cost model

**Goal.** Before a full run, the user gets a cost estimate and a work manifest. The manifest includes each polygon in 11 levels. It records the lane, items, decal marks, and neighbor sequence. The recorded call log supplies the estimate data. This script makes the manifest. It does not make or remove textures.

**Invariants.**

- Cost values come from the rows of `cost_log.json`, divided by call class. The `retry` rate uses the 14 accepted `pilot` polygons. These are the only polygons with a complete record of try counts.

- Polygons without item boxes have no item model-check call.

- The output states that the small sample gives an estimate with low precision. It requests a new measurement after the first 50 polygons.

**Verification.** The printed report contains the log counts, the costs for each try, and the total estimate. The inputs are open to an audit.

**Implementation.** `_cost_history` groups log rows by call class. Image-call rows contain a cost. Their output names do not contain `verify`, `audit`, or `item_placement`. Model-check rows start with `verify:`, and item rows contain `item_placement`. The function calculates each class's mean and uses set defaults for empty classes.

`build_manifest` goes through each level and puts together polygon types, item templates, decal marks, and BFS sequence. For polygons with boxes, the cost for one try includes an image call and the two model checks. One check is for geometry, and one is for items. Polygons without boxes do not include the item check cost. It multiplies these totals by the mean try count in accepted polygons. An arrow audit cost uses the accepted fraction in the sample.

**Caveats.**

- Defect: the image-call class also includes doorway-check rows. Their names start with `insitu:`. These model calls have a low cost and decrease the calculated mean for image calls. This makes the estimate too low.

- Defect: the cost formula applies to the previous process, which has one stage. The active full run can add 2 stage-2 image calls. It adds them only after stage 1 is accepted. The estimate does not include those calls. It charges one item check call for each estimated try. Thus, it cannot show the active call sequence.

- The docstring gives the log count as `2257` calls. The value becomes incorrect as the log becomes larger.

- Defect: `LEVEL_STEMS` includes `vigil`, but there is no `levels/vigil.json`. A new manifest build cannot make the repository manifest again. Decision open (see `spec/open-questions.md`, item `SOUNDART-VIGIL-SCOPE`).

## `calibrate_v3.py` — v3 calibration `driver`

**Goal.** A small batch with a call cost shows 3 new stages as one sequence on this calibration gate stack. They are boxes with labels on the schematic, walk mask calculation, and the decal exception. Output goes only to audit directories and does not change textures used by the engine.

**Invariants.**

- A cached schematic is necessary. The run stops with a clear error if the cache has no schematic.

- Each gate result, with costs and the box and mark counts, goes into `calibration_v3_report.json`. Audit copies of the `texture`, the schematic with boxes, and the walk mask go below `tools/artgen/review/`.

**Verification.** The report file and audit images show the results. `overall_ok` puts together all gate results and gives the last result.

**Implementation.** For each named polygon, the script draws boxes with labels on a copy of the schematic. It then builds a prompt with box and decal notes. It makes one image with the boxed schematic and material as references. It then checks full-bleed coverage, the internal empty area, and marks from the schematic.

It also runs `verify_detail_budget` with boxes. The geometry model check uses `allowed_items`. The item model check, walk mask calculation, and `connectivity` check follow.

**Caveats.**

- This script uses the mode that draws boxes, and it records failures from that mode. The full run subsequently replaced it with regions in the prompt text.

- It does not run `verify_shape_conformance`, although the `pilot` and full run
  floor stacks do.

- It checks `connectivity` but not clearance. The clearance gate was added after this script was complete.

## `audit_clearance.py` — product `mask` clearance audit

**Goal.** The clearance gate was added after the masks on disk were made. This audit thus checks each walk mask on disk and reports failures for repair.

**Invariants.**

- Only polygons with `status` value `accepted` and mask `status` value `shipped` are checked. If such a record has no mask file on disk, the audit records a failure and its cause.

- The audit writes `clearance_audit.json` with a report and the full results.

**Verification.** The printed counts, failure list, and report file show the audit result.

**Implementation.** The audit walks `full_run_progress.json`, loads each `mask` image, samples the portal points, and runs `check_polygon_portal_clearance`.

**Caveats.**

- Defect: the docstring's use examples give a `--fix` flag that the argument parser does not give. `regen_clearance_masks.py` does the repairs.

- Reported clearance failures do not change the process exit `status`. The
  command exits 0 after it writes and prints the failure list.

## `regen_clearance_masks.py` — `mask`-only repair

**Goal.** For each polygon with a clearance audit failure, calculate the walk mask again. Use a wider list of box offsets. The repair makes no model calls and does not change textures.

**Invariants.**

- The offset list is `0`, `20`, `40`, `60`, and `80` percent. A last try has no boxes. Each candidate must have correct `connectivity` and clearance results.

- If no candidate has correct results, the code removes the mask file. The engine then uses no mask for that polygon. By the engine contract, the engine adds no terrain blockage in that polygon. Polygon boundaries and normal collision checks continue to apply. Thus, this fallback cannot make a mask that incorrectly blocks terrain. See the texture-load contract in `spec/rendering.md`.

- The progress file records the new `mask` state for each repaired polygon.

**Verification.** The printed line for each polygon gives its end state and `inset`. The printed totals give the complete result.

**Implementation.** For each audit failure, the script gets item boxes from the schematic and scales them to the texture dimensions. It builds and checks a mask at each offset step. The last step has no boxes and uses only the bare polygon.

**Caveats.**

- A schematic is necessary for box geometry. If the cache has none, the script makes it again from level data. The disk texture is the only other process artifact this script uses.

## `verify_in_situ.py` — the in-situ doorway gate

**Goal.** Continuity is checked in a live Perihelion view. The script renders connected pairs of textured polygons through the production renderer at gameplay and wide zoom. It then sends the model a request to check floor continuity across the doorway.

**Invariants.**

- Frames come from `Renderer.draw` with a live `GameSession`, production portal visibility, and the production texture-load path. They are not synthetic composites.

- Each doorway pair is checked once. Doors open before the frames are made. The doorway then shows floor and not a closed door.

- The model returns `continuous_floor`, `no_negative_space`, `geometry_consistent`, `verdict`, and `notes`. `continuous_floor` checks color, brightness, material continuity, and seams at the threshold. It accepts a specified threshold transition. `no_negative_space` checks painted borders, vignettes, margins with low brightness, and raised bands adjacent to walls. These defects make the floor stop short. `geometry_consistent` checks items with no contact with a surface and malformed wall or item shapes.

- The prompt lets the model give a `pass` verdict only when `continuous_floor` and `no_negative_space` are `true`. The formula does not use `geometry_consistent` or `notes`. Defect: the model supplies the verdict, and the code does not calculate it again from the Boolean fields. If the verdict does not agree with those fields, the verdict controls the result.

- Results are kept on disk for each pair. Subsequent runs check only pairs without a result on disk.

**Verification.** Verdict inputs are the set model prompt and 2 live frames. One frame is `480 x 270` at zoom `1.35`. The other is `960 x 540` at zoom `0.55`. The two frames use the same camera position and doorway state. Pair screenshots in the temporary directory and `insitu_verify.json` show the audit data. The JSON records all 3 checks, the verdict, and notes for each pair.

**Implementation.** `_textured_polygons` collects `pilot` polygons that have a texture on disk. `_find_boundary_pairs` reads `connects`, `connects_x`, and `doors` and emits each textured pair once. `render_pair` puts the camera near the edge between the pair. It applies an offset of `20` percent to the first polygon's centroid and renders the two zoom levels.

`judge_pair` sends the two screenshots with the 3-check prompt and parses the JSON response. Costs are recorded as `insitu:<pair>`. The script processes pairs in worker threads. It writes the complete result file again after each pair is complete.

**Caveats.**

- If the model check for a pair raises an exception, the tool records an error verdict. Its short name does not include the door identifier. On the next run, the complete door-pair name does not agree with that record. The pair is then checked again.

- `fail` and `error` verdicts do not change the process exit `status`. A completed
  run exits 0. Callers must examine `insitu_verify.json` or the printed totals.

- The manifest cost model puts these rows in the image-call class. See the manifest caveats.

## `repair_insitu.py` — in-situ repair `pass`

**Goal.** A polygon on a doorway boundary that the model rejected gets one repair try. The repair changes the engine texture to the brightness range for its type. It then runs the same doorway check again. If one new check rejects the polygon, the engine gets no texture for it. A rejected texture must not stay at the engine path.

**Invariants.**

- The repair prompt locks the model to the geometry of the active `texture`. It changes only brightness and material continuity.

- The repair candidate must have a correct full-bleed result. If its brightness is not in the type window, the process applies a brightness adjustment to that window with `strength 0.8`.

- A polygon's target pairs are the pair names attached by `_flagged_polygons`. This function includes each recorded boundary with a verdict other than `pass`. This includes the two values `fail` and `error`. It attaches each pair to the two endpoint polygons when the row contains the level and endpoints.

  The function assembles the complete target-pair list before repairs start. Completed repairs do not change it. Only listed pairs are checked again. If one new verdict is not `pass`, the code removes the repaired polygon's texture file.

- The repair log records each polygon once. Subsequent runs do not change logged polygons.

**Verification.** `insitu_repair.json` gives the end state for each polygon in the list.

**Implementation.** `_flagged_polygons` collects each polygon on a boundary without a `pass` verdict. For each polygon, the tool sends one request to change an image. It uses the active texture as its only reference. It applies the gates and brightness adjustment. It masks the image and writes it to the engine path with an adjacent auxiliary copy.

It then compares each target-pair name with the active level graph and finds its target. A missing target gets no new model result and does not count as a failure. For each found target, it renders and checks the active textures of the two endpoints. If all results have verdict `pass`, the code removes the auxiliary copy.

If one result is not `pass`, the code removes the repaired texture and its auxiliary copy. The flat engine floor stays. A previous repair or removal in the run can thus change the result of a subsequent pair.

**Caveats.**

- The auxiliary copy is used only during repair. If the repaired texture is rejected, the tool removes the repair and the previous accepted texture. The auxiliary copy contains that previous texture. This is the specified result. The boundary model check rejected the repaired result. The previous texture did not get a `pass` verdict from the initial boundary check.

- Defect: after an image-call error or an incorrect `full-bleed` result, the function returns. It keeps the texture made before the repair. That texture failed the initial doorway check.

- Defect: a target pair that cannot be found gets no new model result and does not count as a failure. If the active textured graph has none of the target pairs, the repair texture is recorded as repaired. This record then has no new doorway verdict.

- One line reads `insitu.OUT_PATH` and gives the result to a local name. The code does not use that name. This line is a note about the data source.

- A repair exception records `status="repair_error"`, and the `driver` continues.
  These rows do not make the process exit nonzero.

## `verify_in_context.py` — menu art in context

**Goal.** Menu images are checked in production menu scenes. The script draws those scenes into buffers at Perihelion's internal render dimensions. It includes production text on accepted images and writes screenshots for audits of text, style, and seams.

**Invariants.**

- The scenes are the live classes from `perihelion/menus.py`. They are the heading, death, `WinScene` at the start, `WinScene` after vertical movement, and the 4 `IntroCard` scenes. The app object is a bare stub, which the scenes accept.

- The buffers use Perihelion's internal `render` dimensions.

**Verification.** One written screenshot for each scene state shows the result. The screenshots are below the temporary directory.

**Implementation.** `_shot` runs a scene for a specified number of update ticks at `60` `Hz`. It draws the scene into a new buffer and writes a `PNG`. `WinScene` is rendered once at the start and again after `180` ticks of vertical movement. Each `IntroCard` is rendered at tick `90` with sample text.

**Caveats.**

- Screenshots are written to the set temporary directory. See the geometry unit's caveats for `SCRATCH`.

## `verify_sprite_in_context.py` — `sprite` `judge` in context

**Goal.** A candidate sprite is checked in a supplied scene image and not in an empty image. The function composites the sprite at the requested position and dimensions. It writes the composite to the caller's output path and sends the model a request for a probability.

**Invariants.**

- The prompt requests `p_shippable` in `0..1` with named checks. The sprite must show one object. It must fit the `palette` and `silhouette`, and its alpha must have no outer colored border. The code parses the returned `JSON` but does not check its fields or the `probability` range.

- The prompt tells the model to list the signs in the image first. Each reported defect must agree with that list.

- If each of 3 tries has an error, the call returns a clear error result with `p_shippable=None`. It does not change an error into a verdict.

**Verification.** The composite `PNG` writes at the caller's `composite_out` path. The result contains the parsed checks and report when the model supplies them.

**Implementation.** `composite` scales the sprite to the target width and keeps the ratio of width to height. It composites the sprite with alpha on the scene image at the specified center point. It writes RGB output. `_ask` sends the composite with the specfile text at `temperature 0.2`. It parses the JSON response and records the cost. The CLI uses the same path.

**Caveats.**

- The module keeps different copies of the model name and API location string. It does not use the constants in `gen.py`.

## `verify_arrow_signage.py` — arrow audit for previous `textures`

**Goal.** This audit checks engine textures for baked arrows and pointed marks. It also checks for painted text that can be read. Perihelion's production decal types are limited to `blood`, `splat`, `chip`, `scorch`, and body shapes after death. A texture with a direction mark thus has an image-model defect.

**Invariants.**

- Each call gets one image and no `base truth` image. This is a defect audit and not a geometry check.

- Bare diagonal hazard stripes without a point are accepted. Only pointed marks and text characters set the flag.

- The result contains a `confidence` level and a position note. Errors raise after 3 tries.

**Verification.** The result `JSON` for each `texture` and cost rows named `arrow_audit:<path>` show the results.

**Implementation.** The script uses the same `OpenRouter` call procedure as the other model checks. It sends a prompt with one image and gets a JSON response.

**Caveats.** None.

## `polygon_basetruth.py` — `base truth` `renders`

**Goal.** For each `pilot` polygon, render the specified floor as a flat image in the polygon's local frame. Use 3 pixels for each world unit. This image gives the geometry that the image model will render again.

**Invariants.**

- The render fills the polygon shape with its floor color from the production `Renderer`. Pixels not in the polygon stay `#000000`.

- The render does not include props because the user specified this. A long comment records the user's correction that a texture shows floor material, not an image of scene data. Perihelion draws props on the floor in each frame. A solid prop blocks its baked copy from view. A thin prop shows parts of that copy as a second image.

- A polygon index out of range records a failure row. The script continues, prints all failures, and exits with `1` when the failure list is not empty.

**Verification.** The printed `JSON` gives the written count and the failure list.

**Implementation.** For each level with `pilot` polygons, the script loads the level and makes a session and `Renderer`. It fills each polygon shape with its floor color in a new buffer and writes the `PNG` through `necore`.

**Caveats.**

- A comment gives a possible subsequent method. It can replace props with painted marks that have labels, and the comment calls it satisfactory. This module contains no code for that method. `box_conditioning.py` subsequently added item boxes.

- The module docstring incorrectly states that the `base truth` includes small drawing primitives and props. As specified, `render_polygon` draws only the floor fill.

## `polygon_census.py` — polygon type census

**Goal.** Give one count report for the complete polygon set in the 10 levels plus `vigil`. Group it by type and level, and include bounding box dimensions. Do not include the demo and test levels listed in the docstring.

**Invariants.**

- The level list is `l01..l10` plus `vigil`, the same set as the manifest.

- Dimensions are `bounding box` dimensions in world units, because a `texture` fills the `bounding box`.

**Verification.** The printed `JSON` and the table on the error stream give the total count.

**Implementation.** The script loads each level, groups polygons by type, and prints counts, ranges, and medians.

**Caveats.**

- Defect: `LEVEL_FILES` includes `vigil`, but there is no `levels/vigil.json`. The script raises `FileNotFoundError` after it loads `l01` through `l10` and prints no report. Decision open (see `spec/open-questions.md`, item `SOUNDART-VIGIL-SCOPE`).
