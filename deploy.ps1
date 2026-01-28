# Script di deploy automatico con aggiornamento timestamp

Write-Host "Inizio processo di deploy..." -ForegroundColor Green

# 1. Ottieni timestamp corrente
$timestamp = Get-Date -Format "dd/MM/yyyy - HH:mm"
Write-Host "Timestamp: $timestamp" -ForegroundColor Cyan

# 2. Aggiorna il timestamp nel file home_screen.dart
$homeScreenPath = "lib\screens\home_screen.dart"
$content = Get-Content $homeScreenPath -Raw
$pattern = "Ultimo deploy: \d{2}/\d{2}/\d{4} - \d{2}:\d{2}"
$replacement = "Ultimo deploy: $timestamp"
$newContent = $content -replace $pattern, $replacement
Set-Content $homeScreenPath -Value $newContent -NoNewline
Write-Host "Timestamp aggiornato in home_screen.dart" -ForegroundColor Green

# 3. Build Flutter
Write-Host "Avvio build Flutter..." -ForegroundColor Yellow
flutter build web --release --base-href /MatchRecording/
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build fallito!" -ForegroundColor Red
    exit 1
}
Write-Host "Build completato" -ForegroundColor Green

# 4. Commit modifiche
Write-Host "Commit modifiche..." -ForegroundColor Yellow
git add lib/screens/home_screen.dart
git commit -m "UI: Timestamp aggiornato a $timestamp"
git add -f build/web/*
git commit -m "Build: Deploy $timestamp"

# 5. Push su master
Write-Host "Push su master..." -ForegroundColor Yellow
git push origin master
if ($LASTEXITCODE -ne 0) {
    Write-Host "Push su master fallito!" -ForegroundColor Red
    exit 1
}
Write-Host "Push su master completato" -ForegroundColor Green

# 6. Deploy su gh-pages
Write-Host "Deploy su gh-pages..." -ForegroundColor Yellow
$split = git subtree split --prefix build/web master
git push origin ${split}:refs/heads/gh-pages --force
if ($LASTEXITCODE -ne 0) {
    Write-Host "Deploy su gh-pages fallito!" -ForegroundColor Red
    exit 1
}
Write-Host "Deploy su gh-pages completato" -ForegroundColor Green

Write-Host ""
Write-Host "Deploy completato con successo!" -ForegroundColor Green
Write-Host "App disponibile su: https://fabiof-ff.github.io/MatchRecording/" -ForegroundColor Cyan
Write-Host "Timestamp: $timestamp" -ForegroundColor Cyan
