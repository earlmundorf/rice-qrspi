#!/usr/bin/env bash
# Turnkey setup for the QRSPI React example.
# Checks prerequisites, installs the qrspi skill from the repo root, publishes
# the /cq:* commands, and installs npm deps. Safe to re-run.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$here/../.." && pwd)"

# --- Prerequisites -----------------------------------------------------------
# Node.js (>=20) is the only thing you install yourself; npm ships with it and
# `npm install` pulls the dev tools (TypeScript, ESLint, Vite).
if ! command -v node >/dev/null 2>&1; then
  echo "✗ Prerequisite missing: Node.js (>=20, includes npm)"
  echo "  npm install pulls the rest (TypeScript, ESLint, Vite)."
  echo "  Install one of:"
  echo "    https://nodejs.org/   (LTS installer)"
  echo "    nvm install 20        (https://github.com/nvm-sh/nvm)"
  echo "    brew install node"
  echo "  Then re-run ./setup.sh."
  exit 1
fi
node_major="$(node -p 'process.versions.node.split(".")[0]')"
if [ "$node_major" -lt 20 ]; then
  echo "✗ Node.js >=20 required; found $(node --version). Upgrade, then re-run ./setup.sh."
  exit 1
fi
echo "✓ node $(node --version)  npm $(npm --version)"

# --- Install the skill -------------------------------------------------------
echo "→ Installing the qrspi skill from $repo_root/.claude/skills/qrspi"
mkdir -p "$here/.claude/skills"
rm -rf "$here/.claude/skills/qrspi"
cp -r "$repo_root/.claude/skills/qrspi" "$here/.claude/skills/qrspi"

echo "→ Publishing /cq:* commands"
"$here/.claude/skills/qrspi/sync-commands.sh"

# --- Install npm deps (pulls TypeScript, ESLint, Vite) -----------------------
echo "→ Installing npm deps"
( cd "$here" && npm install )

echo
echo "Ready. Open this folder ($here) in Claude Code and run:"
echo "    /cq:go TODO-1"
echo "(jira.mode is 'none', so stage 1 reads tickets/active/TODO-1-mark-todo-complete.md)"
