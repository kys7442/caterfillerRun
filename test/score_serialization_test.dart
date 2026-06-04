import 'package:flutter_test/flutter_test.dart';
import 'package:caterpillar_run/models/game_state.dart';
import 'package:caterpillar_run/models/score_record.dart';

void main() {
  group('GameResult 직렬화', () {
    test('toJson → fromJson 라운드트립 값 보존', () {
      final result = GameResult(score: 1234, level: 7, survivalTime: 95);
      final restored = GameResult.fromJson(result.toJson());

      expect(restored.score, result.score);
      expect(restored.level, result.level);
      expect(restored.survivalTime, result.survivalTime);
    });
  });

  group('ScoreRecord 직렬화', () {
    test('toJson → fromJson 라운드트립 값 보존', () {
      final record = ScoreRecord(
        score: 500,
        level: 3,
        survivalTime: 42,
        timestamp: DateTime(2026, 6, 4, 10, 30),
      );
      final restored = ScoreRecord.fromJson(record.toJson());

      expect(restored.score, record.score);
      expect(restored.level, record.level);
      expect(restored.survivalTime, record.survivalTime);
      expect(restored.timestamp, record.timestamp);
    });

    test('formattedDate는 0 패딩된 YYYY-MM-DD 형식', () {
      final record = ScoreRecord(
        score: 0,
        level: 1,
        survivalTime: 0,
        timestamp: DateTime(2026, 1, 5),
      );
      expect(record.formattedDate, '2026-01-05');
    });
  });
}
