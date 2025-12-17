# claude-code-container

Docker container for running [Claude Code](https://claude.ai/code) CLI in an isolated environment.

## Quick Start

### Option 1: Pull from Docker Hub

```bash
docker pull yesimnathan/claude:latest
```

Available tags:
| Tag | Base | Notes |
|-----|------|-------|
| `latest`, `ubuntu`, `ubuntu-24.04` | Ubuntu 24.04 | Default |
| `debian`, `debian-13` | Debian Trixie | |
| `alpine` | Alpine (node:20-alpine) | Smallest image |

Version-pinned tags (when built with specific CLI version):
- `ubuntu-24.04-cli-0.2.50`
- `alpine-cli-0.2.50`

### Option 2: Build locally

```bash
# Default (Ubuntu 24.04)
make build

# Specific base image
make build-ubuntu
make build-debian
make build-alpine

# Pin CLI version
make build CLAUDE_VERSION=0.2.50
```

### Run via shell function

Add to `~/.bashrc` or `~/.zshrc`:

```bash
claude() {
  local mise_vol="claude-mise-$(basename "$PWD")-$(echo "$PWD" | sha256sum | cut -c1-8)"
  docker run --rm -it \
    -v ~/.claude:/home/claude/.claude \
    -v ~/.claude.json:/home/claude/.claude.json \
    -v ~/.gitconfig:/home/claude/.gitconfig \
    -v "$mise_vol":/home/claude/.local/share/mise \
    -v "$PWD":/workspace \
    yesimnathan/claude:latest "$@"
}

# First run: authenticate via browser
claude

# Subsequent runs: use from any project directory
cd ~/myproject && claude
```

## What's Included

- Node.js 20.x LTS
- [mise](https://mise.jdx.dev/) (runtime version manager)
- ripgrep
- build-essential / build-base
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

## CI/CD

Images are automatically built and pushed to Docker Hub on:
- Push to `main`
- Git tags (`v*`)
- Manual workflow dispatch (with optional CLI version)

Multi-arch: `linux/amd64` and `linux/arm64`
