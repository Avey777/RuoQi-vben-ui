#!/bin/bash
set -euo pipefail

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
LOCAL_IMAGE_NAME="ruoqi-sys-admin"

# 从多种可能的位置获取 Docker Hub 用户名
# 1. 从环境变量
# 2. 从 .env 文件
# 3. 从脚本参数

# 优先使用环境变量
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-}"

# 如果环境变量为空，尝试从 .env 文件加载
if [[ -z "$DOCKER_HUB_USERNAME" ]] && [[ -f ".env" ]]; then
    echo "尝试从 .env 文件加载环境变量"
    source .env 2>/dev/null || true
fi

# 再次检查
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-}"

echo "=== 准备推送 RuoQi Sys Admin 镜像 ==="
echo "本地镜像: $LOCAL_IMAGE_NAME"
echo "标签: $TAG"

# 如果仍然没有用户名，尝试从 secrets 文件读取（GitHub Actions 场景）
if [[ -z "$DOCKER_HUB_USERNAME" ]] && [[ -f "/github/workflow/secrets.json" ]]; then
    echo "尝试从 GitHub Secrets 读取"
    # 这里可以根据实际情况调整
fi

# 最后检查，如果还是没有就报错
if [[ -z "$DOCKER_HUB_USERNAME" ]]; then
    echo "❌ 错误: DOCKER_HUB_USERNAME 未设置"
    echo ""
    echo "请在以下位置之一设置:"
    echo "  1. 环境变量 DOCKER_HUB_USERNAME"
    echo "  2. .env 文件"
    echo "  3. GitHub Secrets"
    echo ""
    echo "当前环境:"
    printenv | grep -E "(DOCKER|USER)" || echo "未找到相关环境变量"
    exit 1
fi

if [[ -z "$DOCKER_HUB_ACCESS_TOKEN" ]]; then
    echo "❌ 错误: DOCKER_HUB_ACCESS_TOKEN 未设置"
    exit 1
fi

REMOTE_IMAGE_NAME="${DOCKER_HUB_USERNAME}/ruoqi-sys-admin:$TAG"
echo "远程镜像: $REMOTE_IMAGE_NAME"

# 检查本地镜像
if ! docker image inspect "$LOCAL_IMAGE_NAME" > /dev/null 2>&1; then
    echo "❌ 错误: 本地镜像 $LOCAL_IMAGE_NAME 不存在"
    exit 1
fi

echo "✅ 本地镜像存在"

# 登录 Docker Hub
echo "=== 登录 Docker Hub ==="
echo "$DOCKER_HUB_ACCESS_TOKEN" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin || {
    echo "❌ Docker Hub 登录失败"
    exit 1
}

echo "✅ Docker Hub 登录成功"

# 重新打标签
echo "=== 重新打标签 ==="
docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME" || {
    echo "❌ 重新打标签失败"
    exit 1
}

# 推送镜像
echo "=== 开始推送镜像 ==="
docker push "$REMOTE_IMAGE_NAME" || {
    echo "❌ 推送失败"
    exit 1
}

echo "✅ 镜像推送成功"

# 清理
docker rmi "$REMOTE_IMAGE_NAME" 2>/dev/null || true

echo ""
echo "🎉 推送完成: $REMOTE_IMAGE_NAME"
