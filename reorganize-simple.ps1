# 簡化版家庭 HA 系統重新組織腳本

Write-Host "========================================"
Write-Host "  家庭 HA 系統重新組織工具"
Write-Host "========================================"
Write-Host ""

# 檢查是否在正確目錄
if (!(Test-Path "01-home-assistant-personal")) {
    Write-Host "找不到家庭 HA 系統目錄" -ForegroundColor Red
    Write-Host "請確保在包含 01-home-assistant-personal 的目錄中執行" -ForegroundColor Yellow
    exit 1
}

Write-Host "開始重新組織家庭 HA 系統..." -ForegroundColor Green

# 建立新的目錄結構
$newStructure = "home-assistant-personal-v2"
Write-Host "建立新的目錄結構..." -ForegroundColor Yellow

# 移除舊的 v2 目錄（如果存在）
if (Test-Path $newStructure) {
    Remove-Item $newStructure -Recurse -Force
}

# 建立主目錄
New-Item -ItemType Directory -Path $newStructure -Force | Out-Null

# 建立功能領域目錄
$areas = @(
    "01-climate-control",
    "02-lighting-automation", 
    "03-window-treatments",
    "04-electrical-monitoring",
    "05-security-safety",
    "06-entertainment",
    "07-notifications",
    "08-integrations"
)

foreach ($area in $areas) {
    New-Item -ItemType Directory -Path "$newStructure\$area" -Force | Out-Null
    Write-Host "  建立目錄: $area" -ForegroundColor Gray
}

# 建立氣候控制子目錄
$climateDir = "$newStructure\01-climate-control"
New-Item -ItemType Directory -Path "$climateDir\aircon-system" -Force | Out-Null
New-Item -ItemType Directory -Path "$climateDir\heating-control" -Force | Out-Null
New-Item -ItemType Directory -Path "$climateDir\humidity-management" -Force | Out-Null

# 建立燈光自動化子目錄
$lightingDir = "$newStructure\02-lighting-automation"
New-Item -ItemType Directory -Path "$lightingDir\indoor-lighting" -Force | Out-Null
New-Item -ItemType Directory -Path "$lightingDir\outdoor-lighting" -Force | Out-Null
New-Item -ItemType Directory -Path "$lightingDir\smart-switches" -Force | Out-Null

# 建立窗簾自動化子目錄
$windowDir = "$newStructure\03-window-treatments"
New-Item -ItemType Directory -Path "$windowDir\motorized-curtains" -Force | Out-Null
New-Item -ItemType Directory -Path "$windowDir\blinds-control" -Force | Out-Null
New-Item -ItemType Directory -Path "$windowDir\schedule-automation" -Force | Out-Null

# 建立電氣監控子目錄
$electricalDir = "$newStructure\04-electrical-monitoring"
New-Item -ItemType Directory -Path "$electricalDir\power-monitoring" -Force | Out-Null
New-Item -ItemType Directory -Path "$electricalDir\battery-management" -Force | Out-Null
New-Item -ItemType Directory -Path "$electricalDir\device-notifications" -Force | Out-Null

# 建立安全防護子目錄
$securityDir = "$newStructure\05-security-safety"
New-Item -ItemType Directory -Path "$securityDir\door-locks" -Force | Out-Null
New-Item -ItemType Directory -Path "$securityDir\cameras" -Force | Out-Null
New-Item -ItemType Directory -Path "$securityDir\alarm-system" -Force | Out-Null

# 建立娛樂系統子目錄
$entertainmentDir = "$newStructure\06-entertainment"
New-Item -ItemType Directory -Path "$entertainmentDir\audio-control" -Force | Out-Null
New-Item -ItemType Directory -Path "$entertainmentDir\tv-automation" -Force | Out-Null
New-Item -ItemType Directory -Path "$entertainmentDir\media-center" -Force | Out-Null

# 建立通知系統子目錄
$notificationsDir = "$newStructure\07-notifications"
New-Item -ItemType Directory -Path "$notificationsDir\multi-platform" -Force | Out-Null
New-Item -ItemType Directory -Path "$notificationsDir\alert-rules" -Force | Out-Null
New-Item -ItemType Directory -Path "$notificationsDir\message-templates" -Force | Out-Null

# 建立整合服務子目錄
$integrationsDir = "$newStructure\08-integrations"
New-Item -ItemType Directory -Path "$integrationsDir\weather-service" -Force | Out-Null
New-Item -ItemType Directory -Path "$integrationsDir\calendar-sync" -Force | Out-Null
New-Item -ItemType Directory -Path "$integrationsDir\voice-assistants" -Force | Out-Null

# 建立共用目錄
New-Item -ItemType Directory -Path "$newStructure\shared-tools" -Force | Out-Null
New-Item -ItemType Directory -Path "$newStructure\docs" -Force | Out-Null
New-Item -ItemType Directory -Path "$newStructure\configs" -Force | Out-Null

Write-Host "目錄結構建立完成" -ForegroundColor Green

# 移動現有檔案
Write-Host "移動現有檔案..." -ForegroundColor Yellow

# 移動空調系統
if (Test-Path "01-home-assistant-personal\aircon-system") {
    Copy-Item "01-home-assistant-personal\aircon-system\*" "$climateDir\aircon-system\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  空調系統已移動到氣候控制" -ForegroundColor Gray
}

# 移動電池管理
if (Test-Path "01-home-assistant-personal\battery-management") {
    Copy-Item "01-home-assistant-personal\battery-management\*" "$electricalDir\battery-management\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  電池管理已移動到電氣監控" -ForegroundColor Gray
}

# 移動通知系統
if (Test-Path "01-home-assistant-personal\notifications") {
    Copy-Item "01-home-assistant-personal\notifications\*" "$notificationsDir\multi-platform\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  通知系統已移動" -ForegroundColor Gray
}

# 移動共用工具
if (Test-Path "01-home-assistant-personal\shared-tools") {
    Copy-Item "01-home-assistant-personal\shared-tools\*" "$newStructure\shared-tools\" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  共用工具已移動" -ForegroundColor Gray
}

# 移動文檔檔案
Get-ChildItem "01-home-assistant-personal\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item $_.FullName "$newStructure\docs\" -Force -ErrorAction SilentlyContinue
    Write-Host "  文檔 $($_.Name) 已移動" -ForegroundColor Gray
}

Write-Host "檔案移動完成" -ForegroundColor Green

# 建立主 README
Write-Host "建立說明文檔..." -ForegroundColor Yellow

$mainReadme = @"
# 家庭 Home Assistant 自動化系統 v2.0

這是重新組織後的家庭自動化系統，按功能領域分類管理。

## 系統架構

### 功能領域分類
- 01-climate-control/ - 氣候控制
- 02-lighting-automation/ - 燈光自動化
- 03-window-treatments/ - 窗簾自動化
- 04-electrical-monitoring/ - 電氣設備監控
- 05-security-safety/ - 安全防護
- 06-entertainment/ - 娛樂系統
- 07-notifications/ - 通知系統
- 08-integrations/ - 整合服務

### 共用資源
- shared-tools/ - 跨領域共用工具
- docs/ - 系統文檔和說明
- configs/ - 全域配置檔案

## 快速導航

### 氣候控制
- 空調三系統 (01-climate-control/aircon-system/)
- 暖氣控制 (01-climate-control/heating-control/)
- 濕度管理 (01-climate-control/humidity-management/)

### 燈光自動化
- 室內燈光 (02-lighting-automation/indoor-lighting/)
- 戶外燈光 (02-lighting-automation/outdoor-lighting/)
- 智能開關 (02-lighting-automation/smart-switches/)

### 窗簾自動化
- 電動窗簾 (03-window-treatments/motorized-curtains/)
- 百葉窗控制 (03-window-treatments/blinds-control/)
- 排程自動化 (03-window-treatments/schedule-automation/)

### 電氣設備監控
- 電力監控 (04-electrical-monitoring/power-monitoring/)
- 電池管理 (04-electrical-monitoring/battery-management/)
- 設備通知 (04-electrical-monitoring/device-notifications/)

### 安全防護
- 門鎖控制 (05-security-safety/door-locks/)
- 攝影機系統 (05-security-safety/cameras/)
- 警報系統 (05-security-safety/alarm-system/)

### 娛樂系統
- 音響控制 (06-entertainment/audio-control/)
- 電視自動化 (06-entertainment/tv-automation/)
- 媒體中心 (06-entertainment/media-center/)

### 通知系統
- 多平台通知 (07-notifications/multi-platform/)
- 警報規則 (07-notifications/alert-rules/)
- 訊息範本 (07-notifications/message-templates/)

### 整合服務
- 天氣服務 (08-integrations/weather-service/)
- 行事曆同步 (08-integrations/calendar-sync/)
- 語音助手 (08-integrations/voice-assistants/)

## 項目管理

### 新增功能
1. 確定功能所屬的領域
2. 在對應目錄下建立子項目
3. 參考現有項目的結構
4. 更新相關文檔

### 維護指南
- 定期檢查各領域的自動化規則
- 監控設備狀態和效能
- 備份重要配置檔案
- 更新文檔和說明

## 版本控制

### 分支策略
- main - 穩定版本
- dev - 開發版本
- feature/* - 功能開發分支

### 提交規範
- feat: 新功能
- fix: 修復問題
- docs: 文檔更新
- config: 配置調整

## 工具和腳本

- 智能同步工具 (shared-tools/sync-scripts/)
- 配置管理工具 (shared-tools/config-manager/)
- 監控儀表板 (shared-tools/dashboard/)
- 備份還原工具 (shared-tools/backup-restore/)
"@

$mainReadme | Out-File -FilePath "$newStructure\README.md" -Encoding UTF8

# 為氣候控制建立 README
$climateReadme = @"
# 氣候控制

## 概述
這個目錄包含氣候控制相關的所有自動化配置和腳本。

## 子系統
- aircon-system/ - 空調三系統控制
- heating-control/ - 暖氣系統控制
- humidity-management/ - 濕度調節管理

## 快速開始
1. 進入對應的子目錄
2. 參考各自的 README.md 檔案
3. 按照說明進行配置和部署

## 配置檔案
- config.json - 主要配置
- devices.json - 設備清單
- automation.json - 自動化規則

## 注意事項
- 修改配置前請先備份
- 測試新功能時建議使用開發環境
- 定期檢查設備狀態和日誌
"@

$climateReadme | Out-File -FilePath "$climateDir\README.md" -Encoding UTF8

Write-Host "說明文檔建立完成" -ForegroundColor Green

Write-Host ""
Write-Host "========================================"
Write-Host "  重新組織完成！"
Write-Host "========================================"
Write-Host ""

Write-Host "新的系統結構：" -ForegroundColor Green
Write-Host "├── 01-climate-control/ - 氣候控制"
Write-Host "├── 02-lighting-automation/ - 燈光自動化"
Write-Host "├── 03-window-treatments/ - 窗簾自動化"
Write-Host "├── 04-electrical-monitoring/ - 電氣設備監控"
Write-Host "├── 05-security-safety/ - 安全防護"
Write-Host "├── 06-entertainment/ - 娛樂系統"
Write-Host "├── 07-notifications/ - 通知系統"
Write-Host "├── 08-integrations/ - 整合服務"
Write-Host "├── shared-tools/ - 共用工具"
Write-Host "├── docs/ - 文檔"
Write-Host "└── configs/ - 配置"

Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "1. 檢查新結構：cd $newStructure"
Write-Host "2. 測試功能是否正常"
Write-Host "3. 備份舊結構：Rename-Item 01-home-assistant-personal 01-home-assistant-personal-backup"
Write-Host "4. 啟用新結構：Rename-Item $newStructure 01-home-assistant-personal"
Write-Host "5. 提交到 GitHub"
Write-Host ""

Read-Host "按 Enter 鍵繼續..."
