import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/skin_provider.dart';
import '../models/game_state.dart';
import 'caterpillar_widget.dart';
import 'obstacle_widget.dart';
import 'food_widget.dart';


/// 게임 보드 위젯
class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        if (gameProvider.state != GameState.playing) {
          return Container(
            color: gameProvider.levelConfig?.backgroundColor ?? Colors.green.shade50,
            child: const Center(
              child: Text('게임 준비 중...'),
            ),
          );
        }

        return RepaintBoundary(
          child: GestureDetector(
            onTapDown: (details) {
              // 터치한 좌표를 목표 지점으로 설정
              final RenderBox box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              gameProvider.setTargetPosition(localPosition);
            },
            child: Container(
              color: gameProvider.levelConfig?.backgroundColor ?? Colors.green.shade50,
              child: Stack(
                children: [
                  // 장애물 렌더링
                  RepaintBoundary(
                    child: Stack(
                      children: gameProvider.obstacles.map(
                        (obstacle) => ObstacleWidget(obstacle: obstacle),
                      ).toList(),
                    ),
                  ),
                  
                  // 먹이 렌더링
                  RepaintBoundary(
                    child: Stack(
                      children: gameProvider.foods.map(
                        (food) => FoodWidget(food: food),
                      ).toList(),
                    ),
                  ),
                  
                  // 애벌레 렌더링 (선택된 스킨 색 적용)
                  RepaintBoundary(
                    child: CaterpillarWidget(
                      segments: gameProvider.caterpillar,
                      direction: gameProvider.currentDirection,
                      frameCount: gameProvider.frameCount,
                      swatch: context.watch<SkinProvider>().selectedSkin.swatch,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}

