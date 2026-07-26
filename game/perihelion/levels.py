"""Level format v2: JSON in, built necore.Sim out.

Polygons are authored as absolute vertex lists on an editor canvas; the engine
re-centers each polygon on its centroid, so every entity/prop position in the
file is converted to polygon-local coordinates by subtracting that centroid.
Doors are pending connections: the polygons are NOT connected until unlocked at
runtime (a locked door is genuinely a wall — you cannot see through it).
"""

from __future__ import annotations

import json
import math
from dataclasses import dataclass, field
from pathlib import Path

LEVEL_VERSION = 2


@dataclass
class EntitySpec:
    type: str
    pos: tuple[float, float]  # polygon-local (post-centroid)
    props: dict = field(default_factory=dict)


@dataclass
class DoorSpec:
    a: int
    ea: int
    b: int
    eb: int
    key: str  # key id, e.g. "red" (empty string is reserved, unimplemented)


@dataclass
class TerminalSpec:
    polygon: int
    pos: tuple[float, float]
    text: str


@dataclass
class LightSpec:
    """A light as a world object (not a screen-space glow). `kind` is
    "static" (geometry-fixed, cached at level load — dock lamps, hydro grow
    strips) or "attached" (recomputed every frame — the player's own light,
    a carried lantern). `radius` is in polygon-local world units; `intensity`
    scales the additive contribution before falloff. `color` is (r,g,b)
    0..255."""
    polygon: int
    pos: tuple[float, float]  # polygon-local (post-centroid)
    color: tuple[int, int, int]
    intensity: float
    radius: float
    kind: str = "static"  # "static" | "attached"
    # directional (cone) lights: `dir` is a polygon-local unit vector,
    # `arc` the full cone angle in radians; dir None = omnidirectional
    dir: tuple[float, float] | None = None
    arc: float = 0.0


@dataclass
class RadioLine:
    trigger: str  # "start" | "enter_polygon:<idx>" | "kills:<n>" | "pickup:<key>" | "exit"
    text: str


@dataclass
class KeyMeta:
    """The diegetic identity of one key id within one level. The id ("red",
    "gold", "void"...) stays a mechanic; the fiction is per level: what
    station object the pickup is, what mechanism it operates, and the
    system-voice lines for both. All-caps, terse — these feed the one-line
    objective prompt and the pickup float text."""
    item_name: str       # what you pick up: "VALVE WHEEL"
    gate_name: str       # what it opens: "PRESSURE HATCH"
    gate_prompt: str     # blocked line: "PRESSURE HATCH SEALED - VALVE WHEEL REQUIRED"
    acquire_prompt: str  # pickup line: "ACQUIRED: VALVE WHEEL"


@dataclass
class Level:
    name: str
    tier: int
    polygon_verts: list[list[tuple[float, float]]]  # local coords (centroid at 0)
    polygon_centroids: list[tuple[float, float]]  # authoring-canvas centroids
    polygon_seeds: list[int]
    polygon_kinds: list[str]  # function tags: dock, corridor, storage, lab, quarters, chapel, core, generic...
    connects: list[tuple[int, int, int, int]]
    connects_x: list[tuple[int, int, int, int, tuple]]
    doors: list[DoorSpec]
    entities: list[tuple[int, EntitySpec]]  # (polygon, spec)
    player_polygon: int
    player_pos: tuple[float, float]
    exit_polygon: int
    exit_pos: tuple[float, float]
    exit_key: str  # "" = none; else a key id the player must hold
    alert_hops: int  # gunshot alert radius in polygon-hops
    vigil: bool  # endless holdout mode: the wave director runs
    exit_gate_kind: str  # "" = none; else all enemies of this kind must die
    intro: str
    radio: list[RadioLine]
    terminals: list[TerminalSpec]
    lights: list[LightSpec]
    ambience: str
    texture_map: dict = None
    # Per-polygon descent scalar 0..1 (how deep into the station this polygon
    # sits). In streamed campaigns WorldStreamer owns this list: chunk k of
    # N gets k/(N-1) and transit-spine polygons get the midpoint of the chunks
    # they join, so the gradient crosses inside the spine rather than
    # stepping at a doorway. A level loaded on its own (editor, --level,
    # vigil) derives one value for all polygons from its tier below.
    polygon_descent: list[float] = field(default_factory=list)
    # key id -> its diegetic identity in THIS level ("blue" is a scrubber
    # cartridge in hydroponics and a surgeon's cardkey one deck later).
    # Levels without an entry fall back to generic "<ID> SEAL" text.
    key_meta: dict[str, KeyMeta] = field(default_factory=dict)
    # levels/<level_id>.json stem, set by load_level. Keys the bespoke
    # texture path (assets/textures/<level_id>/polygon_<index>.png) and the
    # streaming-chunk lookup in stream.py; "" for levels never loaded from
    # a file path (LevelBuilder.build(), the debug level) -- such polygons
    # simply never resolve a texture and render as today.
    level_id: str = ""


def _shoelace(verts) -> float:
    n = len(verts)
    a = 0.0
    for i in range(n):
        x0, y0 = verts[i]
        x1, y1 = verts[(i + 1) % n]
        a += x0 * y1 - x1 * y0
    return a * 0.5


def _centroid(verts: list[tuple[float, float]]) -> tuple[float, float]:
    # Area-weighted centroid, matching engine add_polygon re-centering.
    n = len(verts)
    a = 0.0
    cx = 0.0
    cy = 0.0
    for i in range(n):
        x0, y0 = verts[i]
        x1, y1 = verts[(i + 1) % n]
        w = x0 * y1 - x1 * y0
        a += w
        cx += (x0 + x1) * w
        cy += (y0 + y1) * w
    if abs(a) < 1e-12:
        return (sum(v[0] for v in verts) / n, sum(v[1] for v in verts) / n)
    return (cx / (3.0 * a), cy / (3.0 * a))


def load_level(path: str | Path) -> Level:
    data = json.loads(Path(path).read_text())
    level = level_from_dict(data)
    level.level_id = Path(path).stem
    return level


def level_from_dict(data: dict) -> Level:
    if data.get("version", LEVEL_VERSION) != LEVEL_VERSION:
        raise ValueError(f"level version {data.get('version')} != {LEVEL_VERSION}")
    polygon_verts: list[list[tuple[float, float]]] = []
    polygon_centroids: list[tuple[float, float]] = []
    polygon_seeds: list[int] = []
    polygon_kinds: list[str] = []
    entities: list[tuple[int, EntitySpec]] = []

    for ri, polygon in enumerate(data["polygons"]):
        verts = [tuple(v) for v in polygon["verts"]]
        if _shoelace(verts) > 0:
            # The engine would silently rewind and renumber the edges,
            # breaking every authored connection index. Fail loudly instead.
            raise ValueError(
                f"polygon {ri}: vertices wind the wrong way (positive shoelace); "
                "author y-down visual-CCW")
        c = _centroid(verts)
        polygon_centroids.append(c)
        polygon_verts.append([(x - c[0], y - c[1]) for x, y in verts])
        polygon_seeds.append(int(polygon.get("detail_seed", ri * 7919 + 13)))
        polygon_kinds.append(str(polygon.get("kind", "generic")))
        for e in polygon.get("entities", []):
            ex, ey = e["pos"]
            entities.append(
                (
                    ri,
                    EntitySpec(
                        type=e["type"],
                        pos=(ex - c[0], ey - c[1]),
                        props=dict(e.get("props", {})),
                    ),
                )
            )

    def local(ri: int, pos) -> tuple[float, float]:
        c = polygon_centroids[ri]
        return (pos[0] - c[0], pos[1] - c[1])

    player = data["player"]
    exit_ = data.get("exit")
    tier = int(data.get("tier", 1))
    # tiers run 1..4; map onto the same 0..1 descent axis the streamer uses
    descent = min(1.0, max(0.0, (tier - 1) / 3.0))
    doors = [DoorSpec(**d) for d in data.get("doors", [])]
    key_meta = {k: KeyMeta(**v) for k, v in (data.get("keys") or {}).items()}
    lore = data.get("lore", {})
    radio = [RadioLine(**r) for r in lore.get("radio", [])]
    terminals = [
        TerminalSpec(t["polygon"], local(t["polygon"], t["pos"]), t["text"])
        for t in lore.get("terminals", [])
    ]
    lights = [
        LightSpec(
            polygon=int(lt["polygon"]),
            pos=local(int(lt["polygon"]), lt["pos"]),
            color=tuple(lt.get("color", (255, 220, 170))),
            intensity=float(lt.get("intensity", 1.0)),
            radius=float(lt.get("radius", 140.0)),
            kind=str(lt.get("kind", "static")),
        )
        for lt in data.get("lights", [])
    ]
    return Level(
        name=data.get("name", "?"),
        tier=tier,
        polygon_descent=[descent] * len(polygon_verts),
        polygon_verts=polygon_verts,
        polygon_centroids=polygon_centroids,
        polygon_seeds=polygon_seeds,
        polygon_kinds=polygon_kinds,
        connects=[tuple(c) for c in data.get("connects", [])],
        connects_x=[
            (c[0], c[1], c[2], c[3], tuple(c[4])) for c in data.get("connects_x", [])
        ],
        doors=doors,
        entities=entities,
        player_polygon=int(player["polygon"]),
        player_pos=local(player["polygon"], player["pos"]),
        exit_polygon=int(exit_["polygon"]) if exit_ else -1,
        exit_pos=local(exit_["polygon"], exit_["pos"]) if exit_ else (0.0, 0.0),
        exit_key=(exit_ or {}).get("key", ""),
        exit_gate_kind=(exit_ or {}).get("gate_kind", ""),
        key_meta=key_meta,
        alert_hops=int(data.get("alert_hops", 2)),
        vigil=bool(data.get("vigil", False)),
        intro=lore.get("intro", ""),
        radio=radio,
        terminals=terminals,
        lights=lights,
        ambience=data.get("ambience", "amb_drone_early"),
        texture_map={int(k): tuple(v) for k, v in
                     data.get("texture_map", {}).items()},
    )


def save_level(level_dict: dict, path: str | Path) -> None:
    level_dict = dict(level_dict)
    level_dict["version"] = LEVEL_VERSION
    Path(path).write_text(json.dumps(level_dict, indent=1))


# ---------------------------------------------------------------------------
# Programmatic authoring helpers (used by the campaign generator and tests).
# ---------------------------------------------------------------------------


class LevelBuilder:
    """Accumulates polygons/connections in authoring (absolute-canvas) coords and
    emits a level dict. Polygons may be placed anywhere on the canvas — including
    on top of each other; only connections define adjacency."""

    def __init__(self, name: str, tier: int = 1, ambience: str = "amb_drone_early"):
        self.data: dict = {
            "version": LEVEL_VERSION,
            "name": name,
            "tier": tier,
            "ambience": ambience,
            "polygons": [],
            "connects": [],
            "connects_x": [],
            "doors": [],
            "player": None,
            "exit": None,
            "lore": {"intro": "", "radio": [], "terminals": []},
            "lights": [],
        }

    def polygon(self, verts, detail_seed: int | None = None,
             kind: str | None = None) -> int:
        r = {"verts": [list(v) for v in verts], "entities": []}
        if detail_seed is not None:
            r["detail_seed"] = detail_seed
        if kind is not None:
            r["kind"] = kind
        self.data["polygons"].append(r)
        return len(self.data["polygons"]) - 1

    def set_kind(self, polygon: int, kind: str) -> None:
        self.data["polygons"][polygon]["kind"] = kind

    def rect(self, x, y, w, h, seed=None, kind=None) -> int:
        return self.polygon([(x, y), (x, y + h), (x + w, y + h), (x + w, y)],
                         seed, kind=kind)

    def ngon(self, cx, cy, r, n, phase=0.0, seed=None, kind=None) -> int:
        import math

        # Angle DECREASES so the shoelace area is negative: engine-canonical
        # winding, so authored edge indices survive add_polygon unchanged.
        # Edge i runs from vertex i to i+1.
        verts = []
        for i in range(n):
            a = phase - i * 2.0 * math.pi / n
            verts.append((cx + r * math.cos(a), cy + r * math.sin(a)))
        return self.polygon(verts, seed, kind=kind)

    def poly(self, verts, seed=None) -> int:
        """Polygon from explicit verts; rewinds to canonical if needed (edge
        indices then follow the REWOUND order — prefer authoring canonical)."""
        if _shoelace(verts) > 0:
            verts = list(reversed(verts))
        return self.polygon(verts, seed)

    def connect_pts(self, ra: int, pa, rb: int, pb):
        """Connection resolved by edge MIDPOINT at build time (safe across
        the doorway-splitting pass, which renumbers edges)."""
        self.data.setdefault("connects_pts", []).append(
            [ra, list(pa), rb, list(pb)])

    def door_pts(self, ra: int, pa, rb: int, pb, key: str):
        self.data.setdefault("doors_pts", []).append(
            dict(a=ra, pa=list(pa), b=rb, pb=list(pb), key=key))

    def key_meta(self, key: str, item_name: str, gate_name: str,
                 gate_prompt: str, acquire_prompt: str):
        """Give key id `key` its diegetic identity in this level (see
        KeyMeta). Applies to every door with this key AND the exit if it
        requires this key."""
        self.data.setdefault("keys", {})[key] = dict(
            item_name=item_name, gate_name=gate_name,
            gate_prompt=gate_prompt, acquire_prompt=acquire_prompt)

    def no_connect(self, ra: int, rb: int):
        """Forbid the splitter/autoconnect from opening a doorway between
        these two polygons (their shared wall stays a wall)."""
        self.data.setdefault("no_auto", []).append([ra, rb])

    # -- build pipeline -------------------------------------------------

    def resolve(self, tol: float = 0.5) -> dict:
        """Produce the final level dict: (1) doorway-split pass — where a
        short edge lies collinear inside a longer wall, insert vertices into
        the wall so an exactly-matching sub-edge exists; (2) autoconnect all
        exactly-coincident edge pairs; (3) resolve point-authored connects
        and doors to edge indices. Explicit index-based connects/doors are
        passed through and must reference polygons the splitter never touches."""
        import copy

        data = copy.deepcopy(self.data)
        polygons = data["polygons"]
        no_auto = {tuple(sorted(p)) for p in data.pop("no_auto", [])}

        def edges_of(ri):
            vs = polygons[ri]["verts"]
            n = len(vs)
            return [(ei, tuple(vs[ei]), tuple(vs[(ei + 1) % n])) for ei in range(n)]

        # (1) split walls that contain smaller opposite-facing edges
        changed = True
        guard = 0
        while changed and guard < 200:
            changed = False
            guard += 1
            for ri in range(len(polygons)):
                for rj in range(len(polygons)):
                    if ri == rj:
                        continue
                    for ei, a0, a1 in edges_of(ri):
                        ax, ay = a1[0] - a0[0], a1[1] - a0[1]
                        alen = math.hypot(ax, ay)
                        if alen < tol:
                            continue
                        ux, uy = ax / alen, ay / alen
                        for ej, b0, b1 in edges_of(rj):
                            bx, by = b1[0] - b0[0], b1[1] - b0[1]
                            if bx * ux + by * uy > -tol:  # need opposite dir
                                continue
                            # both endpoints on A's line?
                            d0 = abs((b0[0] - a0[0]) * uy - (b0[1] - a0[1]) * ux)
                            d1 = abs((b1[0] - a0[0]) * uy - (b1[1] - a0[1]) * ux)
                            if d0 > tol or d1 > tol:
                                continue
                            t0 = (b0[0] - a0[0]) * ux + (b0[1] - a0[1]) * uy
                            t1 = (b1[0] - a0[0]) * ux + (b1[1] - a0[1]) * uy
                            lo, hi = min(t0, t1), max(t0, t1)
                            if lo < -tol or hi > alen + tol:
                                continue  # not contained in A's edge
                            inserts = sorted(
                                t for t in (t0, t1) if tol < t < alen - tol)
                            if not inserts:
                                continue  # exact match already
                            vs = polygons[ri]["verts"]
                            pos = vs.index(list(a0)) if list(a0) in vs else None
                            if pos is None:
                                continue
                            for k, t in enumerate(inserts):
                                vs.insert(pos + 1 + k,
                                          [a0[0] + ux * t, a0[1] + uy * t])
                            changed = True
                            break
                        if changed:
                            break
                    if changed:
                        break
                if changed:
                    break

        # (2) autoconnect exactly-coincident edges
        used: set[tuple[int, int]] = set()
        for a, ea, b, eb in data["connects"]:
            used.add((a, ea))
            used.add((b, eb))
        for a, ea, b, eb, _ in data["connects_x"]:
            used.add((a, ea))
            used.add((b, eb))
        for d in data["doors"]:
            used.add((d["a"], d["ea"]))
            used.add((d["b"], d["eb"]))

        def nearest_edge(ri, px, py):
            best, bd = -1, 1e18
            for ei, p0, p1 in edges_of(ri):
                mx, my = (p0[0] + p1[0]) / 2, (p0[1] + p1[1]) / 2
                d = (mx - px) ** 2 + (my - py) ** 2
                if d < bd:
                    best, bd = ei, d
            return best

        # resolve point-authored doors FIRST so autoconnect can't steal them
        for d in data.pop("doors_pts", []):
            ea = nearest_edge(d["a"], *d["pa"])
            eb = nearest_edge(d["b"], *d["pb"])
            data["doors"].append(dict(a=d["a"], ea=ea, b=d["b"], eb=eb,
                                      key=d["key"]))
            used.add((d["a"], ea))
            used.add((d["b"], eb))
        for c in data.pop("connects_pts", []):
            ea = nearest_edge(c[0], *c[1])
            eb = nearest_edge(c[2], *c[3])
            if (c[0], ea) in used or (
                    (c[2], eb) != (c[0], ea) and (c[2], eb) in used):
                raise ValueError(
                    f"connect_pts resolves to an already-used edge: "
                    f"polygon {c[0]} edge {ea} / polygon {c[2]} edge {eb}")
            data["connects"].append([c[0], ea, c[2], eb])
            used.add((c[0], ea))
            used.add((c[2], eb))

        all_edges = []
        for ri in range(len(polygons)):
            for ei, p0, p1 in edges_of(ri):
                all_edges.append((ri, ei, p0, p1))
        for i in range(len(all_edges)):
            ri, ei, a0, a1 = all_edges[i]
            if (ri, ei) in used:
                continue
            for j in range(i + 1, len(all_edges)):
                rj, ej, b0, b1 = all_edges[j]
                if rj == ri or (rj, ej) in used \
                        or tuple(sorted((ri, rj))) in no_auto:
                    continue
                if (abs(a0[0] - b1[0]) < tol and abs(a0[1] - b1[1]) < tol
                        and abs(a1[0] - b0[0]) < tol and abs(a1[1] - b0[1]) < tol):
                    data["connects"].append([ri, ei, rj, ej])
                    used.add((ri, ei))
                    used.add((rj, ej))
                    break
        return data

    def autoconnect(self, tol: float = 0.5):
        """Deprecated shim: splitting/matching now happens in resolve()."""
        # kept so older call sites are harmless; resolve() does the work
        return None

    def connect(self, a, ea, b, eb):
        self.data["connects"].append([a, ea, b, eb])

    def connect_x(self, a, ea, b, eb, m9):
        self.data["connects_x"].append([a, ea, b, eb, list(m9)])

    def door(self, a, ea, b, eb, key: str):
        self.data["doors"].append({"a": a, "ea": ea, "b": b, "eb": eb, "key": key})

    def entity(self, polygon: int, type_: str, pos, **props):
        e = {"type": type_, "pos": list(pos)}
        if props:
            e["props"] = props
        self.data["polygons"][polygon]["entities"].append(e)

    def player(self, polygon: int, pos):
        self.data["player"] = {"polygon": polygon, "pos": list(pos)}

    def exit(self, polygon: int, pos, key: str = "", gate_kind: str = ""):
        self.data["exit"] = {"polygon": polygon, "pos": list(pos)}
        if key:
            self.data["exit"]["key"] = key
        if gate_kind:
            self.data["exit"]["gate_kind"] = gate_kind

    def intro(self, text: str):
        self.data["lore"]["intro"] = text

    def radio(self, trigger: str, text: str):
        raise RuntimeError(
            "radio was eliminated: dialogue lives at terminals and relay "
            "conversations")

    def terminal(self, polygon: int, pos, text: str):
        self.data["lore"]["terminals"].append(
            {"polygon": polygon, "pos": list(pos), "text": text}
        )

    def light(self, polygon: int, pos, color=(255, 220, 170), intensity: float = 1.0,
              radius: float = 140.0, kind: str = "static"):
        """A world light: a real object the visibility engine casts from,
        not a screen-space glow. `kind` "static" is cached at level load;
        "attached" (e.g. a carried light) is recomputed every frame."""
        self.data.setdefault("lights", []).append({
            "polygon": polygon, "pos": list(pos), "color": list(color),
            "intensity": intensity, "radius": radius, "kind": kind,
        })

    def build(self) -> Level:
        if self.data["player"] is None:
            raise ValueError("level has no player spawn")
        return level_from_dict(self.resolve())

    def to_dict(self) -> dict:
        """Final, resolved level dict (what save_level should write)."""
        return self.resolve()
