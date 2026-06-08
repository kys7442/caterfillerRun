import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food.dart';

/// 특수 먹이를 '생애 최초로' 먹었을 때 한 번만 띄우는 안내 팝업.
///
/// - 종류별로 1회만 노출되며, 본 적이 있으면 [hasSeen]이 true를 돌려준다.
/// - 노출 동안 게임은 일시정지되고, '확인'을 누르면 닫혀 이어서 플레이한다.
/// - 비주얼 톤은 스테이지 완료(LevelUpScreen)와 통일감을 맞춘다.
class SpecialFoodIntro {
  SpecialFoodIntro._();

  static String _key(FoodType type) => 'seen_special_${type.name}';

  /// 해당 특수 먹이 안내를 이미 본 적이 있는지.
  static Future<bool> hasSeen(FoodType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(type)) ?? false;
  }

  /// 안내를 봤다고 기록한다(이후 다시 뜨지 않음).
  static Future<void> markSeen(FoodType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(type), true);
  }
}

/// 특수 먹이 최초 획득 안내 다이얼로그 위젯.
class SpecialFoodIntroDialog extends StatefulWidget {
  final FoodType type;

  const SpecialFoodIntroDialog({super.key, required this.type});

  @override
  State<SpecialFoodIntroDialog> createState() => _SpecialFoodIntroDialogState();
}

class _SpecialFoodIntroDialogState extends State<SpecialFoodIntroDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 색/아이콘/설명은 Food 모델을 단일 출처로 사용한다.
    final sample = Food(position: Offset.zero, type: widget.type);
    final info = sample.specialInfo!;
    final color = sample.color;
    final icon = sample.icon ?? Icons.auto_awesome;

    return Material(
      color: Colors.transparent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 어두운 오버레이
              Container(
                color: Colors.black.withValues(alpha: _fade.value * 0.7),
              ),
              Center(
                child: Opacity(
                  opacity: _fade.value,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.45),
                blurRadius: 30,
                spreadRadius: 4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 작은 안내 라벨
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '새로운 먹이 발견!',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 아이콘 원형
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 52, color: color),
              ),
              const SizedBox(height: 20),

              // 제목
              Text(
                info.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                info.description,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // 확인 버튼 → 닫고 이어서 플레이
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    '계속하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
