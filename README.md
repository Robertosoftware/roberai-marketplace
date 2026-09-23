# roberai-marketplace

A Claude Code plugin marketplace. Ships one plugin today: **progress-bar**, which
replaces Claude Code's subagent bars and main status line with token-usage
progress bars.

```
/plugin marketplace add Robertosoftware/roberai-marketplace
/plugin install progress-bar@roberto-tools
/progress-bar:install        # optional: main status line + spinner verbs
```

## What it does

| Part | What it changes | How it gets applied |
| --- | --- | --- |
| Subagent bars | Each subagent row in the agent panel shows a token-usage bar | Automatically, via the plugin's `settings.json` (`subagentStatusLine`) |
| Main status line | A context-window bar with model name and percent | `/progress-bar:install` copies a script to `~/.claude/` and adds `statusLine` to your settings |
| Spinner text (optional) | Custom verbs while Claude works | Same install command adds `spinnerVerbs` |

Plugins can only set the `agent` and `subagentStatusLine` keys themselves, so
the main status line and spinner verbs need the install command. Everything
here targets Claude Code in the terminal, not the Cowork desktop app.

## Requirements

- [jq](https://jqlang.org/) on your `PATH`
- A version of Claude Code that supports `subagentStatusLine` in plugin settings

## Install

```
/plugin marketplace add Robertosoftware/roberai-marketplace
/plugin install progress-bar@roberto-tools
```

Subagent bars render automatically once the plugin is installed. To also get
the main status line and spinner verbs:

```
/progress-bar:install
```

This copies `statusline.sh` to `~/.claude/progress-bar-statusline.sh` and
merges `statusLine`/`spinnerVerbs` into `~/.claude/settings.json`, backing up
the previous file to `settings.json.bak`. It will **not** overwrite an
existing `statusLine` or `spinnerVerbs` unless you pass `--force`:

```
/progress-bar:install --force
```

## Customizing colors and width

Edit `~/.claude/progress-bar-statusline.sh` directly (or
`plugins/progress-bar/scripts/statusline.sh` before running install):

- `width=10` — number of bar cells
- The `green`/`yellow`/`red` variables and the `90`/`70` thresholds near the
  top of the script control coloring
- Subagent bar colors and width live in `plugins/progress-bar/scripts/subagent-bar.sh`

Re-run `/progress-bar:install --force` after editing the plugin's copy of
`statusline.sh` to pick up your changes, since the copied script in
`~/.claude/` does not auto-update.

## Uninstall

```
/progress-bar:uninstall
/plugin uninstall progress-bar@roberto-tools
```

## Known limits

- **Copied script goes stale.** The main status line script lives in
  `~/.claude/`, so plugin updates don't reach it automatically. Re-run
  `/progress-bar:install` after upgrading the plugin.
- **Existing status lines.** If you already have a `statusLine` configured,
  the installer refuses to touch it unless you pass `--force`.
- **Managed settings.** Organizations using `disableAllHooks` or
  `allowManagedHooksOnly` may block status line commands entirely.
- **Null fields.** `used_percentage` can be `null` early in a session; the
  scripts default that to 0%.

## Development

```
# Test the scripts against fixtures
cat tests/fixtures/main-50.json | plugins/progress-bar/scripts/statusline.sh
cat tests/fixtures/subagents.json | plugins/progress-bar/scripts/subagent-bar.sh

# Test install.sh against a throwaway HOME
HOME=$(mktemp -d) CLAUDE_PLUGIN_ROOT=$(pwd)/plugins/progress-bar/scripts \
  ./plugins/progress-bar/scripts/install.sh

# Try the marketplace locally in Claude Code
/plugin marketplace add ./roberai-marketplace
/plugin install progress-bar@roberto-tools
```

## License

MIT — see [LICENSE](LICENSE).
