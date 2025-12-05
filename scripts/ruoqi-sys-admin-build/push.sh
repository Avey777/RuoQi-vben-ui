#!/bin/bash
set -euo pipefail

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
LOCAL_IMAGE_NAME="ruoqi-sys-admin"

# 从环境变量获取（兼容不同命名）
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-${DOCKER_HUB_USER:-}}"
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-${DOCKER_HUB_TOKEN:-}}"

echo "=== 准备推送 RuoQi Sys Admin 镜像 ==="
echo "标签: $TAG"

# 调试信息
echo "🔍 调试信息:"
echo "用户名: ${DOCKER_HUB_USERNAME:-未设置}"
echo "访问令牌: ${DOCKER_HUB_ACCESS_TOKEN:+已设置（隐藏）}"

# 检查环境变量
if [[ -z "$DOCKER_HUB_USERNAME" ]]; then
    echo "❌ 错误: DOCKER_HUB_USERNAME 未设置"
    echo ""
    echo "当前环境变量:"
    printenv | grep -E "(DOCKER|USER)" || echo "未找到相关环境变量"
    echo ""
    echo "请检查 GitHub Secrets 配置:"
    echo "1. 访问 https://github.com/${{ github.repository }}/settings/secrets/actions"
    echo "2. 确保已配置 DOCKER_HUB_USERNAME 和 DOCKER_HUB_ACCESS_TOKEN"
    exit 1
fi

if [[ -z "$DOCKER_HUB_ACCESS_TOKEN" ]]; then
    echo "❌ 错误: DOCKER_HUB_ACCESS_TOKEN 未设置"
    exit 1
fi

# 构建完整镜像名称
REMOTE_IMAGE_NAME="${DOCKER_HUB_USERNAME}/ruoqi-sys-admin:$TAG"
echo "远程镜像: $REMOTE_IMAGE_NAME"

# 检查本地镜像
if ! docker image inspect "$LOCAL_IMAGE_NAME" > /dev/null 2>&1; then
    echo "❌ 错误: 本地镜像 $LOCAL_IMAGE_NAME 不存在"
    echo "请先运行构建脚本: ./build.sh"
    exit 1
fi

echo "✅ 本地镜像存在"

# -----------------------------
# 登录 Docker Hub
# -----------------------------
echo "=== 登录 Docker Hub ==="
echo "$DOCKER_HUB_ACCESS_TOKEN" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin || {
    echo "Docker Hub 登录失败，请检查用户名/Access Token 或网络"
    exit 1
}

echo "✅ Docker Hub 登录成功"

# 重新打标签
echo "=== 重新打标签 ==="
docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME" || {
    echo "❌ 重新打标签失败"
    exit 1
}

echo "✅ 标签创建完成"

# 推送镜像
echo "=== 开始推送镜像 ==="
docker push "$REMOTE_IMAGE_NAME" || {
    echo "❌ 推送失败"
    echo "可能原因:"
    echo "1. 仓库权限不足"
    echo "2. 镜像名称格式错误"
    echo "3. 网络问题"
    exit 1
}

echo "✅ 镜像推送成功"

# 清理临时标签
echo "=== 清理临时标签 ==="
docker rmi "$REMOTE_IMAGE_NAME" 2>/dev/null || {
    echo "⚠️  清理标签失败，继续执行"
}

echo ""
echo "========================================"
echo "🎉 推送完成!"
echo "========================================"
echo ""
echo "📦 镜像: $REMOTE_IMAGE_NAME"
echo ""
echo "🔗 Docker Hub 链接:"
echo "   https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ruoqi-sys-admin"
echo ""
echo "📋 拉取命令:"
echo "   docker pull $REMOTE_IMAGE_NAME"
echo "========================================"
