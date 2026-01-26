/// Stub per piattaforme non-web
/// Questo file viene usato quando si compila per Android/iOS
class WebVideoRecorder {
  Future<void> startRecording() async {
    throw UnsupportedError('WebVideoRecorder è disponibile solo su web');
  }

  Future<String> stopRecording() async {
    throw UnsupportedError('WebVideoRecorder è disponibile solo su web');
  }

  bool get isRecording => false;

  void dispose() {}
}
