import 'package:flutter/material.dart';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Widget per mostrare il video preview della camera web
class WebCameraPreview extends StatefulWidget {
  const WebCameraPreview({Key? key}) : super(key: key);

  @override
  State<WebCameraPreview> createState() => _WebCameraPreviewState();
}

class _WebCameraPreviewState extends State<WebCameraPreview> {
  final String _viewType = 'web-camera-preview-${DateTime.now().millisecondsSinceEpoch}';
  html.VideoElement? _videoElement;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      // Crea elemento video
      _videoElement = html.VideoElement()
        ..autoplay = true
        ..muted = false
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Richiedi accesso alla camera
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'width': {'ideal': 1920},
          'height': {'ideal': 1080},
        },
        'audio': true,
      });

      if (stream != null) {
        _videoElement!.srcObject = stream;
        
        // Registra il view type usando dart:ui_web
        ui_web.platformViewRegistry.registerViewFactory(
          _viewType,
          (int viewId) => _videoElement!,
        );

        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      }
    } catch (e) {
      print('❌ Errore inizializzazione camera web: $e');
    }
  }

  @override
  void dispose() {
    // Ferma lo stream
    final stream = _videoElement?.srcObject as html.MediaStream?;
    stream?.getTracks().forEach((track) {
      track.stop();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return HtmlElementView(viewType: _viewType);
  }
}
