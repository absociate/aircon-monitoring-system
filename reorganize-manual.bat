@echo off
REM 手動重組家庭 HA 系統腳本

echo ========================================
echo   家庭 HA 系統重新組織工具
echo ========================================
echo.

REM 檢查是否存在原目錄
if not exist "01-home-assistant-personal" (
    echo 錯誤：找不到 01-home-assistant-personal 目錄
    echo 請確保在正確的目錄中執行此腳本
    pause
    exit /b 1
)

echo 開始建立新的目錄結構...

REM 建立主目錄
if exist "home-assistant-personal-v2" rmdir /s /q "home-assistant-personal-v2"
mkdir "home-assistant-personal-v2"

REM 建立功能領域目錄
mkdir "home-assistant-personal-v2\01-climate-control"
mkdir "home-assistant-personal-v2\01-climate-control\aircon-system"
mkdir "home-assistant-personal-v2\01-climate-control\heating-control"
mkdir "home-assistant-personal-v2\01-climate-control\humidity-management"

mkdir "home-assistant-personal-v2\02-lighting-automation"
mkdir "home-assistant-personal-v2\02-lighting-automation\indoor-lighting"
mkdir "home-assistant-personal-v2\02-lighting-automation\outdoor-lighting"
mkdir "home-assistant-personal-v2\02-lighting-automation\smart-switches"

mkdir "home-assistant-personal-v2\03-window-treatments"
mkdir "home-assistant-personal-v2\03-window-treatments\motorized-curtains"
mkdir "home-assistant-personal-v2\03-window-treatments\blinds-control"
mkdir "home-assistant-personal-v2\03-window-treatments\schedule-automation"

mkdir "home-assistant-personal-v2\04-electrical-monitoring"
mkdir "home-assistant-personal-v2\04-electrical-monitoring\power-monitoring"
mkdir "home-assistant-personal-v2\04-electrical-monitoring\battery-management"
mkdir "home-assistant-personal-v2\04-electrical-monitoring\device-notifications"

mkdir "home-assistant-personal-v2\05-security-safety"
mkdir "home-assistant-personal-v2\05-security-safety\door-locks"
mkdir "home-assistant-personal-v2\05-security-safety\cameras"
mkdir "home-assistant-personal-v2\05-security-safety\alarm-system"

mkdir "home-assistant-personal-v2\06-entertainment"
mkdir "home-assistant-personal-v2\06-entertainment\audio-control"
mkdir "home-assistant-personal-v2\06-entertainment\tv-automation"
mkdir "home-assistant-personal-v2\06-entertainment\media-center"

mkdir "home-assistant-personal-v2\07-notifications"
mkdir "home-assistant-personal-v2\07-notifications\multi-platform"
mkdir "home-assistant-personal-v2\07-notifications\alert-rules"
mkdir "home-assistant-personal-v2\07-notifications\message-templates"

mkdir "home-assistant-personal-v2\08-integrations"
mkdir "home-assistant-personal-v2\08-integrations\weather-service"
mkdir "home-assistant-personal-v2\08-integrations\calendar-sync"
mkdir "home-assistant-personal-v2\08-integrations\voice-assistants"

mkdir "home-assistant-personal-v2\shared-tools"
mkdir "home-assistant-personal-v2\docs"
mkdir "home-assistant-personal-v2\configs"

echo 目錄結構建立完成

echo.
echo 開始複製現有檔案...

REM 複製空調系統
if exist "01-home-assistant-personal\aircon-system" (
    xcopy "01-home-assistant-personal\aircon-system\*" "home-assistant-personal-v2\01-climate-control\aircon-system\" /E /I /Y >nul 2>&1
    echo   空調系統已複製到氣候控制
)

REM 複製電池管理
if exist "01-home-assistant-personal\battery-management" (
    xcopy "01-home-assistant-personal\battery-management\*" "home-assistant-personal-v2\04-electrical-monitoring\battery-management\" /E /I /Y >nul 2>&1
    echo   電池管理已複製到電氣監控
)

REM 複製通知系統
if exist "01-home-assistant-personal\notifications" (
    xcopy "01-home-assistant-personal\notifications\*" "home-assistant-personal-v2\07-notifications\multi-platform\" /E /I /Y >nul 2>&1
    echo   通知系統已複製
)

REM 複製共用工具
if exist "01-home-assistant-personal\shared-tools" (
    xcopy "01-home-assistant-personal\shared-tools\*" "home-assistant-personal-v2\shared-tools\" /E /I /Y >nul 2>&1
    echo   共用工具已複製
)

REM 複製 Markdown 檔案到文檔目錄
for %%f in ("01-home-assistant-personal\*.md") do (
    copy "%%f" "home-assistant-personal-v2\docs\" >nul 2>&1
    echo   文檔 %%~nxf 已複製
)

echo 檔案複製完成

echo.
echo 建立說明文檔...

REM 建立主 README
echo # 家庭 Home Assistant 自動化系統 v2.0 > "home-assistant-personal-v2\README.md"
echo. >> "home-assistant-personal-v2\README.md"
echo 這是重新組織後的家庭自動化系統，按功能領域分類管理。 >> "home-assistant-personal-v2\README.md"
echo. >> "home-assistant-personal-v2\README.md"
echo ## 系統架構 >> "home-assistant-personal-v2\README.md"
echo. >> "home-assistant-personal-v2\README.md"
echo ### 功能領域分類 >> "home-assistant-personal-v2\README.md"
echo - 01-climate-control/ - 氣候控制 >> "home-assistant-personal-v2\README.md"
echo - 02-lighting-automation/ - 燈光自動化 >> "home-assistant-personal-v2\README.md"
echo - 03-window-treatments/ - 窗簾自動化 >> "home-assistant-personal-v2\README.md"
echo - 04-electrical-monitoring/ - 電氣設備監控 >> "home-assistant-personal-v2\README.md"
echo - 05-security-safety/ - 安全防護 >> "home-assistant-personal-v2\README.md"
echo - 06-entertainment/ - 娛樂系統 >> "home-assistant-personal-v2\README.md"
echo - 07-notifications/ - 通知系統 >> "home-assistant-personal-v2\README.md"
echo - 08-integrations/ - 整合服務 >> "home-assistant-personal-v2\README.md"
echo. >> "home-assistant-personal-v2\README.md"
echo ### 共用資源 >> "home-assistant-personal-v2\README.md"
echo - shared-tools/ - 跨領域共用工具 >> "home-assistant-personal-v2\README.md"
echo - docs/ - 系統文檔和說明 >> "home-assistant-personal-v2\README.md"
echo - configs/ - 全域配置檔案 >> "home-assistant-personal-v2\README.md"

REM 建立氣候控制 README
echo # 氣候控制 > "home-assistant-personal-v2\01-climate-control\README.md"
echo. >> "home-assistant-personal-v2\01-climate-control\README.md"
echo ## 概述 >> "home-assistant-personal-v2\01-climate-control\README.md"
echo 這個目錄包含氣候控制相關的所有自動化配置和腳本。 >> "home-assistant-personal-v2\01-climate-control\README.md"
echo. >> "home-assistant-personal-v2\01-climate-control\README.md"
echo ## 子系統 >> "home-assistant-personal-v2\01-climate-control\README.md"
echo - aircon-system/ - 空調三系統控制 >> "home-assistant-personal-v2\01-climate-control\README.md"
echo - heating-control/ - 暖氣系統控制 >> "home-assistant-personal-v2\01-climate-control\README.md"
echo - humidity-management/ - 濕度調節管理 >> "home-assistant-personal-v2\01-climate-control\README.md"

echo 說明文檔建立完成

echo.
echo ========================================
echo   重新組織完成！
echo ========================================
echo.

echo 新的系統結構：
echo ├── 01-climate-control/ - 氣候控制
echo ├── 02-lighting-automation/ - 燈光自動化
echo ├── 03-window-treatments/ - 窗簾自動化
echo ├── 04-electrical-monitoring/ - 電氣設備監控
echo ├── 05-security-safety/ - 安全防護
echo ├── 06-entertainment/ - 娛樂系統
echo ├── 07-notifications/ - 通知系統
echo ├── 08-integrations/ - 整合服務
echo ├── shared-tools/ - 共用工具
echo ├── docs/ - 文檔
echo └── configs/ - 配置

echo.
echo 下一步：
echo 1. 檢查新結構：cd home-assistant-personal-v2
echo 2. 測試功能是否正常
echo 3. 備份舊結構：ren 01-home-assistant-personal 01-home-assistant-personal-backup
echo 4. 啟用新結構：ren home-assistant-personal-v2 01-home-assistant-personal
echo 5. 提交到 GitHub

echo.
pause
