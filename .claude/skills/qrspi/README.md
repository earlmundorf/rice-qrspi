# qrspi

A generic QRSPI workflow (Ticket/Questions → Research → Design → Structure → Plan →
Implement → Validate) for Claude Code. Small stages in fresh contexts, blind research,
two short review gates, tiered ceremony, verb-resolved verification.

**One skill, many stacks.** Everything project-specific — verification verbs, research
layers, protected paths, the boundary layer, Jira mode — lives in
`working-docs/config.json` (the repo's "profile"). The stage commands contain no
stack-specific logic, so this exact skill folder serves a React/Vite frontend, a Spring
Boot or FastAPI service, or any other codebase. No per-stack forks to keep in sync.

This repo (`rice-qrspi`) is the **canonical home** for the skill. To use it in a real
project: copy `.claude/skills/qrspi/` into that repo, copy the closest profile from
`working-docs/profiles/` to `working-docs/config.json`, and run `./sync-commands.sh` to
publish the `/cq:*` commands.

## Usage

```
/cq:go <TICKET-KEY or description> [trivial|simple|full|comprehensive]
```

One command; Claude recommends a tier from the ticket's scope and you confirm.
Artifacts live in `working-docs/<TICKET-KEY>/` (gitignored except the shared
`working-docs/config.json` and `working-docs/profiles/`, which are committed — they map
verification verbs to this repo's real commands).

| Tier | When |
|---|---|
| trivial | Typo, copy change, <3 files, no design choice |
| simple | Bug with known cause, small change in one area |
| full | Standard feature — multiple files/areas, real design choices |
| comprehensive | Cross-cutting, risky, migration, or team review wanted |

Safety rails at every tier: verification verbs, the diff-ownership gate before any PR,
all I/O through the configured boundary layer, never touch `protectedPaths`, never
push/deploy without consent.

## Profiles

`working-docs/profiles/` ships three ready-made configs:

- `storefront.json` — React/Vite storefront: npm verbs, `ts|tsx` change types,
  routing/components/state/api research layers (`UNIT_TEST` is `MANUAL:` until a test
  runner lands).
- `springboot.json` — Spring Boot service (Maven): `mvnw` verbs, `*.java` change types,
  web/service/data/config research layers (Gradle variant noted inline).
- `fastapi.json` — FastAPI service (uv): `uv run` ruff/mypy/pytest verbs, `*.py` change
  types, routers/schemas/services/data research layers (pip & Poetry variants noted inline).

Pick the closest, copy it to `working-docs/config.json`, edit, commit.

Attribution: inspired by the QRSPI workflow; command mechanics adapted from an MIT-licensed
implementation (github.com/matanshavit/qrspi). Genericized from project-specific variants.
