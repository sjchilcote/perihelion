# What It Says

Deep in the TESTAMENT's spine, a remass bay rises into darkness. Two reaction-mass tanks frame it: a sphere so large the canvas cuts it off, and a drum standing on the right. Both are covered in bronze scale-plates laid in golden-angle spirals, green with verdigris where the light doesn't reach. A ring of galleries with small apertures runs along the far wall. Above them is a domed vault of overlapping plates spiralling in to one oculus. That oculus is the only light in the picture. It is warm, and the dust of ground rock hangs in its beam, which falls diagonally down to the floor of heaped rubble. Where it lands, in a small pool of gold, lies the Ark: a pale, frost-rimed, very human capsule with stencilled lettering and a faded red band. PALMER's frame kneels beside it with one hand on its shell, his back three-quarters to us. A single cold point of cyan sits inside all that warmth: the Ark's diagnostic readout, and the matching glint on his visor. The light is warm and seems almost to bless the scene, so the picture can be read as hope. The one cold mark is what the readout says, so it can just as well be read as sorrow. About 70% of the canvas is near-black bronze, which makes the figure and the box look as small as they are.

**How it was painted.** It was painted in 199 chunks on a warm, dark toned ground. I worked dark to light: first a lay-in of chromatic darks, then the tanks and vault. The scale-plates came from small helper functions, each laying one plate with a body stroke, a shadow arc and a lit edge, placed along golden-angle spirals on the vault, a Fibonacci sphere and a helix on the drum. A dark glaze of bone black, bone brown and ultramarine went over them so they sank back into the gloom. The beam is a series of thin warm veils, each one brushed and then blended along the light, and the floor is thousands of small flat-brush facets lit by their distance from the pool. The paint surprised me constantly. Anything containing lead white came out much lighter over these darks than its pile suggested. Glazes changed colour depending on what was underneath: one went orange, one olive, one grey. Blending over wet paint lifts it. The worst moment was an unclipped blend over a wet heap, which dragged brown fingers 100 units in every direction across the beam and the wall. I spent about forty chunks repairing it. Painting out the damage and rebuilding the beam's colour over it never matched, so in the end I turned the damage into a new rock heap rising into the beam, and it improved the composition. Next time I would mix every glaze on the scrap canvas first, and compare against saved pixels rather than my eye. I would never blend unclipped near wet neighbours. And I would give the frame a more articulated silhouette before it was locked in.

## Pass at 00:25 CDT, 2 Oct 2026

Replaying the log took 77 minutes, which left about ten minutes of painting before the deadline. The chunks were prepared and tested on the scrap easel while the replay ran.

**What changed** (chunks 200–206):
- **Rubble.** About a hundred faceted rocks now sit on the lit heap, in the pool and along the crest of the dark heap. Each one is a polygonal body with a cast shadow falling down-left. After a wait, the faces turned toward the oculus were cut from each rock with half-planes and laid lighter: a half-tone shoulder, the top plane and the hottest edge. The crest of the dark heap now catches the beam, so its outline breaks up into lit lumps.
- **Drum and sphere.** Using the same helix and Fibonacci geometry as the original plates, I laid dim warm rims on the plates' upper edges, stronger on the side facing the beam, and dark verdigris in the recess under each plate, gated by noise.
- **Figure.** A thinner, brighter broken rim runs along the edges that face the light, with four hot glints (crown, far pad, pack, knee).
- **Ark.** A crisp frosted ridge with rime crystals along its lit top and cap.
- **Dust.** About 110 brighter motes (zinc white) inside the beam core.

**What still falls short:**
- The beam-edge softening (a graded veil and a seam blend, `p2/m1.lua`) was never run, because of its slow blends, so the beam's edges are as they were.
- The sphere's new rims spread evenly over its whole dark face. It now reads busier and a little lighter than intended, and should be glazed back down away from the beam side.
- Some lit rocks on the dark heap's left flank sit lower than the beam logic strictly allows.
- The rocks in the pool are a touch too uniform in size.

The chunk sources are in /tmp/cp/ark/p2/.

**Director's decision (00:30):** the 23:00 pass was rejected. The tank sphere
became a busy field of even rings, and the gold pool around the Ark broke into
scattered rocks and lost its glow. The canonical painting stays v1, the first
199 chunks of the log; the pass is kept as `pass_2300_rejected.png`.
