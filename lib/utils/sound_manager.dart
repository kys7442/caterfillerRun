import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사운드 관리 클래스
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _isBgmPlaying = false;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get isBgmPlaying => _isBgmPlaying;

  /// 초기화 및 설정 로드
  Future<void> initialize() async {
    await _loadSettings();
  }

  /// 설정 로드
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _musicEnabled = prefs.getBool('music_enabled') ?? true;
    } catch (e) {
      // 기본값 사용
    }
  }

  /// 설정 저장
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('music_enabled', _musicEnabled);
    } catch (e) {
      // 저장 실패 무시
    }
  }

  /// 배경음악 재생
  Future<void> playBgm(String assetPath, {bool loop = true}) async {
    if (!_musicEnabled) return;
    
    try {
      if (_isBgmPlaying) {
        await _bgmPlayer.stop();
      }
      
      await _bgmPlayer.play(AssetSource(assetPath));
      if (loop) {
        _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      }
      _isBgmPlaying = true;
    } catch (e) {
      // 배경음악 재생 실패 무시 (리소스가 없을 수 있음)
    }
  }

  /// 배경음악 정지
  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _isBgmPlaying = false;
    } catch (e) {
      // 정지 실패 무시
    }
  }

  /// 배경음악 일시정지
  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      // 일시정지 실패 무시
    }
  }

  /// 배경음악 재개
  Future<void> resumeBgm() async {
    if (!_musicEnabled) return;
    try {
      await _bgmPlayer.resume();
    } catch (e) {
      // 재개 실패 무시
    }
  }

  /// 효과음 재생
  Future<void> playSfx(String assetPath) async {
    if (!_soundEnabled) return;
    
    try {
      await _sfxPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
    } catch (e) {
      // 효과음 재생 실패 무시 (리소스가 없을 수 있음)
    }
  }

  /// 사운드 on/off
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await _saveSettings();
  }

  /// 배경음악 on/off
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    await _saveSettings();
    
    if (!enabled) {
      await stopBgm();
    } else if (!_isBgmPlaying) {
      // 배경음악이 꺼져있었다가 켜지면 재생
      await playBgm('sounds/bgm.mp3');
    }
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await _bgmPlayer.dispose();
    await _sfxPlayer.dispose();
  }
}

