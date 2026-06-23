---
name: qrspi
description: >
  Generic QRSPI workflow for Claude Code — Ticket/Questions, Research, Design, Structure,
  Plan, Implement, Validate. One stack-neutral skill; everything project-specific
  (build/verification verbs, research layers, protected paths, Jira mode) lives in
  working-docs/config.json, so the same skill serves a React/Vite frontend, a Spring Boot
  or FastAPI service, or any other codebase with only a different config (or "profile").
  Use when a developer wants to work a Jira ticket against a codebase
  with structured stages: decompose a ticket into research questions; run blind layered
  codebase research; align on design, assumptions, and success criteria; break work into
  vertical slices; produce a tactical plan; implement manually or via Claude with
  toolchain verification; validate against success criteria. Triggers on QRSPI, "work
  this ticket", and research/design/plan/implement intent against any codebase.
---

# QRSPI

You orchestrate a 7-stage workflow. **Each stage runs in a fresh context window, reads only
its declared input artifacts, stays under 40 instructions, and ends by printing the exact
next command.** Never merge stages. Never skip a developer gate.

This is **one generic skill**. There is nothing stack-specific in the stage commands —
the research layers, verification verbs, protected paths, and Jira mode all live in
`working-docs/config.json` (the "profile"). The same skill folder serves a frontend
(React/Vite), a backend service (Spring Boot, FastAPI), or any other codebase; only the
config differs. Three ready-made profiles ship in `working-docs/profiles/` — copy the
closest one to `working-docs/config.json` and adjust.

## Entry point — one command, four tiers

Developers remember `/cq:go <TICKET-KEY> [tier]` and four tier names:
**trivial** (no workflow — just fix and verify), **simple** (brief → implement →
validate-lite), **full** (all stages; 1+2 auto-chained), **comprehensive** (full +
worktree + mandatory full verification per slice + team review of design/structure).
`commands/0_go.md` holds the recommendation heuristics and tier mechanics. Recommend a
tier, confirm it, record it. The numbered stages below are the machinery behind
full/comprehensive — developers can still invoke them directly, but don't have to.

## Stages

| # | Command | Reads | Writes | Dev gate? |
|---|---------|-------|--------|-----------|
| 0 | `commands/0_go.md` | ticket/description | tier decision | confirm tier |
| 1 | `commands/1_ticket.md` | Jira ticket / text | `ticket.md`, `questions.md` | skim |
| 2 | `commands/2_research.md` | `questions.md` only — **never ticket.md** | `research.md` | no |
| 3 | `commands/3_design.md` | `ticket.md` + `research.md` | `design.md` (~200 lines) | ★ YES |
| 4 | `commands/4_structure.md` | `design.md` | `structure.md` (~2 pages) | ★ YES |
| 5 | `commands/5_plan.md` | all artifacts | `plan.md` (checkboxes) | spot-check |
| 6 | `commands/6_implement.md` | `structure.md` + `plan.md` | code, 1 commit/slice | no |
| 7 | `commands/7_validate.md` | `design.md` success criteria | validation report, PR | ★ YES |

Artifacts live in `working-docs/<TICKET-KEY>/`.

## Going backward

Research reveals bad questions → re-run 1. Design finds missing facts → re-run 1+2.
Structure exposes a flawed design → re-run 3. Implementation hits a fundamental plan error
→ re-run 5 (or 3). Adapt small mismatches in place; go back only for fundamentals.

## Ground rules (apply in every stage)

- **The repo's CLAUDE.md is authoritative** for naming/structure patterns, the designated
  boundary layer (`apiBoundary` in config — no I/O bypassing it), typed responses, user
  feedback and formatting helpers, and loading + error states on every async operation.
- **Never modify anything in `protectedPaths`** (config) — generated, vendored, or
  build-output trees (e.g. `node_modules/`/`dist/` for a JS app; `target/`/`build/` for a
  JVM app; `.venv/`/`__pycache__/` for Python). Never commit `.env` or secrets.
- **Stages never hardcode build commands.** They reference verification VERBS, resolved
  through the build adapter in `working-docs/config.json` (see below).
- Feature flow docs (`docs/<flow>/context|components|diagram.md`) are docs-before-code,
  and the final plan task is always Documentation.
- Jira/Confluence publishing is optional; local `working-docs/` is first-class.

## Build adapter — the config IS the profile; detect once, confirm, persist

All project specificity lives in `working-docs/config.json`. On first run (any stage), if
it is missing, either copy the closest profile from `working-docs/profiles/` or detect and
build one, then confirm with the developer and save. Config fields:

| Field | What it holds |
|-------|---------------|
| `profile` / `stack` | Human label + detected stack (drives example vocabulary only) |
| `workingDir` | Directory build commands run from (usually `.`, or a subdir) |
| `protectedPaths` | Paths the workflow must never modify |
| `apiBoundary` | The designated I/O boundary layer (path), or `null` |
| `build` | The verb table: `VERB → command` (a command may be `MANUAL: <steps>`) |
| `changeTypeVerbs` | `glob → [VERBS]` — which checks a given change type requires |
| `jira` | `{ mode: mcp \| manual \| none, project }` |
| `researchLayers` | `[{ name, targets }]` — one stage-2 subagent per layer |
| `_notes` | Hard-won rules worth carrying with the config |

Detection guidance when no profile fits:

1. **Detect layout & build system** from the repo: lockfiles + scripts (npm/pnpm/yarn,
   Vite), build files (`pom.xml`/`build.gradle` + `mvnw`/`gradlew`), Python project files
   (`pyproject.toml`/`requirements.txt`), or whatever the stack uses. Derive `workingDir`,
   `protectedPaths`, and `researchLayers` for that stack and confirm.
2. **Detect Jira mode** (`jira.mode`): Atlassian MCP tools respond → `mcp`; Jira exists
   but unreachable → `manual` (developer pastes ticket in; outbound updates written
   paste-ready to `working-docs/<KEY>/jira-updates.md`); no Jira → `none`.
3. **Resolve the verb table**, confirm with the developer, save. A verb may resolve to
   `MANUAL: <instructions>` — stages then print the instructions and wait for developer
   confirmation instead of running a command.
4. **Map change types → verbs** (`changeTypeVerbs`, editable): every change type lists the
   minimum checks it requires; any slice checkpoint runs at least the cheapest static
   checks (typecheck/lint or compile).

Config is versioned in git, so the team sets it up once per repo.

## Self-improvement (the contract)

This skill gets sharper every ticket. `findings/` holds what prior runs learned —
workflow improvements and accumulated project knowledge (see `findings/README.md`).

- **Start of a ticket (stage 1):** list `findings/*.md` (excluding README/TEMPLATE) and
  load any whose `applies_to.area` / `ticket_type` matches this ticket, so research
  starts informed.
- **During a ticket:** when a stage hits something the references didn't cover — a wrong
  verb mapping, a missed research category, a recurring codebase quirk — write
  `findings/YYYY-MM-DD-{slug}.md` from `TEMPLATE.md`. Small ones count.
- **End of a ticket (stage 7):** summarize new findings and propose which to **promote**
  into the stage commands, this SKILL.md, the config, or the repo's CLAUDE.md.
  Promotion is user-approved; mark promoted findings `status: promoted`.

Unpromoted findings still load next run — they help before promotion.

## Editing the stages — keep the two copies in sync

The 8 stage files live in **two** places: `commands/*.md` here (the portable skill copy,
canonical) and `.claude/commands/cq/*.md` (where Claude Code reads `/cq:*`). The skill
copy is the source of truth; after editing a stage, re-sync with
`./sync-commands.sh` (or `cp .claude/skills/qrspi/commands/*.md .claude/commands/cq/`).
Drift means `/cq` behaves differently from the documented stage — don't let them diverge.

## What this skill does NOT do

Deploy, push without consent, modify `protectedPaths` (generated/vendored/OOTB code),
write design.md before the stage-3 Q&A, proceed past failed verification, or run more
ceremony than the ticket warrants.
