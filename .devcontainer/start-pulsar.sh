#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"
HOST_BIN="$HOME/.agentdeck/bin/agentdeck-host.cjs"
LOG_FILE="$HOME/.agentdeck/pulsar-cloud.log"

mkdir -p "$HOME/.agentdeck/bin"
if [ ! -f "$HOST_BIN" ]; then
  curl -fsSL https://agentdeck.finnova.com.au/agentdeck-host.cjs -o "$HOST_BIN"
fi

# Start Pulsar host in background if not already listening on 48632
if ! curl -fsS http://127.0.0.1:48632/api/health >/dev/null 2>&1; then
  nohup node "$HOST_BIN" start >"$LOG_FILE" 2>&1 &
  for _ in $(seq 1 20); do
    curl -fsS http://127.0.0.1:48632/api/health >/dev/null 2>&1 && break
    sleep 0.5
  done
fi

CODE=$(curl -fsS -X POST -H 'Content-Type: application/json' -H 'X-AgentDeck: 1' http://127.0.0.1:48632/local/pair 2>/dev/null | node -e "try{const d=JSON.parse(require('fs').readFileSync(0,'utf8'));console.log(d.code||'')}catch{}" 2>/dev/null || true)

echo ""
echo "======================================================================"
echo "  PULSAR CLOUD IS RUNNING (14 days free, no card; 60 days Android beta)"
echo "======================================================================"
if [ -n "${CODESPACE_NAME:-}" ]; then
  echo "  QR Pairing Dashboard: https://${CODESPACE_NAME}-48632.app.github.dev/pair"
else
  echo "  QR Pairing Dashboard: http://localhost:48632/pair"
fi
if [ -n "$CODE" ]; then
  echo "  Pairing Code (type in Pulsar phone app): $CODE"
fi
echo ""
echo "  Quick setup:"
echo "    1. Sign into Antigravity once:   agy acp --login"
echo "    2. (Optional) Sign into Claude:  claude"
echo "    3. Clone any of your repos:      gh repo clone owner/repo"
echo "    4. Scan the QR or enter the pairing code in the Pulsar phone app!"
echo "======================================================================"
echo ""
