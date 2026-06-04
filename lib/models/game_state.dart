/// 게임 상태 모델
enum GameState {
  menu,        // 메인 메뉴
  countdown,   // 카운트다운
  playing,     // 게임 중
  paused,      // 일시정지
  gameOver,    // 게임 오버
}

/// 게임 모드
enum GameMode {
  stage,     // 스테이지 진행 (기본): 목표 먹이 달성 시 레벨업
  timeAttack, // 타임어택: 제한 시간 내 최대 점수
  endless,   // 무한: 레벨업 없이 점점 빨라지는 단일 판
}

extension GameModeInfo on GameMode {
  String get label {
    switch (this) {
      case GameMode.stage:
        return '스테이지';
      case GameMode.timeAttack:
        return '타임어택';
      case GameMode.endless:
        return '무한';
    }
  }

  String get description {
    switch (this) {
      case GameMode.stage:
        return '목표를 달성하며 스테이지를 클리어하세요';
      case GameMode.timeAttack:
        return '90초 안에 최대한 많은 점수를!';
      case GameMode.endless:
        return '죽을 때까지! 점점 빨라집니다';
    }
  }

  /// 기록 저장 키 접미사 (모드별 최고기록 분리)
  String get recordKey {
    switch (this) {
      case GameMode.stage:
        return 'stage';
      case GameMode.timeAttack:
        return 'timeattack';
      case GameMode.endless:
        return 'endless';
    }
  }

  /// 타임어택 제한 시간(초). 그 외 0.
  int get timeLimitSec => this == GameMode.timeAttack ? 90 : 0;
}

/// 게임 결과
class GameResult {
  final int score;
  final int level;
  final int survivalTime; // 생존 시간 (초)

  GameResult({
    required this.score,
    required this.level,
    required this.survivalTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'survivalTime': survivalTime,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      score: json['score'] as int,
      level: json['level'] as int,
      survivalTime: json['survivalTime'] as int,
    );
  }
}

