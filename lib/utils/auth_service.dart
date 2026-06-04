import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'firebase_service.dart';

/// 소셜 로그인(Google/Apple) 인증 서비스.
///
/// 정책:
///   - 게임 플레이 자체는 로그인 없이 가능(비회원).
///   - 랭킹 등록 / 광고제거 구매 복원 등 '계정 연계' 기능에서만 로그인 요구.
///   - Firebase가 비활성(설정 파일 없음)이면 모든 로그인은 실패 처리되고,
///     호출부는 비회원 흐름으로 폴백한다.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  bool _ready = false;

  /// 현재 로그인 사용자 (없으면 null)
  User? get currentUser =>
      FirebaseService.instance.isEnabled ? FirebaseAuth.instance.currentUser : null;

  bool get isSignedIn => currentUser != null;

  /// 표시용 이름 (로그인 시 displayName, 없으면 이메일 앞부분)
  String get displayName {
    final u = currentUser;
    if (u == null) return '';
    if (u.displayName != null && u.displayName!.isNotEmpty) {
      return u.displayName!;
    }
    if (u.email != null && u.email!.isNotEmpty) {
      return u.email!.split('@').first;
    }
    return '플레이어';
  }

  /// 인증 상태 변경 구독 시작 (앱 시작 시 1회)
  void initialize() {
    if (!FirebaseService.instance.isEnabled || _ready) return;
    _ready = true;
    FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  /// Apple 로그인 사용 가능 여부 (iOS/macOS만)
  bool get isAppleAvailable => Platform.isIOS || Platform.isMacOS;

  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    if (!FirebaseService.instance.isEnabled) return false;
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false; // 사용자가 취소
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google 로그인 실패: $e');
      return false;
    }
  }

  /// Apple 로그인
  Future<bool> signInWithApple() async {
    if (!FirebaseService.instance.isEnabled || !isAppleAvailable) return false;
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Apple 로그인 실패: $e');
      return false;
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    if (!FirebaseService.instance.isEnabled) return;
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    notifyListeners();
  }
}
