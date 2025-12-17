# claude-code-container

Docker container for running [Claude Code](https://claude.ai/code) CLI in an isolated Ubuntu 24.04 environment.

## Quick Start

```bash
# Build the image
make build

# Run via alias (add to ~/.bashrc or ~/.zshrc)
alias claude='docker run --rm -it \
  -v ~/.claude:/home/claude/.claude \
  -v ~/.claude.json:/home/claude/.claude.json \
  -v ~/.gitconfig:/home/claude/.gitconfig \
  -v ~/.local/share/mise:/home/claude/.local/share/mise \
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
- [mise](https://mise.jdx.dev/) (runtime version manager)
- ripgrep
- build-essential
- Claude Code CLI

## Per-Project Tools with mise

Instead of baking all runtimes into the image, use mise to install tools per-project. Tools are cached in `~/.local/share/mise` on your host machine.

### Example: Go project

Create `.mise.toml` in your project root:

```toml
[tools]
go = "1.23"
```

### Example: Python project

```toml
[tools]
python = "3.12"
```

### Example: Multiple tools

```toml
[tools]
go = "1.23"
python = "3.12"
node = "22"
```

### How it works

1. **Container startup**: If `.mise.toml` exists, mise installs tools before claude starts (~30-60s first time)
2. **Subsequent runs**: Tools cached in `~/.local/share/mise`, near-instant startup

## Container Details

- Runs as non-root user `claude` (uid/gid 1000)
- Working directory: `/workspace`
- Auth persists via mounted `~/.claude` and `~/.claude.json`
- Tool cache persists via mounted `~/.local/share/mise`
- Auto-updater, telemetry, and error reporting disabled
