FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=claude
ARG USER_UID=1000
ARG USER_GID=1000

# 1) System deps, locales, and useful tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    openssh-client \
    build-essential \
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

# 2) Node.js LTS (required for Claude Code CLI)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y --no-install-recommends nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN corepack enable || true

# 3) Non-root user with passwordless sudo
RUN userdel ubuntu
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/bash ${USERNAME} && \
    usermod -aG sudo ${USERNAME} && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-nopasswd

WORKDIR /workspace
USER ${USERNAME}

# 4) Install mise (runtime version manager)
RUN curl https://mise.run | sh && \
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# 5) Create entrypoint script that activates mise and installs tools
RUN printf '#!/bin/bash\neval "$(~/.local/bin/mise activate bash)"\nif [ -f /workspace/.mise.toml ]; then mise install; fi\nexec "$@"\n' > ~/.entrypoint.sh && \
    chmod +x ~/.entrypoint.sh

# Cache bust arg for rebuilding from this point
ARG CACHEBUST=1

# 6) Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code --prefix ~/.local || true

ENV PATH="/home/${USERNAME}/.local/share/mise/shims:/home/${USERNAME}/.local/bin:${PATH}"
ENV MISE_TRUSTED_CONFIG_PATHS=/workspace
ENV DISABLE_AUTOUPDATER=1
ENV DISABLE_TELEMETRY=1
ENV DISABLE_ERROR_REPORTING=1

ENTRYPOINT ["/usr/bin/dumb-init", "--", "/home/claude/.entrypoint.sh"]
CMD ["claude"]
