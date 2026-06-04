import 'package:flutter/material.dart';

/// 개인정보 처리방침 화면
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인정보 처리방침'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. 수집하는 정보',
              '본 앱("애벌레야 ! 어디가 ?")은 사용자의 개인정보를 직접 수집하지 않습니다.\n\n'
                  '다만, 광고 서비스(Google AdMob)를 통해 다음 정보가 자동으로 수집될 수 있습니다:\n'
                  '- 광고 식별자 (IDFA/GAID)\n'
                  '- 기기 정보 (기기 모델, OS 버전)\n'
                  '- 앱 사용 데이터 (광고 노출/클릭)',
            ),
            _buildSection(
              '2. 정보 이용 목적',
              '수집된 정보는 다음 목적으로만 사용됩니다:\n'
                  '- 맞춤형 광고 제공\n'
                  '- 광고 성과 분석',
            ),
            _buildSection(
              '3. 제3자 제공',
              '본 앱은 Google AdMob 광고 서비스를 사용합니다.\n'
                  'Google의 개인정보 처리방침은 아래를 참고하세요:\n'
                  'https://policies.google.com/privacy',
            ),
            _buildSection(
              '4. 데이터 저장',
              '게임 진행 데이터(점수, 레벨, 설정)는 기기 내에만 저장되며, '
                  '외부 서버로 전송되지 않습니다.',
            ),
            _buildSection(
              '5. 아동 보호',
              '본 앱은 13세 미만의 아동으로부터 의도적으로 개인정보를 수집하지 않습니다.',
            ),
            _buildSection(
              '6. 광고 추적 설정',
              'iOS 사용자는 앱 시작 시 표시되는 "앱 추적 허용" 팝업에서 광고 추적 여부를 선택할 수 있습니다.\n'
                  '설정 > 개인정보 보호 > 추적에서 언제든 변경할 수 있습니다.\n\n'
                  'Android 사용자는 설정 > Google > 광고에서 맞춤 광고를 관리할 수 있습니다.',
            ),
            _buildSection(
              '7. 문의',
              '개인정보 처리에 관한 문의사항은 아래로 연락해주세요:\n'
                  'kys7442@gmail.com',
            ),
            _buildSection(
              '8. 변경 사항',
              '본 방침은 2026년 3월 26일부터 시행됩니다.\n'
                  '방침이 변경될 경우 앱 업데이트를 통해 안내합니다.',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
