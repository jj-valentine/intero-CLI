#!/usr/bin/env python3
"""
SessionStart hook — sets the initial tab title to "~/path · branch".
Calls lib/title.sh for format consistency.
Requires CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1.
"""
import json
import os
import re
import subprocess
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

cwd = data.get("cwd", "") or (data.get("tool_input") or {}).get("cwd", "") or os.getcwd()
if not cwd:
    sys.exit(0)

session_id = data.get("session_id", "")

HOOK_DIR = os.path.dirname(os.path.abspath(__file__))
TITLE_SH = os.path.join(HOOK_DIR, "..", "lib", "title.sh")

tab_title = ""
try:
    r = subprocess.run(
        ["bash", TITLE_SH],
        capture_output=True, text=True, timeout=2, cwd=cwd,
    )
    if r.returncode == 0:
        tab_title = r.stdout.strip()
except Exception:
    pass

home = os.path.expanduser("~")
if not tab_title:
    tab_title = cwd.replace(home, "~") if cwd.startswith(home) else cwd

session_title = session_id if session_id else (cwd.replace(home, "~") if cwd.startswith(home) else cwd)

tab_title = re.sub(r'[\x00-\x1f\x7f]', '', tab_title)[:200]
session_title = re.sub(r'[\x00-\x1f\x7f]', '', session_title)[:200]
tab_title = tab_title.replace(" · ", "  ·  ")
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "sessionTitle": session_title,
    },
    "terminalSequence": f"\033]0;{tab_title}\007",
}))
