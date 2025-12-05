#!/bin/bash
set -euo pipefail

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
LOCAL_IMAGE_NAME="ruoqi-sys-admin"
REMOTE_IMAGE_NAME="avey777/ruoqi-sys-admin:$TAG"  # 直接硬编码用户名

echo "=== 准备推送镜像 ==="
echo "本地镜像: $LOCAL_IMAGE_NAME"
echo "远程镜像: $REMOTE_IMAGE_NAME"

# -----------------------------
# 检查本地镜像是否存在
# -----------------------------
if ! docker image inspect "$LOCAL_IMAGE_NAME" > /dev/null 2>&1; then
    echo "错误: 本地镜像 $LOCAL_IMAGE_NAME 不存在，请先构建镜像"
    exit 1
fi

# -----------------------------
# 加载环境变量文件（如果存在）
# -----------------------------
ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
    echo "加载环境变量文件: $ENV_FILE"
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
fi

# -----------------------------
# 设置 Docker Hub 用户名和访问令牌
# -----------------------------
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"  # 提供默认值
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-}"

# 检查访问令牌（用户名可以有默认值，但令牌必须提供）
if [[ -z "$DOCKER_HUB_ACCESS_TOKEN" ]]; then
    echo "错误: DOCKER_HUB_ACCESS_TOKEN 未设置"
    echo "请在 GitHub Secrets 中设置 DOCKER_HUB_ACCESS_TOKEN"
    exit 1
fi

# -----------------------------
# 调试信息
# -----------------------------
echo "=== 环境变量检查 ==="
echo "用户名: ${DOCKER_HUB_USERNAME}"
echo "访问令牌: ${DOCKER_HUB_ACCESS_TOKEN:+已设置（隐藏）}"
echo "远程镜像名称: $REMOTE_IMAGE_NAME"

# -----------------------------
# 登录 Docker Hub
# -----------------------------
echo "=== 登录 Docker Hub ==="
echo "$DOCKER_HUB_ACCESS_TOKEN" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin || {
    echo "Docker Hub 登录失败，请检查用户名/Access Token 或网络"
    exit 1
}
echo "✅ Docker Hub 登录成功"

# -----------------------------
# 重新打标签（如果需要）
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
    echo "推送失败: $REMOTE_IMAGE_NAME"
    echo "可能原因:"
    echo "1. Access Token 权限不足（需要 Write 权限）"
    echo "2. 镜像命名空间不匹配（登录用户与镜像用户名不同）"
    echo "3. 网络问题"
    exit 1
}

echo "=== 镜像推送成功 ==="
echo "镜像地址: docker.io/$REMOTE_IMAGE_NAME"

# -----------------------------
# 清理临时标签
# -----------------------------
echo "=== 清理临时标签 ==="
docker rmi "$REMOTE_IMAGE_NAME" 2>/dev/null || {
    echo "⚠️  清理标签失败，继续执行"
}

echo ""
echo "========================================"
echo "🎉 推送完成!"
echo "========================================"
