---
ste_exempt: true
ste_exempt_reason: This is the owner's decision surface. It preserves precise alternatives and proposed product language for ratification.
---

# Open decisions

These proposals are part of the warm-start review, not descriptions of current behavior. Unless the owner vetoes or edits an item, the proposed answer is the recommended specification for a later change. Each proposal names the standing principle or applied standard from which it follows.

## Runtime and simulation

### ADVERSARY-DOORWAY-HOLD — How must an enemy leave a stalled doorway hold?

Question: What should happen when danger remains high but no peers arrive and `MUSTER` cannot reach its release threshold?

Proposed answer: Give the hold a finite timeout. After the timeout, re-evaluate available routes and either advance along the least-dangerous route when the player is actionable or retreat to a lower-danger chamber. Emit a diagnostic transition so playtest tools can distinguish the two outcomes. Derived from responsiveness, avoidance of permanent non-progress states, and truthful telemetry.

### SIM-CHARGED-BURST — What does a full charge mean?

Question: Is an 80-tick charge the threshold that enables the full burst, with power and ammunition cost still determined at contact?

Proposed answer: Yes. Define “full charge” as the 80-tick threshold, then retain the existing contact-time power and ammunition calculation. This separates the eligibility threshold from the result and avoids an unnecessary mechanical rewrite. Derived from preserving observable behavior unless it conflicts with an explicit goal.

### SIM-WARDEN-HOLD — What ends a warden hold?

Question: Can a hold end when the warden dies, the player dies, or the capture system explicitly releases the body?

Proposed answer: Yes. All three are valid terminal states. The goal should describe release as the general rule and warden death as the normal combat route. Derived from recoverable state transitions and truthful specification of existing behavior.

### SIM-VISIBILITY-SIDE-EFFECTS — May a visibility query change simulation state?

Question: May renderer arguments change the player-light state that later affects `flicker` behavior?

Proposed answer: No. A visibility query should be observational. Move player-light updates to an explicit simulation operation so rendering frequency and camera choices cannot change gameplay. Derived from deterministic behavior, separation of presentation from simulation, and testability.

### SHELL-NEW-GAME-PLUS — Which weapons begin New Game+?

Question: Should New Game+ preserve exactly the weapons in the completed save, or grant the complete weapon set?

Proposed answer: Preserve exactly the saved weapon set. New Game+ should continue the completed state unless the product explicitly advertises a different reward. Derived from user-control and state-preservation principles.

## Audio and music

### AUDIO-CONSTRUCTION-MUTE — Can construction-time mute be removed later?

Question: Is `mute=True` a permanent headless mode, or must `set_mute(False)` create the mixer and load the bank?

Proposed answer: Treat it as a run-time mute state. Removing mute must initialize audio and restore normal operation. A separate explicit headless option should represent permanent absence of audio. Derived from truthful controls and reversible user actions.

### AUDIO-MULTICHANNEL — How should input with more than two channels behave?

Question: Should the loader reject it, select two channels, or downmix it?

Proposed answer: Reject it with a clear error until a documented downmix is implemented. Silent channel selection or an unspecified mix can corrupt authored audio. Derived from failure visibility and preservation of source meaning.

### AUDIO-UNREACHABLE-ENEMY — Does an unreachable enemy affect music?

Question: Should an engaged enemy with no portal route count as a far enemy?

Proposed answer: Omit it from the immediate music-pressure input. “Unreachable” is not a distance class, and treating it as merely far can create pressure with no actionable threat. Derived from semantic accuracy and legible feedback.

### AUDIO-UNKNOWN-ENEMY — What happens for an unknown enemy record?

Question: Should music processing stop, silently ignore the record, or report it?

Proposed answer: Report the bad record through diagnostics and ignore only that record for the current update. Do not stop all music. Derived from graceful degradation plus failure visibility.

### AUDIO-CROSSFADE-LAW — What must the lead crossfade preserve?

Question: Should it preserve squared gain, amplitude sum, or perceived loudness for correlated stems?

Proposed answer: Preserve amplitude sum for correlated stems. This prevents the same musical material from becoming louder at the midpoint. Derived from perceptual continuity and the known correlation of the two lead sources.

### AUDIO-HOLY-TAIL — What happens when a new form change arrives during a tail?

Question: Should the new tail replace the active tail, wait behind it, or be suppressed?

Proposed answer: Replace the active tail with a short click-free fade. The newest form is the truthful state, while an unbounded queue would play obsolete transitions. Derived from timely feedback and perceptual continuity.

### AUDIO-RESET-STATE — Which music state survives `stop` or death?

Question: Which decision state resets, and which state persists?

Proposed answer: `stop` must reset transient playback and decision state, including form, latches, rate history, pending decode results, lane state, and the bar clock. Persist only explicitly authored long-term progression outside `MusicSystem`. Death should call the same clean reset before the next run. Derived from predictable restart behavior and prevention of stale asynchronous state.

## Rendering and narrative UI

### RENDER-ASPECT-RATIO — How should non-16:9 output behave?

Question: Should the renderer accept it with width-based scale, reject it, letterbox it, or crop it?

Proposed answer: Preserve the complete 16:9 view with letterboxing or pillarboxing. Do not distort or crop gameplay information. Derived from the UX standard's accessibility and information-preservation requirements.

### RENDER-DESCENT-SEAM — What proves the level-descent boundary is visually continuous?

Question: Is human visual approval sufficient, or must the requirement have a numeric threshold?

Proposed answer: Use a repeatable image comparison at the boundary plus human review. Record a baseline and fail on a material pixel discontinuity outside the intended transition effect. Derived from reproducible evidence and the fact that the requirement is visual.

### RENDER-POLYGON-ORIGIN — Which center represents an irregular polygon?

Question: Should local effects use the arithmetic mean of vertices or the area centroid?

Proposed answer: Use the area centroid for filled-region placement. The arithmetic mean depends on vertex sampling and can move without a shape change. Derived from geometric meaning and stable authoring behavior.

### RENDER-AGGRO-RINGS — Which rings represent aggro?

Question: Should all historical ring shapes remain, or only the expanding white event-ring pair?

Proposed answer: Keep one consistent expanding white pair for aggro. Other rings should retain distinct meanings so the display does not overload one signal. Derived from perceptual discriminability and interface consistency.

### RENDER-SNAPSHOT-OWNERSHIP — May renderer results share mutable storage?

Question: Should each draw call return a new snapshot, or may later calls overwrite earlier returned arrays?

Proposed answer: Return an independent immutable snapshot, or explicitly name and type the result as a borrowed transient view. Prefer the independent snapshot at the public boundary. Derived from least-surprise API behavior and data integrity.

### RENDER-WIDE-CONE — What happens when a cone's total arc is at least pi?

Question: Should the renderer reject it, clamp it, or draw it without a limit?

Proposed answer: Reject a total arc at or above pi with a clear error. Such a cone no longer has an unambiguous directional wedge. Derived from input validation and semantic clarity.

### RENDER-POD-PULSE — Do pod pulses continue after roots are fully grown?

Question: Should the completed structure still pulse?

Proposed answer: Stop the construction pulse when roots become complete. Any later pulse must have a separately specified gameplay meaning. Derived from truthful status feedback.

### RENDER-STATIC-LIGHTS — Must static lights refresh after topology changes?

Question: Should static and attached lights both follow opened and sealed routes?

Proposed answer: Yes. Invalidate and rebuild every affected light cache after a topology change. A light's attachment type must not make visibility stale. Derived from visual truthfulness and consistency.

### NARRATIVE-LAYOUT-SLEEP — Must large live layouts become bitwise still?

Question: Is bounded subpixel motion acceptable on target-scale graphs?

Proposed answer: Require perceptual stability, not bitwise identity. Define a displacement and duration threshold below which the layout is at rest, then stop updates. Derived from avoiding needless work while preventing visible jitter.

### NARRATIVE-LABEL-FALLBACK — What happens when no collision-free selected label position exists?

Question: Should the UI show overlap, hide the label, or use another presentation?

Proposed answer: Keep the selected label visible and use a leader line to the nearest collision-free position. Never hide the selected item or silently overlap unreadable content. Derived from focus visibility and accessibility.

### NARRATIVE-CHOICE-COUNT — How many posture-form choices are valid?

Question: Must a posture-form choice contain exactly two options?

Proposed answer: Permit two or three options and reject all other counts during content validation. The renderer and input already expose three selections, and accepting invisible options is unsafe. Derived from complete operability and early validation.

## Probe and playtest tools

### SOUNDART-VIGIL-SCOPE — Is `vigil` still in the texture pipeline?

Question: Should `levels/vigil.json` be restored, or should `vigil` be removed from `LEVEL_STEMS`, `LEVEL_FILES`, and the checked-in texture manifest?

Proposed answer: Remove `vigil` from the active pipeline and regenerate the manifest unless the level is restored as shipped campaign content. A required input that does not exist makes the census and full pipeline irreproducible. Derived from reproducibility and truthful scope.

### PROBE-LIGHT-SHAPE — Which aperture shape is authoritative?

Question: Should the sharp patch remain circular or use the recorded airlock aperture geometry?

Proposed answer: Use the aperture geometry and its recorded dimensions. The probe should test the authored shape it claims to represent. Derived from fidelity of evaluation artifacts.

### PROBE-EFFECT-THREE — Must effect 3 animate?

Question: Is its constant image intentional?

Proposed answer: Keep it constant unless the design brief assigns motion a communicative purpose. Animation should not be added only to make the probe busier. Derived from purposeful motion and reduced distraction.

### PROBE-OVERWRITE — May the command replace its three outputs without confirmation?

Question: Should an existing result require an explicit flag?

Proposed answer: Require `--force` to replace existing files. Derived from recoverability and prevention of accidental data loss.

### PROBE-FFMPEG-FAILURE — How must encoding failure surface?

Question: Must FFmpeg failure produce visible diagnostics and a nonzero process result?

Proposed answer: Yes. Preserve stderr, return nonzero, omit success text, and clean incomplete output where safe. Derived from failure visibility and truthful status.

### PROBE-SECOND-ARC — Is the second arc accepted art direction?

Question: Is it final enough to act as a specification reference?

Proposed answer: Treat it as exploratory, not accepted art direction, until the owner explicitly approves its appearance. Derived from avoiding accidental ratification of a probe artifact.

### PLAYTEST-CAMPAIGN-EXIT — Must a failed campaign return nonzero?

Question: Should automation distinguish a failed campaign from a clear?

Proposed answer: Yes. Return zero only for a clear and nonzero for a failed campaign or tool error. Derived from composable command-line behavior and truthful status.

### PLAYTEST-TIME-UNION — May graph analysis use the union of topology over time?

Question: Is that approximation acceptable when breaches change adjacency?

Proposed answer: No for claims about a particular sample. Record topology revisions or per-sample adjacency. A union can remain as a separately named exploratory metric. Derived from measurement validity.

### PLAYTEST-SAMPLE-INTERVAL — What happens when the requested interval does not divide the run?

Question: Should sampling be uneven, fail, or use a rounded interval?

Proposed answer: Preserve the requested cadence and include the final partial interval with its actual timestamp. Do not silently change the cadence. Derived from measurement transparency.

### PLAYTEST-MODEL-FAILURE — Must a scan fail when every model call fails?

Question: Is an empty successful JSON result acceptable?

Proposed answer: No. Return nonzero and retain diagnostics when no model produced a valid result. Derived from failure visibility and prevention of vacuous success.

### PLAYTEST-SHORT-VERDICT — Must short demo modes apply a verdict?

Question: Are still-image modes evidence-only or pass/fail gates?

Proposed answer: Treat short modes as evidence generation and label them clearly as non-gating. A separate explicit option may apply a suitable still-image verdict. Derived from truthful status and avoidance of incomplete gate claims.

## Test policy

### TEST-SKIP-POLICY — Which skipped tests are permitted?

Question: May the full check finish successfully with skipped tests?

Proposed answer: Permit skips only for tests explicitly classified as optional hardware, external-service, or artifact-generation checks. The default full check must report every skip and fail on any unclassified skip. A release or receipt gate must select and require all applicable capabilities. Derived from visible coverage, reproducibility, and prevention of silent test loss.

### MARROW-DISPATCH-TARGET — Is `dispatch_target` required on the first body of a pour?

Question: Does the disabled assertion represent a real requirement separate from `knows_position`?

Proposed answer: Yes. Require a non-null `dispatch_target` on the first body and remove the unconditional `or True`. A body can know a position without recording the dispatch destination, so these are distinct facts. Derived from the test name, adjacent assertions, and avoidance of vacuous tests.
