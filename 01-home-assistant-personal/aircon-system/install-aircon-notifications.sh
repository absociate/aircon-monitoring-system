#!/bin/bash

# 空調設備通知系統安裝腳本
# 此腳本將幫助您快速設置 Node-RED 空調通知系統

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：打印彩色訊息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 函數：檢查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函數：檢查 Node-RED 是否安裝
check_nodered() {
    if command_exists node-red; then
        print_success "Node-RED 已安裝"
        return 0
    else
        print_error "Node-RED 未安裝，請先安裝 Node-RED"
        echo "安裝指令: npm install -g --unsafe-perm node-red"
        return 1
    fi
}

# 函數：安裝必要的 Node-RED 節點
install_nodes() {
    print_info "安裝必要的 Node-RED 節點..."
    
    # 檢查 npm 是否存在
    if ! command_exists npm; then
        print_error "npm 未安裝，請先安裝 Node.js 和 npm"
        exit 1
    fi
    
    # 安裝 Home Assistant 節點
    print_info "安裝 Home Assistant 節點..."
    npm install node-red-contrib-home-assistant-websocket
    
    # 安裝 Telegram 節點
    print_info "安裝 Telegram 節點..."
    npm install node-red-contrib-telegrambot
    
    print_success "Node-RED 節點安裝完成"
}

# 函數：創建配置文件
setup_config() {
    print_info "設置配置文件..."
    
    # 複製環境變數範例文件
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            print_success "已創建 .env 配置文件"
            print_warning "請編輯 .env 文件並填入您的實際配置值"
        else
            print_error ".env.example 文件不存在"
        fi
    else
        print_warning ".env 文件已存在，跳過創建"
    fi
}

# 函數：驗證配置文件
validate_config() {
    print_info "驗證配置文件..."
    
    local config_valid=true
    
    # 檢查必要的文件是否存在
    local required_files=(
        "aircon-notification-flow.json"
        "device-mapping.json"
        "notification-config.js"
        "README-aircon-notifications.md"
    )
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "缺少必要文件: $file"
            config_valid=false
        fi
    done
    
    if [ "$config_valid" = true ]; then
        print_success "配置文件驗證通過"
    else
        print_error "配置文件驗證失敗"
        exit 1
    fi
}

# 函數：顯示下一步指示
show_next_steps() {
    print_success "安裝完成！"
    echo
    print_info "下一步操作："
    echo "1. 編輯 .env 文件，填入您的實際配置值"
    echo "2. 啟動 Node-RED: node-red"
    echo "3. 打開瀏覽器訪問: http://localhost:1880"
    echo "4. 導入 aircon-notification-flow.json 流程文件"
    echo "5. 配置 Home Assistant 連接"
    echo "6. 配置通知服務（Telegram、Synology Chat）"
    echo "7. 部署流程並測試"
    echo
    print_info "詳細說明請參考: README-aircon-notifications.md"
}

# 函數：檢查系統需求
check_requirements() {
    print_info "檢查系統需求..."
    
    # 檢查 Node.js
    if command_exists node; then
        local node_version=$(node --version)
        print_success "Node.js 已安裝: $node_version"
    else
        print_error "Node.js 未安裝，請先安裝 Node.js"
        exit 1
    fi
    
    # 檢查 npm
    if command_exists npm; then
        local npm_version=$(npm --version)
        print_success "npm 已安裝: $npm_version"
    else
        print_error "npm 未安裝，請先安裝 npm"
        exit 1
    fi
}

# 主函數
main() {
    echo "========================================"
    echo "  空調設備通知系統安裝程式"
    echo "========================================"
    echo
    
    # 檢查系統需求
    check_requirements
    
    # 檢查 Node-RED
    if ! check_nodered; then
        exit 1
    fi
    
    # 驗證配置文件
    validate_config
    
    # 詢問是否安裝 Node-RED 節點
    echo
    read -p "是否要安裝必要的 Node-RED 節點？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_nodes
    else
        print_warning "跳過 Node-RED 節點安裝"
    fi
    
    # 設置配置文件
    setup_config
    
    # 顯示下一步指示
    show_next_steps
}

# 執行主函數
main "$@"
