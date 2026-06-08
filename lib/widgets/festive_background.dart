import 'dart:math';
import 'package:flutter/material.dart';

/// 캐주얼 게임 메인 화면용 '화려한 정적 배경'.
///
/// 이미지 에셋 없이 [CustomPaint]로 하늘 그라데이션·구름·반짝이는 별빛·
/// 깃발 가랜드(bunting)를 그린다. 움직이지 않는다(정적).
class FestiveBackground extends StatelessWidget {
  const FestiveBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF3FA9F5), // 밝은 하늘색
            Color(0xFF59C3F0),
            Color(0xFF9BDBF5), // 아래로 갈수록 연하게
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: _FestivePainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _FestivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1) 중앙에서 퍼지는 햇살 같은 방사 글로우
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(center: Offset(w / 2, h * 0.34), radius: w * 0.7),
      );
    canvas.drawRect(Offset.zero & size, glow);

    // 2) 반짝이는 별빛(sparkle) — 고정 시드로 정적 배치
    final rnd = Random(42);
    final sparkle = Paint()..color = Colors.yellow.shade200;
    for (int i = 0; i < 90; i++) {
      final x = rnd.nextDouble() * w;
      final y = rnd.nextDouble() * h * 0.85;
      // 중앙 근처일수록 더 촘촘/밝게
      final dist = (Offset(x, y) - Offset(w / 2, h * 0.34)).distance;
      final near = (1 - (dist / (w * 0.8))).clamp(0.0, 1.0);
      if (rnd.nextDouble() > near * 0.9 + 0.1) continue;
      final r = 1.0 + rnd.nextDouble() * 2.2 * near;
      sparkle.color =
          Colors.yellow.shade100.withValues(alpha: 0.5 + near * 0.5);
      _drawSparkle(canvas, Offset(x, y), r, sparkle);
    }

    // 3) 구름들 (둥근 흰 덩어리)
    _drawCloud(canvas, Offset(w * 0.16, h * 0.14), w * 0.16);
    _drawCloud(canvas, Offset(w * 0.82, h * 0.20), w * 0.13);
    _drawCloud(canvas, Offset(w * 0.78, h * 0.62), w * 0.15);
    _drawCloud(canvas, Offset(w * 0.18, h * 0.70), w * 0.14);
    _drawCloud(canvas, Offset(w * 0.5, h * 0.86), w * 0.18);

    // 4) 상단 깃발 가랜드 (양쪽에서 늘어진 줄 + 삼각 깃발)
    _drawBunting(canvas, Offset(0, h * 0.04), Offset(w * 0.42, h * 0.10), 7);
    _drawBunting(canvas, Offset(w, h * 0.05), Offset(w * 0.62, h * 0.11), 6);
  }

  void _drawSparkle(Canvas canvas, Offset c, double r, Paint p) {
    // 네 갈래 반짝임(다이아몬드 십자)
    final path = Path()
      ..moveTo(c.dx, c.dy - r * 2)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 2)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 2)
      ..close();
    canvas.drawPath(path, p);
  }

  void _drawCloud(Canvas canvas, Offset center, double scale) {
    final p = Paint()..color = Colors.white.withValues(alpha: 0.92);
    final s = scale;
    // 여러 원을 겹쳐 뭉게구름 실루엣
    canvas.drawCircle(center.translate(-s * 0.6, s * 0.1), s * 0.55, p);
    canvas.drawCircle(center.translate(0, -s * 0.15), s * 0.75, p);
    canvas.drawCircle(center.translate(s * 0.65, s * 0.05), s * 0.6, p);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
            center.dx - s * 1.1, center.dy + s * 0.1, s * 2.2, s * 0.6),
        Radius.circular(s * 0.3),
      ),
      p,
    );
  }

  void _drawBunting(Canvas canvas, Offset start, Offset end, int flags) {
    // 늘어진 줄 (살짝 처진 곡선)
    final sag = (end - start).distance * 0.18;
    final ctrl = Offset((start.dx + end.dx) / 2, max(start.dy, end.dy) + sag);
    final line = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);
    canvas.drawPath(
      line,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white.withValues(alpha: 0.85),
    );

    // 줄 위에 삼각 깃발들 (알록달록)
    final colors = [
      Colors.redAccent,
      Colors.orangeAccent,
      Colors.yellow.shade600,
      Colors.greenAccent.shade400,
      Colors.lightBlueAccent,
      Colors.pinkAccent,
    ];
    for (int i = 0; i < flags; i++) {
      final t = (i + 0.5) / flags;
      // 2차 베지어 위의 점
      final p = _quad(start, ctrl, end, t);
      final fw = 14.0; // 깃발 폭
      final fh = 18.0; // 깃발 높이
      final flag = Path()
        ..moveTo(p.dx - fw / 2, p.dy)
        ..lineTo(p.dx + fw / 2, p.dy)
        ..lineTo(p.dx, p.dy + fh)
        ..close();
      canvas.drawPath(flag, Paint()..color = colors[i % colors.length]);
    }
  }

  Offset _quad(Offset a, Offset c, Offset b, double t) {
    final mt = 1 - t;
    final x = mt * mt * a.dx + 2 * mt * t * c.dx + t * t * b.dx;
    final y = mt * mt * a.dy + 2 * mt * t * c.dy + t * t * b.dy;
    return Offset(x, y);
  }

  @override
  bool shouldRepaint(_FestivePainter oldDelegate) => false;
}
