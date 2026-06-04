import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/sound_manager.dart';
import '../utils/purchase_manager.dart';
import '../utils/auth_service.dart';
import '../providers/score_provider.dart';
import '../widgets/login_sheet.dart';
import 'privacy_policy_screen.dart';

/// 설정 화면
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SoundManager _soundManager = SoundManager();
  bool _soundEnabled = true;
  bool _musicEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = _soundManager.soundEnabled;
      _musicEnabled = _soundManager.musicEnabled;
    });
  }

  /// 구매 복원: 로그인을 먼저 유도한 뒤(계정 연결) 스토어 복원을 실행한다.
  /// 로그인 기능이 없거나 사용자가 건너뛰어도 스토어 기반 복원은 진행한다.
  Future<void> _restoreWithLogin(PurchaseManager pm) async {
    if (!AuthService.instance.isSignedIn) {
      await showLoginSheet(
        context,
        reason: '구매 내역을 계정에 연결하면 기기를 바꿔도 복원할 수 있어요.',
      );
    }
    await pm.restorePurchases();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('구매 복원을 요청했어요.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 광고 제거 구매/복원 섹션
  Widget _buildRemoveAdsSection() {
    return Consumer<PurchaseManager>(
      builder: (context, pm, _) {
        // 이미 구매 완료한 경우
        if (pm.isAdRemoved) {
          return Card(
            color: Colors.green.shade50,
            child: const ListTile(
              leading: Icon(Icons.verified, color: Colors.green),
              title: Text('광고가 제거되었습니다',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('구매해 주셔서 감사합니다! 모든 배너/전면광고가 사라집니다.'),
            ),
          );
        }

        final pending = pm.isPurchasePending;

        return Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.block, color: Colors.red.shade400),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '광고 없이 깔끔하게 즐기기',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '배너 및 전면광고가 모두 제거됩니다. (보상형 광고는 직접 선택 시에만 노출)',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (pending || !pm.isAvailable)
                            ? null
                            : () => pm.buyRemoveAds(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: pending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.shopping_cart),
                        label: Text(
                          pm.isAvailable
                              ? '광고 제거 ${pm.removeAdsPriceLabel}'
                              : '스토어 사용 불가',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: pending ? null : () => _restoreWithLogin(pm),
              icon: const Icon(Icons.restore, size: 18),
              label: const Text('구매 복원'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'kys7442@gmail.com',
      queryParameters: {
        'subject': '[애벌레야 어디가?] 문의',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 계정 (로그인)
          const Text(
            '계정',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const _AccountSection(),
          const SizedBox(height: 32),

          // 닉네임 설정 (랭킹 제출용)
          const Text(
            '랭킹 닉네임',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const _NicknameField(),
          const SizedBox(height: 32),

          // 사운드 설정
          const Text(
            '사운드 설정',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('효과음'),
            subtitle: const Text('게임 효과음 재생'),
            value: _soundEnabled,
            onChanged: (value) async {
              setState(() { _soundEnabled = value; });
              await _soundManager.setSoundEnabled(value);
            },
            secondary: Icon(
              _soundEnabled ? Icons.volume_up : Icons.volume_off,
              color: Colors.green.shade700,
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('배경음악'),
            subtitle: const Text('게임 배경음악 재생'),
            value: _musicEnabled,
            onChanged: (value) async {
              setState(() { _musicEnabled = value; });
              await _soundManager.setMusicEnabled(value);
            },
            secondary: Icon(
              _musicEnabled ? Icons.music_note : Icons.music_off,
              color: Colors.green.shade700,
            ),
          ),

          const SizedBox(height: 32),

          // 광고 제거 (인앱 결제)
          const Text(
            '광고 제거',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildRemoveAdsSection(),

          const SizedBox(height: 32),

          // 정보 및 법적 사항
          const Text(
            '정보',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _SettingsTile(
            icon: Icons.privacy_tip,
            title: '개인정보 처리방침',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
              );
            },
          ),
          _SettingsTile(
            icon: Icons.email,
            title: '문의하기',
            subtitle: 'kys7442@gmail.com',
            onTap: _sendEmail,
          ),
          _SettingsTile(
            icon: Icons.description,
            title: '오픈소스 라이선스',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: '애벌레야 ! 어디가 ?',
                applicationVersion: '1.0.0',
              );
            },
          ),

          const SizedBox(height: 32),

          // 게임 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '애벌레야 ! 어디가 ?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text('Caterpillar Run'),
                  const SizedBox(height: 4),
                  Text('버전 1.0.0', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 계정(로그인/로그아웃) 섹션
class _AccountSection extends StatelessWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isSignedIn) {
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade100,
                child: Icon(Icons.person, color: Colors.green.shade700),
              ),
              title: Text(
                auth.displayName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('로그인됨 · 랭킹 등록 가능'),
              trailing: TextButton(
                onPressed: () => auth.signOut(),
                child: const Text('로그아웃'),
              ),
            ),
          );
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '로그인하면 글로벌 랭킹 등록과 구매 복원을 사용할 수 있어요.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => showLoginSheet(context),
                    icon: const Icon(Icons.login),
                    label: const Text('로그인'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 랭킹 닉네임 입력 필드
class _NicknameField extends StatefulWidget {
  const _NicknameField();

  @override
  State<_NicknameField> createState() => _NicknameFieldState();
}

class _NicknameFieldState extends State<_NicknameField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final current = context.read<ScoreProvider>().nickname;
    _controller = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<ScoreProvider>().setNickname(_controller.text);
    if (mounted) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임이 저장되었습니다.'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: '랭킹에 표시될 이름',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onSubmitted: (_) => _save(),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: const Text('저장'),
        ),
      ],
    );
  }
}

/// 설정 항목 타일
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.green.shade700),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!, style: TextStyle(color: Colors.grey.shade600)) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
