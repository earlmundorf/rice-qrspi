# tickets/

Optional local ticket store. When Jira isn't wired up (`jira.mode: manual` or `none`),
drop a ticket as a markdown file here and QRSPI stage 1 will read it as the ticket source.

```
tickets/
├── active/      # open tickets — one .md per ticket (e.g. PROJ-101-add-feature-x.md)
└── completed/   # stage 7 moves a ticket here when it ships
```

**How it's used:** stage 1 (`/cq:1_ticket`) checks `tickets/active/` for a file matching
the key/slug before asking you to paste; a match wins over MCP and paste. Stage 7
(`/cq:7_validate`) moves the file to `tickets/completed/` so `active/` always reflects the
real remaining backlog.

A ticket file is just freeform markdown: title, description, acceptance criteria, and any
notes worth keeping.
