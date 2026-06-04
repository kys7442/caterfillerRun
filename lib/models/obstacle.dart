import 'package:flutter/material.dart';

/// 장애물 모델
class Obstacle {
  final Offset position;
  final double size;
  final Color color;

  Obstacle({
    required this.position,
    this.size = 20.0,
    this.color = Colors.grey,
  });

  /// 충돌 감지 (성능 최적화: 거리 제곱 계산)
  bool checkCollision(Offset point, double radius) {
    final dx = position.dx - point.dx;
    final dy = position.dy - point.dy;
    final distanceSquared = dx * dx + dy * dy;
    final minDistanceSquared = (size / 2 + radius) * (size / 2 + radius);
    return distanceSquared < minDistanceSquared;
  }
}

