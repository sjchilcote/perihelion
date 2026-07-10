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

- 1,815 rooms total (campaign + vigil). Median room at native res is
  273x273 px; 462 rooms fit 256^2, 1,266 fit 512^2, 87 need 1024^2.
- Bespoke texture for EVERY room: ~585 MB PNG / ~152 MB WebP download.
- Generation cost ~$0.066/room => ~$120 total (+~30% art-direction
  margin). Textures are cheap; scope is not the constraint.

## Sequencing

1. Native-resolution rendering path (prerequisite; also fixes every UI,
   the mind map first among them -- the mind map becomes a real graph
   at window res: nodes, prereq edges, regions as territory).
2. PILOT: bespoke textures for a couple of selected sections from EACH
   room style; judge in-context before committing the fleet.
3. Finalize level design; then generate the full station.
4. Lighting.

Entities/HUD stay in the sensor-trace language throughout.
