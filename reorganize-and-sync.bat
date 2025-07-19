@echo off
REM 重組家庭 HA 系統並同步到 GitHub

echo ========================================
echo   家庭 HA 系統重組 + GitHub 同步
echo ========================================
echo.

REM 檢查是否存在原目錄
if not exist "01-home-assistant-personal" (
    echo 錯誤：找不到 01-home-assistant-personal 目錄
    pause
    exit /b 1
)

echo 第一步：重新組織檔案結構...
echo.

REM 執行重組
call reorganize-manual.bat

echo.
echo ========================================
echo   開始 GitHub 同步流程
echo ========================================
echo.

REM 詢問是否要同步到 GitHub
set /p sync_choice="是否要將變更同步到 GitHub？(y/n): "
if /i not "%sync_choice%"=="y" (
    echo 跳過 GitHub 同步
    echo 您可以稍後手動執行：
    echo   git add .
    echo   git commit -m "重新組織家庭 HA 系統"
    echo   git push origin main
    pause
    exit /b 0
)

echo.
echo 檢查 Git 狀態...
git status

echo.
echo 添加所有變更到 Git...
git add .

echo.
echo 檢查是否有變更需要提交...
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo 沒有變更需要提交
    pause
    exit /b 0
)

echo.
set /p commit_msg="請輸入提交訊息 (直接按 Enter 使用預設訊息): "
if "%commit_msg%"=="" set commit_msg=重新組織家庭 HA 系統：按功能領域分類

echo.
echo 提交變更...
git commit -m "%commit_msg%"

if %errorlevel% neq 0 (
    echo 提交失敗！
    pause
    exit /b 1
)

echo.
echo 推送到 GitHub...
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   同步完成！
    echo ========================================
    echo.
    echo ✅ 檔案重組完成
    echo ✅ 變更已提交到 Git
    echo ✅ 已推送到 GitHub
    echo.
    echo 您現在可以：
    echo 1. 在 GitHub 上查看更新後的倉庫
    echo 2. 在公司電腦上拉取最新版本
    echo 3. 使用 simple-ha-manager.ps1 管理項目
) else (
    echo.
    echo ❌ 推送到 GitHub 失敗！
    echo.
    echo 可能的原因：
    echo 1. 網路連線問題
    echo 2. GitHub 認證問題
    echo 3. 遠端倉庫衝突
    echo.
    echo 請檢查錯誤訊息並手動解決
)

echo.
pause
