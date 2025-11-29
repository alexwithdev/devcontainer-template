FROM ghcr.io/alexwithdev/devcontainer-template/base:latest

# 设置用户参数，默认为当前用户
ARG USERNAME=developer

# 切换到 root 用户进行安装
USER root

RUN apk add --no-cache \
    python3 py3-pip 

# 切换回指定用户
USER ${USERNAME}

# 默认启动命令
CMD [ "zsh" ]