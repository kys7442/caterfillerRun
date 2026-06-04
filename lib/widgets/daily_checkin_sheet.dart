import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';
import '../utils/sound_manager.dart';

/// 일일 출석 보상 시트. 오늘 보상을 수령하고 연속 출석 현황을 보여준다.
Future<void> showDailyCheckInSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _CheckInSheet(),
  );
}

class _CheckInSheet extends StatefulWidget {
  const _CheckInSheet();

  @override
  State<_CheckInSheet> createState() => _CheckInSheetState();
}

class _CheckInSheetState extends State<_CheckInSheet> {
  int? _justEarned;

  @override
  Widget build(BuildContext context) {
    final cur = context.watch<CurrencyProvider>();
    final now = DateTime.now();
    final canCheckIn = cur.canCheckIn(now);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
          const Text('🎁 일일 출석',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('연속 ${cur.streak}일 출석 중',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 20),

          // 7일 보상 미리보기
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = i + 1;
              final reward = cur.rewardForStreak(day);
              final isToday = canCheckIn && ((cur.streak % 7) + 1) == day;
              final claimed = (cur.streak % 7) >= day && !canCheckIn ||
                  (cur.streak % 7) >= day;
              return Container(
                width: 40,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? Colors.amber.shade100
                      : claimed
                          ? Colors.green.shade50
                          : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isToday ? Colors.amber : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text('$day일',
                        style: const TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    const Icon(Icons.monetization_on,
                        color: Colors.amber, size: 16),
                    Text('$reward', style: const TextStyle(fontSize: 10)),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          if (_justEarned != null)
            Text('🪙 +$_justEarned 코인 획득!',
                style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          else
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canCheckIn
                    ? () async {
                        final earned = await context
                            .read<CurrencyProvider>()
                            .checkIn(DateTime.now());
                        SoundManager().playSfx('sounds/coin.mp3');
                        if (mounted) setState(() => _justEarned = earned);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Text(
                  canCheckIn ? '출석 보상 받기' : '오늘은 이미 받았어요',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text('보유 코인: ${cur.coins} 🪙',
              style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
