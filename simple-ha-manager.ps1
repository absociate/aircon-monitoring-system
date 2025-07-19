# 簡化版家庭 HA 項目管理工具

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  🏠 家庭 HA 項目管理工具" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 檢查是否存在家庭 HA 目錄
$haDir = "01-home-assistant-personal"
if (!(Test-Path $haDir)) {
    Write-Host "❌ 找不到家庭 HA 系統目錄: $haDir" -ForegroundColor Red
    Write-Host "請確保在正確的目錄中執行此腳本" -ForegroundColor Yellow
    Read-Host "按 Enter 鍵退出..."
    exit 1
}

# 功能領域定義
$areas = @{
    "1" = @{ name = "01-climate-control"; desc = "🌡️ 氣候控制"; projects = @("aircon-system", "heating-control", "humidity-management") }
    "2" = @{ name = "02-lighting-automation"; desc = "💡 燈光自動化"; projects = @("indoor-lighting", "outdoor-lighting", "smart-switches") }
    "3" = @{ name = "03-window-treatments"; desc = "🪟 窗簾自動化"; projects = @("motorized-curtains", "blinds-control", "schedule-automation") }
    "4" = @{ name = "04-electrical-monitoring"; desc = "⚡ 電氣設備監控"; projects = @("power-monitoring", "battery-management", "device-notifications") }
    "5" = @{ name = "05-security-safety"; desc = "🔒 安全防護"; projects = @("door-locks", "cameras", "alarm-system") }
    "6" = @{ name = "06-entertainment"; desc = "🎵 娛樂系統"; projects = @("audio-control", "tv-automation", "media-center") }
    "7" = @{ name = "07-notifications"; desc = "🔔 通知系統"; projects = @("multi-platform", "alert-rules", "message-templates") }
    "8" = @{ name = "08-integrations"; desc = "🔗 整合服務"; projects = @("weather-service", "calendar-sync", "voice-assistants") }
}

function Get-ProjectStatus {
    param([string]$areaPath, [string]$projectName)
    
    $projectPath = "$haDir\$areaPath\$projectName"
    
    if (!(Test-Path $projectPath)) {
        return "❌ 未建立"
    }
    
    $files = Get-ChildItem $projectPath -File -ErrorAction SilentlyContinue
    if (!$files -or $files.Count -eq 0) {
        return "⚠️ 空項目"
    }
    
    if (Test-Path "$projectPath\README.md") {
        return "✅ 已完成"
    }
    
    $configFiles = $files | Where-Object { $_.Name -like "*.json" -or $_.Name -like "*.yaml" }
    if ($configFiles -and $configFiles.Count -gt 0) {
        return "🔧 開發中"
    }
    
    return "📝 規劃中"
}

function Show-MainMenu {
    Write-Host "選擇功能領域：" -ForegroundColor Green
    foreach ($key in $areas.Keys | Sort-Object) {
        $area = $areas[$key]
        Write-Host "$key. $($area.desc)" -ForegroundColor White
    }
    Write-Host "9. 📊 項目總覽" -ForegroundColor White
    Write-Host "0. 🚪 退出" -ForegroundColor White
    Write-Host ""
}

function Show-AreaProjects {
    param([hashtable]$area)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  $($area.desc)" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "現有項目：" -ForegroundColor Green
    $index = 1
    foreach ($project in $area.projects) {
        $status = Get-ProjectStatus -areaPath $area.name -projectName $project
        Write-Host "$index. $project $status" -ForegroundColor White
        $index++
    }
    
    Write-Host ""
    Write-Host "操作選項：" -ForegroundColor Green
    Write-Host "$index. 🆕 新增項目" -ForegroundColor White
    Write-Host "0. 🔙 返回主選單" -ForegroundColor White
    Write-Host ""
}

function New-Project {
    param([hashtable]$area)
    
    Write-Host ""
    Write-Host "🆕 新增項目到 $($area.desc)" -ForegroundColor Green
    Write-Host ""
    
    $projectName = Read-Host "請輸入項目名稱 (例如: smart-thermostat)"
    if (!$projectName) {
        Write-Host "❌ 項目名稱不能為空" -ForegroundColor Red
        return
    }
    
    $projectPath = "$haDir\$($area.name)\$projectName"
    
    if (Test-Path $projectPath) {
        Write-Host "⚠️ 項目已存在：$projectPath" -ForegroundColor Yellow
        return
    }
    
    # 建立項目目錄
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    
    # 建立基本檔案
    $description = Read-Host "請輸入項目描述"
    
    # 建立 README
    $readme = @"
# $projectName

## 概述
$description

## 功能特點
- [ ] 功能 1
- [ ] 功能 2
- [ ] 功能 3

## 配置檔案
- config.json - 主要配置
- devices.json - 設備清單
- automation.json - 自動化規則

## 安裝步驟
1. 複製配置檔案到 Home Assistant
2. 重新啟動 Home Assistant
3. 檢查設備狀態
4. 測試自動化規則

## 注意事項
- 修改配置前請先備份
- 測試新功能時建議使用開發環境

## 更新日誌
- $(Get-Date -Format 'yyyy-MM-dd') - 項目建立
"@
    
    $readme | Out-File -FilePath "$projectPath\README.md" -Encoding UTF8
    
    # 建立基本配置檔案
    $config = @{
        project_name = $projectName
        description = $description
        area = $area.name
        created_date = (Get-Date -Format 'yyyy-MM-dd')
        version = "1.0.0"
        dependencies = @()
        devices = @()
        automations = @()
    }
    
    $config | ConvertTo-Json -Depth 3 | Out-File -FilePath "$projectPath\config.json" -Encoding UTF8
    
    Write-Host "✅ 項目建立成功：$projectPath" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步建議：" -ForegroundColor Yellow
    Write-Host "1. 編輯 README.md 完善項目說明" -ForegroundColor White
    Write-Host "2. 配置 config.json 設定項目參數" -ForegroundColor White
    Write-Host "3. 新增 Node-RED 流程檔案" -ForegroundColor White
    Write-Host "4. 測試功能並更新文檔" -ForegroundColor White
}

function Show-ProjectOverview {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  📊 項目總覽" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    $totalProjects = 0
    $completedProjects = 0
    $inProgressProjects = 0
    $emptyProjects = 0
    
    foreach ($key in $areas.Keys | Sort-Object) {
        $area = $areas[$key]
        Write-Host "$($area.desc)：" -ForegroundColor Green
        
        foreach ($project in $area.projects) {
            $status = Get-ProjectStatus -areaPath $area.name -projectName $project
            Write-Host "  • $project $status" -ForegroundColor White
            
            $totalProjects++
            if ($status -like "*完成*") { 
                $completedProjects++ 
            } elseif ($status -like "*開發中*") { 
                $inProgressProjects++ 
            } elseif ($status -like "*空項目*") {
                $emptyProjects++
            }
        }
        Write-Host ""
    }
    
    Write-Host "統計資訊：" -ForegroundColor Yellow
    Write-Host "  總項目數：$totalProjects" -ForegroundColor White
    Write-Host "  已完成：$completedProjects" -ForegroundColor Green
    Write-Host "  開發中：$inProgressProjects" -ForegroundColor Blue
    Write-Host "  空項目：$emptyProjects" -ForegroundColor Gray
    Write-Host "  待開始：$($totalProjects - $completedProjects - $inProgressProjects - $emptyProjects)" -ForegroundColor Yellow
    
    if ($totalProjects -gt 0) {
        $completionRate = [math]::Round(($completedProjects / $totalProjects) * 100, 1)
        Write-Host "  完成率：$completionRate%" -ForegroundColor Cyan
    }
}

# 主程式邏輯
while ($true) {
    Show-MainMenu
    $choice = Read-Host "請選擇 (0-9)"
    
    if ($choice -eq "0") {
        Write-Host "👋 再見！" -ForegroundColor Green
        break
    } elseif ($choice -eq "9") {
        Show-ProjectOverview
        Read-Host "按 Enter 繼續..."
    } elseif ($areas.ContainsKey($choice)) {
        $selectedArea = $areas[$choice]
        
        while ($true) {
            Show-AreaProjects -area $selectedArea
            $areaChoice = Read-Host "請選擇操作"
            
            if ($areaChoice -eq "0") {
                break
            } elseif ($areaChoice -eq ($selectedArea.projects.Count + 1).ToString()) {
                New-Project -area $selectedArea
                Read-Host "按 Enter 繼續..."
            } elseif ([int]$areaChoice -ge 1 -and [int]$areaChoice -le $selectedArea.projects.Count) {
                $projectIndex = [int]$areaChoice - 1
                $selectedProject = $selectedArea.projects[$projectIndex]
                $projectPath = "$haDir\$($selectedArea.name)\$selectedProject"
                
                Write-Host ""
                Write-Host "📁 項目：$selectedProject" -ForegroundColor Blue
                Write-Host "路徑：$projectPath" -ForegroundColor Gray
                Write-Host "狀態：$(Get-ProjectStatus -areaPath $selectedArea.name -projectName $selectedProject)" -ForegroundColor Gray
                
                if (Test-Path $projectPath) {
                    Write-Host ""
                    Write-Host "項目檔案：" -ForegroundColor Green
                    Get-ChildItem $projectPath | ForEach-Object {
                        $icon = if ($_.PSIsContainer) { "📁" } else { "📄" }
                        Write-Host "  $icon $($_.Name)" -ForegroundColor White
                    }
                    
                    Write-Host ""
                    $openProject = Read-Host "是否要開啟項目目錄？(y/n)"
                    if ($openProject -eq "y") {
                        Start-Process explorer $projectPath
                    }
                } else {
                    Write-Host "❌ 項目目錄不存在" -ForegroundColor Red
                }
                
                Read-Host "按 Enter 繼續..."
            } else {
                Write-Host "❌ 無效選項" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "❌ 無效選項，請重新選擇" -ForegroundColor Red
    }
}
