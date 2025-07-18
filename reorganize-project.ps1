# 專案重新組織腳本 (PowerShell 版本)
# 將現有檔案按照類別重新整理

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  專案重新組織工具" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

Write-Host "[資訊] 開始重新組織專案結構..." -ForegroundColor Green

# 建立主要目錄結構
Write-Host "[資訊] 建立目錄結構..." -ForegroundColor Yellow

$directories = @(
    "01-home-assistant-personal",
    "01-home-assistant-personal\aircon-system",
    "01-home-assistant-personal\battery-management", 
    "01-home-assistant-personal\notifications",
    "02-home-assistant-office",
    "02-home-assistant-office\office-automation",
    "03-lab-management-system",
    "03-lab-management-system\equipment-monitoring",
    "shared-tools",
    "shared-tools\sync-scripts",
    "shared-tools\templates",
    "archive"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  建立目錄: $dir" -ForegroundColor Gray
    }
}

Write-Host "[成功] 目錄結構建立完成" -ForegroundColor Green

# 移動空調系統相關檔案
Write-Host "[資訊] 移動空調系統檔案..." -ForegroundColor Yellow

$airconFiles = @(
    "README-aircon-notifications.md",
    "device-mapping.json",
    "notification-config.js",
    "notification-config.example.js",
    "test-notifications.js"
)

foreach ($file in $airconFiles) {
    if (Test-Path $file) {
        Move-Item $file "01-home-assistant-personal\aircon-system\" -Force
        Write-Host "  移動: $file" -ForegroundColor Gray
    }
}

# 移動所有 aircon-notification-*.json 檔案
Get-ChildItem -Name "aircon-notification-*.json" | ForEach-Object {
    Move-Item $_ "01-home-assistant-personal\aircon-system\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

# 移動安裝腳本
Get-ChildItem -Name "install-aircon-notifications.*" | ForEach-Object {
    Move-Item $_ "01-home-assistant-personal\aircon-system\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

# 移動電池管理相關檔案
Write-Host "[資訊] 移動電池管理檔案..." -ForegroundColor Yellow

$batteryFiles = @(
    "README-battery-charging.md",
    "battery-config.js",
    "battery-helpers.yaml",
    "install-battery-management.sh"
)

foreach ($file in $batteryFiles) {
    if (Test-Path $file) {
        Move-Item $file "01-home-assistant-personal\battery-management\" -Force
        Write-Host "  移動: $file" -ForegroundColor Gray
    }
}

# 移動所有 battery-*.json 檔案
Get-ChildItem -Name "battery-*.json" | ForEach-Object {
    Move-Item $_ "01-home-assistant-personal\battery-management\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

# 移動通知系統檔案
Write-Host "[資訊] 移動通知系統檔案..." -ForegroundColor Yellow

$notificationFiles = @(
    "notifyhelper-test-only.json"
)

foreach ($file in $notificationFiles) {
    if (Test-Path $file) {
        Move-Item $file "01-home-assistant-personal\notifications\" -Force
        Write-Host "  移動: $file" -ForegroundColor Gray
    }
}

# 移動 NotifyHelper 相關檔案
Get-ChildItem -Name "*NotifyHelper*" | ForEach-Object {
    Move-Item $_ "01-home-assistant-personal\notifications\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

# 移動同步工具
Write-Host "[資訊] 移動同步工具..." -ForegroundColor Yellow

$syncFiles = @(
    "GitHub同步快速開始.md",
    "aircon-system-sync-guide.md"
)

foreach ($file in $syncFiles) {
    if (Test-Path $file) {
        Move-Item $file "shared-tools\sync-scripts\" -Force
        Write-Host "  移動: $file" -ForegroundColor Gray
    }
}

# 移動同步腳本
Get-ChildItem -Name "sync-*" | ForEach-Object {
    Move-Item $_ "shared-tools\sync-scripts\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

# 移動其他檔案到歸檔
Write-Host "[資訊] 移動其他檔案到歸檔..." -ForegroundColor Yellow

$archiveFiles = @(
    "3d-alphabet-generator.html",
    "example-letter-E.html", 
    "professional-3d-generator.html",
    "letter-templates.js"
)

foreach ($file in $archiveFiles) {
    if (Test-Path $file) {
        Move-Item $file "archive\" -Force
        Write-Host "  移動到歸檔: $file" -ForegroundColor Gray
    }
}

# 移動 VBA 檔案
Get-ChildItem -Name "*.vba" | ForEach-Object {
    Move-Item $_ "archive\" -Force
    Write-Host "  移動到歸檔: $_" -ForegroundColor Gray
}

# 移動樹莓派相關檔案
Get-ChildItem -Name "*樹莓派*" | ForEach-Object {
    Move-Item $_ "01-home-assistant-personal\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

# 移動使用指南
Get-ChildItem -Name "*使用指南*" | ForEach-Object {
    Move-Item $_ "01-home-assistant-personal\aircon-system\" -Force
    Write-Host "  移動: $_" -ForegroundColor Gray
}

Write-Host "[成功] 檔案移動完成" -ForegroundColor Green

# 建立各目錄的 README 檔案
Write-Host "[資訊] 建立說明文檔..." -ForegroundColor Yellow

# 家裡 HA 系統 README
$homeHaReadme = @"
# 家裡的 Home Assistant 系統

這個目錄包含家裡 Home Assistant 的所有配置和自動化腳本。

## 子系統
- **aircon-system/** - 空調三系統監控
- **battery-management/** - 電池充電管理  
- **notifications/** - 通知系統配置

## 快速開始
1. 進入對應的子目錄
2. 參考各自的 README.md 檔案
3. 按照說明進行配置和部署

## 設備清單
- 樹莓派 4B (主控制器)
- 5個空調設備
- ENELOOP 電池充電器
- 多種通知服務
"@

$homeHaReadme | Out-File -FilePath "01-home-assistant-personal\README.md" -Encoding UTF8

# 公司 HA 系統 README
$officeHaReadme = @"
# 公司的 Home Assistant 系統

這個目錄包含公司 Home Assistant 的配置和辦公室自動化腳本。

## 子系統
- **office-automation/** - 辦公室自動化

## 注意事項
- 配置檔案需要根據公司環境調整
- 注意網路安全和權限設定
- 定期備份重要配置
"@

$officeHaReadme | Out-File -FilePath "02-home-assistant-office\README.md" -Encoding UTF8

# 實驗管理系統 README
$labReadme = @"
# 實驗管理系統

這個目錄包含實驗室設備監控和管理系統。

## 子系統
- **equipment-monitoring/** - 設備監控

## 功能規劃
- 設備狀態監控
- 資料收集和分析
- 自動報告生成
- 異常警報系統
"@

$labReadme | Out-File -FilePath "03-lab-management-system\README.md" -Encoding UTF8

# 共用工具 README
$toolsReadme = @"
# 共用工具

這個目錄包含跨專案使用的工具和腳本。

## 子目錄
- **sync-scripts/** - GitHub 同步腳本
- **templates/** - 範本檔案

## 使用方式
1. 選擇適合的工具
2. 參考工具說明文檔
3. 根據需要進行配置
"@

$toolsReadme | Out-File -FilePath "shared-tools\README.md" -Encoding UTF8

Write-Host "[成功] 說明文檔建立完成" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Blue
Write-Host "  重新組織完成！" -ForegroundColor Blue  
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""
Write-Host "新的專案結構：" -ForegroundColor Green
Write-Host "├── 01-home-assistant-personal/" -ForegroundColor White
Write-Host "│   ├── aircon-system/" -ForegroundColor White
Write-Host "│   ├── battery-management/" -ForegroundColor White
Write-Host "│   └── notifications/" -ForegroundColor White
Write-Host "├── 02-home-assistant-office/" -ForegroundColor White
Write-Host "├── 03-lab-management-system/" -ForegroundColor White
Write-Host "├── shared-tools/" -ForegroundColor White
Write-Host "└── archive/" -ForegroundColor White
Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "1. 檢查檔案是否都移動到正確位置" -ForegroundColor White
Write-Host "2. 更新 .gitignore 檔案" -ForegroundColor White
Write-Host "3. 重新提交到 GitHub" -ForegroundColor White
Write-Host ""
Read-Host "按 Enter 鍵繼續..."
