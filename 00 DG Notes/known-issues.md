# Known Issues & Bugs

## Discord Guild Messaging — Silently Dropped (v2026.2.13 / v2026.2.14)

**Status:** Waiting for upstream fix
**Discovered:** 2025-02-15
**Affected versions:** v2026.2.13, v2026.2.14
**Last known working version:** v2026.1.30

### Symptoms

- Bot connects to Discord, appears online, and resolves guilds/channels successfully.
- **DMs work** — the bot receives and responds to direct messages.
- **Guild/channel messages are silently dropped** — no MESSAGE_CREATE events are logged, no errors, complete silence.
- Slash commands (INTERACTION_CREATE) work fine.

### Root Cause (Diagnosed)

- Discord's gateway **does** send guild MESSAGE_CREATE events (confirmed via raw WebSocket test).
- `@buape/carbon` v0.14.0 **does** dispatch guild events to `MessageCreateListener` in isolation (confirmed via standalone Carbon test client).
- The full OpenClaw gateway setup silently drops guild MESSAGE_CREATE events somewhere between Carbon's dispatch and the message handler.
- Intents are correct (computed value: 46593, matching Discord standard).
- Guild ID, permissions, Developer Portal intents, and channel config are all verified correct.

### GitHub Issues

- [#4555 — Discord bot cannot receive messages](https://github.com/openclaw/openclaw/issues/4555) (filed Jan 30, 2026)
- [#16860 — Discord MESSAGE_CREATE events not received](https://github.com/openclaw/openclaw/issues/16860) (filed Feb 15, 2026, same symptoms)

### Workaround

If guild messaging is urgently needed, downgrade to **v2026.1.30**:

```bash
cd ~/openclaw
git fetch --tags
git checkout v2026.1.30
docker build -t openclaw:local --build-arg GIT_SHA=$(git rev-parse --short HEAD) .
docker compose down && docker compose up -d
```

### How to Check for a Fix

1. Monitor the GitHub issues above for resolution or a linked PR.
2. Check [releases](https://github.com/openclaw/openclaw/releases) for a new version mentioning Discord MESSAGE_CREATE fix.
3. When a fix is available:

```bash
cd ~/openclaw
git pull
git checkout <new-version-tag>
docker build -t openclaw:local --build-arg GIT_SHA=$(git rev-parse --short HEAD) .
docker compose down && docker compose up -d
```

4. Test by sending a message in a Discord guild channel and checking `docker compose logs -f openclaw-gateway` for `discord: inbound` entries.
