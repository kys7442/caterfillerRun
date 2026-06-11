import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../models/game_state.dart';
import '../models/level_config.dart';
import '../models/obstacle.dart';
import '../models/food.dart';
import '../models/eat_event.dart';

/// 게임 상태 관리 Provider
class GameProvider extends ChangeNotifier {
  GameState _state = GameState.menu;
  GameMode _mode = GameMode.stage;
  int _currentLevel = 1;
  int _totalScore = 0;
  int _currentLevelScore = 0;
  List<Offset> _caterpillar = [];
  List<Obstacle> _obstacles = [];
  List<Food> _foods = [];
  LevelConfig? _levelConfig;
  bool _isLevelingUp = false;

  // 터치 기반 이동
  Offset? _targetPosition;
  Offset _currentDirection = Offset(0, 0);
  bool _hasStartedMoving = false;
  int _safeFrames = 0;

  // 길이 증가
  bool _shouldGrow = false;
  static const int _maxSegments = 28;
  int _growGraceFrames = 0; // 길이 증가 후 충돌 감지 유예 프레임

  // 스테이지 클리어 관련
  int _eatenFoodCount = 0;
  int _stageFoodTarget = 0;

  // 콤보 시스템
  int _comboCount = 0;
  int _maxComboThisGame = 0; // 이번 판 최고 콤보 (업적용)
  int _totalFoodEatenThisGame = 0; // 이번 판 총 먹은 먹이 수 (업적용)
  DateTime? _lastEatTime;
  double _comboMultiplier = 1.0;
  String? _comboText;

  int get maxComboThisGame => _maxComboThisGame;
  int get totalFoodEatenThisGame => _totalFoodEatenThisGame;

  // 특수 먹이(파워업) 효과 상태
  bool _hasShield = false; // 방패: 다음 충돌 1회 무효
  int _slowFramesLeft = 0; // 슬로우: 남은 프레임 동안 속도 감소
  int _doubleScoreFramesLeft = 0; // 더블점수: 남은 프레임 동안 점수 2배
  static const int _slowDurationFrames = 300; // 약 5초
  static const int _doubleScoreDurationFrames = 360; // 약 6초

  bool get hasShield => _hasShield;
  bool get isSlowActive => _slowFramesLeft > 0;
  bool get isDoubleScoreActive => _doubleScoreFramesLeft > 0;
  int get slowSecondsLeft => (_slowFramesLeft / 60).ceil();
  int get doubleScoreSecondsLeft => (_doubleScoreFramesLeft / 60).ceil();

  /// 특수 효과 전체 초기화 (게임 시작/재시작/스테이지 전환 시)
  void _resetPowerups() {
    _hasShield = false;
    _slowFramesLeft = 0;
    _doubleScoreFramesLeft = 0;
  }

  // 프레임 카운터 (애니메이션용)
  int _frameCount = 0;

  Size? _screenSize;
  double _gameAreaTop = 0;
  double _gameAreaBottom = 0;
  String _gameOverReason = '';
  int _savedSegmentCount = 3; // 저장된 세그먼트 수

  // Getters
  GameState get state => _state;
  GameMode get mode => _mode;
  int get currentLevel => _currentLevel;
  int get totalScore => _totalScore;
  int get currentLevelScore => _currentLevelScore;
  List<Offset> get caterpillar => _caterpillar;
  List<Obstacle> get obstacles => _obstacles;
  List<Food> get foods => _foods;
  LevelConfig? get levelConfig => _levelConfig;
  bool get isLevelingUp => _isLevelingUp;
  int get score => _totalScore;
  int get eatenFoodCount => _eatenFoodCount;
  int get stageFoodTarget => _stageFoodTarget;
  Offset get currentDirection => _currentDirection;
  int get comboCount => _comboCount;
  double get comboMultiplier => _comboMultiplier;
  String? get comboText => _comboText;
  int get frameCount => _frameCount;
  double get gameAreaTop => _gameAreaTop;
  String get gameOverReason => _gameOverReason;

  /// 먹이 획득 피드백 이벤트 (UI가 소비하여 사운드/진동/파티클 트리거).
  /// 한 번 읽으면 null로 비워진다(중복 처리 방지).
  EatEvent? _pendingEatEvent;
  EatEvent? consumeEatEvent() {
    final e = _pendingEatEvent;
    _pendingEatEvent = null;
    return e;
  }

  /// 방패로 죽음을 막은 순간 1회 true가 되는 이벤트 (UI가 사운드 재생).
  bool _pendingShieldBlock = false;
  bool consumeShieldBlock() {
    final v = _pendingShieldBlock;
    _pendingShieldBlock = false;
    return v;
  }

  GameProvider() {
    _loadGameState();
  }

  Future<void> _loadGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLevel = prefs.getInt('saved_level') ?? 1;
      _totalScore = prefs.getInt('saved_score') ?? 0;
      _savedSegmentCount = prefs.getInt('saved_segments') ?? 3;
      _levelConfig = LevelConfig.getLevelConfig(_currentLevel);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading game state: $e');
    }
  }

  Future<void> _saveGameState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('saved_level', _currentLevel);
      await prefs.setInt('saved_score', _totalScore);
      await prefs.setInt('saved_segments', _caterpillar.isNotEmpty ? _caterpillar.length : _savedSegmentCount);
    } catch (e) {
      debugPrint('Error saving game state: $e');
    }
  }

  Future<void> _clearSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_level');
      await prefs.remove('saved_score');
      await prefs.remove('saved_segments');
    } catch (e) {
      debugPrint('Error clearing saved progress: $e');
    }
  }

  /// 새 게임 시작 (모드 지정 가능, 기본 스테이지)
  void startNewGame({GameMode mode = GameMode.stage}) {
    _mode = mode;
    _state = GameState.countdown;
    _currentLevel = 1;
    _totalScore = 0;
    _currentLevelScore = 0;
    _targetPosition = null;
    _currentDirection = Offset(0, 0);
    _hasStartedMoving = false;
    _safeFrames = 0;
    _shouldGrow = false;
    _eatenFoodCount = 0;
    _comboCount = 0;
    _comboMultiplier = 1.0;
    _comboText = null;
    _caterpillar = [];
    _savedSegmentCount = 3;
    _levelConfig = LevelConfig.getLevelConfig(_currentLevel);
    _saveGameState();
    notifyListeners();
  }

  /// 즉시 재시작
  void quickRestart() {
    startNewGame();
  }

  /// 이어하기 (앱 재시작 시)
  void continueGame() {
    _state = GameState.countdown;
    _currentLevelScore = 0;
    _targetPosition = null;
    _currentDirection = Offset(0, 0);
    _hasStartedMoving = false;
    _safeFrames = 0;
    _shouldGrow = false;
    _eatenFoodCount = 0;
    _comboCount = 0;
    _comboMultiplier = 1.0;
    _comboText = null;
    _levelConfig = LevelConfig.getLevelConfig(_currentLevel);
    notifyListeners();
  }

  /// 카운트다운 완료 후 게임 시작
  void beginPlaying(Size screenSize, {double topInset = 0, double bottomInset = 0}) {
    _state = GameState.playing;
    _isLevelingUp = false;
    _screenSize = screenSize;
    _gameAreaTop = topInset;
    _gameAreaBottom = screenSize.height - bottomInset;
    _hasStartedMoving = false;
    _currentDirection = Offset(0, 0);
    _targetPosition = null;
    _safeFrames = 60;
    _shouldGrow = false;
    _eatenFoodCount = 0;
    _comboCount = 0;
    _maxComboThisGame = 0;
    _totalFoodEatenThisGame = 0;
    _comboMultiplier = 1.0;
    _comboText = null;
    _frameCount = 0;
    _resetPowerups();

    _resetCaterpillarPosition(screenSize);
    _generateObstacles(screenSize);
    _initStage(screenSize);
    notifyListeners();
  }

  /// 애벌레 위치 리셋 (길이 유지, 위치만 중앙으로)
  void _resetCaterpillarPosition(Size screenSize) {
    const margin = 50.0;
    const segmentDistance = 25.0;
    final centerX = screenSize.width / 2;
    final centerY = (_gameAreaTop + _gameAreaBottom) / 2;
    final safeX = centerX.clamp(margin + segmentDistance * 4, screenSize.width - margin);
    final safeY = centerY.clamp(_gameAreaTop + margin, _gameAreaBottom - margin);

    if (_caterpillar.isEmpty) {
      // 저장된 세그먼트 수 또는 기본 3개로 시작
      final segmentCount = _savedSegmentCount.clamp(3, _maxSegments);
      _caterpillar = List.generate(segmentCount, (i) {
        return Offset(safeX - segmentDistance * i, safeY);
      });
    } else {
      final segmentCount = _caterpillar.length;
      _caterpillar = List.generate(segmentCount, (i) {
        return Offset(safeX - segmentDistance * i, safeY);
      });
    }
  }

  /// 스테이지 초기화 (먹이 1개만 스폰)
  void _initStage(Size screenSize) {
    _foods = [];
    // 스테이지 모드만 목표 먹이 개수 제한, 그 외는 무제한(큰 값)
    _stageFoodTarget =
        _mode == GameMode.stage ? (_levelConfig?.foodCount ?? 1) : 999999;
    _eatenFoodCount = 0;
    _spawnSingleFood(screenSize);
  }

  /// 먹이 1개 랜덤 스폰
  void _spawnSingleFood(Size screenSize) {
    final random = Random();
    int attempts = 0;
    Offset? position;

    while (attempts < 100) {
      attempts++;
      final candidate = Offset(
        random.nextDouble() * (screenSize.width - 60) + 30,
        _gameAreaTop + 30 + random.nextDouble() * (_gameAreaBottom - _gameAreaTop - 60),
      );

      // 애벌레 전체 세그먼트와 거리 체크
      bool overlapsBody = false;
      for (final seg in _caterpillar) {
        final dx = candidate.dx - seg.dx;
        final dy = candidate.dy - seg.dy;
        if (dx * dx + dy * dy < 40 * 40) {
          overlapsBody = true;
          break;
        }
      }
      if (overlapsBody) continue;

      // 장애물과 거리 체크
      bool overlapsObstacle = false;
      for (final obs in _obstacles) {
        final dx = candidate.dx - obs.position.dx;
        final dy = candidate.dy - obs.position.dy;
        if (dx * dx + dy * dy < 40 * 40) {
          overlapsObstacle = true;
          break;
        }
      }
      if (overlapsObstacle) continue;

      position = candidate;
      break;
    }

    if (position != null) {
      _foods.add(Food(position: position, type: _rollFoodType(random)));
    }
  }

  /// 특수 먹이 효과 적용
  void _applyFoodEffect(FoodType type) {
    switch (type) {
      case FoodType.shield:
        _hasShield = true;
        break;
      case FoodType.slow:
        _slowFramesLeft = _slowDurationFrames;
        break;
      case FoodType.doubleScore:
        _doubleScoreFramesLeft = _doubleScoreDurationFrames;
        break;
      case FoodType.gold:
      case FoodType.normal:
        break; // 점수는 food.points로 처리
    }
  }

  /// 확률적으로 특수 먹이 타입을 결정한다.
  /// 일반 먹이가 대부분이며, 레벨 3부터 특수 먹이가 가끔 등장한다.
  FoodType _rollFoodType(Random random) {
    if (_currentLevel < 3) return FoodType.normal;

    final roll = random.nextInt(100);
    // 합계 약 22% 특수, 78% 일반
    if (roll < 8) return FoodType.gold; // 8%
    if (roll < 13) return FoodType.doubleScore; // 5%
    if (roll < 18) return FoodType.slow; // 5%
    if (roll < 22) return FoodType.shield; // 4%
    return FoodType.normal;
  }

  /// 장애물 생성
  void _generateObstacles(Size screenSize) {
    _obstacles = [];
    final count = _levelConfig?.obstacleCount ?? 0;
    if (count == 0) return;

    const safeRadius = 100.0;
    final gameAreaHeight = _gameAreaBottom - _gameAreaTop;
    final safeCenter = Offset(screenSize.width / 2, _gameAreaTop + gameAreaHeight / 2);
    final random = Random();
    int attempts = 0;
    int maxAttempts = count * 15;

    while (_obstacles.length < count && attempts < maxAttempts) {
      attempts++;
      final position = Offset(
        random.nextDouble() * (screenSize.width - 40) + 20,
        _gameAreaTop + 20 + random.nextDouble() * (gameAreaHeight - 40),
      );

      final dx = position.dx - safeCenter.dx;
      final dy = position.dy - safeCenter.dy;
      if (dx * dx + dy * dy < safeRadius * safeRadius) continue;

      bool tooClose = false;
      for (final obstacle in _obstacles) {
        final obsDx = position.dx - obstacle.position.dx;
        final obsDy = position.dy - obstacle.position.dy;
        if (obsDx * obsDx + obsDy * obsDy < 60 * 60) {
          tooClose = true;
          break;
        }
      }
      if (!tooClose) {
        _obstacles.add(Obstacle(position: position));
      }
    }
  }

  /// 터치 좌표 설정
  void setTargetPosition(Offset target) {
    if (_state != GameState.playing) return;
    if (_screenSize != null) {
      if (target.dx < 0 || target.dx > _screenSize!.width ||
          target.dy < _gameAreaTop || target.dy > _gameAreaBottom) {
        return;
      }
    }

    _targetPosition = target;
    _hasStartedMoving = true;

    if (_caterpillar.isNotEmpty) {
      final head = _caterpillar[0];
      final dx = target.dx - head.dx;
      final dy = target.dy - head.dy;
      final distance = sqrt(dx * dx + dy * dy);
      if (distance > 0) {
        _currentDirection = Offset(dx / distance, dy / distance);
      }
    }
    notifyListeners();
  }

  /// 게임 업데이트 (매 프레임)
  void updateGame(Size screenSize) {
    if (_state != GameState.playing) return;
    if (_caterpillar.isEmpty) return;
    if (!_hasStartedMoving) return;

    _frameCount++;

    if (_safeFrames > 0) _safeFrames--;

    // 특수 효과 지속시간 감소
    if (_slowFramesLeft > 0) _slowFramesLeft--;
    if (_doubleScoreFramesLeft > 0) _doubleScoreFramesLeft--;

    // 콤보 텍스트 자동 해제 (30프레임 후)
    if (_comboText != null && _frameCount % 30 == 0) {
      _comboText = null;
    }

    final head = _caterpillar[0];
    // 슬로우 효과 활성 시 속도 60%로 감소
    final slowFactor = isSlowActive ? 0.6 : 1.0;
    final speed = (_levelConfig?.speed ?? 75) * 0.016 * slowFactor;

    Offset newHead;
    if (_targetPosition != null) {
      final dx = _targetPosition!.dx - head.dx;
      final dy = _targetPosition!.dy - head.dy;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < speed) {
        newHead = _targetPosition!;
        _targetPosition = null;
      } else {
        newHead = Offset(
          head.dx + _currentDirection.dx * speed,
          head.dy + _currentDirection.dy * speed,
        );
      }
    } else {
      if (_currentDirection.dx == 0 && _currentDirection.dy == 0) return;
      newHead = Offset(
        head.dx + _currentDirection.dx * speed,
        head.dy + _currentDirection.dy * speed,
      );
    }

    // 이동: 세그먼트 체인 방식 (일정 간격 유지)
    // 먼저 머리를 옮기고 몸통을 따라오게 한 뒤, 모든 세그먼트에 대해 충돌을 검사한다.
    _caterpillar[0] = newHead;

    const segmentDistance = 20.0;
    for (int i = 1; i < _caterpillar.length; i++) {
      final prev = _caterpillar[i - 1];
      final curr = _caterpillar[i];
      final dx = prev.dx - curr.dx;
      final dy = prev.dy - curr.dy;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist > segmentDistance) {
        final ratio = segmentDistance / dist;
        _caterpillar[i] = Offset(
          prev.dx - dx * ratio,
          prev.dy - dy * ratio,
        );
      }
    }

    // 길이 증가: 꼬리 끝에 새 세그먼트 추가
    if (_shouldGrow) {
      _shouldGrow = false;
      _caterpillar.add(_caterpillar.last);
    }

    // 벽 충돌 — 머리뿐 아니라 몸통 어느 세그먼트라도 게임 영역을 벗어나면 게임 오버.
    if (_checkWallCollision()) {
      gameOver('벽에 부딪혔습니다!');
      return;
    }

    // 장애물/자기 몸 충돌 감지
    final collision = _checkCollision();
    if (collision != null) {
      if (collision == '꼬리 충돌') {
        gameOver('자신의 몸에 부딪혔습니다!');
      } else {
        gameOver('장애물에 부딪혔습니다!');
      }
      return;
    }

    // 먹이 충돌
    _checkFoodCollision();

    notifyListeners();
  }

  /// 먹이 충돌 감지
  void _checkFoodCollision() {
    if (_caterpillar.isEmpty) return;
    final head = _caterpillar[0];
    const headRadius = 10.0;

    bool ate = false;
    _foods.removeWhere((food) {
      if (food.checkCollision(head, headRadius)) {
        // 콤보 판정
        final now = DateTime.now();
        if (_lastEatTime != null && now.difference(_lastEatTime!).inMilliseconds < 3000) {
          _comboCount++;
        } else {
          _comboCount = 1;
        }
        if (_comboCount > _maxComboThisGame) _maxComboThisGame = _comboCount;
        _lastEatTime = now;

        if (_comboCount >= 4) {
          _comboMultiplier = 3.0;
          _comboText = 'COMBO x3!';
        } else if (_comboCount >= 3) {
          _comboMultiplier = 2.0;
          _comboText = 'COMBO x2!';
        } else if (_comboCount >= 2) {
          _comboMultiplier = 1.5;
          _comboText = 'COMBO x1.5!';
        } else {
          _comboMultiplier = 1.0;
          _comboText = null;
        }

        // 특수 먹이 효과 적용
        _applyFoodEffect(food.type);

        // 더블점수 효과가 활성화면 점수 추가 2배
        final scoreFactor = _comboMultiplier * (isDoubleScoreActive ? 2.0 : 1.0);
        final points = (food.points * scoreFactor).round();
        _totalScore += points;
        _currentLevelScore += points;
        _eatenFoodCount++;
        _totalFoodEatenThisGame++;

        // 먹이 획득 피드백 이벤트 발행 (UI가 소비)
        _pendingEatEvent = EatEvent(
          position: food.position,
          points: points,
          comboCount: _comboCount,
          comboMultiplier: _comboMultiplier,
          foodType: food.type,
        );

        // 길이 증가: 매 먹이마다 1세그먼트 증가 (최대 _maxSegments까지)
        _shouldGrow = (_caterpillar.length < _maxSegments);
        _growGraceFrames = 10;
        debugPrint('>>> ATE FOOD #$_eatenFoodCount/$_stageFoodTarget | score=$_totalScore | segments=${_caterpillar.length} | grow=$_shouldGrow');

        ate = true;
        return true;
      }
      return false;
    });

    if (ate) {
      if (_mode == GameMode.stage) {
        // 스테이지 모드: 목표 먹이 달성 시 레벨업
        if (_eatenFoodCount >= _stageFoodTarget) {
          _stageComplete();
        } else if (_screenSize != null) {
          _spawnSingleFood(_screenSize!);
        }
      } else {
        // 타임어택/무한: 레벨업 없이 계속 진행
        // 무한 모드는 먹이 5개마다 난이도(속도/장애물) 상승
        if (_mode == GameMode.endless && _eatenFoodCount % 5 == 0) {
          _currentLevel++;
          _levelConfig = LevelConfig.getLevelConfig(_currentLevel);
        }
        if (_screenSize != null) {
          _spawnSingleFood(_screenSize!);
        }
      }
    }
  }

  /// 타임어택 제한 시간 종료 → 게임 오버 (시간 종료는 '실패'가 아닌 '완료')
  void timeAttackFinished() {
    if (_state != GameState.playing) return;
    _gameOverReason = '시간 종료!';
    _state = GameState.gameOver;
    _caterpillar = [];
    _clearSavedProgress();
    notifyListeners();
  }

  /// 스테이지 완료
  void _stageComplete() {
    if (_isLevelingUp) return;
    _isLevelingUp = true;
    _currentLevel++;
    _levelConfig = LevelConfig.getLevelConfig(_currentLevel);
    _currentLevelScore = 0;
    _saveGameState();
    notifyListeners();
  }

  /// 레벨 업 완료 → 다음 스테이지 준비
  void levelUpComplete() {
    _isLevelingUp = false;
    _hasStartedMoving = false;
    _currentDirection = Offset(0, 0);
    _targetPosition = null;
    _safeFrames = 60;
    _shouldGrow = false;
    _comboCount = 0;
    _comboMultiplier = 1.0;
    _comboText = null;

    if (_screenSize != null) {
      _resetCaterpillarPosition(_screenSize!);
      _generateObstacles(_screenSize!);
      _initStage(_screenSize!);
    }

    notifyListeners();
  }

  /// 벽 충돌 감지 — 머리뿐 아니라 모든 세그먼트(몸통 전체)가 게임 영역 밖으로
  /// 나가면 true. 게임 영역은 좌우 화면 폭, 상단 _gameAreaTop(HUD), 하단
  /// _gameAreaBottom(광고)으로 둘러싸인 사각형이다.
  bool _checkWallCollision() {
    if (_caterpillar.isEmpty || _screenSize == null) return false;
    final width = _screenSize!.width;
    // 무적(_safeFrames) 동안은 게임 시작/방패 직후 보호를 위해 약간의 여유를 둔다.
    final margin = _safeFrames > 0 ? 5.0 : 0.0;
    for (final seg in _caterpillar) {
      if (seg.dx < -margin ||
          seg.dx > width + margin ||
          seg.dy < _gameAreaTop - margin ||
          seg.dy > _gameAreaBottom + margin) {
        return true;
      }
    }
    return false;
  }

  /// 충돌 감지
  String? _checkCollision() {
    if (_caterpillar.isEmpty) return null;

    // 길이 증가 유예 프레임 감소
    if (_growGraceFrames > 0) {
      _growGraceFrames--;
    }

    final head = _caterpillar[0];
    // 머리·몸통 모든 세그먼트를 동일한 반경으로 충돌 판정한다.
    const segRadius = 10.0;

    // 장애물 충돌 — 길이와 무관하게 항상 검사하며, 머리뿐 아니라 모든 세그먼트(몸통 전체)를 검사한다.
    // 벽 충돌과 동일하게, 돌맹이 등 장애물에 어느 부위라도 닿으면 통과 못 하고 게임 오버.
    // (먹이는 별도로 _checkFoodCollision에서 먹는 처리 — 여기서 다루지 않음)
    for (final obstacle in _obstacles) {
      for (final seg in _caterpillar) {
        if (_safeFrames > 0) {
          // 게임 시작 직후/방패 직후 무적 동안에는 스폰 겹침 보호를 위해
          // 약간 더 관대한 판정을 쓰되, 충돌 자체는 그대로 게임 오버로 이어진다.
          final dx = seg.dx - obstacle.position.dx;
          final dy = seg.dy - obstacle.position.dy;
          final minDist = (obstacle.size / 2 + segRadius + 5);
          if (dx * dx + dy * dy < minDist * minDist) return '장애물 충돌';
        } else {
          if (obstacle.checkCollision(seg, segRadius)) return '장애물 충돌';
        }
      }
    }

    // 자기 몸 충돌 — 너무 짧으면(반원 U턴이 불가능) 자기 몸에 닿을 수 없으므로 건너뛴다.
    // 세그먼트 간 거리가 20px로 일정하므로, 머리 근처 세그먼트는 제외.
    // U턴 시 충돌 가능한 최소 세그먼트 수: 약 5개 (반원 = pi * radius / segmentDist)
    if (_caterpillar.length >= 5) {
      final excludeCount = _growGraceFrames > 0 ? 8 : (_safeFrames > 0 ? 6 : 5);
      for (int i = excludeCount; i < _caterpillar.length; i++) {
        final segment = _caterpillar[i];
        final dx = head.dx - segment.dx;
        final dy = head.dy - segment.dy;
        if (dx * dx + dy * dy < 15.0 * 15.0) {
          return '꼬리 충돌';
        }
      }
    }

    return null;
  }

  /// 게임 오버
  void gameOver([String reason = '']) {
    // 방패 보유 시: 죽음을 1회 막고 방패를 소모한다.
    if (_hasShield) {
      _hasShield = false;
      _pendingShieldBlock = true; // UI가 방어음 재생
      _consumeShieldRescue();
      return;
    }
    _state = GameState.gameOver;
    _gameOverReason = reason;
    _caterpillar = [];
    _clearSavedProgress();
    notifyListeners();
  }

  /// 방패로 죽음을 막았을 때: 머리를 게임 영역 안으로 보정하고
  /// 이동을 멈춘 뒤 잠시 무적(안전 프레임)을 부여한다.
  void _consumeShieldRescue() {
    if (_caterpillar.isEmpty || _screenSize == null) {
      notifyListeners();
      return;
    }
    const margin = 30.0;
    final head = _caterpillar[0];
    final safeX = head.dx.clamp(margin, _screenSize!.width - margin);
    final safeY = head.dy.clamp(_gameAreaTop + margin, _gameAreaBottom - margin);
    final safeHead = Offset(safeX, safeY);
    // 머리뿐 아니라 몸통도 충돌 판정하므로, 몸통 세그먼트가 벽/장애물 밖에
    // 걸쳐 있으면 방패로 구출해도 다음 프레임에 다시 죽는다.
    // 따라서 모든 세그먼트를 안전한 머리 위치로 모아 영역 안으로 끌어들인다.
    for (int i = 0; i < _caterpillar.length; i++) {
      _caterpillar[i] = safeHead;
    }

    // 이동 정지 + 재충돌 방지 안전 프레임
    _targetPosition = null;
    _currentDirection = Offset(0, 0);
    _hasStartedMoving = false;
    _safeFrames = 45;
    _growGraceFrames = 30;
    notifyListeners();
  }

  /// 보상형광고 시청 보상: 최종 점수에 배수를 적용한다.
  /// 게임 오버 화면에서만 호출되며, 적용된 점수는 기록 저장에도 반영된다.
  void applyScoreBonus(double multiplier) {
    if (multiplier <= 1.0) return;
    _totalScore = (_totalScore * multiplier).round();
    notifyListeners();
  }

  /// 게임 오버 후 메뉴 복귀
  void returnToMenuAfterGameOver() {
    _state = GameState.menu;
    _currentLevel = 1;
    _totalScore = 0;
    _currentLevelScore = 0;
    _caterpillar = [];
    _obstacles = [];
    _foods = [];
    _targetPosition = null;
    notifyListeners();
  }

  /// 메인 메뉴로 복귀
  void returnToMenu() {
    _state = GameState.menu;
    _caterpillar = [];
    _obstacles = [];
    _foods = [];
    _targetPosition = null;
    notifyListeners();
  }

  void pause() {
    if (_state == GameState.playing) {
      _state = GameState.paused;
      notifyListeners();
    }
  }

  void resume() {
    if (_state == GameState.paused) {
      _state = GameState.playing;
      notifyListeners();
    }
  }
}
