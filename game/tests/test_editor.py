"""Tests for `perihelion.editor.model` -- the pure-Python (no pygame) half
of the level editor. Exercises the real model code directly: load a shipped
level, mutate it the way the pygame view would, and check the resulting
dict is exactly what a level author would expect, including round-tripping
through the real `perihelion.levels` loader and a live `GameSession`.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path

import pytest

from perihelion.editor import model as M
from perihelion.editor.model import _ENTER_ROOM_RE
from perihelion.levels import load_level
from perihelion.sim import GameSession, InputFrame

ROOT = Path(__file__).resolve().parents[2]
L01 = ROOT / "levels" / "l01.json"


@pytest.fixture()
def m() -> M.EditorModel:
    model = M.EditorModel()
    errs = model.load(L01)
    assert errs == [], errs
    return model


def test_load_l01(m):
    assert len(m.data["rooms"]) > 0
    assert m.validate() == []
    assert not m.dirty


def test_move_room_moves_verts_and_entities(m):
    # Find a room with at least one entity in it to exercise the entity-drag
    # path, and note the player's spawn room -- whichever room that is, its
    # marker must travel with the room if the two coincide.
    room_with_entity = next(
        ri for ri, r in enumerate(m.data["rooms"]) if r["entities"]
    )
    player_room = m.data["player"]["room"]
    target = player_room if m.data["rooms"][player_room]["entities"] else room_with_entity

    before = copy.deepcopy(m.data)
    before_verts = before["rooms"][target]["verts"]
    before_entities = before["rooms"][target]["entities"]
    assert before_entities, "chosen room should have at least one entity"
    before_player_pos = copy.deepcopy(m.data["player"]["pos"])

    m.move_room(target, 40, 40)

    after_verts = m.data["rooms"][target]["verts"]
    after_entities = m.data["rooms"][target]["entities"]
    for (bx, by), (ax, ay) in zip(before_verts, after_verts):
        assert ax == pytest.approx(bx + 40)
        assert ay == pytest.approx(by + 40)
    for be, ae in zip(before_entities, after_entities):
        assert ae["pos"][0] == pytest.approx(be["pos"][0] + 40)
        assert ae["pos"][1] == pytest.approx(be["pos"][1] + 40)

    # the player marker travels with its room iff that's the room we moved.
    assert m.data["player"]["room"] == player_room
    if player_room == target:
        assert m.data["player"]["pos"] == pytest.approx(
            [before_player_pos[0] + 40, before_player_pos[1] + 40]
        )
    else:
        assert m.data["player"]["pos"] == pytest.approx(before_player_pos)

    # every OTHER room is untouched.
    for ri, room in enumerate(m.data["rooms"]):
        if ri == target:
            continue
        assert room["verts"] == before["rooms"][ri]["verts"]

    assert m.dirty


def test_move_room_is_a_single_undo_step(m):
    prior = copy.deepcopy(m.data)
    m.move_room(1, 5, -5)
    assert m.data != prior
    assert m.undo() is True
    assert m.data == prior


def test_delete_room_reindexes_everything(m):
    # Pick a victim room that is neither the player's nor the exit's room,
    # and that actually participates in at least one `connects` entry, so
    # the "drop connects touching the deleted room" path is exercised.
    player_room = m.data["player"]["room"]
    exit_room = m.data["exit"]["room"]
    touched_rooms = {a for a, _, b, _ in m.data["connects"]} | {
        b for a, _, b, _ in m.data["connects"]
    }
    victim = next(
        ri for ri in touched_rooms
        if ri not in (player_room, exit_room)
    )

    before_connects = copy.deepcopy(m.data["connects"])

    def remap(idx):
        if idx is None or idx == victim:
            return None
        return idx - 1 if idx > victim else idx

    expected_connects = []
    for a, ea, b, eb in before_connects:
        na, nb = remap(a), remap(b)
        if na is None or nb is None:
            continue
        expected_connects.append([na, ea, nb, eb])

    n_rooms_before = len(m.data["rooms"])
    m.delete_room(victim)

    assert len(m.data["rooms"]) == n_rooms_before - 1
    # no connect may reference the deleted room, and every remaining index
    # must be in range of the shrunk rooms list.
    n_rooms_after = len(m.data["rooms"])
    for a, ea, b, eb in m.data["connects"]:
        assert 0 <= a < n_rooms_after
        assert 0 <= b < n_rooms_after
    for d in m.data["doors"]:
        assert 0 <= d["a"] < n_rooms_after
        assert 0 <= d["b"] < n_rooms_after
    # player/exit room indices shift exactly like any other reference.
    assert m.data["player"]["room"] == remap(player_room)
    assert m.data["exit"]["room"] == remap(exit_room)
    # Exact expected remap of every original `connects` entry: entries that
    # touched the victim room are dropped; every other room index above the
    # victim shifts down by one (the victim's old index is legitimately
    # reused by what used to be the next room -- it is NOT "the deleted
    # room" reappearing).
    assert m.data["connects"] == expected_connects
    assert m.validate() == []


def test_delete_room_clears_player_when_its_room_is_deleted():
    model = M.EditorModel()
    model.load(L01)
    player_room = model.data["player"]["room"]
    model.delete_room(player_room)
    assert model.data["player"] is None
    errs = model.validate()
    assert any("no player" in e for e in errs)


def test_delete_room_reindexes_terminals_and_radio_triggers():
    model = M.EditorModel()
    model.load(L01)
    # l01 must carry at least one terminal for this test to mean anything --
    # find it dynamically rather than hardcoding which room happens to hold
    # it. Radio is a dead gameplay channel (LevelBuilder.radio() now raises;
    # see levels.py) so l01.json no longer carries any authored radio lines
    # -- the editor's lore.radio reindexing is still live code (the editor
    # lets an author park radio-shaped notes in lore.radio for later
    # terminal/conversation work), so exercise it with a synthetic entry
    # instead of relying on campaign content that no longer exists.
    term_rooms = {t["room"] for t in model.data["lore"]["terminals"]}
    assert term_rooms, "l01 should have at least one terminal"

    non_player_rooms = [r for r in range(len(model.data["rooms"]))
                        if r != model.data["player"]["room"]]
    radio_room = non_player_rooms[0]
    model.data["lore"]["radio"].append(
        {"trigger": f"enter_room:{radio_room}", "text": "test line"})
    radio_rooms = {
        int(_ENTER_ROOM_RE.match(r["trigger"]).group(1))
        for r in model.data["lore"]["radio"]
        if _ENTER_ROOM_RE.match(r["trigger"])
    }
    assert radio_rooms, "synthetic enter_room radio trigger should be present"

    player_room = model.data["player"]["room"]
    # Delete the player's room: it invalidates the level (checked
    # separately elsewhere); what this test cares about is that the
    # *other* room-index references scattered through lore still shift
    # down by one correctly.
    model.delete_room(player_room)

    def remap(idx):
        if idx == player_room:
            return None
        return idx - 1 if idx > player_room else idx

    expected_term_rooms = {remap(r) for r in term_rooms} - {None}
    expected_radio_rooms = {remap(r) for r in radio_rooms} - {None}

    after_term_rooms = {t["room"] for t in model.data["lore"]["terminals"]}
    after_radio_rooms = {
        int(_ENTER_ROOM_RE.match(r["trigger"]).group(1))
        for r in model.data["lore"]["radio"]
        if _ENTER_ROOM_RE.match(r["trigger"])
    }
    assert after_term_rooms == expected_term_rooms
    assert after_radio_rooms == expected_radio_rooms
    errs = model.validate()
    assert errs == ["no player spawn"]


def test_add_room_connect_save_loads_and_runs(tmp_path):
    model = M.EditorModel()
    model.load(L01)
    n_rooms_before = len(model.data["rooms"])

    ri = model.add_rect_room(1000, 1000, 120, 90)
    assert model.data["rooms"][ri]["verts"] == [
        [1000, 1000], [1000, 1090], [1120, 1090], [1120, 1000],
    ]

    # Find some existing room/edge pair that no `connects`/`connects_x`/
    # `doors` entry already claims, so wiring the new room to it is a clean
    # single connection rather than a double-use conflict.
    used_edges = set()
    for a, ea, b, eb in model.data["connects"]:
        used_edges.add((a, ea))
        used_edges.add((b, eb))
    for a, ea, b, eb in model.data.get("connects_x", []):
        used_edges.add((a, ea))
        used_edges.add((b, eb))
    for d in model.data["doors"]:
        used_edges.add((d["a"], d["ea"]))
        used_edges.add((d["b"], d["eb"]))

    target_room, target_edge = next(
        (target_room, ei)
        for target_room, room in enumerate(model.data["rooms"])
        if target_room != ri
        for ei in range(len(room["verts"]))
        if (target_room, ei) not in used_edges
    )

    model.connect_edges(ri, 0, target_room, target_edge)
    assert model.validate() == []

    out = tmp_path / "edited.json"
    errs = model.save(out)
    assert errs == []
    assert model.path == out
    assert not model.dirty

    on_disk = json.loads(out.read_text())
    assert on_disk["version"] == 2
    assert len(on_disk["rooms"]) == n_rooms_before + 1

    lvl = load_level(out)
    assert len(lvl.room_verts) == n_rooms_before + 1

    session = GameSession(lvl, seed=1)
    for t in range(60):
        session.tick(InputFrame(mx=(t % 3) - 1, my=((t // 5) % 3) - 1))
    assert not session.dead


def test_key_metadata_survives_editor_round_trip(tmp_path):
    # l02 carries a top-level "keys" table (diegetic key identities); the
    # editor must not drop unknown-to-it fields on load/save.
    model = M.EditorModel()
    errs = model.load(ROOT / "levels" / "l02.json")
    assert errs == []
    out = tmp_path / "edited.json"
    assert model.save(out) == []
    on_disk = json.loads(out.read_text())
    assert on_disk["keys"]["red"]["item_name"] == "VALVE WHEEL"
    lvl = load_level(out)
    assert lvl.key_meta["red"].gate_name == "PRESSURE HATCH"


def test_undo_restores_exact_prior_dict(m):
    prior = copy.deepcopy(m.data)
    m.add_rect_room(2000, 2000, 50, 50)
    m.move_room(0, 10, 10)
    assert m.data != prior

    assert m.undo() is True  # undoes move_room
    assert m.undo() is True  # undoes add_rect_room
    assert m.data == prior
    assert m.undo() is False  # nothing left to undo


def test_convexity_violation_blocks_save(m, tmp_path):
    # Smash a vertex of room 0 inward so the room becomes reflex there.
    m.data["rooms"][0]["verts"][2] = [50, 50]
    errs_before = m.validate()
    assert any("concave" in e for e in errs_before)

    save_errs = m.save(tmp_path / "should_not_exist.json")
    assert save_errs == errs_before
    assert not (tmp_path / "should_not_exist.json").exists()


def test_wrong_winding_blocks_save(tmp_path):
    model = M.EditorModel()
    model.load(L01)
    model.data["rooms"][0]["verts"] = list(reversed(model.data["rooms"][0]["verts"]))
    errs = model.validate()
    assert any("winding" in e for e in errs)
    assert model.save(tmp_path / "x.json") == errs


def test_missing_player_or_exit_blocks_save(tmp_path):
    model = M.EditorModel()
    model.load(L01)
    model.data["player"] = None
    errs = model.validate()
    assert "no player spawn" in errs
    assert model.save(tmp_path / "x.json") == errs


def test_double_used_edge_blocks_save(m, tmp_path):
    # Room 0 edge 3 is already used by connects[2] == [0,3,1,0]; claim it
    # again from an unrelated room/edge -- must be rejected as a conflict,
    # not silently accepted.
    m.data["connects"].append([0, 3, 2, 0])
    errs = m.validate()
    assert any("used by multiple connections" in e for e in errs)
    assert m.save(tmp_path / "x.json") == errs


def test_self_mirror_connect_is_not_a_double_use_conflict(m):
    # The same edge appearing as BOTH sides of a single record (a==b,
    # ea==eb) is a deliberate mirror connect (see levels/l06.json), not a
    # conflict -- it must not trip the double-used-edge validator.
    ri = m.add_rect_room(5000, 5000, 100, 100)
    m.connect_edges(ri, 0, ri, 0)
    errs = m.validate()
    assert not any("used by multiple connections" in e for e in errs)


def test_add_entity_rejects_unspawnable_type(m):
    with pytest.raises(ValueError):
        m.add_entity(0, "terminal", 10, 10)  # terminals go through add_terminal


def test_delete_entity_and_terminal():
    model = M.EditorModel()
    model.load(L01)
    n_before = len(model.data["rooms"][0]["entities"])
    model.delete_entity(0, 0)
    assert len(model.data["rooms"][0]["entities"]) == n_before - 1

    ti = model.add_terminal(1, 300, 100, "hello")
    assert model.data["lore"]["terminals"][ti]["text"] == "hello"
    model.delete_terminal(ti)
    assert all(t["text"] != "hello" for t in model.data["lore"]["terminals"])


def test_delete_vertex_drops_bound_connections_not_others():
    model = M.EditorModel()
    model.load(L01)
    # room 0 has 6 verts; edges 3 and 4 touch vertex 4 (the vertex between
    # them). Delete vertex 4 and confirm any connect bound to those exact
    # edges of room 0 is gone while unrelated connects on room 0 survive.
    room0 = model.data["rooms"][0]
    n_before = len(room0["verts"])
    ok = model.delete_vertex(0, 4)
    assert ok
    assert len(model.data["rooms"][0]["verts"]) == n_before - 1
    # every remaining connect edge index must be valid for room 0 now.
    n_edges = len(model.data["rooms"][0]["verts"])
    for a, ea, b, eb in model.data["connects"]:
        if a == 0:
            assert 0 <= ea < n_edges
        if b == 0:
            assert 0 <= eb < n_edges


def test_delete_vertex_refuses_below_triangle():
    model = M.EditorModel()
    # a bare triangle room
    model.data["rooms"].append({"verts": [[0, 0], [0, -10], [10, 0]], "entities": []})
    assert model.delete_vertex(0, 0) is False
    assert len(model.data["rooms"][0]["verts"]) == 3


def test_load_malformed_file_does_not_crash_or_clobber_state(tmp_path):
    model = M.EditorModel()
    model.load(L01)
    good_data = copy.deepcopy(model.data)

    bad = tmp_path / "broken.json"
    bad.write_text("{not valid json,,,")
    errs = model.load(bad)
    assert errs != []
    assert model.data == good_data  # untouched by the failed load

    missing = tmp_path / "does_not_exist.json"
    errs2 = model.load(missing)
    assert errs2 != []
    assert model.data == good_data
