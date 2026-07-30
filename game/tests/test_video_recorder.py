"""The recorder's three contracts: every frame, real sound, and a
replay that rides inside the file.

These exist because all three failed silently rather than loudly. The
encoder was configured for a video call (120 kbit/s, no periodic
keyframes, frame-skipping allowed) and a skipped frame was dropped from
the muxed stream while still being counted, so a clip could come out
shorter than the tick stream it documented and nothing would say so.
"""
from __future__ import annotations

import math
import subprocess
import zlib

import numpy as np
import pytest

import necore

W, H, FPS, N = 320, 240, 60, 90


def _frames(n=N):
    """Dark gradient plus a moving one-pixel bright line — the content
    that showed the old settings up, and the reason 4:2:0 hurts here."""
    out = []
    for t in range(n):
        img = np.zeros((H, W, 3), np.uint8)
        img[:, :, 2] = np.linspace(0, 40, W, dtype=np.uint8)[None, :]
        img[:, (t * 3) % W] = (255, 220, 40)
        out.append(img.tobytes())
    return out


def _probe(path, *entries):
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-count_frames", "-show_entries",
         f"stream={','.join(entries)}", "-of", "csv=p=0", str(path)],
        capture_output=True, text=True)
    return out.stdout.strip().splitlines()


def test_every_submitted_frame_reaches_the_file(tmp_path):
    """The count in the container equals the count handed in. A capture
    that quietly drops frames slides every later event earlier in time,
    which is how a judge ends up measuring the wrong tick."""
    p = tmp_path / "a.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames():
        rec.add_frame(f)
    rec.finish()
    assert rec.frames == N
    assert _probe(p, "nb_read_frames") == [str(N)], (
        "the muxed stream must hold exactly the frames it was given")


def test_the_clip_is_seekable_partway_through(tmp_path):
    """Periodic keyframes, so scrubbing works. With openh264's default
    `intra_frame_period` of 0 the only IDR is frame zero and every seek
    decodes from the top of the file."""
    p = tmp_path / "b.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames(FPS * 5):
        rec.add_frame(f)
    rec.finish()
    out = subprocess.run(
        ["ffprobe", "-v", "error", "-select_streams", "v:0", "-show_frames",
         "-show_entries", "frame=key_frame", "-of", "csv=p=0", str(p)],
        capture_output=True, text=True)
    keys = sum(1 for line in out.stdout.split() if line.strip() == "1")
    assert keys >= 3, (
        f"only {keys} keyframes in 5s — the clip is not practically "
        "seekable, which is what a reviewer scrubbing a demo hits first")


def test_audio_arrives_as_a_real_track(tmp_path):
    """A tone in, an audio stream out at the rate it was given."""
    p = tmp_path / "c.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames():
        rec.add_frame(f)
    n = int(44100 * N / FPS)
    tone = (np.sin(2 * math.pi * 440 * np.arange(n) / 44100)
            * 8000).astype(np.int16)
    rec.set_audio(np.repeat(tone, 2).tobytes(), 44100, 2)
    rec.finish()
    rows = _probe(p, "codec_type", "sample_rate", "channels")
    assert any(r.startswith("audio") for r in rows), (
        f"no audio track in the muxed file: {rows}")
    audio = next(r for r in rows if r.startswith("audio"))
    assert "44100" in audio and audio.endswith("2"), audio


def test_a_recording_with_no_audio_is_still_valid(tmp_path):
    """Silence stays silent rather than muxing an empty track."""
    p = tmp_path / "d.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames(10):
        rec.add_frame(f)
    rec.finish()
    rows = _probe(p, "codec_type")
    assert rows == ["video"], f"expected video only, got {rows}"


def test_the_replay_rides_inside_the_file(tmp_path):
    """The sidecar survives the mux byte for byte, and the file is still
    an ordinary mp4 that a player will decode."""
    p = tmp_path / "e.mp4"
    payload = zlib.compress(b'{"tick": 1, "kind": "probe"}\n' * 400, 9)
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames(30):
        rec.add_frame(f)
    rec.set_sidecar("replay", payload)
    rec.finish()

    got = dict(necore.read_sidecars(str(p)))
    assert list(got) == ["replay"]
    assert got["replay"] == payload, "the blob must round-trip exactly"
    assert zlib.decompress(got["replay"]).count(b"\n") == 400

    # ...and the attachment must not cost the file its playability
    assert _probe(p, "nb_read_frames") == ["30"], (
        "a file carrying a sidecar must still decode as normal video")


def test_sidecars_are_named_and_replaceable(tmp_path):
    p = tmp_path / "f.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames(5):
        rec.add_frame(f)
    rec.set_sidecar("replay", b"first")
    rec.set_sidecar("notes", b"hello")
    rec.set_sidecar("replay", b"second")      # same name replaces
    rec.finish()
    got = dict(necore.read_sidecars(str(p)))
    assert got == {"replay": b"second", "notes": b"hello"}


def test_a_file_with_no_sidecar_reads_as_empty(tmp_path):
    p = tmp_path / "g.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames(5):
        rec.add_frame(f)
    rec.finish()
    assert necore.read_sidecars(str(p)) == []


def test_bad_audio_is_refused_rather_than_mangled(tmp_path):
    p = tmp_path / "h.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    with pytest.raises(ValueError, match="whole number"):
        rec.set_audio(b"\x00\x00\x00", 44100, 2)   # not whole samples
    with pytest.raises(ValueError, match="channels"):
        rec.set_audio(b"\x00\x00", 44100, 5)
    with pytest.raises(ValueError, match="sample_rate"):
        rec.set_audio(b"\x00\x00\x00\x00", 0, 2)


def test_odd_dimensions_are_refused(tmp_path):
    with pytest.raises(ValueError, match="even"):
        necore.VideoRecorder(str(tmp_path / "i.mp4"), 321, 240, FPS)


def test_unknown_profile_is_refused(tmp_path):
    with pytest.raises(ValueError, match="profile"):
        necore.VideoRecorder(str(tmp_path / "j.mp4"), W, H, FPS, "medium")


def test_the_video_is_full_chroma(tmp_path):
    """4:4:4 is the point, not a detail: 4:2:0 cannot represent a
    one-pixel saturated line on near-black, and that is the game's
    entire visual vocabulary. It also measured FASTER than 4:2:0,
    because nothing has to subsample the chroma."""
    p = tmp_path / "k.mp4"
    rec = necore.VideoRecorder(str(p), W, H, FPS)
    for f in _frames(30):
        rec.add_frame(f)
    rec.finish()
    rows = _probe(p, "codec_name", "pix_fmt")
    assert rows and "444" in rows[0], f"expected full chroma, got {rows}"


def test_both_profiles_encode(tmp_path):
    """One pipeline, two settings. Telemetry must come out smaller than
    HQ on identical frames — that is the whole point of the split.

    The frames carry NOISE on purpose. `_frames` is a dark gradient and
    a one-pixel line, which compresses to almost nothing at any
    quantiser, so crf 18 and crf 30 landed within noise of each other
    and the comparison measured container overhead rather than the
    setting under test."""
    rng = np.random.default_rng(7)
    noisy = []
    for t in range(60):
        img = rng.integers(0, 255, (H, W, 3), dtype=np.uint8)
        img[:, (t * 3) % W] = (255, 220, 40)
        noisy.append(img.tobytes())
    sizes = {}
    for prof in ("hq", "telemetry"):
        p = tmp_path / f"{prof}.mp4"
        rec = necore.VideoRecorder(str(p), W, H, FPS, prof)
        for f in noisy:
            rec.add_frame(f)
        rec.finish()
        assert _probe(p, "nb_read_frames") == ["60"], prof
        sizes[prof] = p.stat().st_size
    assert sizes["telemetry"] < sizes["hq"], (
        f"telemetry must be the cheaper setting, got {sizes}")
