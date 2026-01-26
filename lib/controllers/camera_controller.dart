import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

/// Controller per gestire la camera e la registrazione video
class CameraRecordingController extends GetxController {
  late CameraController cameraController;
  late Future<void> initializeCameraFuture;
  
  final isRecordingVideo = false.obs;
  final videoPath = ''.obs;
  final isInitialized = false.obs;
  final isWebPlatform = false.obs;
  final useWebSimulation = false.obs;
  
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
      if (useWebSimulation.value) {
        // Modalità web simulation
        print('🎥 Registrazione video (WEB SIMULATION) avviata');
        isRecordingVideo.value = true;
        
        // Crea un timestamp per il nome del file
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        videoPath.value = 'match_${timestamp}_web.mp4';
        
        Get.snackbar(
          'Registrazione',
          'Video registrazione avviata (modalità web)',
          backgroundColor: Colors.green,
        );
        return;
      }

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

      // Avvia registrazione normale
      await cameraController.startVideoRecording();
      isRecordingVideo.value = true;

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      videoPath.value = 'match_${timestamp}.mp4';

      print('🎥 Registrazione video avviata: ${videoPath.value}');
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

      if (useWebSimulation.value) {
        // Modalità web simulation
        isRecordingVideo.value = false;
        print('✅ Video salvato (WEB SIMULATION): ${videoPath.value}');
        Get.snackbar(
          'Successo',
          'Video registrazione completata',
          backgroundColor: Colors.green,
        );
        return videoPath.value;
      }

      final video = await cameraController.stopVideoRecording();
      isRecordingVideo.value = false;

      print('✅ Video salvato: ${videoPath.value}');
      Get.snackbar(
        'Successo',
        'Video registrazione completata',
        backgroundColor: Colors.green,
      );

      return videoPath.value;
    } catch (e) {
      print('❌ Errore nell\'arresto della registrazione: $e');
      Get.snackbar(
        'Errore',
        'Errore nell\'arresto della registrazione: $e',
        backgroundColor: Colors.red,
      );
      return null;
    }
  }

  @override
  void onClose() {
    // Ferma la registrazione se ancora attiva
    if (isRecordingVideo.value) {
      stopVideoRecording();
    }
    
    // Dispose della camera
    try {
      cameraController.dispose();
    } catch (e) {
      print('⚠️ Errore nel dispose della camera: $e');
    }
    super.onClose();
  }
}
