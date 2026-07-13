"""Mouse trajectory model for the human-realistic bot (BOT_REALISM_DESIGN.md §2).

A real player's aim is a smoothed, velocity- and acceleration-bounded
trajectory toward wherever they want to look, not a teleport and not a
constant-velocity lerp. This model keeps persistent position/velocity state
and steers it toward a target aim point every tick:

  - velocity and acceleration are hard-clamped (no teleports);
  - large flicks overshoot the target and correct back (Fitts's-law-ish:
    the bigger the flick, the more overshoot);
  - small corrections undershoot slightly, the way careful tracking does;
  - at rest (no target change, cursor already near target) the point drifts
    with a slow persistent jitter instead of freezing dead-still.

All randomness comes from a `Random` seeded once at construction -- runs
replay identically for a given seed (design doc §8).
"""

from __future__ import annotations

from random import Random

# internal-screen units (matches InputFrame.ax/ay, 480x270 space) per second
MAX_SPEED = 2200.0
MAX_ACCEL = 26000.0
# how far past the target a large flick overshoots, as a fraction of the
# flick distance; big flicks overshoot more, tiny ones barely at all
OVERSHOOT_FRACTION = 0.14
OVERSHOOT_DISTANCE_FLOOR = 120.0
# idle jitter: continuous small drift around the resting point
IDLE_JITTER_AMPLITUDE = 2.0
IDLE_JITTER_SPEED = 1.6


class MouseModel:
    def __init__(self, x: float, y: float, seed: int = 0):
        self.x, self.y = x, y
        self.vx, self.vy = 0.0, 0.0
        self.rng = Random(seed)
        self._overshoot_target: tuple[float, float] | None = None
        self._t = 0.0

    def step(self, target_x: float, target_y: float, dt: float) -> tuple[float, float]:
        """Advance the model one tick toward `target_x, target_y`; returns
        the new (x, y). Call every sim tick with dt = 1/60."""
        self._t += dt
        dx, dy = target_x - self.x, target_y - self.y
        dist = (dx * dx + dy * dy) ** 0.5

        if dist < 0.5:
            # at rest near the target: drift instead of freezing
            jx = self.rng.uniform(-1.0, 1.0)
            jy = self.rng.uniform(-1.0, 1.0)
            self.vx += jx * IDLE_JITTER_SPEED * dt * 30.0
            self.vy += jy * IDLE_JITTER_SPEED * dt * 30.0
            speed = (self.vx ** 2 + self.vy ** 2) ** 0.5
            cap = IDLE_JITTER_AMPLITUDE * 20.0
            if speed > cap:
                self.vx, self.vy = self.vx / speed * cap, self.vy / speed * cap
        else:
            # steer toward an overshoot point on large flicks, the real
            # target on small ones -- this is what produces the
            # overshoot-and-correct signature on fast flicks and the
            # undershoot-then-settle signature on careful tracking
            if dist > OVERSHOOT_DISTANCE_FLOOR:
                ox, oy = dx / dist, dy / dist
                over = dist * OVERSHOOT_FRACTION
                aim_x = target_x + ox * over
                aim_y = target_y + oy * over
            else:
                aim_x, aim_y = target_x, target_y

            ax_, ay_ = aim_x - self.x, aim_y - self.y
            adist = (ax_ * ax_ + ay_ * ay_) ** 0.5 or 1e-6
            ux, uy = ax_ / adist, ay_ / adist

            desired_speed = min(MAX_SPEED, MAX_SPEED * min(1.0, adist / 60.0))
            desired_vx, desired_vy = ux * desired_speed, uy * desired_speed

            dvx, dvy = desired_vx - self.vx, desired_vy - self.vy
            dv = (dvx * dvx + dvy * dvy) ** 0.5
            max_dv = MAX_ACCEL * dt
            if dv > max_dv:
                dvx, dvy = dvx / dv * max_dv, dvy / dv * max_dv
            self.vx += dvx
            self.vy += dvy

        speed = (self.vx ** 2 + self.vy ** 2) ** 0.5
        if speed > MAX_SPEED:
            self.vx, self.vy = self.vx / speed * MAX_SPEED, self.vy / speed * MAX_SPEED

        self.x += self.vx * dt
        self.y += self.vy * dt
        return self.x, self.y
