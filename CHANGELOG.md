# Changelog

## v0.1.1 - 2026-09-23

- Fix subagent bars dropping the agent name and description: rows now show
  `bar % name · description`, built from the task's `label`/`name` and
  `description` fields (tasks have no `content` field)
- Add a marketplace description

## v0.1.0 - 2026-09-23

Initial release.

- Subagent status line: per-task token-usage bars via `subagentStatusLine`
- Main status line: context-window bar with model name and percent, applied
  via `/progress-bar:install`
- Optional spinner verbs, applied via the same install command
- `/progress-bar:uninstall` to reverse the install command's changes

**Note:** the main status line script is copied to `~/.claude/` at install
time. If you upgrade this plugin, re-run `/progress-bar:install --force` to
pick up script changes.
