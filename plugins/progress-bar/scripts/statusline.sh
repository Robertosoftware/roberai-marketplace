#!/usr/bin/env bash
# Reads Claude Code's statusLine JSON payload on stdin and prints a single
# line: a 10-cell context-window bar, percentage, and the model name.
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "progress-bar: jq is required but was not found on PATH"
  exit 0
fi

input="$(cat)"

percent_raw=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# used_percentage can be a float (e.g. 45.2) or null; normalize to an int.
percent=$(printf '%.0f' "$percent_raw" 2>/dev/null || echo 0)
if [ "$percent" -lt 0 ]; then percent=0; fi
if [ "$percent" -gt 100 ]; then percent=100; fi

green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[31m'
reset=$'\033[0m'

width=10
filled=$(( (percent * width + 50) / 100 ))
if [ "$filled" -gt "$width" ]; then filled=$width; fi
if [ "$filled" -lt 0 ]; then filled=0; fi
empty=$(( width - filled ))

color="$green"
if [ "$percent" -ge 90 ]; then
  color="$red"
elif [ "$percent" -ge 70 ]; then
  color="$yellow"
fi

bar=""
for ((i = 0; i < filled; i++)); do bar+="▓"; done
for ((i = 0; i < empty; i++)); do bar+="░"; done

printf '%s %s%s%s %d%%\n' "$model" "$color" "$bar" "$reset" "$percent"
