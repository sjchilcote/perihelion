"""PERIHELION level editor.

`model.py` is the pure-Python level-dict editor; `view.py` is the
drafting-canvas UI on top of it (fb2d/numpy drawing; only run()'s window
pump still touches pygame, lazily). Run via
`uv run python -m perihelion.editor [file.json]`.
"""
