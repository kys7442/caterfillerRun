# ▶️ 이어서 진행 (NEXT STEPS)

> 새 터미널/세션에서 작업을 이어갈 때 이 파일부터 읽으세요.
> 상세 현황은 `docs/PROJECT_STATUS.md`(내부 메모, Git 제외), 출시 절차는
> `GO_LIVE_CHECKLIST.md` · `RELEASE_CHECKLIST.md` · `FIREBASE_SETUP.md` 참고.
>
> 최종 갱신: 2026-06-08

---

## ✅ 최근 완료 (이번 작업분)

1. **Firebase 초기화 사전 전환** — `lib/firebase_options.dart`(자리표시 stub) 추가,
   `FirebaseService.initialize()`가 옵션이 있으면 사용하도록 변경.
   → 출시 직전 `flutterfire configure`만 실행하면 **코드 수정 없이** 정식 옵션 적용.
2. **특수 먹이 최초 획득 안내 팝업** — 골드/방패/슬로우/더블을 처음 먹으면
   게임을 잠시 멈추고 "짜잔" 설명 팝업 노출(종류별 1회). `SharedPreferences`로 영구 기록.
   - 신규: `lib/widgets/special_food_intro.dart`, `Food.specialInfo`(food.dart)
   - 연동: `game_screen.dart`의 `_handleEatEvent` → `_maybeShowSpecialIntro`
3. **STAGE CLEAR(레벨업) 화면에 '여기서 그만두기' 추가** — 기존엔 다음 스테이지로만
   진행 가능했음. 이제 기록 저장 후 메인 메뉴로 나갈 수 있음.
   - `level_up_screen.dart`: 버튼이 `pop(true/false)` 반환
   - `game_screen.dart`: `_showLevelUpScreen`이 결과를 받아 분기
4. **메인 화면 UI 전면 개편 (캐주얼 게임 레퍼런스 컨셉)** — 이미지 에셋 없이 CustomPaint로 구현.
   - `lib/widgets/festive_background.dart`: 하늘·구름·별빛·깃발 가랜드 정적 배경
   - `lib/widgets/caterpillar_mascot.dart`: 정면 애벌레 마스코트(굽이친 몸통·눈·미소·더듬이)
   - `lib/screens/menu_screen.dart`: 배경 + 마스코트 + 화려한 타이틀 + 큰 PLAY 버튼 + 보조 아이콘 줄로 교체
   - `lib/screens/splash_screen.dart`(신규): 동일 컨셉 스플래시 (2.2초 후 진입)
   - 네이티브 런치 화면을 하늘색(#3FA9F5)으로 통일 → 켤 때 흰 화면 깜빡임 제거
     (iOS `LaunchScreen.storyboard`, Android `launch_background.xml` 2종 + `colors.xml`)

검증: `flutter analyze` 이슈 0건 / `flutter test` 6개 통과 / iOS 시뮬레이터 빌드·실행 OK.

> 참고: 웹(`/Volumes/DATA/000_Projects/caterpillar-web`)도 동일 컨셉으로 메인 화면을 개편했으나,
> 해당 폴더에 자체 git이 없어(상위 폴더 저장소에 섞여 있고 리모트 없음) **커밋 보류** 상태.
> 변경 파일은 디스크에 보존됨: `src/components/CaterpillarMascot.tsx`,
> `src/components/FestiveBackground.tsx`, `src/app/page.tsx`, `src/app/globals.css`.

---

## ⏳ 남은 작업 — 모두 "출시 직전 외부 연동" (코드는 준비됨, 자격증명/ID만 입력)

> 아래는 모두 외부 콘솔/계정 작업이라 코드만으로 끝낼 수 없습니다.

| # | 영역 | 할 일 | 입력 위치 |
|---|------|-------|-----------|
| C | **AdMob 광고 ID** | `_prod*` 5개(iOS 배너, And/iOS 전면, And/iOS 보상형) 발급 후 교체 | `lib/utils/ad_config.dart` |
| D | **IAP 상품 등록** | Play Console·App Store Connect 양쪽에 `remove_ads` 등록 | (스토어 콘솔) |
| E | **Firebase 설정 파일** | `flutterfire configure` 실행 → 설정 3종 생성 (코드 수정 불필요) | 프로젝트 루트 |
| F | **소셜 로그인 활성화** | Google/Apple 활성화, 릴리스 키 SHA-1/256, iOS REVERSED_CLIENT_ID | Firebase 콘솔 + Xcode |
| G | **key.properties 값** | storePassword/keyPassword/keyAlias/storeFile 실제 값 입력 | `android/key.properties` |
| H | **개인정보처리방침 URL** | `docs/index.html` 배포 후 공개 URL 확보 | (웹 배포) |
| I | **스토어 등록정보** | 스크린샷, 아이콘(512), 설명, 콘텐츠 등급, 데이터 보안 양식 | (스토어 콘솔) |
| J | **빌드·업로드** | `flutter build appbundle --release` (AAB) / `flutter build ipa --release` (IPA) | — |
| K | **웹 대시보드 연동** | (별도 프로젝트 `caterpillar-web`) AdMob·Play·GA4·Firebase 자격증명 | `caterpillar-web/.env.local` |

---

## 💡 코드만으로 더 할 수 있는 후보 (선택)

- 튜토리얼 3페이지(특수 먹이 4종 압축)를 종류별로 분리해 더 친절하게.
- 특수 먹이 안내 팝업을 본 뒤에도 설정 화면 등에서 다시 볼 수 있는 '도움말' 진입점.
- 위젯/통합 테스트 보강 (현재는 모델 단위 테스트 6개).

---

## 🔁 재개 방법 (새 터미널)

```bash
cd /Volumes/DATA/000_Projects/flutter/caterpillar_run
flutter pub get
flutter analyze        # 이슈 0건이어야 정상
flutter test           # 6개 통과
# 시뮬레이터 실행 (디바이스 ID는 flutter devices로 확인)
flutter run -d <iPhone 시뮬레이터 ID>
#   r = 핫 리로드, R = 핫 리스타트(파일 추가/필드 변경 시), q = 종료
```
