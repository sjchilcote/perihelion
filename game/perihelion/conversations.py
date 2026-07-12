"""Between-sortie conversations — BLANKED by director order (2026-07-11).

The generated placeholder script (and its compositor) is retired; the
director hand-writes all dialogue. His scenes will arrive in an
engine-checked markup (see DIALOGUE_SCAFFOLD.md's markup note) with its
own loader. Until then every gap plays no conversation.

What remains here is the stable interface the App wires through:
`conversation_for(gap, trust, flags)` -> ConversationBundle | None, plus
the speaker constants ConversationScene renders with. Trust/flag
persistence (App._add_trust/_add_flags) stays live — his scripts will
drive the same state.
"""

from __future__ import annotations

from dataclasses import dataclass, field

RATIO = "RATIO"
COMMANDO = "COMMANDO"


@dataclass
class ConversationBundle:
    """Kept structurally identical to the compositor-era bundle so the
    App-side wiring (lines + unconditional base effects reported once at
    scene completion) carries over unchanged to the real script loader."""
    lines: list = field(default_factory=list)
    base_trust: int = 0
    base_flags: tuple = ()


def conversation_for(gap: int, trust: int = 0, flags=()) -> ConversationBundle | None:
    """No placeholder content: every gap is silent until the director's
    hand-written scenes land with their real loader."""
    return None
