import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/festive_background.dart';
import '../widgets/caterpillar_mascot.dart';

/// 앱 시작 시 잠깐 보여주는 스플래시 화면.
/// 달려가는 애벌레 + 타이틀을 보여준 뒤 [onFinish]를 호출해 다음 화면으로 넘어간다.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 애니메이션을 잠깐 보여준 뒤 자동 진행.
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 화려한 정적 배경 (메뉴와 통일)
          const Positioned.fill(child: FestiveBackground()),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // 큰 애벌레 마스코트
                const CaterpillarMascot(size: 180)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),
                const SizedBox(height: 16),

                // 입체 타이틀
                Stack(
                  children: [
                    Text(
                      '애벌레야! 어디가?',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 7
                          ..color = const Color(0xFF5B2A86),
                      ),
                    ),
                    const Text(
                      '애벌레야! 어디가?',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFFD54F),
                        shadows: [
                          Shadow(
                              offset: Offset(0, 3),
                              color: Color(0xFFE69500)),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      delay: 250.ms,
                    ),
                const SizedBox(height: 8),
                const Text(
                  'Caterpillar Run',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    shadows: [Shadow(blurRadius: 3, color: Colors.black38)],
                  ),
                ).animate().fadeIn(delay: 450.ms, duration: 600.ms),
                const Spacer(),

                // 하단 로딩 인디케이터
                const Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
