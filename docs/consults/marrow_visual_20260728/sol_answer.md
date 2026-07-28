# Marrow visual-pass ruling

The hub’s topology is not the problem. The dominant visual failure is the combination of:

1. twenty-four axis-aligned silhouettes;
2. no topological-depth transition into the existing otherworld renderer;
3. corruption expressed mainly by violet light and small organ bodies.

### Bayescraft diagnosis

Live hypotheses:

- **H₁:** rectangular chamber silhouettes plus absent otherworld progression are the main failure.
- **H₂:** the geometry is adequate; sparse props/textures are the main failure.
- **H₃:** the geometry and props are adequate; framing and lighting are the main failure.

For H₁, prior odds were approximately **1:1**. Evidence that the director specifically praised structure but objected to rectangular construction:

- `P(E|H₁) ≈ 0.90`
- `P(E|¬H₁) ≈ 0.25`
- LR ≈ 3.6

Evidence that irregular otherworld rooms already read substantially more alien than an equivalent rectangle:

- `P(E|H₁) ≈ 0.85`
- `P(E|¬H₁) ≈ 0.30`
- LR ≈ 2.8

Those observations are correlated, so I would not multiply them at full strength. Discounted posterior: approximately **6:1, or 86%**, that geometry plus progression is the right primary intervention. Textures remain necessary, but should follow geometry rather than substitute for it.

The recommendation is therefore:

> Preserve the 24-room portal graph and cathedral functions, replace every rectangular shell with a one-off convex biogenic shell, then drive a continuous corruption scalar from the receiving apses to the Source Cells. Make the semantic room-kind switch to `otherworld` at depth six, but crossfade the rendering model around that switch so it never appears as a binary level-theme boundary.

---

# 1. Geometry language

## 1.1 Global grammar

The hub should look like a **precisely machined organism**, not a random cave and not a hexagonal insect nest.

Use these rules for all 24 shells:

- **Five to nine meaningful facets**, ten only for the large vestibule.
- Major silhouette changes must survive at 0.45:
  - large chambers: vertex departures of at least **18–28 world units**, or 8–13 internal pixels;
  - small organ cells: at least **11–18 units**, or 5–8 pixels.
- Avoid details or standalone edges shorter than approximately **22 units / 10 pixels**, excluding edges created by door carving.
- No chamber should read as “a rectangle with two corners clipped.” At least:
  - two major walls must be nonparallel;
  - the centroid should be visibly off the bounding-box symmetry axis;
  - one side should have a different long/short edge rhythm from its opposite.
- Keep the polygons convex. Validate that every consecutive cross-product has the same sign in the engine’s y-down winding.
- Use long–short–medium facet rhythms and asymmetric ovoid, seed, carapace, vertebral, lance, and calyx silhouettes.
- Do **not** use repeated hexagons, evenly spaced ribs, sawteeth, random jitter, or mirrored copies. Those would read as industrial modularity or procedural noise, not Testator handcraft.
- Preserve each chamber’s approximate area within **±8%** and preserve the combined floor-area share of depth bands 0–2 at **50–54%**.
- Preserve the existing chamber names, insertion order, `_LINKS`, degree sequence, and topological depth. No new doors and therefore no new one-door chambers.

The visual result should be “grown in its global proportions, machined in every individual edge.”

## 1.2 Portal-bearing “hard palates”

The arbitrary shapes must be authored around portal edges, not carved opportunistically afterward.

Every connection gets an explicit named host edge:

```python
PortalSeat(
    edge=<authored edge index>,
    t=<position along edge>,
    width=DOOR_W,
)
```

Required host-edge lengths:

- Internal 70u door: at least **94u**, giving 12u of intact wall on each side.
- 96u breach seam: at least **128u**, giving 16u on each side.

At 0.45 these produce openings of approximately:

- internal door: **31.5 pixels**;
- breach: **43.2 pixels**.

That is already large enough. Do not widen them as visual compensation.

Replace `_carve_spread` with explicit seats and change `_LINKS` to identify endpoint seats. Each side is still carved at the same width and connected through `connect_equal`. Construction must continue to assert scale 1.0.

The portal facets should look like **flattened load-bearing palates within otherwise curved/faceted shells**. This gives the door a plausible structural seat without returning the whole room to a rectangle.

## 1.3 Role-by-role grammar

| Chambers | Shape and vertex count | Aspect / irregularity | Portal and combat requirements |
|---|---|---|---|
| **Receiving Apses A1–A3** | 6–7 vertices; asymmetric seed or blunt teardrop | 1.15–1.35; 18–24% radial departure | One broad 128u exterior palate for `BREACH_W`, one separate 94u palate toward G. Keep the breach and court openings broadly opposed, but offset by 10–20° so the room is not a shooting tube. Each apse must be a different silhouette. |
| **Guardian Courts G1–G3** | 6–8 vertices; broad carapace bowl | 1.0–1.3; 15–22% | Two large portal facets. Preserve a central combat disk of at least 60u radius and the existing shelf/resident stations. Do not introduce wall tips close to either doorway’s interior endpoint. |
| **Transepts T1–T3** | 7–9 vertices; interlocking petals or folded plates | 1.1–1.35; 18–25% | Four authored portal facets per room where required. Distribute them around the shell rather than putting two doors on one shortened side. Preserve the T1–T2–T3 fold loop and early multi-route pressure. |
| **Rood Gatehouse R** | 6–7 vertices; convex lens with unequal shoulders | 1.0–1.2; 15–20% | Two broad, nearly opposed portal facets. Preserve the axial read into N1 and a clear arrest area for the husk/spitter residents. It must not become a narrow throat. |
| **Collar Chapels C1–C2** | 6–8 vertices; radial seed chapel with one flattened root | 0.95–1.15; 18–25% | Existing one-door side cells remain one-door. Preserve a central clear radius of at least 36–40u around the collar body. No decorative free-floating rings. |
| **Nave N1–N4** | 6–8 vertices; alternating left/right “vertebrae” | 1.15–1.45; 12–20% | Main forward/back portals stay on broadly opposed facets. N1–N3 receive one lateral chapel facet where needed. Preserve fought-retreat sightlines; do not turn the nave into a zigzag or series of doorway peeks. |
| **Anchor Chapels AN1–AN2** | 6–8 vertices; asymmetric phyllotactic bud | 1.0–1.25; 18–25% | One 94u host edge and a central protected organ envelope. AN1 must retain the brute’s valid resident post and unobstructed exit route. |
| **Scriptorium SC** | 6–8 vertices; compact folded seed | 1.0–1.2; 18–24% | Preserve the central ledger/organ anchor and the current single entrance. Its inscriptions should spiral without forming a complete ring. |
| **Long Connector L** | 6–8 vertices; tapered lance or hollow quill | 3.2–4.0; 10–16% | Two opposed end palates. Keep a minimum cross-section comparable to the current 90u width; preferably 96–104u after area correction. Preserve both lights at local x = ±120. No side teeth or internal-looking pinch points. |
| **Vestibule V** | 8–10 vertices; broad three-lobed calyx expressed as a convex fan | 2.2–2.8; 15–22% | One L inlet and three distinct Source exits on separate broad facets. Preserve the large central combat floor, brute/mite positions, both lights at x = ±100, and pairwise graph separation of the Sources. |
| **Source Cells S1–S3** | 7–9 vertices; three distinct reliquary seeds | 0.9–1.15; 18–28% | Existing one-door cells. Keep each Source Knot’s protected central envelope and enough maneuvering room to fire and retreat. They must not share a silhouette or merely rotate one template. |

## 1.4 Preservation contract

The reshape must not silently relocate landed systems. Each chamber specification should include protected local-space envelopes for:

- organ-part anchors;
- guardian shelf stations and their dispatch ordering;
- resident spawn/post positions;
- garrison/settlement anchors currently derived from chamber interiors;
- the positions in `HUB_LIGHT_PLAN`;
- portal approach and exit clearances.

At construction, assert:

1. every protected point is inside the polygon;
2. every protected body envelope is at least its radius plus 16u from a wall;
3. all lights remain inside their chambers;
4. all residents can route from their post to every applicable exit;
5. the standing guardian burst does not reorder or lose a member because one post acquired a shorter or blocked path;
6. all 24 chamber degrees and apse-to-Source hop counts are unchanged;
7. no new one-door chamber exists;
8. every glued transform has scale `1 ± tolerance`.

Convexity means there are no new internal occluders. Combat changes will chiefly come from doorway angles and reduced corner space. Those are acceptable, but the nave, L, and V should remain broad fought-retreat spaces rather than become alternating funnel mouths.

---

# 2. Exact corruption gradient

## 2.1 Depth definition

Depth is **minimum portal-graph hops from any Receiving Apse**, not campaign depth and never Euclidean distance. The outside chamber containing a breach has no place on this scale.

Use a stored `corruption_descent` scalar per hub polygon:

| Graph depth | Chambers | Descent | Semantic room kind |
|---:|---|---:|---|
| 0 | A1, A2, A3 | 0.10 | `marrow` |
| 1 | G1, G2, G3 | 0.18 | `marrow` |
| 2 | T1, T2, T3 | 0.28 | `marrow` |
| 3 | R, C1, C2 | 0.40 | `marrow` |
| 4 | N1 | 0.50 | `marrow` |
| 5 | N2, AN1 | 0.60 | `marrow` |
| 6 | N3, AN2 | 0.72 | `otherworld` |
| 7 | N4, SC | 0.82 | `otherworld` |
| 8 | L | 0.90 | `otherworld` |
| 9 | V | 0.96 | `otherworld` |
| 10 | S1, S2, S3 | 1.00 | `otherworld` |

This puts the semantic switch at approximately three-fifths depth, while visible corruption starts much earlier.

## 2.2 Do not make the lighting-model transition binary

A hard change from ordinary lighting in N2 to full inverse darkness in N3 would read as a theme trigger, not encroaching corruption.

Extend the existing otherworld compose step to accept a scalar:

```python
ow_mix = smoothstep(0.25, 0.85, corruption_descent)
```

The rendering order should remain one pathway:

1. solve ordinary static and dynamic lights through the portal graph;
2. produce the normal lit environment;
3. produce the existing self-luminous/inverse-darkness otherworld environment;
4. blend the two environment results by `ow_mix`;
5. draw entity traces without applying the environment tint to them.

The semantic kind still switches at depth six, satisfying the director’s ruling. The scalar prevents the lighting discontinuity.

### Interaction with `HUB_LIGHT_PLAN`

Keep the plan’s positions, colors, intensities, and radii unchanged.

- Violet apses remain the first architectural warning.
- Brass courts and the trunk ramp remain the readable Testator processional infrastructure underneath the corruption.
- As `ow_mix` increases, cold self-luminescence raises the floor minimum and inverse darkness moves around the brass pools.
- The brass lights should remain visible as localized warm remnants, especially in V. Do not globally recolor them teal.
- Source-cell violet-white remains visible from each cell’s doorway.
- The player’s warm light must continue to reveal local texture and wall detail. Otherworld composition must not make the flashlight ineffective or tint the player/entity layer.

The resulting read should be: **the old cathedral still lights itself, but its darkness no longer obeys those lights.**

## 2.3 Make `descent` real

The supplied `_props_otherworld` accepts `descent` but currently does not use it. Passing the value without changing the generator would provide no evidence of progression.

Use `descent` to control:

- surviving embodied furniture density: down with depth;
- fold-notation recursion: up with depth;
- self-luminous speckle: up with depth;
- impossible object placement: up with depth;
- polygon-outline afterimages: absent shallow, sparse mid-band, dominant deep;
- corruption coverage of old Testator conduits: up with depth.

Recommended visible stages:

- **0.10–0.28:** intact handcrafted cathedral with small cold defects along selected ribs.
- **0.40–0.60:** familiar objects become misplaced; fold inscriptions no longer close; wall treatment begins breathing.
- **0.72–0.82:** full otherworld lighting model, sparse embodied furniture, strong stale-outline echoes.
- **0.90–1.00:** floors become nominal, recursion dominates, Sources sit in nearly complete inverse space.

Remove the current perfect ring of evenly spaced half-size seats. It violates both the no-repetition law and the “rings mean aggro” vocabulary. Replace it with an incomplete, golden-angle sequence of individually different seat remnants, then progressively displace or occlude them as descent rises.

---

# 3. Infection outside the hub

A breach must contaminate the world side before the player crosses. This should be attached to the **active world-side portal handle**, not inferred from Euclidean proximity to the off-map apse.

During the approximately three-second formation tell:

1. an asymmetric cold stain spreads 35–50u along the wall from the future seam;
2. two or three branching fissures follow existing floor/conduit directions;
3. the local texture begins the same low-amplitude UV drift used by deep marrow;
4. a narrow localized inverse-darkness mask grows 30–45u into the room;
5. only then does the material vanish and the portal become traversable.

After opening, real apse light may propagate through the portal normally. The localized cold mask should remain environmental and should not depend on whether the apse happens to be spatially near the room.

Do not use:

- a circular portal halo;
- concentric pulses;
- an objective-colored outline;
- a whole-room kind swap;
- a permanently infected patch after the breach has closed.

On closure, the inverse mask should contract over roughly two seconds, leaving a low-value scar/decal but no active motion. That distinguishes “a breach was here” from “a breach is live.”

---

# 4. Legibility and palette

## 4.1 Color lanes

Keep the lanes strongly separated in hue, value, and rendering frequency.

| Meaning | Color lane | Recommended values |
|---|---|---|
| **Otherworld environment** | low-value desaturated cyan-green | retain `OW_FLOOR = (52,64,58)`; active environmental accents around `(66,112,104)`; deepest darkness around `(5,13,14)` |
| **Surviving Testator architecture** | aged bronze, verdigris, pale bone | bronze around `(104,78,52)`; verdigris around `(55,91,82)`; inscription bone around `(184,178,151)` |
| **Organ bodies** | saturated violet/magenta, with pale-lilac critical edges | body around `(118,42,160)`; edge around `(218,158,238)`; Source hot point around `(245,218,255)` |
| **Live corrupted-Testator enemies** | high-value bone/copper target traces, never teal or violet | bone fill around `(196,186,150)`; hostile edge/event accent around `(224,92,66)` |
| **Player and player light** | neutral-white chassis plus diffuse warm amber/coral | chassis around `(232,242,244)`; light around `(255,154,112)` |
| **Residue and decals** | low-value oxblood, charcoal, muted chips | retain blood/scorch lanes; chips must remain unoutlined and visually below live bone enemies |

The precise enemy class palette can retain existing tier distinctions, but no live hostile’s primary fill should occupy the environment’s cyan-green or the organ’s violet lane.

## 4.2 Layering requirements

- Otherworld compositing applies to surfaces and environmental props, not entity traces.
- Enemy minimum pixel sizes and tier silhouettes remain unchanged.
- Organ bodies receive a minimum 1px pale-lilac edge at 0.45 so violet bodies do not vanish inside violet architectural light.
- Decals receive no minimum-size promotion and no bright outline.
- The player’s warm light is broad and low-frequency; enemy warm edges are compact body-bound events. This keeps the similar warmth from becoming ambiguous.

## 4.3 Ring discipline

The only free-standing, transient closed ring remains the aggro symbol.

Therefore:

- no floor mandala may present as a clean closed circle;
- no breach halo;
- no complete otherworld echo ring;
- no repeated seats forming a circle;
- use broken arcs, open spirals, nested polygons with deliberate gaps, and asymmetric fold contours.

The Collar’s annular organ body can remain because it is a persistent, filled/attached world object rather than an emitted glyph. It must not pulse by expanding concentric outlines.

---

# 5. Prop and breathing-wall work

## 5.1 New shallow hub vocabulary

Add a canonical `_props_marrow` generator through `_POLYGON_PROP_GENERATORS`. It should produce:

- one-off machined wall ribs with unequal spacing;
- open phyllotactic inlays;
- nested, rotated polygon fragments used as fold notation;
- bone-tone memorial inserts;
- conduits carrying the existing light direction inward;
- vacant guardian stations where the shelf has dispatched;
- role-specific organ housings in C, AN, SC, and S;
- progressively fewer embodied furnishings as `descent` rises.

The generator must be deterministic per polygon seed but should not instantiate a repeated module. Each chamber’s role and seed should produce a distinct maker’s idiom.

The Adversary layer is applied over this vocabulary rather than replacing it:

- tendrils follow old conduit runs and then depart from them;
- old inscriptions remain visible under occlusion;
- ribs are displaced or visually dissolved, not replaced by fleshy cave walls.

This preserves “a consecrated machine seized to manufacture war.”

## 5.2 Breathing walls

Static textures are not sufficient for the final pass.

Use the existing texture/composite pathway:

- apply a per-polygon, low-amplitude UV warp to adversary-touched surface fills;
- amplitude: approximately **0–2 internal pixels**, scaled by `smoothstep(0.35, 0.85, descent)`;
- use two incommensurate periods around **6–11 seconds**;
- phase each polygon from its stable detail seed;
- animate the interior stain/rib layer, not the fixed collision skeleton.

The actual wall boundary and `WALL_MIN` readability line remain stationary. The player must never think collision geometry is moving.

A fixed-camera ten-second shot should reveal breathing. A single frame should still look handcrafted rather than blurred.

Do not use a synchronized whole-room pulse or a texture translation. Those read as an effect layer sliding over the map.

---

# 6. Concrete implementation changes

## `hub.py`

Replace `_ROOMS` with authored chamber specifications:

```python
@dataclass(frozen=True, slots=True)
class ChamberSpec:
    role: str
    verts: tuple[tuple[float, float], ...]
    ports: dict[str, PortalSeat]
    kind: str
    descent: float
    protected: tuple[ProtectedEnvelope, ...]
```

Then:

- author all 24 vertex lists explicitly in y-down visual-CCW order;
- retain the same dictionary insertion order so polygon indices and seeds remain stable in shape;
- replace pair-only `_LINKS` with endpoint names;
- carve at authored host-edge positions rather than `_carve_spread`;
- leave `RESIDENT_PLACEMENT` unchanged;
- leave `HUB_LIGHT_PLAN` unchanged;
- leave `HubLayout` role assignments unchanged;
- keep apse breach seats adopted but unconnected;
- append the same renderer metadata entries—seed, kind, descent—for every new polygon.

Add build-time validation for convexity, area, winding, edge length, anchors, graph degree, hop depth, and scale-1 transforms.

## Level JSON and authoring

No `gauntlet4.json` changes are needed. The hub is initialization-authored in `hub.py`, and duplicating its data into JSON would violate the one-canonical-file rule.

If polygon kind/descent metadata currently lives in level arrays, extend those canonical arrays when each hub polygon is added. Do not create a hub-only rendering registry.

## Renderer

Required changes:

1. add `_props_marrow`;
2. make `_props_otherworld(..., descent=...)` actually use `descent`;
3. remove the evenly spaced seat ring and clean closed decorative loops;
4. let canonical prop generation layer a diminishing marrow underlay with an increasing otherworld overlay;
5. let the otherworld compose step accept `ow_mix`, rather than only a boolean mark;
6. add the low-amplitude adversary UV warp;
7. add the localized world-side breach corruption mask;
8. keep entity rendering outside the environment color transform.

## Texture pipeline

Do not generate the final 24 bespoke textures until geometry is locked. After the filmed geometry and combat gate:

- generate one unique texture per chamber;
- pass role, descent, exact silhouette, portals, light positions, and protected organ envelopes into each prompt;
- preserve Testator handcraft under the corruption;
- leave all breathing and inverse-darkness behavior as runtime treatment, not baked texture animation.

---

# 7. Landing order and filmed gates

Every geometry commit changes combat and must pass the real filmed-playtest gate. Isolated validators are necessary but not sufficient.

## Commit order

1. **Construction infrastructure**
   - `ChamberSpec`, named portal seats, convex/anchor/scale validators.
   - Initially reproduce current rectangles exactly.
   - No feature flag or alternate builder.

2. **Shallow geometry**
   - A1–A3, G1–G3, T1–T3, R, C1–C2.
   - Film all three receiving routes, shallow loop flanking, shelf dispatch, and retreat.

3. **Middle geometry**
   - N1–N4, AN1–AN2, SC.
   - Film fought retreat in both directions, side-chapel entry/exit, resident routing, and Warden/brute-sized movement.

4. **Final-commitment geometry**
   - L, V, S1–S3.
   - Film the long connector, four-door V combat, all Source approaches, and return under pressure.

5. **Corruption metadata and scalar lighting**
   - Exact depth mapping above.
   - Film a continuous apse-to-Source traversal with no cuts.

6. **Marrow and otherworld prop progression**
   - Add `_props_marrow`, implement `descent`, remove forbidden ring formations.

7. **Breathing surfaces and breach infection**
   - Land hardwired, not as an optional effect.
   - Film formation, live portal, traffic in both directions, closure, and residual scar.

8. **Final textures and palette polish**
   - Generate only against the settled shapes.
   - Run the full real-world playtest, with Sonnet checking every fifth frame.

## Required automated checks

- 24 convex polygons;
- exact old portal graph and degree sequence;
- exact old one-door chamber count;
- apse-to-Source topological depths unchanged;
- every portal transform scale 1;
- every protected anchor inside with clearance;
- every light inside;
- no resident or organ part outside;
- no body unable to route through a portal;
- band 0–2 area share remains 50–54%.

## Required film observations

At zoom 0.45 and 640×360:

- every room-role silhouette remains readable during combat;
- the hub no longer presents any full rectangular chamber;
- the guardian burst exits without geometric log-jamming;
- the first-burst roster/order is not changed by post placement;
- L remains a two-way commitment space, not a single-file tunnel;
- V supports pressure from multiple source directions;
- the player can distinguish organ, enemy, residue, and warm player light in one paused frame;
- the breach visibly infects the world-side wall before opening;
- a fixed camera shows breathing without suggesting moving collision;
- progression from built cathedral to inverse otherworld is visible without a HUD or cut.

---

# 8. Recommendation confidence ledger

## R1 — One-off convex biogenic shells

- **Bayes:** prior 2:1; `P(E|H)=0.85`, `P(E|¬H)=0.30`; posterior approximately **5.7:1, 85%**.
- **Predicts on film:** room silhouettes cease reading as boxes even without props; A, T, L, V, and S are distinguishable from their outlines at 0.45.
- **Forbids:** “rectangle with clipped corners,” repeated rotated templates, hex-cell repetition, or tiny facets invisible at gameplay zoom.
- **Strongest reason it may be wrong:** convexity may keep the silhouettes too polite; surface treatment may still carry more of the hive read than geometry.

## R2 — Authored portal palates and protected envelopes

- **Bayes:** prior 4:1; `P(E|H)=0.90`, `P(E|¬H)=0.35`; posterior approximately **10:1, 91%**.
- **Predicts on film:** 70u and 96u openings remain broad and scale-free; residents and the shelf leave cleanly despite irregular walls.
- **Forbids:** opportunistic `_carve_spread`, scale other than 1, anchors outside polygons, new one-door rooms, or a guardian delayed by doorway geometry.
- **Strongest reason it may be wrong:** existing downstream placement code may rely on rectangular bounds more heavily than `hub.py` reveals.

## R3 — Continuous scalar gradient with kind switch at depth six

- **Bayes:** prior 2:1; `P(E|H)=0.90`, `P(E|¬H)=0.20`; posterior approximately **9:1, 90%**.
- **Predicts on film:** corruption is noticeable by R/C, dominant at N3/AN2, and complete at the Sources without an obvious trigger boundary.
- **Forbids:** fully otherworld apses, an abrupt N2→N3 lighting pop, or a descent parameter that changes no pixels.
- **Strongest reason it may be wrong:** the otherworld inverse-lighting branch may not blend cleanly without exposing assumptions elsewhere in the compose pipeline.

## R4 — Localized world-side breach infection

- **Bayes:** prior 3:2; `P(E|H)=0.85`, `P(E|¬H)=0.35`; posterior approximately **3.6:1, 78%**.
- **Predicts on film:** the player sees an infected wall during the formation tell before material disappears, regardless of where the world chamber is.
- **Forbids:** a clean wall instantly becoming a portal, circular halos, whole-room swaps, or any Euclidean lookup toward the hub.
- **Strongest reason it may be wrong:** a 35–50u localized treatment may be too small to notice during a live firefight at 0.45.

## R5 — Separate environment, organ, enemy, and player color lanes

- **Bayes:** prior 3:1; `P(E|H)=0.85`, `P(E|¬H)=0.40`; posterior approximately **6.4:1, 86%**.
- **Predicts on film:** saturated violet organ parts remain identifiable against cold green-blue space; live enemies outrank residue; the warm player light reads as illumination rather than corruption.
- **Forbids:** teal enemies, violet general decals, bright chip residue, or environment post-processing applied over entity traces.
- **Strongest reason it may be wrong:** architectural violet light in the apses may still reduce organ separation in chambers where both appear together.

## R6 — Handcrafted marrow props plus low-amplitude breathing

- **Bayes:** prior 3:2; `P(E|H)=0.90`, `P(E|¬H)=0.35`; posterior approximately **3.9:1, 79%**.
- **Predicts on film:** a fixed camera reveals slow independent surface motion while the collision skeleton remains trustworthy; no two rooms share a maker’s pattern.
- **Forbids:** static final otherworld walls, synchronized pulsing, global texture sliding, repeating ribs, perfect seat rings, or baked cave flesh replacing Testator work.
- **Strongest reason it may be wrong:** motion strong enough to survive 0.45 may become visual noise during combat.

## R7 — Geometry-first staged landing with a full film gate after each gameplay change

- **Bayes:** prior 4:1; `P(E|H)=0.90`, `P(E|¬H)=0.45`; posterior approximately **8:1, 89%**.
- **Predicts on film:** failures are attributable to one depth band or renderer change, and final textures are not invalidated by later reshaping.
- **Forbids:** generating the texture fleet before geometry settles, accepting construction tests as playtest evidence, or landing all visual and combat changes in one uninterpretable commit.
- **Strongest reason it may be wrong:** intermediate canonical commits will temporarily show a mixed rectangular/faceted hub, although no runtime branch or feature flag is introduced.

The principal uncertainty is not whether the rectangles should go. It is whether convex faceting plus controlled surface motion is enough to achieve “alien hive” without drifting into a generic organic cave. The preservation of manufactured ribs, Testator fold notation, organ housings, and the existing processional light plan is what should keep that line intact.