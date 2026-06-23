# /cq Quick Reference

One page. Details: README.md (why) · SKILL.md (machinery) · WALKTHROUGH.md (worked example).

## The one command

```
/cq:go <TICKET-KEY or "description"> [tier]
```

No tier → Claude recommends one; confirm before anything runs.

## Tiers

| Tier | Use for | Runs | You spend |
|---|---|---|---|
| `trivial` | Typo, config value, <3 files, no design choice | fix → verify → diff → own it | ~2 min |
| `simple` | Known-cause bug, small single-area change | brief.md (gate) → implement → validate-lite | ~5 min |
| `full` | Standard feature with design choices | 1+2 auto → design ★ → structure ★ → plan → implement → validate ★ | ~25 min at gates |
| `comprehensive` | Cross-cutting, risky, migration, team review | full + worktree + full verification per slice + team sees design/structure first | + review cycle |

Promote mid-flight anytime: "this is bigger than we thought" → skipped stages run then.

## Stages (run each in a FRESH session; each prints the next command)

| Command | Does | Gate |
|---|---|---|
| `/cq:1_ticket <KEY>` | ticket.md + neutral questions.md | skim |
| `/cq:2_research <dir>` | Blind layered research (never reads the ticket) → facts w/ file:line | — |
| `/cq:3_design <dir>` | Q&A FIRST (options A/B/C), then design.md ~200 lines | ★ approve |
| `/cq:4_structure <dir>` | Vertical slices + verification checkpoints, ~2 pages | ★ approve |
| `/cq:5_plan <dir>` | Checkboxed tactical plan, commands resolved from config | spot-check |
| `/cq:6_implement <dir> mode=dev\|claude` | Slice-by-slice; never proceeds on red; 1 commit/slice | — |
| `/cq:7_validate <dir>` | Criteria re-run + diff-ownership gate + PR + Jira update | ★ "own it" |

`<dir>` = `working-docs/<TICKET-KEY>/`

## Going backward

Bad questions → re-run 1 · missing facts at design → 1+2 · flawed design at structure → 3 ·
fundamental plan error while implementing → 5 (or 3). Small mismatches: adapt in place.

## Config (`working-docs/config.json` — committed, per repo)

Stages reference VERBS; config resolves them to this repo's real commands. Research
layers also live in config (`researchLayers`) — this is what makes the skill stack-
neutral. `protectedPaths` lists what to never touch; `apiBoundary` names the I/O layer.
A verb may be `MANUAL: <steps>` — Claude prints them and waits. `jira.mode`: `mcp`
(automated) · `manual` (you paste in; updates written paste-ready to
`<dir>/jira-updates.md`) · `none`. Three starter profiles in `working-docs/profiles/`
(storefront · springboot · fastapi).

## Resume

Checkboxes in plan.md are the resume mechanism — a fresh session reads them and
continues at the first unchecked task. Artifacts in `working-docs/<KEY>/` are
gitignored except config.json and profiles/.

## Findings (the skill learns)

Stage 1 loads `findings/*.md` whose area matches your ticket; stage 7 captures new ones
and proposes promotion into the stages/config/CLAUDE.md. Findings live IN the skill
(tracked), not in `working-docs/` (per-ticket scratch). One finding per file from
`TEMPLATE.md`.

## Safety rails (every tier, no exceptions)

Verification verbs before claiming done · diff-ownership gate before any PR ·
never modify `protectedPaths` · all I/O through the configured boundary layer ·
never push/deploy without consent.
