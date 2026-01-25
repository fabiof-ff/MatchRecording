@echo off
REM Script per lanciare l'app Flutter come web app

echo ========================================
echo  Match Recording - Web App Launcher
echo ========================================
echo.
echo Pulizia build precedenti...
flutter clean
echo.

echo Scaricamento dipendenze...
flutter pub get
echo.

echo Build web app in progress...
flutter build web
echo.

echo Avvio del server web (porta 8080)...
echo Apri il browser e vai a: http://localhost:8080
echo.

flutter run -d web-server --web-port=8080
pause
