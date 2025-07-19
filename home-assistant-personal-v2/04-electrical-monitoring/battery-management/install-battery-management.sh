#!/bin/bash

# 智能充電電池管理系統安裝腳本
# 適用於樹莓派 Home Assistant + Node-RED 環境

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

# 函數：檢查Home Assistant是否運行
check_home_assistant() {
    print_info "檢查 Home Assistant 狀態..."
    
    if systemctl is-active --quiet home-assistant@homeassistant; then
        print_success "Home Assistant 正在運行"
        return 0
    elif command_exists ha; then
        if ha core info >/dev/null 2>&1; then
            print_success "Home Assistant (Supervised) 正在運行"
            return 0
        fi
    else
        print_error "Home Assistant 未運行或無法檢測"
        return 1
    fi
}

# 函數：檢查Node-RED是否運行
check_node_red() {
    print_info "檢查 Node-RED 狀態..."
    
    if systemctl is-active --quiet nodered; then
        print_success "Node-RED 正在運行"
        return 0
    elif pgrep -f "node-red" >/dev/null; then
        print_success "Node-RED 正在運行"
        return 0
    else
        print_error "Node-RED 未運行"
        return 1
    fi
}

# 函數：備份現有配置
backup_config() {
    print_info "備份現有配置..."
    
    local backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # 備份Home Assistant配置
    if [ -f "/config/configuration.yaml" ]; then
        cp "/config/configuration.yaml" "$backup_dir/"
        print_success "已備份 configuration.yaml"
    fi
    
    # 備份Node-RED flows
    if [ -f "$HOME/.node-red/flows.json" ]; then
        cp "$HOME/.node-red/flows.json" "$backup_dir/"
        print_success "已備份 Node-RED flows"
    fi
    
    print_success "配置備份完成：$backup_dir"
}

# 函數：安裝Home Assistant輔助實體
install_ha_helpers() {
    print_info "安裝 Home Assistant 輔助實體..."

    # 檢查配置目錄 (樹莓派4B常見路徑)
    local config_dir=""
    local possible_dirs=(
        "/usr/share/hassio/homeassistant"
        "/config"
        "$HOME/.homeassistant"
        "/home/homeassistant/.homeassistant"
        "/opt/homeassistant/.homeassistant"
    )

    for dir in "${possible_dirs[@]}"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            config_dir="$dir"
            print_success "找到 Home Assistant 配置目錄：$config_dir"
            break
        fi
    done

    if [ -z "$config_dir" ]; then
        print_error "找不到可寫入的 Home Assistant 配置目錄"
        print_info "請手動指定配置目錄路徑："
        read -p "輸入 Home Assistant 配置目錄路徑: " config_dir
        if [ ! -d "$config_dir" ]; then
            print_error "指定的目錄不存在"
            return 1
        fi
    fi
    
    # 創建helpers目錄
    mkdir -p "$config_dir/packages"
    
    # 複製helpers配置
    if [ -f "battery-helpers.yaml" ]; then
        cp "battery-helpers.yaml" "$config_dir/packages/"
        print_success "已安裝輔助實體配置"
    else
        print_error "找不到 battery-helpers.yaml 文件"
        return 1
    fi
    
    # 檢查configuration.yaml是否包含packages配置
    if ! grep -q "packages:" "$config_dir/configuration.yaml" 2>/dev/null; then
        print_info "添加 packages 配置到 configuration.yaml..."
        echo "" >> "$config_dir/configuration.yaml"
        echo "# 智能充電電池管理系統" >> "$config_dir/configuration.yaml"
        echo "homeassistant:" >> "$config_dir/configuration.yaml"
        echo "  packages: !include_dir_named packages/" >> "$config_dir/configuration.yaml"
        print_success "已添加 packages 配置"
    fi
}

# 函數：安裝Node-RED流程
install_node_red_flow() {
    print_info "安裝 Node-RED 流程..."
    
    # 檢查Node-RED目錄
    local node_red_dir="$HOME/.node-red"
    if [ ! -d "$node_red_dir" ]; then
        print_error "找不到 Node-RED 配置目錄"
        return 1
    fi
    
    # 複製配置文件
    if [ -f "battery-config.js" ]; then
        cp "battery-config.js" "$node_red_dir/"
        print_success "已複製配置文件"
    else
        print_error "找不到 battery-config.js 文件"
        return 1
    fi
    
    # 複製流程文件
    if [ -f "battery-charging-flow.json" ]; then
        cp "battery-charging-flow.json" "$node_red_dir/"
        print_success "已複製流程文件"
        print_warning "請手動導入 battery-charging-flow.json 到 Node-RED"
    else
        print_error "找不到 battery-charging-flow.json 文件"
        return 1
    fi
}

# 函數：檢查必要的Node-RED節點
check_node_red_nodes() {
    print_info "檢查 Node-RED 節點..."
    
    local node_red_dir="$HOME/.node-red"
    local package_json="$node_red_dir/package.json"
    
    if [ ! -f "$package_json" ]; then
        print_warning "找不到 Node-RED package.json"
        return 1
    fi
    
    # 檢查必要的節點
    local required_nodes=(
        "node-red-contrib-home-assistant-websocket"
    )
    
    for node in "${required_nodes[@]}"; do
        if grep -q "\"$node\"" "$package_json"; then
            print_success "已安裝：$node"
        else
            print_warning "未安裝：$node"
            print_info "請在 Node-RED 管理面板中安裝此節點"
        fi
    done
}

# 函數：重啟服務
restart_services() {
    print_info "重啟服務..."
    
    # 重啟Home Assistant
    print_info "重啟 Home Assistant..."
    if systemctl is-active --quiet home-assistant@homeassistant; then
        sudo systemctl restart home-assistant@homeassistant
        print_success "Home Assistant 已重啟"
    elif command_exists ha; then
        ha core restart
        print_success "Home Assistant (Supervised) 已重啟"
    fi
    
    # 重啟Node-RED
    print_info "重啟 Node-RED..."
    if systemctl is-active --quiet nodered; then
        sudo systemctl restart nodered
        print_success "Node-RED 已重啟"
    else
        print_warning "請手動重啟 Node-RED"
    fi
}

# 函數：顯示後續步驟
show_next_steps() {
    print_info "安裝完成！後續步驟："
    echo ""
    echo "1. 等待服務重啟完成（約1-2分鐘）"
    echo "2. 打開 Node-RED 編輯器：http://樹莓派IP:1880"
    echo "3. 導入流程文件：battery-charging-flow.json"
    echo "4. 配置 Home Assistant 連接"
    echo "5. 在 Home Assistant 中檢查新的輔助實體"
    echo "6. 測試充電功能"
    echo ""
    print_success "詳細說明請參考 README-battery-charging.md"
}

# 主函數
main() {
    echo "========================================"
    echo "  智能充電電池管理系統安裝程式"
    echo "========================================"
    echo ""
    
    # 檢查運行環境
    if ! check_home_assistant; then
        print_error "請確保 Home Assistant 正在運行"
        exit 1
    fi
    
    if ! check_node_red; then
        print_error "請確保 Node-RED 正在運行"
        exit 1
    fi
    
    # 確認安裝
    echo ""
    read -p "是否繼續安裝？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "安裝已取消"
        exit 0
    fi
    
    # 執行安裝步驟
    backup_config
    install_ha_helpers
    install_node_red_flow
    check_node_red_nodes
    
    # 詢問是否重啟服務
    echo ""
    read -p "是否重啟 Home Assistant 和 Node-RED？(y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_services
    else
        print_warning "請手動重啟 Home Assistant 和 Node-RED"
    fi
    
    show_next_steps
}

# 檢查是否以root權限運行
if [[ $EUID -eq 0 ]]; then
    print_warning "建議不要以 root 權限運行此腳本"
fi

# 執行主函數
main "$@"
