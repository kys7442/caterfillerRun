# 🔥 Firebase 연동 가이드 (분석 · 랭킹 · 로그인)

> 이 게임은 **Firebase 설정 없이도 정상 빌드·실행**됩니다.
> 설정 파일을 추가하면 분석/랭킹/소셜로그인이 **자동 활성화**되고, 없으면 해당 기능만 조용히 비활성화됩니다.
> (코드는 모두 방어적으로 작성되어 있어 미설정 시 게임 흐름에 영향이 없습니다.)

## 정책 요약
- 🎮 **게임 플레이**: 로그인 불필요 (비회원 자유 플레이)
- 🏆 **랭킹 등록**: 로그인(Google/Apple) 필요
- 💳 **광고 제거 구매 복원**: 로그인 권장(계정 연결)
- ⚙️ **설정 화면**: 수동 로그인/로그아웃 제공

---

## 1. Firebase 프로젝트 생성

1. https://console.firebase.google.com 에서 프로젝트 생성
2. **Analytics 사용 설정** (GA4 속성 자동 생성됨)

## 2. FlutterFire CLI로 앱 등록 (권장)

```bash
dart pub global activate flutterfire_cli
cd /Volumes/DATA/000_Projects/flutter/caterpillar_run
flutterfire configure
```
- Android 패키지: `com.pamp.caterpillar_run`
- iOS 번들: `com.pamp.caterpillarRun`
- 이 명령이 `lib/firebase_options.dart`, `android/app/google-services.json`,
  `ios/Runner/GoogleService-Info.plist`를 자동 생성/배치합니다.

> ✅ **코드 수정 불필요.** `flutterfire configure`가 `lib/firebase_options.dart`(현재는 자리표시 stub)를
> 실제 옵션으로 덮어쓰면, `FirebaseService.initialize()`가 자동으로
> `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`를 사용합니다.
> (미설정 상태에서는 stub이 `null`을 반환해 옵션 없이 초기화 → 설정 없으면 조용히 비활성화)

### 수동 등록(대안)
- Android: 콘솔에서 앱 추가 → `google-services.json` → `android/app/`에 배치
  - `android/settings.gradle.kts`에 `id("com.google.gms.google-services") version "4.4.2" apply false`
  - `android/app/build.gradle.kts` plugins에 `id("com.google.gms.google-services")`
- iOS: `GoogleService-Info.plist` → `ios/Runner/`에 배치 (Xcode로 타깃에 추가)

## 3. 소셜 로그인 설정

### Google 로그인
- Firebase 콘솔 → Authentication → Sign-in method → **Google 사용 설정**
- Android: `google-services.json`에 OAuth 클라이언트 자동 포함.
  릴리스 키의 **SHA-1/SHA-256 지문**을 Firebase 프로젝트 설정에 등록해야 실기기에서 동작.
  ```bash
  keytool -list -v -keystore android/app/caterpillar-run-release.jks -alias <alias>
  ```
- iOS: `GoogleService-Info.plist`의 `REVERSED_CLIENT_ID`를 URL Scheme으로 `Info.plist`에 추가.

### Apple 로그인 (iOS 필수)
- Firebase 콘솔 → Authentication → **Apple 사용 설정**
- Apple Developer → Certificates, Identifiers → App ID에 **Sign In with Apple** capability 추가
- Xcode → Signing & Capabilities → **Sign in with Apple** 추가
- (App Store 정책: 타사 소셜 로그인을 제공하면 Apple 로그인도 제공해야 함)

## 4. Firestore (랭킹) 설정

1. Firebase 콘솔 → Firestore Database 생성 (프로덕션 모드)
2. **보안 규칙** — 로그인 사용자만 자신의 문서를 쓰고, 읽기는 공개:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /leaderboard/{uid} {
      allow read: if true;                         // 랭킹 공개 조회
      allow write: if request.auth != null
                   && request.auth.uid == uid       // 본인 문서만
                   && request.resource.data.score is int
                   && request.resource.data.score >= 0;
    }
  }
}
```
> 점수는 `uid`를 문서 ID로 사용해 **사용자당 최고기록 1건**만 유지합니다(코드에서 기존 점수보다 높을 때만 갱신).

3. (권장) 정렬 쿼리용 인덱스: `score DESC` 단일 필드는 자동 인덱스로 충분.

## 5. 웹 대시보드 ↔ Firebase 연결

웹 대시보드(`caterpillar-web`)의 분석/랭킹 탭이 실데이터를 보이게 하려면
`caterpillar-web/.env.local`에 서비스 계정 자격증명을 설정하세요. (그 쪽 `FIREBASE_SETUP.md`/`SETUP.md` 참고)
- `GA4_PROPERTY_ID` + GA4 뷰어 서비스계정 → 게임분석 탭
- `FIREBASE_PROJECT_ID` + datastore 권한 서비스계정 → 랭킹 탭

## 6. 검증 체크리스트
- [ ] `flutter analyze` 통과
- [ ] `flutter build appbundle --release` 성공 (설정 전/후 모두)
- [ ] 설정 후: 게임 실행 → 설정 화면에서 Google/Apple 로그인 → 게임오버 후 랭킹 등록 → 메뉴 '랭킹'에서 본인 점수 확인
- [ ] 미설정 시: 로그인 버튼이 "곧 제공될 예정" 안내, 랭킹 화면은 "준비 중" 표시
