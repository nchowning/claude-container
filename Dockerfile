FROM ubuntu:24.04
 
ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=nathan
ARG USER_UID=1000
ARG USER_GID=1000
 
# 1) System deps, locales, and useful tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    build-essential \
    python3 \
    python3-pip \
    python3-venv \
    pkg-config \
    unzip \
    gnupg \
    locales \
    sudo \
    dumb-init \
    ripgrep \
 && rm -rf /var/lib/apt/lists/*
 
# Set UTF-8 locale (helps many CLIs and editors)
RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8
 
# 2) Node.js LTS (for JS-based tooling, CLIs, or extension servers)
# Use NodeSource for a current LTS channel
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*
 
# Optional: enable corepack so you can use pnpm/yarn if needed
RUN corepack enable || true
 
# 3) Go 1.25.5
RUN rm -rf /usr/local/go && \
    curl -fsSL https://go.dev/dl/go1.25.5.linux-amd64.tar.gz | tar -C /usr/local -xz

# 4) Non-root user with passwordless sudo (handy for dev containers)
RUN userdel ubuntu
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-nopasswd
 
WORKDIR /workspace
USER ${USERNAME}
 
# Way to invalidate cache from this point on for rebuild
#   `docker build --build-arg CACHEBUST=$(date +%s)`
ARG CACHEBUST=1
 
# 5) (Optional) Install a claude-code CLI if it's published on npm.
# If you have a private tarball or repo, replace this with the proper install step.
# The fallback "|| true" keeps the image buildable even if the package name differs.
# Example:
RUN npm install -g @anthropic-ai/claude-code --prefix ~/.local || true
 
ENV PATH="/home/${USERNAME}/.local/bin:/home/${USERNAME}/go/bin:/usr/local/go/bin:${PATH}"
ENV DISABLE_AUTOUPDATER=1
ENV DISABLE_TELEMETRY=1
ENV DISABLE_ERROR_REPORTING=1

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["claude"]
