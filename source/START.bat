@echo off
set SCRIPT_PATH=%~dp0script.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" %*
