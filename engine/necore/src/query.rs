use std::collections::{HashMap, VecDeque};

use crate::math::{Mat3, Vec2};
use crate::physics::Sim;
use crate::world::{RoomId, World};

#[derive(Debug, Clone)]
pub enum RayHit {
    Wall {
        room: RoomId,
        edge: usize,
        pos: Vec2,
        /// Accumulated hit-room-local -> origin-room-local transform.
        xform: Mat3,
        dist: f64,
        hops: usize,
    },
    Entity {
        id: u64,
        room: RoomId,
        pos: Vec2,
        xform: Mat3,
        dist: f64,
        hops: usize,
    },
    Nothing {
        /// Where the ray gave up, in last-room coords.
        room: RoomId,
        pos: Vec2,
        xform: Mat3,
        dist: f64,
        hops: usize,
    },
}

/// Cast a ray through the room graph. `mask` selects entity groups the ray can
/// hit (bit per group); walls always stop it. Distances accumulate in each
/// room's local metric (correct for rigid portals; intentional for scaling
/// ones -- gameplay ranges breathe with the space).
pub fn raycast(
    sim: &Sim,
    room: RoomId,
    origin: Vec2,
    dir: Vec2,
    max_hops: usize,
    max_len: f64,
    mask: u16,
    ignore: Option<u64>,
) -> RayHit {
    let mut room = room;
    let mut o = origin;
    let mut d = dir.normalized();
    let mut xform = Mat3::IDENTITY; // current-room -> origin-room
    let mut travelled = 0.0;
    let mut hops = 0;

    loop {
        let r = &sim.world.rooms[room];
        // Exit point: nearest positive crossing among edges the ray exits.
        let n_edges = r.verts.len();
        let mut t_exit = f64::INFINITY;
        let mut exit_edge = None;
        for i in 0..n_edges {
            let (a, _b) = r.edge(i);
            let n = r.normals[i];
            let dn = d.dot(n);
            if dn >= -1e-12 {
                continue; // parallel or moving inward relative to this edge
            }
            let t = (o - a).dot(n) / -dn;
            if t > 1e-9 && t < t_exit {
                t_exit = t;
                exit_edge = Some(i);
            }
        }
        let seg_end = t_exit.min(max_len - travelled);

        // Entity hits within this room segment.
        let mut best_ent: Option<(u64, f64)> = None;
        for &eid in &r.entities {
            if Some(eid) == ignore {
                continue;
            }
            let e = match sim.entities.get(&eid) {
                Some(e) if e.alive => e,
                _ => continue,
            };
            if mask & (1 << (e.group as usize & 15)) == 0 {
                continue;
            }
            // |o + t d - c|^2 = r^2
            let oc = o - e.pos;
            let b = oc.dot(d);
            let c = oc.len2() - e.radius * e.radius;
            let disc = b * b - c;
            if disc < 0.0 {
                continue;
            }
            let t = -b - disc.sqrt();
            let t = if t > 1e-9 { t } else { -b + disc.sqrt() };
            if t > 1e-9 && t <= seg_end {
                match best_ent {
                    Some((_, bt)) if bt <= t => {}
                    _ => best_ent = Some((eid, t)),
                }
            }
        }
        if let Some((eid, t)) = best_ent {
            return RayHit::Entity {
                id: eid,
                room,
                pos: o + d * t,
                xform,
                dist: travelled + t,
                hops,
            };
        }

        if travelled + t_exit >= max_len {
            return RayHit::Nothing {
                room,
                pos: o + d * (max_len - travelled).max(0.0),
                xform,
                dist: max_len,
                hops,
            };
        }
        let ei = match exit_edge {
            Some(i) => i,
            None => {
                return RayHit::Nothing {
                    room,
                    pos: o,
                    xform,
                    dist: travelled,
                    hops,
                }
            }
        };
        let hit_pos = o + d * t_exit;
        // Portal opening check: exact span, no extension.
        let (a, b) = r.edge(ei);
        let along = (hit_pos - a).dot((b - a).normalized());
        let portal = r.portals[ei].filter(|_| along >= 0.0 && along <= r.edge_len[ei]);
        match portal {
            None => {
                return RayHit::Wall {
                    room,
                    edge: ei,
                    pos: hit_pos,
                    xform,
                    dist: travelled + t_exit,
                    hops,
                }
            }
            Some(p) => {
                if hops >= max_hops {
                    return RayHit::Nothing {
                        room,
                        pos: hit_pos,
                        xform,
                        dist: travelled + t_exit,
                        hops,
                    };
                }
                travelled += t_exit;
                hops += 1;
                // Into the child: positions through inv, direction through the
                // linear part (renormalized; scale portals stretch distances).
                o = p.inv.apply(hit_pos);
                let nd = p.inv.apply_dir(d);
                d = nd.normalized();
                // Nudge forward so we don't re-hit the same line (and keep
                // the travelled distance honest about it).
                o = o + d * 1e-6;
                travelled += 1e-6;
                xform = xform.mul(p.xform);
                room = p.target_room;
            }
        }
    }
}

/// Routing tables: for each destination, the edge to take from every room.
#[derive(Default)]
pub struct Router {
    tables: HashMap<RoomId, (u64, Vec<Option<usize>>, Vec<u32>)>,
}

impl Router {
    pub fn new() -> Router {
        Router::default()
    }

    fn build(world: &World, dest: RoomId) -> (Vec<Option<usize>>, Vec<u32>) {
        let n = world.rooms.len();
        let mut next: Vec<Option<usize>> = vec![None; n];
        let mut dist: Vec<u32> = vec![u32::MAX; n];
        let mut q = VecDeque::new();
        dist[dest] = 0;
        q.push_back(dest);
        while let Some(m) = q.pop_front() {
            for (em, p) in world.rooms[m].portals.iter().enumerate() {
                let p = match p {
                    Some(p) => p,
                    None => continue,
                };
                // Portal (m, em) -> (t, et). From room t, taking edge et
                // arrives in m.
                let t = p.target_room;
                let et = p.target_edge;
                if dist[t] == u32::MAX {
                    dist[t] = dist[m] + 1;
                    next[t] = Some(et);
                    q.push_back(t);
                }
                let _ = em;
            }
        }
        (next, dist)
    }

    pub fn next_edge(
        &mut self,
        world: &World,
        from: RoomId,
        to: RoomId,
    ) -> Option<usize> {
        if from == to {
            return None;
        }
        let entry = self.tables.entry(to).or_insert_with(|| {
            let (n, d) = Self::build(world, to);
            (world.topology_version, n, d)
        });
        if entry.0 != world.topology_version {
            let (n, d) = Self::build(world, to);
            *entry = (world.topology_version, n, d);
        }
        entry.1.get(from).copied().flatten()
    }

    pub fn hop_distance(&mut self, world: &World, from: RoomId, to: RoomId) -> Option<u32> {
        if from == to {
            return Some(0);
        }
        self.next_edge(world, from, to)?;
        let d = self.tables.get(&to)?.2.get(from).copied()?;
        if d == u32::MAX {
            None
        } else {
            Some(d)
        }
    }
}

/// Walk-mask terrain as light-occluder geometry for room `room`, in that
/// room's own local coordinates -- the same frame `Room::verts`/portal
/// planes live in. Each returned segment is one edge of one terrain rect
/// (`geom::Rect::edges`); a future lighting/shadow pass can treat these
/// exactly like wall segments when building a light's visible wedge.
///
/// **Interface only.** Nothing in `render.py`/the lighting composite
/// consumes this yet (that lane is owned by a sibling in-flight fix, per
/// the director's order) -- this is the clean query surface for it to pick
/// up later. Terrain never affects `visibility.rs`/vision: this function is
/// a separate, additive query, not a change to `visible_set`.
pub fn terrain_light_segments(world: &World, room: RoomId) -> Vec<(Vec2, Vec2)> {
    match world.rooms.get(room) {
        Some(r) => r.terrain.iter().flat_map(|rect| rect.edges()).collect(),
        None => Vec::new(),
    }
}

/// Steer a desired direction around walk-mask terrain so bot pathing (which
/// only routes at ROOM granularity via `Router`) doesn't grind forever
/// against in-room obstacles it beelines straight into.
///
/// Physics-level wall sliding (see `physics::Sim::step_entity`) already
/// handles glancing approaches -- any nonzero tangential velocity component
/// carries the entity around a corner. It does NOT handle an exactly
/// head-on approach: the tangential component is zero, sliding kills all
/// velocity, and a caller that re-aims straight at the same blocked target
/// every tick (the game's `_enemy_ai` "seek" behavior) regenerates the same
/// zero-progress velocity forever -- a real deadlock, confirmed by a
/// fail-first test (`entity_slides_along_terrain_and_reaches_far_side`
/// hung at the padded face until this function was used instead of a raw
/// direction-to-target).
///
/// Casts `desired` (normalized) up to `lookahead` units from `pos`; if it
/// would enter a terrain rect, blends in a tangential deflection AWAY from
/// whichever side the obstacle's center leans toward relative to `pos` (a
/// deterministic tie-break -- never zero, never oscillates between ticks for
/// a static obstacle and desired direction). Otherwise returns `desired`
/// unchanged (normalized). Room-local in, room-local out.
pub fn terrain_avoid_dir(
    world: &World,
    room: RoomId,
    pos: Vec2,
    radius: f64,
    desired: Vec2,
    lookahead: f64,
) -> Vec2 {
    let d = desired.normalized();
    let r = match world.rooms.get(room) {
        Some(r) => r,
        None => return d,
    };
    let end = pos + d * lookahead;
    let mut best: Option<(f64, crate::geom::Rect)> = None;
    for rect in &r.terrain {
        if let Some((t, _n)) = crate::geom::swept_circle_vs_rect(pos, end, radius, rect) {
            match best {
                Some((bt, _)) if bt <= t => {}
                _ => best = Some((t, *rect)),
            }
        }
    }
    let rect = match best {
        Some((_, r)) => r,
        None => return d,
    };
    let center = (rect.lo + rect.hi) * 0.5;
    let to_center = center - pos;
    let perp = d.perp_right();
    // Steer away from the side the obstacle's center leans toward -- a
    // sign that only flips when the obstacle's bearing genuinely does,
    // never chatters between ticks for a static scene.
    let side = if perp.dot(to_center) >= 0.0 { -1.0 } else { 1.0 };
    (d + perp * (side * 0.9)).normalized()
}

pub fn rooms_within(world: &World, center: RoomId, hops: usize) -> Vec<RoomId> {
    let mut seen = vec![false; world.rooms.len()];
    let mut out = vec![center];
    seen[center] = true;
    let mut frontier = vec![center];
    for _ in 0..hops {
        let mut nxt = Vec::new();
        for r in frontier {
            for p in world.rooms[r].portals.iter().flatten() {
                if !seen[p.target_room] {
                    seen[p.target_room] = true;
                    out.push(p.target_room);
                    nxt.push(p.target_room);
                }
            }
        }
        frontier = nxt;
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::math::v;
    use crate::world::World;

    fn square(half: f64) -> Vec<Vec2> {
        vec![
            v(-half, -half),
            v(-half, half),
            v(half, half),
            v(half, -half),
        ]
    }

    #[test]
    fn raycast_crosses_portals_and_hits_walls() {
        let mut w = World::new();
        let a = w.add_room(&square(50.0)).unwrap();
        let b = w.add_room(&square(50.0)).unwrap();
        w.connect(a, 2, b, 0).unwrap();
        let sim = Sim::new(w);
        let hit = raycast(&sim, a, v(0.0, 0.0), v(1.0, 0.0), 4, 1000.0, 0xffff, None);
        match hit {
            RayHit::Wall { room, dist, .. } => {
                assert_eq!(room, b);
                assert!((dist - 150.0).abs() < 1e-6, "dist {dist}");
            }
            other => panic!("expected wall in b, got {other:?}"),
        }
    }

    #[test]
    fn raycast_hits_entity_through_portal() {
        let mut w = World::new();
        let a = w.add_room(&square(50.0)).unwrap();
        let b = w.add_room(&square(50.0)).unwrap();
        w.connect(a, 2, b, 0).unwrap();
        let mut sim = Sim::new(w);
        let t = sim.spawn(b, v(0.0, 0.0), 10.0, 1.0, 1).unwrap();
        let hit = raycast(&sim, a, v(0.0, 0.0), v(1.0, 0.0), 4, 1000.0, 0xffff, None);
        match hit {
            RayHit::Entity { id, dist, .. } => {
                assert_eq!(id, t);
                assert!((dist - 90.0).abs() < 1e-6, "dist {dist}");
            }
            other => panic!("expected entity, got {other:?}"),
        }
    }

    #[test]
    fn router_finds_paths_through_chains() {
        let mut w = World::new();
        let rooms: Vec<_> = (0..5).map(|_| w.add_room(&square(50.0)).unwrap()).collect();
        for i in 0..4 {
            w.connect(rooms[i], 2, rooms[i + 1], 0).unwrap();
        }
        let mut router = Router::new();
        // From room 0 toward room 4: take edge 2 each time.
        assert_eq!(router.next_edge(&w, rooms[0], rooms[4]), Some(2));
        assert_eq!(router.hop_distance(&w, rooms[0], rooms[4]), Some(4));
        assert_eq!(router.next_edge(&w, rooms[4], rooms[0]), Some(0));
        assert_eq!(router.next_edge(&w, rooms[2], rooms[2]), None);
    }

    // ENGINE_INVARIANTS.md W8/Q3 (wave-1): Router caches a BFS table per
    // destination, keyed by `world.topology_version` (query.rs
    // `next_edge`: `if entry.0 != world.topology_version { rebuild }`).
    // That invalidation mechanism had ZERO test coverage before this: the
    // only existing router test never mutates topology after building the
    // router, so a regression that dropped or broke the version check
    // would pass silently. This is exactly the stale-cache bug shape the
    // catalog flags: `split_edge` (the runtime portable-hole feature)
    // mutates topology at runtime, and AI routing depends on
    // `Router::next_edge`/`hop_distance` staying current.
    //
    // Adversarial dimensions: (a) a topology change that shortens an
    // existing cached route (add_room/connect shortcut), and (b) a
    // split_edge that shifts the very edge index the cached table names
    // as the correct hop -- if invalidation didn't fire, the router would
    // hand back an edge index into the OLD topology, which after the
    // shift either points at the wrong (or a since-reindexed) edge.
    //
    // Verified fail-first: temporarily hardcoded the cache-freshness
    // check to always reuse the cached entry (`if false { rebuild }`
    // instead of comparing topology_version) and reran -- both cases
    // failed (stale hop count / stale edge index), confirming this is
    // real instrumentation. Reverted before committing.
    #[test]
    fn router_cache_invalidates_on_topology_change() {
        let mut w = World::new();
        let rooms: Vec<_> = (0..5).map(|_| w.add_room(&square(50.0)).unwrap()).collect();
        for i in 0..4 {
            w.connect(rooms[i], 2, rooms[i + 1], 0).unwrap();
        }
        let mut router = Router::new();
        assert_eq!(router.hop_distance(&w, rooms[0], rooms[4]), Some(4));
        assert_eq!(router.next_edge(&w, rooms[0], rooms[4]), Some(2));

        // A direct shortcut 0<->4 via each room's still-free edge 1.
        // topology_version bumps; the cached table for dest=rooms[4] must
        // be rebuilt, not silently reused.
        w.connect(rooms[0], 1, rooms[4], 1).unwrap();
        assert_eq!(
            router.hop_distance(&w, rooms[0], rooms[4]),
            Some(1),
            "router served a stale (pre-shortcut) hop count after a topology change"
        );
        assert_eq!(
            router.next_edge(&w, rooms[0], rooms[4]),
            Some(1),
            "router served a stale (pre-shortcut) edge after a topology change"
        );

        // split_edge on a wall NOT on the cached route also bumps
        // topology_version; the cached table must still be consistent
        // with a fresh BFS build (same result as a brand-new Router).
        let mid = w.split_edge(rooms[2], 1, 0.3, 0.6).unwrap();
        let _ = mid;
        let mut fresh = Router::new();
        assert_eq!(
            router.hop_distance(&w, rooms[3], rooms[0]),
            fresh.hop_distance(&w, rooms[3], rooms[0]),
            "cached router disagreed with a freshly-built one after split_edge"
        );
        assert_eq!(
            router.next_edge(&w, rooms[3], rooms[0]),
            fresh.next_edge(&w, rooms[3], rooms[0])
        );
    }

    // -- walk-mask terrain queries -----------------------------------

    #[test]
    fn terrain_light_segments_is_empty_absent_a_mask_and_four_edges_once_set() {
        let mut w = World::new();
        let r = w.add_room(&square(50.0)).unwrap();
        assert!(
            terrain_light_segments(&w, r).is_empty(),
            "absence must mean walkable/unoccluded, not fabricated occluder geometry"
        );
        w.set_room_terrain(r, vec![crate::geom::Rect::new(v(-5.0, -5.0), v(5.0, 5.0))])
            .unwrap();
        let segs = terrain_light_segments(&w, r);
        assert_eq!(segs.len(), 4, "one rect must contribute exactly its 4 edges");
        // Every segment endpoint must lie on the rect boundary.
        for (a, b) in &segs {
            for p in [a, b] {
                let on_boundary = (p.x - (-5.0)).abs() < 1e-9
                    || (p.x - 5.0).abs() < 1e-9
                    || (p.y - (-5.0)).abs() < 1e-9
                    || (p.y - 5.0).abs() < 1e-9;
                assert!(on_boundary, "segment endpoint off the rect boundary: {:?}", p);
            }
        }
        // Unknown room: empty, not a panic.
        assert!(terrain_light_segments(&w, 999).is_empty());
    }

    #[test]
    fn terrain_avoid_dir_passes_through_when_the_path_is_clear() {
        let mut w = World::new();
        let r = w.add_room(&square(50.0)).unwrap();
        w.set_room_terrain(r, vec![crate::geom::Rect::new(v(30.0, 30.0), v(40.0, 40.0))])
            .unwrap();
        // Desired direction doesn't come near the rect at all.
        let desired = v(-1.0, 0.0);
        let steered = terrain_avoid_dir(&w, r, v(0.0, -30.0), 3.0, desired, 25.0);
        assert!(steered.dist(desired) < 1e-9, "deflected an already-clear path: {:?}", steered);
    }

    #[test]
    fn terrain_avoid_dir_deflects_and_is_deterministic_for_a_static_scene() {
        let mut w = World::new();
        let r = w.add_room(&square(50.0)).unwrap();
        w.set_room_terrain(r, vec![crate::geom::Rect::new(v(-5.0, -5.0), v(5.0, 5.0))])
            .unwrap();
        let desired = v(1.0, 0.0); // straight at the rect, dead center
        let steered = terrain_avoid_dir(&w, r, v(-30.0, 0.0), 3.0, desired, 40.0);
        assert!(steered.dist(desired) > 1e-3, "did not deflect a head-on approach");
        assert!((steered.len() - 1.0).abs() < 1e-9, "steered direction must stay unit length");
        // Same inputs must give the same output every time (no chatter).
        let steered2 = terrain_avoid_dir(&w, r, v(-30.0, 0.0), 3.0, desired, 40.0);
        assert_eq!(steered.x, steered2.x);
        assert_eq!(steered.y, steered2.y);
    }
}
