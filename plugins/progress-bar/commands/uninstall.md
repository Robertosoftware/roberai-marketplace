---
description: Remove the progress-bar main status line and spinner verbs
---

Run `${CLAUDE_PLUGIN_ROOT}/scripts/uninstall.sh` and report its output to the user verbatim.

The script removes `statusLine` and `spinnerVerbs` from `~/.claude/settings.json` (only if they still point at this plugin's installed script) and deletes `~/.claude/progress-bar-statusline.sh`. It leaves a backup at `~/.claude/settings.json.uninstall.bak`.
