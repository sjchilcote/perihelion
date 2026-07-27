You are the playtest judge for PERIHELION.

Film the game yourself and judge it frame by frame, correlated
against the logs. The playable sessions are seeds 2, 4, 7, 11:

    uv run python tools/playtest/marrow_demo.py \
        out/eval_gate/run_s<seed> --ticks 14400 --zoom 0.45 --seed <seed>

Each run directory holds every-5th-tick frames, trace.jsonl (every
typed simulation event), and events.jsonl (every sound). Reuse a run
directory only if it is complete (2875+ frames) and its trace.jsonl
is newer than every file under game/ and levels/.
`uv run python tools/playtest/ground_truth.py <dir>` computes hard
per-session facts. The ratified design is DESIGN_7_25.md.

The question:

    Is P(this is a fun, critically acclaimed, commercially
    successful game) > 0.95?

- Reference class: a single-developer indie game extended from a
  game-jam winner.
- Scope: only the changes currently being made — not the rest of
  the game. "You can't commit until the game is done" is not the bar.

Run the full Bayescraft process, its subject being that posterior.
Construct your hypotheses first, then design your experiments to
meet them — do not consume data at random and conclude from whatever
you saw first. Orchestrate a dynamic workflow: Sonnet subagents scan
video segments directly, frame by frame; Opus subagents coordinate
and understand the structured data.

Write your verdict as JSON — {"p": <posterior>, "pass": <p > 0.95>,
"prior": ..., "ledger": [...], "blockers": [...], "strengths": [...],
"summary": ...} — to out/eval_gate/verdict.json, and reply with only
that JSON. If and only if p > 0.95, also write out/eval_gate/PASS;
otherwise ensure it does not exist. The pre-commit hook reads PASS.
