# DAW UX pass — plan, graded by ux-principles-interactable-software.md

Inputs: the 13-agent UX scan (out/daw_ux_inventory.json, 91 items), the
main-thread workflow brainstorm, and the playbook. This document is the
playbook applied: what got promoted, what got cut, and what "done" means.

## Step 0 — paradigm gate

Real-time / media app (continuous loop, transport, playhead) → binding
sections: §4 control-loop feedback + glanceable HUD, §5 status truth +
liveness, §7 state machine, §3 discoverability, §15 gate with the
**screen-recording ledger** form. The file watcher is additionally a
machine-operated surface (the artist's DAW "calls" it by writing files)
→ §10's structured-contract discipline applies to file drops.

## §9 gate — patch, not overhaul

Run over the whole artifact: the frame (DAW-session metaphor over a
recorded run, with hot-swap) matches the target user's mental model by
construction, was just validated by the director, and no structural
trigger fires (first pass; no diminishing returns; IA coherent).
Verdict: **patch level**. The §9 from-scratch question — "would I build
it this way today?" — yes: same frame, same surfaces.

## P0 — Status must be true (§5, §12): the lie list

Every item here is a status that can currently lie. Fix = derive from
the work, not intent; acceptance = the §5 falsifiability test named
with each item ("force X; the indicator must say so").

1. **48k/24-bit/format guard.** A DAW-default bounce plays as static or
   detuned under green `ready`. Load-time check of samplerate/width;
   resample 48k or refuse with a §10-grade message ("prayer.wav is
   24-bit 48 kHz — export 16-bit 44.1 kHz WAV"). *Force: drop a 24-bit
   48k wav → red message, old mix keeps playing.*
2. **Render-thread exception guard.** Any decode failure freezes amber
   `rebuilding…` forever. try/except → red `RENDER FAILED: <cause> — R
   retries`, previous buffer stays playable. *Force: drop a truncated
   wav mid-write.*
3. **Watcher = watchdog (§8 resilience).** The always-on intent is
   "replace-and-hear never silently stops," so the fix is not just an
   error surface: guard the loop, auto-restart it, and show liveness
   ("watching 5 folders · scanned 0.4s ago") so silence is
   distinguishable from death. *Force: kill/starve the watcher thread →
   liveness chip goes stale, watchdog restarts it.*
4. **Write-settle by quiescence.** Replace the fixed 0.3s sleep with
   mtime/size stability across scans + rebuild only after a quiet poll
   (also fixes the multi-file-bounce hybrid mix). *Force: slow-copy a
   stem in 3 chunks over 3s → exactly one rebuild, of the final file.*
5. **Wrong-length stem detection.** A loop-length export silently
   silences later bars. Compare against the form length on load; warn
   "prayer.wav is 8 bars, bank needs 36 — bars 8+ silent." *Force: drop
   an 8-bar wav.*
6. **Non-audio-contract drops.** `prayer.aiff` = non-event; `prayer
   (1).wav` = confident no-op reload. Glob common extensions to warn
   "ignored — export WAV/OGG"; diff changed basenames against the stem
   keys this session actually plays → "not a stem this session plays."
   *Force: both.*
7. **Reload-into-muted-lane note** ("lane muted — unmute to hear") and
   **companion-stem note** (new prayer.wav still plays old
   prayer_tail.wav at seams). *Force: solo drums, drop lead.wav.*
8. **Unresolvable bank / missing stem / stale bank.json.** Silence
   under green ready + `None` path; ruler stays stale after bank.json
   edits even on R. Red per-bank status; re-parse Project on bank.json
   change and on R. *Force: rename a bank dir; edit sections.*
9. **Mute+solo contradiction** (muted+soloed lane plays at full volume
   with red M lit) and **unknown lane names** leaking through solo.
   Make the effective-mute computation the single source for both audio
   and display. *Force: mute+solo same lane; add a bogus lane to taps.*
10. **Status surface redesign (§4 mode visibility).** One 13px string
    carries five states; errors wear busy-amber; the Royal-Majesty
    trap. Color-coded chip (green ready / amber busy / red error),
    flash on transition, mix generation counter ("mix #4 · from
    prayer.wav · 21:14:03") so old-vs-new is answerable at a glance.
11. **ffmpeg/video honesty.** Failures swallowed + retried forever;
    missing video indistinguishable from no feature. One red "video
    unavailable (<cause>)" chip; stop the spawn storm; stale-frame dim.
    *Force: remove ffmpeg from PATH; point --video at nothing.*
12. **Thread hygiene backing all of the above:** render-generation cap
    (drop superseded renders early), stem-cache lock, single writer for
    status. CLIP gets an amount + location + reset (jump-to-loudest
    doubles as the §1.5 headroom check).
13. **Startup failures** are raw tracebacks post window-flash → §10
    message + nonzero exit ("recording not found: <path>").
14. **Truth-adjacent visuals** (display asserting things the mix
    contradicts): death halts silence everything but draw as a 20px
    tick → full-height red bars; stab markers parsed but never drawn →
    draw; riser landing invisible → draw the 2-bar envelope to its
    strike; `music_stab`/soft-jump filtering documented in the legend.

## P1 — Undo and state design (§7)

15. **A/B last-two renders = the undo of the swap action.** Keep the
    previous buffer; one key toggles old/new at the same playhead.
    Promoted by §7 from convenience to default-for-destructive-action
    (the swap currently destroys the only copy of "before").
16. **Session recall instead of quit-confirm.** ESC-quits-instantly is
    a slip risk, but a confirm taxes every quit to catch a rare slip
    (§7 anti-pattern). Make the slip cheap instead: persist playhead +
    mutes + window state to the rec dir; restore on reopen. ESC stays
    instant. (Scan's "ESC confirm" suggestion **rejected** per
    playbook.)
17. **Designed non-happy states:** initial-render state (transport that
    explains itself instead of dead SPACE; >1s ⇒ progress per Nielsen
    thresholds — show render progress fraction), end-of-session state
    (SPACE at end restarts from 0 instead of dying), NO-MUSIC-TAPS
    state explains the dead transport, loudness anchor latch guarded
    against M/S-during-first-render.

## P2 — Gulf of execution (§3): each item carries its observed need

Per §8, every addition below names a concrete observed instance, not a
symmetry. Additions without one were cut (see Cut list).

18. **`?` help overlay + marker legend.** The manual is a docstring the
    user can never see = the taped-sign anti-pattern inverted; five
    glyph codes with zero legend = recall-over-recognition. (Observed:
    every beta persona asked how they'd learn the controls.)
19. **Numeric go-to + copy-timestamp.** Director feedback is
    timestamp-shaped (observed: "listened at 3:42"-class notes all
    week). `G` → type mm:ss; `C` → copy "05:23 / bar 30 / tutti_x".
20. **Marker/section jump keys.** (Observed: this week's verification
    work was "audition every riser/sting/halt" — done by eyeballing
    8px glyphs.) `,`/`.` prev/next marker; up/down section starts.
21. **Horizontal zoom.** (Observed: riser-landing verification was done
    numerically because one bar = 3.8px is unverifiable by eye.)
    Stepped zoom about the playhead; overview strip stays full-length
    as the navigator — follow-playhead on.
22. **Loop region.** (Observed: the overnight defect passes re-listened
    fixed 16s windows dozens of times; the artist's seam work is the
    same shape.) Drag on ruler sets cycle; L toggles.
23. **Bounce/export.** (Observed: the whole judge pipeline exports
    windows; artist↔director exchange will be clips.) `B` bounces the
    loop region (or full mix) to a wav next to the rec.
24. **Export-spec + stem-key display (P0.7's twin).** Per-bank line
    "110 bpm · 36 bars · stem 78.5s · 44.1k/16-bit" + current stem key
    per track at the playhead — closes hear-it → name-it →
    overwrite-it.

## P3 — feedback fit and comfort

25. Audio chunk feed off the render loop (real dropout conditions);
    0.2s→shorter chunks for seek feel where cheap.
26. Key repeat for arrows; bar nudge from actual bar events, not the
    session median; scrub hit-region excludes the help line; END goes
    to the end.
27. Redraw caching (static layers to surfaces; blit per frame).
28. Legibility batch: distinguishable section colors + labels,
    palette de-collision (CONTEMPT vs groove hue), bank-boundary
    labels, overview both channels, truncation guards.
29. Resizable window/SCALED — deferred unless the artist's display
    forces it (the one structural rework; §8 restraint).

## Cut list (§8: no observed need, or actively harmful)

- **Per-track gain trim** — would make the monitor lie about the game's
  actual mix; the tool's core promise is truth. Unreachable-bad-state
  argument: don't add it.
- **Quit confirmation** — replaced by session recall (§7).
- **Half-speed audition, exclusive-solo modes, play-from-last-start,
  master fader, bigger video, in-app bank/recording pickers, hover
  inspection layer** — hypothesized needs only; revisit on an observed
  instance from the actual artist (Mom-Test bar: a past occurrence,
  not "they might").
- **Watcher on/off switch** — §8's literal example; resilience instead
  (P0.3).

## Definition of done (§15, media-paradigm ledger)

The earlier headless smoke test is a **grant-everything harness** —
happy-path only, structurally blind to every P0 item. It no longer
counts as verification. Done means:

1. **Fault-injection suite** (§14): scripted forces for every P0 lie —
   48k wav, 24-bit wav, aiff, misnamed, truncated-mid-write, slow
   multi-file copy, short stem, killed watcher, missing ffmpeg, missing
   video, renamed bank dir, edited bank.json, mute+solo, M/S spam —
   each asserting the *indicator*, not just the audio.
2. **Screen-recording ledger**: one timestamped cold-session capture —
   launch → first listen → scrub → zoom/loop → mute/solo → a real
   hot-swap → a forced failure and its red status → A/B toggle →
   quit/reopen recall — with every state legible on screen. Frames
   personally reviewed (in-situ law).
3. **Cognitive walkthrough** (§14) by a context-free agent driving the
   real keybindings against the running tool, plus the director as the
   first non-builder human. The real §2 test — watching the actual
   artist cold — runs the day they onboard, and its findings outrank
   this whole document.
