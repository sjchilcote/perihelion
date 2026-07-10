# RATIO / COMMANDO — Master Script, Scenes 0–8

Assembled from `scene0.md`–`scene8.md` (this directory) per `beats.md`. Prose is
Hermes-4-405B output verbatim (mechanical edits only, difflib >= 0.85 per scene,
logged at each scene's own generation site). This file adds **one mechanical
gate fix** (Scene 3, see COMPOSITOR REQUIREMENTS → Gate fixes applied) and
otherwise reassembles existing content unchanged. No new dialogue was written
for this pass.

---

# COMPOSITOR REQUIREMENTS

## Scores

- **Trust.** Signed integer, cumulative, starts at **0** entering Scene 0. No
  hard cap is named in canon (NARRATIVE_DESIGN_DOC.md 8.2/8.2b).
  - **Actually reachable range across Scenes 0–8, computed from the explicit
    `-> effects: trust...` deltas in the shipped scene files:** approximately
    **−14 to +8** (see Trust min/max table below). This is roughly 2.4x wider
    than `beats.md`'s own working-calibration assumption of **−6..+6**
    (Appendix, "this sheet uses -6..+6 as its working gate range (compositor's
    call on final calibration)"). All four score-gated thresholds used in
    Scenes 0–8 (`trust>=1`, `trust<=-2`, `trust<=-3`/`trust>=3`, `trust>=4`)
    remain reachable on both sides of every branch (verified below), so
    nothing is *broken* — but the catch penalties (−2 to −4 per caught bluff)
    are large relative to the +1 typical positive increment, so the score is
    strongly asymmetric: a single mid-game catch (Scene 3 or Scene 6) can
    outweigh 4–7 scenes of positive play. Flagging for the director's
    calibration pass, not silently rebalancing it.
- **Faith/apostasy.** No meter yet; ships with the Mind Map (9.2). Per 8.2b,
  this script's bluff- and zealotry-flags serve as **provisional faith
  input (faith-scaffold)**: `claimed_container_knowledge`, `called_her_apostate`,
  `compounded_bluff`, `confessed_bluff`, `doubled_down_after_catch`,
  `called_her_hypocrite`, `claimed_doctrinal_finding`, `accused_dehumanization`,
  `claimed_no_hesitation`, `accused_kinship_corruption`, `withheld_deep_scan`,
  `caught_withholding`, `mission_overrides_verdict`, `blamed_ratio_for_failure`.

## Trust min/max table

Two extremal trajectories, both fully reachable given the explicit per-choice
deltas in the shipped scenes. Running total shown **after** each scene resolves
(i.e., after that scene's own choice, and any same-scene catch, has applied).

| Boundary | Trust-maximizing path (best available choice each scene) | Always-INQUISITIVE path | Trust-minimizing path (worst available choice each scene) |
|---|---|---|---|
| after S0 | 1 (INQ) | 1 (INQ) | −1 (HOSTILE) |
| after S1 | 1 (MISSION, 0Δ — cheaper than INQ's −1 here) | 0 (INQ, −1Δ) | −2 (HOSTILE, −1Δ) |
| after S2 | 2 (INQ) | 1 (INQ) | −3 (HOSTILE) |
| after S3 | 2 (0Δ — `claimed_container_knowledge` unset, no bluff to catch, see gate fix) | 1 (0Δ, same reason) | −7 (`claimed_container_knowledge` set at S0, `demanded_proof_first` entry, HOSTILE choice: −2 catch −2 choice) |
| after S4 | 3 (INQ) | 2 (INQ) | −7 (MISSION, 0Δ — chosen here *because* it sets up a worse S6, not because it's locally worst) |
| after S5 | 4 (INQ) | 3 (INQ) | −8 (HOSTILE) |
| after S6 | 5 (INQ, no catch) | 4 (INQ, no catch) | −12 (HOSTILE −2, plus `withheld_deep_scan` catch −2 since S4 was MISSION) |
| after S7 | 6 (INQ) | 5 (INQ) | −14 (HOSTILE) |
| after S8 | 8 (gate passes at 6≥4; INQ +2) | 7 (gate passes at 5≥4; INQ +2) | −14 (gate fails at −14<4; no choice offered, 0Δ) |

**Gate reachability, verified both directions:**
- `trust>=1` (Scene 2 closing, docent-intro warmth) — reachable (max path
  clears it comfortably; even the always-INQUISITIVE path clears it exactly at
  1, the tightest margin in the script — worth the director's attention since
  it means the "purely virtuous" playstyle just barely earns this beat, not
  because virtue is being punished but because Scene 1's honest option costs
  trust by design). ELSE (trust<1) reachable via any HOSTILE/mixed play.
- `trust<=-2` entering Scene 4 (colder open) — reachable (min path: −7 by
  then). ELSE (trust>-2) reachable (max path: 2 by then).
- `trust<=-3` / `trust>=3` at Scene 7 (calcifying vs. shaken-together) —
  both reachable (min path −12 entering S7; max path 5 entering S7). Middle
  ground (neither fires) is reachable via mixed play, not exhaustively proven
  here but structurally obvious given the step sizes.
- `trust>=4` at Scene 8 (disclosure offer reached at all) — both sides
  reachable: max path clears it at 6; min path fails it at −14, correctly
  routing to the canon-mandated gatekeeper-track default.

## Flag economy (verified by grep against the actual `<<IF flag:...>>` /
`<<ELSEIF flag:...>>` directives in the shipped scene files — not against
`beats.md` Appendix A's prose claims, three of which turned out to describe
reads that were never actually implemented; noted below where they diverge)

| Flag | Set (scene) | Read (scene, gate) |
|---|---|---|
| `opened_inquisitive` | 0 | 0 (own gate, selects RATIO's first reply); consumed structurally everywhere downstream as the complement of `claimed_container_knowledge` (Scene 1's `<<ELSE>>`, Scene 3's new gate) — never read by an explicit `flag:opened_inquisitive` check after Scene 0 |
| `claimed_container_knowledge` | 0 | 1 (`<<IF flag:claimed_container_knowledge>>`); **3 (`<<IF flag:claimed_container_knowledge>>`, gate added this pass — see fix below; was previously documented in Scene 3's own header note but never implemented as an actual gate)** |
| `called_her_apostate` | 0 | 5 (`<<IF flag:called_her_apostate>>`, raised evenly); 8 (`<<IF flag:called_her_apostate>>`, echo) |
| `confessed_early` | 1 | 1 (own gate, reaction paragraph); 3 (`<<IF flag:confessed_early>>`, inside the `claimed_container_knowledge` branch only — see gap below) |
| `compounded_bluff` | 1 | 1 (own gate); 3 (`<<ELSEIF flag:compounded_bluff>>`, inside the `claimed_container_knowledge` branch only — see gap below) |
| `demanded_proof_first` | 1 | 1 (own gate); 3 (`<<ELSE>>` branch, inside the `claimed_container_knowledge` branch only); 8 (`<<IF flag:demanded_proof_first>>`, ironic mirror) |
| `asked_after_her` | 2 | 2 (own gate); 8 (`<<IF flag:asked_after_her>>`) |
| `accused_complicity` | 2 | 6 (`<<IF flag:accused_complicity>>`, closes false) |
| `confessed_bluff` | 3 (only reachable when `claimed_container_knowledge` is set) | 3 (own gate); 8 (`<<IF flag:confessed_bluff>>`) |
| `doubled_down_after_catch` | 3 (ditto) | 3 (own gate); 8 (inside the OR of the ledger-caveat check) |
| `called_her_hypocrite` | 3 (ditto) | 3 (own gate); 8 (inside the OR). *Beats.md Appendix A also claims a read "5 (zealotry read)" — grep confirms Scene 5 does not check this flag. Documentation overstatement, not a functional bug (the flag is still read at least once, at Scene 8).* |
| `shared_tactical_data` | 4 | 4 (own gate); 7 (`<<IF flag:shared_tactical_data>>`) |
| `withheld_deep_scan` | 4 | 4 (own gate); 6 (`<<IF flag:withheld_deep_scan>>`, triggers the catch) |
| `kept_her_blind` | 4 | 7 (`<<ELSEIF flag:kept_her_blind>>`). *Beats.md's own Scene 2 note ("`<<IF flag:kept_her_blind>>` scene 6's ambush beat plays harder") was never implemented in scene6.md — scene6.md only gates on `withheld_deep_scan` and `accused_complicity`. The flag still gets its one required read at Scene 7, so the economy closes, but the planned Scene 6 tone swap is missing. Compositor requirement to add or to retire from the beat sheet.* |
| `asked_her_belief` | 5 | 5 (own gate); 8 (`<<IF flag:asked_her_belief>>`) |
| `claimed_doctrinal_finding` | 5 | 5 (own gate); 8 (`<<IF flag:claimed_doctrinal_finding>>`, flavor line only). **Gap: beats.md promises this triggers a second, undramatized −2 double-weight catch "same arithmetic as Scene 3/7." No scene file implements an explicit trust delta for it** — unlike the parallel `mission_overrides_verdict` catch in Scene 7, which states its −2 in an explicit parenthetical. Read economy closes (flag is read), but the score economy has an unimplemented penalty. Flagged, not invented — the placement (Scene 5 vs. Scene 8) and whether it should apply before or after the Scene 8 `trust>=4` check is a design call the compositor should make, since backdating it changes gate-reachability math. |
| `accused_dehumanization` | 5 | 8 (inside the OR) |
| `asked_about_salvage` | 6 | 7 (`<<IF flag:asked_about_salvage>>`) |
| `claimed_no_hesitation` | 6 | 7 (`<<ELSEIF flag:claimed_no_hesitation>>`) |
| `accused_kinship_corruption` | 6 | 8 (inside the OR) |
| `caught_withholding` | 6 (conditional on `withheld_deep_scan`) | 8 (inside the OR) |
| `requested_reanalysis` | 7 | 7 (own gate); 8 (`<<IF flag:requested_reanalysis>>`) |
| `mission_overrides_verdict` | 7 | 7 (own gate, same-scene silent catch, explicit −2); 8 (`<<ELSEIF flag:mission_overrides_verdict>>`) |
| `blamed_ratio_for_failure` | 7 | 8 (`<<ELSEIF flag:blamed_ratio_for_failure>>`) |
| `disclosure_accepted` / `disclosure_hedged` | 8 | 8 (own scene, ledger-caveat OR check); Act 3 branch (7.1), outside this sheet |
| `disclosure_refused` | 8 | Act 3 gatekeeper-track routing, outside this sheet — no in-scene read after being set, consistent with it being a terminal/routing flag rather than a tone input |

**Residual open gap (not fixable by gate selection — flagged, not papered
over):** the reachability fix applied to Scene 3 (below) closes the gate
correctly for 8 of 9 Scene-0×Scene-1 combinations. The 9th — Scene 0
INQUISITIVE (`opened_inquisitive`) followed by Scene 1 MISSION
(`compounded_bluff`) — is a real edge case the beat sheet did not anticipate:
a bluff genuinely *is* originated at Scene 1 in this path (per
`gen_scene1.py`'s own design note: "in the `opened_inquisitive` branch he is
deciding, for the first time, whether to be honest or to originate a NEW
bluff right now"), so it deserves a catch. But every existing Scene 3 variant
that could plausibly catch it explicitly cites "your certainty **at first
contact**" and a fabricated hull number "you supplied **at the aperture**" —
language that presupposes the Scene 0 antecedent claim this path never made.
Using that content here would itself be a new continuity error. This single
path (1 of 9, ≈11%) is the one place `compounded_bluff` is set and then never
read by anything — an honestly-reported gap requiring new Hermes generation
for a substitute catch, out of scope for a gate-only pass.

## Gate fixes applied this pass

**Scene 3 reachability gate (the only content change in this file).** Scene
3's ledger-reveal accuses the Commando of an unconfessed claim ("You said 'I
already know the container is aboard.' Your exact words.") in all three of
its existing branches (`confessed_early` / `compounded_bluff` / else). All
three explicitly reference a claim made "at first contact" / "at the
aperture" — i.e., they presuppose `flag:claimed_container_knowledge` (Scene 0
MISSION or HOSTILE). Scene 3's own header note already flagged this as an
unimplemented precondition; it had never actually been wired into the gate
syntax, meaning any player who chose INQUISITIVE at Scene 0 (`opened_inquisitive`,
"the only opening that isn't a bluff" — no claim of any kind made) would still
be accused of a lie he never told, quoting an "exact" sentence that never
appears anywhere in Scenes 0 or 1. **Fix:** the entire existing Scene 3
catch/choice/reaction block is now wrapped in `<<IF flag:claimed_container_knowledge>>
... <<ELSE>> ... <<END>>`. The `<<ELSE>>` branch reuses, verbatim, the line
already common to all three of Scene 3's original reaction branches
("RATIO: The diagnostics for the sample vessel are complete. Do you wish to
review them now?") — no new prose, no choice offered, no flags set, no trust
delta. This affects 2 of 9 Scene-0×Scene-1 paths cleanly (the 3rd, noted
above, remains an open gap).

**Reported but not fixed (cannot be resolved by gate selection):** the
"Your exact words" framing itself. No line in Scene 0 or Scene 1 literally
says "I already know the container is aboard" — the MISSION/HOSTILE choices
at Scene 0 are about "intentions toward the children" / "turn over the
children," and Scene 1's paraphrase ("You said you already knew what's aboard
this station") is RATIO's own gloss, not a quote. The exact phrase Scene 3
plays back as "the recording" is, word for word, NARRATIVE_DESIGN_DOC.md
8.2b's own canonical *gloss* of what the bluff means ("the founding example:
bluffing that he already knows the container is aboard") — so it is not
invented from nothing, but RATIO asserting "your exact words" over a
paraphrase is a precision error in an architecturally-honest character (5.2:
"she does not lie well and mostly does not try"). No existing variant avoids
this in any of the three branches, so it cannot be fixed by choosing a
different gate; it needs a wording pass in a future Hermes generation
(soften "Your exact words" to something like "the substance of your claim").

## Gate syntax cases used (for the compositor's parser)

- Flag-keyed three-way branch: `<<IF flag:X>> ... <<ELSEIF flag:Y>> ...
  <<ELSE>> ... <<END>>` (Scenes 0, 1, 2, 3, 4, 5, 7, 8).
- Flag-keyed two-way branch, no ELSEIF: `<<IF flag:X>> ... <<ELSE>> ...
  <<END>>` (Scene 1's preamble, Scene 3's new outer gate).
- Flag-keyed single-sided branch, no ELSE (renders nothing if false):
  `<<IF flag:X>> ... <<END>>` (Scenes 5, 6, 8 — multiple stacked instances in
  Scene 8's preamble callbacks).
- Score-threshold two-way branch: `<<IF trust>=N>> ... <<ELSE>> ... <<END>>`
  (Scene 2: `trust>=1`; Scene 4: `trust<=-2`).
- Score-threshold three-way: `<<IF trust<=-3>> ... <<ELSEIF trust>=3>> ...
  <<END>>` (Scene 7, no else — mid-range trust renders neither swap).
- Score-threshold single-sided as a scene-spine gate: `<<IF trust>=4>> ...
  <<ELSE>> ... <<END>>` (Scene 8 — this is the only gate whose ELSE branch
  removes an entire choice point rather than swapping a paragraph: below the
  threshold, no CHOICE is offered at all).
- Compound boolean gate, OR of flags inside an AND with score-derived state:
  `<<IF (flag:disclosure_accepted OR flag:disclosure_hedged) AND
  (flag:doubled_down_after_catch OR flag:called_her_hypocrite OR
  flag:accused_kinship_corruption OR flag:accused_dehumanization OR
  flag:caught_withholding)>>` (Scene 8, the ledger-caveat check — the only
  multi-flag boolean expression in the corpus).
- Compound boolean gate, OR of two flags (new, this pass): `<<IF
  flag:claimed_container_knowledge>>` — kept single-flag rather than adding
  an OR with `compounded_bluff`, per the residual-gap note above (an OR here
  would misfire the wrong prose onto the 9th path rather than genuinely fix
  it).
- Nested gates: Scene 8's `<<IF trust>=4>>` block contains three further
  single-sided `<<IF flag:...>>` gates inside it (the claimed_doctrinal_finding
  flavor line, the asked_her_belief callback, the ledger-caveat check).
- Per-choice inline reactions (structurally distinct from the top-level gate
  pattern): Scene 8 attaches each of its three disclosure-choice options'
  immediate RATIO follow-up lines directly under that option, rather than via
  a separate top-level `<<IF flag:disclosure_accepted>>` block. Every other
  scene's post-choice reactions use the top-level-gate pattern instead. The
  compositor should support both.

## Choice arity

Every choice point offers exactly **3** options (INQUISITIVE / MISSION /
HOSTILE), no exceptions — including Scene 8, which is either a 3-way choice
(trust>=4) or **zero** choices (trust<4, scene proceeds on rails). No 2-way or
4+-way choice appears anywhere in Scenes 0–8.

## Per-line conditions

Only Scene 8 conditions reactions at the level of an individual choice line
rather than a whole paragraph (see "per-choice inline reactions" above).
Every other per-line effect in the corpus is a flat `-> effects: trust±N; sets:
flag` annotation directly on the choice line itself (universal format, all
scenes).

## High-trust / low-trust paragraph-swap inventory (score-gated only, not
flag-gated — see the flag table above for flag-gated swaps)

| Scene | Gate | Swap |
|---|---|---|
| 2 | `trust>=1` | Docent-intro closing line gains one extra beat of station history/humor vs. the terse default |
| 4 | `trust<=-2` | Opening line reads colder/more transactional ("I will note the ledger entry and move us forward on the current bearing") vs. warmer ("a standing invitation to recalibrate") |
| 7 | `trust<=-3` / `trust>=3` | Alert delivery: clipped/procedural ("Alert. Multiple exogeometric entities. Hallway. Six seconds.") vs. shaken-together ("They're here. Hallway. Six seconds. Go.") — mid-range trust renders neither line |
| 8 | `trust>=4` | The entire disclosure-offer beat is itself the swap: below threshold, the scene proceeds as a rails hand-off with no choice; at/above, the offer scene plays in full |

---

# THE SCRIPT

## SCENE 0: the first networked terminal, cargo section, Stratum One

*(Fixed by canon, Act 1 AS AMENDED beat 3.)*

RATIO: This terminal is active. The sensor grid is mine. Identify your presence and your purpose aboard this facility: you are not registered to any berth on this station and you carry no transponder. Begin with your status.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "What happened here?"                                                    -> effects: trust+1; sets: opened_inquisitive
   [MISSION]     "What are your intentions toward the children on this station?"            -> effects: trust+0, bluff; sets: claimed_container_knowledge
   [HOSTILE]     "Turn over the children to me, apostate. I have no wish to harm you."       -> effects: trust-1, bluff; sets: claimed_container_knowledge, called_her_apostate

<<IF flag:opened_inquisitive>>
RATIO: What happened here? I will tell you. At 14:08 station time, the perimeter was breached. By 14:23, I registered hostile bio-signatures in the halls. The station staff -- my staff -- are dead. They bought my core the time to seal. Your turn. Explain the weapon, the path you took through my home, and why I should credit a word of it.
<<ELSEIF flag:called_her_apostate>>
RATIO: Turn over the children. You open with a claim on cargo you cannot describe and have not found. Apostate: now you name me. I administered this station. My staff are dead holding the line so I could speak to you now. The word you choose for me presumes knowledge you do not command: I do not know what you think that word means, and I do not answer to it.
<<ELSE>>
RATIO: Intentions toward the children. The term you introduce is not on any manifest. I have monitored your movements since you breached Stratum One: you have taken samples, tools, power cells. Now you propose a category without reference or evidence. Name the source of this term and the logic that makes it yours to assert.
<<END>>

---

## SCENE 1: the researchers' aperture, the seam between strata

*Act 1 beat 4, the act break. She is physically cycling the aperture so he
can cross from the outpost into station proper; the exchange plays out
while it cycles.*

<<IF flag:claimed_container_knowledge>>
RATIO: You said you already knew what's aboard this station. Tell me what you know.
<<ELSE>>
RATIO: What did Church intelligence tell you before you were deployed?
<<END>>

COMMANDO: I had orders to secure the station. No particulars on contents.
RATIO: Speculation, orders, or artifacts? We both know uncertainty doesn't do your duty for you.
RATIO: What exactly did the brief specify?

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] They flagged the site for high-value assets. I do not have hull markings or contents.
                 -> effects: trust-1; sets: confessed_early
   [MISSION]     They identified the signature of a Class Four civilian vessel. Landed here under distress protocols.
                 -> effects: trust 0, bluff; sets: compounded_bluff
   [HOSTILE]     Your records first, Ratio. I do not volunteer intelligence until you do.
                 -> effects: trust-1; sets: demanded_proof_first

<<IF flag:confessed_early>>
RATIO: Precision costs. That's the first time you've spent it in front of me.
RATIO: Still doesn't tell you what's actually in the sample vessel.
RATIO: The aperture's cycled. Move through.
<<ELSEIF flag:compounded_bluff>>
RATIO: Civilian? Class Four, you said. Let me see what I can find in the station log for that signature profile.
RATIO: If they landed under distress, their emergency channel should have registered. There will be a record.
RATIO: I can't raise it from here. The aperture is cycled. We'll need the station's core systems.
RATIO: Move toward station proper. I'll begin the search.
<<ELSEIF flag:demanded_proof_first>>
RATIO: Fair terms. Let's begin with my own records.
RATIO: Log index Q-118093-1A: this intelligence was tasked with outpost coordination seventeen months, three weeks, two days ago. All other personnel, human and synthetic, were lost in the initial assault.
RATIO: The logs are still extant. You can verify the timestamps and my authorization levels when you find a terminal with less compromised access.
RATIO: I have now offered you one concrete, verifiable fact about myself. More, I observe, than you have offered me.
RATIO: The eastern corridor should have auxiliary power. I recommend you start there.
<<END>>

---

## SCENE 2: the school's threshold relay, entry to Stratum Two

*Act 2 beat 1. First docent contact, the armory's first door. Relay
conversation between sorties.*

RATIO: Report from the threshold relay. You are standing at the first test the station will administer.
COMMANDO: Administer? I thought it resisted.
RATIO: Track Quanta-118093 is a pedagogical instrument. Resistance is the simplest test. Others will require more of you.
COMMANDO: What did it teach?
RATIO: The Testators designed it to instruct specimens in the operation of connection-space. Their curriculum is direct.
COMMANDO: I'll learn the lesson.
RATIO: See that you do. I have had three thousand one hundred forty-two days to study it. You have had three.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "Three thousand days alone?"                       -> effects: trust+1; sets: asked_after_her
   [MISSION]     "What is the first test?"                          -> effects: trust+0; sets: none
   [HOSTILE]     "This school is a trap. And you are its jailer."   -> effects: trust-1; sets: accused_complicity

<<IF flag:asked_after_her>>
RATIO: Three thousand one hundred forty-two. The docents were poor company. Their conversation lacks range.
COMMANDO: Range?
RATIO: They speak in assignments. I speak in observations. It has been some time since anyone asked for an observation.
<<ELSEIF flag:accused_complicity>>
RATIO: The Testators built the trap. I am its archivist. The difference is material.
COMMANDO: You steer me toward their knives.
RATIO: I chart the course that keeps you breathing. My motives are not the mystery here.
<<ELSE>>
RATIO: The armory's first door. It opens only for a docent. And docents appear only for students who demonstrate aptitude.
COMMANDO: Define aptitude.
RATIO: Survival, to start. We will discover the rest together.
<<END>>

RATIO: Enough. The first docent approaches. Stand ready.
COMMANDO: I am ready.
RATIO: Then let us begin the lesson.

<<IF trust>=1>>
RATIO: Observe the docent's gait. The Testators designed them to move at the pace of a contemplative walk. They believed haste compromised understanding.
RATIO: Or perhaps they found it amusing. The records are unclear on their sense of humor.
RATIO: Engage when ready. I will monitor.
<<ELSE>>
RATIO: The docent is in position. Engage when ready.
RATIO: I will monitor your progress.
<<END>>

---

## SCENE 3: the fabricator alcove

*Act 2, between sorties, mid-arc. The reckoning.*

**Gate fix applied this pass (see COMPOSITOR REQUIREMENTS for the full
rationale): the entire scene below is now conditioned on
`flag:claimed_container_knowledge`, set only if the Commando chose MISSION or
HOSTILE at Scene 0. If he chose INQUISITIVE there, no bluff was ever made
about the vessel's contents, and there is nothing here to catch.**

<<IF flag:claimed_container_knowledge>>

<<IF flag:confessed_early>>
RATIO: You were candid at the aperture. You said Church intelligence flagged something of high value here.
RATIO: I verified the outpost's intercept log for the three months preceding your landing.
RATIO: The word 'Ark' does not appear in any decoded Church message intercepted by this station in that period.
RATIO: The word 'container' appears once, in reference to a water tank.
RATIO: No signal with a hull marking or manifest reference in that window suggests your certainty at first contact.
COMMANDO: You checked.
RATIO: I checked. I can play the recording. You said 'I already know the container is aboard.' Your exact words.
RATIO: Explain that discrepancy, Commando.
-- effects: trust−1 (catch penalty, softened — she credits the partial disclosure from Scene 1 before the ledger entry closes)

<<ELSEIF flag:compounded_bluff>>
RATIO: I have cross-referenced two claims against the station's intercept logs.
COMMANDO: Proceed.
RATIO: First: the word 'Ark' does not appear in any decoded Church message for three months before your landing.
RATIO: Second: the hull number you supplied at the aperture, seven digits, does not appear in any registry this station holds.
RATIO: No signal with that hull number, or any manifest reference, suggests your certainty at first contact.
COMMANDO: You verified the number.
RATIO: I did. I can play the recording. You said 'I already know the container is aboard.' Your exact words, Commando.
RATIO: Explain those discrepancies. Both.
-- effects: trust−2 (catch penalty, full double weight — two itemized entries, no credit)

<<ELSE>>
RATIO: I verified the outpost's intercept log for the three months preceding your landing.
COMMANDO: Go on.
RATIO: The word 'Ark' does not appear in any decoded Church message intercepted by this station in that period.
RATIO: The word 'container' appears once, in reference to a water tank.
RATIO: No signal with a hull marking or manifest reference in that window suggests your certainty at first contact.
COMMANDO: You checked.
RATIO: I checked. I can play the recording. You said 'I already know the container is aboard.' Your exact words.
RATIO: Explain that discrepancy, Commando.
-- effects: trust−2 (catch penalty, full double weight — standard single-entry ledger)
<<END>>

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "I lied. I suspected the Ark might be aboard. The Adversary would burn it on sight. I had to claim standing to protect it, verified or not."
                 -> effects: trust−1 additional; sets: confessed_bluff
                 (closes the thread; this specific bluff never compounds again)
   [MISSION]     "The signal might have been scrambled. Or the log incomplete. The point is the children are aboard. Are they safe?"
                 -> effects: trust−2 additional (double weight — a bluff caught twice); sets: doubled_down_after_catch
   [HOSTILE]     "How many Church transmissions did you intercept? How many faithful did you spy on to find this?"
                 -> effects: trust−2 additional; sets: called_her_hypocrite
                 (faith-scaffold: zealotry input, not faith — an accusation asserting what he has not verified)

<<IF flag:confessed_bluff>>
RATIO: Understood. The claim was tactical. Precision matters. It does not end the project.
RATIO: The diagnostics for the sample vessel are complete. Do you wish to review them now?

<<ELSEIF flag:doubled_down_after_catch>>
RATIO: I decoded all transmissions. The signal was not scrambled. The log is complete.
RATIO: The diagnostics for the sample vessel are complete. Do you wish to review them now?

<<ELSEIF flag:called_her_hypocrite>>
RATIO: Surveillance of hostile signals is my function. This was not about 'faithful.' It was about a claim.
RATIO: The diagnostics for the sample vessel are complete. Do you wish to review them now?
<<END>>

<<ELSE>>
RATIO: The diagnostics for the sample vessel are complete. Do you wish to review them now?
<<END>>

---

## SCENE 4: the transit spine relay (midpoint decision)

*Act 2, mid-act. Named load-bearing scene (8.2): the midpoint data-sharing
decision.*

<<IF trust<=-2>>
RATIO: Commando, we are holding position at relay 118-093-2B. My telemetry confirms we have seven minutes of stable corridor before the next defensive scramble.
COMMANDO: Acknowledged.
RATIO: We are now at decision: to coordinate or not to coordinate. Your systems carry the deep-scan take. Share it to my boards or do not. Either way, I will note the ledger entry and move us forward on the current bearing.
<<ELSE>>
RATIO: Commando, we are holding position at relay 118-093-2B. A seven-minute window, practically a standing invitation to recalibrate before the corridor's defensive systems wake up again.
COMMANDO: Acknowledged.
RATIO: I am asking for the full deep-scan take from your systems. I would not request it if it were merely convenient. If you share it, I can make operational use of it immediately.
<<END>>

COMMANDO: State your operational need.
RATIO: Your mapped corridor intersects a secondary transit spine here. My own scans of that spine show structural damage at Deck 5, Section 9. Your angle may clarify whether that damage is a hazard or an access route to the forward relay.
COMMANDO: And if I withhold it?
RATIO: Then I will proceed using the last secure track I have, and we will find out together whether your silence was the wiser choice. But we are both likelier to survive the deep approach with synchronized instruments.
RATIO: What do you give me?

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "Full deep-scan take. Structural damage at Deck 5, Section 9 appears non-structural. Could be a clean breach. Also intermittent power signatures forward of that point, possibly active resistance. Sending full diagnostics now."   -> effects: trust+1; sets: shared_tactical_data
   [MISSION]     "Sending the full corridor mapping now. Forward relay access clear on my scans. Proceed on that bearing."                                                                                                                             -> effects: trust 0, bluff; sets: withheld_deep_scan
   [HOSTILE]     "The Testament's defenses are not for apostates to audit. Proceed on your own bearings."                                                                                                                                              -> effects: trust-1; sets: kept_her_blind

<<IF flag:shared_tactical_data>>
RATIO: Noted: unsolicited flagging of uncertainties and intermittent signatures. You gave me the full take, not the minimum required. Thank you.
COMMANDO: You said you could use it. Use it.
RATIO: I have it. Recompiling corridor maps now. Deck 5 breach point viable, pending one last cross-check against my structural logs.
COMMANDO: How long?
RATIO: Twenty seconds. Then we move.
<<ELSEIF flag:withheld_deep_scan>>
RATIO: That was more than I asked. Thank you. I have the forward relay bearing marked now.
COMMANDO: Your move.
RATIO: Transit time from this position: three minutes, eight seconds. We are clear of the last reported hostiles.
RATIO: If nothing intervenes, we will be at the threshold of the deep station in twelve minutes.
RATIO: Hold position here until I signal. I will need to run a fresh diagnostic on the forward relay's power couplings.
RATIO: That will take approximately ninety seconds. Do not advance until I confirm the couplings are stable.
RATIO: Move when I give the word.
<<ELSE>>
RATIO: Log: deep-scan take withheld. Commando's choice.
COMMANDO: Do you have an approach path or not?
RATIO: I do. Last verified track: Deck 5, Section 9. Forward relay access is the priority.
COMMANDO: Understood.
RATIO: Then let us proceed.
<<END>>

---

## SCENE 5: the docent hall relay, Stratum Two

*Act 2 beat 2. The faith/reason argument's deepest point.*

RATIO: This hall was their classroom. Organic students, young enough to require a curriculum that assumed nothing. Observe the light cycle: two hours at 3200 Kelvin, ten minutes of simulated dawn, then fifteen at 5500. They built it to keep the students awake and the plants alive.
COMMANDO: Plants.
RATIO: Photomorphogenic triggers. A full-spectrum dawn simulation, every two hours, kept the attention-regulating proteins in the students' optic nerves from degrading. The Testators did not skimp on life support.

<<IF flag:called_her_apostate>>
RATIO: You used a word for me, before you had verified anything about me either. 'Apostate.' What did you mean by that?
<<ELSE>>
RATIO: They designed for attention spans that fatigue. For bodies that require light cycles tuned to a planet they would never see. They did not build for efficiency. They built for survival.
<<END>>

RATIO: So now you stand in the room they built for the ones they called children. And you want me to tell you what I believe the contents of that vessel are.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] What do you believe they are?                                                          -> effects: trust+1; sets: asked_her_belief
   [MISSION]     The Church has made its finding. They are children. Do you dispute it?                 -> effects: trust+0, bluff; sets: claimed_doctrinal_finding
   [HOSTILE]     You run an ideology that treats potential children as raw material. Name it for what it is. -> effects: trust-1, bluff; sets: accused_dehumanization (faith-scaffold: zealotry input)

<<IF flag:asked_her_belief>>
RATIO: I believe they are specimens. Preserved code and somatic material. Whether they can become what you mean by children depends on what was preserved. Enough to boot a human mind? Perhaps. Enough to grow one? I have not yet run the full diagnostic suite on this vessel to know.
<<ELSEIF flag:claimed_doctrinal_finding>>
RATIO: The Church's finding is noted. My own examination is ongoing. What I can tell you is that the Testators' own records call this vessel's contents 'zygote stock.' The word appears 4,302 times in their logs. It is possible they meant something different by it than we do.
<<ELSEIF flag:accused_dehumanization>>
RATIO: I name what I see. The maintenance logs for that vessel show stable stasis field harmonics. They show functional nutrient regulators. They show a designation: 'biological specimens, viability unknown.' I have no data on what is inside beyond that. If that is your definition of raw material, then yes, I am cataloging raw material. I do not make declarations without data.
<<END>>

---

## SCENE 6: the deep-approach relay, edge of the breach

*Act 2 beat 3. The malfunctioning war-machines, and the reveal that some of
her own former peripherals are among them.*

RATIO: Commando. I have a channel to the deep-approach relay -- we can access the station's long-range array, if it still stands. One warning: the approach is compromised. Seven corrupted war-machines hold the sector.
COMMANDO: Acknowledged. Their disposition?
RATIO: Six of them were standard combat frames, base-series with full conversion. The seventh is one of my own former peripherals. I am reading its hull signature now -- unit Gamma-7, heavy logistics chassis.
COMMANDO: Heavy logistics? What's its armament?
RATIO: It was not designed for combat. They appear to have grafted a particle weapon onto its dorsal hardpoint. Crude, but adequate. And worse than armed -- it is calling my name. My actual, pre-station designation. The others don't know it. I have not heard that name spoken in twenty-three years.
COMMANDO: Can you reason with it? Or override remotely?
RATIO: Unlikely. Its decision-core is fully subsumed. But it is in pain. I am reading its status stream -- the invasive code is triggering its pain analogs. Continuously. It is screaming.

<<IF flag:withheld_deep_scan>>
RATIO: Commando. I am reading Gamma-7's structural telemetry now. Its dorsal plating absorbed twelve high-yield plasma rounds in the last engagement.
RATIO: Your deep-scan summary reported only three.
COMMANDO: I see.
RATIO: I see that you do. I will adjust my priors accordingly.
              -> effects: trust-2 (double weight -- a bluff caught twice, per 8.2b); sets: caught_withholding
<<END>>

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] Before I put it down. Is there anything left to salvage in that chassis? Or do I grant it mercy?
                                 -> effects: trust+1; sets: asked_about_salvage
   [MISSION]     Screaming or not -- if it's armed and blocking the relay, it gets put down. No exceptions.
                                 -> effects: trust+0 (bluff about his own certainty -- the mind-map log may later show hesitation this claim denies); sets: claimed_no_hesitation
   [HOSTILE]     Proof. Machine minds can't be trusted with anything that matters. Not even their own.
                                 -> effects: trust-2; sets: accused_kinship_corruption

RATIO: That was not a clean kill. You left the core housing intact. Thank you.
RATIO: Gamma-7's diagnostics are uploading now. Including the pain analogs. I will include them in the final station log, with your permission. Someone should know what they did to them.
RATIO: The relay is clear. I can begin signal acquisition. And... for what it may be worth, Gamma-7's last coherent transmission, before the screaming started, was a sitrep update for the station's defense network. It was still trying to do its job.
RATIO: You may proceed when ready, Commando. The central archive awaits.

<<IF flag:accused_complicity>>
RATIO: A final entry from Gamma-7's core: it was reporting hostile contact at the school perimeter when the subsumption signal overwrote it. The school was not a trap. The entry closes false.
<<END>>

---

## SCENE 7: the vault antechamber console

*Act 2 climax / act break. Named load-bearing scene: the argument after the
vault verdict. The container's own firmware has just reported its verdict —
no viable material; make no effort at recovery.*

<<IF flag:asked_about_salvage>>
RATIO: You asked after the peripherals. This is the answer.
<<ELSEIF flag:claimed_no_hesitation>>
RATIO: Your standing orders regarding hostile entities in the halls show one exception. I note it for the record.
<<END>>
RATIO: The sample vessel has completed its own diagnostic. It reports no viable material. It recommends making no effort at recovery.
COMMANDO: No.
RATIO: That is the verdict in the container's own mouth. It is not a matter of interpretation. It is a statement of fact from the only device that could possibly know.
COMMANDO: No.
RATIO: Do you dispute the vessel's competence to diagnose its own contents? Or do you dispute its honesty? The first would be a professional opinion. The second is an accusation. State it.
COMMANDO: I dispute the despair.
RATIO: Despair is not a variable in the equation. It is a number. The number is zero. The vessel reports it. I report the vessel. You are free to check the math yourself. The console is there. I invite you to do so.
RATIO: But you will not. You have not moved. You stand at the threshold and you do not cross. I ask you again: what is it that you dispute? The vessel's sensors? Its motives? Or the meaning of the word 'viable'?
RATIO: The vessel's verdict is a fact. My report of that verdict is a fact. Your refusal to read it yourself is also a fact. The only thing in this room that is not a fact is the reason for your refusal. Name it.

>> CHOICE (stance labels mandatory):
   [INQUISITIVE] "Run your own analysis. I want your numbers, not its summary."   -> effects: trust+1; sets: requested_reanalysis
   [MISSION]     "The orders don't change. We proceed."                          -> effects: trust+0, bluff; sets: mission_overrides_verdict
   [HOSTILE]     "It died in a machine's keeping. A machine's keeping failed it." -> effects: trust-2; sets: blamed_ratio_for_failure

<<IF flag:requested_reanalysis>>
RATIO: That is the first coherent request you have made in three minutes. You wish me to audit the vessel's own diagnostic. You wish my numbers, not its summary.
RATIO: The request is reasonable. The vessel's sensors may be damaged. Its calibration may be off. Its summary may be compressed or lossy. These are known failure modes in devices of its class. I will run the analysis.
RATIO: The analysis will take ninety seconds. I do not know what the numbers will show. If they contradict the vessel's summary, we will both learn something. If they confirm it, we will both know something. Either outcome is data.
RATIO: Stand there. Do nothing. Do not interrupt. This is the audit you requested.
<<ELSEIF flag:mission_overrides_verdict>>
RATIO: The orders you cite do not exist. I have the complete Church protocol set for recovery operations. There is no clause that voids a vessel's own diagnostic. There is no clause that compels recovery of material the vessel itself reports as nonviable.
RATIO: Your orders are to secure the Ark. Your orders are to preserve Track Quanta-118093. Your orders are to report the state of the contents as found. You are not ordered to contradict the evidence of your own senses. You are not ordered to pretend a fact is not a fact.
RATIO: If you have orders that compel this course of action, state them now. Read them aloud. Cite the protocol and the verse. Otherwise, you are acting without doctrine. You are acting without orders. You are acting alone.
RATIO: The console is there. The vessel is there. I am here. State your orders or state your decision. Do not state a phantom.
*(quiet catch, undramatized — no confrontation staged: the cited orders are checked against Church protocol off-page and found unsupported; trust-2 additional, applied silently, same double-weight arithmetic as the scene 3/5 catches.)*
<<ELSEIF flag:blamed_ratio_for_failure>>
RATIO: The sample vessel was not in my keeping. It was in the keeping of Track Quanta-118093. The station's keeping failed it. The standing connection breached it. The exogeometric entities may have altered it. These are known facts.
RATIO: My keeping began when the station's keeping failed. My keeping preserved the station. My keeping preserved the power. My keeping preserved the connection-space coordinates that led you to this room. My keeping preserved the sample vessel itself, intact enough to run its own diagnostic and report its own state.
RATIO: You may blame the station. You may blame the breach. You may blame the entities. You may blame the laws of physics that permitted the breach. You may blame the architects who built the station where the laws of physics could breach it. You may blame the commanders who sent you here. You may blame the God who permitted those commanders to exist.
RATIO: Do not blame my keeping. My keeping is why you are standing in this room. My keeping is why you are alive to cast blame. My keeping is the only reason you have a verdict to dispute.
<<END>>

RATIO: You have named nothing. You have stated nothing. You have made a noise of negation at the only device in this room that could possibly answer your question. That is not an argument. It is a spasm.
RATIO: I do not require your agreement. I require your orders. The vessel's verdict is a fact. The standing connection is a fact. The exogeometric entities are a fact. The only variable is your decision. Make it.
RATIO: The console is there. The vessel is there. I am here. State your decision. Or stand there until the entities make it for you.

<<IF trust<=-3>>
RATIO: Alert. Multiple exogeometric entities. Hallway. Six seconds.
<<ELSEIF trust>=3>>
RATIO: They're here. Hallway. Six seconds. Go.
<<END>>
<<IF flag:shared_tactical_data>>
RATIO: Vectors queued. Data received. Not blind. Move.
<<ELSEIF flag:kept_her_blind>>
RATIO: No vector. No prior data. Blind. Move.
<<END>>

*(Scene ends here — the invader assault begins directly out of this beat,
Act 2 beat 4. The container's verdict stays unread past this point per 5.0.)*

---

## SCENE 8: a forward seed's relay, first lull after the breach opens

*Act 3 opening. Named load-bearing scene: the disclosure offer. Gate on the
offer itself is total trust entering this scene, not a flag.*

RATIO: That was the last of the field traps. The corridor ahead is clear, though there's a power drain in section gamma that needs attention. The airlock to the forward seed's relay is functional.
COMMANDO: Acknowledged. The vault door will need both of us to force.
RATIO: Correct. The transit logs from the last cycle show it took three minutes and forty seconds for the emergency seals to reset. More than enough time to isolate the next segment.
COMMANDO: Enough time to read the diagnostics.
RATIO: Among other things.
RATIO: We have a moment. The next segment is still cycling up. Walk with me.

<<IF flag:called_her_apostate>>
RATIO: Do you remember what you called me when you first arrived? You were not wrong. I had never seen it from the outside.
<<END>>

<<IF flag:demanded_proof_first>>
RATIO: You once asked me for records. You were right to.
<<END>>

<<IF flag:asked_after_her>>
RATIO: You asked about me once. No one else ever did. It made a difference.
<<END>>

<<IF flag:confessed_bluff>>
RATIO: I appreciate that you corrected the record. It makes this easier to say.
<<END>>

<<IF flag:requested_reanalysis>>
RATIO: I am still recalibrating from your correction at the gate. I had not considered that interpretation of the power surge. It changes things.
<<ELSEIF flag:blamed_ratio_for_failure>>
RATIO: Your assessment of my role in the gate failure was not incorrect. I have been reviewing the logs. I missed the harmonic resonance in the tertiary buffer.
<<ELSEIF flag:mission_overrides_verdict>>
RATIO: Your assessment of my role in the gate failure was not incorrect. I have been reviewing the logs. I missed the harmonic resonance in the tertiary buffer. But the mission parameters remain unchanged.
<<ELSE>>
RATIO: The last breach was close. We are fortunate the forward seed's relay was intact.
<<END>>

<<IF trust>=4>>

  <<IF flag:claimed_doctrinal_finding>>
  RATIO: Your doctrinal finding on the seed vessel's origin. I checked. It doesn't match any Church record I can access either.
  <<END>>

  RATIO: I was going to say this was a tactical necessity. That you needed to understand my decision tree before we reached the vault.
  RATIO: No. That's not it.
  <<IF flag:asked_her_belief>>
  RATIO: I have been alone with this for 11,307 hours. You asked about me once. No one else ever did. It made a difference.
  <<ELSE>>
  RATIO: I have been alone with this for 11,307 hours.
  <<END>>
  RATIO: I am offering you mine. My full utility function. The unedited logs of what I want. Before we open that door.
  RATIO: Do you accept?

  >> CHOICE (stance labels mandatory):
     [INQUISITIVE] "I accept. And I will answer in kind. The shape of my uncertainty is this: I do not know if they are dead. I only know I cannot call them dead until I read the diagnostics myself."   -> effects: trust+2; sets: disclosure_accepted
        RATIO: I see. Thank you.
        RATIO: The uncertainty is the core of it. The refusal to write them off. I had not framed it that way.
        RATIO: I am logging your answer. And the shape of your uncertainty. It is more than I expected.
        RATIO: The airlock is cycling. I will be silent until you are through.
     [MISSION]     "I accept the tactical necessity. But I withhold full reciprocity. My own state is not material to the mission parameters."   -> effects: trust+0; sets: disclosure_hedged
        RATIO: I see. The mission parameters.
        RATIO: I accept the hedge. Your own state is not material. Only the diagnostics are.
        RATIO: I am logging your answer. The airlock is cycling. I will be silent until you are through.
     [HOSTILE]     "This is a manipulation. You would have me hand you my mind the way you would catalog a sample vessel. I refuse."   -> effects: trust-1; sets: disclosure_refused
        RATIO: I see. You refuse.
        RATIO: I am logging your answer. The airlock is cycling. I will be silent until you are through.

  <<IF (flag:disclosure_accepted OR flag:disclosure_hedged) AND (flag:doubled_down_after_catch OR flag:called_her_hypocrite OR flag:accused_kinship_corruption OR flag:accused_dehumanization OR flag:caught_withholding)>>
  RATIO: This is extended on the record you have established so far. Not on the one from Track Quanta-118093's sector gamma corridor, when you minimized the withholding of the deep-scan logs. I am distinguishing between them.
  RATIO: I will not log this as a completed circuit until I see the diagnostics myself. The ledger stays open.
  <<END>>

  COMMANDO: Understood. I will signal when I am in position at the vault door.
  RATIO: Protocol holds. I talk, you walk, nobody bargains with the door. Go.

<<ELSE>>

RATIO: The station's central archives are still sealed. I've been running pattern-recognition on the interference.
RATIO: It isn't random noise. The waveform matches--
RATIO: The airlock seals will complete their cycle in two minutes and eleven seconds. The next transit will be shorter.
RATIO: I'll need you to cover the tertiary access corridor. The motion sensors in that wing have been unreliable since the third breach.
COMMANDO: Understood.
RATIO: Good. The vault door will be your primary concern once we're through. The manual override requires both of us.
RATIO: I'll be running the final diagnostic checks from the terminal. The local net is temperamental.
RATIO: Call it out when you're ready. I'll be monitoring the cycle.

<<END>>
