# 使用官方 alpine 镜像作为基础镜像
FROM alpine:3.22.1

# 设置用户ID和组ID环境变量
ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=developer

# 安装开发必需的工具和依赖
# - zsh 系列：现代化的 shell 及其增强插件
# - git 系列：版本控制工具及大文件支持
# - 系统工具：进程监控、网络工具、编辑器等
# - 基础设施：时区数据、证书、SSH 客户端
RUN apk add --no-cache \
  zsh zsh-autosuggestions zsh-completions zsh-syntax-highlighting \
  git git-lfs git-daemon \
  htop strace curl wget neovim nano \
  tzdata ca-certificates openssh-client \
  socat

# 创建非root用户
RUN addgroup -g ${USER_GID} ${USERNAME} && \
  adduser -D -u ${USER_UID} -G ${USERNAME} -s /bin/zsh ${USERNAME}

# 配置 zsh 插件（Alpine 包管理器版本）
RUN echo "source /usr/share/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh" >> /home/${USERNAME}/.zshrc && \
  echo "autoload -U compinit && compinit -C" >> /home/${USERNAME}/.zshrc && \
  echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> /home/${USERNAME}/.zshrc && \
  echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> /home/${USERNAME}/.zshrc

# 安装和配置 Oh My Zsh
RUN wget https://github.com/ohmyzsh/ohmyzsh/raw/master/tools/install.sh && \
  sh install.sh --unattended && \
  mv /root/.oh-my-zsh /home/${USERNAME}/.oh-my-zsh && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.oh-my-zsh && \
  echo "export ZSH=/home/${USERNAME}/.oh-my-zsh" >> /home/${USERNAME}/.zshrc && \
  echo "ZSH_THEME=\"robbyrussell\"" >> /home/${USERNAME}/.zshrc && \
  echo "plugins=(git docker z)" >> /home/${USERNAME}/.zshrc && \
  echo "DISABLE_AUTO_UPDATE=\"true\"" >> /home/${USERNAME}/.zshrc && \
  echo "DISABLE_UPDATE_PROMPT=\"true\"" >> /home/${USERNAME}/.zshrc && \
  echo "source \$ZSH/oh-my-zsh.sh" >> /home/${USERNAME}/.zshrc && \
  rm install.sh

# 配置 Git 全局设置
RUN git config --global init.defaultBranch main && \
  git config --global color.ui auto && \
  git config --global core.autocrlf input && \
  git config --global pull.rebase false && \
  git config --global credential.helper store

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 切换到非root用户
USER ${USERNAME}
WORKDIR /home/${USERNAME}

# 默认启动命令
CMD [ "zsh" ]