# Example: FastAPI Todo + QRSPI

The smallest real app we could make that still has something worth researching: a Todo API
with routers, schemas, and a data layer, plus tests. It comes pre-wired with the `qrspi`
skill config and one sample ticket so you can run the **whole** workflow against real code
in a couple of minutes.

## What's here

```
fastapi-todo/
├── app/
│   ├── main.py            # FastAPI app + /health
│   ├── routers/todos.py   # GET/POST/GET-by-id  (the 'routers' layer)
│   ├── schemas.py         # Pydantic Todo / TodoCreate  (the 'schemas' layer)
│   └── store.py           # in-memory store  (the 'services-data' layer)
├── tests/test_todos.py    # pytest via TestClient
├── pyproject.toml         # uv-managed; ruff + mypy + pytest
├── working-docs/config.json   # the QRSPI profile for THIS repo (jira.mode: none)
├── tickets/active/TODO-1-mark-todo-complete.md   # the ticket you'll work
└── setup.sh               # installs the skill + deps
```

## Prerequisites

You only install one thing yourself:

| Tool | Why | Install |
|------|-----|---------|
| **uv** | Manages the Python toolchain (≥3.11) **and** installs ruff / mypy / pytest via `uv sync` | `curl -LsSf https://astral.sh/uv/install.sh \| sh` · or `brew install uv` · [docs](https://docs.astral.sh/uv/) |
| **Claude Code** | Runs the `/cq:*` workflow | [claude.com/claude-code](https://claude.com/claude-code) |

You do **not** need to install Python, ruff, mypy, or pytest separately — `uv` provides a
compatible Python and `uv sync` installs the dev tools from `pyproject.toml`. `setup.sh`
checks for `uv` and stops with instructions if it's missing.

## Run it

```bash
# 1. From this folder — checks prereqs, installs the qrspi skill, publishes /cq, runs `uv sync`
./setup.sh

# 2. (optional) see the app work first
uv run uvicorn app.main:app --reload    # then open http://127.0.0.1:8000/docs
uv run pytest -q
```

Then open this folder in **Claude Code** and run:

```
/cq:go TODO-1
```

Because `jira.mode` is `none`, stage 1 reads the ticket straight from
`tickets/active/TODO-1-mark-todo-complete.md`. Claude will recommend a tier (this ticket is
a good **simple**/**full**), and walk you through Ticket → Research → Design → Structure →
Plan → Implement → Validate. When it ships, stage 7 moves the ticket file to
`tickets/completed/`.

## The ticket, in one line

**TODO-1** — there's a `completed` flag on `Todo` but no way to set it; add the ability to
mark a todo done. Small, but it has a real design choice (PATCH vs PUT, what's mutable) —
which is exactly what the Design gate is for.

## Follow along

The repo's [**WALKTHROUGH**](../../.claude/skills/qrspi/WALKTHROUGH.md) narrates this exact
ticket through all seven stages, showing the artifact each stage produces and the gate
prompts you'll see. Read it alongside your own run.

> Note: `setup.sh` copies the skill in from the repo root (it's gitignored here so there's
> only one source of truth). If you copy this example out of the repo, also copy
> `../../.claude/skills/qrspi/` next to it.
