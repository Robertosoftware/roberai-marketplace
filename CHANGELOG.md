# Changelog

## 0.2.0


- Zero-step install: a `SessionStart` hook configures the main status line, so `/progress-bar:install` is gone.
- Status line follows plugin updates via a `~/.claude/progress-bar` symlink instead of a stale copied script.
- Both bars render from one shared `bar.jq`; each script is a single `jq` call (no per-task subprocesses).
- `PROGRESS_BAR_WIDTH` env var for bar width.
- Spinner verbs removed (unrelated to progress bars).

## v0.1.2 - 2026-09-23

- Fix `/progress-bar:install` writing `spinnerVerbs` as a plain array, which
  Claude Code rejects ("Expected object"). It now writes
  `{"mode": "replace", "verbs": [...]}`

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
