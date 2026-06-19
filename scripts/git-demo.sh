#!/bin/bash
# Demo: two approaches for git section layout
# Run: bash scripts/git-demo.sh

DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$DIR/lib/colors.sh"
source "$DIR/lib/icons.sh"

label() { printf "\n"; c_overlay1; printf "  %s" "$1"; rst; printf "\n"; }
scenario() { c_subtext0; dim; printf "    %-38s" "$1"; rst; }

printf "\n"
c_mauve; bld; printf "  ══════════════════════════════════════════════════════════════"; rst
printf "\n"
c_mauve; bld; printf "  APPROACH A: Sync encoded in branch color"; rst
printf "\n"
c_subtext0; printf "  Branch name color = worst sync state. Counts as compact suffixes."; rst
printf "\n"
c_mauve; bld; printf "  ══════════════════════════════════════════════════════════════"; rst
printf "\n"

label "Clean, synced, has dirty+staged files, PR open"
scenario ""
c_green; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
c_yellow; printf " %s3" "$IC_DIRTY"; rst
c_green; printf " %s1" "$IC_STAGED"; rst
dot
clr_pr; printf "%s " "$IC_PR"; rst
clr_pr; printf "#5"; rst
c_green; printf " 3∕5"; rst
printf "\n"

label "3 ahead, dirty files, no PR"
scenario ""
c_yellow; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
c_yellow; printf " %s3" "$IC_PUSH"; rst
c_yellow; printf " %s2" "$IC_DIRTY"; rst
printf "\n"

label "Diverged (2 ahead, 1 behind), PR open"
scenario ""
c_red; bld; printf "%s " "$IC_BRANCH"; printf "feat/icon-picker"; rst
c_red; printf " %s2%s1" "$IC_PUSH" "$IC_PULL"; rst
dot
clr_pr; printf "%s " "$IC_PR"; rst
clr_pr; printf "#5"; rst
c_green; printf " 5∕5"; rst
printf "\n"

label "Merged branch, remote still exists"
scenario ""
c_mauve; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
c_mauve; printf " merged"; rst
clr_dim; printf " · remote"; rst
dot
clr_pr; printf "%s " "$IC_PR"; rst
c_mauve; printf "#5 MERGED"; rst
printf "\n"

label "Gone (remote branch deleted)"
scenario ""
c_red; bld; printf "%s " "$IC_BRANCH"; printf "feat/icon-picker"; rst
c_red; printf " gone"; rst
printf "\n"

label "Clean, synced, no changes, no PR"
scenario ""
c_green; printf "%s " "$IC_BRANCH"; bld; printf "main"; rst
printf "\n"

label "No upstream set"
scenario ""
c_peach; printf "%s " "$IC_BRANCH"; bld; printf "feat/new-thing"; rst
c_peach; printf " %s no upstream" "$IC_WARNING"; rst
printf "\n"

label "Stale fetch (>1h), clean"
scenario ""
c_peach; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
clr_dim; printf " fetched 2h ago"; rst
printf "\n"

printf "\n\n"
c_teal; bld; printf "  ══════════════════════════════════════════════════════════════"; rst
printf "\n"
c_teal; bld; printf "  APPROACH B: Sync as compact subsection"; rst
printf "\n"
c_subtext0; printf "  Branch always peach. Sync is dot-separated, icons+counts only."; rst
printf "\n"
c_teal; bld; printf "  ══════════════════════════════════════════════════════════════"; rst
printf "\n"

label "Clean, synced, has dirty+staged files, PR open"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
c_yellow; printf " %s3" "$IC_DIRTY"; rst
c_green; printf " %s1" "$IC_STAGED"; rst
dot
c_green; printf "%s" "$IC_SYNCED"; rst
dot
clr_pr; printf "%s " "$IC_PR"; rst
clr_pr; printf "#5"; rst
c_green; printf " 3∕5"; rst
printf "\n"

label "3 ahead, dirty files, no PR"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
c_yellow; printf " %s3" "$IC_DIRTY"; rst
dot
c_yellow; printf "%s3" "$IC_PUSH"; rst
printf "\n"

label "Diverged (2 ahead, 1 behind), PR open"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
dot
c_red; bld; printf "%s2%s1" "$IC_PUSH" "$IC_PULL"; rst
dot
clr_pr; printf "%s " "$IC_PR"; rst
clr_pr; printf "#5"; rst
c_green; printf " 5∕5"; rst
printf "\n"

label "Merged branch, remote still exists"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
dot
c_mauve; printf "%s merged" "$IC_SYNCED"; rst
clr_dim; printf " · remote"; rst
dot
clr_pr; printf "%s " "$IC_PR"; rst
c_mauve; printf "#5 MERGED"; rst
printf "\n"

label "Gone (remote branch deleted)"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
dot
c_red; bld; printf "%s gone" "$IC_WARNING"; rst
printf "\n"

label "Clean, synced, no changes, no PR"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "main"; rst
dot
c_green; printf "%s" "$IC_SYNCED"; rst
printf "\n"

label "No upstream set"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/new-thing"; rst
dot
c_peach; printf "%s no upstream" "$IC_WARNING"; rst
printf "\n"

label "Stale fetch (>1h), clean"
scenario ""
clr_branch; printf "%s " "$IC_BRANCH"; bld; printf "feat/icon-picker"; rst
dot
c_peach; printf "fetched 2h ago"; rst
printf "\n"

printf "\n"
