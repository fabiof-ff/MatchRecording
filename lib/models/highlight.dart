class Highlight {
  final String id;
  final Duration timestamp;
  final Duration duration;
  final DateTime date;

  Highlight({
    required this.id,
    required this.timestamp,
    this.duration = const Duration(seconds: 10),
    required this.date,
  });

  String get formattedTime {
    final minutes = timestamp.inMinutes;
    final seconds = timestamp.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.inSeconds,
      'duration': duration.inSeconds,
      'date': date.toIso8601String(),
    };
  }

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      timestamp: Duration(seconds: json['timestamp'] as int),
      duration: Duration(seconds: json['duration'] as int),
      date: DateTime.parse(json['date'] as String),
    );
  }
}
