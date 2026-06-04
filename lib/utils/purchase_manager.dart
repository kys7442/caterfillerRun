import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

/// 인앱 결제(광고 제거) 관리 싱글톤.
///
/// - 상품: 비소비성(non-consumable) '광고 제거' 1회성 구매
/// - 구매 완료 시 로컬에 영속 저장하여 앱 재시작 후에도 광고 제거 유지
/// - '구매 복원'으로 기기 변경/재설치 후에도 복구 가능
///
/// 보안 참고:
///   - 이 게임은 자체 서버가 없으므로 영수증 서버검증은 수행하지 않습니다.
///   - 결제 자체는 App Store / Google Play 가 처리하며, 위변조 시도가 있어도
///     '광고 제거'라는 비핵심 혜택만 영향을 받으므로 위험도가 낮습니다.
///   - 향후 서버가 생기면 PurchaseDetails.verificationData 로 서버검증을 추가하세요.
class PurchaseManager extends ChangeNotifier {
  PurchaseManager._();
  static final PurchaseManager instance = PurchaseManager._();

  /// 스토어에 등록할 상품 ID (App Store Connect / Play Console 과 일치해야 함)
  static const String removeAdsProductId = 'remove_ads';

  static const String _prefsKeyAdRemoved = 'iap_ad_removed';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _available = false;
  bool _adRemoved = false;
  bool _purchasePending = false;
  ProductDetails? _removeAdsProduct;

  /// 스토어 결제 사용 가능 여부
  bool get isAvailable => _available;

  /// 광고 제거 구매 여부 (영속)
  bool get isAdRemoved => _adRemoved;

  /// 구매 진행 중 여부 (버튼 로딩 표시용)
  bool get isPurchasePending => _purchasePending;

  /// 광고 제거 상품 정보 (가격 문자열 표시 등). 미로드 시 null.
  ProductDetails? get removeAdsProduct => _removeAdsProduct;

  /// 표시용 가격 문자열 (스토어 로캘 가격). 미로드 시 기본값.
  String get removeAdsPriceLabel => _removeAdsProduct?.price ?? '구매';

  Future<void> initialize() async {
    // 저장된 광고제거 상태 먼저 로드 (오프라인에서도 즉시 반영)
    final prefs = await SharedPreferences.getInstance();
    _adRemoved = prefs.getBool(_prefsKeyAdRemoved) ?? false;
    notifyListeners();

    _available = await _iap.isAvailable();
    if (!_available) {
      debugPrint('IAP: 스토어 사용 불가');
      return;
    }

    // 구매 업데이트 스트림 구독
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription?.cancel(),
      onError: (e) => debugPrint('IAP 스트림 오류: $e'),
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final response =
          await _iap.queryProductDetails({removeAdsProductId});
      if (response.error != null) {
        debugPrint('IAP 상품 조회 오류: ${response.error}');
      }
      if (response.productDetails.isNotEmpty) {
        _removeAdsProduct = response.productDetails.first;
        notifyListeners();
      } else {
        debugPrint('IAP: 등록된 상품을 찾을 수 없음 (스토어 등록 확인 필요)');
      }
    } catch (e) {
      debugPrint('IAP 상품 로드 실패: $e');
    }
  }

  /// '광고 제거' 구매 시작
  Future<void> buyRemoveAds() async {
    if (_adRemoved) return;
    final product = _removeAdsProduct;
    if (!_available || product == null) {
      debugPrint('IAP: 구매 불가 (상품 미로드)');
      return;
    }
    _purchasePending = true;
    notifyListeners();

    final param = PurchaseParam(productDetails: product);
    try {
      // 비소비성 상품 → buyNonConsumable
      await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('IAP 구매 시작 실패: $e');
      _purchasePending = false;
      notifyListeners();
    }
  }

  /// 구매 복원 (재설치/기기변경 시)
  Future<void> restorePurchases() async {
    if (!_available) return;
    _purchasePending = true;
    notifyListeners();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP 복원 실패: $e');
    } finally {
      _purchasePending = false;
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _purchasePending = true;
          notifyListeners();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == removeAdsProductId) {
            await _grantAdRemoval();
          }
          _purchasePending = false;
          notifyListeners();
          break;
        case PurchaseStatus.error:
          debugPrint('IAP 구매 오류: ${purchase.error}');
          _purchasePending = false;
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _purchasePending = false;
          notifyListeners();
          break;
      }

      // 완료 처리 필수 (안 하면 결제가 재전송됨)
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantAdRemoval() async {
    if (_adRemoved) return;
    _adRemoved = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyAdRemoved, true);
    FirebaseService.instance.logPurchaseRemoveAds();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
