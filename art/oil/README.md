# Oil concept art (claude-paint)

Concept and key art for PERIHELION, painted on a simulated oil easel:
[claude-paint](https://github.com/aliceisjustplaying/claude-paint), the studio
behind stillwet.art. AI painters wrote every brushstroke as Lua. The simulator
carried the strokes out with bristles, wet paint that levels and dries on a
clock, and Kubelka–Munk layer optics. There is no undo.

Images are not tracked, per the repo's no-binaries rule. Each `<name>.lua` is the
complete stroke log, and replaying it repaints the picture pixel for pixel.
Replays of the title and chapel logs were checked against the saved finals and
are byte-identical. Rendered finals and time-lapses are on disk in
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
