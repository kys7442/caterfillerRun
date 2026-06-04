/// 점수 기록 모델
class ScoreRecord {
  final int score;
  final int level;
  final int survivalTime;
  final DateTime timestamp;

  ScoreRecord({
    required this.score,
    required this.level,
    required this.survivalTime,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'survivalTime': survivalTime,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      score: json['score'] as int,
      level: json['level'] as int,
      survivalTime: json['survivalTime'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  String get formattedDate {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}

