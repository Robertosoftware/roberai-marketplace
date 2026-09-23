#!/usr/bin/env bash
# Reverses install.sh: removes statusLine/spinnerVerbs from settings.json
# and deletes the copied status line script.
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "progress-bar uninstall: jq is required but was not found on PATH" >&2
  exit 1
fi

CLAUDE_DIR="${HOME}/.claude"
DEST_STATUSLINE="${CLAUDE_DIR}/progress-bar-statusline.sh"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
BACKUP_FILE="${CLAUDE_DIR}/settings.json.uninstall.bak"

if [ -f "$SETTINGS_FILE" ]; then
  cp "$SETTINGS_FILE" "$BACKUP_FILE"
  echo "Backed up $SETTINGS_FILE -> $BACKUP_FILE"

  current_settings="$(cat "$SETTINGS_FILE")"
  is_ours=$(echo "$current_settings" | jq -r --arg cmd "$DEST_STATUSLINE" \
    'if (.statusLine.command // "") == $cmd then "yes" else "no" end')

  if [ "$is_ours" = "yes" ]; then
    new_settings=$(echo "$current_settings" | jq 'del(.statusLine) | del(.spinnerVerbs)')
    echo "$new_settings" > "$SETTINGS_FILE"
    echo "Removed statusLine and spinnerVerbs from $SETTINGS_FILE"
  else
    echo "progress-bar uninstall: statusLine in settings.json was not installed by this plugin; leaving settings.json untouched."
  fi
else
  echo "No settings.json found; nothing to update."
fi

if [ -f "$DEST_STATUSLINE" ]; then
  rm -f "$DEST_STATUSLINE"
  echo "Removed $DEST_STATUSLINE"
fi
