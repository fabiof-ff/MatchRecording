@echo off
REM Script veloce per lanciare l'app web (modalità development)

echo ========================================
echo  Match Recording - Web App (Dev Mode)
echo ========================================
echo.

echo Scaricamento dipendenze...
flutter pub get

echo.
echo ========================================
echo AVVIO DEL SERVER WEB
echo ========================================
echo.
echo L'app sara disponibile su: http://localhost:8080
echo Apri il browser e vai all'indirizzo sopra
echo.
echo Se vedi degli errori qui sotto, leggi il messaggio
echo.

REM Avvia il server Flutter
flutter run -d web-server --web-port=8080

pause
