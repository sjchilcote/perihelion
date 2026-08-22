#!/usr/bin/env bash
# CI-style check: rebuild the necore extension from its home repo (the
# NETDS/engine repository, a sibling checkout), then run pytest against
# it. The Rust engine's own tests run in that repo's check, not here.
# Run from the repo root.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

ENGINE=../noneuclideantopdownshooter/engine
[ -d "$ENGINE" ] || { echo "check.sh: engine repo not found at $ENGINE" >&2; exit 1; }

echo "== maturin develop --release (rebuild necore extension) =="
uv run maturin develop --release -m "$ENGINE/necore-py/Cargo.toml" -q

echo "== uv run python -m pytest -q =="
# python -m, not the pytest script: the venv script's shebang predates
# the repo rename and resolves outside this venv
uv run python -m pytest -q

echo "== check.sh: all green =="
