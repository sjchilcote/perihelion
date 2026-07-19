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
from perihelion.editor.model import _ENTER_POLYGON_RE
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
    assert len(m.data["polygons"]) > 0
    assert m.validate() == []
    assert not m.dirty


def test_move_polygon_moves_verts_and_entities(m):
    # Find a polygon with at least one entity in it to exercise the entity-drag
    # path, and note the player's spawn polygon -- whichever polygon that is, its
    # marker must travel with the polygon if the two coincide.
    polygon_with_entity = next(
        ri for ri, r in enumerate(m.data["polygons"]) if r["entities"]
    )
    player_polygon = m.data["player"]["polygon"]
    target = player_polygon if m.data["polygons"][player_polygon]["entities"] else polygon_with_entity

    before = copy.deepcopy(m.data)
    before_verts = before["polygons"][target]["verts"]
    before_entities = before["polygons"][target]["entities"]
    assert before_entities, "chosen polygon should have at least one entity"
    before_player_pos = copy.deepcopy(m.data["player"]["pos"])

    m.move_polygon(target, 40, 40)

    after_verts = m.data["polygons"][target]["verts"]
    after_entities = m.data["polygons"][target]["entities"]
    for (bx, by), (ax, ay) in zip(before_verts, after_verts):
        assert ax == pytest.approx(bx + 40)
        assert ay == pytest.approx(by + 40)
    for be, ae in zip(before_entities, after_entities):
        assert ae["pos"][0] == pytest.approx(be["pos"][0] + 40)
        assert ae["pos"][1] == pytest.approx(be["pos"][1] + 40)

    # the player marker travels with its polygon iff that's the polygon we moved.
    assert m.data["player"]["polygon"] == player_polygon
    if player_polygon == target:
        assert m.data["player"]["pos"] == pytest.approx(
            [before_player_pos[0] + 40, before_player_pos[1] + 40]
        )
    else:
        assert m.data["player"]["pos"] == pytest.approx(before_player_pos)

    # every OTHER polygon is untouched.
    for ri, polygon in enumerate(m.data["polygons"]):
        if ri == target:
            continue
        assert polygon["verts"] == before["polygons"][ri]["verts"]

    assert m.dirty


def test_move_polygon_is_a_single_undo_step(m):
    prior = copy.deepcopy(m.data)
    m.move_polygon(1, 5, -5)
    assert m.data != prior
    assert m.undo() is True
    assert m.data == prior


def test_delete_polygon_reindexes_everything(m):
    # Pick a victim polygon that is neither the player's nor the exit's polygon,
    # and that actually participates in at least one `connects` entry, so
    # the "drop connects touching the deleted polygon" path is exercised.
    player_polygon = m.data["player"]["polygon"]
    exit_polygon = m.data["exit"]["polygon"]
    touched_polygons = {a for a, _, b, _ in m.data["connects"]} | {
        b for a, _, b, _ in m.data["connects"]
    }
    victim = next(
        ri for ri in touched_polygons
        if ri not in (player_polygon, exit_polygon)
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

    n_polygons_before = len(m.data["polygons"])
    m.delete_polygon(victim)

    assert len(m.data["polygons"]) == n_polygons_before - 1
    # no connect may reference the deleted polygon, and every remaining index
    # must be in range of the shrunk polygons list.
    n_polygons_after = len(m.data["polygons"])
    for a, ea, b, eb in m.data["connects"]:
        assert 0 <= a < n_polygons_after
        assert 0 <= b < n_polygons_after
    for d in m.data["doors"]:
        assert 0 <= d["a"] < n_polygons_after
        assert 0 <= d["b"] < n_polygons_after
    # player/exit polygon indices shift exactly like any other reference.
    assert m.data["player"]["polygon"] == remap(player_polygon)
    assert m.data["exit"]["polygon"] == remap(exit_polygon)
    # Exact expected remap of every original `connects` entry: entries that
    # touched the victim polygon are dropped; every other polygon index above the
    # victim shifts down by one (the victim's old index is legitimately
    # reused by what used to be the next polygon -- it is NOT "the deleted
    # polygon" reappearing).
    assert m.data["connects"] == expected_connects
    assert m.validate() == []


def test_delete_polygon_clears_player_when_its_polygon_is_deleted():
    model = M.EditorModel()
    model.load(L01)
    player_polygon = model.data["player"]["polygon"]
    model.delete_polygon(player_polygon)
    assert model.data["player"] is None
    errs = model.validate()
    assert any("no player" in e for e in errs)


def test_delete_polygon_reindexes_terminals_and_radio_triggers():
    model = M.EditorModel()
    model.load(L01)
    # l01 must carry at least one terminal for this test to mean anything --
    # find it dynamically rather than hardcoding which polygon happens to hold
    # it. Radio is a dead gameplay channel (LevelBuilder.radio() now raises;
    # see levels.py) so l01.json no longer carries any authored radio lines
    # -- the editor's lore.radio reindexing is still live code (the editor
    # lets an author park radio-shaped notes in lore.radio for later
    # terminal/conversation work), so exercise it with a synthetic entry
    # instead of relying on campaign content that no longer exists.
    term_polygons = {t["polygon"] for t in model.data["lore"]["terminals"]}
    assert term_polygons, "l01 should have at least one terminal"

    non_player_polygons = [r for r in range(len(model.data["polygons"]))
                        if r != model.data["player"]["polygon"]]
    radio_polygon = non_player_polygons[0]
    model.data["lore"]["radio"].append(
        {"trigger": f"enter_polygon:{radio_polygon}", "text": "test line"})
    radio_polygons = {
        int(_ENTER_POLYGON_RE.match(r["trigger"]).group(1))
        for r in model.data["lore"]["radio"]
        if _ENTER_POLYGON_RE.match(r["trigger"])
    }
    assert radio_polygons, "synthetic enter_polygon radio trigger should be present"

    player_polygon = model.data["player"]["polygon"]
    # Delete the player's polygon: it invalidates the level (checked
    # separately elsewhere); what this test cares about is that the
    # *other* polygon-index references scattered through lore still shift
    # down by one correctly.
    model.delete_polygon(player_polygon)

    def remap(idx):
        if idx == player_polygon:
            return None
        return idx - 1 if idx > player_polygon else idx

    expected_term_polygons = {remap(r) for r in term_polygons} - {None}
    expected_radio_polygons = {remap(r) for r in radio_polygons} - {None}

    after_term_polygons = {t["polygon"] for t in model.data["lore"]["terminals"]}
    after_radio_polygons = {
        int(_ENTER_POLYGON_RE.match(r["trigger"]).group(1))
        for r in model.data["lore"]["radio"]
        if _ENTER_POLYGON_RE.match(r["trigger"])
    }
    assert after_term_polygons == expected_term_polygons
    assert after_radio_polygons == expected_radio_polygons
    errs = model.validate()
    assert errs == ["no player spawn"]


def test_add_polygon_connect_save_loads_and_runs(tmp_path):
    model = M.EditorModel()
    model.load(L01)
    n_polygons_before = len(model.data["polygons"])

    ri = model.add_rect_polygon(1000, 1000, 120, 90)
    assert model.data["polygons"][ri]["verts"] == [
        [1000, 1000], [1000, 1090], [1120, 1090], [1120, 1000],
    ]

    # Find some existing polygon/edge pair that no `connects`/`connects_x`/
    # `doors` entry already claims, so wiring the new polygon to it is a clean
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

    target_polygon, target_edge = next(
        (target_polygon, ei)
        for target_polygon, polygon in enumerate(model.data["polygons"])
        if target_polygon != ri
        for ei in range(len(polygon["verts"]))
        if (target_polygon, ei) not in used_edges
    )

    model.connect_edges(ri, 0, target_polygon, target_edge)
    assert model.validate() == []

    out = tmp_path / "edited.json"
    errs = model.save(out)
    assert errs == []
    assert model.path == out
    assert not model.dirty

    on_disk = json.loads(out.read_text())
    assert on_disk["version"] == 2
    assert len(on_disk["polygons"]) == n_polygons_before + 1

    lvl = load_level(out)
    assert len(lvl.polygon_verts) == n_polygons_before + 1

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
    m.add_rect_polygon(2000, 2000, 50, 50)
    m.move_polygon(0, 10, 10)
    assert m.data != prior

    assert m.undo() is True  # undoes move_polygon
    assert m.undo() is True  # undoes add_rect_polygon
    assert m.data == prior
    assert m.undo() is False  # nothing left to undo


def test_convexity_violation_blocks_save(m, tmp_path):
    # Smash a vertex of polygon 0 inward so the polygon becomes reflex there.
    m.data["polygons"][0]["verts"][2] = [50, 50]
    errs_before = m.validate()
    assert any("concave" in e for e in errs_before)

    save_errs = m.save(tmp_path / "should_not_exist.json")
    assert save_errs == errs_before
    assert not (tmp_path / "should_not_exist.json").exists()


def test_wrong_winding_blocks_save(tmp_path):
    model = M.EditorModel()
    model.load(L01)
    model.data["polygons"][0]["verts"] = list(reversed(model.data["polygons"][0]["verts"]))
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
    # Polygon 0 edge 3 is already used by connects[2] == [0,3,1,0]; claim it
    # again from an unrelated polygon/edge -- must be rejected as a conflict,
    # not silently accepted.
    m.data["connects"].append([0, 3, 2, 0])
    errs = m.validate()
    assert any("used by multiple connections" in e for e in errs)
    assert m.save(tmp_path / "x.json") == errs


def test_self_mirror_connect_is_not_a_double_use_conflict(m):
    # The same edge appearing as BOTH sides of a single record (a==b,
    # ea==eb) is a deliberate mirror connect (see levels/l06.json), not a
    # conflict -- it must not trip the double-used-edge validator.
    ri = m.add_rect_polygon(5000, 5000, 100, 100)
    m.connect_edges(ri, 0, ri, 0)
    errs = m.validate()
    assert not any("used by multiple connections" in e for e in errs)


def test_add_entity_rejects_unspawnable_type(m):
    with pytest.raises(ValueError):
        m.add_entity(0, "terminal", 10, 10)  # terminals go through add_terminal


def test_delete_entity_and_terminal():
    model = M.EditorModel()
    model.load(L01)
    n_before = len(model.data["polygons"][0]["entities"])
    model.delete_entity(0, 0)
    assert len(model.data["polygons"][0]["entities"]) == n_before - 1

    ti = model.add_terminal(1, 300, 100, "hello")
    assert model.data["lore"]["terminals"][ti]["text"] == "hello"
    model.delete_terminal(ti)
    assert all(t["text"] != "hello" for t in model.data["lore"]["terminals"])


def test_delete_vertex_drops_bound_connections_not_others():
    model = M.EditorModel()
    model.load(L01)
    # polygon 0 has 6 verts; edges 3 and 4 touch vertex 4 (the vertex between
    # them). Delete vertex 4 and confirm any connect bound to those exact
    # edges of polygon 0 is gone while unrelated connects on polygon 0 survive.
    polygon0 = model.data["polygons"][0]
    n_before = len(polygon0["verts"])
    ok = model.delete_vertex(0, 4)
    assert ok
    assert len(model.data["polygons"][0]["verts"]) == n_before - 1
    # every remaining connect edge index must be valid for polygon 0 now.
    n_edges = len(model.data["polygons"][0]["verts"])
    for a, ea, b, eb in model.data["connects"]:
        if a == 0:
            assert 0 <= ea < n_edges
        if b == 0:
            assert 0 <= eb < n_edges


def test_delete_vertex_refuses_below_triangle():
    model = M.EditorModel()
    # a bare triangle polygon
    model.data["polygons"].append({"verts": [[0, 0], [0, -10], [10, 0]], "entities": []})
    assert model.delete_vertex(0, 0) is False
    assert len(model.data["polygons"][0]["verts"]) == 3


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
