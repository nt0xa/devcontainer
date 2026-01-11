FROM debian:stable-slim

# System packages & env {{{

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
    hashicorp/tap/terraform \
    ansible \
    golang \
    node \
    python \
    rustup && \
    brew cleanup --prune=all

# }}}

# Golang {{{

ENV GOPATH=${USER_HOME}/.local/share/go \
    GOCACHE=${USER_HOME}/.cache/go/build \
    GOMODCACHE=${USER_HOME}/.cache/go/mod

RUN go install golang.org/x/tools/gopls@latest && \
    go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest && \
    go install github.com/nametake/golangci-lint-langserver@latest && \
    go clean -cache -modcache

ENV PATH="${USER_HOME}/.local/share/go/bin:${PATH}"

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
