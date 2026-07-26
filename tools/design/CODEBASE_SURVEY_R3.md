# CODEBASE SURVEY — round-3 consult packet (2026-07-25)

Surveyed from branch `rewrite` @ `87c39f7d` (= canon base `d85d3765` + design-doc
commits; code identical to the base the director full-cleared). Eight parallel
surveyors, each reading the real code; section H surveys the discarded-but-
recoverable 07-20..07-25 range at `94b3397b` (mine code, not conclusions).

Sections:
  A. Repo layout, build & module inventory
  B. GameSession internals (sim.py)
  C. Enemy AI at the base
  D. Portal/connect machinery & the engine API surface the marrow needs
  E. Worldgen, levels, and where a hub attaches
  F. Buildings, economy & pickups at the base
  G. Verification infrastructure
  H. The minable code at 94b3397b (incl. the hub-scale bug, quoted)

---

# A. Repo layout, build & module inventory

Surveyed at branch `rewrite`, HEAD `87c39f7d` (design-doc commits on top of the hard-reset canon base `d85d3765`). All paths relative to repo root `/home/login/PycharmProjects/noneuclideantopdownshooter`.

## A.1 Top level

Three code roots plus design docs and data:

- `engine/` — Rust cargo workspace (core crate + PyO3 bindings)
- `game/` — Python package root (`pyproject.toml` sets `package-dir = {"" = "game"}`); contains `perihelion/` (the game), `tests/` (pytest suite), `assets/` (135 MB shipped assets), `tools/` (3 small game-side scripts)
- `tools/` — offline pipelines (art/music/sound generation, playtest farms, level gen, design consults)
- `levels/` — level JSON files + `campaign.json` manifest
- `DESIGN_7_25.md` (346 lines, repo root) — the canonical spec of systems to REBUILD on this base
- Other root docs: `ENGINE_DESIGN.md`, `ENGINE_INVARIANTS.md`, `MINDMAP_DESIGN.md`, `SEEDPOD_UI_DESIGN.md`, `BOT_REALISM_DESIGN.md`, `MUSIC_DESIGN.md`, `MUSIC_AUTHORING.md`, `LEVEL_DESIGN_PLAYBOOK.md`, `MARATHON_LEVEL_STANDARDS.md`, `ARTSTYLE_DIRECTION.md`, `NARRATIVE_DESIGN_DOC.md`, `DIALOGUE_SCAFFOLD.md`, `EDITOR.md`, `README.md`
- **Trap:** `AGENTS.md` at root is STALE pre-rewrite content (references `main.py`, `leveledit.py`, `Polygon.draw()` — none exist on this branch). Ignore it; `check.sh` and this section are authoritative.
- Bulk/scratch dirs (exist, skip): `out/` (untracked experiment outputs), `media/` (recorded demo videos/screens), `engine/target/` (692 MB build artifacts), `game/.hypothesis/`, `__pycache__/` everywhere, `docs/consults/`, two `.zip` archives at root.

### Directory tree (2 levels, caches/targets/asset bulk elided)

```
engine/
├── Cargo.toml            # workspace: members = ["necore", "necore-py"]; release: lto=true, codegen-units=1
├── necore/               # pure-Rust core crate (no deps; dev-dep proptest)
│   ├── src/              # 10 files, ~7,500 lines (see A.3)
│   └── tests/            # invariants.rs, properties.rs, soft_walls.rs
├── necore-py/            # PyO3 cdylib, lib name "necore" (pyo3 0.23, abi3-py311)
│   └── src/lib.rs        # 845 lines, the whole binding layer
└── target/               # build artifacts (692 MB) — ignore
game/
├── perihelion/           # the game package (see A.2)
│   ├── assets/           # runtime assets referenced by package code: fonts/, textures/ (21 MB)
│   ├── assets-hp/        # 14 high-poly enemy/prop PNG sources (7.4 MB)
│   ├── data/             # mindmap.json, corpse_lines.json, mindmap_font_metrics.json
│   ├── editor/           # level editor subpackage
│   └── testkit/          # headless bot/playtest subpackage
├── assets/               # shipped game assets: art/, fonts/, music/ (album_* banks), sfx/ (135 MB)
├── tests/                # pytest suite: 37 test files, 318 test functions; fixtures/ (m1_5dspace.wad)
└── tools/                # capture_mindmap_demo.py, gen_mindmap_font_metrics.py, intro_probe.py
tools/
├── artgen/               # texture/decal generation + clearance audits (full_run.py, gen_* scripts)
├── design/               # marrow consult packets/scripts, probe_portal_scale.py
├── dialogue/t1_experiment/
├── levelgen/             # campaign.py, arrival_maze.py, dense/, INTEGRATION.md
├── marathon/             # Marathon WAD extraction: convert.py, mapread.py, extract_maze.py …
├── musiccal/             # difficulty calibration: run_farm.py, tune_pass_rate.py, build_gauntlet*.py, hunt_winner.py
├── musicgen/             # album bank production: daw.py toolchain, chants, consult scripts
├── playtest/             # headless playtest: run.py, farm_record.py, campaign_run.py, mkvideo.py, parity.py, judges
├── soundgen/             # sfx bank: bank.py, synth.py, verify_bank.py
└── flicker_placement.py
```

## A.2 Python modules under `game/perihelion/`

Top-level package (line counts from `wc -l`):

| Module | Lines | Role |
|---|---|---|
| `render.py` | 3127 | Immediate-mode renderer: necore draw lists → 640×360 (`INTERNAL_W`×`INTERNAL_H`) pygame Surface. Two bit-identical backends behind one `Renderer`: "rust" (necore `Raster` display list, default when built) and pure-pygame. Darkness/otherworld field, glows, bolts, post overlays composite in Python either way. |
| `sim.py` | 2904 | `GameSession` — the deterministic core. Pure Python + necore; no pygame/wall-clock/IO; same level+seed+inputs ⇒ bit-identical run. Exposes `tick(inp: InputFrame)` (line 642), `snapshot() -> dict` (line 2855), `session.fx` / `session.decals` for render/audio, `metrics` for tests. `InputFrame` dataclass at line 214. Also home of `WEAPONS`, `WEAPON_ORDER`, `DT`, `PLAYER_HP`. |
| `music.py` | 1886 | Dynamic music. NOT a state machine: PRAYER/CONTEMPT/STALWART are continuous [0,1] values from heuristic batteries; inputs = triple + level + weapon + aggro list. `shipped_banks()` (line 56) globs `game/assets/music/album_*` with `bank.json` — the no-flags default soundtrack. |
| `mindmap.py` | 1843 | Mind Map graph (concepts the Commando metabolizes). Expansion costs THINK TIME in sim ticks, not components; data from `data/mindmap.json` (33-node early-game state); faith/apostasy derived from investment pattern. |
| `podscene.py` | 1404 | Seed-pod full-screen UI: FABRICATOR tab (components shop, hero art) + MIND tab (mind-map graph, fog-of-war, reveal animation). |
| `app.py` | 1002 | Window, fixed 60 Hz sim timestep decoupled from display fps, scene stack, campaign progression, save/load. `App.__init__(args)` (line 319), `App.run()` (line 773), `GameScene(level, seed, player_state=None, level_path=None, difficulty="normal")` (line 177). `DEFAULT_CAMPAIGN = REPO_ROOT/"levels"/"campaign.json"` (line 28). Contains `start_vigil()` (line 578) loading `levels/vigil.json` — note DESIGN_7_25.md deletes the vigil; it EXISTS at this base. |
| `menus.py` | 540 | `Scene` interface + title/pause/death/win screens + `TerminalOverlay`. Only the stack top gets input/update/draw (pausing for free). |
| `levels.py` | 538 | Level format v2 loader: `class Level` (line 79), `load_level(path) -> Level` (line 151), `class LevelBuilder` (line 265, `.build()` line 531). Absolute authored verts re-centered to per-polygon centroids; doors are pending connections (locked door = real wall). |
| `stream.py` | 397 | One seamless world: campaign chunks lazy-stream into a single live sim via carved transit-spine corridors; death reprints chunk-entry state. |
| `convscene.py` | 308 | `ConversationScene`: full-screen tight-beam dialogue between campaign levels, with choice turns (trust/antagonize). |
| `lighting.py` | 272 | World lights = the visibility engine re-run from the light's POV with falloff; static-light caching exploits root-frame invariance (ENGINE_INVARIANTS R1). |
| `terrain.py` | 255 | Converts `polygon_<i>_walkmask.png` (white=walkable) to polygon-local AA rects for `necore.Sim.set_polygon_terrain`. Missing file ⇒ fully walkable, never fabricated. |
| `hud.py` | 201 | Lo-fi HUD: HP, weapon/ammo, keys, crosshair; pure pygame.draw. |
| `audio.py` | 182 | pygame.mixer bank + graph-propagated positional audio; lazily loads `game/assets/sfx/*.wav`, missing wavs log once and skip. |
| `__main__.py` | 60 | CLI entry (see A.5). |
| `texture_geom.py` | 47 | Dependency-free texel↔polygon-local mapping (`local = bbox_min + (t+0.5)/DENSITY`) shared by renderer and offline artgen. |
| `conversations.py` | 36 | BLANKED by director order 2026-07-11: `conversation_for(gap, trust, flags) -> ConversationBundle | None` returns no conversation; interface + speaker constants only. Director hand-writes all dialogue. |
| `__init__.py` | 0 | empty |

`game/perihelion/testkit/` (headless AI-playtest toolkit, ENGINE_DESIGN.md §4):

| Module | Lines | Role |
|---|---|---|
| `humanbot.py` | 2202 | `HumanBot` — the marketing-playthrough bot (BOT_REALISM_DESIGN.md): perception → reactive executor → humanized input synthesis. |
| `bots.py` | 450 | Deterministic omniscient bot policies (`AggroBot`, `ExplorerBot`, `PacifistBot`, `CamperBot`, `SteadyBot`) driving `GameSession` via `InputFrame`; each owns its own `Random(seed)`. |
| `harness.py` | 282 | `run_bot`/`run_matrix`/`assert_playable`/`summarize`: drive a session with a bot up to `max_ticks`, collect metrics + event log. |
| `perf.py` | 190 | Engine micro-benchmarks on 4 worst-case world shapes (radial hub, mirror polygon, 40-polygon grid, infinite corridor). |
| `tactician.py` | 165 | Sonnet pause-and-think LLM consult layer for HumanBot (event-driven, rate-limited). |
| `perception.py` | 147 | `PerceptionModel`: honesty layer filtering the omniscient `snapshot()` for HumanBot. |
| `replay.py` | 114 | Bit-exact `Replay`: level dict/path + seed + packed InputFrame rows. |
| `mouse_model.py` | 99 | Velocity/accel-bounded aim trajectory model. |
| `graphs.py` | 73 | Synthetic mind-map graphs at target scale (hundreds–thousands of nodes) for layout proofs. |
| `loadouts.py` | 14 | `FULL_LOADOUT` — THE calibration loadout shared by farm, tune_pass_rate, and app `--loadout full`. |
| `__init__.py` | 15 | re-exports bots + harness API. |

`game/perihelion/editor/`: `model.py` (809 — pure-Python `EditorModel` mutating the resolved level dict, headlessly testable), `view.py` (896 — pygame canvas/camera/input only), `__main__.py` (20 — `uv run python -m perihelion.editor [file.json]`).

## A.3 Rust crate layout — `engine/necore/src/`

Workspace `engine/Cargo.toml`: members `necore`, `necore-py`; resolver 2; release profile lto=true/codegen-units=1; dev opt-level=1. `necore` has ZERO runtime dependencies (proptest as dev-dep).

| File | Lines | Role |
|---|---|---|
| `lib.rs` | 24 | Crate doc + module wiring. World = graph of convex polygons connected edge-to-edge by invertible affine transforms; NO world space — every coordinate polygon-local, portal transforms relate polygons. Core owns geometry/visibility/simulation/queries and emits events; meaning belongs to the game layer. |
| `math.rs` | 255 | `Vec2`, `Mat3` (row-major affine) primitives. |
| `geom.rs` | 573 | Shoelace signed area (engine-canonical polygons y-down, visually CCW ⇒ NEGATIVE area), `HalfPlane`, clipping helpers. |
| `world.rs` | 466 | `PolygonId`, `Portal { target_polygon, … }`, `World` graph construction/connection. |
| `physics.rs` | 1047 | `Sim`: entity movement/collision, portal transfer (`TRANSFER_NUDGE = 1e-3`), wall spans, events. |
| `visibility.rs` | 577 | Portal-frustum recursion: view frusta expressed in the current polygon's local coords; `visible_set`. |
| `query.rs` | 540 | `RayHit`, raycasts, routing/broad-phase queries over the sim. |
| `soft.rs` | 273 | Otherworld soft walls: damped mass-spring on the polygon-graph vertex set; edges remember rest LENGTH only (translation/rotation-invariant energy ⇒ new stable configurations possible). |
| `raster.rs` | 2875 | Software rasterizer with **bit-exact pygame-ce 2.5.7 parity** (direct ports of pygame `draw.c` algorithms); display-list renderer for world/entity/overlay layers. |
| `raster_pygame_fixtures.rs` | 57 | GENERATED pygame-ce 2.5.7 ground-truth pixel fixtures — do not edit. |

`engine/necore/tests/`: `invariants.rs` (correct-by-construction property tests, e.g. CONTAINMENT: entity ends every step inside its registered polygon), `properties.rs` (proptest suite per ENGINE_DESIGN.md §2.6, + `properties.proptest-regressions`), `soft_walls.rs` (Otherworld soft-wall invariants as integration tests).

`engine/necore-py/src/lib.rs` (845 lines) — the entire binding layer. Module `necore` (cdylib, pyo3 0.23, abi3-py311) exposes exactly: classes `Sim` (pyclass at line 86) and `Raster` (line 598); functions `mat_mul`, `mat_inv`, `mat_apply`, `mat_apply_dir`, `mat_translate`, `mat_rotate`, `mat_scale`, `mat_rotation_angle`, `mat_identity`, `clip_polygon`, `clip_polyline` (registration lines 829–843). Matrices cross the boundary as row-major 9-tuples of floats; angles radians; errors become `ValueError`.

## A.4 Build & test

`check.sh` (repo root, verbatim body):

```bash
#!/usr/bin/env bash
# CI-style check: Rust engine core tests, then Python (pytest) against the
# built necore extension. Run from the repo root.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

echo "== cargo test -p necore =="
(cd engine && cargo test -p necore)

echo "== maturin develop --release (rebuild necore extension) =="
uv run maturin develop --release -m engine/necore-py/Cargo.toml -q

echo "== uv run pytest -q =="
uv run pytest -q

echo "== check.sh: all green =="
```

- Extension rebuild: `uv run maturin develop --release -m engine/necore-py/Cargo.toml` (installs `necore` into the uv venv). All Python runs through `uv run` (uv-only law).
- Pytest: `[tool.pytest.ini_options] testpaths = ["game/tests"]`; one marker `slow` (`-m "not slow"` for the fast subset). 37 test files / 318 test functions at this base. Hypothesis is a dev dependency (property tests populate `game/.hypothesis/`).
- Runtime deps (pyproject): `pygame-ce>=2.5`, `numpy`, `python-dotenv`, `httpx`. The long dev-group list (librosa, pedalboard, essentia, torchcrepe, …) serves the offline music/sound tools, not the game.

## A.5 Launch

No `[project.scripts]` entry point; launch is module execution:

- **Game:** `uv run python -m perihelion [flags]` → `game/perihelion/__main__.py:main()` builds argparse, then `App(args).run()`. Flags: `--level PATH` (overrides campaign manifest), `--seed INT`, `--scale INT` (window = 640×360 × scale; default fits 1440×810), `--mute`, `--hard`, `--fps`, `--zoom FLOAT` (default 1.35), `--music-bank DIR` (an `album_*` bank or a dir of them; default = `music.shipped_banks()`), `--loadout full` (calibration loadout), `--no-music`, `--play`; hidden flags: `--autoplay`, `--bot {aggro,explorer,pacifist,human}`, `--bot-skill`, `--tactician`, `--record DIR`, `--record-every` (default 2), `--record-seconds` (default 180), `--start-chunk`. `--record` without `--bot`/`--play` defaults to the aggro bot; any `--bot` implies autoplay.
- **Editor:** `uv run python -m perihelion.editor [file.json]`.
- **Headless playtest (no window):** `uv run python tools/playtest/run.py --level <json> [--bot aggro|... --seed N --max-ticks N --gif]` prints the harness `Result` as JSON. Calibration farm: `tools/musiccal/run_farm.py` (drives `GameSession` directly, human bot default); pass-rate: `tools/musiccal/tune_pass_rate.py --level <json> --k N`. Farm-exact video capture is `tools/playtest/farm_record.py` (app `--record` mode diverges from farm sim — known and documented in that file); assembly via `tools/playtest/mkvideo.py`.

## A.6 Level & data files

All levels in `levels/` (level format v2 JSON; top-level keys of a gauntlet file: `version, name, tier, ambience, polygons, connects, connects_x, doors, player, exit`):

- `campaign.json` — manifest, exactly `{"levels": ["levels/l01.json" … "levels/l10.json"]}`; the App default (`DEFAULT_CAMPAIGN`, app.py:28), streamed as one world by `stream.py`.
- `l01.json`–`l10.json` — the 10 campaign chunks (63–95 KB each).
- `gauntlet4.json` — **canonical gauntlet** (163 polygons, 62,520 bytes; DESIGN_7_25.md:11 states "Canonical gauntlet = gauntlet4.json").
- **Duplicate warning:** `gauntlet_cal3.json` is byte-identical to `gauntlet4.json` at this base (`cmp` confirms). Per the one-canonical-version law it is a stale copy pending deletion — implementers should touch only `gauntlet4.json`.
- Older calibration variants: `gauntlet_cal.json`, `gauntlet_cal2.json`, `gauntlet_horde.json`.
- `vigil.json` — exists and is wired (`App.start_vigil`, app.py:578); DESIGN_7_25.md deletes the vigil, so removal is part of the rebuild, not already done.
- `marathon_arrival.json`, `maze_demo.json` — Marathon-derived imports (`tools/marathon/`); `smoke_4polygon.json` — smoke fixture.
- Game data in `game/perihelion/data/`: `mindmap.json` (committed 33-node mind-map design), `corpse_lines.json` (corpse flavor lines), `mindmap_font_metrics.json` (generated by `game/tools/gen_mindmap_font_metrics.py`).
- Test fixture: `game/tests/fixtures/m1_5dspace.wad` (Marathon map source).

**Does NOT exist at this base** (relevant to layout expectations): no hub level file, no marrow/breach/caller/kin systems anywhere in `game/perihelion/` (DESIGN_7_25.md describes them as rebuilds; the discarded implementations live only at reflog commit `94b3397b`), no `ImmuneConfig`/feature-flag machinery (torn out per the no-feature-flags law), and no console-script entry points — module execution only.


---

# B. GameSession internals (`game/perihelion/sim.py`)

`sim.py` (2,904 lines at HEAD 87c39f7d) is the entire deterministic game core: pure Python + the `necore` PyO3 engine module. No pygame, no wall clock, no I/O; same Level + seed + InputFrame sequence ⇒ bit-identical run. All randomness flows through `self.rng = Random(seed)` (sim.py:249). Fixed timestep `DT = 1/60`, `TICK_RATE = 60` (sim.py:21-22). Collision groups: `GROUP_PLAYER=0, GROUP_ENEMY=1, GROUP_PBULLET=2, GROUP_EBULLET=3, GROUP_PICKUP=4` (sim.py:24-28). `ACTIVE_HOPS = 5` (sim.py:30).

Input is `InputFrame` (sim.py:213-232): `mx,my` (screen-space move −1..1), `ax,ay` (aim in internal-screen pixels), `fire`, `alt`, `interact`, `weapon` (0=keep, 1..N selects `WEAPON_ORDER[i-1]`), with `pack()`/`unpack()` for replay recording.

## 1. `GameSession.__init__` (sim.py:236-432), in construction order

Signature: `__init__(self, level: Level, seed: int = 0, screen=(480, 270), zoom: float = 1.35, player_state: dict | None = None, difficulty: str = "normal")`.

1. **Level + difficulty** (239-256): deep-copies `level.polygon_verts` (soft/otherworld polygons deform them in place), sets `self.player_resist` from `player_state["dmg_taken_mul"]`, `_hp_mul=1.35` / `_dmg_mul=1.25` on hard, `rng`, screen dims, `tick_count=0`, `dead/complete=False`, `freeze=0` (hitstop).
2. **Engine world** (258-284): `s = necore.Sim()`; `s.add_polygon(verts)` per polygon; `terrain.apply_walk_masks(s, level)` (painted collision rects, engine-side); `s.connect(...)` / `s.connect_with_xform(...)` for portals; collision matrix: all pairs off, then PLAYER↔ENEMY, ENEMY↔ENEMY, PBULLET↔ENEMY, EBULLET↔PLAYER, and PBULLET↔PLAYER on (your own rounds can return). GROUP_PICKUP collides with nothing.
3. **Lighting** (298-304): `LightingSystem(s, level)`; appends `self.player_light` — an attached `LightSpec` work lamp (intensity 0.95, radius 85) that is the only always-on light.
4. **Doors** (307-320): `self.doors` list of dicts `{a,ea,b,eb,key,open,gate_prompt}` (pending portal connections), `self.door_edges[(polygon,edge)] -> key`.
5. **Player** (322-398): `self.pid = s.spawn(level.player_polygon, *level.player_pos, PLAYER_RADIUS=6.5, PLAYER_MASS=1.2, GROUP_PLAYER)`; props `rest_wall=0.0, rest_ent=0.05, max_substep=6.0`. Then economy/state from `player_state`: `max_hp` (default `PLAYER_HP=100`), `hp`, `ammo` (default `{"9mm":48,"shell":0,"cell":0}`), `weapons` (default `["knife","pistol"]`), `components`, `chassis`, `station_kits`, `hp_ups`, `mind` set + think state (`think_focus/think_progress/think_done`), `_recompute_mind()` (derives all combat multipliers, sim.py:2515-2553), `recalls`, `stations` (seeds `add_station` at the spawn), `keys`/`held_key_meta`, `soft_polygons` (calls `sim.soften_polygon(i)` for "otherworld" kinds), `weapon`, `lightning_charge` (full), `cooldown`, `hurt_cd`, `aim=(1,0)`, `holes`, `hole_mark`, `tau_charge=0`, `cloister=None`, `turrets={}`, `sentries={}`.
6. **Camera** (393-398): `_set_cam(translate(w/2,h/2) · scale(zoom) · translate(-px,-py))` — hard reset with whole-pixel snap.
7. **World objects** (400-421): flicker light-map cache slots; `self.enemies/bullets/pickups = {}` dicts; `self.terminals` from level; `self._spawn_from_spec(polygon, spec)` for every `level.entities` entry; `exit_polygon/exit_pos`; `wave=0`, `wave_timer` (only if `level.vigil`); optional `_build_cloister()` if carried state had one.
8. **Output channels** (423-432): `self.fx = []` (drained by app each tick), `self._oob_fx` (menu-time events joined next tick), `self.decals: dict[polygon -> list]`, `self._objective_fired` once-gates, `self.metrics` dict (`ticks, shots, hits, kills, dmg_dealt, wave, dmg_taken, pickups, transfers, deaths, polygons_visited, hp_series, completed`).

## 2. The `tick(inp: InputFrame)` pipeline (sim.py:642-723), exact order

1. **fx swap** (647-648): `self.fx = self._oob_fx; self._oob_fx = []` — fx is *cleared every tick*; menu-time emissions (`buy`, `respawn_at_station`, etc.) are parked in `_oob_fx` via `_park_oob` (2343) so the clear doesn't eat them.
2. `tick_count += 1`; metrics; `hp_series` append every 60 ticks (649-652).
3. Early-out if `dead` or `complete` (653-654); hitstop: if `freeze > 0`, decrement and return (655-657) — the whole sim pauses.
4. `ppolygon = self.player_polygon()`; **`s.set_active_within(ppolygon, ACTIVE_HOPS)`** (660-661) — active region recomputed every tick.
5. Soft-polygon vert refresh into `level.polygon_verts` (663-667).
6. `_containment_sweep(ppolygon)` every 30 ticks (668-669; def 2161) — recovers entities persistently ≥25u outside their polygon (6 consecutive sweeps) to centroid; damage control for an engine escape bug.
7. `_recall_tick(ppolygon)` (670; def 2411); mind-organ regen every 60 ticks (671-676).
8. `_think_tick(ppolygon)` (678; def 2460) — focus-node rumination.
9. **`_player_control(inp, ppolygon)`** (679; def 735): weapon select → aim (through `inv(_cam_smooth)`) → movement accel via `set_vel(v + dir·PLAYER_ACCEL·_accel_mul·DT)` → `_fire` if `fire && cooldown<=0` → alt handling (tau charge / lightning).
10. **`_enemy_ai(ppolygon)`** (680; def 1545) — see §3/§10.
11. **Friction** (683-685): `_apply_friction` (727) on player then every enemy — `set_vel(v·(1−fric·DT))`. Applied to ALL enemies, including ones outside the active region.
12. **Physics**: `events = s.step(DT)` (687) — the single engine step per tick (engine substeps internally per entity, governed by the `max_substep` prop; there is no Python substep loop). Then `_consume_events(events)` (688; def 1987) handles `transfer` (player: cloister rotate + `_cam_rebase(m9)` + metrics), `wall` (door bump prompts, soft-wall impulses, "shoot"-key doors, bullet wall fates: tau bounce / spit splat / dart detonate / bullet chip+despawn), `contact` (→ `_contact`, def 2080: all damage resolution).
13. `sweep_bullets()` (689; def 2668): ttl decrement for ALL bullets + the wounded-round guard (straight rounds under 700 u/s are despawned — spawn-overlap drifters).
14. `_turret_tick()` (691; def 1241) and `_sentry_tick()` (692; def 1325) — cloister guardians and data-driven sentries; both run regardless of active region.
15. Mid-tick death gate (693-698): if `dead` was set during events, return before scans (a dead frame must not scoop its own corpse).
16. **Scans** (699-702): `_pickup_scan` (2210), `_terminal_scan` (2610, needs `inp.interact`), `_station_scan` (2604, emits `("shop",)` fx), `_exit_scan` (2622, sets `complete`).
17. `_vigil_tick(ppolygon)` if `level.vigil` (704-705; def 1154) — the wave director (exists in code at this base; DESIGN_7_25 deletes vigil, but that is a spec decision, not this code).
18. Cooldown / hurt_cd decrement; `lightning_charge` +1 capped at `LIGHTNING_RECHARGE_TICKS = 540` (706-710).
19. **Camera follow** (716-723): exponential pull `k = min(1, 7·DT)` on `_cam_smooth`, then `_cam_step_follow` steps the rendered `cam` by whole pixels only.

## 3. Entity model

Engine entities are opaque u64 ids from `sim.spawn(polygon, x, y, radius, mass, group)`; the engine owns polygon membership, position, velocity, facing (`set_dir`), radius, mass, group and per-entity props (`rest_wall`, `rest_ent`, `max_substep`, `transfers`). `sim.get(id)` returns `(polygon, x, y, vx, vy, dx, dy)`. Python holds *everything else* in id-keyed dicts:

- `self.enemies[eid]` = `{kind, hp, state, touch_cd, spit_cd, scream_cd, wander_cd, buff, trace_intensity, ...}` (spawn_enemy, sim.py:463-474; hp scaled by `_hp_mul`). States: `idle → waking → hunt` (flicker uses its own `lurk/ambush/hunt`). Kinds and stats in `ENEMIES` (77-115): husk 15hp/12 touch, mite 4hp/4, spitter 18hp/9 spit, brute 65hp/24, shrieker 10hp (0 touch), warden 520hp/30 touch + 13 spit, flicker 22hp/16.
- `self.bullets[bid]` = `{kind, dmg, ttl, born, bounces?}`. Kinds: `bullet`, `tau`, `taucharged`, `scrap`, `gland`, `tracer` (rail visual), `dart` (lightning), `turret` (friendly), `spit` (enemy, GROUP_EBULLET). Player rounds spawn GROUP_PBULLET at the muzzle clamped inside the polygon (`_clamp_apex`, sim.py:868-870) and inherit 40% of shooter velocity (883).
- `self.pickups[eid]` = `{kind, meta?, amount?, contents?, line?}` (spawn_pickup, 476-487; catalog `PICKUPS` 117-135). GROUP_PICKUP, `transfers=False`.
- `self.sentries[tid]` / `self.turrets[tid]`: indestructible GROUP_PICKUP emplacements.

**Spawn paths**: level entities via `_spawn_from_spec` (438-461) at init and via `append_chunk(level)` (1062-1100, the streamer's re-indexed chunk ingester); vigil waves (`_vigil_tick`); warden brood (`_boss_adds`, 1119-1145); drop tables + guaranteed `components` salvage pickup on every kill (`_kill_enemy` 1471-1489); `corpse_frame` on player death; conditional `organ_gland`. **Despawn** is always the pair `self.sim.remove(id)` + dict pop; there is no free-list or handle reuse concern at the Python level.

## 4. Damage, death, knockback — as they exist today

- **Enemy damage**: `_damage_enemy(eid, dmg, ndir, knock)` (1426-1450). Applies `_dmg_out_mul`, `_target_mark_mul` (non-idle only), crit roll; subtracts hp; forces `state="hunt"`; metrics; blood decal + `("hitflash", eid)` fx; kills at hp≤0 via `_kill_enemy` (1452-1494): corpse + blood decals, `("gib", ...)` fx, hitstop 4/7, drop table, salvage components (`score × _salvage_mul`), `alert_enemies(polygon, 1)` unless brood.
- **Knockback is a velocity-write, not an engine impulse.** There is no impulse API in necore. sim.py:1441-1443: `self.sim.set_vel(eid, evx + ndir[0]*knock/m, evy + ndir[1]*knock/m)` — mass-scaled velocity increment. Magnitudes: knife 260, rail 420, bullets/tau/turret 90 (in `_contact`, 2090), lightning blast `force=1500`·falloff written the same way (1394-1395), chain arcs 0.
- **The player receives NO knockback anywhere** — no `set_vel` on `self.pid` from any damage path. Weapon `kick` values are screen-shake magnitudes only (`self._shake(w.get("kick", 2.0))`, 859).
- **Player damage**: `_damage_player(dmg, polygon)` (1496-1519). Gated by `hurt_cd` — a global 30-tick (0.5s) i-frame window for ALL sources (touch, spit, dart splash, returned rounds). Severs recall channels. Applies `_dmg_mul · _armor_mul · player_resist`. At hp≤0: `dead=True`, `("playerdie",)` fx, `corpse_player` decal, `_drop_corpse` (1521-1541) — spawns a `corpse_frame` pickup holding `components` + `station_kits` (with `protected_revival`, components stay banked). Touch damage lands in `_contact` (2118-2140) with the brood bite-rate gate (one brood bite per 12 ticks). Returned own rounds hit for 0.75× unless bullet age ≤ 2 ticks (spawn artifact, silent, 2104-2111).

## 5. Player death / respawn machinery

Death only sets flags + drops the corpse; recovery is caller-driven (app.py:667-676 `reprint()`):

- `respawn_at_station()` (sim.py:2566-2602): requires `chassis > 0` and `stations`; picks nearest station by `sim.hop_distance`; decrements chassis; **removes all bullets**; `reseat_player` (2555-2564 — engine `set_pos` cannot change polygon membership, so the player entity is removed and respawned) or `set_pos` if same polygon; `hp = max_hp`, `dead = False`, clears freeze/tau_charge/hole_mark; hard camera reset; `REPRINTED` objective via `_park_oob`. World state (enemies, doors, wreck) untouched.
- No chassis → app falls back to `restart_level()` → `streamer.respawn()` (stream.py:348) — the cold chunk restore. That machinery lives in `stream.py`, not sim.py.
- **Stations**: `add_station(polygon, pos)` (2326, dedupes within 24u), `station_near` (2335, radius `STATION_RADIUS=30.0`), `place_station()` (2349, consumes a kit). **Recall**: `use_recall()` (2398) opens a 90-tick channel; any hit severs it (`_damage_player`, 1500-1502); `_recall_tick` (2411) teleports to the nearest station on completion.
- **Corpse frames** are ordinary pickups (`corpse_frame` in `_pickup_scan`, 2274-2286): recovering one restores its contents and emits `("logvoice", line)` fx.

## 6. The fx / event / decal contract with the renderer

- `session.fx` is a list of tuples, rebuilt every tick (see §2 step 1). The app (app.py:881-905) reads it once per tick: `renderer.consume_fx(fx)`, `audio.handle_sounds(session, fx)`, `music.update(session)`, then app-level handling of `shake`/`objective`/`terminal`/`pickup_text`. Emitted kinds at this base: `("sound", name, polygon, x, y, vol)`, `("shake", mag)`, `("objective", text)`, `("alerted", polygon, x, y)`, `("flash", polygon, x, y, size)`, `("holemark"/"holeopen", polygon, x, y)`, `("scream", polygon, x, y)`, `("hitflash", eid)`, `("gib", polygon, x, y, size, (nx,ny))`, `("playerhurt", dmg)`, `("playerdie",)`, `("lightning", polygon, x, y, radius)`, `("spark", polygon, x, y, nx, ny)`, `("pickup_text", polygon, (x,y), text)`, `("logvoice", seed)`, `("terminal", text)`, `("shop",)`, `("thought_done", node_id)`.
- `session.decals: dict[polygon -> list[(kind, x, y, size, angle)]]` capped at 250 per polygon (`_decal`, 509-514); the renderer reads it directly (render.py:2520). Kinds: `scorch`, `blood`, `splat`, `chip`, `corpse_<enemykind>`, `corpse_player`.
- Menu-time API calls (`buy`, `place_station`, `pod_heal`, `complete_focus`, `set_focus`, `use_recall`, `respawn_at_station`) bracket their emissions with `mark = len(self.fx)` … `_park_oob(mark)` (2343-2347) so they surface on the *next* tick.

## 7. Active-region machinery — and what the asked-about API is NOT

**`set_active_within_roots` and `_processing_roots` DO NOT EXIST at this base.** Repo-wide grep over `game/perihelion/`, `engine/necore/src/`, `engine/necore-py/src/` finds neither name. The only API is single-root: `Sim.set_active_within(polygon, hops)` (binding engine/necore-py/src/lib.rs:367-372; implementation engine/necore/src/physics.rs:156-176 — BFS over portals filling `active_polygons: Vec<bool>`; default state is `all_active=true` until first call). sim.py calls it once per tick with the player's polygon and `ACTIVE_HOPS=5` (sim.py:661).

What freezes outside the active set:
- **Engine**: `Sim::step` (physics.rs:248-270) skips `step_entity` for any entity whose polygon fails `polygon_active` (physics.rs:244-246). So outside 5 hops: no integration, no movement, no collision, no wall/contact/transfer events. Velocity is retained (and still writable from Python).
- **Python AI**: `_enemy_ai` re-derives the same set via `s.polygons_within(ppolygon, ACTIVE_HOPS)` and `continue`s past enemies outside it (sim.py:1547-1552) — no AI, and their per-enemy cooldowns (`touch_cd/spit_cd/...`, decremented at 1556-1558) and `waking` countdowns also freeze.
- **NOT frozen**: friction still decays every enemy's velocity (683-685); `sweep_bullets` still decrements ttl for all bullets everywhere (so an out-of-region bullet dies in place without flying); `_turret_tick`/`_sentry_tick` still scan and can spawn bullets in inactive polygons (which then won't move); `alert_enemies` (624-636) still flips `idle → waking` by hop distance regardless of region; `_vigil_tick` spawns anywhere.

## 8. Camera / aim coupling

Two matrices: `_cam_smooth` (exact float, player-polygon-local → internal screen) and `cam` (rendered copy whose translation only ever moves by whole pixels). Three mutation paths: `_set_cam` (534, hard cut with snap — spawn/recall/reprint), `_cam_step_follow` (562, per-tick whole-pixel step toward the smooth matrix), `_cam_rebase` (589, portal transfer: right-multiply BOTH matrices by `inv(m9)` — exact, no re-rounding). **Gameplay is coupled to the smooth matrix, not the rendered one**: `_player_control` maps `inp.ax/ay` through `inv(_cam_smooth)` for aim (755-756) and `mat_apply_dir(inv, mx, my)` for movement direction (769); `set_dir(self.pid, ...)` sets facing and `self.aim`. Bots read `session.cam` when composing inputs. `visible()` (2745-2757) is the renderer entry: apex = player position clamped inside the polygon by `_clamp_apex` (2718, `_APEX_EPS=0.75` which must stay < engine `EDGE_BAND=1.0`); it also re-pins `player_light` there. `sight_map()` (2775-2810) serves the same portal-clipped visibility to AI/bots; `point_in_sight` (2812) tests it.

## 9. Weapons — complete list (`WEAPONS` sim.py:39-63, `WEAPON_ORDER` 64-65)

| Weapon | Damage | Cooldown | Firing model |
|---|---|---|---|
| knife | 9, knock 260 | 22 | melee arc scan, range 27 + target radius, arc ±55°, same-polygon only (811-834) |
| pistol | 12 | 20 | projectile 1500 u/s, spread 1.6°, 1×9mm |
| smg | 7 | 6 | projectile 1350 u/s, spread 5.5°, 1×9mm |
| shotgun | 6 × 8 pellets | 54 | 1150 u/s, spread 11°, 1 shell |
| rail | 42, knock 420, pierce 3 | 84 | **hitscan** `sim.raycast` loop (900-926), range 2000, 1 cell; wall scorch decal; 5200 u/s visual tracer (dmg 0, ttl 14); hitstop 2 |
| lightning | dart 26 dmg; blast radius 220, dmg 26×(0.6+0.4·falloff), force 1500; chain arcs: range 150, 16 dmg each, max 18 | implant: 540-tick recharge (no cd field); as selected weapon cd 18 | slow dart 720 u/s (ttl 240); detonates on wall/enemy/ttl via `_detonate_dart` (1370-1422); hits the player for 26×0.6 splash if it lands on them |
| tau (uncharged) | 9 | 7 | 1900 u/s, spread 2°, 1 cell, 2 wall bounces (`rest_wall=1.0`), ttl 140 |
| tau (charged) | **18 + 46·power**, power = `min(1, charge/80) × (0.4 + 0.6·cost/5)`, cost = `min(cells, 5)` ⇒ dmg range ~25.4 (1 cell, full hold) to **64** (5 cells, ≥80-tick hold) | release-triggered | hold `alt`: `tau_charge` +1/tick while cells > 0; `TAU_CHARGE_FULL=80`, holding past `TAU_OVERCHARGE=160` deals 12 self-damage and resets (784-788); release fires 2600 u/s, 3 bounces, ttl 160, hitstop 2 (`_fire_tau_charged` 943-966) |
| hole | — | 18 | portable-hole shooter: two marks carve a 15u-wide, 36u corridor between walls (`_hole_shot` 972-1033); with cloister, links the sanctum |
| scrap | 13 × 3 pellets | 46 | 980 u/s, spread 8.5°, **costs 2 components** (ammo IS the currency), ttl 34 |
| gland | 16 | 36 | 560 u/s glob, radius-3 bullet, ttl 170, **costs 1 hp per shot** |

All damage-out is further scaled by mind-map multipliers from `_recompute_mind` (2515-2553): `_dmg_out_mul` (×1.20 blessed, ×1.15 monstrous), `_target_mark_mul` 1.10, crit (10%/1.75× or 20%/2.0×), `_spread_mul` 0.75. Every shot calls `alert_enemies(ppolygon, level.alert_hops)` (898).

## 10. Signal-field / chemotaxis / reinforcement code at this base: NONE

Verified by grep over sim.py and the whole `game/perihelion/` + engine tree: there is **no** signal field, chemotaxis, quorum, pheromone, gradient, `IMMUNE_*`, or reinforcement-arrival system anywhere at 87c39f7d (the ImmuneConfig work lives only in the discarded branch at 94b3397b). The only alert/coordination mechanisms in today's sim.py are: `alert_enemies` hop-graph wake propagation (624-636), the shrieker's scream (wake + 5s `buff` within 2 hops) and rally-toward-allies steering (`_shrieker_ai` 1772-1831), warden brood spawns (`_boss_adds` 1119-1145, engage/enrage tables at 187-195), and the vigil wave spawner (1152-1193). Enemy targeting composes portal transforms up to 3 hops with a raycast LOS check (`_enemy_ai` 1639-1669); pathing toward the player uses `s.next_edge` greedy hop routing plus `s.terrain_avoid_dir` steering. Any DESIGN_7_25 signal-field/reinforcement system is a from-scratch build against this file.

---

# C. Enemy AI at the base (branch `rewrite`, HEAD 87c39f7d, canon base d85d3765)

All enemy AI lives in **one file**: `game/perihelion/sim.py` (2904 lines), inside the single class `GameSession`. There is no separate AI module, no per-enemy class hierarchy — enemies are dicts in `GameSession.enemies: dict[int, dict]` keyed by engine entity id, driven by `GameSession._enemy_ai(ppolygon)` (sim.py:1545) called once per tick from `GameSession.tick(inp)` (sim.py:642, AI call at :680). Bot-side "perception" code in `game/perihelion/testkit/` (perception.py, humanbot.py) is test harness for the *player* bot, not enemy AI — do not confuse the two.

## C.1 Roster and stat table

The stat table is the module-level constant **`ENEMIES: dict[str, dict]`, sim.py:77–115**. Seven kinds:

| kind | hp | radius | mass | accel | fric | ~walk speed* | touch_dmg | touch_cd | score | extra |
|---|---|---|---|---|---|---|---|---|---|---|
| husk | 15 | 8.0 | 1.0 | 430 | 3.2 | ~127 u/s | 12 | 38 | 1 | lunge (see C.2) |
| mite | 4 | 4.0 | 0.35 | 690 | 4.5 | ~142 u/s | 4 | 24 | 1 | no footfall sfx |
| spitter | 18 | 9.0 | 1.4 | 340 | 3.8 | ~84 u/s | 8 | 45 | 2 | spit_cd=95, spit_speed=380, spit_dmg=9, keep_min=110, keep_max=190 |
| brute | 65 | 13.5 | 7.0 | 260 | 2.6 | ~96 u/s | 24 | 55 | 4 | lunge; excluded from portable-hole corridors (diameter 27 > HOLE_WIDTH 15, sim.py:68) |
| shrieker | 10 | 7.0 | 0.8 | 520 | 3.4 | ~144 u/s | 0 | 60 | 3 | scream_cd=300 (5 s) |
| warden | 520 | 16.0 | 12.0 | 330 | 2.4 | ~132 u/s | 30 | 48 | 25 | boss; spit_cd=70, spit_speed=460, spit_dmg=13, keep_min=0, keep_max=100; enrage at hp<260 |
| flicker | 22 | 8.5 | 1.0 | 560 | 3.4 | ~155 u/s (hunt) | 16 | 42 | 3 | lurk_speed=95, ambush_radius=70, ambush_burst=560, ambush_ticks=18, disengage_light=0.15, disengage_dist=220, disengage_beat=90 |

*Walk speed is derived, not stored: velocity integrates as `v ← (v + accel·DT)·(1 − fric·DT)` (accel in `_enemy_ai`, friction in `_apply_friction` sim.py:727, applied per-tick at sim.py:684–685), so terminal ≈ `accel·(1 − fric/60)/fric`. Player terminal ≈ 133 u/s (PLAYER_ACCEL=820, PLAYER_FRICTION=5.6, sim.py:34–35). **There is no turn-rate stat**: `sim.set_dir()` snaps facing instantly every tick; enemies always face their target exactly (sim.py:1674).

Supporting tables, all module-level in sim.py: `WAKE_TICKS` (sim.py:621–622: husk 32, mite 18, spitter 26, brute 45, shrieker 12, warden 20 — no flicker entry, it never uses idle/waking); `DROP_TABLES` (sim.py:197–210); `WARDEN_ADDS_ENGAGE` / `WARDEN_ENRAGE_HP = 260.0` / `WARDEN_ADDS_ENRAGE` (sim.py:187–195); `VIGIL_COSTS` (sim.py:1152). Each kind also carries `alert_snd` / `die_snd` sound ids. On kill (`_kill_enemy` sim.py:1452) every enemy drops a `components` pickup worth `ceil(score · _salvage_mul)` (sim.py:1483–1489) plus one roll on its DROP_TABLES row. Difficulty scaling: hp × 1.35 on `difficulty="hard"` (`_hp_mul`, sim.py:247); per-instance `hp` can be overridden by the level spec (`_spawn_from_spec` sim.py:446–447, also multiplied by `_hp_mul`).

## C.2 The standard state machine (husk, mite, spitter, brute, warden)

Enemy records are created by `spawn_enemy(polygon, pos, kind) -> int` (sim.py:463–474) with fields `kind, hp, state, touch_cd, spit_cd, scream_cd, wander_cd, buff, trace_intensity` (flickers start in `state="lurk"`, everything else `"idle"`). States are plain strings; the machine is inline in `_enemy_ai` (sim.py:1545–1760):

- **idle** (sim.py:1591–1612): if the player is in the *same polygon* → transition to **waking** (`wake = WAKE_TICKS[kind]`), play `alert_snd`, emit `("alerted", …)` fx, face the player. This is the "notice beat" — the player always gets the first move. Otherwise: random wander drift (new random unit direction every 90–240 ticks, thrust at `0.25·accel`).
- **waking** (sim.py:1614–1618): countdown; at 0 → **hunt**. Nothing else happens (no movement).
- **hunt** (sim.py:1620–1760): random "groan" sfx every 140–260 ticks; `accel` is multiplied by `buff_mul` (default 1.25) while `buff > 0`. Then:
  - **Target acquisition** (sim.py:1639–1669): if co-polygon, target = player position. Else if `1 ≤ hop_distance ≤ 3`, compose portal transforms hop-by-hop (`next_edge` → `portal_xform` → `mat_mul`, sim.py:1644–1661) to express the player in the enemy's local frame, then LoS-verify with `sim.raycast(polygon, ex, ey, dir, 3 hops, dist+40, 1<<GROUP_PLAYER, eid)` (sim.py:1666–1668) — combat works through doorways at any depth the ray clears (cross-room combat law).
  - **Engaged** (target found, sim.py:1670–1743): face target exactly; movement heading is `sim.terrain_avoid_dir(polygon, ex, ey, radius, nx, ny, lookahead)` (steers around walk-mask terrain rects; sim.py:1684). Husk/brute **lunge** when dist < 95 and `lunge_cd ≤ 0`: velocity burst 300 (husk, cd 120) / 240 (brute, cd 150) (sim.py:1688–1693). Spitter/warden hold the `keep_min..keep_max` range band and fire `_spit` (sim.py:1762–1770: spawns a `GROUP_EBULLET` glob, dmg from `spit_dmg`, ttl 180) each `spit_cd`; spitters `continue` after band logic (never close to melee), the warden also advances (sim.py:1741–1743).
  - **Not engaged** (no target, sim.py:1744–1760): pursue omnisciently — `edge = sim.next_edge(polygon, ppolygon)`; steer toward `sim.edge_midpoint(polygon, edge)` (through terrain avoidance). Enemies with `tether=True` (level prop, sim.py:448–449; used by the wardens in `levels/l08.json:43` and `levels/l10.json:453`) skip pursuit but still fight via the engagement branch.

Extras woven into the loop: footfall sfx per ~30/44 units traveled for all kinds except mite/shrieker (sim.py:1572–1589); touch damage is handled by the physics contact callback, not the AI — `_contact` (sim.py:2080–2140) applies `touch_dmg` to the player gated by per-enemy `touch_cd`, with a swarm-wide "brood bite" gate of ≤ 1 bite / 12 ticks for `brood`-flagged adds (sim.py:2124–2140).

**Warden specifics** (inside hunt): at first engagement it spawns `WARDEN_ADDS_ENGAGE` (10 adds) via `_boss_adds` (sim.py:1119–1145 — one-sided telegraphed wave in the sector beyond the warden from the player, staggered wakes `40 + 30·i`, all flagged `brood=True`); at `hp < WARDEN_ENRAGE_HP` (260) it sets `enraged`, permanent `buff` with `buff_mul=1.15`, halves `spit_cd`, adds a rotating 6-way radial spit volley per cooldown (sim.py:1735–1740), screams, and spawns `WARDEN_ADDS_ENRAGE` (3 adds). Boss drop is a guaranteed cache (DROP_TABLES sim.py:207–208 — note `_kill_enemy` breaks after the *first* successful roll, so warden effectively drops one item from that list, p=1.0 medkit first).

## C.3 Shrieker: `_shrieker_ai` (sim.py:1772–1831)

Non-combat alarm caller (touch_dmg 0). In hunt it: (a) **screams** every `scream_cd`=300 ticks — every enemy within hop distance ≤ 2 is set straight to `state="hunt"` with `buff=300` (5 s of ×1.25 accel) (sim.py:1782–1793); (b) **rallies**: every 60 ticks it picks the reachable polygon (hops ≤ 5, never the player's polygon) maximizing `count_of_non-shrieker_allies / (1 + hops)` and walks there via `next_edge`/`edge_midpoint` + terrain avoidance; with no rally target it backs directly away from the player if co-polygon, else holds position with its friends (sim.py:1794–1831). Excluded from vigil waves ("a thing that flees forever stalls a holdout", sim.py:1151) and from warden enrage adds (sim.py:193–195).

## C.4 Flicker: `_flicker_ai` (sim.py:1868–1983) — LURK/AMBUSH/hunt

Bypasses idle/waking entirely (dispatch at sim.py:1562–1570; spawn state `"lurk"` at sim.py:470). Light-driven: queries `light_level_at(light_map, …)` from `game/perihelion/lighting.py` via the per-tick cached `_polygon_light_map()` (sim.py:1837–1848).

- **lurk**: renders as a flickering sensor trace (`trace_intensity` alternates 0.34/0.12 on a random 6–22-tick cadence, `_flicker_dormant_trace` sim.py:1854–1866). If co-polygon and dist < `ambush_radius` (70) → **ambush**: velocity set to `ambush_burst` (560) toward the player, full-solid trace, alert sfx. Otherwise, if current light > `LURK_MAX_LIGHT` (0.12, sim.py:1852) and a debounce cooldown expired, sample 8 directions at 44 u (random phase) and move toward the darkest (sim.py:1918–1937).
- **ambush** (sim.py:1942–1953): `ambush_ticks` (18) of full-accel charge, then → **hunt**.
- **hunt** (sim.py:1955–1983): husk-pattern seek co-polygon / `next_edge` pursuit cross-polygon; **disengages back to lurk** after `disengage_beat` (90) consecutive ticks with light < 0.15 and dist > 220 — the only de-aggro path any enemy has.

## C.5 Perception — what enemies can actually sense

There is **no vision cone, no viewport check, no hearing model, no light-based detection for non-flickers, and no memory of last-seen position**. Detection is exactly four mechanisms:

1. **Co-polygon presence** (idle → waking): the player being in the same polygon at any distance, no LoS test (sim.py:1591–1592).
2. **Weapon-noise graph alert**: `alert_enemies(polygon, hops)` (sim.py:624–636) wakes *idle* enemies within `hops` of the noise polygon (hop metric = `sim.hop_distance`). Called on projectile fire with `level.alert_hops` (sim.py:898; per-level field, `levels.py:95`, default 2 — gauntlets and l08/l10 author 1), lightning with `alert_hops+1` (sim.py:941), charged tau with `alert_hops` (sim.py:966), and on any non-brood enemy death with hops=1 (sim.py:1493–1494). Knife and portable hole never alert.
3. **Being damaged**: `_damage_enemy` sets `state="hunt"` unconditionally (sim.py:1436) — shot = instant aggro, skipping waking.
4. **Shrieker scream** (C.3) — hop ≤ 2 broadcast to hunt.

During hunt, *aiming/attacking* uses composed-portal-transform + raycast LoS out to 3 hops (C.2), but *pursuit* is omniscient: `next_edge(polygon, ppolygon)` always routes toward the player's current polygon. Everything (physics activity and the Python AI loop) is frozen outside `ACTIVE_HOPS = 5` of the player: `sim.set_active_within(ppolygon, 5)` at sim.py:661, and `_enemy_ai` skips any enemy whose polygon is not in `sim.polygons_within(ppolygon, 5)` (sim.py:1547–1552) — cooldowns, wander, everything stops.

## C.6 Pathing / navigation — the engine routing API

Movement is force-based (accel toward a heading + friction), no waypoints, no local avoidance between enemies beyond physics collision (GROUP_ENEMY×GROUP_ENEMY collides, sim.py:280). Cross-chamber routing is fully engine-provided, via PyO3 bindings in `engine/necore-py/src/lib.rs`:

- `Sim.next_edge(from_polygon, to_polygon) -> i64` (lib.rs:523) — the edge to exit `from_polygon` by, −1 if unreachable. Backed by `Router` in `engine/necore/src/query.rs:186–255`: per-destination BFS table over the portal graph, cached and invalidated by `world.topology_version` (so carved doors/holes re-route automatically). Hop counts only — no edge weights, no distances.
- `Sim.hop_distance(a, b) -> i64` (lib.rs:537), `Sim.polygons_within(polygon, hops) -> Vec<usize>` (lib.rs:551).
- `Sim.edge_midpoint(r, e) -> (f64, f64)` (lib.rs:165) — the steering target when heading for a portal.
- `Sim.terrain_avoid_dir(r, x, y, radius, dx, dy, lookahead=40.0) -> (f64, f64)` (lib.rs:245–262) — deflects a desired heading around walk-mask terrain rects (painted equipment); without it a straight seek grinds forever against obstacles (comment sim.py:1675–1683). AI passes `lookahead = clamp(dist, 40, 120)`.
- `Sim.portal_xform(r, e) -> Option<M9>` (lib.rs:150) and `Sim.raycast(polygon, ox, oy, dx, dy, max_hops, max_len, mask, ignore=-1)` (lib.rs:491–521) — used for cross-portal target acquisition (C.2). Note per query.rs:1293-comment in sim.py: `raycast` stops at polygon edges/entities and knows nothing about terrain rects.

Actual traversal between chambers is physical: an enemy shoves through the portal plane and the engine emits a `transfer` event; nothing in `_consume_events` (sim.py:1987) does anything enemy-specific on transfer.

## C.7 Spawning

Three sources at this base — **all enemies are either authored in level JSON or spawned by the two in-code directors**:

1. **Authored**: `Level.entities: list[(polygon, EntitySpec)]` (`levels.py:20–24, 89`); JSON levels in `/levels/*.json` carry per-polygon `entities` lists. `GameSession.__init__` spawns them at sim.py:413–414 via `_spawn_from_spec` (sim.py:438–461; dispatches on `spec.type` into ENEMIES / SENTRIES / PICKUPS; props: `hp` override, `tether`). Campaign streaming re-invokes it: `append_chunk` at sim.py:1086 when a chunk is stitched on, and `WorldStreamer.respawn` (game/perihelion/stream.py:348–393) despawns and re-spawns the current chunk's enemies on player death ("cold restore"). Authored census: campaign l01–l10 use husk/mite/spitter/brute/shrieker plus flicker (l07–l09), warden ×1 in l08 and l10 (tethered); `gauntlet4.json` (canonical gauntlet) authors 219 enemies incl. 14 wardens and 36 sentries; `vigil.json` authors zero (wave-driven).
2. **The vigil wave director**: `_vigil_tick(ppolygon)` (sim.py:1154–1193), gated on `level.vigil` (sim.py:704–705; only `vigil.json` sets it). Budgeted waves (`3 + 2·wave`) drawn from `VIGIL_COSTS` (mite 1/husk 2/spitter 4/brute 7, no shriekers), warden on every 5th wave, spawned in random non-player polygons directly in `state="hunt"`, 8 s between waves, 60 s straggler grace.
3. **Warden brood**: `_boss_adds` (sim.py:1119–1145), described in C.2.

There are **no spawner entities, no respawning trickle, no off-screen re-population** outside these; a cleared chamber stays cleared until streamer cold-restore.

## C.8 Aggro/alert propagation as it exists

The complete list: `alert_enemies` hop-graph wake on weapon noise (idle→waking only — already-hunting or mid-wake enemies are untouched, sim.py:626–627); death-of-a-neighbor alert at 1 hop, suppressed for `brood`-flagged kills (sim.py:1490–1494); shrieker scream hop≤2 hunt+buff broadcast. Aggro is one-way and permanent — once in hunt nothing but death (or flicker disengage) leaves it; the loot-zone deadliness finding (comment sim.py:137–142) exists precisely because standard enemies have **no de-aggro path**.

## C.9 Friendly emplacements (context the implementer will hit)

Two indestructible turret systems target enemies (never vice-versa — enemies only ever target the player): cloister guardians `self.turrets` / `_turret_tick` (sim.py:1241–1269, nearest-in-polygon, no LoS) and data-driven `SENTRIES` (sim.py:156–165) / `spawn_sentry` (sim.py:489) / `_sentry_tick` (sim.py:1325–1368, range 300 + terrain-LoS via `_sentry_los_clear` sim.py:1319 + 10-tick spin-up). Both spawn as GROUP_PICKUP, which collides with nothing under the collision matrix (sim.py:276–284).

## C.10 What does NOT exist at this base (verified by grep over game/ and engine/)

- **No signal fields, chemotaxis, or quorum sensing** — the immune-enemy work (IMMUNE_* flags, signal-field code) is not in this tree; zero hits for `signal_field|chemotax|quorum|IMMUNE` outside DESIGN docs.
- **No spotter, caller, or garrison entities/roles** — the only "caller" hits are English prose in doc comments. The shrieker's rally is the closest existing ancestor of a caller.
- **No flocking/boids/kin field** — no group cohesion of any kind; enemies pile up purely via physics contacts.
- **No shrieker mark/glob mechanic, no marker projectile, no warden engulf, no two-mode caller** — those belong to the discarded experimental branch (recoverable at 94b3397b), not this base.
- **No enemy hearing of actual game sounds** (fx sounds are cosmetic; alerts are the separate hop-graph call), **no patrols, no search/investigate behavior, no last-known-position memory, no threat tables** (the player is the only possible target), **no enemy ranged classes besides spitter/warden spit**, **no turn-rate/rotation model**, and **no per-enemy config/flag system** (stats are the one hardwired `ENEMIES` dict — no-feature-flags law).
- `Level.exit_gate_kind` ("all enemies of this kind must die to exit", `_exit_scan` sim.py:2644–2660) exists as machinery but no level JSON sets it; the streamer sets `exit_gate_polygons` (stream.py:115) to scope it per-chunk.

Bots/tests read enemy state through `GameSession.snapshot()` (sim.py:2855–2904), which exposes per-enemy `id, kind, polygon, pos, hp, state, hops`; any new AI state that bots must react to needs to be surfaced there.

---

# D. Portal/connect machinery & the engine API surface the marrow needs

Engine = Rust crate `necore_core` (`engine/necore/src/{world,physics,query,visibility,geom,math,soft,raster}.rs`), exposed to Python as module **`necore`** via PyO3 bindings in `engine/necore-py/src/lib.rs` (maturin build, `module-name = "necore"` in `engine/necore-py/pyproject.toml`). All matrices cross the boundary as **row-major 9-tuples of f64** (`M9`); angles are radians; all Rust errors surface as `ValueError`. The game holds exactly one `necore.Sim` per `GameSession` (`game/perihelion/sim.py:259-260`).

## D.1 Full public API of `necore`

Module registration: `lib.rs:829-845`. Two classes + 11 module functions. **Nothing else exists.**

### `necore.Sim` (lib.rs:86-557)

World construction / topology:
- `Sim()` — empty world.
- `add_polygon(verts: list[(x,y)]) -> int` — convex polygon; verts re-centered on centroid, rewound to canonical winding. Errors: NotConvex/TooFewVerts/DegenerateEdge. Returns polygon id (append-only; **ids are stable forever — there is no polygon-removal API**). (`world.rs:92-129`)
- `connect(a, ea, b, eb) -> None` — glue edge `ea` of polygon `a` to edge `eb` of `b` (see D.2). Error `EdgeOccupied` if either edge already has a portal; supports self-connection and mirror (a==b, ea==eb).
- `connect_with_xform(a, ea, b, eb, m9) -> None` — arbitrary invertible transform mapping b-local → a-local; caller owns geometric sanity (`world.rs:272-293`).
- `disconnect(a, ea) -> None` — removes the portal AND its paired reverse side; bumps `topology_version`; no-op if edge has no portal (`world.rs:326-335`).
- `split_edge(polygon, edge, t0, t1) -> int` — split a SOLID wall edge into three collinear sub-edges at parametric t0<t1; returns the middle sub-edge index (the doorway-to-be). Refuses occupied edges and degenerate t. **Every portal anywhere targeting a later edge of this polygon is remapped (+2) engine-side; Python-side (polygon,edge) maps must apply the same shift themselves** (`world.rs:344-391`, warning repeated in the binding docstring lib.rs:124-127).
- `num_polygons() -> int`; `polygon_verts(r) -> list[(x,y)]` (polygon-local, centroid at origin); `polygon_portals(r) -> list[None | (target_polygon, target_edge)]` (per edge); `portal_xform(r, e) -> M9 | None`; `edge_endpoints(r, e) -> (x1,y1,x2,y2)`; `edge_midpoint(r, e) -> (x,y)`; `edge_normal(r, e) -> (nx,ny)` (unit **inward**); `polygon_radius(r) -> float` (bounding radius).

Walk-mask terrain: `set_polygon_terrain(r, rects)` (list of `(lo_x,lo_y,hi_x,hi_y)` local AABBs, wholesale replace, empty clears), `polygon_terrain(r)`, `set_terrain_block(group, blocked)` (all groups blocked by default), `terrain_light_segments(r)`, `terrain_avoid_dir(r, x, y, radius, dx, dy, lookahead=40.0) -> (dx,dy)` (head-on-deadlock steering for seek AI, `query.rs:296-331`).

Entities:
- `spawn(polygon, x, y, radius, mass, group) -> id` — clamps spawn point decisively inside the polygon (`physics.rs:177-233`). Defaults: `rest_wall=0.0, rest_ent=0.3, max_substep=max(radius,1), transfers=True`.
- `remove(id)`, `exists(id) -> bool`.
- `set_vel(id, vx, vy)`, `set_pos(id, x, y)`, `set_dir(id, dx, dy)` (normalized).
- `set_props(id, rest_wall=None, rest_ent=None, max_substep=None, transfers=None, radius=None, mass=None, group=None)` — partial update.
- `get(id) -> (polygon, x, y, vx, vy, dx, dy)`; `get_radius(id)`; `get_polygon(id)`; `polygon_entities(polygon) -> list[id]` (the spatial index).
- `set_collision_pair(g, h, on)` — 16 groups, symmetric mask.
- `set_active_within(polygon, hops)` / `set_all_active()` — BFS activity gate; **entities in inactive polygons are completely skipped by `step()`** (`physics.rs:264`).
- Soft walls (Otherworld): `soften_polygon(polygon)`, `soft_wall_impulse(polygon, edge, t, magnitude)`.

Simulation: `step(dt) -> list[event tuples]` (see D.8).

Queries (see D.6/D.7): `visible_set(camera_polygon, cam_m9, apex_x, apex_y, screen_w, screen_h, max_depth, max_instances)`, `raycast(polygon, ox, oy, dx, dy, max_hops, max_len, mask, ignore=-1)`, `next_edge(from_polygon, to_polygon) -> int`, `hop_distance(a, b) -> int`, `polygons_within(polygon, hops) -> list[int]`.

### `necore.Raster` (lib.rs:598-754)
Software rasterizer, not marrow-relevant: `Raster(w,h)`, `.width/.height`, `begin(bg_rgba=0x000000FF)`, `set_darkness(on)`, `set_lightmap(data)`, `add_clip(pts, coverage=True) -> int`, `add_xform(m9) -> int`, `set_texture(id,w,h,data)`, `draw(cmds, coords)`, `draw_blob(cmds, coords, xform_idx, clip_idx)`, `finish() -> bytes`, `finish_into(buf)`.

### Module functions (lib.rs:758-827)
`mat_mul(a,b)`, `mat_inv(m)` (ValueError if singular), `mat_apply(m,x,y)` (full affine), `mat_apply_dir(m,x,y)` (**linear part only — includes scale, no translation, NOT normalized**), `mat_translate(x,y)`, `mat_rotate(theta)`, `mat_scale(sx,sy)`, `mat_rotation_angle(m)` (`atan2(m[3], m[0])`), `mat_identity()`, `clip_polygon(subject, clip)`, `clip_polyline(pts, clip)` (convex clip).

## D.2 `connect()` — exact semantics and the derived scale

`world.rs:155-199`. Both polygons wind the same way, so glued edges must run in **opposite directions** when overlaid (the t→1−t flip): a's edge start pairs with b's edge end (`M·pb1 == pa0`, `M·pb0 == pa1`). The transform is built as rotation `θ = ang(da) − ang(−db)` composed with **uniform scale `s = la/lb`** (line 191: `let s = la / lb;`) where `la`,`lb` are the two edge lengths — **scale is DERIVED from any length mismatch, it is not an optional field you can leave unset.** Mutually inverse transforms are installed on both edges (`install_portal`, world.rs:295-324); `topology_version` bumps.

**Probe (tools/design/probe_portal_scale.py), executed against the real engine 07-25 — measured facts:**

| edge a (len) | edge b (len) | `portal_xform(a,ea)` scale | verdict |
|---|---|---|---|
| 96.00 | 96.00 | 1.000000 | RIGID (exactly, not approximately) |
| 96.00 | 52.00 | 1.846154 (= 96/52) | SCALED — bodies resize crossing |
| 52.00 | 96.00 | 0.541667 (= 52/96) | SCALED |

The probe carves both sub-edges with `split_edge`, connects, and reads scale as `hypot(m[0], m[3])` of the returned M9. **Marrow construction rule (DESIGN_7_25.md §1, "How the scaling factor is actually avoided"): carve both sides of a breach at the same width, then assert `abs(scale − 1) < tol` at breach-construction time.** This is the verified root cause of the prior build's "reinforcements can't fit through the gate" failure — the fit gate is physical: `physics.rs:350` `fits = 2.0 * e.radius <= edge_len * 1.05`; an entity whose diameter exceeds the portal opening treats it as a wall and never transfers.

What a portal carries (`world.rs:6-14`): `Portal { target_polygon, target_edge, xform: Mat3, inv: Mat3 }`. On transfer, position/velocity go through the **full affine** (`inv.apply`, `inv.apply_dir` — velocity scales with the portal, radius does NOT: the entity keeps its numeric radius in the new polygon's local metric). `rebuild_portal_pair` (world.rs:207-270, used by the soft-wall system when doorway endpoints move) is **pub in Rust but NOT exposed in the bindings.**

## D.3 `carve_door` — exists, but in Python, not the engine

**There is no engine-level `carve_door`.** The engine primitive is `split_edge` (D.1). What exists:

1. **`GameSession.carve_door(self, polygon: int, near, width: float = 70.0) -> int | None`** (`game/perihelion/sim.py:1035-1060`). Scans every portal-free edge of `polygon`, requires span ≥ `width + 8.0`, clamps the cut center at least `width/2 + 3.0` from each corner, picks the edge whose feasible cut point is nearest `near` (polygon-local), calls `self.sim.split_edge(polygon, e, t0, t1)`, then `self._shift_edge_maps(polygon, e)`, returns the mid-edge index or `None` if no wall has the span.
2. **`GameSession._shift_edge_maps(polygon, edge)`** (`sim.py:1102-1117`) — the mandatory Python-side companion: remaps `door_edges`, `doors[*].ea/eb`, and cloister links by +2 for edges > `edge` in that polygon. **Any new Python-side (polygon,edge) registry (breach records!) must be added here or apply its own shift.**
3. **`WorldStreamer._carve_in_chunk`** (`game/perihelion/stream.py:193-220`) — the robustness pattern: try `carve_door` at the target polygon; if portal-saturated, BFS outward within the chunk to the nearest carvable wall (`DOOR_W = 70.0`, stream.py:23). Raises RuntimeError if nothing carvable.
4. The **LevelBuilder** doorway path is build-time only: `LevelBuilder.resolve()` in `game/perihelion/levels.py:348+` matches touching edges; runtime carving is exclusively `split_edge`-based.

A runtime wall-cut for a breach is therefore: `carve_door(chamber, pos, W)` → carve the hub side at the **same W** → `sim.connect(chamber, mid_a, hub_polygon, mid_b)` → assert scale 1. Precedents already in-tree doing exactly this shape: the portable-hole shot (`_hole_shot`, sim.py:972-1033 — two splits, a fresh corridor polygon, two connects, including the delicate same-polygon "+2 after the second split" bookkeeping at sim.py:1015-1022) and the streamer's spine (`_build_spine`/`_load_next`, stream.py:238-297).

## D.4 Runtime connect/disconnect on a live session

**Yes — fully supported and already exercised mid-session.** Live precedents: cloister attach/rotate (`_attach_cloister` sim.py:1228-1234 does `sim.disconnect(corridor, 2)` then `sim.connect(...)` on player transfer events); shoot-doors (`sim.connect` inside the wall-event consumer, sim.py:2032); hole corridors; streamed chunks (`append_chunk` sim.py:1062-1100 adds polygons + connects while the game runs).

- **Polygon renumbering: none, ever.** Polygons are append-only; ids never shift. Only **edge indices** shift (+2, split_edge, same-polygon-later-edges only), engine-remapped internally, Python-remapped via `_shift_edge_maps`.
- **Visibility cache invalidation: none needed engine-side.** `visible_set` is stateless — recomputed from the live portal graph every call. Router invalidates itself (D.6).
- **Game-side stale-cache hazard (real):** `LightingSystem` bakes static-light instances once at `add_lights` time (`game/perihelion/lighting.py:242-253`) and **never recomputes on topology change** — a runtime breach next to a static fixture will not spill/unspill that light until the cache is rebuilt. Attached lights (the player lamp) recompute per frame and are fine. `render.py` per-polygon blob caches are keyed by polygon id and encode shape; `split_edge` inserts collinear verts (shape unchanged), so they stay valid.
- **Closing a breach (a breach must seal): `sim.disconnect(a, ea)` is sufficient and exists.** Both sides clear atomically, the sub-edge reverts to solid wall, `topology_version` bumps, routes rebuild. The collinear split vertices remain (harmless; polygon stays convex); the same sub-edge pair can be re-connected later. **What's missing / caller-owned:** no event is emitted on disconnect (the game must drive its own breach state machine); no engine guard for an entity mid-crossing — containment is center-based (`contain_in_polygon`, physics.rs:652-684, runs unconditionally every tick), so a straddler ends up wholly on whichever side its center was, and hub-side agents are simply stranded (they keep existing; see the activity gate below); Python-side edge/door registries must be cleaned by the caller.
- **Activity gate — critical for an off-map hub:** every tick the game calls `s.set_active_within(ppolygon, ACTIVE_HOPS)` with `ACTIVE_HOPS = 5` (sim.py:661, sim.py:30). Entities in polygons more than 5 portal-hops from the player **do not move in `step()` at all** (physics.rs:264), and the game's `_enemy_ai` additionally gates on `polygons_within(ppolygon, ACTIVE_HOPS)` (sim.py:1547). A hub 10–11 hops deep is engine-frozen unless a live breach shortens the hop distance or the marrow's Python layer runs its own economy clock independent of engine physics. (Per the 07-25 rulings, far-sim is deferred — this is the mechanism an implementer must design around, stated as fact.)

## D.5 Portal transforms — semantics, composition, the TARGET→SOURCE gotcha

- **`portal_xform(a, ea)` returns the matrix mapping the TARGET polygon's local coords INTO polygon `a`'s local coords** (`Portal.xform` doc, world.rs:10: "Maps target-polygon coordinates into THIS polygon's coordinates"). To map a-local → b-local, use the paired portal `portal_xform(b, eb)` or `mat_inv`.
- **The Transfer event's matrix points the other way**: `Event::Transfer.xform` is `portal.inv` — "maps from-polygon coordinates into to-polygon coordinates: apply it to anything you were tracking in the old frame (camera, trails)" (physics.rs:39-47; used exactly so by `_cam_rebase`, sim.py:1999).
- **Raycast accumulates hit-local → origin-local**: `xform = xform.mul(p.xform)` per hop (query.rs:177); the returned M9 maps the hit polygon's frame back into the ray-origin polygon's frame. Same convention in `visible_set` instances (instance xform maps polygon-local → screen).
- Composition is plain row-major matrix product: `necore.mat_mul(outer, inner)`; chains through k portals are the product of the k portal xforms in traversal order. Mirror self-portals square to identity (world.rs test:455-465). Scale composes multiplicatively; `Mat3::linear_scale()` = √|det of linear part| (math.rs:180) is what the engine itself uses to scale entity radii for rendering (lib.rs:442-443).

## D.6 Routing and topology invalidation

`Router` (query.rs:186-255) lives inside the binding `Sim` (lib.rs:87-90). Per-destination BFS tables (unweighted hop counts) built lazily, keyed by `world.topology_version`; **any `add_polygon` / `connect` / `connect_with_xform` / `disconnect` / `split_edge` bumps the version and the next query rebuilds automatically** (`next_edge`, query.rs:236-239; regression-tested with a fail-first test at query.rs:443-483 covering both a shortcut connect and a split_edge index shift). Python surface:
- `next_edge(from_polygon, to_polygon) -> int` — edge to take FROM `from_polygon`; **−1 means both "unreachable" and "from == to"** (None→−1 mapping, lib.rs:523-535).
- `hop_distance(a, b) -> int` — 0 for a==b, −1 unreachable.
- `polygons_within(polygon, hops)` and `set_active_within` do raw BFS, not the router.

A freshly connected hub chamber is routable the same tick; a sealed breach drops out of routes the same tick. AI call sites that depend on this: sim.py:1642-1648, 1750, 1815, 1974, 2421, 2575.

## D.7 Raycast / visibility for a find/senses layer

- **`raycast(polygon, ox, oy, dx, dy, max_hops, max_len, mask, ignore=-1)`** (query.rs:40-182, binding lib.rs:491-521). Crosses portals up to `max_hops`; walls always stop it; `mask` is a bit-per-entity-group filter (`1 << group`; `mask=0` = walls only — the hole shot uses this, sim.py:976); `ignore` excludes one entity id. Returns tuples: `("wall", polygon, edge, x, y, dist, hops, m9)` / `("ent", id, polygon, x, y, dist, hops, m9)` / `("none", polygon, x, y, dist, hops, m9)`; positions in hit-polygon-local coords; `m9` maps hit-local → origin-local; **distance accumulates in each polygon's local metric** (intentional: ranges breathe through scaling portals).
- **`visible_set(...)`** — portal-clipped visibility from an apex. Per instance: `(polygon, m9_xform, depth, clip_screen[(x,y)...], walls[(ax,ay,bx,by,is_portal)...], entry_edge (−1 = camera polygon), ents[(eid, sx, sy, sdx, sdy, sradius, fully_inside)...])`, with portal-straddling entities duplicated into neighbor instances (lib.rs:449-472).
- **`GameSession.sight_map(polygon, x, y, radius=700.0, max_depth=4, max_instances=24)`** (sim.py:2775-2810) — the ready-made senses primitive: wraps `visible_set` from an arbitrary viewpoint, returns `[{polygon, xform (polygon-local → viewer-centred), clip}]`; complement of the clips is real shadow/cover. Paired with **`GameSession.point_in_sight(sight, polygon, px, py)`** (sim.py:2812-2835, even-odd test). "Is there an active portal here?" = `sim.polygon_portals(r)` (per-edge None/(target, edge)).
- **NOT exposed:** `geom::point_in_polygon` / `depth_in_polygon` exist in Rust (geom.rs:257, 274) but have **no binding**; Python does its own even-odd tests (sim.py:2812, lighting.py:140). `necore.clip_polygon` is available for region intersection.
- Apex hygiene: cast from a point strictly inside the polygon or the traversal culls the entry portal — see `_clamp_apex` (sim.py:2718-2743).

## D.8 The event stream and how the game consumes it

`sim.step(DT)` (DT = 1/60, sim.py:21) returns a flat list of tuples (encoding lib.rs:52-70; source structs physics.rs:37-77):
- `("transfer", ent, from_polygon, to_polygon, edge, m9)` — `edge` is the FROM-polygon edge index; `m9` maps from→to. **Fires for every transferring entity, player, enemy, or bullet** — the breach "anything crossing the line" rule can be implemented purely by reading these. Today `_consume_events` (sim.py:1987-2058) only acts on player transfers (camera rebase, cloister rotate, metrics); enemy/bullet transfers are silently ignored.
- `("wall", ent, polygon, edge, x, y, nx, ny, speed)` — consumed for door bumps, soft-wall impulses, shoot-door opening, bullet impact/decal/removal.
- `("terrain", ent, polygon, terrain_idx, x, y, nx, ny, speed)` — same physics as wall; distinct tag for feedback only.
- `("contact", a, b, x, y, nx, ny, rel_speed)` — deduplicated per pair per tick; consumed by `_contact` (sim.py:2080-2140) for bullet damage and touch damage.

Non-transferring entities (`set_props(id, transfers=False)`, e.g. cloister turrets sim.py:1221) treat portals as walls and emit wall events at them.

## D.9 Physics: impulses, forces, mass

- **There is no force/impulse/acceleration API in the engine.** Entities are velocity-driven: game code writes `set_vel` every tick (player control, enemy AI), and friction is applied game-side (`_apply_friction`, sim.py:727-733) because it's "artistic."
- **Mass representation:** `Entity.mass: f64` (physics.rs:27), set at `spawn(..., mass, ...)`, mutable via `set_props(mass=...)`. Game values: `PLAYER_MASS = 1.2` (sim.py:36), per-kind `ENEMIES[kind]["mass"]`.
- **Where the engine uses mass:** entity–entity contact resolution — restitution impulse `j = −(1+rest)·rel_n / (1/mₐ + 1/m_b)` applied by inverse mass, positional separation split by inverse mass (physics.rs:497-523). Wall bounce uses `rest_wall` only.
- **Current knockback (the pattern to replace):** `_damage_enemy` does a direct read-modify-write, `set_vel(eid, evx + ndir·knock/m)` with `m = ENEMIES[kind]["mass"]` (sim.py:1441-1443) — mass-scaled Δv, but a velocity write, which DESIGN_7_25 §"All weapons push" explicitly forbids for the rebuild ("force through the physics (mass-scaled impulse), never a direct velocity write"). **Honest gap:** implementing that ruling needs either a new binding (`apply_impulse(id, jx, jy)` doing `e.vel += J/m` engine-side — a ~6-line addition to lib.rs + no core change, since Δv=J/m is the whole operation for a point mass) or a game-side impulse accumulator that sums J per tick and applies one `get`+`set_vel` before `step` — the engine as it stands offers only `set_vel`.
- Substep integrity: `max_substep` (units per substep, default `max(radius,1)`; player 6.0, bullets 3.0) gives no-tunneling for 4000 u/s projectiles; corner-trap detection kills velocity rather than hang (physics.rs:14-17, 291-297). `contain_in_polygon` + `push_out_of_terrain` run unconditionally at tick end — center-in-polygon is an engine invariant downstream code may assume (physics.rs:582-588).

### Summary of what does NOT exist at this base (build list for the marrow)
- No engine `carve_door` (Python `GameSession.carve_door` exists); no breach/portal lifecycle events; no `apply_impulse`/force API; no polygon removal; no edge re-merge after `split_edge` (sealed = solid sub-edge, cosmetically identical); no binding for `point_in_polygon`/`depth_in_polygon` or `rebuild_portal_pair`; no engine-side far-simulation (activity gate is player-centric BFS, ACTIVE_HOPS=5); no automatic invalidation of the game's static-light cache on topology change; no scale-assertion anywhere — the s=la/lb guard must be added at breach construction.

---

# E. Worldgen, levels, and where a hub attaches

All paths relative to repo root `/home/login/PycharmProjects/noneuclideantopdownshooter`, branch `rewrite` @ `87c39f7d`.

## E.1 Level format v2 and the two coordinate frames

`game/perihelion/levels.py` (538 lines) owns the JSON format, the loader, and the programmatic builder.

**AUTHORED frame vs CENTERED frame.** Polygons are authored as absolute vertex lists on one shared editor canvas. The engine (`engine/necore/src/world.rs:90-101`, `World::add_polygon`) re-centers every polygon on its area-weighted centroid, so the Python loader pre-converts everything: `level_from_dict` (levels.py:158) computes the same centroid (`_centroid`, levels.py:133-148, exact match to the engine formula) and stores `polygon_verts` as **polygon-local** coords (centroid at origin). Every positional field in a loaded `Level` — entity positions, `player_pos`, `exit_pos`, terminal and light positions — is already polygon-local (authoring pos minus that polygon's centroid; see the `local()` closure at levels.py:193). The original authoring-canvas centroids are preserved in `Level.polygon_centroids`. Anything that talks to a live `necore.Sim` (entity spawns, raycasts, `carve_door`) works in the CENTERED frame; anything that talks to a `LevelBuilder` (`connect_pts`, `door_pts`, `entity`) works in the AUTHORED frame.

**Winding rule.** Engine-canonical winding is negative shoelace = y-down visual-CCW. `level_from_dict` raises `ValueError` on a positive-shoelace polygon (levels.py:169-174) because the engine would silently rewind and renumber edges, breaking authored connection indices. `LevelBuilder.ngon` generates canonical winding by decreasing angle (levels.py:303-313); `LevelBuilder.poly` rewinds if needed but then edge indices follow the REWOUND order (levels.py:315-320) — prefer authoring canonical.

**`Level` dataclass** (levels.py:78-120), fields relevant here: `polygon_verts` (local), `polygon_centroids` (authoring), `polygon_seeds` (detail seeds, default `ri*7919+13`), `polygon_kinds` (function tags), `connects: list[(a,ea,b,eb)]`, `connects_x: list[(a,ea,b,eb,m9)]` (explicit 3x3 transform), `doors: list[DoorSpec]`, `entities: list[(polygon, EntitySpec)]`, `player_polygon/player_pos`, `exit_polygon/exit_pos/exit_key/exit_gate_kind`, `alert_hops`, `vigil`, `key_meta: dict[str, KeyMeta]`, `polygon_descent: list[float]`, `terminals`, `lights: list[LightSpec]`, `texture_map: dict[int, (level_id, local_idx)]`, `level_id` (JSON stem, set by `load_level`; keys the bespoke floor-texture path `assets/textures/<level_id>/polygon_<index>.png`).

Entry points: `load_level(path) -> Level` (levels.py:151), `level_from_dict(data)` (158), `save_level(level_dict, path)` (254). `DoorSpec(a, ea, b, eb, key)` (levels.py:28-33) — `key` is an arbitrary string id ("red", "gold", "shoot"); empty string is reserved/unimplemented.

## E.2 LevelBuilder API (levels.py:265-538)

Accumulates a raw level dict in AUTHORED coords. Class docstring is load-bearing: *"Polygons may be placed anywhere on the canvas — including on top of each other; only connections define adjacency."* Disconnected island polygons are legal at every layer (builder, loader, engine).

- `polygon(verts, detail_seed=None, kind=None) -> int` (:286); `rect(x, y, w, h, seed=None, kind=None) -> int` (:299) — **rect edge indices are stable and documented: 0=west, 1=south, 2=east, 3=north** (y-down; relied on across the tools); `ngon(cx, cy, r, n, phase=0.0, ...)` (:303); `poly(verts, seed=None)` (:315); `set_kind(polygon, kind)` (:296).
- `connect(a, ea, b, eb)` (:483), `connect_x(a, ea, b, eb, m9)` (:486), `door(a, ea, b, eb, key)` (:489) — raw index-based; must reference polygons the doorway-splitter never touches.
- `connect_pts(ra, pa, rb, pb)` (:322) / `door_pts(ra, pa, rb, pb, key)` (:328) — connection resolved to the **nearest edge by midpoint at build time**, safe across the splitter pass (which renumbers edges). This is the preferred authoring API.
- `no_connect(ra, rb)` (:341) — forbids the splitter/autoconnect from opening a doorway between two polygons; their shared wall stays a wall (used 30 times by the Marathon maze stamp to preserve 5D overlaps).
- `entity(polygon, type_, pos, **props)` (:492), `player(polygon, pos)` (:498), `exit(polygon, pos, key="", gate_kind="")` (:501), `terminal(polygon, pos, text)` (:516), `light(polygon, pos, color, intensity, radius, kind)` (:521), `key_meta(key, item_name, gate_name, gate_prompt, acquire_prompt)` (:332). `radio()` raises `RuntimeError` — eliminated (:511).
- `resolve(tol=0.5) -> dict` (:348) — the build pipeline, three passes in order: **(1) doorway-splitter** (:367-414): where a short edge lies collinear and opposite-directed inside a longer wall (both endpoints within `tol=0.5` of the wall's line, contained in its span), insert vertices into the long wall so an exactly-matching sub-edge exists; loops to fixpoint (guard 200). **(2) point-authored doors resolved FIRST** so autoconnect can't steal their edges (:438-444), then `connects_pts` (raises on already-used edges, :445-455). **(3) autoconnect** (:457-475): every remaining exactly-coincident opposite edge pair (endpoints within tol, not in `no_auto`) gets welded into a portal.
- `build() -> Level` (:531) validates (winding/schema/spawn) and returns a loaded Level; `to_dict()` (:536) returns the resolved dict for `save_level`.

Practical consequence: authoring two polygons flush with a short "door stub" edge on one of them auto-creates a doorway of exactly the stub's width; `no_connect` is the opt-out; `connect_pts` is for non-adjacent (non-Euclidean) joins.

**Engine connect scaling — the breach-guard fact.** `World::connect` (engine/necore/src/world.rs:155-192) *derives* a uniform scale `s = la/lb` from the two glued edge lengths (world.rs:187) and bakes it into the portal transform. Equal lengths → pure isometry; mismatched lengths → bodies resize crossing the portal. This matches DESIGN_7_25.md §1 ("How the scaling factor is actually avoided"): carve both sides at the same width, then assert `portal_xform` scale == 1. Precedent for enforcement: `_rigidify(level)` in `tools/musiccal/build_gauntlet3.py:267` forces every portal in the gauntlet rigid and **raises** if any seam is left scaled.

## E.3 The canonical level: `levels/gauntlet4.json`

Byte-identical to `levels/gauntlet_cal3.json` (verified with `cmp`); both are the output of `tools/musiccal/build_gauntlet3.py` (736 lines; `main()` at :721, default `--out levels/gauntlet_cal3.json`, `--n 180 --min-sep 90 --seed 1`). Internal name is `"GAUNTLET III — TACTICAL CALIBRATION"` (the file name, not the `name` field, is canonical). Facts as measured from the JSON:

- **version 2, tier 3, ambience `amb_drone_late`, `alert_hops: 1`**, no `vigil` key.
- **163 polygons, 173 connects, 0 connects_x, 0 doors, 105 lights, 0 terminals, 0 radio, no keys.** Player: polygon 0 at authored `(-490, 60075)`; exit: polygon 162 at `(120130, 60075)`.
- **Topology is a linear chain** (spawn → 6 combat segments → exit), built by `build_gauntlet3.py:640-719`: spawn rect (kind `storage`) → per segment *i*: 3-piece **kite lane** (LANE_LEN 1050, LANE_W 150) with a 170-wide **sentry alcove** and a non-Euclidean double-back (lane's far end portals to its start) → **choke** (CHOKE_W 64) → **arena** (polygon groups copied verbatim from campaign levels l04/l05/l06/l07 via `tools/musiccal/build_gauntlet.py`'s `SEGMENTS`/`add_segment`, with texture provenance) → **adapter trapezoid** back to LANE_W. Boss chambers are spliced after segments 1-4 (`BOSSES = {1: boss_donut, 2: boss_cross, 3: boss_ring, 4: boss_dark}`, build_gauntlet3.py:611).
- **Polygon kinds** present: corridor 120, storage 15, hall 11, quarters 6, medbay 4, chapel 3, transit 2, pump 1, core 1.
- **Enemies/props/pickups are authored inline** per polygon (`"entities": [{"type", "pos", "props"?}]`, AUTHORED frame). Counts: husk 60, mite 39, spitter 33, brute 28, flicker 25, shrieker 20, warden 14 (bosses+guards), sentry 36 (friendly turrets), medkit 60, ammo_9mm 18, ammo_shell 18, ammo_cell 12. No entity in this file uses `props`. Placement is `populate()`'s spread discipline over arenas+lanes only; spawn/chokes/alcoves/boss polygons stay clear, plus a medkit every ~3rd combat polygon (build_gauntlet3.py:696-708).
- **`texture_map`** (25 entries): polygon index → `[src_level_id, src_local_idx]`, floor-texture provenance for the copied arena polygons.
- **`boss_polygons`** (`{"1": [25..46], "2": ..., "3": ..., "4": ...}`, 19-22 polygons each): tool-side metadata for per-boss fail attribution. **`level_from_dict` silently drops it** — it is not a `Level` field and nothing at runtime reads it; only musiccal tools consume it from the raw JSON.
- **All portals are rigid** (pure isometries) — `_rigidify` ran at generation.

Loading paths: `uv run python -m perihelion --level levels/gauntlet4.json` (game/perihelion/__main__.py:10); campaign mode loads `levels/campaign.json` manifest (l01-l10) through `WorldStreamer` (app.py:566-640); farm/playtest tools default to gauntlet4 (e.g. `tools/playtest/replay_study.py:45`).

## E.4 How tools/levelgen generates levels

`tools/levelgen/campaign.py` (291 lines): ten level functions `l01()..l10()` along the escalation curve (deniable wrongness → confirmable paradox → overt impossibility → pure graph), each now a thin delegate to a standalone dense module in `tools/levelgen/dense/l01.py..l10.py` (~120-cell Marathon-density rebuilds; cell rhythm 60/90/150/220 u per their docstrings). Each returns a `LevelBuilder`; `main()` (:267) writes `levels/l01.json..l10.json`, `levels/vigil.json` (the `vigil()` holdout arena, built inline at :224-260 — hex core + 6 petals via `ngon`+`connect_pts`), and the `levels/campaign.json` manifest. Shared authoring helpers worth reusing: `wall_basis(b, polygon, wall, t)` (:45, wall midpoint/tangent/inward-normal in AUTHORED coords), `wall_pos` (:70), `cache` (:79), `squad` (:35), `sector_ring` (:103).

`tools/levelgen/arrival_maze.py`: `build_maze(b, origin, scale=80.0) -> dict` stamps the 66-cell Marathon 1 "Arrival" east maze into any builder; returns graft points `entry/exit/exit2/north/west/west2` as `(builder_polygon_id, (x,y))` ready for `connect_pts`. `tools/levelgen/INTEGRATION.md` documents graft widths (entry 66 u, others 40 u) and warns explicitly that `connect` scales span-onto-span when lengths differ.

**"Chunks"** in this codebase means streamed campaign chunks, owned by `game/perihelion/stream.py` (`WorldStreamer`): each levels/*.json is lazily appended into ONE live sim as the player advances; chunk k's exit gets a carved doorway into a synthetic two-polygon transit spine (`SPINE_LEN 260, SPINE_W 70, DOOR_W 70`, stream.py:21-23); entering the spine loads chunk k+1 (`_load_next`, :273) and welds it on. `polygon_descent` (the depth gradient driving palette) is owned by the streamer: chunk k of N gets k/(N-1), spines get the midpoint.

## E.5 "Off the reachable map" — exact mechanisms and constraints

Four distinct mechanisms exist at this base; a hub can use any combination:

1. **Doors are pending connections** (the module docstring, levels.py:6-7). A `DoorSpec` in the JSON produces NO portal at build time: `GameSession.__init__` stores dict records in `self.doors` / `self.door_edges` (sim.py:306-315) and only wires `level.connects`/`connects_x` into the engine (sim.py:271-274). A locked door is **genuinely a wall — no movement, no visibility, no light through it**. Opening = `self.sim.connect(d["a"], d["ea"], d["b"], d["eb"])` at runtime: on key pickup (`_unlock_doors`, sim.py:2310-2318), or on player-bullet wall hit for `key == "shoot"` (sim.py:2023-2039). So yes: **rooms can exist connected to nothing (or connected only among themselves), with authored door records naming exactly where they will attach later, and the attach is one `sim.connect` call.**
2. **Island polygons.** The builder, loader, and engine all accept polygons with zero connections. They load, get textures/seeds/kinds, and simply have no address. (Nothing prevalidates reachability at load.)
3. **Runtime carving.** `GameSession.carve_door(polygon, near, width=70.0) -> int | None` (sim.py:1035-1060): finds the portal-free wall nearest `near` (polygon-local), requires wall length ≥ `width + 8.0` with `width/2 + 3` end margins, calls `sim.split_edge(polygon, e, t0, t1)` to cut an exactly-`width` sub-edge, fixes all Python-side (polygon,edge) references via `_shift_edge_maps` (sim.py:1102-1117 — a split inserts 2 edges; every stored edge index beyond it shifts by +2), and returns the new edge index ready for `sim.connect`. `WorldStreamer._carve_in_chunk` (stream.py:193-220) adds the fallback: BFS outward within the chunk to the nearest polygon with a carvable wall (portal-saturated polygons exist), `RuntimeError` if none.
4. **Runtime polygon creation.** Two shipped precedents: **(a) the cloister** (`_build_cloister`, sim.py:1200-1226): an 8-gon sanctum + 36×15 corridor added mid-session with `sim.add_polygon`, "an isolated pocket with no address"; it is attached to wherever the portable hole last cut via `_attach_cloister` (sim.py:1228-1234) which does `disconnect(corridor, 2)` then `connect(polygon, edge, corridor, 2)` — proving portals can be re-pointed dynamically. **(b) `append_chunk(level) -> offset`** (sim.py:1062-1100): streams a whole loaded `Level` into the live sim — polygons, walk-masks, connects, doors (re-indexed by `offset` into the same pending-connection machinery), terminals, entities, lights, seeds, kinds. This is the ready-made "load an entire authored off-map area at runtime" API; a hub authored as its own levels/*.json could be appended with it and attached by a carved breach.

**Bookkeeping contract for synthetic polygons** (what `_build_spine`, stream.py:238-271, does and the cloister does only partially): extend `level.polygon_seeds`, `level.polygon_kinds`, `level.polygon_verts`, `level.polygon_centroids`, and the descent list, or the renderer/detail systems index past their arrays. `append_chunk` handles all of this; raw `sim.add_polygon` callers must do it by hand.

**Engine constraints on attach:** `connect` fails if either edge already has a portal (`disconnect(a, ea)` exists, engine/necore-py/src/lib.rs:120); `connect` derives scale `s = la/lb` (world.rs:187) — **carve both sides at the same width and assert `portal_xform(r, e)` (lib.rs:150) is scale-1**, per DESIGN_7_25.md; `split_edge` renumbers edges — always route through `carve_door`/`_shift_edge_maps` rather than calling it raw when door/cloister records exist.

**The activity gate (what "off-map" costs).** Every tick, `GameSession.tick` calls `s.set_active_within(ppolygon, ACTIVE_HOPS)` with `ACTIVE_HOPS = 5` (sim.py:30, :661). Engine side (engine/necore/src/physics.rs:156-175) this BFS-marks polygons within 5 portal hops of the player; `step_entity` skips entities in inactive polygons entirely. Python side, `_enemy_ai` independently gates on `set(s.polygons_within(ppolygon, ACTIVE_HOPS))` and `continue`s past enemies outside it (sim.py:1545-1551). Concretely: **an off-map hub more than 5 hops from the player is fully frozen — no physics, no AI — until a breach shortens the hop distance or the hub's logic runs outside the per-entity AI loop.** (`set_all_active()` exists, lib.rs:375. Prior investigation pinned a dead-reinforcements bug on portal scale mismatch, not on ACTIVE_HOPS; far-sim redesign is explicitly deferred.)

## E.6 Room metadata a hub-builder / breach prevalidator can query

Level-side (static, per loaded `Level`): `polygon_kinds[i]` (observed vocabulary: dock, corridor, storage, lab, quarters, chapel, core, hall, medbay, pump, transit, generic, plus special `otherworld` = soft walls, softened at session init sim.py:371-374), `polygon_centroids[i]` (AUTHORED frame — pairwise canvas distances are meaningless across portals; use hop metrics), `polygon_seeds[i]`, `polygon_descent[i]`, `texture_map`, `level_id`, `entities`.

Engine-side (live, `necore.Sim`, signatures from engine/necore-py/src/lib.rs): `num_polygons()`, `polygon_verts(r)` (CENTERED frame, reflects soft-wall deformation), `polygon_portals(r) -> list[Option[(target_polygon, target_edge)]]` per edge (**`None` = solid wall — the carvable-wall test**), `portal_xform(r, e) -> m9 | None`, `edge_endpoints(r, e) -> (x1,y1,x2,y2)`, `edge_midpoint(r, e)`, `edge_normal(r, e)`, `polygon_radius(r)` (lib.rs:181, the engine's cached bounding radius), `polygon_entities(r) -> list[id]`, `polygons_within(r, hops)`, `hop_distance(a, b) -> i64` (-1 if unreachable — the "is it off-map" oracle), `next_edge(from, to)` (router), `raycast(polygon, ox, oy, dx, dy, max_hops, max_len, mask, ignore)`, `visible_set(camera_polygon, cam_m9, apex, w, h, max_depth, max_instances)`, `polygon_terrain(r)` (walk-mask rects).

**Area is not exposed anywhere public**: levels.py's `_shoelace` is module-private; ready-made helpers `poly_area`, `point_in_poly`, `dist_to_edges` live in `tools/musiccal/build_gauntlet2.py` (imported by build_gauntlet3.py:39-41). A breach prevalidator's wall test today is: for each edge with `polygon_portals(r)[e] is None`, `edge_endpoints` length ≥ desired width + 8 (carve_door's own margin).

## E.7 Props, decals, pickups — placement and metadata

- **Authored entities** (the only authored "props"): per-polygon JSON `entities` → `EntitySpec(type, pos, props)` → `GameSession._spawn_from_spec` (sim.py:438-461) routes by type table: `ENEMIES` (sim.py:77-116; supported props: `hp` float override, `tether` flag), `SENTRIES` (:163), `PICKUPS` (:118-134: ammo_9mm/shell/cell, medkit, weapon_smg/shotgun/rail/tau, portable_hole, safe_polygon_core, turret, implant_lightning, key_red/blue/gold/void, components, corpse_frame, organ_gland), literal `"player"` ignored, anything else raises `ValueError`. Pickups/sentries spawn as real physics entities (GROUP_PICKUP, mass 100, `transfers=False`). Key pickups carry `KeyMeta` for diegetic naming.
- **Decals are runtime-only, never authored, never persisted**: `self.decals: dict[polygon -> [(kind, x, y, size, angle)]]`, appended by `_decal` (sim.py:509-514), capped at 250 per polygon (corpses, scorch, etc.).
- **Lights** are authored (`lights` list → `LightSpec`, levels.py:44-56): `kind="static"` cached at load, `"attached"` recomputed per frame; cast through the real portal visibility system. The player's own lamp is an attached LightSpec added at init (sim.py:300-304). gauntlet4 has 105 static lights.
- **Terminals** authored under `lore.terminals`; radio triggers parse but are consumed as nothing (`LevelBuilder.radio` raises, levels.py:511-514).
- **Visual floor detail** comes from `detail_seed` per polygon plus bespoke textures at `assets/textures/<level_id>/polygon_<index>.png` (redirected by `texture_map` for copied polygons). **Walk-masks** are the collision-real "painted machinery" layer: `terrain.apply_walk_masks(sim, level, polygon_offset=0)` (game/perihelion/terrain.py:244) feeds axis-aligned rects into `sim.set_polygon_terrain(r, rects)`; absence of a mask file = fully walkable.

## E.8 Scale conventions (the numbers that decide breach width)

Player: `PLAYER_RADIUS = 6.5` (diameter 13; sim.py:33), terminal speed ~133 u/s. Enemy radii (sim.py:77-116): mite **4.0**, shrieker **7.0**, husk **8.0**, flicker **8.5**, spitter **9.0**, brute **13.5**, warden **16.0**. Friendly sentry 7.0; pickups 5.0-8.0.

Door/opening widths in the shipped content: portable hole **15** (`HOLE_WIDTH`, sim.py:68 — "player diameter 13 + clearance; brutes (27 dia) excluded" — the existing proof that opening width vs body diameter is a hard gate); campaign door stubs **40-80** (Marathon scale 80 u/WU; median door 80); streamer carve width **70** (`DOOR_W`, stream.py:23; also `carve_door`'s default); gauntlet4 chokes **64** (`CHOKE_W`, build_gauntlet3.py:56). Measured portal edge lengths in gauntlet4.json: min 64, p25 150, median 150, p75 170, max 430; modal values 150 (lane joins, full corridor width), 220, 64 (chokes).

Room sizes in gauntlet4: bounding boxes run 80-700 u wide (median 160) × 60-700 u tall (median 150); corridors are LANE_W = 150 wide; campaign dense cells follow the 60/90/150/220 rhythm.

Spec arithmetic check (DESIGN_7_25.md §1b: width `max(96, 2 * largest_dispatchable_radius + 16)`): largest current radius is the warden's 16.0 → `2*16+16 = 48` → **width = 96** for the entire existing roster; the 96 floor binds, not the radius term. Note 96 is wider than every existing doorway convention (70/80/64), and `carve_door` needs a portal-free wall of length ≥ width+8 = **104 u** — satisfied by most hall/arena walls but NOT by 60-90 u cells, which is exactly what the breach-site prevalidator must check via `polygon_portals` + `edge_endpoints` (E.6).

---

# F. Buildings, economy & pickups at the base (d85d3765 lineage, HEAD 87c39f7d)

Everything in this section lives in the Python game layer (`game/perihelion/`); the Rust engine (`engine/necore`) knows nothing about economy — it only provides entity spawn/groups (`GROUP_PICKUP`, `GROUP_PLAYER`, `GROUP_ENEMY`, `GROUP_PBULLET`) that the systems below build on. The 07-10 "revival economy" (components / seed stations / fabricator / mind map) EXISTS and is fully wired. The 07-20+ CUCULUS *building* economy (player-placed sentries, repair station, scrubber, cleaning robot, carried structures) does NOT exist at this base — those are to-build per DESIGN_7_25.md.

## F.1 Components / score economy

One currency: **components** ("salvaged mass"), held as `GameSession.components` (int, `game/perihelion/sim.py:338`, initialized from `player_state`).

- **Kill drops.** `GameSession._kill_enemy(eid, polygon, pos, ndir)` (sim.py:1452) always spawns a `"components"` pickup worth `ceil(score * self._salvage_mul)` at the kill site (sim.py:1483–1489). `score` per enemy comes from the `ENEMIES` dict (sim.py:77–115): husk 1, mite 1, spitter 2, shrieker 3, flicker 3, brute 4, warden 25. `_salvage_mul` is 1.5 with the `salvage_yield_1` mind unlock, else 1.0 (sim.py:2544). Salvage income equals fight difficulty by construction (comment at sim.py:167–169).
- Additionally one roll against `DROP_TABLES` (sim.py:197–210) can drop ammo/medkit — a single first-match roll (`break` at sim.py:1475), e.g. husk: 35% ammo_9mm, 8% medkit; warden: guaranteed medkit+9mm+shell (+50% cell).
- Enemy corpses are **decals only** (`corpse_<kind>` via `_decal`, sim.py:1458). There is no harvestable enemy-corpse entity at this base (relevant to the spec's pod-roots/cleaning-robot corpse handling — to-build).
- **Player corpse frame.** On death, `_drop_corpse(polygon, pos)` (sim.py:1521–1541) spawns one `"corpse_frame"` pickup holding `contents={components, station_kits}` and zeroes both on the player; with the `protected_revival` mind unlock only kits ride the corpse (components stay banked). Weapons/holes never ride the corpse (dupe-through-cold-restore reasoning documented in the docstring). Walking over it in `_pickup_scan` refunds contents ("FRAME RECOVERED", sim.py:2274–2286) and fires a `logvoice` fx. Conservation is pinned by `game/tests/test_corpse_economy.py`; the whole economy by `game/tests/test_economy.py`.
- **What components buy.** `SHOP` price sheet (sim.py:170–179): `chassis` 8 (spare hull), `station_kit` 12, `hp_up` 10 with `growth=6` (price = `cost + growth*hp_ups`, `shop_price()` sim.py:2394), `scrap_driver` 15 (one-time), `recall` 6, `ammo_9mm` 3 /`ammo_shell` 3 /`ammo_cell` 4. Purchase logic in `GameSession.buy(item) -> bool` (sim.py:2362–2392). The **scrap driver** weapon fires components as ammo (2 per shot: `WEAPONS["scrap"]`, `ammo="components", per=2`, sim.py:56–58; ammo check sim.py:836–842). Note DESIGN_7_25.md:30 removes gland & scrap driver.
- Components/chassis/kits/mind state persist across chunks and levels via the streamer snapshot (`WorldStreamer._snapshot_state`, `game/perihelion/stream.py:117–149` — economy fields are save-file-only; `_restore_state` deliberately never restores them) and via `carried_state`/`player_state` on level advance (`app.py:659–663, 686–705`). Bot-visible state: `GameSession.snapshot()` (sim.py:2855–2904) exposes `components, chassis, station_kits, recalls, stations, mind, think_*`.

## F.2 Seed stations, pod, buy flow, respawn

- `GameSession.stations: list[dict]` of `{polygon, pos}` (sim.py:360). `add_station(polygon, pos)` (sim.py:2326) dedupes within 24u in the same polygon. Sources: the spawn point itself (sim.py:363), every streamer chunk entry (`stream.py:52–54` and `stream.py:323`), and player-planted kits.
- `place_station() -> bool` (sim.py:2349–2360): consumes one `station_kits`, plants at the player's current polygon/pos, no placement restrictions. Bound to **B** (`app.py:232–233`). `use_recall()`/`_recall_tick` (sim.py:2398–2437, key **T**): 90-tick channel, severed by any hit, teleports to nearest station.
- `station_near(ppolygon)` (sim.py:2335) uses `STATION_RADIUS = 30.0`. `_station_scan` (sim.py:2604–2608): pressing **E** near a station emits the `("shop",)` fx; `app.py:913–916` catches it and pushes `PodScene(game.session)`.
- **PodScene** (`game/perihelion/podscene.py:194`, ~1400 lines, keyboard-only, full-screen, pure vector drawing; design doc `SEEDPOD_UI_DESIGN.md` at repo root). Two tab pages (TAB/M switches): FABRICATOR (item list `FAB_ORDER` at podscene.py:199–200, Enter/Space → `session.buy(...)` at podscene.py:455–464, hero art from `assets/hero/<item>.png`, wallet in the chrome) and MIND ("ENCARTA" tab — the mind-map graph with fog-of-war, camera glide, live physics, and the ~5s unlock reveal animation). `on_enter` calls `session.pod_heal()` (podscene.py:245–246) — full heal on entering, free (sim.py:2498–2508). Hardware-class name constant `POD_UNIT_NAME = "CUCULUS"` (podscene.py:46) — the *name* predates the 07-20 building economy and is unrelated to it. Pinned by `game/tests/test_podscene.py`.
- **Death/respawn.** `respawn_at_station() -> bool` (sim.py:2566–2602): with a racked chassis, reprint at nearest station, world untouched (wreck included); returns False with no chassis/station. Caller `App.reprint()` (`app.py:667–676`) falls back to `streamer.respawn()` cold restore (chunk reseed + hp/ammo floors, stream.py:117–160). Death menu wiring in `menus.py:415–442`.
- Stations are rendered as an obelisk-on-plate fixture with a pulsing ring in `render.py:2581–2606` (inside the per-polygon fixture pass).

## F.3 Turrets / sentries — what actually exists (verify: partial, none player-buildable)

Two separate friendly-turret systems exist, both **level/script-spawned only, indestructible, and free** — there is NO buildable/carryable/destructible structure of any kind:

1. **Cloister guardians** — `self.turrets: dict[int, dict]` (sim.py:386), spawned only by `_build_cloister()` (2 fixed guardians, sim.py:1218–1222), ticked by `_turret_tick` (sim.py:1241–1269): same-polygon nearest-enemy, no range/LOS/spin-up, dmg 6, cd 16. Pinned by `test_cloister.py`.
2. **Gauntlet sentries** — data-driven `SENTRIES` dict (sim.py:156–165): `sentry` = radius 7, **dmg 18, cd 14, range 300, spin_up 10, bolt_speed 1400**. Spawned from level JSON entities via `_spawn_from_spec` (sim.py:450–451) → `spawn_sentry(polygon, pos, kind) -> int` (sim.py:489–494), stored in `self.sentries`. Ticked by `_sentry_tick` (sim.py:1325–1368) with real LOS against walk-mask terrain (`_sentry_los_clear` sim.py:1319, Liang-Barsky `_segment_crosses_rect` sim.py:1286–1317). No `hp` — indestructible by design (long comment sim.py:137–155). Both systems fire bullets tagged `kind="turret"`, which damage enemies but never the player (`_contact`, sim.py:2089, 2102–2103). Pinned by `game/tests/test_sentry_turret.py` (352 lines). Placement: 36 sentries in `levels/gauntlet4.json` (per-polygon `entities` arrays), authored by `tools/musiccal/build_gauntlet*.py`; **zero in campaign levels**.
- **Rendering gap (verified):** sentry and guardian bodies have NO draw path. `Renderer._role_kind` (`render.py:2747–2760`) maps entity ids only through `pid`/`enemies`/`bullets`/`pickups`; `self.sentries`/`self.turrets` ids return `(None, None)` and are skipped (`render.py:2770–2771`). Their bolts render as generic tracers (`_draw_bullet` else-branch, render.py:2915). The tripod glyph at render.py:2945–2951 belongs to the inert `"turret"` PICKUPS kind (sim.py:128, `_pickup_scan` treats it as furniture at sim.py:2249–2250) which **no shipped level places**. The spec's sentries (rotating, UV-laser, destructible glass cannon, DESIGN_7_25.md:205–206), repair station (:209), pheromone scrubber (:210), and cleaning robot (:211) all do not exist in any form.

## F.4 Pickups (medkits etc.) and their placement

`PICKUPS` catalog (sim.py:117–135): ammo x3, `medkit` (radius 6, amount 35), weapon_* x4, `portable_hole`, `safe_polygon_core`, `turret` (furniture), `implant_lightning`, `key_*` x4, `components`, `corpse_frame`, `organ_gland`. Spawn: `spawn_pickup(polygon, pos, kind, meta=None, extra=None) -> int` (sim.py:476–487, engine `GROUP_PICKUP`, non-transferring). Collection: `_pickup_scan(ppolygon)` (sim.py:2210–2301), walk-over radius `PLAYER_RADIUS + kind radius + 2`. Medkit specifics: refused while `hp > 70` ("leave it for later", sim.py:2227–2229); heals 35 capped at `max_hp`. Glyph rendering in `Renderer._draw_pickup` (render.py:2921–2995).

**Placement logic today — three sources, none is a "storage area" system:**
1. **Authored level JSON** — per-polygon `entities` lists parsed in `levels.py:180–183` into `Level.entities: list[tuple[int, EntitySpec]]`. Counts: campaign l01–l10 have 4–22 medkits each scattered through combat/rest spaces; `levels/gauntlet4.json` has 60 medkits and pairs them with sentry alcoves (generator: `tools/musiccal/build_gauntlet3.py`, e.g. lines 101–113, 166–169, 417–419).
2. **Random kill drops** via `DROP_TABLES` (F.1).
3. **Scripted trickle**: vigil wave pantry (every 2nd wave, sim.py:1189–1193) and the cloister pantry (medkit + 9mm on build, sim.py:1223–1225).
The spec (DESIGN_7_25.md:257) converts these to rare Testator **field-repair kits in designated storage areas** — no storage-area concept, kit item, or rarity gate exists at this base; implementing it means touching the authored JSONs/generators plus `PICKUPS`/`DROP_TABLES`/`_pickup_scan`.

## F.5 Mind map / think-focus (brief — it lives in the pod)

Module `game/perihelion/mindmap.py` (1843 lines), data `game/perihelion/data/mindmap.json` (33 nodes, regions vocation/history/comprehension/void; design doc `MINDMAP_DESIGN.md`). Expansion costs TIME not components: node weight = design-sheet `cost.components + cost.data`, think-time = weight × 600 ticks (`THINK_SECONDS_PER_WEIGHT = 10`, mindmap.py:32–33; `think_ticks()` :62). Session-side state (sim.py:344–355): `mind: set[str]`, `think_focus`, `think_progress`, `think_done` — all survive death/reprint/cold-restore. Flow: `set_focus(node_id)` (sim.py:2443, called from PodScene MIND page) → `_think_tick` accrues during field ticks only (sim.py:2460–2476) → completion queues in `think_done` → `complete_focus(node_id)` (sim.py:2478–2496) is called by the pod's reveal animation and only then adds to `mind` and rewires effects via `_recompute_mind()` (sim.py:2515–2553: damage/spread/armor/accel/crit/salvage/ammo/regen/protected-revival/hole-bonus multipliers from unlock keys). `faith` computed, never displayed (sim.py:2510–2513, `mindmap.faith_score`). API surface the pod uses: `nodes() / available() / frontier() / unlocks() / layout() / live_relax_step() / camera_glide()`. Layout determinism pinned by `game/tests/test_mindmap_layout.py`.

## F.6 Carrying / inventory — no physical carry exists

The player "inventory" is pure counters/collections on `GameSession`: `components`, `chassis`, `station_kits`, `recalls`, `holes`, `hp_ups`, `ammo: dict`, `weapons: list`, `keys: set`, `held_key_meta`. There is **no carryable world object**: no carry slot, no pick-up/put-down verb (`InputFrame` fields are mx/my/ax/ay/fire/alt/interact/weapon only, sim.py:213–227), no movement penalty hook (speed is `PLAYER_ACCEL=820` × `_accel_mul` from mind unlocks only, sim.py:773–774), and no carried-object rendering (player draws as the fixed `PLAYER_SHAPE` polygon, render.py:2773–2780). The spec's one-kit-on-back carry with slowdown and rotation rendering (and carried structures generally) is entirely to-build. (Grep confirms: the only "carry" in the codebase is `carried_state` — the between-level player_state dict, app.py:659.)

## F.7 HUD inventory (what is drawn today, where)

`HUD.draw(surf, session, mouse_pos)` (`game/perihelion/hud.py:27`), called from `GameScene.draw` (app.py:257). Elements:
- **HP bar + numeric** top-left at ui(6,12), low-hp pulse, backing plate (`_draw_hp`, hud.py:41–59).
- **Economy line** under it: `"{components}c  {n} chassis  {n} kit  {n} recall"` (+ `"{deaths} lost"` with the `loss_ledger_display` unlock); hidden until any is nonzero (`_draw_economy`, hud.py:61–84). This is the ancestor of the spec's "scrap count".
- **Think pip**: small ring filling with focus progress, pulses when a thought is done (`_draw_think`, hud.py:86–124).
- **Weapon/ammo** bottom-right: name + count; scrap shows `"{n}c"`, hole shows count + `*` when a wall is marked, tau shows charge %, lightning draws a radial recharge ring (`_draw_weapon`, hud.py:126–166).
- **Key glyphs** top-right (`_draw_keys`, hud.py:168–180).
- **Crosshair** with cooldown-expansion (`_draw_crosshair`, hud.py:182–201).
- **WAVE counter** top-left, vigil levels only (hud.py:29–32).
Also drawn by `GameScene.draw` (app.py:263–315), on top: rising **float_texts** (from `pickup_text` fx), **location title** banner (top center, font 26), **objective one-liner** (mid-screen at ui(62) — the spec explicitly retires this and the banners, DESIGN_7_25.md:238), **logvoice** line (bottom center), and the first-14-seconds **key hints** (app.py:303–315, mentions "B plant seed kit"). Spec target: strip everything top-left except the scrap count; at this base that means deleting/reworking `_draw_hp`, `_draw_think`, the wave counter, and most of `_draw_economy`, plus the app.py banner/objective code.

---

# G. Verification infrastructure

Everything below was read from the tree at `rewrite`@87c39f7d (canon base d85d3765 + design-doc commits). There is **no CI service** (no `.github/`); the only executable gate is `./check.sh` run locally. All Python runs through `uv run` (never bare python/pip).

## G.1 Test layout and the check.sh gate

**Gate:** `/home/login/PycharmProjects/noneuclideantopdownshooter/check.sh` — three stages, `set -euo pipefail`:
1. `cd engine && cargo test -p necore` — Rust engine only (**99 tests**: unit `#[test]`s per module — raster.rs 36, physics.rs 14, geom.rs 9, query.rs 7, visibility.rs 6, world.rs 3, math.rs 3 — plus integration suites `engine/necore/tests/properties.rs` (~12 `proptest!` blocks, has a committed `properties.proptest-regressions`), `tests/invariants.rs`, `tests/soft_walls.rs`). `necore-py` has no tests of its own; its binding surface is covered transitively via pytest.
2. `uv run maturin develop --release -m engine/necore-py/Cargo.toml -q` — rebuilds the `necore` extension the Python tests import.
3. `uv run pytest -q` — **623 collected tests** in `game/tests/` (pytest config in `pyproject.toml` `[tool.pytest.ini_options]`: `testpaths=["game/tests"]`, one marker `slow`; deselect with `-m "not slow"`). There is **no conftest.py anywhere** — tests are self-contained modules. ENGINE_INVARIANTS.md notes a **~90 s wall-time ceiling** for additions to check.sh.

**game/tests inventory** (37 files, 9,202 lines; one-liners from each file's own docstring):

| File | What it gates |
|---|---|
| test_audio_bank.py | WAV integrity of the generated SFX bank (`game/assets/sfx/*.wav`) |
| test_camera_phase_lock.py | camera pixel-snap regression suite (half-pixel polygon-crossing flicker) |
| test_cloister.py | safe-polygon (Cloister) links, shifting attachment, turret defense |
| test_containment.py | engine end-of-step center-in-polygon containment; game sweep is a silent backstop |
| test_convscene.py | ConversationScene machinery + no-placeholder-dialogue contract |
| test_corpse_economy.py | SIM7 wave-1: death/respawn component conservation (hypothesis) |
| test_economy.py | revival economy: salvage, corpses, chassis, seed stations, fabricator |
| test_editor.py | pure-Python editor model (`perihelion.editor.model`) load/mutate/save |
| test_flicker_campaign_placement.py | Adversary-territory flicker placement invariants |
| test_flicker_harness.py | R7 flicker gate: neighbor decal ink never blinks, real render path, `[cross]`/`[braided]` topologies |
| test_flicker_lurker.py | shadow-lurker ambush enemy + light-level query |
| test_gauntlet_calibration.py | pins committed `tools/musiccal/factor_model.json` shape/direction (hypothesis) |
| test_gauntlet_level.py | structural gates for `levels/gauntlet_cal.json` |
| test_hole_tau.py | portable hole (runtime `split_edge`) + tau cannon gates |
| test_human_bot.py | HumanBot: perception honesty, mouse realism, reaction asymmetry, determinism (`test_two_identical_human_bot_runs_are_bit_identical` at :278) |
| test_levels.py | every shipped level loads/traverses; key-before-door reachability |
| test_level_winding.py | L1 wave-1: positive-shoelace polygon rejected at load (hypothesis) |
| test_lighting_invariants.py | lighting.py properties: lights are world objects via engine `visible_set` (hypothesis) |
| test_light_occlusion_demo.py | fast deterministic occlusion gate derived from the CLI demo world |
| test_marathon_mapread.py | `tools/marathon/mapread.py` vs the one binary fixture `game/tests/fixtures/m1_5dspace.wad` |
| test_mindmap_layout.py | PBT for mind-map layout laws + real `data/mindmap.json` (hypothesis) |
| test_music_system.py | dynamic-music continuous-value properties (PRAYER/CONTEMPT/STALWART) |
| test_necore_smoke.py | PyO3 binding smoke: two-polygon world, sim, visibility, raycast, matrices |
| test_objective.py | objective prompt as the only in-combat text channel |
| test_podscene.py | seed-pod UI lifecycle, fog of war, keyboard nav (dummy video driver) |
| test_render_backends.py | rust Raster vs pygame backends produce **bit-identical frames** (R3) |
| test_render_headless.py | renderer smoke under `SDL_VIDEODRIVER=dummy`, 240 scripted ticks |
| test_render_textures.py | OP_TEX_FILL rust/numpy pixel identity + lightmap multiply |
| test_root_invariance.py | camera root-polygon choice has zero pixel consequence |
| test_seamless.py | portal transitions imperceptible: per-wall screen-space tracking across frames |
| test_sentry_turret.py | friendly sentry turret in safe corridors |
| test_stream.py | chunk streaming, spines, arrival, respawn |
| test_terrain_light_shadows.py | terrain blocks lamp light but not vision |
| test_testkit.py | determinism, replay round-trip, bot smoke completion, perf budgets (detailed below) |
| test_vigil.py | wave-director spawn/escalate/record (NOTE: DESIGN_7_25 deletes the vigil — this test + `levels/vigil.json` still exist at this base and will need removal/replacement) |
| test_walkmask_clearance_gate.py | walk-mask clearance (BFS-passes-but-too-narrow regression) |
| test_walk_mask_terrain.py | `<texture>_walkmask.png` → collision rects; absent mask = fully walkable |

## G.2 Playtest bot machinery (`tools/playtest/`, `game/perihelion/testkit/`)

**Bots** (all deterministic policies emitting `InputFrame`s from `session.snapshot()`):
- `game/perihelion/testkit/bots.py` (450 ln): `Bot` base (`step(snapshot, session) -> InputFrame`; read-only session access), `AggroBot` (primary campaign-clearer), `SteadyBot` (half aim-wander, mid-skill proxy — hard-mode gates use this), `PacifistBot` (never fires), `CamperBot` (holds position), `ExplorerBot`.
- `game/perihelion/testkit/humanbot.py` (2,202 ln): `HumanBot(seed, skill=DEFAULT_SKILL)` with `DEFAULT_SKILL = 4.0` (:81). Perception-honest: `testkit/perception.py` filters the omniscient snapshot down to renderer-visibility (the snapshot itself lists **every enemy in the level** with exact hp/pos — perception.py's docstring is explicit about this). `testkit/tactician.py` `Tactician` wraps HumanBot (app `--tactician`). `testkit/mouse_model.py` supplies human mouse trajectories.
- `testkit/loadouts.py`: `FULL_LOADOUT` — THE calibration loadout (all 10 weapons, ammo 9mm=400/shell=80/cell=120/components=60, HP 100). Law in its docstring: tune_pass_rate, run_farm, and the app's `--loadout full` all draw from here so a recorded run reproduces a farmed run bit-for-bit.

**Harness** — `testkit/harness.py`: `run_bot(level, bot, seed, max_ticks=60*300, capture_every=0, capture_dir=None, renderer=None) -> Result` (:78) — the core headless loop (`snapshot → bot.step → session.tick`), collecting `Result` (outcome/metrics/ammo+hp timelines/events/portal_crossings; frame capture best-effort, never fails the run). `summarize(res) -> dict` (:174, JSON-safe), `run_matrix(level, bots, seeds, max_ticks)` (:198), and `assert_playable(level, seed=0, ...) -> list[str]` (:220): AggroBot must complete, PacifistBot must NOT complete a combat level, 4-bot containment sweep (`polygon_radius + 8.0` margin), and a mean-tick-wall-time gate (`TICK_BUDGET_MS = 2.5`).

**CLI entry** — `tools/playtest/run.py`: `uv run python tools/playtest/run.py --level levels/smoke_4polygon.json --bot aggro --seed 3 [--max-ticks N] [--gif]` — prints the summary JSON to stdout, exit 0 iff complete. Bot names here: aggro/steady/pacifist/camper/explorer.

**Farm / soak runners:**
- `tools/musiccal/tune_pass_rate.py` — pass-rate farm over K seeds via `ProcessPoolExecutor`; its `one(args)` is the **canonical farm loop**. Critical camera-parity comment (:33): calibration must run at the **shipping camera** — `GameSession(level, seed, player_state=FULL_LOADOUT-derived, screen=(640,360), zoom=0.45)` — the sim default (480,270, zoom 1.35) measures a different bot.
- `tools/musiccal/hunt_winner.py` — streams per-seed outcomes, exits after `--want` winning seeds (`--k 240 --workers 24`).
- `tools/musiccal/boss_probe.py` — farm-exact batch runs on `levels/gauntlet4.json` (`--seeds 1000:1016 --procs 8 --max-ticks 64800`) with a tick-clock MusicSystem attached; reports outcome + boss-music engagement + death diagnostics (tick, polygon kind, wardens down).
- `tools/musiccal/run_farm.py` — raw per-tick recorder (no feature engineering, director's order): one `<bot>_<seed>.jsonl.gz` per run, header line then positional arrays; `fit_factors.py` derives features downstream. `saturation_stream.py` is the memory-bounded per-polygon hazard evaluator over those files.
- `tools/playtest/campaign_run.py` — sequential campaign difficulty instrument (state carries between levels, death retries same level, `MAX_RETRIES=6`, `MAX_TICKS=60*420`).
- `tools/playtest/stream_soak.py` — full streamed ten-chunk campaign soak with cold-restore respawns (`--seeds 2175,23,7` default).

**farm_record.py — the bot-video path** (`tools/playtest/farm_record.py`, 112 ln): `uv run python tools/playtest/farm_record.py SEED OUT_DIR [--level levels/gauntlet_cal3.json] [--every 4] [--max-ticks 64800] [--skill S]`. Replays `tune_pass_rate.one()`'s EXACT loop (same GameSession construction at 640×360/zoom 0.45, same HumanBot, nothing else touching the sim) while rendering frames and logging audio taps. Its docstring records the reason it exists: **the app's record mode injects inputs the farm never sees** (terminal auto-read `inp.interact` — visible in `app.py` ~:855-865 — streamer ticks, overlay pushes), so seed 7095 full-clears in the farm but dies 4× in an app capture. Any "bot cleared it on video" claim must come through farm_record, never `--record` alone.

**Known seeds/budgets:** default farm tick budget 64,800 (18 min @60 Hz); harness default 18,000 (5 min); seed 7095 = the proven gauntlet_cal3 farm full-clear; stream_soak defaults 2175/23/7; `replay_study.py` default `--seed 2200` on gauntlet4 (director's own recorded attempts live untracked in `out/director_fc/`). `GAUNTLET4_BOT_REPORT.md` (repo root) is the decision document for the gauntlet4 bot program (~1% honest clear rate at this base; the later "83%" work was discarded in the reset).

## G.3 Video / frame pipeline

**App capture** (`game/perihelion/__main__.py` flags; `app.py`:404-469): `SDL_VIDEODRIVER=dummy SDL_AUDIODRIVER=dummy uv run python -m perihelion --seed N --mute --record DIR --record-seconds S [--record-every 2] [--start-chunk K] [--bot aggro|explorer|pacifist|human] [--play]`. Lockstep 1 sim tick per drawn frame; writes `frame_%06d.png` (every `--record-every`=2 ticks → 30 fps), `events.jsonl` (audio taps timestamped on the 60 Hz frame clock via `Audio.tap`), and since 2026-07-19 `inputs.jsonl` (per-tick InputFrame rows — human play must be re-simulatable, app.py:867-876). `--record` without `--bot`/`--play` defaults to the aggro bot; `--play` keeps human control while recording.

**Assembly** — `tools/playtest/mkvideo.py` (1,292 ln): `uv run python tools/playtest/mkvideo.py --rec DIR --out run.mp4 --fps 30 [--segments "a-b,c-d"]`. Rebuilds the soundtrack offline from `events.jsonl` against `game/assets/sfx/*.wav` (same bank the game plays), then ffmpeg-encodes (requires `ffmpeg` on PATH).

**Frame review (the "Sonnet checks every Nth frame" pattern)** — two pieces, and the consultant should know the split:
- `tools/playtest/framecheck.py`: samples a capture every `--every-ticks 10` sim ticks into `<rec>/review/` + `manifest.json` of `(frame, t_seconds)`.
- `tools/playtest/FRAME_REVIEW_RUBRIC.md`: the review protocol — Sonnet reviewers each take a **contiguous** span, read **every** sampled frame in order, findings must cite frame filenames/timestamps, "all clear" without a per-category checked-list doesn't count. Categories: readability, seamlessness (constitution invariant), lighting, diegesis, HUD sanity, motion continuity, scene flow; severities P0/P1/P2, JSON findings format.
- **There is no script that automates the Sonnet gameplay review** — it is executed by spawning Sonnet agents (Claude Code subagents) over the `review/` frames. The one scripted LLM-frame-judge in the repo is `tools/playtest/human_judge.py` (A/B "which clip is the human", judge = `subprocess.run(["claude", "-p", prompt, "--model", model, ...])` with `--model sonnet` default at :120, plus a `--control` all-bot fail-first validation of the judge itself). DESIGN_7_25.md:268 raises the bar for the rebuild: "**Verification = a full run with a Sonnet checking every 5th frame.** Ten frames is not verification."
- Adjacent judge tooling reusable as patterns: `tools/artgen/verify_sprite_in_context.py` (paste real asset into real rendered scene, Gemini-vision judge over OpenRouter, never fabricates a pass — errors come back as `p_shippable=None`), `tools/playtest/audio_judge.py` (Gemini ears for SFX), `tools/playtest/camera_phase_check.py` (sub-pixel camera-shift instrument: consecutive-pair and span/FFT modes).

**OpenRouter key convention:** env `OPENROUTER_API_KEY` first, then the repo key file `/home/login/PycharmProjects/noneuclideantopdownshooter/.openrouter_key` (mode 600, gitignored; `tools/artgen/gen.py:34,47-58 _load_key`). `audio_judge.py:144-156` additionally falls back to `/home/login/Documents/youtube/autoclipping/.openrouter_key`. Paid calls log spend to `cost_log.json` conventions (e.g. `tools/playtest/cost_log.json`). Never commit or print the key.

## G.4 Determinism affordances

- **The guarantee that exists:** `GameSession.tick` is a pure function of (level, seed, input sequence). Enforced by `test_testkit.py::test_two_identical_aggro_runs_are_bit_identical` (:83) and `test_explorer_bot_run_is_deterministic` (:98) — full bit-identity of events/ammo/hp timelines and metrics over 7,200-tick real-combat runs — plus `test_human_bot.py::test_two_identical_human_bot_runs_are_bit_identical` (:278). Cataloged as SIM1/grade A in ENGINE_INVARIANTS.md:137.
- **Replay machinery** — `game/perihelion/testkit/replay.py`: `Replay` (seed + packed `InputFrame` rows + level_path/level_dict; gzip save/load), `record(session_factory, input_source, max_ticks, *, level_path/level_dict, meta)` and `play(replay, screen=(480,270), zoom=1.35)`. Subtlety at :88-95: `record()` ticks with the **quantized** frame (`InputFrame.unpack(inp.pack())`) because `pack()` rounds mx/my to 4 dp and ax/ay to 2 dp (`sim.py:214-232`) and the physics is chaotic enough that 1e-4 rounding diverges within a few hundred ticks. Any new input field must be added to pack/unpack or replays break silently.
- `tools/playtest/replay_study.py` re-simulates a **human** run from a `--play --record` capture's `inputs.jsonl` and verifies parity against the recording's own events.jsonl music lines before reporting anything (damage ledger, engagement ranges, cover usage via renderer sight_map).
- **The director's rule (DESIGN_7_25.md:271): "Do not impose a determinism requirement — it's a video game, not a deterministic system."** For the rebuild this means: do NOT contort new systems (marrow economy, dispatch, garrisons, scrubber…) to keep seed-replay bit-exactness, and do not gate them on SIM1-style tests. The existing SIM1/replay tests cover the existing sim; verification gates for new systems should be behavioral/statistical (farm pass-rates, invariant assertions, frame review), not bit-identity. Be aware replay_study.py's human-run analysis depends on tick purity of the *current* sim — if a new system introduces nondeterminism it consumes that tool.

## G.5 Property-based testing / invariant enforcement

- **`ENGINE_INVARIANTS.md`** (repo root, 287 ln) is the standing program: a complete per-module invariant catalog (M/G/W/V/P/SIM/L/H/T/X rows) with columns Statement · Scope · **Enforcement (exact test names or NONE)** · Strategy grade (**A = adversarial/heterogeneous, B = some variety, C = tame/fixed, N/A**) · Priority (P0/P1/P2). The consultant should treat it as the template: every new invariant gets a row, an exact test name, and an honest grade. Its Phase-3 section records the wave-1 method that is now house law: **fail-first verification** (each property demonstrated load-bearing against a deliberately-broken mutant, mutation reverted before commit), honest negative results (P4), and one real latent bug found (S4 `SoftSystem::on_split` arrays short by one after `split_edge` — documented, deliberately unfixed, not player-reachable).
- **The adversarial-strategy law** (embedded in the grading + V9 row): homogeneous PBT strategies rate B at best — the root-invariance suite originally passed on uniform topologies while the real bug lived in deep chains/off-axis cases. New PBT must sweep heterogeneous, adversarial inputs (arbitrary polygons, deep portal chains, mirror/scale transforms), not axis-aligned squares.
- **Rust:** proptest 1.x (dev-dep, `engine/necore/Cargo.toml:9`). `engine/necore/tests/properties.rs` (connect invariants on random heterogeneous hulls, mirror involution, containment_after_impulses, visibility_soundness, degenerate-edge injection, terrain-collision-after-portal-crossing vs native-local oracle, …), `tests/invariants.rs` (e.g. `containment_holds_under_random_walks_through_corners` 4000-step corner stress; `visibility_coverage_is_continuous_across_doorway_sweeps`), `tests/soft_walls.rs`.
- **Python:** `hypothesis` (dev group in pyproject) used in exactly five files: test_corpse_economy, test_gauntlet_calibration, test_level_winding, test_lighting_invariants, test_mindmap_layout — e.g. `test_level_winding.py:39-52` `@given(n_sides=st.integers(3,8), radius=st.floats(30,300))`.
- **Unenforced instruments to know about:** `tools/playtest/parity.py` (rust-vs-pygame statistical pixel parity over 4 real-campaign fixtures, PASS ≥98.5% pixels within ±2/channel — **CLI-only, not a pytest gate**; the enforced byte-exact versions are in test_render_backends.py) and `tools/playtest/flicker_cross.py` (7×7 grid world exceeding `max_instances=96` — the most adversarial flicker topology cataloged, also CLI-only). ENGINE_INVARIANTS R3/R7 flag both gaps explicitly.

## G.6 Purpose-built isolated test levels (the director's "isolated test vectors" rule)

`perihelion.levels.LevelBuilder` (levels.py:265) is the mechanism — authoring in absolute canvas coords, adjacency only via explicit `connect`. Smallest real example, `test_testkit.py:67-75`:

```python
b = LevelBuilder("smoke_empty")
r0 = b.rect(0, 0, 200, 200)
r1 = b.rect(300, 0, 200, 200)
b.connect(r0, 2, r1, 0)      # (polygon, edge, polygon, edge)
b.player(r0, (100, 100))
b.exit(r1, (400, 100))
level = b.build()             # b.to_dict() for replay/serialization
```

`build_smoke_level()` (test_testkit.py:42-64) is the combat variant (4-polygon chain, husks + mites + key forcing genuinely-mandatory combat). Other builder verbs: `ngon/poly`, `connect_x(a,ea,b,eb,m9)` (arbitrary portal transform), `door(...,key)`, `no_connect`, `autoconnect(tol)`, `entity(polygon, type, pos, **props)`, `terminal`, `light`, `intro/radio`, `key_meta`. Placement coords are absolute-canvas (re-add the polygon's origin — the test file's docstring warns about this exact trap). Pathological worlds for perf/visibility live in `testkit/perf.py`: `build_radial_hub()`, `build_mirror_polygon()`, `build_infinite_corridor()`, `build_grid40()`, with budgets `TICK_BUDGET_P90_MS=2.5`, `VISIBLE_BUDGET_P90_MS=3.0` enforced by `test_perf_budgets_fast_subset` (always-on) and the `slow`-marked full suite. Shipped-level fixtures: `levels/smoke_4polygon.json`, `gauntlet_cal*.json`, `gauntlet4.json`, `l01..l10.json` + `campaign.json`, `gauntlet_horde.json`, `vigil.json` (doomed), `marathon_arrival.json`, `maze_demo.json`.

## G.7 Instrumentation hooks a harness can consume

- **`GameSession.snapshot()`** (sim.py:2855) — omniscient JSON-able dict per tick: tick/hp/dead/complete/polygon/pos/weapon(s)/ammo/keys, enemies `[{id, kind, polygon, pos, hp, state, hops}]` (hops = engine `hop_distance` to player), pickups, stations, economy fields (components/chassis/station_kits/recalls), think-state. This is the bot input AND the standard probe.
- **`session.metrics`** — kills, dmg_dealt, dmg_taken, pickups, transfers, polygons_visited (a set — `summarize()` sorts it for JSON).
- **`session.fx`** — per-tick effect/event stream consumed by `Renderer.consume_fx`, `Audio.handle_sounds`, and MusicSystem; harness event logs (kill/damage_taken/pickup) are derived from metric deltas in `run_bot`.
- **`session.visible(max_depth=14, max_instances=96)`** (sim.py:2745) — the renderer's portal-visibility instance set (polygon, xform, depth, clip_screen, walls, entry_edge, ents); usable headlessly for sight/occlusion assertions (HumanBot perception and replay_study cover metrics are built on it).
- **`PERIHELION_VIS_DUMP=1`** env var during `--record` (app.py:445-465) — writes `visdump.jsonl` beside every saved frame: `{frame, tick, n, inst:[{polygon, depth, entry, bbox, x6}]}` so a frame-pair pixel diff can be traced to the exact visible-instance-set change (built for the flicker investigation).
- **Capture directory contract**: `frame_%06d.png` + `events.jsonl` (audio taps `{t, kind, name, vol, pan}`) + `inputs.jsonl` (per-tick InputFrame rows, human/`--play` runs) — consumed by mkvideo.py, framecheck.py, replay_study.py, camera_phase_check.py.
- **`Audio.tap`** — assignable callable `(kind, name, vol, pan)` (set by app.py:416 and farm_record.py:76-77) — lets any headless run log the full SFX/music stream without a mixer.
- **Farm sidecars** — run_farm.py's `.jsonl.gz` positional per-tick format (header line with field order) is the raw-data convention for anything statistical; `tools/playtest/judge_out/` and `parity_out/` show the artifact-directory convention for judge runs (keep raw judge JSON next to the verdict).

**What does NOT exist at this base** (so the plan must build or forgo it): no CI runner; no pytest coverage of parity.py/flicker_cross.py-class CLI instruments; no automated Sonnet frame-review driver (protocol is manual-agent per the rubric); no verification hooks for any DESIGN_7_25 system (hub, marrow, CORE, breach/dispatch, garrisons, kin field, scrubber — none of it exists in code here); no `hub_farm`/`caller_farm` tooling in the tree (those `out/` dirs are residue of the discarded branch; the scripts live only at reflog commit 94b3397b).

---

# H. The minable code at 94b3397b (discarded 07-20 → 07-25 work)

The rewrite branch was hard-reset to d85d3765 (the director-cleared canon base). The week of work after it — 107 commits — is intact and reachable read-only at `94b3397b` (kept alive via reflog; verify with `git cat-file -e 94b3397b^{commit}` before relying on it, and consider `git tag mine-94b3397b 94b3397b` to pin it). **Director's law: mine this range for CODE, not conclusions.** Interim commit-message diagnoses in the range are context-rot (see H.5 — the "door too narrow" comment is itself a wrong diagnosis). Access everything with `git show 94b3397b:<path>` / `git diff d85d3765..94b3397b -- <path>`; never check anything out into the working tree.

Scale of the range: `game/perihelion/sim.py` grew 2,904 → 4,884 lines; `testkit/humanbot.py` shrank 2,202 → 1,481 (a deliberate lean rewrite); `render.py` was rewritten pygame-free (base `render.py` still has `import pygame` at d85d3765:render.py:45).

## H.1 Full commit list (d85d3765..94b3397b, oldest last)

```
94b3397b app: enrich human session-log telemetry for studying strategy vs new mechanics
823ecde5 adversary: summoning is a weakest-in-fight combat task, planted close-as-safe
e41a8186 world: remove Vigil gamemode; every world always has a marrow hub
ca31fe96 adversary: decouple caller from marrow; two-mode caller cycle; kin field
b2c27600 adversary: weakest-present caller, shrieker mark state-machine, warden engulf
83703483 bot: seek medkits when hurt + fire at any perceived on-screen enemy
b69ab9ae bot: tune the push/fall-back to 50% clears on gauntlet4
e50a6204 bot: simplify to a lean push/fire-on-LOS/fall-back core; shriekers patrol
393a6b57 adversary+render+bot: real breach, marrow reserve economy, no more special-casing
4662cbbc Merge branch 'pygame-free-render' into rewrite
bcef7707 bot: stop burning pod salvage as scrap ammo; lay a forward respawn-anchor chain
203da395 render: remove pygame entirely from render.py; restore the diegetic HUD
f8d255cf sim: siege meter is a stagnation timer -- fresh ground resets it, not shaves it
9040934b sim: breach into a streamed polygon crashed on level.polygon_verts index
1ed8b75e render+adversary: carried load rotates with the body; drop caller-tell; un-jam breach spawns
25e40edc adversary+economy: inflammation SIEGE for turtling; bootstrap the zero-kit run
d3ef4e40 carry: one assembly kit at a time (pod prints it, you haul it, assemble in situ)
1db06174 tooling: scope the turn-end video gate to turns that report a .mp4
850fc1e4 remove the ImmuneConfig feature-flag system: behaviors are hardwired now
2f6f0e0d music: hub_core has no danger/threat weight -> crash when a breach builds it
63adc2a8 adversary: reinforcement calling is the Adversary lane's, not the Testators'
2317e1f8 cleanup: delete stale gauntlet level versions (one canonical file)
02e198dd tooling: replace the turn-end Stop hook with a single "did you watch the video?" gate
2fdd91a7 adversary: the hub core dwarfs its guardians; the chamber floor reads as infested tissue
84d91dad adversary: fix two more hub_core KeyErrors (alert + drops)
13ce8105 adversary: the breach tear sits on the wall it tore through -- the visual IS the doorway
cb40f2b1 adversary: fix hub IndexError -- extend field arrays when hub polygons are added
104e9df8 adversary: the reachable hub -- cross a breach to the source and kill it
fcaf5fe8 adversary: a breach hits like a surge, and jolts when it tears in close
7aa8d2f8 adversary: breach reads as a tear not a stain; caller "imminent" beat; fix darkness invariance
69c9c5be adversary: breach audio cue + the caller-less "you grinded too hard" breach
63b8c5bb adversary: reinforcement calling reads on screen, generalizes, and actually fires
71395ba8 adversary: reinforcement calling is live -- drop the experiment flag
e543621d adversary: reinforcement calling -- a caller opens a breach behind the front (IMMUNE_REINFORCE)
81f94ef4 docs: add ADVERSARY_DESIGN.md, a game-mechanics-only design reference
887c7264 buildings: repair station unpacks for 30s before it can heal
c34b956e buildings: pod grows roots as it digs in; visible pod->turret supply conduit
b882998b camera+HUD: zoom out to 1.0, strip HUD to scrap, retire banners, carry reads on the body
1054021d replay: capture camera zoom in the replay (deterministic-contract fix)
97a71512 repair: heal only ON it (20s exposed), and a Christian cross, not red
0623545f buildings: destroyed on contact by anything bigger than a mite
88099657 sentry: half the damage, twice the fire, a drum, a slewing turret
b53632e3 bot: the network stretches to the endgame — 49% canonical, targets met
6b5e6703 bot: the long pod trip was the whole answer
6fea1ec2 farm: play the game's actual death rule — revival was never measured
0ee833af out/: stale tracked videos moved to out/old — one current deliverable
5263ecab calibration: unblock the pod supply-run; ship the designed roster
692589e1 calibrate at the real zoom: zoom-invariant aim, pod economics that close
4ed97f30 render: the Adversary reads as an absence, not a scribble
b044994a economy/bot: pods cost 65 and go where they make sense
7f016176 levelgen: portals never scale — the entry corridor's lens is gone
45c7ba18 lighting: muzzle flash is a real light, and so is every other flash
3971391d render: floors first, then everything else on top — the seam cut, fixed
0a23ecb6 render: delete the pygame renderer — one renderer, the one that ships
d0e948c8 capture at the REAL game zoom (1.35), not a third of it (0.45)
a5a6145b progress watchdog: a stall is a deterministic loss, flagged in the sim
6c38f627 calibrate to 50%: deeper ammo stock, field rearm, and a thickened roster
3c82f5a4 bot: buy ammunition at the pod, and end the knife-in-hand stalemate
5924a26e render: draw the Adversary trace at the scale it needs to be read
ef536b8b economy: the pod IS the CUCULUS, and nothing is free
1f6fe53d the pod is a printer, and its rack shows the bodies left in it
ab72fd59 render layers: rooms, then entities, then the LOS shadow on top
d28987b9 the gap rule sees across portals - 50% at n=48
69e1473b recon by fire into the dark; always-on session log; branch lighting
b338a4cd art pass: field infirmary, real emplacement, formless Adversary; bodies stop fusing
7d507cdb patrols must stay inside the simulated world
9eecafa0 the Adversary was spinning, not roaming: drift is a rate, not a per-tick turn
f185df0f fix the rendering errors the director saw, and the SMG dump
6c2298c4 light the corridors I authored: two fixtures per stretch, not one
59cb5e4a sentries go amber: a player's gun must not look like the thing killing it
bcf78667 work lamp 70 -> 88: light the ground you stand on, keep the dark
38faa889 banners hold long enough to read; a torn-down gun is an event
a7c51134 iconography: the infirmary stops wearing the gun's colours; the Adversary sweeps
4fd1dee1 Adversary hunts your installations - calibration lands at 46%
806decae field structures light their own ground; one Adversary silhouette, not two
4216f096 farm_record: draw objective banners - headless captures dropped every one
1b7baed3 structures plant in front of you; build loop runs the whole run; the win says so
1e90a9ff render: sentries were invisible; make the field structures read at zoom
5e7d0dd6 bot: cap repair kits per shop stop - calibration lands at exactly 50%
d1d606e5 gauntlet: install the reworked level; carried structures are a beacon
293b87d7 gauntlet: the pod IS the fabricator - supply runs, torn-down sentries, contested branches
e48ea3d6 buildings: repair stations, one carried-structure model, and the Adversary lane
e8252cd1 economy: drop-pod action — set a carried revival pod down as an item
9fd62ed9 hooks: scope the verify-turn-end Stop hook to this project only
9295559b economy: revival-pod redesign (per-pod stock, expensive, carry-slows)
97683cc0 ant AI: room_danger + trails + raid — pure routing/timing (behavior-only)
460c4afd immune AI: enable coordination behaviors as the enemy AI (behavior-only)
9f38e819 docs: cut IMMUNE_ENEMY_DESIGN to a fact-only reference
fcbf5e86 docs: fold Sonnet research wave into IMMUNE_ENEMY_DESIGN (bestiary, coordination, aesthetic, level-as-organ)
1abeb441 farm_record: --immune passthrough so recordings match probe config
ce6a47bf immune: relay recruitment, inflammation, stand-down/signature, boids flocking (flag-gated)
f161640f immune: quorum recruitment — idle cells wake on local field threshold (behind quorum flag)
674fa1ef immune: chemotaxis — enemies climb the signal gradient, no global oracle (behind chemotaxis flag)
beaa0043 immune: signal-field substrate (foundation, behind signal_field flag)
1808215c docs: IMMUNE_ENEMY_DESIGN — synthesis of 5 research streams into a buildable design
51e56121 immune enemy: feature-flag scaffold + session/probe wiring
5b8e92c9 bot: close-when-winning showmanship reverted — boss-music silence is arithmetical, not behavioral
d6918ba5 bot prepares battlespaces — 128/128 (100%) full-clear on both banks
98676b62 GOAL MET: 83% full-clear on the redesigned gauntlet (53/64 on BOTH banks, n=128)
a4a7b4d9 lighting: directional cone lights, flashlight rig, muzzle flash as a real light
7873f054 field fabrication: sentries and regenerative boosters built from salvage anywhere
26fbb765 loop plumbing: seed full-heal on plant; holes/kits/chassis in the full loadout
b91f3966 shrieker: Cordyceps sentinel FSM + corridor placement doctrine
f954fc26 enemy kinematics: nothing is outrunnable — heavy, fast, wide-turning
ffb95e19 all weapons push; fully charged tau detonates on impact
f550bbfb warden is a normal high-tier enemy: hp 168, brood and enrage removed
b2b722d6 docs: COMBAT_REDESIGN — director's post-FC canon (2026-07-19)
```

## H.2 diff --stat summary (what was created / heavily modified)

75 files changed, 17,868 insertions(+), 7,905 deletions(-). Significant rows (`git diff --stat d85d3765..94b3397b`):

```
game/perihelion/sim.py                   | 2540 ++++-   (all adversary/marrow/buildings/immune systems)
game/perihelion/render.py                | 1669 ++--    (pygame-free rewrite + all new-system draw code)
game/perihelion/testkit/humanbot.py      | 1333 +---    (net SHRINK: lean push/fall-back rewrite)
game/perihelion/hud.py                   |  305 +-      (diegetic HUD rebuilt on numpy/PIL text path)
game/perihelion/app.py                   |  161 +-      (always-on session log out/sessions/*.jsonl)
game/perihelion/immune.py                |  122 +       (NEW: SignalField substrate)
game/perihelion/text.py                  |   76 +       (NEW: PIL/FSEX300 bitmap text, no pygame.font)
game/tests/test_economy.py               |  366 +-      (building-economy suite)
game/tests/test_render_layers.py         |  243 +       (NEW: seam/occlusion/layer invariants)
game/tests/test_human_bot.py             |  223 +-
game/tests/test_sentry_turret.py         |  190 +-
game/tests/test_lighting_invariants.py   |  152 +-
game/tests/test_level_geometry.py        |   72 +       (NEW: pins every portal at scale 1.0)
game/tests/test_render_backends.py       |  150 -       (deleted with the pygame backend)
game/tests/test_gauntlet_level.py        |  133 -       (deleted)
game/tests/test_vigil.py                 |   39 -       (deleted with Vigil mode, e41a8186)
levels/gauntlet4.json                    | 11232 ++++    (reworked level: approach choke, branches, adversary seeds)
levels/vigil.json / gauntlet_cal*.json / gauntlet_horde.json  (deleted — one-canonical-version law)
tools/levelgen/gauntlet4_rework.py       |  260 +       (NEW: additive level rework generator)
tools/levelgen/thicken_adversary.py      |   78 +       (NEW)
tools/playtest/reinforce_trace.py        |  145 +       (NEW: tick-level breach/caller instrumentation)
tools/playtest/session_report.py         |   97 +       (NEW: human-session jsonl reader)
tools/playtest/parity.py                 |  164 -       (deleted)
tools/musiccal/build_gauntlet*.py, *_meta.json           (deleted — stale generators)
ADVERSARY_DESIGN.md 226+ / IMMUNE_ENEMY_DESIGN.md 255+ / COMBAT_REDESIGN.md 69+ / IDEAS.md 21+  (docs — superseded by DESIGN_7_25.md; treat as context-rot except for cited numbers)
plus .claude/verify-turn-end.py hook, farm_record.py 59+-, boss_probe.py 16+, out/*.mp4 churn
```

## H.3 System-by-system mining map

All line numbers below are into `94b3397b:game/perihelion/sim.py` unless another file is named.

### Signal fields / chemotaxis
- **Where:** `94b3397b:game/perihelion/immune.py` (122 lines, complete file) — built at beaa0043, extended ce6a47bf/ca31fe96. Sim-side consumers in sim.py.
- **Shape:** `SPECIES: dict[str, tuple[float,float]]` maps species → (diffuse D, per-tick decay); at tip: `distress`(0.10,0.010), `noise`(0.11,0.055), `scent`(0.00,0.030), `muster`(0.08,0.004). `class SignalField`: `__init__(self, sim)`, `emit(species, polygon, amount)`, `sample(species, polygon) -> float`, `step()` (one deterministic diffusion+decay tick restricted to the `wet` set), `total(species)`, `_rebuild_adj()` (must be called when topology grows — hub polygons, portable holes; cb40f2b1 was the crash). Also a directed army-ant edge pheromone: `trail: dict[(polygon, edge), float]` with `deposit_trail`/`trail_at`, `_TRAIL_CAP=8.0`, `_TRAIL_DECAY=0.06` (from 97683cc0). Adjacency is HOP adjacency (portals), never Euclidean; no RNG, fixed iteration order — replay-safe.
- **Sim hooks:** DISTRESS on `_damage_enemy`/kill, NOISE at fire sites, passive SCENT at player polygon per tick (grep `self.field.emit` at the ref). `_climb_field_edge(polygon, species, ppolygon) -> int` (sim.py:2777) picks the portal edge toward the richest neighbor, falling back to `s.next_edge()` oracle so cold-ground searchers are never inert (674fa1ef's chemotaxis, hardwired after 850fc1e4 tore out ImmuneConfig).
- **Reusability: clean lift.** immune.py is self-contained (depends only on `sim.num_polygons()`/`sim.polygon_portals()`), deterministic, and measured stable (bounded ~50 mass/~55 wet polygons, decays to zero). The sim-side emit hooks are a small, greppable partial salvage.

### Spotter / caller AI (reinforcement calling)
- **Where:** sim.py `_begin_call` (3142), `_should_summon(eid, e, kind, polygon, ppolygon) -> bool` (3150), `_caller_step` (3179), `_caller_transmit` (3226); constants block 246–299 (`CALL_TRANSMIT_TICKS=15s`, `CALL_COOLDOWN_TICKS=30s`, `CALL_MAX_OPEN_BREACHES=2`, `SCENT_WAKE=0.12`, `CALLER_PEAK_ENTER=2.0`). Evolution: e543621d (flagged) → 71395ba8 (live) → b2c27600 (weakest-present) → ca31fe96 (two-mode cycle + `kin` field) → 823ecde5 (final: summoning is a *combat task*).
- **Shape at tip (matches DESIGN_7_25's ratified ruling):** the weakest-HP enemy kind sharing the intruder's polygon (ties by eid; must not be alone; one caller at a time) peels off, walks the danger field downhill toward the player until the next step would enter the hot zone (`danger(p) = distress+noise+scent > CALLER_PEAK_ENTER`) — "close as safe" — then transmits stationary for 15s (abortable by entering its polygon or killing it), emitting `muster`, and on completion calls `_open_breach(polygon, (ex,ey))`. The caller knows nothing of the marrow's reserve — `_open_breach` owns refusal.
- **The `kin` species** (friendly-scent, callers avoid clustering garrisons) was added at ca31fe96 and **removed by 823ecde5** — absent from immune.py at tip. Mine ca31fe96's diff if garrison-spreading is wanted.
- **Reusability: clean lift of the tip version** — it is the shape DESIGN_7_25 ratifies. The two-mode cycle at ca31fe96 is superseded; ignore it.

### Shrieker mark FSM + Brand + marker projectile (b2c27600)
- **Where:** `class Brand` sim.py:444–467 (`strength`, `source_eid`; `renew(eid)`, `decay(per_tick)`); constants 338–347 (`BRAND_DURATION=14s`, `BRAND_SCENT_GAIN=8.0`, `BRAND_TRAIL_DEPOSIT=8.0`, `MARK_SPEED_MULT=3.0`, `MARK_FIRE_RANGE=210`, `MARK_AIM_TICKS=18`, `MARKER_SPEED=620`, `MARKER_TTL=150`) plus `MARK_STANDOFF=95.0` / `MARK_FRONT_CONE=0.5` at 2847–2850. Behavior: `_fire_marker` (2810, velocity-led shot spawning a `kind="marker"` bullet — brand applied in `_consume_events` bullet/player collision), `_shrieker_rouse` (2832), `_shrieker_ai` (2852, the full FSM), `_shrieker_patrol` (2793), `_alarm_tick` (2003, brand-amplified scent: `scent *= 1.0 + BRAND_SCENT_GAIN * brand`, plus carry-weight scent at 2017).
- **Reusability: clean lift** — matches the anti-sprint memory's mark/glob design; self-contained state machine over existing enemy dict + field.

### Warden engulf (b2c27600, tuned director 2026-07-25)
- **Where:** `class EngulfGrip` (469–478); `WARDEN_ENGULF_*` constants 349–361 (RANGE 155, CHARGE 12 ticks, LUNGE_MULT 2.5, DOT 0.5, DPS 75, COOLDOWN 5s); `_engulf_tick` (2022), `_release_engulf` (2054), `_warden_engulf_step` (2064); dispatch hook in `_enemy_ai` at 2129 (`e.get("engulf") in ("charge","lunge","hold")` short-circuits the normal FSM) and trigger at 2396–2404. Only escape is killing the warden.
- **Reusability: clean lift.**

### Breach / reinforcement dispatch / the marrow hub
- **Where:** `_build_hub` (3249), `_find_doorway_edge` (3287), `_hub_attach` (3302), `_hub_detach` (3322), `_reinforce_kind` (3327), `_open_breach(polygon, pos)` (3338), `_breach_tick` (3373), `_inflammation_breach_tick(ppolygon)` (3429). Economy constants 264–325: `BREACH_REINFORCEMENTS=6`, `BREACH_EMIT_INTERVAL=30` ticks, `BREACH_IDLE_CLOSE_TICKS=45s`, `REINFORCE_WEIGHTS` (husk .46/mite .24/spitter .12/…, never Adversary kinds), `MARROW_RESERVE_MAX=24`, `MARROW_REGEN_TICKS=600`, `MARROW_BREACH_MIN=6`, `MARROW_CORE_DEAD_RESERVE=-100000`, `INFLAMMATION_BREACH_THRESH=24.0`, siege constants (SIEGE_CAMP_TICKS=45s, SIEGE_BREACHES=5, SIEGE_MIN_POP=20, SIEGE_HEAT=3.0).
- **Shape:** hub = off-map octagonal chamber (r=78) + 40×15 corridor, `hub_core` enemy (hp 320, immobile) + 3 brute guards; one breach at a time is the live portal in (`hub["attached"]`); breaches emit on cadence at the breach polygon with golden-angle jitter, spend `hub["reserve"]` per body, close after idle; core death seals and kills supply forever. `_inflammation_breach_tick` is the caller-less path: hottest wet polygon over threshold → flank breach; plus the SIEGE stagnation timer (f8d255cf: fresh-ground *resets* `_camp_ticks`, a relief-shave provably siege-spammed advancing runs — that reasoning is in-code and worth keeping).
- **Reusability: partial salvage.** The economy/tick logic and inflammation/siege logic are sound lifts. The **geometry glue is the bug** (H.5) — `_hub_attach`/`_build_hub` must be rebuilt under DESIGN_7_25's scale-guard (carve both sides at the same width, assert derived scale == 1). Also lift the hardening fixes that were paid for in crashes: field-array extension on topology growth (cb40f2b1 / the `_rebuild_adj` call at end of `_build_hub`), `polygon_seeds.extend` for the new polygons (3273), streamed-polygon breach crash (9040934b), hub_core music/alert/drops KeyErrors (2f6f0e0d, 84d91dad).

### CUCULUS buildings (pods / sentries / repair / carry)
- **Where:** the whole placement+economy layer, sim.py 3871–4360: `add_station(polygon, pos, stock=0, ...)` (3871, gained `stock`/`lit`/unpack vs base's `add_station(polygon, pos)`), `structure_blocked(polygon, pos, skip_sentry=None)` (3977), `station_near` (4022), `_booster_tick` (4045, repair pool: `BOOSTER_CHARGE=60`, `REPAIR_HP=14`, heal only while ON it), `_structure_contact_tick` (4114, 0623545f: anything bigger than a mite wrecks structures on contact), `refill_station` (4157), `place_station` (4189, consumes a `station_kit`, plants at `PLANT_REACH=24` in FRONT of player, full-heal on plant), `place_repair` (4217, 30s `BUILDING_UNPACK_TICKS` inert-unpack), `place_sentry` (4249, re-checks the engine-clamped landing spot — a measured bug), `drop_pod` (4286, heaviest-first `DROP_ORDER`, `POD_DROP_GRACE=90`), `buy`/`SHOP` (4306+, one-assembly-kit-at-a-time law d3ef4e40; pods cost 65 per b044994a), carry model at 1163–1188 (`CARRY_WEIGHT`, `POD_CARRY_FLOOR=0.45`, `_carry_speed_mul`, `station_kits` property = count of "pod" in `self.carried`). Sentry combat rework at `_sentry_tick` (1719; 88099657: half damage, double rate, drum, slewing turret). Render side: pod roots/conduit (c34b956e), carried-load-on-body (1ed8b75e, b882998b) live in `94b3397b:game/perihelion/render.py`.
- **Base comparison (honest):** d85d3765 already has a skeleton — `spawn_sentry` (:489), `_sentry_tick` (:1325), `add_station` (:2326), `place_station` (:2349), `buy` (:2362). Everything else above (carry model, repair boosters, unpack timers, drop/pickup of structures, contact fragility, prices, Adversary structure-hunting `_structure_hunt` at 2628) does NOT exist at base.
- **Reusability: strong partial salvage.** The API shapes and constants match DESIGN_7_25's pod-is-fabricator law; lift function-by-function onto the base skeleton rather than diffing wholesale (the tip functions reference `self.field`, `self.carried`, `fx` parking (`_park_oob` 4183) that must come along).

### Quorum recruitment / boids flocking
- **Quorum:** inline in `_enemy_ai`, sim.py ~2202–2222: idle cell wakes when local `distress+noise >= 0.9 + 0.5*((eid*2654435761)%1000)/1000` (deterministic per-eid jitter → cascade, not snap), OR smells the player (`scent >= SCENT_WAKE=0.12` — the "standoffs are impossible" rule); emits `muster` on commit. **Clean lift.**
- **Boids separation:** inline at ~2340–2370: per-pair radius push-apart (`r_self + r_other + 12`), 1/d weighting, weight 1.4 for mites / 0.45 for everything else, added to the pursuit heading (pursuit supplies cohesion). **Reference only / rewrite:** DESIGN_7_25 §flocking (line 333) explicitly corrects this to *priority-budget allocation* (separation claims acceleration first, 1/d² falloff) because weighted averaging fails when requests oppose. Mine the pair-iteration scaffolding, not the blend.

### Find / senses API attempts
- **Honest statement: no literal `find()` API exists anywhere in the range.** DESIGN_7_25's "find API" ruling is new work. What the range DID build, senses-wise:
  - `_player_sighting(eid, polygon, ex, ey, max_hops=3)` (sim.py:2726) — the player's position in the *enemy's local frame* via composed portal xforms (`necore.mat_mul`/`mat_apply` chain along `next_edge`) + a raycast confirm. This is the cross-room-combat-law pattern in miniature and the best seed for a general senses API. **Clean lift.**
  - `_climb_field_edge` (2777) — field-gradient steering (above).
  - humanbot `_visible_enemy_screens` (94b3397b:testkit/humanbot.py:453) — viewport-based bot perception.
  - Already at base (do not re-mine): `visible()` (d85d3765:sim.py:2745), `sight_map` (:2775), `point_in_sight` (:2813), `testkit/perception.py:PerceptionModel` (:50).

### The pygame-free renderer (203da395, merged at 4662cbbc)
- **Diff stat of 203da395:** `app.py | 9`, `hud.py | 145`, `render.py | 778`, `testkit/harness.py | 4`, `text.py | 76 (new)`.
- **What it touched (verified in the file, not just the message):** render.py imports no pygame — world/entity rasterization stays in Rust (`necore.Raster`, wrapped by `class _RustCanvas` ~:443); lightmap build, light wedges, glow, otherworld darkness, and overlays became numpy ops on the framebuffer using pygame-ce's exact blend formulas (`_mult_into` (s*d+255)>>8, `_add_into` min(255,s+d), `_alpha_over`, ~:415–441); polygon coverage for wedges/darkness rasterizes via a second `necore.Raster` coverage mask so seam-freeness invariants hold; `pygame.Rect` replaced by a local `class Rect` (:338); textures via PIL; `draw()` returns a `(W, H, 3) uint8` framebuffer in surfarray axis order, which app.py/farm_record/harness blit. New `game/perihelion/text.py`: PIL-rasterized FSEX300 bitmap glyphs (cached) composited onto the numpy frame — the ONE text path renderer+HUD share. hud.py rebuilt on it (health number+bar, weapon+ammo, salvage). Suite was green at 626 tests when landed. Precursor commits on the same branch: 0a23ecb6 (deleted the pygame world backend + test_render_backends.py), 3971391d (floor-first draw order), ab72fd59 (rooms → entities → LOS shadow layering), 45c7ba18/a4a7b4d9 (lights).
- **Reusability: clean lift as a unit** — take `94b3397b:game/perihelion/render.py`, `text.py`, `hud.py`, and the harness/app blit changes together. **Caveat:** tip render.py also contains draw code for discarded sim features (breach tears, hub tissue floor, carried-load, pod roots/conduit, Adversary trace) that references sim fields the base lacks — lifting requires either bringing those systems or excising their draw branches. The base at d85d3765 is still pygame-rendered (render.py:45).

### Bot work (context for calibration, not spec)
Lean humanbot rewrite e50a6204 (2202→1481 lines: push / fire-on-LOS / fall-back core), tune b69ab9ae (50% clears on gauntlet4), medkit-seek + fire-at-perceived 83703483, forward respawn-anchor pod chain bcef7707/6b5e6703, progress watchdog a5a6145b (`_progress_watchdog` sim.py:793, `stalled` :804 — in sim, salvageable). Level rework: `tools/levelgen/gauntlet4_rework.py` (additive: approach choke, rejoining branches with salvage, vagrant/lacuna seeding; every existing polygon keeps its index) and the resulting `levels/gauntlet4.json` (+11k lines at tip). New enemy kinds at tip: `vagrant` (hp 26) and `lacuna` (hp 34) — the Adversary lane (`ENEMIES` :140/:145, `ADVERSARY` tuple :156) — these do not exist at base.

## H.4 Test vectors and harnesses worth salvaging

- `94b3397b:tools/playtest/reinforce_trace.py` (145 lines) — tick-level sim-state instrumentation of caller/breach ("is the feature firing, and if not which condition blocks it"), explicitly built because audio taps can't attribute breaches. Lift nearly as-is for the rebuild's breach bring-up.
- `94b3397b:tools/playtest/session_report.py` (97 lines) + the always-on session log in `94b3397b:game/perihelion/app.py` (:411–:506, `_log_session_tick`; writes `out/sessions/<stamp>_<level>.jsonl` — one InputFrame line per tick + sampled state every 250ms; re-simulatable because the sim is deterministic on level+seed+inputs). 94b3397b itself enriched the telemetry for studying human strategy vs the new mechanics.
- `94b3397b:game/tests/test_level_geometry.py` — **pins every portal in gauntlet4 at scale 1.0** (`test_gauntlet4_has_no_scaling_portals`: connected edges must be EQUAL length) plus `test_the_approach_corridor_still_chokes`. This is the regression net for H.5's bug class; lift it early.
- `94b3397b:game/tests/test_render_layers.py` (243 lines) — seam-cut, corner-occlusion, adversary-trace-scale, station/decal-on-seam invariants for the pygame-free renderer.
- `94b3397b:game/tests/test_economy.py` — full building-economy suite (unpack-before-heal, one-kit law, plant-blocked, adversary overrun, fabricator prices, pod spacing, corpse economy…) — test names at :32–:763 read as an executable spec of the CUCULUS economy.
- `94b3397b:game/tests/test_sentry_turret.py`, `test_human_bot.py` reworks; `tools/musiccal/boss_probe.py` field_peak/field_wet_peak instrumentation (beaa0043); `farm_record.py` gained objective-banner drawing (4216f096) and records via the farm-exact path.
- Docs in range (`ADVERSARY_DESIGN.md`, `IMMUNE_ENEMY_DESIGN.md`, `COMBAT_REDESIGN.md`) are conclusions — superseded by DESIGN_7_25.md; consult only for constants already cross-checked above.

## H.5 The hub-scale bug (the real dead-reinforcements root cause)

The engine derives portal scale from geometry: `connect()` in `engine/necore/src/world.rs` (fn at :155; :182 — "Rotation taking -db (b's edge reversed) onto da, plus uniform scale") computes `s = la/lb` from the two glued edge lengths. Scale is not an optional field you can leave unset — **any length mismatch becomes a resizing lens** (DESIGN_7_25.md:40, measured 07-25: 96↔96 gives s=1.000000; 96↔52 gives s=1.846).

The discarded hub construction glues mismatched edges. In `94b3397b:game/perihelion/sim.py`:

```python
# _build_hub, sim.py:3265-3266 — the corridor's far mouth (edge 2) is 15 units long:
corridor = s.add_polygon([(0.0, 0.0), (0.0, 15.0), (40.0, 15.0), (40.0, 0.0)])
s.connect(chamber, door, corridor, 0)          # chamber door is 15 wide -> scale 1, fine

# sim.py:3285 — but the map-side breach door was widened to 52:
BREACH_DOOR_HALF = 26.0            # 52-wide opening (~3 husks abreast)

# _hub_attach, sim.py:3312-3316 — 52-wide door glued to the 15-unit corridor mouth:
mid = self.sim.split_edge(polygon, edge, t0, t1)    # t0,t1 = 0.5 -/+ 26/elen  => 52 wide
...
self.sim.connect(polygon, mid, self.hub["corridor"], 2)   # 52 <-> 15: derived scale ~3.47
```

Every breach portal into the hub was therefore a ×3.47 lens: bodies resize crossing it (a husk of radius 8 becomes ~28 — diameter ~55 against a 52-wide opening), which is why reinforcements could not fit through the gate and presented as dead/jammed. **The in-code comment above `BREACH_DOOR_HALF` (sim.py:3281–3284, "the old 15-wide door was narrower than a husk... bodies jammed") is exactly the context-rot the director warned about:** widening only the map side is what *created* the lens, because the corridor mouth stayed 15. `ACTIVE_HOPS = 5` (sim.py:30) was blamed in interim diagnoses and exonerated post-reset (far-sim is deferred; do not raise it).

**Rule for the rebuild (already ratified in DESIGN_7_25.md:40, :117):** carve BOTH sides of any glue at the *same* width (`carve_door(..., width=W)` at identical W — base has `carve_door(polygon, near, width=70.0)` at d85d3765; sim.py:1505 at tip), then assert the resulting transform's scale is 1 within tolerance at construction time, and keep `test_gauntlet4_has_no_scaling_portals` (H.4) in the suite so the level side stays pinned too (the shipped level's own 50 scaled portals were separately purged at 7f016176).

