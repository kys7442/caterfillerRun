import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'providers/game_provider.dart';
import 'providers/score_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/skin_provider.dart';
import 'screens/menu_screen.dart';
import 'screens/tutorial_screen.dart';
import 'utils/ad_config.dart';
import 'utils/ad_manager.dart';
import 'utils/purchase_manager.dart';
import 'utils/sound_manager.dart';
import 'utils/firebase_service.dart';
import 'utils/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS: 앱 추적 투명성 (ATT) 요청
  if (Platform.isIOS) {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // 약간의 딜레이 후 요청 (iOS 권장)
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('ATT request failed: $e');
    }
  }

  // Firebase 초기화 (분석/랭킹/인증). 설정 파일이 없으면 내부에서 비활성화 처리.
  await FirebaseService.instance.initialize();
  AuthService.instance.initialize();

  // 인앱 결제 초기화 (광고 제거 상태를 먼저 알아야 광고 노출 여부 결정 가능)
  try {
    await PurchaseManager.instance.initialize();
  } catch (e) {
    debugPrint('PurchaseManager initialization failed: $e');
  }

  // AdMob 초기화
  try {
    await AdConfig.initialize();
    // 광고를 제거하지 않은 사용자에게만 전면/보상형 광고를 미리 로드
    if (!PurchaseManager.instance.isAdRemoved) {
      AdManager.instance.preload();
    }
  } catch (e) {
    debugPrint('AdMob initialization failed: $e');
  }

  // 사운드 매니저 초기화
  try {
    await SoundManager().initialize();
  } catch (e) {
    debugPrint('Sound manager initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final CurrencyProvider _currency;
  late final AchievementProvider _achievements;
  late final SkinProvider _skins;

  @override
  void initState() {
    super.initState();
    _currency = CurrencyProvider();
    _achievements = AchievementProvider();
    _skins = SkinProvider();
    // 업적 보상을 코인으로 지급, 스킨 구매에 코인 사용하기 위해 연결
    _achievements.attachCurrency(_currency);
    _skins.attachCurrency(_currency);
  }

  @override
  void dispose() {
    _currency.dispose();
    _achievements.dispose();
    _skins.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ScoreProvider()),
        ChangeNotifierProvider.value(value: _currency),
        ChangeNotifierProvider.value(value: _achievements),
        ChangeNotifierProvider.value(value: _skins),
        // 광고 제거 구매 상태를 UI 전역에서 구독
        ChangeNotifierProvider.value(value: PurchaseManager.instance),
        // 로그인 상태를 UI 전역에서 구독
        ChangeNotifierProvider.value(value: AuthService.instance),
      ],
      child: MaterialApp(
        title: 'Caterpillar Run',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const _RootGate(),
      ),
    );
  }
}

/// 첫 실행이면 튜토리얼, 그 외엔 바로 메뉴로 진입시키는 게이트.
class _RootGate extends StatefulWidget {
  const _RootGate();

  @override
  State<_RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<_RootGate> {
  bool? _showTutorial; // null = 판정 전

  @override
  void initState() {
    super.initState();
    TutorialScreen.hasSeen().then((seen) {
      if (mounted) setState(() => _showTutorial = !seen);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showTutorial == null) {
      // 판정 중 — 짧은 로딩
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_showTutorial!) {
      return TutorialScreen(
        onFinish: () => setState(() => _showTutorial = false),
      );
    }
    return const MenuScreen();
  }
}
