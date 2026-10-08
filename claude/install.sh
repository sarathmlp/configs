#!/usr/bin/env bash
# Copy this Claude Code config into ~/.claude, recording what it changes so
# uninstall.sh can put ~/.claude back exactly as it was. Safe to re-run.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.claude"
STATE="$DEST/config-install"
MANIFEST="$STATE/manifest"

# Manifest lines are "<kind>\t<path relative to ~/.claude>":
#   new       file did not exist before; uninstall deletes it
#   replaced  original saved under $STATE/originals; uninstall restores it
#   dir       directory created by install; uninstall removes it if empty
recorded() { [ -f "$MANIFEST" ] && grep -q "	$1\$" "$MANIFEST"; }
record() { printf '%s\t%s\n' "$1" "$2" >> "$MANIFEST"; }

make_dirs() {
  local missing="" d="$1"
  while [ ! -d "$DEST/$d" ]; do
    missing="$d $missing"
    [ "$d" = "." ] && break
    d="$(dirname "$d")"
  done
  for d in $missing; do
    mkdir "$DEST/$d"
    recorded "$d" || record dir "$d"
  done
}

[ -d "$DEST" ] || { mkdir -p "$DEST"; FRESH=1; }
mkdir -p "$STATE/originals"
[ "${FRESH:-}" = 1 ] && ! recorded . && record dir .

installed=0 unchanged=0
cd "$SRC"
while IFS= read -r f; do
  target="$DEST/$f"
  if [ -f "$target" ] && cmp -s "$f" "$target"; then
    unchanged=$((unchanged + 1))
    continue
  fi
  if ! recorded "$f"; then
    if [ -f "$target" ]; then
      mkdir -p "$STATE/originals/$(dirname "$f")"
      cp -p "$target" "$STATE/originals/$f"
      record replaced "$f"
    else
      record new "$f"
    fi
  fi
  make_dirs "$(dirname "$f")"
  cp "$f" "$target"
  echo "installed $f"
  installed=$((installed + 1))
done < <(find CLAUDE.md RTK.md settings.json skills agents -type f | sort)

echo "$installed installed, $unchanged unchanged → $DEST"
echo "uninstall.sh restores ~/.claude to how it was before the first install"
command -v rtk >/dev/null || echo "warning: rtk not on PATH — settings.json's hook and the review skills need it"
[ "$installed" -gt 0 ] && echo "Start a new Claude Code session so new or changed agents load."
exit 0
