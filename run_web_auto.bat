@echo off
REM Script per lanciare il PowerShell con lo script di avvio

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_web.ps1"
pause
