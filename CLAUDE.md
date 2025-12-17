# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker dev container for running Claude Code CLI in isolated Ubuntu 24.04 environment.

## Build

```bash
make build
```

Run via shell function mounting config and project dir.

## Container Stack

- Ubuntu 24.04 base
- Node.js 20.x LTS (via NodeSource)
- mise (runtime version manager)
- ripgrep, build-essential
- Claude Code CLI (`@anthropic-ai/claude-code`)

## Container Runtime

- Runs as non-root user `claude` (uid/gid 1000)
- Working dir: `/workspace`
- Entrypoint: `dumb-init` → `claude`
- Auto-updater, telemetry, error reporting disabled

## Volume Mounts (via shell function)

- `~/.claude` → config/state persistence
- `~/.claude.json` → preferences/OAuth
- `~/.gitconfig` → git config
- `claude-mise-<project>-<hash>` → per-project tool cache (Docker named volume)
- `$PWD` → `/workspace`
