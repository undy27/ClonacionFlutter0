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
      // TEST: Usamos el sonido de descarte que sabemos que funciona para descartar problema de código
      debugPrint('SoundManager: Playing TEST sound (correct discard)...');
      await _menuPlayer.play(AssetSource('sonidos/descartes/correcto/correcto.1.wav'), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Error playing menu sound: $e');
    }
  }
  
  void dispose() {
    _menuPlayer.dispose();
  }
}
