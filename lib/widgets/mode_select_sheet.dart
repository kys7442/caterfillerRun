import 'package:flutter/material.dart';
import '../models/game_state.dart';

/// 게임 모드 선택 바텀시트. 선택한 [GameMode]를 반환(취소 시 null).
Future<GameMode?> showModeSelectSheet(BuildContext context) {
  return showModalBottomSheet<GameMode>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const _ModeSelectSheet(),
  );
}

class _ModeSelectSheet extends StatelessWidget {
  const _ModeSelectSheet();

  @override
  Widget build(BuildContext context) {
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
          const Text('모드 선택',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _ModeCard(
            mode: GameMode.stage,
            icon: Icons.flag,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            mode: GameMode.timeAttack,
            icon: Icons.hourglass_bottom,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _ModeCard(
            mode: GameMode.endless,
            icon: Icons.all_inclusive,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final GameMode mode;
  final IconData icon;
  final MaterialColor color;

  const _ModeCard({
    required this.mode,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.pop(context, mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color.shade700, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mode.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mode.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.shade300),
          ],
        ),
      ),
    );
  }
}
