# 使用官方 alpine 镜像作为基础镜像
FROM alpine:3.22.1

# 设置用户ID和组ID环境变量
ARG USER_UID=1000
ARG USER_GID=1000

# 安装必要工具
RUN apk add --no-cache \
  bash \
  git

# 创建非root用户
RUN addgroup -g ${USER_GID} developer && \
  adduser -D -u ${USER_UID} -G developer -s /bin/bash developer

# 切换到非root用户
USER developer
WORKDIR /home/developer

# 默认启动命令
CMD [ "bash" ]