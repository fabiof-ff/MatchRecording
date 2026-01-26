import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller per la registrazione video su piattaforma web
class WebVideoRecorder {
  html.MediaStream? _mediaStream;
  html.MediaRecorder? _mediaRecorder;
  final List<html.Blob> _recordedChunks = [];
  bool _isRecording = false;
  
  /// Avvia la registrazione video web
  Future<void> startRecording() async {
    try {
      // Richiedi accesso alla camera e microfono
      _mediaStream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'width': {'ideal': 1920},
          'height': {'ideal': 1080},
        },
        'audio': true,
      });

      if (_mediaStream == null) {
        throw Exception('Impossibile accedere alla camera');
      }

      // Crea MediaRecorder
      _mediaRecorder = html.MediaRecorder(_mediaStream!, {
        'mimeType': 'video/webm;codecs=vp9',
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
        // Crea un blob dal video registrato
        final blob = html.Blob(_recordedChunks, 'video/webm');
        
        // Crea nome file con timestamp
        final timestamp = DateTime.now();
        final fileName = 'match_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.webm';

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

    // Ferma tutti i track dello stream
    _mediaStream?.getTracks().forEach((track) {
      track.stop();
    });

    return completer.future;
  }

  /// Verifica se è in registrazione
  bool get isRecording => _isRecording;

  /// Cleanup
  void dispose() {
    if (_isRecording) {
      _mediaRecorder?.stop();
    }
    _mediaStream?.getTracks().forEach((track) {
      track.stop();
    });
    _recordedChunks.clear();
  }
}
