"""The revival economy (design doc 9.1/9.3): salvage, corpses, chassis,
seed stations, the fabricator."""

import math
import os
import tempfile

from perihelion.levels import LevelBuilder, save_level, load_level
from perihelion.sim import ENEMIES, GameSession, InputFrame, SHOP
from perihelion.stream import WorldStreamer


def _level():
    b = LevelBuilder("ECON TEST", 1)
    r0 = b.rect(0, 0, 260, 180, kind="dock")
    r1 = b.rect(260, 30, 200, 120, kind="corridor")
    b.player(r0, (60, 90))
    b.exit(r1, (420, 90))
    return b.build()


def _session(**st):
    return GameSession(_level(), seed=7, player_state=st or None)


def _tick(s, n=1, **kw):
    for _ in range(n):
        s.tick(InputFrame(**kw))


def test_kill_drops_salvage_worth_score():
    s = _session()
    eid = s.spawn_enemy(0, (120.0, 0.0), "husk")
    s._damage_enemy(eid, 999.0, (1.0, 0.0), 0.0, source="test")
    drops = [p for p in s.pickups.values() if p["kind"] == "components"]
    assert len(drops) == 1
    assert drops[0]["amount"] == ENEMIES["husk"]["score"]


def test_components_pickup_adds_to_wallet():
    s = _session()
    px, py = s.player_pos()
    s.spawn_pickup(s.player_polygon(), (px + 2, py), "components",
                   extra=dict(amount=5))
    _tick(s, 2)
    assert s.components == 5
    assert not any(p["kind"] == "components" for p in s.pickups.values())


def test_death_drops_corpse_and_zeroes_carried_salvage():
    s = _session(components=9, station_kits=1)
    polygon = s.player_polygon()
    s._damage_player(9999.0, polygon, source="test")
    assert s.dead
    assert s.components == 0 and s.station_kits == 0
    corpses = [p for p in s.pickups.values() if p["kind"] == "corpse_frame"]
    assert len(corpses) == 1
    assert corpses[0]["contents"] == dict(components=9, station_kits=1)


def test_multiple_corpses_accumulate():
    s = _session(components=3, chassis=2)
    s.add_station(s.player_polygon(), s.player_pos())
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.respawn_at_station()
    s.components = 4
    s.hurt_cd = 0
    s._damage_player(9999.0, s.player_polygon(), source="test")
    corpses = [p for p in s.pickups.values() if p["kind"] == "corpse_frame"]
    assert len(corpses) == 2


def test_corpse_retrieval_returns_contents_exactly():
    s = _session(components=9, chassis=1)
    polygon = s.player_polygon()
    pos = s.player_pos()
    s.add_station(polygon, (pos[0] - 60, pos[1]))
    s._damage_player(9999.0, polygon, source="test")
    assert s.respawn_at_station()
    assert not s.dead and s.hp == s.max_hp and s.chassis == 0
    # walk back onto the wreck
    s.sim.set_pos(s.pid, *pos)
    _tick(s, 2)
    assert s.components == 9
    assert not any(p["kind"] == "corpse_frame" for p in s.pickups.values())


def test_no_chassis_prints_at_the_starting_pod():
    """DESIGN_7_25: the starting pod has infinite backup chassis (for
    now) — with nothing racked you always come back, and what you pay
    is the walk from the START, not the nearest station."""
    s = _session(components=1)
    home = s.stations[0]
    near = (s.player_pos()[0] - 40, s.player_pos()[1])
    s.add_station(s.player_polygon(), near)
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.respawn_at_station(), "the home pod must always print"
    assert not s.dead and s.hp == s.max_hp and s.chassis == 0
    assert s.player_polygon() == home["polygon"]
    px, py = s.player_pos()
    assert (round(px, 1), round(py, 1)) == (round(home["pos"][0], 1),
                                            round(home["pos"][1], 1)), \
        "a free print must come from the STARTING pod, not the nearest station"


def test_fabricator_prices_and_purchases():
    s = _session(components=100)
    assert s.buy("chassis") and s.chassis == 1
    assert s.buy("station_kit") and s.station_kits == 1
    hp0 = s.max_hp
    p0 = s.shop_price("hp_up")
    assert s.buy("hp_up") and s.max_hp == hp0 + 15
    assert s.shop_price("hp_up") == p0 + SHOP["hp_up"]["growth"]
    a0 = s.ammo.get("shell", 0)
    assert s.buy("ammo_shell") and s.ammo["shell"] == a0 + 7
    spent = (SHOP["chassis"]["cost"] + SHOP["station_kit"]["cost"] + p0 +
             SHOP["ammo_shell"]["cost"])
    assert s.components == 100 - spent


def test_fabricator_refuses_when_broke():
    s = _session(components=1)
    assert not s.buy("chassis")
    assert s.components == 1 and s.chassis == 0


def test_place_station_consumes_kit_and_anchors_here():
    s = _session(station_kits=1)
    assert s.place_station()
    assert s.station_kits == 0
    st = s.station_near(s.player_polygon())
    assert st is not None
    assert not s.place_station()  # no kit left


def test_interact_at_station_opens_shop():
    s = _session()
    s.add_station(s.player_polygon(), s.player_pos())
    s.fx.clear()
    _tick(s, 1, interact=True)
    assert ("shop",) in s.fx


def _chunks(n=2):
    tmp = tempfile.mkdtemp()
    paths = []
    for i in range(n):
        b = LevelBuilder(f"CHUNK {i}", 1)
        r0 = b.rect(0, 0, 260, 180, kind="dock")
        r1 = b.rect(260, 30, 200, 120, kind="corridor")
        b.player(r0, (60, 90))
        b.exit(r1, (420, 90))
        p = os.path.join(tmp, f"c{i}.json")
        save_level(b.to_dict(), p)
        paths.append(p)
    return paths


def test_cold_restore_preserves_corpses_and_does_not_refund():
    paths = _chunks()
    s = GameSession(load_level(paths[0]), seed=3,
                    player_state=dict(components=6))
    ws = WorldStreamer(s, paths)
    # chunk entry planted a seed station automatically
    assert s.stations and s.stations[0]["polygon"] == s.player_polygon()
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.dead and s.components == 0
    ws.respawn()
    assert not s.dead
    # the wreck survived the chunk restock, and the entry snapshot did not
    # resurrect the components that are riding it
    corpses = [p for p in s.pickups.values() if p["kind"] == "corpse_frame"]
    assert len(corpses) == 1
    assert corpses[0]["contents"]["components"] == 6
    assert s.components == 0


# ---------------------------------------------------------------------------
# the mind map (9.2): thinking as time (SEEDPOD_UI_DESIGN.md)
# ---------------------------------------------------------------------------

def _grant(s, *nids):
    """Walk the full time model for each node: focus it, accrue the last
    field tick of thought, and perform the pod's completion (the accrual
    boundary is exercised; the bulk ticks are preseeded for test speed)."""
    from perihelion import mindmap
    for nid in nids:
        assert s.set_focus(nid), nid
        s.think_progress[nid] = mindmap.think_ticks(nid) - 1
        _tick(s)
        assert nid in s.think_done, nid
        assert s.complete_focus(nid), nid


def test_mindmap_data_integrity():
    from perihelion import mindmap
    tbl = mindmap.nodes()
    assert len(tbl) >= 28
    lay = mindmap.layout()
    for n in tbl.values():
        for p in n["prereqs"]:
            assert p in tbl, f"dangling prereq {p}"
        assert n["region"] in mindmap.REGION_ORDER
        assert mindmap.think_ticks(n["id"]) > 0
        assert n["id"] in lay
    # deterministic layout: same table -> same positions, no collisions
    assert len({lay[i] for i in tbl}) == len(tbl)


def test_set_focus_prereqs_and_refusals():
    s = _session()
    # a capstone is locked until its spine is thought through
    assert not s.set_focus("vocation-protected-revival")
    assert s.set_focus("vocation-just-war")
    assert s.think_focus == "vocation-just-war"
    # switching focus keeps the old node's accrued thought
    _tick(s, 10)
    assert s.set_focus("history-the-long-peace")
    assert s.think_progress["vocation-just-war"] == 10
    # a node already in the mind can't be re-focused
    _grant(s, "history-the-long-peace")
    assert not s.set_focus("history-the-long-peace")


def test_thinking_accrues_in_field_and_unlock_waits_for_pod():
    from perihelion import mindmap
    s = _session()
    nid = "vocation-just-war"
    need = mindmap.think_ticks(nid)
    assert need == mindmap.weight(nid) * mindmap.THINK_TICKS_PER_WEIGHT
    assert s.set_focus(nid)
    _tick(s, need - 1)
    assert s.think_progress[nid] == need - 1 and not s.think_done
    s.fx.clear()
    _tick(s)  # the finishing tick
    assert s.think_done == [nid]
    assert s.think_focus is None
    assert nid not in s.mind  # field completion is a cue, not the unlock
    assert ("thought_done", nid) in s.fx  # the quiet field cue fired
    # the pod reveal performs the unlock
    assert s.complete_focus(nid)
    assert nid in s.mind and not s.think_done
    assert s.faith == mindmap.nodes()[nid]["faith"]
    # completing twice refuses
    assert not s.complete_focus(nid)


def test_dead_frames_do_not_think():
    s = _session()
    assert s.set_focus("vocation-just-war")
    _tick(s, 5)
    s._damage_player(9999.0, s.player_polygon(), source="test")
    p = s.think_progress["vocation-just-war"]
    _tick(s, 20)  # dead ticks accrue nothing
    assert s.think_progress["vocation-just-war"] == p


def test_reveal_unlock_admits_neighbors():
    from perihelion import mindmap
    s = _session()
    assert "vocation-doctrine-of-restraint" not in mindmap.frontier(s.mind)
    _grant(s, "vocation-just-war")
    # the fog lifts: the integrated node's dependents join the frontier
    assert "vocation-doctrine-of-restraint" in mindmap.frontier(s.mind)
    assert mindmap.available(s.mind, "vocation-doctrine-of-restraint")


def test_mindmap_effects_wire_into_combat():
    s = _session()
    base_armor = s._armor_mul
    _grant(s, "vocation-just-war", "vocation-doctrine-of-restraint",
           "vocation-testators-as-kin", "vocation-armor-of-the-unsleeping")
    assert s._spread_mul < 1.0
    assert s._armor_mul < base_armor
    assert s._target_mark_mul > 1.0


def test_protected_revival_banks_salvage():
    s = _session(components=50)
    _grant(s, "vocation-just-war", "vocation-doctrine-of-restraint",
           "vocation-testators-as-kin", "vocation-psalm-of-the-loop",
           "vocation-protected-revival")
    left = s.components
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.components == left  # the seed held it in trust
    assert not any(p["kind"] == "corpse_frame" for p in s.pickups.values())


def test_mind_rides_state_snapshots():
    s = _session()
    _grant(s, "history-the-long-peace")
    st = dict(mind=sorted(s.mind))
    s2 = _session(**st)
    assert "history-the-long-peace" in s2.mind
    assert s2.mind_unlocks == s.mind_unlocks


def test_thinking_survives_death_and_reprint():
    s = _session(components=9, chassis=1)
    s.add_station(s.player_polygon(), s.player_pos())
    assert s.set_focus("vocation-just-war")
    _tick(s, 30)
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.dead and s.components == 0  # dying costs loot...
    assert s.respawn_at_station()
    assert s.think_focus == "vocation-just-war"  # ...never thought
    assert s.think_progress["vocation-just-war"] == 30
    _tick(s, 10)
    assert s.think_progress["vocation-just-war"] == 40  # still accruing


def test_thinking_survives_cold_restore():
    from perihelion import mindmap
    paths = _chunks()
    s = GameSession(load_level(paths[0]), seed=3)
    ws = WorldStreamer(s, paths)
    assert s.set_focus("vocation-just-war")
    # finish the thought in the field: the completion queue must also ride
    s.think_progress["vocation-just-war"] = \
        mindmap.think_ticks("vocation-just-war") - 1
    _tick(s)
    assert s.think_done == ["vocation-just-war"]
    s._damage_player(9999.0, s.player_polygon(), source="test")
    ws.respawn()
    assert not s.dead
    assert s.think_done == ["vocation-just-war"]  # queue survived
    # and the save-file snapshot carries the whole thinking state
    st = ws.entry_states[0]
    assert "think_progress" in st and "think_done" in st


def test_thinking_state_roundtrips_player_state():
    s = _session()
    assert s.set_focus("vocation-just-war")
    _tick(s, 25)
    st = dict(mind=sorted(s.mind), think_focus=s.think_focus,
              think_progress=dict(s.think_progress),
              think_done=list(s.think_done))
    s2 = _session(**st)
    assert s2.think_focus == "vocation-just-war"
    assert s2.think_progress["vocation-just-war"] == 25
    _tick(s2, 5)
    assert s2.think_progress["vocation-just-war"] == 30


def test_thinking_is_deterministic():
    def run():
        s = _session()
        s.set_focus("vocation-just-war")
        for i in range(240):
            s.tick(InputFrame(mx=1.0 if i % 3 else 0.0, my=0.5,
                              fire=i % 7 == 0))
        snap = s.snapshot()
        return (snap["think_focus"], dict(snap["think_progress"]),
                list(snap["think_done"]), snap["pos"])

    assert run() == run()


# ---------------------------------------------------------------------------
# recall beacons: emergency teleport home
# ---------------------------------------------------------------------------

def test_recall_channel_completes_at_the_seed():
    s = _session(components=10)
    assert s.buy("recall") and s.recalls == 1
    home = s.stations[0]
    s.sim.set_pos(s.pid, home["pos"][0] + 80, home["pos"][1])
    assert s.use_recall()
    assert not s.use_recall()  # channel already open
    _tick(s, 95)
    assert s.recalls == 0 and s.recall_t == 0
    px, py = s.player_pos()
    assert abs(px - home["pos"][0]) < 2 and abs(py - home["pos"][1]) < 2


def test_recall_severed_by_damage():
    s = _session(recalls=1)
    assert s.use_recall()
    _tick(s, 10)
    s._damage_player(5.0, s.player_polygon(), source="test")
    assert s.recall_t == 0
    assert s.recalls == 1  # the beacon is not spent on a severed channel
    _tick(s, 100)
    assert s.recalls == 1  # and the channel did not complete


def test_recall_refuses_without_beacon():
    s = _session()
    assert not s.use_recall()


def test_protected_revival_grants_a_grace_window():
    """The rite of return (mindmap vocation capstone): a fresh print is
    untouchable for 3 seconds — run 51 flagged the promised window as
    having no consumer at all."""
    s = _session(components=1, mind=["vocation-protected-revival"])
    assert s._protected_revival, "unlock plumbing broken"
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.dead
    assert s.respawn_at_station()
    assert s.revival_grace == 180
    hp0 = s.hp
    s.hurt_cd = 0
    s._damage_player(50.0, s.player_polygon(), source="test")
    assert s.hp == hp0, "damage landed inside the grace window"
    _tick(s, 181)
    assert s.revival_grace == 0
    s.hurt_cd = 0
    s._damage_player(10.0, s.player_polygon(), source="test")
    assert s.hp < hp0, "the window never closed"


def test_no_grace_window_without_the_rite():
    s = _session(components=1)
    s._damage_player(9999.0, s.player_polygon(), source="test")
    assert s.respawn_at_station()
    assert s.revival_grace == 0
    hp0 = s.hp
    s.hurt_cd = 0
    s._damage_player(10.0, s.player_polygon(), source="test")
    assert s.hp < hp0
