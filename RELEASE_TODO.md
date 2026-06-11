# 🚀 출시 마스터 체크리스트 — 애벌레야! 어디가? (Caterpillar Run)

> **이 파일 하나만 읽으면 출시까지 남은 작업을 이어갈 수 있다.**
> 두 프로젝트(게임앱 `flutter/caterpillar_run` + 웹 `caterpillar-web`)를 통합 관리.
> 작업을 완료할 때마다 이 파일의 체크박스와 "최근 진행 로그"를 갱신할 것.
>
> - 최초 작성: 2026-06-10 (실제 코드/git/빌드 상태를 직접 검증하여 작성)
> - 기존 분산 문서(GO_LIVE_CHECKLIST · NEXT_STEPS · RELEASE_CHECKLIST · docs/PROJECT_STATUS)는
>   참고용이며, **현재 상태의 정본은 이 파일**이다.

---

## 0. 빠른 현황 (2026-06-10 검증 기준)

| 영역 | 상태 | 비고 |
|------|------|------|
| 게임 본체 코드 | ✅ 완료 | `flutter analyze` 이슈 0건, 테스트 2종 통과 |
| Git 형상관리 (게임) | ✅ 완료 | 4커밋, 리모트 `kys7442/caterfillerRun` |
| Git 형상관리 (웹) | ✅ 완료 | 2커밋, 리모트 `kys7442/caterpillar-web` |
| Firebase 설정 파일 3종 | ✅ 완료 | 실제 값 생성됨, project `caterpillar-run-2026` |
| 서명키(jks)·key.properties | ✅ 완료 | 값 채워짐, `.gitignore` 보호 확인 |
| 릴리스 빌드 산출물 | ✅ 존재 | AAB(6/8), IPA(3/26) — **광고ID 교체 후 재빌드 필요** |
| 웹 빌드 | ✅ 성공 | `npm run build` 정상, privacy 페이지 공개 접근 OK |
| **AdMob 광고 ID (6종)** | ✅ 완료 (6/10) | 애벌레 전용 AdMob 앱 신규생성(Android/iOS) 후 6개 단위 전부 반영. 과거 코드의 `~2226160971`은 성경책 앱 ID였음 → 교정 |
| **IAP 상품 등록** | ✅ 완료 (6/10) | 양 스토어 `remove_ads` 등록 완료 (Play 활성/ASC 제출 준비 중). 심사는 빌드와 동시 제출 |
| **소셜 로그인 활성화** | ✅ 완료 (6/10) | Google/Apple 활성화·SHA 4종·URL Scheme 완료. Play 앱서명 SHA 추가 등록만 남음 |
| **웹 HTTPS** | ⏳ 미완 | 현재 8088 HTTP만, 443 인증서 미설정 |
| **앱 스토어 URL** | ⏳ 미완 | 웹 `appStoreUrl='#'` (iOS 출시 후 교체) |
| **스토어 등록정보·심사** | ⏳ 미완 | 스크린샷·등급·데이터보안·제출 |
| **웹 대시보드 외부 연동** | ⏳ 선택 | OAuth/Play/GA4 자격증명(미설정 시 데모데이터) |

**종합:** 코드·형상관리·빌드 인프라는 **모두 완료**. 남은 건 거의 전부 **외부 콘솔/계정 작업**(광고ID·스토어등록·HTTPS).

---

## 1. 게임앱 — 출시 직전 외부 연동

### 1-A. AdMob 광고 단위 ID 발급 → 코드 교체 ✅ 완료(2026-06-10)
- [x] 애벌레 전용 AdMob 앱 신규 생성: Android `~6305446676`, iOS `~3480511780`
  - ⚠️ 기존 코드의 `~2226160971`/배너 `/6781505112`는 "성경책 1일1장" 앱 것이었음 → 전면 교정
- [x] `lib/utils/ad_config.dart`의 `_prod*` 6개 모두 반영:
  - [x] `_prodBannerAndroid` = `/1032938698`
  - [x] `_prodInterstitialAndroid` = `/2011854152`
  - [x] `_prodRewardedAndroid` = `/2912996576`
  - [x] `_prodBannerIOS` = `/4589040322`
  - [x] `_prodInterstitialIOS` = `/5024154590`
  - [x] `_prodRewardedIOS` = `/5216601995`
- [x] `AndroidManifest.xml` 앱ID → `~6305446676`, `Info.plist` 앱ID → `~3480511780`
- [ ] AdMob 앱을 Play/App Store 앱과 "연결" (스토어 출시 후 처리)
- 검증: 릴리스 빌드에서 실광고 노출(본인 클릭 금지 — 정책 위반)

### 1-B. 인앱결제 상품 등록 ✅ 완료(2026-06-10)
- [x] Google Play Console → 일회성 제품 `remove_ads` (구입=비소비성, 옵션ID base, 173개국, **활성**)
- [x] App Store Connect → 인앱 구입 `remove_ads` (비소모성, Apple ID 6778679331, 175개국, 한국어 현지화, **제출 준비 중**)
- [x] 상품 ID가 코드(`PurchaseManager.removeAdsProductId = 'remove_ads'`)와 일치 확인 — 양쪽 정확히 일치
- [ ] 심사 제출 시 IAP 함께 제출 (Apple: 첫 IAP는 앱 1.0 빌드와 동시 제출 필수, 심사용 스크린샷 첨부)
- 📌 선행작업: Play 판매자 결제프로필 신설(업체명 김영식/명세서명 CATERPILLAR/하나은행 코드081 계좌...8007, 확인 대기중). Play 앱 생성+내부테스트 v1 게시. ASC 앱 생성(번들 com.pamp.caterpillarRun).

### 1-C. 소셜 로그인 활성화 ✅ 완료(2026-06-10)
- [x] Firebase Authentication → Google 로그인 활성화
- [x] Firebase Authentication → Apple 로그인 활성화 (iOS 네이티브, 서비스ID 불필요)
- [x] Android: 릴리스+디버그 **SHA-1/SHA-256** 4종 등록 → oauth_client 3개 생성
- [x] google-services.json/GoogleService-Info.plist 재다운로드 교체 (이전 oauth_client=[]→채워짐)
- [x] iOS: Info.plist에 CFBundleURLTypes로 REVERSED_CLIENT_ID URL Scheme 추가 (plutil 검증·일치 확인)
- [x] flutter analyze 0 issues. 코드는 Google/Apple만 사용(이메일 미사용=의도)
- [x] **Play 앱서명 키 SHA를 Firebase에 추가 등록(2026-06-10)** — 앱서명키 SHA-1 C9:EE…/SHA-256 69:7F… 등록(총 6개). google-services.json 재다운로드 교체(oauth_client 3→4). 정식 배포본 Google 로그인 OK
- 검증: 로그인 → 게임오버 랭킹 등록 → 메뉴 '랭킹'에서 확인 (실기 테스트 필요)

### 1-D. Firestore 보안 규칙 ⏳
- [ ] Firestore 생성 + `firestore.rules` 적용 (이미 파일 존재, 콘솔 배포 확인)

---

## 2. 웹 (caterpillar-web) — 배포·연동

### 2-A. HTTPS 전환 ⏳
- [ ] `test.caterpillrun.com` 443 포트 HTTPS(Let's Encrypt 인증서) 설정
  - 현재: 8088 HTTP만 응답(200), 443은 인증서 미설정
- [ ] 운영 도메인 DNS A 레코드 확인
- [ ] (선택) 8088 → 80/443 전환

### 2-B. 스토어 URL 교체 ⏳
- [ ] iOS 출시 후 `src/lib/gameInfo.ts`의 `appStoreUrl='#'`을 실제 App Store URL로 교체
  - ℹ️ `playStoreUrl`은 이미 패키지 기반 URL로 설정됨

### 2-C. 대시보드 외부 연동 ⏳ (선택 — 미설정 시 데모 데이터)
> `caterpillar-web/.env.local`에 입력 후 `docker compose up -d --force-recreate app`
- [ ] AdMob 수익: `GOOGLE_OAUTH_CLIENT_ID/SECRET/REFRESH_TOKEN` (현재 빈 값)
- [ ] 스토어 지표: `GOOGLE_PLAY_SA_*`
- [ ] 게임 분석: `GA4_PROPERTY_ID` + `GA4_SA_*`
- [ ] 랭킹: `FIREBASE_PROJECT_ID` + `FIREBASE_SA_*`
- ℹ️ `DASHBOARD_PASSWORD`·`GMAIL_*`은 이미 설정됨

---

## 3. 스토어 등록·심사 (메타데이터)

### 3-A. 개인정보처리방침 공개 URL ⏳
- [ ] 공개 URL 확정 — 후보: `docs/index.html` 배포 또는 웹 `/privacy`
  - ℹ️ 웹 `/privacy`는 이미 8088로 접근 가능(HTTPS 전환 후 그 URL 사용 권장)

### 3-B. Google Play 출시 ⏳
- [ ] Play Console 앱 생성(기본 언어 한국어)
- [ ] 앱 서명(업로드 키 `caterpillar-run-release.jks`)
- [ ] **광고ID 교체 후 AAB 재빌드** → 업로드
- [ ] 데이터 보안 양식 / 콘텐츠 등급 설문 / 타겟 연령(13세+)
- [ ] 개인정보처리방침 URL 입력
- [ ] 등록정보: 아이콘(512), 그래픽(1024×500), 스크린샷(폰 2~8장)
- [ ] 내부 테스트 → 비공개 테스트 → 프로덕션

### 3-C. App Store 출시 ⏳
- [ ] Apple Developer Program 인증서/프로비저닝
- [ ] App Store Connect 앱 생성(번들 `com.pamp.caterpillarRun`)
- [ ] **광고ID 교체 후 IPA 재빌드** → 업로드
- [ ] 앱 개인정보 보호(ATT 명시) / 연령 등급
- [ ] 스크린샷(6.7"/6.5"/5.5") / 개인정보처리방침 URL
- [ ] TestFlight → 심사 제출

---

## 4. 권장 작업 순서

1. ~~**AdMob 광고 ID 발급 → `ad_config.dart` 교체** (1-A)~~ ✅ 2026-06-10 완료
2. **IAP `remove_ads` 양 스토어 등록** (1-B) ← 다음 차례
3. **소셜 로그인 활성화 + SHA 지문 + iOS URL Scheme** (1-C, 1-D)
4. **웹 HTTPS 전환** (2-A) → 개인정보처리방침 공개 URL 확정 (3-A)
5. **광고ID 반영 릴리스 재빌드** (AAB/IPA)
6. **스토어 등록정보 작성 → 심사 제출** (3-B, 3-C)
7. iOS 출시 후 웹 `appStoreUrl` 교체 (2-B)
8. (여유 시) 웹 대시보드 외부 연동 (2-C)

---

## 5. 빠른 명령 참조

```bash
# 게임앱
cd /Volumes/DATA/000_Projects/flutter/caterpillar_run
flutter analyze && flutter test           # 그린 상태 확인
flutter build appbundle --release         # AAB (Play)
flutter build ipa --release               # IPA (App Store)

# 웹
cd /Volumes/DATA/000_Projects/caterpillar-web
npm run build && npm run start            # 로컬 검증
docker compose up -d --force-recreate app # 자격증명 반영 재기동
```

| 항목 | 값 |
|------|-----|
| Android 패키지 | `com.pamp.caterpillar_run` |
| iOS 번들 ID | `com.pamp.caterpillarRun` |
| 버전 | 1.0.0 (+1) |
| AdMob 앱 ID (Android) | `ca-app-pub-3568835154047233~6305446676` |
| AdMob 앱 ID (iOS) | `ca-app-pub-3568835154047233~3480511780` |
| Firebase 프로젝트 | `caterpillar-run-2026` |
| 문의 이메일 | kys7442@gmail.com |

---

## 6. 📝 최근 진행 로그 (최신순 — 작업 완료 시 여기 추가)

- **2026-06-10** — 두 프로젝트 출시 잔여 과제 전수 검증 후 본 마스터 체크리스트 신설.
  검증 결과 문서보다 진척 큼: git 커밋·Firebase 설정 파일(실값)·서명키·릴리스 산출물·웹 빌드 모두 완료 확인.
  남은 외부 작업: 광고ID 5종 / IAP등록 / 소셜로그인활성화 / 웹HTTPS / 스토어등록·심사.
