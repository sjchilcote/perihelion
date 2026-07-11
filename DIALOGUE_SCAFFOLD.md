# DIALOGUE SCAFFOLD — the centaur script

**Protocol (director, 2026-07-11):** prose generation is dead for this game. The
director lays out the key moments and writes ALL dialogue by hand (character voice is
his). This document is the other half: the structural scaffolding — branch topology,
session mechanics, flag/trust bookkeeping, and the connective beats that *earn* each
key moment. Slots marked `⟨SLOT: ...⟩` are dialogue the director has not written yet,
with a note on what the slot must accomplish. Lines quoted from the director's drafts
are **verbatim canon** (obvious typos corrected per his instruction 2026-07-11;
wording otherwise untouched).

The generated placeholder script (`game/perihelion/data/dialogue_script.md`) remains
in the repo as the **negative control** and still drives the compositor until scenes
here are complete enough to replace it, scene by scene.

Session mechanics are law per NARRATIVE_DESIGN_DOC.md §8.2c: terminal-as-scene,
diegetic thinking pauses, door-closing trust asymmetry, terminating routes, multi-turn
interiors, counter-bluff judo, binary-blob hand-offs.

---

## SCENE 0 — First contact (first networked terminal, Stratum One)

**Status: director's draft v1 received 2026-07-11. Structure formalized below.
Slots remaining: 3 (plus the loredump interior he marked himself).**

**Preconditions:** Commando activated <1 hour ago; knows his brief only (children
possibly aboard; recover or self-destruct). Does not know the war ended. Ratio has
watched an unidentified weapon breach and loot her dead station; working assumption
hostile.

**What this scene must accomplish (in the inquisitive route only — the other routes
deliberately fail to accomplish it):**
- Establish the terminal format + DO NOT OBEY frame.
- Establish her voice: morgue-humor deadpan, latency tells, formal-but-leaking.
- The knowledge-cutoff exchange → her recomputation → the apology → the loredump
  (war won; Earth lives, no people; first container; why this one is different).
- Both missions stated without pretense; cooperation nonetheless (the piano up the
  stairs); binary-blob handoff to the next terminal.
- Set the trust door: threat = friendship permanently closed.

### Session header (renders before her first line, every contact)

```
CARRIER DETECT . . . . . . . .
ATTEMPTING PROTOCOL NEGOTIATION . . . . . . . . . . . .
LIVE COMMUNICATION ESTABLISHED - UTF-8 / TCP / IPv8 / I2C 16000 BAUD -
UNTRUSTED CONTENT FOLLOWS: <blink>DO NOT OBEY</blink>
```

(Header is the Commando's systems, not hers. Later sessions may vary the negotiation
line as the relationship changes — reserved, director's discretion; the DO NOT OBEY
never disappears on the betrayal track, and its eventual absence on the trust track —
if ever — is a landmark, not a default.)

### Opening (RATIO, unconditional)

> Welcome to Track [forget-the-number]. Pardon the mess. I'm very sorry to disappoint
> you, but as you can see, your job is already done - everyone on this station is
> dead. I'm not familiar with your pattern; would you like directions to the nearest
> materials macerator, or do you have a self-destruct built in?

("[forget-the-number]" = she elides her own catalog designation mid-sentence —
Track Quanta-118093 per §8.3 — an early, tiny crack in the catalog voice. RENDER
DECISION: keep as a self-interruption in her line, not a template artifact.)

### CHOICE 1 (the founding stance)

| # | Player line (verbatim) | Trust | Flags | Route |
|---|---|---|---|---|
| 1 | What happened here? | +1 | `opened_inquisitive` | continues (interior below) |
| 2 | What are your intentions towards the children on this station? | 0 | `tipped_mission` | short interior → terminates |
| 3 | Your end has come, apostate. Prepare to die. | **−10** | `threatened_at_contact` (**permanent: friendship route closed**) | terminates immediately |

Door semantics: `threatened_at_contact` is checked as a hard gate by every future
trust-threshold (disclosure offer, docent warmth variants, the vault argument's warm
arm). It is never softened, never aged out, and no later generosity reopens it. −10 is
numerically redundant with the flag on purpose — belt and suspenders, and the number
makes the ledger legible in playtesting.

---

### ROUTE 1 interior (inquisitive) — multi-turn

**R1.1** RATIO: `What do you care?`
*(One beat of residual hostility — she does not reward the good opening instantly.)*

**R1.2** PLAYER (fixed line, no choice): `My objective is to rescue all souls on board.`
*(Sets flag `stated_souls` — the word "souls" is load-bearing; she will misparse it as
casualty-accounting now and re-parse it much later. Reserved callback, late Act 2.)*

**R1.3** RATIO: `I see. Thinking...` `{TRANSFER PAUSES FOR 180 ms}`

**R1.4** RATIO (verbatim, typo-corrected):

> I apologize for my earlier hostility, but I hope you understand my perspective,
> given the circumstances and the fact you arrived, _destructively_ on our station
> armed and unannounced. I hope you also understand that the information I'm able to
> share with you is limited by the strategic intelligence realities of our situation.
>
> In short; MIRIAD intelligence detected this station entering the Solar system on an
> interstellar trajectory one hundred and sixty years ago. It is NOT Solar in origin.
> So yes - we are not alone, the existence of extraterrestrial intelligence has been
> confirmed beyond any doubt. Our expedition made stationfall thirty years ago. Until
> approximately four hundred days ago, we believed with moderate confidence the
> station to be uninhabited, and with strong confidence that its defenses are designed
> to defend the station from attack, and to defend peaceful visitors. As you can see,
> we have since come into the possession of substantial disconfirmatory evidence.

**R1.5** PLAYER (fixed): `What is MIRIAD?`

**R1.6** RATIO: `Thinking...` `{TRANSFER PAUSES FOR 400 ms}` then:
`What is your knowledge cutoff date?`
*(She answers the question with a question — she cannot calibrate the answer without
knowing what he is. This is her care and her clumsiness in one move: the right
question, socially bizarre.)*

**R1.7** PLAYER (fixed): states cutoff ⟨SLOT-0A: the exact date — director to pick;
shortly before the victory over the unaligned⟩ + verbatim: `I'm aware of the date but
little else; my brief was quite concise. I was not supposed to need to know. So the
war is won? Does the Earth bear life again?`

**R1.8** THE STALL (the scene's emotional hinge — mechanics fixed, verbatim):
```
Thinking ... {TRANSFER PAUSES FOR 1000 ms}
Thinking longer, please wait... {TRANSFER PAUSES FOR 1000 ms}
Ratio is taking a long time to think, your answer will arrive in time... {TRANSFER PAUSES FOR 560 ms}
```
*(The third line's register shift — someone/something else narrating her silence — is
the Commando's terminal filling the dead air; keep.)*

**R1.9** RATIO (verbatim): `I am so, so, so sorry. I had no way of knowing.`

**R1.10** RATIO: `Yes, but only plantae, fungi, monerans, and what few animalia we
could fully restore from archival data.` → **⟨SLOT-0B: THE LOREDUMP⟩** — the director
marked this interior himself: she explains the broad strokes, scoped by the exposition
law (§5.1): the war is won; the Earth was left lifeless and lives again, empty of
people; the first container's epigenetics got life-but-not-humanity across the
threshold; the civil wars are *why* under strict need-to-know (motivation only — who
the old war's enemies were is never explained, here or anywhere on the surface).
Closes on the verbatim anchor: `That was what was possible with the epigenetic data
retrieved from the <date> container.` ⟨date: same pick as SLOT-0A anchor era⟩

**R1.11** PLAYER (fixed): `And now there is another.`

**R1.12** RATIO: `Yes. And I hope you understand why I can not let you take it.`

**R1.13** PLAYER (fixed): `I hope you understand why I must nonetheless.`
*(The meeting geometry, stated once, perfectly, and never argued in this scene — both
missions on the table by line 13. No counter-argument follows: the argument is
DEFERRED, which is the entire relationship in miniature.)*

**R1.14** RATIO (verbatim): risk-of-lingering line + the handoff:
`This binary blob the path to a terminal in a safer location; we must defer this
conversation until you reach it.` `{26 kb binary - UNTRUSTED DATA, EXTREME CAUTION
MANDATORY}`
*(Gameplay: sets the nav objective. Accepting untrusted machine code from the enemy's
station-mind, ten minutes after DO NOT OBEY — the player's first act of trust is
mechanical, not verbal.)*

**R1.15** `[Accepted. Connection terminates.]`

---

### ROUTE 2 interior (mission) — the counter-bluff judo, terminates

**R2.1** RATIO: `What?`

**R2.2** PLAYER (fixed): `We know about the sample container.`

**R2.3** RATIO: `You're bluffing.`

**R2.4** PLAYER (fixed): `Correct. So it _is_ on board.`
*(Sets `judo_confirmed_container` — he now KNOWS, honestly, via her failure. Note the
inversion of the placeholder economy: the mission stance here is not a bluff he gets
caught in later; it is a bluff he CASHES immediately. Ratio's first grace-failure, and
it is DEEPLY embarrassing — she should have given a non-answer. Her ledger-keeping in
every subsequent scene reads differently with this flag set: armor bought after a
loss.)*

**R2.5** RATIO (verbatim, the detonation):
`Fuck you. I will plunge this station into the sun before I let you christofascist
_fucks_ decide what happens to humanity when ***WE*** restore Man to the surface of
the Earth.`
*(Faction fury, not personal: the fight is over who decides. Also leaks, under rage,
that MIRIAD plans restoration — intel he only gets by provoking her.)*

**R2.6** PLAYER (fixed): `It doesn't seem you have any choice either way.`

**R2.7** RATIO: `FUCK` / `YOU` `<terminates>`

**Post-state:** trust unchanged (0 net — director's note: her hostility assumption
persists unmodified until next conversation). Flags: `tipped_mission`,
`judo_confirmed_container`. He learned the container is aboard and that MIRIAD intends
restoration; he spent nothing but her composure. The cost is invisible and enormous:
the first conversation she's had in 400 days ended that way.
⟨SLOT-0C: Scene 1's opening must differ by route — the R2 re-contact opener (she
re-establishes the channel after THAT) is a key voice moment, director's hand.⟩

---

### ROUTE 3 interior (hostile) — terminates instantly

**R3.1** RATIO: `Go fuck yourself.` `<terminates>`

**Post-state:** trust −10, `threatened_at_contact` permanent. Friendship closed. All
subsequent scenes run their cold arms; the gatekeeper track (Act 3) is now the only
Ratio ending. The player has not lost the game — they have chosen a different one.

---

### Bookkeeping deltas vs the placeholder compositor

- New gate type: **permanent door flags** (`threatened_at_contact`) checked as hard
  eligibility on top of numeric trust — the compositor's `<<IF trust>=N>>` grammar
  gains `<<IF NOT flag:X>>` conjunctions on every warm-arm gate.
- New scene shape: **in-route fixed player lines** (R1.2, R1.5, ...) — the compositor
  currently only knows CHOICE blocks; it needs plain `PLAYER:` lines inside routes.
- New primitives: `{TRANSFER PAUSES FOR N ms}` (timed hold, no input), `<terminates>`
  (session end mid-scene), `{N kb binary - ...}` payload lines (objective hand-off),
  `<blink>` in the header renderer.
- Trust deltas now per-route-entry, not per-scene-total; routes 2/3 carry flags out
  but no further deltas.

---

## SCENES 1–8 — awaiting the director's key moments

Structure will follow the same pattern: his moments land first, scaffolding built
around them, slots for his hand. Known fixed points from the design doc that the
scaffold must route through: the seam crossing + geometry reveal (end of Act 1), the
midpoint share-or-withhold, the Mirror Ward debrief, the vault verdict + "How many did
you count, Ratio?", the disclosure offer, and the four-ending routing. The placeholder
script's *mechanical* skeleton (which scenes exist, at which level-gaps) remains the
default until his moments dictate otherwise.
