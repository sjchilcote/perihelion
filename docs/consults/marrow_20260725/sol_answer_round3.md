# Round 3 — implementation and verification control plan

## Operating rule

Every unit below is a commit-sized transaction:

1. Start from a green parent.
2. Add the construction invariant and fail-first test before the behavior.
3. Demonstrate that a deliberate mutant fails the intended gate.
4. Revert the mutant.
5. Run the unit’s focused gate.
6. Run `./check.sh`.
7. Commit only if both are green.
8. Record the commit hash, test commands, and artifact paths in `out/build_manifest.jsonl`.

No later unit may weaken an earlier assertion. If a gate reveals a contradiction in shipped level geometry, activity range, or engine behavior, the agent stops at the last green commit rather than adding a fallback path or feature flag.

---

# Preliminary Bayesian updates from the survey

These are implementation choices, not design changes.

| Question | Live hypotheses and prior | Survey evidence | Posterior/action |
|---|---|---|---|
| Where should knockback live? | H₁ Rust `apply_impulse`, H₂ Python impulse accumulator; prior 3:2 | Spec requires force through physics. `P(E\|H₁)=0.95`, `P(E\|H₂)=0.25`, LR 3.8 | About 5.7:1 for H₁. Add the Rust API; no Python fallback. |
| How should runtime edges be tracked? | H₁ central topology owner, H₂ continue ad-hoc edge-index repair; prior 2:1 | `split_edge` shifts every later edge, and doors, cloister, holes, sites, and breaches all retain indices. `0.90/0.30`, LR 3 | About 6:1. Centralize all runtime topology mutation. |
| How should the hub be supplied to `GameSession`? | H₁ pure programmatic `Level` builder, H₂ load a second JSON from inside `sim.py`; prior 1:1 | `GameSession` currently has no I/O, while `LevelBuilder` and `append_chunk` already provide the needed shape. `0.85/0.35`, LR 2.4 | Use one canonical `game/perihelion/hub.py` builder. |
| Why did the discarded breach fail? | H₁ scale mismatch, H₂ active-window freeze, H₃ AI routing; prior roughly 2:1:1 | Measured 52↔15 scale is 3.47 and predicts a husk diameter near 55 at a 52-wide gate. `P(E\|H₁)≈0.95`, `P(E\|¬H₁)≈0.15`, LR 6.3 | Scale mismatch is overwhelmingly supported for that failure. Gates must still test activity and routing separately. |

---

# Part 1 — dependency-ordered implementation units

## U0. Reapply the pygame-free renderer

**Goal:** `render.py` has one shipping renderer and imports no pygame.

**Files**

- Cherry-pick `203da395` first, as directed.
- Resolve only the minimum conflicts in:
  - `game/perihelion/render.py`
  - `game/perihelion/hud.py`
  - `game/perihelion/app.py`
  - `game/perihelion/testkit/harness.py`
  - `game/perihelion/text.py`
- Update:
  - `game/tests/test_render_backends.py`
  - `game/tests/test_render_headless.py`
- Delete the pygame-backend parity tests rather than preserving a second backend.

**API**

- `Renderer.draw(session) -> numpy.ndarray`
- `text.draw_text(frame, text, position, ...)`
- No renderer API accepts or returns a pygame `Surface`.

**Size:** M. The code already exists, but conflict resolution and removal of the obsolete dual-backend tests are potentially nontrivial.

**Mine**

- Cherry-pick exactly `203da395`.
- Do not lift the tip of `94b3397b:render.py`; it contains draw branches for superseded hub and building implementations.

---

## U1. Instrumentation spine

**Goal:** every simulation path can emit typed, structured, tick-stamped evidence through one always-present channel shared by human and bot runs.

**Files**

Create:

- `game/perihelion/telemetry.py`
- `game/tests/test_telemetry.py`
- `game/tests/test_architecture_boundaries.py`
- `tools/playtest/trace_check.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/app.py`
- `game/perihelion/testkit/harness.py`
- `tools/playtest/farm_record.py`
- `game/perihelion/testkit/replay.py` only if trace metadata needs recording; do not make traces part of replay equality.

**API**

```python
class TraceBus:
    def emit(self, event: TraceEvent) -> None: ...
    def sample(self, sample: StateSample) -> None: ...
    def drain(self) -> list[TraceRecord]: ...

@dataclass(frozen=True, slots=True)
class TraceRecord:
    seq: int
    tick: int
    kind: str
    data: Mapping[str, JsonValue]
```

Typed events added initially:

- `AgentTransition`
- `PortalCrossing`
- `DamageApplied`
- `ImpulseApplied`
- `TopologyChanged`

Reserved for later units:

- `FieldSample`
- `CallLeaseEvent`
- `CallImprintEvent`
- `BreachLifecycle`
- `ReserveSample`
- `DispatchDecision`
- `CorePartEvent`
- `StructureEvent`

`GameSession.trace` always exists. The simulation emits to memory; app and harness drain the same bus to JSONL. Neither audio nor rendering is involved.

**Boundary enforcement**

- `telemetry.py` may import only standard-library typing/dataclass modules.
- It may not import `audio`, `render`, `app`, or pygame.
- Systems receive `TraceBus`, not `Audio` or `Renderer`.
- Trace state cannot affect simulation decisions: the bus exposes no query method.

**Size:** M.

**Mine**

- Partially salvage the session-log writer and `session_report.py` from `94b3397b`.
- Salvage the event naming discipline from `reinforce_trace.py`.
- Do not preserve its ad-hoc introspection of private dictionaries; later systems must emit their own typed events.

---

## U2. Physics impulse and combat canon

**Goal:** all player weapons apply mass-scaled engine impulses, enemy kinematics satisfy the canon, charged Tau reaches 84 damage with impact AoE, and the Warden is a normal 168-HP enemy.

**Files**

Rust long pole:

- `engine/necore/src/physics.rs`
- `engine/necore-py/src/lib.rs`
- `engine/necore/tests/invariants.rs`

Python:

- `game/perihelion/sim.py`
- `game/tests/test_necore_smoke.py`
- `game/tests/test_combat_canon.py` — new
- `game/tests/test_hole_tau.py`
- `game/tests/test_sentry_turret.py`
- `game/perihelion/testkit/loadouts.py`

Content/API cleanup:

- Remove gland and scrap-driver weapon and pickup paths from `sim.py`, PodScene ordering, loadouts, and level entities.

**API**

Rust:

```rust
pub fn apply_impulse(&mut self, id: EntityId, impulse: Vec2)
    -> Result<(), SimError>;
```

Python:

```python
Sim.apply_impulse(entity_id: int, jx: float, jy: float) -> None
```

Game helper:

```python
GameSession._apply_impulse(
    entity_id: int,
    impulse: tuple[float, float],
    source: str,
) -> None
```

Weapon/projectile records carry an impulse magnitude. No weapon damage path writes enemy velocity directly.

First-pass kinematic targets, expressed as measured terminal-speed ratios to the unupgraded Commando:

| Kind | Minimum speed ratio |
|---|---:|
| warden | 1.15× |
| brute | 1.18× |
| spitter | 1.20× |
| husk | 1.25× |
| shrieker | 1.45× |
| flicker | 1.50× |
| mite | 1.55× |

Every enemy mass must exceed `PLAYER_MASS=1.2`; 1.4 is the minimum first-pass value. Turning is acceleration-heading limited instead of snapping movement direction every tick. These values are tuning candidates, not design constants.

Charged Tau:

- maximum direct damage: 84
- first-pass AoE radius: 48 units
- AoE damage and impulse fall off from the impact
- impact terminates the charged projectile

Warden:

- 168 HP
- no brood spawn
- no enrage branch
- rail remains 42

**Size:** L. It touches the Rust ABI, every weapon contact path, enemy motion, tests, and tuning.

**Mine**

- Lift the combat behavior from:
  - `f550bbfb`
  - `ffb95e19`
  - `f954fc26`
- Rewrite its knockback calls to use the new Rust API.
- Do not lift any direct `set_vel` knockback.
- Ignore discarded Warden HP, brood, and hub-core assumptions not matching the ratified spec.

---

## U3. Shared find/senses API

**Goal:** enemy perception, active-portal sensing, and one-hop observations use immutable shared observations rather than reaching into `GameSession` dictionaries.

**Files**

Create:

- `game/perihelion/senses.py`
- `game/tests/test_senses.py`

Modify:

- `game/perihelion/sim.py`
- `game/tests/test_sentry_turret.py`
- `game/tests/test_flicker_lurker.py`

**API**

```python
@dataclass(frozen=True, slots=True)
class SenseHit:
    entity_id: int
    kind: str
    faction: str
    role: str
    polygon: int
    position: tuple[float, float]
    distance: float
    portal_depth: int
    state_tags: frozenset[str]

@dataclass(frozen=True, slots=True)
class PortalSense:
    polygon: int
    edge: int
    target_polygon: int
    active: bool
    midpoint: tuple[float, float]
    portal_depth: int

@dataclass(frozen=True, slots=True)
class SenseFrame:
    observer_id: int
    polygon: int
    hits: tuple[SenseHit, ...]
    portals: tuple[PortalSense, ...]

class SenseQuery:
    def frame(self, observer_id: int, *, portal_depth: int = 1) -> SenseFrame: ...
    def active_portals(self, observer_id: int) -> tuple[PortalSense, ...]: ...
```

`portal_depth > 1` raises `ValueError` for agent-facing calls.

Lacuna probing later receives only:

- target chamber identity
- portal geometry
- sampled chamber signals

It does not receive hidden entity positions or a list of all objects in the adjacent room.

**Boundary enforcement**

- `senses.py` uses a `SenseWorld` protocol.
- It does not import `sim.py`, marrow, scouts, call medium, audio, or render.
- Observations contain no object references and no mutable dictionaries.
- No observation exposes reserve, hub identity, core state, player HP, or private enemy dictionaries.

**Size:** M.

**Mine**

- Lift and generalize `_player_sighting` from `94b3397b`.
- Reuse existing `sight_map`, `point_in_sight`, `visible_set`, and `raycast`.
- Do not create another visibility implementation.

---

## U4. Nine-field signal substrate

**Goal:** all nine chamber fields exist with timestamp-correct exponential decay, portal-graph spreading, one-hop sampling, dynamic-topology invalidation, and structured field telemetry.

**Files**

Create:

- `game/perihelion/signals.py`
- `game/tests/test_signals.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/senses.py`
- `game/tests/test_hole_tau.py`

**API**

```python
class SignalKind(Enum):
    DISTRESS = ...
    DANGER = ...
    NOISE = ...
    TRAIL = ...
    PATROL = ...
    MUSTER = ...
    GARRISON_INTERIOR = ...
    GARRISON_REACH = ...
    KIN = ...

@dataclass(frozen=True, slots=True)
class SignalNeighborhood:
    center: int
    own: Mapping[SignalKind, float]
    adjacent: tuple[tuple[int, Mapping[SignalKind, float]], ...]

class SignalField:
    def emit(self, kind: SignalKind, polygon: int, amount: float, tick: int) -> None: ...
    def sample(self, kind: SignalKind, polygon: int, tick: int) -> float: ...
    def neighborhood(self, polygon: int, tick: int, *, depth: int = 1) -> SignalNeighborhood: ...
    def step_to(self, tick: int) -> None: ...
    def drain(self, polygon_weights: Mapping[int, float], capacity: float, tick: int) -> float: ...
    def on_topology_changed(self) -> None: ...
```

Each chamber/species cell stores `last_updated_tick`; all reads materialize decay from elapsed ticks before use. Sampling depth above one is rejected.

The substrate also owns the per-door traffic marker used by the raid/trail behavior:

```python
deposit_doorway_trail(polygon, edge, amount, tick)
doorway_trail(polygon, edge, tick) -> float
```

This supplements, rather than replaces, the chamber `TRAIL` field.

First-pass field numbers:

| Field | Half-life | Spread |
|---|---:|---|
| Distress | 45 s | 0.12/s neighbor exchange |
| Danger | 180 s | none |
| Noise | 3 s | 1.20/s |
| Trail | 12 s | none |
| Patrol | 60 s | none |
| Muster | 1.0 s | 1.8/s, steep one-hop attenuation |
| Garrison Interior | 1.5 s | special two-front rule |
| Garrison Reach | 2.0 s | 0.7/s |
| Kin | 8 s | 0.45/s |

Only Trail, Patrol, and Danger have ratified half-lives. The others are explicitly expected to move.

**Size:** L. Nine signal rules, lazy decay, dynamic graph changes, and garrison special propagation make this more than a dictionary.

**Mine**

- Clean-lift the compact substrate shape from `94b3397b:game/perihelion/immune.py`.
- Replace its per-tick linear decay with timestamped exponential decay.
- Add all ratified fields, including Kin.
- Reuse its wet-set optimization only after proving inactive rooms decay correctly.
- Rewrite its old species constants.

---

## U5. Coordination behaviors

**Goal:** ordinary combat agents use fractional quorum, chemotaxis, relay recruitment, priority-budget flocking, stand-down, danger holding, trails, and the one-third raid fan.

**Files**

Create:

- `game/perihelion/coordination.py`
- `game/tests/test_coordination.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/signals.py`
- `game/perihelion/senses.py`
- existing enemy-AI tests

**API**

Pure decision surface:

```python
@dataclass(frozen=True, slots=True)
class CoordinationInput:
    senses: SenseFrame
    signals: SignalNeighborhood
    objective: TacticalObjective
    threshold: float

@dataclass(frozen=True, slots=True)
class SteeringRequest:
    direction: tuple[float, float]
    acceleration: float
    priority: int

def quorum_fraction(committed_visible: int, all_visible: int,
                    noise: float, distress: float) -> float: ...

def allocate_acceleration(max_accel: float,
                          requests: Sequence[SteeringRequest]) -> tuple[float, float]: ...

def choose_route(best_edge: int, second_edge: int,
                 raid_member: bool) -> int: ...
```

Spawn-time threshold is stored once in each enemy record, initially sampled in `[0.25, 0.45]`.

The old `alert_enemies()` hop-wake route is removed after all firing/death hooks emit Noise, Distress, Danger, and Muster through the field. It must not remain as a parallel coordination system.

**Boundary enforcement**

- `coordination.py` is a pure decision module.
- It receives immutable sense and signal snapshots.
- It cannot import `GameSession`, marrow, breaches, audio, or render.
- All field sampling remains one hop.

**Size:** L. It rewires the central enemy state machine and movement composition.

**Mine**

- Reuse chemotaxis route scaffolding and pair enumeration from `94b3397b`.
- Replace absolute quorum with the ratified fractional equation.
- Replace weighted boid blending with acceleration-budget allocation.
- Keep trail/raid concepts from `97683cc0`, not its obsolete field constants.

---

## U6. Generic capture system and Warden engulf

**Goal:** the Warden gains the ratified engulf attack through a generic captor/captive system that does not couple player code to the Warden kind.

**Files**

Create:

- `game/perihelion/capture.py`
- `game/tests/test_warden_engulf.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/render.py`
- `game/perihelion/telemetry.py`

**API**

```python
@dataclass(frozen=True, slots=True)
class CaptureSpec:
    captor_id: int
    captive_id: int
    pull_rate: float
    damage_per_second: float
    release: ReleaseCondition
    redirect_fire: bool

class CaptureSystem:
    def begin(self, spec: CaptureSpec) -> None: ...
    def step(self, tick: int) -> None: ...
    def forced_target(self, entity_id: int) -> int | None: ...
    def release_for_entity(self, entity_id: int) -> None: ...
```

Warden state additions:

- `engulf_charge`: stopped; two flashes across 12 ticks
- `engulf_lunge`: impulse/acceleration to approximately 2.5× normal speed
- attack state persists until speed falls below normal
- capture requires contact while engulfing and normalized forward dot > 0.5
- captive takes 75 HP/s
- any weapon fire uses `CaptureSystem.forced_target()`

**Boundary enforcement**

- `capture.py` knows entity ids and physics operations, not player or Warden classes.
- Player firing checks generic forced target only.
- Warden AI creates `CaptureSpec`; it does not mutate player inventory, aim, or HP directly.

**Size:** M.

**Mine**

- Lift constants and sequencing from `b2c27600`.
- Replace `EngulfGrip`’s direct player/Warden assumptions with the generic capture service.

---

## U7. World call medium and finite scouts

**Goal:** vagrants and lacunae exist as finite authored agents, share one call-medium lease, publish expiring imprints, and execute the weakest-in-room caller behavior without access to the marrow.

**Files**

Create:

- `game/perihelion/callmedium.py`
- `game/perihelion/scouts.py`
- `game/tests/test_call_medium.py`
- `game/tests/test_scouts.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/render.py`
- `game/perihelion/telemetry.py`
- `game/perihelion/senses.py`
- `game/perihelion/coordination.py`

**API**

```python
@dataclass(frozen=True, slots=True)
class CallImprint:
    chamber: int
    position: tuple[float, float]
    tick: int
    caller_class: str
    expires_tick: int

class CallMedium:
    def try_lease(self, caller_id: int, tick: int) -> CallLease | None: ...
    def release(self, caller_id: int, reason: str, tick: int) -> None: ...
    def complete(self, caller_id: int, imprint: CallImprint) -> None: ...
    def consume_one(self, tick: int) -> CallImprint | None: ...
```

The medium stores at most one active lease. Imprints expire after 15 seconds and are consumed once whether or not a portal opens.

Scout first-pass stats:

| | Vagrant | Lacuna |
|---|---:|---:|
| HP | 84 | 42 |
| Speed | 1.45× player | 1.20× player |
| Turn rate | 0.55× baseline | 0.50× baseline |
| Rooted broadcast | 6 s | 8 s |
| Total exposure | 8 s | 10 s |

Scout states:

- `infiltrate`
- `brace`
- `transmit`
- `release`
- `pour_observe`
- `seek_safe_garrison`
- `seek_danger_peak`

A scout recognizes a response only by perceiving a newly active portal through `SenseFrame`; it receives no callback from marrow.

Lacuna probe returns only the adjacent chamber’s field sample and portal geometry. Its imprint always uses its body’s current chamber.

**Boundary enforcement**

AST/import gate:

- `scouts.py` may import `senses`, `signals`, `coordination`, `callmedium`, and shared datatypes.
- It may not import `marrow`, `breach`, `hub`, `sim`, `audio`, or `render`.
- `CallImprint` has no reserve amount, desired composition, hub id, or breach id.
- Scout constructors receive no marrow/controller object.

**Size:** L.

**Mine**

- Mine caller state transitions and weakest selection from `823ecde5`.
- Do not lift direct `_open_breach()` calls.
- Do not lift the old weakest-by-HP rule; class order is lacuna before vagrant.
- Mine no obsolete Kin deletion: Kin remains a field.

---

## U8. Topology ownership, breach-site inventory, and the 24-chamber hub

**Goal:** every `GameSession` builds one unreachable 24-chamber hub, and all runtime edge mutation and prevalidated breach sites are owned by a scale-checking topology service.

**Files**

Create:

- `game/perihelion/topology.py`
- `game/perihelion/hub.py`
- `game/tests/test_runtime_topology.py`
- `game/tests/test_hub_layout.py`
- `game/tests/test_breach_sites.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/stream.py`
- `game/perihelion/lighting.py`
- `game/perihelion/signals.py`
- `game/tests/test_hole_tau.py`
- `game/tests/test_cloister.py`
- `game/tests/test_stream.py`
- shipped level generation where walls are too short

**API**

```python
@dataclass(frozen=True, slots=True)
class EdgeHandle:
    token: int

@dataclass(frozen=True, slots=True)
class PortalLink:
    a: EdgeHandle
    b: EdgeHandle
    generation: int

class TopologyManager:
    def carve(self, polygon: int, near: tuple[float, float],
              width: float, purpose: str) -> EdgeHandle: ...
    def connect_equal(self, a: EdgeHandle, b: EdgeHandle,
                      *, tolerance: float = 1e-9) -> PortalLink: ...
    def disconnect(self, link: PortalLink) -> None: ...
    def current_edge(self, handle: EdgeHandle) -> tuple[int, int]: ...
```

All existing runtime mutations—portable hole, cloister, shoot doors, streaming spine, breach—must route through this owner. Raw `sim.split_edge/connect/disconnect` calls outside construction and `topology.py` are rejected by source test.

Hub API:

```python
@dataclass(frozen=True, slots=True)
class HubLayout:
    level: Level
    receiving_apses: tuple[int, int, int]
    guardian_courts: tuple[int, ...]
    collar_chapels: tuple[int, int]
    anchor_chapels: tuple[int, ...]
    scriptorium: int
    source_cells: tuple[int, int, int]
    breach_edges: tuple[EdgeHandle, ...]

def build_hub(seed: int, breach_width: float) -> HubLayout: ...
```

The hub is appended at initialization and is never optional.

Breach width:

```python
W = max(96.0, 2 * largest_dispatchable_radius + 16.0)
```

Both map-side and hub-side site edges are exactly `W`. `connect_equal` checks endpoint lengths before connecting and then checks the derived matrix scale.

**Size:** L/XL. The topology wrapper is broad, and the existing levels contain chambers whose walls cannot fit a 96-unit carve.

**Mine**

- Mine `test_level_geometry.py`.
- Reuse `append_chunk`, `carve_door`, `_shift_edge_maps`, and the streamer BFS pattern.
- Do not lift the discarded octagonal hub, 15-unit corridor, tissue visuals, or `_hub_attach`.
- Use the round-2 24-chamber graph as the programmatic layout seed.

---

## U9. Breach lifecycle, marrow reserve, guardian shelf, and cost-fair dispatch

**Goal:** completed imprints and extreme-distress demands can cause real scale-1 portals, physical guardian dispatch, sustained reserve-governed pour, and honest closure.

**Files**

Create:

- `game/perihelion/breach.py`
- `game/perihelion/marrow.py`
- `game/tests/test_breach_lifecycle.py`
- `game/tests/test_marrow_economy.py`
- `game/tests/test_dispatch_fairness.py`
- `tools/playtest/reinforce_trace.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/telemetry.py`
- `game/perihelion/hub.py`
- `game/perihelion/topology.py`

**API**

Economy:

```python
class ReserveDepot:
    cap: float = 120.0
    reserve: float

    def advance(self, elapsed_seconds: float) -> None: ...
    def can_pay(self, cost: float) -> bool: ...
    def pay(self, cost: float) -> None: ...
    def set_debt(self, amount: float) -> None: ...
```

`advance()` is exactly:

```python
empty = clamp(1 - reserve / 120, 0, 1)
regen = 0.10 * (1 + 2.5 * empty)
```

Marrow controller:

```python
@dataclass(frozen=True, slots=True)
class BreachStatus:
    breach_id: int
    route_interest: bool
    open_tick: int

class MarrowController:
    def step(self, tick: int,
             imprints: tuple[CallImprint, ...],
             breach_statuses: tuple[BreachStatus, ...]) -> tuple[MarrowCommand, ...]: ...
```

No player/fight state appears in its input.

Breach:

```python
class Breach:
    def note_crossing(self, entity_id: int, tick: int) -> None: ...
    def note_route_interest(self, interested: bool, tick: int) -> None: ...
    def request_close(self, reason: ClosureReason, tick: int) -> None: ...
    def step(self, tick: int) -> tuple[BreachEvent, ...]: ...
```

A breach receives close requests. It does not inspect reserve or other breaches.

Dispatch scheduler:

```python
class CostFairScheduler:
    def add_breach(self, breach_id: int) -> None: ...
    def remove_breach(self, breach_id: int) -> None: ...
    def assign(self, unit_cost: int) -> int: ...
```

Each live breach accrues equal credit; assigning a unit subtracts its class cost. A new breach starts at mean credit.

Initial guardian shelf:

- 3 mites
- 2 husks
- 1 spitter
- 1 shrieker
- 1 flicker
- 1 brute
- 1 warden

They are real hub entities. Initial shelf release is pre-produced inventory; later replacements pay reserve and arrive no faster than one per 12 seconds. The scheduler still accounts for shelf unit combat cost to preserve multi-breach fairness.

Formation tell: 3 seconds. Sustained dispatch opportunity: 2.2 seconds.

Closure conditions:

- 45 seconds without any transfer across that exact portal
- marrow exhaustion request, with 10-second grace
- 12 seconds with no hub-side route interest after opening

**Boundary enforcement**

- `ReserveDepot` imports only dataclasses/math.
- A source test rejects `player`, `hp`, `kill`, `difficulty`, `distress`, and `noise` identifiers in `ReserveDepot`.
- `breach.py` may not import `marrow.py`.
- `Breach` stores no collection of other breaches.
- Only `MarrowController` owns the scheduler and compares breaches.
- Spawn provenance records hub polygon and subsequent transfer. No dispatch may spawn directly in the world-side chamber.

**Size:** XL.

**Mine**

- Partial salvage:
  - reserve tick shape
  - breach timers
  - transfer-event crossing hook
  - `reinforce_trace.py`
- Rebuild all portal geometry.
- Reject the old 24-unit reserve, direct world-side spawning, single live attachment, `hub_core`, and permanent shutdown.

---

## U10. Scout strategic cycle, garrisons, and Shrieker trail

**Goal:** scouts alternate safe expansion and base raids, followers settle around oblivious Wardens, and Shriekers lay a follow-me trail that draws ordinary agents.

**Files**

Create/modify:

- `game/perihelion/scouts.py`
- `game/perihelion/garrisons.py` — new
- `game/perihelion/coordination.py`
- `game/perihelion/signals.py`
- `game/perihelion/sim.py`
- `game/tests/test_garrisons.py`
- `game/tests/test_scout_strategy.py`
- `game/tests/test_shrieker_mark.py`

**API**

```python
@dataclass(frozen=True, slots=True)
class SettlementDecision:
    settle: bool
    reason: str

def may_settle(
    senses: SenseFrame,
    signals: SignalNeighborhood,
    continuous_safe_ticks: int,
) -> SettlementDecision: ...
```

Settlement conditions:

- Warden physically present in same chamber
- no hostile visible
- Noise < 0.20
- Danger < 0.35
- condition held continuously for 12 seconds
- at least two settlers for functioning garrison propagation

Settlers:

- remain normal fighters
- ignore external Muster
- emit Garrison Interior/Reach
- persist after Warden leaves

The Warden record gains no follower count, base id, command state, or emissions.

Scout cycle after observing its first successful response:

1. descend Trail/Danger and Kin toward safe, thinly held ground
2. complete a safe call
3. climb Danger toward a peak, refusing any chamber above the high-danger entry threshold
4. call at the last safe chamber
5. repeat

Shrieker behavior emits a follow trail and a local “approach only with enough Muster” influence; it does not become a reinforcement caller.

**Size:** L.

**Mine**

- Reuse Shrieker marker/FSM pieces from `b2c27600`, adjusted to the ratified follow-trail semantics.
- Reuse no contact-pressure substitute for Kin.
- Rewrite garrison settlement to the ratified 12-second Warden-present rule.

---

## U11. CORE organ and hub interior systems

**Goal:** the hub contains destructible, regenerating CORE parts whose physical state controls production, dispatch rate, repair persistence, learning storage, and the reserve-derived blackout.

**Files**

Create:

- `game/perihelion/core_organ.py`
- `game/tests/test_core_organ.py`
- `game/tests/test_core_recovery.py`

Modify:

- `game/perihelion/hub.py`
- `game/perihelion/marrow.py`
- `game/perihelion/sim.py`
- `game/perihelion/render.py`
- `game/perihelion/telemetry.py`

**API**

```python
class CoreOrgan:
    def damage(self, part_id: int, amount: float, tick: int) -> None: ...
    def step(self, tick: int) -> tuple[CoreCommand, ...]: ...
    def production_capacity(self, tick: int) -> float: ...
    def dispatch_interval(self) -> float: ...
    def source_count(self) -> int: ...
```

Part construction exactly follows the ratified table.

Key consequences:

- one Collar destroyed: 3.14 s dispatch interval
- both: 4.89 s
- all three Sources destroyed: `reserve = -32`
- blackout has no timer
- breaches receive exhaustion close requests after 10 seconds
- at reserve > 0, reform exactly:
  - one Source
  - one Anchor
  - three Buds
  - one Caretaker
- Sources heal 2 HP/s after 10 seconds undamaged
- Caretakers heal 6 HP/s while physically in contact
- part damage schedules ordinary Muster response approximately 6 seconds later
- all healing/rebuild requires existing Source/Caretaker state; no hidden reset on death

**Boundary enforcement**

- The organ issues production multipliers and commands; it does not inspect the player.
- The reserve receives `set_debt(-32)` only from the all-sources transition.
- There is no blackout timer field.
- A constructor rejects a hub lacking exactly the required part counts and room assignments.

**Size:** XL.

**Mine**

- Do not lift `hub_core`.
- Use HP constants and repair concepts from round 2/spec.
- The discarded Scriptorium implementation is only a naming/reference source.

---

## U12. Building economy and persistent death

**Goal:** the CUCULUS prints one carryable kit at a time; pods, sentries, and repair stations can be assembled in situ, unpack for 30 seconds, and obey the destruction and support rules.

**Files**

Create:

- `game/perihelion/structures.py`
- `game/tests/test_structures.py`

Modify:

- `game/perihelion/sim.py`
- `game/perihelion/podscene.py`
- `game/perihelion/render.py`
- `game/perihelion/app.py`
- `game/perihelion/stream.py`
- `game/perihelion/testkit/humanbot.py`
- `game/perihelion/testkit/loadouts.py`
- `game/tests/test_economy.py`
- `game/tests/test_corpse_economy.py`
- `game/tests/test_sentry_turret.py`

**API**

```python
class StructureKind(Enum):
    POD = ...
    SENTRY = ...
    REPAIR = ...
    SCRUBBER = ...

@dataclass(slots=True)
class CarriedKit:
    kind: StructureKind

class StructureSystem:
    def print_kit(self, pod_id: int, kind: StructureKind) -> bool: ...
    def pick_up_kit(self, kit_id: int, player_id: int) -> bool: ...
    def assemble(self, player_id: int) -> int | None: ...
    def step(self, tick: int) -> None: ...
```

Rules:

- exactly zero or one carried kit
- loadout starts with zero kits
- carrying reduces movement speed
- carried sprite uses player facing
- every structure is inert and fragile for 30 seconds
- every enemy except mite destroys a structure on contact
- projectile enemies prefer visible structures
- sentry:
  - 50-shot magazine
  - pod support by hop distance, not Euclidean distance
  - rotating target direction
  - damage sufficient to kill a spitter in one shot
  - approximately two shots/second
- repair:
  - requires player physically inside for 20 continuous seconds
  - taking damage or leaving resets progress
  - no remote healing
- no structure is an indestructible `GROUP_PICKUP`

Death:

- world state is never cold-restored
- if no carried chassis is available, the starting pod’s current infinite backup supply revives the player there
- `WorldStreamer.respawn()` is no longer a normal death fallback

**Size:** XL.

**Mine**

- Strong partial salvage of carry, station, structure contact, repair, and sentry functions from `94b3397b`.
- Lift tests selectively.
- Rewrite prices and old pod assumptions against the current spec.
- Do not restore free-anywhere fabrication.

---

## U13. Scrubber, cleaning robot, pod roots, and physical salvage

**Goal:** a pod-linked scrubber subtracts shared signal capacity, and a cleaning robot visibly processes splatter, casings, and physical corpses into occasional components while pod roots grow toward useful material.

**Files**

Create:

- `game/perihelion/cleaning.py`
- `game/tests/test_scrubber.py`
- `game/tests/test_cleaning_robot.py`

Modify:

- `game/perihelion/structures.py`
- `game/perihelion/signals.py`
- `game/perihelion/sim.py`
- `game/perihelion/render.py`
- `game/perihelion/telemetry.py`

**API**

```python
class Scrubber:
    capacity_per_second = 1.2

    def sink_weights(self) -> Mapping[int, float]: ...
    # own room 1.0, adjacent rooms 0.5

class CleaningRobot:
    def assign_next(self, local_tasks: Sequence[CleaningTask]) -> CleaningTask | None: ...
    def step(self, tick: int) -> tuple[CleaningEvent, ...]: ...
```

The 1.2-unit capacity is shared across all nine fields and all covered chambers, allocated proportionally to current removable signal. It is not 1.2 per field.

The cleaning system introduces physical records for:

- enemy remains
- shell casings
- cleanable splatter patches

Components are emitted through one tunable salvage probability/rate. First-pass rate should target roughly 1–3 components after a major base fight, not one component per corpse. This is expected to be wrong.

Agents receive no “scrubbed” observation and have no regional baseline.

**Size:** L.

**Mine**

- Lift pod root and conduit drawing concepts from `c34b956e`.
- The cleaning robot is new work.
- Do not infer missing signal as suspicious.

---

## U14. Lighting, visual tells, HUD strip, and fixed font

**Goal:** muzzle flashes and directional lights use the real lighting system, all marrow/scout/building tells are visible, and the HUD contains only the scrap count in the top-left.

**Files**

Modify:

- `game/perihelion/lighting.py`
- `game/perihelion/levels.py`
- `game/perihelion/render.py`
- `game/perihelion/hud.py`
- `game/perihelion/text.py`
- `game/perihelion/app.py`
- `game/tests/test_lighting_invariants.py`
- `game/tests/test_render_headless.py`
- `game/tests/test_render_layers.py` — mined/new
- `game/tests/test_objective.py`

**API**

Extend `LightSpec`:

```python
@dataclass(frozen=True)
class LightSpec:
    ...
    direction: tuple[float, float] | None = None
    cone_half_angle: float | None = None
```

`LightingSystem.on_topology_changed()` invalidates and rebuilds static-light instances affected by a breach, hole, door, or disconnect.

Visual state must be drawn from the actual simulation state:

- scout brace/root/release and one pulse per second
- breach material absence
- guardian stations occupied/vacant
- Collar missing beats
- CORE part condition
- Warden body flashes
- carried kit rotation
- sentry target rotation and pulsed UV beam
- pod roots/conduits
- cleaning robot tasks

No special warning animation may be emitted by telemetry, audio, or a separate reserve HUD.

Font:

- Fixedsys Excelsior/FSEX path only
- fixed 16-pixel render size

Remove:

- top-left HP, chassis, kits, recall, think indicator, wave
- location banners
- objective one-liner
- initial mid-screen key hints that contradict the new carry loop

**Size:** L.

**Mine**

- Directional lighting and muzzle-light code from `a4a7b4d9` and `45c7ba18`.
- Render-layer tests from the discarded branch.
- Do not lift organic hub tissue art.
- Mine carried-load and structure drawings only after adapting them to current state records.

---

## U15. Canonical world and gauntlet4 integration

**Goal:** all systems are authored into the real world, gauntlet4 is the sole gauntlet, Vigil and stale duplicates are removed, and full live behavior can occur without test-only injection.

**Files**

Modify:

- `levels/gauntlet4.json`
- `levels/l01.json` … `levels/l10.json`
- `levels/campaign.json`
- `game/perihelion/app.py`
- `game/perihelion/__main__.py`
- `game/perihelion/stream.py`
- `game/perihelion/sim.py`
- `game/tests/test_levels.py`
- `game/tests/test_gauntlet_level.py`
- all playtest tools defaulting to stale gauntlets

Create one canonical generator if generation remains necessary:

- `tools/levelgen/gauntlet4.py`

Delete:

- `levels/gauntlet_cal.json`
- `levels/gauntlet_cal2.json`
- `levels/gauntlet_cal3.json`
- `levels/gauntlet_horde.json`
- `levels/vigil.json`
- `game/tests/test_vigil.py`
- `App.start_vigil`
- stale gauntlet builders once the canonical generator supersedes them

Integration work:

- author finite vagrant/lacuna census
- author dormant scouts
- ensure every call-capable chamber has valid fixed-width sites
- designate rare storage areas for field-repair kits
- remove random medkit drops and scattered medkits
- remove gland/scrap pickups
- add hub visual kinds/lights
- ensure Portable Hole is in full loadout
- ensure mites and Shriekers remain hole-capable

Direct-breach threshold:

1. Run aggressive full-clear traces before enabling the direct path.
2. Measure the peak sustained Distress distribution.
3. Commit a threshold near twice the highest aggressive-play peak, with a sustained-duration requirement.
4. The threshold remains a hardwired scalar, not a config flag.

**Size:** XL. This is content migration, tool cleanup, balance, and real-run integration.

**Mine**

- Partially mine `gauntlet4_rework.py` for additive geometry and scout placement.
- Do not copy its old vagrant/lacuna stats or old breach implementation.
- Mine `test_level_geometry.py`.
- Update every tool to `levels/gauntlet4.json`; do not retain aliases.

---

## U16. Global acceptance harness and killbox experiment

**Goal:** one command proves the complete marrow loop in isolated vectors and a full real gauntlet run, and separately measures whether mouth fighting strictly dominates.

**Files**

Create:

- `tools/playtest/marrow_acceptance.py`
- `tools/playtest/check_frame_review.py`
- `tools/playtest/killbox_experiment.py`
- `tools/playtest/MARROW_REVIEW_RUBRIC.md`
- `game/tests/test_marrow_acceptance_vectors.py`

Modify:

- `tools/playtest/framecheck.py`
- `tools/playtest/farm_record.py`
- `ENGINE_INVARIANTS.md`
- `check.sh` only for fast acceptance vectors; full-run vision review remains a release artifact gate because of time/cost.

**API/commands**

```bash
uv run python tools/playtest/marrow_acceptance.py \
  --level levels/gauntlet4.json \
  --trace out/marrow_acceptance/trace.jsonl \
  --capture out/marrow_acceptance/capture

uv run python tools/playtest/framecheck.py \
  --rec out/marrow_acceptance/capture \
  --every-ticks 5

uv run python tools/playtest/check_frame_review.py \
  out/marrow_acceptance/capture/review

uv run python tools/playtest/killbox_experiment.py \
  --trials 64 \
  --out out/killbox
```

**Size:** L.

**Mine**

- `reinforce_trace.py`, `session_report.py`, frame-review rubric, farm recording, and existing matrix/farm infrastructure.
- Do not use app `--record` as evidence for a farm-exact bot run.

---

# First overnight cut line

## Safe overnight prefix: U0 through U3

That leaves the branch with:

- the required pygame-free renderer
- always-on structured instrumentation
- correct engine impulses and ratified combat arithmetic
- a real shared senses API already consumed by existing AI

This prefix is green and meaningful. No unused coordination substrate is left hanging.

Expected overnight sequence:

1. U0: renderer cherry-pick and repair
2. U1: instrumentation
3. U2: impulse/combat canon
4. U3: senses

If U3 is not complete, stop after U2. Do not begin U4 unless there is enough uninterrupted time to finish U5 as well; a signal substrate with no decision consumer is a poor unattended stopping point even if its tests pass.

---

# Part 2 — unit verification gates

Every new invariant must be added to `ENGINE_INVARIANTS.md` with an exact test name and a fail-first mutant record.

## U0 gate — pygame-free renderer

### 1. Construction/unrepresentable state

- AST test fails if `render.py`, `hud.py`, or `text.py` imports pygame.
- Repository test fails if a second renderer backend class exists.
- `Renderer.draw()` rejects non-NumPy output.

### 2. Isolated vector

Render `smoke_4polygon.json` for 240 scripted ticks.

Assertions:

- frame shape is `(640, 360, 3)`
- dtype is `uint8`
- at least 95% of frames differ from their predecessor during movement
- no exception under the dummy video driver

### 3. Live-run evidence

Capture the first 5,000 ticks of gauntlet4. Frame review asks:

- Are floors, entities, shadows, and portal seams layered without holes?
- Is any prior frame retained or smeared?
- Is text consistently bitmap-sharp?

### 4. Makes impossible

- Silent pygame reintroduction
- dual backends drifting apart
- a renderer that passes imports but returns an unusable object

---

## U1 gate — instrumentation spine

### 1. Construction

- Typed event constructors reject missing fields.
- `TraceBus` has no read/query API.
- import-boundary test forbids audio/render/app imports.
- sequence numbers must increase; tick numbers may repeat but may not decrease.

### 2. Isolated vector

Run a 120-tick two-room level with one shot and one portal crossing.

Assert exactly:

- 120 input records from both app-style and harness-style recorders
- one `DamageApplied`
- one or more `ImpulseApplied`
- one `PortalCrossing` for the player
- samples at ticks `15, 30, 45, 60, 75, 90, 105, 120`
- app and harness JSON schemas are identical

Do not assert complete event-stream determinism across runs.

### 3. Live-run evidence

A 10,000-tick gauntlet trace must:

- parse completely
- contain input records, state samples, damage, transitions, and portal crossings
- have no audio event as the sole source of a gameplay fact

### 4. Makes impossible

- “It happened” claims based on sound playback
- human runs being less instrumented than bot runs
- telemetry changing simulation behavior

---

## U2 gate — impulse/combat canon

### 1. Construction

- source test rejects `set_vel(... knock...)` and velocity increments in all damage paths
- Rust entity rejects impulses on nonexistent ids
- weapon table constructor requires an impulse entry for every damaging player weapon
- Warden constructor rejects HP other than 168
- old brood/enrage keys are absent

### 2. Isolated vectors

**Impulse mass law**

Apply `(400, 0)` to masses 1 and 4 at rest.

Assert:

- `Δv₁ = 400 ± 1e-9`
- `Δv₄ = 100 ± 1e-9`
- ratio `4.0 ± 1e-9`

**Weapon arithmetic**

- four rail hits kill a 168-HP Warden
- three rail hits leave 42 HP
- two maximum charged Tau hits kill it
- one leaves 84 HP
- charged Tau impact damages and pushes a target 20 units away
- a target 60 units away is unaffected for the initial 48-unit radius

**All weapons push**

For each weapon, hit a mass-2 stationary husk and assert velocity projected along shot direction becomes positive.

**Kinematics**

Measure terminal speed over 10 seconds in an empty room. Every roster entry must meet its minimum ratio. A 90-degree target reversal must take longer for every enemy than for the player and longer for Warden than mite.

### 3. Live-run evidence

Gauntlet trace checker requires:

- all seven enemy kinds receive at least one `ImpulseApplied`
- no Warden emits brood/enrage transitions
- at least one Warden death has exactly four cumulative rail-equivalent 42-damage hits or two 84-damage Tau hits in the trace
- fallback sequences show enemy speed greater than player speed while distance is recovered through impacts/turning

Vision rubric:

- Does knockback visibly move bodies rather than teleport them?
- Does charged Tau visibly detonate on impact?
- Do heavy enemies visibly overshoot or turn wide?

### 4. Makes impossible

- mass-independent push
- direct velocity-write knockback
- 64-damage charged Tau
- 520-HP boss Warden
- “faster” enemies that remain outrunnable in measured motion

---

## U3 gate — senses

### 1. Construction

- frozen/slot dataclasses
- `portal_depth > 1` raises
- observations contain no mutable records, HP, reserve, or hub reference
- forbidden-import AST test

### 2. Isolated vector

Build three rooms:

- A↔B
- B↔C
- an observer in A
- visible enemy in B through the portal
- hidden enemy in B behind terrain
- enemy in C

Assert:

- visible B enemy appears with `portal_depth=1`
- hidden B enemy does not appear
- C enemy does not appear
- active A↔B portal is returned
- disconnecting it removes the portal observation on the next query

Lacuna probe vector:

- probe B from A
- receive B’s chamber id and fields
- receive zero hidden entity identities

### 3. Live-run evidence

Trace checker compares every AI engagement transition with a corresponding recent `SenseHit` or field-driven search decision. No enemy may fire without a sight observation unless its weapon explicitly supports blind fire.

### 4. Makes impossible

- adjacent-room wallhacks
- deep omniscient perception
- scouts reading hub state through a “sense” object
- duplicate visibility code

---

## U4 gate — signals

### 1. Construction

- exactly nine `SignalKind` members
- per-cell `last_updated_tick`
- negative time deltas raise
- depth above one raises
- unknown polygons raise
- topology mutation must call `on_topology_changed`; topology tests verify this
- all field values are finite and nonnegative

### 2. Isolated vectors

**Decay**

Emit Trail 0.80 at tick 0:

- at 12 s: `0.400 ± 0.002`
- at 24 s: `0.200 ± 0.002`
- at 36 s: `0.100 ± 0.002`

Emit Danger 0.40:

- at 180 s: `0.200 ± 0.002`
- at 360 s: `0.100 ± 0.002`

Update the same room every tick in one run and only at final read in another. Values must differ by less than `1e-9`.

**Spread**

Two equal rooms, one portal, initial value 1 in A and 0 in B:

- Distress in B after 1 s: `[0.102, 0.109]`
- Noise in B after 1 s: `[0.35, 0.37]`
- Danger in B remains exactly 0

Disconnect at 0.5 s; B must receive no further transfer after disconnection.

**One-hop sample**

A-B-C: neighborhood from A contains A and B, never C.

### 3. Live-run evidence

Gauntlet trace requires:

- Noise peaks follow firing
- Distress follows enemy damage only
- Danger follows death
- Trail follows player chamber occupancy
- fields decay during quiet intervals independent of room update frequency
- no signal crosses a closed door or sealed breach

### 4. Makes impossible

- frame-rate-dependent decay
- Euclidean spread through walls
- Kin being replaced by local contact counts
- agents sampling two or more hops

---

## U5 gate — coordination

### 1. Construction

- threshold sampled once and stored
- no `alert_enemies()` parallel wake path remains
- steering allocator accepts a finite acceleration budget and cannot return a larger vector
- all decisions consume `SenseFrame` and `SignalNeighborhood`

### 2. Isolated vectors

**Fractional quorum**

With `Noise+Distress=0.60`, no committed peers:

- 3 visible calm peers: `f = 1/4 = 0.25`
- 6 peers: `f = 1/7 ≈ 0.142857`
- 12 peers: `f = 1/13 ≈ 0.076923`

The computed Hill hazard must strictly decrease in that order.

Over 1,000 independent spawn thresholds, the three-agent room must produce at least twice as many commitments in two seconds as the twelve-agent room. This is a statistical behavior gate, not bit-identity.

**Priority flocking**

Give an agent:

- separation request 100 left
- objective request 100 right
- acceleration budget 100

Result must be full left, not zero.

**Raid fan**

On a diamond graph with best route B and second route C, 300 committed searchers must route 80–120 through C.

**Stand-down**

A hunter outside the player’s room with all local relevant fields below threshold for 300 ticks must exit hunt on tick 300±1. A hunter in the same room must not.

**Danger hold**

A lone agent at a high-Danger doorway remains outside for 300 ticks and emits Muster; with sufficient local committed peers it crosses.

### 3. Live-run evidence

Gauntlet trace must show:

- at least one sparse-edge cascade preceding dense-room commitment
- at least one stand-down
- at least one doorway hold followed by coordinated crossing
- multiple route edges used in one raid
- no remaining omniscient `next_edge(...player_polygon)` pursuit without a sensed/field objective

Vision rubric:

- Do groups maintain visible gaps at doors?
- Do they fan across routes rather than form a single conga line?
- Does a lone agent visibly wait at dangerous ground?

### 4. Makes impossible

- packed halls flipping more easily than pickets
- weighted cancellation into doorframes
- permanent hunt for every standard enemy
- global player-position pursuit masquerading as chemotaxis

---

## U6 gate — engulf

### 1. Construction

- player code contains no `warden` type check
- Warden code cannot directly subtract player HP
- capture releases automatically if captor no longer exists
- only one captor can own a given captive

### 2. Isolated vector

- Warden enters range.
- For 12 charge ticks, speed remains below 1 unit/s.
- Exactly two flash-state transitions occur.
- Lunge peak is `[2.4, 2.6] ×` normal speed.
- Glancing contact with dot 0.49 does not capture.
- Contact with dot 0.51 captures.
- After 60 captured ticks, player loses `75 ± 1` HP.
- Firing pistol while aiming away damages the Warden.
- Killing Warden releases the player on the same tick.

### 3. Live-run evidence

Trace must contain charge → lunge → either miss or capture. Frame review asks:

- Are the two body flashes visible on the Warden itself?
- Is the pause before lunge readable?
- Does capture pull the player inward rather than snap instantly?

### 4. Makes impossible

- hidden instant grab
- glancing-contact captures
- player-specific Warden code
- escape without killing the captor

---

## U7 gate — call medium and scouts

### 1. Construction

- forbidden-import gate for `scouts.py`
- imprint schema rejects reserve/composition/hub fields
- one lease maximum
- imprint chamber must equal the caller’s physical chamber at completion
- scout census can only decrease after initialization

### 2. Isolated vectors

**Lease**

Two lacunae begin brace on the same tick:

- exactly one lease granted
- second remains non-transmitting
- killing holder releases lease within one tick
- second can acquire it next

**Weakest rule**

One vagrant and one lacuna in the room:

- lacuna transitions to brace
- vagrant remains combat-active

Two vagrants only:

- exactly one acquires the medium

**Timing**

- vagrant rooted for exactly 360 ticks, total exposed sequence 480 ticks
- lacuna rooted for exactly 480 ticks, total exposed sequence 600 ticks
- displacement during rooted broadcast < `1e-6`

**Dry call**

Complete one call with no consumer response:

- one imprint exists
- `consume_one()` removes it
- no queued retry remains
- scout receives no failure reason

**Probe**

Lacuna in A probes B; completing its call still creates an A imprint.

### 3. Live-run evidence

In gauntlet4:

- finite census at tick 0 equals authored census
- every scout death permanently decrements it
- at least one full broadcast occurs
- no simultaneous rooted broadcasters
- every imprint position matches caller position
- every imprint is consumed or expires, never waits indefinitely

Vision rubric:

- Is the scout stationary and visibly exposed for the whole broadcast?
- Does it pulse once per second?
- Can the first causal lesson “pulse, then wall opens” be seen when marrow is available?

### 4. Makes impossible

- scouts querying reserve
- calls queued until affordable
- lacuna calling through a cordon
- renewable Adversary scouts

---

## U8 gate — topology and hub

### 1. Construction

`TopologyManager.connect_equal()`:

1. resolves both current edge indices
2. measures both lengths
3. rejects `abs(la-lb) > 1e-9`
4. connects
5. reads `portal_xform`
6. computes `scale = hypot(m[0], m[3])`
7. rejects `abs(scale-1) > 1e-9`
8. disconnects immediately if postcondition fails

Additional invariants:

- all runtime `split_edge/connect/disconnect` calls must occur in `topology.py` or initial static world construction
- stale `EdgeHandle` generation raises
- every world has exactly one `HubLayout`
- hub has exactly 24 chambers
- before any breach, player-to-hub hop distance is `-1`

### 2. Isolated vectors

**Scale regression**

- 96↔96 succeeds and reports scale 1
- 96↔52 raises before leaving a live portal
- deliberate mutant removing the length check must still fail on post-transform assertion

**Edge shifting**

Carve three sites in one polygon in varying edge order. Existing door, hole, and site handles must still resolve to their intended geometric midpoint within `1e-6`.

**Hub graph**

Assert:

- 24 chambers
- three receiving apses
- source-cell depth from each apse is 10 or 11
- shallow transept loop exists
- after the Gatehouse, every path to a Source uses the axial trunk
- three Source Cells are distinct and pairwise nonadjacent
- first three depth bands contain 45–55% of floor area

### 3. Live-run evidence

Loading gauntlet4 must emit:

- one `hub_built`
- 24 appended hub polygons
- no reachable hub path before a breach
- valid site count per chamber as required by migrated content
- every static light cache rebuild after topology mutation

Frame review on an entered hub asks:

- Does it read as manufactured Testator architecture rather than a cave?
- Do traffic, light, and vacant posts point inward?
- Are there no visible scaling jumps at the portal?

### 4. Makes impossible

- recurrence of the 52↔15 scale bug
- stale edge references after later splits
- optional/None marrow hub
- a shallow eight-room “system diagram” hub

---

## U9 gate — breach and dispatch

### 1. Construction

- `Breach` cannot import reserve/marrow or store other breaches
- marrow input has no player or combat fields
- a dispatch entity must be created in a hub polygon
- world-side spawn of a dispatched unit raises
- opening requires a free prevalidated map site and free receiving-ap se edge
- opening cannot resize or widen a site
- no affordable-substitution branch exists

### 2. Isolated vectors

**Reserve**

- at reserve 120, one second adds `0.10 ± 0.001`, capped at 120
- at reserve 0, one second adds `0.35 ± 0.001`
- from `-32`, after 90 s reserve is in `[-0.6, -0.4]`
- after 92 s reserve is positive
- no timer field is present

**Payment stall**

At reserve 0:

- pending mite wait: approximately 2.86 s
- pending brute: 11.43 s
- pending Warden: 22.86 s
- selected class remains unchanged while waiting

**Physical entry**

Open one breach with eight available guardians. By 30 seconds:

- all eight have at least one transfer event
- every spawn polygon is in the hub
- every final polygon is world-side
- none was teleported or spawned world-side
- no entity remains touching the mouth for more than five continuous seconds solely because of fit failure

**Closure**

- no crossing: close at 45 s ±1 tick
- projectile crossing at 44 s resets the idle timer
- exhaustion request: closes 10 s later despite repeated crossings
- no route interest: closes 12 s after the interest timer begins

**Fairness**

Two breaches, enough units for total dispatch cost 100:

- cumulative cost difference between gates ≤ maximum single-unit cost, 8
- after a Warden goes through A, B receives cheaper bodies until cost balance returns
- new breach begins within one unit cost of mean credit

### 3. Live-run evidence

Required trace sequence in gauntlet4:

1. `CallImprintEvent(completed)`
2. `BreachLifecycle(open_requested)`
3. `TopologyChanged(connect)`
4. 3-second formation interval
5. guardian dispatch
6. hub-to-world `PortalCrossing`
7. ordinary AI transitions in world chambers
8. reserve decline and payment stalls
9. closure by idle, exhaustion, or route-usefulness condition

The checker rejects a run where reinforcement entities first appear world-side.

Vision rubric:

- Is the breach an absence in the wall, not a targetable object?
- Do agents physically walk through it?
- Are bodies unchanged in size?
- Is there visible space between arrivals rather than a log jam?
- Does the initial guardian burst disappear on later calls?

### 4. Makes impossible

- fake reinforcement spawning
- breach objects reading reserve
- headcount round-robin instead of cost fairness
- cheap-unit substitution hiding depletion
- unkillable portal mouth modeled as an NPC

---

## U10 gate — garrisons and strategic expansion

### 1. Construction

- Warden schema rejects follower/base fields
- no garrison entity or garrison HP exists
- settlement timer resets immediately on any failed condition
- agents may sample only own/adjacent signals

### 2. Isolated vectors

**Settlement**

Place a Warden and two followers in a quiet chamber:

- at 719 ticks, zero settlers
- at 720 ticks, both become settled
- removing the Warden at tick 600 prevents settlement
- removing it after tick 720 leaves existing settlers
- third later follower cannot settle without Warden present

**Field behavior**

- one settler produces Reach but not functioning Interior
- two settlers produce Interior where two fronts meet
- destroying one causes Interior to decay on its 1.5-second half-life

**Scout cycle**

On a graph with a low-Kin safe branch and a high-Danger branch:

- safe phase chooses the low-Kin branch
- raid phase moves toward increasing Danger
- if next chamber exceeds high-danger threshold, scout stops in current chamber and calls there

**Shrieker**

A Shrieker tailing the player leaves a Trail gradient. Uninformed agents follow it but hold short when Muster is insufficient.

### 3. Live-run evidence

Gauntlet trace must show:

- at least one scout choosing lower Kin
- at least one two-settler garrison
- a Warden state trace unchanged by settlement
- settled agents refusing outside Muster
- later combat destroying a garrison and its fields decaying

Vision rubric:

- Does a garrison look like ordinary agents holding a room, not a spawned base object?
- Do followers remain after the Warden leaves?
- Does Shrieker movement visibly draw other enemies without opening a breach?

### 4. Makes impossible

- leader command AI sneaking in
- hot battlefields becoming bases solely from Distress
- garrison clustering despite Kin
- hidden garrison objects

---

## U11 gate — CORE

### 1. Construction

- exact part counts and room placement required
- no master HP
- no invulnerability state
- no mandatory-order field
- no blackout countdown
- all three Source Cells must be separate
- Core production capacity is derived from living parts and pipeline state

### 2. Isolated vectors

- one rail kills a 42-HP Caretaker/Bud
- two rails or one charged Tau kill an 84-HP Anchor/Scriptorium
- three rails leave a 168-HP Source at 42
- four rails kill it
- one Collar loss changes interval immediately from 2.20 to 3.14 s
- second changes it to 4.89 s
- Source undamaged for 599 ticks does not heal; at 600 ticks healing begins at 2 HP/s
- Caretaker not in contact heals 0; in contact heals 6 HP/s
- all Sources dead sets reserve exactly to `-32`
- recovery occurs only as reserve crosses above zero
- reformed counts are exactly 1 Source, 1 Anchor, 3 Buds, 1 Caretaker
- player death does not restore parts or reserve

### 3. Live-run evidence

A hub raid trace must show at least two valid target orders in separate runs, such as Collar-first and Source-rush. Checker verifies:

- immediate interval change after Collar damage
- damage persists after Caretaker death
- all-source kill causes debt
- world-side dispatch stops during debt
- existing breaches close after grace
- dry scout calls continue
- recovery is tied to reserve crossing zero

Vision rubric:

- Are CORE parts distinct, physical targets?
- Does damaged machinery visibly miss beats?
- Are there no boss phases or master bar?
- Does the place visually explain that production comes from deeper rooms?

### 4. Makes impossible

- scripted blackout timer
- chip damage persisting despite live repair
- mandatory boss order
- a single static “core NPC”

---

## U12 gate — buildings and death

### 1. Construction

- carry slot type contains zero or one kit
- attempting to print/pick up a second kit fails without consuming resources
- structures use a dedicated collidable group, not indestructible pickup records
- no remote-repair API
- no death path may call cold world restore

### 2. Isolated vectors

- loadout begins with zero kits
- printing one creates one physical kit
- carrying it reduces measured terminal player speed by the configured multiplier
- carried facing follows player facing within one tick
- building is inactive at tick 1,799 and active at 1,800
- brute contact destroys it on first contact
- mite contact does not
- sentry fires no more than 50 unsupported shots
- pod in same or adjacent hop supports it; Euclidean-near but disconnected pod does not
- spitter dies in one sentry hit
- repair progress:
  - 1,199 continuous ticks: no heal
  - 1,200 ticks: heal completes
  - leaving at tick 1,000 resets to zero
- death with zero racked chassis revives at starting pod and preserves enemies, reserve, breaches, CORE damage, signals, and structures

### 3. Live-run evidence

Gauntlet trace must contain:

- pod prints kit
- player carries exactly one
- movement penalty while carried
- structure placed away from immediate enemies
- 30-second unpack
- sentry expends ammunition
- enemy destroys at least one isolated structure
- player completes or aborts a 20-second repair
- death/revival with unchanged world hashes for persistent systems

Vision rubric:

- Does the carried object look attached to and rotate with the body?
- Is each structure’s purpose readable before it activates?
- Does the sentry turn toward its target and visibly run dry?
- Is repair visibly vulnerable rather than remote?

### 4. Makes impossible

- dropping active turrets into a swarm
- infinite sentry ammunition
- Euclidean pod support
- inventory stacks of kits
- world reset on death

---

## U13 gate — scrubber and cleaner

### 1. Construction

- scrubber receives only a `SignalField` sink interface
- no “quietness” or regional baseline query exists
- sink capacity is one shared scalar
- robot can act only if linked by hop path to both a pod and scrubber
- components can only be emitted after a completed physical cleaning task

### 2. Isolated vectors

Emit one unit into each of the nine fields in the scrubber’s chamber. After one second:

- total removed across all fields is `1.20 ± 0.02`, not 10.8
- identical fields lose equal amounts
- adjacent-only chamber removes at half weighting relative to own chamber
- direct sight remains unchanged

Quiet base:

- low continuous emissions remain below 0.10 after settling

Loud fight:

- emissions above 1.2 units/s accumulate and leak into adjacent rooms

Robot:

- with ten remains/casing/splatter tasks, robot visibly completes all
- no components appear before a task completion
- first-pass long-run mean is within the committed salvage band, initially 1–3 components per ten substantial corpse tasks

### 3. Live-run evidence

Trace compares matched scrubbed and unscrubbed bases:

- scrubbed quiet base has substantially lower field integral
- active fight still leaks
- agents do not path toward the base merely because values are unusually low
- robot task and component emissions are causally linked

Vision rubric:

- Does the robot scrub splatter, sweep casings, and move bodies?
- Do pod roots reach toward the resulting piles?
- Are components emitted sparingly rather than as a fountain?

### 4. Makes impossible

- 1.2 capacity per signal
- scrubbed regions becoming independently suspicious
- cosmetic-only cleaning
- free passive component generation

---

## U14 gate — visual systems

### 1. Construction

- all visual tells read actual system state
- no reserve HUD
- renderer cannot subscribe to telemetry
- static-light cache must be invalidated on topology version changes
- font constructor rejects sizes other than 16 for game UI
- HUD test fails if top-left includes anything but scrap

### 2. Isolated vectors

- directional light illuminates points inside cone and not equal-radius points outside it
- muzzle flash creates a `LightSpec` visible through an open portal and blocked by a wall
- opening a breach changes static-light instances on the next frame
- sentry facing converges toward target
- scout emits exactly one visible pulse per 60 ticks
- Collar unpaid cycle has machinery motion without an arriving silhouette
- carried sprite rotates 90 degrees when player does

### 3. Live-run evidence

Mandatory full-run frame review every fifth simulation frame. Reviewers answer:

- Can the scout’s brace, rooted broadcast, pulses, and release be distinguished?
- Does the wall opening follow the same broadcast seen earlier?
- Are reserve stalls represented by actual missing arrivals/machinery beats?
- Are sentry aim, firing, ammo exhaustion, and destruction legible?
- Does the Warden flash before lunging?
- Does the hub read as built, consecrated machinery corrupted secondarily?
- Is only scrap shown top-left?
- Is every UI glyph Fixedsys at 16 px?

### 4. Makes impossible

- fake tells detached from arithmetic
- stale lighting across a new portal
- hidden sentry state
- legacy HUD/banners quietly surviving

---

## U15 gate — canonical integration

### 1. Construction

Repository assertions:

- only `levels/gauntlet4.json` matches `gauntlet*.json`
- no `vigil.json`
- no `start_vigil`
- no game/tool defaults reference removed gauntlets
- every shipped level loads
- every portal in every shipped level has scale 1
- each call-capable chamber has 1–3 valid sites
- every world builds exactly one hub
- no CORE production table contains vagrant/lacuna
- no random medkit drop remains

### 2. Isolated/content vectors

- regenerate gauntlet4 and compare byte-for-byte to committed JSON
- finite scout count matches authored manifest
- storage-area repair kits occur only in designated storage polygons
- direct threshold is greater than twice the maximum sustained aggressive-run Distress used to derive it
- Portable Hole path admits player, mite, and Shrieker but rejects brute/Warden by physical fit

### 3. Live-run evidence

A full gauntlet4 run must mechanically show:

- authored scouts become active
- at least one interrupted call
- at least one completed call
- at least one dry call
- at least one physical breach pour
- at least one closure
- player fallback to a firebase
- building unpack/support/destruction
- persistent death/revival if death occurs
- optional hub entry and exit strategy in the acceptance run
- no loading of a stale gauntlet or Vigil path

### 4. Makes impossible

- test-only marrow that never fires in the real level
- stale duplicate content
- renewable scouts
- direct breach threshold occurring in ordinary aggressive play
- “valid in synthetic test, impossible in gauntlet geometry”

---

# Global acceptance harness

The marrow unit is **DONE** only when all of the following appear in one accepted artifact set.

## Mechanical checklist

`marrow_acceptance.py` fails unless the trace proves:

1. Every world constructed one hub.
2. Hub was initially unreachable.
3. A lacuna or vagrant perceived its local preconditions.
4. The weakest eligible class acquired the sole medium lease.
5. It braced, rooted, pulsed, and completed the call while stationary.
6. The imprint contained only chamber, position, tick, and caller class.
7. Marrow consumed the imprint exactly once.
8. A map site and hub site of equal width were connected.
9. Derived portal scale was `1 ± 1e-9`.
10. A three-second formation period occurred.
11. Agents originated in the hub.
12. Agents crossed through transfer events.
13. Agents then used normal AI in world chambers.
14. Reserve changed only according to regeneration and production payments.
15. Two live breaches received approximately equal dispatch expenditure.
16. An unaffordable selected class waited without substitution.
17. The stream fought the player or firebase.
18. At least one breach timer was reset by a projectile or entity crossing.
19. Exhaustion or idleness eventually closed a breach.
20. A dry scout call occurred while supply was unavailable.
21. Entering the hub showed a depleted guardian shelf.
22. CORE damage changed the corresponding real subsystem.
23. Three Source deaths set reserve to `-32`.
24. Blackout length emerged from repayment rather than a timer.
25. Calls continued during blackout.
26. Recovery occurred only when reserve crossed zero.
27. Player death did not reset the world.
28. Finite scout census never increased.
29. No runtime portal scale differed from one.
30. No dispatch entity was spawned world-side.

## Full-run visual gate

Capture every simulation frame with the farm-exact path. Sample every fifth frame. Split the samples into contiguous reviewer spans.

`check_frame_review.py` must reject the review unless:

- every sampled frame is covered exactly once
- every span has category checklists
- findings cite frame filenames and timestamps
- no unexplained gap exists
- event-indexed required scenes are covered
- reviewers answer all marrow-specific rubric questions
- there are no unresolved P0/P1 findings

The full run must reach a terminal outcome; for final acceptance it must be a successful gauntlet4 clear, not a ten-second demonstration or isolated showcase.

---

# Killbox measurement

## Hypotheses

- **H₁:** fighting directly at the breach mouth strictly dominates.
- **H₂:** standing off and fighting across approach geometry is better on at least one meaningful resource.
- **H₃:** neither dominates; choice depends on class mix, number of breaches, or structure placement.

Prior should remain approximately 1:1:1 until measured.

## Experiment

Run at least 64 paired trials across the same seed/class-package schedule:

### Policy A — mouth hold

- sentry and player arrest position centered on the breach mouth
- fire begins at first visible crossing

### Policy B — stand-off/fallback

- same resources and package
- arrest position at least one room or prepared firing lane back
- no firing through the mouth before enemies enter approach geometry

### Policy C — multi-route pressure where geometry permits

- same resources
- second route/breach active
- fallback position must cover movement rather than the portal plane

Do not clone a mid-run state through unsupported serialization. Reconstruct matched scenarios from identical initial conditions and randomized seeds. Do not require bit-identical outcomes.

## Metrics

Per trial and policy:

- ammunition spent
- player damage taken
- sentry shots spent
- structures lost
- components gained/lost
- enemies killed
- reserve exhausted
- time to exhaustion
- breach crossings denied
- retreat portals denied/closed
- player death
- time pinned in the mouth chamber
- number of enemies simultaneously able to attack
- fraction of sentry fire wasted on congestion/occlusion
- successful hub-entry window
- usable blackout seconds after returning to the world objective

## Decision rule

Mouth holding is “strictly dominant” only if its paired bootstrap 95% intervals show:

- no more ammunition spent
- no more damage taken
- no more structures lost
- no more retreat access lost
- and at least one strictly better result

across the representative package/multi-breach strata.

If H₁ wins, the next unit changes approach geometry, arrest positions, and multi-route pressure. It must not inflate enemy HP or damage.

---

# Part 3 — risks and long poles

## Critical engine and infrastructure gaps

### 1. Engine impulse API

**Status:** missing; critical path for U2.

**Correct action:** add `Sim::apply_impulse` in Rust and expose it through PyO3.

**Fallback:** none. A Python velocity accumulator still resolves to a direct velocity write and violates the ratified rule. U2 must block if the Rust change cannot land.

---

### 2. Stable edge identities

**Status:** engine exposes numeric edge indices only; `split_edge` shifts later edges.

**Correct action:** Python `TopologyManager` owns stable handles and all runtime mutation.

**Fallback:** none involving ad-hoc `_shift_edge_maps` additions. That is the failure-prone design being replaced.

---

### 3. Runtime disconnect and dynamic polygons

**Status:** both already exist.

**Correct action:** preflight them with isolated tests before building breaches.

If the binding is unexpectedly missing or broken, expose/fix the existing Rust operation. Do not represent closure with an invisible wall entity, destructible plug, disabled collision, or fake closed state.

---

### 4. Static-light topology cache

**Status:** stale after runtime portal changes.

**Correct action:** topology manager notifies `LightingSystem.on_topology_changed()`.

**Fallback:** rebuild all static-light instances after any topology change. This is slower but honest and does not create a second lighting path.

---

### 5. Active-window limitation

**Status:** critical and unresolved by the engine. Only polygons within five hops of the player receive physics and AI.

A live breach makes the Receiving Apse close to the world-side site, but:

- deep hub production can remain frozen
- a breach more than roughly four world hops from the player can freeze its hub-side agents
- behind-the-line reclamation can stop when the player moves away
- ten-to-eleven-hop hub depth is inactive while the player remains outside

**Compliant first implementation:**

- reserve arithmetic, imprint expiry, field decay, and closure timers continue analytically
- standing guardians and replacement spawn points must be in the active shallow hub bands when a nearby breach is used
- no claim is made that distant offscreen battles continue
- inactive-breach incidence is logged explicitly
- route-usefulness closure removes frozen, abandoned breaches

**No compliant fallback exists** for fully simulated distant reclamation without adding multi-root activity or all-world simulation, which is deferred. The implementation must not silently call this “containment.”

---

## Three most likely autonomous-agent misbuilds

### Risk 1: tests prove dispatch records, not physical traversal

The agent may spawn enemies on the world side, emit plausible dispatch logs, and pass economic tests.

**Additional structure**

- dispatched entity constructor requires a hub polygon
- acceptance checker requires spawn provenance followed by a matching `transfer`
- world-side spawn of a dispatch-tagged entity raises
- visual review checks unchanged body scale and actual mouth crossing

---

### Risk 2: decoupling is violated in `GameSession` orchestration

Even if `scouts.py` does not import marrow, `sim.py` might pass reserve availability into a scout decision or directly call marrow on completion.

**Additional structure**

- scout step signature accepts only `SenseFrame`, `SignalNeighborhood`, and `CallMedium`
- no generic `context`/`session` parameter
- AST test inspects call sites, not only imports
- `CallImprint` schema cannot encode reserve demand
- dry-call test uses a fake consumer that consumes without response and confirms identical scout behavior

---

### Risk 3: visual tells are decorative duplicates

The agent may animate “low reserve” lights or pulses on a separate timer, producing a convincing but dishonest tell.

**Additional structure**

- render reads Collar/dispatch/scout state directly
- no renderer access to telemetry
- event-to-frame temporal checker aligns:
  - rooted pulse state with rendered pulse
  - unpaid dispatch attempt with missing silhouette
  - collar destruction tick with changed beat interval
- deliberate mutant adding a free-running warning timer must fail source or alignment tests

---

# Survey/spec conflicts that must be acknowledged

## 1. Not every existing chamber can hold a 96-unit breach

`carve_door(width=96)` needs a free wall at least 104 units long. The survey explicitly reports 60–90-unit cells.

Therefore the ratified statement “1–3 viable wall segments per chamber” is not true of the current shipped geometry and cannot be implemented merely by choosing better edges.

**Required resolution:** migrate chamber geometry or narrow the set of call-capable chambers. The latter would change the spec, so this plan assumes geometry migration and makes level construction fail until every required chamber has a valid site. The autonomous agent must not silently skip short-wall chambers or route calls to another chamber.

---

## 2. Deep physical hub operation conflicts with player-rooted five-hop activity

The hub is 10–11 crossings deep, but physics and AI freeze outside five hops of the player. The economy can advance analytically, but physical Caretakers, deep defenders, and replacement traffic cannot all operate offscreen as specified.

This is not the old portal-scale bug; it is a separate limitation.

The first implementation can validate the raid while the player is inside and shallow dispatch while the player is near a breach. It cannot honestly claim full distant physical hub operation. That claim remains blocked until far-simulation or multi-root activation is designed.

---

## 3. Current death fallback violates persistent-world death

With no chassis, the app invokes streamer cold restore. That contradicts the ratified death rule.

The starting pod’s infinite backup supply must make cold restore unreachable in ordinary play. This is part of U12, not optional cleanup.

---

## 4. Current enemy AI has no turn-rate model

The kinematics directive cannot be met by changing only acceleration/friction because facing and steering currently snap every tick. U2 must add heading/turn-limited movement rather than merely increasing speed.

---

## 5. Current sentries and stations are indestructible pickup-group entities

They cannot be incrementally “tuned” into the specified buildings. Their ownership and collision model must move into the structure system; retaining the old sentry path would be a forbidden parallel pathway.

---

## 6. The signal vocabulary has both chamber Trail and doorway traffic marks

The ratified table defines Trail as a chamber scalar, while the coordination behavior also asks agents to mark chosen doorways. Both are needed:

- chamber Trail: where the intruder has recently been
- doorway trail: which route searchers have repeatedly chosen

Conflating them would lose either temporal player scent or route-lane organization.

---

# Numbers expected to move first

The following are first-pass measurements, not protected structure:

1. Distress, Noise, Muster, Garrison, and Kin half-lives/spread rates
2. Enemy speed ratios and turn rates
3. 48-unit charged-Tau AoE radius
4. scout danger thresholds
5. number and placement of finite scouts
6. cleaning salvage rate
7. guardian replacement cadence
8. 12-second garrison dwell, though the order of magnitude is ratified
9. strike-package role percentages
10. direct-breach Distress threshold
11. `reserve=-32`, once late-game usable-blackout time exists
12. approach geometry if killbox trials favor mouth holding

The following must not drift during tuning:

- scale-1 breach construction
- no world-side reinforcement spawning
- finite scouts
- one-hop sensing
- Kin as a scalar field
- reserve blindness to player/fight state
- call consumption on dry response
- no cheap-unit substitution
- cost-fair multi-breach scheduling
- no blackout timer
- no Warden/player hard coupling
- persistent world on death
- no feature flags or duplicate pathways.