# 使用 Ubuntu LTS 版本作为基础镜像
FROM ubuntu:22.04

# 以 root 身份执行系统级操作
USER root

# 更新包列表并安装必要的软件
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tigervnc-standalone-server \
    tigervnc-tools \
    fluxbox \
    xterm \
    wget \
    curl \
    libfuse2 \
    net-tools \
    ca-certificates \
    unzip \
    moreutils \
    ibus \               
    ibus-libpinyin \          
    language-pack-zh-hans \   
    dbus-x11 \                  
    fonts-noto-cjk fonts-noto-cjk-extra \
    nano \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 设置参数
# 定义用户名和家目录，方便引用
ARG USER_NAME=developer
ARG USER_HOME=/home/${USER_NAME}
# 固定 UID/GID 为 1000，这是许多基础镜像中第一个非 root 用户的常见选择
ARG USER_UID=1000
ARG USER_GID=1000

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive \
    # 将 USER 和 HOME 设置为我们创建的非 root 用户
    USER=${USER_NAME} \
    HOME=${USER_HOME} \
    DISPLAY=:1 \
    VNC_GEOMETRY=1920x1080 \
    VNC_DEPTH=24



# 创建用户组和用户，并指定 UID/GID
RUN groupadd --gid ${USER_GID} ${USER_NAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} --create-home --shell /bin/bash ${USER_NAME} && \
    # 创建 VNC 配置目录并立即设置正确的所有权
    mkdir -p ${USER_HOME}/.vnc && \
    chown -R ${USER_NAME}:${USER_NAME} ${USER_HOME}

RUN wget https://github.com/xexpanderx/Fluxbox-themes/archive/refs/heads/master.zip -O fluxbox-theme.zip  \ 
    && unzip fluxbox-theme.zip Fluxbox-themes-master/Zombie/*

RUN mkdir -p ${USER_HOME}/.themes \
    && mkdir -p ${USER_HOME}/.icons \
    && mkdir -p ${USER_HOME}/.fluxbox/styles \ 
    && cd Fluxbox-themes-master/Zombie/ \
    && mv Gtk/Qogir-ubuntu-zombie-dark/ ${USER_HOME}/.themes/ \
    && mv Icons/* ${USER_HOME}/.icons/ \
    && mv 'Fluxbox style/Zombie' ${USER_HOME}/.fluxbox/styles/ \
    && chown -R "${USER_NAME}:${USER_NAME}" ${USER_HOME}/.fluxbox \
    && cd ../../ \
    && rm fluxbox-theme.zip \
    && rm -rf ./Fluxbox-themes-master

COPY --chown=${USER_NAME}:${USER_NAME} config/fluxbox/init ${USER_HOME}/.fluxbox/init
COPY --chown=${USER_NAME}:${USER_NAME} config/fluxbox/menu ${USER_HOME}/.fluxbox/menu
COPY --chown=${USER_NAME}:${USER_NAME} config/fluxbox/overlay ${USER_HOME}/.fluxbox/overlay
# 复制 VNC 启动脚本 (xstartup) 并设置所有权和权限
COPY --chown=${USER_NAME}:${USER_NAME} config/xstartup ${USER_HOME}/.vnc/xstartup
# 复制入口点脚本，它将被非 root 用户执行，所以放在根目录或其他地方都可以
COPY config/entrypoint.sh /entrypoint.sh
RUN chmod +x ${USER_HOME}/.vnc/xstartup && \
    chmod +x /entrypoint.sh

# 配置输入法环境变量
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8 \
    GTK_IM_MODULE=ibus \
    XMODIFIERS=@im=ibus \
    QT_IM_MODULE=ibus

# 暴露 VNC 端口
EXPOSE 5901

# 切换到非 root 用户
USER ${USER_NAME}

# 设置工作目录为用户家目录
WORKDIR ${USER_HOME}

# 设置容器启动时执行的入口点脚本
# 这个脚本现在会以 ${USER_NAME} 的身份运行
# ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/entrypoint.sh" ]