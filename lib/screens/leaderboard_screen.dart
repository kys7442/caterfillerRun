import 'package:flutter/material.dart';
import '../utils/firebase_service.dart';

/// 글로벌 랭킹 화면 (Firestore 기반).
/// Firebase 미설정 시 안내 메시지를 표시한다.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<LeaderboardEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = FirebaseService.instance.fetchTopScores(limit: 50);
  }

  void _refresh() {
    setState(() {
      _future = FirebaseService.instance.fetchTopScores(limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = FirebaseService.instance.isEnabled;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 글로벌 랭킹'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: enabled ? _refresh : null,
          ),
        ],
      ),
      body: !enabled
          ? _buildDisabled()
          : FutureBuilder<List<LeaderboardEntry>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final entries = snapshot.data ?? [];
                if (entries.isEmpty) {
                  return const Center(
                    child: Text('아직 등록된 기록이 없어요.\n첫 도전자가 되어보세요!',
                        textAlign: TextAlign.center),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: entries.length,
                  separatorBuilder: (_, i) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final e = entries[i];
                    return _RankTile(rank: i + 1, entry: e);
                  },
                );
              },
            ),
    );
  }

  Widget _buildDisabled() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '랭킹 기능 준비 중',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              '온라인 랭킹은 곧 제공될 예정이에요.\n그동안 최고 기록에 도전해 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _RankTile({required this.rank, required this.entry});

  String get _medal {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    return Container(
      color: isTop3 ? Colors.amber.withValues(alpha: 0.08) : null,
      child: ListTile(
        leading: SizedBox(
          width: 36,
          child: Center(
            child: Text(
              _medal,
              style: TextStyle(
                fontSize: isTop3 ? 22 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
        title: Text(entry.nickname,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('스테이지 ${entry.level}'),
        trailing: Text(
          '${entry.score}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
      ),
    );
  }
}
