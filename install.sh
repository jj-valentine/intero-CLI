#!/bin/bash
# intero — Install script
# Symlinks pulse.sh into ~/.claude/ and updates settings.json

set -e

INTERO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SETTINGS="$CLAUDE_DIR/settings.json"

mkdir -p "$CLAUDE_DIR"
[[ -f "$SETTINGS" ]] || echo '{}' > "$SETTINGS"

echo "Installing intero..."

# Create symlink
ln -sf "$INTERO_DIR/intero.sh" "$CLAUDE_DIR/statusline-command.sh"
echo "  ✓ Symlinked intero.sh → ~/.claude/statusline-command.sh"

# Update settings.json statusLine config
if [[ -f "$SETTINGS" ]]; then
  # Check if statusLine already exists
  if jq -e '.statusLine' "$SETTINGS" &>/dev/null; then
    # Update existing
    tmp=$(mktemp)
    jq --arg cmd "bash $INTERO_DIR/intero.sh" '.statusLine.command = $cmd' "$SETTINGS" > "$tmp"
    mv "$tmp" "$SETTINGS"
    echo "  ✓ Updated statusLine command in settings.json"
  else
    # Add statusLine
    tmp=$(mktemp)
    jq --arg cmd "bash $INTERO_DIR/intero.sh" '. + {statusLine: {type: "command", command: $cmd}}' "$SETTINGS" > "$tmp"
    mv "$tmp" "$SETTINGS"
    echo "  ✓ Added statusLine config to settings.json"
  fi
else
  echo "  ⚠ settings.json not found at $SETTINGS"
fi

# Title hooks: tab-summary.py (UserPromptSubmit) + session-title.py (SessionStart).
# Needs CC's own auto-titler OFF (CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1) so the
# hook-driven title isn't overridden. Idempotent: re-registers by filename.
chmod +x "$INTERO_DIR"/hooks/*.py 2>/dev/null || true
if [[ -f "$SETTINGS" ]]; then
  tmp=$(mktemp)
  jq --arg ups "python3 $INTERO_DIR/hooks/tab-summary.py" \
     --arg ss  "python3 $INTERO_DIR/hooks/session-title.py" '
    .env.CLAUDE_CODE_DISABLE_TERMINAL_TITLE = "1"
    | .hooks.UserPromptSubmit = (.hooks.UserPromptSubmit // [{hooks: []}])
    | .hooks.UserPromptSubmit[0].hooks =
        ((.hooks.UserPromptSubmit[0].hooks // [])
         | map(select((.command // "") | contains("tab-summary.py") | not))
         + [{type: "command", command: $ups, timeout: 10}])
    | .hooks.SessionStart = (.hooks.SessionStart // [{hooks: []}])
    | .hooks.SessionStart[0].hooks =
        ((.hooks.SessionStart[0].hooks // [])
         | map(select((.command // "") | contains("session-title.py") | not))
         + [{type: "command", command: $ss}])
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "  ✓ Wired title hooks + CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1 into settings.json"
fi

# Copy example config if no config exists
if [[ ! -f "$INTERO_DIR/config.sh" ]]; then
  cp "$INTERO_DIR/config.example.sh" "$INTERO_DIR/config.sh"
  echo "  ✓ Created config.sh from example (customize as needed)"
fi

# Seed the summary model cache (persistent, survives reboot).
# This is the ONLY place a model ID literal appears.
SUMMARY_MODEL_CACHE="$HOME/.cache/intero/summary-model"
if [[ ! -f "$SUMMARY_MODEL_CACHE" ]]; then
  mkdir -p "$(dirname "$SUMMARY_MODEL_CACHE")"
  echo "claude-haiku-4-5-20251001" > "$SUMMARY_MODEL_CACHE"
  echo "  ✓ Seeded summary model cache at $SUMMARY_MODEL_CACHE"
else
  echo "  · Summary model cache exists ($(cat "$SUMMARY_MODEL_CACHE"))"
fi

echo ""
echo "Done. Restart Claude Code to see the status line."
echo "Run 'bash $INTERO_DIR/mock.sh' to preview the design."
