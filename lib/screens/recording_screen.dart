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
  Function()? _switchCameraCallback;

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
                        WebCameraPreview(
                          onCameraReady: (switchCamera) {
                            _switchCameraCallback = switchCamera;
                          },
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

                  // Live Overlay (cronometro e punteggio)
                  Obx(
                    () {
                      final isLandscape = matchController.isOverlayLandscape.value;
                      
                      if (isLandscape) {
                        // LAYOUT LANDSCAPE COMPLETO - RUOTATO DI 90 GRADI
                        return Positioned(
                          left: -100,
                          top: 60, // Centrato verticalmente
                          child: Transform.rotate(
                            angle: -1.5708, // -90 gradi in radianti (-π/2)
                            origin: const Offset(0, 0),
                            child: Container(
                              width: 550, // Ingrandito ulteriormente
                              height: 400, // Ingrandito ulteriormente
                              child: Stack(
                                children: [
                                  // 1. Overlay compatto in alto a sinistra
                                  Positioned(
                                    top: 12,
                                    left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 8,
                                  children: [
                                    // Tempo + indicatore tempo
                                    Row(
                                      spacing: 4,
                                      children: [
                                        const Icon(Icons.schedule, color: Colors.white, size: 14),
                                        Text(
                                          matchController.formatMatchTime(matchController.matchTime.value),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                        Text(
                                          ' ${matchController.halfTime.value}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Separatore
                                    Container(
                                      width: 1,
                                      height: 20,
                                      color: Colors.white.withOpacity(0.5),
                                    ),
                                    // Squadre e punteggio
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Nomi squadre
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          spacing: 6,
                                          children: [
                                            Text(
                                              matchController.team1Name.value,
                                              style: TextStyle(
                                                color: matchController.team1Color.value,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '-',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              matchController.team2Name.value,
                                              style: TextStyle(
                                                color: matchController.team2Color.value,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // Punteggio
                                        Text(
                                          '${matchController.team1Score.value}-${matchController.team2Score.value}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                                              matchController.formatMatchTime(matchController.matchTime.value),
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
                              right: 12,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 12,
                                  children: [
                                    // Highlight button
                                    Obx(
                                      () => Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: matchController.isRecording.value
                                              ? matchController.markHighlight
                                              : null,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: matchController.isRecording.value
                                                  ? Colors.amber
                                                  : Colors.grey.withOpacity(0.5),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.star,
                                              color: Colors.black,
                                              size: 28,
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
                                            width: 50,
                                            height: 50,
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
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                    // Switch camera button
                                    if (kIsWeb)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            if (_switchCameraCallback != null) {
                                              _switchCameraCallback!();
                                            }
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.flip_camera_ios,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    
                                    // Toggle orientation button
                                    if (kIsWeb)
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            matchController.toggleOverlayOrientation();
                                            Get.snackbar(
                                              'Orientamento',
                                              'Verticale',
                                              duration: const Duration(seconds: 1),
                                              snackPosition: SnackPosition.TOP,
                                            );
                                          },
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.7),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.stay_current_portrait,
                                              color: Colors.white,
                                              size: 24,
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
                                          width: 50,
                                          height: 50,
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
                                  ],
                                ),
                              ),
                            ),
                            
                            // 4. Score controls compatti in basso
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 80,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Obx(
                                  () => Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 24,
                                    children: [
                                      // Team 1
                                      Row(
                                        spacing: 8,
                                        children: [
                                          IconButton(
                                            onPressed: matchController.subtractGoalTeam1,
                                            icon: const Icon(Icons.remove_circle, color: Colors.blue),
                                            iconSize: 20,
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
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      // Separatore
                                      Container(
                                        width: 2,
                                        height: 24,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      // Team 2
                                      Row(
                                        spacing: 8,
                                        children: [
                                          IconButton(
                                            onPressed: matchController.subtractGoalTeam2,
                                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                                            iconSize: 20,
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
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                        );
                      } else {
                        // LAYOUT VERTICALE - originale invariato
                        return Stack(
                          children: [
                            Positioned(
                              top: 16,
                              left: 16,
                              child: Column(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Match time
                                  Container(
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

                                  // Score board
                                  Container(
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
                                ],
                              ),
                            ),
                            
                            // Bottom controls per layout verticale
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
                                                  matchController.stopRecording();
                                                  await _cameraRecordingController.stopVideoRecording();
                                                } else {
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
                                        
                                        // Switch camera button (solo web)
                                        if (kIsWeb)
                                          IconButton(
                                            onPressed: () {
                                              print('🎥 Pulsante camera premuto. Callback: ${_switchCameraCallback != null ? "presente" : "null"}');
                                              if (_switchCameraCallback != null) {
                                                _switchCameraCallback!();
                                              } else {
                                                print('❌ Callback null!');
                                              }
                                            },
                                            icon: const Icon(Icons.flip_camera_ios),
                                            color: Colors.white,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.black.withOpacity(0.6),
                                            ),
                                            tooltip: 'Cambia camera',
                                          ),
                                        
                                        // Toggle overlay orientation button
                                        if (kIsWeb)
                                          Obx(
                                            () => IconButton(
                                              onPressed: () {
                                                final currentOrientation = matchController.isOverlayLandscape.value;
                                                matchController.toggleOverlayOrientation();
                                                Get.snackbar(
                                                  'Orientamento Overlay',
                                                  currentOrientation ? 'Verticale' : 'Orizzontale',
                                                  duration: const Duration(seconds: 1),
                                                  snackPosition: SnackPosition.TOP,
                                                );
                                              },
                                              icon: Icon(
                                                matchController.isOverlayLandscape.value 
                                                  ? Icons.stay_current_portrait 
                                                  : Icons.stay_current_landscape,
                                              ),
                                              color: Colors.white,
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.black.withOpacity(0.6),
                                              ),
                                              tooltip: 'Cambia orientamento overlay',
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