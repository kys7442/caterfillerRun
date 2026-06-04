import 'dart:math';
import 'package:flutter/material.dart';

/// 아기자기한 애벌레 위젯
class CaterpillarWidget extends StatelessWidget {
  final List<Offset> segments;
  final Offset direction;
  final int frameCount;
  final MaterialColor swatch; // 스킨 색 계열

  const CaterpillarWidget({
    super.key,
    required this.segments,
    this.direction = const Offset(1, 0),
    this.frameCount = 0,
    this.swatch = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 몸통 (뒤에서 앞으로 그려서 머리가 위에 오도록)
        for (int i = segments.length - 1; i > 0; i--)
          _CaterpillarSegment(
            position: segments[i],
            index: i,
            totalSegments: segments.length,
            isTail: i == segments.length - 1,
            frameCount: frameCount,
            swatch: swatch,
          ),
        // 머리 (가장 위에)
        _CaterpillarHead(
          position: segments[0],
          direction: direction,
          frameCount: frameCount,
          swatch: swatch,
        ),
      ],
    );
  }
}

/// 애벌레 머리 - 귀여운 디자인
class _CaterpillarHead extends StatelessWidget {
  final Offset position;
  final Offset direction;
  final int frameCount;
  final MaterialColor swatch;

  const _CaterpillarHead({
    required this.position,
    required this.direction,
    required this.frameCount,
    required this.swatch,
  });

  @override
  Widget build(BuildContext context) {
    final angle = atan2(direction.dy, direction.dx);

    return Positioned(
      left: position.dx - 17,
      top: position.dy - 17,
      child: Transform.rotate(
        angle: angle,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 머리 본체
              Center(
                child: Container(
                  width: 30,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [swatch.shade500, swatch.shade700],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: swatch.shade900.withValues(alpha: 0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // 왼쪽 더듬이
              Positioned(
                left: 8,
                top: -6,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: swatch.shade800,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // 오른쪽 더듬이
              Positioned(
                right: 8,
                top: -6,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: swatch.shade800,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // 왼쪽 눈 (흰자)
              Positioned(
                left: 5,
                top: 9,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              // 오른쪽 눈 (흰자)
              Positioned(
                right: 5,
                top: 9,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              // 왼쪽 볼 홍조
              Positioned(
                left: 2,
                top: 18,
                child: Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // 오른쪽 볼 홍조
              Positioned(
                right: 2,
                top: 18,
                child: Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // 미소
              Positioned(
                left: 12,
                top: 21,
                child: Container(
                  width: 8,
                  height: 3,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: swatch.shade900, width: 1.5),
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 애벌레 몸통 세그먼트 - 교차 색상 + 등 무늬
class _CaterpillarSegment extends StatelessWidget {
  final Offset position;
  final int index;
  final int totalSegments;
  final bool isTail;
  final int frameCount;
  final MaterialColor swatch;

  const _CaterpillarSegment({
    required this.position,
    required this.index,
    required this.totalSegments,
    this.isTail = false,
    required this.frameCount,
    required this.swatch,
  });

  @override
  Widget build(BuildContext context) {
    // 크기 점진적으로 작아짐 (최소 14)
    final size = (22.0 - index * 0.3).clamp(14.0, 22.0);
    final halfSize = size / 2;

    // 교차 색상
    final isEven = index % 2 == 0;
    final baseColor = isEven ? swatch.shade500 : swatch.shade300;
    final borderColor = isEven ? swatch.shade700 : swatch.shade500;

    // 꿈틀거림 (미세한 오프셋)
    final wiggle = sin(frameCount * 0.15 + index * 0.8) * 1.5;

    return Positioned(
      left: position.dx - halfSize + wiggle,
      top: position.dy - halfSize,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            colors: [baseColor.withValues(alpha: 0.9), baseColor],
          ),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: swatch.shade900.withValues(alpha: 0.15),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: !isTail
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: swatch.shade800.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: size * 0.2),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: swatch.shade800.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}
