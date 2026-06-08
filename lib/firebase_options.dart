// ⚠️ 이 파일은 임시 자리표시(stub)입니다.
//
// 정식 파일은 `flutterfire configure` 명령이 자동 생성하며, 실행 시
// 이 파일을 **그대로 덮어씁니다**. 그때부터 실제 Firebase 옵션이 들어갑니다.
//
// 목적(현재):
//   - Firebase 미설정 상태에서도 `firebase_service.dart`가
//     `DefaultFirebaseOptions.currentPlatform` API를 안정적으로 참조하게 합니다.
//   - 여기서는 `null`을 반환하므로, 초기화 시 옵션 없이(네이티브 설정 파일 의존)
//     시도하다가 설정이 없으면 조용히 비활성화됩니다. → 기존 동작과 완전히 동일.
//
// 출시 직전(코드 수정 불필요):
//   1. `flutterfire configure` 실행 → 이 파일이 실제 옵션으로 교체됩니다.
//   2. `firebase_service.dart`가 자동으로 `currentPlatform` 옵션을 사용합니다.
//   - 자세한 절차는 `FIREBASE_SETUP.md` 참고.

import 'package:firebase_core/firebase_core.dart';

/// `flutterfire configure`가 생성할 정식 구현과 시그니처를 맞춘 자리표시.
class DefaultFirebaseOptions {
  /// 미설정 상태에서는 옵션이 없음을 의미하는 `null`을 반환합니다.
  static FirebaseOptions? get currentPlatform => null;
}
