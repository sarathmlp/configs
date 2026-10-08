#!/usr/bin/env bash
# Copy the Claude Code config from ~/.claude into this directory, so changes
# made there can be committed. The reverse of install.sh; it never commits.
set -euo pipefail

SRC="$HOME/.claude"
DEST="$(cd "$(dirname "$0")" && pwd)"
# Skills that are not ours: graphify is installed by its own tool, synced/ is
# managed by claude.ai.
SKIP_SKILLS="graphify synced"

files() {
  for f in CLAUDE.md RTK.md settings.json; do [ -f "$f" ] && echo "$f"; done
  [ -d agents ] && find agents -maxdepth 1 -type f -name '*.md'
  for d in skills/*/; do
    name="$(basename "$d")"
    case " $SKIP_SKILLS " in *" $name "*) continue ;; esac
    find "skills/$name" -type f
  done
}

copied=0 unchanged=0
cd "$SRC"
while IFS= read -r f; do
  if [ -f "$DEST/$f" ] && cmp -s "$f" "$DEST/$f"; then
    unchanged=$((unchanged + 1))
    continue
  fi
  mkdir -p "$DEST/$(dirname "$f")"
  cp "$f" "$DEST/$f"
  echo "collected $f"
  copied=$((copied + 1))
done < <(files | sort)

echo "$copied collected, $unchanged unchanged → $DEST"
git -C "$DEST" status --short -- .
