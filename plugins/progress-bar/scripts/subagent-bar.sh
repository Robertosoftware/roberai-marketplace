#!/usr/bin/env bash
# Reads a JSON object with a "tasks" array on stdin (one row per subagent).
# Emits one JSON line per task: {"id":..., "content":...}
# Tasks missing contextWindowSize are passed through untouched so the
# caller keeps whatever default row it already had for them.
set -euo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo '{"error":"progress-bar plugin requires jq, which was not found on PATH"}' >&2
  exit 1
fi

input="$(cat)"

green=$'\033[32m'
yellow=$'\033[33m'
red=$'\033[31m'
reset=$'\033[0m'

make_bar() {
  local percent="$1"
  local width=10
  local filled
  filled=$(( (percent * width + 50) / 100 ))
  if [ "$filled" -gt "$width" ]; then filled=$width; fi
  if [ "$filled" -lt 0 ]; then filled=0; fi
  local empty=$(( width - filled ))
  local color="$green"
  if [ "$percent" -ge 90 ]; then
    color="$red"
  elif [ "$percent" -ge 70 ]; then
    color="$yellow"
  fi
  local bar=""
  local i
  for ((i = 0; i < filled; i++)); do bar+="▓"; done
  for ((i = 0; i < empty; i++)); do bar+="░"; done
  printf '%s%s%s %d%%' "$color" "$bar" "$reset" "$percent"
}

echo "$input" | jq -c '.tasks // []' | jq -c '.[]' | while IFS= read -r task; do
  has_ctx=$(echo "$task" | jq -r 'if (.contextWindowSize // null) == null or .contextWindowSize == 0 then "no" else "yes" end')
  id=$(echo "$task" | jq -r '.id')

  if [ "$has_ctx" = "no" ]; then
    # No contextWindowSize: skip so the caller's default row is kept.
    continue
  fi

  token_count=$(echo "$task" | jq -r '.tokenCount // 0')
  ctx_size=$(echo "$task" | jq -r '.contextWindowSize')
  content=$(echo "$task" | jq -r '.content // ""')

  percent=$(( token_count * 100 / ctx_size ))
  if [ "$percent" -gt 100 ]; then percent=100; fi
  if [ "$percent" -lt 0 ]; then percent=0; fi

  bar="$(make_bar "$percent")"

  if [ -n "$content" ]; then
    new_content="${bar} ${content}"
  else
    new_content="${bar}"
  fi

  jq -cn --arg id "$id" --arg content "$new_content" '{id: $id, content: $content}'
done
