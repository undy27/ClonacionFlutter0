import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _menuPlayer = AudioPlayer();
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  Future<void> playMenuButton() async {
    try {
      if (_menuPlayer.state == PlayerState.playing) {
        await _menuPlayer.stop();
      }
      
      // Ensure player releases resources after playing
      await _menuPlayer.setReleaseMode(ReleaseMode.stop);
      
      debugPrint('SoundManager: Playing menu sound...');
      await _menuPlayer.play(AssetSource('sonidos/menu/menu.1.wav'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error playing menu sound: $e');
    }
  }

  Future<void> playBackgroundMusic({bool musicEnabled = true}) async {
    try {
      if (!musicEnabled) {
        debugPrint('SoundManager: Music is disabled in settings');
        return;
      }

      if (_isMusicPlaying) {
        debugPrint('SoundManager: Background music already playing');
        return;
      }

      debugPrint('SoundManager: Starting background music...');
      
      // Configure audio context for Android to continue playing in background
      await _backgroundMusicPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: [AVAudioSessionOptions.mixWithOthers],
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundMusicPlayer.setVolume(0.5); // 50% volume for background music
      await _backgroundMusicPlayer.play(
        AssetSource('musica/M.1.mp3'),
        mode: PlayerMode.mediaPlayer, // Use mediaPlayer mode for background music
      );
      _isMusicPlaying = true;
      debugPrint('SoundManager: Background music started');
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      if (!_isMusicPlaying) {
        return;
      }

      debugPrint('SoundManager: Stopping background music...');
      await _backgroundMusicPlayer.stop();
      _isMusicPlaying = false;
      debugPrint('SoundManager: Background music stopped');
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }
  
  void dispose() {
    _menuPlayer.dispose();
    _backgroundMusicPlayer.dispose();
  }
}
