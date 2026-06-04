import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/score_provider.dart';
import '../widgets/banner_ad_widget.dart';

/// 최근 기록 화면
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('최근 기록'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ScoreProvider>(
        builder: (context, scoreProvider, child) {
          final records = scoreProvider.recentRecords;
          final bestRecord = scoreProvider.bestRecord;

          if (records.isEmpty && bestRecord == null) {
            return const Center(
              child: Text(
                '기록이 없습니다.\n게임을 플레이해보세요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return Column(
            children: [
              // 최고 기록 표시
              if (bestRecord != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade300, Colors.amber.shade100],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '🏆 최고 기록',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '레벨 ${bestRecord.level}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '점수: ${bestRecord.score}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '생존 시간: ${bestRecord.survivalTime}초',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        bestRecord.formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              // 최근 기록 목록
              Expanded(
                child: records.isEmpty
                    ? const Center(
                        child: Text('최근 기록이 없습니다.'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade700,
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                '레벨 ${record.level}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('점수: ${record.score}'),
                                  Text('생존 시간: ${record.survivalTime}초'),
                                  Text(
                                    record.formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                            ),
                          );
                        },
                      ),
              ),

              // 하단 광고
              const BannerAdWidget(),
            ],
          );
        },
      ),
    );
  }
}

