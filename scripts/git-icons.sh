#!/bin/bash
# Git state icon picker — focused on sync, safety, operation, fetch, working tree
source "$(dirname "$0")/../lib/colors.sh"

show() {
  local code="$1" name="$2" note="$3"
  local icon
  icon=$(printf "$code")
  printf "  %s  " "$icon"
  c_subtext0; printf "%-32s" "$name"; rst
  clr_dim; printf "%-10s" "$code"; rst
  [[ -n "$note" ]] && { c_pink; printf " %s" "$note"; rst; }
  echo ""
}

header() {
  echo ""
  c_pink; bld; printf "━━ %s " "$1"; rst
  clr_dim; printf "%s" "$2"; rst
  echo ""
  echo ""
}

family() { c_mauve; printf "  ── %s ──\n" "$1"; rst; }

# ── SYNC: synced/ok ─────────────────────────────────────────────────────────
header "SYNC: ALL CLEAR / SYNCED" "something that says 'all good'"
family "Font Awesome (large)"
show '\UF058'  'fa-check_circle'           'current-ish (using ✓ text)'
show '\UF00C'  'fa-check'
show '\UF14A'  'fa-check_square'
show '\UF06E'  'fa-eye'
show '\UF13E'  'fa-unlock_alt'
show '\UF164'  'fa-thumbs_up'
family "Octicons (large)"
show '\UF4A2'  'oct-check_circle'
show '\UF46D'  'oct-shield_check'
show '\UF43E'  'oct-verified'
show '\UF4DF'  'oct-check_circle_fill'
family "MD (small)"
show '\UF0133' 'md-check_circle'
show '\UF0C4E' 'md-shield_check'
show '\UF15A0' 'md-cloud_check'
show '\UF15A1' 'md-cloud_check_variant'
show '\UF040D' 'md-check_decagram'

# ── SYNC: ahead (push needed) ───────────────────────────────────────────────
header "SYNC: AHEAD / PUSH NEEDED" "unpushed commits"
family "Font Awesome (large)"
show '\UF062'  'fa-arrow_up'
show '\UF093'  'fa-upload'
show '\UF148'  'fa-outdent'
show '\UF14D'  'fa-external_link_square'
family "Octicons (large)"
show '\UF40A'  'oct-arrow_up'
show '\UF4B0'  'oct-upload'
show '\UF4DE'  'oct-repo_push'
family "MD (small)"
show '\UF0552' 'md-cloud_upload'
show '\UF0055' 'md-arrow_up_bold'
show '\UF005D' 'md-arrow_up_circle'

# ── SYNC: behind (pull needed) ──────────────────────────────────────────────
header "SYNC: BEHIND / PULL NEEDED" "need to pull"
family "Font Awesome (large)"
show '\UF063'  'fa-arrow_down'
show '\UF019'  'fa-download'
show '\UF0AB'  'fa-sort_amount_desc'
family "Octicons (large)"
show '\UF403'  'oct-arrow_down'
show '\UF4B1'  'oct-download'
family "MD (small)"
show '\UF0550' 'md-cloud_download'
show '\UF0048' 'md-arrow_down_bold'

# ── SYNC: diverged ──────────────────────────────────────────────────────────
header "SYNC: DIVERGED" "both ahead and behind"
family "Font Awesome (large)"
show '\UF07E'  'fa-arrows_h'
show '\UF0EC'  'fa-exchange'
show '\UF074'  'fa-random'
show '\UF071'  'fa-exclamation_triangle'
family "Octicons (large)"
show '\UF46A'  'oct-alert'
show '\UF416'  'oct-git_compare'
family "MD (small)"
show '\UF01CE' 'md-cached'
show '\UF04E2' 'md-swap_vertical'
show '\UF0026' 'md-alert'
show '\UF0027' 'md-alert_circle'

# ── SYNC: no upstream ───────────────────────────────────────────────────────
header "SYNC: NO UPSTREAM" "branch not published"
family "Font Awesome (large)"
show '\UF071'  'fa-exclamation_triangle'   'current (text ⚠)'
show '\UF127'  'fa-unlink'
show '\UF05E'  'fa-ban'
show '\UF1EB'  'fa-wifi'
family "Octicons (large)"
show '\UF4A3'  'oct-cloud_offline'
show '\UF46A'  'oct-alert'
family "MD (small)"
show '\UF0553' 'md-cloud_off_outline'
show '\UF0551' 'md-cloud_alert'
show '\UF15A6' 'md-cloud_question'

# ── BRANCH SAFETY: gone ─────────────────────────────────────────────────────
header "SAFETY: GONE (remote deleted)" "branch was deleted on remote"
family "Font Awesome (large)"
show '\UF1F8'  'fa-trash'
show '\UF014'  'fa-trash_o'
show '\UF057'  'fa-times_circle'
show '\UF05C'  'fa-minus_circle'
show '\UF071'  'fa-exclamation_triangle'
family "Octicons (large)"
show '\UF52E'  'oct-trash'
show '\UF46A'  'oct-alert'
show '\UF407'  'oct-x_circle'
family "MD (small)"
show '\UF09E7' 'md-delete_alert'
show '\UF0A7A' 'md-ghost'
show '\UF156E' 'md-source_branch_remove'

# ── BRANCH SAFETY: merged ───────────────────────────────────────────────────
header "SAFETY: MERGED" "branch was merged — cleanup time"
family "Font Awesome (large)"
show '\UF058'  'fa-check_circle'
show '\UF00C'  'fa-check'
show '\UF164'  'fa-thumbs_up'
family "Octicons (large)"
show '\UF419'  'oct-git_merge'             'natural choice'
show '\UF4DB'  'oct-git_merge_queue'
show '\UF43E'  'oct-verified'
family "MD (small)"
show '\UF0628' 'md-source_merge'
show '\UF062C' 'md-source_branch_check'
show '\UF01C5' 'md-broom'

# ── OPERATION: merge/rebase/cherry-pick ─────────────────────────────────────
header "OPERATION IN PROGRESS" "interactive merge/rebase/cherry-pick"
family "Font Awesome (large)"
show '\UF074'  'fa-random'
show '\UF126'  'fa-code_fork'
show '\UF0E8'  'fa-sitemap'
show '\UF252'  'fa-hourglass_half'
show '\UF110'  'fa-spinner'
family "Octicons (large)"
show '\UF419'  'oct-git_merge'
show '\UF416'  'oct-git_compare'
show '\UF42E'  'oct-workflow'
family "MD (small)"
show '\UF0628' 'md-source_merge'
show '\UF062A' 'md-source_branch_sync'
show '\UF0637' 'md-sync'

# ── FETCH STALENESS ─────────────────────────────────────────────────────────
header "FETCH STALENESS" "how long since last git fetch"
family "Font Awesome (large)"
show '\UF021'  'fa-refresh'
show '\UF01E'  'fa-undo'
show '\UF017'  'fa-clock'
show '\UF252'  'fa-hourglass_half'
show '\UF253'  'fa-hourglass_end'
family "Octicons (large)"
show '\UF46B'  'oct-sync'
show '\UF510'  'oct-clock'
family "MD (small)"
show '\UF15A4' 'md-cloud_refresh'
show '\UF0954' 'md-timer_sand'
show '\UF13AB' 'md-clock_outline'
show '\UF025D' 'md-clock_alert'

# ── WORKING TREE: dirty ─────────────────────────────────────────────────────
header "WORKING TREE: DIRTY" "modified files"
family "Font Awesome (large)"
show '\UF040'  'fa-pencil_square_o'
show '\UF044'  'fa-pencil_square'
show '\UF06E'  'fa-eye'
show '\UF111'  'fa-circle'
show '\UF192'  'fa-dot_circle_o'
family "Octicons (large)"
show '\UF440'  'oct-diff'
show '\UF441'  'oct-diff_added'
show '\UF444'  'oct-diff_modified'
show '\UF4CC'  'oct-pencil'
family "MD (small)"
show '\UF03EB' 'md-delta'
show '\UF0DCA' 'md-pencil'
show '\UF0DD9' 'md-pencil_circle'

# ── WORKING TREE: staged ────────────────────────────────────────────────────
header "WORKING TREE: STAGED" "ready to commit"
family "Font Awesome (large)"
show '\UF055'  'fa-plus_circle'
show '\UF0FE'  'fa-plus_square'
show '\UF058'  'fa-check_circle'
show '\UF00C'  'fa-check'
family "Octicons (large)"
show '\UF441'  'oct-diff_added'
show '\UF4DF'  'oct-check_circle_fill'

# ── WORKING TREE: untracked ─────────────────────────────────────────────────
header "WORKING TREE: UNTRACKED" "new files not yet staged"
family "Font Awesome (large)"
show '\UF128'  'fa-question'
show '\UF059'  'fa-question_circle'
show '\UF29C'  'fa-question_circle_o'
show '\UF067'  'fa-plus'
show '\UF0FE'  'fa-plus_square'
family "Octicons (large)"
show '\UF4E0'  'oct-question'
show '\UF4A0'  'oct-plus_circle'
family "MD (small)"
show '\UF0656' 'md-help_circle'
show '\UF0BA6' 'md-new_box'

echo ""
clr_dim; printf "  Run in iTerm to see true rendering with Hack Nerd Font Mono."; rst
echo ""
