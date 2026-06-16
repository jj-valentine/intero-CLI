#!/bin/bash
_title_path() {
  echo "${PWD/$HOME/\~}"
}

_title_branch() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
  [[ "$branch" == "HEAD" ]] && return
  echo "$branch"
}

_title_summary() {
  local session_id="${1//[^A-Za-z0-9._-]/_}"
  [[ -z "$session_id" ]] && return
  local tmpdir="${TMPDIR:-${XDG_RUNTIME_DIR:-/tmp}}"
  local cache_file="$tmpdir/intero/tab-$session_id"
  [[ -f "$cache_file" ]] && cat "$cache_file"
}

render_title() {
  local session_id="${1:-}"
  local path branch summary out

  path=$(_title_path)
  branch=$(_title_branch)
  summary=$(_title_summary "$session_id")

  out="$path"
  [[ -n "$branch" ]] && out="$out · $branch"
  [[ -n "$summary" ]] && out="$out · $summary"
  echo "$out"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  session_id=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --session) session_id="$2"; shift 2 ;;
      *) shift ;;
    esac
  done
  render_title "$session_id"
fi
