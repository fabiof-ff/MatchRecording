# ⚽ Test di Registrazione - Guida Rapida

## 🚀 Avvio Rapido

### Opzione 1: Batch File (più semplice - Windows)
```batch
run_test_server.bat
```

### Opzione 2: Python Script (multipiattaforma)
```bash
# Windows PowerShell
python start_test_server.py

# macOS/Linux
python3 start_test_server.py
```

### Opzione 3: Manuale HTTP Server
```bash
python -m http.server 8000
# Poi apri: http://localhost:8000/test_recording.html
```

---

## 📋 Cosa Testare

### 1️⃣ **Registrazione Base**
- [ ] Clicca **"INIZIA REGISTRAZIONE"**
- [ ] Cronometro parte e incrementa ogni secondo
- [ ] Badge cambia a "REC" (rosso lampeggiante)
- [ ] Video preview ha animazione di registrazione

### 2️⃣ **Controlli Punteggio**
- [ ] Squadra 1: prova +1 e -1
- [ ] Squadra 2: prova +1 e -1
- [ ] Punteggio aggiorna in tempo reale
- [ ] Overlay scoreboard mostra il punteggio aggiornato

### 3️⃣ **Marcatura Highlights**
- [ ] Durante la registrazione, clicca **"MARCA HIGHLIGHT"**
- [ ] Highlight appare in lista con timestamp
- [ ] Tasto disabilitato quando registrazione ferma

### 4️⃣ **Gestione Highlights**
- [ ] Aggiungi 3-5 highlights a tempi diversi
- [ ] Lista mostra tutti gli highlights con timestamp
- [ ] Statistiche aggiornate (count, durata totale, score)

### 5️⃣ **Ferma Registrazione**
- [ ] Clicca **"FERMA REGISTRAZIONE"**
- [ ] Cronometro si ferma
- [ ] Badge torna a "READY"
- [ ] Alert conferma fine registrazione

### 6️⃣ **Export MP4**
- [ ] Clicca **"EXPORT MP4"**
- [ ] Progress bar appare e avanza
- [ ] Percentuale aumenta fino al 100%
- [ ] Alert finale mostra filename

### 7️⃣ **Riepilogo Completo**
- [ ] Sezione summary mostra:
  - Durata totale registrazione
  - Numero highlights marcati
  - Score finale
  - Coverage percentage
  - Dettagli di ogni highlight

### 8️⃣ **Gestione Dati**
- [ ] Tasto **"CANCELLA TUTTI"** rimuove tutti highlights
- [ ] Conferma prima di cancellare
- [ ] Alert di conferma cancellazione

---

## ✅ Checklist Test Completo

### Test Scenario 1: Partita Corta (5 minuti)
```
1. Inizia registrazione
2. Aggiungi gol T1 al minuto 1
3. Marca highlight
4. Aggiungi gol T2 al minuto 3
5. Marca highlight
6. Aggiungi gol T1 al minuto 4
7. Marca highlight
8. Ferma registrazione (5 minuti)
9. Export MP4
10. Verifica riepilogo mostra: 2 gol T1, 1 gol T2, 3 highlights
```

### Test Scenario 2: Partita Lunga (90 minuti)
```
1. Inizia registrazione
2. Incrementa cronometro manualmente (auto-incrementa ogni secondo)
3. Aggiungi gol a intervalli
4. Marca highlights durante il gioco
5. Attendi 90 minuti di registrazione (velocizza con loop)
6. Ferma registrazione
7. Esporta video
```

---

## 🎯 Aspettative di Funzionamento

| Feature | Status | Note |
|---------|--------|------|
| Cronometro | ✅ Funziona | Incrementa ogni secondo |
| Punteggio | ✅ Funziona | +/- buttons funzionano |
| Highlights | ✅ Funziona | Registra timestamp e score |
| Overlay | ✅ Funziona | Mostra timer e scoreboard |
| Export | ✅ Simulato | Progress bar per UX test |
| Riepilogo | ✅ Funziona | Statistiche complete |
| Persistenza | ⚠️ No | Solo in RAM (sessionali) |

---

## 📊 Metriche di Validazione

Dopo il test, verifica:

✅ **UI Responsività**
- [ ] Nessun lag nei click
- [ ] Aggiornamenti immediati
- [ ] Animazioni fluide

✅ **Logica di Stato**
- [ ] Punteggio mai negativo
- [ ] Highlight marcati solo quando recording
- [ ] Export solo con highlights presenti

✅ **Feedback Utente**
- [ ] Alert chiari per ogni azione
- [ ] Badge stato ben visibile
- [ ] Indicatori colori coerenti

✅ **Layout Responsivo**
- [ ] Desktop (1400px+)
- [ ] Tablet (768px-1024px)
- [ ] Mobile (< 768px)

---

## 🐛 Troubleshooting

### "Address already in use" (Porta 8000)
```powershell
# Trova processo su porta 8000
netstat -ano | findstr :8000

# Termina il processo (es: PID 1234)
taskkill /PID 1234 /F

# O usa porta diversa
python -m http.server 8001
```

### Browser non si apre automaticamente
```
Apri manualmente: http://localhost:8000/test_recording.html
```

### Python non trovato
```powershell
# Verifica Python installato
python --version

# Se non funziona, scarica da:
https://www.python.org/downloads/
```

---

## 📝 Note Importanti

1. **Dati Sessionali**: I dati del test rimangono solo in sessione browser
2. **Export Simulato**: L'export MP4 è simulato (no file reale salvato)
3. **Overlays**: Gli overlays sono renderizzati come preview statica
4. **Camera**: Camera preview è simulata (no accesso camera reale)

---

## 🔄 Prossimi Passi

Dopo validazione del test:

1. **Device/Emulator Testing**
   - Build APK per Android
   - Testare su Android emulator o device
   - Verificare camera reale

2. **Camera Integration**
   - Implementare CameraController
   - Testare preview live
   - Validare recording reale

3. **Video Export**
   - Integrare FFmpeg per conversione
   - Testare MP4 output reale
   - Validare qualità video

4. **Persistence**
   - Implementare Hive/SQLite
   - Salvare highlights permanentemente
   - Recuperare da storage

---

## 📞 Supporto

Per problemi:
1. Controlla la console del browser (F12)
2. Leggi gli alert informativi
3. Prova a riavviare il server
4. Cancella cache e ricarica pagina

---

**Enjoy! ⚽🎥**
