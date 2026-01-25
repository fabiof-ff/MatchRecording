# ⚡ TEST REGISTRAZIONE - QUICKSTART

## 🎯 Comando Veloce (30 secondi setup)

### Windows
```batch
TEST_SERVER_MENU.bat
```
Scegli opzione **1** → Server avvia e browser si apre automaticamente

### macOS/Linux
```bash
python3 start_test_server.py
```

---

## 📂 Files del Test

| File | Descrizione | Comando |
|------|-------------|---------|
| `test_recording.html` | Test interattivo web | Apri in browser |
| `start_test_server.py` | Server Python (auto-open) | `python start_test_server.py` |
| `TEST_SERVER_MENU.bat` | Menu Windows | `TEST_SERVER_MENU.bat` |
| `TEST_RECORDING_GUIDE.md` | Guida dettagliata | Leggi prima del test |
| `TEST_REPORT.md` | Report validazione | Per reference |

---

## 🧪 Test in 3 Minuti

### Step 1️⃣: Avvia Server (30s)
```powershell
python start_test_server.py
```
Aspetta: **"✓ Browser aperto"**

### Step 2️⃣: Nel Browser (2min)
1. ⏹️ **Inizia Registrazione**
2. ⚽ **Aggiungi 2 gol** (una squadra per volta)
3. ⭐ **Marca 2 Highlights** (al primo e secondo gol)
4. ⏹️ **Ferma Registrazione** (aspetta 30 secondi)
5. 💾 **Esporta MP4** (visualizza progress)

### Step 3️⃣: Valida Risultati (30s)
✅ Verifiche:
- [ ] Timer incrementa ogni secondo
- [ ] Punteggio aggiorna correttamente
- [ ] Highlights marcati con timestamp
- [ ] Export simula correttamente
- [ ] Riepilogo mostra dati corretti

---

## 🎬 Video Demo Scenario

```
00:00 → Inizia registrazione (timer da 00:00)
00:15 → Gol Squadra 1 (score: 1-0)
00:16 → Marca highlight #1
00:45 → Gol Squadra 2 (score: 1-1)
00:46 → Marca highlight #2
01:30 → Ferma registrazione
```

**Risultato Atteso:**
- Durata: 00:01:30
- Score: 1-1
- Highlights: 2
- Coverage: 26.7%

---

## ✅ Checklist Validazione

- [ ] Cronometro parte al click
- [ ] Incremento visualizzato ogni secondo
- [ ] Punteggio aggiornabile durante registrazione
- [ ] Highlights marcati solo quando registrazione attiva
- [ ] Badge "REC" lampeggia rosso durante registrazione
- [ ] Overlay display mostra timer e score corretti
- [ ] Export MP4 simula con progress bar
- [ ] Clear highlights chiede conferma
- [ ] Riepilogo mostra statistiche complete

---

## 🔥 Tips & Tricks

### Velocizzare il Test
Apri console browser (F12) e copia-incolla:
```javascript
// Velocizza timer a 10 secondi
for (let i = 0; i < 10; i++) {
    state.elapsedTime += 60;
    document.getElementById('timer').textContent = 
        formatTime(state.elapsedTime);
}
```

### Testare Export Veloce
1. Marca 1 highlight
2. Ferma registrazione
3. Clicca "EXPORT MP4"
4. Vedi progress bar anima al 100%

### Debug State
```javascript
// Stampa stato corrente in console
console.log(state);

// Reset completo
state.highlights = [];
state.team1Score = 0;
state.team2Score = 0;
updateHighlightsList();
updateScore();
```

---

## 📊 Dati Test Registrati

Dopo il test, il report mostra:

```
╔══════════════════════════════════════╗
║     Durata Registrazione: 5:00      ║
║     Highlights Marcati: 3            ║
║     Score Finale: 2-1                ║
║     Coverage: 60%                    ║
╚══════════════════════════════════════╝
```

---

## 🐛 Troubleshooting

| Problema | Soluzione |
|----------|-----------|
| "Port 8000 in use" | Chiudi altro processo sulla porta 8000 |
| Browser non si apre | Apri manualmente: `http://localhost:8000/test_recording.html` |
| Python not found | Installa Python da https://www.python.org |
| Timeout | Controlla firewall, prova porta diversa: `python -m http.server 8001` |

---

## 🚀 Prossimi Step

✅ **Completato:** Web UI test
⏳ **Prossimo:** Device/Emulator testing
```bash
flutter run -d emulator-5554
# oppure
flutter run -d chrome
```

---

**Tempo stimato test completo:** 5 minuti ⏱️

🎯 **Goal:** Validare UI, logica state, e feedback utente prima di device testing
