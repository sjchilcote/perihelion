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
    s._damage_enemy(eid, 999.0, (1.0, 0.0), 0.0)
    drops = [p for p in s.pickups.values() if p["kind"] == "components"]
    assert len(drops) == 1
    assert drops[0]["amount"] == ENEMIES["husk"]["score"]


def test_components_pickup_adds_to_wallet():
    s = _session()
    px, py = s.player_pos()
    s.spawn_pickup(s.player_room(), (px + 2, py), "components",
                   extra=dict(amount=5))
    _tick(s, 2)
    assert s.components == 5
    assert not any(p["kind"] == "components" for p in s.pickups.values())


def test_death_drops_corpse_and_zeroes_carried_salvage():
    s = _session(components=9, station_kits=1)
    room = s.player_room()
    s._damage_player(9999.0, room)
    assert s.dead
    assert s.components == 0 and s.station_kits == 0
    corpses = [p for p in s.pickups.values() if p["kind"] == "corpse_frame"]
    assert len(corpses) == 1
    assert corpses[0]["contents"] == dict(components=9, station_kits=1)


def test_multiple_corpses_accumulate():
    s = _session(components=3, chassis=2)
    s.add_station(s.player_room(), s.player_pos())
    s._damage_player(9999.0, s.player_room())
    assert s.respawn_at_station()
    s.components = 4
    s.hurt_cd = 0
    s._damage_player(9999.0, s.player_room())
    corpses = [p for p in s.pickups.values() if p["kind"] == "corpse_frame"]
    assert len(corpses) == 2


def test_corpse_retrieval_returns_contents_exactly():
    s = _session(components=9, chassis=1)
    room = s.player_room()
    pos = s.player_pos()
    s.add_station(room, (pos[0] - 60, pos[1]))
    s._damage_player(9999.0, room)
    assert s.respawn_at_station()
    assert not s.dead and s.hp == s.max_hp and s.chassis == 0
    # walk back onto the wreck
    s.sim.set_pos(s.pid, *pos)
    _tick(s, 2)
    assert s.components == 9
    assert not any(p["kind"] == "corpse_frame" for p in s.pickups.values())


def test_no_chassis_means_no_station_respawn():
    s = _session(components=1)
    s.add_station(s.player_room(), s.player_pos())
    s._damage_player(9999.0, s.player_room())
    assert not s.respawn_at_station()
    assert s.dead


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
    st = s.station_near(s.player_room())
    assert st is not None
    assert not s.place_station()  # no kit left


def test_interact_at_station_opens_shop():
    s = _session()
    s.add_station(s.player_room(), s.player_pos())
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
    assert s.stations and s.stations[0]["room"] == s.player_room()
    s._damage_player(9999.0, s.player_room())
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
# the mind map (9.2)
# ---------------------------------------------------------------------------

def test_mindmap_data_integrity():
    from perihelion import mindmap
    tbl = mindmap.nodes()
    assert len(tbl) >= 28
    for n in tbl.values():
        for p in n["prereqs"]:
            assert p in tbl, f"dangling prereq {p}"
        assert n["region"] in mindmap.REGION_ORDER


def test_buy_node_prereqs_costs_and_faith():
    from perihelion import mindmap
    s = _session(components=500)
    # a capstone is locked until its spine is bought
    assert not s.buy_node("vocation-protected-revival")
    assert s.buy_node("vocation-just-war")
    f1 = s.faith
    assert f1 == mindmap.nodes()["vocation-just-war"]["faith"]
    spent = mindmap.price("vocation-just-war")
    assert s.components == 500 - spent
    # buying twice refuses
    assert not s.buy_node("vocation-just-war")


def test_mindmap_effects_wire_into_combat():
    s = _session(components=500)
    base_armor = s._armor_mul
    for nid in ("vocation-just-war", "vocation-doctrine-of-restraint",
                "vocation-testators-as-kin", "vocation-armor-of-the-unsleeping"):
        assert s.buy_node(nid), nid
    assert s._spread_mul < 1.0
    assert s._armor_mul < base_armor
    assert s._target_mark_mul > 1.0


def test_protected_revival_banks_salvage():
    s = _session(components=500)
    for nid in ("vocation-just-war", "vocation-doctrine-of-restraint",
                "vocation-testators-as-kin", "vocation-psalm-of-the-loop",
                "vocation-protected-revival"):
        assert s.buy_node(nid), nid
    left = s.components
    s._damage_player(9999.0, s.player_room())
    assert s.components == left  # the seed held it in trust
    assert not any(p["kind"] == "corpse_frame" for p in s.pickups.values())


def test_mind_rides_state_snapshots():
    s = _session(components=500)
    assert s.buy_node("history-the-long-peace")
    st = dict(mind=sorted(s.mind), components=s.components)
    s2 = _session(**st)
    assert "history-the-long-peace" in s2.mind
    assert s2.mind_unlocks == s.mind_unlocks


# ---------------------------------------------------------------------------
# scavenged weapons: the scrap driver and the grafted gland
# ---------------------------------------------------------------------------

def test_scrap_driver_fires_components_as_ammo():
    s = _session(components=30)
    assert s.buy("scrap_driver")
    assert s.weapon == "scrap"
    left = s.components
    px, py = s.player_pos()
    s.aim = (1.0, 0.0)
    s._fire(s.player_room(), px, py)
    assert s.components == left - 2
    assert sum(1 for b in s.bullets.values() if b["kind"] == "scrap") == 3


def test_scrap_driver_dry_when_broke():
    s = _session(components=16)
    assert s.buy("scrap_driver")
    s.components = 1
    px, py = s.player_pos()
    s._fire(s.player_room(), px, py)
    assert s.components == 1  # refused, nothing spent
    assert not s.bullets


def test_gland_costs_integrity_and_never_kills_you():
    s = _session()
    s.weapons.append("gland")
    s.weapon = "gland"
    px, py = s.player_pos()
    s._fire(s.player_room(), px, py)
    assert s.hp == s.max_hp - 1
    assert any(b["kind"] == "gland" for b in s.bullets.values())
    s.hp = 1
    s.cooldown = 0
    n = len(s.bullets)
    s._fire(s.player_room(), px, py)
    assert s.hp == 1 and len(s.bullets) == n  # dry: it will not take the last


def test_spitter_yields_gland_only_with_harvest_node():
    s = _session()
    eid = s.spawn_enemy(0, (100.0, 0.0), "spitter")
    s._damage_enemy(eid, 999.0, (1.0, 0.0), 0.0)
    assert not any(p["kind"] == "organ_gland" for p in s.pickups.values())
    s2 = _session(components=500)
    for nid in ("comprehension-connection-space",
                "comprehension-adversary-biology-survey",
                "void-arithmetic-of-futility",
                "void-organ-harvesting-protocol"):
        assert s2.buy_node(nid), nid
    eid = s2.spawn_enemy(0, (100.0, 0.0), "spitter")
    s2._damage_enemy(eid, 999.0, (1.0, 0.0), 0.0)
    assert any(p["kind"] == "organ_gland" for p in s2.pickups.values())
