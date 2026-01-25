@echo off
REM Script per buildare l'app web per la produzione

echo ========================================
echo  Match Recording - Build Web App
echo ========================================
echo.

echo Pulizia build precedenti...
flutter clean

echo.
echo Scaricamento dipendenze...
flutter pub get

echo.
echo Build web app per produzione...
echo Renderer: HTML (compatibile con tutti i browser)
echo.

flutter build web --release --web-renderer html

echo.
echo ========================================
echo Build completato!
echo Files disponibili in: build\web\
echo ========================================
echo.

pause
