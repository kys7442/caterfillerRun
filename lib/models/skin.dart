import 'package:flutter/material.dart';

/// 애벌레 스킨 정의. 색상 팔레트와 언락 조건을 담는다.
class Skin {
  final String id;
  final String name;
  final MaterialColor swatch; // 기본 색 계열
  final int price; // 코인 가격 (0 = 기본 제공)
  final String? unlockAchievementId; // 이 업적 달성 시 무료 언락 (선택)

  const Skin({
    required this.id,
    required this.name,
    required this.swatch,
    this.price = 0,
    this.unlockAchievementId,
  });

  bool get isDefault => price == 0 && unlockAchievementId == null;
}

/// 전체 스킨 목록 (첫 번째가 기본)
const List<Skin> kSkins = [
  Skin(id: 'green', name: '초록 애벌레', swatch: Colors.green, price: 0),
  Skin(id: 'blue', name: '파랑 애벌레', swatch: Colors.blue, price: 200),
  Skin(id: 'orange', name: '주황 애벌레', swatch: Colors.orange, price: 200),
  Skin(id: 'purple', name: '보라 애벌레', swatch: Colors.purple, price: 350),
  Skin(id: 'pink', name: '분홍 애벌레', swatch: Colors.pink, price: 350),
  Skin(id: 'teal', name: '청록 애벌레', swatch: Colors.teal, price: 500),
  Skin(
    id: 'gold',
    name: '황금 애벌레',
    swatch: Colors.amber,
    price: 0,
    unlockAchievementId: 'level_25', // 레벨 25 업적 달성 시 언락
  ),
];

Skin skinById(String id) =>
    kSkins.firstWhere((s) => s.id == id, orElse: () => kSkins.first);
