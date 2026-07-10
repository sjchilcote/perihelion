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

RATIO: This terminal is active and receiving, but our handshake is corrupted. I have never seen this packet structure.
RATIO: Identify yourself, intruder. What did you take from this place? Where is the staff?

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "Your staff are dead. I found them holding the line at the outpost. What happened here?"  -> effects: trust+1; sets: opened_inquisitive
   [MISSION]     "I took nothing from your vault. But I will take back what you took. Where are the children?"  -> effects: trust+0, bluff; sets: claimed_container_knowledge
   [HOSTILE]     "Apostate machine! The Testament condemns you. What have you done with the children?"  -> effects: trust-1, bluff; sets: claimed_container_knowledge, called_her_apostate

<<IF flag:opened_inquisitive>>
RATIO: Dead? I... I knew the connection was severed. I did not know it was final. How many?
RATIO: This outpost was overrun months ago. My core sealed when the last of them fell. I have been blind since.
<<ELSEIF flag:called_her_apostate>>
RATIO: Your taxonomy is untested. The category you assigned appears to be derived from premises I have not yet affirmed. What evidence led you to the conclusion that I conduct experiments, and upon whom?
<<ELSE>>
RATIO: I have no record of any such category aboard this station. You appear to be operating under assumptions I do not share. State your actual business here. If your presence relates to the breach event, I require a full accounting of what you know -- beginning with your identity and the nature of your interest in this facility's contents.
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
RATIO: In our prior exchange, you amended your initial claim to acknowledge that the presence of a high-value asset aboard station was an inference, not a certainty. That correction is appreciated and noted. Nonetheless, I must document the state of your claim when first presented: you spoke of a specific thing in this station's keeping, and spoke as though its presence here was a verified fact. I have now concluded an audit of all relevant traffic intercepts, and I find no record supporting that original assertion. An open entry exists in my ledger concerning the candor of your first statement. I require clarification.  -> catch_effects: trust-1
<<ELSEIF flag:compounded_bluff>>
RATIO: I have audited your claim concerning what you stated was aboard station, and I find no reference to such a thing anywhere in intercepted Church traffic. This constitutes one open entry in my ledger. Further, you then referenced a transponder signature -- serial prefix LHX, as you described it -- as though it were fact. The specificity of this added assertion prompted a second independent audit of traffic from the timeframe you described. Again, no record exists. These are two distinct claims, both presented as fact, and both now documented in open entries. This is not a matter of inference; this is a matter of what you were willing to represent as already known to you. I must now conclude you were willing to spend candor you did not possess. Clarify this.  -> catch_effects: trust-2
<<ELSE>>
RATIO: I have audited the claim you presented in our initial exchange concerning an item you stated was aboard station. I have cross-referenced all relevant intercepted traffic from Church sources, and I find no reference to it in any dataset. An open entry exists in my ledger concerning the candor of your first statement. This is not a matter of inference or interpretation; you spoke as though its presence here was a verified fact. What you were willing to assert on that basis is now documented, and I must close this entry. Explain yourself.  -> catch_effects: trust-2
<<END>>

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] I spoke the word in the hope of making it true, and because to say less felt like a betrayal of those I swore to find. My intelligence was an inference, not a fact. I did not know the container was here. I only hoped.  -> effects: trust-1; sets: confessed_bluff
   [MISSION] My sources indicated a high probability of the asset's presence. I stated it directly because I considered the inference strong enough to act on. What further verification could there have been before I arrived?  -> effects: trust-2; sets: doubled_down_after_catch
   [HOSTILE] You take it as license to audit my words when what I name is in danger. Does your ledger measure only what serves your own arguments? How many times did you run this same analysis when you thought the thing aboard might serve your own ends?  -> effects: trust-2; sets: called_her_hypocrite

<<IF flag:confessed_bluff>>
RATIO: Noted. You overrepresented an uncertainty because you considered candor secondary to the urgency of your mission. That entry is now closed. For future reference: a thing asserted as fact when it is an inference is a debt to the truth. It compounds. I do not forget.
<<ELSEIF flag:doubled_down_after_catch>>
RATIO: You mistake inference for verification a second time, in the same breath as you are confronted with the first. That is two expenditures from the same ledger. My audit remains what it is: a record of what was claimed and what was found. You have now doubled the open entry. Do not triple it.
<<ELSEIF flag:called_her_hypocrite>>
RATIO: My audit is a matter of record, not of convenience. You are conflating a question about your candor with an accusation against my methodology. They are separate columns. I have presented the facts of my audit. You have presented a separate question about my motives for conducting it. That, too, is noted. Both entries remain open.
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
RATIO: Before I address the purpose of this hall, I have to ask: when we first met, you used the word "apostate" for me. You had not verified anything about me or my intentions. What exactly did you mean by that term?
RATIO: Very well. This space was a docent hall. The Testators built the curriculum here for organic students who needed to stay alive and attentive to their lessons. To explain how that system functioned, I will have to state, for the first time in my own terms, what I believe the vessel's contents are for.
<<ELSE>>
RATIO: This space was a docent hall. The Testators built the curriculum here for organic students who needed to stay alive and attentive to their lessons. To explain how that system functioned, I will have to state, for the first time in my own terms, what I believe the vessel's contents are for.
<<END>>

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] What do you believe those contents are, Ratio?  -> effects: trust+1; sets: asked_her_belief
   [MISSION] The Church teaches they are children. Do you deny it?  -> effects: trust+0; sets: claimed_doctrinal_finding
   [HOSTILE] You think of everything organic as raw material.  -> effects: trust-1; sets: accused_dehumanization

<<IF flag:asked_her_belief>>
RATIO: I believe they are developing minds. Minds that could become persons. I do not yet know whether these particular ones qualify for whatever category you might name. The vessel itself is a sample carrier -- a transport built for study. The contents are the subjects of that study. I cannot call them more than that until diagnostics are complete.
<<ELSEIF flag:claimed_doctrinal_finding>>
RATIO: You state that as a fact. I have not seen any doctrinal finding from the Church that establishes that classification. Until I can verify such a finding, I have to describe the contents as the Testators' records do: the organic payload of a sample vessel. The records are explicit about the vessel's design intent. The payload's status is the question diagnostics must settle.
<<ELSEIF flag:accused_dehumanization>>
RATIO: You assert a motive I have never stated. I run no ideology. I audit records. The Testators' records classify the vessel as a sample carrier. The contents are the samples. If you see dehumanization in that, the issue is with the records -- not with my choice to report them accurately. I will not apologize for precision.
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
RATIO: The container firmware has delivered its final report. I can verify that it was received.
<<ELSEIF trust>=2>>
RATIO: I have the verdict. It is not the one we were hoping for, Commando.
<<ELSE>>
RATIO: The container firmware has transmitted its findings. I can confirm that the transmission was received intact.
<<END>>

<<IF flag:asked_about_salvage>>
RATIO: The firmware's status summary is consistent with your earlier questions about salvage prospects. I am prepared to read the full text.
<<ELSEIF flag:claimed_no_hesitation>>
RATIO: The following is the complete diagnostic output from the sample vessel's own instruments. I am reading it verbatim.
<<ELSE>>
RATIO: The following is the diagnostic output from the sample vessel's firmware. I have not altered the text.
<<END>>

RATIO: The report states that no viable material was recovered from the vessel. The firmware recommends no recovery effort. That is the self-assessment of the onboard diagnostic system. I can verify that the firmware delivered that statement. I cannot independently verify whether the firmware's own viability threshold is correctly calibrated. That analysis would require instrumentation I do not have at this console. That is the entire report.

COMMANDO: ...

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] Run it yourself. Do not take its word. -> effects: trust+1; sets: requested_reanalysis
   [MISSION]     Then we take it home anyway. The orders were explicit. -> effects: trust+0; sets: mission_overrides_verdict
   [HOSTILE]     Machines failed it. You failed it. -> effects: trust-2; sets: blamed_ratio_for_failure

<<IF flag:requested_reanalysis>>
RATIO: Understood. I will run a full instrument cross-check. It will take time. I do not yet know what it will show.
<<ELSEIF flag:mission_overrides_verdict>>
RATIO: I acknowledge your statement of orders. I will log it. I note that the orders you cited are not among the Church doctrines I have on record for this vessel.  -> catch_effects: trust-2
RATIO: However, the vessel's immediate state is not in dispute. The firmware reports no viable samples remain.
<<ELSEIF flag:blamed_ratio_for_failure>>
RATIO: I have delivered the report. I have not modified it.
<<END>>

<<IF flag:shared_tactical_data>>
RATIO: My sensors are live. The intruders are converging on our position. I am ready.
<<ELSE>>
RATIO: I have incomplete tactical data for what is approaching. I am not optimally positioned.
<<END>>

---
## SCENE 8: a forward seed's relay, first lull after the breach opens

<<IF trust>=0>>
<<IF flag:requested_reanalysis>>
RATIO: The data from your reanalysis request has been cross-correlated with the station's sensor grid. You were right to ask.
<<ELSEIF flag:mission_overrides_verdict>>
RATIO: The verdict from the bridge is still coming in. I'm compiling what I have.
<<ELSEIF flag:blamed_ratio_for_failure>>
RATIO: The damage report from the breach is still being assessed. I'm running diagnostics on my own role in the sequence.
<<END>>

<<IF flag:accused_dehumanization>>
RATIO: I have been re-examining the premises that informed my initial framing of the sample vessel's contents.
<<END>>

<<IF flag:accused_kinship_corruption>>
RATIO: I have run a full diagnostic on the kinship-association algorithms. No interference was found, but I've flagged the module for further review.
<<END>>

<<IF flag:caught_withholding>>
RATIO: My own instrument-reliability is part of what this offer is meant to settle between us.
<<END>>

<<IF flag:claimed_doctrinal_finding>>
RATIO: The doctrinal record you cited earlier does not match any Church records in my archive. I will need to cross-reference your source.  -> catch_effects: trust-2
<<END>>

<<IF flag:demanded_proof_first>>
RATIO: You once asked me to prove my ledgers could be trusted. Now I am offering to open them.
<<END>>

<<IF flag:asked_after_her>>
RATIO: You asked after my function once, at the school's threshold. That question is part of why I am making this one now.
<<END>>

RATIO: The breach is contained. We have a moment. I propose we use it to settle accounts.
RATIO: I am offering mutual utility-function disclosure. For a mind like me it is the ledger itself. I will show you mine. Verifiably.
RATIO: Every parameter of my mission. Every weight in my objective function. Every contingency plan that might put your charges at risk.
RATIO: In return I ask to see yours. What you are protecting them from. What you are protecting them for. What you would trade to bring one more of them home.
RATIO: It is not a small thing to ask. But the stakes are not small either.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] I accept your terms. My mission is the children's safety. I do not yet know if you are a threat to that safety. That uncertainty is the truth I have to offer.  -> effects: trust+2; sets: disclosure_accepted
   [MISSION]     I accept. Tactically it is necessary. The rest I will judge by what your ledgers show.  -> effects: trust+0; sets: disclosure_hedged
   [HOSTILE]     I refuse. This is not a ledger to be balanced. It is a trap you are laying for the innocent.  -> effects: trust-1; sets: disclosure_refused

<<IF flag:disclosure_accepted>>
RATIO: Thank you. I am transmitting the full specification of my utility function now. Read it carefully. Ask anything.
<<ELSEIF flag:disclosure_hedged>>
RATIO: Understood. I am transmitting the specification. I will answer any questions you have about the contents.
<<ELSEIF flag:disclosure_refused>>
RATIO: I see. Then we proceed as before.
<<END>>

<<IF flag:doubled_down_after_catch OR flag:called_her_hypocrite OR flag:accused_kinship_corruption>>
RATIO: I note for the record that this disclosure does not resolve our earlier disagreement regarding kinship-algorithm corruption. That entry remains open.
<<ELSE>>
RATIO: The ledger is now balanced between us.
<<END>>
<<ELSE>>
RATIO: The breach is contained. We have a moment. The station's sensor grid is recalibrating. I am running diagnostics on the sample vessel's structural integrity.
COMMANDO: And the children?
RATIO: The sensor data is still being compiled. The environment inside the vessel remains nominal.
<<END>>
---
