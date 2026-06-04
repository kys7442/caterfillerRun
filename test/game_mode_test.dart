import 'package:flutter_test/flutter_test.dart';
import 'package:caterpillar_run/models/game_state.dart';

void main() {
  group('GameMode', () {
    test('모든 모드는 라벨/설명/기록키를 가진다', () {
      for (final mode in GameMode.values) {
        expect(mode.label, isNotEmpty);
        expect(mode.description, isNotEmpty);
        expect(mode.recordKey, isNotEmpty);
      }
    });

    test('기록키는 모드별로 고유하다', () {
      final keys = GameMode.values.map((m) => m.recordKey).toSet();
      expect(keys.length, GameMode.values.length);
    });

    test('타임어택만 90초 제한, 나머지는 0', () {
      expect(GameMode.timeAttack.timeLimitSec, 90);
      expect(GameMode.stage.timeLimitSec, 0);
      expect(GameMode.endless.timeLimitSec, 0);
    });
  });
}
