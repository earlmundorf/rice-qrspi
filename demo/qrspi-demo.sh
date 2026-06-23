#!/usr/bin/env bash
# Scripted reenactment of a `/cq:go TODO-1` run, used to render the demo GIF/MP4
# (see demo.tape). This is a dramatization for a clean, reproducible recording —
# NOT a live model run. The real artifacts, gate prompts, and commands are in
# .claude/skills/qrspi/WALKTHROUGH.md and the runnable examples/fastapi-todo.
#
# Pacing lives here, in the sleep values. The final HOLD keeps the summary frame
# on screen before the GIF loops (a GIF has no pause control); the .mp4 output
# has real pause/scrub controls for anyone who wants them.
set -euo pipefail

B=$'\033[1m'; D=$'\033[2m'; G=$'\033[32m'; C=$'\033[36m'; Y=$'\033[33m'; M=$'\033[35m'; R=$'\033[0m'

LINE=0.9     # default pause after a normal line
HEAD=0.8     # pause after a stage header
GATE=1.2     # pause after a gate question/answer (the moments worth reading)
HOLD=7.0     # final hold — keep the summary on screen before the loop

p() { printf '%s\n' "$1"; sleep "${2:-$LINE}"; }
s() { printf '%s%s%s\n' "$C$B" "$1" "$R"; sleep "$HEAD"; }

clear
printf '%s❯%s %s/cq:go TODO-1%s\n' "$M" "$R" "$B" "$R"; sleep 1.3
p "${D}reading tickets/active/TODO-1-mark-todo-complete.md${R}" 1.0
p "recommended tier: ${B}full${R} ${D}(3 layers + tests, one real design choice)${R}  ▸ ${G}confirmed${R}" "$GATE"

s "1 · Ticket"
p "  ${G}✓${R} ticket.md   ${G}✓${R} questions.md  ${D}— 8 neutral research questions${R}"

s "2 · Research ${D}(blind — never reads the ticket)${R}"
p "  ${D}routes app/routers/todos.py:8 · 404 pattern todos.py:24${R}" 0.8
p "  ${D}store.py has no update method — mutation surface is add() only${R}"

s "3 · Design  ${Y}★ DEV GATE${R}"
p "  ${Y}Q1${R} HTTP shape   (A) PATCH /todos/{id}  (B) PUT  (C) POST …/complete  ▸ ${B}A${R}" "$GATE"
p "  ${Y}Q2${R} request model  new TodoUpdate{completed: bool}                   ▸ ${B}A${R}" "$GATE"
p "  ${G}✓${R} design.md  ${D}— criteria: pytest + ruff + mypy / manual curl${R}"

s "4 · Structure  ${Y}★ DEV GATE${R}"
p "  ${G}✓${R} 2 vertical slices, each with a checkpoint"

s "5 · Plan"
p "  ${G}✓${R} plan.md  ${D}— checkboxed; commands resolved from config.json${R}"

s "6 · Implement ${D}mode=claude${R}"
p "  S1 schema + store    ${G}✓${R} mypy   ${G}✓ pytest 4 passed${R}" 0.9
p "  S2 PATCH endpoint     ${G}✓${R} ruff  ${G}✓${R} mypy  ${G}✓ pytest 5 passed${R}" "$GATE"

s "7 · Validate  ${Y}★ DEV GATE${R}"
p "  ${G}✓${R} pytest ${G}5 passed${R}   ${G}✓${R} ruff clean   ${G}✓${R} mypy clean" 0.9
p "  ${Y}\"Have you read this diff and own it?\"${R} ▸ ${B}yes${R}" "$GATE"
p "  ${G}✓${R} PR opened   ${G}✓${R} TODO-1 → tickets/completed/" 1.0

printf '\n%s%s done — one small, owned diff. swap the profile, same 7 stages on any stack.%s\n' "$G" "$B" "$R"
sleep "$HOLD"
