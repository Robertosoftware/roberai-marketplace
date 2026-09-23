#!/usr/bin/env bash
# Installs the progress-bar main status line (and spinner verbs) into the
# user's Claude Code settings. Safe to re-run; never clobbers an existing
# statusLine/spinnerVerbs unless --force is passed.
set -euo pipefail

FORCE=0
for arg in "$@"; do
  case "$arg" in
    --force) FORCE=1 ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "progress-bar install: jq is required but was not found on PATH" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_STATUSLINE="${CLAUDE_PLUGIN_ROOT:-$SCRIPT_DIR}/statusline.sh"
if [ ! -f "$SOURCE_STATUSLINE" ]; then
  SOURCE_STATUSLINE="$SCRIPT_DIR/statusline.sh"
fi

CLAUDE_DIR="${HOME}/.claude"
DEST_STATUSLINE="${CLAUDE_DIR}/progress-bar-statusline.sh"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
BACKUP_FILE="${CLAUDE_DIR}/settings.json.bak"

mkdir -p "$CLAUDE_DIR"

# 1. Copy the status line script to a stable path outside the plugin cache.
cp "$SOURCE_STATUSLINE" "$DEST_STATUSLINE"
chmod +x "$DEST_STATUSLINE"
echo "Copied statusline.sh -> $DEST_STATUSLINE"

# 2. Back up the existing settings file (or start from an empty object).
if [ -f "$SETTINGS_FILE" ]; then
  cp "$SETTINGS_FILE" "$BACKUP_FILE"
  echo "Backed up $SETTINGS_FILE -> $BACKUP_FILE"
  current_settings="$(cat "$SETTINGS_FILE")"
else
  current_settings="{}"
fi

existing_status_line=$(echo "$current_settings" | jq -r '.statusLine // empty')
existing_spinner_verbs=$(echo "$current_settings" | jq -r 'if (.spinnerVerbs // empty) != [] and (.spinnerVerbs // null) != null then "set" else "" end')

if [ -n "$existing_status_line" ] && [ "$FORCE" -ne 1 ]; then
  echo "progress-bar install: settings.json already has a statusLine set." >&2
  echo "Re-run with --force to replace it. Nothing was changed." >&2
  exit 1
fi

if [ -n "$existing_spinner_verbs" ] && [ "$FORCE" -ne 1 ]; then
  echo "progress-bar install: settings.json already has spinnerVerbs set." >&2
  echo "Re-run with --force to replace it. Nothing was changed." >&2
  exit 1
fi

# 3. Merge statusLine and spinnerVerbs, preserving every other key.
new_settings=$(echo "$current_settings" | jq \
  --arg cmd "$DEST_STATUSLINE" \
  '.statusLine = {"type": "command", "command": $cmd} |
   .spinnerVerbs = ["Percolating", "Charting", "Tallying", "Gauging", "Rendering"]')

echo "$new_settings" > "$SETTINGS_FILE"

echo "Updated $SETTINGS_FILE:"
echo "  statusLine   -> command: $DEST_STATUSLINE"
echo "  spinnerVerbs -> [\"Percolating\", \"Charting\", \"Tallying\", \"Gauging\", \"Rendering\"]"
echo "Restart Claude Code (or open a new session) to see the change."
