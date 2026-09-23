#!/usr/bin/env bash
# Subagent rows: one {"id","content"} line per task that has a context size.
# Tasks without one are skipped, so Claude Code keeps their default row.
command -v jq >/dev/null || exit 0
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
jq -c -L "$dir" --argjson w "${PROGRESS_BAR_WIDTH:-10}" 'include "bar";
  .tasks[]? | select((.contextWindowSize // 0) > 0)
  | ([.label // .name, .description] | map(select(. != null and . != "")) | join(" · ")) as $text
  | {id, content: (bar((.tokenCount // 0) * 100 / .contextWindowSize; $w)
                   + (if $text == "" then "" else " " + $text end))}'
