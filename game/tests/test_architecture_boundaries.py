"""Import-boundary gates (U1+): decoupling enforced as structure.

Each rule here is a ratified architectural boundary from DESIGN_7_25.
They are AST checks, not import-time checks, so a violation hidden
inside a function body fails the same as a top-level import.

The vocabulary grows with later units (scouts must not import marrow,
breach must not import marrow, reserve must not read player state) —
add each new module's boundary HERE when the module lands.
"""
from __future__ import annotations

import ast
from pathlib import Path

import pytest

PKG = Path(__file__).resolve().parent.parent / "perihelion"

STDLIB_OK = {
    "__future__", "json", "math", "dataclasses", "typing", "collections",
    "enum", "io", "os", "random", "itertools", "functools", "abc",
    # the frame meter measures wall time; a clock is not a dependency on
    # the game, which is what this law is about
    "time",
}


def _imports_of(path: Path) -> set[str]:
    tree = ast.parse(path.read_text(), filename=str(path))
    roots: set[str] = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for a in node.names:
                roots.add(a.name.split(".")[0])
        elif isinstance(node, ast.ImportFrom):
            if node.level > 0:
                # relative import: record the first component so
                # ".telemetry" reads as "telemetry", "..sim" as "sim"
                if node.module:
                    roots.add(node.module.split(".")[0])
            elif node.module is not None:
                roots.add(node.module.split(".")[0])
    return roots


def test_telemetry_imports_stdlib_only():
    """The spine depends on nothing in the game: no pygame, no numpy, no
    audio, no render, no sim — it cannot even see them."""
    extra = _imports_of(PKG / "telemetry.py") - STDLIB_OK
    assert not extra, f"telemetry.py imports beyond stdlib: {extra}"


@pytest.mark.parametrize("modname", ["render.py", "hud.py"])
def test_renderer_cannot_subscribe_to_telemetry(modname):
    """Visual tells must read real system state; a renderer that draws
    from the trace could animate a lie the sim never lived."""
    assert "telemetry" not in _imports_of(PKG / modname), (
        f"{modname} imports telemetry — tells must come from system state")


def test_sim_stays_pygame_and_io_free():
    roots = _imports_of(PKG / "sim.py")
    for forbidden in ("pygame", "audio", "render", "app"):
        assert forbidden not in roots, f"sim.py imports {forbidden}"


def test_senses_import_only_stdlib_and_engine():
    """The senses are shared infrastructure UNDER the game systems: they
    may see the engine (necore) and nothing above themselves — no sim, no
    marrow, no audio, no render. Perception can never smuggle in another
    system's internals."""
    extra = _imports_of(PKG / "senses.py") - STDLIB_OK - {"necore"}
    assert not extra, f"senses.py imports beyond stdlib+necore: {extra}"


def test_signals_import_only_stdlib_and_engine():
    """The substrate is the shared medium UNDER every system: it may know
    portal adjacency (via the world object it is handed) and nothing else
    — no sim, no senses; it cannot read the fight. Since the 2026-07-28
    perf lift its MATH lives in the engine (necore.SignalField,
    engine/necore/src/signals.rs), so the necore import is the
    implementation home, not a fight dependency — the same boundary
    senses.py holds above."""
    extra = _imports_of(PKG / "signals.py") - STDLIB_OK - {"necore"}
    assert not extra, f"signals.py imports beyond stdlib+necore: {extra}"


def test_audio_is_not_a_trace_source():
    """Logging/instrumentation must not be coupled to the audio system
    (IMPLEMENTATION CORRECTIONS): audio.py neither imports telemetry nor
    is imported by it."""
    assert "telemetry" not in _imports_of(PKG / "audio.py")
    assert "audio" not in _imports_of(PKG / "telemetry.py")
