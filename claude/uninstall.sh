#!/usr/bin/env bash
# Undo install.sh: delete the files it added, restore the files it replaced,
# and remove the directories it created, leaving ~/.claude as it was before.
# Refuses if an installed file was edited since; pass --force to discard edits.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
STATE="$DEST/config-install"
MANIFEST="$STATE/manifest"
FORCE="${1:-}"

[ -f "$MANIFEST" ] || { echo "Nothing to undo: no install record at $MANIFEST"; exit 1; }

edited=""
while IFS=$'\t' read -r kind f; do
  [ "$kind" = dir ] && continue
  if [ -f "$DEST/$f" ] && ! cmp -s "$DEST/$f" "$SRC/$f" 2>/dev/null; then
    edited="$edited $f"
  fi
done < "$MANIFEST"
if [ -n "$edited" ] && [ "$FORCE" != "--force" ]; then
  echo "These installed files were changed since install (or differ from this repo):"
  for f in $edited; do echo "  $f"; done
  echo "Run collect.sh to keep the changes, or uninstall.sh --force to discard them."
  exit 1
fi

restored=0 removed=0
while IFS=$'\t' read -r kind f; do
  case "$kind" in
    replaced) cp -p "$STATE/originals/$f" "$DEST/$f"; echo "restored $f"; restored=$((restored + 1)) ;;
    new)      rm -f "$DEST/$f"; echo "removed  $f"; removed=$((removed + 1)) ;;
  esac
done < "$MANIFEST"

dirs="$(awk -F'\t' '$1 == "dir" { print $2 }' "$MANIFEST" | sort -r)"
rm -rf "$STATE"
# Deepest first; a directory that now holds anything else (e.g. Claude Code's
# own state in a fresh ~/.claude) is kept.
kept=0
for d in $dirs; do
  target="$DEST/$d"; [ "$d" = . ] && target="$DEST"
  if rmdir "$target" 2>/dev/null; then echo "removed  $target/"; else kept=$((kept + 1)); fi
done

echo "$restored restored, $removed removed — ~/.claude is back to how it was before install"
[ "$kept" -gt 0 ] && echo "$kept directory(ies) kept because they now hold other files"
echo "Start a new Claude Code session so removed agents and skills unload."
exit 0
