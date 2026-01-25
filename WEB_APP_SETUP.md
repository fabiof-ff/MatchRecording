# Match Recording - Web App Configuration

## Configurazione Web App

L'app è stata configurata per essere lanciata come web app in Chrome.

### Script di lancio

#### 1. **run_web_dev.bat** (Consigliato per sviluppo)
Avvia l'app in modalità sviluppo con hot reload:
```bash
run_web_dev.bat
```
- Porta: 8080
- URL: http://localhost:8080
- Renderer: HTML (migliore compatibilità)
- Hot reload: ✅ Abilitato

#### 2. **run_web_chrome.bat** (Build + Launch)
Pulisce, compila e lancia l'app:
```bash
run_web_chrome.bat
```
- Fa il clean dei build precedenti
- Build completo
- Lancia automaticamente in Chrome

#### 3. **build_web.bat** (Build produzione)
Crea il build ottimizzato per produzione:
```bash
build_web.bat
```
- Output: `build/web/`
- Ottimizzato per performance
- Pronto per il deploy

### Configurazione effettuata

✅ **pubspec.yaml**: Aggiunto il supporto dev dependencies
✅ **web/index.html**: Aggiunto viewport e meta tags per Chrome
✅ **web/manifest.json**: Configurato per PWA standalone
✅ **Flutter web**: Renderer HTML per massima compatibilità

### Requisiti

- Flutter SDK installato
- Chrome browser installato
- Connessione Internet (primo run)

### Come usare

1. **Prima volta**: Esegui `run_web_chrome.bat` per un build completo
2. **Sviluppo**: Usa `run_web_dev.bat` per avvio veloce con hot reload
3. **Deploy**: Esegui `build_web.bat` e carica i file da `build/web/`

### Troubleshooting

Se ricevi errori:
1. Assicurati che Flutter sia installato correttamente
2. Esegui: `flutter doctor`
3. Se mancano dipendenze: `flutter pub get`
4. Pulisci cache: `flutter clean`

### Disabilitare la camera per il web (se necessario)

Se la camera causa errori sul web, installa dipendenze web-specific:
```bash
flutter pub add camera_web --web-only
```

---

**Nota**: L'app è stata configurata per il web. I moduli nativi (camera, video_player) potrebbero richiedere plugin web-specific per funzionare completamente nel browser.
