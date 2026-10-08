#!/usr/bin/env bash
# Copy this Claude Code config into ~/.claude. Files it would change are
# backed up first; nothing else in ~/.claude is touched.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
BACKUP="$DEST/config-backups/$(date +%Y%m%d-%H%M%S)"

installed=0 unchanged=0 backed_up=0
cd "$SRC"
while IFS= read -r f; do
  target="$DEST/$f"
  if [ -f "$target" ] && cmp -s "$f" "$target"; then
    unchanged=$((unchanged + 1))
    continue
  fi
  if [ -f "$target" ]; then
    mkdir -p "$BACKUP/$(dirname "$f")"
    cp -p "$target" "$BACKUP/$f"
    backed_up=$((backed_up + 1))
  fi
  mkdir -p "$(dirname "$target")"
  cp "$f" "$target"
  echo "installed $f"
  installed=$((installed + 1))
done < <(find CLAUDE.md RTK.md settings.json skills agents -type f | sort)

echo "$installed installed, $unchanged unchanged → $DEST"
[ "$backed_up" -gt 0 ] && echo "$backed_up replaced file(s) backed up to $BACKUP"
command -v rtk >/dev/null || echo "warning: rtk not on PATH — settings.json's hook and the review skills need it"
[ "$installed" -gt 0 ] && echo "Start a new Claude Code session so new or changed agents load."
exit 0
