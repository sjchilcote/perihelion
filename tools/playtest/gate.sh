#!/bin/bash
# The commit gate. The prompt IS the gate; everything else is a
# supporting tool the judge invokes itself through the CLI.
set -e
cd "$(git rev-parse --show-toplevel)"
claude -p "$(cat tools/playtest/GATE_PROMPT.md)" --model fable \
    --output-format json \
    --allowedTools "Read,Grep,Glob,Bash,Agent,Task,Write" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['result'])"
test -f out/eval_gate/PASS
