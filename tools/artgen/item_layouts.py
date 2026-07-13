"""tools/artgen/item_layouts.py

Per-room ITEM LAYOUT data for the labeled-box conditioning workstream
(director's order, 2026-07-13, workstream 1): where specific pieces of
equipment belong inside a room, derived from the room's floorplan role
(FLOORPLANS.md) and the Testator-vs-MIRIAD authorship lanes
(authorship-lanes constitution).

This is DATA, not per-room hand authoring: a per-kind template of labeled
zones (fractional boxes in the room's own bounding box, 0..1 on each axis,
same convention as pilot_texture_lib's room-local pixel frame) captures the
floorplan role described in FLOORPLANS.md/FLOORPLAN_NOTE, and
`room_item_layout()` instantiates it for a specific room. Zones are
axis-aligned fractions of the room's BOUNDING BOX (not the polygon itself)
-- exactly matching the frame `pilot_texture_lib.room_mask`/`_room_xform`
already establish, so box pixel coordinates fall out of the same transform
every other stage in the pipeline uses (no separate room-space convention
to keep in sync).

Every item carries a `lane` (MIRIAD or TESTATOR, per authorship-lanes) so
box-conditioned generation and the decal/marking pass can respect the
constitution: TESTATOR-pure kinds (chapel, otherworld) get zero MIRIAD
stencil/signage language even on their item boxes; `core` is the one
kind that legitimately mixes both lanes (Testator reactor architecture
with grafted MIRIAD server housings, per TESTATOR_DESIGN_LANGUAGE.md).
"""
from __future__ import annotations

import json
from pathlib import Path

from tools.artgen.pilot_texture_lib import TESTATOR_KINDS

# Each entry: (label, (x0, y0, x1, y1) fractional box in room bbox, lane,
# one-line justification -- the in-world reason this item sits there,
# distilled from FLOORPLANS.md's per-kind floorplan rationale).
KIND_ITEM_TEMPLATE: dict[str, list[tuple[str, tuple[float, float, float, float], str, str]]] = {
    "dock": [
        ("CRATE STACK", (0.02, 0.02, 0.24, 0.24), "MIRIAD",
         "cargo stacked in the corner farthest from the door threshold, out of the tow lane"),
        ("CRATE STACK", (0.76, 0.02, 0.98, 0.24), "MIRIAD",
         "second cargo stack in the other far corner, mirroring the first"),
        ("HAZARD LANE", (0.0, 0.86, 1.0, 1.0), "MIRIAD",
         "loader's working lane painted along the mooring wall"),
        ("MOORING RING WALL", (0.0, 0.0, 0.06, 1.0), "MIRIAD",
         "tow point the walk lane from the doorway actually leads to"),
    ],
    "corridor": [
        ("PIPE RUN", (0.0, 0.0, 1.0, 0.10), "MIRIAD",
         "utility piping hugs the wall out of the walk lane"),
        ("PIPE RUN", (0.0, 0.90, 1.0, 1.0), "MIRIAD",
         "matching pipe run on the opposite wall"),
        ("VENT GRATE", (0.44, 0.02, 0.56, 0.10), "MIRIAD",
         "ventilation tie-in along the through-corridor's service run"),
    ],
    "storage": [
        ("CRATE ROW", (0.05, 0.06, 0.32, 0.92), "MIRIAD",
         "stockroom row, aisle-perpendicular so a cart can push straight through"),
        ("CRATE ROW", (0.68, 0.06, 0.95, 0.92), "MIRIAD",
         "second stockroom row mirroring the first, aisle between them"),
        ("SHELF LINE", (0.0, 0.0, 1.0, 0.05), "MIRIAD",
         "wall shelving out of the cart aisle"),
    ],
    "hydro": [
        ("WALL TROUGH", (0.0, 0.0, 1.0, 0.16), "MIRIAD",
         "wall-mounted growing-bed row, condensation/overflow stains radiate from here"),
        ("WALL TROUGH", (0.0, 0.84, 1.0, 1.0), "MIRIAD",
         "second wall-mounted growing-bed row on the opposite wall"),
        ("CENTER TROUGH", (0.36, 0.36, 0.64, 0.64), "MIRIAD",
         "single island bed offset from room center, its own stain halo"),
    ],
    "lab": [
        ("SPECIMEN TABLE", (0.34, 0.52, 0.66, 0.84), "MIRIAD",
         "the room's workstation, offset from center; chemical staining concentrates here"),
        ("SCREEN ARRAY", (0.18, 0.0, 0.82, 0.08), "MIRIAD",
         "wall-mounted monitoring bank feeding the specimen table"),
    ],
    "quarters": [
        ("COT BAY", (0.0, 0.0, 0.22, 1.0), "MIRIAD",
         "personal bunk ringing the wall, wear concentrates at its foot"),
        ("COT BAY", (0.78, 0.0, 1.0, 1.0), "MIRIAD",
         "second bunk on the opposite wall"),
        ("COT BAY", (0.0, 0.0, 1.0, 0.18), "MIRIAD",
         "third bunk along the near wall, open floor shared in the middle"),
    ],
    "chapel": [
        ("PEW ROW", (0.15, 0.20, 0.85, 0.74), "TESTATOR",
         "pews face the dais; the aisle down the center is where bodies moved"),
        ("DAIS", (0.30, 0.78, 0.70, 1.0), "TESTATOR",
         "ceremonial front, old dark ritual staining follows the approach path"),
    ],
    "core": [
        ("CONSOLE RING", (0.14, 0.14, 0.86, 0.86), "TESTATOR",
         "radial console ring around the dark heart, Testator reactor architecture"),
        ("SERVER HOUSING", (0.03, 0.40, 0.24, 0.60), "MIRIAD",
         "MIRIAD server intrusion grafted onto the corrupted core, per l07/l10 canon"),
        ("SERVER HOUSING", (0.76, 0.40, 0.97, 0.60), "MIRIAD",
         "matching server housing flanking the other side of the ring"),
    ],
    "medbay": [
        ("CABINET ROW", (0.0, 0.0, 1.0, 0.12), "MIRIAD",
         "clinical cabinet wall, strictly man-made hospital fixtures"),
        ("EXAM TABLE", (0.38, 0.40, 0.62, 0.70), "MIRIAD",
         "exam/treatment table, disinfectant stains gone dull around it"),
    ],
    "records": [
        ("ARCHIVE SHELVING", (0.0, 0.0, 0.18, 1.0), "MIRIAD",
         "static-dissipative archive stacks along one wall"),
        ("ARCHIVE SHELVING", (0.82, 0.0, 1.0, 1.0), "MIRIAD",
         "matching archive stacks along the opposite wall"),
    ],
    "transit": [
        ("LIFT PAD", (0.32, 0.32, 0.68, 0.68), "MIRIAD",
         "the transit hub's actual lift/junction platform, wear radiates outward from it"),
    ],
    "pump": [
        ("PUMP HOUSING", (0.36, 0.36, 0.64, 0.64), "MIRIAD",
         "wet-service pump housing, mineral staining/condensation radiate from it"),
    ],
    "otherworld": [
        ("GROWTH CLUSTER", (0.22, 0.22, 0.78, 0.78), "TESTATOR",
         "native Testator growth mass -- non-Euclidean, no MIRIAD material anywhere near it"),
    ],
    "generic": [],
}


def room_item_layout(kind: str) -> list[dict]:
    """Instantiate the per-kind item template as a list of
    {label, zone, lane, justification} dicts. `zone` is (x0,y0,x1,y1)
    fractions of the room's bounding box. Pure data lookup -- no network,
    no geometry (callers convert zone -> pixels via the room's own
    _room_xform/room_mask bbox)."""
    out = []
    for label, zone, lane, justification in KIND_ITEM_TEMPLATE.get(kind, []):
        out.append(dict(label=label, zone=zone, lane=lane, justification=justification))
    return out


def zone_to_px(zone: tuple[float, float, float, float], w_px: int, h_px: int
               ) -> tuple[int, int, int, int]:
    """Fractional (x0,y0,x1,y1) -> pixel-space (x0,y0,x1,y1) box for an
    image of size (w_px, h_px)."""
    x0, y0, x1, y1 = zone
    return (int(round(x0 * w_px)), int(round(y0 * h_px)),
            int(round(x1 * w_px)), int(round(y1 * h_px)))


def validate_lanes() -> list[str]:
    """Sanity check: TESTATOR-pure kinds (per pilot_texture_lib.TESTATOR_KINDS)
    must never carry a MIRIAD item, EXCEPT `core`, which is the documented
    mixed-lane exception (Testator architecture + grafted MIRIAD server
    housings). Returns a list of violation strings (empty = clean)."""
    problems = []
    for kind, items in KIND_ITEM_TEMPLATE.items():
        if kind not in TESTATOR_KINDS or kind == "core":
            continue
        for label, _zone, lane, _j in items:
            if lane != "TESTATOR":
                problems.append(f"{kind}/{label}: lane={lane}, expected TESTATOR (pure Testator kind)")
    return problems


def dump_all_kinds(out_path: Path | None = None) -> dict:
    """Write the full KIND_ITEM_TEMPLATE as JSON (for the manifest / review)."""
    data = {kind: room_item_layout(kind) for kind in KIND_ITEM_TEMPLATE}
    if out_path is not None:
        out_path.write_text(json.dumps(data, indent=2))
    return data


if __name__ == "__main__":
    problems = validate_lanes()
    if problems:
        raise SystemExit("lane violations:\n" + "\n".join(problems))
    print("lane check clean; kinds:", list(KIND_ITEM_TEMPLATE.keys()))
