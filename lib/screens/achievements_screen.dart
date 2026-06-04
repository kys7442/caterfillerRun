import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';

/// 업적 목록 화면
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AchievementProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('🏅 업적 (${prov.unlockedCount}/${prov.totalCount})'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: kAchievements.length,
        separatorBuilder: (_, i) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final a = kAchievements[i];
          final unlocked = prov.isUnlocked(a.id);
          final progress = prov.progressOf(a);
          final current = prov.currentValueOf(a);

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: unlocked ? Colors.amber.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: unlocked ? Colors.amber.shade300 : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: unlocked
                        ? Colors.amber.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    unlocked ? a.icon : Icons.lock,
                    color: unlocked ? Colors.amber.shade700 : Colors.grey,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                // 본문
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: unlocked
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text('${a.rewardCoins}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 6),
                      // 진행도 바
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(
                            unlocked ? Colors.amber : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        unlocked ? '달성 완료!' : '$current / ${a.target}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
