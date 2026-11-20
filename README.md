# Pulsar Cloud — Run Antigravity, Claude Code & Codex in the Cloud (Free with GitHub Codespaces!)

Run your AI coding agents in a cloud Linux VM and control them from your **iPhone, iPad, or Android phone** with **Pulsar** — even when your laptop is completely shut off!

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/robinbakshi007/pulsar-cloud?quickstart=1)

## Option 1: Free in GitHub Codespaces (60 hrs/month FREE on every GitHub account)
1. Click **[Launch Pulsar Cloud in GitHub Codespaces](https://codespaces.new/robinbakshi007/pulsar-cloud?quickstart=1)** above.
2. Wait ~60 seconds while Codespaces installs **Antigravity CLI (`agy`)**, **Claude Code**, **Codex**, and **Pulsar Host**.
3. The **Pulsar Pairing QR Dashboard** opens automatically (or copy the 8-character pairing code printed in the terminal).
4. In the Codespace terminal, sign into your agent once:
   ```bash
   agy acp --login          # Google Antigravity CLI
   gh repo clone owner/repo # Clone any repository you want to work on
   ```
5. Open **Pulsar** on your phone ([App Store](https://apps.apple.com/au/app/pulsar-ai-agent-remote/id6824424776) · [Android Beta — 60 days Pro FREE](https://agentdeck.finnova.com.au/android-beta)) and scan the QR code!

## Option 2: Always-On 24/7 Docker (Any VPS, Oracle Cloud Free Tier, or Home Server)
```bash
git clone https://github.com/robinbakshi007/pulsar-cloud.git
cd pulsar-cloud
docker compose up -d
docker exec -it pulsar-cloud agy acp --login
docker logs pulsar-cloud   # Shows your 8-character pairing code!
```

## Option 3: Fly.io Cloud Box
```bash
fly launch --no-deploy
fly volumes create pulsar_data --size 10
fly deploy
fly ssh console -C "agy acp --login"
fly logs
```

---

- **Website:** https://agentdeck.finnova.com.au/cloud
- **Pricing:** 14 days free automatically (no card) · 60 days free for Android Beta testers · from US$0.99/mo or US$29.99 once lifetime.
- *Pulsar is an independent companion app and is not affiliated with Google or Antigravity.*
