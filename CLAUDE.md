# CLAUDE.md

This file provides guidance to Claude Code when working in this repository.

## Project Overview

`rice-qrspi` is the canonical home for the **QRSPI** workflow — a generic, stack-neutral
Claude Code skill (Ticket/Questions → Research → Design → Structure → Plan → Implement →
Validate). The skill is config-driven: all project specificity lives in
`working-docs/config.json`, so one skill serves any stack.

## Project Structure

```
.
├── .claude/skills/qrspi/   # the skill — SKILL.md is the source of truth
│   ├── commands/           # the 7 stages + the /cq:go entry point
│   └── sync-commands.sh    # publishes commands/ → .claude/commands/cq/
├── working-docs/
│   ├── config.json         # active profile (TEMPLATE here)
│   ├── findings/           # self-improvement log (project-owned, not overwritten)
│   └── profiles/           # storefront.json, springboot.json, fastapi.json
├── tickets/{active,completed}/
├── install.sh              # install into a target repo (skill + /cq:* + config seed)
├── CLAUDE.md
└── README.md
```

## Working on the skill

- **`commands/*.md` is canonical.** After editing a stage, run
  `.claude/skills/qrspi/sync-commands.sh` to update `.claude/commands/cq/` (where `/cq:*`
  reads). Don't let the two copies drift.
- **Keep it stack-neutral.** No stage command should hardcode a stack-specific path,
  command, or vocabulary — push it into `working-docs/config.json` (verbs,
  `researchLayers`, `protectedPaths`, `apiBoundary`, `jira.mode`). If a new dimension
  varies by stack, add a config field rather than branching in the stage.
- **Profiles are examples.** `working-docs/profiles/` holds the reference configs
  (`storefront.json`, `springboot.json`, `fastapi.json`); update them when the config
  schema changes.
- **Two publishing paths, don't confuse them.** `sync-commands.sh` publishes *this* repo's
  `commands/` into its own `.claude/commands/cq/` — that's the loop while editing a stage.
  `install.sh` installs into *another* repo. It refuses to target this repo, so it can
  never overwrite the source of truth. Keep it POSIX `sh` — no bashisms — so Git Bash and
  WSL cover Windows without a second script to maintain.
- **Keep `SKILL.md`'s description a complete sentence.** The installer appends a
  `Also triggers on: …` line from the profile's `triggerVocabulary`, so there is no
  placeholder to render and this repo's own skill is always valid as committed. The skill
  directory is replaced wholesale on install, so the clause can never double up.
- **Adding a config field?** Add it to the schema table in `SKILL.md`, to all three
  profiles, to the `working-docs/config.json` template, to both `examples/*/working-docs/
  config.json`, and to the installer's `known` key list — and give the stage that reads it
  a fallback for configs written before the field existed.

## Development Guidelines

- Keep code simple and focused
- Document any external API dependencies
- Store secrets in environment variables, never in code
