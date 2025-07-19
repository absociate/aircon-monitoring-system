@echo off
echo ========================================
echo   GitHub Sync Tool
echo ========================================
echo.

echo Checking Git status...
git status

echo.
echo Adding all changes...
git add .

echo.
set /p commit_msg="Enter commit message (or press Enter for default): "
if "%commit_msg%"=="" set commit_msg=Reorganize home HA system by functional areas

echo.
echo Committing changes...
git commit -m "%commit_msg%"

echo.
echo Pushing to GitHub...
git push origin main

echo.
if %errorlevel% equ 0 (
    echo SUCCESS: Changes synced to GitHub!
) else (
    echo ERROR: Failed to sync to GitHub
)

echo.
pause
