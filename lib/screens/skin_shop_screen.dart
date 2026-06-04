import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/skin.dart';
import '../providers/skin_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/achievement_provider.dart';
import '../utils/sound_manager.dart';

/// 스킨 상점/선택 화면
class SkinShopScreen extends StatefulWidget {
  const SkinShopScreen({super.key});

  @override
  State<SkinShopScreen> createState() => _SkinShopScreenState();
}

class _SkinShopScreenState extends State<SkinShopScreen> {
  @override
  void initState() {
    super.initState();
    // 업적으로 언락되는 스킨 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ach = context.read<AchievementProvider>();
      context.read<SkinProvider>().unlockByAchievements(ach.unlocked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final skinProv = context.watch<SkinProvider>();
    final coins = context.watch<CurrencyProvider>().coins;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎨 애벌레 꾸미기'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('$coins',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: kSkins.length,
        itemBuilder: (context, i) {
          final skin = kSkins[i];
          final owned = skinProv.isOwned(skin.id);
          final selected = skinProv.selectedId == skin.id;

          return _SkinCard(
            skin: skin,
            owned: owned,
            selected: selected,
            onTap: () => _onTap(context, skin, owned, selected),
          );
        },
      ),
    );
  }

  Future<void> _onTap(
      BuildContext context, Skin skin, bool owned, bool selected) async {
    final skinProv = context.read<SkinProvider>();

    if (owned) {
      if (!selected) await skinProv.select(skin.id);
      return;
    }

    // 업적 언락 전용 스킨인데 미보유 → 안내
    if (skin.price <= 0 && skin.unlockAchievementId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('특정 업적을 달성하면 얻을 수 있어요!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 코인 구매 시도
    final ok = await skinProv.buy(skin);
    if (!context.mounted) return;
    if (ok) {
      SoundManager().playSfx('sounds/coin.mp3');
      await skinProv.select(skin.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${skin.name}을(를) 구매했어요!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('코인이 부족해요 🪙'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _SkinCard extends StatelessWidget {
  final Skin skin;
  final bool owned;
  final bool selected;
  final VoidCallback onTap;

  const _SkinCard({
    required this.skin,
    required this.owned,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.green : Colors.grey.shade200,
            width: selected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // 미리보기 (애벌레 머리 모양 원)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [skin.swatch.shade400, skin.swatch.shade700],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: skin.swatch.shade300,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.sentiment_satisfied,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            Text(skin.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // 상태 표시
            _statusChip(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _statusChip() {
    if (selected) {
      return _chip('사용 중', Colors.green, Icons.check_circle);
    }
    if (owned) {
      return _chip('선택하기', Colors.blue, Icons.touch_app);
    }
    if (skin.price <= 0 && skin.unlockAchievementId != null) {
      return _chip('업적 잠금', Colors.grey, Icons.lock);
    }
    return _chip('${skin.price}', Colors.amber.shade700, Icons.monetization_on);
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}
