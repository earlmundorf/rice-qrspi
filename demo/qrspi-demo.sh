#!/usr/bin/env bash
# Scripted reenactment of a `/cq:go TODO-1` run, used to render the demo GIF
# (see demo.tape). This is a dramatization for a clean, reproducible recording —
# NOT a live model run. The real artifacts, gate prompts, and commands are in
# .claude/skills/qrspi/WALKTHROUGH.md and the runnable examples/fastapi-todo.
set -euo pipefail

B=$'\033[1m'; D=$'\033[2m'; G=$'\033[32m'; C=$'\033[36m'; Y=$'\033[33m'; M=$'\033[35m'; R=$'\033[0m'

p() { printf '%s\n' "$1"; sleep "${2:-0.6}"; }            # line
s() { printf '%s%s%s\n' "$C$B" "$1" "$R"; sleep 0.5; }    # stage header

clear
printf '%s❯%s %s/cq:go TODO-1%s\n' "$M" "$R" "$B" "$R"; sleep 1.0
p "${D}reading tickets/active/TODO-1-mark-todo-complete.md${R}" 0.7
p "recommended tier: ${B}full${R} ${D}(3 layers + tests, one real design choice)${R}  ▸ ${G}confirmed${R}" 0.9

s "1 · Ticket"
p "  ${G}✓${R} ticket.md   ${G}✓${R} questions.md  ${D}— 8 neutral research questions${R}"

s "2 · Research ${D}(blind — never reads the ticket)${R}"
p "  ${D}routes app/routers/todos.py:8 · 404 pattern todos.py:24${R}" 0.5
p "  ${D}store.py has no update method — mutation surface is add() only${R}"

s "3 · Design  ${Y}★ DEV GATE${R}"
p "  ${Y}Q1${R} HTTP shape   (A) PATCH /todos/{id}  (B) PUT  (C) POST …/complete  ▸ ${B}A${R}" 0.8
p "  ${Y}Q2${R} request model  new TodoUpdate{completed: bool}                   ▸ ${B}A${R}" 0.8
p "  ${G}✓${R} design.md  ${D}— criteria: pytest + ruff + mypy / manual curl${R}"

s "4 · Structure  ${Y}★ DEV GATE${R}"
p "  ${G}✓${R} 2 vertical slices, each with a checkpoint"

s "5 · Plan"
p "  ${G}✓${R} plan.md  ${D}— checkboxed; commands resolved from config.json${R}"

s "6 · Implement ${D}mode=claude${R}"
p "  S1 schema + store    ${G}✓${R} mypy   ${G}✓ pytest 4 passed${R}" 0.6
p "  S2 PATCH endpoint     ${G}✓${R} ruff  ${G}✓${R} mypy  ${G}✓ pytest 5 passed${R}" 0.7

s "7 · Validate  ${Y}★ DEV GATE${R}"
p "  ${G}✓${R} pytest ${G}5 passed${R}   ${G}✓${R} ruff clean   ${G}✓${R} mypy clean" 0.6
p "  ${Y}\"Have you read this diff and own it?\"${R} ▸ ${B}yes${R}" 0.9
p "  ${G}✓${R} PR opened   ${G}✓${R} TODO-1 → tickets/completed/"

printf '\n%s%s done — one small, owned diff. swap the profile, same 7 stages on any stack.%s\n' "$G" "$B" "$R"
sleep 1.4
