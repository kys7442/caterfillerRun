import 'package:flutter/material.dart';

/// 먹이 종류
enum FoodType {
  normal, // 일반 (10점)
  gold, // 골드 (고득점)
  shield, // 방패 (충돌 1회 무효)
  slow, // 슬로우 (일시적 속도 감소)
  doubleScore, // 더블 (일정 시간 점수 2배)
}

/// 먹이 모델
class Food {
  final Offset position;
  final double size;
  final FoodType type;

  Food({
    required this.position,
    this.size = 15.0,
    this.type = FoodType.normal,
  });

  /// 종류별 기본 점수
  int get points {
    switch (type) {
      case FoodType.gold:
        return 30;
      case FoodType.normal:
      case FoodType.shield:
      case FoodType.slow:
      case FoodType.doubleScore:
        return 10;
    }
  }

  /// 종류별 표시 색상
  Color get color {
    switch (type) {
      case FoodType.normal:
        return Colors.red;
      case FoodType.gold:
        return Colors.amber;
      case FoodType.shield:
        return Colors.blueAccent;
      case FoodType.slow:
        return Colors.lightBlue;
      case FoodType.doubleScore:
        return Colors.purpleAccent;
    }
  }

  /// 종류별 아이콘 (특수 먹이 구분 표시용)
  IconData? get icon {
    switch (type) {
      case FoodType.normal:
        return null;
      case FoodType.gold:
        return Icons.star;
      case FoodType.shield:
        return Icons.shield;
      case FoodType.slow:
        return Icons.hourglass_bottom;
      case FoodType.doubleScore:
        return Icons.bolt;
    }
  }

  bool get isSpecial => type != FoodType.normal;

  /// 특수 먹이 최초 획득 시 보여줄 설명 정보 (일반 먹이는 null).
  SpecialFoodInfo? get specialInfo {
    switch (type) {
      case FoodType.normal:
        return null;
      case FoodType.gold:
        return const SpecialFoodInfo(
          title: '골드 먹이',
          description: '한 번에 30점!\n일반 먹이보다 3배 높은 점수를 줘요.',
        );
      case FoodType.shield:
        return const SpecialFoodInfo(
          title: '방패 먹이',
          description: '충돌 1회를 막아줘요.\n벽·장애물·내 몸에 부딪혀도 한 번은 안전!',
        );
      case FoodType.slow:
        return const SpecialFoodInfo(
          title: '슬로우 먹이',
          description: '잠깐 동안 속도가 느려져요.\n좁은 길도 침착하게 빠져나가세요.',
        );
      case FoodType.doubleScore:
        return const SpecialFoodInfo(
          title: '더블 먹이',
          description: '잠깐 동안 점수가 2배!\n이때 먹이를 많이 먹을수록 이득이에요.',
        );
    }
  }

  /// 충돌 감지 (애벌레 머리와의 충돌)
  bool checkCollision(Offset point, double radius) {
    final dx = position.dx - point.dx;
    final dy = position.dy - point.dy;
    final distanceSquared = dx * dx + dy * dy;
    final minDistanceSquared = (size / 2 + radius) * (size / 2 + radius);
    return distanceSquared < minDistanceSquared;
  }
}

/// 특수 먹이를 최초로 먹었을 때 띄우는 안내 팝업용 정보.
class SpecialFoodInfo {
  final String title;
  final String description;

  const SpecialFoodInfo({required this.title, required this.description});
}
