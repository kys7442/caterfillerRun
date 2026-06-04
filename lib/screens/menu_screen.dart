import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../providers/score_provider.dart';
import '../providers/currency_provider.dart';
import '../utils/sound_manager.dart';
import '../widgets/daily_checkin_sheet.dart';
import 'game_screen.dart';
import 'records_screen.dart';
import 'settings_screen.dart';
import 'leaderboard_screen.dart';
import 'achievements_screen.dart';
import 'skin_shop_screen.dart';
import '../widgets/mode_select_sheet.dart';

/// 메인 메뉴 화면
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final bestRecord = scoreProvider.bestRecord;

    return Scaffold(
      body: Stack(
        children: [
        Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade300,
              Colors.green.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 게임 타이틀 (애니메이션)
                const Text(
                  '애벌레야 ! 어디가 ?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 8),
                const Text(
                  'Caterpillar Run',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 60),

                // 최고 기록 표시 (애니메이션)
                if (bestRecord != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '최고 기록',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '레벨 ${bestRecord.level} | 점수 ${bestRecord.score}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: -0.2, end: 0, delay: 600.ms),
                const SizedBox(height: 40),

                // 새 게임 버튼 (모드 선택 → 시작)
                _MenuButton(
                  text: '새 게임',
                  icon: Icons.play_arrow,
                  onPressed: () async {
                    SoundManager().playSfx('sounds/button_click.mp3');
                    final mode = await showModeSelectSheet(context);
                    if (mode == null || !context.mounted) return;
                    context.read<GameProvider>().startNewGame(mode: mode);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 800.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 800.ms),
                const SizedBox(height: 16),

                // 이어하기 버튼 (저장된 게임이 있을 때만 표시)
                if (context.watch<GameProvider>().totalScore > 0 ||
                    context.watch<GameProvider>().currentLevel > 1)
                  _MenuButton(
                    text: '이어하기',
                    icon: Icons.refresh,
                    onPressed: () {
                      SoundManager().playSfx('sounds/button_click.mp3');
                      context.read<GameProvider>().continueGame();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 400.ms)
                      .slideX(begin: -0.3, end: 0, delay: 900.ms),
                const SizedBox(height: 16),

                // 최근 기록 버튼 (애니메이션)
                _MenuButton(
                  text: '최근 기록',
                  icon: Icons.history,
                  onPressed: () {
                    SoundManager().playSfx('sounds/button_click.mp3');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecordsScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 900.ms),
                const SizedBox(height: 16),

                // 랭킹 버튼 (애니메이션)
                _MenuButton(
                  text: '랭킹',
                  icon: Icons.leaderboard,
                  onPressed: () {
                    SoundManager().playSfx('sounds/button_click.mp3');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 950.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 950.ms),
                const SizedBox(height: 16),

                // 업적 버튼 (애니메이션)
                _MenuButton(
                  text: '업적',
                  icon: Icons.emoji_events,
                  onPressed: () {
                    SoundManager().playSfx('sounds/button_click.mp3');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AchievementsScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 975.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 975.ms),
                const SizedBox(height: 16),

                // 꾸미기(스킨) 버튼
                _MenuButton(
                  text: '꾸미기',
                  icon: Icons.palette,
                  onPressed: () {
                    SoundManager().playSfx('sounds/button_click.mp3');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SkinShopScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 990.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 990.ms),
                const SizedBox(height: 16),

                // 설정 버튼 (애니메이션)
                _MenuButton(
                  text: '설정',
                  icon: Icons.settings,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 1000.ms),
                const SizedBox(height: 16),

                // 나가기 버튼 (애니메이션)
                _MenuButton(
                  text: '나가기',
                  icon: Icons.exit_to_app,
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                )
                    .animate()
                    .fadeIn(delay: 1100.ms, duration: 400.ms)
                    .slideX(begin: -0.3, end: 0, delay: 1100.ms),
              ],
            ),
          ),
        ),
      ),

          // 우상단: 코인 잔액 + 일일 출석 버튼
          const Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: _CoinBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 메뉴 우상단 코인 잔액 + 출석 버튼
class _CoinBar extends StatelessWidget {
  const _CoinBar();

  @override
  Widget build(BuildContext context) {
    final cur = context.watch<CurrencyProvider>();
    final canCheckIn = cur.canCheckIn(DateTime.now());

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 코인 잔액
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.monetization_on, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text('${cur.coins}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // 출석 버튼 (받을 게 있으면 빨간 점 표시)
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: Colors.white.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  SoundManager().playSfx('sounds/button_click.mp3');
                  showDailyCheckInSheet(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.calendar_today,
                      color: Colors.green, size: 20),
                ),
              ),
            ),
            if (canCheckIn)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// 메뉴 버튼 위젯 (애니메이션 포함)
class _MenuButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 200,
          height: 60,
          child: ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.green.shade700,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 24),
                const SizedBox(width: 8),
                Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

