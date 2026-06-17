#!/bin/bash
# intero — CLI icon picker
# Renders icon candidates grouped by section so you can see exactly
# how they look in your terminal. Run: bash pick-icons.sh
#
# Family key (sizing tends to follow family):
#   FA  = Font Awesome     (F000-F2FF)  — consistently large
#   OCT = Octicons         (F400-F533)  — consistently large
#   PL  = Powerline        (E0A0-E0D4)  — consistently large
#   PLE = Powerline Extra  (E0C0-E0D4)  — consistently large
#   COD = Codicons         (EA60-EC15)  — mid/small
#   FAE = FA Extension     (E200-E2A9)  — small
#   MD  = Material Design  (F0001-F1AF0)— small
#   WEA = Weather          (E300-E3E3)  — small
#   DEV = Devicons         (E700-E7FF)  — small
#   SETI= Seti-UI          (E5FA-E631)  — small

source "$(dirname "$0")/lib/colors.sh"

# ── Helpers ──────────────────────────────────────────────────────────────────

show() {
  local code="$1" name="$2" current="$3"
  local icon
  icon=$(printf "$code")
  local marker=""
  [[ "$current" == "1" ]] && marker=" $(c_pink; printf "◄ current"; rst)"
  printf "  %s  " "$icon"
  c_subtext0; printf "%-36s" "$name"; rst
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
  clr_dim; printf "  %-40s%s\n" "────────────────────────────────────" "────────"; rst
}

family_label() {
  c_mauve; printf "  ── %s ──\n" "$1"; rst
}

# ── Sections ─────────────────────────────────────────────────────────────────

header "MODEL" "Current: \UF0E7 (bolt)"
family_label "Font Awesome (large)"
show '\UF0E7'  'fa-bolt'                           1
show '\UF06D'  'fa-fire'
show '\UF0E8'  'fa-sitemap'
show '\UF121'  'fa-code'
show '\UF120'  'fa-terminal'
divider
family_label "Weather / MD / Devicons (small)"
show '\UE315'  'weather-lightning'
show '\UF140B' 'md-lightning_bolt'
show '\UF06A1' 'md-brain'
show '\UF0868' 'md-head-cog'

header "AGENT" "Current: none (text only)"
family_label "Font Awesome (large)"
show '\UF544'  'fa-robot'
show '\UF234'  'fa-user-plus'
show '\UF0C0'  'fa-users'
show '\UF21B'  'fa-user-secret'
divider
family_label "Octicons (large)"
show '\UF42E'  'oct-workflow'
divider
family_label "MD / FAE (small)"
show '\UF110A' 'md-assistant'
show '\UF167F' 'md-robot'
show '\UF06A1' 'md-brain'
show '\UF0868' 'md-head-cog'

header "DIRECTORY" "Current: \UF07B (folder)"
family_label "Font Awesome (large)"
show '\UF07B'  'fa-folder'                         1
show '\UF07C'  'fa-folder-open'
show '\UF114'  'fa-folder-o'
show '\UF115'  'fa-folder-open-o'
divider
family_label "Octicons / MD (variable)"
show '\UF413'  'oct-file-directory'
show '\UF0770' 'md-folder-home'

header "GIT BRANCH" "Current: \UE0A0 (powerline branch)"
family_label "Powerline (large)"
show '\UE0A0'  'pl-branch'                         1
divider
family_label "Font Awesome / Octicons (large)"
show '\UF126'  'fa-code-fork'
show '\UF1D3'  'fa-git'
show '\UF418'  'oct-git-branch'
show '\UF417'  'oct-git-commit'
show '\UF424'  'oct-repo-forked'

header "PR" "Current: \UF407 (oct-git-pull-request)"
family_label "Octicons (large)"
show '\UF407'  'oct-git-pull-request'               1
show '\UF4DC'  'oct-git-pull-request-closed'
show '\UF4DD'  'oct-git-pull-request-draft'
show '\UF440'  'oct-diff'
show '\UF419'  'oct-git-merge'
show '\UF4DB'  'oct-git-merge-queue'

header "CONTEXT" "Current: \UF2DB (microchip)"
family_label "Font Awesome (large)"
show '\UF2DB'  'fa-microchip'                       1
show '\UF1CD'  'fa-area-chart'
show '\UF080'  'fa-bar-chart'
divider
family_label "MD (small)"
show '\UF035B' 'md-chart-donut'
show '\UF028E' 'md-buffer'
show '\UF0A32' 'md-circle-slice-8'

header "BURN RATE / TOKENS/S" "Current: \UF490 (oct-flame)"
family_label "Font Awesome (large)"
show '\UF06D'  'fa-fire'
show '\UF0E4'  'fa-tachometer'
divider
family_label "Octicons (large)"
show '\UF490'  'oct-flame'                          1
show '\UF469'  'oct-pulse'
divider
family_label "Powerline Extra (large)"
show '\UE0C0'  'ple-flame_thick'
show '\UE0C1'  'ple-flame_thin'
divider
family_label "FA new / COD / MD (variable)"
show '\UED78'  'fa-fire_flame_simple'
show '\UEF76'  'fa-fire_flame_curved'
show '\UEAF2'  'cod-flame'
show '\UF0238' 'md-fire'
show '\UF050B' 'md-fire (alt range)'

header "CLOCK / DURATION" "Current: \UF017 (clock)"
family_label "Font Awesome (large)"
show '\UF017'  'fa-clock'                           1
show '\UF252'  'fa-hourglass-half'
show '\UF253'  'fa-hourglass-end'
divider
family_label "MD (small)"
show '\UF0954' 'md-timer-sand'
show '\UF13AB' 'md-clock-outline'
show '\UF0150' 'md-clock-fast'

header "CACHE / TOKENS" "Current: \UF24D (clone/layers)"
family_label "Font Awesome (large)"
show '\UF24D'  'fa-clone'                           1
show '\UF1C0'  'fa-database'
show '\UF1B2'  'fa-cube'
show '\UF1B3'  'fa-cubes'
divider
family_label "FA new / FAE / MD (variable)"
show '\UEDE8'  'fa-coins'
show '\UE26B'  'fae-coins'
show '\UF0A4E' 'md-coin'
show '\UF01DA' 'md-cached'

header "RATE LIMIT" "Current: \UF0E4 (tachometer)"
family_label "Font Awesome (large)"
show '\UF0E4'  'fa-tachometer'                      1
show '\UF201'  'fa-line-chart'
show '\UF080'  'fa-bar-chart'
divider
family_label "FA new (variable)"
show '\UED2F'  'fa-gauge_high'
show '\UEEB2'  'fa-gauge'
divider
family_label "MD (small)"
show '\UF029A' 'md-gauge'
show '\UF04C5' 'md-speedometer'
show '\UF0F86' 'md-speedometer_slow'

header "MCP" "Current: \UF233 (server)"
family_label "Font Awesome (large)"
show '\UF233'  'fa-server'                          1
show '\UF1E6'  'fa-plug'
show '\UF0AC'  'fa-globe'
divider
family_label "Octicons (large)"
show '\UF42E'  'oct-workflow'
divider
family_label "MD (small)"
show '\UF0318' 'md-connection'
show '\UF0493' 'md-hub'
show '\UF048C' 'md-server_minus'
show '\UF048D' 'md-server_network'
show '\UF048F' 'md-server_off'

header "PEAK HOURS" "Current: ☀ (unicode sun)"
family_label "Unicode / Font Awesome (large)"
show '☀'       'unicode-sun'                        1
show '\UF185'  'fa-sun-o'
show '\UF186'  'fa-moon-o'
divider
family_label "Weather (small)"
show '\UE34D'  'weather-sunset'
show '\UE3C1'  'weather-moonrise'
divider
family_label "MD (small)"
show '\UF0599' 'md-weather-sunny'
show '\UF05A8' 'md-white-balance-sunny'

header "STATUS (CC + API)" "Current: \UE291 + \UF109B — BOTH RENDER TINY"
family_label "Font Awesome (large) — CC candidates"
show '\UF120'  'fa-terminal'
show '\UF121'  'fa-code'
show '\UF058'  'fa-check-circle'
show '\UF0E7'  'fa-bolt'
show '\UF1E6'  'fa-plug'
show '\UF0C1'  'fa-link'
show '\UF06D'  'fa-fire'
show '\UF140'  'fa-bullseye'
divider
family_label "Font Awesome (large) — API ON candidates"
show '\UF0AC'  'fa-globe'
show '\UF0C1'  'fa-link'
show '\UF0EC'  'fa-exchange'
show '\UF1EB'  'fa-wifi'
show '\UF1E6'  'fa-plug'
show '\UF012'  'fa-signal'
divider
family_label "Font Awesome (large) — API OFF candidates"
show '\UF127'  'fa-unlink'
show '\UF05E'  'fa-ban'
show '\UF057'  'fa-times-circle'
show '\UF071'  'fa-exclamation-triangle'
divider
family_label "Octicons (large)"
show '\UF469'  'oct-pulse'
show '\UF484'  'oct-globe'
show '\UF43C'  'oct-broadcast'
divider
family_label "Current (small — for comparison)"
show '\UE291'  'fae-cc_cc'                          1
show '\UF109B' 'md-api'                             1
show '\UF1257' 'md-api_off'                         1

header "STASH" "Current: \UF187 (archive)"
family_label "Font Awesome (large)"
show '\UF187'  'fa-archive'                         1
show '\UF1B2'  'fa-cube'
show '\UF0A0'  'fa-hdd'
show '\UF02E0' 'fa-bookmark'

header "WORKTREE" "Current: \UF1BB (tree)"
family_label "Font Awesome (large)"
show '\UF1BB'  'fa-tree'                            1
show '\UF0E8'  'fa-sitemap'
show '\UF126'  'fa-code-fork'
divider
family_label "MD (small)"
show '\UF0E22' 'md-source-branch-plus'

echo ""
c_mauve; bld; printf "━━ PROMPT ICON CANDIDATES "; rst
clr_dim; printf "(for rotating pool)"; rst
echo ""
echo ""

family_label "Font Awesome (large)"
for code in \
  '\UF0E7' '\UF06D' '\UF120' '\UF121' '\UF188' \
  '\UF1BB' '\UF233' '\UF2DB' '\UF0AC' '\UF0E4' \
  '\UF1E6' '\UF017' '\UF24D' '\UF07B' '\UF126' \
  '\UF252' '\UF418' '\UF1C0' '\UF187' '\UF0E8' \
  '\UF11C' '\UF407' '\UF234' '\UF21B' '\UF0C0' \
  '\UF544' '\UF094' '\UF140' '\UF0D0'
do
  icon=$(printf "$code")
  printf "  %s " "$icon"
done
echo ""
echo ""

family_label "User picks (mixed families — check sizes)"
for code in \
  '\UE315' '\UE00A' '\UE23E' '\UF43B' '\UF094' \
  '\UF0F01' '\UF06D' '\UF0BAD' '\UE26A' '\UEF5C' \
  '\UF068C' '\UF0BC8' '\UF14C7' '\UE70D' '\UF08C9' \
  '\UEDD6' '\UF1303' '\UEBCA' '\UF1A11' '\UF0DF7' \
  '\UE234' '\UE26B' '\UE26D' '\UEF15' '\UF0D0' \
  '\UEC10' '\UF51B'
do
  icon=$(printf "$code")
  printf "  %s " "$icon"
done
echo ""
echo ""

family_label "With names"
show '\UE315'  'weather-lightning'
show '\UE00A'  'pom-external_interruption'
show '\UE23E'  'fae-ruby'
show '\UF43B'  'oct-ruby'
show '\UF094'  'fa-lemon_o'
show '\UF0F01' 'md-jellyfish'
show '\UF0BAD' 'md-one_up'
show '\UE26A'  'fae-coffe_beans'
show '\UEF5C'  'fa-raspberry_pi'
show '\UF068C' 'md-skull'
show '\UF0BC8' 'md-skull_outline'
show '\UF14C7' 'md-skull_scan'
show '\UE70D'  'dev-jekyll_small'
show '\UF08C9' 'md-bullseye_arrow'
show '\UEDD6'  'fa-galactic_republic'
show '\UF1303' 'md-fleur_de_lis'
show '\UEBCA'  'cod-terminal_bash'
show '\UF1A11' 'md-wall_fire'
show '\UF0DF7' 'md-screw_round_top'
show '\UE234'  'fae-pulse'
show '\UE26B'  'fae-coins'
show '\UE26D'  'fae-comet'
show '\UEF15'  'fa-wand_sparkles'
show '\UF0D0'  'fa-wand_magic'
show '\UEC10'  'cod-sparkle'
show '\UF51B'  'oct-sparkle_fill'
show '\UEE15'  'fa-skull'
show '\UED78'  'fa-fire_flame_simple'

echo ""
clr_dim; printf "  Run in iTerm to see true rendering. Browser fonts differ."; rst
echo ""
