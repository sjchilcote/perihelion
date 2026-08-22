import pytest

from perihelion.signals import SignalField, SignalKind


class World:
    def __init__(self):
        self.adj = [[1], [0]]

    def num_polygons(self):
        return 2

    def polygon_portals(self, polygon):
        return [(other, 0) for other in self.adj[polygon]]


def test_initial_tick_and_total_are_observable():
    field = SignalField(World(), tick=10)
    with pytest.raises(ValueError):
        field.sample(SignalKind.NOISE, 0, 9)
    assert field.total(SignalKind.NOISE, 10) == 0.0
    field.emit(SignalKind.NOISE, 0, 0.75, 10)
    assert field.total(SignalKind.NOISE, 10) == pytest.approx(0.75)


def test_neighborhood_default_and_zero_depth():
    field = SignalField(World())
    field.emit(SignalKind.NOISE, 0, 0.5, 0)
    field.emit(SignalKind.DANGER, 1, 0.25, 0)
    view = field.neighborhood(0, 0)
    assert view.center == 0
    assert view.own[SignalKind.NOISE] == pytest.approx(0.5)
    assert len(view.adjacent) == 1
    assert view.adjacent[0][0] == 1
    assert view.adjacent[0][1][SignalKind.DANGER] == pytest.approx(0.25)
    own_only = field.neighborhood(0, 0, depth=0)
    assert own_only.center == 0
    assert own_only.adjacent == ()


def test_topology_refresh_replaces_adjacency():
    world = World()
    field = SignalField(world)
    assert len(field.neighborhood(0, 0).adjacent) == 1
    world.adj = [[], []]
    field.on_topology_changed()
    assert field.neighborhood(0, 0).adjacent == ()
