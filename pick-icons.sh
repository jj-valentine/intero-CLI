#!/bin/bash
# intero — CLI icon picker
# Renders icon candidates grouped by section so you can see exactly
# how they look in your terminal. Run: bash pick-icons.sh

source "$(dirname "$0")/lib/colors.sh"

# ── Helpers ──────────────────────────────────────────────────────────────────

show() {
  local code="$1" name="$2" current="$3"
  local icon
  icon=$(printf "$code")
  local marker=""
  [[ "$current" == "1" ]] && marker=" $(c_pink; printf "◄ current"; rst)"
  printf "  %s  " "$icon"
  c_subtext0; printf "%-30s" "$name"; rst
  clr_dim; printf "%s" "$code"; rst
  printf "%s\n" "$marker"
}

header() {
  echo ""
  c_pink; bld; printf "━━ %s " "$1"; rst
  clr_dim; printf "%s" "$2"; rst
  echo ""
  echo ""
}

divider() {
  clr_dim; printf "  %-34s%s\n" "────────────────────────────" "────────"; rst
}

# ── Sections ─────────────────────────────────────────────────────────────────

header "MODEL" "Current:  (bolt)"
show ''  'fa-bolt'             1
show ''  'fa-sitemap'
show ''  'fa-server'
show ''  'fa-microchip'
show ''  'fa-code'
show ''  'fa-robot'
show ''  'fa-keyboard'
show ''  'fa-terminal'
show ''  'fa-bug'
show '\UF0868' 'md-head-cog'
show '\UF06A1' 'md-brain'
show '\UF167F' 'md-robot'
show '\UF110A' 'md-assistant'

header "AGENT" "Current: none (text only)"
show '\UF110A' 'md-assistant'
show '\UF167F' 'md-robot'
show '\UF06A1' 'md-brain'
show '\UF0645' 'md-blur'
show '\UF0868' 'md-head-cog'
show ''  'fa-sitemap'
show ''  'fa-user-plus'
show ''  'fa-users'
show ''  'fa-user-secret'
show ''  'oct-workflow'
show '\UF0A71' 'md-cog-play'
show ''  'fae-cc_cc'

header "DIRECTORY" "Current:  (folder)"
show ''  'fa-folder'           1
show ''  'fa-folder-open'
show ''  'fa-folder-o'
show ''  'fa-folder-open-o'
show ''  'oct-file-directory'
show ''  'fa-folder-minus'
show '\UF0770' 'md-folder-home'
show '\UF024B' 'md-folder-cog'

header "GIT BRANCH" "Current:  (powerline branch)"
show ''  'pl-branch'           1
show ''  'oct-git-branch'
show ''  'fa-code-fork'
show ''  'oct-git-commit'
show ''  'oct-repo-forked'

header "PR" "Current:  (oct-git-pull-request)"
show ''  'oct-git-pull-request' 1
show ''  'oct-git-pull-request-closed'
show ''  'oct-diff'
show ''  'oct-git-merge'
show '\UF0041' 'md-ab-testing'

header "CONTEXT" "Current:  (microchip)"
show ''  'fa-microchip'        1
show '\UF035B' 'md-chart-donut'
show ''  'fa-area-chart'
show ''  'fa-bar-chart'
show '\UF028E' 'md-buffer'
show '\UF0A32' 'md-circle-slice-8'

header "BURN RATE" "Current:  (oct-flame)"
show ''  'oct-flame'           1
show ''  'fa-fire'
show '\UF0238' 'md-arrow-up-bold'
show ''  'fa-tachometer'
show '\UF050B' 'md-fire'

header "CLOCK / DURATION" "Current:  (clock)"
show ''  'fa-clock'            1
show ''  'fa-hourglass-half'
show ''  'fa-hourglass-end'
show '\UF0954' 'md-timer-sand'
show '\UF13AB' 'md-clock-outline'
show '\UF0150' 'md-clock-fast'

header "CACHE" "Current:  (clone/layers)"
show ''  'fa-clone'            1
show ''  'fa-database'
show '\UF01DA' 'md-cached'
show ''  'fa-cube'
show ''  'fa-cubes'
show '\UF0A4E' 'md-coin'

header "RATE LIMIT" "Current:  (tachometer)"
show ''  'fa-tachometer'       1
show '\UF0425' 'md-gauge'
show '\UF049B' 'md-speedometer'
show ''  'fa-line-chart'
show ''  'fa-bar-chart'

header "MCP" "Current:  (server)"
show ''  'fa-server'           1
show ''  'fa-plug'
show ''  'fa-globe'
show '\UF0318' 'md-connection'
show '\UF0493' 'md-hub'
show ''  'oct-workflow'

header "PEAK HOURS" "Current: ☀ (unicode sun)"
show '☀'       'unicode-sun'         1
show '\UF0599' 'md-weather-sunny'
show ''  'fa-sun-o'
show '\UF05A8' 'md-white-balance-sunny'
show ''  'fa-moon-o'

header "STATUS" "Current:  + \UF109B (cc + api)"
show ''  'fae-cc_cc'           1
show '\UF109B' 'md-api'              1
show '\UF1257' 'md-api_off'          1
show '\UF0F51' 'md-heart-pulse'
show '\UF02DC' 'md-check-network'
show '\UF159E' 'md-broadcast'

header "STASH" "Current:  (archive)"
show ''  'fa-archive'          1
show ''  'fa-cube'
show ''  'fa-hdd'
show '\UF01A7' 'md-bookmark'
show ''  'fa-bookmark'

header "WORKTREE" "Current:  (tree)"
show ''  'fa-tree'             1
show ''  'fa-sitemap'
show ''  'fa-code-fork'
show '\UF0E22' 'md-source-branch-plus'

echo ""
c_mauve; bld; printf "━━ PROMPT ICON CANDIDATES "; rst
clr_dim; printf "(for Ozark-style rotating pool)"; rst
echo ""
echo ""

for code in \
  '' '' '\UF050B' \
  '' '' '' \
  '' '' '' \
  '' '' '' \
  '' '' '' \
  '' '' '' \
  '' '' '' \
  '' '' '' \
  '' '' '' \
  '\UF06A1' '\UF167F' '\UF110A' \
  '\UF0868' '\UF0599' '\UF05A8' \
  '\UF0A4E' '\UF050B' '\UF0F51' \
  '\UF01DA' '' ''
do
  icon=$(printf "$code")
  printf "  %s  " "$icon"
done
echo ""
echo ""
clr_dim; printf "  Run in iTerm to see true rendering. Browser fonts differ."; rst
echo ""
