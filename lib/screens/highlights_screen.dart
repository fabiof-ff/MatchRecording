import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/match_controller.dart';

class HighlightsScreen extends StatelessWidget {
  const HighlightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final matchController = Get.find<MatchController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Highlights'),
        elevation: 0,
      ),
      body: Obx(
        () {
          if (matchController.highlights.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun Highlight',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Registra una partita e marca i momenti salienti',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matchController.highlights.length,
                  itemBuilder: (context, index) {
                    final highlight = matchController.highlights[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber.shade700,
                          ),
                        ),
                        title: Text(
                          'Highlight ${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tempo: ${highlight.formattedTime}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(highlight.date)}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            matchController.highlights.removeAt(index);
                            // Highlight rimosso
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Bottom action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  spacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showExportDialog(context, matchController),
                      icon: const Icon(Icons.file_download),
                      label: const Text('Esporta Highlights (MP4)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showClearDialog(context, matchController),
                      icon: const Icon(Icons.delete),
                      label: const Text('Cancella Tutti'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportDialog(BuildContext context, MatchController controller) {
    Get.defaultDialog(
      title: 'Esporta Highlights',
      content: Column(
        children: [
          const Icon(Icons.info_outline, size: 32, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            'Highlights: ${controller.highlights.length}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'Durata totale: ${controller.formatMatchTime(controller.getTotalHighlightsDuration())}',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text(
            'File MP4 pronto per il download',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Scarica'),
        ),
      ],
    );
  }

  void _showClearDialog(BuildContext context, MatchController controller) {
    Get.defaultDialog(
      title: 'Conferma',
      content: const Text('Sei sicuro di voler eliminare tutti gli highlights?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () {
            controller.highlights.clear();
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Elimina', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
