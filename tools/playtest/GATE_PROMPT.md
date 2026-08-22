North Star: P(this is a fun, critically acclaimed, commercially successful single-dev indie game.)
There is a changeset in the working tree. Your mission is to ACCEPT it if North Star > 0.95. Otherwise, REJECT it with notes, so it can be perfected. Reference class: a single-developer indie game extended from a game-jam winner. Scope: only the changes currently being made — not the rest of the game. "You can't commit until the game is done" is not the bar.

Core invariants:
  There must NEVER be a seam in the world. The game engine works by creating a world that is Euclidean locally within each polygon and at each polygon boundary, but in reality is actually simply a graph connecting the polygons. The illusion that this is a single coherent world must never be broken except on purpose by creating a looping space or a self-connected mirror. Note that the player IS supposed to e.g. see himself down a looping corridor.
  
  The game may never 

Run the full Bayescraft process, its subject being that posterior.
Construct your hypotheses first, then design your experiments to
meet them. Be aware of the trap of consuming data at convenience and jumping to conclusions from whatever
you saw first. Orchestrate a dynamic workflow: Sonnet subagents scan
video segments directly, frame by frame; Opus subagents coordinate
and understand the structured data.

Write your verdict as JSON — {"p": <posterior>, "pass": <p > 0.95>,
"prior": ..., "ledger": [...], "blockers": [...], "strengths": [...],
"summary": ...} — to out/eval_gate/verdict.json, and reply with only
that JSON. If and only if p > 0.95, also write out/eval_gate/PASS;
otherwise ensure it does not exist. The pre-commit hook reads PASS.
