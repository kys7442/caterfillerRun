import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../utils/sound_manager.dart';
import '../utils/firebase_service.dart';
import 'game_screen.dart';

/// 카운트다운 화면
class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _countdown = 5;
  Timer? _timer;
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _countdown--;
        });

        if (_countdown > 0) {
          _soundManager.playSfx('sounds/countdown.mp3');
        }

        if (_countdown <= 0) {
          timer.cancel();
          _soundManager.playSfx('sounds/start.mp3');
          _startGame();
        }
      },
    );
  }

  void _startGame() {
    final gameProvider = context.read<GameProvider>();
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final topInset = topPadding + 70; // SafeArea 상단 + HUD 높이
    const bottomInset = 60.0; // 배너 광고 높이
    gameProvider.beginPlaying(size, topInset: topInset, bottomInset: bottomInset);

    // 분석: 게임 시작 이벤트 (Firebase 미설정 시 자동 no-op)
    FirebaseService.instance.logGameStart(gameProvider.currentLevel);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final level = gameProvider.currentLevel;

    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 스테이지 표시
            Text(
              'STAGE $level',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade300,
                letterSpacing: 3,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms),
            const SizedBox(height: 20),

            // 카운트다운 숫자
            if (_countdown > 0)
              Text(
                _countdown.toString(),
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.2, 1.2),
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.easeInOut,
                  )
            else
              const Text(
                '시작!',
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              )
                  .animate()
                  .scale(delay: 0.ms, duration: 300.ms, begin: const Offset(0, 0), end: const Offset(1, 1))
                  .fadeIn(duration: 300.ms),
            const SizedBox(height: 40),

            // 게임 설명
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _GuideRow(icon: Icons.touch_app, text: '화면을 터치하여 애벌레를 조종'),
                  const SizedBox(height: 8),
                  _GuideRow(icon: Icons.eco, text: '나뭇잎을 모두 먹으면 스테이지 클리어'),
                  const SizedBox(height: 8),
                  _GuideRow(icon: Icons.dangerous, text: '벽/장애물/자기 몸에 닿으면 게임 오버'),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _GuideRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
