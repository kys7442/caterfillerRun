import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import 'currency_provider.dart';

/// 업적 진행/달성 관리. 통계를 누적하고 목표 도달 시 코인을 지급한다.
class AchievementProvider extends ChangeNotifier {
  static const String _kUnlockedPrefix = 'ach_unlocked_';
  static const String _kStatPrefix = 'stat_';

  CurrencyProvider? _currency;

  final Set<String> _unlocked = {};
  final Map<StatType, int> _stats = {};

  /// 방금 달성한 업적(토스트 표시용). 소비하면 비워진다.
  final List<Achievement> _justUnlocked = [];

  Set<String> get unlocked => _unlocked;
  int statOf(StatType t) => _stats[t] ?? 0;
  bool isUnlocked(String id) => _unlocked.contains(id);

  int get unlockedCount => _unlocked.length;
  int get totalCount => kAchievements.length;

  AchievementProvider() {
    _load();
  }

  /// CurrencyProvider 연결 (보상 지급용). main에서 주입.
  void attachCurrency(CurrencyProvider currency) {
    _currency = currency;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final a in kAchievements) {
      if (prefs.getBool('$_kUnlockedPrefix${a.id}') ?? false) {
        _unlocked.add(a.id);
      }
    }
    for (final t in StatType.values) {
      _stats[t] = prefs.getInt('$_kStatPrefix${t.name}') ?? 0;
    }
    notifyListeners();
  }

  Achievement? consumeJustUnlocked() {
    if (_justUnlocked.isEmpty) return null;
    return _justUnlocked.removeAt(0);
  }

  /// 한 판이 끝났을 때 통계를 갱신하고 업적 달성을 판정한다.
  Future<void> recordGameResult({
    required int score,
    required int level,
    required int maxCombo,
    required int foodEaten,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // 누적/최댓값 갱신
    await _bump(prefs, StatType.gamesPlayed, statOf(StatType.gamesPlayed) + 1);
    await _bump(prefs, StatType.totalScore, statOf(StatType.totalScore) + score);
    await _bump(prefs, StatType.foodEaten, statOf(StatType.foodEaten) + foodEaten);
    await _max(prefs, StatType.highScore, score);
    await _max(prefs, StatType.maxLevel, level);
    await _max(prefs, StatType.maxCombo, maxCombo);

    await _checkUnlocks(prefs);
    notifyListeners();
  }

  Future<void> _bump(SharedPreferences prefs, StatType t, int value) async {
    _stats[t] = value;
    await prefs.setInt('$_kStatPrefix${t.name}', value);
  }

  Future<void> _max(SharedPreferences prefs, StatType t, int value) async {
    if (value > statOf(t)) {
      _stats[t] = value;
      await prefs.setInt('$_kStatPrefix${t.name}', value);
    }
  }

  Future<void> _checkUnlocks(SharedPreferences prefs) async {
    for (final a in kAchievements) {
      if (_unlocked.contains(a.id)) continue;
      final stat = statOf(statTypeForAchievement(a.id));
      if (stat >= a.target) {
        _unlocked.add(a.id);
        await prefs.setBool('$_kUnlockedPrefix${a.id}', true);
        _justUnlocked.add(a);
        await _currency?.addCoins(a.rewardCoins); // 보상 지급
      }
    }
  }

  /// 업적의 현재 진행도 (0.0~1.0)
  double progressOf(Achievement a) {
    final stat = statOf(statTypeForAchievement(a.id));
    return (stat / a.target).clamp(0.0, 1.0);
  }

  int currentValueOf(Achievement a) => statOf(statTypeForAchievement(a.id));
}
