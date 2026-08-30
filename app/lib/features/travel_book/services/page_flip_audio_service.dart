import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageFlipAudioService {
  final AudioPlayer _player = AudioPlayer(playerId: 'page_flip_audio');
  bool _enabled = true;
  static const String _prefKey = 'page_flip_sound_enabled';

  bool get enabled => _enabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_prefKey) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  Future<void> playFlip() async {
    if (!_enabled) return;
    try {
      await _player.stop();
      await _player.play(AssetSource('audio/page-flip-soft.mp3'));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PageFlipAudioService: failed to play flip sound: $e');
      }
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}

final pageFlipAudioServiceProvider = Provider<PageFlipAudioService>((ref) {
  final service = PageFlipAudioService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});
