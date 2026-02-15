# OpenClaw VPS Deployment Guide

Step-by-step guide for deploying OpenClaw on a fresh Hetzner VPS (or similar Ubuntu server) using Docker.

## Prerequisites

- Ubuntu 22.04+ VPS with at least 4GB RAM, 40GB disk
- Docker + Docker Compose installed
- SSH access as root (or a user with sudo)
- An OpenRouter API key (or other model provider key)
- (Optional) Discord bot token for Discord integration

## 1. Initial Server Setup

```bash
# Install Docker if not already present
curl -fsSL https://get.docker.com | sh

# Verify
docker --version
docker compose version
```

## 2. Clone the Repo

```bash
cd ~
git clone https://github.com/openclaw/openclaw.git
cd openclaw
git checkout v2026.2.13  # or latest stable tag
```

## 3. Create the .env File

```bash
cp "00 DG Notes/docker.env.example" .env
nano .env
```

Fill in at minimum:

```
OPENCLAW_CONFIG_DIR=/root/.openclaw
OPENCLAW_WORKSPACE_DIR=/root/.openclaw/workspace
OPENROUTER_API_KEY=sk-or-v1-your-actual-key
```

## 4. Create the OpenClaw Config Directory

```bash
mkdir -p /root/.openclaw/workspace
```

Copy the template config and customize it:

```bash
cp "00 DG Notes/openclaw.docker.json" /root/.openclaw/openclaw.json
nano /root/.openclaw/openclaw.json
```

**Required edits in openclaw.json:**

- Replace `YOUR_DISCORD_BOT_TOKEN_HERE` with your actual Discord bot token (or remove the `discord` section)
- Replace `YOUR_GUILD_ID` with your Discord server ID
- Verify the model config matches your OpenRouter subscription

## 5. Build the Docker Image

```bash
docker build -t openclaw:local \
  --build-arg OPENCLAW_DOCKER_APT_PACKAGES="chromium fonts-liberation libgbm1 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0" .
```

This takes ~5-10 minutes on a fresh build. Subsequent builds use Docker layer cache and are much faster.

## 6. Start the Services

```bash
docker compose up -d
```

**First start only**: The entrypoint script will automatically bootstrap Homebrew/Linuxbrew into the `linuxbrew-home` Docker volume. This takes ~3-5 minutes. Subsequent starts skip this step.

## 7. Verify

```bash
# Watch the startup logs
docker compose logs -f openclaw-gateway

# You should see:
# [openclaw-init] Homebrew ready at /home/linuxbrew/.linuxbrew/bin/brew  (first run only)
# [gateway] listening on ws://0.0.0.0:18789
# [browser/service] Browser control service ready
# [discord] logged in to discord as ...  (if Discord configured)
```

The Web UI is now available at `http://YOUR_VPS_IP:18789`.

## 8. Add Agents (Optional)

```bash
# Run the onboarding wizard
docker compose run --rm openclaw-cli onboard

# Or add agents manually
docker compose run --rm openclaw-cli agents add my_agent
```

## Architecture Overview

```
VPS Host (Ubuntu)
├── /root/openclaw/              # Git repo + Dockerfile + docker-compose.yml + .env
├── /root/.openclaw/
│   ├── openclaw.json            # Runtime config (models, browser, discord, agents)
│   └── workspace/               # Agent workspaces (persisted)
└── Docker
    ├── openclaw-gateway (container)
    │   ├── /home/node/.openclaw  → bind mount from /root/.openclaw
    │   ├── /home/linuxbrew       → named volume (linuxbrew-home, persists brew)
    │   └── Ports: 18789 (gateway), 18790 (bridge)
    └── openclaw-cli (container, on-demand)
```

## Key Files

| File | Location | Purpose |
|------|----------|---------|
| `docker-compose.yml` | `~/openclaw/` | Service definitions, volumes, ports |
| `Dockerfile` | `~/openclaw/` | Image build (Node, Chromium, brew prereqs) |
| `docker-entrypoint.sh` | `~/openclaw/` | Auto-bootstraps Homebrew on first run |
| `.env` | `~/openclaw/` | Environment variables (gitignored, has secrets) |
| `openclaw.json` | `/root/.openclaw/` | Runtime config (models, browser, discord) |

## Common Operations

### Update OpenClaw

```bash
cd ~/openclaw
git pull
git checkout v2026.X.Y  # latest tag
docker compose down
docker build -t openclaw:local --build-arg OPENCLAW_DOCKER_APT_PACKAGES="chromium fonts-liberation libgbm1 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0" .
docker compose up -d
```

### Install Skills (e.g., 1Password)

After Homebrew is bootstrapped, install skills from the Web UI Skills tab, or:

```bash
docker compose run --rm openclaw-cli skills install 1password
```

### Reset Homebrew

If brew gets corrupted or you want a clean reinstall:

```bash
docker compose down
docker volume rm openclaw_linuxbrew-home
docker compose up -d   # re-bootstraps in ~3-5 min
```

### Fix Linuxbrew Volume Permissions

If brew install fails with permission errors on an existing volume:

```bash
docker run --rm -v openclaw_linuxbrew-home:/home/linuxbrew node:22-bookworm chown -R 1000:1000 /home/linuxbrew
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Gateway crash-loop | Check `docker compose logs openclaw-gateway`. Common: invalid browser profile, missing model config. |
| "brew not installed" on skill install | Rebuild image with updated Dockerfile + docker-entrypoint.sh, then restart. |
| Browser timeout | Ensure `headless: true`, `noSandbox: true`, `executablePath: "/usr/bin/chromium"` in openclaw.json. |
| Corrupted browser user-data | Delete it: `docker exec openclaw-openclaw-gateway-1 rm -rf /tmp/openclaw-browser-*` then restart. |
| Discord not connecting | Verify bot token in openclaw.json `discord.token`. Check guild ID in `discord.channels`. |
| "variable is not set" warnings | These are harmless for unused variables (CLAUDE_*, OPENCLAW_GATEWAY_TOKEN). Set them in .env to silence. |
