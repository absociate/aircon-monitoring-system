# 多倉庫同步管理腳本
# 管理三個獨立的 GitHub 倉庫

param(
    [string]$Action = "",
    [string]$Repo = ""
)

$repos = @{
    "home" = @{
        "name" = "home-assistant-personal"
        "path" = "home-assistant-personal"
        "description" = "🏠 家庭 Home Assistant"
    }
    "office" = @{
        "name" = "home-assistant-office" 
        "path" = "home-assistant-office"
        "description" = "🏢 辦公室 Home Assistant"
    }
    "lab" = @{
        "name" = "lab-management-system"
        "path" = "lab-management-system" 
        "description" = "🔬 實驗管理系統"
    }
}

function Show-Menu {
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "  多倉庫同步管理工具" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""
    
    Write-Host "選擇倉庫：" -ForegroundColor Green
    Write-Host "1. 🏠 家庭 Home Assistant (home-assistant-personal)" -ForegroundColor White
    Write-Host "2. 🏢 辦公室 Home Assistant (home-assistant-office)" -ForegroundColor White
    Write-Host "3. 🔬 實驗管理系統 (lab-management-system)" -ForegroundColor White
    Write-Host "4. 🔄 全部倉庫操作" -ForegroundColor White
    Write-Host "5. 📊 檢查所有倉庫狀態" -ForegroundColor White
    Write-Host "6. 🚪 退出" -ForegroundColor White
    Write-Host ""
}

function Show-Actions {
    param([string]$RepoName)
    
    Write-Host ""
    Write-Host "選擇操作 ($RepoName)：" -ForegroundColor Green
    Write-Host "1. 📥 拉取更新 (pull)" -ForegroundColor White
    Write-Host "2. 📤 推送更新 (push)" -ForegroundColor White
    Write-Host "3. 📊 檢查狀態 (status)" -ForegroundColor White
    Write-Host "4. 📝 提交變更 (commit)" -ForegroundColor White
    Write-Host "5. 🔙 返回主選單" -ForegroundColor White
    Write-Host ""
}

function Execute-GitAction {
    param(
        [string]$RepoPath,
        [string]$Action,
        [string]$RepoName
    )
    
    if (!(Test-Path $RepoPath)) {
        Write-Host "❌ 倉庫目錄不存在: $RepoPath" -ForegroundColor Red
        Write-Host "請先複製倉庫：git clone https://github.com/YOUR_USERNAME/$RepoName.git" -ForegroundColor Yellow
        return
    }
    
    Push-Location $RepoPath
    
    switch ($Action) {
        "pull" {
            Write-Host "📥 拉取 $RepoName 的更新..." -ForegroundColor Yellow
            git pull origin main
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $RepoName 更新完成" -ForegroundColor Green
            } else {
                Write-Host "❌ $RepoName 更新失敗" -ForegroundColor Red
            }
        }
        
        "push" {
            Write-Host "📤 推送 $RepoName 的更新..." -ForegroundColor Yellow
            
            # 檢查是否有變更
            $status = git status --porcelain
            if (!$status) {
                Write-Host "ℹ️ $RepoName 沒有變更需要推送" -ForegroundColor Blue
                Pop-Location
                return
            }
            
            # 顯示變更
            Write-Host "變更的檔案：" -ForegroundColor Gray
            git status --short
            
            $commitMsg = Read-Host "請輸入提交訊息"
            if (!$commitMsg) {
                $commitMsg = "更新 $RepoName 配置"
            }
            
            git add .
            git commit -m $commitMsg
            git push origin main
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $RepoName 推送完成" -ForegroundColor Green
            } else {
                Write-Host "❌ $RepoName 推送失敗" -ForegroundColor Red
            }
        }
        
        "status" {
            Write-Host "📊 檢查 $RepoName 狀態..." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "Git 狀態：" -ForegroundColor Gray
            git status
            Write-Host ""
            Write-Host "最近的提交：" -ForegroundColor Gray
            git log --oneline -5
        }
        
        "commit" {
            Write-Host "📝 提交 $RepoName 的變更..." -ForegroundColor Yellow
            
            $status = git status --porcelain
            if (!$status) {
                Write-Host "ℹ️ $RepoName 沒有變更需要提交" -ForegroundColor Blue
                Pop-Location
                return
            }
            
            git status
            $commitMsg = Read-Host "請輸入提交訊息"
            if (!$commitMsg) {
                $commitMsg = "更新 $RepoName 配置"
            }
            
            git add .
            git commit -m $commitMsg
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ $RepoName 提交完成" -ForegroundColor Green
            } else {
                Write-Host "❌ $RepoName 提交失敗" -ForegroundColor Red
            }
        }
    }
    
    Pop-Location
}

function Check-AllRepos {
    Write-Host "📊 檢查所有倉庫狀態..." -ForegroundColor Yellow
    Write-Host ""
    
    foreach ($key in $repos.Keys) {
        $repo = $repos[$key]
        $repoPath = $repo.path
        
        Write-Host "----------------------------------------" -ForegroundColor Gray
        Write-Host "$($repo.description)" -ForegroundColor Green
        Write-Host "路徑: $repoPath" -ForegroundColor Gray
        
        if (Test-Path $repoPath) {
            Push-Location $repoPath
            
            # 檢查是否有未提交的變更
            $status = git status --porcelain
            if ($status) {
                Write-Host "⚠️ 有未提交的變更" -ForegroundColor Yellow
                git status --short
            } else {
                Write-Host "✅ 工作目錄乾淨" -ForegroundColor Green
            }
            
            # 檢查是否與遠端同步
            git fetch origin main 2>$null
            $behind = git rev-list HEAD..origin/main --count 2>$null
            $ahead = git rev-list origin/main..HEAD --count 2>$null
            
            if ($behind -gt 0) {
                Write-Host "📥 落後遠端 $behind 個提交" -ForegroundColor Yellow
            }
            if ($ahead -gt 0) {
                Write-Host "📤 領先遠端 $ahead 個提交" -ForegroundColor Yellow
            }
            if ($behind -eq 0 -and $ahead -eq 0) {
                Write-Host "🔄 與遠端同步" -ForegroundColor Green
            }
            
            Pop-Location
        } else {
            Write-Host "❌ 倉庫目錄不存在" -ForegroundColor Red
            Write-Host "複製指令: git clone https://github.com/YOUR_USERNAME/$($repo.name).git" -ForegroundColor Blue
        }
        Write-Host ""
    }
}

# 主程式邏輯
if ($Action -and $Repo) {
    # 命令列模式
    if ($repos.ContainsKey($Repo)) {
        $repoInfo = $repos[$Repo]
        Execute-GitAction -RepoPath $repoInfo.path -Action $Action -RepoName $repoInfo.name
    } else {
        Write-Host "❌ 無效的倉庫名稱: $Repo" -ForegroundColor Red
        Write-Host "可用的倉庫: home, office, lab" -ForegroundColor Yellow
    }
    exit
}

# 互動模式
while ($true) {
    Show-Menu
    $choice = Read-Host "請選擇 (1-6)"
    
    switch ($choice) {
        "1" {
            $repoInfo = $repos["home"]
            while ($true) {
                Show-Actions -RepoName $repoInfo.description
                $action = Read-Host "請選擇操作 (1-5)"
                
                switch ($action) {
                    "1" { Execute-GitAction -RepoPath $repoInfo.path -Action "pull" -RepoName $repoInfo.name }
                    "2" { Execute-GitAction -RepoPath $repoInfo.path -Action "push" -RepoName $repoInfo.name }
                    "3" { Execute-GitAction -RepoPath $repoInfo.path -Action "status" -RepoName $repoInfo.name }
                    "4" { Execute-GitAction -RepoPath $repoInfo.path -Action "commit" -RepoName $repoInfo.name }
                    "5" { break }
                    default { Write-Host "❌ 無效選項" -ForegroundColor Red }
                }
                if ($action -eq "5") { break }
                Read-Host "按 Enter 繼續..."
            }
        }
        
        "2" {
            $repoInfo = $repos["office"]
            while ($true) {
                Show-Actions -RepoName $repoInfo.description
                $action = Read-Host "請選擇操作 (1-5)"
                
                switch ($action) {
                    "1" { Execute-GitAction -RepoPath $repoInfo.path -Action "pull" -RepoName $repoInfo.name }
                    "2" { Execute-GitAction -RepoPath $repoInfo.path -Action "push" -RepoName $repoInfo.name }
                    "3" { Execute-GitAction -RepoPath $repoInfo.path -Action "status" -RepoName $repoInfo.name }
                    "4" { Execute-GitAction -RepoPath $repoInfo.path -Action "commit" -RepoName $repoInfo.name }
                    "5" { break }
                    default { Write-Host "❌ 無效選項" -ForegroundColor Red }
                }
                if ($action -eq "5") { break }
                Read-Host "按 Enter 繼續..."
            }
        }
        
        "3" {
            $repoInfo = $repos["lab"]
            while ($true) {
                Show-Actions -RepoName $repoInfo.description
                $action = Read-Host "請選擇操作 (1-5)"
                
                switch ($action) {
                    "1" { Execute-GitAction -RepoPath $repoInfo.path -Action "pull" -RepoName $repoInfo.name }
                    "2" { Execute-GitAction -RepoPath $repoInfo.path -Action "push" -RepoName $repoInfo.name }
                    "3" { Execute-GitAction -RepoPath $repoInfo.path -Action "status" -RepoName $repoInfo.name }
                    "4" { Execute-GitAction -RepoPath $repoInfo.path -Action "commit" -RepoName $repoInfo.name }
                    "5" { break }
                    default { Write-Host "❌ 無效選項" -ForegroundColor Red }
                }
                if ($action -eq "5") { break }
                Read-Host "按 Enter 繼續..."
            }
        }
        
        "4" {
            Write-Host "🔄 全部倉庫操作" -ForegroundColor Green
            Write-Host "1. 📥 全部拉取" -ForegroundColor White
            Write-Host "2. 📤 全部推送" -ForegroundColor White
            Write-Host "3. 🔙 返回" -ForegroundColor White
            
            $allAction = Read-Host "請選擇 (1-3)"
            switch ($allAction) {
                "1" {
                    foreach ($key in $repos.Keys) {
                        $repo = $repos[$key]
                        Execute-GitAction -RepoPath $repo.path -Action "pull" -RepoName $repo.name
                    }
                }
                "2" {
                    foreach ($key in $repos.Keys) {
                        $repo = $repos[$key]
                        Execute-GitAction -RepoPath $repo.path -Action "push" -RepoName $repo.name
                    }
                }
            }
        }
        
        "5" {
            Check-AllRepos
            Read-Host "按 Enter 繼續..."
        }
        
        "6" {
            Write-Host "👋 再見！" -ForegroundColor Green
            exit
        }
        
        default {
            Write-Host "❌ 無效選項，請重新選擇" -ForegroundColor Red
        }
    }
}
