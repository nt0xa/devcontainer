FROM debian:stable-slim

# System packages & env {{{

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        iproute2 \
        procps \
        bind9-host \
        gosu \
        openssh-client \
        git \
        curl \
        locales \
        build-essential \
        ca-certificates && \
    sed -i "/en_US.UTF-8/s/^# //g" /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    TERM=xterm-256color

# }}}

# Linuxbrew {{{

ARG USER_HOME=/home/linuxbrew

RUN useradd -m -s /bin/bash linuxbrew
USER linuxbrew
WORKDIR ${USER_HOME}

RUN mkdir -p .local/share .local/state .cache .config .config/nvim .config/fish && \
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

ENV PATH="${USER_HOME}/.linuxbrew/bin:${PATH}"

RUN brew install \
    fish \
    starship \
    fd \
    ripgrep \
    jq \
    neovim \
    tree-sitter-cli \
    sops \
    age \
    hashicorp/tap/terraform \
    hashicorp/tap/packer \
    ansible \
    golang \
    gopls golangci-lint golangci-lint-langserver \
    node \
    python \
    uv ty ruff \
    rustup && \
    brew cleanup --prune=all

# }}}

# Golang {{{

ENV GOPATH=${USER_HOME}/.local/share/go \
    GOCACHE=${USER_HOME}/.cache/go/build \
    GOMODCACHE=${USER_HOME}/.cache/go/mod

ENV PATH="${USER_HOME}/.local/share/go/bin:${PATH}"

# }}}

# Python {{{

RUN uv tool install ty@latest && uv tool install ruff@latest

# }}}


# Rust {{{

ENV CARGO_HOME=${USER_HOME}/.local/share/cargo \
    RUSTUP_HOME=${USER_HOME}/.rustup

RUN rustup-init -y --default-toolchain stable --component rust-analyzer

ENV PATH="${USER_HOME}/.local/share/cargo/bin:${PATH}"

# }}}

# AI {{{

RUN mkdir -p .config/github-copilot
RUN npm install -g \
    @github/copilot-language-server \
    @anthropic-ai/claude-code \
    @openai/codex \
    npm cache clean --force

# }}}

VOLUME ["${USER_HOME}/.local", "${USER_HOME}/.cache"]
USER root
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
