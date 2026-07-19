# ARTSTYLE DIRECTION (director's ruling, 2026-07-10)

The problem was never the vector graphics. The problem is LARPing as an
Atari game. Teleglitch was the GAMEPLAY reference, never the visual one;
we do not have its constraints and must stop cosplaying them.

## The fiction that licenses the style

What the player sees is the COMMANDO'S INTERNAL REPRESENTATION of his
sensor data. Entities stay vector: enemies are highly stylized target
traces because that is precisely what they are (the alien enemies may
not even resolve clearly in visible light). The environments, however,
are mapped surfaces the sensors know in detail -- they carry the
fidelity.

## The two levers

1. TEXTURES (lever one). Render at full window resolution with the same
   vector entities; raise environment fidelity with bespoke generated
   textures through the existing image pipeline (generation + in-context
   Gemini verification -- the part of our capability that is genuinely
   excellent). Existing procedural prims/decals are base truth: feed
   them as priors ("render this texture at 4x the resolution"); simple
   line-art props are fine as-is or waifu2x-upscaled.

2. LIGHTING (lever two, biggest after textures). visible_set from any
   apex IS a shadowcasting solve -- the engine almost has real lighting
   already. Light sources (terminals, seeds, flashes, the breach) cast
   through portals, including non-Euclidean ones. Phase two, after
   textures land.

## Measured projection (2026-07-10, this repo)

- 1,815 polygons total (campaign + vigil). Median polygon at native res is
  273x273 px; 462 polygons fit 256^2, 1,266 fit 512^2, 87 need 1024^2.
- Bespoke texture for EVERY polygon: ~585 MB PNG / ~152 MB WebP download.
- Generation cost ~$0.066/polygon => ~$120 total (+~30% art-direction
  margin). Textures are cheap; scope is not the constraint.

## Sequencing

1. Native-resolution rendering path (prerequisite; also fixes every UI,
   the mind map first among them -- the mind map becomes a real graph
   at window res: nodes, prereq edges, regions as territory).
2. PILOT: bespoke textures for a couple of selected sections from EACH
   polygon style; judge in-context before committing the fleet.
3. Finalize level design; then generate the full station.
4. Lighting.

Entities/HUD stay in the sensor-trace language throughout.

## Full cost projection (measured 2026-07-10)

Census: 1,815 polygons; buckets 462x256^2 / 1,266x512^2 / 87x1024^2 at
native res (3 px/world-unit).

Download (bespoke texture per polygon):
  1x density: ~585 MB PNG / ~152 MB WebP  <- recommended start
  2x density: ~1.9 GB PNG / ~475 MB WebP
RAM: all-resident decoded ~1.8 GB -> textures stream per chunk
  (~170 MB resident, ~350 MB peak with neighbor warm). Plumbing item.

Generation (anchor: measured $0.044/call blended, this repo's pipeline):
  Lean   (1 cand, spot verify)        ~$0.04/polygon  ~$75  total
  Standard (2 cand + verify + rework) ~$0.10/polygon  ~$185 total
  Empirical worst (3.8 calls/asset)   ~$0.17/polygon  ~$305 total
Wall-clock at standard: ~8,000 calls, 1-2 h at 8-way parallel.

Pilot: 2 sections x 13 polygon styles ~= 75 polygons ~= $8.
Constraint ranking: art direction quality > native-res render path >>
dollars or megabytes (both trivial at any tier).
