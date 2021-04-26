FROM debian:buster-slim

# Let's use Bash as the default shell
ENV SHELL=/bin/bash

# Install vim, python and other utils
RUN apt-get update \
    && apt-get install -y \
    tar \
    wget \
    curl \
    vim \
    git \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m pip install --upgrade pip

# Install nodejs using nvm
ENV NVM_DIR=/opt/nvm
ENV PROFILE=/etc/bash.bashrc
RUN mkdir -p /opt/nvm \
    && wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install --lts \
    && nvm use --lts

# Install neovim (fancy Vim)
RUN mkdir /opt/nvim \
 && wget -O /opt/nvim/nvim.appimage https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage \
 && chmod +x /opt/nvim/nvim.appimage \
 && cd /opt/nvim \
 && /opt/nvim/nvim.appimage --appimage-extract \
 && ln -s /opt/nvim/squashfs-root/usr/bin/nvim /usr/bin/nvim

# Install Fuzzy File Finder (fzf)
RUN git clone --branch "0.27.0" --depth 1 https://github.com/junegunn/fzf.git /tmp/fzf \
 && /tmp/fzf/install --no-zsh --no-fish \
 && cp /tmp/fzf/bin/fzf* /usr/bin/

# Install starship prompt and set vi mode for bash
RUN curl -fsSL https://starship.rs/install.sh -o /tmp/starship.sh \
 && chmod +x /tmp/starship.sh \
 && bash -c "/tmp/starship.sh --yes --bin-dir=/usr/bin" \
 && rm /tmp/starship.sh \
 && echo "[hostname]" >> /etc/starship.toml \
 && echo "ssh_only = false" >> /etc/starship.toml \
 && echo 'format =  "on [$hostname](bold red) "' >> /etc/starship.toml \
 && echo "disabled = false" >> /etc/starship.toml \
 && echo "set -o vi" >> /etc/bash.bashrc \
 && echo bind \'\"jj\":vi-movement-mode\' >> /etc/bash.bashrc \
 && echo "export STARSHIP_CONFIG=/etc/starship.toml" >> /etc/bash.bashrc \
 && echo 'alias l="ls -lah --color=auto"' >> /etc/bash.bashrc \
 && echo 'alias ls="ls --color=auto"' >> /etc/bash.bashrc \
 && echo 'alias v="nvim"' >> /etc/bash.bashrc \
 && echo 'eval "$(starship init bash)"' >> /etc/bash.bashrc
