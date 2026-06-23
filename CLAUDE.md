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
│   ├── findings/           # self-improvement log
│   └── sync-commands.sh    # publishes commands/ → .claude/commands/cq/
├── working-docs/
│   ├── config.json         # active profile (TEMPLATE here)
│   └── profiles/           # storefront.json, springboot.json, fastapi.json
├── tickets/{active,completed}/
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

## Development Guidelines

- Keep code simple and focused
- Document any external API dependencies
- Store secrets in environment variables, never in code
