# 使用 Ubuntu LTS 版本作为基础镜像
FROM ghcr.io/alexwithdev/devcontainer-template/desktop:latest

# 以 root 身份执行系统级操作
USER root

# 更新包列表并安装必要的软件
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    # Java 运行时（Gradle 8.x / AGP 8.x 要求 JDK 17+）
    openjdk-17-jdk \
    # Android Studio 音频依赖
    libpulse0 \
    # Vulkan / ANGLE GPU 加速
    libvulkan1 mesa-vulkan-drivers libgles2 libegl1 mesa-utils \
    # 模拟器 X11 扩展依赖
    libxtst6 libxrender1 libxi6 libxext6 \
    # 模拟器其他运行时依赖
    libpci3 libsdl2-2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置参数
ARG ANDROID_STUDIO_URL="https://edgedl.me.gvt1.com/android/studio/ide-zips/2025.3.3.6/android-studio-panda3-linux.tar.gz"
# 定义用户名和家目录，方便引用
ARG USER_NAME=developer
ARG USER_HOME=/home/${USER_NAME}

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 下载并设置所有权和权限
# 注意：这里仍然以 root 身份下载和设置权限，确保文件能正确放置
RUN wget -q $ANDROID_STUDIO_URL -O /tmp/android-studio.tar.gz \
    && tar -xzf /tmp/android-studio.tar.gz -C /opt/ \
    && rm /tmp/android-studio.tar.gz \
    && chown -R $USER_NAME:$USER_NAME /opt/android-studio

# Create Android Studio wrapper script
COPY scripts/android-studio /usr/local/bin/android-studio
RUN chmod +x /usr/local/bin/android-studio \
    && mkdir -p /home/${USER_NAME}/Android \
    && mkdir -p /home/${USER_NAME}/.android \
    && mkdir -p /home/${USER_NAME}/Projects \
    && mkdir -p /home/${USER_NAME}/.gradle \
    && chown -R ${USER_NAME}:${USER_NAME} /home/${USER_NAME}/Android \
    /home/${USER_NAME}/.android \
    /home/${USER_NAME}/Projects \
    /home/${USER_NAME}/.gradle

# 暴露 VNC 端口
EXPOSE 5901

# 切换到非 root 用户
USER ${USER_NAME}

# 设置工作目录为用户家目录
WORKDIR ${USER_HOME}

# 设置环境变量
ENV EXECUTABLE="/usr/local/bin/android-studio" \
    VNC_GEOMETRY=2560x1440

RUN mkdir -p $HOME/Projects

# 设置容器启动时执行的入口点脚本
# 这个脚本现在会以 ${USER_NAME} 的身份运行
# ENTRYPOINT ["/entrypoint.sh"]
CMD [ "/entrypoint.sh" ]