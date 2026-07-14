"""Dexed headless host — real DX7 factory voices, selected for real.

Dexed 1.0.1 (GPL) Linux VST3. The `program` parameter lists the 32
factory-cartridge voices but the engine ignores parameter-set changes
headless; the documented state XML (`<dexedState currentProgram=... >`
with the cartridge as a sysex blob) is authoritative. State nesting is
the same JUCE sandwich mapped on Odin2: outer VC2!+XML IComponent →
JUCE-base64 → inner VC2!+len+dexedState XML. We decode, edit
currentProgram (and later: swap the sysex blob for other DX7 cartridges
— the entire classic ROM library), re-encode, assign raw_state.
"""
from __future__ import annotations

import re
import struct
from functools import lru_cache
from pathlib import Path

import numpy as np

SR = 44100
S = Path("/tmp/claude-1000/-home-login-PycharmProjects-noneuclideantopdownshooter"
         "/6f0b5b45-ac47-4526-b96e-c9dc90e4fe0b/scratchpad/musicgen/dexed")
VST = S / "Dexed.vst3"
_TABLE = ".ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+"


def _jenc(data: bytes) -> bytes:
    nbits = len(data) * 8
    out = []
    for i in range((nbits + 5) // 6):
        v = 0
        for b in range(6):
            k = i * 6 + b
            if k < nbits and (data[k >> 3] >> (k & 7)) & 1:
                v |= 1 << b
        out.append(_TABLE[v])
    return (str(len(data)) + "." + "".join(out)).encode()


def _jdec(enc: str) -> bytes:
    size_s, data = enc.split(".", 1)
    size = int(size_s)
    out = bytearray(size)
    for i, ch in enumerate(data):
        v = _TABLE.index(ch)
        for b in range(6):
            k = i * 6 + b
            if k < size * 8 and (v >> b) & 1:
                out[k >> 3] |= 1 << (k & 7)
    return bytes(out)


@lru_cache(maxsize=1)
def _plugin():
    import pedalboard
    return pedalboard.load_plugin(str(VST))


def program_names():
    return list(_plugin().parameters["program"].valid_values)


def set_program(n: int):
    p = _plugin()
    outer = bytes(p.raw_state)
    m = re.search(rb"<IComponent>(.*?)</IComponent>", outer, re.S)
    inner = _jdec(m.group(1).decode())
    assert inner[:4] == b"VC2!", inner[:8]
    xml = inner[8:]
    new_xml = re.sub(rb'currentProgram="\d+"',
                     f'currentProgram="{int(n)}"'.encode(), xml, count=1)
    new_inner = b"VC2!" + struct.pack("<I", len(new_xml)) + new_xml
    enc = _jenc(new_inner)
    new_outer = outer[:m.start(1)] + enc + outer[m.end(1):]
    no = bytearray(new_outer)
    no[4:8] = struct.pack("<I", struct.unpack("<I", outer[4:8])[0]
                          + (len(new_outer) - len(outer)))
    p.raw_state = bytes(no)
    return p


def render_notes(program: int, notes, dur_s: float, velocity: int = 100,
                 tail_s: float = 0.8) -> np.ndarray:
    from mido import Message
    p = set_program(program)
    msgs = []
    for nn in notes:
        msgs.append(Message("note_on", note=int(nn), velocity=velocity,
                            time=0.0))
    for nn in notes:
        msgs.append(Message("note_off", note=int(nn), velocity=0,
                            time=dur_s))
    y = p(msgs, duration=dur_s + tail_s, sample_rate=SR)
    return y.mean(axis=0) if y.ndim == 2 else y


if __name__ == "__main__":
    import soundfile as sf
    names = program_names()
    print("factory voices:", names[:8], "...")
    a = render_notes(0, [50], 1.0)
    b = render_notes(4, [50], 1.0)
    n = min(len(a), len(b))
    d = float(np.abs(a[:n] - b[:n]).max())
    print(f"program 0 vs 4 diff: {d:.4f} "
          f"({'PRESETS SWITCH HEADLESS' if d > 1e-3 else 'STILL STUCK'})")
    if d > 1e-3:
        yn = b / (np.abs(b).max() + 1e-9)
        sf.write("out/dexed_factory_test.wav", (yn * 0.85).astype("float32"),
                 SR)
        print(f"wrote out/dexed_factory_test.wav (voice: {names[4]!r})")
