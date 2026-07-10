//! PyO3 binding layer for necore. Thin: converts between Python-friendly
//! tuples/lists and the core Rust types. All matrices cross the boundary as
//! row-major 9-tuples of floats; all angles are radians; errors become
//! ValueError with a useful message.

use pyo3::buffer::PyBuffer;
use pyo3::exceptions::PyValueError;
use pyo3::prelude::*;
use pyo3::types::PyBytes;

use necore_core::{
    geom, raycast as core_raycast, rooms_within as core_rooms_within,
    visible_set as core_visible_set, v, Mat3, RayHit, Raster as CoreRaster, Room, Router,
    Sim as CoreSim, Vec2, World,
};

/// Row-major 3x3 homogeneous transform as it crosses the Python boundary.
type M9 = (f64, f64, f64, f64, f64, f64, f64, f64, f64);

fn mat_from_tuple(m: M9) -> Mat3 {
    Mat3 {
        m: [m.0, m.1, m.2, m.3, m.4, m.5, m.6, m.7, m.8],
    }
}

fn mat_to_tuple(m: Mat3) -> M9 {
    let a = m.m;
    (a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8])
}

fn no_room(r: usize) -> PyErr {
    PyValueError::new_err(format!("no room {r}"))
}

fn no_edge(r: usize, e: usize) -> PyErr {
    PyValueError::new_err(format!("room {r} has no edge {e}"))
}

fn no_ent(id: u64) -> PyErr {
    PyValueError::new_err(format!("no entity {id}"))
}

fn world_err(e: necore_core::WorldError) -> PyErr {
    PyValueError::new_err(e.to_string())
}

fn get_room(world: &World, r: usize) -> PyResult<&Room> {
    world.rooms.get(r).ok_or_else(|| no_room(r))
}

fn event_to_obj(py: Python<'_>, ev: necore_core::Event) -> PyObject {
    use necore_core::Event::*;
    match ev {
        Transfer { ent, from, to, edge, xform } => {
            ("transfer", ent, from, to, edge, mat_to_tuple(xform)).into_py(py)
        }
        WallHit { ent, room, edge, pos, normal, speed } => (
            "wall", ent, room, edge, pos.x, pos.y, normal.x, normal.y, speed,
        )
            .into_py(py),
        Contact { a, b, pos, normal, rel_speed } => {
            ("contact", a, b, pos.x, pos.y, normal.x, normal.y, rel_speed).into_py(py)
        }
    }
}

fn rayhit_to_obj(py: Python<'_>, hit: RayHit) -> PyObject {
    match hit {
        RayHit::Wall { room, edge, pos, xform, dist, hops } => {
            ("wall", room, edge, pos.x, pos.y, dist, hops, mat_to_tuple(xform)).into_py(py)
        }
        RayHit::Entity { id, room, pos, xform, dist, hops } => {
            ("ent", id, room, pos.x, pos.y, dist, hops, mat_to_tuple(xform)).into_py(py)
        }
        RayHit::Nothing { room, pos, xform, dist, hops } => {
            ("none", room, pos.x, pos.y, dist, hops, mat_to_tuple(xform)).into_py(py)
        }
    }
}

#[pyclass]
struct Sim {
    sim: CoreSim,
    router: Router,
}

#[pymethods]
impl Sim {
    #[new]
    fn new() -> Self {
        Sim {
            sim: CoreSim::new(World::new()),
            router: Router::new(),
        }
    }

    // --- World construction --------------------------------------------

    fn add_room(&mut self, verts: Vec<(f64, f64)>) -> PyResult<usize> {
        let vs: Vec<Vec2> = verts.into_iter().map(|(x, y)| v(x, y)).collect();
        self.sim.world.add_room(&vs).map_err(world_err)
    }

    fn connect(&mut self, a: usize, ea: usize, b: usize, eb: usize) -> PyResult<()> {
        self.sim.world.connect(a, ea, b, eb).map_err(world_err)
    }

    fn connect_with_xform(&mut self, a: usize, ea: usize, b: usize, eb: usize, m9: M9) -> PyResult<()> {
        self.sim
            .world
            .connect_with_xform(a, ea, b, eb, mat_from_tuple(m9))
            .map_err(world_err)
    }

    fn disconnect(&mut self, a: usize, ea: usize) -> PyResult<()> {
        self.sim.world.disconnect(a, ea).map_err(world_err)
    }

    /// Split a solid wall edge at parametric (t0, t1); returns the middle
    /// sub-edge index. Portals referencing later edges of this room are
    /// remapped internally (+2) — callers keeping (room, edge) maps in
    /// Python must apply the same shift.
    fn split_edge(&mut self, room: usize, edge: usize, t0: f64, t1: f64) -> PyResult<usize> {
        self.sim.world.split_edge(room, edge, t0, t1).map_err(world_err)
    }

    fn num_rooms(&self) -> usize {
        self.sim.world.rooms.len()
    }

    fn room_verts(&self, r: usize) -> PyResult<Vec<(f64, f64)>> {
        let room = get_room(&self.sim.world, r)?;
        Ok(room.verts.iter().map(|p| (p.x, p.y)).collect())
    }

    fn room_portals(&self, r: usize) -> PyResult<Vec<Option<(usize, usize)>>> {
        let room = get_room(&self.sim.world, r)?;
        Ok(room
            .portals
            .iter()
            .map(|p| p.as_ref().map(|p| (p.target_room, p.target_edge)))
            .collect())
    }

    fn portal_xform(&self, r: usize, e: usize) -> PyResult<Option<M9>> {
        let room = get_room(&self.sim.world, r)?;
        let p = room.portals.get(e).ok_or_else(|| no_edge(r, e))?;
        Ok(p.as_ref().map(|p| mat_to_tuple(p.xform)))
    }

    fn edge_endpoints(&self, r: usize, e: usize) -> PyResult<(f64, f64, f64, f64)> {
        let room = get_room(&self.sim.world, r)?;
        if e >= room.num_edges() {
            return Err(no_edge(r, e));
        }
        let (a, b) = room.edge(e);
        Ok((a.x, a.y, b.x, b.y))
    }

    fn edge_midpoint(&self, r: usize, e: usize) -> PyResult<(f64, f64)> {
        let room = get_room(&self.sim.world, r)?;
        if e >= room.num_edges() {
            return Err(no_edge(r, e));
        }
        let (a, b) = room.edge(e);
        let m = a.lerp(b, 0.5);
        Ok((m.x, m.y))
    }

    fn edge_normal(&self, r: usize, e: usize) -> PyResult<(f64, f64)> {
        let room = get_room(&self.sim.world, r)?;
        let n = room.normals.get(e).ok_or_else(|| no_edge(r, e))?;
        Ok((n.x, n.y))
    }

    fn room_radius(&self, r: usize) -> PyResult<f64> {
        Ok(get_room(&self.sim.world, r)?.radius)
    }

    // --- Entities ---------------------------------------------------------

    fn spawn(&mut self, room: usize, x: f64, y: f64, radius: f64, mass: f64, group: u8) -> PyResult<u64> {
        self.sim
            .spawn(room, v(x, y), radius, mass, group)
            .map_err(PyValueError::new_err)
    }

    fn remove(&mut self, id: u64) {
        self.sim.remove(id);
    }

    fn exists(&self, id: u64) -> bool {
        self.sim.entities.contains_key(&id)
    }

    fn set_vel(&mut self, id: u64, vx: f64, vy: f64) -> PyResult<()> {
        let e = self.sim.entities.get_mut(&id).ok_or_else(|| no_ent(id))?;
        e.vel = v(vx, vy);
        Ok(())
    }

    /// Mark a room's walls soft (Otherworld).
    fn soften_room(&mut self, room: usize) {
        self.sim.soften_room(room);
    }

    /// Impulse a soft wall: t in [0,1] along the edge, positive = outward.
    fn soft_wall_impulse(&mut self, room: usize, edge: usize, t: f64, magnitude: f64) {
        self.sim.soft_wall_impulse(room, edge, t, magnitude);
    }

    fn set_pos(&mut self, id: u64, x: f64, y: f64) -> PyResult<()> {
        let e = self.sim.entities.get_mut(&id).ok_or_else(|| no_ent(id))?;
        e.pos = v(x, y);
        Ok(())
    }

    fn set_dir(&mut self, id: u64, dx: f64, dy: f64) -> PyResult<()> {
        let e = self.sim.entities.get_mut(&id).ok_or_else(|| no_ent(id))?;
        e.dir = v(dx, dy).normalized();
        Ok(())
    }

    #[pyo3(signature = (id, rest_wall=None, rest_ent=None, max_substep=None, transfers=None, radius=None, mass=None, group=None))]
    #[allow(clippy::too_many_arguments)]
    fn set_props(
        &mut self,
        id: u64,
        rest_wall: Option<f64>,
        rest_ent: Option<f64>,
        max_substep: Option<f64>,
        transfers: Option<bool>,
        radius: Option<f64>,
        mass: Option<f64>,
        group: Option<u8>,
    ) -> PyResult<()> {
        let e = self.sim.entities.get_mut(&id).ok_or_else(|| no_ent(id))?;
        if let Some(x) = rest_wall {
            e.rest_wall = x;
        }
        if let Some(x) = rest_ent {
            e.rest_ent = x;
        }
        if let Some(x) = max_substep {
            e.max_substep = x;
        }
        if let Some(x) = transfers {
            e.transfers = x;
        }
        if let Some(x) = radius {
            e.radius = x;
        }
        if let Some(x) = mass {
            e.mass = x;
        }
        if let Some(x) = group {
            e.group = x;
        }
        Ok(())
    }

    fn get(&self, id: u64) -> PyResult<(usize, f64, f64, f64, f64, f64, f64)> {
        let e = self.sim.entities.get(&id).ok_or_else(|| no_ent(id))?;
        Ok((e.room, e.pos.x, e.pos.y, e.vel.x, e.vel.y, e.dir.x, e.dir.y))
    }

    fn get_radius(&self, id: u64) -> PyResult<f64> {
        Ok(self.sim.entities.get(&id).ok_or_else(|| no_ent(id))?.radius)
    }

    fn get_room(&self, id: u64) -> PyResult<usize> {
        Ok(self.sim.entities.get(&id).ok_or_else(|| no_ent(id))?.room)
    }

    fn room_entities(&self, room: usize) -> PyResult<Vec<u64>> {
        Ok(get_room(&self.sim.world, room)?.entities.clone())
    }

    fn set_collision_pair(&mut self, g: u8, h: u8, on: bool) {
        self.sim.set_collision_pair(g, h, on);
    }

    fn set_active_within(&mut self, room: usize, hops: usize) -> PyResult<()> {
        if room >= self.sim.world.rooms.len() {
            return Err(no_room(room));
        }
        self.sim.set_active_within(room, hops);
        Ok(())
    }

    fn set_all_active(&mut self) {
        self.sim.all_active = true;
    }

    // --- Simulation ---------------------------------------------------

    fn step(&mut self, py: Python<'_>, dt: f64) -> Vec<PyObject> {
        self.sim
            .step(dt)
            .into_iter()
            .map(|e| event_to_obj(py, e))
            .collect()
    }

    // --- Rendering query -------------------------------------------------

    #[pyo3(signature = (camera_room, cam_m9, apex_x, apex_y, screen_w, screen_h, max_depth, max_instances))]
    #[allow(clippy::too_many_arguments)]
    fn visible_set(
        &self,
        py: Python<'_>,
        camera_room: usize,
        cam_m9: M9,
        apex_x: f64,
        apex_y: f64,
        screen_w: f64,
        screen_h: f64,
        max_depth: usize,
        max_instances: usize,
    ) -> PyResult<Vec<PyObject>> {
        if camera_room >= self.sim.world.rooms.len() {
            return Err(no_room(camera_room));
        }
        let cam = mat_from_tuple(cam_m9);
        let apex = v(apex_x, apex_y);
        let instances = core_visible_set(
            &self.sim.world,
            camera_room,
            cam,
            apex,
            screen_w,
            screen_h,
            max_depth,
            max_instances,
        );
        let mut out = Vec::with_capacity(instances.len());
        for inst in instances {
            let room = &self.sim.world.rooms[inst.room];
            let clip_screen: Vec<(f64, f64)> =
                inst.clip_screen.iter().map(|p| (p.x, p.y)).collect();
            let walls: Vec<(f64, f64, f64, f64, bool)> = inst
                .walls
                .iter()
                .map(|(a, b, portal)| (a.x, a.y, b.x, b.y, *portal))
                .collect();
            let entry_edge: i64 = inst.entry_edge.map(|e| e as i64).unwrap_or(-1);

            let mut ents = Vec::new();
            for &eid in &room.entities {
                if let Some(e) = self.sim.entities.get(&eid) {
                    let d = geom::depth_in_polygon(e.pos, &inst.clip_local);
                    if d < -e.radius {
                        continue; // fully outside the visible region
                    }
                    let fully_inside = d >= e.radius;
                    let sp = inst.xform.apply(e.pos);
                    let sd = inst.xform.apply_dir(e.dir).normalized();
                    let sr = e.radius * inst.xform.linear_scale();
                    ents.push((eid, sp.x, sp.y, sd.x, sd.y, sr, fully_inside));
                }
            }
            // Entities STRADDLING a portal from the neighbor's side: their
            // circle pokes into this instance's region, so this instance
            // must draw its share or the body is cut off at the boundary.
            for portal in room.portals.iter().flatten() {
                let neighbor = &self.sim.world.rooms[portal.target_room];
                for &eid in &neighbor.entities {
                    if let Some(e) = self.sim.entities.get(&eid) {
                        // neighbor-local -> this-room-local
                        let p_here = portal.xform.apply(e.pos);
                        let r_here = e.radius * portal.xform.linear_scale();
                        let d = geom::depth_in_polygon(p_here, &inst.clip_local);
                        if d < -r_here || d >= 0.0 {
                            // not reaching in, or its center is on OUR side
                            // (then it lives in our room list pass instead)
                            continue;
                        }
                        let sp = inst.xform.apply(p_here);
                        let sd = inst
                            .xform
                            .apply_dir(portal.xform.apply_dir(e.dir))
                            .normalized();
                        let sr = r_here * inst.xform.linear_scale();
                        // never fully_inside: force polygon clipping
                        ents.push((eid, sp.x, sp.y, sd.x, sd.y, sr, false));
                    }
                }
            }

            let tup = (
                inst.room,
                mat_to_tuple(inst.xform),
                inst.depth,
                clip_screen,
                walls,
                entry_edge,
                ents,
            )
                .into_py(py);
            out.push(tup);
        }
        Ok(out)
    }

    // --- Queries -----------------------------------------------------

    #[pyo3(signature = (room, ox, oy, dx, dy, max_hops, max_len, mask, ignore=-1))]
    #[allow(clippy::too_many_arguments)]
    fn raycast(
        &self,
        py: Python<'_>,
        room: usize,
        ox: f64,
        oy: f64,
        dx: f64,
        dy: f64,
        max_hops: usize,
        max_len: f64,
        mask: u16,
        ignore: i64,
    ) -> PyResult<PyObject> {
        if room >= self.sim.world.rooms.len() {
            return Err(no_room(room));
        }
        let ignore_opt = if ignore < 0 { None } else { Some(ignore as u64) };
        let hit = core_raycast(
            &self.sim,
            room,
            v(ox, oy),
            v(dx, dy),
            max_hops,
            max_len,
            mask,
            ignore_opt,
        );
        Ok(rayhit_to_obj(py, hit))
    }

    fn next_edge(&mut self, from_room: usize, to_room: usize) -> PyResult<i64> {
        if from_room >= self.sim.world.rooms.len() {
            return Err(no_room(from_room));
        }
        if to_room >= self.sim.world.rooms.len() {
            return Err(no_room(to_room));
        }
        Ok(self
            .router
            .next_edge(&self.sim.world, from_room, to_room)
            .map(|e| e as i64)
            .unwrap_or(-1))
    }

    fn hop_distance(&mut self, a: usize, b: usize) -> PyResult<i64> {
        if a >= self.sim.world.rooms.len() {
            return Err(no_room(a));
        }
        if b >= self.sim.world.rooms.len() {
            return Err(no_room(b));
        }
        Ok(self
            .router
            .hop_distance(&self.sim.world, a, b)
            .map(|d| d as i64)
            .unwrap_or(-1))
    }

    fn rooms_within(&self, room: usize, hops: usize) -> PyResult<Vec<usize>> {
        if room >= self.sim.world.rooms.len() {
            return Err(no_room(room));
        }
        Ok(core_rooms_within(&self.sim.world, room, hops))
    }
}

// --- Software rasterizer ---------------------------------------------------

fn raster_err(e: necore_core::RasterError) -> PyErr {
    PyValueError::new_err(e.to_string())
}

/// Copy a typed buffer (array('I')/array('f')/numpy) into a Vec.
/// Zero-length buffers short-circuit to an empty Vec BEFORE the typed
/// extraction: CPython's `array` exposes a dummy, unaligned base pointer for
/// empty arrays, which would otherwise fail pyo3's alignment check — and an
/// empty stream (nothing dynamic this frame) is a legitimate no-op.
fn typed_buffer<T: pyo3::buffer::Element + Copy>(
    py: Python<'_>,
    obj: &Bound<'_, PyAny>,
) -> PyResult<Vec<T>> {
    if obj.len().map(|l| l == 0).unwrap_or(false) {
        return Ok(Vec::new());
    }
    PyBuffer::<T>::get(obj)?.to_vec(py)
}

/// Reinterpret a native-endian byte blob (`array(..).tobytes()` /
/// `numpy .tobytes()`) as 4-byte words. Copies, so alignment never matters.
fn blob_words<T>(name: &str, bytes: &[u8], from: impl Fn([u8; 4]) -> T) -> PyResult<Vec<T>> {
    if bytes.len() % 4 != 0 {
        return Err(PyValueError::new_err(format!(
            "{name}: byte length {} is not a multiple of 4",
            bytes.len()
        )));
    }
    Ok(bytes
        .chunks_exact(4)
        .map(|c| from([c[0], c[1], c[2], c[3]]))
        .collect())
}

/// Display-list software rasterizer with pygame-ce pixel parity (world +
/// entity + coverage-fold + darkness + overlay glows). See
/// necore/src/raster.rs for the wire format and the compositing pipeline.
#[pyclass]
struct Raster {
    r: CoreRaster,
}

#[pymethods]
impl Raster {
    #[new]
    fn new(w: usize, h: usize) -> PyResult<Self> {
        if w == 0 || h == 0 || w > 16384 || h > 16384 {
            return Err(PyValueError::new_err(format!(
                "raster size {w}x{h} out of range (1..=16384 per side)"
            )));
        }
        Ok(Raster {
            r: CoreRaster::new(w, h),
        })
    }

    #[getter]
    fn width(&self) -> usize {
        self.r.width()
    }

    #[getter]
    fn height(&self) -> usize {
        self.r.height()
    }

    /// Start a frame: clear world to `bg_rgba`, entity/coverage to empty,
    /// and reset the clip/xform tables and overlay queue.
    #[pyo3(signature = (bg_rgba = 0x0000_00FF))]
    fn begin(&mut self, bg_rgba: u32) {
        self.r.begin(bg_rgba);
    }

    /// Darkness multiply on/off (off = debug full-bright).
    fn set_darkness(&mut self, on: bool) {
        self.r.set_darkness(on);
    }

    /// Register an instance's convex screen-space clip polygon — either a
    /// [(x, y), ...] pair list (what `visible()` hands the renderer; no
    /// Python-side flattening) or a flat [x0, y0, x1, y1, ...] sequence.
    /// Returns its clip-table index. With `coverage`, also union-fill it
    /// into the entity coverage mask (the no-seams invariant's mask).
    #[pyo3(signature = (pts, coverage = true))]
    fn add_clip(&mut self, pts: &Bound<'_, PyAny>, coverage: bool) -> PyResult<u32> {
        let flat: Vec<f64> = if let Ok(pairs) = pts.extract::<Vec<(f64, f64)>>() {
            let mut flat = Vec::with_capacity(pairs.len() * 2);
            for (x, y) in pairs {
                flat.push(x);
                flat.push(y);
            }
            flat
        } else {
            pts.extract::<Vec<f64>>().map_err(|_| {
                PyValueError::new_err(
                    "add_clip: pts must be [(x, y), ...] or a flat [x0, y0, ...] float list",
                )
            })?
        };
        self.r.add_clip(&flat, coverage).map_err(raster_err)
    }

    /// Register a row-major Mat3 (the instance xform from visible());
    /// returns its xform-table index.
    fn add_xform(&mut self, m9: M9) -> u32 {
        self.r.add_xform(mat_from_tuple(m9).m)
    }

    /// Upload (or replace) a room texture: RGB8, row-major, `data` a
    /// `w*h*3`-byte buffer (bytes / bytearray / numpy uint8 array). Persists
    /// across frames — call once per texture, not per frame. `id` is
    /// caller-chosen (render.py uses the engine room index).
    fn set_texture(
        &mut self,
        py: Python<'_>,
        id: u32,
        w: usize,
        h: usize,
        data: PyBuffer<u8>,
    ) -> PyResult<()> {
        let bytes = data.to_vec(py)?;
        self.r.set_texture(id, w, h, &bytes).map_err(raster_err)
    }

    /// Execute a command stream: `cmds` is a u32 buffer (array('I') or numpy
    /// uint32) of 6-word headers, `coords` an f32 buffer (array('f') or
    /// numpy float32) of payload points. Rasterization runs without the GIL.
    fn draw(
        &mut self,
        py: Python<'_>,
        cmds: &Bound<'_, PyAny>,
        coords: &Bound<'_, PyAny>,
    ) -> PyResult<()> {
        let c: Vec<u32> = typed_buffer(py, cmds)?;
        let f: Vec<f32> = typed_buffer(py, coords)?;
        py.allow_threads(|| self.r.draw(&c, &f)).map_err(raster_err)
    }

    /// Replay a static blob (same wire format as `draw`, as bytes), with
    /// every command's CLIP and XFORM header fields overridden — the
    /// per-room detail cache path.
    fn draw_blob(
        &mut self,
        py: Python<'_>,
        cmds: PyBuffer<u8>,
        coords: PyBuffer<u8>,
        xform_idx: u32,
        clip_idx: u32,
    ) -> PyResult<()> {
        let c = blob_words("draw_blob cmds", &cmds.to_vec(py)?, u32::from_ne_bytes)?;
        let f = blob_words("draw_blob coords", &coords.to_vec(py)?, f32::from_ne_bytes)?;
        py.allow_threads(|| self.r.draw_with_overrides(&c, &f, xform_idx, clip_idx))
            .map_err(raster_err)
    }

    /// Composite (entity fold -> darkness -> overlay) and return the frame
    /// as straight RGBA8 bytes, len == w*h*4. Idempotent until `begin`.
    fn finish<'py>(&mut self, py: Python<'py>) -> Bound<'py, PyBytes> {
        py.allow_threads(|| {
            self.r.compose_frame();
        });
        PyBytes::new(py, self.r.compose_frame())
    }

    /// `finish`, but written into a caller-owned writable buffer (persistent
    /// bytearray wrapped once with pygame.image.frombuffer -> zero churn).
    fn finish_into(&mut self, py: Python<'_>, out: PyBuffer<u8>) -> PyResult<()> {
        if out.readonly() {
            return Err(PyValueError::new_err("finish_into: buffer is read-only"));
        }
        let want = self.r.width() * self.r.height() * 4;
        if out.item_count() != want {
            return Err(PyValueError::new_err(format!(
                "finish_into: buffer is {} bytes, need {want} (w*h*4)",
                out.item_count()
            )));
        }
        py.allow_threads(|| {
            self.r.compose_frame();
        });
        out.copy_from_slice(py, self.r.compose_frame())
    }
}

// --- Module-level math helpers --------------------------------------------

#[pyfunction]
fn mat_mul(a: M9, b: M9) -> M9 {
    mat_to_tuple(mat_from_tuple(a).mul(mat_from_tuple(b)))
}

#[pyfunction]
fn mat_inv(m: M9) -> PyResult<M9> {
    let mat = mat_from_tuple(m);
    if !mat.is_invertible() {
        return Err(PyValueError::new_err("matrix is not invertible"));
    }
    Ok(mat_to_tuple(mat.inverse()))
}

#[pyfunction]
fn mat_apply(m: M9, x: f64, y: f64) -> (f64, f64) {
    let p = mat_from_tuple(m).apply(v(x, y));
    (p.x, p.y)
}

#[pyfunction]
fn mat_apply_dir(m: M9, x: f64, y: f64) -> (f64, f64) {
    let p = mat_from_tuple(m).apply_dir(v(x, y));
    (p.x, p.y)
}

#[pyfunction]
fn mat_translate(x: f64, y: f64) -> M9 {
    mat_to_tuple(Mat3::translate(v(x, y)))
}

#[pyfunction]
fn mat_rotate(theta: f64) -> M9 {
    mat_to_tuple(Mat3::rotate(theta))
}

#[pyfunction]
fn mat_scale(sx: f64, sy: f64) -> M9 {
    mat_to_tuple(Mat3::scale(sx, sy))
}

#[pyfunction]
fn mat_rotation_angle(m: M9) -> f64 {
    m.3.atan2(m.0)
}

#[pyfunction]
fn mat_identity() -> M9 {
    mat_to_tuple(Mat3::IDENTITY)
}

#[pyfunction]
fn clip_polygon(subject: Vec<(f64, f64)>, clip: Vec<(f64, f64)>) -> Vec<(f64, f64)> {
    let s: Vec<Vec2> = subject.into_iter().map(|(x, y)| v(x, y)).collect();
    let c: Vec<Vec2> = clip.into_iter().map(|(x, y)| v(x, y)).collect();
    geom::clip_polygon_convex(&s, &c)
        .into_iter()
        .map(|p| (p.x, p.y))
        .collect()
}

#[pyfunction]
fn clip_polyline(pts: Vec<(f64, f64)>, clip: Vec<(f64, f64)>) -> Vec<Vec<(f64, f64)>> {
    let p: Vec<Vec2> = pts.into_iter().map(|(x, y)| v(x, y)).collect();
    let c: Vec<Vec2> = clip.into_iter().map(|(x, y)| v(x, y)).collect();
    geom::clip_polyline_convex(&p, &c)
        .into_iter()
        .map(|line| line.into_iter().map(|pt| (pt.x, pt.y)).collect())
        .collect()
}

#[pymodule]
fn necore(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_class::<Sim>()?;
    m.add_class::<Raster>()?;
    m.add_function(wrap_pyfunction!(mat_mul, m)?)?;
    m.add_function(wrap_pyfunction!(mat_inv, m)?)?;
    m.add_function(wrap_pyfunction!(mat_apply, m)?)?;
    m.add_function(wrap_pyfunction!(mat_apply_dir, m)?)?;
    m.add_function(wrap_pyfunction!(mat_translate, m)?)?;
    m.add_function(wrap_pyfunction!(mat_rotate, m)?)?;
    m.add_function(wrap_pyfunction!(mat_scale, m)?)?;
    m.add_function(wrap_pyfunction!(mat_rotation_angle, m)?)?;
    m.add_function(wrap_pyfunction!(mat_identity, m)?)?;
    m.add_function(wrap_pyfunction!(clip_polygon, m)?)?;
    m.add_function(wrap_pyfunction!(clip_polyline, m)?)?;
    Ok(())
}
