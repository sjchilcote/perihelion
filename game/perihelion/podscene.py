"""The seed pod (SEEDPOD_UI_DESIGN.md, director-directed): ONE full-screen
UI that opens whenever the Commando re-enters a seed station to heal,
upgrade, and think. Two tab-switched pages:

  FABRICATOR -- everything components buy; item list + hero panel (full-
  glory art from assets/hero/<item>.png when present, an enlarged vector
  glyph otherwise -- never a placeholder box).

  MIND -- the mind map as a real graph: regions as territory, prereq
  edges, fog-of-war (unlocked + frontier only), keyboard nav along edges.
  Opening MIND with a finished thought auto-plays the expansion reveal
  (~5s, skippable after the first beat) in one of the game's three visual
  languages (TESTATOR_DESIGN_LANGUAGE.md): phyllotactic bloom for
  faith-positive nodes, MIRIAD schematic snap for neutral ones, and the
  corrupted reveal -- a bloom that sours -- when the Commando has been
  ruminating his way out of his faith. New neighbors fade in only after
  the animation: the reveal is the reward.

This scene is the flagship of the native-resolution mandate: everything
here is drawn at INTERNAL_W x INTERNAL_H with pure vector/procedural
pygame drawing. No image assets are required for any of it.
"""

from __future__ import annotations

import math
import zlib
from pathlib import Path
from random import Random

import pygame

from . import mindmap
from .menus import Scene, get_font, _wrap
from .render import ui
from .sim import DT, SHOP

# ---------------------------------------------------------------------------
# official designations (director-directed). CUCULUS is the seed pods'
# hardware-class name -- the UI identifies itself formally in the chrome
# while colloquial "pod" stays colloquial in help text. The mind page's
# tab carries the in-universe encyclopedia's name (the map IS the
# Commando integrating the public encyclopedia -- the "Encarta Aeterna"
# -- that the Church dumped on his pod's drive). Kept as a single
# constant by directive so any restyling stays a one-line change.
POD_UNIT_NAME = "CUCULUS"
MIND_TAB_LABEL = "ENCARTA"   # director-confirmed final tab label
CAM_GLIDE_DUR = 0.6     # camera glide duration (seconds)

# ---------------------------------------------------------------------------
# palette (TESTATOR_DESIGN_LANGUAGE.md): bone for the memorial elements,
# verdigris/bronze for the aged alloy, MIRIAD cool grays + amber for the
# works of Man, a drained gray-cyan when the reveal goes wrong.
BONE = (214, 205, 182)
BONE_DIM = (150, 143, 126)
VERDIGRIS = (108, 168, 140)
BRONZE = (146, 108, 62)
GOLD = (226, 186, 106)
MIRIAD = (148, 160, 172)
MIRIAD_DIM = (86, 95, 104)
AMBER = (222, 168, 60)
SOUR = (128, 142, 140)   # the drained bloom
CRACK = (96, 78, 96)     # edges that arrive as cracks
BG_TOP = (9, 12, 12)
BG_BOT = (4, 5, 7)
SEED_RED = (122, 44, 38)  # the Commando's own lane: red-organic

GOLDEN_ANGLE = math.radians(137.50776405)

REGION_COLOR = {
    "vocation": (208, 176, 112),      # warm gold: the watch, the faith
    "history": (168, 130, 86),        # bronze: the record
    "comprehension": (136, 156, 172), # MIRIAD gray-blue: the works of Man
    "void": (112, 96, 148),           # cold violet: the rumination
}

HERO_DIR = Path(__file__).resolve().parent / "assets" / "hero"

# ---------------------------------------------------------------------------
# the mind map's typeface (director-directed): Fixedsys Excelsior is the
# terminal/HUD voice and scales badly; the MIND page -- the Commando's
# inner space -- speaks a minimalistic sans-serif instead (IBM Plex Sans,
# OFL, bundled in assets/fonts/ with its license). Canonical label
# geometry lives in mindmap.py (measured advance table); this is just the
# rendering side, scaled by the actual surface width against
# mindmap.CANVAS_W so labels stay crisp at ANY internal resolution
# (rendered at the exact target pt, never smoothscaled bitmap mush).
# ---------------------------------------------------------------------------

_MIND_FONT_DIR = Path(__file__).resolve().parent / "assets" / "fonts"
_MIND_FONT_FILES = {"regular": "IBMPlexSans-Regular.ttf",
                    "medium": "IBMPlexSans-Medium.ttf",
                    "semibold": "IBMPlexSans-SemiBold.ttf"}
_MIND_FONT_CACHE: dict[tuple[str, int], "pygame.font.Font"] = {}


def mind_font(pt: float, face: str = "regular") -> "pygame.font.Font":
    pt_i = max(5, int(round(pt)))
    key = (face, pt_i)
    f = _MIND_FONT_CACHE.get(key)
    if f is None:
        if not pygame.font.get_init():
            pygame.font.init()
        path = _MIND_FONT_DIR / _MIND_FONT_FILES[face]
        if path.exists():
            f = pygame.font.Font(str(path), pt_i)
        else:  # guaranteed-present fallback chain, never a silent default
            fb = (pygame.font.match_font("ibmplexsans")
                  or pygame.font.match_font("dejavusans"))
            f = pygame.font.Font(fb, pt_i) if fb else pygame.font.Font(None, pt_i)
        _MIND_FONT_CACHE[key] = f
    return f


def label_pt(font_px: float, k: float) -> int:
    """The pt size a node label with canonical cell `font_px` renders at
    on a surface scaled `k` from the canonical canvas. FLOORED, not
    rounded: rounding up can render ~11% wider than the canonical box
    (measured, pt 6.75 -> 7), while flooring keeps the worst real-map
    overshoot under 3% -- absorbed by label_size_px's width slack."""
    return max(5, int(math.floor(mindmap.LABEL_FONT_PT
                                 * (font_px / mindmap.LABEL_H_PX) * k)))


_LABEL_IMG_CACHE: dict[tuple, "pygame.Surface"] = {}


def _label_img(text: str, pt: float, color: tuple,
               face: str = "regular") -> "pygame.Surface":
    """Cached antialiased text render (the mind map re-draws every label
    every frame; the text/size/color set is tiny and stable)."""
    key = (text, max(5, int(round(pt))), color, face)
    img = _LABEL_IMG_CACHE.get(key)
    if img is None:
        img = mind_font(pt, face).render(text, True, color)
        if len(_LABEL_IMG_CACHE) > 4096:  # safety valve, never in practice
            _LABEL_IMG_CACHE.clear()
        _LABEL_IMG_CACHE[key] = img
    return img

# one line of register per fabricator item, for the hero panel
ITEM_DESC = {
    "chassis": "A hull racked in advance. Dying prints you at the "
               "nearest seed with the world left as it lies.",
    "station_kit": "A seed, portable. Plant it (B) to anchor revival "
                   "forward of the network.",
    "hp_up": "Layered plating bonded to the frame. +15 integrity "
             "ceiling, printed with every future frame.",
    "scrap_driver": "Fires your salvage as shot. The ammunition is the "
                    "currency itself.",
    "recall": "A ninety-tick channel home. Any hit severs it.",
    "ammo_9mm": "Thirty rounds, printed to pattern. The pistol and the "
                "smg drink from the same clip.",
    "ammo_shell": "Seven shells. The close argument.",
    "ammo_cell": "Eight cells. The rail and the tau share them.",
}

# reveal-animation timeline (seconds)
REVEAL_DUR = 5.0
REVEAL_GLIDE = 0.9      # camera glides to the node
REVEAL_IGNITE = 1.3     # the node flares: the first beat (skippable after)
REVEAL_UNFURL = 3.4     # petals / segments / the souring
REVEAL_SOUR = 2.2       # when a corrupted bloom goes wrong
REVEAL_ZOOM_IN = 1.35   # extra magnification (on top of mindmap.LOCAL_ZOOM)
                        # the reveal eases in while it isolates its node


def _node_rng(node_id: str, salt: str = "") -> Random:
    """Deterministic per-node randomness for reveal ornament (cracks,
    tremor phases). crc32, not hash(): hash() is salted per process and
    the animation must not re-roll between opens."""
    return Random(zlib.crc32((node_id + salt).encode()))


# ---------------------------------------------------------------------------
# the settle: the exact relaxation trajectory (mindmap.layout_steps), cached
# once per process.
# ---------------------------------------------------------------------------

_SETTLE_TAIL_FRAMES = 14
_SETTLE_DUR = 0.7  # seconds
_LABEL_FADE_IN = 0.35  # seconds: subset-settle labels fade in after rest

_traj_cache: list[dict[str, tuple[float, float]]] | None = None


def _settle_trajectory() -> list[dict[str, tuple[float, float]]]:
    global _traj_cache
    if _traj_cache is None:
        _traj_cache = mindmap.layout_steps(record_every=4)
    return _traj_cache


class PodScene(Scene):
    """The unified seed-pod UI. Owns no sim state: focus/progress/queue
    live in GameSession (deterministic, persisted); this scene is the
    presentation around them."""

    FAB_ORDER = ["chassis", "station_kit", "hp_up", "scrap_driver",
                 "recall", "ammo_9mm", "ammo_shell", "ammo_cell"]

    def __init__(self, session):
        self.session = session
        self.t = 0.0
        self.page = "mind" if session.think_done else "fabricator"
        # fabricator
        self.fab_sel = 0
        self.flash = 0.0  # >0 bought, <0 refused
        self._hero_cache: dict[str, "pygame.Surface | None"] = {}
        # mind
        self.layout = mindmap.layout()
        # NO baked global label layout (director's round-2 clarification:
        # the camera is LOCAL -- labels are placed per-frame around the
        # camera by mindmap.local_label_layout, LOD-faded with distance,
        # and dropped -- never exiled -- when they cannot sit adjacent)
        self._frame_labels: dict[str, dict] = {}
        self.sel: str | None = None
        self.reveal: dict | None = None
        self._overlay: "pygame.Surface | None" = None
        self._ducked = False
        self._settle: dict | None = None
        # live physics (director-directed hybridization: nodes stay
        # hard-confined to their own depth-annulus band; selection no
        # longer yanks a node anywhere -- see `_cam` below instead): a
        # live, per-tick relaxation (mindmap.live_relax_step), NOT a baked
        # trajectory -- ticked continuously while the MIND page is open,
        # so the graph's chaotic-within-bands jitter is always the real
        # physics settling, not a canned animation. Suspended (positions
        # held at rest) whenever a baked settle or the reveal animation owns
        # the camera -- see _node_pos()/update().
        self._phys_state = mindmap.live_rest_state()
        self._phys_accum = 0.0
        # the camera (director-directed: selection moves the CAMERA to
        # frame the selected node's ring, never the node itself -- see
        # mindmap.camera_glide).
        cam0 = self.layout.get(self.sel, (0.0, 0.0))
        self._cam = {"from": cam0, "to": cam0, "t0": 0.0, "dur": 0.0}
        self._cam_sel: str | None = None
        # (subset, t_end): labels for these nodes stay hidden until t_end,
        # then fade in over _LABEL_FADE_IN -- set by a subset settle
        self._label_fade: tuple[set[str], float] | None = None

    # ------------------------------------------------------------------

    def on_enter(self, app) -> None:
        self.session.pod_heal()  # entering the pod heals (design brief)
        self._ensure_selection()
        # open with the camera ALREADY centered on the selection (a
        # 0-duration glide) instead of animating in from the world origin
        # -- only a later selection CHANGE glides.
        p = self.layout.get(self.sel, (0.0, 0.0))
        self._cam = {"from": p, "to": p, "t0": self.t, "dur": 0.0}
        self._cam_sel = self.sel
        if self.page == "mind":
            self._start_settle()
        if self.session.think_done and self.reveal is None:
            self.page = "mind"
            self._start_reveal(app)

    # ------------------------------------------------------------------
    # the settle: node positions visibly relax into place using the REAL
    # relaxation trajectory (mindmap.layout_steps), not a fake tween --
    # played on opening MIND and again, scoped to the affected
    # neighborhood, right after a reveal admits new nodes.
    # ------------------------------------------------------------------

    def _start_settle(self, subset: set[str] | None = None) -> None:
        traj = _settle_trajectory()
        if len(traj) < 2:
            return
        tail = traj[-_SETTLE_TAIL_FRAMES:] if len(traj) > _SETTLE_TAIL_FRAMES else traj
        self._settle = dict(frames=tail, t0=self.t, dur=_SETTLE_DUR, subset=subset)
        if subset:
            # labels of the settling neighborhood hold their tongue until
            # the motion stops, then fade in (a moving node under a
            # static-box label reads as the label colliding with the map;
            # the box non-occlusion proof only holds at rest)
            self._label_fade = (set(subset), self.t + _SETTLE_DUR)

    def _node_pos(self, nid: str) -> tuple[float, float]:
        s = self._settle
        if s is not None and (s["subset"] is None or nid in s["subset"]):
            frames = s["frames"]
            u = (self.t - s["t0"]) / s["dur"]
            if u < 1.0:
                fu = max(0.0, u) * (len(frames) - 1)
                i0 = int(fu)
                i1 = min(i0 + 1, len(frames) - 1)
                frac = fu - i0
                f0, f1 = frames[i0], frames[i1]
                if nid in f0 and nid in f1:
                    x0, y0 = f0[nid]
                    x1, y1 = f1[nid]
                    return (x0 + (x1 - x0) * frac, y0 + (y1 - y0) * frac)
            return self.layout.get(nid, (0.0, 0.0))
        if s is None and self.reveal is None:
            # no baked settle or reveal in flight: the live physics
            # state owns positions (reveal precedence -- see update()'s
            # suspend guard, which keeps _phys_state parked at rest
            # whenever a settle or the reveal is active). Selection plays no
            # part here at all -- see _cam/_to_screen for how selection is
            # expressed instead.
            p = self._phys_state.pos.get(nid)
            if p is not None:
                return p
        return self.layout.get(nid, (0.0, 0.0))

    # ------------------------------------------------------------------
    # the live physics (director's hybridization: nodes are hard-confined
    # to their own depth-annulus band; the ONLY thing selection moves is
    # the camera, see _cam below -- see mindmap.live_relax_step). Ticked
    # at a FIXED sim rate (accumulator over real dt, like the rest of the
    # engine's fixed-step sim) so the trajectory is deterministic --
    # identical on every machine, independent of frame rate. Precedence
    # (task-directed): a baked settle (open) or the reveal animation
    # OWNS the camera and positions while active; live physics is
    # suspended (held at rest) for that whole span rather than fighting
    # it, and simply resumes -- from a clean rest state -- the moment
    # both are clear.
    # ------------------------------------------------------------------

    def _update_physics(self, dt: float) -> None:
        if self._settle is not None or self.reveal is not None:
            # reveal/settle precedence: park the physics at a fresh rest
            # state (asleep=False, quiet=0 -- re-verified, not assumed) so
            # it resumes cleanly (not from a stale mid-motion position) the
            # instant it gets the floor back
            self._phys_state = mindmap.live_rest_state()
            self._phys_accum = 0.0
            return
        if self.page != "mind":
            return  # nothing reads physics positions off-page; don't tick it
        self._phys_accum += dt
        while self._phys_accum >= DT:
            self._phys_accum -= DT
            self._phys_state = mindmap.live_relax_step(self._phys_state)

    def on_exit(self, app) -> None:
        if self._ducked:
            app.audio.duck_ambience(1.0)
            self._ducked = False

    # ------------------------------------------------------------------
    # mind-graph queries
    # ------------------------------------------------------------------

    def _visible(self) -> set[str]:
        """Fog-of-war: the integrated mind, its frontier, and finished
        thoughts awaiting their reveal. Nothing else exists yet."""
        s = self.session
        vis = set(s.mind) | set(mindmap.frontier(s.mind)) | set(s.think_done)
        if self.reveal is not None:
            # mid-reveal the newly admitted neighbors are the animation's to show
            vis -= self.reveal["new"] - self.reveal["shown"]
        return vis

    def _edges(self, vis: set[str]) -> list[tuple[str, str]]:
        tbl = mindmap.nodes()
        return [(p, nid) for nid in vis for p in tbl[nid]["prereqs"]
                if p in vis]

    def _ensure_selection(self) -> None:
        vis = self._visible()
        if self.sel in vis:
            return
        s = self.session
        for pick in (s.think_focus, *s.think_done,
                     *mindmap.frontier(s.mind), *sorted(s.mind)):
            if pick in vis:
                self.sel = pick
                return
        self.sel = next(iter(sorted(vis)), None)

    def _cam_pos(self) -> tuple[float, float]:
        """The camera's current position (unit space) via
        `mindmap.camera_glide` (pure function, tested independent of
        pygame -- see test_mindmap_layout.py): selection glides the
        camera to the selected node's ring."""
        c = self._cam
        return mindmap.camera_glide(self.t, c["t0"], c["dur"], c["from"], c["to"])

    def _zoom(self) -> float:
        """The physics-mode camera's current magnification: LOCAL_ZOOM at
        rest (the local-neighborhood framing -- the whole graph is NEVER
        in frame, director's round-2 law; density-scaled by
        mindmap.local_zoom so the framing survives the map growing to
        hundreds/thousands of vertices), eased up by REVEAL_ZOOM_IN
        while the reveal isolates its node. Continuous at the reveal's
        start by construction: u(0) == 0 leaves it exactly local_zoom()."""
        z = mindmap.local_zoom()
        r = self.reveal
        if r is not None:
            u = min(1.0, r["t"] / REVEAL_GLIDE)
            u = u * u * (3 - 2 * u)  # smoothstep, same curve as the glide
            if r["kind"] == "corrupt" and r["t"] > REVEAL_GLIDE:
                # the hand tremors: the zoom overshoots and corrects
                v = r["t"] - REVEAL_GLIDE
                u += math.exp(-2.2 * v) * math.sin(9.0 * v) * 0.10
            z *= 1.0 + (REVEAL_ZOOM_IN - 1.0) * u
        return z

    def _to_screen(self, surf, x: float, y: float) -> tuple[int, int]:
        w, h = surf.get_size()
        # single source of truth with mindmap.py's canonical canvas (the
        # local-label PBT proves geometry against these same fractions).
        # LOCAL camera: the unit->screen scale carries _zoom(), and the
        # view center always tracks _cam_pos() -- INCLUDING during the
        # reveal, whose _start_reveal installs an ordinary camera glide
        # from wherever the camera currently sits to the revealing node.
        # (The old reveal branch interpolated from a GLOBAL origin-
        # centered view instead, which cut/snapped whenever the camera
        # was parked on a selection away from the origin -- the
        # discontinuity the director flagged in the round-1 video.)
        zoom = self._zoom()
        sx = w * mindmap.SX_FRAC * zoom   # elliptical: the screen is wide
        sy = h * mindmap.SY_FRAC * zoom
        camx, camy = self._cam_pos()
        cx = w * mindmap.CX_FRAC - camx * sx
        cy = h * mindmap.CY_FRAC - camy * sy
        r = self.reveal
        if r is not None and r["kind"] == "corrupt" and \
                REVEAL_GLIDE < r["t"] < REVEAL_UNFURL:
            amp = ui(2) * math.exp(-(r["t"] - REVEAL_GLIDE))
            cx += math.sin(r["t"] * 37.0) * amp
            cy += math.cos(r["t"] * 41.0) * amp
        return int(cx + x * sx), int(cy + y * sy)

    # ------------------------------------------------------------------
    # input
    # ------------------------------------------------------------------

    def handle_event(self, app, event) -> None:
        if event.type != pygame.KEYDOWN:
            return
        if self.reveal is not None:
            # the reveal holds the floor; skippable after the first beat
            if self.reveal["t"] >= REVEAL_IGNITE:
                self._finish_reveal(app)
            return
        if event.key in (pygame.K_ESCAPE, pygame.K_e):
            app.pop()
        elif event.key in (pygame.K_TAB, pygame.K_m):
            self.page = "mind" if self.page == "fabricator" else "fabricator"
            if self.page == "mind":
                self._ensure_selection()
                if self.session.think_done:
                    self._start_reveal(app)
                else:
                    self._start_settle()
        elif self.page == "fabricator":
            self._fab_event(app, event)
        else:
            self._mind_event(app, event)

    def _fab_event(self, app, event) -> None:
        if event.key in (pygame.K_UP, pygame.K_w):
            self.fab_sel = (self.fab_sel - 1) % len(self.FAB_ORDER)
        elif event.key in (pygame.K_DOWN, pygame.K_s):
            self.fab_sel = (self.fab_sel + 1) % len(self.FAB_ORDER)
        elif event.key in (pygame.K_RETURN, pygame.K_SPACE):
            ok = self.session.buy(self.FAB_ORDER[self.fab_sel])
            self.flash = 0.35 if ok else -0.35
            if ok:
                app.audio.play("fabricate_buy", 0.9)

    _DIRS = {pygame.K_LEFT: (-1, 0), pygame.K_a: (-1, 0),
             pygame.K_RIGHT: (1, 0), pygame.K_d: (1, 0),
             pygame.K_UP: (0, -1), pygame.K_w: (0, -1),
             pygame.K_DOWN: (0, 1), pygame.K_s: (0, 1)}

    def _mind_event(self, app, event) -> None:
        if event.key in self._DIRS:
            self._nav(*self._DIRS[event.key])
        elif event.key in (pygame.K_RETURN, pygame.K_SPACE):
            if self.sel is not None:
                ok = self.session.set_focus(self.sel)
                self.flash = 0.35 if ok else -0.35

    def _nav(self, dx: int, dy: int) -> None:
        """Walk the prereq edges: prefer an edge-connected neighbor in the
        pressed direction; fall back to the nearest visible node in that
        half-plane so no island is unreachable."""
        if self.sel is None:
            self._ensure_selection()
            return
        vis = self._visible()
        tbl = mindmap.nodes()
        x0, y0 = self.layout[self.sel]
        linked = set(tbl[self.sel]["prereqs"]) | {
            nid for nid in vis if self.sel in tbl[nid]["prereqs"]}

        def score(nid: str) -> float | None:
            x, y = self.layout[nid]
            vx, vy = x - x0, y - y0
            d = math.hypot(vx, vy)
            if d < 1e-9:
                return None
            along = (vx * dx + vy * dy) / d
            if along < 0.25:
                return None  # not in this direction
            return d * (2.2 - along)

        for pool in (linked & vis, vis - {self.sel}):
            best, bs = None, None
            for nid in pool:
                sc = score(nid)
                if sc is not None and (bs is None or sc < bs):
                    best, bs = nid, sc
            if best is not None:
                self.sel = best
                return

    # ------------------------------------------------------------------
    # the reveal (unlock animation)
    # ------------------------------------------------------------------

    def _start_reveal(self, app) -> None:
        s = self.session
        if not s.think_done:
            return
        node = s.think_done[0]
        pre = set(s.mind) | set(mindmap.frontier(s.mind)) | set(s.think_done)
        # commit the unlock NOW (the sim owns state; the reveal is theater --
        # quitting mid-animation can never lose an integrated thought)
        s.complete_focus(node)
        post = set(s.mind) | set(mindmap.frontier(s.mind)) | set(s.think_done)
        faith = mindmap.nodes()[node]["faith"]
        kind = "bloom" if faith > 0 else ("corrupt" if faith < 0 else "snap")
        self.reveal = dict(node=node, kind=kind, t=0.0, new=post - pre,
                         shown=set(), rng=_node_rng(node),
                         fired=set())
        self.sel = node
        # the reveal PULLS the camera: a continuous glide from wherever
        # the camera is right now (mid-glide included) to the completed
        # node, through the same camera machinery every other move uses
        # -- never a snap to a different framing (the round-1 video's
        # selection->reveal discontinuity was exactly such a snap).
        cur = self._cam_pos()
        self._cam = {"from": cur, "to": self.layout.get(node, cur),
                     "t0": self.t, "dur": REVEAL_GLIDE}
        self._cam_sel = node

    def _finish_reveal(self, app) -> None:
        r = self.reveal
        if r is None:
            return
        r["shown"] = set(r["new"])
        self.reveal = None
        if self._ducked:
            app.audio.duck_ambience(1.0)
            self._ducked = False
        if self.session.think_done:  # a queue of thoughts: next reveal
            self._start_reveal(app)
        else:
            self._ensure_selection()
            # the newly revealed neighborhood relaxes live to make polygon:
            # the same real relaxation trajectory, scoped to just the new
            # nodes and the node they unfolded from, so the rest of the
            # graph holds still while that corner visibly settles
            self._start_settle(subset=set(r["new"]) | {r["node"]})

    def _reveal_cue(self, app, key: str, sound: str, vol: float = 0.9) -> None:
        r = self.reveal
        if key not in r["fired"]:
            r["fired"].add(key)
            app.audio.play(sound, vol)

    def update(self, app, dt: float) -> None:
        self.t += dt
        if self.flash > 0:
            self.flash = max(0.0, self.flash - dt)
        elif self.flash < 0:
            self.flash = min(0.0, self.flash + dt)
        if self._settle is not None and self.t - self._settle["t0"] >= self._settle["dur"]:
            self._settle = None
        if self._label_fade is not None and self.t >= self._label_fade[1] + _LABEL_FADE_IN:
            self._label_fade = None
        self._update_physics(dt)
        if self.sel != self._cam_sel and self.reveal is None and self._settle is None:
            # selection changed (anywhere -- nav, reveal start, fog lifting):
            # glide the CAMERA to the node instead of the node to the
            # camera (director's brief, verbatim -- now shared by BOTH
            # layout variants, see _cam_pos). Starts from wherever the
            # camera currently sits (mid-glide or at rest), so a rapid
            # re-selection re-targets smoothly rather than jumping. Gated
            # off while a baked settle or the reveal owns the camera (see
            # on_enter's precedence comment); the glide simply starts once
            # whichever one finishes, from the camera's current resting
            # spot.
            cur = self._cam_pos()
            target = self.layout.get(self.sel, cur)
            self._cam = {"from": cur, "to": target, "t0": self.t, "dur": CAM_GLIDE_DUR}
            self._cam_sel = self.sel
        r = self.reveal
        if r is None:
            return
        r["t"] += dt
        t = r["t"]
        if t >= REVEAL_IGNITE - 0.4:
            # ignition cue per grammar (sfx placeholders; separate pipeline)
            self._reveal_cue(app, "ignite",
                           {"bloom": "reveal_bloom", "snap": "reveal_snap",
                            "corrupt": "reveal_bloom"}[r["kind"]])
        if r["kind"] == "corrupt" and t >= REVEAL_SOUR:
            self._reveal_cue(app, "sour", "reveal_sour")
            if not self._ducked:
                app.audio.duck_ambience(0.35)  # the ambient dips
                self._ducked = True
        # new neighbors fade in only after the reveal's main body
        if t >= REVEAL_UNFURL:
            r["shown"] = set(r["new"])
        if t >= REVEAL_DUR:
            self._finish_reveal(app)

    # ------------------------------------------------------------------
    # drawing
    # ------------------------------------------------------------------

    def _ensure_overlay(self, size) -> "pygame.Surface":
        if self._overlay is None or self._overlay.get_size() != size:
            self._overlay = pygame.Surface(size, pygame.SRCALPHA)
        self._overlay.fill((0, 0, 0, 0))
        return self._overlay

    def draw(self, app, surf) -> None:
        # ENCARTA suppresses the pod ribs: screen-fixed arcs behind a map
        # whose own camera-space depth bands are also arcs read as a stuck
        # second ring system (director, 2026-07-11). The ribs are pod-
        # interior ambiance and stay on the fabricator page.
        self._draw_pod_bg(surf, ribs=self.page == "fabricator")
        if self.page == "fabricator":
            self._draw_fabricator(surf)
        else:
            self._draw_mind(surf)
        self._draw_chrome(surf)

    def _draw_pod_bg(self, surf, ribs: bool = True) -> None:
        """The inside of the seed: a dark vertical gradient ribbed with
        golden-angle arcs (the pod grew; it was not machined) and a faint
        red-organic pulse low in the shell -- the Commando's own lane."""
        w, h = surf.get_size()
        for y in range(0, h, 2):
            k = y / h
            c = (int(BG_TOP[0] + (BG_BOT[0] - BG_TOP[0]) * k),
                 int(BG_TOP[1] + (BG_BOT[1] - BG_TOP[1]) * k),
                 int(BG_TOP[2] + (BG_BOT[2] - BG_TOP[2]) * k))
            pygame.draw.rect(surf, c, (0, y, w, 2))
        if not ribs:
            return
        # pod ribs: concentric arcs from below-screen, golden-ratio gaps
        cx, cy = w // 2, int(h * 1.55)
        r = h * 0.72
        pulse = 0.5 + 0.5 * math.sin(self.t * 1.1)
        for i in range(7):
            col = (18 + i, 20 + i, 20) if i else (
                int(20 + 14 * pulse), 14, 13)  # innermost rib breathes red
            rect = pygame.Rect(int(cx - r), int(cy - r), int(2 * r), int(2 * r))
            pygame.draw.arc(surf, col, rect, math.radians(50),
                            math.radians(130), max(1, ui(2)))
            r *= 1.13 + 0.05 * i  # never-uniform spacing (handcraft law)

    def _draw_chrome(self, surf) -> None:
        w, h = surf.get_size()
        s = self.session
        f = get_font(12)
        # tabs
        tabs = [("FABRICATOR", "fabricator"), (MIND_TAB_LABEL, "mind")]
        x = ui(24)
        for label, key in tabs:
            active = self.page == key
            img = get_font(16).render(label, True,
                                      BONE if active else BONE_DIM)
            surf.blit(img, (x, ui(10)))
            if active:
                pygame.draw.line(surf, VERDIGRIS, (x, ui(30)),
                                 (x + img.get_width(), ui(30)), max(1, ui(1)))
            x += img.get_width() + ui(26)
        # the unit's nameplate, centered in the free chrome between the
        # tabs and the wallet: the hardware class knows its own name
        plate = get_font(10).render(POD_UNIT_NAME + " UNIT", True, (86, 99, 92))
        surf.blit(plate, (w // 2 - plate.get_width() // 2, ui(14)))
        # wallet, right-aligned
        head = f"{s.components}c   {s.chassis} CHASSIS   {s.station_kits} KITS"
        img = f.render(head, True, (170, 200, 185))
        surf.blit(img, (w - img.get_width() - ui(24), ui(12)))
        # footer hints
        if self.reveal is not None:
            hint = "" if self.reveal["t"] < REVEAL_IGNITE else "any key: skip"
        elif self.page == "fabricator":
            hint = ("W/S: select   ENTER: fabricate   TAB: "
                    f"{MIND_TAB_LABEL.lower()}   ESC: seal the pod")
        else:
            hint = "arrows: walk   ENTER: think   TAB: fabricator   ESC: seal the pod"
        if hint:
            img = get_font(10).render(hint, True, (110, 120, 115))
            surf.blit(img, (w // 2 - img.get_width() // 2, h - ui(14)))

    # ------------------------------------------------------------------
    # FABRICATOR page
    # ------------------------------------------------------------------

    def _draw_fabricator(self, surf) -> None:
        w, h = surf.get_size()
        s = self.session
        f = get_font(12)
        y = ui(58)
        for i, item in enumerate(self.FAB_ORDER):
            price = s.shop_price(item)
            owned_note = ""
            if item == "scrap_driver" and "scrap" in s.weapons:
                owned_note = "  [PATTERN HELD]"
            label = f"{SHOP[item]['label']:<22} {price:>3}c{owned_note}"
            sel = i == self.fab_sel
            if sel:
                col = (240, 245, 240)
                if self.flash > 0:
                    col = (140, 255, 160)
                elif self.flash < 0:
                    col = (255, 120, 110)
                pygame.draw.polygon(surf, VERDIGRIS, [
                    (ui(16), y + ui(2)), (ui(22), y + ui(6)), (ui(16), y + ui(10))])
            else:
                col = (150, 180, 160) if s.components >= price else (100, 115, 105)
            surf.blit(f.render(label, True, col), (ui(28), y))
            y += ui(20)
        self._draw_hero_panel(surf, self.FAB_ORDER[self.fab_sel])

    def _hero_art(self, item: str) -> "pygame.Surface | None":
        if item in self._hero_cache:
            return self._hero_cache[item]
        img = None
        p = HERO_DIR / f"{item}.png"
        if p.exists():
            try:
                img = pygame.image.load(str(p))
                try:
                    img = img.convert_alpha()
                except pygame.error:
                    pass  # headless: raw surface still blits
            except (pygame.error, OSError):
                img = None
        self._hero_cache[item] = img
        return img

    def _draw_hero_panel(self, surf, item: str) -> None:
        w, h = surf.get_size()
        rect = pygame.Rect(int(w * 0.47), ui(46), int(w * 0.49), h - ui(46) - ui(96))
        pygame.draw.rect(surf, (10, 13, 13), rect)
        pygame.draw.rect(surf, MIRIAD_DIM, rect, max(1, ui(1)))
        # corner brackets: the fabricator frames its subject
        b = ui(8)
        for cx, cy, sx, sy in ((rect.left, rect.top, 1, 1),
                               (rect.right, rect.top, -1, 1),
                               (rect.left, rect.bottom, 1, -1),
                               (rect.right, rect.bottom, -1, -1)):
            pygame.draw.line(surf, MIRIAD, (cx, cy), (cx + sx * b, cy), max(1, ui(1)))
            pygame.draw.line(surf, MIRIAD, (cx, cy), (cx, cy + sy * b), max(1, ui(1)))
        inner = rect.inflate(-ui(16), -ui(16))
        art = self._hero_art(item)
        if art is not None:
            aw, ah = art.get_size()
            k = min(inner.w / aw, inner.h / ah)
            img = pygame.transform.smoothscale(art, (max(1, int(aw * k)),
                                                     max(1, int(ah * k))))
            surf.blit(img, (inner.centerx - img.get_width() // 2,
                            inner.centery - img.get_height() // 2))
        else:
            self._draw_item_glyph(surf, inner, item)
        # nameplate + description under the panel
        f = get_font(12)
        name = f.render(SHOP[item]["label"], True, BONE)
        surf.blit(name, (rect.left, rect.bottom + ui(8)))
        df = get_font(10)
        yd = rect.bottom + ui(26)
        cols = max(18, rect.w // df.size("M")[0])
        for line in _wrap(ITEM_DESC.get(item, ""), cols)[:3]:
            surf.blit(df.render(line, True, BONE_DIM), (rect.left, yd))
            yd += ui(12)

    def _draw_item_glyph(self, surf, r: pygame.Rect, item: str) -> None:
        """The vector fallback IS the live path (no hero art exists yet):
        an enlarged schematic rendering in the MIRIAD register --
        alignment guides, dimension ticks, amber accents. Never a box."""
        lw = max(1, ui(2))
        t = self.t
        cx, cy = r.centerx, r.centery
        u = min(r.w, r.h) / 100.0  # glyph unit
        # drafting guides through the subject
        pygame.draw.line(surf, (26, 32, 34), (r.left, cy), (r.right, cy), 1)
        pygame.draw.line(surf, (26, 32, 34), (cx, r.top), (cx, r.bottom), 1)
        # a slow survey arc sweeps the subject (alive, not static)
        a0 = (t * 0.6) % (2 * math.pi)
        rad = int(44 * u)
        rect = pygame.Rect(cx - rad, cy - rad, 2 * rad, 2 * rad)
        pygame.draw.arc(surf, (40, 52, 55), rect, a0, a0 + 0.9, 1)

        def L(x1, y1, x2, y2, col=MIRIAD, width=lw):
            pygame.draw.line(surf, col, (cx + x1 * u, cy + y1 * u),
                             (cx + x2 * u, cy + y2 * u), width)

        def C(x, y, rr, col=MIRIAD, width=lw):
            pygame.draw.circle(surf, col, (int(cx + x * u), int(cy + y * u)),
                               max(1, int(rr * u)), width)

        def P(pts, col=MIRIAD, width=lw):
            pygame.draw.polygon(surf, col, [(cx + x * u, cy + y * u)
                                            for x, y in pts], width)

        if item == "chassis":
            # the spare frame, hung in the rack: head, torso shell, limbs
            C(0, -26, 8)
            P([(-14, -14), (14, -14), (10, 14), (-10, 14)])
            L(-14, -12, -24, 8); L(-24, 8, -20, 26)
            L(14, -12, 24, 8); L(24, 8, 20, 26)
            L(-6, 14, -8, 34); L(6, 14, 8, 34)
            C(0, -2, 4, AMBER)  # the empty mind socket, amber-flagged
            L(-30, -34, 30, -34, MIRIAD_DIM, 1)  # the rack rail
            L(0, -34, 0, -32, AMBER, lw)
        elif item == "station_kit":
            # a seed, folded: vesica shell around a coiled tendril
            P([(0, -34), (16, -6), (12, 22), (0, 32), (-12, 22), (-16, -6)])
            ang, rr = 0.0, 3.0
            pts = []
            while rr < 20:
                pts.append((rr * math.cos(ang) * 0.7, 4 + rr * math.sin(ang) * 0.8))
                ang += 0.5
                rr += 1.1
            if len(pts) > 1:
                pygame.draw.lines(surf, SEED_RED, False,
                                  [(cx + x * u, cy + y * u) for x, y in pts], lw)
            L(0, 32, 0, 40, MIRIAD_DIM, 1)  # the planting spike
        elif item == "hp_up":
            # hull plating: overlapped plates, riveted
            P([(-30, -18), (2, -18), (8, 2), (-24, 2)])
            P([(-8, -6), (26, -6), (32, 14), (-2, 14)])
            for x, y in ((-24, -14), (-4, -14), (-18, -2), (2, -2),
                         (-2, -2), (20, -2), (4, 10), (26, 10)):
                C(x, y, 1.6, MIRIAD_DIM, 0)
            L(12, -24, 12, -10, AMBER); L(5, -17, 19, -17, AMBER)  # +15
        elif item == "scrap_driver":
            # the salvage gun: receiver, hopper, three shard tracers
            P([(-30, -2), (6, -2), (6, 10), (-30, 10)])
            P([(-14, -14), (0, -14), (2, -2), (-16, -2)])  # hopper
            L(6, 1, 26, 1); L(6, 7, 22, 7)
            L(-24, 10, -20, 22); L(-12, 10, -10, 20)  # grip
            for i, (dx, dy) in enumerate(((34, -6), (40, 2), (36, 8))):
                P([(dx, dy), (dx + 6, dy + 2), (dx + 2, dy + 5)], AMBER, 1)
        elif item == "recall":
            # the beacon: mast, golden-gapped broadcast arcs
            L(0, 30, 0, -10); P([(-8, 30), (8, 30), (5, 36), (-5, 36)])
            C(0, -14, 4, AMBER)
            rr = 10.0
            for i in range(4):
                rect2 = pygame.Rect(int(cx - rr * u), int(cy - 14 * u - rr * u),
                                    int(2 * rr * u), int(2 * rr * u))
                pygame.draw.arc(surf, VERDIGRIS, rect2,
                                math.radians(35), math.radians(145), lw)
                rr *= 1.618
        elif item.startswith("ammo_"):
            kind = item[5:]
            n = {"9mm": 3, "shell": 2, "cell": 2}[kind]
            for i in range(n):
                dx = (i - (n - 1) / 2) * 22
                if kind == "9mm":
                    P([(dx - 5, 22), (dx + 5, 22), (dx + 5, -12), (dx, -22),
                       (dx - 5, -12)])
                    L(dx - 5, 12, dx + 5, 12, MIRIAD_DIM, 1)
                elif kind == "shell":
                    P([(dx - 7, 24), (dx + 7, 24), (dx + 7, -18), (dx - 7, -18)])
                    L(dx - 7, 14, dx + 7, 14, AMBER, lw)
                    C(dx, 20, 2, MIRIAD_DIM, 0)
                else:  # cell
                    P([(dx - 8, 18), (dx + 8, 18), (dx + 8, -18), (dx - 8, -18)])
                    L(dx - 3, -10, dx + 3, 0, AMBER, lw)
                    L(dx + 3, 0, dx - 3, 10, AMBER, lw)
        # dimension ticks along the base: the fabricator measures
        for i in range(9):
            x = r.left + r.w * (i + 0.5) / 9
            hgt = ui(4) if i % 2 else ui(6)
            pygame.draw.line(surf, MIRIAD_DIM, (x, r.bottom - ui(3)),
                             (x, r.bottom - ui(3) - hgt), 1)

    # ------------------------------------------------------------------
    # MIND page
    # ------------------------------------------------------------------

    def _mind_scale(self, surf) -> float:
        """Canvas -> surface scale for the MIND page's own typography and
        margins (mindmap.py's canonical 640x360 canvas is the reference;
        the aspect ratio is fixed, so one factor serves both axes)."""
        return surf.get_width() / mindmap.CANVAS_W

    def _map_clip(self, surf) -> "pygame.Rect":
        """The strip the map may draw into: below the tab header, above
        the detail panel/footer -- the same margins label_layout reserves
        (mindmap.HEADER_MARGIN_PX / FOOTER_MARGIN_PX), so even mid-glide
        or mid-reveal nothing ever bleeds onto chrome."""
        w, h = surf.get_size()
        ky = h / mindmap.CANVAS_H
        top = int(round(mindmap.HEADER_MARGIN_PX * ky))
        bot = h - int(round(mindmap.FOOTER_MARGIN_PX * ky))
        return pygame.Rect(0, top, w, max(1, bot - top))

    def _draw_bands(self, under, surf) -> None:
        """The depth-annulus bands themselves (director: nodes live IN
        bands, so the player must see bands, not bare circles): alternate
        depths get a whisper of fill, the selected node's own band gets a
        touch more, and every boundary keeps a thin stroke. All radii come
        from the SAME depth_bands()/ring_boundary_radii() the containment
        clamps to -- what is drawn IS the constraint."""
        maxd = max(mindmap.depths().values())
        bands = mindmap.depth_bands(maxd)
        ccx, ccy = self._to_screen(surf, 0.0, 0.0)
        sel_d = mindmap.depths().get(self.sel, -1)

        def radii(rr: float) -> tuple[int, int]:
            ex, _ = self._to_screen(surf, rr, 0.0)
            _, ey = self._to_screen(surf, 0.0, rr)
            return abs(ex - ccx), abs(ey - ccy)

        for d in range(maxd, -1, -1):
            alpha = 13 if d % 2 else 0
            if d == sel_d:
                alpha += 10
            if alpha <= 0:
                continue
            lo, hi = bands[d]
            rxo, ryo = radii(hi)
            rxi, ryi = radii(lo)
            if rxo <= 1 or ryo <= 1:
                continue
            pygame.draw.ellipse(under, (104, 138, 118, alpha),
                                (ccx - rxo, ccy - ryo, 2 * rxo, 2 * ryo))
            if lo > 0 and rxi > 1 and ryi > 1:
                # punch the interior back to transparent (pygame.draw
                # writes raw RGBA on SRCALPHA surfaces -- no blending)
                pygame.draw.ellipse(under, (0, 0, 0, 0),
                                    (ccx - rxi, ccy - ryi, 2 * rxi, 2 * ryi))
        for rr in mindmap.ring_boundary_radii(maxd):
            rx, ry = radii(rr)
            if rx > 1 and ry > 1:
                pygame.draw.ellipse(under, (86, 108, 96, 34),
                                    (ccx - rx, ccy - ry, 2 * rx, 2 * ry),
                                    max(1, ui(1)))

    def _draw_region_headers(self, surf, vis: set[str]) -> None:
        """Sector names, letterspaced Plex Medium in the region's own hue,
        dimmed -- placed by mindmap.region_header_layout() (the SAME rects
        label_layout reserves, so node labels never sit on them) and moved
        rigidly with the map by _to_screen (no screen clamping: if the
        camera glides a header off-strip, the clip simply crops it)."""
        k = self._mind_scale(surf)
        tbl = mindmap.nodes()
        scale = mindmap.HEADER_CELL_PX / mindmap.LABEL_H_PX
        pt = mindmap.LABEL_FONT_PT * scale * k
        for region, info in mindmap.region_header_layout().items():
            if not any(tbl[nid]["region"] == region for nid in vis):
                continue
            ux, uy = info["center_unit"]
            cxp, cyp = self._to_screen(surf, ux, uy)
            # local camera: headers obey the same LOD fade as labels, so a
            # half-clipped sector name never lingers at a screen edge as
            # stray letters -- territory names surface as the camera
            # actually travels into their sector
            alpha = mindmap.label_view_alpha(
                info["center_unit"], self._cam_pos(), self._zoom())
            if alpha <= 0.0:
                continue
            wpx, _ = mindmap.region_header_size_px(info["label"])
            col = tuple(int(c * 0.60) for c in REGION_COLOR[region])
            if alpha < 1.0:
                col = tuple(int(c * alpha) for c in col)
            x = cxp - wpx * k / 2.0 + 3.0 * k  # optical center in the
            # reserved box (whose width carries a 6px ink-overhang pad)
            for ch in info["label"]:
                img = _label_img(ch, pt, col, "medium")
                surf.blit(img, (int(x), int(cyp - img.get_height() / 2)))
                x += (mindmap.text_width_px(ch, "medium") * scale
                      + mindmap.HEADER_TRACK_PX) * k

    def _draw_mind(self, surf) -> None:
        w, h = surf.get_size()
        s = self.session
        vis = self._visible()
        over = self._ensure_overlay((w, h))
        r = self.reveal

        prev_clip = surf.get_clip()
        surf.set_clip(self._map_clip(surf))

        # bands + edges live on one SRCALPHA underlay so both can whisper
        # (true alpha) instead of shouting solid lines across the map
        under = pygame.Surface((w, h), pygame.SRCALPHA)
        if r is None:
            self._draw_bands(under, surf)

        sel_edges: list[tuple[str, str]] = []
        for a, b in self._edges(vis):
            if r is None and self.sel in (a, b):
                sel_edges.append((a, b))
                continue  # drawn after, brighter, over the rest
            ax, ay = self._to_screen(surf, *self._node_pos(a))
            bx, by = self._to_screen(surf, *self._node_pos(b))
            both = a in s.mind and b in s.mind
            col = (112, 138, 122, 128) if both else (98, 110, 105, 76)
            pygame.draw.line(under, col, (ax, ay), (bx, by), max(1, ui(1)))
        for a, b in sel_edges:
            # the selected node's own connections carry the emphasis
            ax, ay = self._to_screen(surf, *self._node_pos(a))
            bx, by = self._to_screen(surf, *self._node_pos(b))
            pygame.draw.line(under, (*VERDIGRIS, 185), (ax, ay), (bx, by),
                             max(1, ui(1)))
        surf.blit(under, (0, 0))

        self._draw_region_headers(surf, vis)

        # per-frame LOCAL label placement: labels live only near the
        # camera (LOD -- distant nodes are unlabeled points), sit adjacent
        # to their nodes, and are dropped rather than exiled when they
        # cannot fit. World-px placement is camera-PAN-invariant, so
        # anchors hold steady through a glide; recomputed every frame
        # because node positions (settle/live jitter) and the zoom
        # (reveal) are themselves per-frame.
        self._frame_labels = mindmap.local_label_layout(
            {nid: self._node_pos(nid) for nid in vis},
            self._cam_pos(), zoom=self._zoom(), sel=self.sel)

        # nodes
        for nid in sorted(vis):
            self._draw_node(surf, nid)

        # the reveal draws above a dimmed graph
        if r is not None:
            dim = 150
            if r["t"] > REVEAL_UNFURL:
                dim = int(150 * max(0.0, (REVEAL_DUR - r["t"]) / (REVEAL_DUR - REVEAL_UNFURL)))
            over.fill((0, 0, 0, dim))
            self._draw_reveal(surf, over)
        surf.blit(over, (0, 0))
        surf.set_clip(prev_clip)

        if r is None:
            self._draw_detail(surf)

    def _draw_node(self, surf, nid: str) -> None:
        s = self.session
        n = mindmap.nodes()[nid]
        nx, ny = self._node_pos(nid)
        x, y = self._to_screen(surf, nx, ny)
        rad = ui(6) + (ui(2) if not n["prereqs"] else 0)
        rcol = REGION_COLOR[n["region"]]
        owned = nid in s.mind
        queued = nid in s.think_done
        focus = nid == s.think_focus
        if owned:
            pygame.draw.circle(surf, BONE, (x, y), rad)
            pygame.draw.circle(surf, rcol, (x, y), rad, max(1, ui(1)))
        elif queued:
            pulse = 0.5 + 0.5 * math.sin(self.t * 4.0)
            pygame.draw.circle(surf, (int(120 + 90 * pulse),) * 3, (x, y), rad)
            pygame.draw.circle(surf, GOLD, (x, y), rad + ui(2), max(1, ui(1)))
        else:  # frontier
            pygame.draw.circle(surf, (22, 26, 26), (x, y), rad)
            pygame.draw.circle(surf, tuple(c // 2 for c in rcol), (x, y),
                               rad, max(1, ui(1)))
        if focus:
            # the thinking arc: progress eats its way around the node
            frac = min(1.0, s.think_progress.get(nid, 0)
                       / max(1, mindmap.think_ticks(nid)))
            rr = rad + ui(4)
            rect = pygame.Rect(x - rr, y - rr, 2 * rr, 2 * rr)
            pygame.draw.arc(surf, VERDIGRIS, rect, math.pi / 2,
                            math.pi / 2 + frac * 2 * math.pi, max(1, ui(2)))
        if nid == self.sel and self.reveal is None:
            # selection ring: three rotating arc shards
            rr = rad + ui(6)
            rect = pygame.Rect(x - rr, y - rr, 2 * rr, 2 * rr)
            a0 = self.t * 1.4
            col = (240, 245, 240)
            if self.flash > 0:
                col = (140, 255, 160)
            elif self.flash < 0:
                col = (255, 120, 110)
            for k in range(3):
                a = a0 + k * 2 * math.pi / 3
                pygame.draw.arc(surf, col, rect, a, a + 1.1, max(1, ui(1)))
        # labels are placed per-frame around the LOCAL camera
        # (mindmap.local_label_layout -- PBT-proven non-occluding and
        # node-adjacent within the legibility radius; distant nodes are
        # honest unlabeled points). During the reveal, non-focus labels
        # dim to near-invisible during the glide/ignite (nothing legible
        # sits on top of the animation art) and the revealing node draws
        # no ordinary label at all (the animation IS its name-card).
        r = self.reveal
        if r is not None and nid == r["node"]:
            return
        alpha = 255
        if r is not None:
            if r["t"] < REVEAL_UNFURL:
                alpha = 26
            else:
                alpha = int(255 * min(1.0, (r["t"] - REVEAL_UNFURL) / 0.6))
            if alpha <= 0:
                return
        fade = self._label_fade
        if fade is not None and nid in fade[0]:
            if self.t < fade[1]:
                return  # node still settling: no label over the motion
            alpha = int(alpha * min(1.0, (self.t - fade[1]) / _LABEL_FADE_IN))
            if alpha <= 0:
                return
        k = self._mind_scale(surf)
        info = self._frame_labels.get(nid)
        if info is None:
            return  # beyond the legibility radius, or dropped: a dot
        alpha = int(alpha * info["alpha"])
        if alpha <= 0:
            return
        # "off" is world px == canonical-canvas screen px: scale by k only
        # (zoom is already inside the world-px frame), anchored on the
        # node's own screen position so the label rides every camera/zoom
        # move rigidly with its node
        lx = x + int(round(info["off"][0] * k))
        ly = y + int(round(info["off"][1] * k))
        font_px = 16
        col = BONE if nid == self.sel else (GOLD if queued else (
            132, 140, 136) if not owned else tuple(min(255, c + 40) for c in rcol))
        # rendered at the exact target size (Plex Sans stays crisp at any
        # pt; never bitmap-smoothscale mush), scaled with the surface so
        # labels hold their screen fraction at any internal resolution
        img = _label_img(n["label"], label_pt(font_px, k), col)
        if alpha < 255:
            img = img.copy()
            img.set_alpha(alpha)
        surf.blit(img, (lx - img.get_width() // 2, ly - img.get_height() // 2))

    def _draw_detail(self, surf) -> None:
        w, h = surf.get_size()
        s = self.session
        if self.sel is None:
            return
        n = mindmap.nodes()[self.sel]
        k = self._mind_scale(surf)
        band_h = ui(58)
        y0 = h - band_h - ui(18)
        pygame.draw.rect(surf, (10, 11, 14), (0, y0, w, band_h))
        pygame.draw.line(surf, (40, 46, 44), (0, y0), (w, y0), 1)
        rcol = REGION_COLOR[n["region"]]
        # the detail panel speaks the map's own voice (Plex), not the
        # terminal's: it is part of the mind page, not the HUD
        title = _label_img(n["label"].upper(), 11.5 * k, BONE, "semibold")
        surf.blit(title, (ui(16), y0 + ui(5)))
        tag = _label_img(mindmap.REGION_LABELS[n["region"]], 9 * k, rcol, "medium")
        surf.blit(tag, (ui(16), y0 + ui(23)))
        # status: what thinking here costs / has cost
        nid = self.sel
        if nid in s.mind:
            status = "INTEGRATED"
        elif nid in s.think_done:
            status = "THOUGHT COMPLETE - REVEAL PENDING"
        else:
            need = mindmap.think_ticks(nid)
            have = s.think_progress.get(nid, 0)
            secs = mindmap.weight(nid) * mindmap.THINK_SECONDS_PER_WEIGHT
            if nid == s.think_focus:
                status = f"THINKING - {100 * have // need}% of {secs}s"
            elif have:
                status = f"PARKED AT {100 * have // need}% of {secs}s"
            else:
                status = f"THINK TIME: {secs}s IN THE FIELD"
        surf.blit(_label_img(status, 9 * k, VERDIGRIS, "medium"),
                  (ui(16), y0 + ui(38)))
        bx = max(ui(268), ui(20) + title.get_width())
        bf = mind_font(10 * k)
        max_w = w - bx - ui(16)
        words = n.get("brief", "").split()
        lines: list[str] = []
        cur = ""
        for word in words:
            cand = (cur + " " + word).strip()
            if cur and bf.size(cand)[0] > max_w:
                lines.append(cur)
                cur = word
            else:
                cur = cand
        if cur:
            lines.append(cur)
        for i, line in enumerate(lines[:3]):
            surf.blit(_label_img(line, 10 * k, (150, 148, 140)),
                      (bx, y0 + ui(6) + i * ui(15)))

    # ------------------------------------------------------------------
    # the three reveal grammars
    # ------------------------------------------------------------------

    def _draw_reveal(self, surf, over) -> None:
        r = self.reveal
        t = r["t"]
        x, y = self._to_screen(surf, *self.layout[r["node"]])
        # ignition flare, shared by all three grammars: a soft bloom of
        # concentric light, then a bright expanding ring
        if t > REVEAL_GLIDE:
            k = min(1.0, (t - REVEAL_GLIDE) / (REVEAL_IGNITE - REVEAL_GLIDE))
            # the flare is transient: full at ignition, gone half a beat later
            fade = max(0.0, 1.0 - max(0.0, t - REVEAL_IGNITE) / 0.5)
            base = GOLD if r["kind"] != "snap" else MIRIAD
            if fade > 0.0:
                for gr, ga in ((ui(30), 34), (ui(18), 62), (ui(10), 110)):
                    pygame.draw.circle(over, (*base, int(ga * fade)), (x, y), gr)
                fr = ui(8) + int(ui(34) * k)
                alpha = int(210 * (1.0 - 0.7 * k) * fade)
                pygame.draw.circle(over, (*base, alpha), (x, y), fr,
                                   max(1, ui(2)))
        if r["kind"] == "bloom":
            self._reveal_bloom(surf, over, x, y, t, sour_at=None)
        elif r["kind"] == "corrupt":
            self._reveal_bloom(surf, over, x, y, t, sour_at=REVEAL_SOUR)
        else:
            self._reveal_snap(surf, over, x, y, t)
        self._reveal_neighbors(surf, over, t)
        # the node itself, reborn bone-bright at the center
        if t > REVEAL_IGNITE:
            col = BONE if not (r["kind"] == "corrupt" and t > REVEAL_SOUR) else SOUR
            pygame.draw.circle(over, (*col, 255), (x, y), ui(7))
            pygame.draw.circle(over, (*REGION_COLOR[
                mindmap.nodes()[r["node"]]["region"]], 255), (x, y), ui(7),
                max(1, ui(1)))

    def _reveal_bloom(self, surf, over, x, y, t, sour_at) -> None:
        """PHYLLOTACTIC BLOOM: petals unfurl at the golden angle, radius
        by sqrt(k) -- the sunflower law in machined light (Testator lane).
        With `sour_at`, the same bloom is betrayed mid-unfurl: color
        drains, petals go angular, growth staggers -- the corrupted reveal."""
        r = self.reveal
        if t <= REVEAL_IGNITE - 0.2:
            return
        n_petals = 21
        t0, t1 = REVEAL_IGNITE - 0.2, REVEAL_UNFURL
        for k in range(n_petals):
            born = t0 + (t1 - t0) * k / n_petals
            if t < born:
                break
            grow = min(1.0, (t - born) / 0.7)
            soured = sour_at is not None and t > sour_at
            ang = k * GOLDEN_ANGLE
            # each petal is a leaf stretching from near the node out to its
            # floret position (radius by sqrt(k): the sunflower disc)
            d_out = (ui(20) + ui(74) * math.sqrt((k + 1) / n_petals)) * grow
            d_in = ui(9) + d_out * 0.30
            ca, sa = math.cos(ang), math.sin(ang)
            mid = (d_in + d_out) / 2
            pw = max(ui(2), (d_out - d_in) * 0.26)
            if not soured:
                warm = k / n_petals
                col = (int(BONE[0] + (GOLD[0] - BONE[0]) * warm),
                       int(BONE[1] + (GOLD[1] - BONE[1]) * warm),
                       int(BONE[2] + (GOLD[2] - BONE[2]) * warm))
                pts = [(x + ca * d_in, y + sa * d_in),
                       (x + ca * mid - sa * pw, y + sa * mid + ca * pw),
                       (x + ca * d_out, y + sa * d_out),
                       (x + ca * mid + sa * pw, y + sa * mid - ca * pw)]
                ipts = [(int(a), int(b)) for a, b in pts]
                alpha = int(120 * min(1.0, grow * 1.4))
                pygame.draw.polygon(over, (*col, alpha), ipts)
                pygame.draw.polygon(over, (*col, min(255, alpha + 110)),
                                    ipts, max(1, ui(1)))
            else:
                # the same petal, drained and gone to knives
                rng = _node_rng(r["node"], f"petal{k}")
                j = rng.uniform(-1.0, 1.0) * ui(3)
                pts = [(x + ca * d_in, y + sa * d_in),
                       (x + ca * mid * 0.9 - sa * (pw + j),
                        y + sa * mid * 0.9 + ca * (pw + j)),
                       (x + ca * d_out * 1.12, y + sa * d_out * 1.12),
                       (x + ca * mid * 1.05 + sa * pw * 0.35,
                        y + sa * mid * 1.05 - ca * pw * 0.35)]
                ipts = [(int(a), int(b)) for a, b in pts]
                pygame.draw.polygon(over, (*SOUR, 70), ipts)
                pygame.draw.polygon(over, (*SOUR, 235), ipts, max(1, ui(1)))

    def _reveal_snap(self, surf, over, x, y, t) -> None:
        """MIRIAD SCHEMATIC SNAP: alignment guides flash, then the node
        assembles from clean vector segments with a drafting-table
        register -- the lane of the works of Man."""
        w, h = surf.get_size()
        # alignment guides sweep in during the glide and fade
        if t < REVEAL_IGNITE + 0.9:
            a = int(140 * max(0.0, 1.0 - abs(t - REVEAL_GLIDE) / 1.1))
            if a > 0:
                pygame.draw.line(over, (*MIRIAD, a), (0, y), (w, y), 1)
                pygame.draw.line(over, (*MIRIAD, a), (x, 0), (x, h), 1)
                for off in (-ui(30), ui(30)):
                    pygame.draw.line(over, (*MIRIAD, a // 2),
                                     (0, y + off), (w, y + off), 1)
                    pygame.draw.line(over, (*MIRIAD, a // 2),
                                     (x + off, 0), (x + off, h), 1)
        if t <= REVEAL_IGNITE - 0.2:
            return
        bright = (200, 214, 226)
        # eight ring segments snap in, each with a little overshoot
        segs = 8
        t0, t1 = REVEAL_IGNITE - 0.2, REVEAL_UNFURL - 0.4
        rr = ui(26)
        for k in range(segs):
            born = t0 + (t1 - t0) * k / segs
            if t < born:
                break
            u = min(1.0, (t - born) / 0.35)
            overshoot = 1.0 + 0.25 * math.exp(-6 * u) * math.sin(12 * u)
            a0 = -math.pi / 2 + k * 2 * math.pi / segs
            span = (2 * math.pi / segs) * 0.72 * u
            for rad, wd in ((rr * overshoot, ui(2)), (rr * 0.62 * overshoot, ui(1))):
                rect = pygame.Rect(int(x - rad), int(y - rad),
                                   int(2 * rad), int(2 * rad))
                pygame.draw.arc(over, (*bright, 240), rect, a0, a0 + span,
                                max(1, wd))
        # corner brackets: the drafting frame closes on the subject
        if t > t0 + 0.3:
            b, d = ui(6), ui(34)
            for sx_, sy_ in ((-1, -1), (1, -1), (-1, 1), (1, 1)):
                pygame.draw.lines(over, (*MIRIAD, 220), False,
                                  [(x + sx_ * d, y + sy_ * (d - b)),
                                   (x + sx_ * d, y + sy_ * d),
                                   (x + sx_ * (d - b), y + sy_ * d)],
                                  max(1, ui(1)))
        # index ticks + amber datum once assembly completes
        if t > t1:
            for k in range(segs):
                a = -math.pi / 2 + (k + 0.5) * 2 * math.pi / segs
                x1 = x + math.cos(a) * (rr + ui(3))
                y1 = y + math.sin(a) * (rr + ui(3))
                x2 = x + math.cos(a) * (rr + ui(8))
                y2 = y + math.sin(a) * (rr + ui(8))
                pygame.draw.line(over, (*AMBER, 230), (x1, y1), (x2, y2),
                                 max(1, ui(1)))

    def _reveal_neighbors(self, surf, over, t) -> None:
        """New neighbors fade in only after the reveal's main body: edges
        first (tendrils for the bloom, straight drafting lines for the
        snap, cracks for the corrupted reveal), then the nodes themselves."""
        r = self.reveal
        if t < REVEAL_UNFURL - 0.3 or not r["new"]:
            return
        u = min(1.0, (t - (REVEAL_UNFURL - 0.3)) / 1.2)
        x, y = self._to_screen(surf, *self.layout[r["node"]])
        tbl = mindmap.nodes()
        for nid in sorted(r["new"]):
            if nid not in self.layout:
                continue
            nx, ny = self._to_screen(surf, *self.layout[nid])
            grow = min(1.0, u * 1.6)
            ex, ey = x + (nx - x) * grow, y + (ny - y) * grow
            if r["kind"] == "bloom":
                # a tendril: curved via a perpendicular midpoint bow
                mx, my = (x + ex) / 2, (y + ey) / 2
                dx, dy = ex - x, ey - y
                d = math.hypot(dx, dy) or 1e-6
                bow = ui(10) * math.sin(grow * math.pi)
                bx_, by_ = mx - dy / d * bow, my + dx / d * bow
                pts = [(x, y)]
                for i in range(1, 9):
                    q = i / 9
                    ax_ = (1 - q) ** 2 * x + 2 * (1 - q) * q * bx_ + q * q * ex
                    ay_ = (1 - q) ** 2 * y + 2 * (1 - q) * q * by_ + q * q * ey
                    pts.append((ax_, ay_))
                pts.append((ex, ey))
                pygame.draw.lines(over, (*VERDIGRIS, 235), False,
                                  [(int(a), int(b)) for a, b in pts], max(1, ui(2)))
            elif r["kind"] == "snap":
                pygame.draw.line(over, (*MIRIAD, 220), (x, y), (ex, ey),
                                 max(1, ui(1)))
            else:
                # a crack: a deterministic jagged walk toward the neighbor
                rng = _node_rng(r["node"], nid)
                dx, dy = ex - x, ey - y
                d = math.hypot(dx, dy) or 1e-6
                pts = [(x, y)]
                steps = 6
                for i in range(1, steps):
                    q = i / steps
                    off = rng.uniform(-1, 1) * ui(5)
                    pts.append((x + dx * q - dy / d * off,
                                y + dy * q + dx / d * off))
                pts.append((ex, ey))
                ipts = [(int(a), int(b)) for a, b in pts]
                pygame.draw.lines(over, (150, 122, 150, 240), False, ipts,
                                  max(1, ui(2)))
                pygame.draw.lines(over, (*CRACK, 160), False,
                                  [(a, b + ui(1)) for a, b in ipts], 1)
            # the neighbor arrives: a fading-in disc only -- its NAME is
            # drawn exactly once, by the ordinary per-node label pass in
            # _draw_node (which fades it in over the same window once
            # r["shown"] admits the node into `vis`). Drawing the label
            # here too used to double it up: this fade-in glow's `u>0.5`
            # gate only trips at REVEAL_UNFURL+0.3s, by which point
            # r["shown"] (flipped at REVEAL_UNFURL) already made the
            # ordinary label pass draw the same name -- two draws of one
            # word, stacked.
            if u > 0.5:
                a = int(255 * (u - 0.5) * 2)
                rcol = REGION_COLOR[tbl[nid]["region"]]
                pygame.draw.circle(over, (22, 26, 26, a), (nx, ny), ui(6))
                pygame.draw.circle(over, (*[c // 2 for c in rcol], a),
                                   (nx, ny), ui(6), max(1, ui(1)))
