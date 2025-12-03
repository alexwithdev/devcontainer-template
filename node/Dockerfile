# 多阶段构建 - 第一阶段从node:alpine提取Node.js
FROM node:20.18.1-alpine AS node-source

# 第二阶段 - 使用自定义基础镜像
FROM ghcr.io/alexwithdev/devcontainer-template/base:latest

# 设置用户参数，默认为当前用户
ARG USERNAME=developer
ARG NODE_VERSION=20.18.1

# 切换到 root 用户进行安装
USER root

# 安装必要工具
RUN apk add --no-cache \
  bash \
  libstdc++  # Node.js运行需要

# 创建必要的目录
RUN mkdir -p /usr/local/lib/node_modules /usr/local/include/node

# 从node:alpine镜像中复制Node.js，并设置所有者
COPY --from=node-source /usr/local/bin/node /usr/local/bin/
COPY --from=node-source /usr/local/include/node /usr/local/include/node
COPY --from=node-source --chown=${USERNAME}:${USERNAME} /usr/local/lib/node_modules /usr/local/lib/node_modules

# 创建必要的软链接并设置权限
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
  && ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  && chown -h ${USERNAME}:${USERNAME} /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/nodejs \
  && chmod +x /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx

# 验证安装
RUN su ${USERNAME} -c "node --version && npm --version"

# 设置npm全局安装目录
RUN mkdir -p /home/${USERNAME}/.npm-global && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.npm-global

# 切换回指定用户
USER ${USERNAME}

# 配置npm使用用户目录
ENV NPM_CONFIG_PREFIX=/home/${USERNAME}/.npm-global
ENV PATH="/home/${USERNAME}/.npm-global/bin:${PATH}"

# 全局安装pnpm
RUN npm i -g pnpm

# 配置pnpm store目录
RUN mkdir -p /home/${USERNAME}/.pnpm-store && \
  pnpm config set store-dir /home/${USERNAME}/.pnpm-store

ENV ZSH_PLUGINS_APPEND="node npm"

# 默认启动命令
CMD [ "zsh" ]