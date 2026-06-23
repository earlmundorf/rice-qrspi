# QRSPI — End-to-End Walkthrough

A complete run against the **runnable example** in this repo:
[`examples/fastapi-todo`](../../../examples/fastapi-todo). Clone it, run `./setup.sh`, and
follow along with `/cq:go TODO-1` — the artifacts and gate prompts below are what you'll
actually see. The flow is identical on any stack; only the concrete commands come from the
example's `working-docs/config.json` (the `fastapi` profile, `uv` verbs, `jira.mode: none`).

> The app: a tiny Todo API — `app/routers/todos.py` (GET/POST/GET-by-id), `app/schemas.py`
> (`Todo` has a `completed` flag), `app/store.py` (in-memory). The ticket asks for the one
> thing it's missing: a way to mark a todo done.

---

## 0. Setup (once)

```bash
cd examples/fastapi-todo
./setup.sh                 # copies the skill in, publishes /cq, runs `uv sync`
```

Verify the app is healthy before changing it:

```bash
uv run pytest -q           # 3 passed
```

Open the folder in Claude Code. Typing `/cq` autocompletes `0_go … 7_validate`.

---

## 1. Start — one command

```
> /cq:go TODO-1
```

`jira.mode` is `none`, so stage 1 finds `tickets/active/TODO-1-mark-todo-complete.md` and
reads it directly. Claude recommends a tier:

> "TODO-1 touches three layers (router, schema, store) and a test, and has a real design
> choice (how to express 'mark complete' as an HTTP operation). I recommend **full**.
> (trivial / simple / full / comprehensive)"

You confirm `full`. Stages 1+2 auto-chain and two files appear under `working-docs/TODO-1/`.

**`ticket.md`** (excerpt)
> **Problem:** A `Todo` carries a `completed` flag but no endpoint ever changes it; users
> can't check items off.
> **ASSUMPTION-1:** "Mark complete" is a state change on an existing todo, not a new resource.
> **ASSUMPTION-2:** The in-memory store is acceptable; no persistence in scope.
> **Draft success criteria:** marking a todo flips `completed` for fetch + list; unknown id
> → 404; create/list/get unchanged.
> **Out of scope:** un-completing, bulk operations, auth.

**`questions.md`** (excerpt — neutral, no solutioning)
> Q1. How are todo routes defined and registered today, and what status codes/error
> patterns are already in use? (file:line)
> Q2. How is a single todo looked up, and what happens when it's missing?
> Q3. What is the shape of the request/response models, and how is `completed` represented?
> Q4. How does the store expose mutation today, and how is identity (`id`) assigned?
> Q5. How are the existing endpoints tested, and what does the test setup look like?

## 2. Research — blind, layered (no input from you)

Stage 2 reads `questions.md` **only** (never the ticket), runs one subagent per
`researchLayers` entry (routers, schemas, services-data, app-config, build), and writes
`research.md` — facts with `file:line`:

> A1. Routes live in `app/routers/todos.py:8` on an `APIRouter(prefix="/todos")`; the
> router is included in `app/main.py:8`. POST returns `201` (todos.py:17); GET-by-id raises
> `HTTPException(404, "todo not found")` (todos.py:24).
> A2. Lookup is `store.get(todo_id)` → `Todo | None` (`app/store.py:27`); the router maps
> `None` to 404.
> A3. `Todo` (`app/schemas.py:13`) = `id:int, title:str, completed:bool=False`. `TodoCreate`
> has only `title`. Nothing mutates `completed` anywhere.
> A4. `TodoStore` (`app/store.py`) holds a `dict[int, Todo]`; `add()` assigns `_next_id`.
> There is **no** update method — mutation surface is `add()` only.
> A5. Tests use `TestClient(app)` (`tests/test_todos.py:5`); pattern is
> request → assert status → assert body.

## 3. Design — DEV GATE 1 (the leverage point)

```
> /cq:3_design working-docs/TODO-1/
```

Claude **must ask before writing anything**:

> **Q1 — HTTP shape.** (A) `PATCH /todos/{id}` with a partial body `{"completed": true}`,
> (B) `PUT /todos/{id}` full replacement, (C) action route `POST /todos/{id}/complete`.
> **Recommend A** — partial state change on an existing resource; leaves room for editing
> `title` later; idempotent.
> **Q2 — request model.** (A) new `TodoUpdate { completed: bool }`, (B) reuse `TodoCreate`,
> (C) no body, route implies `completed=true`. **Recommend A** — explicit, validates, and
> matches the existing schema-per-operation style (schemas.py).
> **Q3 — store API.** (A) add `set_completed(id, value) -> Todo | None`, (B) generic
> `update(id, **fields)`. **Recommend A** — smallest surface for the one need.
> **ASSUMPTION-1 confirmed** (research A2/A4: existing get-by-id + 404 pattern fits).
> **ASSUMPTION-2 confirmed** (A4: in-memory store, no persistence).

You answer `A / A / A`. Claude writes `design.md` (~120 lines) with **Current state**,
**Desired end state**, the three decisions, confirmed assumptions, and split success
criteria:

> **Automated:** `uv run pytest -q` green (incl. new tests); `uv run ruff check .` clean;
> `uv run mypy app` clean.
> **Manual:** `uv run uvicorn app.main:app --reload`, then via `/docs` or curl — create a
> todo, `PATCH /todos/{id}` `{"completed": true}`, confirm GET + list show `completed:true`;
> `PATCH /todos/99999` → 404.

You approve.

## 4. Structure — DEV GATE 2

```
> /cq:4_structure working-docs/TODO-1/
```

Vertical slices, each with a checkpoint (verbs from config). Two slices here:

> **S1 — data + schema.** Add `TodoUpdate{completed: bool}` to `schemas.py`; add
> `TodoStore.set_completed(todo_id, value) -> Todo | None` to `store.py`; unit-test the
> store directly. **Checkpoint:** `TYPECHECK + UNIT_TEST`.
> **S2 — endpoint.** Add `PATCH /todos/{id}` to `routers/todos.py` calling `set_completed`,
> 404 on `None`, returning the updated `Todo`; test 200 round-trip + 404.
> **Checkpoint:** `LINT + TYPECHECK + UNIT_TEST`.

(Mapping comes from `changeTypeVerbs`: `*schemas*.py` → TYPECHECK+UNIT_TEST; `*router*.py` →
LINT+TYPECHECK+UNIT_TEST.) You approve.

## 5 → 6. Plan, then implement

```
> /cq:5_plan working-docs/TODO-1/          # checkboxed tasks; verbs resolved to commands
> /cq:6_implement working-docs/TODO-1/ mode=claude
```

`plan.md` (excerpt — commands already resolved from config):

> - [ ] **S1.1** `app/schemas.py`: add `class TodoUpdate(BaseModel): completed: bool`
> - [ ] **S1.2** `app/store.py`: `set_completed(self, todo_id, value) -> Todo | None` —
>   look up; if missing return `None`; else set `.completed`, store, return it
> - [ ] **S1.3** `tests/test_todos.py`: store-level test — add, set_completed True, assert
>   - _verify:_ `uv run mypy app && uv run pytest -q`
> - [ ] **S2.1** `app/routers/todos.py`: `@router.patch("/{todo_id}")` → `set_completed`,
>   `None` → `HTTPException(404, "todo not found")`
> - [ ] **S2.2** `tests/test_todos.py`: PATCH 200 round-trip (GET reflects it) + PATCH 404
>   - _verify:_ `uv run ruff check . && uv run mypy app && uv run pytest -q`
> - [ ] **Docs** update `examples/fastapi-todo/README.md` endpoint list

`mode=claude` works slice by slice: implement → run the slice's verbs → **never proceed on
red** → one commit per slice (`feat(todos): TODO-1 …`), checking off boxes as it goes. If
something doesn't match the plan it stops and asks rather than improvising.

## 7. Validate & ship — DEV GATE 3

```
> /cq:7_validate working-docs/TODO-1/
```

1. Re-runs every **Automated** criterion verbatim and records output in `validation.md`:
   `uv run pytest -q` → `5 passed`; `ruff` clean; `mypy` clean.
2. Lists the **Manual** steps (the curl/`/docs` script) for you to perform.
3. **Ownership gate:** shows the full diff summary and asks *"Have you read this diff and do
   you own it?"* — no PR without your explicit yes.
4. Opens the PR grounded in `design.md` (problem, the PATCH-vs-PUT decision and why, criteria
   status, manual steps for the reviewer). `jira.mode: none` → no ticket update.
5. Appends a short retro, captures any `findings/`, and moves
   `tickets/active/TODO-1-*.md` → `tickets/completed/`.

Final diff is small and obvious — a new schema, one store method, one route, four assertions:
exactly the point of QRSPI on a small ticket, and the same shape scaled up on a large one.

---

## The other tiers, in one line each

- **trivial** — `/cq:go "fix the /health docstring" trivial` → edit, `ruff`+`mypy`, diff, own it.
- **simple** — `/cq:go TODO-1 simple` → one-page `brief.md` (you gate the assumptions) →
  implement → validate-lite. A fine choice for this ticket if you don't want the full gates.
- **comprehensive** — for a risky/cross-cutting change: everything above + worktree isolation
  + full verification per slice + design/structure shared for review before code.

## What to notice

- **Stage 2 never saw the ticket.** Research stays unbiased — it documents what *is*, so the
  design isn't a foregone conclusion dressed up as analysis.
- **The design gate is where you steer.** Five minutes choosing PATCH-vs-PUT beats unwinding
  the wrong choice after it's coded.
- **Every checkpoint is a real command from `config.json`.** Swap the profile and the exact
  same stages drive a React or Spring Boot repo — the commands just resolve differently.
  [`examples/react-todo`](../../../examples/react-todo) is this same ticket on a React/Vite
  stack: identical stages, `npx tsc --noEmit` / `npm run build` instead of `uv run` verbs.
