import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/skin.dart';
import 'currency_provider.dart';

/// 애벌레 스킨 보유/선택/구매 관리.
class SkinProvider extends ChangeNotifier {
  static const String _kOwnedPrefix = 'skin_owned_';
  static const String _kSelected = 'skin_selected';

  CurrencyProvider? _currency;

  final Set<String> _owned = {'green'}; // 기본 스킨 보유
  String _selectedId = 'green';

  String get selectedId => _selectedId;
  Skin get selectedSkin => skinById(_selectedId);
  bool isOwned(String id) => _owned.contains(id);

  SkinProvider() {
    _load();
  }

  void attachCurrency(CurrencyProvider currency) {
    _currency = currency;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    for (final s in kSkins) {
      if (s.isDefault || (prefs.getBool('$_kOwnedPrefix${s.id}') ?? false)) {
        _owned.add(s.id);
      }
    }
    _selectedId = prefs.getString(_kSelected) ?? 'green';
    notifyListeners();
  }

  /// 업적 달성으로 언락되는 스킨을 보유 처리 (업적 화면/시작 시 호출)
  Future<void> unlockByAchievements(Set<String> unlockedAchievements) async {
    final prefs = await SharedPreferences.getInstance();
    bool changed = false;
    for (final s in kSkins) {
      if (s.unlockAchievementId != null &&
          unlockedAchievements.contains(s.unlockAchievementId) &&
          !_owned.contains(s.id)) {
        _owned.add(s.id);
        await prefs.setBool('$_kOwnedPrefix${s.id}', true);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  /// 코인으로 스킨 구매. 성공 시 true.
  Future<bool> buy(Skin skin) async {
    if (_owned.contains(skin.id)) return true;
    if (skin.price <= 0) return false; // 가격 없는 건 업적 언락 전용
    final ok = await _currency?.spendCoins(skin.price) ?? false;
    if (!ok) return false;

    _owned.add(skin.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_kOwnedPrefix${skin.id}', true);
    notifyListeners();
    return true;
  }

  /// 보유한 스킨 선택
  Future<void> select(String id) async {
    if (!_owned.contains(id)) return;
    _selectedId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSelected, id);
    notifyListeners();
  }
}
