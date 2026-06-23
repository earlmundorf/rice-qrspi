# VHS tape for the QRSPI demo GIF.
# Render from the repo root:  vhs demo/demo.tape   →   demo/qrspi-demo.gif
# Install VHS: https://github.com/charmbracelet/vhs  (brew install vhs)

Output demo/qrspi-demo.gif

Set Shell bash
Set FontSize 15
Set Width 1080
Set Height 760
Set Padding 24
Set Theme "Catppuccin Mocha"
Set TypingSpeed 35ms

# The script clears the screen and renders the reenactment; the typed path
# flashes briefly, then `clear` wipes it.
Type "./demo/qrspi-demo.sh"
Sleep 500ms
Enter
Sleep 22s
