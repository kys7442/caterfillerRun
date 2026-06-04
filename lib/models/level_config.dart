import 'dart:math';
import 'package:flutter/material.dart';

/// 레벨 설정
class LevelConfig {
  final int level;
  final double speed; // 애벌레 속도 (픽셀/초)
  final int obstacleCount; // 장애물 개수
  final int foodCount; // 먹이 개수
  final Color backgroundColor; // 배경색

  LevelConfig({
    required this.level,
    required this.speed,
    required this.obstacleCount,
    required this.foodCount,
    required this.backgroundColor,
  });

  /// 레벨별 설정 생성 (무한 스케일링)
  static LevelConfig getLevelConfig(int level) {
    return LevelConfig(
      level: level,
      speed: 80.0 + (level - 1) * 3.0,
      obstacleCount: min(level - 1, 30),
      foodCount: level,
      backgroundColor: _getBackgroundColor(level),
    );
  }

  static Color _getBackgroundColor(int level) {
    final tier = ((level - 1) ~/ 10) % 4;
    switch (tier) {
      case 0:
        return Colors.green.shade50;
      case 1:
        return Colors.blue.shade50;
      case 2:
        return Colors.orange.shade50;
      case 3:
        return Colors.purple.shade50;
      default:
        return Colors.green.shade50;
    }
  }
}
