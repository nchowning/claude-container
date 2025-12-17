# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker dev container for running Claude Code CLI in isolated Ubuntu 24.04 environment.

## Build

```bash
make build
```

Run via shell alias mounting `~/.claude`, `~/.claude.json`, `~/.gitconfig`, and `$(pwd):/workspace`.

## Container Stack

- Ubuntu 24.04 base
- Node.js 20.x LTS (via NodeSource)
- Go 1.25.5
- Python 3 + pip + venv
- ripgrep
- Claude Code CLI (`@anthropic-ai/claude-code`)

## Container Runtime

- Runs as non-root user `nathan` (uid/gid 1000)
- Working dir: `/workspace`
- Entrypoint: `dumb-init` → `claude`
- Auto-updater, telemetry, error reporting disabled

## Volume Mounts (via `make run`)

- `~/.claude` → config/state persistence
- `~/.claude.json` → preferences/OAuth
- `~/.gitconfig` → git config
- `$(PWD)` → `/workspace`
