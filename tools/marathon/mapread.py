"""Classic Marathon map wadfile parser.

Reverse-engineered from hex dumps of the Steam Aleph One releases, cross-
checked against the public wadfile documentation (Aleph One `wad.h`;
marathon.bungie.org file-format notes). Everything is BIG-endian — these are
Motorola-Mac files; the Steam releases additionally arrive wrapped in a
MacBinary envelope (128-byte header, filename as a Pascal string at offset 1,
type/creator at 65/69: 'scen'/'26.2' for M1, 'sce2'/'52.4' for M2, 'sce2'/
'26.û' for Infinity).

Layout (offsets relative to the start of the data fork):

  wad header, 128 bytes:
    +0   i16  version        0 = Marathon 1, 2 = Marathon 2, 4 = Infinity
    +2   i16  data_version
    +4   c64  file_name
    +68  u32  checksum
    +72  i32  directory_offset
    +76  i16  wad_count      (= level count; one wad per level)
    +78  i16  application_specific_directory_data_size  (74 on M2/Inf maps)
    +80  i16  entry_header_size          (0 -> 12 on v0; 16 on v2/v4)
    +82  i16  directory_entry_base_size  (0 -> 8 on v0; 10 on v2/v4)
    +84  u32  parent_checksum
    +88  pad  40 bytes

  directory (at directory_offset), wad_count entries of
  directory_entry_base_size + app_size bytes each:
    v0:    {u32 offset, u32 length}
    v2/v4: {u32 offset, u32 length, i16 index} + app data; for map files the
           74-byte app data is {i16 mission_flags, i16 environment_flags,
           i32 entry_point_flags, c66 level_name}.

  each wad (level) is a chain of chunks; chunk entry header:
    v0:    {u32 tag, u32 next_offset, u32 length}            (12 bytes)
    v2/v4: {u32 tag, u32 next_offset, u32 length, u32 pad}   (16 bytes)
  next_offset is relative to the wad start; 0 terminates the chain.

Chunks parsed here (record sizes verified against chunk lengths):
    PNTS  world_point2d {i16 x, i16 y}                          4 B
    EPNT  endpoint_data — vertex world_point2d at +6             16 B (M1)
    LINS  line_data — endpoints at +0/+2, flags u16 at +4,
          owner polygons (cw, ccw) at +16/+18, -1 = none        32 B
    POLY  polygon_data — vertex_count at +6, endpoint_indexes[8]
          at +8, line_indexes[8] at +24, floor/ceiling height at
          +44/+46, adjacent_polygon_indexes[8] at +68           128 B
    OBJS  saved map_object {i16 type, index, facing, polygon,
          x, y, z, u16 flags} — type 3 = player start           16 B
    Minf  level info; level name c66 at +18 (both formats — M1's Minf is
          88 bytes like M2's, `0002 0001 0007 ...` = environment/physics/
          song, then name at +18)
    NAME  M1 only: level-name strings; redundant with Minf, unparsed

One world unit (WU) = 1024 internal units; a standard corridor/door is 1 WU.
"""

from __future__ import annotations

import struct
from dataclasses import dataclass, field
from pathlib import Path

WU = 1024  # internal units per Marathon world unit

# line flag bits (map.h)
SOLID_LINE_BIT = 0x4000
TRANSPARENT_LINE_BIT = 0x2000

# saved-object types (OBJS)
OBJ_MONSTER, OBJ_SCENERY, OBJ_ITEM, OBJ_PLAYER, OBJ_GOAL, OBJ_SOUND = range(6)

NONE = -1


@dataclass
class Line:
    e0: int
    e1: int
    flags: int
    cw_poly: int
    ccw_poly: int

    @property
    def solid(self) -> bool:
        return bool(self.flags & SOLID_LINE_BIT)

    @property
    def transparent(self) -> bool:
        return bool(self.flags & TRANSPARENT_LINE_BIT)

    @property
    def polys(self) -> tuple[int, ...]:
        return tuple(p for p in (self.cw_poly, self.ccw_poly) if p != NONE)

    @property
    def is_portal(self) -> bool:
        """Joins two polygons and is not a solid wall (walkable opening)."""
        return len(self.polys) == 2 and not self.solid


@dataclass
class Polygon:
    type: int
    flags: int
    vertex_count: int
    endpoints: list[int]      # vertex_count point indexes
    lines: list[int]          # vertex_count line indexes
    floor_height: int
    ceiling_height: int
    adjacent: list[int]       # vertex_count polygon indexes (NONE = wall)


@dataclass
class MapObject:
    type: int
    index: int
    facing: int
    polygon: int
    x: int
    y: int
    z: int
    flags: int


@dataclass
class MarathonLevel:
    index: int
    name: str
    points: list[tuple[int, int]] = field(default_factory=list)
    lines: list[Line] = field(default_factory=list)
    polygons: list[Polygon] = field(default_factory=list)
    objects: list[MapObject] = field(default_factory=list)
    chunks: dict[str, bytes] = field(default_factory=dict)

    def player_starts(self) -> list[MapObject]:
        return [o for o in self.objects if o.type == OBJ_PLAYER]

    def poly_verts(self, pi: int) -> list[tuple[int, int]]:
        p = self.polygons[pi]
        return [self.points[e] for e in p.endpoints]

    def poly_area(self, pi: int) -> float:
        """Unsigned area in internal units^2 (divide by WU*WU for WU^2)."""
        vs = self.poly_verts(pi)
        s = 0.0
        for i in range(len(vs)):
            x0, y0 = vs[i]
            x1, y1 = vs[(i + 1) % len(vs)]
            s += x0 * y1 - x1 * y0
        return abs(s) / 2.0

    def poly_centroid(self, pi: int) -> tuple[float, float]:
        vs = self.poly_verts(pi)
        return (sum(v[0] for v in vs) / len(vs),
                sum(v[1] for v in vs) / len(vs))

    def poly_degree(self, pi: int) -> int:
        """Number of walkable portal edges of polygon `pi`."""
        return sum(1 for li in self.polygons[pi].lines
                   if self.lines[li].is_portal)


# ---------------------------------------------------------------------------
# container layers
# ---------------------------------------------------------------------------


def strip_macbinary(buf: bytes) -> bytes:
    """Return the data fork if `buf` is a MacBinary envelope, else `buf`.

    MacBinary: byte 0 == 0, byte 1 = filename length 1..63, data-fork length
    is the u32 at +83. (The Steam maps all match; a bare wad file starts with
    a version i16 whose high byte is 0 *and* byte 1 is 0, failing the name-
    length test only for wads literally named with control characters —
    acceptable.)
    """
    if len(buf) < 128 or buf[0] != 0:
        return buf
    name_len = buf[1]
    if not (1 <= name_len <= 63):
        return buf
    (data_len,) = struct.unpack_from(">I", buf, 83)
    if 128 + data_len > len(buf):
        return buf
    return buf[128:128 + data_len]


@dataclass
class WadHeader:
    version: int
    data_version: int
    file_name: str
    checksum: int
    directory_offset: int
    wad_count: int
    app_data_size: int
    entry_header_size: int
    dir_entry_size: int

    @classmethod
    def parse(cls, buf: bytes) -> "WadHeader":
        (version, data_version, raw_name, checksum, dir_off, wad_count,
         app_size, entry_hdr, dir_entry) = struct.unpack_from(
            ">hh64sIihhhh", buf, 0)
        if version not in (0, 1, 2, 4):
            raise ValueError(f"not a Marathon wadfile (version={version})")
        # v0 files leave the size fields zero; defaults are implied
        if entry_hdr == 0:
            entry_hdr = 12 if version < 2 else 16
        if dir_entry == 0:
            dir_entry = 8 if version < 2 else 10
        return cls(
            version=version,
            data_version=data_version,
            file_name=raw_name.split(b"\0", 1)[0].decode("mac_roman"),
            checksum=checksum,
            directory_offset=dir_off,
            wad_count=wad_count,
            app_data_size=app_size,
            entry_header_size=entry_hdr,
            dir_entry_size=dir_entry,
        )


@dataclass
class DirEntry:
    index: int
    offset: int
    length: int
    name: str  # from app-specific data (v2/v4 map files); "" on v0
    entry_point_flags: int = 0  # v2/v4: bit 0 solo, 1 co-op, 2 carnage...


def read_directory(buf: bytes, hdr: WadHeader) -> list[DirEntry]:
    entries = []
    stride = hdr.dir_entry_size + hdr.app_data_size
    for i in range(hdr.wad_count):
        base = hdr.directory_offset + i * stride
        offset, length = struct.unpack_from(">II", buf, base)
        index = i
        name = ""
        entry_flags = 0
        if hdr.dir_entry_size >= 10:
            (index,) = struct.unpack_from(">h", buf, base + 8)
        if hdr.app_data_size >= 74:
            # app data: {i16 mission_flags, i16 environment_flags,
            #            i32 entry_point_flags, c66 level_name}
            (entry_flags,) = struct.unpack_from(
                ">i", buf, base + hdr.dir_entry_size + 4)
            raw = buf[base + hdr.dir_entry_size + 8:
                      base + hdr.dir_entry_size + 74]
            name = raw.split(b"\0", 1)[0].decode("mac_roman")
        entries.append(DirEntry(index, offset, length, name, entry_flags))
    return entries


def read_chunks(buf: bytes, entry: DirEntry, hdr: WadHeader) -> dict[str, bytes]:
    """Walk one wad's chunk chain -> {tag: data}."""
    chunks: dict[str, bytes] = {}
    pos = 0
    wad = buf[entry.offset:entry.offset + entry.length]
    while True:
        tag_raw, next_off, length = struct.unpack_from(">4sII", wad, pos)
        tag = tag_raw.decode("mac_roman")
        data_start = pos + hdr.entry_header_size
        chunks[tag] = bytes(wad[data_start:data_start + length])
        if next_off == 0:
            break
        if next_off <= pos or next_off >= len(wad):
            raise ValueError(f"bad chunk chain at {pos} -> {next_off}")
        pos = next_off
    return chunks


# ---------------------------------------------------------------------------
# chunk decoders
# ---------------------------------------------------------------------------


def _decode_points(chunks: dict[str, bytes]) -> list[tuple[int, int]]:
    if "PNTS" in chunks:
        d = chunks["PNTS"]
        n = len(d) // 4
        return [struct.unpack_from(">hh", d, i * 4) for i in range(n)]
    if "EPNT" in chunks:  # M1: full endpoint_data records, vertex at +6
        d = chunks["EPNT"]
        n = len(d) // 16
        return [struct.unpack_from(">hh", d, i * 16 + 6) for i in range(n)]
    return []


def _decode_lines(chunks: dict[str, bytes]) -> list[Line]:
    d = chunks.get("LINS", b"")
    out = []
    for i in range(len(d) // 32):
        e0, e1, flags = struct.unpack_from(">hhH", d, i * 32)
        cw_poly, ccw_poly = struct.unpack_from(">hh", d, i * 32 + 16)
        out.append(Line(e0, e1, flags, cw_poly, ccw_poly))
    return out


def _decode_polygons(chunks: dict[str, bytes]) -> list[Polygon]:
    d = chunks.get("POLY", b"")
    out = []
    for i in range(len(d) // 128):
        b = i * 128
        ptype, flags, _perm, vc = struct.unpack_from(">hHhh", d, b)
        endpoints = list(struct.unpack_from(">8h", d, b + 8))
        lines = list(struct.unpack_from(">8h", d, b + 24))
        floor_h, ceil_h = struct.unpack_from(">hh", d, b + 44)
        adjacent = list(struct.unpack_from(">8h", d, b + 68))
        vc = max(0, min(8, vc))
        out.append(Polygon(
            type=ptype, flags=flags, vertex_count=vc,
            endpoints=endpoints[:vc], lines=lines[:vc],
            floor_height=floor_h, ceiling_height=ceil_h,
            adjacent=adjacent[:vc]))
    return out


def _decode_objects(chunks: dict[str, bytes]) -> list[MapObject]:
    d = chunks.get("OBJS", b"")
    out = []
    for i in range(len(d) // 16):
        typ, idx, facing, poly, x, y, z, flags = struct.unpack_from(
            ">hhhhhhhH", d, i * 16)
        out.append(MapObject(typ, idx, facing, poly, x, y, z, flags))
    return out


def _decode_name(chunks: dict[str, bytes]) -> str:
    # Both M1 and M2/Inf carry the level name at +18 of Minf (c66).
    d = chunks.get("Minf", b"")
    if len(d) >= 84:
        return d[18:84].split(b"\0", 1)[0].decode("mac_roman")
    return ""


# ---------------------------------------------------------------------------
# top level
# ---------------------------------------------------------------------------


class MapFile:
    def __init__(self, path: str | Path):
        self.path = Path(path)
        self.buf = strip_macbinary(self.path.read_bytes())
        self.header = WadHeader.parse(self.buf)
        self.directory = read_directory(self.buf, self.header)

    def __len__(self) -> int:
        return len(self.directory)

    def level(self, i: int) -> MarathonLevel:
        entry = self.directory[i]
        chunks = read_chunks(self.buf, entry, self.header)
        name = entry.name or _decode_name(chunks)
        lvl = MarathonLevel(index=i, name=name, chunks=chunks)
        lvl.points = _decode_points(chunks)
        lvl.lines = _decode_lines(chunks)
        lvl.polygons = _decode_polygons(chunks)
        lvl.objects = _decode_objects(chunks)
        _validate(lvl)
        return lvl

    def levels(self):
        for i in range(len(self.directory)):
            yield self.level(i)

    def solo_indices(self) -> list[int]:
        """Indices of single-player levels. v2/v4 map files say so in the
        directory (entry_point_flags bit 0); M1 (v0) has no such flag —
        there, solo levels are exactly the ones with a single player start
        (net levels carry 8-14 starts), verified against the known list of
        27 M1 solo levels."""
        if self.header.version >= 2:
            return [i for i, e in enumerate(self.directory)
                    if e.entry_point_flags & 1]
        return [i for i in range(len(self.directory))
                if len(self.level(i).player_starts()) == 1]


def _validate(lvl: MarathonLevel) -> None:
    np, nl, npoly = len(lvl.points), len(lvl.lines), len(lvl.polygons)
    for li, ln in enumerate(lvl.lines):
        if not (0 <= ln.e0 < np and 0 <= ln.e1 < np):
            raise ValueError(f"{lvl.name}: line {li} endpoint out of range")
    for pi, p in enumerate(lvl.polygons):
        if not (3 <= p.vertex_count <= 8):
            raise ValueError(f"{lvl.name}: poly {pi} vertex_count {p.vertex_count}")
        for e in p.endpoints:
            if not (0 <= e < np):
                raise ValueError(f"{lvl.name}: poly {pi} endpoint {e} out of range")
        for l in p.lines:
            if not (0 <= l < nl):
                raise ValueError(f"{lvl.name}: poly {pi} line {l} out of range")
        for a in p.adjacent:
            if a != NONE and not (0 <= a < npoly):
                raise ValueError(f"{lvl.name}: poly {pi} adjacency {a} out of range")


STEAM = Path("~/.steam/steam/steamapps/common").expanduser()
GAMES = {
    "m1": STEAM / "Classic Marathon" / "Map.scen",
    "m2": STEAM / "Classic Marathon 2" / "Map.sceA",
    "inf": STEAM / "Classic Marathon Infinity" / "Map.sceA",
}


if __name__ == "__main__":
    for key, path in GAMES.items():
        if not path.exists():
            print(f"{key}: MISSING {path}")
            continue
        mf = MapFile(path)
        h = mf.header
        print(f"{key}: wad v{h.version} data v{h.data_version} "
              f"levels={h.wad_count} dir@{h.directory_offset:#x}")
        for i, e in enumerate(mf.directory):
            lvl = mf.level(i)
            starts = len(lvl.player_starts())
            print(f"  [{i:2d}] {lvl.name!r:44s} polys={len(lvl.polygons):4d} "
                  f"lines={len(lvl.lines):4d} pts={len(lvl.points):4d} "
                  f"starts={starts} chunks={','.join(lvl.chunks)}")
