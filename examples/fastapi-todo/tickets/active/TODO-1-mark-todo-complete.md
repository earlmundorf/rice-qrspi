# TODO-1 — Let users mark a todo complete

**Type:** Feature
**Reporter:** product

## Description

Right now a todo can be created and listed, but there's no way to mark one as done.
The `Todo` model already carries a `completed` flag (defaults to `false`), but no
endpoint ever changes it. Users want to check items off.

## Acceptance criteria

- A client can mark an existing todo complete, and the change is reflected when the
  todo is fetched or listed.
- Marking a todo that doesn't exist returns a clear 404.
- Existing create/list/get behavior is unchanged.

## Notes

- Keep it small and conventional — this is a starter example.
- No persistence/database in scope; the in-memory store is fine.
