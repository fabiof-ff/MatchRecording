import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    // Abilita tutti gli orientamenti per la registrazione
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Inizializza il camera controller
    _cameraRecordingController = Get.put(CameraRecordingController());
    
    // Collega il camera controller al match controller
    final matchController = Get.find<MatchController>();
    matchController.setCameraController(_cameraRecordingController);
  }

  @override
  void dispose() {
    // Ferma il timer della partita
    final matchController = Get.find<MatchController>();
    matchController.stopMatch();
    
    // Ripristina solo orientamento portrait quando esci
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
                        WebCameraPreview(
                          cameraController: _cameraRecordingController,
                        )
                      else
                        CameraPreview(_cameraRecordingController.cameraController),

                  // Top recording indicator (solo in modalità verticale)
                  Obx(
                    () => !matchController.isOverlayLandscape.value
                        ? Positioned(
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
                          )
                        : const SizedBox(),
                  ),

                  // Live Overlay (cronometro e punteggio) - SOLO IN MODALITÀ ORIZZONTALE
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
                      
                      // Mostra messaggio se in modalità portrait
                      if (!isLandscape) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.screen_rotation,
                                  color: Colors.white,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Ruota il dispositivo in modalità orizzontale',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      if (isLandscape) {
                        // LAYOUT LANDSCAPE COMPLETO - SENZA ROTAZIONE
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Transform.rotate(
                            angle: 0, // Nessuna rotazione
                            origin: const Offset(0, 0),
                            child: Container(
                              width: 550, // Ingrandito ulteriormente
                              height: 400, // Ingrandito ulteriormente
                              child: Stack(
                                children: [
                                  // 1. Overlay compatto in alto a sinistra
                                  Positioned(
                                    top: 0,
                                    left: 0,
                              child: Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 4,
                                  children: [
                                    // Tempo + indicatore tempo
                                    Row(
                                      spacing: 4,
                                      children: [
                                        Text(
                                          matchController.formatMatchTime(matchController.matchTime.value),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        Text(
                                          ' ${matchController.halfTime.value}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Separatore
                                    Container(
                                      width: 1,
                                      height: 16,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    // Team 1 con controlli
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          matchController.team1Name.value.length > 10
                                            ? matchController.team1Name.value.substring(0, 10)
                                            : matchController.team1Name.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          spacing: 4,
                                          children: [
                                            InkWell(
                                              onTap: matchController.subtractGoalTeam1,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                child: const Icon(Icons.remove_circle, color: Colors.blue, size: 18),
                                              ),
                                            ),
                                            Text(
                                              '${matchController.team1Score.value}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: matchController.addGoalTeam1,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                child: const Icon(Icons.add_circle, color: Colors.blue, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Separatore
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    // Team 2 con controlli
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          matchController.team2Name.value.length > 10
                                            ? matchController.team2Name.value.substring(0, 10)
                                            : matchController.team2Name.value,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          spacing: 4,
                                          children: [
                                            InkWell(
                                              onTap: matchController.subtractGoalTeam2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                child: const Icon(Icons.remove_circle, color: Colors.red, size: 18),
                                              ),
                                            ),
                                            Text(
                                              '${matchController.team2Score.value}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: matchController.addGoalTeam2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                child: const Icon(Icons.add_circle, color: Colors.red, size: 18),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            ),
                            
                            // 2. Recording indicator in alto a destra (se attivo)
                            Positioned(
                              top: 12,
                              right: 70,
                              child: Obx(
                                () => matchController.isRecording.value
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 6,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Text(
                                              matchController.formatMatchTime(matchController.recordingTime.value),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                            
                            // 3. Pulsanti azione VERTICALI sul lato destro
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 2,
                                  children: [
                                    // Back button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          if (matchController.isRecording.value) {
                                            matchController.stopRecording();
                                          }
                                          Get.back();
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Highlight button
                                    Obx(
                                      () => Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: matchController.isRecording.value
                                              ? matchController.markHighlight
                                              : null,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: matchController.isRecording.value
                                                  ? Colors.amber
                                                  : Colors.grey.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.star,
                                              color: Colors.black,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Record/Stop button
                                    Obx(
                                      () => Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () async {
                                            if (matchController.isRecording.value) {
                                              matchController.stopRecording();
                                              await _cameraRecordingController.stopVideoRecording();
                                            } else {
                                              matchController.startRecording();
                                              await _cameraRecordingController.startVideoRecording();
                                            }
                                          },
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: matchController.isRecording.value
                                                  ? Colors.red
                                                  : Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              matchController.isRecording.value
                                                  ? Icons.stop
                                                  : Icons.circle,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Toggle half time button
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          matchController.toggleHalfTime();
                                        },
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.7),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Obx(() => Text(
                                              matchController.halfTime.value,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Play/Pause and Reset row
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 2,
                                      children: [
                                        // Pause/Play timer button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              matchController.toggleTimerPause();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Obx(() => Icon(
                                                !matchController.isTimerStarted.value || matchController.isTimerPaused.value
                                                    ? Icons.play_arrow
                                                    : Icons.pause,
                                                color: Colors.white,
                                                size: 22,
                                              )),
                                            ),
                                          ),
                                        ),
                                        
                                        // Reset timer button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              matchController.resetMatch();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.refresh,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // +10s and -10s row
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 2,
                                      children: [
                                        // Add 10 seconds button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              matchController.addTime(10);
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  Text(
                                                    '10s',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        // Subtract 10 seconds button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              matchController.subtractTime(10);
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  Text(
                                                    '10s',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    // Zoom in and zoom out row
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 2,
                                      children: [
                                        // Zoom in button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _cameraRecordingController.zoomIn();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.zoom_in,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        // Zoom out button
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              _cameraRecordingController.zoomOut();
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.zoom_out,
                                                color: Colors.white,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Video saved info (landscape)
                            Positioned(
                              bottom: 60,
                              left: 12,
                              right: 80,
                              child: Obx(
                                () => matchController.recordedVideoPath.value.isNotEmpty
                                    ? Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          border: Border.all(color: Colors.green, width: 1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Video Salvato',
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ],
                        ),
                            ),
                            ),
                          ),
                        );
                      } else {
                        // LAYOUT VERTICALE - Banner con messaggio
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange, width: 2),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.screen_rotation,
                                  color: Colors.orange,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Mettere il dispositivo in orizzontale\nper iniziare la registrazione',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
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