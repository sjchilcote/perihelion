# ENGINE_INVARIANTS.md

Complete enumeration of PERIHELION's engine/game invariants, per the director's
directive: "break the engine down into a complete list of invariants and
PBT-enforce all of them." Source law: `ENGINE_DESIGN.md`, `design_document_2.md`
§11. Method: walked every module in `engine/necore/src`, `game/perihelion`, and
their test suites; derived what each function/module promises, not just what
it's already tested for.

**Lane exclusion note**: `game/perihelion/render.py`'s darkness/root-swap
lighting path and `game/tests/test_root_invariance.py` are owned by an
in-flight sibling fix. Both are cataloged by name/existence only (invariant
#R1 below) — not edited, not graded in depth, not touched by wave 1 here.

**Columns**: Statement (one testable sentence) · Scope · Enforcement (exact
test name(s) or NONE) · Strategy grade (A = adversarial/heterogeneous,
B = some variety but missing degenerate cases, C = tame/fixed cases only,
N/A = no test) · Priority (P0 = player-visible or state-corrupting,
P1 = subtle/latent, P2 = hygiene).

---

## 1. Math (`engine/necore/src/math.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| M1 | `Mat3::inverse` is a true two-sided inverse: `M·M⁻¹ = I`. | engine-rust | `math::tests::inverse_roundtrip` | C (one fixed matrix) | P1 |
| M2 | `perp_right()` is the inward-normal convention for a y-down visually-CCW polygon. | engine-rust | `math::tests::perp_right_is_inward_for_visual_ccw` | C (one axis-aligned square) | P2 |
| M3 | `apply` is a true projective transform (divides by homogeneous w); `apply_dir` applies only the linear part (no translation/perspective) — correct for direction/velocity transport. | engine-rust | NONE direct | N/A | P1 |
| M4 | `mul` is associative; `IDENTITY` is a two-sided identity for `mul`. | engine-rust | NONE direct (only indirectly via portal round-trip products) | N/A | P2 |
| M5 | `normalized()` has a defined fallback `(1,0)` for near-zero-length vectors, never NaN. **This fallback is the documented root cause of THE FLICKER** (see geom.rs `DEGENERATE_EDGE` comment) — untested at the source, only guarded against transitively. | engine-rust | NONE | N/A | **P0** |
| M6 | `linear_scale()` returns a nonnegative uniform-ish scale (`sqrt(|det|)` of the linear part). | engine-rust | NONE | N/A | P2 |

## 2. Geometry (`engine/necore/src/geom.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| G1 | `signed_area` negative for canonical polygons; `canonicalize_winding` reverses iff area > 0 and is idempotent. | engine-rust | `geom::tests::canonical_square_checks` | C | P2 |
| G2 | `is_convex`: n≥3, every consecutive edge-triple cross ≤ 1e-9 (canonical winding); collinear tolerated. | engine-rust | `properties::hull_strategy_produces_valid_convex_polygons` (accept side only, via `add_polygon`) | B | P1 |
| G3 | `centroid` = shoelace-weighted area centroid, with vertex-average fallback when `|area| < 1e-12`. Fallback branch never exercised. | engine-rust | `geom::tests::canonical_square_checks` (non-degenerate case only) | C | P1 |
| G4 | `DEGENERATE_EDGE` (1e-9): every half-plane builder (`clip_polygon_convex`, `polygon_halfplanes`, `point_in_polygon`, `depth_in_polygon`) skips sub-threshold edges rather than fabricating a phantom half-plane from `normalized()`'s `(1,0)` fallback. **THE FLICKER's fix.** | engine-rust | `geom::tests::duplicate_clip_vertex_is_inert` | A (dup at every position + wrap-seam, but fixed axis-aligned square only) | **P0** (extend to arbitrary polygons) |
| G5 | `clip_polygon_halfplane` (Sutherland-Hodgman): preserves winding, output ⊆ half-plane, never expands. | engine-rust | `geom::tests::clip_square_by_halfplane` | C | P1 |
| G6 | `clip_polygon_convex(subject, clip)`: result ⊆ subject ∩ clip; empty (not garbage) when disjoint. | engine-rust | `geom::tests::clip_convex_by_convex`; backstopped by `properties::visibility_soundness` | B | P1 |
| G7 | `clip_segment`: `None` iff fully outside; else exact parametric sub-range, handling near-parallel (`dd≈0`) case. | engine-rust | `geom::tests::segment_clip` | C | P1 |
| G8 | `point_in_polygon(p,pts,eps)`: true iff within `eps` of the inward side of every non-degenerate edge. | engine-rust | `canonical_square_checks` + `duplicate_clip_vertex_is_inert` | B | P1 |
| G9 | `depth_in_polygon`: min signed inward distance is a valid inside-measure; callers treat `depth ≥ -1e-6` as inside. | engine-rust | used as oracle by physics tests; not independently verified beyond one square | B | P1 |
| G10 | `polygon_bbox`: tight AABB (`lo ≤ p ≤ hi` componentwise for all p). | engine-rust | NONE | N/A | P2 |
| G11 | `clip_polyline_convex`/`_halfplanes`: splits at clip boundaries, merges reconnecting segments (dist < 1e-9), no spurious breaks. | engine-rust | tail of `duplicate_clip_vertex_is_inert` | C | P1 |

## 3. World / portal algebra (`engine/necore/src/world.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| W1 | `add_polygon`: re-centers on centroid, rejects <3 verts / non-convex / any edge < 1e-9. Centroid-at-origin postcondition itself unchecked; the three `Err` variants have zero tests. | engine-rust | `properties::hull_strategy_produces_valid_convex_polygons` (accept path only) | C | **P0** (error paths untested — a silently-accepted bad polygon corrupts the whole world) |
| W2 | `connect(a,ea,b,eb)`: mutually-inverse transforms, orientation-flipped endpoint correspondence (t→1−t), scales by `la/lb` on length mismatch. | engine-rust | `world::tests::connect_produces_mutually_inverse_flush_transforms` + `properties::connect_invariants` (proptest, heterogeneous hulls + random edges) | A | P1 |
| W3 | Mirror self-connection (`a==ea==b==eb`) is an involution: `xform·xform = I`. | engine-rust | `world::tests::mirror_self_connection` + `properties::mirror_involution` (proptest) | A | P1 |
| W4 | `connect_with_xform`/`install_portal` reject non-invertible transforms (`NotInvertible`) and already-occupied edges (`EdgeOccupied`). The general/arbitrary-transform entry point's core safety contract is **completely untested**. | engine-rust | NONE | N/A | **P0** |
| W5 | `rebuild_portal_pair` recomputes the map from current endpoints, preserving handedness; the `det<0` (mirror/reflection) branch is never exercised anywhere. | engine-rust | `soft_walls::portal_transform_stays_exact_under_deformation` (det≥0 branch only) | B | P1 |
| W6 | `split_edge`: 3 collinear sub-edges at t0<t1, total length preserved, every OTHER portal referencing a later edge is remapped (+2), including cross-polygon and same-polygon double-split cases. | engine-rust / game (sim.py hole feature) | `world::tests::split_edge_inserts_doorway_and_remaps_portals` (Rust, fixed case); `test_hole_tau.py::test_portable_hole_links_two_walls` (game, same-polygon double-split path) | B | P1 |
| W7 | `disconnect` removes both sides symmetrically (except true self-mirror) and bumps `topology_version`. | engine-rust | NONE — `disconnect` is never called by any test | N/A | P1 |
| W8 | `topology_version` monotonically bumps on every structural mutation and is consumed by `query::Router` to invalidate cached routing tables. **Classic stale-cache bug shape; zero coverage of the invalidation actually firing.** | engine-rust | NONE — `router_finds_paths_through_chains` never mutates topology after building the router | N/A | **P0** |

## 4. Visibility (`engine/necore/src/visibility.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| V1 | `dedup_key` is camera-independent (polygon, entry edge, quantized portal-chain-relative xform + segment) — a genuine traversal cycle collides with an ancestor key and terminates recursion regardless of camera pose. | engine-rust | `mirror_polygon_terminates`, `infinite_corridor_self_loop_terminates_and_repeats` (topology-adversarial, but no test sweeps the camera itself) | B | P1 |
| V2 | Dedup collision skips recursion but still **emits** the instance (dropping the emit would pop wedges across frames). | renderer | `invariants::visibility_coverage_is_continuous_across_doorway_sweeps` (general continuity backstop; no test isolates the dedup-collision-still-emits sub-case) | A (general) / N/A (specific) | P1 |
| V3 | `clip_local` output has no consecutive duplicate vertices, including the wrap pair — the canonical output contract. | renderer | `invariants::visibility_coverage_is_continuous_across_doorway_sweeps` | A | P1 |
| V4 | Off-screen/degenerate-area culling only drops subtrees with bbox fully off-screen or signed area < 1e-6 — never a soft/relative threshold (no pop). | renderer | general backstop only, same sweep test | B | P1 |
| V5 | `Frustum::half_planes`: collinear apex degenerates gracefully to the single portal half-plane; `wide` (180°) fan requires apex near the finite **segment**, not just the infinite line. **The commit-2f4fa94 regression class** (also see V-new below, director-reported this session). | renderer | `doorway_apex_sees_whole_neighbor`, `wide_fan_requires_apex_near_segment` (real production-bug-derived regression) | A (fixed topology only) | P1 |
| V6 | Painter's order: `visible_set` sorted deepest-first, stable among equal depths. | renderer | `corridor_of_polygons_renders_neighbors` (two depths only; stability among equal depths untested) | C | P1 |
| V7 | Result soundness: every instance's `clip_local` is convex, ⊆ its polygon, ⊆ its frustum half-planes. | renderer | `properties::visibility_soundness` (proptest, but only axis-aligned pure-translation grid) | B | P1 |
| V8 | `max_depth`/`max_instances` bound traversal (never exceeded) while still producing nonempty coverage under pathological topology. | renderer | `mirror_polygon_terminates`, `infinite_corridor_self_loop_terminates_and_repeats` | A | P1 |
| V9 | **Deep-chain apex-grazing-unrelated-edge false-wide-fan** — commit 2f4fa94 (this session, director-reported via campaign video, mpv-shot0019-22): a discontinuous coverage spike (1px sliver → 142px quad in one tick) from the apex's perpendicular distance to a portal edge's infinite line being checked without confirming proximity to the finite segment, at deep (depth-3) chain instances. | renderer | fixed by commit 2f4fa94; regression test presumably added alongside — **verify it is proptest/adversarial, not just the one captured tick**, since this is exactly the "root-invariance PBT was homogeneous" lesson repeating one level down (deep chains, off-axis apex, non-uniform topology). | needs re-grading after that commit lands fully | **P0** |

## 5. Physics/sim (`engine/necore/src/physics.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| P1 | Containment: after `step_entity`, entity center is inside its polygon polygon (+ε), regardless of which sub-path fired. **The anti-tunneling invariant.** | engine-rust / sim (backstop) | `physics::tests::wall_slide_keeps_entity_inside`, `properties::containment_after_impulses` (proptest), `invariants::containment_holds_under_random_walks_through_corners` (4000-step deterministic corner-seeking stress); game-layer backstop `sim.py::_containment_sweep`, `game/tests/test_containment.py` | A | P1 (already best-covered) |
| P2 | Wall reflection: `rest_wall=0` fully absorbs normal component, preserves tangential exactly; general `rest_wall` scales reflected normal by `(1+rest)`. | engine-rust | `wall_slide_keeps_entity_inside` (tangential only), `fast_bullet_does_not_tunnel_through_wall` (sign only) | C | P1 |
| P3 | Anti-tunneling: no substep advances past `max_substep` (earliest-crossing check). | engine-rust | `fast_bullet_does_not_tunnel_through_wall` (one fixed extreme case) | B | P1 |
| P4 | Iteration cap (`MAX_ITERS=512`) / stall breaker (`MAX_STALLS=8`) guarantee `step_entity` terminates (never hangs) in a corner trap, zeroing velocity rather than resolving further. **Load-bearing safety valve, zero direct coverage of it actually tripping.** | engine-rust | NONE | N/A | **P0** |
| P5 | Portal transfer: position via full affine `inv.apply`, velocity/facing via linear-only `inv.apply_dir` (renormalized), `TRANSFER_NUDGE` (1e-3) push into target interior; a "shoved-outside" entity is still deposited inside via two-pass half-plane clamp. | engine-rust | `transfer_from_shoved_outside_position_lands_inside_target`, `portal_transfer_preserves_motion_and_roundtrips`, `properties::transfer_roundtrip` (proptest, sub-microsecond crossing precision) — all on identical/simple-rotation squares; **no scaling portal (`la≠lb`) case for transfer specifically.** | A (topology) / gap on scale | P1 |
| P6 | Entity-entity collision: momentum-conserving, KE non-increasing for `rest_ent≤1`, inverse-mass positional split. | engine-rust | `entity_collision_conserves_energy_bound`, `properties::energy_never_increases` (proptest) | A | P1 |
| P7 | Non-transferring entities (`transfers=false`) treat portals as walls even when geometrically fitting. | engine-rust | `non_transferring_entity_treats_portal_as_open_but_stays` (one fixed case) | C | P2 |
| P8 | `fits` gate: `2·radius ≤ edge_len·1.05` — oversized entities are walled off from an otherwise-open portal edge. | engine-rust / game | formula asserted directly in game's `test_hole_tau.py::test_hole_corridor_excludes_brutes_admits_mites` (A, exact numeric boundary vs real enemy radius table); **no direct engine-level physics test spawns an oversized entity against a too-narrow portal and checks the wall-off behavior end to end.** | B | P1 |
| P9 | Euclidean-oracle correctness: on a rigid pure-translation grid, world-frame raycasts and elastic bounces agree with an independent flat-Euclidean simulation to a mechanism-derived tolerance. | engine-rust | `properties::euclidean_raycast_oracle`, `euclidean_physics_oracle` (proptest, full angle sweep; surfaced a real minor engine bug in raycast distance accounting, documented not silently loosened) | A | P1 |

## 6. Queries (`engine/necore/src/query.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| Q1 | `raycast` composes accumulated transform across hops correctly (position via full apply, direction via linear-only, renormalized). | engine-rust | fixed unit tests + `euclidean_raycast_oracle` (A via oracle) | A (oracle) | P1 |
| Q2 | Raycast's portal-opening span check uses the exact edge span; physics's wall-collision span extends by `EDGE_SPAN_EXT=1.0`. **Documented, load-bearing divergence between the two systems — "can I shoot through a gap I can't walk through" — zero cross-system consistency test.** | engine-rust | NONE | N/A | P1 |
| Q3 | `Router::next_edge`/`hop_distance`: BFS-shortest-hop routing, self-route trivial, cache keyed and invalidated by `topology_version` (see W8). | engine-rust | `router_finds_paths_through_chains` (linear chain only; no branching graph, no cycle, **no topology mutation after router built**) | C | **P0** (cache-invalidation half; ties to W8) |
| Q4 | `polygons_within`/BFS frontier always includes center, never double-visits. Same pattern used untested in `Sim::set_active_within`. | engine-rust | NONE | N/A | P1 |

## 7. Soft polygons / Otherworld (`engine/necore/src/soft.rs`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| S1 | Convexity preservation: every deformation update is projected so no soft-polygon polygon ever goes reflex. | engine-rust | `soft_walls::convexity_holds_under_bombardment` (240-step randomized bombardment, checked every step) | A | P1 |
| S2 | Rest-length restoration: damped spring dynamics return edge lengths near rest after an impulse; equilibria are not degenerate (shape/position may differ). | engine-rust | `impulse_deforms_then_lengths_restore`, `hard_hit_reaches_a_new_stable_shape` | B (fixed shape/impulse only) | P2 |
| S3 | Portal quotient reconciliation: shared soft-portal endpoints are averaged into agreement every step; portal transform is rebuilt (`rebuild_portal_pair`) to stay exact under deformation. | engine-rust | `wave_crosses_the_portal`, `portal_transform_stays_exact_under_deformation` (300 steps) | B (2-polygon fixed topology; soft/rigid mixed pairing and >2-polygon untested) | P1 |
| S4 | `on_split`: soft-state arrays (`vel`, `rest_len`) are realigned correctly when a soft polygon's edge is `split_edge`'d at runtime — velocity averaged, rest-length split proportionally. **Zero coverage; exactly the kind of array-shape-realignment code that silently corrupts on the untested path.** | engine-rust | NONE | N/A | **P0** |
| S5 | `wall_impulse` no-ops on non-soft polygons (never panics). | engine-rust | NONE | N/A | P2 |

## R. Renderer (`game/perihelion/render.py`) — non-darkness parts

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| R1 | Root-frame invariance including lighting (re-rooting the portal-chain anchor has zero pixel consequence). **Owned by in-flight sibling fix.** | renderer | `game/tests/test_root_invariance.py` (exists; not graded here) | — (in-flight) | — |
| R2 | Backend selection precedence: explicit arg > env var > default; explicit `"rust"` request without `necore.Raster` fails loudly; unknown backend name fails loudly. | renderer | `test_render_backends.py::test_backend_selection` | A | P1 |
| R3 | Backend byte-parity: rust-raster and pygame backends produce bit-identical frames for the same scene/tick, including the otherworld darkness-compositing divergent path. | renderer | `test_backends_render_identical_frames`, `test_backends_identical_through_otherworld` (A, exact byte compare, real combat); `test_rust_backend_survives_surface_resize` (B); `tools/playtest/parity.py` (statistical, 4 heterogeneous real-campaign fixtures incl. tesseract deep-recursion + mirror-polygon — **not wired into pytest/CI, so not an enforced gate**) | A (pytest) / A-but-unenforced (parity.py) | P1 |
| R4 | Bespoke floor-texture rendering matches across backends and correctly receives the darkness field (formula-agnostic monotonicity, not hard-coded LUT values). | renderer | `test_textured_floor_matches_across_backends`, `test_textured_floor_differs_from_untextured_fallback`, `test_darkness_applies_to_textured_pixels` | A | P1 |
| R5 | Texture-clip containment: floor-texture sampling never bleeds outside a polygon's screen-space clip polygon. | renderer | only as a side effect of parity tests — no standalone containment-targeted test | B | P1 |
| R6 | Seam-freeness at portals: fully-on-screen wall segments are geometrically continuous frame-to-frame (same line, overlapping span, ≤6px), across ordinary corridors, self-loop/mirror portals, and doorway-split sub-edges. | renderer | `test_seamless.py` (5 scenarios: corridor, infinite self-loop, doorway wobble, mirror approach, brightness-continuity — A/A/A/A/B; strong self-adjacent+mirror+split coverage, **no heterogeneous polygon-kind/palette mix, no >5-hop chain**) | A (topology) | P1 |
| R7 | Flicker gate: a neighbor polygon's decal ink never collapses tick-to-tick under player motion — pixel-truth, not existence-only. | renderer | `test_flicker_harness.py::test_neighbor_decor_never_blinks[cross]`/`[braided]` (A, parametrized adversarial topologies, root-caused from a real captured regression tick); `tools/playtest/flicker_cross.py`'s 7×7 grid world exceeding `max_instances=96` is the single most adversarial topology cataloged but is **CLI-only, not a pytest gate** | A (pytest, 2 topologies) / gap (grid-cap topology unenforced) | P1 |
| R8 | Prop placement stays on real wall segments, excludes portal/doorway edges. | renderer | none dedicated; only incidental via parity-test scene content | C | P2 |

## X. Texture streaming & the texel law

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| X1 | The texel law: texel (tx,ty) ↔ polygon-local point via a single `DENSITY=3.0` constant shared by construction between the Rust raster and the Python generation tool; `texture_size_for_polygon` always fully covers the bbox via `ceil`. | game/renderer | `test_texture_size_helper_matches_polygon_bbox` (one fixed size) | B | P1 |
| X2 | Lazy chunk streaming: chunk k+1's polygons are appended into the live `Sim` only on entering chunk k's transit spine; append-only (no unload — "idempotence" is vacuous by construction, guarded by `loaded_next`). | sim/stream | `test_stream_lazy_load_arrival_and_completion` (single scripted 3-chunk traversal) | B | P1 |
| X3 | `polygon_texture_key(polygon)` is stable for the session life (chunks never renumber, only append); transit-spine polygons resolve to `None`. **No test for stability across a multi-chunk streamed session specifically — only a single-level session.** | stream | NONE (in scope) | N/A | P1 |
| X4 | Descent-gradient continuity: index gaps padded with last-known value; spine polygons get the midpoint of adjoining chunks so the palette gradient crosses inside the corridor, never steps at a doorway. | stream | NONE — asserted only by comment | N/A | P2 |
| X5 | Chunk-entry seed-station idempotence: `add_station` dedupes so a chunk-entry re-add of an already-printed-from station is a no-op. | sim/stream | NONE explicit | N/A | P1 |

## SIM. Simulation invariants (`game/perihelion/sim.py`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| SIM1 | Tick determinism: same level+seed+input sequence ⇒ bit-identical run (event/ammo/hp timelines, metrics). | sim | `test_two_identical_aggro_runs_are_bit_identical`, `test_explorer_bot_run_is_deterministic` (7200-tick real combat/AI/RNG) | A | P1 |
| SIM2 | Replay round-trip identity, including gzip save/load. | sim/persistence | `test_replay_record_play_roundtrip_identical_final_state`, `test_replay_save_load_gzip_roundtrip` | B (fixed seed/bot, no property sweep) | P1 |
| SIM3 | `_containment_sweep`: python-side backstop recovers only entities continuously outside their polygon for ≥6 sweeps (3s) — **the soak-test lesson**: recovering transient door-crush escapes destabilizes the finale (54/985 soak runs wedged by recovery churn vs 1/1894 baseline, per in-code comment); recovery target must use live verts, not the stale authored-frame `polygon_centroids` (a real regression this fixed). | sim | `test_escaped_enemy_is_recovered`, `test_normal_play_never_triggers_recovery` (one fixed level/seed each — **no hypothesis sweep reproducing the actual soak-discovered failure mode**) | B | **P0** (soak lesson explicitly says spot-check seeds pass while scale finds 5%-class failures — this is exactly that class, still spot-check-only) |
| SIM4 | NaN propagation: no explicit guard found anywhere in the Python game layer; if it exists at all it lives entirely in necore (Rust) f64 arithmetic. | sim/engine | NONE in Python; unverified in Rust either (see M5, G4 territory) | N/A | P1 |
| SIM5 | Portal entity transfer (game-layer view): polygon changes, velocity magnitude preserved, `"transfer"` event reported with correct fields. | sim | `test_transfer_preserves_speed_and_changes_polygon` (one straight-line spawn, one portal, no rotated/`connect_with_xform` case) | B | P1 |
| SIM6 | Zone-boundary key clearing: crossing into a new streamed chunk voids all non-diegetic held keys, objective line fires once. | sim/stream | `test_stream_lazy_load_arrival_and_completion` | B | P2 |
| SIM7 | Death/respawn economy: `_drop_corpse` either zeros components into a corpse pickup or (protected-revival unlock) preserves them live and drops only station kits — **conservation (no loss, no duplication) is asserted only in prose comments, never by a test that kills-with-loot then retrieves and sums.** | sim | `test_stream_respawn_at_chunk_entry` (hp floor + enemy reseed only — does not touch the loot-conservation claim at all) | C | **P0** (state/economy corruption risk, player-visible, literally untested) |
| SIM8 | Think-state (mind-map focus/progress/done) deliberately survives death/respawn — session-scope, excluded from `_restore_state`. | sim/stream | not covered by the files audited here (exists elsewhere per catalog, out of this pass's scope) | not gradable | P2 |
| SIM9 | `GameSession.snapshot()` is a read-only projection (bots/HUD), distinct from the actual save-file persistence path (`WorldStreamer._snapshot_state` → `app.py` json.dump); hp/ammo floors on chunk-entry are load-bearing balance numbers derived from an undocumented-in-tests soak run (seed 2175, 9 rounds, died 400+ times). | sim/persistence | NONE for the save.json round-trip itself | C | P1 |

## L. Level schema (`game/perihelion/levels.py`)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| L1 | Canonical winding: authored polygons must have `shoelace ≤ 0`; a positive-shoelace polygon raises `ValueError` at load — **not silently rewound**, because rewinding would desync authored connection edge indices. **The reject path has zero test coverage.** | levels | NONE for the reject path (only correct-construction via `LevelBuilder` covered) | N/A | **P0** (a silently-accepted bad winding would corrupt every connection index in that polygon) |
| L2 | Doors are pending/unconnected until unlocked — genuinely opaque/solid, not a visual-only lock. | levels/sim | `test_level_structure` proves reachability once force-opened; pre-open opacity/solidity itself not directly asserted | B | P1 |
| L3 | Key-before-door reachability: every door's key is obtainable without passing through that door. | levels | `test_keys_reachable_before_their_doors`, parametrized over every shipped campaign level | A | P1 |
| L4 | Full-graph reachability with all doors open. | levels | `test_level_structure`, parametrized over every shipped level | A | P1 |
| L5 | Every shipped key/door has diegetic metadata (`item_name` ⊆ `gate_prompt`, `acquire_prompt` prefix). | levels | `test_...` parametrized over every shipped level, exact substring/prefix assertions | A | P2 |
| L6 | `KeyMeta` round-trips through save/load verbatim. | levels/persistence | `test_key_meta_round_trips_through_save_and_load` (one key, one polygon, fixed) | B | P1 |
| L7 | Doorway splitter: a shorter opposite-facing collinear edge fully inside a longer wall always gets an exact matching sub-edge inserted before autoconnect. | levels | `test_doorway_splitter_makes_doorways` (single fixed geometry; no multi-doorway-per-wall, no near-degenerate opposite edge) | B | P1 |
| L8 | `no_connect` suppresses autoconnect even for exactly-coincident edges. | levels | `test_no_connect_keeps_walls_solid` | B | P2 |
| L9 | Campaign manifest structural gate: `campaign.json` exists, lists exactly 10 levels. | levels | `test_campaign_exists_and_generator_runs` | C (brittle hard-coded count) | P2 |

## H. Portable hole / runtime wall-splitting (game feature on top of W6)

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| H1 | Fit rule: `HOLE_WIDTH=15.0` admits player (13.0≤15.75) and mites (8.0≤15.75), excludes brutes (27.0>15.75) — physics, not AI special-casing. | sim | `test_hole_corridor_excludes_brutes_admits_mites` (exact numeric check vs real enemy table) | A | P2 |
| H2 | Two-mark hole linking splits both walls, inserts a corridor polygon, remaps all `(polygon,edge)` bookkeeping including the same-polygon-double-split edge-index-shift case, and is traversable both directions. | sim | `test_portable_hole_links_two_walls` (exercises the trickiest same-polygon-double-split path directly) | A | P1 |
| H3 | Cloister (safe-polygon) hole-attach rotates correctly and rejects marks inside the sanctum/corridor. | sim | NONE in `test_hole_tau.py` | N/A | P1 |

---

## Phase 2 — Gap matrix and wave plan

**Wave 1 = all P0 gaps, plus any P0-adjacent item graded C.** Selected for
implementation this pass (see Phase 3), in priority order by risk × current
coverage:

| Wave-1 item | Invariant(s) | Why P0 |
|---|---|---|
| W1-A | M5 + G4 (extended) | Root cause of a real, shipped flicker bug; only tested on one fixed axis-aligned square, never on arbitrary polygon shapes/duplicate counts/positions. |
| W1-B | P4 (iteration/stall cap) | Zero coverage of the corner-trap safety valve actually tripping; a silent regression here reads as a hang or a tunnel, both player-visible. |
| W1-C | W4 (`connect_with_xform` invertibility contract) | The general/arbitrary-transform entry point's core safety contract (reject singular, install correct inverse otherwise) is completely untested; this is the entry point used for scaling corridors and chirality flips per ENGINE_DESIGN.md §2.2. |
| W1-D | W8 + Q3 (topology_version → Router cache invalidation) | Classic stale-cache bug shape. `split_edge` (the portable-hole feature) mutates topology at runtime; if the Router cache doesn't invalidate, AI routing silently goes stale mid-game. |
| W1-E | S4 (`soft::on_split`) | Nontrivial array-realignment code, zero coverage, silently corrupts on the untested path if soft polygons are ever split at runtime. |
| W1-F | SIM7 (corpse loot conservation) | Player-visible economy corruption (duplicated or vanished components), asserted only in prose comments today. |
| W1-G | L1 (winding-violation reject path) | A silently-accepted malformed polygon desyncs every authored connection index in it — a whole-level corruption class with zero coverage of the guard that's supposed to prevent it. |

Deferred to a later wave (documented here, not implemented this pass — time
budget is ~90s added to `check.sh`):
- V9's post-2f4fa94 regression coverage needs re-grading once that fix is
  fully landed with its own test (owned by this session's other work, not
  duplicated here).
- Q2 (raycast-vs-physics doorway span asymmetry cross-check) — deliberate,
  documented divergence; worth a consistency test but not state-corrupting.
- X3 (streamed texture-key stability across multi-chunk sessions).
- H3 (cloister hole-attach rejection).
- P8 direct physics-level `fits`-gate test (currently only asserted via the
  game-layer numeric-formula check in `test_hole_tau.py`).

---

## Phase 3/4 — wave 1 implemented, open violations found

Seven wave-1 properties implemented (5 Rust, 2 Python), each fail-first
verified against a deliberately-broken/mutated variant, mutation reverted
before commit. Full details and exact test names/locations in the final
report; summarized here for the record:

- **M5 / G4 (extended)** — `math::tests::normalized_fallback_is_unit_and_never_nan`,
  `properties::degenerate_edge_injection_is_inert_under_arbitrary_polygons`.
  Both fail-first confirmed load-bearing. The G4 test's own first draft
  had a real bug (winding not canonicalized before feeding
  `clip_polygon_convex`) — caught and fixed before it could give a false
  pass; documented as a lesson, not a product bug.
- **W4** — `properties::connect_with_xform_rejects_singular_or_installs_true_inverse`.
  Fail-first confirmed load-bearing (discovered `connect_with_xform` has
  the invertibility guard duplicated at two call sites — the outer
  function AND `install_portal` — so both had to be removed together to
  observe the failure; harmless redundancy, not a bug).
- **W8 / Q3** — `query::tests::router_cache_invalidates_on_topology_change`.
  Fail-first confirmed load-bearing.
- **P4** — `properties::corner_trap_safety_valve_preserves_containment`.
  **Negative result, reported honestly**: two rounds of fail-first
  (disabling `MAX_ITERS`/`MAX_STALLS` entirely, across increasingly acute
  wedge geometry) never tripped a failure for single-entity elastic
  bounces — this engine's per-substep resolution always makes forward
  progress for that scenario class. The test itself is a genuine new
  containment property for sharp-angle polygons (a real gap the existing
  `min_edge_len>=5` strategy excluded), but **P4's specific mechanism
  remains unverified instrumentation** — open item, not closed.
- **S4 — REAL OPEN VIOLATION FOUND**: `soft_walls::on_split_array_length_tracks_world_split_edge`.
  `world::split_edge` inserts TWO new vertices per call (three collinear
  sub-edges from one wall). `SoftSystem::on_split`'s own doc comment
  describes a ONE-vertex split ("edge, edge+1 are the halves") and its
  body performs exactly one `Vec::insert` on `vel`/`rest_len`. Confirmed:
  after a real `split_edge` + `on_split` call, the soft-state arrays are
  short by one entry relative to the polygon's vertex count. **Not
  crash-class** — `SoftSystem::step` has its own defensive length-mismatch
  check that re-softens (silently drops in-flight velocity/rest-length
  state) rather than indexing out of bounds. **Not currently
  player-reachable** — the game layer never calls `split_edge` on a soft
  (Otherworld) polygon (only rigid polygons get the portable-hole treatment
  today, per the game-layer catalog's H1-H3 audit). Left unfixed per
  scope (this pass is PBT-enforcement, not feature engineering); flagged
  here as the one genuine latent bug this directive's fail-first
  methodology surfaced.
- **SIM7** — `test_corpse_economy.py`'s three tests. Fail-first confirmed
  load-bearing on the round-trip test (retrieval accumulation).
- **L1** — `test_level_winding.py`'s three tests. Fail-first confirmed
  load-bearing on both the single-polygon and multi-polygon-position variants.

## Deferred wave-1-adjacent items (not implemented this pass)

Time-budgeted out per the ~90s check.sh runtime ceiling and this pass's
scope (PBT enforcement, not feature work): V9 re-grading after commit
2f4fa94 fully lands, Q2 (raycast-vs-physics span cross-check), X3
(streamed texture-key stability), H3 (cloister hole-attach rejection),
P8 (direct physics-level `fits`-gate test). These remain P0/P1 in the
gap matrix above for a future wave.

---

## T. Walk-mask terrain (director's directive, 2026-07-13)

Painted-in polygon terrain (equipment, troughs, machinery) blocks movement and
shots exactly like a wall, but never affects vision/visibility — see
`ENGINE_DESIGN.md` "Walk-mask terrain" for the format and the light-occlusion
interface contract. Engine: `engine/necore/src/geom.rs` (`Rect`,
`swept_circle_vs_rect`), `physics.rs` (`Sim::step_entity`'s terrain branch,
`push_out_of_terrain`, `terrain_blocks`/`set_terrain_block`), `query.rs`
(`terrain_avoid_dir`, `terrain_light_segments`). Game: `game/perihelion/
terrain.py` (PNG decode + rect extraction), `sim.py` (`GameSession.__init__`/
`append_chunk` load masks; `_enemy_ai` steers through `terrain_avoid_dir`).

| # | Statement | Scope | Enforcement | Grade | Pri |
|---|---|---|---|---|---|
| T1 | Terrain blocks entity movement exactly like a wall: swept-circle-vs-rect per substep, slide (project out the normal component) not stick, never tunnels even at bullet speed. | engine-rust | `physics::tests::entity_head_on_into_terrain_stops_short_never_tunnels`, `fast_bullet_does_not_tunnel_through_terrain`, `entity_slides_along_terrain_and_reaches_far_side`/`terrain_avoid_dir_steering_reaches_far_side`, `geom::tests::swept_circle_vs_rect_*` (4 cases: every approach side, fast diagonal non-tunneling, clean miss, already-embedded) | A | P0 |
| T2 | Projectiles are blocked by terrain by default (terrain is opaque solid equipment); a per-group flag (`set_terrain_block`) can exempt a group, off by default for none. | engine-rust | `physics::tests::terrain_blocks_projectiles_by_default`, `set_terrain_block_false_lets_a_group_pass_through` | A | P1 |
| T3 | Terrain collision is polygon-local, so re-rooting (which polygon the game's camera-transform chain currently anchors at) has zero effect on collision outcomes — the engine has no "root" concept at all; the only way one could leak in is if collision consulted anything beyond the entity's current polygon-local state, and it doesn't. | engine-rust | `properties::terrain_collision_after_portal_crossing_matches_native_local_simulation` (proptest, 48 cases, randomized edge pairs; fail-first confirmed load-bearing by omitting terrain from the "native" path and observing the divergence assert fire) | A | **P0** (explicit directive item) |
| T4 | Absence of a walk-mask (no `set_polygon_terrain` call, or no `<texture>_walkmask.png` on disk) means fully walkable — no terrain is ever fabricated. | engine-rust / game | `physics::tests::empty_terrain_mask_is_fully_walkable`, `test_walk_mask_terrain.py::test_absence_of_mask_file_means_fully_walkable`, `test_level_with_no_level_id_never_touches_disk` | A | P1 |
| T5 | Defense-in-depth: an entity whose center ends a tick embedded in terrain anyway (portal transfer, hot-loaded mask, mid-overlap radius change) is pushed out along the shallowest axis, unconditionally, same pattern as polygon-wall containment. | engine-rust | `physics::tests::spawn_embedded_in_terrain_is_pushed_out_not_left_tunneled` | B (one fixed embedding case) | P1 |
| T6 | Bot pathing routes around terrain instead of grinding forever against it: `query::terrain_avoid_dir` steers a desired heading around the nearest blocking rect on a deterministic side, wired into `sim.py`'s `_enemy_ai` (both in-polygon hunting and polygon-graph pursuit legs). Physics-level slide alone is **insufficient** for this — a straight seek at a target directly behind a flat terrain face generates zero tangential velocity and deadlocks. | engine-rust / sim | `physics::tests::naive_seek_deadlocks_head_on_against_terrain` (documents the deadlock, fail-first discovered while writing this wave), `terrain_avoid_dir_steering_reaches_far_side` (the fix), `query::tests::terrain_avoid_dir_passes_through_when_the_path_is_clear`, `terrain_avoid_dir_deflects_and_is_deterministic_for_a_static_scene` | B (deadlock scenario + clear-path + deterministic-tiebreak cases; no proptest sweep over rect/target geometry) | P1 |
| T7 | Light-occlusion query INTERFACE: `query::terrain_light_segments`/`Sim.terrain_light_segments` exposes terrain edges as polygon-local segments, ready for a future lighting pass to treat as occluders alongside wall segments. Not wired into `render.py`'s lighting composite (owned by an in-flight sibling fix, per this directive's explicit scope fence) — this row only covers the query surface, not any consumer. | engine-rust / game | `query::tests::terrain_light_segments_is_empty_absent_a_mask_and_four_edges_once_set` | C (interface existence + shape only; no consumer to test against yet) | P1 |
| T8 | Terrain never affects `visibility.rs`: vision passes through painted equipment (enemies behind it stay visible as sensor traces), and this feature makes zero edits to `visibility.rs`/`EDGE_BAND`/frustum code. | engine-rust | Provable by inspection (no terrain reference anywhere in `visibility.rs`, unchanged by this diff — `git diff` scope check) rather than a runtime test, since there is nothing to assert against short of re-testing all of §4's existing visibility suite, which already passed unmodified after this wave (`cargo test -p necore`, all `visibility::tests::*`/`V*` proptests green with terrain code present but unused by that module). | N/A (inspection) | P1 |

Loot/economy, level-schema, and other wave-1 rows above are unaffected by
this pass; check.sh is green end-to-end (`cargo test -p necore` + full
`uv run pytest`, 510 tests) with all of the above added.
