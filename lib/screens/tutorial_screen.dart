import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 첫 실행 온보딩 튜토리얼. 조작법/콤보/특수먹이를 페이지로 안내한다.
/// 1회성: 완료/건너뛰기 시 다시 표시되지 않는다.
class TutorialScreen extends StatefulWidget {
  /// 완료 후 콜백 (게임 시작 등)
  final VoidCallback onFinish;

  const TutorialScreen({super.key, required this.onFinish});

  static const String _kSeenKey = 'tutorial_seen';

  /// 튜토리얼을 본 적 있는지
  static Future<bool> hasSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSeenKey) ?? false;
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSeenKey, true);
  }

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _page = 0;

  final _pages = const [
    _TutorialPage(
      icon: Icons.touch_app,
      title: '터치로 조종해요',
      description: '화면을 터치한 곳으로 애벌레가 이동합니다.\n벽과 장애물, 자기 몸을 피하세요!',
      color: Colors.green,
    ),
    _TutorialPage(
      icon: Icons.local_fire_department,
      title: '콤보를 노려요',
      description: '먹이를 빠르게 연속으로 먹으면\n점수가 x1.5 → x2 → x3로 올라가요!',
      color: Colors.orange,
    ),
    _TutorialPage(
      icon: Icons.auto_awesome,
      title: '특수 먹이를 모아요',
      description: '⭐골드(고득점) 🛡방패(충돌 방어)\n⏳슬로우 ⚡더블점수! 색깔 먹이를 노리세요.',
      color: Colors.purple,
    ),
    _TutorialPage(
      icon: Icons.emoji_events,
      title: '도전하고 꾸며요',
      description: '랭킹·업적에 도전하고\n모은 코인으로 애벌레를 꾸며보세요!',
      color: Colors.blue,
    ),
  ];

  Future<void> _finish() async {
    await TutorialScreen.markSeen();
    if (mounted) widget.onFinish();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 건너뛰기
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('건너뛰기'),
              ),
            ),
            // 페이지
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: _pages,
              ),
            ),
            // 인디케이터
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.green : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLast) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast ? '시작하기!' : '다음',
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final MaterialColor color;

  const _TutorialPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: color.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64, color: color.shade400),
          ),
          const SizedBox(height: 36),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
                fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
