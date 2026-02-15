#!/bin/bash
set -e

BREW_BIN="/home/linuxbrew/.linuxbrew/bin/brew"

# Bootstrap Linuxbrew on first run (persists in the linuxbrew-home volume).
if [ ! -x "$BREW_BIN" ]; then
  echo "[openclaw-init] Bootstrapping Homebrew/Linuxbrew (first run only, ~3-5 min)..."
  echo "[openclaw-init] This enables built-in skill installations (1password, etc.)"

  # Ensure the target directory exists and is writable by the current user.
  mkdir -p /home/linuxbrew/.linuxbrew 2>/dev/null || true

  # Install Homebrew non-interactively.
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    echo "[openclaw-init] WARNING: Homebrew bootstrap failed. Skills requiring brew will not work."
    echo "[openclaw-init] You can retry by removing the volume and restarting:"
    echo "[openclaw-init]   docker volume rm openclaw_linuxbrew-home && docker compose up -d"
  }

  if [ -x "$BREW_BIN" ]; then
    echo "[openclaw-init] Homebrew ready at $BREW_BIN"
  fi
fi

exec "$@"
