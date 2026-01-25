@echo off
REM ============================================
REM  ⚽ Match Recording - Test Server Launcher
REM ============================================

setlocal enabledelayedexpansion

REM Colori (richiede Windows 10+)
for /F %%A in ('echo prompt $H ^| cmd') do set "BS=%%A"

cls
echo.
echo  ╔═════════════════════════════════════════╗
echo  ║   ⚽ MATCH RECORDING - TEST SERVER     ║
echo  ╚═════════════════════════════════════════╝
echo.

REM Cambio directory
cd /d "C:\Users\fabio\Desktop\APPs\MatchRecording"

REM Menu
echo  Seleziona una opzione:
echo.
echo    1) Avvia server HTTP (Python)
echo    2) Apri test_recording.html
echo    3) Apri TEST_RECORDING_GUIDE.md
echo    4) Controlla porta 8000
echo    5) Esci
echo.

set /p choice="  Scelta (1-5): "

if "%choice%"=="1" goto :launch_server
if "%choice%"=="2" goto :open_test
if "%choice%"=="3" goto :open_guide
if "%choice%"=="4" goto :check_port
if "%choice%"=="5" goto :exit

echo.
echo  ❌ Scelta non valida!
pause
goto :eof

:launch_server
echo.
echo  Controllo Python...
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    where python3 >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo  ❌ Python non trovato!
        echo.
        echo  Installa Python da: https://www.python.org
        echo.
        pause
        goto :eof
    )
    set PYTHON=python3
) else (
    set PYTHON=python
)

echo  ✓ Python trovato: !PYTHON!
echo.
echo  🚀 Avvio server...
echo  📂 Cartella: C:\Users\fabio\Desktop\APPs\MatchRecording
echo  🌐 URL: http://localhost:8000/test_recording.html
echo.
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

start "" "http://localhost:8000/test_recording.html"

!PYTHON! start_test_server.py

pause
goto :eof

:open_test
echo.
echo  Apertura test_recording.html...
start "" "http://localhost:8000/test_recording.html"
pause
goto :eof

:open_guide
echo.
echo  Apertura guida...
start notepad "TEST_RECORDING_GUIDE.md"
pause
goto :eof

:check_port
echo.
echo  Controllo porta 8000...
netstat -ano | findstr :8000
if %ERRORLEVEL% EQU 0 (
    echo.
    echo  ⚠️  Porta 8000 è in uso
) else (
    echo.
    echo  ✓ Porta 8000 è libera
)
pause
goto :eof

:exit
echo.
exit /b 0
