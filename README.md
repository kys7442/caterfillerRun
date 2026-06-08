# 🐛 애벌레야! 어디가? (Caterpillar Run)

먹고, 자라고, 살아남아라! 한 손으로 즐기는 중독성 꼬리잡기 게임.

Flutter로 제작한 캐주얼 아케이드 모바일 게임입니다. 애벌레를 조종해 먹이를
먹으며 몸을 키우고, 벽·장애물·자기 몸을 피해 최대한 오래 살아남습니다.

| 항목 | 값 |
|------|-----|
| 앱 이름 | 애벌레야! 어디가? / Caterpillar Run |
| 버전 | 1.0.0 (+1) |
| Android 패키지 | `com.pamp.caterpillar_run` |
| iOS 번들 ID | `com.pamp.caterpillarRun` |
| 카테고리 | 게임 > 아케이드 / 캐주얼 |

---

## ✨ 주요 기능

- **게임 모드 3종** — 스테이지 / 타임어택 / 엔드리스
- **콤보 시스템** — 빠르게 연속으로 먹으면 점수 x1.5 → x2 → x3
- **특수 먹이** — ⭐골드(고득점) / 🛡방패(충돌 방어) / ⏳슬로우 / ⚡더블점수
  - 각 특수 먹이를 처음 먹으면 안내 팝업으로 효과를 설명(종류별 1회)
- **콘텐츠** — 스킨샵, 업적, 일일 출석, 글로벌 랭킹(Firebase)
- **수익화** — 배너/전면/보상형 광고(AdMob), 광고 제거 인앱결제
- **방어적 설계** — 광고/Firebase/결제 미설정 시에도 정상 빌드·실행
  (광고는 테스트 광고 폴백, Firebase는 조용히 비활성화)

---

## 🛠 개발 환경

| 도구 | 버전 |
|------|------|
| Flutter SDK | 3.38.3 (stable) |
| Dart SDK | `^3.10.1` |
| 대상 플랫폼 | Android (minSdk 21), iOS |

주요 패키지: `provider`, `google_mobile_ads`, `in_app_purchase`,
`firebase_core`/`firebase_analytics`/`cloud_firestore`/`firebase_auth`,
`google_sign_in`, `sign_in_with_apple`, `shared_preferences`, `flutter_animate`.

---

## 🚀 설치 및 실행

### 1. 사전 준비
- [Flutter SDK 3.38.3+](https://docs.flutter.dev/get-started/install) 설치
- iOS 빌드: Xcode + CocoaPods / Android 빌드: Android Studio(SDK)

### 2. 의존성 설치
```bash
git clone https://github.com/kys7442/caterfillerRun.git
cd caterfillerRun
flutter pub get
```

### 3. 실행 (개발)
```bash
flutter devices                 # 연결된 기기/시뮬레이터 확인
flutter run -d <device-id>      # 디버그 모드로 실행
#   r = 핫 리로드, R = 핫 리스타트, q = 종료
```

### 4. 정적 분석 & 테스트
```bash
flutter analyze                 # 정적 분석 (이슈 0건 유지)
flutter test                    # 단위 테스트
```

> Firebase/광고 설정 없이도 바로 빌드·실행됩니다. 미설정 기능은 자동으로 폴백됩니다.

---

## 🎮 사용법 (플레이 방법)

1. **새 게임** → 모드(스테이지/타임어택/엔드리스) 선택
2. 화면을 **터치**한 곳으로 애벌레가 이동 — 벽·장애물·자기 몸을 피하세요
3. 먹이를 먹어 점수를 올리고 몸을 키우세요. **빠르게 연속으로 먹으면 콤보!**
4. 색깔 있는 **특수 먹이**를 노려 방패·슬로우·더블점수 같은 효과를 얻으세요
5. 모은 코인으로 **스킨샵**에서 애벌레를 꾸미고, **업적·랭킹**에 도전하세요

---

## 📦 릴리스 빌드

```bash
# Android (AAB)
flutter build appbundle --release
# 또는 제공 스크립트
./build_android_release.sh

# iOS (IPA) — 서명 설정 필요
flutter build ipa --release
./build_ios_release.sh
```

> 릴리스 전 서명키(`android/key.properties`)와 외부 연동(AdMob ID, Firebase 설정,
> IAP 상품 등록)이 필요합니다. 자세한 절차는 아래 문서를 참고하세요.

---

## 📚 관련 문서

| 문서 | 용도 |
|------|------|
| [`NEXT_STEPS.md`](NEXT_STEPS.md) | 이어서 진행할 작업 / 남은 출시 체크리스트 |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | 출시 전체 체크리스트 + 빌드 명령 |
| [`GO_LIVE_CHECKLIST.md`](GO_LIVE_CHECKLIST.md) | 출시 직전 외부 연동 일괄 처리 가이드 |
| [`FIREBASE_SETUP.md`](FIREBASE_SETUP.md) | Firebase 분석·랭킹·로그인 연동 절차 |

소개 웹/관리 대시보드: [caterpillar-web](https://github.com/kys7442/caterpillar-web)

---

## 📁 프로젝트 구조

```
lib/
├── main.dart              # 진입점 (스플래시 → 튜토리얼/메뉴)
├── models/                # 게임 데이터 모델 (food, game_state, skin 등)
├── providers/             # 상태관리 (game, score, currency, skin, achievement)
├── screens/               # 화면 (menu, game, splash, leaderboard 등)
├── widgets/               # 위젯 (caterpillar, festive_background, mascot 등)
└── utils/                 # 서비스 (ad, firebase, auth, purchase, sound)
```

---

## 📄 라이선스 / 문의

© 2026 PAMP. All rights reserved.
문의: kys7442@gmail.com
