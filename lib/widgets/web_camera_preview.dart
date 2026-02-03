import 'package:flutter/material.dart';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Widget per mostrare il video preview della camera web
class WebCameraPreview extends StatefulWidget {
  final Function(Function() switchCamera)? onCameraReady;
  final dynamic cameraController; // CameraRecordingController per aggiornare lo stream
  
  const WebCameraPreview({
    Key? key, 
    this.onCameraReady,
    this.cameraController,
  }) : super(key: key);

  @override
  State<WebCameraPreview> createState() => _WebCameraPreviewState();
}

class _WebCameraPreviewState extends State<WebCameraPreview> {
  final String _viewType = 'web-camera-preview-${DateTime.now().millisecondsSinceEpoch}';
  html.VideoElement? _videoElement;
  bool _initialized = false;
  bool _useFrontCamera = false; // false = posteriore, true = frontale

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
        ..volume = 0.0  // Forza volume a zero
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      // Richiedi accesso alla camera con constraints multipli per compatibilità
      // Su iOS/Chrome usa solo 'ideal' perché 'exact' fallisce spesso
      final constraints = [
        // Constraint 1: Camera posteriore con facingMode ideal
        {
          'video': {
            'facingMode': {'ideal': 'environment'},
            'width': {'ideal': 1920},
            'height': {'ideal': 1080},
          },
          'audio': true,
        },
        // Constraint 2: Camera posteriore semplice
        {
          'video': {
            'facingMode': 'environment',
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
          
          // Notifica il callback che la camera è pronta con la funzione di switch
          print('✅ Camera pronta, callback registrato');
          widget.onCameraReady?.call(_switchCamera);
        }
      }
    } catch (e) {
      print('❌ Errore inizializzazione camera web: $e');
    }
  }
  
  /// Cambia tra camera frontale e posteriore
  Future<void> _switchCamera() async {
    print('🔄 Switch camera chiamato! Stato attuale: ${_useFrontCamera ? "frontale" : "posteriore"}');
    try {
      // Ferma lo stream corrente
      final currentStream = _videoElement?.srcObject as html.MediaStream?;
      currentStream?.getTracks().forEach((track) {
        track.stop();
      });
      
      // Inverte la camera
      _useFrontCamera = !_useFrontCamera;
      
      // Richiedi nuovo stream con la camera desiderata
      final facingMode = _useFrontCamera ? 'user' : 'environment';
      final stream = await html.window.navigator.mediaDevices?.getUserMedia({
        'video': {
          'facingMode': {'ideal': facingMode},
          'width': {'ideal': 1920},
          'height': {'ideal': 1080},
        },
        'audio': true,
      });
      
      if (stream != null) {
        _videoElement!.srcObject = stream;
        print('✅ Camera cambiata a: ${_useFrontCamera ? "frontale" : "posteriore"}');
        
        // Aggiorna anche lo stream nel recorder se è in registrazione
        if (widget.cameraController != null) {
          widget.cameraController.updateCameraStream(stream);
          print('📹 Stream aggiornato nel recorder');
        }
      }
    } catch (e) {
      print('❌ Errore cambio camera: $e');
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

    // Avvolgi l'HtmlElementView con IgnorePointer per permettere ai pulsanti
    // sopra di ricevere i click
    return IgnorePointer(
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
