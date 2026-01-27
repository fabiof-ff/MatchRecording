import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/highlight.dart';
import 'camera_controller.dart';

class MatchController extends GetxController {
  // Match data
  final isRecording = false.obs;
  final matchTime = Duration.zero.obs;
  final team1Score = 0.obs;
  final team2Score = 0.obs;
  final team1Name = 'Squadra 1'.obs;
  final team2Name = 'Squadra 2'.obs;
  final team1Color = Colors.blue.obs;
  final team2Color = Colors.red.obs;
  final halfTime = '1° T'.obs; // Primo o secondo tempo
  final highlights = RxList<Highlight>([]);
  final recordedVideoPath = ''.obs;
  final isOverlayLandscape = true.obs; // Overlay sempre in orizzontale di default

  Timer? _timer;
  CameraRecordingController? _cameraController;

  void setCameraController(CameraRecordingController controller) {
    _cameraController = controller;
    print('✅ CameraRecordingController collegato al MatchController');
  }
  
  void toggleOverlayOrientation() {
    isOverlayLandscape.value = !isOverlayLandscape.value;
    // Aggiorna immediatamente l'overlay
    if (isRecording.value) {
      _updateOverlay();
    }
  }
  
  void toggleHalfTime() {
    halfTime.value = halfTime.value == '1° T' ? '2° T' : '1° T';
    // Aggiorna immediatamente l'overlay
    if (isRecording.value) {
      _updateOverlay();
    }
  }
  
  void _updateOverlay() {
    if (_cameraController == null) {
      print('⚠️ _cameraController non disponibile');
      return;
    }
    try {
      print('🔄 _updateOverlay chiamato: ${team1Name.value} ${team1Score.value} - ${team2Score.value} ${team2Name.value} | ${formatMatchTime(matchTime.value)} | Landscape: ${isOverlayLandscape.value}');
      _cameraController!.updateOverlay(
        team1Name: team1Name.value,
        team2Name: team2Name.value,
        team1Color: '#${team1Color.value.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        team2Color: '#${team2Color.value.value.toRadixString(16).padLeft(8, '0').substring(2)}',
        team1Score: team1Score.value,
        team2Score: team2Score.value,
        matchTime: formatMatchTime(matchTime.value),
        halfTime: halfTime.value,
        isLandscape: isOverlayLandscape.value,
      );
    } catch (e) {
      print('❌ Errore in _updateOverlay: $e');
    }
  }

  void startRecording() {
    isRecording.value = true;
    matchTime.value = Duration.zero;
    
    // Inizializza l'overlay con i valori correnti
    _updateOverlay();
    
    _startTimer();
    
    // Avvia registrazione video della camera
    _startVideoRecording();
    
    print('📹 Registrazione iniziata');
  }

  void stopRecording() async {
    isRecording.value = false;
    _timer?.cancel();
    
    // Ferma registrazione video della camera
    await _stopVideoRecording();
    
    print('⏹️ Registrazione fermata');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      matchTime.value = Duration(milliseconds: matchTime.value.inMilliseconds + 100);
      // Aggiorna l'overlay ad ogni tick per garantire sincronizzazione
      _updateOverlay();
    });
  }

  Future<void> _startVideoRecording() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.startVideoRecording();
    } catch (e) {
      print('⚠️ Errore avvio registrazione video: $e');
    }
  }

  Future<void> _stopVideoRecording() async {
    if (_cameraController == null) return;
    try {
      final videoPath = await _cameraController!.stopVideoRecording();
      if (videoPath != null) {
        recordedVideoPath.value = videoPath;
        print('✅ Video salvato: $videoPath');
      }
    } catch (e) {
      print('⚠️ Errore arresto registrazione video: $e');
    }
  }

  void addGoalTeam1() {
    if (!isRecording.value) {
      Get.snackbar('Errore', 'Registrazione non attiva', backgroundColor: Colors.red);
      return;
    }
    team1Score.value++;
    _updateOverlay();
    print('⚽ Gol ${team1Name.value}! Score: ${team1Score.value} - ${team2Score.value}');
    Get.snackbar('Gol!', '${team1Name.value} segna!', backgroundColor: Colors.green);
  }

  void addGoalTeam2() {
    if (!isRecording.value) {
      Get.snackbar('Errore', 'Registrazione non attiva', backgroundColor: Colors.red);
      return;
    }
    team2Score.value++;
    _updateOverlay();
    print('⚽ Gol ${team2Name.value}! Score: ${team1Score.value} - ${team2Score.value}');
    Get.snackbar('Gol!', '${team2Name.value} segna!', backgroundColor: Colors.green);
  }

  void subtractGoalTeam1() {
    if (team1Score.value > 0) {
      team1Score.value--;
      _updateOverlay();
    }
  }

  void subtractGoalTeam2() {
    if (team2Score.value > 0) {
      team2Score.value--;
      _updateOverlay();
    }
  }

  void markHighlight() {
    if (!isRecording.value) {
      Get.snackbar('Errore', 'Registrazione non attiva', backgroundColor: Colors.red);
      return;
    }
    final highlight = Highlight(
      id: UniqueKey().toString(),
      timestamp: matchTime.value,
      date: DateTime.now(),
    );
    highlights.add(highlight);
    print('⭐ Highlight marcato al ${highlight.formattedTime}');
    Get.snackbar('Highlight!', 'Momento saliente registrato', backgroundColor: Colors.amber);
  }

  String formatMatchTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Duration getTotalHighlightsDuration() {
    return highlights.fold(Duration.zero, (total, h) => total + h.duration);
  }

  String getMatchSummary() {
    final duration = formatMatchTime(matchTime.value);
    final totalHighlightsDuration = formatMatchTime(getTotalHighlightsDuration());
    final result = team1Score.value > team2Score.value
        ? '${team1Name.value} vince'
        : team2Score.value > team1Score.value
            ? '${team2Name.value} vince'
            : 'Pareggio';

    return '''
📊 RIASSUNTO PARTITA
━━━━━━━━━━━━━━━━━━━━
${team1Name.value} ${team1Score.value} - ${team2Score.value} ${team2Name.value}
Risultato: $result

⏱️ Durata: $duration
⭐ Highlights: ${highlights.length}
📹 Durata highlights: $totalHighlightsDuration
    ''';
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
