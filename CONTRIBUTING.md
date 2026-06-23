# Contributing to rice-qrspi

Thanks for your interest! This repo is the canonical home of the **QRSPI** workflow — a
generic, config-driven Claude Code skill. Contributions that make it sharper or easier to
adopt across more stacks are very welcome.

## Ways to contribute

- **A new profile.** The highest-leverage contribution. If you've adapted QRSPI to a stack
  we don't ship yet (Django/Flask, Go, Rails, .NET, mobile, …), add a
  `working-docs/profiles/<stack>.json`. See [Adding a profile](#adding-a-profile).
- **Improve a stage.** The stages live in `.claude/skills/qrspi/commands/0_go.md` …
  `7_validate.md`. Keep them stack-neutral (see the golden rule below).
- **Docs & examples.** README, WALKTHROUGH, QUICKREF — clarity for newcomers matters.
- **Findings.** Real lessons from running QRSPI belong in `.claude/skills/qrspi/findings/`
  (one file per finding, from `TEMPLATE.md`).

## The golden rule: keep the stages stack-neutral

The whole point of QRSPI is **one skill, many stacks**. A stage command must never hardcode
a stack-specific path, command, or vocabulary. If something varies by stack, it belongs in
`working-docs/config.json`, not in a stage:

- a command to run → a **verb** in `build` + a `changeTypeVerbs` mapping
- a place to look → a `researchLayers` entry
- a path to never touch → `protectedPaths`
- the I/O boundary → `apiBoundary`

If you find yourself wanting to write "for React, do X; for Spring Boot, do Y" in a stage,
that's the signal to add a config field instead.

## Editing stages — keep the two copies in sync

`.claude/skills/qrspi/commands/*.md` is the **source of truth**. Claude Code reads `/cq:*`
from `.claude/commands/cq/`. After editing a stage, re-sync:

```bash
.claude/skills/qrspi/sync-commands.sh
```

CI/reviewers will check that the two copies match.

## Adding a profile

1. Copy an existing profile in `working-docs/profiles/` as a starting point.
2. Fill in: `profile`, `stack`, `workingDir`, `protectedPaths`, `apiBoundary`, the `build`
   verb table, `changeTypeVerbs`, `researchLayers`, and `jira.mode`.
3. Validate it: `python3 -c "import json; json.load(open('working-docs/profiles/<x>.json'))"`
4. Add a row to the profile table in the README.
5. Open a PR describing the stack and how you verified the verbs run.

## Development workflow

This project dogfoods itself — non-trivial changes are a great excuse to run QRSPI. Small
fixes: just open a PR.

1. Fork and branch from `main`.
2. Make your change; keep commits focused with clear messages.
3. If you touched a stage, run `sync-commands.sh` and commit the synced copies too.
4. Open a PR. Describe the problem and the approach; link any finding it came from.

## Code of Conduct

Participation is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating
you agree to uphold it.

## License

By contributing, you agree your contributions are licensed under the [MIT License](LICENSE).
