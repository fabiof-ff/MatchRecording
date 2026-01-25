@echo off
REM Script di avvio rapido per Match Recording App - Windows

echo.
echo 🚀 Match Recording App - Flutter Setup
echo ======================================
echo.

REM Controlla Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter non trovato nel PATH
    echo Prova con: C:\flutter\bin\flutter
    pause
    exit /b 1
)

echo ✅ Flutter trovato
C:\flutter\bin\flutter --version

REM Vai alla cartella progetto
echo.
echo 📁 Cartella progetto: %cd%
echo.

REM Scarica dipendenze
echo 📦 Scaricamento dipendenze...
C:\flutter\bin\flutter pub get

if %errorlevel% neq 0 (
    echo ❌ Errore nel download dipendenze
    pause
    exit /b 1
)

echo.
echo ✅ Dipendenze installate!
echo.

REM Controlla dispositivi
echo 📱 Dispositivi disponibili:
C:\flutter\bin\flutter devices

echo.
echo 🎮 Comandi disponibili:
echo.
echo   flutter run          - Avvia l'app
echo   flutter run -v       - Avvia con log dettagliati
echo   flutter emulators    - Lista emulatori
echo   flutter analyze      - Controlla errori codice
echo   flutter build apk    - Crea APK per Android
echo.
echo ✨ Per avviare: flutter run
echo.
pause
