#!/usr/bin/env sh
# QRSPI installer — macOS / Linux / WSL / Git Bash.
# On Windows, run it from Git Bash or WSL; it needs only POSIX sh, no bashisms.
#
#   ./install.sh list                          show available profiles
#   ./install.sh <profile> <target-dir>        install into <target-dir>
#   ./install.sh <profile> --target <dir>      same, explicit flag
#
# Installs the skill, publishes the /cq: commands, and seeds working-docs/ in the target
# repo. The target is required: this repo is the source of truth and is never installed
# into itself.
#
# Nothing is deleted outside <target>/.claude/skills/qrspi and <target>/.claude/commands/cq.
# An existing <target>/working-docs/config.json is never overwritten.

set -eu

SELF_DIR=$(cd "$(dirname "$0")" && pwd)
SKILL_SRC="$SELF_DIR/.claude/skills/qrspi"
PROFILES_DIR="$SELF_DIR/working-docs/profiles"
FINDINGS_SRC="$SELF_DIR/working-docs/findings"
VERSION=$(git -C "$SELF_DIR" describe --tags --always 2>/dev/null || echo unknown)

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

# --- read one single-line string field out of a profile, without assuming jq ---------
field() {
  grep -m1 "\"$2\"" "$1" 2>/dev/null \
    | sed -e "s/^.*\"$2\"[[:space:]]*:[[:space:]]*\"//" -e 's/",*[[:space:]]*$//'
}

summary() {  # first entry of _notes
  awk '/"_notes"/{getline; gsub(/^[[:space:]]*"/,""); gsub(/",?[[:space:]]*$/,""); print; exit}' "$1"
}

cmd_list() {
  printf '\nQRSPI %s — available profiles:\n\n' "$VERSION"
  for p in "$PROFILES_DIR"/*.json; do
    [ -f "$p" ] || continue
    printf '  %-24s %s\n' "$(basename "$p" .json)" "$(field "$p" stack)"
    printf '  %-24s %s\n\n' "" "$(summary "$p")"
  done
  printf 'Install with:  %s <profile> <target-dir>\n\n' "$0"
}

cmd_install() {
  profile=$1
  target=$2
  src="$PROFILES_DIR/$profile.json"

  # ---- validate everything BEFORE touching the target -------------------------------
  [ -f "$src" ] || { printf 'error: no such profile: %s\n\n' "$profile" >&2; cmd_list >&2; exit 1; }
  [ -d "$target" ] || die "target directory does not exist: $target"
  [ -w "$target" ] || die "target directory is not writable: $target"
  [ -f "$SKILL_SRC/SKILL.md" ] || die "source looks incomplete: $SKILL_SRC/SKILL.md not found"

  target_abs=$(cd "$target" && pwd)
  [ "$target_abs" != "$SELF_DIR" ] || die "refusing to install into this repo — it is the source of truth. Pass a different target."

  # triggerVocabulary is optional: when a profile defines it, the installed SKILL.md gets
  # a stack-specific trigger clause appended. The skill directory is replaced wholesale
  # on every install, so the clause is added to a pristine copy and can never double up.
  tv=$(field "$src" triggerVocabulary)
  case $tv in
    *\\*) die "triggerVocabulary in $profile.json must not contain a backslash" ;;
  esac

  printf 'Installing profile %s (QRSPI %s)\n  into %s\n\n' "$profile" "$VERSION" "$target_abs"

  # ---- 1. the skill (generated in the target: replaced wholesale) --------------------
  rm -rf "$target/.claude/skills/qrspi"
  mkdir -p "$target/.claude/skills/qrspi"
  cp -R "$SKILL_SRC/." "$target/.claude/skills/qrspi/"
  printf '  .claude/skills/qrspi/            installed\n'

  # ---- 2. append the stack trigger clause to the installed copy ----------------------
  skill="$target/.claude/skills/qrspi/SKILL.md"
  if [ -n "$tv" ]; then
    # Insert a folded-scalar continuation line just before the frontmatter's closing ---.
    awk -v tv="$tv" 'BEGIN{d=0}
      /^---$/ { d++; if (d==2) print "  Also triggers on: " tv }
      { print }' "$skill" > "$skill.tmp" && mv "$skill.tmp" "$skill"
    printf '  SKILL.md frontmatter             trigger clause appended for %s\n' "$profile"
  else
    printf '  SKILL.md frontmatter             generic (profile defines no triggerVocabulary)\n'
  fi

  # ---- 3. publish the /cq: commands -------------------------------------------------
  mkdir -p "$target/.claude/commands/cq"
  cp "$SKILL_SRC/commands/"*.md "$target/.claude/commands/cq/"
  printf '  .claude/commands/cq/             published (/cq:go … /cq:7_validate)\n'

  # ---- 4. the config: never overwrite ----------------------------------------------
  mkdir -p "$target/working-docs"
  cfg="$target/working-docs/config.json"
  if [ -f "$cfg" ]; then
    cp "$src" "$cfg.new"
    printf '  working-docs/config.json         KEPT (yours) — profile written to config.json.new\n'
    config_note="existing config kept; review config.json.new and merge, then delete it"
  else
    cp "$src" "$cfg"
    printf '  working-docs/config.json         written from %s\n' "$profile"
    config_note="config written; fill in any <placeholders> it names"
  fi

  # ---- 5. seed the findings log (never clobber existing findings) --------------------
  mkdir -p "$target/working-docs/findings"
  for f in README.md TEMPLATE.md; do
    if [ ! -f "$target/working-docs/findings/$f" ] && [ -f "$FINDINGS_SRC/$f" ]; then
      cp "$FINDINGS_SRC/$f" "$target/working-docs/findings/$f"
    fi
  done
  printf '  working-docs/findings/           seeded (existing findings untouched)\n'

  # ---- 6. stamp what produced this install -----------------------------------------
  cat > "$target/.claude/skills/qrspi/.installed-from" <<EOF
profile: $profile
qrspiVersion: $VERSION
installedAt: $(date +%Y-%m-%d)
source: $SELF_DIR
note: generated directory — edit the source repo and re-install, never edit here
EOF
  printf '  .installed-from                  stamped\n'

  # ---- 7. sanity-check the config the target will actually run ----------------------
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$cfg" <<'PY' || true
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception as e:
    print(f"  config check                     WARNING: unreadable JSON ({e})"); sys.exit()
known = {"profile","profileVersion","stack","workingDir","buildTool","packageManager","appModule",
         "framework","protectedPaths","apiBoundary","build","changeTypeVerbs","jira","researchLayers",
         "questionCategories","manualVerificationSurfaces","sliceExample","verbNamespaces",
         "triggerVocabulary","_notes","project"}
build = d.get("build", {})
bad = [v for vs in d.get("changeTypeVerbs", {}).values() for v in vs if v not in build]
unknown = sorted(set(d) - known)
if bad:     print(f"  config check                     ERROR: changeTypeVerbs names verbs missing from build: {sorted(set(bad))}")
if unknown: print(f"  config check                     warning: unknown keys (typo?): {unknown}")
if not bad and not unknown: print("  config check                     ok")
PY
  else
    printf '  config check                     skipped (no python3)\n'
  fi

  printf '\nDone. %s\n' "$config_note"
  printf 'Next:  /cq:go <TICKET-KEY>          (tiers: trivial | simple | full | comprehensive)\n'
  printf 'Installed from %s (left untouched).\n\n' "$SELF_DIR"
}

main() {
  [ $# -ge 1 ] || { cmd_list; exit 0; }
  case $1 in
    list|--list|-l|-h|--help|help) cmd_list; exit 0 ;;
  esac

  profile=$1; shift
  target=""
  while [ $# -gt 0 ]; do
    case $1 in
      --target) [ $# -ge 2 ] || die "--target needs a directory"; target=$2; shift 2 ;;
      -*)       die "unknown argument: $1" ;;
      *)        [ -z "$target" ] || die "target given twice: $target and $1"; target=$1; shift ;;
    esac
  done
  [ -n "$target" ] || die "a target directory is required — usage: $0 <profile> <target-dir>"
  cmd_install "$profile" "$target"
}

main "$@"
