#!/bin/bash
set -euo pipefail

# -----------------------------
# 脚本配置
# -----------------------------
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
ROOT_DIR="${SCRIPT_DIR}/../.."

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
LOCAL_IMAGE_NAME="ruoqi-sys-admin"
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"
REMOTE_IMAGE_NAME="${DOCKER_HUB_USERNAME}/ruoqi-sys-admin:$TAG"

echo "=== 准备推送 RuoQi Sys Admin 镜像 ==="
echo "本地镜像: $LOCAL_IMAGE_NAME"
echo "远程镜像: $REMOTE_IMAGE_NAME"

# -----------------------------
# 显示帮助信息
# -----------------------------
show_help() {
    echo "RuoQi Sys Admin 镜像推送工具"
    echo ""
    echo "用法: $0 [TAG]"
    echo ""
    echo "参数:"
    echo "  TAG     镜像标签（默认: latest）"
    echo ""
    echo "环境变量:"
    echo "  DOCKER_HUB_USERNAME      Docker Hub 用户名（必需）"
    echo "  DOCKER_HUB_ACCESS_TOKEN  Docker Hub 访问令牌（必需）"
    echo ""
    echo "示例:"
    echo "  $0                        # 推送 latest 标签"
    echo "  $0 v1.0.0                 # 推送 v1.0.0 标签"
    echo "  $0 20231215-abc123        # 推送指定标签"
    echo ""
    echo "GitHub Actions 使用:"
    echo "  - 在仓库 Settings -> Secrets 中设置:"
    echo "    - DOCKER_HUB_USERNAME"
    echo "    - DOCKER_HUB_ACCESS_TOKEN"
}

# 显示帮助
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

# -----------------------------
# 检查本地镜像是否存在
# -----------------------------
echo "=== 检查本地镜像 ==="
if ! docker image inspect "$LOCAL_IMAGE_NAME" > /dev/null 2>&1; then
    echo "错误: 本地镜像 $LOCAL_IMAGE_NAME 不存在"
    echo "提示: 请先运行构建脚本: ./build.sh"
    exit 1
fi

echo "✅ 本地镜像存在: $LOCAL_IMAGE_NAME"

# -----------------------------
# 检查必需的环境变量
# -----------------------------
echo "=== 检查环境变量 ==="

if [[ -z "$DOCKER_HUB_USERNAME" ]]; then
    echo "错误: DOCKER_HUB_USERNAME 未设置"
    echo "提示: 请设置环境变量或通过 .env 文件配置"
    exit 1
fi

if [[ -z "$DOCKER_HUB_ACCESS_TOKEN" ]]; then
    echo "错误: DOCKER_HUB_ACCESS_TOKEN 未设置"
    echo "提示: 请设置环境变量或通过 .env 文件配置"
    exit 1
fi

echo "✅ 环境变量检查通过"
echo "用户名: $DOCKER_HUB_USERNAME"
echo "访问令牌: ${DOCKER_HUB_ACCESS_TOKEN:0:10}...（已隐藏）"

# -----------------------------
# 登录 Docker Hub
# -----------------------------
echo "=== 登录 Docker Hub ==="
echo "$DOCKER_HUB_ACCESS_TOKEN" | docker login \
    -u "$DOCKER_HUB_USERNAME" \
    --password-stdin || {
    echo "❌ Docker Hub 登录失败"
    echo "可能的原因:"
    echo "  1. 用户名或访问令牌错误"
    echo "  2. 访问令牌权限不足（需要 Write 权限）"
    echo "  3. 网络连接问题"
    exit 1
}

echo "✅ Docker Hub 登录成功"

# -----------------------------
# 重新打标签
# -----------------------------
echo "=== 重新打标签 ==="
echo "将本地镜像 $LOCAL_IMAGE_NAME 重命名为 $REMOTE_IMAGE_NAME"

docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME" || {
    echo "❌ 重新打标签失败"
    exit 1
}

echo "✅ 镜像重命名完成"

# -----------------------------
# 推送镜像
# -----------------------------
echo "=== 开始推送镜像 ==="
echo "推送: $REMOTE_IMAGE_NAME"

docker push "$REMOTE_IMAGE_NAME" || {
    echo "❌ 推送失败: $REMOTE_IMAGE_NAME"
    echo "可能的原因:"
    echo "  1. 访问令牌权限不足"
    echo "  2. Docker Hub 仓库不存在或权限不足"
    echo "  3. 镜像名称不符合规范"
    exit 1
}

echo "✅ 镜像推送成功"

# -----------------------------
# 清理临时标签
# -----------------------------
echo "=== 清理临时标签 ==="
docker rmi "$REMOTE_IMAGE_NAME" 2>/dev/null || true
echo "✅ 临时标签已清理"

# -----------------------------
# 推送成功信息
# -----------------------------
echo ""
echo "========================================"
echo "🎉 RuoQi Sys Admin 镜像推送完成！"
echo "========================================"
echo ""
echo "📦 镜像信息:"
echo ""
echo "  本地镜像: $LOCAL_IMAGE_NAME"
echo "  远程镜像: $REMOTE_IMAGE_NAME"
echo ""
echo "🔗 相关链接:"
echo ""
echo "  Docker Hub 仓库:"
echo "    https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ruoqi-sys-admin"
echo ""
echo "  查看所有标签:"
echo "    https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ruoqi-sys-admin/tags"
echo ""
echo "📋 拉取命令:"
echo ""
echo "  docker pull $REMOTE_IMAGE_NAME"
echo ""
echo "========================================"
