class MatchController extends GetxController {
  // Match data
  final isRecording = false.obs;
  final matchTime = Duration.zero.obs;
  final team1Score = 0.obs;
  final team2Score = 0.obs;
  final team1Name = 'Squadra 1'.obs;
  final team2Name = 'Squadra 2'.obs;
  final highlights = RxList<Highlight>([]);

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
  }

  void startRecording() {
    isRecording.value = true;
    matchTime.value = Duration.zero;
    _startTimer();
    print('📹 Registrazione iniziata');
  }

  void stopRecording() {
    isRecording.value = false;
    _timer?.cancel();
    print('⏹️ Registrazione fermata');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      matchTime.value = Duration(milliseconds: matchTime.value.inMilliseconds + 100);
    });
  }

  void addGoalTeam1() {
    if (!isRecording.value) {
      Get.snackbar('Errore', 'Registrazione non attiva', backgroundColor: Colors.red);
      return;
    }
    team1Score.value++;
    print('⚽ Gol ${team1Name.value}! Score: ${team1Score.value} - ${team2Score.value}');
    Get.snackbar('Gol!', '${team1Name.value} segna!', backgroundColor: Colors.green);
  }

  void addGoalTeam2() {
    if (!isRecording.value) {
      Get.snackbar('Errore', 'Registrazione non attiva', backgroundColor: Colors.red);
      return;
    }
    team2Score.value++;
    print('⚽ Gol ${team2Name.value}! Score: ${team1Score.value} - ${team2Score.value}');
    Get.snackbar('Gol!', '${team2Name.value} segna!', backgroundColor: Colors.green);
  }

  void subtractGoalTeam1() {
    if (team1Score.value > 0) team1Score.value--;
  }

  void subtractGoalTeam2() {
    if (team2Score.value > 0) team2Score.value--;
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
