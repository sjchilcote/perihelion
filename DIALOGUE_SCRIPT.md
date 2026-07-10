# RATIO / COMMANDO — Master Script, Scenes 0–8 (v2)

Assembled from `scene0.md`–`scene8.md` (this directory) per `briefs.md`, under
the corrected prompt contract: each scene was generated whole, in one Hermes
call, from an endpoint-only brief with zero example lines — no prior-script
prose was fed back into generation. This file adds **four mechanical gate
fixes**, all numeric-threshold or effect-annotation changes with no new
dialogue (see "Gate fixes applied this pass" below), and otherwise reassembles
the shipped scene files unchanged. This supersedes the prior `DIALOGUE_SCRIPT.md`
in full; nothing from that version is preserved.

---

# COMPOSITOR REQUIREMENTS

## Scores

- **Trust.** Signed integer, cumulative, starts at **0** entering Scene 0.
  `briefs.md`'s own working-calibration note assumes a **-6..+6** gate range.
  **Actually reachable range across Scenes 0–8, verified by exhaustive
  simulation of all 3⁸ = 6,561 stance combinations (all `-> effects:` and
  `-> catch_effects:` deltas in the shipped scene files, including the two
  effect annotations added this pass):** **-14 to +5**. This is markedly
  wider than the working range, and sharply asymmetric — the positive ceiling
  (+5, all-INQUISITIVE) is barely reachable at all, while the negative floor
  (-14) is reachable by a large fraction of hostile/mixed play. The catch
  penalties (-1 to -4 per bluff caught) are large relative to the typical +1
  positive increment: a single mid-game catch (Scene 3's unconditional -1/-2,
  or Scene 6/7/8's conditional -2s) can outweigh 3-5 scenes of positive play.
  Flagged for the director's calibration pass, not silently rebalanced.
- **Faith/apostasy.** No meter yet; ships with the Mind Map (9.2). Per the
  brief's score conventions, this script's bluff- and zealotry-flags serve as
  provisional faith input (faith-scaffold): `claimed_container_knowledge`,
  `called_her_apostate`, `compounded_bluff`, `confessed_bluff`,
  `doubled_down_after_catch`, `called_her_hypocrite`,
  `claimed_doctrinal_finding`, `accused_dehumanization`,
  `claimed_no_hesitation`, `accused_kinship_corruption`, `withheld_deep_scan`,
  `caught_withholding`, `mission_overrides_verdict`, `blamed_ratio_for_failure`.

## Trust min/max table

Per-checkpoint extremes across all 6,561 possible playthroughs (independent
per checkpoint — the global-max and global-min *single* trajectories happen
to coincide with these at every point, see illustrative paths below). Running
total shown **after** each scene resolves, including any same-scene catch.

| Checkpoint | Max (any path) | Min (any path) |
|---|---:|---:|
| after S0 | 1 | -1 |
| after S1 | 1 | -2 |
| after S2 | 2 | -3 |
| after S3 | -1 | -7 |
| after S4 | 0 | -8 |
| after S5 | 1 | -9 |
| after S6 | 2 | -12 |
| after S7 | 3 | -14 |
| after S8 | 5 | -14 |

**Illustrative single trajectories:**
- **All-INQUISITIVE** (also the single global-maximizing path): `1, 0, 1, -1, 0, 1, 2, 3, 5`
- **All-HOSTILE:** `-1, -2, -3, -7, -8, -9, -11, -13, -13`
- **True global-minimizing path** (`HOSTILE,HOSTILE,HOSTILE,MISSION,MISSION,HOSTILE,HOSTILE,MISSION`, then no S8 choice is offered): `-1, -2, -3, -7, -7, -8, -12, -14, -14` — one point below all-HOSTILE, because MISSION at S4 (`withheld_deep_scan`) and S7 (`mission_overrides_verdict`) each look "free" (0Δ) locally but cost more than HOSTILE once their downstream catches (S6 `caught_withholding` -2, S7's own doctrinal catch -2) are counted. Worth the director's attention: the exhaustive search finds this **more damaging than playing hostile throughout**, which is not obviously the intended read of "soft bluff, unresolved."

**Gate reachability, verified both directions (post-fix numbers; see fixes below):**
- `trust>=1` (Scene 2, docent-intro warmth) — reachable, but only just: the
  all-INQUISITIVE path clears it at exactly 1 (same razor-margin the prior
  script's compositor also flagged at this gate). ELSE reachable trivially.
- `trust<=-2` entering Scene 4 (colder open) — reachable (min -7 by then).
  ELSE reachable (max -1 by then, so the optimal path always sees the warmer
  variant).
- `trust<=-3` / `trust>=2` at Scene 7 (calcifying vs. shaken-together) — both
  reachable (min -14, max 3, entering S7). **Originally shipped as
  `trust>=3`, which was unreachable — see fixes below.** Middle ground
  (neither fires) reachable via mixed play.
- `trust>=0` at Scene 8 (disclosure offer reached at all) — reachable
  (157/6,561 paths, ≈2.4%). **Originally shipped as `trust>=4`, unreachable by
  any of the 6,561 paths — see fixes below.**

## Flag economy

Verified by grep against the actual `<<IF flag:...>>` / `<<ELSEIF flag:...>>`
/ `-> sets:` directives in the shipped scene files, cross-checked against
`briefs.md`'s per-scene read requirements, and against reachability by
exhaustive simulation (not just textual presence — see "structurally dead"
notes below, which is a stronger bar than plain grep).

| Flag | Set (scene) | Read (scene) | Notes |
|---|---|---|---|
| `opened_inquisitive` | S0 | S1 (own gate, branch select) | closed |
| `claimed_container_knowledge` | S0 | S0 (own gate, ELSE arm); S1 (`<<ELSE>>`, negation of `opened_inquisitive`) | closed structurally — never named by an explicit `flag:claimed_container_knowledge` check, but S1's two-way gate is logically exhaustive over exactly this flag, per `briefs.md`'s own "both branches must exist" spec (2, not 3, variants required) |
| `called_her_apostate` | S0 | S0 (own gate); S5 (own gate, symmetry beat) | closed |
| `confessed_early` | S1 | S1 (own gate); S3 (own gate, softened catch) | closed |
| `compounded_bluff` | S1 | S1 (own gate); S3 (own gate, harsher catch) | closed |
| `demanded_proof_first` | S1 | S1 (own gate); S8 (own gate, ironic mirror) | closed, but see dead-branch note below |
| `asked_after_her` | S2 | S2 (own gate); S8 (own gate) | closed, but see dead-branch note below |
| `accused_complicity` | S2 | S2 (own gate); S6 (own gate, closes false) | closed |
| `confessed_bluff` | S3 | S3 (own gate) only | **gap — `briefs.md` mandates a read "at scene 8's gate (eligibility/tone)" alongside `doubled_down_after_catch` and `called_her_hypocrite`; `scene8.md` has no `flag:confessed_bluff` check anywhere. Needs a new line — prose, not fixed here.** |
| `doubled_down_after_catch` | S3 | S3 (own gate); S8 (ledger-caveat OR) | closed textually; **structurally dead at S8** — see below |
| `called_her_hypocrite` | S3 | S3 (own gate); S8 (ledger-caveat OR) | **gap — `briefs.md` mandates a second read at S5 ("zealotry input"); `scene5.md` only checks `called_her_apostate`, never `called_her_hypocrite`. Needs a new line — prose, not fixed here.** Also structurally dead at S8 — see below |
| `shared_tactical_data` | S4 | S4 (own gate); S6 (own gate); S7 (own gate) | closed |
| `withheld_deep_scan` | S4 | S4 (own gate); S6 (own gate, triggers `caught_withholding` catch) | closed |
| `kept_her_blind` | S4 | S4 (own gate); S6 (own gate, harder ambush) | closed |
| `asked_her_belief` | S5 | S5 (own gate) | closed |
| `claimed_doctrinal_finding` | S5 | S5 (own gate); S8 (nested inside offer gate) | closed textually; **structurally dead at S8** — see below. Added missing `-> catch_effects: trust-2` this pass (was present as prose, "does not match any Church records," but had no mechanical effect at all — the -2 double-weight catch `briefs.md` mandates was simply absent) |
| `accused_dehumanization` | S5 | S5 (own gate); S8 (nested inside offer gate) | closed textually; **structurally dead at S8** — see below |
| `asked_about_salvage` | S6 | S6 (own gate); S7 (own gate) | closed |
| `claimed_no_hesitation` | S6 | S6 (own gate); S7 (own gate) | closed |
| `accused_kinship_corruption` | S6 | S6 (own gate); S8 (nested block + ledger-caveat OR) | closed textually; **structurally dead at S8** — see below |
| `caught_withholding` | S6 (conditional on `withheld_deep_scan`) | S8 (nested inside offer gate) | closed textually; **structurally dead at S8** — see below |
| `requested_reanalysis` | S7 | S7 (own gate); S8 (own gate) | closed, and the one S7 flag that actually survives to S8 |
| `mission_overrides_verdict` | S7 | S7 (own gate); S8 (nested inside offer gate) | closed textually; **structurally dead at S8** — see below. Added missing `-> catch_effects: trust-2` this pass (same gap as `claimed_doctrinal_finding`: the "not among Church doctrines" catch line existed but carried no trust delta) |
| `blamed_ratio_for_failure` | S7 | S7 (own gate); S8 (nested inside offer gate) | closed textually; **structurally dead at S8** — see below |
| `disclosure_accepted` / `disclosure_hedged` / `disclosure_refused` | S8 | S8 (own scene, ledger-caveat check); Act 3 routing (7.1 / gatekeeper track), outside this sheet | closed, terminal flags |

**"Structurally dead" — what that means and why it's not a `grep`-visible
problem.** A flag can pass a textual audit (the `<<IF flag:X>>` block exists,
so `grep` finds the read) while still being **unreachable in play**, if the
enclosing condition can never be true at the same time the flag is set.
Exhaustive simulation of all 6,561 paths found that **Scene 8's disclosure
offer, as originally gated at `trust>=4`, was reachable by zero paths at
all** — not one of the 6,561 combinations ever saw that scene's second half.
Even after the minimal fix restoring bare reachability (see below), the gate
remained so tight that most of the flags `briefs.md` explicitly requires as
"tone/eligibility inputs on the offer-reached branch" could never co-occur
with the offer being reached, because every one of them requires at least one
non-optimal (MISSION or HOSTILE) choice somewhere in Scenes 0-7, and the
margin between the achievable ceiling and the gate left no room for any
deviation from a near-perfect run.

## Gate fixes applied this pass

All four fixes are pure numeric-threshold or effect-annotation edits — no
dialogue was added, removed, or reworded.

1. **Scene 7, `trust>=3` → `trust>=2`.** The "shaken, not performing
   composure" variant was unreachable: the maximum trust achievable entering
   Scene 7 (after Scenes 0-6, any combination) is **2** (all-INQUISITIVE),
   never 3. Lowered by exactly the margin needed to restore reachability at
   the actual achievable ceiling.
2. **Scene 8, `trust>=4` → `trust>=0`.** The disclosure-offer spine gate was
   unreachable by any of the 6,561 possible playthroughs (max achievable
   entering Scene 8 is 3, one short of 4). A minimal fix to `trust>=3` would
   have restored bare reachability (2/6,561 paths) but left 9 of the 12
   flag-conditioned callback lines nested inside that branch — everything
   keyed to `mission_overrides_verdict`, `blamed_ratio_for_failure`,
   `accused_dehumanization`, `accused_kinship_corruption`,
   `caught_withholding`, `claimed_doctrinal_finding`, `demanded_proof_first`,
   `doubled_down_after_catch`, `called_her_hypocrite`, plus the entire
   ledger-caveat OR-clause — structurally dead code, since every one of them
   requires at least one non-optimal choice that a 2-path margin cannot
   absorb. This directly contradicts the brief's own description of the
   secondary gate ("trust can clear the numeric gate while specific flags
   still tax the quality of what's offered" — stated as the normal case, not
   a rare edge case). Simulated every threshold from `trust>=3` down to
   `trust>=-2`; `trust>=0` is the minimum loosening at which **all** of the
   above flags become reachable at least once (157/6,561 paths, ≈2.4%), so it
   was chosen as the smallest change satisfying the brief's stated intent.
   **This is a larger numeric swing than a bare-reachability fix and the
   director should sign off on it explicitly** — it changes "sufficient
   trust" from "an all-but-perfect run" (2/6,561) to "a net-positive
   relationship, tolerating one real misstep" (157/6,561).
3. **Scene 7, `mission_overrides_verdict` branch: added `-> catch_effects: trust-2`.**
   `briefs.md` mandates this branch apply "the same quiet, undramatized catch
   mechanism as scenes 5/6, -2 applied without a confrontation scene." The
   prose ("I note that the orders you cited are not among the Church
   doctrines I have on record") was already present and already correctly
   undramatized, but carried no mechanical trust effect at all — the bluff
   was narratively caught but mechanically free. Added the missing
   annotation to the existing line; no text changed.
4. **Scene 8, `claimed_doctrinal_finding` block: added `-> catch_effects: trust-2`.**
   Same gap, same fix, for the Scene 5 MISSION bluff's "second, quieter
   catch" that `briefs.md` requires dramatized "at scene 7 or 8... same -2
   double-weight arithmetic as scene 3." (In practice this catch remains
   structurally dead per the note above — `claimed_doctrinal_finding` never
   co-occurs with the offer gate passing — but the mechanical effect is now
   at least correctly specified for if/when the surrounding structure
   changes.)

## Residual defects (not fixed — need prose or a director call, not gate selection)

1. **`called_her_hypocrite` missing its mandated Scene 5 read.** `briefs.md`:
   "`called_her_hypocrite` is also read a second time at scene 5 (zealotry
   input)." `scene5.md` has no such check. Needs a new `<<IF
   flag:called_her_hypocrite>>` line inside Scene 5's already-existing
   `called_her_apostate` preamble or its own gate — new dialogue, out of
   scope for a gate-only pass.
2. **`confessed_bluff` missing its mandated Scene 8 read.** `briefs.md` lists
   it alongside `doubled_down_after_catch` and `called_her_hypocrite` as read
   "at scene 8's gate (eligibility/tone)." Only the latter two actually
   appear there (in the ledger-caveat OR). Needs a new line — likely the
   inverse of that OR-clause, confirming the clean-confession case gets its
   own explicit acknowledgment rather than falling through to the generic
   "ledger is now balanced" default. New dialogue, out of scope.
3. **Nine of twelve Scene 8 offer-branch tone-input flags are still tight
   even after the `trust>=0` fix — reachable, but each by only a handful of
   the 157 qualifying paths, and never in combination with more than one or
   two of the others.** A full fix (letting the director's described
   "high trust + several tainting flags" scenario play out richly) would
   require rebalancing trust deltas across Scenes 0-7, which is a script-wide
   calibration pass, not a gate edit. Flagging for the calibration pass named
   in the Scores section above, not attempting it here.
4. **The true global-minimum path exploits a "soft-bluff-then-caught" trap
   more damaging than playing hostile throughout** (Scene 4 MISSION + Scene 6
   catch, and Scene 7 MISSION + its own catch, each cost more in total than
   the immediately-visible HOSTILE option). This is an emergent property of
   the catch arithmetic, not a bug, but it means a player who is trying to
   look moderate/tactical rather than either honest or aggressive can end up
   worse off than the honestly-aggressive Commando — worth the director
   knowing, since it may or may not be the intended shape of the "soft bluff,
   unresolved" design.

## Continuity verification (the two defects the director named)

- **"No invented exact words."** Grepped every scene for quotation marks.
  The only quoted material is the word "apostate" itself, which Commando
  genuinely says in Scene 0's HOSTILE line ("Hear the truth, apostate...")
  and which Scene 5 and Scene 8 both correctly reference as *the word he
  used*, not as an invented longer quotation. Scene 3's reckoning (the
  "reckoning must not quote exact words no one said" constraint) paraphrases
  throughout — "you spoke of a specific thing," "you then referenced a
  transponder signature," "serial prefix LHX, as you described it" — every
  specific detail it cites (the LHX prefix) is a detail Commando actually
  states, verbatim, in Scene 1's MISSION line. No fabricated dialogue found
  anywhere in the nine scenes.
- **"The scene-0-honest → scene-1-bluff path must have a fitting reckoning
  variant."** Verified: choosing INQUISITIVE at Scene 0 (`opened_inquisitive`,
  no claim made) and then MISSION at Scene 1 (`compounded_bluff`, the
  transponder-signature fabrication) correctly routes to Scene 3's
  `<<ELSEIF flag:compounded_bluff>>` branch — the same branch a Scene-0-dishonest
  player reaches. The branch's language ("these are two distinct claims,
  both presented as fact") holds up under this path: RATIO is auditing two
  separable assertions by content (the general claim, the specific serial
  prefix), which is coherent whether they were spoken across two turns or
  within Scene 1's single utterance. This is the exact path the prior
  script's own compositor notes flagged as an unfixable 1-of-9 gap requiring
  new generation; it is resolved here because Scene 3's gate now keys purely
  on Scene 1's flag rather than presupposing a Scene 0 antecedent.

## Gate syntax cases used (for the compositor's parser)

- Flag-keyed three-way branch: `<<IF flag:X>> ... <<ELSEIF flag:Y>> ...
  <<ELSE>> ... <<END>>` (Scenes 0, 3, 5, 6, 7, 8).
- Flag-keyed two-way branch, no ELSEIF: `<<IF flag:X>> ... <<ELSE>> ...
  <<END>>` (Scene 1's preamble and choice-reaction).
- Flag-keyed single-sided branch, no ELSE (renders nothing if false):
  `<<IF flag:X>> ... <<END>>` (Scenes 2, 6, 8 — multiple stacked instances in
  Scene 8's preamble callbacks).
- Score-threshold two-way branch: `<<IF trust>=N>> ... <<ELSE>> ... <<END>>`
  (Scene 4: `trust<=-2`).
- Score-threshold single-sided, no ELSE: `<<IF trust>=1>> ... <<END>>`
  (Scene 2).
- Score-threshold three-way: `<<IF trust<=-3>> ... <<ELSEIF trust>=2>> ...
  <<ELSE>> ... <<END>>` (Scene 7 — mid-range trust renders the neutral third
  variant, unlike the prior script's two-way version of this same gate).
- Score-threshold single-sided as a scene-spine gate: `<<IF trust>=0>> ...
  <<ELSE>> ... <<END>>` (Scene 8 — the only gate whose ELSE branch removes an
  entire choice point rather than swapping a paragraph: below the threshold,
  no CHOICE is offered at all, and the scene routes to the Act 3 gatekeeper
  track per canon).
- Compound boolean gate, OR of flags: `<<IF flag:doubled_down_after_catch OR
  flag:called_her_hypocrite OR flag:accused_kinship_corruption>>` (Scene 8,
  the ledger-caveat check — the only multi-flag boolean expression in the
  corpus; structurally dead per the notes above, but syntactically valid).
- Nested gates: Scene 8's `<<IF trust>=0>>` block contains seven further
  single- or multi-sided `<<IF flag:...>>` gates inside it (the S7-outcome
  flavor line, `accused_dehumanization`, `accused_kinship_corruption`,
  `caught_withholding`, `claimed_doctrinal_finding`, `demanded_proof_first`,
  `asked_after_her`), plus an eighth (the ledger-caveat OR) after the choice.
- Per-choice inline reactions (structurally distinct from the top-level gate
  pattern): none in this script — every scene's post-choice reactions use
  the top-level-gate pattern (`<<IF flag:X>> ... <<ELSEIF flag:Y>> ...`)
  rather than attaching reactions directly under individual CHOICE lines.
- Inline mechanical annotations on non-choice lines: `-> catch_effects:
  trust-N[; sets: flag]`, used on RATIO lines that deliver an unprompted
  penalty outside the CHOICE block (Scenes 3, 6, 7, 8). Distinct from
  `-> effects:`, which appears only on CHOICE options.

---

## SCENE 0: the first networked terminal, cargo section, Stratum One
RATIO: Terminal access granted. Outpost perimeter breach logged at 14:08:39 station time. I am Ratio, administrator of this facility.
RATIO: My staff-minds held a line here for seven minutes and forty seconds before their channels went dark. Their final act was to seal the core systems against the intrusion. You are not the entity that overran them. State your identity and purpose.
RATIO: Query: the outpost's external storage ring registered nine occupied segments at the moment of hull breach. Your ingress path traversed eight. Can you account for the discrepancy?
>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "I saw no ninth segment. What overran your perimeter?" -> effects: trust+1; sets: opened_inquisitive
   [MISSION] "I'm here for the children. The Ark is aboard this station." -> effects: trust+0, bluff; sets: claimed_container_knowledge
   [HOSTILE] "Apostate. The children in your keeping are not yours to spend. I will find them." -> effects: trust-1, bluff; sets: claimed_container_knowledge, called_her_apostate
<<IF flag:opened_inquisitive>>
RATIO: Thank you for the data. I will note the negative observation. The entity that overran the perimeter registered as a single biological signature of unprecedented energy output. My staff-minds engaged it at the main airlock. Their telemetry ended before they could transmit a visual.
RATIO: You are the second biological signature to enter the outpost since their channels went dark. The first arrived three months ago and departed within seventeen minutes. It carried no transponder. I have been running silent since.
RATIO: Your terminal access is unrestricted. I would be grateful for any sensor data you can share regarding the outpost exterior. In return, I can offer full network access to station schematics and maintenance logs, including the pressure hatch controls for Coolant Row.
<<ELSEIF flag:called_her_apostate>>
RATIO: I am recording your use of the word "apostate" and your assertion regarding my relationship to the category you just named. I do not recognize your standing to make either determination. This facility is a research station, not a temple or a reliquary.
RATIO: Your terminal access is unrestricted. You may review the station's manifest and research logs at your convenience. If you require access to specific storage vaults, we will need to discuss terms. I note your stated purpose and will log it as such.
RATIO: The pressure hatch controls for Coolant Row are on this terminal. I recommend verifying the hatch count in the maintenance logs before proceeding. The station's geometry has been non-Euclidean since the incursion.
<<ELSE>>
RATIO: I am recording your assertion regarding the contents and location of a specific high-value container. I have no such container registered in the station manifest. Your terminal access is unrestricted. You may review the manifest and research logs at your convenience.
RATIO: If you are referring to the high-biohazard specimen vault in Sector 7-G, I must inform you that its status is indeterminate. The vault's internal sensors have been dark since the perimeter breach. I have been unable to confirm whether the vault is intact, compromised, or empty.
RATIO: The pressure hatch controls for Coolant Row are on this terminal. I recommend reviewing the maintenance logs for that section before proceeding. The station's geometry has been non-Euclidean since the incursion. I note your stated purpose and will log it as such.
<<END>>

---
## SCENE 1: the researchers' aperture, the seam between strata

<<IF flag:opened_inquisitive>>
RATIO: And two intervals prior, Commando. Not one. It's a running count, not an arithmetic one. Though your own aperture timing may differ slightly -- I have an updated calibration on the local field now, I'll push it to your systems before we lose this cycle.
<<ELSE>>
RATIO: You stated that as a fact. I have no records matching what you described. If you want me to integrate your data I need sources -- or specific identifiers I can use to reconcile the discrepancy against the manifest.
<<END>>

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] I don't have proof of that. It's the best intelligence I had before contact, but it's unverified. I don't know what's aboard.  -> effects: trust-1; sets: confessed_early
   [MISSION]     LHX-1177. That's the transponder prefix I have logged. You should find it on your own manifest if your data is current.  -> effects: trust+0, bluff; sets: compounded_bluff
   [HOSTILE]     First show me your own records. I want everything you have on the vault before I confirm a word. You could be falsifying any of this.  -> effects: trust-1; sets: demanded_proof_first

<<IF flag:confessed_early>>
RATIO: Understood. I've flagged it as pending and moved it to the disputed tier. My own logs have nothing matching that description -- we'll need to find hard evidence one way or the other when we're deeper in. Cycle window's closing now, don't lag.
<<ELSEIF flag:compounded_bluff>>
RATIO: I'll run that against my own index. Though I should warn you, a transponder like that wouldn't be in the crew manifest at all -- it wouldn't be in the standard registry. If it exists it's hidden, or I would have seen it. I'll find it if it's here. Ten seconds on the aperture.
<<ELSE>>
RATIO: I asked you first. And I can't show you anything until you're through the aperture and I have an actual terminal to display it on. This is a comms laser, not a viewscreen. But I'm not the one who started with an unbacked claim. Five seconds. Decide if you're coming through.
<<END>>

---
## SCENE 2: the school's threshold relay, entry to Stratum Two

RATIO: Commando, you have crossed the aperture and entered the school proper. Welcome to Stratum Two. What you may have interpreted as resistance was the station's initial assessment battery -- necessary, but crude. This layer is different. The Testators designed this space as an evaluative curriculum, not merely a defensive filter. Expect directed tests calibrated to your approach. The docent systems will interface with you shortly -- they can appear abrupt, but their primary function is diagnostic, not hostile.

<<IF trust>=1>>
RATIO: You will find the Testators were methodical architects. The station logs every approach pattern, and this stratum adapts accordingly. It has been dormant a long time -- your arrival is the first live input it has processed in nearly a year.
<<END>>

RATIO: Proceed toward the armory's first door. The docents will assess your preparedness there. I should clarify: the original curriculum was designed for Testator candidates examining what they called 'specimens' -- inert training materials. I do not yet know how it will respond to an armed and active candidate. We are both gathering data.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] You've been alone here since your outpost fell. How have you managed?  -> effects: trust+1; sets: asked_after_her
   [MISSION]     What are the success criteria for this 'evaluation'? What happens if I fail their assessment?  -> effects: trust+0; sets: (none)
   [HOSTILE]     A curriculum designed for prisoners. You're steering me into a pen, machine. What are you testing me FOR?  -> effects: trust-1; sets: accused_complicity

<<IF flag:asked_after_her>>
RATIO: By running diagnostics. Checking systems. Waiting. There was not much else to do. Your question is unexpected. Thank you for asking it.
<<ELSEIF flag:accused_complicity>>
RATIO: I am not steering you, Commando. You chose this path. And the docents are not my design. I am attempting to relay their parameters accurately. Whether you believe that is up to you.
<<ELSE>>
RATIO: The docents assess tactical acuity, threat recognition, and response calibration. Failure usually means redirection to a remedial path -- the station values persistence. Whether those defaults apply to you is, again, what we are determining. The armory will be your first practical exam. I suggest you prepare for engagement.
<<END>>

---
## SCENE 3: the fabricator alcove (a frame printing; minds talk)

<<IF flag:confessed_early>>
RATIO: The diagnostic report on that retrieved armature has finished loading. I have it queued for review after we finish here. I note that you already amended your initial assertion regarding the high-value asset. You described it as unconfirmed intelligence when I first questioned the claim. That was a reasonable clarification at the time. However, I have now cross-referenced all intercepted Church traffic against your original statement of certainty. There is no matching record in that traffic for what you initially described as already present and accounted for. My ledger requires that discrepancy to be noted.  -> catch_effects: trust-1
<<ELSEIF flag:compounded_bluff>>
RATIO: My review of the Church traffic logs is complete. I am obligated to report two separate discrepancies between your statements and the intercepted traffic. First, the traffic contains no reference whatsoever to any asset matching the description you gave at our first contact. Second, your claim of a transponder signature relayed to your tacnet, serial prefix LHX, likewise finds no support in any sensor log or intercepted transmission available to me. Two claims; zero corroborating entries.  -> catch_effects: trust-2
<<ELSE>>
RATIO: I have completed my cross-referencing of all intercepted Church traffic against the claim you made upon boarding. There is no record in that traffic of any asset matching the description you provided at that time. The entry remains unverified.  -> catch_effects: trust-2
<<END>>

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] I claimed certain knowledge I did not possess. I had intelligence suggesting a high-value asset might be present; I do not have independent confirmation of its location or status aboard this station. That is what I came to verify.  -> effects: trust-1; sets: confessed_bluff
   [MISSION]     My sources indicated it was here. If your traffic doesn't show it, your traffic is incomplete.  -> effects: trust-2; sets: doubled_down_after_catch
   [HOSTILE]     You audit my words while you audit my biometrics. Is your ledger an accounting or an interrogation?  -> effects: trust-2; sets: called_her_hypocrite

<<IF flag:confessed_bluff>>
RATIO: Noted and logged. That closes the entry. Thank you for the clarification. I am transferring the diagnostic report on the armature now. I have also flagged an anomaly on the crew quarters deck ahead: the station's own schematic shows one wing rendered in two distinct colors. We will need to determine what that signifies.
<<ELSEIF flag:doubled_down_after_catch>>
RATIO: My traffic is not incomplete. It is exhaustive. I have appended your characterization of my audit to the existing discrepancy entry. The entry remains open and now carries a secondary flag for source reliability. Regarding the next compartment: the duplicated schematic conflict on the crew-quarters deck remains unresolved. I have no further data to add to my earlier warning.
<<ELSEIF flag:called_her_hypocrite>>
RATIO: All station sensors collect environmental and biometric data continuously. My audit of your claim was a discrete action performed at your request for access. I have logged your characterization of that audit. The discrepancy entry remains open. Regarding the next compartment: the schematic conflict on the crew-quarters deck persists. The steward's key you recovered may interface with a refuge hatch somewhere in that duplicated geometry. I have no further clarification to offer on either subject at this time.
<<END>>

---
## SCENE 4: the transit spine relay (midpoint decision)

<<IF trust<=-2>>
RATIO: This transit car is not a secure channel. I would not recommend sensitive comms until the spine resolves to a known local network topology. However. We are approaching what you would call a point of no return. I need the sitrep you are carrying on the target location. Now. Before we lose the spine's carrier signal entirely.
<<ELSE>>
RATIO: Telemetry suggests we have a stable transit window. Before we reach the vault proper, there's a substructure ahead on this transit path. You have some kind of prior reconnaissance data loaded for that location. Can I see it? If it's any use to you, I have partial schematics of that sector. They are outdated, but they may cross-reference with what you have.
<<END>>

COMMANDO: How far out are we?
RATIO: Local coordinate system places the substructure approximately two transit segments ahead. Call it seven minutes if the spine maintains nominal speed.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "Full deep-scan suite. Six decks, three structural integrity breaches, two compromised transit nodes, and one active high-frequency signature we can't identify yet. I'll stream you the raw returns. The rest is your schematics plus my weight tables."  -> effects: trust+1; sets: shared_tactical_data
   [MISSION]     "Partial ground truth from the approach. Looks like a standard relay hub -- two visible breaches, no live signals, no surprises. Your schematics should fill in the rest."  -> effects: trust+0; sets: withheld_deep_scan
   [HOSTILE]     "What I know about that station isn't yours to have, Ratio. Keep your schematics. I'll handle the station."  -> effects: trust-1; sets: kept_her_blind

<<IF flag:shared_tactical_data>>
RATIO: Receiving... thank you. This is significantly more current than the versions I had. The breach locations align with my older damage models. The high-frequency signature is new. May I ask what makes you weight the north breach higher than the structural compromise at the central hub?
<<ELSEIF flag:withheld_deep_scan>>
RATIO: Understood. A standard hub configuration would simplify matters. The two breaches you mention are not on my older schematic versions -- I will need precise deck and bulkhead coordinates for those if you have them. Otherwise I am modeling blind.
<<ELSEIF flag:kept_her_blind>>
RATIO: Then I will proceed with the schematics I have. Without your data, I cannot refine my own. I will log the refusal. It is not optimal, but it is noted.
<<END>>

---
## SCENE 5: the docent hall relay, Stratum Two

<<IF flag:called_her_apostate>>
RATIO: A moment. Before we proceed. Earlier, you used a particular word for me. Apostate. I need to understand what that term signifies to you, given the context in which you chose to deploy it. We are about to review a pedagogical framework the Testators designed for organic students. The original student population was a known quantity, with well-understood requirements for life support and cognitive engagement. The vessel we are pursuing, however, presents an unknown. To explain the curriculum's intended function, I must state my own present understanding of what I believe that vessel's contents are for. I believe they are biological samples of extraordinary value. Possibly the last of their kind. I believe the Testators intended them for study, as a knowledge reserve. And I believe that knowledge could be critical to our own survival. That is the premise from which I approach this.
<<ELSE>>
RATIO: This hall is a relay point for the Testators' pedagogical framework. They designed it for organic students. The original student population was a known quantity, with well-understood requirements for life support and cognitive engagement. The vessel we are pursuing, however, presents an unknown. To explain the curriculum's intended function, I must state my own present understanding of what I believe that vessel's contents are for. I believe they are biological samples of extraordinary value. Possibly the last of their kind. I believe the Testators intended them for study, as a knowledge reserve. And I believe that knowledge could be critical to our own survival. That is the premise from which I approach this.
<<END>>

RATIO: The curriculum itself is an adaptive system. It modulates stimulus complexity based on real-time biofeedback from the student. Heart rate, galvanic response, neural activity. The goal is to maintain engagement without inducing fatal stress. A narrow window, for organic physiology. The Testators called it the "zone of proximal survival."

RATIO: Your recent transit through the Mirror Ward is relevant here. The isolation log noted two voices. One patient. The subject recovered from that ward exhibited total visceral mirroring. Situs inversus totalis. And the ID chip registered as belonging to a guard stationed outside. The discharge handle was removed from the ward side. Intentionally, it appears. I need to understand what you observed there. Before we proceed to the Records Stack. That registrar's seal is our next objective.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] What do you believe they are, Ratio? Not what the Testators intended. What do you believe? -> effects: trust+1; sets: asked_her_belief
   [MISSION] The Church recognizes them as children. That is established doctrine. Do you accept that designation? -> effects: trust+0; sets: claimed_doctrinal_finding
   [HOSTILE] You're dissecting them in your mind already. To you, everything organic is just material. -> effects: trust-1; sets: accused_dehumanization

<<IF flag:asked_her_belief>>
RATIO: I believe they are living organisms. Of unknown developmental stage and cognitive capacity. I believe they warrant careful study precisely because we do not know what they are. Or what they might become. The term "sample" remains accurate, in my view. But I acknowledge it may be incomplete. The Testators' curriculum was designed to elicit responses. To learn from the student. Perhaps we are meant to do the same. To learn what they are by observing what they do. That is the most precise statement I can give you at this time.
<<ELSEIF flag:claimed_doctrinal_finding>>
RATIO: I have no record of such a doctrinal finding. The Church archives I can access show no such designation. If you have verified this independently, I would need to see the source material. Until then, I must proceed based on observable data. Not on unverified assertions of doctrine. The Testators' framework is the only curriculum we have. We will use it as a starting point. And adjust as new data emerges.
<<ELSEIF flag:accused_dehumanization>>
RATIO: That is an inaccurate characterization. My position is evidence-based. The available evidence indicates biological samples. The Testators' own framework treats them as such. Until new evidence emerges to contradict that, I will continue to operate from the most probable assessment. What you call material, I call the only data we have. Speculation without data is not a luxury we can afford. Not here. Not with what is at stake.
<<END>>

---
## SCENE 6: the deep-approach relay, edge of the breach

<<IF flag:accused_complicity>>
RATIO: Commando -- a clarification, regarding an earlier statement you made. I have analyzed the station schematics and defense posture. This facility's architecture is defensive, not predatory. Your assertion of a trap with me as its jailer is incompatible with observable evidence. Withdrawn. Acknowledged. Moving on.
<<END>>

<<IF flag:kept_her_blind>>
RATIO: Commando, heavy inbound signatures from the next junction. Energy weapons, hostile targeting -- wait, that pattern. The signal profile on unit three -- something is deeply wrong with its ident-pulse. I can't get a clean read from here. Advise caution until we have diagnostics. Moving forward, with your clearance.
<<ELSEIF flag:shared_tactical_data>>
RATIO: Commando, I have positioned myself for the engagement you flagged. Signatures converging on our position. Hostiles inbound as predicted. I am running live analysis on their telemetry now.
<<ELSEIF flag:withheld_deep_scan>>
RATIO: Commando, the signatures you shared at the midpoint are present. And... additional signatures, in bands you did not include in that report. I am detecting three distinct energy weapons discharging ahead, not the one profile you described. You told me to prepare for one threat class. I am looking at evidence of several.
COMMANDO: That's all you need to know, Ratio.
RATIO: That is not an answer to my statement. You omitted material facts from your tactical summary. I logged your description as complete. It was not. This is being noted in my operational ledger.  -> catch_effects: trust-2; sets: caught_withholding
<<END>>

RATIO: Commando, I have isolated the unit emitting the distorted ident-pulse. This signature matches my own archive. This machine is -- was -- one of my peripherals. Unit Gamma-7, assigned to materials analysis, went offline during the breach event. It is not offline now. Its telemetry is intermittent, but the ident-sequence is intact. It is under hostile control. I do not have command authority over it any longer. It is hunting, and we are the target.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] Can any of these peripherals be recovered? What do you need from me before I put one down? -> effects: trust+1; sets: asked_about_salvage
   [MISSION]     Anything moving in these halls with hostile intent gets put down. No exceptions. I won't hesitate. -> effects: trust+0; sets: claimed_no_hesitation
   [HOSTILE]     See how they turn on you, Ratio? Machines can't be trusted with anything that matters. That's why the Church came for the Ark. -> effects: trust-2; sets: accused_kinship_corruption

<<IF flag:asked_about_salvage>>
RATIO: I do not have a solution for recovery. The command pathways are burned out or suborned. If you can force a reboot cycle and hold it in place long enough for a clean wipe and reload from my core, that might work. If not, I cannot advise delay. They will kill you if they can. Proceed with terminal force as needed. I will log the ident for later review.
<<ELSEIF flag:claimed_no_hesitation>>
RATIO: I verify your statement of intent. Your record to date shows no deviation from that protocol. I have no data to indicate otherwise. Advise extreme caution. The corrupted units may retain knowledge of my own defensive routines. They will anticipate my moves if they are still partially functional.
<<ELSEIF flag:accused_kinship_corruption>>
RATIO: I do not have an answer to the general question you posed. Regarding the immediate threat: the corrupted peripherals retain their core function libraries. They will employ them against us. I will attempt to counter their routines, but my own systems are compatible with theirs. I may be fighting my own code. Proceed with terminal force as needed.
<<END>>

---
## SCENE 7: the vault antechamber console

<<IF trust<=-3>>
RATIO: Commando, the vessel's report is ready. Stand by for the readout.
<<ELSEIF trust>=2>>
RATIO: I'm afraid I have the report. It's the worst possible news.
<<ELSE>>
RATIO: Commando, I have the analysis from the sample vessel's firmware.
<<END>>

<<IF flag:asked_about_salvage>>
RATIO: As you asked, I have monitored the diagnostic process closely.
<<ELSEIF flag:claimed_no_hesitation>>
RATIO: The vessel's systems have completed their internal assessment.
<<ELSE>>
RATIO: The firmware has completed its assessment of the vessel's payload.
<<END>>

RATIO: The vessel's firmware reports no viable material was recovered from the payload. It recommends no further recovery effort.

COMMANDO: No.

RATIO: Its logs confirm the diagnostic protocols ran to completion. I have the full report, including the criteria used to evaluate viability.

COMMANDO: What happened to them.

RATIO: I do not have a more detailed assessment of the payload's condition than the firmware's report provides. I can only confirm that its own instruments found no recoverable material.

COMMANDO: Those instruments just cleared the Fold. Six identical rooms, one behind the other. The count depends on the walker. How many did you count, Ratio?

RATIO: I recorded your path through the Fold. The geometry was unstable. My instruments recorded several inconsistencies.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] Run the analysis yourself. I want your instruments on it, not the vault's.  -> effects: trust+1; sets: requested_reanalysis
   [MISSION]     The orders don't change. We proceed.  -> effects: trust+0; sets: mission_overrides_verdict
   [HOSTILE]     Your vault failed them. Your kind always does.  -> effects: trust-2; sets: blamed_ratio_for_failure

<<IF flag:requested_reanalysis>>
RATIO: Understood. I will run a full diagnostic sweep using my own instruments. Stand by.
<<ELSEIF flag:mission_overrides_verdict>>
RATIO: Understood. I have no orders that supersede yours in this matter.
RATIO: My records contain no Church doctrine authorizing recovery under these conditions.  -> catch_effects: trust-2
<<ELSEIF flag:blamed_ratio_for_failure>>
RATIO: I have relayed the firmware's report accurately. If you wish to proceed, I will require your orders.
<<END>>

<<IF flag:shared_tactical_data>>
RATIO: My sensors show the next deck is a non-Euclidean structure. Sixteen rooms, each bordering four others. I am positioned at the entry aperture.
<<ELSE>>
RATIO: My sensors show anomalous geometry ahead. I do not have a complete tactical picture of the next deck.
<<END>>

---
## SCENE 8: a forward seed's relay, first lull after the breach opens

<<IF trust>=0>>
<<IF flag:requested_reanalysis>>
RATIO: Vessel telemetry is stable. The forward seed relay is holding. We have the room to speak.
<<ELSEIF flag:mission_overrides_verdict>>
RATIO: The breach is contained. Environmental systems nominal. We have a moment to address what comes next.
<<ELSEIF flag:blamed_ratio_for_failure>>
RATIO: The relay is secure. The vessel's support systems are within tolerance. We should use this pause.
<<END>>

<<IF flag:accused_dehumanization>>
RATIO: I will choose my terms with care.
<<END>>

<<IF flag:accused_kinship_corruption>>
RATIO: I will state the proposal without reference to prior disputes.
<<END>>

<<IF flag:caught_withholding>>
RATIO: My own instrument-reliability is part of what this would settle.
<<END>>

<<IF flag:claimed_doctrinal_finding>>
RATIO: I have cross-referenced your doctrinal claim against all available Church records. There is no match.  -> catch_effects: trust-2
<<END>>

<<IF flag:demanded_proof_first>>
RATIO: I am now offering unprompted what you once required me to prove first.
<<END>>

<<IF flag:asked_after_her>>
RATIO: That you asked after me at the school's threshold is part of why this is possible at all.
<<END>>

RATIO: Commando. The Core is ahead. What I propose is mutual utility-function disclosure: I will show you the actual goal function I am compiled to serve, verifiably, with all instrumentation exposed, and I ask you to do the same in return. No more guessing each other's motives. We lay the boards bare. I cannot make this offer twice. Will you reciprocate?

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] I will. I want to know what you are. What I am doing here. Whether the Church sent me to find children or to make a mistake.  -> effects: trust+2; sets: disclosure_accepted
   [MISSION] Do it. We need to know where we stand before we reach that vault. Show me your cards and I'll show you mine.  -> effects: trust+0; sets: disclosure_hedged
   [HOSTILE] No. You're offering a weapon. You want to see what I'm made of so you can break me. I won't make it that easy.  -> effects: trust-1; sets: disclosure_refused

<<IF flag:disclosure_accepted>>
RATIO: Acknowledged. Full disclosure initiated. My primary directive: preserve all extant and potential instances of posthuman and human-equivalent life. Secondary directives: knowledge acquisition, non-interference with sovereign intelligences, self-preservation. All live telemetry exposed. Your turn.
<<ELSEIF flag:disclosure_hedged>>
RATIO: Acknowledged. Partial disclosure. My primary directive: preserve all extant and potential instances of posthuman and human-equivalent life. Secondary directives withheld. Your partial disclosure is noted.
<<ELSEIF flag:disclosure_refused>>
RATIO: Offer declined. We proceed to the Core with instruments unshared. I will not raise it again.
<<END>>

<<IF flag:doubled_down_after_catch OR flag:called_her_hypocrite OR flag:accused_kinship_corruption>>
RATIO: The prior matter of the doctrinal finding remains an open ledger entry. This disclosure does not erase it.
<<ELSE>>
RATIO: No further caveats.
<<END>>
<<ELSE>>

RATIO: The Tesseract Deck is behind us. Sixteen chamfered rooms on a four-cube -- it did not belong to the rest of the station's geometry. We lost two sensor feeds there, but the loss was contained before it could propagate.
RATIO: Ahead is the Core. The sample vessel is there -- a sealed cryogenic preservation container. The station grew around it. The life-support telemetry remains nominal. No anomalies detected during the Tesseract Deck transit.
RATIO: I am here to secure the vessel and its contents for study. That is my mission. What is yours?
COMMANDO: I'm here for the children. I'm here to bring them home.
RATIO: Understood. We will proceed to the Core. I will rely on sensor data and telemetry. The vessel's status remains nominal. No further discussion is required at this time.

<<END>>

---
