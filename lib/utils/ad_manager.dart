import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config.dart';
import 'purchase_manager.dart';

/// 전면광고 / 보상형광고를 중앙에서 관리하는 싱글톤.
///
/// - 광고는 미리 로드(preload)해 두었다가 필요할 때 즉시 노출합니다.
/// - 노출 후에는 다음 광고를 자동으로 다시 로드합니다.
/// - 광고 제거를 구매한 사용자에게는 전면광고를 노출하지 않습니다.
///   (보상형광고는 사용자가 '자발적으로' 보상을 위해 보는 것이므로 항상 허용)
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isInterstitialLoading = false;
  bool _isRewardedLoading = false;

  /// 전면광고 노출 빈도 제한: 게임 오버 N회마다 1번만 노출
  static const int _interstitialEveryNGameOvers = 3;
  int _gameOverCount = 0;

  /// 앱 시작 시 호출 — 광고 미리 로드
  void preload() {
    _loadInterstitial();
    _loadRewarded();
  }

  // ===================== 전면광고 =====================

  void _loadInterstitial() {
    if (_isInterstitialLoading || _interstitialAd != null) return;
    _isInterstitialLoading = true;

    InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: AdConfig.adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial(); // 다음 광고 준비
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoading = false;
          debugPrint('Interstitial 로드 실패: $error');
        },
      ),
    );
  }

  /// 게임 오버 시 호출. 빈도 제한과 광고제거 구매 여부를 고려해
  /// 조건이 맞을 때만 전면광고를 노출한다.
  void onGameOverMaybeShowInterstitial() {
    if (PurchaseManager.instance.isAdRemoved) return;

    _gameOverCount++;
    if (_gameOverCount % _interstitialEveryNGameOvers != 0) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _loadInterstitial(); // 다음 기회를 위해 로드 시도
      return;
    }
    ad.show();
    _interstitialAd = null; // show 후 콜백에서 dispose + 재로드
  }

  // ===================== 보상형광고 =====================

  void _loadRewarded() {
    if (_isRewardedLoading || _rewardedAd != null) return;
    _isRewardedLoading = true;

    RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: AdConfig.adRequest,
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              _loadRewarded();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
          debugPrint('Rewarded 로드 실패: $error');
        },
      ),
    );
  }

  /// 보상형광고가 현재 노출 가능한 상태인지
  bool get isRewardedReady => _rewardedAd != null;

  /// 보상형광고 노출. 사용자가 끝까지 시청해 보상을 받으면 [onReward] 호출.
  /// 광고가 준비되지 않았거나 보상을 못 받으면 [onReward]는 호출되지 않는다.
  ///
  /// 반환값: 광고를 실제로 노출했으면 true.
  bool showRewarded({required VoidCallback onReward}) {
    final ad = _rewardedAd;
    if (ad == null) {
      _loadRewarded();
      return false;
    }
    _rewardedAd = null;
    ad.show(
      onUserEarnedReward: (ad, reward) {
        onReward();
      },
    );
    return true;
  }

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
