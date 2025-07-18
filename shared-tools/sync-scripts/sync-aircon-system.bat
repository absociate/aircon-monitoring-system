@echo off
REM 空調系統 GitHub 同步腳本 (Windows)
REM 此腳本幫助您快速同步空調系統專案到 GitHub

setlocal enabledelayedexpansion

echo ========================================
echo   空調系統 GitHub 同步工具
echo ========================================
echo.

REM 檢查是否在正確的目錄
if not exist "README-aircon-notifications.md" (
    echo [錯誤] 請在包含空調系統檔案的目錄中執行此腳本
    echo 當前目錄: %CD%
    pause
    exit /b 1
)

REM 檢查 Git 是否安裝
git --version >nul 2>&1
if errorlevel 1 (
    echo [錯誤] Git 未安裝或不在 PATH 中
    echo 請先安裝 Git: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo [資訊] 檢查 Git 狀態...
git status >nul 2>&1
if errorlevel 1 (
    echo [警告] 此目錄尚未初始化為 Git 倉庫
    echo.
    set /p init_git="是否要初始化 Git 倉庫？(y/n): "
    if /i "!init_git!"=="y" (
        echo [資訊] 初始化 Git 倉庫...
        git init
        echo [資訊] Git 倉庫初始化完成
        echo.
        echo [資訊] 請設定遠端倉庫 URL:
        set /p remote_url="請輸入 GitHub 倉庫 URL: "
        git remote add origin !remote_url!
        echo [資訊] 遠端倉庫設定完成
    ) else (
        echo [資訊] 跳過 Git 初始化
        pause
        exit /b 0
    )
)

echo.
echo [資訊] 當前 Git 狀態:
git status --short

echo.
echo 請選擇操作:
echo 1. 推送更新到 GitHub (在家裡使用)
echo 2. 從 GitHub 拉取更新 (在公司使用)
echo 3. 檢查狀態
echo 4. 建立新分支
echo 5. 切換分支
echo 6. 退出
echo.

set /p choice="請輸入選項 (1-6): "

if "%choice%"=="1" goto push_updates
if "%choice%"=="2" goto pull_updates
if "%choice%"=="3" goto check_status
if "%choice%"=="4" goto create_branch
if "%choice%"=="5" goto switch_branch
if "%choice%"=="6" goto exit_script

echo [錯誤] 無效的選項
goto exit_script

:push_updates
echo.
echo [資訊] 準備推送更新到 GitHub...
echo.

REM 顯示將要提交的檔案
echo [資訊] 將要提交的檔案:
git status --short

echo.
set /p commit_msg="請輸入提交訊息: "
if "%commit_msg%"=="" set commit_msg="更新空調系統配置"

echo [資訊] 添加檔案到暫存區...
git add .

echo [資訊] 提交變更...
git commit -m "%commit_msg%"

echo [資訊] 推送到 GitHub...
git push origin main
if errorlevel 1 (
    echo [錯誤] 推送失敗，可能需要先拉取遠端變更
    echo [資訊] 嘗試拉取並合併...
    git pull origin main
    if errorlevel 1 (
        echo [錯誤] 拉取失敗，請手動解決衝突
        goto exit_script
    )
    echo [資訊] 重新推送...
    git push origin main
)

echo [成功] 更新已推送到 GitHub
goto exit_script

:pull_updates
echo.
echo [資訊] 從 GitHub 拉取更新...

REM 檢查是否有未提交的變更
git diff-index --quiet HEAD --
if errorlevel 1 (
    echo [警告] 發現未提交的變更
    git status --short
    echo.
    set /p stash_changes="是否要暫存這些變更？(y/n): "
    if /i "!stash_changes!"=="y" (
        echo [資訊] 暫存變更...
        git stash push -m "自動暫存 - %date% %time%"
    )
)

echo [資訊] 拉取遠端變更...
git pull origin main
if errorlevel 1 (
    echo [錯誤] 拉取失敗，可能有衝突需要解決
    goto exit_script
)

echo [成功] 更新已從 GitHub 拉取完成

REM 如果之前有暫存變更，詢問是否要恢復
git stash list | findstr "stash@{0}" >nul 2>&1
if not errorlevel 1 (
    echo.
    set /p restore_stash="是否要恢復之前暫存的變更？(y/n): "
    if /i "!restore_stash!"=="y" (
        echo [資訊] 恢復暫存的變更...
        git stash pop
    )
)

goto exit_script

:check_status
echo.
echo [資訊] Git 狀態檢查:
echo.
echo 當前分支:
git branch --show-current
echo.
echo 檔案狀態:
git status
echo.
echo 最近的提交:
git log --oneline -5
goto exit_script

:create_branch
echo.
set /p branch_name="請輸入新分支名稱: "
if "%branch_name%"=="" (
    echo [錯誤] 分支名稱不能為空
    goto exit_script
)

echo [資訊] 建立並切換到新分支: %branch_name%
git checkout -b %branch_name%
echo [成功] 分支 %branch_name% 建立完成
goto exit_script

:switch_branch
echo.
echo [資訊] 可用的分支:
git branch -a
echo.
set /p target_branch="請輸入要切換的分支名稱: "
if "%target_branch%"=="" (
    echo [錯誤] 分支名稱不能為空
    goto exit_script
)

echo [資訊] 切換到分支: %target_branch%
git checkout %target_branch%
if errorlevel 1 (
    echo [錯誤] 切換分支失敗
) else (
    echo [成功] 已切換到分支: %target_branch%
)
goto exit_script

:exit_script
echo.
echo [資訊] 腳本執行完成
pause
exit /b 0
