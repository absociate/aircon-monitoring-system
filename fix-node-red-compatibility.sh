#!/bin/bash

# Node-RED Home Assistant 相容性修正腳本
# 解決 call-service 節點問題，適用於樹莓派4B

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

# 函數：檢查Node-RED狀態
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

# 函數：備份Node-RED配置
backup_node_red() {
    print_info "備份 Node-RED 配置..."
    
    local backup_dir="node-red-backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    if [ -d "$HOME/.node-red" ]; then
        cp -r "$HOME/.node-red/flows.json" "$backup_dir/" 2>/dev/null || true
        cp -r "$HOME/.node-red/package.json" "$backup_dir/" 2>/dev/null || true
        print_success "Node-RED 配置已備份到：$backup_dir"
    else
        print_warning "找不到 Node-RED 配置目錄"
    fi
}

# 函數：檢查Home Assistant節點版本
check_ha_node_version() {
    print_info "檢查 Home Assistant 節點版本..."
    
    local node_red_dir="$HOME/.node-red"
    
    if [ ! -d "$node_red_dir" ]; then
        print_error "找不到 Node-RED 目錄"
        return 1
    fi
    
    cd "$node_red_dir"
    
    if [ -f "package.json" ]; then
        local current_version=$(npm list node-red-contrib-home-assistant-websocket 2>/dev/null | grep node-red-contrib-home-assistant-websocket | awk '{print $2}' | head -1)
        if [ -n "$current_version" ]; then
            print_info "當前版本：$current_version"
        else
            print_warning "未安裝 Home Assistant 節點"
        fi
    fi
}

# 函數：更新Home Assistant節點
update_ha_node() {
    print_info "更新 Home Assistant 節點..."
    
    local node_red_dir="$HOME/.node-red"
    cd "$node_red_dir"
    
    # 檢查npm是否可用
    if ! command_exists npm; then
        print_error "npm 未安裝，請先安裝 Node.js"
        return 1
    fi
    
    # 停止Node-RED
    print_info "停止 Node-RED..."
    if systemctl is-active --quiet nodered; then
        sudo systemctl stop nodered
    fi
    
    # 更新節點
    print_info "更新 node-red-contrib-home-assistant-websocket..."
    
    # 方法1：嘗試更新
    if npm update node-red-contrib-home-assistant-websocket; then
        print_success "節點更新成功"
    else
        print_warning "更新失敗，嘗試重新安裝..."
        
        # 方法2：重新安裝
        npm uninstall node-red-contrib-home-assistant-websocket
        if npm install node-red-contrib-home-assistant-websocket@latest; then
            print_success "節點重新安裝成功"
        else
            print_error "節點安裝失敗"
            return 1
        fi
    fi
    
    # 重啟Node-RED
    print_info "重啟 Node-RED..."
    sudo systemctl start nodered
    
    # 等待啟動
    sleep 5
    
    if systemctl is-active --quiet nodered; then
        print_success "Node-RED 已重啟"
    else
        print_error "Node-RED 重啟失敗"
        return 1
    fi
}

# 函數：修正流程文件
fix_flow_file() {
    print_info "修正流程文件中的節點類型..."
    
    if [ ! -f "battery-charging-flow.json" ]; then
        print_error "找不到 battery-charging-flow.json 文件"
        return 1
    fi
    
    # 備份原始文件
    cp "battery-charging-flow.json" "battery-charging-flow.json.backup"
    
    # 替換節點類型
    sed -i 's/"type": "call-service"/"type": "api-call-service"/g' battery-charging-flow.json
    
    print_success "流程文件已修正"
    print_info "原始文件已備份為：battery-charging-flow.json.backup"
}

# 函數：驗證修正結果
verify_fix() {
    print_info "驗證修正結果..."
    
    # 檢查Node-RED狀態
    if ! systemctl is-active --quiet nodered; then
        print_error "Node-RED 未運行"
        return 1
    fi
    
    # 檢查節點版本
    local node_red_dir="$HOME/.node-red"
    cd "$node_red_dir"
    
    local new_version=$(npm list node-red-contrib-home-assistant-websocket 2>/dev/null | grep node-red-contrib-home-assistant-websocket | awk '{print $2}' | head -1)
    if [ -n "$new_version" ]; then
        print_success "Home Assistant 節點版本：$new_version"
    else
        print_error "無法確認節點版本"
        return 1
    fi
    
    # 檢查流程文件
    if grep -q "api-call-service" battery-charging-flow.json 2>/dev/null; then
        print_success "流程文件已使用新的節點類型"
    else
        print_warning "流程文件可能需要手動修正"
    fi
    
    print_success "修正完成！"
}

# 函數：顯示後續步驟
show_next_steps() {
    print_info "後續步驟："
    echo ""
    echo "1. 打開 Node-RED 編輯器：http://樹莓派IP:1880"
    echo "2. 重新導入修正後的流程文件：battery-charging-flow.json"
    echo "3. 檢查所有節點是否正常顯示（不再有unknown節點）"
    echo "4. 配置 Home Assistant 連接"
    echo "5. 部署並測試流程"
    echo ""
    print_warning "如果仍有問題，請檢查 Node-RED 日誌："
    echo "journalctl -u nodered -f"
}

# 主函數
main() {
    echo "========================================"
    echo "  Node-RED Home Assistant 相容性修正"
    echo "========================================"
    echo ""
    
    # 檢查運行環境
    if ! check_node_red; then
        print_error "請確保 Node-RED 正在運行"
        exit 1
    fi
    
    # 確認修正
    echo ""
    read -p "是否繼續修正 Node-RED Home Assistant 節點相容性問題？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "修正已取消"
        exit 0
    fi
    
    # 執行修正步驟
    backup_node_red
    check_ha_node_version
    update_ha_node
    fix_flow_file
    verify_fix
    show_next_steps
}

# 檢查是否以root權限運行
if [[ $EUID -eq 0 ]]; then
    print_warning "建議不要以 root 權限運行此腳本"
fi

# 執行主函數
main "$@"
