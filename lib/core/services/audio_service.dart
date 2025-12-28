import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  Future<void> playAlertSound() async {
    print('🔊 AUDIO: Reproduciendo sonido de error...');

    try {
      // Crear nueva instancia cada vez para evitar timeout
      final AudioPlayer player = AudioPlayer();

      await player.setVolume(1.0);
      await player.setPlayerMode(PlayerMode.lowLatency);

      // Sonido de error que funciona
      const String errorSound =
          'https://www.soundjay.com/misc/sounds/fail-buzzer-02.wav';
      await player.play(UrlSource(errorSound));

      print('🔊 AUDIO: ✅ Sonido reproducido');

      // Limpiar después de usar
      await Future.delayed(const Duration(seconds: 2));
      await player.dispose();
    } catch (e) {
      print('🔊 AUDIO ERROR: $e');
    }
  }

  Future<void> playClickSound() async {
    await HapticFeedback.lightImpact();
  }

  void dispose() {
    // Ya no necesitamos dispose global
  }
}
