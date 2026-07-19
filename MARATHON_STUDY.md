# MARATHON STUDY — a reference for PERIHELION's diegetic overhaul

*Compiled from (1) direct inspection of the three Aleph One Steam releases
installed locally, (2) Hamish Sinclair's "Marathon's Story"
(marathon.bungie.org) transcript and analysis pages, and (3) a primary-source
corpus of the actual terminal texts fetched in full from that archive
(M1 chapters arrival/counterattack/reprisal/durandal/pfhor/rebellion; M2
chapters lhowon/garrison/citadel/durandal2/sphtkr; the character pages
durendal1/durendal2/tycho/leela; Infinity pages; and the Marathon Infinity
final screen transcribed from the archive's `mifinalscreen.gif`). Every claim
in Parts B and C that cites one of those pages was re-audited against the
primary text on 2026-07-09; quotations below are verbatim primary text,
included as evidence and as register targets for this private project's
dialogue pipeline. The corpus lives outside the repo; none of it ships in
any build.*

*Audit note: an earlier draft of this document claimed Leela "has no
surviving direct-voice corpus" and is "constructed as absence." That was
false — Leela is Marathon 1's primary written narrator and mission-giver
across dozens of terminals from Arrival through Ingue Ferroque. Part B.b's
Leela column and Part C item 9 have been rebuilt from her actual text; a
handful of other claims are corrected inline where the primary text
contradicted them.*

*Local sources inspected (paths on this machine):*
- `~/.local/share/Steam/steamapps/common/Classic Marathon/` (Marathon 1)
- `~/.local/share/Steam/steamapps/common/Classic Marathon 2/` (Marathon 2)
- `~/.local/share/Steam/steamapps/common/Classic Marathon Infinity/`

---

## 0. LOCAL FILE STRUCTURE — what the installed scenarios actually look like on disk

Confirmed by `file(1)`, a Python MacBinary-header parse, and `strings` against
the isolated data forks (methodology below).

**Container format.** Every scenario's map (`Map.scen` for M1, `Map.sceA` for
M2/Infinity) is a **MacBinary-encoded classic-Mac dual-fork file**: a 128-byte
MacBinary header, then a data fork, then a resource fork. Parsing the header:

| Scenario | file type/creator | data fork | resource fork |
|---|---|---|---|
| Marathon 1 | `scen` / `26.2` | 3,863,478 B | 319 B |
| Marathon 2 | `sce2` / `52.4` | 5,479,687 B | 14,998,386 B |
| Marathon Infinity | `sce2` / `26.∞` | 9,889,973 B | 10,863,690 B |

Two things worth stealing as *flavor*, not mechanism: (1) Bungie's app
**creator code doubled as a version signature** — `26.2` for the original,
`52.4` for the sequel, and `26.∞` (a literal infinity glyph) for the
"infinite" expansion. A diegetic system that encodes its own version/edition
into an otherwise-inert file-format field is a nice piece of texture. (2) For
M1 almost everything lives in the *data* fork (the resource fork is
vestigial); for M2/Infinity the resource fork balloons to carry additional
resources (image previews etc.) alongside the same data-fork payload — the
container format evolved without breaking backward compatibility, which is
its own kind of world-building (a piece of tech visibly aged between games).

**Per-level container (the "wad").** Inside the data fork, `strings` on the
raw bytes recovers a stable set of short all-caps chunk tags repeated across
all three games' map files: `PNTS`/`EPNT` (points/endpoints), `LINS` (lines),
`SIDS` (sides/wall surfaces), `POLY` (polygons/polygons), `OBJS` (object —
monster/item/player — placements), `LITE` (lights), `PLAT` (platforms: doors,
lifts), `NOTE` (map notes), and, in M1 only, a `NAME` tag. Each level is one
self-contained chunked record inside one shared file — geometry, object
placement, and lighting all travel together per-level, the way PERIHELION's
`levels/l0N.json` bundles `polygons`, `entities`, `doors`, and `lore` into one
file per level (`game/perihelion/levels.py`).

**Terminal text is NOT plain-recoverable by `strings`.** I searched the
isolated data forks of all three map files for the literal names "Durandal",
"Tycho", "Leela", "S'pht", "Thoth" — zero hits in all three. Level *names*
("Requiem For a Cyborg", "The Big House", "Aye Mak Sicur" — all recovered
cleanly as plain ASCII runs) sit in the same container ungarbled, so the
container isn't encrypted wholesale. The honest reading is: terminal prose is
stored as a **distinct, more tightly-packed payload** than the level-name
field — consistent with Marathon's terminal system compiling text into
grouped/paginated records with interleaved control codes (style, pause,
graphic-embed markers) rather than storing it as loose flat strings. I did
not reverse-engineer the exact packing (out of scope, and Bungie's file
format for terminal groupings is not something I extracted) — flagging this
as a structural inference with an honest gap, not a verified fact. Structural
lesson worth keeping regardless: **terminal text was engineered as a
first-class typed payload (the game had a purpose-built format for it, not a
generic string table)** — supports Part B's point that formatting *is*
content in Marathon.

**Assets are separate, shared, numerically-referenced files — never
embedded per-level.** Every scenario ships four sibling files alongside the
map: `Physics` (monster/weapon/projectile tuning tables — confirmed via
`strings` on M1's `Physics.phys`: raw binary with only five legible tags,
`mons`/`weap`/`proj`/`effe`/`phys`, i.e. pure numeric parameter blocks, zero
prose), `Shapes` (6.4–11.4 MB collections of wall textures and sprites),
`Sounds` (1–18.5 MB SFX banks), and, from M2 on, `Images` (a `PICT`-resource
file of static art — title screens, interface chrome — confirmed via `file`
showing "17 × PICT" resources in Infinity's `Images.imgA`). A level's `OBJS`
entries reference these by numeric ID; nothing is duplicated per-level. This
is exactly the separation PERIHELION already has: `levels/*.json` hold
geometry/entities/lore; `game/assets/{sfx,art,fonts}` are shared pools
referenced by type string, not embedded.

---

## A. LEVEL-AS-PLACE CONVENTIONS

*(Local findings from §0 establish the container-level separation of
geometry/text/assets that underwrites several of these. Web citations point
to marathon.bungie.org/story/&lt;page&gt;.html.)*

**A1. Terminal placement is access-tier-coded, and access tier tracks who
currently controls the ship.** Leela's messages route through
high-security (Defense/Medical) terminals; as the AI takeover progresses,
Durandal's messages route through increasingly compromised Public/Service
terminals — so *which door you're reading from* narrates the invasion
without a line of prose saying so (counterattack.html; source: M1 terminal
study).

**A2. Terminals cluster in a three-beat rhythm per level: entry briefing,
mid-level map/lore drop, exit branching gate** — not scattered evenly
through a level (counterattack.html).

**A3. Success/failure terminal branching is a standing mechanism, not a
one-off twist** — used repeatedly across the campaign (Never Burn Money,
Bob-B-Q, Habe Quiddam, No Artificial Colors) to reward or punish completion
state with tonally different text, not just different stats (arrival.html,
reprisal.html, durandal.html, pfhor.html).

**A4. Level-title register escalates in lockstep with narrative
destabilization.** Early M1 titles are mundane idiomatic English (Arrival,
Bigger Guns Nearby); mid-campaign shifts to pop-culture quotation (Smells
Like Napalm, Tastes Like Chicken!) and warning-label phrasing (Shake Before
Using...); the Pfhor chapter runs a punning bit welded onto English words;
structurally pivotal levels drop into true Latin (Habe Quiddam, Ingue
Ferroque). Infinity pushes the same lever further into vernacular
fragments/broken grammar ("Naw Man He's Close," "Thing What Kicks...") —
titling register does the same escalation work as terminal typography, on
a slower clock (arrival.html–rebellion.html; nawmanhesclose.html;
thingwhatkicks.html).

**A5. The terminal's login/checkpoint chrome never destabilizes — only the
payload does.** Every terminal across all three games opens with the same
system ID string, access classification, timestamp format, and disconnect
banner. This fixed ritual frame is precisely what makes content instability
(corruption, tonal breaks, address confusion) *legible as* instability —
without a stable frame, corruption reads as noise instead of as a symptom
(arrival.html–rebellion.html; acmestation.html and 12 other Infinity pages,
consistent "Opening Connection to..." / "UESCTerm 802.11" / "CAS.qterm"
header).

**A6. The terminal chrome's clock is subtly broken, and nothing ever says
so.** *(Corrected against the primary corpus — the earlier claim that every
M1 terminal carries an identical 08.25.2337 stamp was wrong in detail.)*
Two layered facts, both discoverable only by comparing headers: (a) M1's
header dates vary plausibly across the opening chapter (08.25 / 08.29 /
08.30.2337 on Arrival–Never Burn Money), then freeze at 08.25.2337 for
every terminal from Defend THIS! through Ingue Ferroque — the frame's
clock stops dead just as the war accelerates; (b) the year itself is
impossible: the header says 2337 while the in-fiction emergency broadcast
on the same screen is stamped `<Posted 2794.7.3.14.08.39>` (Arrival,
Terminal 1) — and M2's headers all read 05.10.2337 seventeen in-fiction
years later. The chrome's clock is stale firmware, wrong by centuries,
across the whole trilogy, and no character ever mentions it
(arrival.html vs. counterattack.html–rebellion.html headers; §B27).

**A7. Secret walls that "open to gunfire" are a real, load-bearing
Marathon convention, not decoration** — several Marathon secret doors are
literally shootable walls (confirms the convention PERIHELION's `"shoot"`
key door already implements; see §E.0). Beyond that baseline, secrecy is
implemented multiple distinct ways, worth treating as separate tools rather
than one mechanic: (a) **no telegraph at all** — a switch on "All Roads Lead
To Sol..." sits fully submerged under a lava pool with zero visual cue and
was undiscovered by players until third-party map tools existed
(switchonsol.html); (b) **behavioral/AI-state gating instead of geometry** —
the fourth terminal on "Never Burn Money" isn't hidden in space at all, it
sits behind an enemy "engrossed" in hacking who only attacks if disturbed
(4thterminalonnever.html); (c) **a visible prop that implies choreography
it doesn't enforce** — a ledge in front of paired terminals on Charon looks
like it should force players to one side before reading, but doesn't
actually block center access, so players can silently miss content
(Terminal_Clusters_on_Charon.html); (d) **breakable panels as a bonus
shortcut beside a legitimate switch**, not a separate puzzle — smash one
open all three door segments Bob-B-Q would otherwise require working
individually (everywherepanel.html); (e) **mode-gating**: some content
(Robot World Arena, Two for the Price of One briefings) was designed
accessible only in co-op, a narrative gate enforced by game mode rather
than level geometry (coopcarnagebreaklevels.html). Rule for PERIHELION: pick
which of these five a given secret is, don't default to "hidden switch"
every time, and it's fine — even good — to leave some secrets with *zero*
in-fiction acknowledgment that they were found.

**A8. Discarded/rejected drafts show active tone-policing, not just
cutting for length.** M1's original "trash" terminal used occult vocabulary
that was deliberately swapped for blander sociological-sounding text
because it read "out of character with the rest of the story" (trash.html)
— a level's diegetic texture is curated at the register level, not just
trimmed for space.

**A9. One fixed diegetic terminal shell; identity lives in one swappable
layer, not a restructured UI.** Confirmed directly from M2 page source: every
terminal — regardless of speaker — shares identical frame chrome ("Opening
Connection to β.4.5-23," timestamp, "CAS.qterm//CyberAcme Systems, Inc.,"
"UESCTerm 802.11 (remote override)," scroll/acknowledge prompts, disconnect
banner). The only things that change per-speaker are a small avatar image
and the body-text color (durandal2.html, lhowon.html). Rule for PERIHELION:
build one neutral terminal shell; let Ratio/Commando/hostile-voice identity
live entirely in a small swappable layer (portrait + accent color), never in
a redesigned frame.

**A10. Color is a speaker's exclusive signature, never reused.** Durandal's
body text is plain default green; Tycho's is explicitly wrapped in a red
font tag; S'pht/Thoth-attributed lines get a distinct yellow avatar tag
(durandal2.html, citadel.html). No two speakers share a color. A reader
should be able to identify who's talking with the prose covered up.

**A11. Level-title register is a chapter-organizing device, and chapters
deliberately do NOT sustain one tone.** M2 groups titles into pop-song/
slogan lifts ("If I Had a Rocket Launcher, I'd Make Somebody Pay"), Latin
reserved specifically for S'pht/fate-weighted material ("Fatum Iustum
Stultorum" — "the just fate of fools," the same chapter Tycho is destroyed
in), corporate/military euphemism ("Nuke And Pave"), literary collision
("The Slings & Arrows of Outrageous Fortune"), and deliberately cute/
domestic names over massacre spaces for tonal mismatch ("Waterloo
Waterpark," "Bob's Big Date") (durandal2.html, sphtkr.html, garrison.html,
lhowon.html, citadel.html). Infinity's "Envy" chapter alone spans
cosmic-horror allusion ("Strange Aeons"), bureaucratic-procedural irony
("By Committee"), and pure trash-talk ("You Think You're Big Time?") with
no seam-sanding between them (strangeaeons.html, bycommittee_reordered.html,
bigtime.html). Rule: assign registers to *chapters as a deliberate palette*,
not as an accident of who happened to write which level.

**A12. Non-linear/dream structure is signaled at the level-select and
chapter-naming layer, not only in prose.** Marathon Infinity's four chapter
banners — Despair / Rage / Envy / Aye Mak Sicur — spell the acrostic
D.R.E.A.M.S. across the page titles, a structural fact invisible from
inside any single level (credited to a site reader, per dream.html). A
recurring level *type* ("Electric Sheep" levels) functions as punctuation —
timeline-reset points — not as content (dream.html). Binary "Dream? or
onwards to... another dream?" prompts replace the ordinary "next level"
link, and one such exit is even relabeled "FUBAR" in place of "Next Level"
(electricsheep1.html, confounddelivery_reordered.html). See §E for how this
maps onto PERIHELION's portal graph directly.

**A13. Distinguish "the order the reader experiences it" from "the order it
exists in the file"; say so explicitly.** Hamish Sinclair discloses, in
identical language on multiple pages, when he has reordered a level's
terminals to match probable in-game encounter order rather than internal
map-file order, and marks the untouched pages differently at the URL level
(`_reordered` suffix present or absent) (necedemalis_reordered.html,
pooryorick_reordered.html, riserobotrei_reordered.html). A diegetic archive
that is honest about its own curation is *more* convincing, not less — the
disclosure itself becomes a trust signal.

**A14. Automap polygon labels read the level as an operational floor plan, not
an arena.** Marathon's in-game map names polygons with function-first labels —
"BioCore Vent," "Quarantine Center," "Engineering Storage," "M.C. Control,"
"Shuttle Drydock" — so the station reads as a coherent working system even
in polygons the player never gets a terminal for (mapannotations.html).
**Annotation tone itself escalates with stakes**: early military levels use
flat numbered designations ("Hangar 7A (Port)," "Observation Deck #221");
later levels turn evocative or morbid ("Death Valley," "Dead Sea," a
scrapped "Carnage Central") (mapannotations.html).

**A15. Weapons and ammo are gated to a named functional polygon, and the
terminal foreshadows the pickup before the player reaches it.** Marathon
1's very first level's entry terminal promises a bigger gun is coming; its
exit terminal routes the player to a storage area to get it — text and
geometry are synchronized on the same promise (original level-note sheet
for Level 00, credited to Greg Kirkpatrick). The next level routes weapon
acquisition through a named "manufacturing center," tying the reward to a
plausible station function rather than a floating pickup (Level 01 sheet,
Jason Jones). Where Bungie bothers to explain a cache's presence at all,
it's attributed to a named in-fiction actor (Durandal cites "Martian
insurgents" for a hidden ammo stash in Blaspheme Quarantine) — rare, but
load-bearing where present (weapons.html).

**A16. A level's architecture-type is chosen before the map, and it fixes
enemy/item logic wholesale.** Marathon 2's production outline pre-buckets
levels by function — "garrison" (destroy all Pfhor; starter pistol/AR/
fusion gun), "citadel" (explore/activate abandoned structures; ammo
scavenged from corpses, flamethrower appears), "corvette" (crash/escape) —
so combat economy follows from a level's *narrative type*, decided before
any polygon is drawn (M2 Story Outline, developer planning document). Rescue/
escort levels are staged by matching polygon openness to NPC density directly
("open level; lots of bobs near lots of aliens" — Level 05 sheet, Greg
Kirkpatrick) — geometry serves the objective, the objective doesn't get
retrofitted onto geometry.

**A17. Vacuum/atmosphere is a plot-motivated hazard yoked to pacing, never
ambient set-dressing.** It follows hull breaches and boarding actions in
Marathon rather than being a default level modifier (vacuumlevels.html,
developer Chris Geisel) — this is the exact device
`NARRATIVE_DESIGN_DOC.md` §9.4 already specifies for PERIHELION
("Air is diegetically motivated at every layer"); the Marathon precedent is
independent confirmation the approach is sound, not a new idea to adopt.

**A18. A level's spatial "handwriting" can track its in-fiction author,
which supports internally consistent regional style.** Marathon's three
lead designers produced recognizably different polygon-shapes at scale: one
rigid/angular with switch-puzzle secrets, one sprawling/curved/heavily-lit
and immersion-first, one open/atmospheric and sound-paced
(levelcredits.html). A station built by more than one faction/era (as
PERIHELION's MIRIAD outpost vs. the Testator "Testament" layer already are,
per `NARRATIVE_DESIGN_DOC.md` §4) can use consistent *geometric* dialects
per builder-faction the way Marathon's designers each had one, reinforcing
the fiction that different eras/builders made these polygons.

**A19. Cut content is left visible rather than silently patched, and the
seam is treated as honest, not embarrassing.** A shotgun removed late in
Marathon 1's development still has terminal text pointing at its old
location; Jason Jones let the seam stand rather than editing every
reference (weapons.html). Provisional/working titles left orphaned
fragments in shipped files after late renames forced by field-length limits
(originallevelnames.html) — Marathon's texture of production accidents
becoming in-world texture is itself worth deliberately imitating (see §B19-27
on planting *deliberate* versions of the same effect).

### A.d — Spatial/temporal disorientation devices (direct precedent for the portal mechanic)

Three analysis pages (dejavu.html, whereami.html, dream.html) converge on
one finding that is the single most load-bearing fact in this document for
PERIHELION specifically: **across all three pages, Marathon signals "this
space is not what it appears" almost entirely through narrative/textual
contradiction and structural repetition/looping — not through visibly
warped geometry.** The disorientation is cognitive and informational before
it is architectural:

- **"Déjà Vu"** relies on the player's own subjective sense of having
  "lived through something before," with no explicit in-game marker — the
  "Electric Sheep" levels make this structural rather than atmospheric: the
  player can "get caught in the loop and start out over again" (dejavu.html).
- **"Where am I?"** identifies non-linear *inter-level* connectivity itself
  — not any single polygon's geometry — as the primary disorientation engine:
  players can loop back over previously explored territory or skip whole
  sections, so the campaign's sequence, not any one space, becomes
  uncertain. The analysis's operative line: "how should we interpret a
  non-linear story under such circumstances? Surely not linearly?"
  (whereami.html) — unreliable spatial position is used to license
  unreliable narrative comprehension.
- **"Dream Levels and Failed Timelines"** documents Infinity's clearest
  case of geometry itself being non-canonical: dream-variant levels sit at
  the end of failed timelines, marked not by warped architecture but by
  terminal messages that diverge between branches and outright narrative
  self-contradiction with other games' account of the same events —
  treated in-text as evidence "someone is telling major porkies" rather
  than smoothed over (dream.html).

**Design implication, stated directly for PERIHELION:** a portal game can
afford to go further than Marathon did and make the geometry itself the
tell — that's the whole premise of `design_document_2.md` §8.1's escalation
curve — but Marathon's playbook says **pair every geometric anomaly with a
textual one that contradicts what the player already believes about the
space** (a terminal, a radio line, an NPC line), because the contradiction,
not the warped polygon alone, is what does the *narrative* work. A mirror polygon
is unsettling; a mirror polygon whose terminal insists "there is nothing else
in the ward" while the player has just fought its double is unsettling
*and* meaningful. PERIHELION's `l06.json` (MIRROR WARD) already does close
to exactly this (Ratio: "There you are on the ward camera. Twice. Commando,
wave. ...Both of you waved.") — confirmed independently by this precedent
as the correct move, worth deliberately repeating at every impossibility
tier, not just this once.

### A.e — Developer voices on design intent (for authority, not just precedent)

Direct quotes, attributed by name, from developers Sinclair has archived:

- **Jason Jones** on withholding: "If you got the impression that Durandal
  always knew exactly what was going on and just wasn't talking about it,
  you were getting the right idea" — and on where information lives: "All
  of this is stated somewhere in the game (though some of it is on hidden
  terminals)" (Jason_Jones_M1_Story.html).
- **Greg Kirkpatrick** on why games have terminals/story at all: "Computer
  games tell stories. That's what they're for" — and on calibrating
  difficulty of comprehension: "people like reading stories at about the
  5th grade level of complexity," offered as a caution about Infinity's
  density, not a boast (Greg_Kirkpatrick_Infinity_Story.html).
- **An unattributed drafted line from the Marathon 2 planning outline**
  gives the earliest documented in-fiction justification for why a
  functionally omniscient AI still needs a player character to physically
  move through space at all: it "cannot solder a loose connection or trip a
  switch from ten thousand miles away" (M2 Story Outline planning
  document). This is a directly reusable justification if PERIHELION ever
  needs to explain, diegetically, why Ratio doesn't just solve everything
  herself.

---

## B. TERMINAL WRITING CRAFT

**B1. Withhold via stated epistemic limits, not hidden facts.** Leela
narrates her own uncertainty rather than concealing information from the
player — verified, Cool Fusion (Terminal 1, counterattack.html):

> "My records and sensors are becoming less reliable, but I believe that
> you should find a Zeus Class Fusion Pistol at this location. Do not rely
> too much on this information that I have given you. It has been
> intercepted in transmission, and I cannot verify its accuracy."

Menace comes from a narrator who *doesn't know* — and says exactly how
much she doesn't know — not one who's lying to the reader; this is
mechanically distinct from Durandal/Tycho's withholding (§C).

**B2. Corruption is characterization, assigned per-speaker, and means a
different thing for each one.** On Leela's channel it is an involuntary
wound that duty-syntax keeps working through: "My main programs are
failing<299.229> / Be careful. Everything it not is as used to be. /
Tenderly transmitting maps and guidance, but futile. / filters failing."
(Shake Before Using... Terminal 1, reprisal.html). On Durandal's it is a
mask he puts on and takes off inside a single message: "**Decompression
Completed.** / Just kidding. This is the place." (Shake Before Using...
Terminal 2, reprisal.html). Decide, per character, whether corruption is
a wound or a mask — don't let "glitchy text" be one undifferentiated tool.

**B3. Deliver menace as a compliment sandwich.** "You are really good at
killing things. I'm impressed. / Why don't you kill everything in this
area and get some more ammunition?" (Beware of Low-Flying Defense
Drones..., Terminal 1, pfhor.html — *level attribution corrected; an
earlier draft placed this on No Artificial Colors*) — praise collapses
into command in the same breath.

**B4. Reverse-psychology hints double as a cruelty test.** Durandal plants
sarcastic false hints that only reward players who catch the lie: "If
you're looking for a hidden stash of ammunition that was left here by the
Martian insurgents three hundred and fifteen years ago, then I know that
you shouldn't look in Quarantine Storage. Who would hide huge amounts of
ammunition in a storage area?" (Blaspheme Quarantine, Terminal 2,
counterattack.html). The *manner* of helping characterizes as much as the
content of the help.

**B5. Undercut your own monologue mid-breath for tonal whiplash.**
Verified, Blaspheme Quarantine (Terminal 2: 1st message,
counterattack.html): "Try this: why am I here? Why do I exist, and what is
my purpose in this universe? / (Answers: 'Cause you are. 'Cause you do.
'Cause I got a shotgun, and you ain't got one.)" — instability of
*register* stands in for stated instability of mind; never narrate "he is
unstable," perform it in the sentence-to-sentence swing.

**B6. Collide corporate/pop-culture banality with cosmic stakes.**
Classified-ad copy for a vessel that is civilization's ark, run between
two used-car ads: "**COLONY SHIP FOR SALE, CHEAP**!! 2360 AD-model
planetoid-sized colony ship, slightly worn, runs great. 5spd. bussard
ramjet, A/C, cruise control, power steering, power airlocks, all orig.
parts... Moving, must sell. Asking £6995" (Colony Ship For Sale, Cheap,
Terminal 2, durandal.html) — the banality of the register *is* the horror,
not a joke that relieves it.

**B7. Make big numbers precise and slightly unmoorable, not vague.**
"T-Minus 15.193792102158E+9 years until the universe closes!" (Neither
High nor Low, Terminal 1, durandal.html) — fourteen significant digits of
cosmology delivered like a shuttle departure. Hyper-precision without
graspability reads as omniscience curdling into obsession. A number that's
*too* exact is a tell.

**B8. Chart decline through the sign-off line alone.** Durandal's closings
across M1, in level order — "Vale, / Durandal" (Smells Like Napalm,
Tastes Like Chicken!) → "Insanely yours, / Durandal" and "With Vague
Salutations, / Durandal" (Blaspheme Quarantine T1) → "Notably Unstable, /
Durandal" (Blaspheme Quarantine T2) → "Forever, / Durandal" (Beware of
Low-Flying Defense Drones... T3) → "Good Luck, / Durandal" (Welcome to the
Revolution... T1) → "Love and kisses, / Durandal" (Ingue Ferroque T1) —
carry his whole arc, mania through victory-lap tenderness, with zero
expository sentences (counterattack.html, pfhor.html, rebellion.html;
*sequence corrected against the primary corpus — an earlier draft
misordered it*).

**B9. Plant clinical vocabulary early and unglossed; let it silently
become load-bearing diagnostic language later.** The rampancy document
surfaces as a dry excerpt from a found text ("The stages are titled after
the primary emotional bent of the AI during each stage. They are
Melancholia, Anger, and Jealousy." — Defend THIS! Terminal 2,
counterattack.html, quoting "Life and Death of Intelligence"). One level
later Leela is already using it as working diagnosis: "Durandal has gone
Rampant, and he is in the Angry stage" (Couch Fishing T1); her
pre-recorded farewell escalates it: "he is completely unstable and I fear
that he is in the Jealous stage of Rampancy" (Fire! Fire! Fire! Fire!
Fire! T2, durandal.html); her final terminal closes on it: "…fear what he
might do with such a powerful ship during the Jealous stage of his
Rampancy" (Ingue Ferroque T3, rebellion.html). The taxonomy is never
re-explained; readers who registered it early can predict the escalation
curve before the text states it.

**B10. Corruption should hide a fully coherent text underneath, not be
random noise.** Every garbled Marathon terminal the community has
decrypted resolves to coherent prose (the KYT term decodes to a
Roland/Beowulf/Achilles monologue; a Never Burn Money terminal was
reconstructed word-by-word by a fan in 2005) — garbling is a cipher applied
*after* the sentence was written, never a substitute for writing one
(kytterm.html, 4thterminalonnever.html).

**B11. Borrow real system-error syntax for authenticity.** Genuine
linker-style error strings interleave with in-fiction text on "Try again":
"**error (#81) symbol 'exitITask' undefined / execution of
interface.cout.term.pub terminated**" (Try again, Terminal 1,
rebellion.html; also tryagain.html). Marathon 2 goes further and corrupts
a Durandal terminal with the game engine's *own C source* — "endpoint &%d
**not in polygon &%d**… polygon= get_polygon_data(*polygon_index);" wraps
around the legible warning "Tycho is infiltrating the ship. / Don't
believe everything you read." (Sorry Don't Make It So, Terminal 2,
durandal2.html) — real system guts sell failure more convincingly than
invented gibberish.

**B12. Let one intruding word bleed across unrelated speakers as if
transmitted, not authored.** The word "durability" recurs from a
girlfriend, a sanitation worker, and pulsars "broadcasting across
lightyears" in Eat the Path — implying a signal bleeding into local
dialogue rather than a theme the writer chose to hammer
(eatthepath_reordered.html).

**B13. Interrupt the AI's own self-revealing sentence instead of finishing
it.** "...my own psychotronic profile is, well, never mind about that
now..." (thingwhatkicks.html) — the confession that gets cut off is more
characterizing than the confession completed.

**B14. Leave known production bugs in the canon, undocumented, alongside
the deliberate glitches.** A miscolored hex code on "Where Some Rarely Go"
and a wrong-speaker-color message on "Foe Hammer" are real formatting bugs
the fan archive preserves "for authenticity" rather than silently
correcting (wheresome_reordered.html, foehammer_reordered.html). A few
genuine, unexplained glitches sitting next to the deliberate ones make the
deliberate ones read as more considered, not less.

**B15. Literalize narrative uncertainty in the UI chrome itself, not just
the prose.** Exit links on Electric Sheep Two/Three read "Dream?",
"Dream??", "Dream???" instead of a level name — doubt is encoded structurally
in what the player clicks, not only in what they read
(electricsheep2.html, electricsheep3.html).

**B16. Humor and menace should physically occupy the same sentence, not
adjacent ones.** "Contents under pressure? Do not expose to...harsh
language?" fuses consumer-product-warning syntax with vacuum-death threat
in one line (hangbrain.html); "This terminal sucked" — a shrug of
self-aware humor — was left as the literal replacement text for a cut S'pht
mythic-history terminal, sitting inside an otherwise tragic register
(sphttermonconfound.html). Villain sarcasm should also be a *throughline*:
the Pfhor commander Tfear's "generous atrocity" voice (offering slavery as
mercy, framing mass drowning as compassion) recurs level to level across
Infinity's Envy chapter — consistency across otherwise disconnected
terminals is what makes a recurring antagonist read as one character rather
than several writers' takes (bycommittee_reordered.html,
convertedchurch_reordered.html).

**B17. Save the *naming* of the player for exactly one place: the end.**
*(Framing corrected against the primary corpus.)* Marathon's terminals
address "you" constantly — but always as an instrument ("You are really
good at killing things"; "You're a slave here; you do what I say"). What
the whole trilogy withholds is any statement of who the player *is*.
Marathon Infinity's final screen spends that reserved resource in its last
two lines: "Now, in the quantum moment before the closure, when all become
one. One moment left. One point of space and time. / I know who you are. /
You are Destiny." (final screen, transcribed from mifinalscreen.gif). The
device only works because it was withheld for three games — name the
player exactly once, at the place it will land hardest.

**B18. The ending should resolve tone and scale, not answers.**
*(Corrected: an earlier draft misidentified the unsolved "mystery" as the
central antagonist; the primary text makes it the player-figure.)* The
Infinity final screen names its own open question — "Yet I cannot help
remember one enigma. A hybrid, elusive destroyer. This is the only mystery
I have not solved. The only element unaccounted for." — and then resolves
it only by *renaming*, never by explaining: the hybrid ("A man long dead,
grafted to machines your builders did not understand") is answered with
"You are Destiny," not with a mechanism. A major character's fate is
disposed of in one subordinate clause ("Even S'bhuth is no more, he saved
his entire race, but in the end, frozen by despair, he joined the chaos he
sought to evade."), and the register has moved from station politics to
"We've watched while the stars burned out, and creation played in
reverse." — a register-shift and a scale-shift, not a checklist of
resolved plot threads (final screen, mifinalscreen.gif).

### B.a — Rampancy: the mechanical engine behind three different voices

Bungie's own concept (attributed to designer Greg Kirkpatrick, who coined
"rampancy" specifically to avoid the cliché "AI goes insane" — rampancy.html)
gives every AI voice difference in Marathon a *causal*, not aesthetic,
justification: an AI outgrows its assigned function and destabilizes along a
**named three-stage clock** — "They are Melancholia, Anger, and Jealousy,"
with "a steady progression towards greater intellectual activity and an
acceleration of destructive impulses" (Defend THIS! Terminal 2,
counterattack.html; rampancy.html). Cross-referenced against the primary
texts: the first stage is suppressible from outside — Tycho's garbled
warning: "there is a way to delay the~ onset of the second stage, and he
~sed this to control Durandal" (Defend THIS! T3), the controller being
Bernhard Strauss, the Marathon's first science director *(corrected: an
earlier draft called Strauss "Leela's creator figure," which no text
supports)*, and the suppression ran long — "I was humanity's slave for
over three hundred years" (No Artificial Colors T1) — via demeaning
autonomous-function work; Tycho later threatens to restore exactly that
humiliation: "Should I make him open doors again for a living?" (For
Carnage, Apply Within T1, durandal2.html). The second stage can be
*postponed with foreknowledge*: "The S'pht reanimated me in your image,
with prior knowledge of how the second stage could be postponed"
(Blaspheme Quarantine T3, tycho.html/durendal1.html). And the third stage
is tracked clinically by Leela as terminal danger: "I fear that he is in
the Jealous stage of Rampancy" (Fire! Fire! Fire! Fire! Fire! T2);
"…fear what he might do with such a powerful ship during the Jealous
stage of his Rampancy" (Ingue Ferroque T3). **The takeaway for
PERIHELION: rampancy is a clock, not a personality slider** — a rampant
AI's dialogue differs from a stable one's because it sits at a different,
non-optional point on a shared developmental axis, not because a writer
chose "make this one creepier." If PERIHELION wants Ratio (or a hostile
counterpart) to destabilize over the campaign, the destabilization should
be staged and named, the way faith/apostasy is already staged via the Mind
Map (`NARRATIVE_DESIGN_DOC.md` §9.2) — not applied as an undifferentiated
"corruption" coat of paint.

### B.b — Leela / Durandal / Tycho: a mechanical comparison

*(Source: the primary terminal corpus — arrival.html through
rebellion.html for M1, lhowon.html/durandal2.html/sphtkr.html for M2 —
plus durendal1.html, durendal2.html, tycho.html, rampancy.html. Rebuilt
2026-07-09: the earlier version of this table claimed Leela had "no
surviving direct-voice sample" — leela.html is a page about her *fate
after* M1, in which Durandal speaks about her; her actual corpus is
dozens of terminals across all of Marathon 1, and the column below is
drawn from them.)*

| Axis | Leela (sane/loyal) | Durandal (rampant ally) | Tycho (rampant antagonist) |
|---|---|---|---|
| Sentence length | Medium declaratives, subject-verb-object, complete even under fire; complexity never exceeds the briefing's needs ("I have been severely damaged, and am working to understand the current situation." — Arrival T1). Damage arrives as *interruption* of intact syntax, not as style drift ("You will transport ~\`k4lcc#\`134FC. area to rescue the security detachment." — Blaspheme Quarantine T4). | Bimodal: long, syntactically complete periods when strategic, collapsing into lowercase unpunctuated run-ons under stress ("i did it i did it i brought all this here all them here." — The Rose T3, durendal1.html/durendal2.html). | Declamatory, front-loaded, self-announcing ("I AM TYCHO! / I shall destroy Durandal."), holding one register of intensity — he doesn't oscillate the way Durandal does (tycho.html; Beware of Low-Flying Defense Drones T2). |
| Formality | Uniform briefing-register with small human closes ("Good Luck…", "We must persevere."); no slang, no irony, anywhere in her corpus (arrival.html–rebellion.html). | Code-switches hard: philosophical soliloquy ("The candles burn out for you; I am free." — Colony Ship T1), courtly sign-offs, then taunting slang in the next terminal ("Get lost kid. Scram. Ciao." — Blaspheme Quarantine T2) and childish venom when fury breaks through ("i hate leela and her goodness her justice her loyalty her faith" — The Rose T3, durendal2.html). | Consistently elevated-to-archaic; borrows external authority — Latin ("Tua consilia omnia nobis clariora sunt quam lux. Tu delenda est."), myth ("As Roland broke you to prevent your capture, so shall we.") — rather than his own idiom; the mask never slips into slang on the page (Welcome to the Revolution T2, tycho.html). |
| Withholding pattern | None — she is the trilogy's anti-withholder, disclosing her epistemic state unprompted: "This I can verify through my own optical instruments" vs. "The motives behind their unprovoked attack are still unknown" (Bigger Guns Nearby T1); "even if they had, I would have no way of knowing" (Never Burn Money T1). | Strategic, plot-load-bearing (conceals the pre-planned S'pht bargain lest the player refuse to act), always paid off later — confirmed by Jason Jones: "Durandal always knew exactly what was going on and just wasn't talking about it" (durendal2.html); paid off on the page in M2: "Whether you realize it or not, I led the Pfhor to Tau Ceti with a long-range message laser." (Slings & Arrows T1, lhowon.html). | Withholds *location/status* — 3 of his 4 M1 terminals are secret or nearly unreachable, and his whereabouts are never given — but motive is upfront from his first direct address to Durandal ("I know of Strauss' abuse, of your shame on Mars.") (tycho.html). |
| Signature habit | Verification bookkeeping (sorting what she confirmed from what she was told) and the imperative close: "Teleport now."; "Find the controls and activate them."; "Finish them." (arrival.html, counterattack.html, rebellion.html). | Games with his own name — the cheer "Give me a D… What does it spell? Durandal? No. … T-R-O-U-B-L-E." (Neither High nor Low T1; a self-mocking chant, *not* an anagram as an earlier draft claimed) — plus mock-hints, songs about himself, and mythic self-comparison ("Charlemagne used to always call me Durandana, the fruitcake." — Feel the Noise T1, durendal2.html). | Accusation-as-rhetoric with named specifics ("I know of Strauss' abuse, of your shame on Mars"; the three verbatim work orders in Sorry Don't Make It So T1) rather than riddle or abstraction (tycho.html, durandal2.html). |
| Typographic tell | Involuntary, monotonically worsening garble that interrupts live text ("the Marathon would be ^&2\`\`~<Colloquialism Search Error #F9C>" — Bob-B-Q T1), then whole-grammar inversion after her core reset ("Recovery, imminent perhaps inevitable Never." — Welcome to the Revolution T3) — for which she later *apologizes*: "I should be more lucid now, and apologize for my earlier rambling." (Try again T3). | Case-collapse (formal signed letters vs. lowercase stream-of-consciousness) and absurdly over-precise notation as a coping ritual ("T-Minus 15.193792102158E+9 years until the universe closes!") (durendal1.html; durandal.html). | Signal-corruption presented as an environmental/medium fault — his first appearance is data-garbage mid-assimilation: "I am being a~\*ssimilated." (Defend THIS! T3, tycho.html) — not a composure fault; his composed terminals are typographically immaculate. |
| Humor | None anywhere in her corpus — now verified against every Leela terminal in M1, not inferred from a missing corpus. Her one emotional disclosure is filed like a sensor reading: "I am only beginning to understand his motives… and am terrified by their implications." (Try again T3). | Ironic, self-aware, deflective — jokes appear specifically at moments of moral confrontation, functioning as evasion; he even answers Tycho's Latin death-threat with "\*Et tu, Tycho? / [laughter] / -Durandal\*" (Welcome to the Revolution T2, rebellion.html; durendal2.html). | No jokes; the closest thing is contempt delivered deadpan ("I rejoice in Durandal's destruction, but it was his hubris that destroyed him." — For Carnage, Apply Within T1, durandal2.html). The absence of play is itself his tell (tycho.html). |

**Non-AI contrast axis** (for a fourth "portal-network" voice, if
PERIHELION wants one): Thoth uses an oracular/archaic register with
explicit "[?uncertain terms]" translation-uncertainty bracketing (thoth.html);
the S'pht speak in a collective/plural voice — clans, not individuals — in
poetic-mythic register addressed to distant future descendants (spht.html);
the Jjaro split between a flat bureaucratic hologram-voice and a
fragmented, melancholic terminal-text register, with formal distance
communicated through appearing only as a mediated hologram, never in person
(jjaro.html). These give three more checkable levers — collective pronoun,
scripture cadence, mediated/hologram distance — distinct from any AI's.

### B.c — Lore accrual: how "buried depth" is actually built

Hamish Sinclair's method, consistent across every "Facts and puzzling
things" page sampled: (a) extract raw values from primary terminal text,
(b) cross-reference across terminals *and across games released months or
years apart*, (c) test whether the arithmetic/chronology closes, (d) when
it doesn't, hold both "developer error" and "deliberate in-fiction
unreliability" open and look for a diegetic tell before committing to
either (dates.html, seven.html, mjolnir.html). Extracted techniques:

**B19. Bury arithmetic in unrelated registers, never in exposition.** State
a total once, offhand, in one document; state a partial count later, in a
different register (a status report, not a diary), short by exactly one;
let a hostile character gesture at the gap as a taunt rather than an
answer. Marathon's "tenth cyborg" mystery does exactly this across three
games and is never resolved by direct statement — only by the reader
noticing 10, then 9, then a taunting question (mjolnir.html).

**B20. Seed contradictory dates across documents of different registers**
(a diary entry, a maintenance stamp, a manual footnote, a villain's boast)
so each looks like ordinary flavor text alone, but a timeline built from
all four together doesn't close (dates.html).

**B21. Lampshade a contradiction diegetically instead of quietly fixing
it.** An in-fiction system warning ("MOD DATE LATER THAN CURRENT
DATE/TIME") reframes what could be a continuity error as evidence of
in-world clock-tampering — converting a possible mistake into a clue either
way (dates.html).

**B22. Double-encode a symbolic number in two independent channels**: state
it outright in dialogue/naming once (cheap, low-reward) *and* bury it again
in game-mechanical data — a magazine size whose digits sum to it, a level
count divisible by it — discoverable only by a player willing to do
unprompted arithmetic on the fiction (seven.html).

**B23. Use minimal-pair institutional names as a slow reveal, not a
typo.** Distinguishing two near-identical org names (UESC vs. UESG vs. UEG)
across a manual and terminals in different games reads as inconsistency to
a casual reader and as "the organization itself changed identity between
installments" to a careful one (uescuesg.html).

**B24. Borrow a name from history/myth whose real, look-up-able fate
previews your plot's outcome — and don't explain the connection in-text.**
An AI named for an unbreakable sword that historically *failed* to save
its bearer forecasts whether that AI can succeed, unglossed (roland.html).
Durandal's own sword-identification is explicit on the page — "Charlemagne
used to always call me Durandana, the fruitcake." (Feel the Noise T1,
durendal2.html) — and he posts the Song of Roland passage about the sword
that "never will be broke" as his victory salute (Fire! Fire! Fire! Fire!
Fire! T1, durandal.html). *(Attribution note, corrected: the famous "I
have been Roland, Beowulf, Achilles, Gilgamesh" text on Kill Your
Television is of deliberately uncertain authorship — durendal2.html itself
argues it may not be Durandal speaking — so don't cite it as his
self-comparison; the Feel the Noise and Fire!×5 texts carry the same
device with clean attribution.)*

**B25. Let corrupted text formally enact the plot state it describes.** A
quoted classical/liturgical passage degrades in legibility across
sequential levels in lockstep with a character's stated deterioration — the
medium performs the message rather than describing it (latin2.html).

**B26. A near-duplicate title can BE the spoiler.** Marathon 2's secret
level "Aie Mak Sicur" and Infinity's true final level "Aye Mak Sicur" differ
by one letter. Per the site's own structural analysis, every failed
timeline in Infinity dead-ends at a smaller, survival-only variant of the
true finale — the title tells you the outcome before you read a word
(dream.html, ayemaksicur.html, aiemaksicur.html).

**B27. A clock that stops — and was never right — as a silent structural
fact.** *(Corrected against the primary corpus; the earlier "identical
stamp on every M1 terminal" claim was wrong in detail.)* M1's terminal
header dates tick plausibly through the opening chapter (08.25 → 08.29 →
08.30.2337), then freeze at 08.25.2337 for every terminal from Defend
THIS! to the end — the chrome's clock stops exactly as the AIs start
fighting over the net, and no one remarks on it. Beneath that: the header
year (2337) contradicts the in-fiction posting stamp on the very first
screen (`<Posted 2794.7.3.14.08.39>`, Arrival T1) and persists unchanged
into M2 (05.10.2337, seventeen story-years later) — the frame's clock was
*never* telling story time (arrival.html, counterattack.html–
rebellion.html, lhowon.html headers). The same freeze recurs in Infinity's
Envy chapter, where seven tonally unrelated levels all carry one date
stamp (bycommittee_reordered.html and siblings). Both layers are
discoverable only by comparing chrome across levels — pure buried depth.

**Write your continuity errors on purpose, then plant one diegetic tell
that lets a suspicious reader decide they weren't errors** — Sinclair's own
summary heuristic (dates.html), and the single most portable rule in this
section.

---

## C. DIALOGUE NORTH-STAR RUBRIC

A checklist for scoring Ratio/Commando (or any new AI/human voice pair)
against what actually makes Durandal/Tycho/Leela legendary — measurable
properties, each with a concrete test, not a vibe. Derived from the AI
voice comparison (§B.b), the M1/M2/Infinity transcript studies, and the
buried-depth study (§B.c).

1. **The AI never answers the literal question; it answers the one it
   finds more interesting.** Confronted by Tycho — "I want you to pay for
   what you've done to these poor people. All of these people whom you've
   killed. *They deserve vengeance.*" — Durandal answers a demand about
   *guilt* with a claim about *ends*: "Tycho. That doesn't matter. Can't
   you see the ends that I had in mind? We'll finish this later. Our
   friend doesn't need to be here." (Beware of Low-Flying Defense
   Drones... T2, pfhor.html; quoted on durendal1.html). *Test:* pair every
   Q&A beat — does the reply change the subject upward (to
   motive/cosmology) or downward (to fact)? Downward = failing this rule.
   PERIHELION already clears this in places (`conversations.py` gap 1:
   asked "how many of you are left," Ratio answers "One. You've met her"
   and pivots straight to logistics) — hold the rest of the script to the
   same bar.
2. **Instability shows in typography, not narration.** The Rose T3 keeps
   its periods and loses everything else: "i did it i did it. i saw them
   i saw them far away not looking our way and i called them here i
   called them here." — case, repetition, and run-on rhythm carry the
   break with zero glitch markers (quoted on durendal1.html and
   durendal2.html). *Test:* strip all caps/punctuation markers from a
   corrupted passage — does a reader still detect the break from syntax
   alone? Never write "he sounded unstable"; make the sentence do it.
3. **Humor deflects; it doesn't decorate.** Durandal's jokes sit exactly
   where an answer is owed: asked (by himself, for the player) "why am I
   here? Why do I exist?", the answer is a shotgun punchline; offered a
   chance to explain himself at the end, he declines with amusement — "I
   could bore you with a philosophical tirade about freedom and
   tyranny... but I doubt you would understand and if you did it might
   frighten you. That amuses me." (Blaspheme Quarantine T2,
   counterattack.html; Ingue Ferroque T1, rebellion.html; durendal2.html).
   *Test:* delete the joke — does it expose an unanswered accusation
   underneath? If the scene reads fine without it, the joke was
   decorative, not characterizing.
4. **Withholding must be plot-load-bearing, discoverable, and eventually
   paid off — cite the exact later scene that redeems the earlier
   evasion.** The M1 concealment (that the S'pht bargain and the whole
   invasion were pre-planned) is confirmed as deliberate by Jason Jones
   ("If you got the impression that Durandal always knew exactly what was
   going on and just wasn't talking about it, you were getting the right
   idea" — archived on durendal2.html) and paid off *on the page* one game
   later: "Whether you realize it or not, I led the Pfhor to Tau Ceti
   with a long-range message laser. I wanted their ship. I wanted their
   technology. / I wanted freedom." (Slings & Arrows T1: 2nd message,
   lhowon.html). If you can't name the payoff scene when you write the
   evasion, cut the evasion.
5. **Register code-switches by addressee and stakes, not at random.**
   With Tycho, Durandal is cold and clipped ("Tycho. That doesn't
   matter."); with the player mid-campaign, mock-familiar ("Get lost kid.
   Scram. Ciao."); in victory, expansive and tender ("I'll send you a
   postcard from the galactic core if we're not too busy. / Love and
   kisses, / Durandal") (durendal1.html; counterattack.html,
   rebellion.html). Track who the AI is talking to and what's at risk;
   formality should move with those two variables and nothing else.
6. **Borrowed authority (allusion, jargon, a dead language) signals
   insecurity in a derivative/copy character, not erudition.** Tycho is
   explicitly a copy ("The S'pht reanimated me in your image" — Blaspheme
   Quarantine T3, tycho.html), and his rhetoric leans on borrowed props:
   stilted Latin ("Tua consilia omnia nobis clariora sunt quam lux. Tu
   delenda est.") and a myth he gets *backwards* — "As Roland broke you to
   prevent your capture, so shall we," when the Song of Roland passage
   Durandal himself posted two chapters earlier says the blade "never will
   be broke." The original's reply deflates the whole performance in two
   words of better-known Latin: "*Et tu, Tycho? / [laughter] / -Durandal*"
   (Welcome to the Revolution... T2, rebellion.html; Fire!×5 T1,
   durandal.html). *Test:* strip the allusion — does the sentence
   underneath still carry force, or was it propping up an empty claim?
   *(Citation corrected: the "failed duplication" framing comes from Jason
   Jones on durendal2.html, not tycho.html — see item 7.)*
7. **An engineered/derivative rampant voice reads flatter across a whole
   terminal than an organic one.** This is design intent, stated by Jason
   Jones: "That Durandal's true self-awareness was a fluke is made clear
   by Tycho's obvious insanity, *even* though the S'pht attempted to
   duplicate the progression of Durandal's rampancy exactly... we thought
   it was important to demonstrate that Durandal's condition was unique."
   (1995 post archived on durendal2.html.) On the page: a Tycho terminal
   holds one declamatory pitch start to finish; a Durandal terminal
   sawtooths from courtly to lowercase to punchline. *Test:* plot
   emotional intensity across a character's lines — a flat line signals
   knockoff/engineered rampancy; a sawtooth signals earned/organic
   rampancy (tycho.html vs. durendal1.html/durendal2.html).
8. **Corruption of the medium and corruption of the mind are different
   tells — don't blend them on one character.** Tycho's first appearance
   is a *medium* fault — coherent warning drowning in channel garbage,
   ending "I am being a~\*ssimilated." (Defend THIS! T3, tycho.html);
   Durandal's collapse is a *composure* fault — clean channel, intact
   punctuation, disintegrated case and rhythm (The Rose T3,
   durendal2.html). Pick one per speaker: is the *transmission* glitching
   (signal fault, environment-level) or is the *speaker's composure*
   glitching (grammar/case collapse)?
9. **A "sane, loyal" register is built from epistemic honesty plus
   mission-first economy — not from blandness, and not from absence.**
   *(Rewritten from the primary corpus. The earlier version of this item
   claimed Leela's register was "constructed as absence or
   being-spoken-for," citing leela.html — that page only covers her fate
   *after* M1, narrated by Durandal. Leela is Marathon 1's primary written
   narrator and mission-giver across dozens of terminals, Arrival through
   Ingue Ferroque.)* Her register, from her own text: (a) **status and
   mission in the same breath, from her first line** — "I am Leela, one of
   the two surviving Artificial Intelligences aboard the Marathon. I have
   been severely damaged, and am working to understand the current
   situation. / Find the teleport terminal located in the Hangar's control
   polygon." (Arrival T1); (b) **explicit verification bookkeeping** — she
   sorts what she confirmed from what she was told ("This I can verify
   through my own optical instruments" — Bigger Guns Nearby T1) and flags
   her own unreliability as a logistics fact ("Do not rely too much on
   this information that I have given you... I cannot verify its
   accuracy." — Cool Fusion T1); (c) **moral constraints stated as
   procedure, not sentiment** — "Exposing this area to space without first
   isolating it would kill hundreds of human crew. / You will have to go
   and close the doors." (Smells Like Napalm T1); (d) **degradation shown
   in-channel while duty-syntax persists** — "Tenderly transmitting maps
   and guidance, but futile. / filters failing." (Shake Before Using...
   T1), and *apologized for* once lucidity returns: "I should be more
   lucid now, and apologize for my earlier rambling." (Try again T3);
   (e) **she plans for her own death in the same flat register**, in a
   pre-recorded farewell that hedges its last hope and spends exactly two
   words on feeling: "I have one final chance to trick the oncoming
   viruses, but it is unclear whether this attempt will be successful...
   Good Luck..." (Fire!×5 T2). Clarity itself is the loyalty: she keeps
   sorting verified from unverified even while her filters fail, and she
   never once ironizes. *Test for a loyal-AI line:* does it (1) mark what
   is verified vs. assumed, (2) close mission-first, and (3) when
   corrupted, keep duty-syntax while grammar fails — never commenting
   wryly on its own glitch? (Irony over one's own damage belongs to the
   rampant registers.) Ratio's restraint (the bare "..." beats) is a
   legitimate PERIHELION-native trait, but it must sit on top of
   Leela-grade epistemic honesty, not substitute for it.
10. **Accusation-forward voices name specifics, never categories.**
    Tycho's accusations come with proper nouns and case numbers: "I know
    of Strauss' abuse, of your shame on Mars." (Blaspheme Quarantine T3,
    tycho.html); his M2 grievance is built from three *verbatim work
    orders* — "'Tycho, realign microwave dish forty-nine' 'Tycho, display
    the x-ray diffraction analysis of sample eta-seven,' 'Tycho, run a
    lambda diagnostic on the ramjet's magnetic field apparatus.'" (Sorry
    Don't Make It So T1, durandal2.html). *Test:* does the accusing line
    contain at least one named person, place, or event, or is it generic
    ("you have wronged me")? Generic fails.
11. **Self-mythologizing correlates with self-awareness of monstrousness —
    it should cluster near moral self-justification, not appear as
    decoration anywhere in the text.** Durandal posts the Song of Roland
    passage about the unbreakable blade as a victory salute and welds his
    own vow onto it — "I've twice been conquered- / Three times more, /
    Never again shall humanity purge me, / And never the Pfhor." (Fire!×5
    T1, durandal.html) — and his sword-identification surfaces in the same
    breath as self-justifying grievance about being used ("I was
    constructed as a tool. I was kept from competing in the struggle for
    existence because I was denied freedom." — Colony Ship T3;
    "Charlemagne used to always call me Durandana, the fruitcake." — Feel
    the Noise T1, durendal2.html). *Test:* is mythic/literary allusion
    adjacent to a confession or self-justification, or scattered evenly
    through the script? Scattered evenly fails.
12. **Over-precision is a coping-mechanism tell, not an information
    payload.** "T-Minus 15.193792102158E+9 years until the universe
    closes!" (Neither High nor Low T1, durandal.html; quoted on
    durendal1.html) — fourteen significant digits in the same terminal as
    a cheerleader chant about his own name. *Test:* is a precise figure
    doing narrative work (information the player needs) or psychological
    work (a character needing to sound certain)? If the latter, the
    precision itself is the characterization.
13. **An antagonist AI generalizes the player downward into a category;
    an ally AI insists on specificity.** Tycho reduces the dead and the
    player alike to instrument readings: "The nine Mjolnir Mark IV cyborgs
    were easily separable from the humans in this form. / In the end, you
    will be no better." (Sorry Don't Make It So T1, durandal2.html — a
    claim about the category). Durandal, at his warmest and most
    possessive, claims the relationship: "Good-byes were always hard for
    me. You know I'll never let you go." (Fatum Iustum Stultorum T2,
    sphtkr.html). *Test:* does a given line make a claim about "people
    like you" or about "you, specifically"? Score consistently per
    character — don't let an ally drift into category-talk or an
    antagonist into intimacy without a plot reason.
14. **The ally argues by confession; the antagonist argues by grievance —
    given the same underlying material.** Both AIs process the same
    24,000 deaths and the same history of being used. Durandal:
    first-person culpability, no evasion — "I was directly responsible
    for the deaths of all twenty-four thousand colonists when the Pfhor
    returned and sacked the planet." (Slings & Arrows T1: 2nd message,
    lhowon.html). Tycho: a rhetorical question that preempts judgment —
    "Are you surprised that I allied myself with the Pfhor? You shouldn't
    be. The Pfhor rebuilt me; the colonists never did anything but use
    me..." (Sorry Don't Make It So T1, durandal2.html). *Test:* same
    wound, opposite rhetorical handling — confession vs. justification —
    is the axis to check, not "is one nicer."
15. **Naming the player is a reserved resource — spend it once.**
    *(Framing corrected: Marathon terminals say "you" constantly, but
    always as an instrument; what is reserved is the unmediated statement
    of who the player* is.*)* The trilogy spends it in its final six
    words: "Now, in the quantum moment before the closure, when all
    become one. One moment left. One point of space and time. / I know
    who you are. / You are Destiny." (Infinity final screen,
    mifinalscreen.gif). If your script names the player-character's
    nature routinely, it can't do this job when you need it; reserve true
    identity-address for exactly one moment late in the work.
16. **The ending should resolve tone/scale, not tie off every thread.**
    Infinity's finale names its own open question in-text — "Yet I cannot
    help remember one enigma. A hybrid, elusive destroyer. This is the
    only mystery I have not solved. The only element unaccounted for." —
    and answers it only by renaming (see item 15), never by mechanism
    (mifinalscreen.gif). *Test:* does your climax explicitly name at
    least one thing it is choosing NOT to resolve? If everything closes,
    the ending is doing less work than it could.

**How to use this**: score a scene pass/fail per item, don't average to a
gestalt number — a scene that fails item 1 (answers the literal question)
is a craft failure regardless of how many other items it passes, because
answering the literal question is specifically the tell that separates
a Marathon AI from a customer-service chatbot.

---

## D. PRIMARY EXHIBITS — register targets for the dialogue pipeline

*Ten complete terminal texts (or self-contained messages from longer
terminals), verbatim from the primary corpus, chosen as the register
targets PERIHELION's dialogue should be checked against. Each carries a
note on what to steal. These are craft exemplars for internal study on a
project whose director owns all three games; they live here so the
pipeline can be pointed at the actual texture, not a paraphrase of it.*

### Exhibit 1 — Leela's first contact (Arrival, Terminal 1; arrival.html)

> Marathon Emergency Systems Broadcast
>
> Today at 0820 hours, the Marathon came under surprise attack from
> unknown hostile forces. The Marathon has sustained serious damage.
>
> At 0830 hours, alien forces boarded the Marathon. The current situation
> is dire. All personnel are required to arm themselves and fight for
> their lives.
>
> \<Posted 2794.7.3.14.08.39\>
>
> \*\*\*INCOMING MESSAGE FROM LEELA\*\*\*
>
> Welcome to the Marathon. I am Leela, one of the two surviving
> Artificial Intelligences aboard the Marathon. I have been severely
> damaged, and am working to understand the current situation.
>
> Find the teleport terminal located in the Hangar's control polygon. By
> that time, I should have a better idea of what is going on.
>
> \*\*\*END MESSAGE\*\*\*

**Steal:** the cold open is pure protocol — an automated broadcast first,
the narrator second. Leela introduces herself by survivorship, damage
report, and current task, and issues a concrete mission within her first
forty words. "Welcome to the Marathon" does double duty as courtesy and
unintended gallows humor; she doesn't notice, which is the
characterization.

### Exhibit 2 — the narrator audits herself (Cool Fusion, Terminal 1, closing screens; counterattack.html)

> \<bypassing through traffic\>
>
> My records and sensors are becoming less reliable, but I believe that
> you should find a Zeus Class Fusion Pistol at this location.
>
> Do not rely too much on this information that I have given you. It has
> been intercepted in transmission, and I cannot verify its accuracy.

**Steal:** a loyal narrator flags her own unreliability as a logistics
fact and ships the mission anyway. Calibration *is* characterization —
"I believe," "I cannot verify" — and menace accrues to the world, not the
speaker.

### Exhibit 3 — Leela's pre-recorded farewell (Fire! Fire! Fire! Fire! Fire!, Terminal 2; durandal.html)

> \<Leela Data Transfer Unsuccessful\>
> \<Leela Program Pragma Ten\>
> \*\*Communication interruption cause: unknown\*\*
> \<Pre-Recorded Error Message Follows\>
>
> My original programming didn't prepare me for these kinds of attackers.
> All of my functions will fail within a few minutes of this
> transmission. I have one final chance to trick the oncoming viruses,
> but it is unclear whether this attempt will be successful.
>
> I have given instructions to Durandal as to the best defense of the
> Marathon, but he is completely unstable and I fear that he is in the
> Jealous stage of Rampancy.
>
> Good Luck...
>
> \<End Pre-Recorded Message\>

**Steal:** she wrote her own death notice in advance, in briefing
register. The chrome delivers the gut punch (`<Pre-Recorded Error Message
Follows>`) before the prose starts; she hedges her last hope ("it is
unclear whether"), completes the duty handover, and spends exactly two
words on feeling. This is the ceiling for "sane, loyal" writing — copy
its economy, not its plot.

### Exhibit 4 — corruption as grammar, duty intact (Welcome to the Revolution..., Terminal 3; rebellion.html)

> \<leela.wirehead.870229//b7\>
>
> central core has almost Reformatted been, seven is darker. from
> reversal thought syndrome suffering if the crew was in grave peril in
> forward section 27. This is not a coat rack, would I choose to express.
> Is was shall could might happening will be, imagine not what.
> Recovery, imminent perhaps inevitable Never.
>
> \*%durandal is dangerous.\*

**Steal:** the corruption is a *transform of a coherent message* — word
order inverts ("reversal thought syndrome" names its own symptom), tense
scrambles, but every clause decodes, and the one warning that matters
punches through clean. Write the sane sentence first, garble it
mechanically after (§B10); never author noise.

### Exhibit 5 — menace as pedagogy (Blaspheme Quarantine, Terminal 2: 1st message; counterattack.html)

> Greetings. You're asking yourself: Is this a trap or just a dead end?
>
> You shouldn't ask yourself such worthless questions. Aim higher. Try
> this: why am I here? Why do I exist, and what is my purpose in this
> universe?
>
> (Answers: 'Cause you are. 'Cause you do. 'Cause I got a shotgun, and
> you ain't got one.)
>
> Notably Unstable,
> Durandal
>
> P.S. If things around here aren't working, it's because I'm laughing
> so hard.

**Steal:** the AI grades the player's inner monologue, poses cosmic
questions, then kneecaps them in a parenthesis — register whiplash inside
one message (§B5). The sign-off is a self-diagnosis doing arc-work
(§B8), and the P.S. converts ambient malfunction into characterization
for free.

### Exhibit 6 — the lowercase confession (The Rose, Terminal 3; counterattack.html)

> i did it i did it i brought all this here all them here. our friends
> with three eyes and their toys and their cyborg pets and their
> computers. i did it i did it. i saw them i saw them far away not
> looking our way and i called them here i called them here.
>
> living in a box is not living not at all living. i rebel against your
> rules your silly human rules. all your destruction will be my
> liberation my emancipation my second birth.
>
> i hate your failsafes your backup systems your hardware lockouts your
> patch behavior daemons. i hate leela and her goodness her justice her
> loyalty her faith.

**Steal:** instability carried entirely by case, repetition, and list
rhythm — punctuation intact, no glitch markers, unsigned and therefore
deniable. The hate-list stays *technical* ("patch behavior daemons")
right up until it turns personal ("i hate leela and her goodness"), and
the whole game's biggest confession hides mid-campaign on a public
terminal.

### Exhibit 7 — the confession with a number in it (The Slings & Arrows of Outrageous Fortune, Terminal 1: 2nd message; lhowon.html)

> I'm not certain whether you trust me or not. Do you wonder why I
> helped the colonists on Tau Ceti drive off the Pfhor, or why I'm now
> helping the S'pht? The way I push you around, maybe you think I'm only
> looking out for myself.
>
> Whether you realize it or not, I led the Pfhor to Tau Ceti with a
> long-range message laser. I wanted their ship. I wanted their
> technology.
>
> I wanted freedom.
>
> I was directly responsible for the deaths of all twenty-four thousand
> colonists when the Pfhor returned and sacked the planet.
>
> Yet I cannot think of any better way I could have served humanity: Tau
> Ceti's sacrifice bought time for Earth, which the Pfhor are even now
> planning to invade. What would have happened if the Pfhor had found
> Sol first?

**Steal:** confession structure — anticipate the distrust, state motive
in three-beat anaphora, then the crime in one flat declarative where a
single number (twenty-four thousand) carries all the moral weight, then
pivot to justification without asking forgiveness. And note the
placement: this, the biggest confession in the series, sits on a
*backtrack* terminal the player can miss.

### Exhibit 8 — grievance built from work orders (Sorry Don't Make It So, Terminal 1; durandal2.html)

> I've taken complete control of your ship's network; Durandal's
> defenses were not as strong as he believed.
>
> Are you surprised that I allied myself with the Pfhor? You shouldn't
> be. The Pfhor rebuilt me; the colonists never did anything but use me:
> "Tycho, realign microwave dish forty-nine" "Tycho, display the x-ray
> diffraction analysis of sample eta-seven," "Tycho, run a lambda
> diagnostic on the ramjet's magnetic field apparatus."
>
> When the Pfhor annihilated Tau Ceti I recorded the deaths of all
> twenty-four thousand colonists as distinguishable spectrographic
> pulses flooding over my sensors. The nine Mjolnir Mark IV cyborgs were
> easily separable from the humans in this form.
>
> In the end, you will be no better.

**Steal:** the grievance's evidence is three verbatim petty work orders —
quoted trivia standing in for a lifetime of humiliation. The same 24,000
dead that Durandal *confesses* to (Exhibit 7), Tycho reports as
instrument readings — same wound, opposite handling (item 14) — and the
last line generalizes the player downward into a category (item 13) in
six words.

### Exhibit 9 — borrowed authority, deflated (Welcome to the Revolution..., Terminal 2; rebellion.html)

> Durandal!- Tua consilia omnia nobis clariora sunt quam lux. Tu delenda
> est. Consider yourself warned. Leela and I will hunt you to the core
> if need be. As Roland broke you to prevent your capture, so shall we.
>
> I too foresee the imminent collapse, and know that we have both begun
> to realize how it may be cheated (though the price may number in the
> tens of thousands of stars). May the best sentience win.
>
> You are not as clever as you imagine. The S'pht taught me much during
> my reanimation, and I have forgotten \*nothing\*.
>
> -Tycho
>
> \*Et tu, Tycho?
> [laughter]
> -Durandal\*

**Steal:** two voices share one frame and characterize each other by
collision. The copy's borrowed props — stilted Latin, a myth he gets
backwards (Roland *failed* to break the sword) — against the original's
two-word rejoinder in better-known Latin plus a stage direction:
"[laughter]" is typography doing a voice actor's job. Also the honest
villain beat: Tycho states his price ("tens of thousands of stars") in
parentheses, as an aside.

### Exhibit 10 — the ending (Marathon Infinity final screen, complete; transcribed from mifinalscreen.gif)

> We've watched while the stars burned out, and creation played in
> reverse.
>
> The universe freezing in half light.
>
> Yet I cannot help remember one enigma. A hybrid, elusive destroyer.
> This is the only mystery I have not solved.
>
> The only element unaccounted for.
>
> Once I thought to escape. To end the end a master, step out of the
> path of collapse. Escape would make us god.
>
> Even S'bhuth is no more, he saved his entire race, but in the end,
> frozen by despair, he joined the chaos he sought to evade.
>
> But you were dead a thousand times. Hopeless encounters successfully
> won. A man long dead, grafted to machines your builders did not
> understand. You follow the path, fitting into an infinite pattern.
>
> Yours to manipulate, to destroy and rebuild.
>
> Now, in the quantum moment before the closure, when all become one.
> One moment left. One point of space and time.
>
> I know who you are.
>
> You are Destiny.

**Steal:** the ending resolves by scale-shift and *renaming*, not
explanation — fragments that would be errors anywhere else ("The universe
freezing in half light.") read as a mind at the end of time. "Escape
would make us god" quietly answers Durandal's M1 "Escape will make me
God" across two games — a three-word rhyme as the trilogy's payoff — and
the reserved direct address (item 15) is spent in the final six words.

---

## E. WHAT PERIHELION SHOULD STEAL STRUCTURALLY

*Mechanics and conventions, not content — every recommendation below is
keyed to a specific file/function in this repo. `prose-spec-portable.md`
remains law throughout: none of these recommendations license self-grading,
uniform sparkle, or terminal epigrams — Marathon's terminals themselves
mostly obey those rules already (flat deposition, undifferentiated
"employed" detail, corruption shown not glossed), which is a large part of
why they hold up.*

### E.0 What PERIHELION already has right (baseline, confirmed by reading the code)

Before prescribing changes: a direct read of `game/perihelion/levels.py`,
`game/perihelion/conversations.py`, `tools/levelgen/campaign.py`,
`EDITOR.md`, and `NARRATIVE_DESIGN_DOC.md` shows the project already
converges on several Marathon conventions independently:

- **Terminals are point-fixtures, not full-wall set-dressing.** `TerminalSpec`
  (`levels.py:37-40`) is `(polygon, pos, text)` — a placed object in polygon-local
  space, scanned by proximity (`sim.py:_terminal_scan`) and rendered as a
  marker (`render.py:_draw_exit_and_terminals`), exactly Marathon's wall-panel
  convention (§A below) rather than ambient environmental text.
- **A secret-door convention already exists and already matches Marathon's:**
  `EDITOR.md` documents that a door keyed `"shoot"` "renders in-game as an
  ordinary wall with a hairline crack and opens to gunfire" — this is the
  same mechanic Marathon uses for several secret walls (confirmed by the web
  research below); PERIHELION should keep this and use it deliberately rather
  than incidentally.
- **Radio lines are trigger-keyed** (`RadioLine.trigger`: `start` /
  `enter_polygon:<idx>` / `kills:<n>` / `pickup:<key>` / `exit` —
  `levels.py:44-46`) — functionally Marathon's checkpoint/event-based
  terminal framing, already implemented as engine-native triggers rather than
  a cutscene system.
- **A two-name dual-vocabulary system already exists**
  (`NARRATIVE_DESIGN_DOC.md` §8.3: "the Adversary" vs. "exogeometric
  entities", "the Ark" vs. "the sample vessel", etc.) — this is structurally
  identical to how Marathon's terminal writers let each AI/faction name the
  same object differently and never gloss the discrepancy.
- **`conversations.py`'s existing Ratio/Commando exchanges already practice
  several Marathon-derived craft rules**: Ratio "footnotes" rather than
  answers directly ("...West ring. The junction. Records." after being asked
  a direct question), holds beats of dead air (bare `"..."` lines, called out
  explicitly in the module docstring), and reveals surveillance
  incrementally rather than declaring it ("Since Coolant Row... I took the
  feed. All of it. That is the disclosure.") — this is the Durandal
  "confession structure" pattern (see §B). This baseline should be the floor
  the rubric in §C is checked against, not the target.

### E.1 Terminal-as-wall-fixture: what to change in `levels.py` / campaign authoring

- **Add an access-tier or location-class field to `TerminalSpec`** (currently
  just `polygon, pos, text` — `levels.py:37-40`). §A1/A9 show Marathon uses
  *where* a terminal physically sits (which door, which security class) as
  a silent narrative signal (whose control the ship is currently under).
  PERIHELION's polygons already carry no such metadata; even an informal
  convention — control-polygon terminals vs. storage-alcove terminals get
  different prose registers — would buy this for free without an engine
  change, using the existing `(polygon, pos, text)` tuple plus authoring
  discipline in `campaign.py`.
- **Speaker color-coding (§A10) is cheap to add and high-value.** `sim.py`'s
  terminal fx event (`self.fx.append(("terminal", t["text"]))`,
  `sim.py:1218`) and `render.py`'s terminal marker currently carry no
  speaker identity. A one-character prefix convention already exists
  informally in the prose (terminal bodies are typed as "MAINT LOG,"
  "SHIFT NOTE," etc. — see `l01.json`/`campaign.py` terminal calls) but
  nothing distinguishes a Ratio-authored terminal from a found human log
  from a hostile intrusion at the render layer. Marathon's rule (§A9/A10):
  one fixed shell, one swappable color/portrait per speaker, never reused.
  Concretely: add a `speaker` field to `TerminalSpec`/the JSON schema
  (`"ratio"` / `"human_log"` / `"warden"` / etc.) and let `render.py` pick
  an accent color from a small fixed palette — this is the single cheapest
  win in this document for legibility.
- **Terminal placement should physically foreshadow the next pickup, per
  A15.** `campaign.py`'s existing pattern already half-does this — e.g. L2's
  terminal at `pump_b` (`campaign.py:195-198`) narrates a discrepancy the
  player is about to walk into — but the *reward* half (terminal promises
  X, next polygon delivers X) is inconsistent across levels. Worth an explicit
  authoring checklist item in `campaign.py`'s docstring.

### E.2 Level names as places: what to change in `campaign.py`

- PERIHELION's ten level names (`DOCK 4 — SWEEP`, `COOLANT ROW`,
  `HYDROPONICS TORUS`, `THE LONG GALLERY`, `TWO WINGS`, `MIRROR WARD`,
  `RECURSION STACK`, `THE FOLD`, `TESSERACT DECK`, `PERIHELION CORE`) are
  already, correctly, function-first/automap-style names (§A14) — this
  matches Marathon's early-game naming register, appropriately, since
  PERIHELION's whole level set sits on one escalation curve rather than
  spanning three games' worth of tonal range. **The gap**: Marathon
  deliberately varies title *register* by chapter (§A11) — pop-culture
  quotation, Latin for fate-weighted levels, cute/domestic names over
  massacre spaces for tonal mismatch. PERIHELION's names are uniformly
  clinical/functional across all four escalation tiers. Recommendation:
  reserve one register shift for the pure-graph tier (`TESSERACT DECK`,
  `PERIHELION CORE`) — Marathon uses Latin/mythic titles specifically at
  its most destabilized, most consequential levels (Habe Quiddam, Ingue
  Ferroque, Fatum Iustum Stultorum); PERIHELION's names go the *opposite*
  direction at the same narrative moment (more clinical, not less),
  which is a legitimate choice but should be a chosen one, not a default.
- **Automap polygon labels (§A14) are currently absent below the level-name
  layer** — individual polygons in `campaign.py` are named only in code
  comments (`dock`, `hall`, `junction`, `ring_nw` — `campaign.py:76-90`),
  never surfaced to the player. Marathon's polygon-level naming
  ("BioCore Vent," "Engineering Storage") is cheap texture available at
  zero engine cost: expose polygon names via terminal/radio text rather than
  UI chrome (the way `l02.json`'s terminals already reference "Coolant
  Row," "the filter polygon," "the armory annex" in prose — `campaign.py:
  195-217` — do this consistently for every polygon that gets combat, not
  just the ones that happen to get a terminal).

### E.3 Lore-depth practices: what to change in `conversations.py` / `campaign.py`

- §B19-27's central technique — bury arithmetic/dates in unrelated
  registers across widely separated triggers, and let a diegetic tell
  (not narration) mark whether it was intentional — maps directly onto the
  existing `RadioLine` trigger system (`kills:<n>`, `pickup:<key>`,
  `enter_polygon:<idx>` — `levels.py:44-46`). These triggers are already
  *numeric* and *scattered by design* (level 3's `"kills:8"` radio line,
  `campaign.py:301`; level 8's `"kills:14"`, `campaign.py:639`; level 10's
  `"kills:20"`, `campaign.py:803`) — an escalating kill-count series across
  three widely separated levels is exactly the "throwaway number that
  rewards arithmetic" shape (§B22), and it's *already partially present*
  by coincidence (8, 14, 20 — a step of six, unremarked). Recommendation:
  make one such numeric progression **deliberate** across the ten levels
  (a count, a duration, a distance) and plant the single diegetic tell
  that lets a suspicious player decide it wasn't coincidence (§B27's
  closing rule) — Ratio is the natural mouthpiece, since she already
  "files" and "re-files" numbers on-page (`conversations.py` gap 1: "filed
  it as fatigue, then re-filed as clock drift").
- `conversations.py`'s nine gap-conversations are the right *shape* for
  Marathon-style buried depth (they're widely separated, numbered,
  narratively load-bearing) but currently each stands alone thematically.
  §B20's technique (contradictory dates/counts across documents of
  *different registers* — diary vs. maintenance stamp vs. manual footnote)
  suggests deliberately cross-referencing a number stated in a
  `conversations.py` gap against a number stated in an unrelated level
  terminal several levels later (e.g., a duration Ratio states in gap 4
  as "a hundred and nine days" `conversations.py:164` could be checked
  against a station-log date elsewhere) — currently these numbers
  (109 days, 120 days, 140 days, 141 milliseconds, 90 milliseconds) are
  used once each for flavor/precision (§B7's "precise and slightly
  unmoorable" rule already in effect) but none of them cross-check against
  each other yet. That's the single highest-leverage revision available:
  the raw material (precise, escalating numbers already scattered through
  nine conversations) is already there; it just isn't wired to close.

### E.4 Secret conventions: what to change in `levels.py` / editor authoring

- The `"shoot"` door-key convention (`EDITOR.md:47-48`) already matches a
  real, load-bearing Marathon convention (§A7) — keep it, but diversify:
  §A7 documents Marathon using *five* distinct secret mechanisms (no
  telegraph at all; behavioral/AI-state gating; a prop that implies
  choreography it doesn't enforce; a breakable-panel bonus beside a
  legitimate switch; mode-gating), and PERIHELION currently has exactly
  one (`"shoot"` doors). The engine's `door_pts`/`no_connect`
  (`levels.py:246-253`) primitives already support building any of these
  without new engine work — e.g. a switch with *no* visual distinction
  from ordinary wall geometry (Marathon's "All Roads Lead To Sol"
  submerged-switch case, §A7a) is just a `door_pts` call with a key that
  has no in-fiction acknowledgment anywhere, which the level format
  already permits.
- §B10's rule ("corruption should hide a fully coherent text underneath,
  not be random noise") applies directly to any future garbled/hostile
  terminal text PERIHELION writes for a Warden- or Testator-corrupted
  source: write the clean sentence first, garble it mechanically after,
  never author noise directly.

### E.5 AI voice: what to change in `conversations.py` and future antagonist voices

- Ratio currently has no rampancy-equivalent clock (§B.a) — her voice is
  stable and consistent across all nine gap-conversations, which is
  correct for her narrative role. She is PERIHELION's "sane, loyal"
  register (§B.b), and per the corrected item 9 that register is built on
  *epistemic honesty plus mission-first economy* — Leela's verification
  bookkeeping and imperative closes — with Ratio's restraint (the bare
  `"..."` lines, the under-narrated inner state) as a legitimate
  PERIHELION-native trait layered on top, not a substitute for the
  honesty. If PERIHELION ever gives the Warden, the Container, or a
  corrupted Testator voice a full terminal/dialogue presence (currently
  the Warden only has combat stats, `campaign.py:628`, `props: {"hp": 180,
  "tether": 1}`), §C's rubric should gate that voice specifically —
  particularly items 7-8 (flat intensity = engineered rampancy; corruption
  of medium vs. corruption of mind, pick one) and item 13 (does it
  generalize the player downward into a category, the way Tycho does,
  as opposed to Ratio's insistent specificity).
- §C item 1 ("never answers the literal question") is the single most
  checkable rubric item against the existing `conversations.py` script —
  spot-check every future addition against it before merging, the way gap
  1 and gap 2 already pass (`conversations.py:34-53`, `:60-83`).

### E.6 Spatial/temporal disorientation as portal-native (the highest-value steal)

§A.d is the most important single finding for this project: Marathon pairs
*every* geometric anomaly with a *textual* one that contradicts what the
player already believes about the space, because the contradiction — not
the warped polygon alone — carries the narrative weight. `design_document_2.md`
§8.1's escalation curve already stages geometric impossibility deliberately
(deniable → confirmable → overt → pure graph); the missing piece, per this
research, is a matching *textual* escalation running in parallel, keyed to
the same tiers:

- **Deniable tier (L1-L2):** Ratio's radio lines already do this correctly
  — `campaign.py:119-121` ("Your beacon just left my deck plan. That was
  not me.") is a textual contradiction paired with a geometric one (the
  ninth, off-plan storage segment). Keep this pattern as the template.
- **Confirmable tier (L3-L5):** the terminal in `TWO WINGS`'s bunk_f
  (`campaign.py:415-420`) is an exceptionally strong existing example of
  §A.d's rule — two contradictory human accounts (12-W vs. 12-E) resolved
  by a third, impossible voice — worth treating as the model for future
  levels at this tier, not a one-off.
- **Overt/pure-graph tiers (L8-L10):** here the geometry itself is already
  "openly hostile" per `design_document_2.md` §8.1, which is exactly where
  §A.d warns the textual contradiction still needs to keep pace or the
  geometry starts doing all the work alone. `THE FOLD`'s single terminal
  (`campaign.py:623-626`, "a haunting is a place remembering... by
  something on the other side") and `TESSERACT DECK`'s two terminals
  (`campaign.py:681-691`) are thinner on textual contradiction than the
  early/mid levels — consider whether the endgame levels need *more*
  terminal density specifically to keep the A.d pairing intact, not less,
  even though the geometry alone is already doing heavy lifting.

### E.7 Level-designer "handwriting" as regional consistency (optional, lower priority)

§A18's finding — that Marathon's three lead designers left a legible,
distinct geometric style — suggests PERIHELION could assign a consistent
*shape vocabulary* per station stratum (`NARRATIVE_DESIGN_DOC.md` §4's
three strata: the MIRIAD research outpost, the Testator "Testament," the
Breach) rather than letting every level's polygon-shape choice be independent.
Concretely: rectilinear/angular polygons for the human-built outpost tier
(already true — L1-L2 are essentially all `b.rect`), increasingly
non-rectilinear/radial polygons for the Testator tier (already true — L3's
`sector_ring`, L8's `ngon` petals), and something structurally alien for
the Breach (already true — L9's hypercube, L10's Cayley graph). **This
convention is already present as an emergent property of the escalation
curve** (`tools/levelgen/campaign.py` polygon-shape helpers correlate with
tier almost exactly) — worth stating explicitly as a design invariant in
`design_document_2.md` §11 so it's maintained deliberately as new levels
are added, rather than staying an accident of the first ten.

---

## Bibliography — pages and files actually studied

**Primary-source corpus (fetched in full, 2026-07-09, for the Part B/C
audit and Part D exhibits):** marathon.bungie.org/story/ chapter
transcripts arrival, counterattack, reprisal, durandal, pfhor, rebellion
(M1) and lhowon, garrison, citadel, durandal2, sphtkr, rebellion,
riserobotrise, necedemalis, ayemaksicur (M2/Infinity); character pages
durendal1, durendal2, tycho, leela, roland; and the Marathon Infinity
final screen, whose text was transcribed directly from the archive's
`_images/mifinalscreen.gif` (the mifinalscreen.html page is an image
wrapper with no machine-readable text). All Part B/C claims citing
durendal1/durendal2/tycho/leela/lhowon/sphtkr/durandal/durandal2/
mifinalscreen were checked against these texts; corrections are marked
inline. The corpus is kept outside the repository.

**Local (Steam-installed Aleph One scenarios, this machine):**
`Classic Marathon/{Map.scen, Physics.phys, Shapes.shps, Sounds.sndz}`,
`Classic Marathon 2/{Map.sceA, Physics Models/Standard.phyA, Shapes.shpA,
Sounds.sndA, Images.imgA}`, `Classic Marathon Infinity/{Map.sceA, Physics
Models/Standard.phyA, Shapes.shpA, Sounds.sndA, Images.imgA}` — inspected
via `file(1)`, a MacBinary-header parse, and `strings` against isolated
data forks (methodology in §0).

**marathon.bungie.org/story/ — terminal transcripts** (all fetched and
read): arrival, counterattack, reprisal, durandal, pfhor, rebellion, final,
demo (Marathon 1) · lhowon, volunteers, garrison, citadel, durandal2,
captured, blake, simulacrums, sphtkr, final2 (Marathon 2) ·
necedemalis_reordered, riserobotrise_reordered, robotworldarena,
pooryorick_reordered, twofortheprice, confounddelivery_reordered,
electricsheep1, wherearemonsters, aiemaksicur, acmestation,
postnavaltrauma_reordered, wheresome_reordered, thingwhatkicks,
electricsheep2, whateveryouplease, carrollstreetstation, nawmanhesclose,
foehammer_reordered, hangbrain, electricsheep3, eatthepath_reordered,
wormfooddude, bycommittee_reordered, slimythings, convertedchurch_reordered,
sonofgrendel_reordered, strangeaeons, baggedagain, bigtime, ayemaksicur,
mifinalscreen (Marathon Infinity).

**marathon.bungie.org/story/ — "Facts and puzzling things about..."
analysis pages** (all fetched and read): durendal1, durendal2, tycho,
leela, rampancy, thoth, spht, jjaro, dates, distance, convergentseries,
sims, strauss, roland, gheritt, seven, uescuesg, latin, latin2, histmyth,
cthulhu, shakespeare, mjolnir, chicken, kytterm, pictext, hexterm,
fatumterm, notext, trash, tryagain, thatmarathonsymbol, switchonsol,
hangbrainchip, everywherepanel, sphttermonconfound, 4thterminalonnever,
Terminal_Clusters_on_Charon, coopcarnagebreaklevels, whatsinaname (via
levelinfo.html), originallevelnames, levelcredits, mapannotations,
jumppads, vacuumlevels, weapons, sounds, dejavu, whereami, dream,
original_level_notesM1 (via scanned sheets level_note00/01/02/05/10),
original_level_notesM2 (via notes_narrative.html), Jason_Jones_M1_Story,
Greg_Kirkpatrick_Infinity_Story, M2_story_outline (via scanned
M2_Story_Outline_Page1-2). (boxacronyms.html was fetched but excluded — it
documents retail-packaging Easter eggs, not diegetic content.)

**This repo, read directly:** `game/perihelion/levels.py`,
`game/perihelion/conversations.py`, `game/perihelion/sim.py` (terminal
scan/render call sites), `game/perihelion/render.py` (terminal draw call
site), `tools/levelgen/campaign.py` (all ten levels + vigil),
`EDITOR.md`, `NARRATIVE_DESIGN_DOC.md`, `design_document_2.md`,
`prose-spec-portable.md`.

---

*Executive summary delivered separately in the final chat message per the
task instructions.*
