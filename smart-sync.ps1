# 智能同步腳本 - 根據環境自動選擇同步策略

param(
    [string]$Environment = "auto",
    [string]$Repository = "",
    [string]$Action = ""
)

# 檢測當前環境
function Detect-Environment {
    $networkName = (Get-NetConnectionProfile).Name
    $computerName = $env:COMPUTERNAME
    
    if ($networkName -like "*office*" -or $networkName -like "*company*") {
        return "office"
    } elseif ($networkName -like "*home*" -or $computerName -like "*home*") {
        return "home"
    } else {
        # 讓用戶手動選擇
        Write-Host "無法自動檢測環境，請手動選擇：" -ForegroundColor Yellow
        Write-Host "1. 🏠 家裡" -ForegroundColor White
        Write-Host "2. 🏢 辦公室" -ForegroundColor White
        
        $choice = Read-Host "請選擇 (1-2)"
        return if ($choice -eq "1") { "home" } else { "office" }
    }
}

# 顯示環境資訊
function Show-EnvironmentInfo {
    param([string]$env)
    
    $envConfig = @{
        "home" = @{
            "icon" = "🏠"
            "name" = "家裡"
            "description" = "開發和測試環境"
            "recommended_actions" = @("開發新功能", "測試配置", "推送到 GitHub")
        }
        "office" = @{
            "icon" = "🏢" 
            "name" = "辦公室"
            "description" = "生產部署環境"
            "recommended_actions" = @("拉取最新版本", "部署到實際設備", "驗證功能")
        }
    }
    
    $config = $envConfig[$env]
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  $($config.icon) 當前環境：$($config.name)" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "描述：$($config.description)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "建議操作：" -ForegroundColor Green
    $config.recommended_actions | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
    Write-Host ""
}

# 智能提交訊息
function Get-SmartCommitMessage {
    param([string]$env, [string]$repo)
    
    $envPrefix = if ($env -eq "home") { "[HOME-DEV]" } else { "[OFFICE-DEPLOY]" }
    $repoName = switch ($repo) {
        "home-assistant-personal" { "家庭HA" }
        "home-assistant-office" { "辦公室HA" }
        "lab-management-system" { "實驗管理" }
        default { $repo }
    }
    
    $defaultMsg = "$envPrefix 更新 $repoName 系統配置"
    
    Write-Host "建議的提交訊息：$defaultMsg" -ForegroundColor Gray
    $customMsg = Read-Host "請輸入提交訊息 (直接按 Enter 使用建議訊息)"
    
    return if ($customMsg) { "$envPrefix $customMsg" } else { $defaultMsg }
}

# 執行同步操作
function Execute-SmartSync {
    param(
        [string]$env,
        [string]$repo,
        [string]$action
    )
    
    if (!(Test-Path $repo)) {
        Write-Host "❌ 倉庫目錄不存在: $repo" -ForegroundColor Red
        
        if ($env -eq "office") {
            Write-Host "💡 在辦公室建議先複製倉庫：" -ForegroundColor Yellow
            Write-Host "git clone https://github.com/absociate/$repo.git" -ForegroundColor Blue
        }
        return
    }
    
    Push-Location $repo
    
    switch ($action) {
        "smart-push" {
            if ($env -eq "home") {
                Write-Host "🏠 在家裡推送到 GitHub..." -ForegroundColor Green
                
                # 檢查是否有變更
                $status = git status --porcelain
                if (!$status) {
                    Write-Host "ℹ️ 沒有變更需要推送" -ForegroundColor Blue
                    Pop-Location
                    return
                }
                
                # 顯示變更
                Write-Host "變更的檔案：" -ForegroundColor Gray
                git status --short
                
                # 智能提交訊息
                $commitMsg = Get-SmartCommitMessage -env $env -repo $repo
                
                git add .
                git commit -m $commitMsg
                git push origin main
                
                Write-Host "✅ 推送完成！在辦公室可以拉取這些變更" -ForegroundColor Green
                
            } else {
                Write-Host "🏢 在辦公室建議先拉取最新版本，再推送" -ForegroundColor Yellow
                Write-Host "使用 'smart-pull' 然後再 'smart-push'" -ForegroundColor Blue
            }
        }
        
        "smart-pull" {
            Write-Host "📥 拉取最新版本..." -ForegroundColor Yellow
            
            # 檢查是否有未提交的變更
            $status = git status --porcelain
            if ($status) {
                Write-Host "⚠️ 發現未提交的變更：" -ForegroundColor Yellow
                git status --short
                
                $stash = Read-Host "是否要暫存這些變更？(y/n)"
                if ($stash -eq "y") {
                    git stash push -m "自動暫存 - $env - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
                    Write-Host "💾 變更已暫存" -ForegroundColor Blue
                }
            }
            
            git pull origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ 拉取完成" -ForegroundColor Green
                
                # 如果有暫存的變更，詢問是否恢復
                $stashList = git stash list
                if ($stashList) {
                    Write-Host "發現暫存的變更：" -ForegroundColor Gray
                    git stash list
                    
                    $restore = Read-Host "是否要恢復最近的暫存變更？(y/n)"
                    if ($restore -eq "y") {
                        git stash pop
                        Write-Host "🔄 暫存變更已恢復" -ForegroundColor Blue
                    }
                }
            } else {
                Write-Host "❌ 拉取失敗" -ForegroundColor Red
            }
        }
        
        "status" {
            Write-Host "📊 檢查倉庫狀態..." -ForegroundColor Yellow
            Write-Host ""
            
            # Git 狀態
            Write-Host "Git 狀態：" -ForegroundColor Gray
            git status
            
            # 與遠端的差異
            git fetch origin main 2>$null
            $behind = git rev-list HEAD..origin/main --count 2>$null
            $ahead = git rev-list origin/main..HEAD --count 2>$null
            
            Write-Host ""
            if ($behind -gt 0) {
                Write-Host "📥 落後遠端 $behind 個提交" -ForegroundColor Yellow
            }
            if ($ahead -gt 0) {
                Write-Host "📤 領先遠端 $ahead 個提交" -ForegroundColor Yellow
            }
            if ($behind -eq 0 -and $ahead -eq 0) {
                Write-Host "🔄 與遠端同步" -ForegroundColor Green
            }
        }
    }
    
    Pop-Location
}

# 主選單
function Show-MainMenu {
    param([string]$env)
    
    Write-Host "選擇倉庫：" -ForegroundColor Green
    Write-Host "1. 🏠 家庭 Home Assistant" -ForegroundColor White
    Write-Host "2. 🏢 辦公室 Home Assistant" -ForegroundColor White
    Write-Host "3. 🔬 實驗管理系統" -ForegroundColor White
    Write-Host "4. 📊 檢查所有倉庫狀態" -ForegroundColor White
    Write-Host "5. 🚪 退出" -ForegroundColor White
    Write-Host ""
}

function Show-ActionMenu {
    param([string]$env, [string]$repoName)
    
    Write-Host ""
    Write-Host "選擇操作 ($repoName)：" -ForegroundColor Green
    
    if ($env -eq "home") {
        Write-Host "1. 📤 智能推送 (推薦：在家裡開發後推送)" -ForegroundColor White
        Write-Host "2. 📥 拉取更新" -ForegroundColor White
        Write-Host "3. 📊 檢查狀態" -ForegroundColor White
    } else {
        Write-Host "1. 📥 智能拉取 (推薦：在辦公室先拉取最新版本)" -ForegroundColor White
        Write-Host "2. 📤 推送更新" -ForegroundColor White
        Write-Host "3. 📊 檢查狀態" -ForegroundColor White
    }
    
    Write-Host "4. 🔙 返回主選單" -ForegroundColor White
    Write-Host ""
}

# 主程式
$currentEnv = if ($Environment -eq "auto") { Detect-Environment } else { $Environment }
Show-EnvironmentInfo -env $currentEnv

$repos = @{
    "1" = "home-assistant-personal"
    "2" = "home-assistant-office"
    "3" = "lab-management-system"
}

while ($true) {
    Show-MainMenu -env $currentEnv
    $repoChoice = Read-Host "請選擇 (1-5)"
    
    if ($repoChoice -eq "5") {
        Write-Host "👋 再見！" -ForegroundColor Green
        break
    }
    
    if ($repoChoice -eq "4") {
        # 檢查所有倉庫狀態
        foreach ($repo in $repos.Values) {
            Write-Host "----------------------------------------" -ForegroundColor Gray
            Write-Host "檢查 $repo" -ForegroundColor Green
            Execute-SmartSync -env $currentEnv -repo $repo -action "status"
        }
        Read-Host "按 Enter 繼續..."
        continue
    }
    
    if ($repos.ContainsKey($repoChoice)) {
        $selectedRepo = $repos[$repoChoice]
        
        while ($true) {
            Show-ActionMenu -env $currentEnv -repoName $selectedRepo
            $actionChoice = Read-Host "請選擇操作 (1-4)"
            
            switch ($actionChoice) {
                "1" {
                    $action = if ($currentEnv -eq "home") { "smart-push" } else { "smart-pull" }
                    Execute-SmartSync -env $currentEnv -repo $selectedRepo -action $action
                }
                "2" {
                    $action = if ($currentEnv -eq "home") { "smart-pull" } else { "smart-push" }
                    Execute-SmartSync -env $currentEnv -repo $selectedRepo -action $action
                }
                "3" {
                    Execute-SmartSync -env $currentEnv -repo $selectedRepo -action "status"
                }
                "4" {
                    break
                }
                default {
                    Write-Host "❌ 無效選項" -ForegroundColor Red
                }
            }
            
            if ($actionChoice -eq "4") { break }
            Read-Host "按 Enter 繼續..."
        }
    } else {
        Write-Host "❌ 無效選項" -ForegroundColor Red
    }
}
