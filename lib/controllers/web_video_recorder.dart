import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller per la registrazione video su piattaforma web
class WebVideoRecorder {
  html.MediaStream? _cameraStream;
  html.MediaStream? _canvasStream;
  html.MediaRecorder? _mediaRecorder;
  final List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;
  
  html.CanvasElement? _canvas;
  html.VideoElement? _videoElement;
  Timer? _drawTimer;
  int _frameCount = 0;
  String _mimeType = 'video/webm;codecs=vp9';
  String _fileExtension = 'webm';
  
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
    
    // Debug: stampa i valori aggiornati
    print('🎯 Overlay values: $team1Name $team1Score - $team2Score $team2Name | $matchTime $halfTime | Landscape: ${this.isLandscape}');
  }
  
  /// Avvia la registrazione video web con overlay
  Future<void> startRecording() async {
    try {
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

      // Disegna frame con overlay ripetutamente (30 FPS)
      _drawTimer = Timer.periodic(const Duration(milliseconds: 33), (_) {
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

      // Crea MediaRecorder dal canvas stream
      _mediaRecorder = html.MediaRecorder(_canvasStream!, {
        'mimeType': _mimeType,
      });

      _recordedChunks.clear();

      // Ascolta i dati registrati
      _mediaRecorder!.addEventListener('dataavailable', (event) {
        final blobEvent = event as html.BlobEvent;
        if (blobEvent.data != null && blobEvent.data!.size > 0) {
          _recordedChunks.add(blobEvent.data!);
        }
      });

      // Avvia la registrazione
      _mediaRecorder!.start();
      _isRecording = true;

      print('🎥 Registrazione web avviata');
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

    final completer = Completer<String>();

    // Ascolta l'evento di stop
    _mediaRecorder!.addEventListener('stop', (event) {
      try {
        // Crea un blob dal video registrato con il tipo corretto
        final blob = html.Blob(_recordedChunks, _mimeType);
        
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
        print('📊 Dimensione: $sizeMB MB');

        completer.complete(fileName);
      } catch (e) {
        print('❌ Errore nel salvataggio: $e');
        completer.completeError(e);
      }
    });

    // Ferma la registrazione
    _mediaRecorder!.stop();
    _isRecording = false;

    // Ferma il timer di disegno
    _drawTimer?.cancel();
    _drawTimer = null;

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
      print('🎨 Drawing overlay: $team1Name $team1Score - $team2Score $team2Name | $matchTime | Landscape: $isLandscape');
    }
    
    ctx.save();
    
    // Colori
    final bgColor = 'rgba(0, 0, 0, 0.7)';
    final textColor = 'white';
    
    if (isLandscape) {
      // === LAYOUT LANDSCAPE COMPATTO - IDENTICO ALLA PREVIEW ===
      // Overlay compatto in alto a sinistra (0, 0)
      final boxX = 0.0;
      final boxY = 0.0;
      final padding = 6.0;
      final spacing = 4.0;
      
      // Calcola dimensioni del box
      ctx.font = 'bold 11px monospace';
      final timerWidth = ctx.measureText(matchTime).width!.toDouble();
      ctx.font = 'bold 9px Arial';
      final halfTimeWidth = ctx.measureText(' $halfTime').width!.toDouble();
      ctx.font = '600 11px Arial';
      final team1NameText = team1Name.length > 10 ? team1Name.substring(0, 10) : team1Name;
      final team2NameText = team2Name.length > 10 ? team2Name.substring(0, 10) : team2Name;
      
      final boxWidth = padding + timerWidth + spacing + halfTimeWidth + spacing + 8 + // Timer section
                       3 + 6 + 60 + spacing + 8 + // Team 1 (rettangolo + nome + punteggio)
                       3 + 6 + 60 + padding; // Team 2 (rettangolo + nome + punteggio)
      final boxHeight = padding * 2 + 30;
      
      // Disegna box background
      ctx.fillStyle = bgColor;
      _drawRoundedRect(ctx, boxX, boxY, boxWidth, boxHeight, 8);
      ctx.fill();
      
      var currentX = boxX + padding;
      final centerY = boxY + boxHeight / 2;
      
      // 1. Timer
      ctx.fillStyle = textColor;
      ctx.font = 'bold 11px monospace';
      ctx.textBaseline = 'middle';
      ctx.textAlign = 'left';
      ctx.fillText(matchTime, currentX, centerY);
      currentX += timerWidth + spacing;
      
      // 2. HalfTime (1°T / 2°T)
      ctx.font = 'bold 9px Arial';
      ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
      ctx.fillText(halfTime, currentX, centerY);
      currentX += halfTimeWidth + spacing + 8;
      
      // 3. Team 1 - Rettangolo colorato
      ctx.fillStyle = '#2196F3'; // Blu
      ctx.fillRect(currentX, boxY + 8, 3, boxHeight - 16);
      currentX += 3 + 6;
      
      // Team 1 - Nome (troncato a 10 caratteri)
      final team1Text = team1NameText.length > 10 ? team1NameText.substring(0, 10) : team1NameText;
      ctx.fillStyle = textColor;
      ctx.font = '600 11px Arial';
      ctx.textAlign = 'center';
      final team1X = currentX + 30;
      ctx.fillText(team1Text, team1X, centerY - 7);
      
      // Team 1 - Punteggio
      ctx.font = 'bold 11px Arial';
      ctx.fillText('${team1Score}', team1X, centerY + 7);
      currentX += 60 + spacing + 8;
      
      // 4. Team 2 - Rettangolo colorato
      ctx.fillStyle = '#F44336'; // Rosso
      ctx.fillRect(currentX, boxY + 8, 3, boxHeight - 16);
      currentX += 3 + 6;
      
      // Team 2 - Nome (troncato a 10 caratteri)
      final team2Text = team2NameText.length > 10 ? team2NameText.substring(0, 10) : team2NameText;
      ctx.fillStyle = textColor;
      ctx.font = '600 11px Arial';
      ctx.textAlign = 'center';
      final team2X = currentX + 30;
      ctx.fillText(team2Text, team2X, centerY - 7);
      
      // Team 2 - Punteggio
      ctx.font = 'bold 11px Arial';
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

  /// Cleanup
  void dispose() {
    if (_isRecording) {
      _mediaRecorder?.stop();
    }
    _drawTimer?.cancel();
    _cameraStream?.getTracks().forEach((track) {
      track.stop();
    });
    _canvasStream?.getTracks().forEach((track) {
      track.stop();
    });
    _recordedChunks.clear();
  }
}
