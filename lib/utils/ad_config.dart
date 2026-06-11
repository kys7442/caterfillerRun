import 'dart:io';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 설정 클래스
///
/// 디버그 빌드에서는 항상 Google 공식 테스트 광고 ID를 사용하고,
/// 릴리스 빌드에서만 실제 프로덕션 광고 ID를 사용합니다.
/// (테스트 중 실광고 클릭은 AdMob 정책 위반 → 계정 정지 위험이 있으므로 분리)
class AdConfig {
  // ===== 앱 ID =====
  // AndroidManifest.xml / Info.plist 에도 동일하게 설정되어 있어야 합니다.
  static const String appId = 'ca-app-pub-3568835154047233~6305446676';

  // ===== Google 공식 테스트 광고 단위 ID =====
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS =
      'ca-app-pub-3940256099942544/2934735716';
  static const String _testInterstitialAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS =
      'ca-app-pub-3940256099942544/4411468910';
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';

  // ===== 프로덕션 광고 단위 ID =====
  // AdMob 광고 단위 ID (애벌레 전용 AdMob 앱, 2026-06-10 발급·반영 완료).
  //   - Android / iOS 각각 별도의 광고 단위 ID.
  //   - 값을 비워두면(빈 문자열) 안전하게 테스트 ID로 폴백합니다.
  static const String _prodBannerAndroid =
      'ca-app-pub-3568835154047233/1032938698';
  static const String _prodBannerIOS =
      'ca-app-pub-3568835154047233/4589040322';
  static const String _prodInterstitialAndroid =
      'ca-app-pub-3568835154047233/2011854152';
  static const String _prodInterstitialIOS =
      'ca-app-pub-3568835154047233/5024154590';
  static const String _prodRewardedAndroid =
      'ca-app-pub-3568835154047233/2912996576';
  static const String _prodRewardedIOS =
      'ca-app-pub-3568835154047233/5216601995';

  static bool get _isIOS => Platform.isIOS;

  /// 프로덕션 ID가 비어있으면 테스트 ID로 폴백 (실수로 빈 ID 출시 방지)
  static String _resolve(String prodId, String testId) {
    if (kDebugMode) return testId;
    return prodId.isNotEmpty ? prodId : testId;
  }

  /// 배너 광고 단위 ID
  static String get bannerAdUnitId => _resolve(
        _isIOS ? _prodBannerIOS : _prodBannerAndroid,
        _isIOS ? _testBannerIOS : _testBannerAndroid,
      );

  /// 전면 광고 단위 ID
  static String get interstitialAdUnitId => _resolve(
        _isIOS ? _prodInterstitialIOS : _prodInterstitialAndroid,
        _isIOS ? _testInterstitialIOS : _testInterstitialAndroid,
      );

  /// 보상형 광고 단위 ID
  static String get rewardedAdUnitId => _resolve(
        _isIOS ? _prodRewardedIOS : _prodRewardedAndroid,
        _isIOS ? _testRewardedIOS : _testRewardedAndroid,
      );

  /// AdRequest 생성
  static AdRequest get adRequest => const AdRequest();

  /// AdMob 초기화
  static Future<InitializationStatus> initialize() async {
    return await MobileAds.instance.initialize();
  }
}
