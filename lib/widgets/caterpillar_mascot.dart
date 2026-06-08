import 'package:flutter/material.dart';

/// 메인 화면 중앙에 놓는 '정면을 보는 큰 애벌레 마스코트' (정적).
///
/// 이미지 에셋 없이 [CustomPaint]로 그린다. 게임 속 애벌레와 톤을 맞춰
/// 둥근 초록 몸통 마디(아래로 쌓인) + 큰 머리 + 반짝이는 눈 + 볼 홍조 + 미소.
class CaterpillarMascot extends StatelessWidget {
  /// 마스코트 전체 크기(정사각 기준 한 변, px).
  final double size;
  final MaterialColor swatch;

  const CaterpillarMascot({
    super.key,
    this.size = 160,
    this.swatch = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MascotPainter(swatch)),
    );
  }
}

class _MascotPainter extends CustomPainter {
  final MaterialColor swatch;
  _MascotPainter(this.swatch);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // 바닥 그림자
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.95), width: w * 0.5, height: h * 0.06),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    // 몸통 마디 (아래에서 위로 여러 개를 길게 쌓아 '애벌레'처럼).
    // 좌우로 살짝 굽이쳐 통통 기어오르는 느낌을 준다.
    final bodyR = w * 0.155; // 몸통 마디 반지름
    final bodyDefs = [
      [cx + w * 0.05, h * 0.88], // 꼬리
      [cx - w * 0.05, h * 0.76],
      [cx + w * 0.05, h * 0.64],
      [cx - w * 0.04, h * 0.53],
      [cx + w * 0.03, h * 0.43], // 머리 바로 아래(목)
    ];
    for (int i = 0; i < bodyDefs.length; i++) {
      final c = Offset(bodyDefs[i][0], bodyDefs[i][1]);
      // 꼬리로 갈수록 약간 작게
      final r = bodyR * (0.82 + i * 0.045);
      final base = i.isEven ? swatch.shade400 : swatch.shade300;
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.35, -0.4),
            colors: [
              base.withValues(alpha: 0.98),
              base,
              swatch.shade500,
            ],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = swatch.shade600,
      );
      // 등 무늬 점
      final dot = Paint()..color = swatch.shade700.withValues(alpha: 0.3);
      canvas.drawCircle(c.translate(-r * 0.25, -r * 0.15), 2, dot);
      canvas.drawCircle(c.translate(r * 0.25, -r * 0.15), 2, dot);
    }

    // 머리 (몸통보다 약간만 크게, 위쪽)
    final head = Offset(cx + w * 0.02, h * 0.27);
    final headR = w * 0.205;
    canvas.drawCircle(
      head,
      headR,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [swatch.shade400, swatch.shade600],
        ).createShader(Rect.fromCircle(center: head, radius: headR)),
    );
    canvas.drawCircle(
      head,
      headR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = swatch.shade700,
    );

    // 더듬이 (양쪽 위로 뻗고 끝에 동그라미)
    final antennaPaint = Paint()
      ..color = swatch.shade700
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final lTip = Offset(head.dx - headR * 0.45, head.dy - headR * 1.35);
    final rTip = Offset(head.dx + headR * 0.45, head.dy - headR * 1.35);
    final lPath = Path()
      ..moveTo(head.dx - headR * 0.35, head.dy - headR * 0.75)
      ..quadraticBezierTo(head.dx - headR * 0.7, head.dy - headR * 1.2,
          lTip.dx, lTip.dy);
    final rPath = Path()
      ..moveTo(head.dx + headR * 0.35, head.dy - headR * 0.75)
      ..quadraticBezierTo(head.dx + headR * 0.7, head.dy - headR * 1.2,
          rTip.dx, rTip.dy);
    canvas.drawPath(lPath, antennaPaint);
    canvas.drawPath(rPath, antennaPaint);
    final knob = Paint()..color = Colors.pink.shade300;
    canvas.drawCircle(lTip, headR * 0.13, knob);
    canvas.drawCircle(rTip, headR * 0.13, knob);

    // 두 눈 (큰 흰자 + 검은 눈동자 + 하이라이트)
    final eyeDx = headR * 0.44;
    final eyeY = head.dy - headR * 0.08;
    for (final sign in [-1.0, 1.0]) {
      final ec = Offset(head.dx + sign * eyeDx, eyeY);
      canvas.drawCircle(ec, headR * 0.38, Paint()..color = Colors.white);
      canvas.drawCircle(
        ec,
        headR * 0.38,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = swatch.shade700.withValues(alpha: 0.4),
      );
      final pupil = ec.translate(headR * 0.06, headR * 0.07);
      canvas.drawCircle(pupil, headR * 0.2, Paint()..color = Colors.black87);
      // 하이라이트
      canvas.drawCircle(
        pupil.translate(-headR * 0.07, -headR * 0.07),
        headR * 0.08,
        Paint()..color = Colors.white,
      );
    }

    // 볼 홍조
    final blush = Paint()..color = Colors.pink.shade200.withValues(alpha: 0.6);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(head.dx - headR * 0.6, head.dy + headR * 0.42),
          width: headR * 0.4,
          height: headR * 0.26),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(head.dx + headR * 0.6, head.dy + headR * 0.42),
          width: headR * 0.4,
          height: headR * 0.26),
      blush,
    );

    // 활짝 웃는 입 (반원 + 분홍 혀)
    final mouthRect = Rect.fromCenter(
      center: Offset(head.dx, head.dy + headR * 0.42),
      width: headR * 0.7,
      height: headR * 0.55,
    );
    canvas.drawArc(
      mouthRect,
      0.15,
      3.14 - 0.3,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = swatch.shade900,
    );
    // 입 안 채우기 (살짝)
    final mouthFill = Path()
      ..addArc(mouthRect, 0.15, 3.14 - 0.3)
      ..close();
    canvas.drawPath(
        mouthFill, Paint()..color = const Color(0xFF7A3B3B).withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(_MascotPainter oldDelegate) => false;
}
