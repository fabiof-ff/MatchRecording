@echo off
REM Script per lanciare l'app Flutter come web app in Chrome

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
flutter build web --web-renderer html
echo.

echo Avvio dell'app in Chrome...
start chrome http://localhost:8080

echo.
echo Avvio del server web...
flutter run -d web-server --web-port=8080
pause
