# demo/

The demo GIF in the project README is rendered with
[VHS](https://github.com/charmbracelet/vhs) from [`demo.tape`](demo.tape).

## What it shows

`qrspi-demo.sh` is a **scripted reenactment** of a `/cq:go TODO-1` run — the seven stages,
the two design-gate questions, and the verified checkpoints, in about 20 seconds. It's a
dramatization so the recording is clean and reproducible (no live model, auth, or network
at render time). For the **real** thing, see:

- [`../.claude/skills/qrspi/WALKTHROUGH.md`](../.claude/skills/qrspi/WALKTHROUGH.md) — the
  actual artifacts each stage produces, narrated end to end.
- [`../examples/fastapi-todo`](../examples/fastapi-todo) — run it yourself: `./setup.sh`
  then `/cq:go TODO-1`.

## Render the GIF

```bash
# one-time: install vhs (brings ttyd + ffmpeg as deps)
brew install vhs            # or: https://github.com/charmbracelet/vhs#installation

# from the repo root — writes BOTH outputs:
vhs demo/demo.tape          #   demo/qrspi-demo.gif  (loops, for the README)
                            #   demo/qrspi-demo.mp4  (plays once, with pause/scrub controls)
```

Both are committed and referenced from the top-level README.

## Tweak the pacing

A GIF can't be paused, so pacing is controlled entirely by the `sleep` values in
[`qrspi-demo.sh`](qrspi-demo.sh):

- `LINE` / `HEAD` / `GATE` — per-line pauses (raise them to slow it down overall).
- `HOLD` — how long the final summary frame stays on screen before the GIF loops.
- The script runs ~29s; the tape's trailing `Sleep` (in [`demo.tape`](demo.tape)) is set
  **just under** that so the recording ends on the summary frame instead of the returning
  shell prompt. If you change the script's runtime, adjust that `Sleep` to match.

Size, theme, and font also live in [`demo.tape`](demo.tape). For true pause/scrub, point
people at the `.mp4`.
