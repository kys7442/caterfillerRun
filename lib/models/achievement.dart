import 'package:flutter/material.dart';

/// 업적 정의 (정적 메타데이터)
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int target; // 목표 수치
  final int rewardCoins; // 달성 보상 코인

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.target,
    required this.rewardCoins,
  });
}

/// 업적 진행 추적에 쓰이는 통계 종류
enum StatType {
  totalScore, // 누적 점수
  highScore, // 단일 최고 점수
  maxLevel, // 도달 최고 레벨
  maxCombo, // 최고 콤보 수
  gamesPlayed, // 누적 플레이 횟수
  foodEaten, // 누적 먹이 수
}

/// 전체 업적 목록
const List<Achievement> kAchievements = [
  Achievement(
    id: 'first_game',
    title: '첫 걸음',
    description: '게임을 1회 플레이',
    icon: Icons.flag,
    target: 1,
    rewardCoins: 30,
  ),
  Achievement(
    id: 'score_1000',
    title: '천 점 돌파',
    description: '한 판에 1,000점 달성',
    icon: Icons.star,
    target: 1000,
    rewardCoins: 50,
  ),
  Achievement(
    id: 'score_5000',
    title: '오천 점의 사나이',
    description: '한 판에 5,000점 달성',
    icon: Icons.auto_awesome,
    target: 5000,
    rewardCoins: 150,
  ),
  Achievement(
    id: 'level_10',
    title: '스테이지 마스터',
    description: '레벨 10 도달',
    icon: Icons.trending_up,
    target: 10,
    rewardCoins: 80,
  ),
  Achievement(
    id: 'level_25',
    title: '불굴의 애벌레',
    description: '레벨 25 도달',
    icon: Icons.military_tech,
    target: 25,
    rewardCoins: 200,
  ),
  Achievement(
    id: 'combo_4',
    title: '콤보 마스터',
    description: '콤보 4회 달성 (x3)',
    icon: Icons.local_fire_department,
    target: 4,
    rewardCoins: 60,
  ),
  Achievement(
    id: 'games_10',
    title: '단골 손님',
    description: '누적 10회 플레이',
    icon: Icons.repeat,
    target: 10,
    rewardCoins: 70,
  ),
  Achievement(
    id: 'games_50',
    title: '애벌레 중독',
    description: '누적 50회 플레이',
    icon: Icons.whatshot,
    target: 50,
    rewardCoins: 250,
  ),
  Achievement(
    id: 'food_500',
    title: '대식가',
    description: '누적 먹이 500개 섭취',
    icon: Icons.restaurant,
    target: 500,
    rewardCoins: 120,
  ),
];

/// 통계 종류 ↔ 업적 매핑
StatType statTypeForAchievement(String id) {
  switch (id) {
    case 'first_game':
    case 'games_10':
    case 'games_50':
      return StatType.gamesPlayed;
    case 'score_1000':
    case 'score_5000':
      return StatType.highScore;
    case 'level_10':
    case 'level_25':
      return StatType.maxLevel;
    case 'combo_4':
      return StatType.maxCombo;
    case 'food_500':
      return StatType.foodEaten;
    default:
      return StatType.totalScore;
  }
}
