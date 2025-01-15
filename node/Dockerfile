# 使用官方 Node.js 镜像作为基础镜像
FROM node:20.18.1-alpine3.21

# 设置工作目录
WORKDIR /code

# 安装必要工具
RUN apk add --no-cache \
  bash \
  git

# 默认启动命令
CMD [ "bash" ]