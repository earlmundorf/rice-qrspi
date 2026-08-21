# findings/ — self-improvement log

Where the workflow writes what it learned. The goal: every ticket QRSPI runs leaves
it sharper for the next one. Two flavors of finding live here:

- **Workflow findings** — the stages themselves could be better. A research layer missed
  a category for some ticket type; a gate let something through; a verb mapping was wrong;
  a tier heuristic mis-fired. These get promoted into the config or, when they apply to
  every project rather than just this one, upstream into the stage commands or SKILL.md.
- **Project-knowledge findings** — a fact about *this* codebase that the next ticket
  touching the same area should know up front, so its research stage starts ahead.
  (Example: "knowledge-content changes aren't live until a reindex runs" — a ticket in
  that area should know that before designing verification.)

## Why this lives here and not in the skill

These live in `working-docs/findings/`, alongside `config.json` — **not** in
`.claude/skills/qrspi/`. That skill directory is upstream-owned: updating QRSPI replaces
it wholesale, so anything you wrote there would be lost. This directory belongs to the
project and is committed with it (`.gitignore` keeps the rest of `working-docs/` out but
whitelists this).

## What belongs here

- A stage produced a worse result than it should have, and you can say why.
- A verification verb / change-type mapping in `working-docs/config.json` was missing or wrong.
- A recurring project pattern worth front-loading into future research (an API quirk, a
  build gotcha, a "this repo does X differently" convention).
- A tier recommendation that turned out wrong, and the signal that should have changed it.

## What does NOT belong here

- Per-ticket status (that's the `plan.md` checkboxes) or the per-ticket retro
  (that's `working-docs/<KEY>/validation.md`).
- Anything already stated in the repo's CLAUDE.md or the stage commands.
- Secrets or customer data.

## File naming

One finding per file: `YYYY-MM-DD-{slug}.md`, from `TEMPLATE.md`.

## The loop

1. **Start of a ticket (stage 1):** the skill lists `working-docs/findings/*.md` (excluding README/TEMPLATE)
   and loads any whose `applies_to` matches the ticket's area/type — so research starts
   informed by what prior tickets learned.
2. **During a ticket:** when a stage hits something the references didn't cover, write a
   finding. Even small ones count.
3. **End of a ticket (stage 7):** summarize new findings and propose which to **promote**
   into the stage commands, SKILL.md, the config, or the repo's CLAUDE.md. Promotion is
   always user-approved. Mark promoted findings `status: promoted`.

Unpromoted findings still load on the next run — they help even before promotion.
