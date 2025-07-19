@echo off
echo 建立多倉庫結構...

mkdir temp-repos
mkdir temp-repos\home-assistant-personal
mkdir temp-repos\home-assistant-office
mkdir temp-repos\lab-management-system

echo 複製檔案...
if exist "01-home-assistant-personal" xcopy "01-home-assistant-personal\*" "temp-repos\home-assistant-personal\" /E /I /Y
if exist "02-home-assistant-office" xcopy "02-home-assistant-office\*" "temp-repos\home-assistant-office\" /E /I /Y
if exist "03-lab-management-system" xcopy "03-lab-management-system\*" "temp-repos\lab-management-system\" /E /I /Y

if exist "shared-tools" (
    xcopy "shared-tools\*" "temp-repos\home-assistant-personal\shared-tools\" /E /I /Y
    xcopy "shared-tools\*" "temp-repos\home-assistant-office\shared-tools\" /E /I /Y
    xcopy "shared-tools\*" "temp-repos\lab-management-system\shared-tools\" /E /I /Y
)

echo 完成！請手動設定 Git 並推送到 GitHub
pause