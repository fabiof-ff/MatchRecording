import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../controllers/match_controller.dart';
import '../controllers/camera_controller.dart';
import '../widgets/web_camera_preview.dart' if (dart.library.io) '../widgets/web_camera_preview_stub.dart';

class RecordingScreen extends StatefulWidget {
  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  late CameraRecordingController _cameraRecordingController;

  @override
  void initState() {
    super.initState();
    // Inizializza il camera controller
    _cameraRecordingController = Get.put(CameraRecordingController());
  }

  @override
  void dispose() {
    // Non dispose qui perché GetX lo farà automaticamente
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matchController = Get.find<MatchController>();

    return WillPopScope(
      onWillPop: () async {
        if (matchController.isRecording.value) {
          matchController.stopRecording();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Registrazione'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (matchController.isRecording.value) {
                matchController.stopRecording();
              }
              Get.back();
            },
          ),
        ),
        body: Obx(
          () {
            if (!_cameraRecordingController.isInitialized.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return FutureBuilder<void>(
              future: _cameraRecordingController.initializeCameraFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      // Camera preview - diverso per web e mobile
                      if (kIsWeb)
                        const WebCameraPreview()
                      else
                        CameraPreview(_cameraRecordingController.cameraController),

                  // Top recording indicator
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Obx(
                      () => matchController.isRecording.value
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                spacing: 8,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      matchController.formatMatchTime(matchController.matchTime.value),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),

                  // Live Overlay (cronometro e punteggio)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Match time
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              spacing: 4,
                              children: [
                                const Icon(Icons.schedule, color: Colors.white, size: 16),
                                Text(
                                  matchController.formatMatchTime(matchController.matchTime.value),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Score board
                        Obx(
                          () => Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  spacing: 12,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          matchController.team1Name.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '${matchController.team1Score.value}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      width: 1,
                                      height: 30,
                                      color: Colors.white,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          matchController.team2Name.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                        Text(
                                          '${matchController.team2Score.value}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom controls
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black.withOpacity(0.4),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        spacing: 12,
                        children: [
                          // Score controls
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Obx(
                              () => Row(
                                spacing: 12,
                                children: [
                                  // Team 1
                                  Expanded(
                                    child: Column(
                                      spacing: 4,
                                      children: [
                                        Text(
                                          matchController.team1Name.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          spacing: 8,
                                          children: [
                                            IconButton(
                                              onPressed: matchController.subtractGoalTeam1,
                                              icon: const Icon(Icons.remove_circle, color: Colors.blue),
                                              iconSize: 24,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Text(
                                              '${matchController.team1Score.value}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: matchController.addGoalTeam1,
                                              icon: const Icon(Icons.add_circle, color: Colors.blue),
                                              iconSize: 24,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Team 2
                                  Expanded(
                                    child: Column(
                                      spacing: 4,
                                      children: [
                                        Text(
                                          matchController.team2Name.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          spacing: 8,
                                          children: [
                                            IconButton(
                                              onPressed: matchController.subtractGoalTeam2,
                                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                                              iconSize: 24,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                            Text(
                                              '${matchController.team2Score.value}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: matchController.addGoalTeam2,
                                              icon: const Icon(Icons.add_circle, color: Colors.red),
                                              iconSize: 24,
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Action buttons
                          Row(
                            spacing: 12,
                            children: [
                              // Highlight button
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: matchController.isRecording.value
                                      ? matchController.markHighlight
                                      : null,
                                  icon: const Icon(Icons.star),
                                  label: const Text('Highlight'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                    disabledBackgroundColor: Colors.grey.shade300,
                                  ),
                                ),
                              ),

                              // Record/Stop button
                              Expanded(
                                child: Obx(
                                  () => ElevatedButton.icon(
                                    onPressed: () async {
                                      if (matchController.isRecording.value) {
                                        // Ferma sia il match timer che la video registrazione
                                        matchController.stopRecording();
                                        await _cameraRecordingController.stopVideoRecording();
                                      } else {
                                        // Avvia sia il match timer che la video registrazione
                                        matchController.startRecording();
                                        await _cameraRecordingController.startVideoRecording();
                                      }
                                    },
                                    icon: Icon(matchController.isRecording.value ? Icons.stop : Icons.circle),
                                    label: Text(matchController.isRecording.value ? 'Stop' : 'Registra'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: matchController.isRecording.value ? Colors.red : Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Video saved info
                          Obx(
                            () => matchController.recordedVideoPath.value.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.only(top: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      border: Border.all(color: Colors.green, width: 1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Video Salvato',
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        SelectableText(
                                          matchController.recordedVideoPath.value,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
            );
          },
        ),
      ),
    );
  }
}