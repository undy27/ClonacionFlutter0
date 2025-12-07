import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _menuPlayer = AudioPlayer();

  Future<void> playMenuButton() async {
    try {
      if (_menuPlayer.state == PlayerState.playing) {
        await _menuPlayer.stop();
      }
      // Use mediaPlayer mode for better compatibility on Android 
      await _menuPlayer.play(AssetSource('sonidos/menu/menu.1.wav'), mode: PlayerMode.mediaPlayer);
    } catch (e) {
      debugPrint('Error playing menu sound: $e');
    }
  }
  
  void dispose() {
    _menuPlayer.dispose();
  }
}
