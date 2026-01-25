@echo off
REM Script veloce per lanciare l'app web in Chrome (modalità desenvolvimento)

echo ========================================
echo  Match Recording - Web App (Dev Mode)
echo ========================================
echo.

echo Scaricamento dipendenze...
flutter pub get

echo.
echo Avvio dell'app web in Chrome (porta 8080)...
echo Accedi a: http://localhost:8080
echo.

flutter run -d web-server --web-port=8080 --web-renderer=html

pause
