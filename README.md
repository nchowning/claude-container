# claude-code-container

Docker container for running [Claude Code](https://claude.ai/code) CLI in an isolated Ubuntu 24.04 environment.

## Quick Start

```bash
# Build the image
make build

# Run via function (add to ~/.bashrc or ~/.zshrc)
claude() {
  local mise_vol="claude-mise-$(basename "$PWD")-$(echo "$PWD" | sha256sum | cut -c1-8)"
  docker run --rm -it \
    -v ~/.claude:/home/claude/.claude \
    -v ~/.claude.json:/home/claude/.claude.json \
    -v ~/.gitconfig:/home/claude/.gitconfig \
    -v "$mise_vol":/home/claude/.local/share/mise \
    -v "$PWD":/workspace \
    claude:latest "$@"
}

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

Instead of baking all runtimes into the image, use mise to install tools per-project. Tools are cached in per-project Docker volumes.

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
2. **Subsequent runs**: Tools cached in per-project Docker volume, near-instant startup
3. **Cross-platform**: Named volumes work on Linux/macOS/Windows - no binary compatibility issues

## Container Details

- Runs as non-root user `claude` (uid/gid 1000)
- Working directory: `/workspace`
- Auth persists via mounted `~/.claude` and `~/.claude.json`
- Tool cache persists via per-project Docker volumes (named `claude-mise-<project>-<hash>`)
- Auto-updater, telemetry, and error reporting disabled
