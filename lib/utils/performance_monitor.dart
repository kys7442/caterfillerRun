import 'package:flutter/foundation.dart';

/// 성능 모니터링 유틸리티 (디버그 모드에서만 사용)
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  int _frameCount = 0;
  DateTime? _lastFrameTime;
  double _averageFPS = 60.0;
  final List<double> _fpsHistory = [];

  /// 프레임 업데이트
  void updateFrame() {
    if (!kDebugMode) return;

    final now = DateTime.now();
    if (_lastFrameTime != null) {
      final delta = now.difference(_lastFrameTime!).inMilliseconds;
      if (delta > 0) {
        final fps = 1000.0 / delta;
        _fpsHistory.add(fps);
        if (_fpsHistory.length > 60) {
          _fpsHistory.removeAt(0);
        }
        _averageFPS = _fpsHistory.reduce((a, b) => a + b) / _fpsHistory.length;
      }
    }
    _lastFrameTime = now;
    _frameCount++;
  }

  /// FPS 가져오기
  double get fps => _averageFPS;

  /// 리셋
  void reset() {
    _frameCount = 0;
    _lastFrameTime = null;
    _fpsHistory.clear();
    _averageFPS = 60.0;
  }

  /// 성능 정보 출력
  void printPerformanceInfo() {
    if (!kDebugMode) return;
    debugPrint('Performance: FPS=${_averageFPS.toStringAsFixed(1)}, Frames=$_frameCount');
  }
}

