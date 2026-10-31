FROM ubuntu:24.04

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

RUN set -eux; \
    # 检查 GID 是否存在
    if getent group "${USER_GID}" >/dev/null; then \
        OLD_GROUP=$(getent group "${USER_GID}" | cut -d: -f1); \
        groupmod -n "${USERNAME}" "${OLD_GROUP}"; \
    else \
        groupadd --gid ${USER_GID} ${USERNAME}; \
    fi; \
    # 检查 UID 是否存在
    if getent passwd "${USER_UID}" >/dev/null; then \
        OLD_USER=$(getent passwd "${USER_UID}" | cut -d: -f1); \
        usermod -l "${USERNAME}" "${OLD_USER}"; \
        usermod -d "/home/${USERNAME}" -m "${USERNAME}"; \
        usermod -g "${USERNAME}" "${USERNAME}"; \
    else \
        useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/zsh ${USERNAME}; \
    fi

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY scripts/default-text-editor /usr/local/bin/default-text-editor
RUN chmod +x /usr/local/bin/default-text-editor

COPY scripts/emudhra.test.sh /tmp/emudhra.test.sh
RUN chmod 755 /tmp/emudhra.test.sh

ENV VISUAL=default-text-editor
ENV EDITOR=default-text-editor
ENV ZSH_PLUGIN_LIST="git"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# eMudhra fix
RUN /tmp/emudhra.test.sh

RUN wget https://github.com/ohmyzsh/ohmyzsh/raw/master/tools/install.sh && \
  sh install.sh --unattended --keep-zshrc && \
  echo "export ZSH=/home/${USERNAME}/.oh-my-zsh" >> /home/${USERNAME}/.zshrc && \
  echo "ZSH_THEME=\"robbyrussell\"" >> /home/${USERNAME}/.zshrc && \
  echo "plugins=(\${=ZSH_PLUGIN_LIST} \${=ZSH_PLUGINS_APPEND})" >> /home/${USERNAME}/.zshrc && \
  echo "DISABLE_AUTO_UPDATE=\"true\"" >> /home/${USERNAME}/.zshrc && \
  echo "DISABLE_UPDATE_PROMPT=\"true\"" >> /home/${USERNAME}/.zshrc && \
  echo "source \$ZSH/oh-my-zsh.sh" >> /home/${USERNAME}/.zshrc && \
  rm install.sh

# 设置默认终端为zsh
# RUN chsh -s $(which zsh)
ENV SHELL=/bin/zsh

RUN git config --global init.defaultBranch main && \
  git config --global color.ui auto && \
  git config --global core.autocrlf input && \
  git config --global pull.rebase false && \
  git config --global credential.helper store

CMD ["zsh"]
