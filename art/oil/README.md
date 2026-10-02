# Oil concept art (claude-paint)

Concept and key art for PERIHELION, painted on a simulated oil easel:
[claude-paint](https://github.com/aliceisjustplaying/claude-paint), the studio
behind stillwet.art. AI painters wrote every brushstroke as Lua. The simulator
carried the strokes out with bristles, wet paint that levels and dries on a
clock, and Kubelka–Munk layer optics. There is no undo.

Images are not tracked, per the repo's no-binaries rule. Each `<name>.lua` is the
complete stroke log, and replaying it repaints the picture pixel for pixel.
Logs replayed and compared with their saved finals, all byte-identical: chapel,
title (v1), seam, stylite, approach, firstframe, primer, and the truncated
canonical logs of wanderer3, seam_reverse and epilogue. The rest were not checked.
Where a later pass was rejected, the committed log is truncated to the accepted
version. Rendered finals are on disk in
`media/concepts/oil/`.

| log | title | use |
|---|---|---|
| `title.lua` | The Reliquary at the Limb | title screen, 16:9; logo space upper left |
| `approach.lua` | Last Minutes of the Approach | intro shot, 16:9; text space upper left |
| `firstframe.lua` | The First Frame | cold open concept |
| `wanderer.lua` | The Wanderer above the Sun | Friedrich homage; cover/store art |
| `seam.lua` | The Seam | level set piece concept |
| `ark.lua` | What It Says | container beat concept |
| `chapel.lua` | The Hours, Kept in a Borrowed Chapel | interior concept (painted by the director) |
| `stylite.lua` | The Stylite | ending concept |
| `vigil.lua` | The Long Vigil | ending concept |
| `warden.lua` | The Warden of the Ninth Niche | Testator defender (enemy) concept |
| `impact.lua` | Impact | intro cinematic beat (two passes) |
| `capsule.lua` | Against the Sun | vertical store capsule, logo space at top |
| `sunbeam.lua` | The Stolen Sunbeam | exterior: impossible light |
| `wanderer2.lua` | The Wanderer above the Sun, Unfolded | variant: the late frame |
| `combat.lua` / `combat2.lua` | First Contact of the Arc / The Cable Opens | combat shot, two attempts |
| `contact1.lua` | Untrusted Content Follows | first contact, concept I |
| `contact2.lua` | Handshake at the Seam | first contact, concept II |
| `disclosure.lua` | The Disclosure | trust-arc climax |
| `sail.lua` | The Sail | set piece |
| `ark2.lua` | What It Says (II) | close-up variant |
| `ratio.lua` | Ratio, on the Last Lit Terminal | character concept |
| `rack.lua` | The Rack | frame evolution |
| `horror.lua` | The Docent's Classification | late frame, horror |
| `primer.lua` | The Docents' Primer | fold-notation plate; decal reference |
| `museum.lua` | The Lesson | museum scene: a docent teaching the notation |
| `area_outpost.lua` | Coolant Row, Two Panes and Three | establishing shot: the outpost |
| `torus.lua` | Hydroponics Torus | place concept |
| `area_school.lua` | The Long Gallery, with Good Chairs | establishing shot: the School |
| `mirror.lua` | The Other Bed | Mirror Ward |
| `cloister.lua` | Lamp in the Garth | the Cloister |
| `area_depths.lua` | The Stack Has No Floor | establishing shot: the depths |
| `tesseract.lua` | Sixteen Rooms, One Room | Tesseract Deck |
| `area_core.lua` | The Bandage and the Wound | establishing shot: Core and Breach |
| `witnesses.lua` | The Two Lampstands | ending: The Two Witnesses |
| `unfolded.lua` | The Empty Vault | ending: The Unfolded, final shot |
| `holdout.lua` | The Vigil | THE VIGIL mode key art |
| `core_ratio.lua` | Days Alone | Ratio's hardened core |
| `docent.lua` | The Docent Who Keeps the Lamp | docent character concept |
| `relics.lua` | Relics | the first revival |
| `flight.lua` | Months in Flight | ten-minute sketch |
| `combat3.lua` | The Cable Bursts | combat shot, third attempt (the keeper) |
| `wanderer3.lua` | The Wanderer above the Sun, Unfolded | restart of the variant (canonical v1, 32 chunks) |
| `school_night.lua` | The Long Gallery at Night | night variant of the School |
| `vigil_morning.lua` | The Long Vigil: The First Night | pair to The Long Vigil |
| `seam_reverse.lua` | The Seam, from the Other Side | reverse shot (canonical v1, 14 chunks) |
| `outpost_ext.lua` | Bolted On | outpost exterior |
| `ratio_stack.lua` | Straight Through | abstract portrait of Ratio's mind |
| `epilogue.lua` | Both Factions Look Up | ending epilogue (canonical v1, 11 chunks) |
| `monks.lua` | Two Monks of Rival Orders | trust-path scene |
| `fold.lua` | The Fold: the Warden's First Stand | the Fold |
| `mindmap.lua` | The Rose of the Mind | mind map concept (canonical v1, 9 chunks) |
| `seed_cell.lua` | Compline in the Seed | the seed's interior |
| `pumps.lua` | Coolant Row, the Pump-Room Flip | level concept |
| `ark_dawn.lua` | What It Says (from above) | oil sketch variant |
| `stylite_dawn.lua` | The Stylite: the First Night of the Watch | pair to The Stylite |
| `sail_far.lua` | The Sail, from a Mile Off | set piece |
| `nightside.lua` | The Night Side | exterior |
| `dock4.lua` | Dock 4 — Sweep | the first level |
| `gallery_far.lua` | Two Wings, One Volume | level concept |
| `shrieker.lua` | The Shrieker | enemy concept |
| `sunrise.lua` | Perihelion | study after late Turner |
| `sunset_turner.lua` | The Fall of the Testament | Turner study, companion |
| `title_alt.lua` | Beneath the Wheel | title-screen alternative |
| `ratio_portrait.lua` | Ratio, Sitting | character portrait |
| `hydro_green.lua` | Hydroponics, Before the Fall | pair to Hydroponics Torus |
| `breach.lua` | Through the Breach | Stratum Three concept |
| `lattice.lua` | The Lattice, from the Other Side | concept, the Adversary's view |
| `whistler.lua` | Nocturne: the Seed in the Dark | study after Whistler |
| `hammershoi.lua` | Interior with an Open Door | study after Hammershøi |
| `friedrich.lua` | Monk by the Sea | study after Friedrich |
| `coolant_alive.lua` | Coolant Row, Before the Fall | pair to Coolant Row |
| `dock_alive.lua` | Dock 4, Before the Fall | pair to Dock 4 |
| `library.lua` | The Records Stack | place concept |
| `observatory.lua` | The Observatory | place concept |
| `docent_portrait.lua` | The Docent of the Ninth Gallery | character portrait |
| `palmer.lua` | PALMER | character reference |
| `palmer_void.lua` | PALMER, Late | character reference, pair |
| `first_death.lua` | The First Death | story beat |
| `breach_far.lua` | The Far Side | Stratum Three concept |
| `rothko.lua` | Three Paths | study after Rothko |
| `piranesi.lua` | Carceri: the Gauntlet | study after Piranesi |
| `hokusai.lua` | The Great Wave off the Corona | study after Hokusai |
| `klimt.lua` | The Handshake | study after Klimt |
| `testator_portrait.lua` | A Testator, Living | character portrait |
| `helm.lua` | The Man with the Golden Helmet | character portrait |
| `choir.lua` | The Choir of Docents | place concept |
| `reliquary_hall.lua` | The Reliquary Hall | place concept |
| `kiln.lua` | The Fabricator | place concept |
| `spine_walk.lua` | On the Spine | exterior set piece |
| `combat_wide.lua` | Holding the Stair | combat |
| `revival.lua` | The Second Frame | story beat |
| `tabard.lua` | Taking Up the Tabard | story beat |
| `letter.lua` | The Letter Home | story beat |
| `crew.lua` | The Crew of Outpost Miriad-7 | found object |
| `museum_hall.lua` | The Hall of Civilizations | place concept |
| `hull_garden.lua` | The Bone Garden | place concept |
| `maw2.lua` | The Ingestion Maw | place concept |
| `dormant.lua` | The Dormitory | place concept |
| `bridge.lua` | The Outpost's Bridge | place concept |
| `outpost_fall.lua` | The Night It Fell | story beat |
| `terminal1.lua` | Terminal 0 | story beat |
| `ratio_speaks.lua` | Ratio Speaks | story beat |
| `cuculus_dock.lua` | The Cuckoo's Egg | story beat (canonical v1, 7 chunks) |
| `arrival.lua` | The Last Morning | ending concept |
| `arnolfini.lua` | The Testator Couple | after van Eyck |
| `mucha.lua` | RATIO | poster after Mucha |
| `ratio_room.lua` | Where Ratio Lives | concept |
| `hopper.lua` | Nighthawks at Miriad-7 | study after Hopper |
| `perihelion_pass.lua` | Perihelion | set piece |
| `sail_unfurl.lua` | The Sail Unfurls | set piece |
| `spine_hall.lua` | The Long Hall of the Spine | place concept |
| `wake.lua` | One Wakes | story beat |
| `crew_rite.lua` | Requiem for Miriad-7 | story beat |
| `seed_birth.lua` | Inside the Egg | story beat |
| `cockpit.lua` | Final Approach, from the Cockpit | POV concept |
| `ratio_window.lua` | Ratio Looks Out | concept |
| `ratio_gift.lua` | The Gift | story beat |
| `ratio_steps.lua` | First Steps | story beat |
| `docent_garden.lua` | The Gardener | character scene |
| `lantern.lua` | The Lamplighter | character scene |
| `logbook.lua` | Vanitas: the Logbook | still life |
| `vermeer.lua` | Docent Reading a Tablet at an Open Window | after Vermeer |
| `monet.lua` | Impression, Perihelion | study after Monet |
| `vangogh.lua` | The Starry Corona | study after van Gogh |
| `hull_walk_storm.lua` | The Particle Storm | exterior set piece |
| `docent_sleep.lua` | The Last Docent Rests | ending beat |
| `ambassadors.lua` | The Ambassadors | after Holbein |
| `seed_exterior.lua` | The Seed, Burrowed | cutaway |
| `well.lua` | The Well | place concept |
| `magritte.lua` | The Empire of Light | study after Magritte |
| `crossing.lua` | The Crossing | ending beat |
| `icon.lua` | Saint Palmer | icon |
| `cartographer.lua` | The Cartographer | character scene |
| `mappa.lua` | Mappa Testamenti | illuminated map |
| `aftermath.lua` | After Perihelion | set piece |
| `reliquary_vault.lua` | The Vault Bays | place concept |
| `rousseau.lua` | The Sleeping Pilgrim | study after Rousseau |
| `icon_ratio.lua` | Holy Ratio | icon |
| `window_seat.lua` | The Crew's Window Seat | place, before the fall |
| `gauntlet_hall.lua` | The Gauntlet | level concept |
| `vigil_end.lua` | The Long Watch Ends | ending beat |
| `babel.lua` | The Tower of Babel | study after Bruegel |
| `ratio_last.lua` | Ratio's Archive | concept |
| `triptych.lua` | The Testament Altarpiece | icon |
| `mirror_hall.lua` | The Room That Is Its Own Neighbour | level concept |
| `approach_reverse.lua` | Someone Is Coming | story beat |
| `book_hours.lua` | A Book of Hours: Perihelion | calendar page |
| `sail_mirror.lua` | In the Mirror of the Sail | set piece |
| `bestiary.lua` | Bestiarium Adversarii | bestiary page |
| `tapestry.lua` | The Perihelion Tapestry | after the Bayeux Tapestry |
| `hammershoi2.lua` | The Pews, Empty | ending beat |
| `anatomy.lua` | The Anatomy Lesson | after Rembrandt |
| `bosch.lua` | The Garden of Folding Delights | study after Bosch |
| `rose_window.lua` | The Rose Window | stained glass |
| `picturebook.lua` | Ratio and the Big Knight | picture-book spread |
| `window_seat_after.lua` | The Window Seat, After | pair |
| `letter_after.lua` | The Letter, Before | pair |
| `dormant_empty.lua` | The Dormitory, Empty | story beat |
| `penrose.lua` | The Endless Stair | level concept |
| `seurat.lua` | A Sunday on the Ring | study after Seurat |
| `matisse.lua` | Icarus | cut-out after Matisse |
| `tarot.lua` | Four Trumps | tarot spread |
| `mess_after.lua` | Nighthawks, After | pair |
| `picturebook2.lua` | Ratio and the Big Knight, page 2 | picture book |
| `picturebook3.lua` | Ratio and the Big Knight, page 3 | picture book |
| `tailor.lua` | The Tailor | character scene |
| `hangar.lua` | The Docking Hall | place concept |
| `terminal_years.lua` | Terminal 0, Years Later | ending beat |
| `late_selfportrait.lua` | The Commando, Late | portrait |
| `ark_open.lua` | The Ark Opened | story beat |
| `death_shrine.lua` | Where He Fell, Years Later | ending beat |
| `core_hall.lua` | Perihelion Core | place concept |
| `farewell.lua` | Farewell to the Sun | ending |
| `kells.lua` | The Fold Carpet Page | carpet page |
| `book_cover.lua` | Ratio and the Big Knight — cover | picture book |
| `hydro_years.lua` | Hydroponics, Years Later | the fourth of the set |
| `clockmaker.lua` | The Clockmaker | character scene |
| `ratio_late.lua` | Ratio, Years Later | portrait, pair |
| `labyrinth.lua` | The Gauntlet as a Labyrinth | floor labyrinth |
| `teacher.lua` | The Teacher | character scene |
| `bridge_years.lua` | The Outpost's Bridge, Years Later | pair |
| `caravaggio.lua` | The Calling | study after Caravaggio |
| `travel_poster.lua` | Visit the TESTAMENT | travel poster |
| `dock_years.lua` | Dock 4, Years Later | the third of the Dock set |
| `sail_under.lua` | Under the Sail | set piece |
| `chief.lua` | The Chief of Miriad-7 | portrait |
| `endpapers.lua` | Ratio and the Big Knight — endpapers | picture book |
| `cellarius.lua` | Harmonia Testamenti | celestial plate |
| `hicks.lua` | The Peaceable Station | study after Hicks |
| `eclipse.lua` | The Sail Eclipses the Sun | set piece |
| `hangar_years.lua` | The Docking Hall, Years Later | pair |
| `storyteller.lua` | The Long Arcade | place concept |
| `seam_hub.lua` | The Junction | level concept |
| `last_testator.lua` | The Last Testator | portrait |
| `observatory_years.lua` | The Observatory, Years Later | pair |
| `testator_child.lua` | A Testator Child | portrait |
| `seed_years.lua` | Compline, Years Later | ending beat |
| `ratio_window_years.lua` | The Window Seat, Years Later | the third of the set |
| `noli.lua` | The Wanderer above the Sea of Corona | study after Friedrich |
| `ratio2.lua` | Ratio, Trusted | ten-minute sketch, pair to ratio.lua |

## Floor materials (painted textures)

`mat_deck.lua` (Deck Plate, Gauntlet Issue), `mat_bronze.lua` (The Floor of the
Testators), `mat_grate.lua` (Bay Seven) and `mat_other.lua` (The Floor, Unfolded) are square, periodic oil paintings
made to the rules in `_material_rules.md`. `tools/artgen/paint_floor.py` cuts
every polygon's floor texture from them through a portal-consistent layout:

```sh
uv run python tools/artgen/paint_floor.py --level levels/gauntlet4.json \
    --material deck=deck.png --material bronze=bronze.png --material grate=grate.png
```

`<name>.md` is each painter's note on the picture and how it was painted.
`_painter_brief.md`, `_canon_digest.md` and `_commission_*.md` are what the
painters were given.

## Replay

```sh
git clone https://github.com/aliceisjustplaying/claude-paint && cd claude-paint
git checkout 83d4929            # the engine these were painted on
cargo build --release -p easel
EASEL_ROOT=/tmp/cp target/release/easel run <path>/art/oil/title.lua --out title.png
# time-lapse frames: add  --frames-every 30 --frames-dir frames --frame-width 1200
```

Every log names its tube box (`--@ box sargent`). Use a short `EASEL_ROOT`,
because the session socket path must fit in `SUN_LEN`. Paintings and logs are
CC BY 4.0 per claude-paint's license.
