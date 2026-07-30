"""Feature demo videos — OFF by default, run when you want to look.

Director: "You can check the videos in as an optional, default-off test
that we can run whenever we want to visually confirm a specific
feature."

These are not assertions about pixels. They exist to REGENERATE the
demo videos on demand and to prove the capture path still works end to
end: each scenario still drives its behavior, the engine encoder still
writes a playable file, and the camera still ends up on the agent rather
than the player.

Every scenario is CONSTRUCTED — the world is built in the state where
the behavior is about to happen, so nothing here searches for a session
in which it happened to occur. Off by default anyway: capturing and
encoding three clips is seconds-to-a-minute of work, which is still far
too slow for the suite that runs on every change.

    # all of them
    PERIHELION_FEATURE_DEMOS=1 uv run pytest tests/test_feature_demos.py

    # just one
    PERIHELION_FEATURE_DEMOS=1 uv run pytest tests/test_feature_demos.py \
        -k shrieker

Videos land in media/features/ (gitignored — the tool regenerates them).
"""
from __future__ import annotations

import os
import struct
import subprocess
import sys
from pathlib import Path

import pytest

ROOT = Path(__file__).resolve().parents[2]
TOOL = ROOT / "tools" / "playtest" / "feature_demo.py"
OUT = ROOT / "media" / "features"

pytestmark = pytest.mark.skipif(
    os.environ.get("PERIHELION_FEATURE_DEMOS") != "1",
    reason="feature demo capture is opt-in: set PERIHELION_FEATURE_DEMOS=1",
)

FEATURES = ["adversary_return", "adversary_lob",
            "adversary_snare", "shrieker_mark"]


def _mp4_track_count(path: Path) -> int:
    """Count top-level MP4 boxes of type 'moov'/'mdat' without a decoder.

    A file that is merely non-empty proves nothing — the first cut of
    the capture path wrote a perfectly valid mp4 full of horizontal
    streaks, because the renderer hands back pygame's (W, H, 3) buffer
    and nobody had transposed it. This at least proves the container is
    real; the eye proves the rest, which is the whole point of the
    videos."""
    seen = 0
    with path.open("rb") as fh:
        while True:
            head = fh.read(8)
            if len(head) < 8:
                break
            size, kind = struct.unpack(">I4s", head)
            if size < 8:
                break
            if kind in (b"moov", b"mdat", b"ftyp"):
                seen += 1
            fh.seek(size - 8, 1)
    return seen


@pytest.mark.parametrize("feature", FEATURES)
def test_feature_demo_captures(feature):
    """Regenerate one demo and make sure it is a real, non-trivial file.

    The tool refuses to write a video for a behavior that did not fire
    in its own scenario, so a zero exit code already means the feature
    was demonstrated."""
    proc = subprocess.run(
        [sys.executable, str(TOOL), "--feature", feature,
         "--out-dir", str(OUT)],
        cwd=str(ROOT), capture_output=True, text=True, timeout=3600,
    )
    assert proc.returncode == 0, (
        f"{feature} demo failed — the behavior never fired in its "
        f"scenario, so no video was written:\n{proc.stdout}\n{proc.stderr}")

    out = OUT / f"{feature}.mp4"
    assert out.exists(), f"{feature}: the tool reported success but wrote no file"
    assert out.stat().st_size > 50_000, (
        f"{feature}: {out.stat().st_size} bytes is too small to be a "
        f"real capture")
    assert _mp4_track_count(out) >= 2, (
        f"{feature}: not a well-formed mp4 container")
    print(f"\n{feature}: {out}  ({out.stat().st_size/1e6:.1f} MB)")
