"""Runtime dialogue compositor for DIALOGUE_SCRIPT.md (v2, commit b12d44b).

Parses the nine RATIO/COMMANDO relay scenes -- lines, three-option CHOICE
blocks with mandatory [STANCE] labels, inline effect/catch_effect
annotations, and `<<IF ...>> <<ELSEIF ...>> <<ELSE>> <<END>>` gates keyed on
flags or on the trust score -- into a small AST, then composites a given
scene against persistent play state (flags set so far, trust total) into a
sequence of resolved lines plus (if reached) a three-way choice.

The parser is strict: a malformed gate, an unterminated `<<IF>>`, an
unknown speaker, a CHOICE block that isn't exactly the three mandated
stances, or an effects/catch_effects clause that doesn't parse raises
`ScriptParseError` at load time with scene + line context. Nothing is ever
silently dropped -- a checker that returns "all clear" on broken input is a
lie.

Gate syntax cases handled (per the script's own "Gate syntax cases used"
section): flag-keyed 3-way (`IF/ELSEIF/ELSE/END`), flag-keyed 2-way
(`IF/ELSE/END`), flag-keyed single-sided (`IF/END`, renders nothing if
false), score-threshold 2-way and single-sided, score-threshold 3-way,
score-threshold single-sided as a scene-spine gate (removes the CHOICE
entirely when false -- Scene 8), the compound boolean OR-of-flags gate, and
arbitrary nesting (Scene 8's disclosure block nests seven further gates,
including its own CHOICE, inside the outer `trust>=0` gate).

Data file: shipped at `game/perihelion/data/dialogue_script.md` (a copy of
the repo-root `DIALOGUE_SCRIPT.md`, kept in sync manually -- see the
director's note if this ever drifts) so `uv run python -m perihelion` works
from any cwd; falls back to searching upward from this file for a
repo-root `DIALOGUE_SCRIPT.md` if the packaged copy is missing.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path

RATIO = "RATIO"
COMMANDO = "COMMANDO"
SPEAKERS = {RATIO, COMMANDO}

STANCES = ("INQUISITIVE", "MISSION", "HOSTILE")

# Faith/apostasy scaffold (front matter, "Faith/apostasy" section): bluff-
# and zealotry-flags serve as provisional faith input until the Mind Map
# (9.2) ships. Read-only mirror; the mind map owns real faith.
FAITH_SCAFFOLD_FLAGS = frozenset({
    "claimed_container_knowledge", "called_her_apostate", "compounded_bluff",
    "confessed_bluff", "doubled_down_after_catch", "called_her_hypocrite",
    "claimed_doctrinal_finding", "accused_dehumanization",
    "claimed_no_hesitation", "accused_kinship_corruption",
    "withheld_deep_scan", "caught_withholding", "mission_overrides_verdict",
    "blamed_ratio_for_failure",
})


class ScriptParseError(ValueError):
    pass


def _ctx(scene_idx: int | None, lineno: int, msg: str) -> str:
    where = f"scene {scene_idx}" if scene_idx is not None else "front matter"
    return f"DIALOGUE_SCRIPT.md {where}, line {lineno}: {msg}"


# ---------------------------------------------------------------------------
# AST
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class FlagAtom:
    name: str

    def eval(self, flags: frozenset, trust: int) -> bool:
        return self.name in flags


@dataclass(frozen=True)
class TrustAtom:
    op: str  # ">=" or "<="
    n: int

    def eval(self, flags: frozenset, trust: int) -> bool:
        return trust >= self.n if self.op == ">=" else trust <= self.n


@dataclass(frozen=True)
class Condition:
    atoms: tuple  # OR'd together

    def eval(self, flags: frozenset, trust: int) -> bool:
        return any(a.eval(flags, trust) for a in self.atoms)


@dataclass(frozen=True)
class Line:
    speaker: str
    text: str
    catch_trust: int = 0
    catch_sets: tuple = ()


@dataclass(frozen=True)
class ChoiceOption:
    stance: str
    text: str
    trust_delta: int
    bluff: bool
    sets: tuple


@dataclass(frozen=True)
class Choice:
    options: tuple  # exactly 3 ChoiceOption, order INQUISITIVE/MISSION/HOSTILE


@dataclass(frozen=True)
class Gate:
    # list of (Condition | None, tuple[node, ...]); None condition = ELSE
    branches: tuple

    def select(self, flags: frozenset, trust: int):
        for cond, body in self.branches:
            if cond is None or cond.eval(flags, trust):
                return body
        return None


@dataclass(frozen=True)
class Scene:
    idx: int
    title: str
    nodes: tuple  # top-level sequence of Line | Choice | Gate


# ---------------------------------------------------------------------------
# tokenizing + parsing
# ---------------------------------------------------------------------------

_SCENE_RE = re.compile(r"^## SCENE (\d+):\s*(.*)$")
_IF_RE = re.compile(r"^<<IF\s+(.+?)\s*>>$")
_ELSEIF_RE = re.compile(r"^<<ELSEIF\s+(.+?)\s*>>$")
_ELSE_RE = re.compile(r"^<<ELSE>>$")
_END_RE = re.compile(r"^<<END>>$")
_SPEAKER_RE = re.compile(r"^(RATIO|COMMANDO):\s?(.*)$")
_CHOICE_HDR_RE = re.compile(r"^>>\s*CHOICE\b")
_OPTION_RE = re.compile(r"^\s*\[(\w+)\]\s*(.*)$")
_CATCH_RE = re.compile(r"^(.*?)\s*->\s*catch_effects:\s*(.+)$")
_EFFECTS_RE = re.compile(r"^(.*?)\s*->\s*effects:\s*(.+)$")
_FLAG_ATOM_RE = re.compile(r"^flag:(\w+)$")
_TRUST_ATOM_RE = re.compile(r"^trust(>=|<=)(-?\d+)$")
_TRUST_TERM_RE = re.compile(r"^trust([+-]\d+)$")


def _parse_condition(text: str, scene_idx: int, lineno: int) -> Condition:
    atoms = []
    for part in text.split(" OR "):
        part = part.strip()
        m = _FLAG_ATOM_RE.match(part)
        if m:
            atoms.append(FlagAtom(m.group(1)))
            continue
        m = _TRUST_ATOM_RE.match(part)
        if m:
            atoms.append(TrustAtom(m.group(1), int(m.group(2))))
            continue
        raise ScriptParseError(_ctx(scene_idx, lineno,
            f"malformed gate condition atom {part!r} (want flag:X or trust>=/<=N)"))
    if not atoms:
        raise ScriptParseError(_ctx(scene_idx, lineno, "empty gate condition"))
    return Condition(tuple(atoms))


def _parse_effects_clause(clause: str, scene_idx: int, lineno: int) -> tuple[int, bool, tuple]:
    """Parses `trust+1; sets: X, Y` / `trust+0, bluff; sets: (none)`."""
    if ";" not in clause:
        raise ScriptParseError(_ctx(scene_idx, lineno,
            f"effects clause missing ';' before sets: {clause!r}"))
    score_part, sets_part = clause.split(";", 1)
    terms = [t.strip() for t in score_part.split(",")]
    if not terms:
        raise ScriptParseError(_ctx(scene_idx, lineno, f"empty effects clause {clause!r}"))
    m = _TRUST_TERM_RE.match(terms[0])
    if not m:
        raise ScriptParseError(_ctx(scene_idx, lineno,
            f"effects clause must start with trust+/-N, got {terms[0]!r}"))
    delta = int(m.group(1))
    bluff = False
    for extra in terms[1:]:
        if extra == "bluff":
            bluff = True
        else:
            raise ScriptParseError(_ctx(scene_idx, lineno,
                f"unknown effects term {extra!r}"))
    sets_part = sets_part.strip()
    if not sets_part.startswith("sets:"):
        raise ScriptParseError(_ctx(scene_idx, lineno,
            f"effects clause missing 'sets:' {clause!r}"))
    sets_text = sets_part[len("sets:"):].strip()
    if sets_text == "(none)":
        flags: tuple = ()
    else:
        flags = tuple(f.strip() for f in sets_text.split(","))
        for f in flags:
            if not re.match(r"^\w+$", f):
                raise ScriptParseError(_ctx(scene_idx, lineno, f"malformed flag name {f!r}"))
    return delta, bluff, flags


def _parse_catch_clause(clause: str, scene_idx: int, lineno: int) -> tuple[int, tuple]:
    """Parses `trust-1` / `trust-2; sets: caught_withholding`."""
    if ";" in clause:
        score_part, sets_part = clause.split(";", 1)
    else:
        score_part, sets_part = clause, None
    m = _TRUST_TERM_RE.match(score_part.strip())
    if not m:
        raise ScriptParseError(_ctx(scene_idx, lineno,
            f"catch_effects clause must be trust+/-N[; sets: ...], got {clause!r}"))
    delta = int(m.group(1))
    sets: tuple = ()
    if sets_part is not None:
        sets_part = sets_part.strip()
        if not sets_part.startswith("sets:"):
            raise ScriptParseError(_ctx(scene_idx, lineno,
                f"catch_effects clause malformed tail {clause!r}"))
        sets_text = sets_part[len("sets:"):].strip()
        if sets_text and sets_text != "(none)":
            sets = tuple(f.strip() for f in sets_text.split(","))
    return delta, sets


class _Tok:
    __slots__ = ("kind", "payload", "lineno")

    def __init__(self, kind, payload, lineno):
        self.kind = kind
        self.payload = payload
        self.lineno = lineno


def _tokenize(raw_lines: list[str], scene_idx: int, start_lineno: int) -> list[_Tok]:
    tokens: list[_Tok] = []
    i = 0
    n = len(raw_lines)
    while i < n:
        lineno = start_lineno + i
        line = raw_lines[i].rstrip("\n")
        stripped = line.strip()
        i += 1
        if not stripped or stripped == "---":
            continue
        if stripped.startswith("<<"):
            m = _IF_RE.match(stripped)
            if m:
                tokens.append(_Tok("IF", _parse_condition(m.group(1), scene_idx, lineno), lineno))
                continue
            m = _ELSEIF_RE.match(stripped)
            if m:
                tokens.append(_Tok("ELSEIF", _parse_condition(m.group(1), scene_idx, lineno), lineno))
                continue
            if _ELSE_RE.match(stripped):
                tokens.append(_Tok("ELSE", None, lineno))
                continue
            if _END_RE.match(stripped):
                tokens.append(_Tok("END", None, lineno))
                continue
            raise ScriptParseError(_ctx(scene_idx, lineno, f"malformed gate token {stripped!r}"))
        if _CHOICE_HDR_RE.match(stripped):
            options = []
            while i < n:
                opt_lineno = start_lineno + i
                opt_line = raw_lines[i].rstrip("\n")
                if not opt_line.strip():
                    i += 1
                    break
                m = _OPTION_RE.match(opt_line)
                if not m:
                    break
                stance, rest = m.group(1), m.group(2)
                i += 1
                if stance not in STANCES:
                    raise ScriptParseError(_ctx(scene_idx, opt_lineno,
                        f"unknown stance label [{stance}] (want one of {STANCES})"))
                em = _EFFECTS_RE.match(rest)
                if not em:
                    raise ScriptParseError(_ctx(scene_idx, opt_lineno,
                        f"CHOICE option missing '-> effects: ...' clause: {rest!r}"))
                text, clause = em.group(1).strip(), em.group(2).strip()
                if not text:
                    raise ScriptParseError(_ctx(scene_idx, opt_lineno,
                        "CHOICE option has no dialogue text"))
                delta, bluff, sets = _parse_effects_clause(clause, scene_idx, opt_lineno)
                options.append(ChoiceOption(stance, text, delta, bluff, sets))
            if len(options) != 3:
                raise ScriptParseError(_ctx(scene_idx, lineno,
                    f"CHOICE block must have exactly 3 stance options, got {len(options)}"))
            got_stances = tuple(o.stance for o in options)
            if set(got_stances) != set(STANCES):
                raise ScriptParseError(_ctx(scene_idx, lineno,
                    f"CHOICE block stances {got_stances} != mandated {STANCES}"))
            tokens.append(_Tok("CHOICE", Choice(tuple(options)), lineno))
            continue
        m = _SPEAKER_RE.match(stripped)
        if m:
            speaker, rest = m.group(1), m.group(2)
            cm = _CATCH_RE.match(rest)
            if cm:
                text, clause = cm.group(1).strip(), cm.group(2).strip()
                delta, sets = _parse_catch_clause(clause, scene_idx, lineno)
            else:
                text, delta, sets = rest.strip(), 0, ()
            if not text:
                raise ScriptParseError(_ctx(scene_idx, lineno, "dialogue line has no text"))
            tokens.append(_Tok("LINE", Line(speaker, text, delta, sets), lineno))
            continue
        raise ScriptParseError(_ctx(scene_idx, lineno, f"unrecognized line {stripped!r}"))
    return tokens


def _parse_nodes(tokens: list[_Tok], pos: int, scene_idx: int, stop: frozenset):
    nodes = []
    while pos < len(tokens):
        tok = tokens[pos]
        if tok.kind in stop:
            return tuple(nodes), pos
        if tok.kind == "IF":
            gate, pos = _parse_gate(tokens, pos, scene_idx)
            nodes.append(gate)
        elif tok.kind in ("ELSEIF", "ELSE", "END"):
            raise ScriptParseError(_ctx(scene_idx, tok.lineno,
                f"<<{tok.kind}>> with no matching <<IF>>"))
        elif tok.kind in ("LINE", "CHOICE"):
            nodes.append(tok.payload)
            pos += 1
        else:
            raise ScriptParseError(_ctx(scene_idx, tok.lineno, f"unexpected token {tok.kind}"))
    if stop:
        raise ScriptParseError(_ctx(scene_idx, tokens[-1].lineno if tokens else 0,
            "unterminated <<IF>> gate: missing <<END>>"))
    return tuple(nodes), pos


def _parse_gate(tokens: list[_Tok], pos: int, scene_idx: int):
    if_tok = tokens[pos]
    cond = if_tok.payload
    pos += 1
    branches = []
    body, pos = _parse_nodes(tokens, pos, scene_idx, frozenset({"ELSEIF", "ELSE", "END"}))
    branches.append((cond, body))
    while pos < len(tokens) and tokens[pos].kind == "ELSEIF":
        cond2 = tokens[pos].payload
        pos += 1
        body2, pos = _parse_nodes(tokens, pos, scene_idx, frozenset({"ELSEIF", "ELSE", "END"}))
        branches.append((cond2, body2))
    if pos < len(tokens) and tokens[pos].kind == "ELSE":
        pos += 1
        else_body, pos = _parse_nodes(tokens, pos, scene_idx, frozenset({"END"}))
        branches.append((None, else_body))
    if pos >= len(tokens) or tokens[pos].kind != "END":
        raise ScriptParseError(_ctx(scene_idx, if_tok.lineno,
            "<<IF>> gate never reaches a matching <<END>>"))
    pos += 1  # consume END
    return Gate(tuple(branches)), pos


def _parse_scene(idx: int, title: str, body_lines: list[str], start_lineno: int) -> Scene:
    tokens = _tokenize(body_lines, idx, start_lineno)
    nodes, pos = _parse_nodes(tokens, 0, idx, frozenset())
    if pos != len(tokens):
        raise ScriptParseError(_ctx(idx, tokens[pos].lineno, "trailing unparsed content"))
    return Scene(idx, title, nodes)


def parse_script(text: str) -> list[Scene]:
    lines = text.splitlines()
    headers = []  # (line_index, scene_idx, title)
    for i, line in enumerate(lines):
        m = _SCENE_RE.match(line)
        if m:
            headers.append((i, int(m.group(1)), m.group(2).strip()))
    if not headers:
        raise ScriptParseError("no '## SCENE N:' headers found in DIALOGUE_SCRIPT.md")
    scenes = []
    for k, (line_idx, scene_idx, title) in enumerate(headers):
        end = headers[k + 1][0] if k + 1 < len(headers) else len(lines)
        body = lines[line_idx + 1:end]
        scenes.append(_parse_scene(scene_idx, title, body, start_lineno=line_idx + 2))
    expected = list(range(len(scenes)))
    got = [s.idx for s in scenes]
    if got != expected:
        raise ScriptParseError(f"scene indices {got} are not the expected contiguous {expected}")
    return scenes


# ---------------------------------------------------------------------------
# locating + loading the data file
# ---------------------------------------------------------------------------


def _find_script_path() -> Path:
    packaged = Path(__file__).parent / "data" / "dialogue_script.md"
    if packaged.exists():
        return packaged
    here = Path(__file__).resolve()
    for parent in here.parents:
        candidate = parent / "DIALOGUE_SCRIPT.md"
        if candidate.exists():
            return candidate
    raise ScriptParseError(
        "DIALOGUE_SCRIPT.md not found: no game/perihelion/data/dialogue_script.md "
        "and no repo-root DIALOGUE_SCRIPT.md above this file")


@lru_cache(maxsize=1)
def load_scenes() -> tuple[Scene, ...]:
    path = _find_script_path()
    return tuple(parse_script(path.read_text(encoding="utf-8")))


# ---------------------------------------------------------------------------
# compositing: resolve a scene's nodes against (flags, trust)
# ---------------------------------------------------------------------------


class _State:
    __slots__ = ("flags", "trust")

    def __init__(self, flags: set, trust: int):
        self.flags = set(flags)
        self.trust = trust


def _apply_catch(line: Line, state: _State) -> None:
    if line.catch_trust or line.catch_sets:
        state.trust += line.catch_trust
        state.flags.update(line.catch_sets)


def _walk(nodes: tuple, state: _State):
    """Generator yielding ('line', speaker, text) for every resolved line in
    document order and, at most once per scene, ('choice', Choice). The
    caller must `.send(option_index)` to resume after a 'choice' yield;
    the chosen option's trust/flag effects are applied to `state` before
    the walk continues into whatever follows the CHOICE in the tree."""
    for node in nodes:
        if isinstance(node, Line):
            _apply_catch(node, state)
            yield ("line", node.speaker, node.text)
        elif isinstance(node, Choice):
            chosen = yield ("choice", node)
            opt = node.options[chosen]
            state.trust += opt.trust_delta
            state.flags.update(opt.sets)
        elif isinstance(node, Gate):
            branch = node.select(frozenset(state.flags), state.trust)
            if branch is not None:
                yield from _walk(branch, state)
        else:
            raise TypeError(f"unknown node type {node!r}")


@dataclass
class CompositedOption:
    stance: str
    text: str
    trust_delta: int  # incremental, on top of the scene's base_trust_delta
    bluff: bool
    flags: tuple  # incremental flags set by picking this option (own + downstream catches)
    reply_lines: list  # RATIO text lines that follow, in order


@dataclass
class CompositedScene:
    idx: int
    title: str
    pre_lines: list  # [(speaker, text), ...] rendered unconditionally before any choice
    base_trust_delta: int  # from catch_effects reached before the choice (or the whole scene)
    base_flags: tuple  # flags set unconditionally, same scope
    options: list | None  # None if this scene offers no choice at the given state


def composite_scene(scene: Scene, flags, trust: int) -> CompositedScene:
    flags = frozenset(flags)
    state0 = _State(flags, trust)
    gen = _walk(scene.nodes, state0)
    pre = []
    choice_node = None
    for item in gen:
        if item[0] == "choice":
            choice_node = item[1]
            break
        pre.append((item[1], item[2]))

    base_trust_delta = state0.trust - trust
    base_flags = tuple(sorted(state0.flags - flags))

    if choice_node is None:
        return CompositedScene(scene.idx, scene.title, pre, base_trust_delta, base_flags, None)

    options = []
    for i in range(len(choice_node.options)):
        opt_spec = choice_node.options[i]
        st = _State(flags, trust)
        gen2 = _walk(scene.nodes, st)
        for item in gen2:
            if item[0] == "choice":
                break
        else:
            raise ScriptParseError(
                f"scene {scene.idx}: choice vanished on re-walk (non-deterministic gate?)")
        reply_items = []
        try:
            first = gen2.send(i)
            reply_items.append(first)
            reply_items.extend(gen2)
        except StopIteration:
            pass
        reply_lines = []
        for kind, spk, txt in reply_items:
            if spk != RATIO:
                raise ScriptParseError(
                    f"scene {scene.idx}: post-choice reply line spoken by {spk!r}, "
                    "expected RATIO (per-choice inline non-RATIO replies aren't in this script)")
            reply_lines.append(txt)
        trust_delta = st.trust - state0.trust
        flags_added = tuple(sorted(st.flags - state0.flags))
        options.append(CompositedOption(opt_spec.stance, opt_spec.text, trust_delta,
                                         opt_spec.bluff, flags_added, reply_lines))

    return CompositedScene(scene.idx, scene.title, pre, base_trust_delta, base_flags, options)


def build_conversation_lines(composited: CompositedScene) -> list[tuple]:
    """Turns a CompositedScene into the ConversationScene-compatible turn
    list: plain (speaker, text) turns plus, if a choice was reached, one
    ("CHOICE", [(stance, text, trust_delta, flags, *reply_lines), ...]) turn."""
    lines: list[tuple] = list(composited.pre_lines)
    if composited.options:
        options = tuple(
            (o.stance, o.text, o.trust_delta, list(o.flags), *o.reply_lines)
            for o in composited.options
        )
        lines.append(("CHOICE", options))
    return lines
