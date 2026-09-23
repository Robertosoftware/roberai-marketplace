---
description: Install the progress-bar main status line and spinner verbs
---

Run `${CLAUDE_PLUGIN_ROOT}/scripts/install.sh` and report its output to the user verbatim.

If the user passes `--force` as an argument to this command, forward it to the script: `${CLAUDE_PLUGIN_ROOT}/scripts/install.sh --force`.

The script copies the status line renderer to `~/.claude/progress-bar-statusline.sh`, backs up `~/.claude/settings.json` to `settings.json.bak`, and merges in `statusLine` and `spinnerVerbs` without touching any other settings. It refuses to overwrite an existing `statusLine` or `spinnerVerbs` unless `--force` is given.
