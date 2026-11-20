#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
mkdir -p "$HOME/.local/bin" "$HOME/.agentdeck/bin"

echo "Installing Pulsar host..."
curl -fsSL https://agentdeck.finnova.com.au/agentdeck-host.cjs -o "$HOME/.agentdeck/bin/agentdeck-host.cjs"

echo "Installing Google Antigravity CLI (agy)..."
curl -fsSL https://antigravity.google/cli/install.sh | bash || echo "Note: agy CLI install skipped; run manually if needed."

echo "Installing Claude Code & Codex CLIs (optional)..."
npm install -g @anthropic-ai/claude-code @openai/codex >/dev/null 2>&1 || true

# Persist PATH for interactive shells
grep -q '.local/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
echo "Pulsar Cloud tools installed."
