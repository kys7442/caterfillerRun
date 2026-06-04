import 'dart:math';
import 'package:flutter/material.dart';

/// 먹이 획득 시 떠오르는 점수 팝업 (+10, COMBO x2 등).
/// 스스로 애니메이션하고 완료 시 [onDone]을 호출해 부모가 제거하게 한다.
class ScorePopup extends StatefulWidget {
  final Offset position;
  final int points;
  final double comboMultiplier;
  final VoidCallback onDone;

  const ScorePopup({
    super.key,
    required this.position,
    required this.points,
    required this.comboMultiplier,
    required this.onDone,
  });

  @override
  State<ScorePopup> createState() => _ScorePopupState();
}

class _ScorePopupState extends State<ScorePopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _rise;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _rise = Tween<double>(begin: 0, end: -42)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 1, end: 0)
        .animate(CurvedAnimation(parent: _c, curve: const Interval(0.5, 1.0)));
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.2), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCombo = widget.comboMultiplier > 1.0;
    final color = isCombo ? Colors.amber.shade400 : Colors.white;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Positioned(
          left: widget.position.dx - 30,
          top: widget.position.dy + _rise.value - 10,
          child: Opacity(
            opacity: _fade.value,
            child: Transform.scale(
              scale: _scale.value,
              child: SizedBox(
                width: 60,
                child: Text(
                  '+${widget.points}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isCombo ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: color,
                    shadows: const [
                      Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 3,
                          color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 먹이 획득 지점에서 터지는 파티클 폭발.
class ParticleBurst extends StatefulWidget {
  final Offset position;
  final Color color;
  final VoidCallback onDone;

  const ParticleBurst({
    super.key,
    required this.position,
    required this.color,
    required this.onDone,
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // 시드를 위치 기반으로 두어 매 폭발이 약간씩 달라지게 함
    final rnd = Random(widget.position.dx.toInt() * 31 +
        widget.position.dy.toInt());
    _particles = List.generate(8, (i) {
      final angle = (i / 8) * 2 * pi + rnd.nextDouble() * 0.5;
      final speed = 18 + rnd.nextDouble() * 16;
      return _Particle(
        dx: cos(angle) * speed,
        dy: sin(angle) * speed,
        size: 3 + rnd.nextDouble() * 3,
      );
    });
    _c.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Stack(
          children: _particles.map((p) {
            return Positioned(
              left: widget.position.dx + p.dx * t,
              top: widget.position.dy + p.dy * t,
              child: Opacity(
                opacity: (1 - t).clamp(0.0, 1.0),
                child: Container(
                  width: p.size,
                  height: p.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Particle {
  final double dx;
  final double dy;
  final double size;
  _Particle({required this.dx, required this.dy, required this.size});
}
