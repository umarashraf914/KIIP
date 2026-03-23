import 'package:flutter_tts/flutter_tts.dart';
import 'settings_service.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();
  final SettingsService _settings;
  bool _initialized = false;

  TtsService(this._settings);

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(_settings.ttsSpeed);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    await _ensureInit();
    await _tts.setSpeechRate(_settings.ttsSpeed);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }

  void dispose() {
    _tts.stop();
  }
}
