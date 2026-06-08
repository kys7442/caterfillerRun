import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/score_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/achievement_provider.dart';
import '../models/game_state.dart';
import '../models/score_record.dart';
import '../utils/sound_manager.dart';
import '../utils/vibration_helper.dart';
import '../utils/performance_monitor.dart';
import '../utils/firebase_service.dart';
import '../utils/auth_service.dart';
import 'countdown_screen.dart';
import 'game_over_screen.dart';
import 'level_up_screen.dart';
import '../widgets/game_board.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/eat_feedback.dart';
import '../widgets/special_food_intro.dart';
import '../models/food.dart';

/// 게임 플레이 화면
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _gameTimer;
  Timer? _survivalTimer;
  int _survivalTime = 0;
  final GlobalKey<GameBoardState> _gameBoardKey = GlobalKey();
  final SoundManager _soundManager = SoundManager();
  final VibrationHelper _vibrationHelper = VibrationHelper();
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  /// 먹이 획득 피드백 오버레이 위젯들 (점수 팝업/파티클). 완료 시 자동 제거.
  final List<Widget> _feedbackOverlays = [];
  int _feedbackKeySeq = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGameState();
      _startGameLoop();
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _survivalTimer?.cancel();
    _soundManager.pauseBgm();
    super.dispose();
  }

  void _checkGameState() {
    final gameProvider = context.read<GameProvider>();
    
    if (gameProvider.state == GameState.countdown) {
      // 카운트다운 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CountdownScreen(),
        ),
      );
    } else if (gameProvider.state == GameState.gameOver) {
      // 게임 오버 화면으로 이동
      _gameTimer?.cancel();
      _survivalTimer?.cancel();
      _saveRecord();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameOverScreen(survivalTime: _survivalTime),
        ),
      );
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _survivalTimer?.cancel();
    _survivalTime = 0;
    
    // 생존 시간 타이머
    _survivalTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _survivalTime++;
        });

        // 타임어택: 제한 시간 도달 시 종료
        final gp = context.read<GameProvider>();
        if (gp.mode == GameMode.timeAttack &&
            gp.state == GameState.playing &&
            _survivalTime >= gp.mode.timeLimitSec) {
          timer.cancel();
          gp.timeAttackFinished();
        }
      },
    );
    
    // 게임 업데이트 타이머
    _gameTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60 FPS
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        final gameProvider = context.read<GameProvider>();
        
        if (gameProvider.state == GameState.playing) {
          final size = MediaQuery.of(context).size;
          gameProvider.updateGame(size);

          // 먹이 획득 피드백 처리 (사운드/진동/팝업/파티클)
          _handleEatEvent(gameProvider);

          // 방패 방어 피드백 (묵직한 방어음 + 진동)
          if (gameProvider.consumeShieldBlock()) {
            _soundManager.playSfx('sounds/shield.mp3');
            _vibrationHelper.heavyImpact();
          }

          // 성능 모니터링 (디버그 모드에서만)
          _performanceMonitor.updateFrame();
          
          // UI 업데이트는 Consumer가 자동으로 처리
          // 게임 보드와 상단 UI가 gameProvider를 watch하므로 자동 업데이트됨
          
          // 레벨 업 체크
          if (gameProvider.isLevelingUp) {
            timer.cancel();
            _soundManager.playSfx('sounds/level_up.mp3');
            _vibrationHelper.mediumImpact();
            FirebaseService.instance.logLevelUp(gameProvider.currentLevel);
            _showLevelUpScreen(gameProvider);
            return;
          }
          
          // 게임 오버 체크
          if (gameProvider.state == GameState.gameOver) {
            timer.cancel();
            _survivalTimer?.cancel();
            _soundManager.stopBgm();
            _soundManager.playSfx('sounds/game_over.mp3');
            _vibrationHelper.heavyImpact();
            _saveRecord();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => GameOverScreen(survivalTime: _survivalTime),
              ),
            );
          }
        } else if (gameProvider.state != GameState.paused) {
          timer.cancel();
          _survivalTimer?.cancel();
        }
      },
    );
  }

  /// 먹이 획득 이벤트를 소비해 사운드/진동/시각 피드백을 트리거한다.
  void _handleEatEvent(GameProvider gameProvider) {
    final event = gameProvider.consumeEatEvent();
    if (event == null) return;

    // 사운드: 특수먹이 > 콤보 > 일반먹이 우선순위로 재생
    final String sfx;
    if (event.isSpecial) {
      sfx = 'sounds/special.mp3';
    } else if (event.isCombo) {
      sfx = 'sounds/combo.mp3';
    } else {
      sfx = 'sounds/eat.mp3';
    }
    _soundManager.playSfx(sfx);

    // 진동: 콤보일수록 강하게
    if (event.comboMultiplier >= 2.0) {
      _vibrationHelper.mediumImpact();
    } else {
      _vibrationHelper.lightImpact();
    }

    // 시각: 점수 팝업 + 파티클 (애니메이션 완료 시 자동 제거)
    final popupKey = ValueKey('popup_${_feedbackKeySeq++}');
    final burstKey = ValueKey('burst_${_feedbackKeySeq++}');

    late final Widget popup;
    late final Widget burst;
    popup = ScorePopup(
      key: popupKey,
      position: event.position,
      points: event.points,
      comboMultiplier: event.comboMultiplier,
      onDone: () {
        if (mounted) setState(() => _feedbackOverlays.remove(popup));
      },
    );
    burst = ParticleBurst(
      key: burstKey,
      position: event.position,
      color: event.isCombo ? Colors.amber : Colors.lightGreenAccent,
      onDone: () {
        if (mounted) setState(() => _feedbackOverlays.remove(burst));
      },
    );

    setState(() {
      _feedbackOverlays.add(burst);
      _feedbackOverlays.add(popup);
    });

    // 특수 먹이를 '생애 최초'로 먹었으면 안내 팝업으로 짧게 멈춰 설명한다.
    if (event.isSpecial) {
      _maybeShowSpecialIntro(gameProvider, event.foodType);
    }
  }

  /// 처음 보는 특수 먹이면 게임을 잠시 멈추고 안내 팝업을 띄운다.
  /// (이미 본 종류면 아무것도 하지 않는다 — 종류별 최초 1회)
  Future<void> _maybeShowSpecialIntro(
      GameProvider gameProvider, FoodType type) async {
    if (await SpecialFoodIntro.hasSeen(type)) return;
    if (!mounted || gameProvider.state != GameState.playing) return;

    // 게임 루프를 멈추고 일시정지 → 닫으면 재개 (레벨업 다이얼로그와 동일 패턴)
    _gameTimer?.cancel();
    _gameTimer = null;
    gameProvider.pause();
    await SpecialFoodIntro.markSeen(type);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => SpecialFoodIntroDialog(type: type),
    );

    if (!mounted) return;
    // 팝업을 보는 사이 다른 흐름(게임오버/메뉴 이동 등)으로 빠졌으면 재개하지 않는다.
    if (gameProvider.state == GameState.paused) {
      gameProvider.resume();
      _startGameLoop();
    }
  }

  void _saveRecord() {
    final gameProvider = context.read<GameProvider>();
    final scoreProvider = context.read<ScoreProvider>();
    
    final record = ScoreRecord(
      score: gameProvider.totalScore,
      level: gameProvider.currentLevel,
      survivalTime: _survivalTime,
      timestamp: DateTime.now(),
    );

    scoreProvider.saveRecord(record);

    // 점수를 코인으로 환산해 적립 (스킨 언락 재화)
    context.read<CurrencyProvider>().awardFromScore(gameProvider.totalScore);

    // 업적 통계 기록 + 달성 판정 (달성 시 코인 보상 자동 지급)
    context.read<AchievementProvider>().recordGameResult(
          score: gameProvider.totalScore,
          level: gameProvider.currentLevel,
          maxCombo: gameProvider.maxComboThisGame,
          foodEaten: gameProvider.totalFoodEatenThisGame,
        );

    // 분석 이벤트 (Firebase 미설정 시 자동 no-op)
    FirebaseService.instance.logGameOver(
      score: gameProvider.totalScore,
      level: gameProvider.currentLevel,
      reason: gameProvider.gameOverReason,
      survivalTime: _survivalTime,
    );

    // 랭킹 등록은 '로그인 회원'만 자동 제출. 비회원은 게임오버 화면에서
    // '로그인하고 랭킹 등록' 버튼으로 유도한다.
    final user = AuthService.instance.currentUser;
    if (user != null) {
      FirebaseService.instance.submitScore(
        uid: user.uid,
        nickname: scoreProvider.nickname.isNotEmpty
            ? scoreProvider.nickname
            : AuthService.instance.displayName,
        score: gameProvider.totalScore,
        level: gameProvider.currentLevel,
      );
    }
  }

  Future<void> _showLevelUpScreen(GameProvider gameProvider) async {
    if (!mounted) return;

    final continueGame = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpScreen(
        newLevel: gameProvider.currentLevel,
        totalScore: gameProvider.totalScore,
      ),
    );
    if (!mounted) return;

    // '여기서 그만두기'(false) → 기록 저장 후 메인 메뉴로 나간다.
    if (continueGame == false) {
      _gameTimer?.cancel();
      _survivalTimer?.cancel();
      _soundManager.stopBgm();
      _saveRecord();
      gameProvider.returnToMenu();
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    // 계속하기 → 다음 스테이지 진행
    gameProvider.levelUpComplete();
    _startGameLoop();
  }


  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    
    // 게임 상태에 따라 다른 화면 표시
    if (gameProvider.state == GameState.countdown) {
      return const CountdownScreen();
    } else if (gameProvider.state == GameState.gameOver) {
      return const GameOverScreen();
    }

        // 게임이 시작되면 루프 시작 및 배경음악 재생
        if (gameProvider.state == GameState.playing && 
            !gameProvider.isLevelingUp && 
            _gameTimer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _startGameLoop();
            _soundManager.playBgm('sounds/bgm.mp3');
          });
        }
        
        // 카운트다운 화면 표시
        if (gameProvider.state == GameState.countdown) {
          return const CountdownScreen();
        }

    // 하단 배너 높이만큼 게임 영역을 비워 배너와 겹치지 않게 한다.
    const double bannerHeight = 60;

    return Scaffold(
          body: Stack(
            children: [
              // 게임 보드 (하단 배너 영역 제외 → 터치 우발 클릭/시야 침범 방지)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: bannerHeight,
                child: GameBoard(key: _gameBoardKey),
              ),

              // 먹이 획득 피드백 (점수 팝업 + 파티클)
              ..._feedbackOverlays,

              // 상단 UI (점수, 레벨) - RepaintBoundary로 최적화
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: RepaintBoundary(
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                        _InfoCard(
                          key: ValueKey('score_${gameProvider.totalScore}'),
                          icon: Icons.star,
                          label: '점수',
                          value: gameProvider.totalScore.toString(),
                        ),
                        // 레벨 (스테이지/무한 모드만)
                        if (gameProvider.mode != GameMode.timeAttack)
                          _InfoCard(
                            key: ValueKey('level_${gameProvider.currentLevel}'),
                            icon: Icons.flag,
                            label: '레벨',
                            value: gameProvider.currentLevel.toString(),
                          ),
                        // 먹이: 스테이지=진행도, 그 외=먹은 개수
                        _InfoCard(
                          key: ValueKey('food_${gameProvider.eatenFoodCount}'),
                          icon: Icons.eco,
                          label: '먹이',
                          value: gameProvider.mode == GameMode.stage
                              ? '${gameProvider.eatenFoodCount}/${gameProvider.stageFoodTarget}'
                              : '${gameProvider.eatenFoodCount}',
                        ),
                        // 시간: 타임어택=남은시간, 그 외=경과시간
                        _InfoCard(
                          key: ValueKey('time_$_survivalTime'),
                          icon: gameProvider.mode == GameMode.timeAttack
                              ? Icons.hourglass_bottom
                              : Icons.timer,
                          label: gameProvider.mode == GameMode.timeAttack
                              ? '남은시간'
                              : '시간',
                          value: gameProvider.mode == GameMode.timeAttack
                              ? '${(gameProvider.mode.timeLimitSec - _survivalTime).clamp(0, 999)}초'
                              : '$_survivalTime초',
                        ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 활성 파워업 효과 배지 (HUD 아래)
              Positioned(
                top: MediaQuery.of(context).padding.top + 78,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (gameProvider.hasShield)
                        const _PowerupBadge(
                          icon: Icons.shield,
                          color: Colors.blueAccent,
                          label: '방패',
                        ),
                      if (gameProvider.isDoubleScoreActive)
                        _PowerupBadge(
                          icon: Icons.bolt,
                          color: Colors.purpleAccent,
                          label: '2배 ${gameProvider.doubleScoreSecondsLeft}s',
                        ),
                      if (gameProvider.isSlowActive)
                        _PowerupBadge(
                          icon: Icons.hourglass_bottom,
                          color: Colors.lightBlue,
                          label: '슬로우 ${gameProvider.slowSecondsLeft}s',
                        ),
                    ],
                  ),
                ),
              ),

              // 콤보 텍스트
              if (gameProvider.comboText != null)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.red.shade400],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Text(
                        gameProvider.comboText!,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),

              // 벽 근접 경고 효과
              if (gameProvider.caterpillar.isNotEmpty) ...[
                // 상단 경고
                if (gameProvider.caterpillar[0].dy < 50)
                  Positioned(
                    top: 0, left: 0, right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.red.withValues(alpha: 0.7), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                // 하단 경고
                if (gameProvider.caterpillar[0].dy > MediaQuery.of(context).size.height - 50)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.red.withValues(alpha: 0.7), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                // 왼쪽 경고
                if (gameProvider.caterpillar[0].dx < 50)
                  Positioned(
                    top: 0, bottom: 0, left: 0,
                    child: Container(
                      width: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.red.withValues(alpha: 0.7), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                // 오른쪽 경고
                if (gameProvider.caterpillar[0].dx > MediaQuery.of(context).size.width - 50)
                  Positioned(
                    top: 0, bottom: 0, right: 0,
                    child: Container(
                      width: 8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerRight,
                          end: Alignment.centerLeft,
                          colors: [Colors.red.withValues(alpha: 0.7), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
              ],

              // 일시정지 버튼
              Positioned(
                top: 60,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.pause, color: Colors.white),
                  onPressed: () {
                    gameProvider.pause();
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => _PauseDialog(),
                    );
                  },
                ),
              ),

              // 하단 광고 (게임 영역과 분리된 전용 영역 → 우발 터치 방지)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: bannerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.85),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  child: const BannerAdWidget(),
                ),
              ),
            ],
          ),
        );
  }
}

/// 활성 파워업 효과 배지
class _PowerupBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _PowerupBadge({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 정보 카드 위젯
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// 일시정지 다이얼로그
class _PauseDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '일시정지',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                gameProvider.resume();
                Navigator.of(context).pop();
              },
              child: const Text('계속하기'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                gameProvider.returnToMenu();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('메인 메뉴로'),
            ),
          ],
        ),
      ),
    );
  }
}

