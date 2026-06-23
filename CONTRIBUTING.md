# Contributing to rice-qrspi

Thanks for your interest — a quick, honest note on how this project is run.

## This is a personal project

rice-qrspi is maintained by one person, on purpose, as a personal open-source project. To
keep it sustainable, the contribution model is intentionally narrow:

- ✅ **Forking is encouraged.** It's [MIT-licensed](LICENSE) — fork it, adapt it, build
  profiles for your stack, ship your own version. That's exactly what it's for.
- ✅ **Issues are welcome.** Found a bug, hit a rough edge? [Open an
  issue](https://github.com/earlmundorf/rice-qrspi/issues). I read them.
- ✅ **Want to propose a new feature?** Open an issue describing it. If it's a good fit, I'm
  happy to **collaborate** with you on getting it in — that's the path for code, rather than
  a surprise PR.
- 🚫 **Unsolicited pull requests aren't accepted.** PRs from people I don't already work
  with are **closed automatically** (politely — see `.github/workflows/close-external-prs.yml`).
  It's not personal; it's how I keep a solo project manageable. Start with an issue and
  let's talk.

So: **fork freely, file issues, but don't send code you'd be unhappy to see closed.**

## If you forked it (the recommended path)

Everything below helps your fork stay healthy. None of it is a request to send changes back
here — it's how the skill is meant to be extended in *your* copy.

### Keep the stages stack-neutral

The whole point of QRSPI is **one skill, many stacks**. A stage command should never hardcode
a stack-specific path, command, or vocabulary. If something varies by stack, it belongs in
`working-docs/config.json`, not in a stage:

- a command to run → a **verb** in `build` + a `changeTypeVerbs` mapping
- a place to look → a `researchLayers` entry
- a path to never touch → `protectedPaths`
- the I/O boundary → `apiBoundary`

If you catch yourself writing "for React, do X; for Spring Boot, do Y" in a stage, that's the
signal to add a config field instead.

### Adding a profile for your stack

1. Copy an existing profile in `working-docs/profiles/` as a starting point.
2. Fill in: `profile`, `stack`, `workingDir`, `protectedPaths`, `apiBoundary`, the `build`
   verb table, `changeTypeVerbs`, `researchLayers`, and `jira.mode`.
3. Validate it: `python3 -c "import json; json.load(open('working-docs/profiles/<x>.json'))"`.
4. Point `working-docs/config.json` at it and run a ticket through `/cq:go`.

### Editing stages — keep the two copies in sync

`.claude/skills/qrspi/commands/*.md` is the **source of truth**. Claude Code reads `/cq:*`
from `.claude/commands/cq/`. After editing a stage, re-sync:

```bash
.claude/skills/qrspi/sync-commands.sh
```

## License

MIT — see [LICENSE](LICENSE). Forks and derivatives are welcome under the same terms.
