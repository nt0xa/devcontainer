FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y git curl locales build-essential
RUN useradd -m -s /bin/bash linuxbrew
RUN sed -i "/en_US.UTF-8/s/^# //g" /etc/locale.gen && locale-gen

USER linuxbrew
RUN mkdir -p ~/.local/share ~/.local/state
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

RUN brew install \
    fish starship fd ripgrep jq \
    neovim tree-sitter-cli \
    golang gopls \
    python \
    node

RUN npm install -g @github/copilot-language-server

VOLUME /home/linuxbrew/.local/share
VOLUME /home/linuxbrew/.local/state

ENV LANG=en_US.UTF-8  
ENV LANGUAGE=en_US:en  
ENV LC_ALL=en_US.UTF-8     
ENV TERM=xterm-256color

