#!/usr/bin/env bash
# Turnkey setup for the QRSPI FastAPI example.
# Checks prerequisites, installs the qrspi skill from the repo root, publishes
# the /cq:* commands, and installs Python deps with uv. Safe to re-run.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$here/../.." && pwd)"

# --- Prerequisites -----------------------------------------------------------
# uv is the only thing you install yourself: it manages the Python toolchain
# (>=3.11) AND installs ruff / mypy / pytest via `uv sync`.
if ! command -v uv >/dev/null 2>&1; then
  echo "✗ Prerequisite missing: uv"
  echo "  uv manages Python (>=3.11) and the dev tools (ruff, mypy, pytest) for this example."
  echo "  Install one of:"
  echo "    curl -LsSf https://astral.sh/uv/install.sh | sh"
  echo "    brew install uv"
  echo "  Then re-run ./setup.sh.  Docs: https://docs.astral.sh/uv/"
  exit 1
fi
echo "✓ uv $(uv --version | awk '{print $2}')"

# --- Install the skill -------------------------------------------------------
echo "→ Installing the qrspi skill from $repo_root/.claude/skills/qrspi"
mkdir -p "$here/.claude/skills"
rm -rf "$here/.claude/skills/qrspi"
cp -r "$repo_root/.claude/skills/qrspi" "$here/.claude/skills/qrspi"

echo "→ Publishing /cq:* commands"
"$here/.claude/skills/qrspi/sync-commands.sh"

# --- Install Python deps (uv resolves Python + ruff/mypy/pytest) -------------
echo "→ Installing Python deps (uv sync)"
( cd "$here" && uv sync )

echo
echo "Ready. Open this folder ($here) in Claude Code and run:"
echo "    /cq:go TODO-1"
echo "(jira.mode is 'none', so stage 1 reads tickets/active/TODO-1-mark-todo-complete.md)"
