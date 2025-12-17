# claude-code-container

Docker container for running [Claude Code](https://claude.ai/code) CLI in an isolated Ubuntu 24.04 environment.

## Quick Start

```bash
# Build the image
make build

# Run via alias (add to ~/.bashrc or ~/.zshrc)
alias claude='docker run --rm -it \
  -v ~/.claude:/home/nathan/.claude \
  -v ~/.claude.json:/home/nathan/.claude.json \
  -v ~/.gitconfig:/home/nathan/.gitconfig \
  -v "$(pwd):/workspace" \
  claude:latest'

# First run: authenticate via browser
claude

# Subsequent runs: use from any project directory
cd ~/myproject && claude
```

## What's Included

- Ubuntu 24.04
- Node.js 20.x LTS
- Go 1.25.5
- Python 3 + pip + venv
- ripgrep
- Claude Code CLI

## Container Details

- Runs as non-root user `nathan` (uid/gid 1000)
- Working directory: `/workspace`
- Auth persists via mounted `~/.claude` and `~/.claude.json`
- Auto-updater, telemetry, and error reporting disabled
