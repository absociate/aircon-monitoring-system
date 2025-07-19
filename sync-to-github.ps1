# GitHub 同步腳本

Write-Host "========================================" -ForegroundColor Blue
Write-Host "  GitHub 同步工具" -ForegroundColor Blue
Write-Host "========================================" -ForegroundColor Blue
Write-Host ""

# 檢查是否在 Git 倉庫中
if (!(Test-Path ".git")) {
    Write-Host "❌ 當前目錄不是 Git 倉庫" -ForegroundColor Red
    Write-Host "請確保在正確的 Git 倉庫目錄中執行" -ForegroundColor Yellow
    Read-Host "按 Enter 鍵退出..."
    exit 1
}

# 檢查 Git 狀態
Write-Host "📊 檢查 Git 狀態..." -ForegroundColor Yellow
$status = git status --porcelain

if (!$status) {
    Write-Host "ℹ️ 沒有變更需要提交" -ForegroundColor Blue
    Write-Host "工作目錄是乾淨的" -ForegroundColor Gray
    Read-Host "按 Enter 鍵退出..."
    exit 0
}

# 顯示變更的檔案
Write-Host ""
Write-Host "📁 發現以下變更：" -ForegroundColor Green
git status --short

Write-Host ""
$confirm = Read-Host "是否要提交這些變更到 GitHub？(y/n)"
if ($confirm -ne "y") {
    Write-Host "❌ 取消同步" -ForegroundColor Yellow
    exit 0
}

# 添加所有變更
Write-Host ""
Write-Host "📝 添加變更到暫存區..." -ForegroundColor Yellow
git add .

# 輸入提交訊息
Write-Host ""
$commitMsg = Read-Host "請輸入提交訊息 (直接按 Enter 使用預設訊息)"
if (!$commitMsg) {
    $commitMsg = "更新家庭 HA 系統配置 - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

# 提交變更
Write-Host ""
Write-Host "💾 提交變更..." -ForegroundColor Yellow
git commit -m $commitMsg

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 提交失敗！" -ForegroundColor Red
    Read-Host "按 Enter 鍵退出..."
    exit 1
}

# 檢查遠端連線
Write-Host ""
Write-Host "🔗 檢查遠端倉庫連線..." -ForegroundColor Yellow
$remoteUrl = git remote get-url origin 2>$null
if (!$remoteUrl) {
    Write-Host "❌ 找不到遠端倉庫設定" -ForegroundColor Red
    Write-Host "請先設定遠端倉庫：git remote add origin <URL>" -ForegroundColor Yellow
    Read-Host "按 Enter 鍵退出..."
    exit 1
}

Write-Host "遠端倉庫：$remoteUrl" -ForegroundColor Gray

# 推送到 GitHub
Write-Host ""
Write-Host "🚀 推送到 GitHub..." -ForegroundColor Yellow
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ 同步完成！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "變更已成功推送到 GitHub" -ForegroundColor White
    Write-Host "您現在可以：" -ForegroundColor Yellow
    Write-Host "• 在 GitHub 上查看更新" -ForegroundColor White
    Write-Host "• 在其他設備上拉取最新版本" -ForegroundColor White
    Write-Host "• 繼續開發新功能" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "❌ 推送失敗！" -ForegroundColor Red
    Write-Host ""
    Write-Host "可能的原因：" -ForegroundColor Yellow
    Write-Host "• 網路連線問題" -ForegroundColor White
    Write-Host "• GitHub 認證問題" -ForegroundColor White
    Write-Host "• 遠端倉庫有新的提交" -ForegroundColor White
    Write-Host ""
    Write-Host "建議解決方案：" -ForegroundColor Yellow
    Write-Host "1. 檢查網路連線" -ForegroundColor White
    Write-Host "2. 先拉取遠端變更：git pull origin main" -ForegroundColor White
    Write-Host "3. 解決衝突後重新推送" -ForegroundColor White
}

Write-Host ""
Read-Host "按 Enter 鍵退出..."
