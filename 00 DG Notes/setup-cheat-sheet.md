# OpenClaw VPS Cheat Sheet

## VPS Connection

```bash
ssh root@5.78.140.181
```

Password in https://docs.google.com/document/d/1jNtdaY0HdHpo1Ab88KvmW0p2AQ_zEiXi7g-xLiWRwBg/edit?usp=sharing

- **Host**: Hetzner VPS, Ubuntu 24.04, 4GB RAM, 75GB disk
- **Hostname**: ubuntu-4gb-hil-1
- **IP**: 5.78.140.181
- **OpenClaw repo**: `/root/openclaw`
- **OpenClaw config**: `/root/.openclaw/openclaw.json`
- **OpenClaw workspace**: `/root/.openclaw/workspace`

## Docker Commands (run from ~/openclaw)

```bash
cd ~/openclaw
```

**Start / Stop / Restart:**

```bash
docker compose up -d                    # Start all services
docker compose down                     # Stop all services
docker compose restart openclaw-gateway # Restart gateway only
```

**View logs:**

```bash
docker compose logs -f openclaw-gateway        # Stream gateway logs (Ctrl+C to stop)
docker compose logs --tail 50 openclaw-gateway  # Last 50 lines
```

**Rebuild image (after Dockerfile or code changes):**

```bash
docker build -t openclaw:local \
  --build-arg OPENCLAW_DOCKER_APT_PACKAGES="chromium fonts-liberation libgbm1 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0" .
```

**Full rebuild + restart cycle:**

```bash
docker compose down
docker build -t openclaw:local --build-arg OPENCLAW_DOCKER_APT_PACKAGES="chromium fonts-liberation libgbm1 libnss3 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libpango-1.0-0 libcairo2 libasound2 libatspi2.0-0" .
docker compose up -d
docker compose logs -f openclaw-gateway
```

**Run CLI commands inside the container:**

```bash
docker compose run --rm openclaw-cli channels status
docker compose run --rm openclaw-cli agents list
docker compose run --rm openclaw-cli config set browser.headless true
docker compose run --rm openclaw-cli onboard
```

**Shell into the running gateway container:**

```bash
docker exec -it openclaw-openclaw-gateway-1 /bin/bash
```

## Config Editing

**Edit openclaw.json directly:**

```bash
nano /root/.openclaw/openclaw.json
```

**Edit with python (scripted changes):**

```bash
python3 -c "
import json
with open('/root/.openclaw/openclaw.json') as f:
    cfg = json.load(f)
# ... make changes ...
with open('/root/.openclaw/openclaw.json', 'w') as f:
    json.dump(cfg, f, indent=2)
"
```

## File Transfer (from local Windows machine)

```powershell
scp C:\Users\deang\projects\openclaw\<file> root@5.78.140.181:/root/openclaw/<file>
```

## Linuxbrew / Skill Dependencies

Homebrew is auto-bootstrapped on first container start via `docker-entrypoint.sh`.
It persists in the `linuxbrew-home` Docker volume.

**If brew needs to be re-bootstrapped:**

```bash
docker compose down
docker volume rm openclaw_linuxbrew-home
docker compose up -d   # entrypoint will reinstall brew (~3-5 min)
```

**Fix volume permissions (if brew install fails with permission errors):**

```bash
docker run --rm -v openclaw_linuxbrew-home:/home/linuxbrew node:22-bookworm chown -R 1000:1000 /home/linuxbrew
```

## Key Files on VPS

| File | Purpose |
|------|---------|
| `~/openclaw/docker-compose.yml` | Docker services config |
| `~/openclaw/Dockerfile` | Image build definition |
| `~/openclaw/docker-entrypoint.sh` | Entrypoint (brew bootstrap) |
| `/root/.openclaw/openclaw.json` | OpenClaw runtime config |
| `/root/.openclaw/workspace/` | Agent workspaces |

## Web UI

- **URL**: `http://5.78.140.181:18789`
- Gateway WebSocket: `ws://5.78.140.181:18789`

## Troubleshooting

- **Gateway crash-loop**: Check `docker compose logs openclaw-gateway` for the error. Common causes: invalid browser profile in openclaw.json, missing model config.
- **Browser not working**: Ensure `browser.headless: true` and `browser.noSandbox: true` in openclaw.json. Chromium must be installed via `OPENCLAW_DOCKER_APT_PACKAGES` build arg.
- **Skill install "brew not installed"**: Rebuild the image with the updated Dockerfile that includes `docker-entrypoint.sh`. Brew bootstraps on first start.
- **Discord not connecting**: Check that the Discord bot token is set in openclaw.json under `discord.token`.
