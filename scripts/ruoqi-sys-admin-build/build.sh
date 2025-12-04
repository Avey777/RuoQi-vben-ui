#!/bin/bash
set -euo pipefail

# -----------------------------
# 脚本配置
# -----------------------------
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
ROOT_DIR="${SCRIPT_DIR}/../.."
LOG_FILE="${SCRIPT_DIR}/build.log"
IMAGE_NAME="ruoqi-sys-admin"
CONTAINER_NAME="ruoqi-sys-admin-container"
PORT=8010

# -----------------------------
# 颜色定义
# -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# -----------------------------
# 日志函数
# -----------------------------
log() {
    local level="$1"
    local color="$2"
    local message="$3"
    echo -e "${color}[${level}]${NC} ${message}" | tee -a "$LOG_FILE"
}

log_info() {
    log "INFO" "$BLUE" "$1"
}

log_success() {
    log "SUCCESS" "$GREEN" "$1"
}

log_warning() {
    log "WARNING" "$YELLOW" "$1"
}

log_error() {
    log "ERROR" "$RED" "$1"
}

# -----------------------------
# 显示帮助信息
# -----------------------------
show_help() {
    echo "RuoQi Sys Admin 构建工具"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --clean          清理现有容器和镜像"
    echo "  --no-deps        不安装依赖"
    echo "  --no-run         构建后不运行容器"
    echo "  --port=PORT      指定容器端口（默认: 8010）"
    echo "  --help, -h       显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                 # 完整构建流程"
    echo "  $0 --no-run        # 只构建，不运行"
    echo "  $0 --port=8080     # 指定端口运行"
    echo ""
    echo "后续步骤:"
    echo "  构建完成后，使用 push.sh 推送到 Docker Hub"
    echo "  ./push.sh [TAG]"
}

# -----------------------------
# 解析参数
# -----------------------------
CLEANUP=false
INSTALL_DEPS=true
RUN_CONTAINER=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEANUP=true
            shift
            ;;
        --no-deps)
            INSTALL_DEPS=false
            shift
            ;;
        --no-run)
            RUN_CONTAINER=false
            shift
            ;;
        --port=*)
            PORT="${1#*=}"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# -----------------------------
# 开始构建
# -----------------------------
echo ""
echo "========================================"
log_info "开始构建 RuoQi Sys Admin"
echo "========================================"
echo ""
log_info "项目根目录: $ROOT_DIR"
log_info "镜像名称: $IMAGE_NAME"
log_info "容器端口: $PORT:8081"
log_info "日志文件: $LOG_FILE"
echo ""

# 清空日志文件
> "$LOG_FILE"

# -----------------------------
# 清理现有容器和镜像
# -----------------------------
if [ "$CLEANUP" = true ]; then
    log_info "清理现有资源..."

    # 停止并删除容器
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_info "停止容器: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
        log_info "删除容器: $CONTAINER_NAME"
        docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true
    fi

    # 删除镜像
    if docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
        log_info "删除镜像: $IMAGE_NAME"
        docker rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
    fi
fi

# -----------------------------
# 检查依赖
# -----------------------------
log_info "检查依赖..."

if ! command -v docker &> /dev/null; then
    log_error "Docker 未安装"
    exit 1
fi

if [[ ! -f "$ROOT_DIR/package.json" ]]; then
    log_error "未找到项目根目录"
    exit 1
fi

log_success "依赖检查通过"

# -----------------------------
# 安装项目依赖
# -----------------------------
if [ "$INSTALL_DEPS" = true ]; then
    log_info "安装项目依赖..."

    cd "$ROOT_DIR" || {
        log_error "无法切换到项目根目录"
        exit 1
    }

    if pnpm install 2>&1 | tee -a "$LOG_FILE"; then
        log_success "依赖安装成功"
    else
        log_error "依赖安装失败"
        exit 1
    fi
else
    log_warning "跳过依赖安装"
fi

# -----------------------------
# 构建 Docker 镜像
# -----------------------------
log_info "构建 Docker 镜像..."
log_info "使用 Dockerfile: $SCRIPT_DIR/Dockerfile"

cd "$ROOT_DIR" || {
    log_error "无法切换到项目根目录"
    exit 1
}

if docker build -t "$IMAGE_NAME" -f "$SCRIPT_DIR/Dockerfile" . 2>&1 | tee -a "$LOG_FILE"; then
    log_success "Docker 镜像构建成功"
else
    log_error "Docker 镜像构建失败"
    exit 1
fi

# -----------------------------
# 运行容器（可选）
# -----------------------------
if [ "$RUN_CONTAINER" = true ]; then
    log_info "启动容器..."

    # 停止现有容器（如果有）
    docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
    docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true

    if docker run -d \
        --name "$CONTAINER_NAME" \
        -p "$PORT:8081" \
        "$IMAGE_NAME" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "容器启动成功"

        sleep 2
        log_info "容器状态:"
        docker ps --filter "name=$CONTAINER_NAME"

        log_info "访问地址: http://localhost:$PORT"
    else
        log_error "容器启动失败"
        exit 1
    fi
else
    log_warning "跳过容器运行"
fi

# -----------------------------
# 构建完成
# -----------------------------
echo ""
echo "========================================"
log_success "RuoQi Sys Admin 构建完成！"
echo "========================================"
echo ""
log_info "生成的镜像: $IMAGE_NAME"
echo ""
log_info "后续步骤:"
echo ""
log_info "1. 测试镜像:"
log_info "   docker run -d -p $PORT:8081 --name test-$IMAGE_NAME $IMAGE_NAME"
echo ""
log_info "2. 推送到 Docker Hub:"
log_info "   # 设置环境变量"
log_info "   export DOCKER_HUB_USERNAME=你的用户名"
log_info "   export DOCKER_HUB_ACCESS_TOKEN=你的访问令牌"
log_info ""
log_info "   # 推送 latest 标签"
log_info "   ./push.sh"
log_info ""
log_info "   # 推送指定标签"
log_info "   ./push.sh v1.0.0"
echo ""
log_info "3. 或者推送多个标签:"
log_info "   ./push-multi.sh"
echo ""
echo "========================================"
