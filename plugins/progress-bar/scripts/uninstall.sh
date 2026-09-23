#!/usr/bin/env bash
# Removes our statusLine entry and the ~/.claude/progress-bar link.
set -eu
command -v jq >/dev/null || { echo "jq is required" >&2; exit 1; }
settings="$HOME/.claude/settings.json"

if [ -f "$settings" ] && jq -e '.statusLine.command // "" | test("progress-bar")' "$settings" >/dev/null; then
  tmp="$(mktemp)"
  jq 'del(.statusLine)' "$settings" > "$tmp" && cat "$tmp" > "$settings"; rm -f "$tmp"
  echo "Removed statusLine from $settings"
else
  echo "statusLine isn't ours; left $settings untouched"
fi
[ -L "$HOME/.claude/progress-bar" ] && rm "$HOME/.claude/progress-bar" && echo "Removed ~/.claude/progress-bar"
echo "Now run: /plugin uninstall progress-bar@roberto-tools"
