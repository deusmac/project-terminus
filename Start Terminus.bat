@echo off
title Terminus - Limiting Heights Workbench
cd /d "%~dp0"
echo.
echo  ============================================
echo   TERMINUS / LIMITING HEIGHTS WORKBENCH
echo  ============================================
echo.
echo  Opening http://localhost:8321 in your browser...
echo  Keep this window open while you work.
echo  Close this window when you're done.
echo.
start "" http://localhost:8321/
python -m http.server 8321 2>nul
if errorlevel 1 (
  echo  Server may already be running - your browser tab should still work.
  pause
)
