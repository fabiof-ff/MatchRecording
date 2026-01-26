import 'package:flutter/material.dart';

/// Stub per piattaforme non-web
class WebCameraPreview extends StatelessWidget {
  const WebCameraPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'WebCameraPreview disponibile solo su web',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
