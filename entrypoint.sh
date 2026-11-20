#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
HOST_BIN="$HOME/.agentdeck/bin/agentdeck-host.cjs"
mkdir -p "$HOME/.agentdeck/bin" "$HOME/workspaces"

# Auto-refresh host binary on container start if online
curl -fsSL https://agentdeck.finnova.com.au/agentdeck-host.cjs -o "$HOST_BIN.tmp" && mv "$HOST_BIN.tmp" "$HOST_BIN" || true

# Optional 1-click Cloud Sync bootstrap: clone user's repo + branch and apply optional patch
if [ -n "${PULSAR_GIT_REPO:-}" ]; then
  REPO_NAME=$(basename "${PULSAR_GIT_REPO%.git}")
  TARGET_DIR="$HOME/workspaces/$REPO_NAME"
  CLONE_URL="$PULSAR_GIT_REPO"
  if [ -n "${PULSAR_GITHUB_TOKEN:-}" ] && [[ "$CLONE_URL" == https://github.com/* ]]; then
    CLONE_URL="https://x-access-token:${PULSAR_GITHUB_TOKEN}@${CLONE_URL#https://}"
  fi
  if [ ! -d "$TARGET_DIR/.git" ]; then
    git clone --depth=50 ${PULSAR_GIT_BRANCH:+-b "$PULSAR_GIT_BRANCH"} "$CLONE_URL" "$TARGET_DIR" || git clone "$CLONE_URL" "$TARGET_DIR" || true
  elif [ -n "${PULSAR_GIT_BRANCH:-}" ]; then
    git -C "$TARGET_DIR" fetch origin "$PULSAR_GIT_BRANCH" && git -C "$TARGET_DIR" checkout -B "$PULSAR_GIT_BRANCH" FETCH_HEAD || true
  fi
  if [ -n "${PULSAR_PATCH_B64:-}" ] && [ -d "$TARGET_DIR/.git" ]; then
    printf '%s' "$PULSAR_PATCH_B64" | base64 -d | git -C "$TARGET_DIR" apply --3way - || true
  fi
fi

# Start Pulsar host (Store automatically honors PULSAR_HOST_ID, PULSAR_HOST_NAME, PULSAR_PREPAIR_* & AGENTDECK_RELAY_URL)
node "$HOST_BIN" start &
HOST_PID=$!

for _ in $(seq 1 30); do
  curl -fsS http://127.0.0.1:48632/api/health >/dev/null 2>&1 && break
  sleep 0.5
done

if [ -n "${PULSAR_LICENSE_KEY:-}" ]; then
  curl -fsS -X POST -H 'Content-Type: application/json' -H 'X-AgentDeck: 1' \
    -d "{\"key\":\"${PULSAR_LICENSE_KEY}\"}" http://127.0.0.1:48632/local/license >/dev/null 2>&1 || true
fi

# Print a pairing code on startup if no phone is paired yet
PAIRED=$(curl -fsS http://127.0.0.1:48632/local/status 2>/dev/null | node -e "try{const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log((d.devices||[]).length)}catch{console.log(0)}" 2>/dev/null || echo 0)
if [ "$PAIRED" = "0" ]; then
  CODE=$(curl -fsS -X POST -H 'Content-Type: application/json' -H 'X-AgentDeck: 1' http://127.0.0.1:48632/local/pair 2>/dev/null | node -e "try{const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log(d.code||'')}catch{}" 2>/dev/null || true)
  echo "============================================================"
  echo "  PULSAR CLOUD HOST READY — Pairing code: ${CODE:-unavailable}"
  echo "  Enter this code in the Pulsar phone app (Connect -> Type code)"
  echo "  First time using Antigravity CLI? Run inside container:"
  echo "    agy acp --login"
  echo "============================================================"
fi

wait "$HOST_PID"
