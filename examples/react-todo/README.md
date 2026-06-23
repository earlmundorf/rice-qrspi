# Example: React + Vite Todo + QRSPI

The same idea as [`../fastapi-todo`](../fastapi-todo), on a different stack. A tiny
React/TypeScript Todo UI with a clean layering — an API boundary, a state hook, and
components — pre-wired with the `qrspi` skill and **the same ticket, TODO-1**. Run the exact
same workflow and watch the stages resolve to npm/tsc/eslint commands instead of Python ones.

That's the whole point: **one skill, two stacks, identical flow.**

## What's here

```
react-todo/
├── src/
│   ├── App.tsx                # composition + loading/error wiring  ('pages-app' layer)
│   ├── components/            # TodoForm, TodoList  ('components' layer)
│   ├── hooks/useTodos.ts      # list/loading/error state  ('state' layer)
│   ├── services/api.ts        # THE API boundary  ('api-types' layer)
│   └── types/index.ts         # Todo type
├── package.json · tsconfig.json · vite.config.ts · eslint.config.js
├── working-docs/config.json   # the QRSPI profile for THIS repo (storefront, jira: none)
├── tickets/active/TODO-1-mark-todo-complete.md
└── setup.sh
```

## Prerequisites

You only install one thing yourself:

| Tool | Why | Install |
|------|-----|---------|
| **Node.js ≥ 20** | Ships with npm; `npm install` then pulls TypeScript, ESLint, and Vite | [nodejs.org](https://nodejs.org/) · or `nvm install 20` · or `brew install node` |
| **Claude Code** | Runs the `/cq:*` workflow | [claude.com/claude-code](https://claude.com/claude-code) |

You do **not** need to install TypeScript, ESLint, or Vite separately — `npm install` pulls
them from `package.json`. `setup.sh` checks for Node ≥ 20 and stops with instructions if it's
missing.

## Run it

```bash
# 1. From this folder — checks prereqs, installs the qrspi skill, publishes /cq, runs `npm install`
./setup.sh

# 2. (optional) see the app work first
npm run dev        # then open the printed http://localhost:5173
npx tsc --noEmit   # typecheck (UNIT_TEST is MANUAL in this profile)
npm run lint
```

Then open this folder in **Claude Code** and run:

```
/cq:go TODO-1
```

`jira.mode` is `none`, so stage 1 reads `tickets/active/TODO-1-mark-todo-complete.md`. The
ticket is the UI twin of the FastAPI one: the `Todo` type already has a `completed` flag and
`TodoList` already strikes through done items — but nothing sets it. Add the toggle, routed
through the API boundary.

## Compare the two stacks

| | `fastapi-todo` | `react-todo` |
|---|---|---|
| Profile | `fastapi` (uv) | `storefront` (npm) |
| TYPECHECK | `uv run mypy app` | `npx tsc --noEmit` |
| Checkpoint test | `uv run pytest -q` | `MANUAL` (no runner yet) |
| Boundary | service/client layer | `src/services/api.ts` |
| Research layers | routers/schemas/services-data | pages/components/state/api |

The [**WALKTHROUGH**](../../.claude/skills/qrspi/WALKTHROUGH.md) narrates the FastAPI run in
detail; the stages here are identical — only the resolved commands differ.

> Note: `setup.sh` copies the skill in from the repo root (gitignored here so there's only
> one source of truth). If you copy this example out of the repo, also copy
> `../../.claude/skills/qrspi/` next to it.
