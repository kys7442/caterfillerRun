# 🚀 애벌레야! 어디가? (Caterpillar Run) — 출시 체크리스트

> 최종 업데이트: 2026-06-01
> 이 문서는 Google Play / App Store 출시까지 개발자가 직접 처리해야 할 작업을 단계별로 정리합니다.

---

## 0. 앱 기본 정보

| 항목 | 값 |
|------|-----|
| 앱 이름 (한글) | 애벌레야! 어디가? |
| 앱 이름 (영문) | Caterpillar Run |
| Android 패키지 | `com.pamp.caterpillar_run` |
| iOS 번들 ID | `com.pamp.caterpillarRun` |
| 버전 | 1.0.0 (+1) |
| AdMob 앱 ID | `ca-app-pub-3568835154047233~2226160971` |
| 문의 이메일 | kys7442@gmail.com |
| 카테고리 | 게임 > 아케이드 / 캐주얼 |

---

## 1. ✅ 코드에 이미 적용된 항목 (완료)

- [x] **보안**: 평문 HTTP 전면 차단 (Android `network_security_config`, iOS ATS)
- [x] **보안**: `allowBackup=false` (백업 통한 데이터 유출 방지)
- [x] **보안**: ProGuard/R8 난독화 + 리소스 축소 + 릴리스 로그 제거
- [x] **보안**: 비밀키(.jks/key.properties) `.gitignore` 처리 확인됨
- [x] **광고**: 배너 광고 (게임/결과/기록 화면 하단)
- [x] **광고**: 전면 광고 (게임 오버 3회마다 1회, 빈도 제한)
- [x] **광고**: 보상형 광고 (게임 오버 시 "광고 보고 점수 2배")
- [x] **수익화**: 인앱결제 "광고 제거" (비소비성) + 구매 복원
- [x] **정책**: ATT(iOS 추적 동의), SKAdNetwork 18종, 개인정보처리방침(앱 내 + 웹)
- [x] **앱 아이콘**: Android(5종 해상도) / iOS(1024 포함 19종) 생성 완료

---

## 2. ⚠️ 출시 전 반드시 처리 (개발자 작업)

### 2-1. AdMob 광고 단위 ID 발급 → 코드 교체
현재 **전면/보상형 광고와 iOS 배너**는 프로덕션 ID가 비어 있어 자동으로 *테스트 광고*로 폴백됩니다.
출시 전 [AdMob 콘솔](https://apps.admob.com)에서 광고 단위를 생성하고 아래 파일을 교체하세요.

📄 `lib/utils/ad_config.dart`
```dart
static const String _prodBannerIOS = '';          // ← iOS 배너 단위 ID
static const String _prodInterstitialAndroid = ''; // ← Android 전면 단위 ID
static const String _prodInterstitialIOS = '';     // ← iOS 전면 단위 ID
static const String _prodRewardedAndroid = '';     // ← Android 보상형 단위 ID
static const String _prodRewardedIOS = '';         // ← iOS 보상형 단위 ID
```
> 빈 값으로 출시해도 테스트 광고가 나가 **수익이 발생하지 않으므로** 반드시 교체해야 합니다.

### 2-2. 인앱결제 상품 등록
양쪽 스토어에 상품 ID `remove_ads` 를 **동일하게** 등록해야 합니다.
- **Google Play Console** → 수익 창출 → 인앱 상품 → 상품 ID `remove_ads` (관리되는 상품/비소비성)
- **App Store Connect** → 기능 → 인앱 구입 → `remove_ads` (비소모성)
- 등록 후 가격 설정 → 심사 시 IAP도 함께 제출

### 2-3. AdMob ↔ 앱 연결 & 앱-ads.txt
- AdMob 콘솔에서 앱을 Google Play / App Store 앱과 "연결" 처리
- (선택) 앱-ads.txt 설정 시 웹사이트 도메인 등록

---

## 3. Google Play 출시 절차

1. [ ] Play Console에서 앱 생성 (앱 이름, 기본 언어 한국어)
2. [ ] **앱 서명**: Play 앱 서명 사용 (업로드 키는 `caterpillar-run-release.jks`)
3. [ ] AAB 업로드: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`
4. [ ] **데이터 보안 양식**: 광고 ID 수집함 / 데이터 기기 외 전송 없음 / 암호화 전송
5. [ ] **콘텐츠 등급 설문** (아케이드 게임, 폭력성 없음 → 전체 이용가 예상)
6. [ ] **타겟 고객층**: 13세 이상 권장 (광고 포함)
7. [ ] 개인정보처리방침 URL 입력 (아래 5번 웹사이트)
8. [ ] 스토어 등록정보: 아이콘(512), 그래픽 이미지(1024×500), 스크린샷(폰 2~8장)
9. [ ] 내부 테스트 트랙 → 비공개 테스트 → 프로덕션 단계적 출시

---

## 4. App Store 출시 절차

1. [ ] Apple Developer Program 가입 ($99/년) 및 인증서/프로비저닝
2. [ ] App Store Connect에서 앱 생성 (번들 ID `com.pamp.caterpillarRun`)
3. [ ] 빌드 업로드: `flutter build ipa --release` → Transporter 또는 Xcode로 업로드
4. [ ] **앱 개인정보 보호**: 추적용 광고 ID 사용 명시 (ATT 적용됨)
5. [ ] 스크린샷: 6.7"/6.5"/5.5" iPhone + iPad (필요 시)
6. [ ] 연령 등급 설문 (4+ 또는 광고로 인해 12+ 가능)
7. [ ] 개인정보처리방침 URL 입력
8. [ ] TestFlight 베타 → 심사 제출

---

## 5. 웹사이트 (개인정보처리방침 호스팅)

스토어는 **공개 URL의 개인정보처리방침**을 요구합니다. 다음 중 하나 사용:
- 기존: `docs/index.html` (GitHub Pages 배포 가능)
- 신규: `/Volumes/DATA/000_Projects/caterpillar-web/` Next.js 사이트의 `/privacy` 페이지

배포 후 URL을 양 스토어 등록정보에 입력하세요.

---

## 6. 스토어 설명 (복붙용 초안)

### 짧은 설명 (80자)
> 먹이를 먹고 쑥쑥 자라는 애벌레! 벽과 장애물을 피해 최고 스테이지에 도전하세요.

### 전체 설명
```
🐛 애벌레야! 어디가? — 한 손으로 즐기는 중독성 꼬리잡기 게임!

화면을 터치해 애벌레를 움직이고, 먹이를 먹어 점점 길어지세요.
벽과 장애물, 그리고 자기 자신의 몸을 피하는 순간의 판단이 승부를 가릅니다.

✨ 주요 특징
• 콤보 시스템 — 3초 안에 연속으로 먹으면 점수 x2, x3!
• 무한 스테이지 — 레벨이 오를수록 빨라지는 짜릿한 난이도
• 직관적인 조작 — 누구나 30초면 마스터하는 원터치 플레이
• 귀여운 그래픽과 신나는 사운드
• 최고 기록 도전과 최근 기록 보관

지금 바로 애벌레의 모험을 시작하세요!
```

### 키워드 (App Store)
> 애벌레,스네이크,꼬리잡기,아케이드,캐주얼게임,한손게임,점수도전,콤보

---

## 7. 빌드 명령 요약

```bash
# Android (Play 업로드용 AAB)
flutter build appbundle --release

# iOS (App Store 업로드용 IPA)
flutter build ipa --release

# 정적 분석
flutter analyze
```
