import pytest

from perihelion.topology import (EdgeHandle, PortalLink, TopologyError,
                                  TopologyManager)


class Sim:
    def __init__(self, lengths=None, scale=1.0):
        self.lengths = lengths or {(0, 2): 4.0, (1, 3): 4.0}
        self.scale = scale
        self.connected = []
        self.disconnected = []

    def edge_endpoints(self, polygon, edge):
        length = self.lengths[(polygon, edge)]
        return 0.0, 0.0, length, 0.0

    def connect(self, ra, ea, rb, eb):
        self.connected.append((ra, ea, rb, eb))

    def portal_xform(self, polygon, edge):
        return (self.scale, 0.0, 0.0, 0.0, self.scale, 0.0, 0.0, 0.0, 1.0)

    def disconnect(self, polygon, edge):
        self.disconnected.append((polygon, edge))


class World:
    def __init__(self, sim=None, carve_result=None):
        self.sim = sim or Sim()
        self.carve_result = carve_result
        self.carve_calls = []

    def carve_door(self, polygon, near, width):
        self.carve_calls.append((polygon, near, width))
        return self.carve_result


def test_adopt_assigns_stable_distinct_handles():
    manager = TopologyManager(World())
    first = manager.adopt(4, 7)
    second = manager.adopt(4, 8)
    assert first == EdgeHandle(1)
    assert second == EdgeHandle(2)
    assert manager.current_edge(first) == (4, 7)
    assert manager.current_edge(second) == (4, 8)
    with pytest.raises(TopologyError, match="stale edge handle 99"):
        manager.current_edge(EdgeHandle(99))


def test_split_updates_only_later_handles_in_the_same_polygon():
    manager = TopologyManager(World())
    before = manager.adopt(2, 3)
    at_or_after = manager.adopt(2, 4)
    other_polygon = manager.adopt(3, 5)
    manager._shift_after_split(2, 4)
    assert manager.current_edge(before) == (2, 3)
    assert manager.current_edge(at_or_after) == (2, 6)
    assert manager.current_edge(other_polygon) == (3, 5)


def test_carve_forwards_arguments_and_notifies_only_on_success():
    changes = []
    world = World(carve_result=None)
    manager = TopologyManager(world, lambda: changes.append("changed"))
    assert manager.carve(5, (1.0, 2.0), 6.0) is None
    assert world.carve_calls == [(5, (1.0, 2.0), 6.0)]
    assert changes == []
    world.carve_result = 4
    handle = manager.carve(5, (3.0, 4.0), 8.0)
    assert manager.current_edge(handle) == (5, 4)
    assert changes == ["changed"]


def test_connect_returns_endpoints_and_notifies():
    changes = []
    world = World()
    manager = TopologyManager(world, lambda: changes.append("changed"))
    a = manager.adopt(0, 2)
    b = manager.adopt(1, 3)
    assert manager.connect_equal(a, b) == PortalLink(a, b)
    assert world.sim.connected == [(0, 2, 1, 3)]
    assert changes == ["changed"]


def test_bad_derived_scale_disconnects_the_source_edge():
    sim = Sim(scale=1.25)
    manager = TopologyManager(World(sim))
    a = manager.adopt(0, 2)
    b = manager.adopt(1, 3)
    with pytest.raises(TopologyError, match="derived portal scale 1.250000000"):
        manager.connect_equal(a, b)
    assert sim.disconnected == [(0, 2)]


def test_length_error_names_both_lengths_without_connecting():
    sim = Sim(lengths={(0, 2): 4.0, (1, 3): 5.0})
    manager = TopologyManager(World(sim))
    a = manager.adopt(0, 2)
    b = manager.adopt(1, 3)
    with pytest.raises(TopologyError, match=r"4\.000000000 vs 5\.000000000"):
        manager.connect_equal(a, b)
    assert sim.connected == []
