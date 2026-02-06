import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller per la registrazione video su piattaforma web
class WebVideoRecorder {
  html.MediaStream? _cameraStream;
  html.MediaStream? _canvasStream;
  html.MediaRecorder? _mediaRecorder;
  final List<html.Blob> _recordedChunks = [];
  final List<html.Blob> _allVideoSegments = []; // Per salvare segmenti multipli
  bool _isRecording = false;
  bool _isPausedBySystem = false; // Flag per pausa da sistema
  bool _isSavingPartialVideo = false; // Flag per evitare salvataggi multipli
  Timer? _memoryCleanupTimer; // Timer per pulizia periodica memoria
  int _segmentCount = 0; // Contatore segmenti video
  
  html.CanvasElement? _canvas;
  html.VideoElement? _videoElement;
  Timer? _drawTimer;
  int _frameCount = 0;
  String _mimeType = 'video/webm;codecs=vp9';
  String _fileExtension = 'webm';
  
  // Callback per notificare pausa/ripresa
  Function()? onSystemPause;
  Function()? onSystemResume;
  Function(String videoPath)? onAutoSave;
  
  // Dati overlay
  String team1Name = 'Squadra 1';
  String team2Name = 'Squadra 2';
  String team1Color = '#2196F3'; // Blu
  String team2Color = '#F44336'; // Rosso
  int team1Score = 0;
  int team2Score = 0;
  String matchTime = '00:00';
  String halfTime = '1° T';
  bool isLandscape = false; // Orientamento del dispositivo
  
  /// Aggiorna lo stream della camera (per switch camera durante registrazione)
  void updateCameraStream(html.MediaStream newStream) {
    print('🔄 Aggiornamento stream camera nel recorder');
    
    // Aggiorna il riferimento allo stream
    _cameraStream = newStream;
    
    // Se il video element esiste, aggiorna anche quello
    if (_videoElement != null) {
      _videoElement!.srcObject = newStream;
      print('✅ Video element aggiornato con nuovo stream');
    }
  }
  
  /// Aggiorna i dati dell'overlay
  void updateOverlay({
    String? team1Name,
    String? team2Name,
    String? team1Color,
    String? team2Color,
    int? team1Score,
    int? team2Score,
    String? matchTime,
    String? halfTime,
    bool? isLandscape,
  }) {
    if (team1Name != null) this.team1Name = team1Name;
    if (team2Name != null) this.team2Name = team2Name;
    if (team1Color != null) this.team1Color = team1Color;
    if (team2Color != null) this.team2Color = team2Color;
    if (team1Score != null) this.team1Score = team1Score;
    if (team2Score != null) this.team2Score = team2Score;
    if (matchTime != null) this.matchTime = matchTime;
    if (halfTime != null) this.halfTime = halfTime;
    if (isLandscape != null) this.isLandscape = isLandscape;
    
    // Debug: stampa i valori aggiornati inclusi i colori
    print('🎯 Overlay values: $team1Name $team1Score - $team2Score $team2Name | $matchTime $halfTime | Colors: T1=${this.team1Color} T2=${this.team2Color} | Landscape: ${this.isLandscape}');
  }
  
  /// Avvia la registrazione video web con overlay
  Future<void> startRecording() async {
    // Previeni doppie chiamate
    if (_isRecording) {
      print('⚠️ Registrazione già in corso, ignoro chiamata duplicata');
      return;
    }
    
    try {
      // Setup listener per visibilità pagina
      _setupVisibilityListener();
      
      // Prova constraint multipli in ordine di preferenza per massima compatibilità
      print('📹 Tentativo di accesso alla camera...');
      
      final constraints = [
        // Constraint 1: Camera posteriore con facingMode ideal
        {
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 2: Camera posteriore semplice
        {
          'video': {
            'facingMode': 'environment',
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 3: Camera frontale con resolution ideale (fallback)
        {
          'video': {
            'facingMode': 'user',
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 3: Qualsiasi camera con resolution
        {
          'video': {
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 4: Solo video generico (ultimo fallback)
        {
          'video': true,
          'audio': true,
        },
      ];
      
      Exception? lastError;
      for (var i = 0; i < constraints.length; i++) {
        try {
          print('📹 Tentativo ${i + 1}/${constraints.length}...');
          _cameraStream = await html.window.navigator.mediaDevices?.getUserMedia(constraints[i]);
          if (_cameraStream != null) {
            print('✅ Camera acquisita con constraint ${i + 1}');
            break;
          }
        } catch (e) {
          print('❌ Constraint ${i + 1} fallito: $e');
          lastError = e is Exception ? e : Exception(e.toString());
          if (i == constraints.length - 1) {
            throw lastError;
          }
        }
      }

      if (_cameraStream == null) {
        throw Exception('Impossibile accedere alla camera dopo ${constraints.length} tentativi');
      }

      // Crea video element per lo stream della camera
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = true
        ..srcObject = _cameraStream;
      
      // Imposta playsinline per iOS/Safari
      _videoElement!.setAttribute('playsinline', 'true');
      
      print('📹 Video element creato, attesa metadata...');

      // Attendi che il video sia pronto e avvialo
      await _videoElement!.onLoadedMetadata.first;
      print('📹 Metadata caricati');
      
      await _videoElement!.play();
      print('📹 Video.play() chiamato');
      
      // Attendi per essere sicuri che il video stia effettivamente riproducendo
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Crea canvas per composizione video + overlay
      final videoWidth = _videoElement!.videoWidth;
      final videoHeight = _videoElement!.videoHeight;
      
      if (videoWidth == 0 || videoHeight == 0) {
        throw Exception('Video non inizializzato correttamente: ${videoWidth}x${videoHeight}');
      }
      
      print('📐 Dimensioni video: ${videoWidth}x${videoHeight}');
      
      _canvas = html.CanvasElement(width: videoWidth, height: videoHeight);
      final ctx = _canvas!.context2D;

      // Cattura stream dal canvas PRIMA di iniziare a disegnare
      // captureStream() senza parametri cattura ogni volta che il canvas viene modificato
      _canvasStream = _canvas!.captureStream();
      
      // Aggiungi audio track dalla camera
      final audioTracks = _cameraStream!.getAudioTracks();
      if (audioTracks.isNotEmpty) {
        _canvasStream!.addTrack(audioTracks.first);
      }

      // Disegna frame con overlay ripetutamente (15 FPS - ottimizzato per iOS)
      _drawTimer = Timer.periodic(const Duration(milliseconds: 67), (_) {
        if (_canvas == null || _videoElement == null || ctx == null) return;
        
        // Verifica che il video sia in riproduzione
        if (_videoElement!.paused || _videoElement!.ended) {
          return;
        }
        
        // Pulisci il canvas
        ctx.clearRect(0, 0, videoWidth, videoHeight);
        
        // Disegna il video
        ctx.drawImageScaled(_videoElement!, 0, 0, videoWidth, videoHeight);
        
        // Disegna overlay (leggerà i valori aggiornati delle variabili)
        _drawOverlay(ctx, videoWidth, videoHeight);
      });

      // Determina il mimeType supportato dal browser
      final supportedTypes = [
        'video/mp4',
        'video/mp4;codecs=avc1',
        'video/webm;codecs=h264',
        'video/webm;codecs=vp9',
        'video/webm',
      ];
      
      for (var type in supportedTypes) {
        if (html.MediaRecorder.isTypeSupported(type)) {
          _mimeType = type;
          _fileExtension = type.startsWith('video/mp4') ? 'mp4' : 'webm';
          print('🎬 Formato video supportato: $_mimeType');
          break;
        }
      }

      // Crea MediaRecorder dal canvas stream con chunk di 15 secondi
      _mediaRecorder = html.MediaRecorder(_canvasStream!, {
        'mimeType': _mimeType,
      });

      _recordedChunks.clear();
      _allVideoSegments.clear();
      _segmentCount = 0;

      // Ascolta i dati registrati
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blobEvent = event as html.BlobEvent;
        if (blobEvent.data != null && blobEvent.data!.size > 0) {
          _recordedChunks.add(blobEvent.data!);
          final sizeMB = blobEvent.data!.size / (1024 * 1024);
          print('📦 Chunk ricevuto: ${sizeMB.toStringAsFixed(2)} MB - Totale chunks: ${_recordedChunks.length}');
        } else {
          print('⚠️ Chunk vuoto ricevuto');
        }
      });

      // Avvia la registrazione con timeslice di 30 secondi
      // Ottimizzato per iPhone SE con registrazioni lunghe (1 ora)
      // 30s = 120 chunk/ora invece di 240, riduce carico memoria del 50%
      _mediaRecorder!.start(30000); // 30000ms = 30 secondi
      _isRecording = true;
      
      // Avvia timer di pulizia memoria ogni 20 secondi
      _startMemoryCleanup();

      print('🎥 Registrazione web avviata');
      print('📹 Genererò un chunk ogni 30 secondi (ottimizzato per iPhone SE)');
    } catch (e) {
      print('❌ Errore avvio registrazione web: $e');
      rethrow;
    }
  }

  /// Ferma la registrazione e salva il video
  Future<String> stopRecording() async {
    if (!_isRecording || _mediaRecorder == null) {
      throw Exception('Nessuna registrazione in corso');
    }

    // Previeni chiamate multiple - segna subito come non in registrazione
    _isRecording = false;

    final completer = Completer<String>();
    
    print('🛑 Fermo registrazione, chunk attuali: ${_recordedChunks.length}, segmenti consolidati: ${_allVideoSegments.length}');

    // Ascolta l'evento di stop UNA SOLA VOLTA
    void handleStop(html.Event event) {
      // Rimuovi il listener per evitare chiamate multiple
      _mediaRecorder!.removeEventListener('stop', handleStop);
      
      // Aspetta un attimo per assicurarsi che l'ultimo chunk sia arrivato
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          // Combina tutti i segmenti consolidati + chunk rimanenti
          final List<html.Blob> allBlobs = [..._allVideoSegments, ..._recordedChunks];
          print('📦 Creazione video finale da ${allBlobs.length} segmenti/chunks');
          print('📊 Segmenti consolidati: ${_allVideoSegments.length}');
          print('📊 Chunks rimanenti: ${_recordedChunks.length}');
          
          if (allBlobs.isEmpty) {
            print('❌ Nessun dato video da salvare!');
            completer.completeError('Nessun dato video disponibile');
            return;
          }
          
          // Crea un blob dal video registrato con il tipo corretto
          final blob = html.Blob(allBlobs, _mimeType);
          
          // Crea nome file con timestamp ed estensione corretta
          final timestamp = DateTime.now();
          final fileName = 'match_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.$_fileExtension';

          // Crea URL per il blob
          final url = html.Url.createObjectUrlFromBlob(blob);

          // Crea elemento anchor per il download
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', fileName)
            ..style.display = 'none';

          // Aggiungi al DOM, clicca e rimuovi
          html.document.body?.append(anchor);
          anchor.click();
          anchor.remove();

          // Rilascia l'URL
          html.Url.revokeObjectUrl(url);

          final sizeMB = (blob.size / (1024 * 1024)).toStringAsFixed(2);
          
          print('✅ Video salvato: $fileName');
          print('📊 Dimensione totale: $sizeMB MB');

          completer.complete(fileName);
        } catch (e) {
          print('❌ Errore nel salvataggio: $e');
          completer.completeError(e);
        }
      });
    }
    
    // Registra il listener per l'evento stop
    _mediaRecorder!.addEventListener('stop', handleStop);

    // Richiedi esplicitamente l'ultimo chunk prima di fermare
    try {
      _mediaRecorder!.requestData();
      print('📤 Richiesto ultimo chunk prima dello stop');
    } catch (e) {
      print('⚠️ Non è stato possibile richiedere l\'ultimo chunk: $e');
    }
    
    // Aspetta un momento per dare tempo al chunk di essere generato
    await Future.delayed(const Duration(milliseconds: 100));

    // Ferma la registrazione - questo triggerera' l'evento onStop
    _mediaRecorder!.stop();

    // Ferma il timer di disegno
    _drawTimer?.cancel();
    _drawTimer = null;
    
    // Ferma il timer di cleanup memoria
    _memoryCleanupTimer?.cancel();
    _memoryCleanupTimer = null;

    // Ferma tutti i track degli stream
    _cameraStream?.getTracks().forEach((track) {
      track.stop();
    });
    _canvasStream?.getTracks().forEach((track) {
      track.stop();
    });

    return completer.future;
  }
  
  /// Disegna overlay sul canvas
  void _drawOverlay(html.CanvasRenderingContext2D ctx, int width, int height) {
    // Debug ogni secondo
    _frameCount++;
    if (_frameCount % 30 == 0) {
      print('🎨 Drawing overlay: $team1Name $team1Score - $team2Score $team2Name | $matchTime | Landscape: $isLandscape | COLORS: T1=$team1Color T2=$team2Color');
    }
    
    ctx.save();
    
    // Colori
    final bgColor = 'rgba(0, 0, 0, 0.7)';
    final textColor = 'white';
    
    if (isLandscape) {
      // === LAYOUT LANDSCAPE COMPATTO - IDENTICO ALLA PREVIEW ===
      // Overlay compatto in alto a sinistra (5, 5)
      final boxX = 5.0;
      final boxY = 5.0;
      final padding = 6.0;
      final spacing = 4.0;
      
      // Calcola dimensioni del box
      ctx.font = 'bold 15px monospace';
      final timerWidth = ctx.measureText(matchTime).width!.toDouble();
      ctx.font = 'bold 13px Arial';
      final halfTimeWidth = ctx.measureText(' $halfTime').width!.toDouble();
      ctx.font = '600 15px Arial';
      final team1NameText = team1Name.length > 10 ? team1Name.substring(0, 10) : team1Name;
      final team2NameText = team2Name.length > 10 ? team2Name.substring(0, 10) : team2Name;
      
      final boxWidth = padding + timerWidth + spacing + halfTimeWidth + spacing + 8 + // Timer section
                       3 + 6 + 85 + spacing + 8 + // Team 1 (rettangolo + nome + punteggio)
                       3 + 6 + 85 + padding; // Team 2 (rettangolo + nome + punteggio)
      final boxHeight = padding * 2 + 34;
      
      // Disegna box background
      ctx.fillStyle = bgColor;
      _drawRoundedRect(ctx, boxX, boxY, boxWidth, boxHeight, 8);
      ctx.fill();
      
      var currentX = boxX + padding;
      final centerY = boxY + boxHeight / 2;
      
      // 1. Timer
      ctx.fillStyle = textColor;
      ctx.font = 'bold 15px monospace';
      ctx.textBaseline = 'middle';
      ctx.textAlign = 'left';
      ctx.fillText(matchTime, currentX, centerY);
      currentX += timerWidth + spacing;
      
      // 2. HalfTime (1°T / 2°T)
      ctx.font = 'bold 13px Arial';
      ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
      ctx.fillText(halfTime, currentX, centerY);
      currentX += halfTimeWidth + spacing + 8;
      
      // 3. Team 1 - Rettangolo colorato
      ctx.fillStyle = team1Color; // Colore personalizzato Team 1
      ctx.fillRect(currentX, boxY + 8, 3, boxHeight - 16);
      currentX += 3 + 6;
      
      // Team 1 - Nome (troncato a 10 caratteri)
      final team1Text = team1NameText.length > 10 ? team1NameText.substring(0, 10) : team1NameText;
      ctx.fillStyle = textColor;
      ctx.font = '600 15px Arial';
      ctx.textAlign = 'center';
      final team1X = currentX + 42;
      ctx.fillText(team1Text, team1X, centerY - 7);
      
      // Team 1 - Punteggio
      ctx.font = 'bold 15px Arial';
      ctx.fillText('${team1Score}', team1X, centerY + 7);
      currentX += 85 + spacing + 8;
      
      // 4. Team 2 - Rettangolo colorato
      ctx.fillStyle = team2Color; // Colore personalizzato Team 2
      ctx.fillRect(currentX, boxY + 8, 3, boxHeight - 16);
      currentX += 3 + 6;
      
      // Team 2 - Nome (troncato a 10 caratteri)
      final team2Text = team2NameText.length > 10 ? team2NameText.substring(0, 10) : team2NameText;
      ctx.fillStyle = textColor;
      ctx.font = '600 15px Arial';
      ctx.textAlign = 'center';
      final team2X = currentX + 42;
      ctx.fillText(team2Text, team2X, centerY - 7);
      
      // Team 2 - Punteggio
      ctx.font = 'bold 15px Arial';
      ctx.fillText('${team2Score}', team2X, centerY + 7);
      
    } else {
      // === LAYOUT VERTICALE ===
      final margin = 16.0;
      final borderRadius = 6.0;
      
      // BOX TEMPO (in alto a sinistra) - più grande
      final timeBoxX = margin;
      final timeBoxY = margin;
      final timeBoxWidth = 170.0; // Aumentato per tempo + 1°T/2°T
      final timeBoxHeight = 42.0; // Aumentato
    
    ctx.fillStyle = bgColor;
    _drawRoundedRect(ctx, timeBoxX, timeBoxY, timeBoxWidth, timeBoxHeight, borderRadius);
    ctx.fill();
    
    // Icona orologio
    ctx.fillStyle = textColor;
    ctx.font = '18px Arial'; // Font ingrandito
    ctx.fillText('🕐', timeBoxX + 12, timeBoxY + 13);
    
    // Testo tempo
    ctx.font = 'bold 16px monospace'; // Font ingrandito
    ctx.textBaseline = 'middle';
    ctx.fillText(matchTime, timeBoxX + 42, timeBoxY + timeBoxHeight / 2);
    
    // Indicatore tempo (1° T / 2° T)
    ctx.font = 'bold 13px Arial'; // Font ingrandito
    ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
    ctx.fillText(halfTime, timeBoxX + 125, timeBoxY + timeBoxHeight / 2);
    
    // BOX PUNTEGGIO (sotto il tempo) - più grande
    final scoreBoxX = timeBoxX;
    final scoreBoxY = timeBoxY + timeBoxHeight + 10;
    final scoreBoxWidth = 240.0; // Aumentato
    final scoreBoxHeight = 90.0; // Aumentato
    
    ctx.fillStyle = bgColor;
    _drawRoundedRect(ctx, scoreBoxX, scoreBoxY, scoreBoxWidth, scoreBoxHeight, 8.0);
    ctx.fill();
    
    // Testo squadre e punteggi
    ctx.fillStyle = textColor;
    
    // Team 1
    ctx.font = 'bold 12px Arial'; // Font ingrandito e bold
    ctx.textAlign = 'center';
    final team1X = scoreBoxX + scoreBoxWidth / 4;
    ctx.fillStyle = team1Color;
    ctx.fillText(team1Name, team1X, scoreBoxY + 22);
      
      ctx.font = 'bold 22px Arial'; // Font ingrandito
      ctx.fillText('$team1Score', team1X, scoreBoxY + 52);
      
      // Linea separatore verticale
      ctx.strokeStyle = textColor;
      ctx.lineWidth = 1.5; // Linea più spessa
      ctx.beginPath();
      ctx.moveTo(scoreBoxX + scoreBoxWidth / 2, scoreBoxY + 15);
      ctx.lineTo(scoreBoxX + scoreBoxWidth / 2, scoreBoxY + scoreBoxHeight - 15);
      ctx.stroke();
      
      // Team 2
      ctx.font = 'bold 12px Arial'; // Font ingrandito e bold
      final team2X = scoreBoxX + 3 * scoreBoxWidth / 4;
      ctx.fillStyle = team2Color;
      ctx.fillText(team2Name, team2X, scoreBoxY + 22);
    
      ctx.font = 'bold 22px Arial'; // Font ingrandito
      ctx.fillText('$team2Score', team2X, scoreBoxY + 52);
    }
    
    ctx.restore();
  }
  
  /// Disegna rettangolo con angoli arrotondati
  void _drawRoundedRect(html.CanvasRenderingContext2D ctx, double x, double y, double width, double height, double radius) {
    ctx.beginPath();
    ctx.moveTo(x + radius, y);
    ctx.lineTo(x + width - radius, y);
    ctx.arcTo(x + width, y, x + width, y + radius, radius);
    ctx.lineTo(x + width, y + height - radius);
    ctx.arcTo(x + width, y + height, x + width - radius, y + height, radius);
    ctx.lineTo(x + radius, y + height);
    ctx.arcTo(x, y + height, x, y + height - radius, radius);
    ctx.lineTo(x, y + radius);
    ctx.arcTo(x, y, x + radius, y, radius);
    ctx.closePath();
  }

  /// Verifica se è in registrazione
  bool get isRecording => _isRecording;
  
  /// Verifica se è in pausa per motivi di sistema
  bool get isPausedBySystem => _isPausedBySystem;
  
  /// Avvia timer di pulizia periodica memoria (ogni 20 secondi)
  /// Ottimizzato per iPhone SE con memoria limitata
  void _startMemoryCleanup() {
    _memoryCleanupTimer?.cancel();
    _memoryCleanupTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!_isRecording || _recordedChunks.isEmpty) return;
      
      final chunksCount = _recordedChunks.length;
      final totalSize = _recordedChunks.fold<int>(0, (sum, blob) => sum + blob.size);
      final sizeMB = totalSize / (1024 * 1024);
      
      print('🧹 Pulizia memoria - Chunks: $chunksCount, Dimensione: ${sizeMB.toStringAsFixed(2)} MB');
      
      // Se ci sono più di 30 chunk (15 minuti con chunk da 30s)
      // consolida i chunk in un blob unico per liberare memoria
      // Per 1 ora avrai 4 consolidamenti invece di tenere 120 chunk in memoria
      if (chunksCount > 30) {
        print('⚠️ Troppi chunk in memoria ($chunksCount), consolido...');
        _consolidateChunks();
      }
    });
  }
  
  /// Consolida i chunk esistenti in un unico blob per liberare memoria
  void _consolidateChunks() {
    if (_recordedChunks.isEmpty) return;
    
    try {
      // Crea un blob consolidato con tutti i chunk attuali
      final consolidatedBlob = html.Blob(_recordedChunks, _mimeType);
      _allVideoSegments.add(consolidatedBlob);
      _segmentCount++;
      
      final sizeMB = consolidatedBlob.size / (1024 * 1024);
      print('✅ Segmento #$_segmentCount consolidato: ${sizeMB.toStringAsFixed(2)} MB');
      
      // Pulisci i chunk dalla memoria
      _recordedChunks.clear();
      
      // Forza garbage collection (suggerimento al browser)
      print('🗑️ Memoria liberata');
    } catch (e) {
      print('❌ Errore consolidamento chunk: $e');
    }
  }

  /// Setup listener per visibilità pagina (interruzioni)
  /// DISABILITATO: Su iOS causava richiesta permessi camera al ritorno
  void _setupVisibilityListener() {
    // NON gestiamo più la visibilità perché:
    // 1. iOS revoca i permessi camera se fermiamo lo stream
    // 2. MediaRecorder continua anche in background
    // 3. Wake Lock (se disponibile) previene il lock dello schermo
    
    // Tentiamo di acquisire Wake Lock per prevenire sleep
    _requestWakeLock();
    
    print('👁️ Listener visibilità DISABILITATO (fix iOS)');
  }
  
  /// Richiede Wake Lock per prevenire sleep dello schermo durante registrazione
  void _requestWakeLock() {
    try {
      // Wake Lock API (disponibile su browser moderni)
      final navigator = html.window.navigator;
      if (navigator.toString().contains('wakeLock')) {
        // @ts-ignore - API non ancora in dart:html
        final wakeLock = js.context.callMethod('eval', ['navigator.wakeLock']);
        if (wakeLock != null) {
          js.context.callMethod('eval', [
            'navigator.wakeLock.request("screen").then(() => console.log("🔒 Wake Lock attivato")).catch(e => console.log("⚠️ Wake Lock non disponibile:", e))'
          ]);
        }
      }
    } catch (e) {
      print('⚠️ Wake Lock non supportato: $e');
    }
  }
  
  // Metodi di gestione background RIMOSSI
  // La registrazione continua anche se l'app va in background
  // iOS potrebbe mettere in pausa automaticamente, ma lo stream non viene fermato

  /// Cleanup
  void dispose() {
    if (_isRecording) {
      _mediaRecorder?.stop();
    }
    _drawTimer?.cancel();
    _memoryCleanupTimer?.cancel();
    _cameraStream?.getTracks().forEach((track) {
      track.stop();
    });
    _canvasStream?.getTracks().forEach((track) {
      track.stop();
    });
    _recordedChunks.clear();
    _allVideoSegments.clear();
  }
}
