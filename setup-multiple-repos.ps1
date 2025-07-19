# 設定多個 GitHub 倉庫的腳本
# 將專案分離到三個獨立的倉庫

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  多倉庫設定工具" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 檢查當前目錄
$currentPath = Get-Location
Write-Host "當前目錄: $currentPath" -ForegroundColor Yellow
Write-Host ""

# 提示用戶先在 GitHub 建立倉庫
Write-Host "請先在 GitHub 建立以下三個倉庫：" -ForegroundColor Green
Write-Host "1. home-assistant-personal (Private)" -ForegroundColor White
Write-Host "2. home-assistant-office (Private)" -ForegroundColor White  
Write-Host "3. lab-management-system (Private)" -ForegroundColor White
Write-Host ""

$username = Read-Host "請輸入您的 GitHub 用戶名"
Write-Host ""

# 確認是否已建立倉庫
$confirm = Read-Host "是否已在 GitHub 建立上述三個倉庫？(y/n)"
if ($confirm -ne "y") {
    Write-Host "請先到 GitHub 建立倉庫，然後重新執行此腳本" -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "[資訊] 開始設定多倉庫結構..." -ForegroundColor Green

# 建立臨時目錄來組織檔案
$tempDir = "temp-repos"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

# 建立三個子目錄
$repos = @("home-assistant-personal", "home-assistant-office", "lab-management-system")
foreach ($repo in $repos) {
    New-Item -ItemType Directory -Path "$tempDir\$repo" -Force | Out-Null
}

Write-Host "[資訊] 複製檔案到對應倉庫..." -ForegroundColor Yellow

# 複製家庭 HA 系統檔案
if (Test-Path "01-home-assistant-personal") {
    Copy-Item "01-home-assistant-personal\*" "$tempDir\home-assistant-personal\" -Recurse -Force
    Write-Host "  ✅ 家庭 HA 系統檔案已複製" -ForegroundColor Gray
}

# 複製辦公室 HA 系統檔案
if (Test-Path "02-home-assistant-office") {
    Copy-Item "02-home-assistant-office\*" "$tempDir\home-assistant-office\" -Recurse -Force
    Write-Host "  ✅ 辦公室 HA 系統檔案已複製" -ForegroundColor Gray
}

# 複製實驗管理系統檔案
if (Test-Path "03-lab-management-system") {
    Copy-Item "03-lab-management-system\*" "$tempDir\lab-management-system\" -Recurse -Force
    Write-Host "  ✅ 實驗管理系統檔案已複製" -ForegroundColor Gray
}

# 複製共用工具到每個倉庫
if (Test-Path "shared-tools") {
    foreach ($repo in $repos) {
        Copy-Item "shared-tools" "$tempDir\$repo\" -Recurse -Force
    }
    Write-Host "  ✅ 共用工具已複製到各倉庫" -ForegroundColor Gray
}

Write-Host ""
Write-Host "[資訊] 為每個倉庫建立專用的 README 和配置..." -ForegroundColor Yellow

# 家庭 HA 系統 README
$homeReadme = @"
# 🏠 家庭 Home Assistant 自動化系統

這個倉庫包含家裡 Home Assistant 的所有配置和自動化腳本。

## 🌡️ 主要功能

### 空調三系統 (aircon-system)
- 監控 5 個空調設備（加濕器、全熱交換器、3台冷氣）
- 多重通知系統（NotifyHelper、Synology Chat、Telegram）
- 智能溫度和模式控制

### 電池管理 (battery-management)
- ENELOOP 電池充電管理
- 安全時間控制和監控
- 充電狀態通知

### 通知系統 (notifications)
- NotifyHelper 配置
- 多平台通知整合
- 自定義通知規則

## 🚀 快速開始

1. 複製倉庫到樹莓派
2. 進入對應的子目錄
3. 參考各自的 README.md 檔案
4. 按照說明進行配置和部署

## 🔧 硬體需求

- 樹莓派 4B (主控制器)
- Home Assistant OS
- 5個空調設備
- ENELOOP 電池充電器

## 🔄 同步說明

此倉庫專門用於家庭環境，與辦公室系統完全分離。
使用 shared-tools/sync-scripts/ 中的腳本進行同步。
"@

$homeReadme | Out-File -FilePath "$tempDir\home-assistant-personal\README.md" -Encoding UTF8

# 辦公室 HA 系統 README
$officeReadme = @"
# 🏢 辦公室 Home Assistant 自動化系統

這個倉庫包含公司 Home Assistant 的配置和辦公室自動化腳本。

## 🏢 主要功能

### 辦公室自動化 (office-automation)
- 會議室環境控制
- 照明和空調自動化
- 工作時間排程

## 🚀 快速開始

1. 複製倉庫到辦公室設備
2. 根據公司環境調整配置
3. 注意網路安全和權限設定

## ⚠️ 注意事項

- 配置檔案需要根據公司環境調整
- 注意網路安全和權限設定
- 定期備份重要配置
- 遵守公司 IT 政策

## 🔄 同步說明

此倉庫專門用於辦公室環境，與家庭系統完全分離。
"@

$officeReadme | Out-File -FilePath "$tempDir\home-assistant-office\README.md" -Encoding UTF8

# 實驗管理系統 README
$labReadme = @"
# 🔬 實驗管理系統

這個倉庫包含實驗室設備監控和管理系統。

## 🔬 主要功能

### 設備監控 (equipment-monitoring)
- 實驗設備狀態監控
- 溫度、濕度、壓力感測
- 異常警報系統

## 🚀 功能規劃

- 設備狀態監控
- 資料收集和分析
- 自動報告生成
- 異常警報系統

## 📊 資料管理

- 實驗資料自動收集
- 資料庫整合
- 即時資料分析
- 報告自動生成

## 🔄 同步說明

此倉庫專門用於實驗室環境，包含敏感的實驗資料。
請確保遵守資料保護政策。
"@

$labReadme | Out-File -FilePath "$tempDir\lab-management-system\README.md" -Encoding UTF8

Write-Host ""
Write-Host "[資訊] 為每個倉庫建立 Git 設定..." -ForegroundColor Yellow

# 為每個倉庫建立 Git 設定
foreach ($repo in $repos) {
    $repoPath = "$tempDir\$repo"
    
    # 進入倉庫目錄
    Push-Location $repoPath
    
    # 初始化 Git
    git init | Out-Null
    
    # 建立 .gitignore
    $gitignore = @"
# 敏感資訊
.env
.env.*
config.local.js
secrets.json
private-config.json

# Home Assistant 敏感檔案
configuration.yaml
secrets.yaml
known_devices.yaml
.storage/
home-assistant.log*

# API 金鑰
*token*.txt
*webhook*.txt
*api-key*.json

# Node.js
node_modules/
npm-debug.log*
*.log

# 系統檔案
.DS_Store
Thumbs.db
*.tmp
*.temp

# 個人檔案
personal-*
my-*
notes.txt
"@
    
    $gitignore | Out-File -FilePath ".gitignore" -Encoding UTF8
    
    # 添加檔案
    git add .
    git commit -m "初始化 $repo 倉庫" | Out-Null
    
    # 設定遠端倉庫
    git remote add origin "https://github.com/$username/$repo.git"
    
    # 設定主分支
    git branch -M main
    
    Write-Host "  ✅ $repo Git 設定完成" -ForegroundColor Gray
    
    # 回到原目錄
    Pop-Location
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Blue
Write-Host "  設定完成！" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

Write-Host "下一步操作：" -ForegroundColor Green
Write-Host ""
Write-Host "1. 推送到 GitHub：" -ForegroundColor Yellow
foreach ($repo in $repos) {
    Write-Host "   cd temp-repos\$repo" -ForegroundColor White
    Write-Host "   git push -u origin main" -ForegroundColor White
    Write-Host ""
}

Write-Host "2. 在不同環境中複製對應倉庫：" -ForegroundColor Yellow
Write-Host "   家裡：git clone https://github.com/$username/home-assistant-personal.git" -ForegroundColor White
Write-Host "   公司：git clone https://github.com/$username/home-assistant-office.git" -ForegroundColor White
Write-Host "   實驗室：git clone https://github.com/$username/lab-management-system.git" -ForegroundColor White
Write-Host ""

Write-Host "3. 清理原始目錄（可選）：" -ForegroundColor Yellow
Write-Host "   移除 01-home-assistant-personal, 02-home-assistant-office, 03-lab-management-system" -ForegroundColor White
Write-Host ""

Read-Host "按 Enter 鍵繼續..."
