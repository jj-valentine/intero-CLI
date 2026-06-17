#!/usr/bin/env python3
"""
UserPromptSubmit hook — sets terminal tab title to "~/path · branch · summary".

Sync: reads cached summary, emits terminalSequence immediately (~50ms).
Async: if prompt is substantive and cooldown elapsed, spawns detached
curl→Anthropic API to refresh the per-session summary cache.
New summary appears on the NEXT prompt (one-prompt lag by design).

Requires CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1 and ANTHROPIC_API_KEY.

Tunables (config.sh or env — env wins):
  INTERO_TAB_DISABLE_SUMMARY=1   ~/path · branch only, never call API
  INTERO_TAB_MODEL=<id>          pin model (overrides lib/model.sh)
  INTERO_TAB_COOLDOWN=90         seconds between summary refreshes
  INTERO_TAB_TIMEOUT=8           max seconds for the curl call
"""
import json
import os
import re
import subprocess
import sys
import time

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)

prompt = data.get("prompt", "")
if not prompt or not isinstance(prompt, str):
    ti = data.get("tool_input") or {}
    prompt = ti.get("content", "") or ti.get("message", "")
if not isinstance(prompt, str):
    prompt = ""

session_id = data.get("session_id", "")
if session_id:
    session_id = re.sub(r'[^A-Za-z0-9._-]', '_', session_id)
cwd = data.get("cwd", "") or os.getcwd()

HOOK_DIR = os.path.dirname(os.path.abspath(__file__))
INTERO_DIR = os.path.join(HOOK_DIR, "..")
TITLE_SH = os.path.join(INTERO_DIR, "lib", "title.sh")
MODEL_SH = os.path.join(INTERO_DIR, "lib", "model.sh")


def load_config():
    cfg = {}
    config_sh = os.path.join(INTERO_DIR, "config.sh")
    if not os.path.exists(config_sh):
        return cfg
    keys = ["INTERO_TAB_DISABLE_SUMMARY", "INTERO_TAB_MODEL",
            "INTERO_TAB_COOLDOWN", "INTERO_TAB_TIMEOUT", "INTERO_TAB_MODEL_MATRIX"]
    script = 'source "$1" >/dev/null 2>&1; ' + "".join(
        f'printf "%s\\t%s\\n" "{k}" "${{{k}-}}"; ' for k in keys)
    try:
        r = subprocess.run(["bash", "-c", script, "_", config_sh],
                           capture_output=True, text=True, timeout=2)
        for line in r.stdout.splitlines():
            if "\t" in line:
                k, v = line.split("\t", 1)
                if v != "":
                    cfg[k] = v
    except Exception:
        pass
    return cfg


_cfg = load_config()


def knob(key, default=""):
    return os.environ.get(key) or _cfg.get(key) or default


def get_title():
    cmd = ["bash", TITLE_SH]
    if session_id:
        cmd += ["--session", session_id]
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=2, cwd=cwd)
        if r.returncode == 0 and r.stdout.strip():
            return r.stdout.strip()
    except Exception:
        pass
    home = os.path.expanduser("~")
    return cwd.replace(home, "~") if cwd.startswith(home) else cwd


def _sanitize_title(s):
    return re.sub(r'[\x00-\x1f\x7f]', '', s)[:200]


def emit(title):
    if not title:
        return
    title = _sanitize_title(title)
    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "sessionTitle": title,
        },
        "terminalSequence": f"\033]0;{title}\007",
    }))


# ── Cache setup ─────────────────────────────────────────────────────────────
tmpdir = os.environ.get("TMPDIR", os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
cache_dir = os.path.join(tmpdir, "intero")
cache_ok = False
try:
    os.makedirs(cache_dir, mode=0o700, exist_ok=True)
    cache_ok = os.access(cache_dir, os.W_OK)
except Exception:
    pass
cache_file = os.path.join(cache_dir, f"tab-{session_id}") if session_id and cache_ok else ""

cached_age = float("inf")
if cache_file and os.path.exists(cache_file):
    try:
        cached_age = time.time() - os.path.getmtime(cache_file)
    except Exception:
        pass

# Always emit current title immediately (sync part)
emit(get_title())

if knob("INTERO_TAB_DISABLE_SUMMARY") in ("1", "true", "yes"):
    sys.exit(0)
if not session_id:
    sys.exit(0)
if not cache_file:
    sys.exit(0)

# ── Should we refresh? ─────────────────────────────────────────────────────
prompt_lower = (prompt or "").lower().strip()
SKIP = {
    'yes', 'no', 'yeah', 'yep', 'nope', 'sure', 'ok', 'okay', 'agreed',
    'correct', 'right', 'exactly', 'perfect', 'done', 'lgtm', 'ship it',
    'go ahead', 'do it', 'sounds good', 'go for it', 'approved', 'y', 'n',
    'stop', 'sure whatever',
}
trivial = (not prompt) or len(prompt_lower) < 25 or prompt_lower.startswith('/') \
    or prompt_lower.rstrip('.!') in SKIP

try:
    cooldown = float(knob("INTERO_TAB_COOLDOWN", "90"))
except ValueError:
    cooldown = 90.0

if trivial or cached_age < cooldown:
    sys.exit(0)

# ── Resolve model ──────────────────────────────────────────────────────────
model = knob("INTERO_TAB_MODEL")
if not model:
    try:
        model_env = dict(os.environ)
        matrix = knob("INTERO_TAB_MODEL_MATRIX")
        if matrix:
            model_env["INTERO_TAB_MODEL_MATRIX"] = matrix
        r = subprocess.run(["bash", MODEL_SH], capture_output=True,
                           text=True, timeout=2, env=model_env)
        if r.returncode == 0:
            model = r.stdout.strip()
    except Exception:
        pass
if not model:
    sys.exit(0)

# ── Resolve API key ────────────────────────────────────────────────────────
api_key = os.environ.get("ANTHROPIC_API_KEY", "")
if not api_key:
    try:
        r = subprocess.run(
            ["security", "find-generic-password", "-s", "anthropic", "-w"],
            capture_output=True, text=True, timeout=2,
        )
        if r.returncode == 0:
            api_key = r.stdout.strip()
    except Exception:
        pass
if not api_key:
    sys.exit(0)

# ── Spawn detached curl ───────────────────────────────────────────────────
try:
    timeout_s = int(float(knob("INTERO_TAB_TIMEOUT", "8")))
except ValueError:
    timeout_s = 8

existing = ""
if cache_file and os.path.exists(cache_file):
    try:
        with open(cache_file) as f:
            existing = f.read().strip()
    except Exception:
        pass

request_body = json.dumps({
    "model": model,
    "max_tokens": 20,
    "system": (
        "Generate a 3-5 word summary for a browser tab title describing "
        "what the user is working on. Output ONLY the summary, no quotes, "
        "no punctuation, no explanation. Lowercase."
    ),
    "messages": [{"role": "user", "content":
        f"Current tab: {existing}\nNew user message: {prompt[:400]}"}],
})

# API key and cache path passed via env (not interpolated into bash string)
script = f'''
response=$(curl -s --max-time {timeout_s} \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "content-type: application/json" \
  -H "anthropic-version: 2023-06-01" \
  -d @- \
  "https://api.anthropic.com/v1/messages" <<'BODY'
{request_body}
BODY
)
summary=$(echo "$response" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    t = d['content'][0]['text'].strip().rstrip('.').strip('\"').lower()
    if 0 < len(t) < 60: print(t)
except Exception: pass
" 2>/dev/null)
[ -n "$summary" ] && printf '%s' "$summary" > "$INTERO_CACHE_FILE"
'''

try:
    subprocess.Popen(
        ["bash", "-c", script],
        start_new_session=True,
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        env={
            "ANTHROPIC_API_KEY": api_key,
            "PATH": os.environ.get("PATH", ""),
            "INTERO_CACHE_FILE": cache_file,
        },
    )
except Exception:
    pass

sys.exit(0)
