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
