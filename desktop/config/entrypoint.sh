#!/bin/bash
set -e # 如果任何命令失败，则退出脚本

# VNC 密码从环境变量 VNC_PASSWORD 获取
if [ -z "${VNC_PASSWORD}" ]; then
  echo "错误：环境变量 VNC_PASSWORD 未设置。"
  echo "请在运行容器时使用 -e VNC_PASSWORD=yourpassword 来设置密码。"
  exit 1
fi

# --- 修改开始 ---
# 显式指定 vncpasswd 的完整路径
VNCPASSWD_CMD="/usr/bin/vncpasswd"

# 检查命令是否存在 (可选的额外检查)
if [ ! -x "$VNCPASSWD_CMD" ]; then
  echo "错误: 找不到 VNC 密码设置命令 '$VNCPASSWD_CMD'。"
  echo "请检查 tigervnc-standalone-server 是否已在 Dockerfile 中正确安装。"
  exit 1
fi
# --- 修改结束 ---

# 设置 VNC 密码
# 这些操作现在由 appuser 在其家目录中执行，权限足够
# 确保 .vnc 目录存在
mkdir -p ${HOME}/.vnc
# 将密码写入 VNC 密码文件 - 使用绝对路径
echo "${VNC_PASSWORD}" | ${VNCPASSWD_CMD} -f > ${HOME}/.vnc/passwd
# 设置密码文件的权限
chmod 600 ${HOME}/.vnc/passwd

echo "正在以用户 $(whoami) 身份启动 VNC 服务器 (Display ${DISPLAY})..." # 使用 whoami 确认用户
exec /usr/bin/vncserver ${DISPLAY} -fg -localhost no -xstartup ${HOME}/.vnc/xstartup -geometry ${VNC_GEOMETRY} -depth ${VNC_DEPTH} -SecurityTypes VncAuth -passwd ${HOME}/.vnc/passwd