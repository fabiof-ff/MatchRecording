import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/highlight.dart';
import 'camera_controller.dart';

class MatchController extends GetxController {
  // Match data
  final isRecording = false.obs;
  final isTimerPaused = false.obs;
  final isTimerStarted = false.obs; // Indica se il timer è stato avviato almeno una volta
  final matchTime = Duration.zero.obs;
  final recordingTime = Duration.zero.obs; // Timer separato per la registrazione
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
  final initialTimer = Duration.zero.obs; // Timer iniziale impostato dall'utente

  Timer? _timer;
  Timer? _recordingTimer; // Timer separato per la registrazione
  CameraRecordingController? _cameraController;

  void setCameraController(CameraRecordingController controller) {
    _cameraController = controller;
    print('✅ CameraRecordingController collegato al MatchController');
  }
  
  void toggleHalfTime() {
    halfTime.value = halfTime.value == '1° T' ? '2° T' : '1° T';
    // Aggiorna immediatamente l'overlay
    _updateOverlay();
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

  void startMatch() {
    matchTime.value = initialTimer.value; // Inizia dal timer impostato
    
    // Inizializza l'overlay con i valori correnti
    _updateOverlay();
    
    _startTimer();
    
    print('⏱️ Timer partita avviato');
  }

  void startRecording() {
    isRecording.value = true;
    recordingTime.value = Duration.zero; // Reset timer registrazione
    
    // Avvia timer di registrazione
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      recordingTime.value = Duration(seconds: recordingTime.value.inSeconds + 1);
    });
    
    // Avvia registrazione video della camera
    _startVideoRecording();
    
    print('📹 Registrazione iniziata');
  }

  void stopRecording() async {
    isRecording.value = false;
    _recordingTimer?.cancel(); // Ferma timer registrazione
    
    // Ferma registrazione video della camera
    await _stopVideoRecording();
    
    print('⏹️ Registrazione fermata');
  }

  void stopMatch() {
    _timer?.cancel();
    isTimerStarted.value = false;
    print('⏹️ Timer partita fermato');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isTimerPaused.value) {
        matchTime.value = Duration(seconds: matchTime.value.inSeconds + 1);
        // Aggiorna l'overlay ogni secondo
        _updateOverlay();
      }
    });
  }

  void toggleTimerPause() {
    if (!isTimerStarted.value) {
      // Prima volta che si preme play - avvia il timer
      startMatch();
      isTimerStarted.value = true;
      isTimerPaused.value = false;
      print('▶️ Timer avviato');
    } else {
      // Timer già avviato - pausa/riprendi
      isTimerPaused.value = !isTimerPaused.value;
      print('⏯️ Timer ${isTimerPaused.value ? "in pausa" : "ripreso"}');
    }
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
    team1Score.value++;
    _updateOverlay();
    print('⚽ Gol ${team1Name.value}! Score: ${team1Score.value} - ${team2Score.value}');
  }

  void addGoalTeam2() {
    team2Score.value++;
    _updateOverlay();
    print('⚽ Gol ${team2Name.value}! Score: ${team1Score.value} - ${team2Score.value}');
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
      return;
    }
    final highlight = Highlight(
      id: UniqueKey().toString(),
      timestamp: matchTime.value,
      date: DateTime.now(),
    );
    highlights.add(highlight);
    print('⭐ Highlight marcato al ${highlight.formattedTime}');
  }

  void addTime(int seconds) {
    matchTime.value = Duration(seconds: matchTime.value.inSeconds + seconds);
    _updateOverlay();
    print('⏱️ Aggiunti $seconds secondi. Tempo totale: ${formatMatchTime(matchTime.value)}');
  }

  void subtractTime(int seconds) {
    final newSeconds = matchTime.value.inSeconds - seconds;
    if (newSeconds >= 0) {
      matchTime.value = Duration(seconds: newSeconds);
      _updateOverlay();
      print('⏱️ Sottratti $seconds secondi. Tempo totale: ${formatMatchTime(matchTime.value)}');
    }
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

  /// Esporta gli highlights in un file TXT
  void exportHighlightsToTxt() {
    if (highlights.isEmpty) {
      Get.snackbar(
        'Nessun Highlight',
        'Non ci sono highlights da esportare',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Crea il contenuto del file
    final buffer = StringBuffer();
    buffer.writeln('HIGHLIGHTS - ${team1Name.value} vs ${team2Name.value}');
    buffer.writeln('Data: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln('Score: ${team1Score.value} - ${team2Score.value}');
    buffer.writeln('Durata partita: ${formatMatchTime(matchTime.value)}');
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('');
    buffer.writeln('TIMESTAMP HIGHLIGHTS:');
    buffer.writeln('');
    
    for (int i = 0; i < highlights.length; i++) {
      final highlight = highlights[i];
      buffer.writeln('${i + 1}. Tempo: ${highlight.formattedTime}');
    }
    
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('Totale highlights: ${highlights.length}');

    // Crea il blob e scarica il file
    final content = buffer.toString();
    final bytes = html.Blob([content]);
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'highlights_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.txt')
      ..click();
    html.Url.revokeObjectUrl(url);

    Get.snackbar(
      'Esportazione Completata',
      'File highlights.txt scaricato con successo',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    
    print('📄 Highlights esportati in TXT: ${highlights.length} elementi');
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
