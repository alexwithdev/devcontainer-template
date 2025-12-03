FROM ghcr.io/alexwithdev/devcontainer-template/base:latest

# 设置用户参数，默认为当前用户
ARG USERNAME=developer

# 切换到 root 用户进行安装
USER root

RUN apk add --no-cache \
    go

# 切换回指定用户
USER ${USERNAME}

RUN go install github.com/go-delve/delve/cmd/dlv@v1.25.2 \
    && echo 'export PATH="$PATH:$(go env GOPATH)/bin"' >> ~/.zshrc

# 默认启动命令
CMD [ "zsh" ]