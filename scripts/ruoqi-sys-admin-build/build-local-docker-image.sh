#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR="${SCRIPT_DIR}/../.."  # 项目根目录
LOG_FILE="${SCRIPT_DIR}/build.log"
ERROR=""
IMAGE_NAME="ruoqi-sys-admin"
CONTAINER_NAME="ruoqi-sys-admin-container"
PORT=8010

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "${LOG_FILE}"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "${LOG_FILE}"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "${LOG_FILE}"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "${LOG_FILE}"
}

# 清理现有容器和镜像
cleanup() {
    log_info "清理现有容器和镜像..."

    # 停止并删除容器
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        log_info "停止容器: ${CONTAINER_NAME}"
        docker stop "${CONTAINER_NAME}" >/dev/null 2>&1
        log_info "删除容器: ${CONTAINER_NAME}"
        docker rm "${CONTAINER_NAME}" >/dev/null 2>&1
    fi

    # 删除镜像
    if docker images --format '{{.Repository}}' | grep -q "^${IMAGE_NAME}$"; then
        log_info "删除镜像: ${IMAGE_NAME}"
        docker rmi "${IMAGE_NAME}" >/dev/null 2>&1
    fi
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."

    # 检查 Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker 未安装，请先安装 Docker"
        return 1
    fi

    # 检查是否在项目根目录下存在 package.json
    if [[ ! -f "${ROOT_DIR}/package.json" ]]; then
        log_error "未找到项目根目录，请确认目录结构"
        return 1
    fi

    log_success "依赖检查通过"
    return 0
}

# 安装项目依赖
install_dependencies() {
    log_info "安装项目依赖..."

    cd "${ROOT_DIR}" || {
        log_error "无法切换到项目根目录: ${ROOT_DIR}"
        return 1
    }

    if ! pnpm install 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "依赖安装失败"
        return 1
    fi

    log_success "依赖安装成功"
    return 0
}

# 构建 Docker 镜像
build_docker_image() {
    log_info "构建 Docker 镜像..."

    cd "${ROOT_DIR}" || {
        log_error "无法切换到项目根目录"
        return 1
    }

    log_info "使用 Dockerfile: ${SCRIPT_DIR}/Dockerfile"
    log_info "构建上下文: ${ROOT_DIR}"

    if ! docker build -t "${IMAGE_NAME}" -f "${SCRIPT_DIR}/Dockerfile" . 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "Docker 镜像构建失败"
        return 1
    fi

    log_success "Docker 镜像构建成功"
    return 0
}

# 运行容器
run_container() {
    log_info "启动容器..."

    if ! docker run -d \
        --name "${CONTAINER_NAME}" \
        -p "${PORT}:8080" \
        "${IMAGE_NAME}" 2>&1 | tee -a "${LOG_FILE}"; then
        log_error "容器启动失败"
        return 1
    fi

    log_success "容器启动成功"
    log_info "容器名称: ${CONTAINER_NAME}"
    log_info "镜像名称: ${IMAGE_NAME}"
    log_info "访问地址: http://localhost:${PORT}"

    # 显示容器状态
    sleep 2
    docker ps --filter "name=${CONTAINER_NAME}"

    return 0
}

# 主函数
main() {
    log_info "开始构建 ruoqi-sys-admin 项目"
    log_info "========================================"
    log_info "项目根目录: ${ROOT_DIR}"
    log_info "构建目录: ${SCRIPT_DIR}"
    log_info "镜像名称: ${IMAGE_NAME}"
    log_info "容器名称: ${CONTAINER_NAME}"
    log_info "端口映射: ${PORT}:8080"
    log_info "日志文件: ${LOG_FILE}"
    log_info "========================================"

    # 清空日志文件
    > "${LOG_FILE}"

    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi

    # 清理现有资源
    cleanup

    # 安装依赖
    if ! install_dependencies; then
        exit 1
    fi

    # 构建镜像
    if ! build_docker_image; then
        exit 1
    fi

    # 运行容器
    if ! run_container; then
        exit 1
    fi

    log_info "========================================"
    log_success "ruoqi-sys-admin 项目部署完成！"
    log_info ""
    log_info "常用命令:"
    log_info "  查看日志: docker logs ${CONTAINER_NAME}"
    log_info "  进入容器: docker exec -it ${CONTAINER_NAME} sh"
    log_info "  停止容器: docker stop ${CONTAINER_NAME}"
    log_info "  启动容器: docker start ${CONTAINER_NAME}"
    log_info "  重启容器: docker restart ${CONTAINER_NAME}"
    log_info "  删除容器: docker rm ${CONTAINER_NAME}"
    log_info "  删除镜像: docker rmi ${IMAGE_NAME}"
    log_info ""
    log_info "访问应用: http://localhost:${PORT}"
    log_info "========================================"
}

# 执行主函数
main
