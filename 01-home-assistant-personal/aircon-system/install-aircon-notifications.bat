@echo off
setlocal enabledelayedexpansion

REM 空調設備通知系統安裝腳本 (Windows 版本)
REM 此腳本將幫助您快速設置 Node-RED 空調通知系統

echo ========================================
echo   空調設備通知系統安裝程式 (Windows)
echo ========================================
echo.

REM 檢查 Node.js 是否安裝
echo [INFO] 檢查 Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js 未安裝，請先安裝 Node.js
    echo 下載地址: https://nodejs.org/
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo [SUCCESS] Node.js 已安裝: !NODE_VERSION!
)

REM 檢查 npm 是否安裝
echo [INFO] 檢查 npm...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm 未安裝，請先安裝 npm
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
    echo [SUCCESS] npm 已安裝: !NPM_VERSION!
)

REM 檢查 Node-RED 是否安裝
echo [INFO] 檢查 Node-RED...
node-red --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node-RED 未安裝，請先安裝 Node-RED
    echo 安裝指令: npm install -g --unsafe-perm node-red
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('node-red --version') do set NODERED_VERSION=%%i
    echo [SUCCESS] Node-RED 已安裝: !NODERED_VERSION!
)

REM 驗證配置文件
echo [INFO] 驗證配置文件...
set CONFIG_VALID=1

if not exist "aircon-notification-flow.json" (
    echo [ERROR] 缺少必要文件: aircon-notification-flow.json
    set CONFIG_VALID=0
)

if not exist "device-mapping.json" (
    echo [ERROR] 缺少必要文件: device-mapping.json
    set CONFIG_VALID=0
)

if not exist "notification-config.js" (
    echo [ERROR] 缺少必要文件: notification-config.js
    set CONFIG_VALID=0
)

if not exist "README-aircon-notifications.md" (
    echo [ERROR] 缺少必要文件: README-aircon-notifications.md
    set CONFIG_VALID=0
)

if !CONFIG_VALID! equ 0 (
    echo [ERROR] 配置文件驗證失敗
    pause
    exit /b 1
) else (
    echo [SUCCESS] 配置文件驗證通過
)

REM 詢問是否安裝 Node-RED 節點
echo.
set /p INSTALL_NODES="是否要安裝必要的 Node-RED 節點？(y/n): "
if /i "!INSTALL_NODES!"=="y" (
    echo [INFO] 安裝必要的 Node-RED 節點...
    
    echo [INFO] 安裝 Home Assistant 節點...
    npm install node-red-contrib-home-assistant-websocket
    if %errorlevel% neq 0 (
        echo [WARNING] Home Assistant 節點安裝失敗，請手動安裝
    ) else (
        echo [SUCCESS] Home Assistant 節點安裝完成
    )
    
    echo [INFO] 安裝 Telegram 節點...
    npm install node-red-contrib-telegrambot
    if %errorlevel% neq 0 (
        echo [WARNING] Telegram 節點安裝失敗，請手動安裝
    ) else (
        echo [SUCCESS] Telegram 節點安裝完成
    )
    
    echo [SUCCESS] Node-RED 節點安裝完成
) else (
    echo [WARNING] 跳過 Node-RED 節點安裝
)

REM 設置配置文件
echo [INFO] 設置配置文件...
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env" >nul
        echo [SUCCESS] 已創建 .env 配置文件
        echo [WARNING] 請編輯 .env 文件並填入您的實際配置值
    ) else (
        echo [ERROR] .env.example 文件不存在
    )
) else (
    echo [WARNING] .env 文件已存在，跳過創建
)

REM 顯示下一步指示
echo.
echo [SUCCESS] 安裝完成！
echo.
echo [INFO] 下一步操作：
echo 1. 編輯 .env 文件，填入您的實際配置值
echo 2. 啟動 Node-RED: node-red
echo 3. 打開瀏覽器訪問: http://localhost:1880
echo 4. 導入 aircon-notification-flow.json 流程文件
echo 5. 配置 Home Assistant 連接
echo 6. 配置通知服務（Telegram、Synology Chat）
echo 7. 部署流程並測試
echo.
echo [INFO] 詳細說明請參考: README-aircon-notifications.md
echo.

pause
