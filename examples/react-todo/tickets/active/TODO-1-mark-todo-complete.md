# TODO-1 — Let users mark a todo complete

**Type:** Feature
**Reporter:** product

## Description

The list shows todos and you can add new ones, but there's no way to check one off.
The `Todo` type already has a `completed` flag (and `TodoList` already strikes through
items whose `completed` is `true`) — but nothing in the UI ever sets it.

## Acceptance criteria

- Each todo in the list can be toggled complete/incomplete, and the change is reflected
  immediately (the item shows as done).
- The change goes through the API boundary (`src/services/api.ts`), not directly from a
  component.
- Loading and error states are handled; existing add/list behavior is unchanged.

## Notes

- Keep it small and conventional — this is a starter example.
- No backend; the in-memory store in `src/services/api.ts` is fine.
