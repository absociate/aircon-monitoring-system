@echo off
REM 專案重新組織腳本
REM 將現有檔案按照類別重新整理

echo ========================================
echo   專案重新組織工具
echo ========================================
echo.

echo [資訊] 開始重新組織專案結構...

REM 建立主要目錄結構
echo [資訊] 建立目錄結構...
mkdir "01-home-assistant-personal" 2>nul
mkdir "01-home-assistant-personal\aircon-system" 2>nul
mkdir "01-home-assistant-personal\battery-management" 2>nul
mkdir "01-home-assistant-personal\notifications" 2>nul

mkdir "02-home-assistant-office" 2>nul
mkdir "02-home-assistant-office\office-automation" 2>nul

mkdir "03-lab-management-system" 2>nul
mkdir "03-lab-management-system\equipment-monitoring" 2>nul

mkdir "shared-tools" 2>nul
mkdir "shared-tools\sync-scripts" 2>nul
mkdir "shared-tools\templates" 2>nul

mkdir "archive" 2>nul

echo [成功] 目錄結構建立完成

REM 移動空調系統相關檔案
echo [資訊] 移動空調系統檔案...
move "README-aircon-notifications.md" "01-home-assistant-personal\aircon-system\" 2>nul
move "aircon-notification-*.json" "01-home-assistant-personal\aircon-system\" 2>nul
move "device-mapping.json" "01-home-assistant-personal\aircon-system\" 2>nul
move "notification-config.js" "01-home-assistant-personal\aircon-system\" 2>nul
move "notification-config.example.js" "01-home-assistant-personal\aircon-system\" 2>nul
move "install-aircon-notifications.*" "01-home-assistant-personal\aircon-system\" 2>nul
move "test-notifications.js" "01-home-assistant-personal\aircon-system\" 2>nul
move "*空調*" "01-home-assistant-personal\aircon-system\" 2>nul

REM 移動電池管理相關檔案
echo [資訊] 移動電池管理檔案...
move "README-battery-charging.md" "01-home-assistant-personal\battery-management\" 2>nul
move "battery-*.json" "01-home-assistant-personal\battery-management\" 2>nul
move "battery-*.js" "01-home-assistant-personal\battery-management\" 2>nul
move "battery-*.yaml" "01-home-assistant-personal\battery-management\" 2>nul
move "install-battery-management.sh" "01-home-assistant-personal\battery-management\" 2>nul
move "*電池*" "01-home-assistant-personal\battery-management\" 2>nul

REM 移動通知系統檔案
echo [資訊] 移動通知系統檔案...
move "NotifyHelper*.md" "01-home-assistant-personal\notifications\" 2>nul
move "notifyhelper-*.json" "01-home-assistant-personal\notifications\" 2>nul

REM 移動同步工具
echo [資訊] 移動同步工具...
move "sync-*.bat" "shared-tools\sync-scripts\" 2>nul
move "sync-*.sh" "shared-tools\sync-scripts\" 2>nul
move "GitHub同步快速開始.md" "shared-tools\sync-scripts\" 2>nul
move "aircon-system-sync-guide.md" "shared-tools\sync-scripts\" 2>nul

REM 移動其他檔案到適當位置
echo [資訊] 移動其他檔案...
move "*3d*" "archive\" 2>nul
move "*.vba" "archive\" 2>nul
move "letter-*.js" "archive\" 2>nul
move "*.html" "archive\" 2>nul

REM 移動樹莓派相關檔案
move "*樹莓派*" "01-home-assistant-personal\" 2>nul

echo [成功] 檔案移動完成

REM 建立各目錄的 README 檔案
echo [資訊] 建立說明文檔...

echo # 家裡的 Home Assistant 系統 > "01-home-assistant-personal\README.md"
echo. >> "01-home-assistant-personal\README.md"
echo 這個目錄包含家裡 Home Assistant 的所有配置和自動化腳本。 >> "01-home-assistant-personal\README.md"
echo. >> "01-home-assistant-personal\README.md"
echo ## 子系統 >> "01-home-assistant-personal\README.md"
echo - aircon-system/ - 空調三系統監控 >> "01-home-assistant-personal\README.md"
echo - battery-management/ - 電池充電管理 >> "01-home-assistant-personal\README.md"
echo - notifications/ - 通知系統配置 >> "01-home-assistant-personal\README.md"

echo # 公司的 Home Assistant 系統 > "02-home-assistant-office\README.md"
echo. >> "02-home-assistant-office\README.md"
echo 這個目錄包含公司 Home Assistant 的配置和辦公室自動化腳本。 >> "02-home-assistant-office\README.md"

echo # 實驗管理系統 > "03-lab-management-system\README.md"
echo. >> "03-lab-management-system\README.md"
echo 這個目錄包含實驗室設備監控和管理系統。 >> "03-lab-management-system\README.md"

echo # 共用工具 > "shared-tools\README.md"
echo. >> "shared-tools\README.md"
echo 這個目錄包含跨專案使用的工具和腳本。 >> "shared-tools\README.md"

echo [成功] 說明文檔建立完成

echo.
echo ========================================
echo   重新組織完成！
echo ========================================
echo.
echo 新的專案結構：
echo ├── 01-home-assistant-personal/
echo │   ├── aircon-system/
echo │   ├── battery-management/
echo │   └── notifications/
echo ├── 02-home-assistant-office/
echo ├── 03-lab-management-system/
echo ├── shared-tools/
echo └── archive/
echo.
echo 下一步：
echo 1. 檢查檔案是否都移動到正確位置
echo 2. 更新 .gitignore 檔案
echo 3. 重新提交到 GitHub
echo.
pause
