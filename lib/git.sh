#!/bin/bash
# intero — Git data extraction with 5s TTL caching

# ── Cache infrastructure ─────────────────────────────────────────────────────

_git_cache_key() {
  local cwd=$1
  echo -n "$cwd" | md5 2>/dev/null || echo -n "$cwd" | md5sum 2>/dev/null | cut -d' ' -f1
}

_git_cache_file() {
  echo "$INTERO_CACHE_DIR/git-$(_git_cache_key "$1")"
}

_git_cache_fresh() {
  local cache_file=$1 ttl=${2:-5}
  [[ ! -f "$cache_file" ]] && return 1
  local now file_age
  now=$(date +%s)
  file_age=$(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null)
  (( now - file_age < ttl ))
}

# ── Core data collection ─────────────────────────────────────────────────────

# Populates GIT_* variables from cache or fresh git calls
# Usage: git_collect <cwd>
git_collect() {
  local cwd=$1
  local git_dir

  # Check if we're in a git repo
  git_dir=$(git -C "$cwd" rev-parse --git-dir 2>/dev/null) || {
    GIT_IN_REPO=0
    return
  }
  GIT_IN_REPO=1

  # Resolve absolute git dir for file checks
  [[ "$git_dir" != /* ]] && git_dir="$cwd/$git_dir"

  # Worktree detection: git-dir differs from git-common-dir in worktrees
  local git_common_dir
  git_common_dir=$(git -C "$cwd" rev-parse --git-common-dir 2>/dev/null)
  [[ "$git_common_dir" != /* ]] && git_common_dir="$cwd/$git_common_dir"
  local resolved_git_dir resolved_common_dir
  resolved_git_dir=$(cd "$git_dir" 2>/dev/null && pwd -P)
  resolved_common_dir=$(cd "$git_common_dir" 2>/dev/null && pwd -P)
  if [[ "$resolved_git_dir" != "$resolved_common_dir" ]]; then
    GIT_IS_WORKTREE=1
  else
    GIT_IS_WORKTREE=0
  fi

  local cache_file
  cache_file=$(_git_cache_file "$cwd")

  if _git_cache_fresh "$cache_file"; then
    source "$cache_file"
    return
  fi

  # ── Fresh collection ─────────────────────────────────────────────────────

  # Branch + ahead/behind from single porcelain call
  local status_output
  status_output=$(git -C "$cwd" status --porcelain=v2 --branch 2>/dev/null)

  GIT_BRANCH=$(echo "$status_output" | sed -n 's/^# branch.head //p')
  [[ "$GIT_BRANCH" == "(detached)" ]] && GIT_BRANCH="HEAD"

  # Ahead/behind
  local ab_line
  ab_line=$(echo "$status_output" | sed -n 's/^# branch.ab //p')
  GIT_AHEAD=0; GIT_BEHIND=0
  if [[ -n "$ab_line" ]]; then
    GIT_AHEAD=$(echo "$ab_line" | grep -o '+[0-9]*' | tr -d '+')
    GIT_BEHIND=$(echo "$ab_line" | grep -o '\-[0-9]*' | tr -d '-')
  fi

  # File counts from porcelain v2
  GIT_STAGED=0; GIT_DIRTY=0; GIT_UNTRACKED=0
  while IFS= read -r line; do
    case "$line" in
      "1 "*)  # ordinary changed
        local xy="${line:2:2}"
        [[ "${xy:0:1}" != "." ]] && (( GIT_STAGED++ ))
        [[ "${xy:1:1}" != "." ]] && (( GIT_DIRTY++ ))
        ;;
      "2 "*)  # renamed
        local xy="${line:2:2}"
        [[ "${xy:0:1}" != "." ]] && (( GIT_STAGED++ ))
        [[ "${xy:1:1}" != "." ]] && (( GIT_DIRTY++ ))
        ;;
      "u "*)  # unmerged
        (( GIT_DIRTY++ ))
        ;;
      "? "*)  # untracked
        (( GIT_UNTRACKED++ ))
        ;;
    esac
  done <<< "$status_output"

  # Stash count
  GIT_STASH=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')

  # Ongoing operation
  GIT_OP=""
  if [[ -f "$git_dir/MERGE_HEAD" ]]; then
    GIT_OP="MERGING"
  elif [[ -d "$git_dir/rebase-merge" || -d "$git_dir/rebase-apply" ]]; then
    GIT_OP="REBASING"
  elif [[ -f "$git_dir/CHERRY_PICK_HEAD" ]]; then
    GIT_OP="CHERRY-PICK"
  fi

  # Last fetch time
  GIT_LAST_FETCH=0
  if [[ -f "$git_dir/FETCH_HEAD" ]]; then
    GIT_LAST_FETCH=$(stat -f %m "$git_dir/FETCH_HEAD" 2>/dev/null || stat -c %Y "$git_dir/FETCH_HEAD" 2>/dev/null || echo 0)
  fi

  # Remote URL (for OSC 8)
  GIT_REMOTE_URL=$(git -C "$cwd" remote get-url origin 2>/dev/null | sed 's/\.git$//' | sed 's|git@github.com:|https://github.com/|')

  # Upstream tracking
  GIT_HAS_UPSTREAM=1
  git -C "$cwd" rev-parse --abbrev-ref "@{upstream}" &>/dev/null || GIT_HAS_UPSTREAM=0

  # Branch safety: gone + merged detection
  GIT_GONE=0
  GIT_MERGED=0
  if [[ "$GIT_BRANCH" != "main" && "$GIT_BRANCH" != "master" ]]; then
    git -C "$cwd" branch -vv --list "$GIT_BRANCH" 2>/dev/null | grep -q '\[.*: gone\]' && GIT_GONE=1
    # Resolve default branch (not always "main")
    local default_branch
    default_branch=$(git -C "$cwd" symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
    default_branch=${default_branch:-main}
    # Check merge via git (fast-forward/true merge) OR gh (squash/rebase merge)
    git -C "$cwd" branch --merged "$default_branch" --list "$GIT_BRANCH" 2>/dev/null | grep -q . && GIT_MERGED=1
    if (( ! GIT_MERGED )); then
      gh pr list --repo "$GIT_REMOTE_URL" --head "$GIT_BRANCH" --state merged --json number --jq '.[0].number' 2>/dev/null | grep -q . && GIT_MERGED=1
    fi
    # Check if remote branch still exists
    GIT_REMOTE_BRANCH_EXISTS=0
    git -C "$cwd" ls-remote --heads origin "$GIT_BRANCH" 2>/dev/null | grep -q . && GIT_REMOTE_BRANCH_EXISTS=1
  else
    GIT_GONE=0
    GIT_MERGED=0
    GIT_REMOTE_BRANCH_EXISTS=0
  fi

  # Write cache
  cat > "$cache_file" <<CACHE
GIT_BRANCH="$GIT_BRANCH"
GIT_AHEAD=$GIT_AHEAD
GIT_BEHIND=$GIT_BEHIND
GIT_STAGED=$GIT_STAGED
GIT_DIRTY=$GIT_DIRTY
GIT_UNTRACKED=$GIT_UNTRACKED
GIT_STASH=$GIT_STASH
GIT_OP="$GIT_OP"
GIT_LAST_FETCH=$GIT_LAST_FETCH
GIT_REMOTE_URL="$GIT_REMOTE_URL"
GIT_HAS_UPSTREAM=$GIT_HAS_UPSTREAM
GIT_GONE=$GIT_GONE
GIT_MERGED=$GIT_MERGED
GIT_REMOTE_BRANCH_EXISTS=$GIT_REMOTE_BRANCH_EXISTS
GIT_IS_WORKTREE=$GIT_IS_WORKTREE
GIT_IN_REPO=1
CACHE
}

# ── Sync status rendering ───────────────────────────────────────────────────

# Outputs the sync status section (colored)
git_sync_status() {
  if (( ! GIT_IN_REPO )); then return; fi

  # Operation takes priority
  if [[ -n "$GIT_OP" ]]; then
    clr_op; bld; printf "%s" "$GIT_OP"; rst
    return
  fi

  # Branch safety: gone/merged takes priority over normal sync
  if (( GIT_GONE )); then
    clr_sync_bad; printf "%s gone — pull main" "$IC_WARNING"; rst
    return
  fi
  if (( GIT_MERGED )); then
    c_mauve; printf "%s merged" "$IC_SYNCED"; rst
    if (( GIT_REMOTE_BRANCH_EXISTS )); then
      clr_dim; printf " · remote"; rst
    fi
    return
  fi

  # Upstream check
  if (( ! GIT_HAS_UPSTREAM )); then
    c_peach; printf "%s no upstream" "$IC_WARNING"; rst
    return
  fi

  # Ahead/behind
  if (( GIT_BEHIND > 0 && GIT_AHEAD > 0 )); then
    clr_sync_bad; printf "%s %s%d %s%d diverged" "$IC_WARNING" "$IC_PUSH" "$GIT_AHEAD" "$IC_PULL" "$GIT_BEHIND"; rst
  elif (( GIT_BEHIND > 0 )); then
    clr_sync_bad; printf "%s %d behind — pull needed" "$IC_WARNING" "$GIT_BEHIND"; rst
  elif (( GIT_AHEAD > 0 )); then
    c_yellow; printf "%s %d to push" "$IC_PUSH" "$GIT_AHEAD"; rst
  else
    # Check fetch staleness
    local now fetch_age
    now=$(date +%s)
    if (( GIT_LAST_FETCH > 0 )); then
      fetch_age=$((now - GIT_LAST_FETCH))
      if (( fetch_age > 86400 )); then
        c_red; printf "fetched %s" "$(fmt_relative "$GIT_LAST_FETCH")"; rst
      elif (( fetch_age > 3600 )); then
        c_peach; printf "fetched %s" "$(fmt_relative "$GIT_LAST_FETCH")"; rst
      else
        clr_sync_ok; printf "%s synced" "$IC_SYNCED"; rst
      fi
    else
      clr_sync_ok; printf "%s synced" "$IC_SYNCED"; rst
    fi
  fi

  # Stash indicator (appended)
  if (( GIT_STASH > 0 )); then
    dot
    clr_stash; printf "%s %d stashed" "$IC_STASH" "$GIT_STASH"; rst
  fi
}

# ── Branch section rendering ────────────────────────────────────────────────

git_branch_section() {
  if (( ! GIT_IN_REPO )); then return; fi

  clr_branch; printf "%s " "$IC_BRANCH"; rst
  [[ -n "$GIT_REMOTE_URL" ]] && link_open "$GIT_REMOTE_URL"
  clr_branch; printf "%s" "$GIT_BRANCH"; rst
  [[ -n "$GIT_REMOTE_URL" ]] && link_close

  # File state indicators
  if (( GIT_DIRTY > 0 )); then
    c_yellow; printf " %s%d" "$IC_DIRTY" "$GIT_DIRTY"; rst
  fi
  if (( GIT_STAGED > 0 )); then
    c_green; printf " %s%d" "$IC_STAGED" "$GIT_STAGED"; rst
  fi
  if (( GIT_UNTRACKED > 0 )); then
    c_blue; printf " %s%d" "$IC_UNTRACKED" "$GIT_UNTRACKED"; rst
  fi
}
