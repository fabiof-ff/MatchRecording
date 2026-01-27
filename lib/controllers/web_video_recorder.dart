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
  int team1Score = 0;
  int team2Score = 0;
  String matchTime = '00:00';
  
  /// Aggiorna i dati dell'overlay
  void updateOverlay({
    String? team1Name,
    String? team2Name,
    int? team1Score,
    int? team2Score,
    String? matchTime,
  }) {
    if (team1Name != null) this.team1Name = team1Name;
    if (team2Name != null) this.team2Name = team2Name;
    if (team1Score != null) this.team1Score = team1Score;
    if (team2Score != null) this.team2Score = team2Score;
    if (matchTime != null) this.matchTime = matchTime;
    
    // Debug: stampa i valori aggiornati
    print('🎯 Overlay values: $team1Name $team1Score - $team2Score $team2Name | $matchTime');
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
      Get.snackbar(
        'Registrazione Avviata',
        'Il video sarà salvato automaticamente al termine',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Errore avvio registrazione web: $e');
      Get.snackbar(
        'Errore',
        'Impossibile avviare la registrazione: $e',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      );
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
        
        Get.snackbar(
          'Video Salvato!',
          'File: $fileName\nDimensione: $sizeMB MB\n\nIl browser dovrebbe aver avviato il download automaticamente.',
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 5),
        );

        completer.complete(fileName);
      } catch (e) {
        print('❌ Errore nel salvataggio: $e');
        Get.snackbar(
          'Errore',
          'Errore durante il salvataggio: $e',
          backgroundColor: Colors.red,
        );
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
      print('🎨 Drawing overlay: $team1Name $team1Score - $team2Score $team2Name | $matchTime');
    }
    
    // Salva stato
    ctx.save();
    
    // Font e stile
    ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
    ctx.font = 'bold 32px Arial';
    ctx.textBaseline = 'top';
    
    // Box in alto a sinistra - Tempo partita
    final timeText = matchTime;
    final timeWidth = ctx.measureText(timeText).width! + 40;
    ctx.fillRect(20, 20, timeWidth, 60);
    ctx.fillStyle = 'white';
    ctx.fillText(timeText, 40, 35);
    
    // Box punteggio - Centro alto
    final scoreText = '$team1Name $team1Score - $team2Score $team2Name';
    final scoreWidth = ctx.measureText(scoreText).width! + 60;
    final scoreX = (width - scoreWidth) / 2;
    ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
    ctx.fillRect(scoreX, 20, scoreWidth, 60);
    ctx.fillStyle = 'white';
    ctx.fillText(scoreText, scoreX + 30, 35);
    
    // Ripristina stato
    ctx.restore();
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
