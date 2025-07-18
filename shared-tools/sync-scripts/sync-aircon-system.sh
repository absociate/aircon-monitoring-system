#!/bin/bash

# 空調系統 GitHub 同步腳本 (Linux/Mac)
# 此腳本幫助您快速同步空調系統專案到 GitHub

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：打印彩色訊息
print_info() {
    echo -e "${BLUE}[資訊]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[錯誤]${NC} $1"
}

# 函數：檢查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函數：檢查是否在正確的目錄
check_directory() {
    if [ ! -f "README-aircon-notifications.md" ]; then
        print_error "請在包含空調系統檔案的目錄中執行此腳本"
        print_info "當前目錄: $(pwd)"
        exit 1
    fi
}

# 函數：檢查 Git 是否安裝
check_git() {
    if ! command_exists git; then
        print_error "Git 未安裝，請先安裝 Git"
        print_info "Ubuntu/Debian: sudo apt-get install git"
        print_info "CentOS/RHEL: sudo yum install git"
        print_info "macOS: brew install git"
        exit 1
    fi
}

# 函數：初始化 Git 倉庫
init_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_warning "此目錄尚未初始化為 Git 倉庫"
        echo
        read -p "是否要初始化 Git 倉庫？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "初始化 Git 倉庫..."
            git init
            print_success "Git 倉庫初始化完成"
            echo
            read -p "請輸入 GitHub 倉庫 URL: " remote_url
            git remote add origin "$remote_url"
            print_success "遠端倉庫設定完成"
        else
            print_info "跳過 Git 初始化"
            exit 0
        fi
    fi
}

# 函數：推送更新到 GitHub
push_updates() {
    print_info "準備推送更新到 GitHub..."
    echo
    
    # 顯示將要提交的檔案
    print_info "將要提交的檔案:"
    git status --short
    
    echo
    read -p "請輸入提交訊息: " commit_msg
    if [ -z "$commit_msg" ]; then
        commit_msg="更新空調系統配置"
    fi
    
    print_info "添加檔案到暫存區..."
    git add .
    
    print_info "提交變更..."
    git commit -m "$commit_msg"
    
    print_info "推送到 GitHub..."
    if ! git push origin main; then
        print_error "推送失敗，可能需要先拉取遠端變更"
        print_info "嘗試拉取並合併..."
        if git pull origin main; then
            print_info "重新推送..."
            git push origin main
        else
            print_error "拉取失敗，請手動解決衝突"
            return 1
        fi
    fi
    
    print_success "更新已推送到 GitHub"
}

# 函數：從 GitHub 拉取更新
pull_updates() {
    print_info "從 GitHub 拉取更新..."
    
    # 檢查是否有未提交的變更
    if ! git diff-index --quiet HEAD --; then
        print_warning "發現未提交的變更"
        git status --short
        echo
        read -p "是否要暫存這些變更？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "暫存變更..."
            git stash push -m "自動暫存 - $(date)"
        fi
    fi
    
    print_info "拉取遠端變更..."
    if ! git pull origin main; then
        print_error "拉取失敗，可能有衝突需要解決"
        return 1
    fi
    
    print_success "更新已從 GitHub 拉取完成"
    
    # 如果之前有暫存變更，詢問是否要恢復
    if git stash list | grep -q "stash@{0}"; then
        echo
        read -p "是否要恢復之前暫存的變更？(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "恢復暫存的變更..."
            git stash pop
        fi
    fi
}

# 函數：檢查狀態
check_status() {
    print_info "Git 狀態檢查:"
    echo
    echo "當前分支:"
    git branch --show-current
    echo
    echo "檔案狀態:"
    git status
    echo
    echo "最近的提交:"
    git log --oneline -5
}

# 函數：建立新分支
create_branch() {
    echo
    read -p "請輸入新分支名稱: " branch_name
    if [ -z "$branch_name" ]; then
        print_error "分支名稱不能為空"
        return 1
    fi
    
    print_info "建立並切換到新分支: $branch_name"
    git checkout -b "$branch_name"
    print_success "分支 $branch_name 建立完成"
}

# 函數：切換分支
switch_branch() {
    echo
    print_info "可用的分支:"
    git branch -a
    echo
    read -p "請輸入要切換的分支名稱: " target_branch
    if [ -z "$target_branch" ]; then
        print_error "分支名稱不能為空"
        return 1
    fi
    
    print_info "切換到分支: $target_branch"
    if git checkout "$target_branch"; then
        print_success "已切換到分支: $target_branch"
    else
        print_error "切換分支失敗"
        return 1
    fi
}

# 函數：顯示選單
show_menu() {
    echo "========================================"
    echo "  空調系統 GitHub 同步工具"
    echo "========================================"
    echo
    
    print_info "當前 Git 狀態:"
    git status --short
    
    echo
    echo "請選擇操作:"
    echo "1. 推送更新到 GitHub (在家裡使用)"
    echo "2. 從 GitHub 拉取更新 (在公司使用)"
    echo "3. 檢查狀態"
    echo "4. 建立新分支"
    echo "5. 切換分支"
    echo "6. 退出"
    echo
}

# 主函數
main() {
    # 檢查系統需求
    check_directory
    check_git
    init_git_repo
    
    while true; do
        show_menu
        read -p "請輸入選項 (1-6): " choice
        
        case $choice in
            1)
                push_updates
                ;;
            2)
                pull_updates
                ;;
            3)
                check_status
                ;;
            4)
                create_branch
                ;;
            5)
                switch_branch
                ;;
            6)
                print_info "腳本執行完成"
                exit 0
                ;;
            *)
                print_error "無效的選項"
                ;;
        esac
        
        echo
        read -p "按 Enter 鍵繼續..." -r
        clear
    done
}

# 執行主函數
main "$@"
