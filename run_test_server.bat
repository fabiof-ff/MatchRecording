@echo off
REM Test Server Launcher per MatchRecording
REM Lancia il server Python e apre il browser

echo ========================================
echo   Match Recording - Test Server
echo ========================================
echo.

REM Cambio directory
cd /d "C:\Users\fabio\Desktop\APPs\MatchRecording"

REM Verifica se Python è disponibile
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    where python3 >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo ❌ Python non trovato!
        echo Installa Python da https://www.python.org
        pause
        exit /b 1
    )
    set PYTHON=python3
) else (
    set PYTHON=python
)

echo ✓ Python trovato: %PYTHON%
echo.
echo 🚀 Avvio server...
echo.

REM Avvia il server Python
%PYTHON% run_test_server.py

pause
