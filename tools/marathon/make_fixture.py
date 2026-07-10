"""Extract a small test fixture from the M1 map: the net level "5-D space"
(50 polygons, and — fittingly — the level named for the overlapping-space
trick), keeping only the chunks the parser reads. Output is a valid
version-0 wadfile, no MacBinary wrapper, ~14 KB.

    uv run python tools/marathon/make_fixture.py
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from mapread import GAMES, MapFile, read_chunks  # noqa: E402

OUT = REPO / "game" / "tests" / "fixtures" / "m1_5dspace.wad"
LEVEL = 29  # '5-D space'
KEEP = ("EPNT", "LINS", "POLY", "OBJS", "Minf")


def main() -> None:
    mf = MapFile(GAMES["m1"])
    entry = mf.directory[LEVEL]
    chunks = read_chunks(mf.buf, entry, mf.header)

    wad = bytearray()
    kept = [(tag, chunks[tag]) for tag in KEEP if tag in chunks]
    for i, (tag, data) in enumerate(kept):
        next_off = 0 if i == len(kept) - 1 else len(wad) + 12 + len(data)
        wad += struct.pack(">4sII", tag.encode("mac_roman"), next_off,
                           len(data))
        wad += data

    header = struct.pack(
        ">hh64sIihhhhI40s",
        0, 0,                       # version 0, data_version 0
        b"5-D space fixture",       # file_name
        0,                          # checksum (unchecked by the parser)
        128 + len(wad),             # directory_offset
        1,                          # wad_count
        0, 0, 0,                    # app data / entry hdr / dir entry sizes
        0,                          # parent checksum
        b"",
    )
    directory = struct.pack(">II", 128, len(wad))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_bytes(header + wad + directory)
    print(f"{OUT}: {OUT.stat().st_size} bytes, chunks {[t for t, _ in kept]}")


if __name__ == "__main__":
    main()
