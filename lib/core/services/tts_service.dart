import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;
  String _currentLanguage = 'en-US';

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _tts.setLanguage(_currentLanguage);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.45);

      _isInitialized = true;
    } catch (e) {
      print('Error initializing TTS: $e');
    }
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await initialize();
    if (_isSpeaking) await stop();

    try {
      _isSpeaking = true;
      await _tts.speak(text);

      // Set up completion handler
      _tts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _tts.setErrorHandler((error) {
        _isSpeaking = false;
        print('TTS error: $error');
      });
    } catch (e) {
      _isSpeaking = false;
      print('Error speaking text: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      _isSpeaking = false;
    } catch (e) {
      print('Error stopping TTS: $e');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      await _tts.setLanguage(languageCode);
      _currentLanguage = languageCode;
    } catch (e) {
      print('Error setting TTS language: $e');
    }
  }

  Future<void> setRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting TTS rate: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _tts.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting TTS volume: $e');
    }
  }
}
