#!/bin/bash
set -euo pipefail

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
IMAGE_NAME="avey777/ruoqi-sys-admin:$TAG"  # 硬编码用户名到镜像名称

echo "=== 准备推送镜像 ==="
echo "镜像标签: $IMAGE_NAME"

# -----------------------------
# 检查本地镜像是否存在
# -----------------------------
if ! docker image inspect "ruoqi-sys-admin" > /dev/null 2>&1; then
    echo "错误: 本地镜像 ruoqi-sys-admin 不存在，请先构建镜像"
    exit 1
fi

# -----------------------------
# 登录 Docker Hub（直接从环境变量读取）
# -----------------------------
echo "=== 登录 Docker Hub ==="
echo "${{ secrets.DOCKER_HUB_ACCESS_TOKEN }}" | docker login -u "${{ secrets.DOCKER_HUB_USERNAME }}" --password-stdin || {
    echo "Docker Hub 登录失败"
    exit 1
}
echo "✅ Docker Hub 登录成功"

# -----------------------------
# 重新打标签（重要！）
# -----------------------------
echo "=== 重新打标签 ==="
docker tag "ruoqi-sys-admin" "$IMAGE_NAME" || {
    echo "重新打标签失败"
    exit 1
}
echo "✅ 标签创建完成"

# -----------------------------
# 推送镜像
# -----------------------------
echo "=== 开始推送镜像 ==="
docker push "$IMAGE_NAME" || {
    echo "推送失败: $IMAGE_NAME"
    exit 1
}

echo "=== 镜像推送成功 ==="
echo "镜像地址: docker.io/$IMAGE_NAME"
