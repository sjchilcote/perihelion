"""Sonnet tactical layer (BOT_REALISM_DESIGN.md §7): pause-and-think policy
consults for `HumanBot`.

Consults are rate-limited and event-driven (run start, a new polygon entered,
HP crossing a low-HP threshold, or the bot going unusually long without
reaching a new polygon), never per-tick -- the diegetic equivalent of a player
stopping to think. Each consult sends a compact JSON digest of the current
situation to `claude -p` (headless CLI, sonnet model) and parses back a
policy object; `HumanBot.policy` is updated with whatever it returns.
Sonnet sets policy, never keystrokes: it is never in the reflex loop, and a
consult failure (timeout, malformed JSON, CLI missing) just keeps the last
policy -- it must never crash or stall the game loop.

`--bot human` runs fine without this module at all (see `HumanBot`'s default
static policy); `--bot human --tactician` wires this in.
"""

from __future__ import annotations

import json
import subprocess
import time
from random import Random

CONSULT_MIN_INTERVAL_S = 25.0
STUCK_PROGRESS_TICKS = 60 * 45  # ~45s without reaching a new polygon
LOW_HP_FRACTION = 0.4
CONSULT_TIMEOUT_S = 45.0

POLICY_KEYS = {"movement", "risk", "target_priority", "intent"}
VALID_MOVEMENT = {"explore", "advance-carefully", "hold-choke", "kite",
                   "retreat-and-resupply", "rush-objective"}
VALID_RISK = {"cautious", "normal", "aggressive"}

_PROMPT_TEMPLATE = (
    "You are the tactical adviser for a game-playing bot in a top-down "
    "shooter. You will be given a compact JSON digest of its current "
    "situation (position, HP, weapons/ammo, threats already encountered in "
    "this polygon, and why this consult was triggered). Reply with ONLY a "
    "single JSON object, no prose, no markdown fences, with exactly these "
    "keys:\n"
    '  "movement": one of explore | advance-carefully | hold-choke | kite | '
    "retreat-and-resupply | rush-objective\n"
    '  "risk": one of cautious | normal | aggressive\n'
    '  "target_priority": a list of enemy-kind strings, most important '
    "first, or null if no preference\n"
    '  "intent": a short human-readable sentence describing the plan\n\n'
    "Digest:\n{digest}"
)


class Tactician:
    """Owns consult rate-limiting/triggers for one `HumanBot` instance and
    logs every digest+policy pair it produces (for `events.jsonl` and for
    post-hoc marketing narration -- the bot's "thought process" is real)."""

    def __init__(self, bot, seed: int = 0, model: str = "sonnet",
                 enabled: bool = True, on_consult=None):
        self.bot = bot
        self.rng = Random(seed)
        self.model = model
        self.enabled = enabled
        self.on_consult = on_consult  # callback(dict) for events.jsonl logging
        self.log: list[dict] = []
        self._last_consult_t = float("-inf")
        self._last_polygon: int | None = None
        self._last_new_polygon_tick = 0
        self._was_low_hp = False

    def _trigger_reason(self, snapshot: dict, tick: int) -> str | None:
        ppolygon = snapshot["polygon"]
        if self._last_polygon is None:
            return "run-start"
        if ppolygon != self._last_polygon:
            return "new-polygon"
        max_hp = max(1, snapshot.get("max_hp", 100) or 100)
        low = (snapshot["hp"] / max_hp) < LOW_HP_FRACTION
        if low and not self._was_low_hp:
            return "low-hp"
        if tick - self._last_new_polygon_tick > STUCK_PROGRESS_TICKS:
            return "stuck"
        return None

    def maybe_consult(self, snapshot: dict, session, tick: int,
                       now: float | None = None) -> dict | None:
        """Call once per game tick. Returns the consult record if a consult
        actually ran this tick, else None (the overwhelmingly common case)."""
        now = time.monotonic() if now is None else now
        ppolygon = snapshot["polygon"]
        max_hp = max(1, snapshot.get("max_hp", 100) or 100)
        low_hp = (snapshot["hp"] / max_hp) < LOW_HP_FRACTION

        reason = self._trigger_reason(snapshot, tick) if self.enabled else None

        if ppolygon != self._last_polygon:
            self._last_new_polygon_tick = tick
        self._last_polygon = ppolygon
        self._was_low_hp = low_hp

        if reason is None:
            return None
        if now - self._last_consult_t < CONSULT_MIN_INTERVAL_S:
            return None
        self._last_consult_t = now

        digest = self._build_digest(snapshot, session, reason, tick)
        policy, error = self._consult(digest)
        if policy:
            self.bot.policy.update(policy)
        record = dict(tick=tick, reason=reason, digest=digest, policy=policy,
                      error=error)
        self.log.append(record)
        if self.on_consult is not None:
            self.on_consult(record)
        return record

    def _build_digest(self, snapshot: dict, session, reason: str, tick: int) -> dict:
        threats: dict[str, int] = {}
        for e in snapshot["enemies"]:
            if e.get("hops") == 0:
                threats[e["kind"]] = threats.get(e["kind"], 0) + 1
        return dict(
            reason=reason, tick=tick, polygon=snapshot["polygon"],
            hp=snapshot["hp"], max_hp=snapshot.get("max_hp"),
            weapon=snapshot["weapon"], weapons=snapshot["weapons"],
            ammo=snapshot["ammo"], threats_in_polygon=threats,
            exit_gate_remaining=snapshot.get("exit_gate_remaining", 0),
            exit_key_needed=snapshot.get("exit_key_needed") or None,
            current_policy=dict(self.bot.policy),
        )

    def _consult(self, digest: dict) -> tuple[dict | None, str | None]:
        """Returns (policy, error). A failed consult keeps the last policy
        (the reflex loop must never stall on the adviser), but the failure
        reason is always surfaced in the consult record -- a null policy
        with no explanation is a swallowed error."""
        prompt = _PROMPT_TEMPLATE.format(digest=json.dumps(digest))
        try:
            result = subprocess.run(
                ["claude", "-p", prompt, "--model", self.model,
                 "--output-format", "json"],
                capture_output=True, text=True, timeout=CONSULT_TIMEOUT_S)
        except subprocess.TimeoutExpired:
            return None, f"timeout after {CONSULT_TIMEOUT_S}s"
        except OSError as exc:
            return None, f"claude CLI unavailable: {exc}"
        if result.returncode != 0:
            return None, (f"claude exited {result.returncode}: "
                          f"{result.stderr[:300]}")
        try:
            payload = json.loads(result.stdout)
            text = payload["result"] if isinstance(payload, dict) else payload
            policy = json.loads(text) if isinstance(text, str) else text
        except (json.JSONDecodeError, KeyError, TypeError) as exc:
            return None, f"unparseable response ({exc}): {result.stdout[:300]}"
        if not isinstance(policy, dict):
            return None, f"non-object policy: {policy!r}"
        policy = {k: v for k, v in policy.items() if k in POLICY_KEYS}
        if policy.get("movement") not in VALID_MOVEMENT:
            policy.pop("movement", None)
        if policy.get("risk") not in VALID_RISK:
            policy.pop("risk", None)
        if not policy:
            return None, "no valid keys in policy response"
        return policy, None
