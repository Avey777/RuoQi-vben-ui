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

# 从环境变量获取 Docker Hub 用户名
# 使用更严格的方式检查环境变量
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-}"

echo "=== 准备推送 RuoQi Sys Admin 镜像 ==="
echo "本地镜像: $LOCAL_IMAGE_NAME"
echo "标签: $TAG"

# 调试信息：显示环境变量状态
echo "环境变量状态:"
echo "  DOCKER_HUB_USERNAME: ${DOCKER_HUB_USERNAME:-（未设置）}"
echo "  DOCKER_HUB_ACCESS_TOKEN: ${DOCKER_HUB_ACCESS_TOKEN:0:10}...（部分显示）"

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
# 检查必需的环境变量
# -----------------------------
echo "=== 检查环境变量 ==="

# 更严格的检查
if [[ -z "${DOCKER_HUB_USERNAME}" ]] || [[ "${DOCKER_HUB_USERNAME}" == "/" ]]; then
    echo "❌ 错误: DOCKER_HUB_USERNAME 未设置或为空"
    echo ""
    echo "可能的原因:"
    echo "  1. 环境变量 DOCKER_HUB_USERNAME 未设置"
    echo "  2. GitHub Secrets 中未配置 DOCKER_HUB_USERNAME"
    echo "  3. 工作流中未正确传递环境变量"
    echo ""
    echo "当前环境变量:"
    printenv | grep -i docker || echo "  未找到 Docker 相关环境变量"
    exit 1
fi

# 移除可能的前后空格
DOCKER_HUB_USERNAME=$(echo "${DOCKER_HUB_USERNAME}" | xargs)

# 验证用户名格式
if [[ ! "${DOCKER_HUB_USERNAME}" =~ ^[a-z0-9]+(?:[._-][a-z0-9]+)*$ ]]; then
    echo "❌ 错误: DOCKER_HUB_USERNAME 格式无效: ${DOCKER_HUB_USERNAME}"
    echo "提示: Docker Hub 用户名应只包含小写字母、数字、点、下划线和连字符"
    exit 1
fi

if [[ -z "${DOCKER_HUB_ACCESS_TOKEN}" ]]; then
    echo "❌ 错误: DOCKER_HUB_ACCESS_TOKEN 未设置"
    echo ""
    echo "提示: 请检查以下配置:"
    echo "  1. GitHub Secrets 中是否配置了 DOCKER_HUB_ACCESS_TOKEN"
    echo "  2. 工作流中是否传递了该环境变量"
    exit 1
fi

echo "✅ 环境变量检查通过"
echo "用户名: $DOCKER_HUB_USERNAME"
echo "访问令牌: ${DOCKER_HUB_ACCESS_TOKEN:0:10}...（已隐藏）"

# 构建完整的远程镜像名称
REMOTE_IMAGE_NAME="${DOCKER_HUB_USERNAME}/ruoqi-sys-admin:$TAG"
echo "远程镜像: $REMOTE_IMAGE_NAME"

# -----------------------------
# 检查本地镜像是否存在
# -----------------------------
echo "=== 检查本地镜像 ==="
if ! docker image inspect "$LOCAL_IMAGE_NAME" > /dev/null 2>&1; then
    echo "❌ 错误: 本地镜像 $LOCAL_IMAGE_NAME 不存在"
    echo ""
    echo "提示: 请先运行构建脚本:"
    echo "  ./build.sh"
    echo ""
    echo "当前可用镜像:"
    docker images | head -10
    exit 1
fi

echo "✅ 本地镜像存在: $LOCAL_IMAGE_NAME"

# 显示镜像信息
echo "镜像详情:"
docker image inspect "$LOCAL_IMAGE_NAME" --format '
  ID: {{.Id}}
  大小: {{.Size | divide 1000000 }} MB
  创建时间: {{.Created}}
  标签: {{range .RepoTags}}{{.}} {{end}}
' 2>/dev/null || true

# -----------------------------
# 登录 Docker Hub
# -----------------------------
echo "=== 登录 Docker Hub ==="
echo "登录用户: $DOCKER_HUB_USERNAME"

# 测试网络连接
echo "测试 Docker Hub 连接..."
if ! timeout 10s bash -c "curl -s --head https://hub.docker.com | head -1" 2>/dev/null; then
    echo "⚠️  警告: 无法连接到 Docker Hub，可能网络有问题"
fi

echo "$DOCKER_HUB_ACCESS_TOKEN" | docker login \
    -u "$DOCKER_HUB_USERNAME" \
    --password-stdin || {
    echo "❌ Docker Hub 登录失败"
    echo ""
    echo "可能的原因:"
    echo "  1. 用户名或访问令牌错误"
    echo "  2. 访问令牌权限不足（需要 Write 权限）"
    echo "  3. 网络连接问题"
    echo "  4. 访问令牌已过期"
    echo ""
    echo "排查步骤:"
    echo "  1. 在 https://hub.docker.com/settings/security 生成新的访问令牌"
    echo "  2. 确保令牌有读写权限"
    echo "  3. 检查网络连接"
    exit 1
}

echo "✅ Docker Hub 登录成功"

# 验证登录状态
echo "验证登录状态..."
if docker info | grep -q "Username: $DOCKER_HUB_USERNAME"; then
    echo "✅ 登录验证通过"
else
    echo "⚠️  警告: 无法验证登录状态，但继续执行..."
fi

# -----------------------------
# 重新打标签
# -----------------------------
echo "=== 重新打标签 ==="
echo "将本地镜像 $LOCAL_IMAGE_NAME 重命名为 $REMOTE_IMAGE_NAME"

# 检查是否已存在相同标签
if docker image inspect "$REMOTE_IMAGE_NAME" > /dev/null 2>&1; then
    echo "⚠️  注意: 目标标签已存在，将覆盖..."
    docker rmi "$REMOTE_IMAGE_NAME" 2>/dev/null || true
fi

docker tag "$LOCAL_IMAGE_NAME" "$REMOTE_IMAGE_NAME" || {
    echo "❌ 重新打标签失败"
    echo ""
    echo "可能的原因:"
    echo "  1. 本地镜像不存在"
    echo "  2. 镜像名称格式错误"
    exit 1
}

echo "✅ 镜像重命名完成"

# -----------------------------
# 推送镜像
# -----------------------------
echo "=== 开始推送镜像 ==="
echo "推送: $REMOTE_IMAGE_NAME"
echo "开始时间: $(date)"

# 显示推送进度
docker push "$REMOTE_IMAGE_NAME" || {
    echo "❌ 推送失败: $REMOTE_IMAGE_NAME"
    echo ""
    echo "可能的原因:"
    echo "  1. 访问令牌权限不足"
    echo "  2. Docker Hub 仓库不存在或权限不足"
    echo "  3. 镜像名称不符合规范"
    echo "  4. 网络问题"
    echo ""
    echo "检查步骤:"
    echo "  1. 访问 https://hub.docker.com/repositories 确认仓库存在"
    echo "  2. 确认 $DOCKER_HUB_USERNAME 有推送权限"
    echo "  3. 检查网络连接"
    exit 1
}

echo "✅ 镜像推送成功"
echo "完成时间: $(date)"

# 获取镜像摘要信息
echo "=== 镜像摘要 ==="
DIGEST=$(docker image inspect "$REMOTE_IMAGE_NAME" --format='{{index .RepoDigests 0}}' 2>/dev/null || echo "unknown")
echo "镜像摘要: $DIGEST"

# -----------------------------
# 清理临时标签
# -----------------------------
echo "=== 清理临时标签 ==="
docker rmi "$REMOTE_IMAGE_NAME" 2>/dev/null || {
    echo "⚠️  警告: 清理临时标签失败，但继续执行..."
}
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
echo "  标签: $TAG"
echo "  摘要: ${DIGEST:0:50}..."
echo ""
echo "🔗 相关链接:"
echo ""
echo "  Docker Hub 仓库:"
echo "    https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ruoqi-sys-admin"
echo ""
echo "  查看所有标签:"
echo "    https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ruoqi-sys-admin/tags"
echo ""
echo "  查看特定标签:"
echo "    https://hub.docker.com/r/$DOCKER_HUB_USERNAME/ruoqi-sys-admin/tags?name=$TAG"
echo ""
echo "📋 拉取命令:"
echo ""
echo "  docker pull $REMOTE_IMAGE_NAME"
echo ""
echo "⏰ 构建时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
