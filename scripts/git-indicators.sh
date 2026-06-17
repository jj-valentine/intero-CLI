#!/bin/bash
# Independent indicator icon picker — the icon-as-state-carrier approach
source "$(dirname "$0")/../lib/colors.sh"

show() {
  local code="$1" name="$2" note="$3"
  local icon
  icon=$(printf "$code")
  printf "  %s  " "$icon"
  c_subtext0; printf "%-30s" "$name"; rst
  [[ -n "$note" ]] && { c_pink; printf " %s" "$note"; rst; }
  echo ""
}

header() {
  echo ""
  c_pink; bld; printf "━━ %s " "$1"; rst
  echo ""
  echo ""
}

family() { c_mauve; printf "  ── %s ──\n" "$1"; rst; }
state_label() { c_green; bld; printf "    %s\n" "$1"; rst; }

# ══════════════════════════════════════════════════════════════════════════════
header "REMOTE INDICATOR — 1 char, icon swap + color"
echo "  Concept: one icon slot that changes to show remote tracking state"
echo ""

state_label "TRACKING OK (green)"
family "on/off pairs"
show '\UF1126' 'md-remote_tv'              '← your suggestion'
show '\UF0C1'  'fa-link'
show '\UF06E'  'fa-eye'
show '\UF15A0' 'md-cloud_check'
show '\UF46D'  'oct-shield_check'
show '\UF0C4E' 'md-shield_check'
show '\UF1EB'  'fa-wifi'
show '\UF012'  'fa-signal'
show '\UF058'  'fa-check_circle'

state_label "NO UPSTREAM / GONE (red)"
show '\UF1127' 'md-remote_tv_off'          '← your suggestion'
show '\UF127'  'fa-unlink'
show '\UF070'  'fa-eye_slash'
show '\UF0553' 'md-cloud_off_outline'
show '\UF15A5' 'md-shield_off'
show '\UF05E'  'fa-ban'
show '\UF1EB'  'fa-wifi (dim/red)'
show '\UF057'  'fa-times_circle'

state_label "MERGED (mauve)"
show '\UF419'  'oct-git_merge'
show '\UF0628' 'md-source_merge'
show '\UF058'  'fa-check_circle'
show '\UF43E'  'oct-verified'

# ══════════════════════════════════════════════════════════════════════════════
header "FRESHNESS INDICATOR — 1 char, icon CLASS degrades"
echo "  Concept: icon itself changes as data gets staler"
echo ""

state_label "FRESH < 1h (green)"
show '\UF46B'  'oct-sync'
show '\UF058'  'fa-check_circle'
show '\UF00C'  'fa-check'
show '\UF021'  'fa-refresh'
show '\UF0637' 'md-sync'

state_label "STALE 1-24h (peach/yellow)"
show '\UF252'  'fa-hourglass_half'
show '\UF017'  'fa-clock'
show '\UF510'  'oct-clock'
show '\UF0954' 'md-timer_sand'
show '\UF13AB' 'md-clock_outline'
show '\UF025D' 'md-clock_alert'

state_label "VERY STALE >24h (red) — your garbage can idea"
show '\UF1F8'  'fa-trash'
show '\UF014'  'fa-trash_o'
show '\UF52E'  'oct-trash'
show '\UF253'  'fa-hourglass_end'
show '\UF068C' 'md-skull'
show '\UF0BC8' 'md-skull_outline'
show '\UF071'  'fa-exclamation_triangle'
show '\UF057'  'fa-times_circle'
show '\UF05C'  'fa-minus_circle'

# ══════════════════════════════════════════════════════════════════════════════
header "DIRECTION — icon + count (2-4 chars)"
echo "  These always need numbers. Showing arrow style candidates."
echo ""

state_label "AHEAD / PUSH (yellow)"
show '\UF062'  'fa-arrow_up'
show '\UF093'  'fa-upload'
show '\UF40A'  'oct-arrow_up'
show '\UF4DE'  'oct-repo_push'
show '\UF0055' 'md-arrow_up_bold'
show '\UF0552' 'md-cloud_upload'

state_label "BEHIND / PULL (red)"
show '\UF063'  'fa-arrow_down'
show '\UF019'  'fa-download'
show '\UF403'  'oct-arrow_down'
show '\UF4B1'  'oct-download'
show '\UF0048' 'md-arrow_down_bold'
show '\UF0550' 'md-cloud_download'

# ══════════════════════════════════════════════════════════════════════════════
header "OPERATION — 1 char, rare (replaces remote icon when active)"
echo ""

show '\UF419'  'oct-git_merge'              'MERGING'
show '\UF416'  'oct-git_compare'            'REBASING'
show '\UF126'  'fa-code_fork'               'CHERRY-PICK'
show '\UF074'  'fa-random'                  'REBASING alt'
show '\UF252'  'fa-hourglass_half'          'any operation'
show '\UF110'  'fa-spinner'                 'any operation'
show '\UF42E'  'oct-workflow'               'any operation'
show '\UF062A' 'md-source_branch_sync'      'any operation'

# ══════════════════════════════════════════════════════════════════════════════
header "WORKING TREE — icon + count, combinable"
echo ""

state_label "DIRTY (yellow)"
show '\UF444'  'oct-diff_modified'
show '\UF4CC'  'oct-pencil'
show '\UF040'  'fa-pencil_square_o'
show '\UF111'  'fa-circle'                  'simple dot'
show '\UF192'  'fa-dot_circle_o'
show '\UF03EB' 'md-delta'

state_label "STAGED (green)"
show '\UF441'  'oct-diff_added'
show '\UF055'  'fa-plus_circle'
show '\UF058'  'fa-check_circle'
show '\UF00C'  'fa-check'

state_label "UNTRACKED (blue)"
show '\UF128'  'fa-question'
show '\UF059'  'fa-question_circle'
show '\UF4E0'  'oct-question'
show '\UF067'  'fa-plus'
show '\UF0BA6' 'md-new_box'

# ══════════════════════════════════════════════════════════════════════════════
header "COMPOSITION EXAMPLE — how these might sit together"
echo ""
echo "  Concept: branch + indicators + direction + working tree + PR"
echo ""
printf "  "
c_peach; printf "\UE0A0 "; bld; printf "feat/icon-picker"; rst
printf " "
c_green; printf "\UF1126"; rst          # remote_tv green = tracking ok
c_green; printf "\UF46B"; rst           # oct-sync green = fresh
printf " "
c_yellow; printf "\UF062""3"; rst       # ↑3 ahead
printf " "
c_yellow; printf "\UF444""2"; rst       # diff_modified 2
c_green; printf "\UF441""1"; rst        # diff_added 1
printf " "
clr_sep; bld; printf "· "; rst
c_periwinkle; printf "\UF407 "; rst     # PR icon
c_periwinkle; printf "#5"; rst
c_green; printf " 3/5"; rst
echo ""
echo ""

printf "  "
c_red; bld; printf "\UE0A0 "; printf "feat/old-branch"; rst
printf " "
c_red; printf "\UF1127"; rst            # remote_tv_off = gone
c_red; printf "\UF1F8"; rst             # trash = very stale
echo ""
echo ""

printf "  "
c_green; printf "\UE0A0 "; bld; printf "main"; rst
printf " "
c_green; printf "\UF1126"; rst          # remote_tv green
c_green; printf "\UF46B"; rst           # sync green
echo ""
echo ""

printf "  "
c_mauve; printf "\UE0A0 "; bld; printf "feat/merged-one"; rst
printf " "
c_mauve; printf "\UF419"; rst           # git_merge mauve
printf " "
clr_sep; bld; printf "· "; rst
c_mauve; printf "\UF407 "; rst
c_mauve; printf "#5 MERGED"; rst
echo ""
echo ""

clr_dim; printf "  Run in iTerm: bash /Users/james/dev/new/intero-CLI/scripts/git-indicators.sh"; rst
echo ""
