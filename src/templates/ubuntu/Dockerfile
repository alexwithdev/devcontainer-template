FROM ubuntu:22.04

USER root

ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=developer

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Shanghai

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    zsh \
    git \
    git-lfs \
    htop \
    strace \
    curl \
    wget \
    nano \
    neovim \
    ca-certificates \
    openssh-client \
    openssl \
    tzdata \
    xz-utils \
    socat \
    imagemagick \
    locales \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen zh_CN.UTF-8

ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/zsh ${USERNAME}

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY scripts/default-text-editor /usr/local/bin/default-text-editor
RUN chmod +x /usr/local/bin/default-text-editor

ENV VISUAL=default-text-editor
ENV EDITOR=default-text-editor
ENV ZSH_PLUGIN_LIST="git"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

RUN wget https://github.com/ohmyzsh/ohmyzsh/raw/master/tools/install.sh && \
    sh install.sh --unattended --keep-zshrc && \
    echo "export ZSH=/home/${USERNAME}/.oh-my-zsh" >> /home/${USERNAME}/.zshrc && \
    echo "ZSH_THEME=\"robbyrussell\"" >> /home/${USERNAME}/.zshrc && \
    echo "plugins=(\${=ZSH_PLUGIN_LIST} \${=ZSH_PLUGINS_APPEND})" >> /home/${USERNAME}/.zshrc && \
    echo "DISABLE_AUTO_UPDATE=\"true\"" >> /home/${USERNAME}/.zshrc && \
    echo "DISABLE_UPDATE_PROMPT=\"true\"" >> /home/${USERNAME}/.zshrc && \
    echo "source \$ZSH/oh-my-zsh.sh" >> /home/${USERNAME}/.zshrc && \
    rm install.sh

RUN git config --global init.defaultBranch main && \
    git config --global color.ui auto && \
    git config --global core.autocrlf input && \
    git config --global pull.rebase false && \
    git config --global credential.helper store

CMD ["zsh"]
