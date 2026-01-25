# Script PowerShell per lanciare l'app web in Chrome

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Match Recording - Web App Launcher" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se Flutter è installato
$flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutter) {
    Write-Host "ERRORE: Flutter non trovato nel PATH" -ForegroundColor Red
    Write-Host "Installa Flutter o aggiungi al PATH di sistema" -ForegroundColor Red
    pause
    exit
}

Write-Host "Scaricamento dipendenze..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Avvio del server web su porta 8080..." -ForegroundColor Yellow
Write-Host "L'app sarà disponibile su: http://localhost:8080" -ForegroundColor Green
Write-Host ""

# Avvia il server Flutter in background
Write-Host "Avvio del server Flutter..." -ForegroundColor Yellow
$process = Start-Process -FilePath "flutter" -ArgumentList "run", "-d", "web-server", "--web-port=8080" -PassThru -WindowStyle Normal

# Attendi che il server sia pronto (circa 15 secondi)
Write-Host "Attendere l'avvio del server (15-20 secondi)..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Prova ad aprire Chrome in vari percorsi
$chromePaths = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe"
)

$chromeFound = $false
foreach ($path in $chromePaths) {
    if (Test-Path $path) {
        Write-Host "Chrome trovato: $path" -ForegroundColor Green
        Write-Host "Apertura di Chrome..." -ForegroundColor Yellow
        Start-Process $path -ArgumentList "http://localhost:8080" -WindowStyle Maximized
        $chromeFound = $true
        break
    }
}

if (-not $chromeFound) {
    Write-Host "Chrome non trovato nel PATH standard" -ForegroundColor Yellow
    Write-Host "Apri manualmente il browser e vai a: http://localhost:8080" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "Server in esecuzione. Premi Ctrl+C per arrestare." -ForegroundColor Green
$process.WaitForExit()
