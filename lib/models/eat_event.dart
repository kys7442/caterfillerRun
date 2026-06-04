import 'package:flutter/material.dart';
import 'food.dart';

/// 먹이 획득 시 UI 피드백(사운드/진동/점수팝업/파티클)을 위해
/// GameProvider가 발행하고 화면이 1회 소비하는 이벤트.
class EatEvent {
  final Offset position; // 먹이를 먹은 위치 (화면 좌표)
  final int points; // 획득 점수 (콤보 배수 적용 후)
  final int comboCount; // 현재 콤보 수
  final double comboMultiplier; // 콤보 배수 (1.0 = 콤보 없음)
  final FoodType foodType; // 먹은 먹이 종류 (특수먹이 사운드 구분용)

  const EatEvent({
    required this.position,
    required this.points,
    required this.comboCount,
    required this.comboMultiplier,
    this.foodType = FoodType.normal,
  });

  bool get isCombo => comboMultiplier > 1.0;
  bool get isSpecial => foodType != FoodType.normal;
}
