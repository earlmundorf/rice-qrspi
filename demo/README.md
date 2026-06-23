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

# from the repo root
vhs demo/demo.tape          # writes demo/qrspi-demo.gif
```

Then embed it in the top-level README (the line is pre-written there, commented out — just
uncomment it) and commit `demo/qrspi-demo.gif`.

## Tweak it

- Pacing/content live in [`qrspi-demo.sh`](qrspi-demo.sh) (the `sleep` values).
- Size, theme, font, and the capture window live in [`demo.tape`](demo.tape). If you change
  the script's total runtime, update the final `Sleep` in the tape to match.
