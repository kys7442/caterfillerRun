import 'package:flutter/material.dart';
import '../models/obstacle.dart';

/// 둥근 돌맹이 장애물 위젯
class ObstacleWidget extends StatelessWidget {
  final Obstacle obstacle;

  const ObstacleWidget({
    super.key,
    required this.obstacle,
  });

  @override
  Widget build(BuildContext context) {
    final size = obstacle.size;

    return Positioned(
      left: obstacle.position.dx - size / 2,
      top: obstacle.position.dy - size / 2,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            // 그림자
            Positioned(
              left: 2,
              top: 2,
              child: Container(
                width: size - 2,
                height: size - 2,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(size * 0.35),
                    topRight: Radius.circular(size * 0.25),
                    bottomLeft: Radius.circular(size * 0.3),
                    bottomRight: Radius.circular(size * 0.4),
                  ),
                ),
              ),
            ),
            // 돌 본체
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade500,
                    Colors.grey.shade600,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size * 0.35),
                  topRight: Radius.circular(size * 0.25),
                  bottomLeft: Radius.circular(size * 0.3),
                  bottomRight: Radius.circular(size * 0.4),
                ),
                border: Border.all(
                  color: Colors.grey.shade700,
                  width: 1,
                ),
              ),
            ),
            // 하이라이트 (빛 반사)
            Positioned(
              left: size * 0.2,
              top: size * 0.15,
              child: Container(
                width: size * 0.25,
                height: size * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
              ),
            ),
            // 작은 점 (질감)
            Positioned(
              right: size * 0.25,
              bottom: size * 0.3,
              child: Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey.shade700.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
