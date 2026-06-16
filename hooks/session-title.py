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

HOOK_DIR = os.path.dirname(os.path.abspath(__file__))
TITLE_SH = os.path.join(HOOK_DIR, "..", "lib", "title.sh")

title = ""
try:
    r = subprocess.run(
        ["bash", TITLE_SH],
        capture_output=True, text=True, timeout=2, cwd=cwd,
    )
    if r.returncode == 0:
        title = r.stdout.strip()
except Exception:
    pass

if not title:
    home = os.path.expanduser("~")
    title = cwd.replace(home, "~") if cwd.startswith(home) else cwd

title = re.sub(r'[\x00-\x1f\x7f]', '', title)[:200]
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "sessionTitle": title,
    },
    "terminalSequence": f"\033]0;{title}\007",
}))
