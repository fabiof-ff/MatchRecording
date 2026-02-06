import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:io';

// Import condizionale per web
import 'web_video_recorder.dart' if (dart.library.io) 'web_video_recorder_stub.dart';

/// Controller per gestire la camera e la registrazione video
class CameraRecordingController extends GetxController {
  late CameraController cameraController;
  late Future<void> initializeCameraFuture;
  
  final isRecordingVideo = false.obs;
  final videoPath = ''.obs;
  final isInitialized = false.obs;
  final isWebPlatform = false.obs;
  final useWebSimulation = false.obs;
  final videosSaveDirectory = ''.obs;
  final zoomLevel = 1.0.obs;
  
  // Web video recorder
  WebVideoRecorder? _webRecorder;
  html.VideoElement? _videoElement;
  
  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    _initVideoDirectory();
  }
  
  /// Inizializza e salva il percorso della directory video
  Future<void> _initVideoDirectory() async {
    if (kIsWeb) {
      videosSaveDirectory.value = 'Web: download automatico nella cartella Download del browser';
      _webRecorder = WebVideoRecorder();
      print('✅ WebVideoRecorder inizializzato');
      return;
    }
    
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      videosSaveDirectory.value = '${appDir.path}/MatchRecordings';
      print('📁 Directory video: ${videosSaveDirectory.value}');
    } catch (e) {
      print('⚠️ Errore nel recupero directory: $e');
      videosSaveDirectory.value = 'Non disponibile';
    }
  }
  
  /// Ottiene il percorso della directory dove vengono salvati i video
  String getVideoSaveDirectory() {
    return videosSaveDirectory.value;
  }

  /// Imposta il livello di zoom (solo per web)
  void setZoom(double zoom) {
    if (kIsWeb) {
      zoomLevel.value = zoom.clamp(1.0, 3.0);
      
      // Applica lo zoom al video element
      final videoElements = html.document.querySelectorAll('video');
      if (videoElements.isNotEmpty) {
        final video = videoElements.first as html.VideoElement;
        video.style.transform = 'scale(${zoomLevel.value})';
        print('🔍 Zoom impostato a: ${zoomLevel.value.toStringAsFixed(1)}x');
      }
    }
  }

  /// Aumenta lo zoom di 0.25x
  void zoomIn() {
    setZoom(zoomLevel.value + 0.25);
  }

  /// Diminuisce lo zoom di 0.25x
  void zoomOut() {
    setZoom(zoomLevel.value - 0.25);
  }
  
  /// Aggiorna lo stream della camera (per switch camera)
  void updateCameraStream(dynamic newStream) {
    if (kIsWeb && _webRecorder != null) {
      _webRecorder!.updateCameraStream(newStream);
    }
  }
  
  /// Aggiorna i dati dell'overlay per la registrazione web
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
    if (kIsWeb) {
      if (_webRecorder == null) {
        print('⚠️ _webRecorder non ancora inizializzato, updateOverlay ritentato dopo 100ms');
        Future.delayed(const Duration(milliseconds: 100), () {
          updateOverlay(
            team1Name: team1Name,
            team2Name: team2Name,
            team1Color: team1Color,
            team2Color: team2Color,
            team1Score: team1Score,
            team2Score: team2Score,
            matchTime: matchTime,
            halfTime: halfTime,
            isLandscape: isLandscape,
          );
        });
        return;
      }
      _webRecorder!.updateOverlay(
        team1Name: team1Name,
        team2Name: team2Name,
        team1Color: team1Color,
        team2Color: team2Color,
        team1Score: team1Score,
        team2Score: team2Score,
        matchTime: matchTime,
        halfTime: halfTime,
        isLandscape: isLandscape,
      );
    }
  }

  /// Inizializza la camera disponibile
  Future<void> initializeCamera() async {
    try {
      // Ottieni lista di camera disponibili
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        print('⚠️ Nessuna camera trovata, userò la simulazione web');
        isWebPlatform.value = true;
        useWebSimulation.value = true;
        isInitialized.value = true;
        initializeCameraFuture = Future.value();
        return;
      }

      // Usa la prima camera (generalmente quella posteriore)
      final firstCamera = cameras.first;
      print('📷 Camera trovata: ${firstCamera.name}');

      // Crea il controller della camera
      cameraController = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: true, // Abilita audio per la registrazione video
      );

      // Inizializza il controller
      initializeCameraFuture = cameraController.initialize();
      await initializeCameraFuture;
      
      isInitialized.value = true;
      print('✅ Camera inizializzata con successo');
    } catch (e) {
      print('❌ Errore nell\'inizializzazione della camera: $e');
      print('⚠️ Passerò alla modalità web simulation');
      isWebPlatform.value = true;
      useWebSimulation.value = true;
      isInitialized.value = true;
      initializeCameraFuture = Future.value();
    }
  }

  /// Avvia la registrazione video
  Future<void> startVideoRecording() async {
    try {
      if (kIsWeb) {
        // Modalità web con registrazione reale
        if (_webRecorder != null) {
          await _webRecorder!.startRecording();
          isRecordingVideo.value = true;
          
          final timestamp = DateTime.now();
          final fileName = 'match_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}.webm';
          videoPath.value = 'Web: $fileName';
          
          print('🎥 Registrazione video web avviata: $fileName');
        } else {
          throw Exception('Web recorder non inizializzato');
        }
        return;
      }

      if (!cameraController.value.isInitialized) {
        return;
      }

      if (isRecordingVideo.value) {
        return;
      }

      // Ottieni la directory per salvare il video
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String videosDir = '${appDir.path}/MatchRecordings';
      
      // Crea la directory se non esiste
      final Directory dir = Directory(videosDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        print('📁 Creata directory: $videosDir');
      }
      
      // Crea il nome del file con timestamp
      final timestamp = DateTime.now();
      final fileName = 'match_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}.mp4';
      final filePath = '$videosDir/$fileName';
      
      // Avvia registrazione
      await cameraController.startVideoRecording();
      isRecordingVideo.value = true;
      videoPath.value = filePath;

      print('🎥 Registrazione video avviata');
      print('📁 Salverà in: $filePath');
    } catch (e) {
      print('❌ Errore nell\'avvio della registrazione: $e');
    }
  }

  /// Ferma la registrazione video
  Future<String?> stopVideoRecording() async {
    try {
      if (!isRecordingVideo.value) {
        print('⚠️ Registrazione video già fermata, ignoro chiamata duplicata');
        return null;
      }

      // Segna subito come non in registrazione per evitare chiamate duplicate
      isRecordingVideo.value = false;

      if (kIsWeb) {
        // Modalità web con salvataggio reale
        if (_webRecorder != null && _webRecorder!.isRecording) {
          final fileName = await _webRecorder!.stopRecording();
          videoPath.value = 'Web: $fileName (salvato in Download)';
          print('✅ Video web salvato: $fileName');
          return videoPath.value;
        } else {
          return null;
        }
      }

      // Ferma la registrazione e ottieni il file temporaneo
      final XFile video = await cameraController.stopVideoRecording();
      isRecordingVideo.value = false;
      
      // Sposta il file dalla posizione temporanea alla destinazione finale
      final File videoFile = File(video.path);
      final File savedFile = await videoFile.copy(videoPath.value);
      
      // Elimina il file temporaneo
      try {
        await videoFile.delete();
      } catch (e) {
        print('⚠️ Non è stato possibile eliminare il file temporaneo: $e');
      }

      final fileSize = await savedFile.length();
      final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
      
      print('✅ Video salvato con successo!');
      print('📁 Percorso: ${videoPath.value}');
      print('📊 Dimensione: $fileSizeMB MB');

      return videoPath.value;
    } catch (e) {
      print('❌ Errore nell\'arresto della registrazione: $e');
      return null;
    }
  }

  @override
  void onClose() {
    // Ferma la registrazione se ancora attiva
    if (isRecordingVideo.value) {
      stopVideoRecording();
    }
    
    // Dispose del web recorder
    _webRecorder?.dispose();
    
    // Dispose della camera
    if (!kIsWeb) {
      try {
        cameraController.dispose();
      } catch (e) {
        print('⚠️ Errore nel dispose della camera: $e');
      }
    }
    super.onClose();
  }
}
