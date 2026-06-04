import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/game_provider.dart';
import '../providers/score_provider.dart';
import 'menu_screen.dart';
import 'game_screen.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/login_sheet.dart';
import '../utils/ad_manager.dart';
import '../utils/firebase_service.dart';
import '../utils/auth_service.dart';

/// 화려한 게임 오버 화면
class GameOverScreen extends StatefulWidget {
  final int survivalTime;

  const GameOverScreen({super.key, this.survivalTime = 0});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  /// 보상형광고로 점수 2배 보너스를 이미 받았는지 (1회 제한)
  bool _bonusClaimed = false;
  bool _bonusApplied = false;

  @override
  void initState() {
    super.initState();
    // 게임 오버 화면 진입 시 빈도 조건에 맞으면 전면광고 노출.
    // 위젯 트리가 완전히 그려진 뒤 호출해야 안전하다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdManager.instance.onGameOverMaybeShowInterstitial();
    });
  }

  /// 랭킹 등록 상태: 등록 완료 여부
  bool _rankSubmitted = false;

  /// 랭킹에 점수 등록. 비로그인 시 로그인 시트를 띄운 뒤 등록한다.
  Future<void> _registerToRanking(
      GameProvider gameProvider, ScoreProvider scoreProvider) async {
    var user = AuthService.instance.currentUser;

    // 비로그인 → 로그인 유도
    if (user == null) {
      final ok = await showLoginSheet(
        context,
        reason: '내 점수를 글로벌 랭킹에 등록하려면 로그인이 필요해요.',
      );
      if (!ok) return;
      user = AuthService.instance.currentUser;
      if (user == null) return;
    }

    final nick = scoreProvider.nickname.isNotEmpty
        ? scoreProvider.nickname
        : AuthService.instance.displayName;

    await FirebaseService.instance.submitScore(
      uid: user.uid,
      nickname: nick,
      score: gameProvider.totalScore,
      level: gameProvider.currentLevel,
    );

    if (!mounted) return;
    setState(() => _rankSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🏆 랭킹에 등록되었어요!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 보상형광고를 보고 점수 2배 보너스 받기
  void _watchAdForDoubleScore(GameProvider gameProvider) {
    final scoreProvider = context.read<ScoreProvider>();
    final shown = AdManager.instance.showRewarded(
      onReward: () {
        if (!mounted) return;
        setState(() {
          _bonusApplied = true;
          _bonusClaimed = true;
        });
        gameProvider.applyScoreBonus(2.0);
        // 직전 게임 기록에도 보너스 반영
        scoreProvider.applyBonusToLatest(2.0);
        FirebaseService.instance.logRewardedAdView();
      },
    );
    if (shown) {
      setState(() => _bonusClaimed = true); // 중복 노출 방지
    } else {
      // 광고 미준비: 사용자에게 알림
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('광고가 아직 준비되지 않았어요. 잠시 후 다시 시도해 주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final survivalTime = widget.survivalTime;
    final gameProvider = context.watch<GameProvider>();
    final scoreProvider = context.read<ScoreProvider>();
    final bestRecord = scoreProvider.bestRecord;
    final isNewBest = bestRecord == null || gameProvider.score >= bestRecord.score;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.red.shade800,
              Colors.red.shade400,
              Colors.orange.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 게임 오버 아이콘
                        Icon(
                          Icons.sentiment_dissatisfied_rounded,
                          size: 80,
                          color: Colors.white.withValues(alpha: 0.8),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .shake(delay: 400.ms, duration: 500.ms),
                        const SizedBox(height: 12),

                        // 게임 오버 텍스트
                        const Text(
                          'GAME OVER',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                            shadows: [
                              Shadow(offset: Offset(2, 2), blurRadius: 8, color: Colors.black38),
                              Shadow(offset: Offset(0, 0), blurRadius: 20, color: Colors.redAccent),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(delay: 200.ms, duration: 400.ms, begin: const Offset(0.5, 0.5)),

                        // 게임 오버 원인
                        if (gameProvider.gameOverReason.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  gameProvider.gameOverReason.contains('벽')
                                      ? Icons.border_outer
                                      : gameProvider.gameOverReason.contains('몸')
                                          ? Icons.rotate_left
                                          : Icons.block,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  gameProvider.gameOverReason,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 500.ms, duration: 400.ms),
                        ],

                        // 최고 기록 갱신 표시
                        if (isNewBest && gameProvider.score > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.yellow.shade600, Colors.amber.shade400],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.yellow.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emoji_events, color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'NEW BEST!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 800.ms, duration: 400.ms)
                              .shimmer(delay: 1200.ms, duration: 1500.ms),
                        ],
                        const SizedBox(height: 32),

                        // 스코어 카드들
                        _ResultCard(
                          icon: Icons.star_rounded,
                          label: '점수',
                          value: '${gameProvider.score}',
                          color: Colors.amber,
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3),
                        const SizedBox(height: 12),
                        _ResultCard(
                          icon: Icons.flag_rounded,
                          label: '도달 스테이지',
                          value: '${gameProvider.currentLevel}',
                          color: Colors.blue,
                        ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.3),
                        const SizedBox(height: 12),
                        _ResultCard(
                          icon: Icons.timer_rounded,
                          label: '생존 시간',
                          value: '$survivalTime초',
                          color: Colors.green,
                        ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),

                        // 이전 최고 기록 표시
                        if (bestRecord != null && !isNewBest) ...[
                          const SizedBox(height: 12),
                          Text(
                            '최고 기록: ${bestRecord.score}점 (스테이지 ${bestRecord.level})',
                            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
                          ).animate().fadeIn(delay: 700.ms),
                        ],

                        const SizedBox(height: 24),

                        // 보상형광고: 점수 2배 보너스 (점수가 있고 아직 안 받았을 때만)
                        if (gameProvider.score > 0 && !_bonusClaimed) ...[
                          SizedBox(
                            width: 240,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: () =>
                                  _watchAdForDoubleScore(gameProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade600,
                                foregroundColor: Colors.white,
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.play_circle_fill, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    '광고 보고 점수 2배!',
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 700.ms)
                              .shimmer(delay: 1100.ms, duration: 1500.ms),
                          const SizedBox(height: 14),
                        ],

                        // 보너스 적용 완료 표시
                        if (_bonusApplied) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('점수 2배 적용 완료!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],

                        // 랭킹 등록 버튼 (점수>0, 비로그인이거나 아직 미등록)
                        if (gameProvider.score > 0 &&
                            !_rankSubmitted &&
                            AuthService.instance.currentUser == null) ...[
                          SizedBox(
                            width: 240,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () => _registerToRanking(
                                  gameProvider, context.read<ScoreProvider>()),
                              icon: const Icon(Icons.leaderboard, size: 20),
                              label: const Text(
                                '로그인하고 랭킹 등록',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.7),
                                    width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 750.ms),
                          const SizedBox(height: 14),
                        ],

                        // 즉시 재시작 버튼 (강조)
                        SizedBox(
                          width: 220,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              gameProvider.quickRestart();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const GameScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red.shade700,
                              elevation: 8,
                              shadowColor: Colors.black38,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.replay_rounded, size: 24),
                                SizedBox(width: 8),
                                Text(
                                  '다시 시작',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 800.ms)
                            .scale(delay: 800.ms, duration: 300.ms, begin: const Offset(0.8, 0.8)),
                        const SizedBox(height: 14),

                        // 메인 메뉴 버튼
                        SizedBox(
                          width: 220,
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () {
                              gameProvider.returnToMenuAfterGameOver();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MenuScreen()),
                                (route) => false,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              '메인 메뉴',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ).animate().fadeIn(delay: 900.ms),
                      ],
                    ),
                  ),
                ),
              ),
              const BannerAdWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 결과 카드 위젯
class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final MaterialColor color;

  const _ResultCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.shade400.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7))),
              Text(value, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
