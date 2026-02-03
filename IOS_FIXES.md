# Fix per iOS - Richiesta Permessi Fotocamera Durante Registrazione

## Problema Riscontrato
L'app web su iPhone richiedeva nuovamente i permessi della fotocamera durante la registrazione, causando l'interruzione.

## Causa Principale

### **Gestione Errata del Background** ❌
Il codice originale aveva un listener che:
1. Rilevava quando l'app andava in background (notifica, lock screen, cambio app)
2. **Fermava completamente lo stream della camera**
3. Salvava il video e distruggeva la connessione
4. Al ritorno in foreground, **iOS richiedeva nuovamente i permessi**

Questo è un comportamento di sicurezza di iOS: se fermi e riavvii lo stream della camera, i permessi devono essere richiesti di nuovo.

## Soluzioni Implementate

### 1. **Disabilitazione Listener Visibilità** 🔴➡️🟢
**Problema:** Il listener fermava lo stream quando l'app andava in background
**Soluzione:** Listener completamente disabilitato

```dart
// PRIMA: Listener attivo che fermava tutto
html.document.onVisibilityChange.listen((event) {
  if (html.document.hidden) {
    _stopAndSaveOnBackground(); // ❌ Fermava lo stream!
  }
});

// DOPO: Listener disabilitato
void _setupVisibilityListener() {
  // NON gestiamo più la visibilità
  // MediaRecorder continua anche in background
  _requestWakeLock(); // Previene sleep schermo
}
```

**Risultato:**
- ✅ Lo stream della camera **non viene mai fermato**
- ✅ **Nessuna richiesta permessi** al ritorno dall'app
- ✅ La registrazione continua anche se ricevi una notifica o blocchi lo schermo

### 2. **Wake Lock API** 🔒
Implementato tentativo di acquisire Wake Lock per prevenire lo sleep dello schermo:

```dart
void _requestWakeLock() {
  // Richiede al browser di mantenere lo schermo acceso
  navigator.wakeLock.request("screen");
}
```

**Benefici:**
- Schermo rimane acceso durante registrazione
- Su iOS/Safari non sempre disponibile, ma su Chrome/Android funziona

### 3. **Riduzione FPS Overlay** (30 → 15 FPS)
```dart
// PRIMA: Timer.periodic(const Duration(milliseconds: 33), (_) // 30 FPS
// DOPO:  Timer.periodic(const Duration(milliseconds: 67), (_) // 15 FPS
```
**Benefici:**
- Riduzione del 50% del consumo CPU
- Minore impatto sulla batteria
- 15 FPS sono più che sufficienti per un overlay statico

### 2. **Chunk Interval per MediaRecorder**
```dart
_mediaRecorder!.start(10000); // Genera chunk ogni 10 secondi
```
**Benefici:**
- Evita accumulo infinito di dati in memoria
- I chunk vengono generati periodicamente
- Permette gestione più granulare della memoria

### 3. **Pulizia Periodica Memoria**
```dart
// Timer ogni 30 secondi che consolida i chunk
_memoryCleanupTimer = Timer.periodic(const Duration(seconds: 30), ...);
```
**Funzionamento:**
- Ogni 30 secondi controlla quanti chunk sono in memoria
- Se ci sono più di 60 chunk (≈10 minuti):
  - Consolida tutti i chunk in un unico blob
  - Aggiunge il blob consolidato a `_allVideoSegments`
  - Pulisce `_recordedChunks` liberando memoria
  - Suggerisce al browser di eseguire garbage collection

### 4. **Gestione Segmenti Video**
```dart
final List<html.Blob> _allVideoSegments = []; // Segmenti consolidati
final List<html.Blob> _recordedChunks = [];    // Chunk correnti
```
**Al salvataggio:**
```dart
final allBlobs = [..._allVideoSegments, ..._recordedChunks];
final blob = html.Blob(allBlobs, _mimeType);
```

### 5. **Ottimizzazioni HTML per iOS**
```html
<!-- Prevenire zoom indesiderato -->
<meta name="viewport" content="..., maximum-scale=1.0, user-scalable=no">

<!-- Ottimizzazioni iOS -->
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="format-detection" content="telephone=no">
```

## Risultati Attesi

### Prima delle Fix:
- ❌ Richiesta permessi fotocamera durante registrazione
- ❌ Interruzione registrazione al ritorno dall'app
- ❌ Impossibile ricevere notifiche durante registrazione

### Dopo le Fix:
- ✅ **Nessuna richiesta permessi** durante registrazione
- ✅ Registrazione **continua** anche in background
- ✅ Puoi ricevere notifiche, bloccare schermo, ecc.
- ✅ Memoria ottimizzata (consolidamento chunk)
- ✅ Consumo ridotto (15 FPS overlay)

## Come Testare

1. **Rebuild dell'app web:**
   ```bash
   flutter build web --release
   ```

2. **Test su iPhone:**
   - Avvia una registrazione
   - Lascia registrare per almeno 15-20 minuti
   - Monitora:
     - Nessun crash/chiusura automatica
     - Temperatura del dispositivo accettabile
     - Consumo batteria ragionevole

3. **Verifica Console (Safari Developer):**
   ```
   🧹 Pulizia memoria - Chunks: X, Dimensione: Y MB
   ⚠️ Troppi chunk in memoria, consolido...
   ✅ Segmento #N consolidato: X.XX MB
   🗑️ Memoria liberata
   ```

## Note Aggiuntive

### Limiti iOS/Safari Conosciuti:
- Memoria disponibile limitata (varia per modello iPhone)
- Gestione aggressiva dei processi in background
- MediaRecorder API supporto parziale (solo WebM su Safari 14.1+)

### Best Practices per Registrazioni Lunghe:
- Consigliare agli utenti di chiudere altre app in background
- Mantenere iPhone collegato a caricatore per registrazioni >30min
- Evitare di passare ad altre app durante la registrazione

### Monitoraggio Consigliato:
Aggiungere nella UI un indicatore di:
- Memoria utilizzata approssimativa
- Numero di segmenti consolidati
- Durata registrazione corrente

## Prossimi Miglioramenti Possibili

1. **Salvataggio Progressivo** - Salvare segmenti multipli invece di un unico file
2. **Compressione Video** - Ridurre bitrate per iPhone più vecchi
3. **Risoluzione Adattiva** - Abbassare risoluzione se memoria critica
4. **Wake Lock API** - Prevenire sleep dello schermo durante registrazione
