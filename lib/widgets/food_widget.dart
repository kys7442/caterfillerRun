import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food.dart';
import '../providers/game_provider.dart';

/// 나뭇잎 형태의 먹이 위젯
class FoodWidget extends StatelessWidget {
  final Food food;

  const FoodWidget({
    super.key,
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    final frameCount = context.select<GameProvider, int>((p) => p.frameCount);
    // 펄스 애니메이션 (부유하는 느낌)
    final pulse = sin(frameCount * 0.08) * 2;
    final scaleAnim = 1.0 + sin(frameCount * 0.1) * 0.08;

    return Positioned(
      left: food.position.dx - 12,
      top: food.position.dy - 12 + pulse,
      child: Transform.scale(
        scale: scaleAnim,
        child: SizedBox(
          width: 24,
          height: 24,
          child: food.isSpecial
              ? _SpecialFood(food: food)
              : CustomPaint(painter: _LeafPainter()),
        ),
      ),
    );
  }
}

/// 특수 먹이: 색상 원 + 아이콘 + 글로우
class _SpecialFood extends StatelessWidget {
  final Food food;
  const _SpecialFood({required this.food});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [food.color, food.color.withValues(alpha: 0.7)],
        ),
        boxShadow: [
          BoxShadow(
            color: food.color.withValues(alpha: 0.7),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(food.icon, size: 15, color: Colors.white),
    );
  }
}

/// 나뭇잎 모양 페인터
class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 잎사귀 본체
    final leafPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: [Colors.green.shade300, Colors.green.shade600],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(centerX, 2);
    path.quadraticBezierTo(size.width + 2, centerY * 0.6, centerX, size.height - 2);
    path.quadraticBezierTo(-2, centerY * 0.6, centerX, 2);
    path.close();

    canvas.drawPath(path, leafPaint);

    // 잎맥 (중앙 줄)
    final veinPaint = Paint()
      ..color = Colors.green.shade800.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(centerX, 4),
      Offset(centerX, size.height - 4),
      veinPaint,
    );

    // 잎맥 (좌우 가지)
    canvas.drawLine(
      Offset(centerX, centerY * 0.7),
      Offset(centerX - 5, centerY * 0.5),
      veinPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY * 0.7),
      Offset(centerX + 5, centerY * 0.5),
      veinPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY * 1.2),
      Offset(centerX - 4, centerY),
      veinPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY * 1.2),
      Offset(centerX + 4, centerY),
      veinPaint,
    );

    // 하이라이트 (반짝이는 느낌)
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX - 3, centerY - 3), 2.5, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
