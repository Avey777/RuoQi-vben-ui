#!/bin/bash
set -euo pipefail

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
LOCAL_IMAGE_NAME="ruoqi-sys-admin"
REMOTE_IMAGE_NAME="avey777/ruoqi-sys-admin:$TAG"  # 硬编码用户名

echo "=== 准备推送镜像 ==="
echo "本地镜像: $LOCAL_IMAGE_NAME"
echo "远程镜像: $REMOTE_IMAGE_NAME"

# -----------------------------
# 调试：显示所有环境变量
# -----------------------------
echo ""
echo "=== 调试信息 ==="
echo "当前目录: $(pwd)"
echo "所有环境变量:"
env | sort
echo ""

# -----------------------------
# 设置 Docker Hub 用户名和访问令牌
# -----------------------------
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-}"

echo "检查环境变量:"
echo "DOCKER_HUB_USERNAME: '$DOCKER_HUB_USERNAME'"
echo "DOCKER_HUB_ACCESS_TOKEN: ${DOCKER_HUB_ACCESS_TOKEN:+已设置}"
echo ""

# 检查访问令牌
if [[ -z "$DOCKER_HUB_ACCESS_TOKEN" ]]; then
    echo "❌ 错误: DOCKER_HUB_ACCESS_TOKEN 未设置"
    echo "请在 GitHub Secrets 中设置 DOCKER_HUB_ACCESS_TOKEN"
    exit 1
fi

# 检查本地镜像
if ! docker image inspect "$LOCAL_IMAGE_NAME" > /dev/null 2>&1; then
    echo "❌ 错误: 本地镜像 $LOCAL_IMAGE_NAME 不存在"
    exit 1
fi

echo "✅ 本地镜像存在"

# -----------------------------
# 重新打标签
# -----------------------------
echo "=== 重新打标签 ==="
docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME" || {
    echo "❌ 重新打标签失败"
    exit 1
}

echo "✅ 标签创建完成"

# -----------------------------
# 推送镜像
# -----------------------------
echo "=== 开始推送镜像 ==="
docker push "$REMOTE_IMAGE_NAME" || {
    echo "❌ 推送失败"
    exit 1
}

echo "✅ 镜像推送成功"
echo "镜像地址: docker.io/$REMOTE_IMAGE_NAME"
