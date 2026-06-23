# rice-qrspi

[![CI](https://github.com/earlmundorf/rice-qrspi/actions/workflows/ci.yml/badge.svg)](https://github.com/earlmundorf/rice-qrspi/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Fork-friendly](https://img.shields.io/badge/fork-friendly-brightgreen.svg)](CONTRIBUTING.md)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-8A2BE2.svg)](https://claude.com/claude-code)

**QRSPI** is a structured way to take a ticket from *"here's a Jira issue"* to *"here's a
reviewed PR"* — without losing the plot halfway through. It's packaged as a single,
stack-neutral [Claude Code](https://claude.com/claude-code) skill that works the same on a
React frontend, a Spring Boot service, or anything else, because everything
project-specific lives in one config file.

This repo is the canonical, copy-me home for that skill. Take it, point it at your codebase,
and run `/cq:go YOUR-TICKET`.

## See it run

A `/cq:go TODO-1` run — Ticket → Research → Design → Structure → Plan → Implement → Validate,
with the gates and verified checkpoints, in about 20 seconds:

![QRSPI demo](demo/qrspi-demo.gif)

> Rendered by [VHS](https://github.com/charmbracelet/vhs) from
> [`demo/demo.tape`](demo/demo.tape) — a faithful reenactment for a clean, reproducible
> clip. The **real** artifacts and commands are in the
> [WALKTHROUGH](.claude/skills/qrspi/WALKTHROUGH.md), and you can run the whole thing
> yourself in [`examples/fastapi-todo`](examples/fastapi-todo).

---

## The idea

Working a non-trivial ticket well means doing seven things in order, and *not* skipping the
boring middle. QRSPI names them and gives each its own fresh context so the model never
runs them all mushed together:

| | Stage | What it produces |
|---|---|---|
| **Q** | **Q**uestion / Ticket | The ticket restated, plus 8–15 *neutral* research questions |
| **R** | **R**esearch | Blind, layered codebase research — facts with `file:line`, no solutioning |
| | **D**esign | Q&A **first**, then a ~200-line design doc with split success criteria |
| **S** | **S**tructure | The work cut into vertical slices, each with a verification checkpoint |
| **P** | **P**lan | A checkboxed tactical plan, commands resolved from your config |
| **I** | **I**mplement | Slice by slice; never proceeds on a red check; one commit per slice |
| | **V**alidate | Re-run criteria, diff-ownership gate, open the PR |

Three short human gates (Design, Structure, Validate) are where you steer; everything else
runs on rails. A four-tier system (`trivial · simple · full · comprehensive`) scales the
ceremony to the ticket so a typo doesn't get the full treatment.

## Why not just prompt the model?

You can — and for a typo you should (that's the `trivial` tier). But on a real ticket, a
single "here's the issue, go fix it" prompt collapses research, design, and coding into one
breath. The model picks an approach in its first sentence and then rationalizes it; the
design choice never actually surfaces, the "research" is whatever justifies the code it
already wrote, and you find out at review time that it solved the wrong problem. Long single
sessions also drift as the context fills with diffs and dead ends.

QRSPI is the structure that prevents that:

- **Blind research.** Stage 2 never sees the ticket — it documents what *is*, with
  `file:line`, so the design is grounded in the codebase instead of motivated by a
  foregone conclusion.
- **Design before code.** Stage 3 *must* ask its questions and get your answers before it
  writes a line — the PATCH-vs-PUT-type decisions become explicit and yours, not implicit
  and the model's.
- **Fresh context per stage.** Each stage reads only its declared inputs and stays small,
  so none of them rots under a giant scrollback, and each artifact is reviewable on its own.
- **"Done" means verified.** Checkpoints resolve to real commands from your config; the
  workflow never proceeds on a red check or opens a PR you haven't explicitly owned.
- **It compounds.** Each ticket can leave a `findings/` note that makes the next run sharper.

The cost is a few minutes at three gates. The payoff is catching the wrong approach before
it's a 400-line diff. When that tradeoff isn't worth it, drop a tier — same skill, less
ceremony.

## Why it travels: one skill, many stacks

The reason you can adopt this anywhere is that **the stage commands contain zero
stack-specific logic.** Everything that differs between projects lives in
`working-docs/config.json` (a "profile"):

| In the config | Replaces hardcoding… |
|---|---|
| `build` verbs + `changeTypeVerbs` | "run `npm run build`" vs "run `./mvnw package`" |
| `researchLayers` | which parts of the codebase stage 2 investigates |
| `protectedPaths` | `node_modules/dist` vs `target/`/`build/` |
| `apiBoundary` | the "all I/O goes through this layer" rule |
| `jira.mode` | `mcp` (automated) · `manual` (paste-in) · `none` |

Three ready-made profiles ship in [`working-docs/profiles/`](working-docs/profiles): a
React/Vite **storefront**, a **Spring Boot** service, and a **FastAPI** service. Adding
your stack is usually just a new profile — no forking the skill.

## Try it in 2 minutes (runnable examples)

The fastest way to *get* QRSPI is to watch it work. This repo ships two tiny apps — the
**same ticket (TODO-1) on two stacks** — each with the skill and an open ticket pre-wired:

| Example | Stack | You need | Setup |
|---|---|---|---|
| [`examples/fastapi-todo`](examples/fastapi-todo) | Python · FastAPI | **uv** ([install](https://docs.astral.sh/uv/)) | `cd examples/fastapi-todo && ./setup.sh` |
| [`examples/react-todo`](examples/react-todo) | TypeScript · React/Vite | **Node ≥ 20** ([install](https://nodejs.org/)) | `cd examples/react-todo && ./setup.sh` |

`setup.sh` checks your prerequisite, installs the skill, publishes `/cq`, and installs deps
(everything else — ruff/mypy/pytest or tsc/eslint/vite — comes automatically). Then, in
Claude Code from that folder:

```
/cq:go TODO-1
```

Claude takes the ticket ("let users mark a todo complete") through all seven stages against
real code. The [**WALKTHROUGH**](.claude/skills/qrspi/WALKTHROUGH.md) narrates the FastAPI run
stage by stage — read it side by side. The two examples prove the headline: identical flow,
only the resolved commands differ.

## Quickstart — adopt it in your repo

```bash
# 1. Copy the skill into your project
cp -r rice-qrspi/.claude/skills/qrspi  /path/to/your-repo/.claude/skills/

# 2. Pick the closest profile as your starting config
cp rice-qrspi/working-docs/profiles/storefront.json  /path/to/your-repo/working-docs/config.json
#    (edit it: verbs, research layers, protected paths, jira.mode)

# 3. Publish the /cq:* slash commands
/path/to/your-repo/.claude/skills/qrspi/sync-commands.sh
```

Then, in Claude Code from your repo:

```
/cq:go PROJ-123
```

Claude recommends a tier, you confirm, and it's off. New to it? Read the
[**WALKTHROUGH**](.claude/skills/qrspi/WALKTHROUGH.md) (a full worked example) or the
one-page [**QUICKREF**](.claude/skills/qrspi/QUICKREF.md).

## What's in here

```
.
├── .claude/skills/qrspi/        # THE SKILL — copy this into your repo
│   ├── SKILL.md                 #   orchestration + the config schema
│   ├── README · QUICKREF · WALKTHROUGH
│   ├── commands/0_go … 7_validate.md
│   ├── findings/                #   self-improvement log (the skill learns per ticket)
│   └── sync-commands.sh
├── working-docs/
│   ├── config.json              # active profile (a fill-in template here)
│   └── profiles/                # storefront.json · springboot.json · fastapi.json
├── tickets/{active,completed}/  # optional local ticket store (when Jira isn't wired)
├── examples/
│   ├── fastapi-todo/            # runnable demo (Python) + the ticket the WALKTHROUGH works
│   └── react-todo/             # the same ticket on a React/Vite stack
├── CONTRIBUTING.md · CODE_OF_CONDUCT.md · LICENSE
```

## Using & adapting it

This is a personal project, and the best way to use it is to **fork it and make it yours** —
it's MIT, so adapt it freely, add profiles for your stack, ship your own version. Found a bug
or have an idea? **Open an issue** — I read them. I'm **not accepting unsolicited pull
requests** (they're closed automatically; nothing personal), so please don't send code you'd
be sad to see closed — see [CONTRIBUTING.md](CONTRIBUTING.md) for the why and the how.

If you're extending it, the one design rule: keep the stages stack-neutral; anything that
varies by stack goes in the config, not the command.

## Attribution

Inspired by the QRSPI ticket-workflow approach; the command mechanics here were adapted from
an MIT-licensed implementation ([github.com/matanshavit/qrspi](https://github.com/matanshavit/qrspi)).
This repo genericizes project-specific variants into a single, config-driven skill.

## License

[MIT](LICENSE) © 2026 Jon Mundorf
