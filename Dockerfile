FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
      bash ca-certificates curl git openssh-client python3 jq \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code & Codex CLIs globally (optional agents alongside Antigravity)
RUN npm install -g @anthropic-ai/claude-code @openai/codex || true

# Non-root workspace user (persists ~/.agentdeck pairing + ~/.gemini Antigravity auth + repos)
RUN useradd -m -s /bin/bash pulsar
USER pulsar
WORKDIR /home/pulsar
ENV HOME=/home/pulsar PATH="/home/pulsar/.local/bin:${PATH}"

# Install Google Antigravity CLI (agy) + Pulsar Host bundle
RUN mkdir -p /home/pulsar/.local/bin /home/pulsar/.agentdeck/bin /home/pulsar/workspaces \
    && curl -fsSL https://antigravity.google/cli/install.sh | bash \
    && curl -fsSL https://agentdeck.finnova.com.au/agentdeck-host.cjs -o /home/pulsar/.agentdeck/bin/agentdeck-host.cjs

COPY --chown=pulsar:pulsar entrypoint.sh /home/pulsar/entrypoint.sh
RUN chmod +x /home/pulsar/entrypoint.sh

VOLUME ["/home/pulsar/.agentdeck", "/home/pulsar/.gemini", "/home/pulsar/workspaces"]
ENTRYPOINT ["/home/pulsar/entrypoint.sh"]
