# Oil concept art (claude-paint)

Concept and key art for PERIHELION, painted on a simulated oil easel:
[claude-paint](https://github.com/aliceisjustplaying/claude-paint), the studio
behind stillwet.art. AI painters wrote every brushstroke as Lua. The simulator
carried the strokes out with bristles, wet paint that levels and dries on a
clock, and Kubelka–Munk layer optics. There is no undo.

Images are not tracked, per the repo's no-binaries rule. Each `<name>.lua` is the
complete stroke log, and replaying it repaints the picture pixel for pixel.
Seven logs were replayed and compared with their saved finals: chapel,
title (v1), seam, stylite, approach, firstframe and primer. All were
byte-identical; the rest were not checked. Rendered finals are on disk in
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
