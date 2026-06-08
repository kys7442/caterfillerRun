import 'package:flutter/material.dart';
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
import '../widgets/festive_background.dart';
import '../widgets/caterpillar_mascot.dart';

/// 메인 메뉴 화면
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scoreProvider = Provider.of<ScoreProvider>(context);
    final bestRecord = scoreProvider.bestRecord;
    final gp = context.watch<GameProvider>();
    final hasSaved = gp.totalScore > 0 || gp.currentLevel > 1;

    return Scaffold(
      body: Stack(
        children: [
          // 1) 화려한 정적 배경 (하늘·구름·별빛·깃발)
          const Positioned.fill(child: FestiveBackground()),

          // 2) 메인 콘텐츠
          SafeArea(
            child: Column(
              children: [
                // 상단 우측: 코인 + 출석
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _CoinBar(),
                  ),
                ),

                // 중앙: 마스코트 + 타이틀 + 최고기록
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CaterpillarMascot(size: 170)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                      const SizedBox(height: 8),
                      _buildTitleLogo()
                          .animate()
                          .fadeIn(delay: 250.ms, duration: 500.ms)
                          .slideY(begin: 0.25, end: 0, delay: 250.ms),
                      const SizedBox(height: 14),
                      if (bestRecord != null)
                        _buildBestRecord(bestRecord.level, bestRecord.score)
                            .animate()
                            .fadeIn(delay: 500.ms, duration: 500.ms),
                    ],
                  ),
                ),

                // 하단: 큰 PLAY 버튼 + 보조 메뉴 아이콘 줄
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 18),
                  child: Column(
                    children: [
                      _buildPlayButton(context, hasSaved)
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 400.ms)
                          .slideY(begin: 0.4, end: 0, delay: 600.ms),
                      const SizedBox(height: 18),
                      _buildSecondaryRow(context)
                          .animate()
                          .fadeIn(delay: 750.ms, duration: 400.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 화려한 타이틀 로고 (입체 텍스트 + 부제 리본 느낌).
  Widget _buildTitleLogo() {
    return Column(
      children: [
        // 메인 타이틀 — 두 줄로 나눠 시원하게 (외곽선 + 노랑 채움 입체)
        _outlinedText('애벌레야!', 44),
        const SizedBox(height: 2),
        _outlinedText('어디가?', 44),
        const SizedBox(height: 8),
        // 부제 리본
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB74D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE69500), width: 2),
          ),
          child: const Text(
            'Caterpillar Run',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// 외곽선(보라) + 노랑 채움으로 입체감 있는 타이틀 글자.
  Widget _outlinedText(String text, double size) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..color = const Color(0xFF5B2A86),
          ),
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 44,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            color: Color(0xFFFFD54F),
            shadows: [
              Shadow(offset: Offset(0, 3), color: Color(0xFFE69500)),
            ],
          ).copyWith(fontSize: size),
        ),
      ],
    );
  }

  Widget _buildBestRecord(int level, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
          const SizedBox(width: 8),
          Text(
            '최고  레벨 $level · $score점',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
            ),
          ),
        ],
      ),
    );
  }

  /// 큰 PLAY 버튼 (저장된 게임이 있으면 이어하기, 없으면 모드 선택).
  Widget _buildPlayButton(BuildContext context, bool hasSaved) {
    return _BigPlayButton(
      onTap: () async {
        SoundManager().playSfx('sounds/button_click.mp3');
        final mode = await showModeSelectSheet(context);
        if (mode == null || !context.mounted) return;
        context.read<GameProvider>().startNewGame(mode: mode);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      },
      onContinue: hasSaved
          ? () {
              SoundManager().playSfx('sounds/button_click.mp3');
              context.read<GameProvider>().continueGame();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameScreen()),
              );
            }
          : null,
    );
  }

  /// 보조 메뉴 아이콘 줄 (기록·랭킹·업적·꾸미기·설정).
  Widget _buildSecondaryRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _CircleIconButton(
          icon: Icons.history_rounded,
          label: '기록',
          onTap: () {
            SoundManager().playSfx('sounds/button_click.mp3');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RecordsScreen()));
          },
        ),
        _CircleIconButton(
          icon: Icons.leaderboard_rounded,
          label: '랭킹',
          onTap: () {
            SoundManager().playSfx('sounds/button_click.mp3');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
          },
        ),
        _CircleIconButton(
          icon: Icons.emoji_events_rounded,
          label: '업적',
          onTap: () {
            SoundManager().playSfx('sounds/button_click.mp3');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AchievementsScreen()));
          },
        ),
        _CircleIconButton(
          icon: Icons.palette_rounded,
          label: '꾸미기',
          onTap: () {
            SoundManager().playSfx('sounds/button_click.mp3');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SkinShopScreen()));
          },
        ),
        _CircleIconButton(
          icon: Icons.settings_rounded,
          label: '설정',
          onTap: () {
            SoundManager().playSfx('sounds/button_click.mp3');
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
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

/// 큰 PLAY 버튼. 저장된 게임이 있으면 위에 작은 '이어하기'가 함께 뜬다.
class _BigPlayButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback? onContinue;

  const _BigPlayButton({required this.onTap, this.onContinue});

  @override
  State<_BigPlayButton> createState() => _BigPlayButtonState();
}

class _BigPlayButtonState extends State<_BigPlayButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 이어하기 (저장된 게임이 있을 때만)
        if (widget.onContinue != null) ...[
          GestureDetector(
            onTap: widget.onContinue,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4FC3F7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 3)),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 6),
                  Text('이어하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // 큰 PLAY 버튼
        GestureDetector(
          onTapDown: (_) => _c.forward(),
          onTapUp: (_) {
            _c.reverse();
            widget.onTap();
          },
          onTapCancel: () => _c.reverse(),
          child: ScaleTransition(
            scale: _scale,
            child: Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFF7BAC), Color(0xFFF0568E)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 10,
                      offset: Offset(0, 5)),
                ],
              ),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 30),
                    SizedBox(width: 6),
                    Text(
                      'PLAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 2,
                              color: Color(0x66000000)),
                        ],
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
  }
}

/// 하단 보조 메뉴용 원형 아이콘 버튼 + 라벨.
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 6,
                    offset: Offset(0, 3)),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32), size: 26),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
            ),
          ),
        ],
      ),
    );
  }
}


