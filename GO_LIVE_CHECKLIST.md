# 🚦 출시 직전 외부 연동 체크리스트 (GO-LIVE)

> 방침: **모든 외부 연동은 출시 직전에 일괄 처리한다.**
> 개발 중에는 연동 없이도 게임/웹이 정상 동작하도록 모두 방어적으로 구현되어 있다.
> (광고=테스트광고 폴백, Firebase=비활성, 대시보드=데모 데이터)
> 이 문서 하나만 따라가면 실서비스 전환이 완료된다.

---

## A. 게임 앱 — AdMob (수익)
- [ ] AdMob 콘솔에서 **광고 단위 발급** (Android/iOS 각각)
  - 배너(iOS), 전면(And/iOS), 보상형(And/iOS) — Android 배너는 이미 설정됨
- [ ] `lib/utils/ad_config.dart`의 `_prod*` 빈 문자열을 실제 ID로 교체
  - 비워두면 자동으로 **테스트 광고**가 나가 수익 0 → 반드시 교체
- [ ] AdMob 앱을 Play/App Store 앱과 **연결**
- 검증: 릴리스 빌드에서 실광고 노출 확인 (단, 본인 클릭 금지 — 정책 위반)

## B. 게임 앱 — 인앱결제 (광고 제거)
- [ ] Google Play Console → 인앱 상품 `remove_ads` 등록 (관리되는 상품)
- [ ] App Store Connect → 인앱 구입 `remove_ads` 등록 (비소모성)
- [ ] 두 스토어의 상품 ID가 코드(`PurchaseManager.removeAdsProductId = 'remove_ads'`)와 일치하는지 확인
- [ ] 심사 제출 시 IAP도 함께 제출

## C. 게임 앱 — Firebase (분석·랭킹·로그인)
> 상세 절차는 `FIREBASE_SETUP.md`
- [ ] `flutterfire configure` 실행 → `google-services.json` / `GoogleService-Info.plist` / `firebase_options.dart` 생성
  - ✅ 코드 수정 불필요: `firebase_options.dart`(현재 stub)가 실제 옵션으로 덮어써지면 `FirebaseService.initialize()`가 자동으로 옵션을 사용
- [ ] Authentication → **Google / Apple 로그인 활성화**
  - Android: 릴리스 키 **SHA-1/SHA-256** 지문 등록
  - iOS: Apple 로그인 capability + REVERSED_CLIENT_ID URL Scheme
- [ ] Firestore 생성 + **보안 규칙** 적용 (FIREBASE_SETUP.md의 규칙 복붙)
- 검증: 로그인 → 게임오버 랭킹 등록 → 메뉴 '랭킹'에서 확인

## D. 웹 대시보드 — 외부 API 연동
> 상세 절차는 `caterpillar-web/SETUP.md`
`caterpillar-web/.env.local`에 자격증명 입력 후 `docker compose up -d --force-recreate app`
- [ ] **AdMob 수익**: `GOOGLE_OAUTH_*` + `GOOGLE_ADMOB_PUBLISHER_ID`
- [ ] **스토어 지표**: `GOOGLE_PLAY_SA_*` (Play Console 서비스 계정)
- [ ] **게임 분석**: `GA4_PROPERTY_ID` + `GA4_SA_*` (GA4 뷰어 권한)
- [ ] **랭킹**: `FIREBASE_PROJECT_ID` + `FIREBASE_SA_*` (datastore 권한)
- [ ] `DASHBOARD_PASSWORD` 운영용으로 변경
- 각 항목 미설정 시 해당 탭은 데모 데이터로 표시(앱은 정상)

## E. 스토어 등록 (메타데이터)
> 상세는 `RELEASE_CHECKLIST.md`
- [ ] 개인정보처리방침 **공개 URL** 입력 (웹 `/privacy` 배포 후)
- [ ] 스크린샷, 아이콘, 설명, 콘텐츠 등급, 데이터 보안 양식
- [ ] Android: AAB 업로드 / iOS: IPA 업로드 (TestFlight → 심사)

## F. 도메인/배포 (운영 전환 시)
- [ ] `test.caterpillrun.com` → 실제 DNS A 레코드 + HTTPS(Let's Encrypt)
- [ ] Nginx 포트 8088 → 80/443 전환 (현재 로컬 8088은 다른 nginx 회피용)

---

## 현재 상태 (개발 완료, 연동 대기)
| 영역 | 코드 | 외부 연동 |
|------|------|----------|
| 광고(배너/전면/보상형) | ✅ | ⏳ 출시 직전 |
| 광고제거 IAP | ✅ | ⏳ 출시 직전 |
| 보안 강화 | ✅ | — |
| Firebase 분석/랭킹/로그인 | ✅ | ⏳ 출시 직전 |
| 웹 소개페이지 | ✅ | — |
| 웹 대시보드(4탭) | ✅ | ⏳ 출시 직전 |
| Docker/Nginx 배포 | ✅ (로컬) | ⏳ 운영 도메인 |
