# 家庭 HA 項目管理工具
# 管理多個自動化項目的工具

param(
    [string]$Action = "",
    [string]$Area = "",
    [string]$Project = ""
)

$functionalAreas = @{
    "climate" = @{
        "name" = "01-climate-control"
        "icon" = "🌡️"
        "description" = "氣候控制"
        "projects" = @("aircon-system", "heating-control", "humidity-management")
    }
    "lighting" = @{
        "name" = "02-lighting-automation"
        "icon" = "💡"
        "description" = "燈光自動化"
        "projects" = @("indoor-lighting", "outdoor-lighting", "smart-switches")
    }
    "window" = @{
        "name" = "03-window-treatments"
        "icon" = "🪟"
        "description" = "窗簾自動化"
        "projects" = @("motorized-curtains", "blinds-control", "schedule-automation")
    }
    "electrical" = @{
        "name" = "04-electrical-monitoring"
        "icon" = "⚡"
        "description" = "電氣監控"
        "projects" = @("power-monitoring", "battery-management", "device-notifications")
    }
    "security" = @{
        "name" = "05-security-safety"
        "icon" = "🔒"
        "description" = "安全防護"
        "projects" = @("door-locks", "cameras", "alarm-system")
    }
    "entertainment" = @{
        "name" = "06-entertainment"
        "icon" = "🎵"
        "description" = "娛樂系統"
        "projects" = @("audio-control", "tv-automation", "media-center")
    }
    "notifications" = @{
        "name" = "07-notifications"
        "icon" = "🔔"
        "description" = "通知系統"
        "projects" = @("multi-platform", "alert-rules", "message-templates")
    }
    "integrations" = @{
        "name" = "08-integrations"
        "icon" = "🔗"
        "description" = "整合服務"
        "projects" = @("weather-service", "calendar-sync", "voice-assistants")
    }
}

function Show-MainMenu {
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  🏠 家庭 HA 項目管理工具" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "選擇功能領域：" -ForegroundColor Green
    $index = 1
    foreach ($key in $functionalAreas.Keys) {
        $area = $functionalAreas[$key]
        Write-Host "$index. $($area.icon) $($area.description)" -ForegroundColor White
        $index++
    }
    Write-Host "$index. 📊 項目總覽" -ForegroundColor White
    Write-Host "$($index + 1). 🆕 新增項目" -ForegroundColor White
    Write-Host "$($index + 2). 🔄 同步所有項目" -ForegroundColor White
    Write-Host "$($index + 3). 🚪 退出" -ForegroundColor White
    Write-Host ""
}

function Show-AreaMenu {
    param([hashtable]$area, [string]$areaKey)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  $($area.icon) $($area.description)" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "現有項目：" -ForegroundColor Green
    $index = 1
    foreach ($project in $area.projects) {
        $status = Get-ProjectStatus -area $area.name -project $project
        Write-Host "$index. $project $status" -ForegroundColor White
        $index++
    }
    
    Write-Host ""
    Write-Host "操作選項：" -ForegroundColor Green
    Write-Host "$index. 🆕 新增項目" -ForegroundColor White
    Write-Host "$($index + 1). 📊 檢查所有項目狀態" -ForegroundColor White
    Write-Host "$($index + 2). 🔄 同步此領域" -ForegroundColor White
    Write-Host "$($index + 3). 🔙 返回主選單" -ForegroundColor White
    Write-Host ""
}

function Show-ProjectMenu {
    param([string]$areaName, [string]$projectName)
    
    $projectPath = "01-home-assistant-personal\$areaName\$projectName"
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  📁 $projectName" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    if (Test-Path $projectPath) {
        Write-Host "項目路徑：$projectPath" -ForegroundColor Gray
        Write-Host "項目狀態：$(Get-ProjectStatus -area $areaName -project $projectName)" -ForegroundColor Gray
        
        # 顯示項目檔案
        Write-Host ""
        Write-Host "項目檔案：" -ForegroundColor Green
        Get-ChildItem $projectPath | ForEach-Object {
            $icon = if ($_.PSIsContainer) { "📁" } else { "📄" }
            Write-Host "  $icon $($_.Name)" -ForegroundColor White
        }
    } else {
        Write-Host "⚠️ 項目目錄不存在：$projectPath" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "操作選項：" -ForegroundColor Green
    Write-Host "1. 📝 編輯項目" -ForegroundColor White
    Write-Host "2. 🔧 檢查配置" -ForegroundColor White
    Write-Host "3. 📊 查看狀態" -ForegroundColor White
    Write-Host "4. 🔄 同步項目" -ForegroundColor White
    Write-Host "5. 📚 查看文檔" -ForegroundColor White
    Write-Host "6. 🔙 返回上級" -ForegroundColor White
    Write-Host ""
}

function Get-ProjectStatus {
    param([string]$area, [string]$project)
    
    $projectPath = "01-home-assistant-personal\$area\$project"
    
    if (!(Test-Path $projectPath)) {
        return "❌ 未建立"
    }
    
    $files = Get-ChildItem $projectPath -File
    if ($files.Count -eq 0) {
        return "⚠️ 空項目"
    }
    
    # 檢查是否有 README
    if (Test-Path "$projectPath\README.md") {
        return "✅ 已完成"
    }
    
    # 檢查是否有配置檔案
    $configFiles = $files | Where-Object { $_.Name -like "*.json" -or $_.Name -like "*.yaml" }
    if ($configFiles.Count -gt 0) {
        return "🔧 開發中"
    }
    
    return "📝 規劃中"
}

function New-Project {
    param([string]$areaName, [string]$areaKey)
    
    Write-Host ""
    Write-Host "🆕 新增項目到 $($functionalAreas[$areaKey].description)" -ForegroundColor Green
    Write-Host ""
    
    $projectName = Read-Host "請輸入項目名稱 (例如: smart-thermostat)"
    if (!$projectName) {
        Write-Host "❌ 項目名稱不能為空" -ForegroundColor Red
        return
    }
    
    $projectPath = "01-home-assistant-personal\$areaName\$projectName"
    
    if (Test-Path $projectPath) {
        Write-Host "⚠️ 項目已存在：$projectPath" -ForegroundColor Yellow
        return
    }
    
    # 建立項目目錄
    New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
    
    # 建立基本檔案結構
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
        "project_name" = $projectName
        "description" = $description
        "area" = $areaName
        "created_date" = (Get-Date -Format 'yyyy-MM-dd')
        "version" = "1.0.0"
        "dependencies" = @()
        "devices" = @()
        "automations" = @()
    }
    
    $config | ConvertTo-Json -Depth 3 | Out-File -FilePath "$projectPath\config.json" -Encoding UTF8
    
    # 建立 .gitkeep 檔案確保目錄被追蹤
    "" | Out-File -FilePath "$projectPath\.gitkeep" -Encoding UTF8
    
    Write-Host "✅ 項目建立成功：$projectPath" -ForegroundColor Green
    
    # 更新功能領域的項目清單
    $functionalAreas[$areaKey].projects += $projectName
    
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
    
    foreach ($areaKey in $functionalAreas.Keys) {
        $area = $functionalAreas[$areaKey]
        Write-Host "$($area.icon) $($area.description)：" -ForegroundColor Green
        
        foreach ($project in $area.projects) {
            $status = Get-ProjectStatus -area $area.name -project $project
            Write-Host "  • $project $status" -ForegroundColor White
            
            $totalProjects++
            if ($status -like "*完成*") { $completedProjects++ }
            elseif ($status -like "*開發中*") { $inProgressProjects++ }
        }
        Write-Host ""
    }
    
    Write-Host "統計資訊：" -ForegroundColor Yellow
    Write-Host "  總項目數：$totalProjects" -ForegroundColor White
    Write-Host "  已完成：$completedProjects" -ForegroundColor Green
    Write-Host "  開發中：$inProgressProjects" -ForegroundColor Blue
    Write-Host "  待開始：$($totalProjects - $completedProjects - $inProgressProjects)" -ForegroundColor Gray
    
    $completionRate = if ($totalProjects -gt 0) { [math]::Round(($completedProjects / $totalProjects) * 100, 1) } else { 0 }
    Write-Host "  完成率：$completionRate%" -ForegroundColor Cyan
}

function Sync-AllProjects {
    Write-Host ""
    Write-Host "🔄 同步所有項目..." -ForegroundColor Green
    
    # 檢查 Git 狀態
    $status = git status --porcelain 2>$null
    if ($status) {
        Write-Host "發現未提交的變更：" -ForegroundColor Yellow
        git status --short
        
        $commit = Read-Host "是否要提交這些變更？(y/n)"
        if ($commit -eq "y") {
            $message = Read-Host "請輸入提交訊息"
            if (!$message) { $message = "更新家庭 HA 項目" }
            
            git add .
            git commit -m $message
            Write-Host "✅ 變更已提交" -ForegroundColor Green
        }
    }
    
    # 推送到 GitHub
    Write-Host "推送到 GitHub..." -ForegroundColor Yellow
    git push origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 同步完成" -ForegroundColor Green
    } else {
        Write-Host "❌ 同步失敗" -ForegroundColor Red
    }
}

# 主程式邏輯
if ($Action -and $Area) {
    # 命令列模式
    switch ($Action) {
        "list" {
            if ($functionalAreas.ContainsKey($Area)) {
                $areaInfo = $functionalAreas[$Area]
                Write-Host "$($areaInfo.description) 項目：" -ForegroundColor Green
                foreach ($project in $areaInfo.projects) {
                    $status = Get-ProjectStatus -area $areaInfo.name -project $project
                    Write-Host "  • $project $status" -ForegroundColor White
                }
            }
        }
        "new" {
            if ($functionalAreas.ContainsKey($Area) -and $Project) {
                New-Project -areaName $functionalAreas[$Area].name -areaKey $Area
            }
        }
        "overview" {
            Show-ProjectOverview
        }
    }
    exit
}

# 互動模式
while ($true) {
    Show-MainMenu
    $choice = Read-Host "請選擇 (1-$($functionalAreas.Count + 3))"
    
    $areaKeys = @($functionalAreas.Keys)
    
    if ($choice -ge 1 -and $choice -le $functionalAreas.Count) {
        $selectedAreaKey = $areaKeys[$choice - 1]
        $selectedArea = $functionalAreas[$selectedAreaKey]
        
        while ($true) {
            Show-AreaMenu -area $selectedArea -areaKey $selectedAreaKey
            $areaChoice = Read-Host "請選擇操作"
            
            if ($areaChoice -ge 1 -and $areaChoice -le $selectedArea.projects.Count) {
                $selectedProject = $selectedArea.projects[$areaChoice - 1]
                
                while ($true) {
                    Show-ProjectMenu -areaName $selectedArea.name -projectName $selectedProject
                    $projectChoice = Read-Host "請選擇操作 (1-6)"
                    
                    switch ($projectChoice) {
                        "1" {
                            $projectPath = "01-home-assistant-personal\$($selectedArea.name)\$selectedProject"
                            Write-Host "開啟項目目錄：$projectPath" -ForegroundColor Blue
                            if (Test-Path $projectPath) {
                                Start-Process explorer $projectPath
                            }
                        }
                        "2" {
                            $configPath = "01-home-assistant-personal\$($selectedArea.name)\$selectedProject\config.json"
                            if (Test-Path $configPath) {
                                Get-Content $configPath | ConvertFrom-Json | ConvertTo-Json -Depth 3
                            } else {
                                Write-Host "❌ 配置檔案不存在" -ForegroundColor Red
                            }
                        }
                        "3" {
                            $status = Get-ProjectStatus -area $selectedArea.name -project $selectedProject
                            Write-Host "項目狀態：$status" -ForegroundColor Blue
                        }
                        "6" { break }
                    }
                    
                    if ($projectChoice -eq "6") { break }
                    Read-Host "按 Enter 繼續..."
                }
            } elseif ($areaChoice -eq ($selectedArea.projects.Count + 1)) {
                New-Project -areaName $selectedArea.name -areaKey $selectedAreaKey
                Read-Host "按 Enter 繼續..."
            } elseif ($areaChoice -eq ($selectedArea.projects.Count + 4)) {
                break
            }
        }
    } elseif ($choice -eq ($functionalAreas.Count + 1)) {
        Show-ProjectOverview
        Read-Host "按 Enter 繼續..."
    } elseif ($choice -eq ($functionalAreas.Count + 2)) {
        # 新增項目
        Write-Host "選擇要新增項目的領域：" -ForegroundColor Green
        $index = 1
        foreach ($key in $functionalAreas.Keys) {
            $area = $functionalAreas[$key]
            Write-Host "$index. $($area.icon) $($area.description)" -ForegroundColor White
            $index++
        }
        
        $areaChoice = Read-Host "請選擇領域 (1-$($functionalAreas.Count))"
        if ($areaChoice -ge 1 -and $areaChoice -le $functionalAreas.Count) {
            $selectedAreaKey = $areaKeys[$areaChoice - 1]
            $selectedArea = $functionalAreas[$selectedAreaKey]
            New-Project -areaName $selectedArea.name -areaKey $selectedAreaKey
        }
        Read-Host "按 Enter 繼續..."
    } elseif ($choice -eq ($functionalAreas.Count + 3)) {
        Sync-AllProjects
        Read-Host "按 Enter 繼續..."
    } elseif ($choice -eq ($functionalAreas.Count + 4)) {
        Write-Host "👋 再見！" -ForegroundColor Green
        break
    } else {
        Write-Host "❌ 無效選項" -ForegroundColor Red
    }
}
