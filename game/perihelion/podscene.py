"""The seed pod (SEEDPOD_UI_DESIGN.md, director-directed): ONE full-screen
UI that opens whenever the Commando re-enters a seed station to heal,
upgrade, and think. Two tab-switched pages:

  FABRICATOR -- everything components buy; item list + hero panel (full-
  glory art from assets/hero/<item>.png when present, an enlarged vector
  glyph otherwise -- never a placeholder box).

  MIND -- the mind map as a real graph: regions as territory, prereq
  edges, fog-of-war (unlocked + frontier only), keyboard nav along edges.
  Opening MIND with a finished thought auto-plays the expansion rite
  (~5s, skippable after the first beat) in one of the game's three visual
  languages (TESTATOR_DESIGN_LANGUAGE.md): phyllotactic bloom for
  faith-positive nodes, MIRIAD schematic snap for neutral ones, and the
  corrupted rite -- a bloom that sours -- when the Commando has been
  ruminating his way out of his faith. New neighbors fade in only after
  the rite: the reveal is the reward.

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
# palette (TESTATOR_DESIGN_LANGUAGE.md): bone for the memorial elements,
# verdigris/bronze for the aged alloy, MIRIAD cool grays + amber for the
# works of Man, a drained gray-cyan when the rite goes wrong.
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

# rite timeline (seconds)
RITE_DUR = 5.0
RITE_GLIDE = 0.9      # camera glides to the node
RITE_IGNITE = 1.3     # the node flares: the first beat (skippable after)
RITE_UNFURL = 3.4     # petals / segments / the souring
RITE_SOUR = 2.2       # when a corrupted bloom goes wrong


def _node_rng(node_id: str, salt: str = "") -> Random:
    """Deterministic per-node randomness for rite ornament (cracks,
    tremor phases). crc32, not hash(): hash() is salted per process and
    the ceremony must not re-roll between opens."""
    return Random(zlib.crc32((node_id + salt).encode()))


# ---------------------------------------------------------------------------
# the settle: the exact relaxation trajectory (mindmap.layout_steps), cached
# once per process, and label anchors as unit-space offsets from their node
# (so labels glide/zoom with their node under the rite's camera exactly like
# the node does -- both go through the same _to_screen call).
# ---------------------------------------------------------------------------

_SETTLE_TAIL_FRAMES = 14
_SETTLE_DUR = 0.7  # seconds

_traj_cache: list[dict[str, tuple[float, float]]] | None = None


def _settle_trajectory() -> list[dict[str, tuple[float, float]]]:
    global _traj_cache
    if _traj_cache is None:
        _traj_cache = mindmap.layout_steps(record_every=4)
    return _traj_cache


def _label_unit_offsets(layout: dict[str, tuple[float, float]],
                        labels: dict[str, dict],
                        ) -> dict[str, tuple[float, float]]:
    """node id -> (dx, dy) in unit space from the node to its label
    rectangle's CENTER, so the label can be positioned with the same
    self._to_screen(surf, node_x + dx, node_y + dy) call used for the
    node -- it inherits the rite's zoom/glide for free and never drifts
    out of sync with the node it names."""
    out: dict[str, tuple[float, float]] = {}
    sxw = mindmap.CANVAS_W * mindmap.SX_FRAC
    syh = mindmap.CANVAS_H * mindmap.SY_FRAC
    for nid, info in labels.items():
        if nid not in layout:
            continue
        l, t, r, b = info["box"]
        bcx, bcy = (l + r) / 2, (t + b) / 2
        npx, npy = mindmap._to_px(layout[nid])
        out[nid] = ((bcx - npx) / sxw, (bcy - npy) / syh)
    return out


class PodScene(Scene):
    """The unified seed-pod UI. Owns no sim state: focus/progress/queue
    live in GameSession (deterministic, persisted); this scene is the
    ceremony around them."""

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
        self._labels = mindmap.label_layout(self.layout)
        self._label_offset = _label_unit_offsets(self.layout, self._labels)
        self.sel: str | None = None
        self.rite: dict | None = None
        self._overlay: "pygame.Surface | None" = None
        self._ducked = False
        self._settle: dict | None = None
        # the selection pin (director-directed: "yanked to the center...
        # drifted back...when released"): a live, per-tick relaxation
        # (mindmap.live_relax_step), NOT a baked trajectory -- it is the
        # SAME live force field regardless of which node self.sel names,
        # so simply changing self.sel IS the "release": the old node's
        # spring reverts to its own rest anchor and the new one's becomes
        # the center pin, no special-cased transition needed. Suspended
        # (positions held at rest) whenever a baked settle or the rite
        # ceremony owns the camera -- see _node_pos()/update().
        self._pin_state = mindmap.live_rest_state()
        self._pin_accum = 0.0

    # ------------------------------------------------------------------

    def on_enter(self, app) -> None:
        self.session.pod_heal()  # entering the pod heals (design brief)
        self._ensure_selection()
        if self.page == "mind":
            self._start_settle()
        if self.session.think_done and self.rite is None:
            self.page = "mind"
            self._start_rite(app)

    # ------------------------------------------------------------------
    # the settle: node positions visibly relax into place using the REAL
    # relaxation trajectory (mindmap.layout_steps), not a fake tween --
    # played on opening MIND and again, scoped to the affected
    # neighborhood, right after a rite reveals new nodes.
    # ------------------------------------------------------------------

    def _start_settle(self, subset: set[str] | None = None) -> None:
        traj = _settle_trajectory()
        if len(traj) < 2:
            return
        tail = traj[-_SETTLE_TAIL_FRAMES:] if len(traj) > _SETTLE_TAIL_FRAMES else traj
        self._settle = dict(frames=tail, t0=self.t, dur=_SETTLE_DUR, subset=subset)

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
        if s is None and self.rite is None:
            # no baked settle or ceremony in flight: the live selection pin
            # owns positions (ceremony precedence -- see update()'s
            # pin-suspend guard, which keeps _pin_state parked at rest
            # whenever a settle or the rite is active)
            p = self._pin_state.pos.get(nid)
            if p is not None:
                return p
        return self.layout.get(nid, (0.0, 0.0))

    # ------------------------------------------------------------------
    # the selection pin (director-directed feature): "the currently
    # selected one got yanked to the center and then drifted back to
    # wherever it naturally wants to be when released." Ticked at a FIXED
    # sim rate (accumulator over real dt, like the rest of the engine's
    # fixed-step sim) so the trajectory is deterministic -- identical on
    # every machine, independent of frame rate. Precedence (task-directed):
    # a baked settle (open/reveal) or the rite ceremony OWNS the camera and
    # positions while active; the pin is suspended (held at rest) for that
    # whole span rather than fighting it, and simply resumes -- from a
    # clean rest state -- the moment both are clear.
    # ------------------------------------------------------------------

    def _update_pin(self, dt: float) -> None:
        if self._settle is not None or self.rite is not None:
            # ceremony/settle precedence: park the pin at a fresh rest
            # state (asleep=False, quiet=0 -- re-verified, not assumed) so
            # it resumes cleanly (not from a stale mid-yank position) the
            # instant it gets the floor back
            self._pin_state = mindmap.live_rest_state()
            self._pin_accum = 0.0
            return
        if self.page != "mind":
            return  # nothing reads pin positions off-page; don't tick it
        self._pin_accum += dt
        while self._pin_accum >= DT:
            self._pin_accum -= DT
            self._pin_state = mindmap.live_relax_step(self._pin_state, pin=self.sel)

    def on_exit(self, app) -> None:
        if self._ducked:
            app.audio.duck_ambience(1.0)
            self._ducked = False

    # ------------------------------------------------------------------
    # mind-graph queries
    # ------------------------------------------------------------------

    def _visible(self) -> set[str]:
        """Fog-of-war: the integrated mind, its frontier, and finished
        thoughts awaiting ceremony. Nothing else exists yet."""
        s = self.session
        vis = set(s.mind) | set(mindmap.frontier(s.mind)) | set(s.think_done)
        if self.rite is not None:
            # mid-rite the newly revealed neighbors are the rite's to show
            vis -= self.rite["new"] - self.rite["shown"]
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

    def _to_screen(self, surf, x: float, y: float) -> tuple[int, int]:
        w, h = surf.get_size()
        sx, sy = w * 0.40, h * 0.365  # elliptical: the screen is wide
        cx, cy = w * 0.5, h * 0.46
        if self.rite is not None:
            r = self.rite
            u = min(1.0, r["t"] / RITE_GLIDE)
            u = u * u * (3 - 2 * u)  # smoothstep glide
            if r["kind"] == "corrupt" and r["t"] > RITE_GLIDE:
                # the hand tremors: the glide overshoots and corrects
                v = r["t"] - RITE_GLIDE
                u += math.exp(-2.2 * v) * math.sin(9.0 * v) * 0.10
            nx, ny = self.layout[r["node"]]
            z = 1.0 + 0.9 * u
            sx, sy = sx * z, sy * z
            # glide the view center onto the node (node -> screen center)
            cx = w * 0.5 - nx * sx * u
            cy = h * 0.46 - ny * sy * u
            if r["kind"] == "corrupt" and RITE_GLIDE < r["t"] < RITE_UNFURL:
                amp = ui(2) * math.exp(-(r["t"] - RITE_GLIDE))
                cx += math.sin(r["t"] * 37.0) * amp
                cy += math.cos(r["t"] * 41.0) * amp
        return int(cx + x * sx), int(cy + y * sy)

    # ------------------------------------------------------------------
    # input
    # ------------------------------------------------------------------

    def handle_event(self, app, event) -> None:
        if event.type != pygame.KEYDOWN:
            return
        if self.rite is not None:
            # the ceremony holds the floor; skippable after the first beat
            if self.rite["t"] >= RITE_IGNITE:
                self._finish_rite(app)
            return
        if event.key in (pygame.K_ESCAPE, pygame.K_e):
            app.pop()
        elif event.key in (pygame.K_TAB, pygame.K_m):
            self.page = "mind" if self.page == "fabricator" else "fabricator"
            if self.page == "mind":
                self._ensure_selection()
                if self.session.think_done:
                    self._start_rite(app)
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
    # the rite
    # ------------------------------------------------------------------

    def _start_rite(self, app) -> None:
        s = self.session
        if not s.think_done:
            return
        node = s.think_done[0]
        pre = set(s.mind) | set(mindmap.frontier(s.mind)) | set(s.think_done)
        # commit the unlock NOW (the sim owns state; the rite is theater --
        # quitting mid-ceremony can never lose an integrated thought)
        s.complete_focus(node)
        post = set(s.mind) | set(mindmap.frontier(s.mind)) | set(s.think_done)
        faith = mindmap.nodes()[node]["faith"]
        kind = "bloom" if faith > 0 else ("corrupt" if faith < 0 else "snap")
        self.rite = dict(node=node, kind=kind, t=0.0, new=post - pre,
                         shown=set(), rng=_node_rng(node),
                         fired=set())
        self.sel = node

    def _finish_rite(self, app) -> None:
        r = self.rite
        if r is None:
            return
        r["shown"] = set(r["new"])
        self.rite = None
        if self._ducked:
            app.audio.duck_ambience(1.0)
            self._ducked = False
        if self.session.think_done:  # a queue of thoughts: next rite
            self._start_rite(app)
        else:
            self._ensure_selection()
            # the newly revealed neighborhood relaxes live to make room:
            # the same real relaxation trajectory, scoped to just the new
            # nodes and the node they unfolded from, so the rest of the
            # graph holds still while that corner visibly settles
            self._start_settle(subset=set(r["new"]) | {r["node"]})

    def _rite_cue(self, app, key: str, sound: str, vol: float = 0.9) -> None:
        r = self.rite
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
        self._update_pin(dt)
        r = self.rite
        if r is None:
            return
        r["t"] += dt
        t = r["t"]
        if t >= RITE_IGNITE - 0.4:
            # ignition cue per grammar (sfx placeholders; separate pipeline)
            self._rite_cue(app, "ignite",
                           {"bloom": "rite_bloom", "snap": "rite_snap",
                            "corrupt": "rite_bloom"}[r["kind"]])
        if r["kind"] == "corrupt" and t >= RITE_SOUR:
            self._rite_cue(app, "sour", "rite_sour")
            if not self._ducked:
                app.audio.duck_ambience(0.35)  # the ambient dips
                self._ducked = True
        # new neighbors fade in only after the rite's main body
        if t >= RITE_UNFURL:
            r["shown"] = set(r["new"])
        if t >= RITE_DUR:
            self._finish_rite(app)

    # ------------------------------------------------------------------
    # drawing
    # ------------------------------------------------------------------

    def _ensure_overlay(self, size) -> "pygame.Surface":
        if self._overlay is None or self._overlay.get_size() != size:
            self._overlay = pygame.Surface(size, pygame.SRCALPHA)
        self._overlay.fill((0, 0, 0, 0))
        return self._overlay

    def draw(self, app, surf) -> None:
        self._draw_pod_bg(surf)
        if self.page == "fabricator":
            self._draw_fabricator(surf)
        else:
            self._draw_mind(surf)
        self._draw_chrome(surf)

    def _draw_pod_bg(self, surf) -> None:
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
        tabs = [("FABRICATOR", "fabricator"), ("MIND", "mind")]
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
        # wallet, right-aligned
        head = f"{s.components}c   {s.chassis} CHASSIS   {s.station_kits} KITS"
        img = f.render(head, True, (170, 200, 185))
        surf.blit(img, (w - img.get_width() - ui(24), ui(12)))
        # footer hints
        if self.rite is not None:
            hint = "" if self.rite["t"] < RITE_IGNITE else "any key: conclude the rite"
        elif self.page == "fabricator":
            hint = "W/S: select    ENTER: fabricate    TAB: mind    ESC/E: seal the pod"
        else:
            hint = "arrows: walk the map    ENTER: think about it    TAB: fabricator    ESC/E: seal the pod"
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

    def _draw_mind(self, surf) -> None:
        w, h = surf.get_size()
        s = self.session
        vis = self._visible()
        over = self._ensure_overlay((w, h))
        r = self.rite

        # region territory: each region names its own compass sector
        for region in mindmap.REGION_ORDER:
            if not any(mindmap.nodes()[nid]["region"] == region
                       for nid in vis):
                continue
            a = math.radians(mindmap._REGION_ANGLE_DEG[region])
            lx, ly = self._to_screen(surf, 1.16 * math.cos(a),
                                     1.16 * math.sin(a))
            img = get_font(10).render(mindmap.REGION_LABELS[region], True,
                                      tuple(c // 2 for c in REGION_COLOR[region]))
            w, h = surf.get_size()
            bx = max(ui(4), min(w - img.get_width() - ui(4),
                                lx - img.get_width() // 2))
            by = max(ui(34), min(h - ui(96), ly - ui(6)))
            surf.blit(img, (bx, by))

        # edges
        for a, b in self._edges(vis):
            ax, ay = self._to_screen(surf, *self._node_pos(a))
            bx, by = self._to_screen(surf, *self._node_pos(b))
            both = a in s.mind and b in s.mind
            col = (70, 86, 78) if both else (44, 52, 50)
            pygame.draw.line(surf, col, (ax, ay), (bx, by), max(1, ui(1)))

        # nodes
        for nid in sorted(vis):
            self._draw_node(surf, nid)

        # the rite draws above a dimmed graph
        if r is not None:
            dim = 150
            if r["t"] > RITE_UNFURL:
                dim = int(150 * max(0.0, (RITE_DUR - r["t"]) / (RITE_DUR - RITE_UNFURL)))
            over.fill((0, 0, 0, dim))
            self._draw_rite(surf, over)
        surf.blit(over, (0, 0))

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
        if nid == self.sel and self.rite is None:
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
        # every visible node gets its label now: mindmap.label_layout()
        # already proved (PBT, test_mindmap_layout.py) that no two labels
        # and no label/node pair ever collide at rest. During the rite,
        # non-focus labels dim to near-invisible during the glide/ignite
        # (the known "label sits on the animation" collision class is
        # gone by construction -- there's nothing legible there to sit on
        # top of the ceremony art) and the rite's own node draws no
        # ordinary label at all (the ceremony IS its name-card).
        r = self.rite
        if r is not None and nid == r["node"]:
            return
        alpha = 255
        if r is not None:
            if r["t"] < RITE_UNFURL:
                alpha = 26
            else:
                alpha = int(255 * min(1.0, (r["t"] - RITE_UNFURL) / 0.6))
            if alpha <= 0:
                return
        off = self._label_offset.get(nid)
        if off is None:
            return
        lx, ly = self._to_screen(surf, nx + off[0], ny + off[1])
        info = self._labels.get(nid, {})
        font_px = info.get("font_px", 16)
        col = BONE if nid == self.sel else (GOLD if queued else (
            132, 140, 136) if not owned else tuple(min(255, c + 40) for c in rcol))
        img = get_font(9).render(n["label"], True, col)
        if font_px < 16:
            k = font_px / 16.0
            img = pygame.transform.smoothscale(
                img, (max(1, int(img.get_width() * k)), max(1, int(img.get_height() * k))))
        if alpha < 255:
            img = img.copy()
            img.set_alpha(alpha)
        if info.get("leader") and r is None:
            # an escalated label (leader-line placement, per the layout's
            # own escalation ladder): a thin tick names which node it is
            pygame.draw.line(surf, (74, 80, 76), (x, y + rad), (lx, ly), 1)
        surf.blit(img, (lx - img.get_width() // 2, ly - img.get_height() // 2))

    def _draw_detail(self, surf) -> None:
        w, h = surf.get_size()
        s = self.session
        if self.sel is None:
            return
        n = mindmap.nodes()[self.sel]
        band_h = ui(58)
        y0 = h - band_h - ui(18)
        pygame.draw.rect(surf, (10, 11, 14), (0, y0, w, band_h))
        pygame.draw.line(surf, (40, 46, 44), (0, y0), (w, y0), 1)
        f = get_font(12)
        rcol = REGION_COLOR[n["region"]]
        surf.blit(f.render(n["label"].upper(), True, BONE), (ui(16), y0 + ui(5)))
        tag = get_font(10).render(mindmap.REGION_LABELS[n["region"]], True, rcol)
        surf.blit(tag, (ui(16), y0 + ui(22)))
        # status: what thinking here costs / has cost
        nid = self.sel
        if nid in s.mind:
            status = "INTEGRATED"
        elif nid in s.think_done:
            status = "THOUGHT COMPLETE - THE RITE AWAITS"
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
        img = get_font(10).render(status, True, VERDIGRIS)
        surf.blit(img, (ui(16), y0 + ui(38)))
        bx = ui(250)
        bf = get_font(10)
        for i, line in enumerate(_wrap(n.get("brief", ""), 48)[:3]):
            surf.blit(bf.render(line, True, (150, 148, 140)),
                      (bx, y0 + ui(6) + i * ui(14)))

    # ------------------------------------------------------------------
    # the three rite grammars
    # ------------------------------------------------------------------

    def _draw_rite(self, surf, over) -> None:
        r = self.rite
        t = r["t"]
        x, y = self._to_screen(surf, *self.layout[r["node"]])
        # ignition flare, shared by all three grammars: a soft bloom of
        # concentric light, then a bright expanding ring
        if t > RITE_GLIDE:
            k = min(1.0, (t - RITE_GLIDE) / (RITE_IGNITE - RITE_GLIDE))
            # the flare is transient: full at ignition, gone half a beat later
            fade = max(0.0, 1.0 - max(0.0, t - RITE_IGNITE) / 0.5)
            base = GOLD if r["kind"] != "snap" else MIRIAD
            if fade > 0.0:
                for gr, ga in ((ui(30), 34), (ui(18), 62), (ui(10), 110)):
                    pygame.draw.circle(over, (*base, int(ga * fade)), (x, y), gr)
                fr = ui(8) + int(ui(34) * k)
                alpha = int(210 * (1.0 - 0.7 * k) * fade)
                pygame.draw.circle(over, (*base, alpha), (x, y), fr,
                                   max(1, ui(2)))
        if r["kind"] == "bloom":
            self._rite_bloom(surf, over, x, y, t, sour_at=None)
        elif r["kind"] == "corrupt":
            self._rite_bloom(surf, over, x, y, t, sour_at=RITE_SOUR)
        else:
            self._rite_snap(surf, over, x, y, t)
        self._rite_reveal(surf, over, t)
        # the node itself, reborn bone-bright at the center
        if t > RITE_IGNITE:
            col = BONE if not (r["kind"] == "corrupt" and t > RITE_SOUR) else SOUR
            pygame.draw.circle(over, (*col, 255), (x, y), ui(7))
            pygame.draw.circle(over, (*REGION_COLOR[
                mindmap.nodes()[r["node"]]["region"]], 255), (x, y), ui(7),
                max(1, ui(1)))

    def _rite_bloom(self, surf, over, x, y, t, sour_at) -> None:
        """PHYLLOTACTIC BLOOM: petals unfurl at the golden angle, radius
        by sqrt(k) -- the sunflower law in machined light (Testator lane).
        With `sour_at`, the same bloom is betrayed mid-unfurl: color
        drains, petals go angular, growth staggers -- the corrupted rite."""
        r = self.rite
        if t <= RITE_IGNITE - 0.2:
            return
        n_petals = 21
        t0, t1 = RITE_IGNITE - 0.2, RITE_UNFURL
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

    def _rite_snap(self, surf, over, x, y, t) -> None:
        """MIRIAD SCHEMATIC SNAP: alignment guides flash, then the node
        assembles from clean vector segments with a drafting-table
        register -- the lane of the works of Man."""
        w, h = surf.get_size()
        # alignment guides sweep in during the glide and fade
        if t < RITE_IGNITE + 0.9:
            a = int(140 * max(0.0, 1.0 - abs(t - RITE_GLIDE) / 1.1))
            if a > 0:
                pygame.draw.line(over, (*MIRIAD, a), (0, y), (w, y), 1)
                pygame.draw.line(over, (*MIRIAD, a), (x, 0), (x, h), 1)
                for off in (-ui(30), ui(30)):
                    pygame.draw.line(over, (*MIRIAD, a // 2),
                                     (0, y + off), (w, y + off), 1)
                    pygame.draw.line(over, (*MIRIAD, a // 2),
                                     (x + off, 0), (x + off, h), 1)
        if t <= RITE_IGNITE - 0.2:
            return
        bright = (200, 214, 226)
        # eight ring segments snap in, each with a little overshoot
        segs = 8
        t0, t1 = RITE_IGNITE - 0.2, RITE_UNFURL - 0.4
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

    def _rite_reveal(self, surf, over, t) -> None:
        """New neighbors fade in only after the rite's main body: edges
        first (tendrils for the bloom, straight drafting lines for the
        snap, cracks for the corrupted rite), then the nodes themselves."""
        r = self.rite
        if t < RITE_UNFURL - 0.3 or not r["new"]:
            return
        u = min(1.0, (t - (RITE_UNFURL - 0.3)) / 1.2)
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
            # gate only trips at RITE_UNFURL+0.3s, by which point
            # r["shown"] (flipped at RITE_UNFURL) already made the
            # ordinary label pass draw the same name -- two draws of one
            # word, stacked.
            if u > 0.5:
                a = int(255 * (u - 0.5) * 2)
                rcol = REGION_COLOR[tbl[nid]["region"]]
                pygame.draw.circle(over, (22, 26, 26, a), (nx, ny), ui(6))
                pygame.draw.circle(over, (*[c // 2 for c in rcol], a),
                                   (nx, ny), ui(6), max(1, ui(1)))
