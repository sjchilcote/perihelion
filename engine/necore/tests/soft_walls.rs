//! Otherworld soft-wall invariants, as integration tests (they build the
//! lib without cfg(test), so they run independent of in-flight unit-test
//! scaffolding elsewhere in the crate).

use necore::math::{v, Vec2};
use necore::physics::Sim;
use necore::world::World;

fn square(half: f64) -> Vec<Vec2> {
    vec![
        v(-half, -half),
        v(-half, half),
        v(half, half),
        v(half, -half),
    ]
}

fn soft_pair() -> (Sim, usize, usize) {
    let mut w = World::new();
    let a = w.add_room(&square(50.0)).unwrap();
    let b = w.add_room(&square(50.0)).unwrap();
    w.connect(a, 2, b, 0).unwrap();
    let mut sim = Sim::new(w);
    sim.soften_room(a);
    sim.soften_room(b);
    (sim, a, b)
}

fn max_len_err(sim: &Sim, room: usize) -> f64 {
    let r = &sim.world.rooms[room];
    let rest = &sim.soft.rooms[&room].rest_len;
    r.edge_len
        .iter()
        .zip(rest.iter())
        .map(|(l, r)| (l - r).abs())
        .fold(0.0, f64::max)
}

#[test]
fn impulse_deforms_then_lengths_restore() {
    let (mut sim, a, _) = soft_pair();
    let before: Vec<Vec2> = sim.world.rooms[a].verts.clone();
    sim.soft_wall_impulse(a, 0, 0.5, 120.0);
    for _ in 0..12 {
        sim.step(1.0 / 60.0);
    }
    let moved = sim.world.rooms[a]
        .verts
        .iter()
        .zip(before.iter())
        .map(|(p, q)| p.dist(*q))
        .fold(0.0, f64::max);
    assert!(moved > 1.0, "impulse did not deform the wall ({moved})");
    for _ in 0..1800 {
        sim.step(1.0 / 60.0);
    }
    let err = max_len_err(&sim, a);
    assert!(err < 1.5, "edge lengths did not restore: max err {err}");
}

#[test]
fn wave_crosses_the_portal() {
    let (mut sim, a, b) = soft_pair();
    let before_b: Vec<Vec2> = sim.world.rooms[b].verts.clone();
    // hit a wall of room a far from the portal; the wave must reach b.
    sim.soft_wall_impulse(a, 0, 0.5, 150.0);
    for _ in 0..90 {
        sim.step(1.0 / 60.0);
    }
    let moved_b = sim.world.rooms[b]
        .verts
        .iter()
        .zip(before_b.iter())
        .map(|(p, q)| p.dist(*q))
        .fold(0.0, f64::max);
    assert!(
        moved_b > 0.35,
        "wave did not propagate into the neighbor ({moved_b})"
    );
}

#[test]
fn convexity_holds_under_bombardment() {
    let (mut sim, a, b) = soft_pair();
    let mut seed = 0x5EED_u64;
    for i in 0..240 {
        seed = seed.wrapping_mul(6364136223846793005).wrapping_add(1);
        let edge = (seed >> 32) as usize % 4;
        let t = ((seed >> 16) & 0xff) as f64 / 255.0;
        if i % 3 == 0 {
            sim.soft_wall_impulse(if i % 2 == 0 { a } else { b }, edge, t, 90.0);
        }
        sim.step(1.0 / 60.0);
        for &room in &[a, b] {
            let vs = &sim.world.rooms[room].verts;
            let n = vs.len();
            let area2: f64 = (0..n).map(|k| vs[k].cross(vs[(k + 1) % n])).sum();
            for k in 0..n {
                let p = vs[(k + n - 1) % n];
                let c = vs[k];
                let q = vs[(k + 1) % n];
                let cr = (c - p).cross(q - c);
                assert!(
                    cr * area2.signum() >= -1e-6,
                    "reflex vertex in room {room} at step {i}"
                );
            }
        }
    }
}

#[test]
fn portal_transform_stays_exact_under_deformation() {
    let (mut sim, a, b) = soft_pair();
    sim.soft_wall_impulse(a, 1, 0.3, 140.0);
    for _ in 0..300 {
        sim.step(1.0 / 60.0);
        let p = sim.world.rooms[a].portals[2].unwrap();
        let (pa0, pa1) = sim.world.rooms[a].edge(2);
        let (pb0, pb1) = sim.world.rooms[b].edge(0);
        assert!(p.xform.apply(pb1).dist(pa0) < 1e-6, "portal map drifted");
        assert!(p.xform.apply(pb0).dist(pa1) < 1e-6, "portal map drifted");
    }
}

#[test]
fn hard_hit_reaches_a_new_stable_shape() {
    let (mut sim, a, _) = soft_pair();
    let before: Vec<Vec2> = sim.world.rooms[a].verts.clone();
    sim.soft_wall_impulse(a, 0, 0.2, 200.0);
    sim.soft_wall_impulse(a, 0, 0.8, 200.0);
    for _ in 0..3600 {
        sim.step(1.0 / 60.0);
    }
    // settled: lengths near rest...
    let err = max_len_err(&sim, a);
    assert!(err < 2.0, "not settled: len err {err}");
    // ...but the configuration moved: vertices have no rest position.
    let net = sim.world.rooms[a]
        .verts
        .iter()
        .zip(before.iter())
        .map(|(p, q)| p.dist(*q))
        .fold(0.0, f64::max);
    assert!(
        net > 2.0,
        "shape snapped back exactly; equilibria are not degenerate ({net})"
    );
}
