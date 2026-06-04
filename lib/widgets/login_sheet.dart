import 'package:flutter/material.dart';
import '../utils/auth_service.dart';
import '../utils/firebase_service.dart';

/// 소셜 로그인 바텀시트. 로그인 성공 시 true 반환.
///
/// 사용: `final ok = await showLoginSheet(context);`
Future<bool> showLoginSheet(BuildContext context, {String? reason}) async {
  // Firebase 미설정이면 로그인 자체가 불가 → 안내만
  if (!FirebaseService.instance.isEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('로그인 기능은 곧 제공될 예정이에요.'),
        duration: Duration(seconds: 2),
      ),
    );
    return false;
  }

  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _LoginSheet(reason: reason),
  );
  return result ?? false;
}

class _LoginSheet extends StatefulWidget {
  final String? reason;
  const _LoginSheet({this.reason});

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  bool _loading = false;

  Future<void> _run(Future<bool> Function() action) async {
    setState(() => _loading = true);
    final ok = await action();
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인에 실패했어요. 다시 시도해 주세요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('로그인',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            widget.reason ?? '랭킹 등록과 구매 복원을 위해 로그인해 주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else ...[
            // Google 로그인
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _run(auth.signInWithGoogle),
                icon: const Icon(Icons.login, color: Colors.red),
                label: const Text('Google로 계속하기',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            // Apple 로그인 (iOS/macOS)
            if (auth.isAppleAvailable) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _run(auth.signInWithApple),
                  icon: const Icon(Icons.apple),
                  label: const Text('Apple로 계속하기',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ],
          const SizedBox(height: 16),
          Text(
            '로그인 없이도 게임은 자유롭게 즐길 수 있어요.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
