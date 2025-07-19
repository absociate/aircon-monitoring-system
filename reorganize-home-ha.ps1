# 家庭 HA 系統重新組織腳本
# 按功能領域重新整理項目結構

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  家庭 HA 系統重新組織工具" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 檢查是否在正確目錄
if (!(Test-Path "01-home-assistant-personal")) {
    Write-Host "❌ 找不到家庭 HA 系統目錄" -ForegroundColor Red
    Write-Host "請確保在包含 01-home-assistant-personal 的目錄中執行" -ForegroundColor Yellow
    exit 1
}

Write-Host "[資訊] 開始重新組織家庭 HA 系統..." -ForegroundColor Green

# 建立新的功能領域目錄結構
$functionalAreas = @{
    "01-climate-control" = @{
        "description" = "🌡️ 氣候控制"
        "subdirs" = @("aircon-system", "heating-control", "humidity-management")
    }
    "02-lighting-automation" = @{
        "description" = "💡 燈光自動化"
        "subdirs" = @("indoor-lighting", "outdoor-lighting", "smart-switches")
    }
    "03-window-treatments" = @{
        "description" = "🪟 窗簾自動化"
        "subdirs" = @("motorized-curtains", "blinds-control", "schedule-automation")
    }
    "04-electrical-monitoring" = @{
        "description" = "⚡ 電氣設備監控"
        "subdirs" = @("power-monitoring", "battery-management", "device-notifications")
    }
    "05-security-safety" = @{
        "description" = "🔒 安全防護"
        "subdirs" = @("door-locks", "cameras", "alarm-system")
    }
    "06-entertainment" = @{
        "description" = "🎵 娛樂系統"
        "subdirs" = @("audio-control", "tv-automation", "media-center")
    }
    "07-notifications" = @{
        "description" = "🔔 通知系統"
        "subdirs" = @("multi-platform", "alert-rules", "message-templates")
    }
    "08-integrations" = @{
        "description" = "🔗 整合服務"
        "subdirs" = @("weather-service", "calendar-sync", "voice-assistants")
    }
}

# 建立新的目錄結構
Write-Host "[資訊] 建立新的功能領域目錄..." -ForegroundColor Yellow

$newStructure = "home-assistant-personal-v2"
New-Item -ItemType Directory -Path $newStructure -Force | Out-Null

foreach ($area in $functionalAreas.Keys) {
    $areaInfo = $functionalAreas[$area]
    
    # 建立主目錄
    $areaPath = "$newStructure\$area"
    New-Item -ItemType Directory -Path $areaPath -Force | Out-Null
    
    # 建立子目錄
    foreach ($subdir in $areaInfo.subdirs) {
        New-Item -ItemType Directory -Path "$areaPath\$subdir" -Force | Out-Null
    }
    
    Write-Host "  ✅ 建立 $($areaInfo.description)" -ForegroundColor Gray
}

# 建立共用目錄
New-Item -ItemType Directory -Path "$newStructure\shared-tools" -Force | Out-Null
New-Item -ItemType Directory -Path "$newStructure\docs" -Force | Out-Null
New-Item -ItemType Directory -Path "$newStructure\configs" -Force | Out-Null

Write-Host "[成功] 目錄結構建立完成" -ForegroundColor Green

# 移動現有檔案到對應的功能領域
Write-Host "[資訊] 移動現有檔案到對應功能領域..." -ForegroundColor Yellow

# 移動空調系統到氣候控制
if (Test-Path "01-home-assistant-personal\aircon-system") {
    Copy-Item "01-home-assistant-personal\aircon-system\*" "$newStructure\01-climate-control\aircon-system\" -Recurse -Force
    Write-Host "  📁 空調系統 → 氣候控制" -ForegroundColor Gray
}

# 移動電池管理到電氣監控
if (Test-Path "01-home-assistant-personal\battery-management") {
    Copy-Item "01-home-assistant-personal\battery-management\*" "$newStructure\04-electrical-monitoring\battery-management\" -Recurse -Force
    Write-Host "  🔋 電池管理 → 電氣監控" -ForegroundColor Gray
}

# 移動通知系統
if (Test-Path "01-home-assistant-personal\notifications") {
    Copy-Item "01-home-assistant-personal\notifications\*" "$newStructure\07-notifications\multi-platform\" -Recurse -Force
    Write-Host "  🔔 通知系統 → 通知系統" -ForegroundColor Gray
}

# 移動共用工具
if (Test-Path "01-home-assistant-personal\shared-tools") {
    Copy-Item "01-home-assistant-personal\shared-tools\*" "$newStructure\shared-tools\" -Recurse -Force
    Write-Host "  🛠️ 共用工具 → 共用工具" -ForegroundColor Gray
}

# 移動文檔
Get-ChildItem "01-home-assistant-personal\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-Item $_.FullName "$newStructure\docs\" -Force
    Write-Host "  📚 $($_.Name) → 文檔" -ForegroundColor Gray
}

Write-Host "[成功] 檔案移動完成" -ForegroundColor Green

# 為每個功能領域建立 README
Write-Host "[資訊] 建立功能領域說明文檔..." -ForegroundColor Yellow

foreach ($area in $functionalAreas.Keys) {
    $areaInfo = $functionalAreas[$area]
    $areaPath = "$newStructure\$area"
    
    $readme = @"
# $($areaInfo.description)

## 概述
這個目錄包含 $($areaInfo.description.Substring(2)) 相關的所有自動化配置和腳本。

## 子系統
"@
    
    foreach ($subdir in $areaInfo.subdirs) {
        $readme += "`n- **$subdir/** - $(Get-SubdirDescription -subdir $subdir)"
    }
    
    $readme += @"

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
    
    $readme | Out-File -FilePath "$areaPath\README.md" -Encoding UTF8
}

# 建立主 README
$mainReadme = @"
# 🏠 家庭 Home Assistant 自動化系統 v2.0

這是重新組織後的家庭自動化系統，按功能領域分類管理。

## 🎯 系統架構

### 功能領域分類
"@

foreach ($area in $functionalAreas.Keys) {
    $areaInfo = $functionalAreas[$area]
    $mainReadme += "`n- **$area/** - $($areaInfo.description)"
}

$mainReadme += @"

### 共用資源
- **shared-tools/** - 🛠️ 跨領域共用工具
- **docs/** - 📚 系統文檔和說明
- **configs/** - ⚙️ 全域配置檔案

## 🚀 快速導航

### 🌡️ 氣候控制
- [空調三系統](01-climate-control/aircon-system/)
- [暖氣控制](01-climate-control/heating-control/)
- [濕度管理](01-climate-control/humidity-management/)

### 💡 燈光自動化
- [室內燈光](02-lighting-automation/indoor-lighting/)
- [戶外燈光](02-lighting-automation/outdoor-lighting/)
- [智能開關](02-lighting-automation/smart-switches/)

### 🪟 窗簾自動化
- [電動窗簾](03-window-treatments/motorized-curtains/)
- [百葉窗控制](03-window-treatments/blinds-control/)
- [排程自動化](03-window-treatments/schedule-automation/)

### ⚡ 電氣設備監控
- [電力監控](04-electrical-monitoring/power-monitoring/)
- [電池管理](04-electrical-monitoring/battery-management/)
- [設備通知](04-electrical-monitoring/device-notifications/)

### 🔒 安全防護
- [門鎖控制](05-security-safety/door-locks/)
- [攝影機系統](05-security-safety/cameras/)
- [警報系統](05-security-safety/alarm-system/)

### 🎵 娛樂系統
- [音響控制](06-entertainment/audio-control/)
- [電視自動化](06-entertainment/tv-automation/)
- [媒體中心](06-entertainment/media-center/)

### 🔔 通知系統
- [多平台通知](07-notifications/multi-platform/)
- [警報規則](07-notifications/alert-rules/)
- [訊息範本](07-notifications/message-templates/)

### 🔗 整合服務
- [天氣服務](08-integrations/weather-service/)
- [行事曆同步](08-integrations/calendar-sync/)
- [語音助手](08-integrations/voice-assistants/)

## 📋 項目管理

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

## 🔄 版本控制

### 分支策略
- main - 穩定版本
- dev - 開發版本
- feature/* - 功能開發分支

### 提交規範
- feat: 新功能
- fix: 修復問題
- docs: 文檔更新
- config: 配置調整

## 🛠️ 工具和腳本

- [智能同步工具](shared-tools/sync-scripts/)
- [配置管理工具](shared-tools/config-manager/)
- [監控儀表板](shared-tools/dashboard/)
- [備份還原工具](shared-tools/backup-restore/)

## 📞 支援

如有問題請參考：
1. 各功能領域的 README.md
2. docs/ 目錄中的詳細文檔
3. GitHub Issues 回報問題
"@

$mainReadme | Out-File -FilePath "$newStructure\README.md" -Encoding UTF8

Write-Host "[成功] 說明文檔建立完成" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Blue
Write-Host "  重新組織完成！" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

Write-Host "新的系統結構：" -ForegroundColor Green
foreach ($area in $functionalAreas.Keys) {
    $areaInfo = $functionalAreas[$area]
    Write-Host "├── $area/ - $($areaInfo.description)" -ForegroundColor White
}
Write-Host "├── shared-tools/ - 🛠️ 共用工具" -ForegroundColor White
Write-Host "├── docs/ - 📚 文檔" -ForegroundColor White
Write-Host "└── configs/ - ⚙️ 配置" -ForegroundColor White

Write-Host ""
Write-Host "下一步：" -ForegroundColor Yellow
Write-Host "1. 檢查新結構：cd $newStructure" -ForegroundColor White
Write-Host "2. 測試功能是否正常" -ForegroundColor White
Write-Host "3. 備份舊結構：mv 01-home-assistant-personal 01-home-assistant-personal-backup" -ForegroundColor White
Write-Host "4. 啟用新結構：mv $newStructure 01-home-assistant-personal" -ForegroundColor White
Write-Host "5. 提交到 GitHub" -ForegroundColor White
Write-Host ""

# 輔助函數
function Get-SubdirDescription {
    param([string]$subdir)
    
    $descriptions = @{
        "aircon-system" = "空調三系統控制"
        "heating-control" = "暖氣系統控制"
        "humidity-management" = "濕度調節管理"
        "indoor-lighting" = "室內燈光控制"
        "outdoor-lighting" = "戶外照明系統"
        "smart-switches" = "智能開關管理"
        "motorized-curtains" = "電動窗簾控制"
        "blinds-control" = "百葉窗自動化"
        "schedule-automation" = "時程自動化"
        "power-monitoring" = "電力使用監控"
        "battery-management" = "電池充電管理"
        "device-notifications" = "設備狀態通知"
        "door-locks" = "智能門鎖控制"
        "cameras" = "監控攝影系統"
        "alarm-system" = "安全警報系統"
        "audio-control" = "音響系統控制"
        "tv-automation" = "電視自動化"
        "media-center" = "媒體中心管理"
        "multi-platform" = "多平台通知整合"
        "alert-rules" = "警報規則設定"
        "message-templates" = "通知訊息範本"
        "weather-service" = "天氣資訊整合"
        "calendar-sync" = "行事曆同步"
        "voice-assistants" = "語音助手整合"
    }
    
    return $descriptions[$subdir] ?? "功能模組"
}

Read-Host "按 Enter 鍵繼續..."
