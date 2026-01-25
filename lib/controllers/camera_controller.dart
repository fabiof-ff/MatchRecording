import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Controller per gestire la camera e la registrazione video
class CameraRecordingController extends GetxController {
  late CameraController cameraController;
  late Future<void> initializeCameraFuture;
  
  final isRecordingVideo = false.obs;
  final videoPath = ''.obs;
  final isInitialized = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  /// Inizializza la camera disponibile
  Future<void> initializeCamera() async {
    try {
      // Ottieni lista di camera disponibili
      final cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        Get.snackbar(
          'Errore',
          'Nessuna camera disponibile',
          backgroundColor: Colors.red,
        );
        return;
      }

      // Usa la prima camera (generalmente quella posteriore)
      final firstCamera = cameras.first;

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
      Get.snackbar(
        'Errore Camera',
        'Non è stato possibile inizializzare la camera: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Avvia la registrazione video
  Future<void> startVideoRecording() async {
    try {
      if (!cameraController.value.isInitialized) {
        Get.snackbar(
          'Errore',
          'Camera non inizializzata',
          backgroundColor: Colors.red,
        );
        return;
      }

      if (isRecordingVideo.value) {
        Get.snackbar(
          'Attenzione',
          'Registrazione già in corso',
          backgroundColor: Colors.orange,
        );
        return;
      }

      // Crea cartella per salvare i video
      final appDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${appDir.path}/match_recordings');
      
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      // Crea nome file basato su timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final videoPath = '${videoDir.path}/match_$timestamp.mp4';

      // Avvia registrazione
      await cameraController.startVideoRecording();
      this.videoPath.value = videoPath;
      isRecordingVideo.value = true;

      print('🎥 Registrazione video avviata: $videoPath');
      Get.snackbar(
        'Registrazione',
        'Video registrazione avviata',
        backgroundColor: Colors.green,
      );
    } catch (e) {
      print('❌ Errore nell\'avvio della registrazione: $e');
      Get.snackbar(
        'Errore',
        'Errore nell\'avvio della registrazione: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  /// Ferma la registrazione video
  Future<String?> stopVideoRecording() async {
    try {
      if (!isRecordingVideo.value) {
        Get.snackbar(
          'Attenzione',
          'Nessuna registrazione in corso',
          backgroundColor: Colors.orange,
        );
        return null;
      }

      final video = await cameraController.stopVideoRecording();
      isRecordingVideo.value = false;

      // Salva il video nel percorso specificato
      await video.saveTo(videoPath.value);

      print('✅ Video salvato: ${videoPath.value}');
      Get.snackbar(
        'Successo',
        'Video registrazione completata',
        backgroundColor: Colors.green,
      );

      return videoPath.value;
    } catch (e) {
      print('❌ Errore nel stop della registrazione: $e');
      Get.snackbar(
        'Errore',
        'Errore nel salvataggio del video: $e',
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  /// Pausa la registrazione video (se supportata dalla camera)
  Future<void> pauseVideoRecording() async {
    try {
      if (!isRecordingVideo.value) return;
      
      await cameraController.pauseVideoRecording();
      print('⏸️ Registrazione video in pausa');
    } catch (e) {
      print('⚠️ Errore nella pausa: $e');
    }
  }

  /// Riprendi la registrazione video (se in pausa)
  Future<void> resumeVideoRecording() async {
    try {
      if (!isRecordingVideo.value) return;
      
      await cameraController.resumeVideoRecording();
      print('▶️ Registrazione video ripresa');
    } catch (e) {
      print('⚠️ Errore nella ripresa: $e');
    }
  }

  /// Scatta una foto (per thumbnail o preview)
  Future<XFile?> takePicture() async {
    try {
      if (!cameraController.value.isInitialized) return null;

      return await cameraController.takePicture();
    } catch (e) {
      print('❌ Errore nello scatto: $e');
      return null;
    }
  }

  /// Cambia la torcia (flash) on/off
  Future<void> toggleFlash() async {
    try {
      if (cameraController.value.flashMode == FlashMode.off) {
        await cameraController.setFlashMode(FlashMode.torch);
        print('🔦 Torcia accesa');
      } else {
        await cameraController.setFlashMode(FlashMode.off);
        print('🔦 Torcia spenta');
      }
    } catch (e) {
      print('⚠️ Errore nel cambio della torcia: $e');
    }
  }

  /// Cambia zoom
  Future<void> setZoom(double zoom) async {
    try {
      await cameraController.setZoomLevel(zoom);
    } catch (e) {
      print('⚠️ Errore nello zoom: $e');
    }
  }

  @override
  void onClose() {
    // Ferma la registrazione se ancora attiva
    if (isRecordingVideo.value) {
      stopVideoRecording();
    }
    
    // Dispose della camera
    cameraController.dispose();
    super.onClose();
  }
}
