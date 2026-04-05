# intero-CLI

A rich, multi-line status bar for Claude Code that surfaces context, git state, rate limits, and more — right in your terminal.

**intero-CLI** — from *interoception* + *CLI* — your session's vital signs at a glance. Part of the brain ecosystem: [cerebellum](https://github.com/jj-valentine/cerebellum) (memory), [cerebro](https://github.com/jj-valentine/cerebro) (orchestration), intero (surfacing internal state).

## What it shows

```
Line 1: Model + thinking | Branch + dirty/staged | Sync status | Duration | Peak hours
Line 2: Context bar + tokens | Lines +/- | Burn rate | Cache hit ratio
Line 3: 5h rate limit bar | 7d rate limit bar | MCP health | PR status + test checks
```

## Features

- **Context window** — bar + percentage + token counts with threshold colors (green → yellow → red)
- **Git status** — branch, dirty/staged/untracked counts, ahead/behind, stash, ongoing operations (merge/rebase/cherry-pick)
- **Sync awareness** — synced, behind, ahead, diverged, stale fetch detection (uses `FETCH_HEAD` mtime)
- **Rate limits** — 5-hour and 7-day usage bars with reset times, weighted by model (Opus = 5x)
- **Burn rate** — tokens/minute consumption indicator
- **Cache ratio** — percentage of tokens served from prompt cache
- **PR status** — current branch PR number, state, and test plan checkbox progress via `gh`
- **MCP health** — server count from `claude mcp list`
- **Peak hours** — weekday 5am-11am PT warning with countdown
- **Tab title** — auto-sets terminal tab to `dir + branch + summary`
- **Catppuccin Mocha** color palette with pastel accents

## Requirements

- Bash 4+
- `jq`
- `gh` (GitHub CLI) — for PR status
- A [Nerd Font](https://www.nerdfonts.com/) — for icons
- Claude Code with status line support

## Install

```sh
git clone https://github.com/jj-valentine/intero-CLI.git
cd intero-CLI
bash install.sh
```

This symlinks `intero.sh` into `~/.claude/` and configures `settings.json`. Restart Claude Code to activate.

## Preview

```sh
bash mock.sh
```

Renders the full 3-line layout with fake data. Tweak the variables at the top of `mock.sh` to preview different states.

## Configure

Copy `config.example.sh` to `config.sh` and customize:

```sh
cp config.example.sh config.sh
```

Options include bar style (`parallelogram`, `blocks`, `dots`, `geometric`, `squares`), context/burn/fetch thresholds, and feature toggles.

## File structure

| File | Purpose |
|------|---------|
| `intero.sh` | Main entry — reads JSON from stdin, renders 3 lines |
| `mock.sh` | Design preview with fake data |
| `install.sh` | Symlinks + settings.json setup |
| `config.example.sh` | Overridable thresholds and toggles |
| `lib/colors.sh` | Catppuccin Mocha palette + semantic aliases |
| `lib/icons.sh` | Nerd Font icon definitions |
| `lib/bars.sh` | Multi-style bar renderer with threshold colors |
| `lib/format.sh` | Token, duration, time, burn rate formatting |
| `lib/git.sh` | Git data with 5s TTL caching |
| `lib/pr.sh` | PR status via `gh` with 30s TTL cache |
| `lib/peak.sh` | Anthropic peak hours detection |
| `health/mcp-check.sh` | MCP server health probe |

## License

MIT
