import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase 연동(분석 + 랭킹)을 안전하게 래핑하는 서비스.
///
/// 설계 원칙:
///   - Firebase 설정 파일(google-services.json / GoogleService-Info.plist)이
///     없으면 초기화가 실패하는데, 이 경우 [_enabled]=false 로 두고
///     모든 메서드를 no-op 처리한다.
///   - 따라서 Firebase 설정 전에도 게임은 정상 빌드/실행되며,
///     설정 파일만 추가하면 자동으로 분석/랭킹이 활성화된다.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _enabled = false;
  FirebaseAnalytics? _analytics;
  FirebaseFirestore? _firestore;

  bool get isEnabled => _enabled;

  /// 앱 시작 시 1회 호출. 실패해도 예외를 던지지 않는다.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _analytics = FirebaseAnalytics.instance;
      _firestore = FirebaseFirestore.instance;
      _enabled = true;
      debugPrint('Firebase 초기화 완료 (분석/랭킹 활성화)');
    } catch (e) {
      _enabled = false;
      debugPrint('Firebase 미설정 또는 초기화 실패 → 분석/랭킹 비활성화: $e');
    }
  }

  // ===================== 분석 이벤트 =====================

  Future<void> logGameStart(int level) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'game_start',
        parameters: {'level': level},
      );
    } catch (_) {}
  }

  Future<void> logGameOver({
    required int score,
    required int level,
    required String reason,
    required int survivalTime,
  }) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(
        name: 'game_over',
        parameters: {
          'score': score,
          'level': level,
          'reason': reason,
          'survival_time': survivalTime,
        },
      );
    } catch (_) {}
  }

  Future<void> logLevelUp(int level) async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(name: 'level_up', parameters: {'level': level});
    } catch (_) {}
  }

  Future<void> logRewardedAdView() async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(name: 'rewarded_ad_view');
    } catch (_) {}
  }

  Future<void> logPurchaseRemoveAds() async {
    if (!_enabled) return;
    try {
      await _analytics?.logEvent(name: 'purchase_remove_ads');
    } catch (_) {}
  }

  // ===================== 랭킹 (Firestore) =====================

  /// 점수를 글로벌 리더보드에 제출한다. (로그인 사용자 전용)
  ///
  /// 사용자별로 '최고 점수 1건'만 유지한다(uid를 문서 ID로 사용).
  /// 새 점수가 기존 최고 기록보다 높을 때만 갱신한다.
  /// 실패해도 게임 흐름에 영향을 주지 않도록 조용히 무시한다.
  Future<void> submitScore({
    required String uid,
    required String nickname,
    required int score,
    required int level,
  }) async {
    if (!_enabled || score <= 0 || uid.isEmpty) return;
    try {
      final doc = _firestore?.collection('leaderboard').doc(uid);
      if (doc == null) return;
      final existing = await doc.get();
      final prevScore =
          (existing.data()?['score'] as num?)?.toInt() ?? -1;
      if (score <= prevScore) return; // 자기 최고기록 미달이면 갱신 안 함

      await doc.set({
        'uid': uid,
        'nickname': nickname.isEmpty ? '익명' : nickname,
        'score': score,
        'level': level,
        'createdAt': FieldValue.serverTimestamp(),
      });
      debugPrint('점수 제출 완료: $nickname $score');
    } catch (e) {
      debugPrint('점수 제출 실패: $e');
    }
  }

  /// 글로벌 상위 N개 랭킹 조회 (게임 내 랭킹 화면용)
  Future<List<LeaderboardEntry>> fetchTopScores({int limit = 50}) async {
    if (!_enabled) return [];
    try {
      final snap = await _firestore
          ?.collection('leaderboard')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();
      if (snap == null) return [];
      return snap.docs.map((d) {
        final data = d.data();
        return LeaderboardEntry(
          nickname: (data['nickname'] as String?) ?? '익명',
          score: (data['score'] as num?)?.toInt() ?? 0,
          level: (data['level'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('랭킹 조회 실패: $e');
      return [];
    }
  }
}

/// 게임 내 랭킹 표시용 항목
class LeaderboardEntry {
  final String nickname;
  final int score;
  final int level;

  const LeaderboardEntry({
    required this.nickname,
    required this.score,
    required this.level,
  });
}
