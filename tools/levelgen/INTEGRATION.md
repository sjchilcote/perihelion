# Grafting Arrival's maze into a campaign level

`arrival_maze.py` stamps the east maze of Marathon 1's "Arrival" (66 cells,
including its genuine 5D overlaps) into any `LevelBuilder`. It is
self-contained data — no Steam files needed at generation time — produced
by `tools/marathon/extract_maze.py`; regenerate there, never hand-edit.

The three-line graft (e.g. into l01/l02, owned by campaign.py):

```python
from arrival_maze import build_maze

maze = build_maze(b, origin=(2600.0, 400.0), scale=80.0)
b.connect_pts(hall, (hall_x, hall_y), maze["entry"][0], maze["entry"][1])
b.connect_pts(maze["exit"][0], maze["exit"][1], vault, (vault_x, vault_y))
```

- `origin` is any free spot on the authoring canvas; the maze covers
  ~775×900 u at `scale=80` (the canonical 1 WU → 80 u mapping). Overlap
  with existing rooms is harmless — only connects define adjacency — but
  keep ≥ 1 u of separation from walls you don't intend to weld, or the
  doorway-splitter/autoconnect may act on coincident edges.
- Graft points returned: `entry` (NW vestibule), `exit`/`exit2` (south
  doors), `north` (corridor stub), `west`/`west2`. Each is
  `(room_id, (x, y))` ready for `connect_pts`/`door_pts`. Unused ones
  simply stay walls.
- Graft edge widths: entry 66 u, exit/exit2 40 u, north/west/west2 40 u.
  The engine's `connect` maps span onto span (it scales when lengths
  differ), so a 70-80 u door welded to the 40 u exit works but plays as a
  4:3 squeeze at the threshold; author the receiving edge near the graft
  width when you care.
- Alternative used by the demo generator (`tools/marathon/make_maze_demo.py`,
  output `levels/maze_demo.json`): build the receiving room so one wall
  *exactly contains* the graft edge's two endpoints — the doorway-splitter
  plus autoconnect then weld it with no explicit connect call.
- The maze brings its own `no_connect` list (30 pairs) protecting the 5D
  crossings; do not "fix" corridors that overlap on the canvas without
  touching — that overlap is the homage (playbook §11 applies: the paradox
  is the mechanic).
- Rooms come tagged `corridor`/`transit` by degree; retag individual cells
  via `b.set_kind(maze["rooms"][marathon_index], kind)` if a level wants,
  say, the dead-end alcoves as `storage`.
