"""The world call medium (U7, DESIGN_7_25 §1b).

"Only one agent transmits at a time" is a property of the MEDIUM, not
of the hub — one radio channel for the whole world. A scout takes the
single lease, broadcasts, and on completion leaves an IMPRINT (chamber,
position, tick, caller class) that expires in ~15 seconds. Interruption
or death releases the lease. A consumer samples imprints and consumes
one whether or not it acts on it — calls never queue waiting for
resources, and the imprint carries no reserve demand, no hub state, no
desired enemy mix. That is how the caller stays ignorant of the marrow
while the one-transmitter rule still holds.

This module knows nothing about scouts, hubs, or the sim: ids, ticks,
and positions only.
"""
from __future__ import annotations

from dataclasses import dataclass

IMPRINT_TTL_TICKS = 15 * 60


@dataclass(frozen=True, slots=True)
class CallImprint:
    chamber: int
    position: tuple[float, float]
    tick: int
    caller_class: str
    expires_tick: int


@dataclass(frozen=True, slots=True)
class CallLease:
    caller_id: int
    tick: int


class CallMedium:
    __slots__ = ("_lease", "_imprints")

    def __init__(self) -> None:
        self._lease: CallLease | None = None
        self._imprints: list[CallImprint] = []

    def try_lease(self, caller_id: int, tick: int) -> CallLease | None:
        """At most one active lease in the world. A holder re-asking gets
        its own lease back; anyone else gets None and stays silent."""
        if self._lease is not None and self._lease.caller_id != caller_id:
            return None
        if self._lease is None:
            self._lease = CallLease(caller_id=caller_id, tick=tick)
        return self._lease

    def holder(self) -> int | None:
        return self._lease.caller_id if self._lease is not None else None

    def release(self, caller_id: int) -> None:
        """Interruption, death, or completion frees the channel."""
        if self._lease is not None and self._lease.caller_id == caller_id:
            self._lease = None

    def complete(self, caller_id: int, chamber: int, position, tick: int,
                 caller_class: str) -> CallImprint | None:
        """A finished broadcast: the lease is spent, the imprint is left
        in the medium. Only the holder can complete."""
        if self._lease is None or self._lease.caller_id != caller_id:
            return None
        self._lease = None
        imp = CallImprint(chamber=chamber,
                          position=(float(position[0]), float(position[1])),
                          tick=tick, caller_class=caller_class,
                          expires_tick=tick + IMPRINT_TTL_TICKS)
        self._imprints.append(imp)
        return imp

    def consume_one(self, tick: int) -> CallImprint | None:
        """Oldest live imprint, removed whether or not the consumer acts
        on it — a dry call is spent, never queued."""
        self._imprints = [i for i in self._imprints if i.expires_tick > tick]
        if not self._imprints:
            return None
        return self._imprints.pop(0)

    def pending(self, tick: int) -> int:
        return sum(1 for i in self._imprints if i.expires_tick > tick)
