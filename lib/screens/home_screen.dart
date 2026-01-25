class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchController = Get.put(MatchController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Recording'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Match Recording',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Registra e evidenzia i momenti salienti',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Recording Status
              Obx(
                () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: matchController.isRecording.value ? Colors.red.shade50 : Colors.gray.shade100,
                    border: Border.all(
                      color: matchController.isRecording.value ? Colors.red : Colors.gray,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: matchController.isRecording.value ? Colors.red : Colors.gray,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              matchController.isRecording.value
                                  ? 'Registrazione in corso'
                                  : 'Pronto per registrare',
                              style: const TextStyle(
                                fontWeight: FontWeight.semibold,
                                fontSize: 16,
                              ),
                            ),
                            if (matchController.isRecording.value)
                              Obx(
                                () => Text(
                                  'Durata: ${matchController.formatMatchTime(matchController.matchTime.value)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

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
                    const SizedBox(height: 12),
                    Obx(
                      () => Column(
                        children: [
                          _buildSettingRow('Tempo partita', matchController.formatMatchTime(matchController.matchTime.value)),
                          const SizedBox(height: 8),
                          _buildSettingRow('${matchController.team1Name.value}', '${matchController.team1Score.value} gol'),
                          const SizedBox(height: 8),
                          _buildSettingRow('${matchController.team2Name.value}', '${matchController.team2Score.value} gol'),
                        ],
                      ),
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
                            fontWeight: FontWeight.semibold,
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
                ],
              ),
            ],
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
            fontWeight: FontWeight.semibold,
          ),
        ),
      ],
    );
  }
}
