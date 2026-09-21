#!/bin/bash

# ============================================
# Docker 与 Docker Compose 安装脚本
# 适用于 Ubuntu 22.04 LTS
# ============================================

set -e  # 遇到错误立即退出

# 颜色定义，美化输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否以 root 运行
check_root() {
    if [ "$EUID" -eq 0 ]; then 
        log_warning "当前以 root 用户运行，建议使用普通用户执行此脚本"
        log_warning "如果继续，后续将不需要 sudo 前缀"
        read -p "是否继续？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
        SUDO=""
    else
        SUDO="sudo"
    fi
}

# 检查系统版本
check_system() {
    log_info "检查系统版本..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [ "$ID" != "ubuntu" ]; then
            log_error "此脚本仅支持 Ubuntu 系统"
            exit 1
        fi
        log_success "系统版本: Ubuntu $VERSION_ID"
    else
        log_error "无法识别系统版本"
        exit 1
    fi
}

# 卸载旧版本 Docker
remove_old_docker() {
    log_info "正在卸载旧版本 Docker（如果存在）..."
    $SUDO apt remove -y \
        docker \
        docker-engine \
        docker.io \
        containerd \
        runc \
        2>/dev/null || true
    log_success "旧版本清理完成"
}

# 安装依赖和设置仓库
setup_repository() {
    log_info "正在安装依赖并设置 Docker 官方仓库..."
    
    # 更新包索引
    $SUDO apt update -y
    
    # 安装依赖
    $SUDO apt install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        apt-transport-https
        
    # 创建 keyrings 目录
    $SUDO install -m 0755 -d /etc/apt/keyrings
    
    # 下载并安装 Docker GPG 密钥
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
            $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        $SUDO chmod a+r /etc/apt/keyrings/docker.gpg
        log_success "Docker GPG 密钥已添加"
    else
        log_info "Docker GPG 密钥已存在，跳过"
    fi
    
    # 添加 Docker 软件源
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | \
        $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    log_success "Docker 仓库已添加"
}

# 安装 Docker
install_docker() {
    log_info "正在安装 Docker 引擎和 Docker Compose 插件..."
    
    # 更新包索引
    $SUDO apt update -y
    
    # 安装 Docker 相关包
    $SUDO apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    log_success "Docker 安装完成"
}

# 启动 Docker 服务
start_docker() {
    log_info "正在启动 Docker 服务..."
    $SUDO systemctl enable docker
    $SUDO systemctl start docker
    log_success "Docker 服务已启动"
}

# 验证安装
verify_installation() {
    log_info "正在验证安装..."
    
    if $SUDO docker run --rm hello-world > /dev/null 2>&1; then
        log_success "Docker 运行测试通过"
    else
        log_error "Docker 运行测试失败"
        exit 1
    fi
    
    # 显示版本信息
    echo ""
    log_info "Docker 版本信息："
    docker --version
    
    echo ""
    log_info "Docker Compose 版本信息："
    docker compose version
    
    echo ""
    log_success "所有组件安装验证通过！"
}

# 配置普通用户权限
configure_user_permissions() {
    if [ "$EUID" -ne 0 ]; then
        log_info "正在将当前用户 ($USER) 添加到 docker 组..."
        $SUDO usermod -aG docker $USER
        
        log_success "用户已添加到 docker 组"
        log_warning "⚠️  重要提示："
        log_warning "   请注销当前会话并重新登录，或者运行以下命令使权限生效："
        log_warning "   newgrp docker"
        log_warning "   然后再次运行 'docker ps' 验证是否可以免 sudo 使用"
    else
        log_info "当前为 root 用户，跳过用户组配置"
    fi
}

# 主函数
main() {
    echo "========================================="
    echo "  Docker 与 Docker Compose 安装脚本"
    echo "  适用于 Ubuntu 22.04 LTS"
    echo "========================================="
    echo ""
    
    check_root
    check_system
    
    echo ""
    log_info "开始安装 Docker..."
    echo ""
    
    remove_old_docker
    setup_repository
    install_docker
    start_docker
    verify_installation
    configure_user_permissions
    
    echo ""
    echo "========================================="
    log_success "🎉 Docker 安装完成！"
    echo "========================================="
    echo ""
    log_info "后续步骤："
    echo "  1. 重新登录或运行: newgrp docker"
    echo "  2. 验证免 sudo 运行: docker ps"
    echo "  3. 安装 Gitea: 参考第二步的 docker-compose.yml"
    echo ""
}

# 执行主函数
main
