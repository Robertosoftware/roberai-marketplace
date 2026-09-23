#!/usr/bin/env bash
# Main status line: "<model> ▓▓▓▓▓░░░░░ 50%"
command -v jq >/dev/null || { echo "progress-bar: jq not found"; exit 0; }
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
jq -r -L "$dir" --argjson w "${PROGRESS_BAR_WIDTH:-10}" 'include "bar";
  "\(.model.display_name // "Claude") \(bar(.context_window.used_percentage; $w))"'
