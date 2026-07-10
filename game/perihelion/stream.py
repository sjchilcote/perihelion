"""One seamless world: campaign levels stream into a single live sim.

"Levels" are chunks of rooms lazy-loaded as the player approaches. Chunk k's
exit pad becomes a carved doorway into a transit spine (two long corridor
rooms, kind "transit"); entering the spine loads chunk k+1, carves its entry
doorway near the authored player spawn, and joins the worlds. The far side
of every spine is a fresh security zone: held keys clear on arrival.

Death reprints the frame at the current chunk's entry with the state it was
first entered with — the seed keeps its checkpoints. The final chunk keeps
its real exit pad, which ends the campaign.
"""

from __future__ import annotations

import math

from .levels import Level, load_level
from .sim import GameSession

SPINE_LEN = 260.0
SPINE_W = 70.0
DOOR_W = 70.0


class WorldStreamer:
    def __init__(self, session: GameSession, level_paths: list[str],
                 start_chunk: int = 0):
        self.session = session
        self.paths = list(level_paths)
        self.start_chunk = start_chunk
        # chunk records: {offset, n_rooms, level, entry_room, entry_pos,
        #                 spine_rooms (tuple | None), loaded_next}
        self.chunks: list[dict] = []
        self.current = 0
        self.entry_states: dict[int, dict] = {}
        self._last_room = session.player_room()
        self.on_chunk_entered = None  # callback(chunk_idx, name)
        self.on_campaign_complete = None

        first = session.level  # session was constructed with chunk start_chunk
        rec = dict(offset=0, n_rooms=len(first.room_verts), level=first,
                   entry_room=first.player_room, entry_pos=first.player_pos,
                   spine_rooms=None, loaded_next=False)
        self.chunks.append(rec)
        # The descent axis: chunk k of N sits at k/(N-1). The campaign's
        # loaded-alone tier-derived values are replaced with the streamed
        # gradient so ten chunks read as ten distinct depths of one station.
        first.room_descent = ([self._chunk_descent(0)]
                              * len(first.room_verts))
        self.entry_states[0] = self._snapshot_state()
        # every chunk entry is a seed station (9.1: the seed that prints
        # your frames; 9.3: planted kits extend the same network)
        session.add_station(first.player_room, first.player_pos)
        session.exit_enabled = self._is_final(0)
        if self._is_final(0):
            self._point_exit_at(0)
        else:
            self._build_spine(0)
            self._retarget()

    # ------------------------------------------------------------------

    def _is_final(self, chunk_idx: int) -> bool:
        return self.start_chunk + chunk_idx >= len(self.paths) - 1

    def _chunk_descent(self, chunk_idx: int) -> float:
        """Descent scalar for chunk `chunk_idx` (local index): global chunk
        k of N maps to k/(N-1), 0.0 at the dock, 1.0 at the core."""
        den = max(1, len(self.paths) - 1)
        return min(1.0, (self.start_chunk + chunk_idx) / den)

    def _extend_descent(self, first_room: int, values: list[float]) -> None:
        """Append per-room descent values for rooms starting at engine index
        `first_room`. Rooms the sim added on its own since the last stream
        event (portable-hole corridors, the cloister) never extend this
        list, so pad any gap with the last known value — those rooms are
        always carved near where the player already is."""
        rd = self.session.level.room_descent
        fill = rd[-1] if rd else values[0]
        while len(rd) < first_room:
            rd.append(fill)
        rd.extend(values)

    def _retarget(self) -> None:
        """Keep the (disabled) exit marker pointing at the way forward so
        route queries — and bots — always have a heading: the spine while
        the next chunk is unloaded, its entry room once it exists."""
        s = self.session
        cur = self.chunks[self.current]
        if self._is_final(self.current):
            return
        if self.current + 1 < len(self.chunks):
            nxt = self.chunks[self.current + 1]
            s.exit_room = nxt["entry_room"] + nxt["offset"]
            s.exit_pos = nxt["entry_pos"]
        elif cur["spine_rooms"]:
            s.exit_room = cur["spine_rooms"][1]
            s.exit_pos = (0.0, 0.0)

    def _point_exit_at(self, chunk_idx: int) -> None:
        s = self.session
        c = self.chunks[chunk_idx]
        lvl = c["level"]
        s.exit_room = lvl.exit_room + c["offset"]
        s.exit_pos = lvl.exit_pos
        s.level.exit_key = lvl.exit_key
        s.level.exit_gate_kind = lvl.exit_gate_kind
        # blocked-exit prompt comes from THIS chunk's key fiction, not
        # chunk 0's (s.level is chunk 0's Level object)
        meta = lvl.key_meta.get(lvl.exit_key) if lvl.exit_key else None
        s.exit_gate_prompt = meta.gate_prompt if meta else ""
        # the gate only counts guardians of THIS chunk; stragglers from
        # earlier decks hold no doors here
        s.exit_gate_rooms = (c["offset"], c["offset"] + c["n_rooms"])

    def _snapshot_state(self) -> dict:
        # hp and 9mm floors: respawning hurt or dry into a fully restocked
        # chunk death-spirals — every retry replays the same doomed loadout
        # (soak seed 2175 entered the finale with 9 rounds and died 400+
        # times; hard mode needs higher floors against 1.35x enemies, 75 of
        # 983 hard soak campaigns ground out on normal-tuned floors). The
        # seed prints a battle-ready frame, not a copy of your wounds or
        # your empty magazines. Floors only lift the pathological bottom;
        # normal entries carry far more and are untouched.
        s = self.session
        hard = getattr(s, "difficulty", "normal") == "hard"
        ammo = dict(s.ammo)
        ammo["9mm"] = max(ammo.get("9mm", 0), 90 if hard else 45)
        if hard:
            ammo["shell"] = max(ammo.get("shell", 0), 8)
        return dict(hp=max(int(s.hp), 85 if hard else 70), ammo=ammo,
                    weapons=list(s.weapons), weapon=s.weapon,
                    holes=s.holes, cloister=s.cloister is not None,
                    # economy fields ride the snapshot for save-file
                    # persistence only; _restore_state never touches them
                    # (the corpse already holds what death cost you --
                    # restoring entry values would duplicate it)
                    components=s.components, chassis=s.chassis,
                    station_kits=s.station_kits, max_hp=s.max_hp,
                    hp_ups=s.hp_ups, recalls=s.recalls,
                    mind=sorted(s.mind),
                    # thinking rides the snapshot for save-file persistence
                    # only; _restore_state never touches it (the live
                    # session already holds it -- the mind survives the
                    # body, so a cold restore must not rewind a thought)
                    think_focus=s.think_focus,
                    think_progress=dict(s.think_progress),
                    think_done=list(s.think_done))

    def _restore_state(self, st: dict) -> None:
        s = self.session
        s.hp = min(st["hp"], s.max_hp)
        s.ammo = dict(st["ammo"])
        s.weapons = list(st["weapons"])
        s.weapon = st["weapon"]
        s.holes = st["holes"]
        s.keys = set()
        s.tau_charge = 0
        s.hole_mark = None

    def room_chunk(self, room: int) -> int:
        for i, c in enumerate(self.chunks):
            if c["offset"] <= room < c["offset"] + c["n_rooms"]:
                return i
            if c["spine_rooms"] and room in c["spine_rooms"]:
                return i
        return self.current

    def room_texture_key(self, room: int) -> tuple[str, int] | None:
        """Renderer.room_texture_lookup hook: engine room index ->
        (level_id, local_room_index) for the bespoke floor texture path,
        or None. Transit-spine rooms are synthetic (not authored in any
        levels/*.json) and never carry a texture."""
        for c in self.chunks:
            if c["offset"] <= room < c["offset"] + c["n_rooms"]:
                level_id = getattr(c["level"], "level_id", "") or ""
                if not level_id:
                    return None
                return (level_id, room - c["offset"])
            if c["spine_rooms"] and room in c["spine_rooms"]:
                return None
        return None

    # ------------------------------------------------------------------
    # construction
    # ------------------------------------------------------------------

    def _carve_in_chunk(self, chunk_rec, room: int, pos) -> tuple[int, int]:
        """Carve a doorway near (room, pos); if that room has no carvable
        wall (portal-saturated rooms exist: the Fold's core, the tesseract),
        BFS outward within the chunk to the nearest room that does."""
        s = self.session
        lo = chunk_rec["offset"]
        hi = lo + chunk_rec["n_rooms"]
        mid = s.carve_door(room, pos, DOOR_W)
        if mid is not None:
            return room, mid
        seen = {room}
        frontier = [room]
        while frontier:
            nxt_frontier = []
            for r in frontier:
                for p in s.sim.room_portals(r):
                    if p is None:
                        continue
                    tr = p[0]
                    if tr in seen or not (lo <= tr < hi):
                        continue
                    seen.add(tr)
                    mid = s.carve_door(tr, (0.0, 0.0), DOOR_W)
                    if mid is not None:
                        return tr, mid
                    nxt_frontier.append(tr)
            frontier = nxt_frontier
        raise RuntimeError(f"chunk at offset {lo}: no carvable wall anywhere")

    # The relay conversations happen at PLACES (DIALOGUE_SCRIPT.md scene
    # headers); the spine that hosts scene k dresses as that place and
    # announces itself, instead of nine identical anonymous corridors
    # (diegesis audit finding #1). Kinds reuse shipped prop generators.
    SCENE_STAGES = {
        0: ("dock", "CARGO RELAY"),
        1: ("lab", "THE RESEARCHERS' APERTURE"),
        2: ("chapel", "THE SCHOOL'S THRESHOLD"),
        3: ("storage", "THE FABRICATOR ALCOVE"),
        4: ("transit", "THE TRANSIT SPINE"),
        5: ("chapel", "THE DOCENT HALL"),
        6: ("corridor", "THE DEEP APPROACH"),
        7: ("core", "THE VAULT ANTECHAMBER"),
        8: ("generic", "A FORWARD SEED'S RELAY"),
    }

    def _build_spine(self, chunk_idx: int) -> None:
        """Carve a doorway near chunk k's exit pad into a two-room transit
        spine. Its far end stays sealed until the next chunk loads."""
        s = self.session
        c = self.chunks[chunk_idx]
        lvl: Level = c["level"]
        exit_room, mid = self._carve_in_chunk(
            c, lvl.exit_room + c["offset"], lvl.exit_pos)
        spine_a = s.sim.add_room([(0.0, 0.0), (0.0, SPINE_W),
                                  (SPINE_LEN, SPINE_W), (SPINE_LEN, 0.0)])
        spine_b = s.sim.add_room([(0.0, 0.0), (0.0, SPINE_W),
                                  (SPINE_LEN, SPINE_W), (SPINE_LEN, 0.0)])
        # spine rect edges: 0 = west end (len W), 2 = east end
        s.sim.connect(exit_room, mid, spine_a, 0)
        s.sim.connect(spine_a, 2, spine_b, 0)
        c["spine_rooms"] = (spine_a, spine_b)
        s.level.room_seeds.extend([spine_a * 7919 + 13, spine_b * 7919 + 13])
        stage = self.SCENE_STAGES.get(self.start_chunk + chunk_idx,
                                      ("transit", None))
        c["spine_name"] = stage[1]
        s.level.room_kinds.extend([stage[0], "transit"])
        # the spine joins chunk k and k+1: give it the midpoint descent so
        # the palette gradient crosses INSIDE the transit corridor (two
        # half-steps) instead of a full step at either doorway
        mid_d = (self._chunk_descent(chunk_idx)
                 + self._chunk_descent(chunk_idx + 1)) / 2.0
        self._extend_descent(spine_a, [mid_d, mid_d])
        s.level.room_verts.extend([[(-130.0, -35.0), (-130.0, 35.0),
                                    (130.0, 35.0), (130.0, -35.0)]] * 2)
        s.level.room_centroids.extend([(0.0, 0.0), (0.0, 0.0)])
        # the tight-beam relay: reading it plays the between-chunk exchange
        conv_idx = self.start_chunk + chunk_idx
        s.terminals.append(dict(room=spine_a, pos=(0.0, 0.0),
                                text=f"__CONV__{conv_idx}", read=False))

    def _load_next(self, chunk_idx: int) -> None:
        """The player entered chunk k's spine: stream chunk k+1 and join."""
        c = self.chunks[chunk_idx]
        if c["loaded_next"] or self._is_final(chunk_idx):
            return
        c["loaded_next"] = True
        s = self.session
        path = self.paths[self.start_chunk + chunk_idx + 1]
        nxt = load_level(path)
        offset = s.append_chunk(nxt)
        self._extend_descent(offset, [self._chunk_descent(chunk_idx + 1)]
                             * len(nxt.room_verts))
        rec = dict(offset=offset, n_rooms=len(nxt.room_verts), level=nxt,
                   entry_room=nxt.player_room, entry_pos=nxt.player_pos,
                   spine_rooms=None, loaded_next=False)
        entry_room, mid = self._carve_in_chunk(
            rec, nxt.player_room + offset, nxt.player_pos)
        rec["entry_room"] = entry_room - offset
        rec["entry_pos"] = (0.0, 0.0) if entry_room != nxt.player_room + offset \
            else nxt.player_pos
        spine_b = c["spine_rooms"][1]
        s.sim.connect(spine_b, 2, entry_room, mid)
        self.chunks.append(rec)
        if not self._is_final(chunk_idx + 1):
            self._build_spine(chunk_idx + 1)

    # ------------------------------------------------------------------
    # per-tick
    # ------------------------------------------------------------------

    def tick(self) -> None:
        s = self.session
        room = s.player_room()
        if room == self._last_room:
            return
        self._last_room = room
        cur = self.chunks[self.current]
        # entering the spine streams the next chunk in
        if cur["spine_rooms"] and room in cur["spine_rooms"]:
            if cur.get("spine_name"):
                s.fx.append(("locname", cur.pop("spine_name")))
            self._load_next(self.current)
            self._retarget()
            return
        # crossing into the next chunk's rooms: arrival
        if self.current + 1 < len(self.chunks):
            nxt = self.chunks[self.current + 1]
            if nxt["offset"] <= room < nxt["offset"] + nxt["n_rooms"]:
                self.current += 1
                self.entry_states[self.current] = self._snapshot_state()
                s.add_station(nxt["entry_room"] + nxt["offset"],
                              nxt["entry_pos"])
                # a new security zone honors no old badges -- and says so
                # the one time it actually voids something (audit: silent
                # rule enforcement is a diegesis leak)
                if s.keys:
                    s._objective("ZONE BOUNDARY - PRIOR CLEARANCES VOID")
                s.keys = set()
                s.exit_enabled = self._is_final(self.current)
                if s.exit_enabled:
                    self._point_exit_at(self.current)
                else:
                    self._retarget()
                name = nxt["level"].name
                s.fx.append(("locname", name))
                amb = nxt["level"].ambience
                s.fx.append(("ambience", amb))
                if self.on_chunk_entered:
                    self.on_chunk_entered(
                        self.start_chunk + self.current, name)

    # ------------------------------------------------------------------
    # death
    # ------------------------------------------------------------------

    def respawn(self) -> None:
        """The seed prints a fresh frame at the current chunk's entry with
        the state it was first entered with. The chunk's dead rise again;
        its unclaimed supplies are restocked."""
        s = self.session
        c = self.chunks[self.current]
        lo, hi = c["offset"], c["offset"] + c["n_rooms"]
        for eid in [e for e in s.bullets]:
            s.sim.remove(eid)
        s.bullets.clear()
        for eid in [e for e, rec in s.enemies.items()
                    if lo <= s.sim.get_room(e) < hi]:
            s.sim.remove(eid)
            s.enemies.pop(eid, None)
        for eid in [e for e, rec in s.pickups.items()
                    if lo <= s.sim.get_room(e) < hi
                    and rec["kind"] != "corpse_frame"]:
            # wrecked frames survive the restock: loot is only lost until
            # retrieved (9.1), and the cold restore never deletes a corpse
            s.sim.remove(eid)
            s.pickups.pop(eid, None)
        lvl: Level = c["level"]
        for room, spec in lvl.entities:
            s._spawn_from_spec(room + c["offset"], spec,
                               key_meta=lvl.key_meta)
        # doors of this chunk re-lock only if their key is re-collectable;
        # simpler and kinder: opened doors stay open.
        self._restore_state(self.entry_states[self.current])
        entry_room = c["entry_room"] + c["offset"]
        px, py = c["entry_pos"]
        s.sim.set_pos(s.pid, px, py)
        # engine set_pos does not move room membership; re-seat via a
        # remove/spawn would lose the id, so use the sim's own transfer:
        if s.sim.get_room(s.pid) != entry_room:
            self._reseat_player(entry_room, (px, py))
        s.sim.set_vel(s.pid, 0.0, 0.0)
        s.dead = False
        s.freeze = 0
        s.metrics["deaths"] += 1
        import necore
        s._set_cam(necore.mat_mul(
            necore.mat_mul(
                necore.mat_translate(s.screen_w / 2, s.screen_h / 2),
                necore.mat_scale(s.zoom, s.zoom)),
            necore.mat_translate(-px, -py)))
        s.fx.append(("locname", lvl.name))

    def _reseat_player(self, room: int, pos) -> None:
        """Move the player's engine entity to another room."""
        self.session.reseat_player(room, pos)
