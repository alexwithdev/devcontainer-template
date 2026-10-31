FROM ghcr.io/alexwithdev/devcontainer-template/base:main

# 设置用户参数，默认为当前用户
ARG USERNAME=developer

# 切换到 root 用户进行安装
USER root

RUN apk add --no-cache \
    'python3>=3.14.9' py3-pip 

# 切换回指定用户
USER ${USERNAME}

# eMudhra fix
COPY scripts/emudhra.test.py /tmp/emudhra.test.py
RUN python3 /tmp/emudhra.test.py

ENV ZSH_PLUGINS_APPEND="python pip"

# 默认启动命令
CMD [ "zsh" ]