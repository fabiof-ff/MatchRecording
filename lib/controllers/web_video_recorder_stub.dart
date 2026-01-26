/// Stub per piattaforme non-web
/// Questo file viene usato quando si compila per Android/iOS
class WebVideoRecorder {
  void updateOverlay({
    String? team1Name,
    String? team2Name,
    int? team1Score,
    int? team2Score,
    String? matchTime,
  }) {}
  
  Future<void> startRecording() async {
    throw UnsupportedError('WebVideoRecorder è disponibile solo su web');
  }

  Future<String> stopRecording() async {
    throw UnsupportedError('WebVideoRecorder è disponibile solo su web');
  }

  bool get isRecording => false;

  void dispose() {}
}
