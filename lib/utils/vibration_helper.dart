import 'package:flutter/services.dart';
import 'dart:io';

/// 진동 헬퍼 클래스
class VibrationHelper {
  static final VibrationHelper _instance = VibrationHelper._internal();
  factory VibrationHelper() => _instance;
  VibrationHelper._internal();

  bool _vibrationEnabled = true;

  bool get vibrationEnabled => _vibrationEnabled;
  
  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
  }

  /// 짧은 진동 (충돌, 버튼 클릭 등)
  Future<void> lightImpact() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (Platform.isAndroid) {
        await HapticFeedback.lightImpact();
      } else if (Platform.isIOS) {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      // 진동 실패 무시
    }
  }

  /// 중간 진동 (레벨 업 등)
  Future<void> mediumImpact() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (Platform.isAndroid) {
        await HapticFeedback.mediumImpact();
      } else if (Platform.isIOS) {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // 진동 실패 무시
    }
  }

  /// 강한 진동 (게임 오버 등)
  Future<void> heavyImpact() async {
    if (!_vibrationEnabled) return;
    
    try {
      if (Platform.isAndroid) {
        await HapticFeedback.heavyImpact();
      } else if (Platform.isIOS) {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // 진동 실패 무시
    }
  }
}

