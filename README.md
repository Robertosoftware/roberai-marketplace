# roberai-marketplace

A Claude Code plugin marketplace. Ships one plugin today: **progress-bar**,
token-usage progress bars for the main status line and every subagent row.

## Install

One line in your terminal:

```bash
claude plugin marketplace add Robertosoftware/roberai-marketplace ; claude plugin install progress-bar@roberto-tools --scope user
```

Or, from inside a Claude Code session:

```
/plugin marketplace add Robertosoftware/roberai-marketplace
/plugin install progress-bar@roberto-tools
```

That's it, no extra setup command. Start a new session (or send one message)
and the bars appear.

```
Claude Sonnet 5 ▓▓▓▓▓░░░░░ 50%
```

Requires [jq](https://jqlang.org/) on your `PATH`.

## How it works

| Part | Mechanism |
| --- | --- |
| Subagent bars | The plugin's `settings.json` sets `subagentStatusLine` (plugins are allowed to) |
| Main status line | Plugins can't set `statusLine`, so a `SessionStart` hook does it for you |

On every session start, `scripts/setup.sh` quietly:

1. Points `~/.claude/progress-bar` (a symlink) at the current plugin version's
   `scripts/` folder, so plugin updates apply automatically.
2. Adds `statusLine` to `~/.claude/settings.json` **only if you don't already
   have one** (or the existing one is ours). A custom status line of your own
   is never touched.

If you remove the plugin, the symlink dangles and the status line simply
renders nothing.

## Customizing

Set `PROGRESS_BAR_WIDTH` (default `10`) in the `env` block of your settings.
Colors and the 70% / 90% thresholds live in `plugins/progress-bar/scripts/bar.jq`,
which both bars share.

## Uninstall

```
/progress-bar:uninstall
/plugin uninstall progress-bar@roberto-tools
```

## Development

```
cat tests/fixtures/main-50.json   | plugins/progress-bar/scripts/statusline.sh
cat tests/fixtures/subagents.json | plugins/progress-bar/scripts/subagent-bar.sh
HOME=$(mktemp -d) plugins/progress-bar/scripts/setup.sh   # try setup in a throwaway HOME

/plugin marketplace add ./roberai-marketplace
/plugin install progress-bar@roberto-tools
```

## License

MIT — see [LICENSE](LICENSE).
