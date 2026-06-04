import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/score_record.dart';

/// 점수 관리 Provider
class ScoreProvider extends ChangeNotifier {
  List<ScoreRecord> _recentRecords = [];
  ScoreRecord? _bestRecord;
  String _nickname = '';

  List<ScoreRecord> get recentRecords => _recentRecords;
  ScoreRecord? get bestRecord => _bestRecord;

  /// 랭킹 제출용 닉네임 (미설정 시 빈 문자열 → 제출 시 '익명' 처리)
  String get nickname => _nickname;

  ScoreProvider() {
    _loadRecords();
    _loadNickname();
  }

  Future<void> _loadNickname() async {
    final prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString('nickname') ?? '';
    notifyListeners();
  }

  /// 닉네임 저장 (랭킹 화면/설정에서 호출)
  Future<void> setNickname(String value) async {
    _nickname = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', _nickname);
    notifyListeners();
  }

  /// 기록 저장
  Future<void> saveRecord(ScoreRecord record) async {
    _recentRecords.insert(0, record);
    
    // 최대 10개까지만 저장
    if (_recentRecords.length > 10) {
      _recentRecords = _recentRecords.take(10).toList();
    }

    // 최고 기록 업데이트
    if (_bestRecord == null || record.score > _bestRecord!.score) {
      _bestRecord = record;
    }

    await _saveRecords();
    notifyListeners();
  }

  /// 가장 최근 기록의 점수를 배수 적용해 갱신한다.
  /// (보상형광고 '점수 2배' 보너스를 직전 게임 기록에도 반영하기 위함)
  Future<void> applyBonusToLatest(double multiplier) async {
    if (multiplier <= 1.0 || _recentRecords.isEmpty) return;

    final latest = _recentRecords.first;
    final updated = ScoreRecord(
      score: (latest.score * multiplier).round(),
      level: latest.level,
      survivalTime: latest.survivalTime,
      timestamp: latest.timestamp,
    );
    _recentRecords[0] = updated;

    // 최고 기록도 같은 게임이면 함께 갱신
    if (_bestRecord != null &&
        _bestRecord!.timestamp == latest.timestamp) {
      _bestRecord = updated;
    } else if (_bestRecord == null || updated.score > _bestRecord!.score) {
      _bestRecord = updated;
    }

    await _saveRecords();
    notifyListeners();
  }

  /// 기록 로드
  Future<void> _loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 최근 기록 로드
      final recentJson = prefs.getString('recent_records');
      if (recentJson != null) {
        final List<dynamic> decoded = json.decode(recentJson);
        _recentRecords = decoded
            .map((json) => ScoreRecord.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // 최고 기록 로드
      final bestJson = prefs.getString('best_record');
      if (bestJson != null) {
        _bestRecord = ScoreRecord.fromJson(
            json.decode(bestJson) as Map<String, dynamic>);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading records: $e');
    }
  }

  /// 기록 저장
  Future<void> _saveRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 최근 기록 저장
      final recentJson = json.encode(
          _recentRecords.map((record) => record.toJson()).toList());
      await prefs.setString('recent_records', recentJson);

      // 최고 기록 저장
      if (_bestRecord != null) {
        final bestJson = json.encode(_bestRecord!.toJson());
        await prefs.setString('best_record', bestJson);
      }
    } catch (e) {
      debugPrint('Error saving records: $e');
    }
  }

  /// 기록 삭제
  Future<void> clearRecords() async {
    _recentRecords = [];
    _bestRecord = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_records');
    await prefs.remove('best_record');
    notifyListeners();
  }
}

