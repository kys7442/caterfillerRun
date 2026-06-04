import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인게임 재화(코인) + 일일 출석 보상 관리.
///
/// - 코인은 게임 플레이, 일일 출석, 업적 보상으로 적립되고 스킨 언락에 사용된다.
/// - 일일 출석은 마지막 수령 날짜를 비교해 하루 1회 보상하며, 연속 출석 보너스가 있다.
/// - 모든 데이터는 기기 로컬(SharedPreferences)에 저장된다.
class CurrencyProvider extends ChangeNotifier {
  static const String _kCoins = 'coins';
  static const String _kLastCheckIn = 'last_checkin_date'; // yyyy-MM-dd
  static const String _kStreak = 'checkin_streak';

  int _coins = 0;
  String _lastCheckInDate = '';
  int _streak = 0;

  int get coins => _coins;
  int get streak => _streak;

  CurrencyProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _coins = prefs.getInt(_kCoins) ?? 0;
    _lastCheckInDate = prefs.getString(_kLastCheckIn) ?? '';
    _streak = prefs.getInt(_kStreak) ?? 0;
    notifyListeners();
  }

  /// 오늘 날짜 문자열 (yyyy-MM-dd) — 외부에서 주입(테스트/일관성)
  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 코인 적립
  Future<void> addCoins(int amount) async {
    if (amount <= 0) return;
    _coins += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCoins, _coins);
    notifyListeners();
  }

  /// 코인 사용. 잔액이 충분하면 차감하고 true, 아니면 false.
  Future<bool> spendCoins(int amount) async {
    if (amount <= 0) return true;
    if (_coins < amount) return false;
    _coins -= amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCoins, _coins);
    notifyListeners();
    return true;
  }

  /// 게임 점수를 코인으로 환산해 적립 (100점당 1코인, 최소 1)
  Future<void> awardFromScore(int score) async {
    if (score <= 0) return;
    final earned = (score / 100).floor().clamp(1, 9999);
    await addCoins(earned);
  }

  // ===================== 일일 출석 =====================

  /// 오늘 출석 보상을 받을 수 있는지
  bool canCheckIn(DateTime now) => _lastCheckInDate != dateKey(now);

  /// 연속 출석 일수에 따른 보상 코인 (1~7일 순환, 7일째 보너스)
  int rewardForStreak(int streak) {
    const base = [50, 60, 70, 80, 100, 120, 200]; // 7일 주기
    final idx = ((streak - 1) % 7).clamp(0, 6);
    return base[idx];
  }

  /// 오늘 출석 처리. 성공 시 지급된 코인 수 반환, 이미 받았으면 0.
  Future<int> checkIn(DateTime now) async {
    final today = dateKey(now);
    if (_lastCheckInDate == today) return 0;

    // 연속 여부 판정: 어제 날짜와 비교
    final yesterday = dateKey(now.subtract(const Duration(days: 1)));
    if (_lastCheckInDate == yesterday) {
      _streak += 1;
    } else {
      _streak = 1; // 끊겼으면 리셋
    }

    final reward = rewardForStreak(_streak);
    _lastCheckInDate = today;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastCheckIn, _lastCheckInDate);
    await prefs.setInt(_kStreak, _streak);
    _coins += reward;
    await prefs.setInt(_kCoins, _coins);

    notifyListeners();
    return reward;
  }
}
