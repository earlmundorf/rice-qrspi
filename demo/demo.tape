# VHS tape for the QRSPI demo.
# Render from the repo root:  vhs demo/demo.tape
#   → demo/qrspi-demo.mp4  (embedded in the README with <video controls>; play on demand)
# Install VHS: https://github.com/charmbracelet/vhs  (brew install vhs)

Output demo/qrspi-demo.mp4

Set Shell bash
Set FontSize 15
Set Width 1080
Set Height 760
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 35ms

# The script clears the screen and renders the reenactment; the typed path flashes
# briefly, then `clear` wipes it. The script runs ~29s with a 7s hold at the end;
# we stop recording ~5s into that hold so the GIF ends on the summary, not the prompt.
Type "./demo/qrspi-demo.sh"
Sleep 500ms
Enter
Sleep 27s
