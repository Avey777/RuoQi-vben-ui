#!/bin/bash
set -euo pipefail

# 基本配置
IMAGE_NAME="ruoqi-sys-admin"
DOCKERFILE_PATH="$(dirname "$0")/Dockerfile"
PROJECT_ROOT="$(dirname "$0")/../.."

echo "=== 构建 RuoQi Sys Admin Docker 镜像 ==="
echo "镜像名称: $IMAGE_NAME"
echo "Dockerfile: $DOCKERFILE_PATH"
echo "项目根目录: $PROJECT_ROOT"

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装"
    exit 1
fi

# 检查项目根目录
if [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
    echo "错误: 未找到项目根目录"
    exit 1
fi

# 构建镜像
cd "$PROJECT_ROOT" || exit 1

echo "开始构建 Docker 镜像..."
if docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .; then
    echo "✅ Docker 镜像构建成功: $IMAGE_NAME"
else
    echo "❌ Docker 镜像构建失败"
    exit 1
fi

# 显示构建结果
echo ""
echo "=== 构建完成 ==="
echo "镜像信息:"
docker images "$IMAGE_NAME"

echo ""
echo "后续步骤:"
echo "1. 测试运行: docker run -d -p 8081:8081 --name ruoqi-test $IMAGE_NAME"
echo "2. 推送到 Docker Hub: ./scripts/ruoqi-sys-admin/docker_push.sh"
echo ""
