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
        ..muted = true  // Muto per non riprodurre l'audio del microfono
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Richiedi accesso alla camera con constraints multipli per compatibilità
      // Prova prima camera posteriore (environment), poi fallback
      final constraints = [
        // Constraint 1: Camera posteriore con facingMode exact (iOS)
        {
          'video': {
            'facingMode': {'exact': 'environment'},
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 2: Camera posteriore con facingMode ideal (Android)
        {
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 3: Camera frontale con resolution ideale (fallback)
        {
          'video': {
            'facingMode': 'user',
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 3: Qualsiasi camera con resolution (fallback)
        {
          'video': {
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 4: Solo video generico (ultimo fallback)
        {
          'video': true,
          'audio': true,
        },
      ];

      html.MediaStream? stream;
      for (var i = 0; i < constraints.length; i++) {
        try {
          stream = await html.window.navigator.mediaDevices?.getUserMedia(constraints[i]);
          if (stream != null) {
            print('✅ Camera preview acquisita con constraint ${i + 1}');
            break;
          }
        } catch (e) {
          print('❌ Preview constraint ${i + 1} fallito: $e');
          if (i == constraints.length - 1) rethrow;
        }
      }

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
