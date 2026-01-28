import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/match_controller.dart';
import '../controllers/camera_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchController = Get.put(MatchController());

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              // Overlay Settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Impostazioni Overlay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Squadra 1
                    const Text('Squadra 1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Nome squadra 1',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) => matchController.team1Name.value = value,
                            controller: TextEditingController(text: matchController.team1Name.value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => GestureDetector(
                          onTap: () => _showColorPicker(context, matchController, true),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: matchController.team1Color.value,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Squadra 2
                    const Text('Squadra 2', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Nome squadra 2',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) => matchController.team2Name.value = value,
                            controller: TextEditingController(text: matchController.team2Name.value),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() => GestureDetector(
                          onTap: () => _showColorPicker(context, matchController, false),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: matchController.team2Color.value,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300, width: 2),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              // Highlights Count
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    border: Border.all(color: Colors.yellow.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rate_rounded, color: Colors.yellow.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Highlights marcati: ${matchController.highlights.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons
              Column(
                spacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed('/recording'),
                    icon: const Icon(Icons.videocam),
                    label: const Text('Inizia Registrazione'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/highlights'),
                    icon: const Icon(Icons.star_rate_rounded),
                    label: Obx(
                      () => Text('I Miei Highlights (${matchController.highlights.length})'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.amber.shade700,
                      side: BorderSide(color: Colors.amber.shade700, width: 2),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  // Info percorso salvataggio video
                  TextButton.icon(
                    onPressed: () {
                      try {
                        final cameraController = Get.find<CameraRecordingController>();
                        final dir = cameraController.getVideoSaveDirectory();
                        Get.dialog(
                          AlertDialog(
                            title: const Text('📁 Percorso Salvataggio'),
                            content: SelectableText(
                              dir,
                              style: const TextStyle(fontSize: 12),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        // Camera non ancora inizializzata
                      }
                    },
                    icon: const Icon(Icons.folder_outlined, size: 18),
                    label: const Text('Dove vengono salvati i video?'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey.shade100,
        child: Text(
          'Ultimo deploy: 28/01/2026 - 21:00',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  void _showColorPicker(BuildContext context, MatchController controller, bool isTeam1) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.lime,
      Colors.amber,
    ];
    
    Get.dialog(
      AlertDialog(
        title: Text('Scegli colore ${isTeam1 ? "Squadra 1" : "Squadra 2"}'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                if (isTeam1) {
                  controller.team1Color.value = color;
                } else {
                  controller.team2Color.value = color;
                }
                Get.back();
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }
}
