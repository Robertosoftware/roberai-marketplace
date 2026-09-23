#!/usr/bin/env bash
# SessionStart hook. Idempotent and silent:
#  1. Points ~/.claude/progress-bar at this plugin version's scripts/ dir,
#     so plugin updates reach the status line without a reinstall.
#  2. Adds statusLine to ~/.claude/settings.json, but only if you have none
#     (or it's already ours). Your own status line is never touched.
set -u
command -v jq >/dev/null || exit 0

scripts="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="$HOME/.claude"
link="$claude_dir/progress-bar"
settings="$claude_dir/settings.json"
# Guarded so a removed plugin leaves a blank line instead of an error.
cmd='f="$HOME/.claude/progress-bar/statusline.sh"; [ -x "$f" ] && exec "$f"; true'

mkdir -p "$claude_dir"
if [ -L "$link" ] || [ ! -e "$link" ]; then
  [ "$(readlink "$link" 2>/dev/null)" = "$scripts" ] || ln -sfn "$scripts" "$link"
fi

[ -f "$settings" ] || echo '{}' > "$settings"
current="$(jq -r '.statusLine.command // ""' "$settings" 2>/dev/null)" || exit 0
case "$current" in
  "$cmd") exit 0 ;;                      # already set up
  ""|*progress-bar*) ;;                  # empty, or ours (incl. old installs)
  *) exit 0 ;;                           # someone else's status line: leave it
esac

tmp="$(mktemp)"
jq --arg cmd "$cmd" '.statusLine = {type: "command", command: $cmd}' "$settings" > "$tmp" \
  && cat "$tmp" > "$settings"; rm -f "$tmp"
rm -f "$claude_dir/progress-bar-statusline.sh"   # leftover from v0.1 installer
