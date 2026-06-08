import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

/// 화려한 스테이지 완료 화면
class LevelUpScreen extends StatefulWidget {
  final int newLevel;
  final int totalScore;

  const LevelUpScreen({super.key, required this.newLevel, required this.totalScore});

  @override
  State<LevelUpScreen> createState() => _LevelUpScreenState();
}

class _LevelUpScreenState extends State<LevelUpScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _starController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _starRotation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _starController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));

    _starRotation = Tween<double>(begin: 0.0, end: 6.28)
        .animate(CurvedAnimation(parent: _starController, curve: Curves.linear));

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _particleController, curve: Curves.linear));

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _starController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  bool _isMilestone(int level) {
    return level % 10 == 0 || level == 5 || level == 25 || level == 50 || level == 100;
  }

  @override
  Widget build(BuildContext context) {
    final levelConfig = context.read<GameProvider>().levelConfig;
    final milestone = _isMilestone(widget.newLevel);

    // 마일스톤에 따라 다른 색상
    final List<Color> gradientColors;
    if (widget.newLevel >= 50) {
      gradientColors = [Colors.purple.shade400, Colors.deepPurple.shade600];
    } else if (widget.newLevel >= 25) {
      gradientColors = [Colors.red.shade400, Colors.orange.shade600];
    } else if (widget.newLevel >= 10) {
      gradientColors = [Colors.blue.shade400, Colors.indigo.shade600];
    } else {
      gradientColors = [Colors.amber.shade300, Colors.orange.shade400];
    }

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: Listenable.merge([_mainController, _starController, _particleController]),
        builder: (context, child) {
          return Stack(
            children: [
              // 배경 (어두운 오버레이)
              Container(
                color: Colors.black.withValues(alpha: _fadeAnimation.value * 0.75),
              ),

              // 파티클 효과
              if (_fadeAnimation.value > 0.5)
                ..._buildParticles(context),

              // 메인 카드
              Center(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 회전하는 별
                          Transform.rotate(
                            angle: _starRotation.value,
                            child: Icon(
                              milestone ? Icons.auto_awesome : Icons.star,
                              size: milestone ? 90 : 70,
                              color: Colors.yellow.shade200,
                              shadows: const [
                                Shadow(offset: Offset(0, 0), blurRadius: 20, color: Colors.yellow),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 제목
                          Text(
                            milestone ? 'AMAZING!' : 'STAGE CLEAR!',
                            style: TextStyle(
                              fontSize: milestone ? 28 : 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 3,
                              shadows: const [
                                Shadow(offset: Offset(2, 2), blurRadius: 6, color: Colors.black38),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 레벨 번호
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'STAGE ${widget.newLevel}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 점수
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.yellow.shade200, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.totalScore}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                ' points',
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            ],
                          ),

                          if (levelConfig != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _NextInfo(icon: Icons.speed, label: '${levelConfig.speed.toInt()}'),
                                  const SizedBox(width: 16),
                                  _NextInfo(icon: Icons.block, label: '${levelConfig.obstacleCount}'),
                                  const SizedBox(width: 16),
                                  _NextInfo(icon: Icons.eco, label: '${levelConfig.foodCount}'),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),

                          // 다음 스테이지 버튼
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              // true = 다음 스테이지로 계속
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: gradientColors[1],
                                elevation: 8,
                                shadowColor: Colors.black38,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'STAGE ${widget.newLevel} START',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 22),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 그만두고 메뉴로 나가기
                          TextButton.icon(
                            // false = 게임을 끝내고 메뉴로
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: const Icon(Icons.home_rounded,
                                size: 18, color: Colors.white70),
                            label: const Text(
                              '여기서 그만두기',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildParticles(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final particles = <Widget>[];
    final random = _particleAnimation.value;

    for (int i = 0; i < 20; i++) {
      final x = (screenSize.width * ((i * 0.137 + random) % 1.0));
      final y = screenSize.height * (1.0 - ((i * 0.089 + random * 1.5) % 1.0));
      final size = 4.0 + (i % 5) * 2.0;
      final opacity = (0.3 + (i % 3) * 0.2).clamp(0.0, 1.0);

      particles.add(
        Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: [
                Colors.yellow.shade300,
                Colors.orange.shade300,
                Colors.amber.shade200,
                Colors.white,
              ][i % 4]
                  .withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return particles;
  }
}

class _NextInfo extends StatelessWidget {
  final IconData icon;
  final String label;

  const _NextInfo({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
