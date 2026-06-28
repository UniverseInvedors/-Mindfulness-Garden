import 'package:flutter_tts/flutter_tts.dart';
import 'package:pranaverse/core/localization/app_copy.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// VoiceService — app-wide TTS singleton
//
// Speaks throughout the app. Carries Buddha-style wisdom phrases for the
// AI tutor. Call VoiceService().speak(...) from anywhere.
// ─────────────────────────────────────────────────────────────────────────────

enum VoicePersonality { buddha, zeno, monk }

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;
  bool _enabled = true;
  double _rate = 0.42;
  double _pitch = 0.85; // Slightly lower = more serene / authoritative
  final double _volume = 0.9;
  String _language = 'en-US';
  AppLanguage _appLanguage = AppLanguage.english;
  VoicePersonality _personality = VoicePersonality.buddha;

  VoicePersonality get personality => _personality;
  AppLanguage get appLanguage => _appLanguage;

  Future<void> setPersonality(VoicePersonality p) async {
    _personality = p;
    await LocalStorageService.saveSetting('voice_personality', p.name);
  }

  // ── Init ──────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // Load preferences
    final enabled = LocalStorageService.getSetting('voice_enabled');
    if (enabled is bool) _enabled = enabled;
    final rate = LocalStorageService.getSetting('voice_rate');
    if (rate is double) _rate = rate;

    final p = LocalStorageService.getSetting('voice_personality');
    if (p is String) {
      try {
        _personality = VoicePersonality.values.firstWhere((v) => v.name == p);
      } catch (_) {}
    }

    // Language is now managed by AppSettingsProvider, but we still need to initialize TTS
    _language = _getTtsLanguageCode(_appLanguage);

    // Resolve and apply best-available TTS language (with fallbacks)
    try {
      await setLanguage(_language);
    } catch (_) {
      // If setLanguage fails for any reason, ensure we have a working fallback
      _language = 'en-US';
      await _tts.setLanguage(_language);
    }
    await _tts.setSpeechRate(_rate);
    await _tts.setPitch(_pitch);
    await _tts.setVolume(_volume);
    await _tts.awaitSpeakCompletion(false); // non-blocking by default
  }

  // Update language from global provider
  Future<void> updateLanguage(AppLanguage language) async {
    _appLanguage = language;
    _language = _getTtsLanguageCode(language);
    await setLanguage(_language);
  }

  Future<void> setAppLanguage(AppLanguage language) => updateLanguage(language);

  String _getTtsLanguageCode(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'en-US';
      case AppLanguage.bengali:
        return 'bn-IN';
      case AppLanguage.hindi:
        return 'hi-IN';
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  /// Speak any text. Silently skips if voice is disabled.
  Future<void> speak(String text, {bool await_ = false}) async {
    if (!_enabled || text.isEmpty) return;
    await initialize();
    final spokenText = AppCopy.voice(_appLanguage, text);
    await _tts.stop();
    if (await_) {
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(spokenText);
      await _tts.awaitSpeakCompletion(false);
    } else {
      await _tts.speak(spokenText);
    }
  }

  Future<void> stop() async => _tts.stop();

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await LocalStorageService.saveSetting('voice_enabled', value);
    if (!value) await stop();
  }

  Future<void> setRate(double rate) async {
    _rate = rate.clamp(0.1, 1.0);
    await _tts.setSpeechRate(_rate);
    await LocalStorageService.saveSetting('voice_rate', _rate);
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
    await LocalStorageService.saveSetting('voice_pitch', _pitch);
  }

  Future<void> setLanguage(String lang) async {
    // Try to resolve a suitable TTS language variant supported by the engine.
    final resolved = await _resolveTtsLanguage(lang);
    _language = resolved;
    try {
      await _tts.setLanguage(resolved);
    } catch (e) {
      // As a last resort, fallback to English
      _language = 'en-US';
      try {
        await _tts.setLanguage(_language);
      } catch (_) {}
    }
  }

  // Attempt to find a suitable TTS language supported by the platform.
  Future<String> _resolveTtsLanguage(String lang) async {
    try {
      final langs = await _tts.getLanguages;
      if (langs == null || langs.isEmpty) return lang;

      // Exact match
      if (langs.contains(lang)) return lang;

      // Try code-only (e.g., "hi" for "hi-IN")
      final parts = lang.split('-');
      if (parts.isNotEmpty) {
        final codeOnly = parts.first;
        if (langs.contains(codeOnly)) return codeOnly;

        // Find any language that starts with the code
        for (final l in langs) {
          if (l.toLowerCase().startsWith(codeOnly.toLowerCase())) return l;
        }
      }

      // Try common fallbacks for Hindi/Bengali
      final lower = lang.toLowerCase();
      if (lower.startsWith('hi')) {
        if (langs.contains('hi-IN')) return 'hi-IN';
        if (langs.contains('hi')) return 'hi';
      }
      if (lower.startsWith('bn')) {
        if (langs.contains('bn-IN')) return 'bn-IN';
        if (langs.contains('bn')) return 'bn';
        if (langs.contains('bn-BD')) return 'bn-BD';
      }

      // Fallback to first available language that looks like the target
      for (final l in langs) {
        if (l.toLowerCase().contains('hi')) return l;
        if (l.toLowerCase().contains('bn')) return l;
      }

      // Finally, prefer English
      if (langs.contains('en-US')) return 'en-US';
      if (langs.contains('en')) return 'en';

      // Give up and return the requested value (will likely fail upstream)
      return lang;
    } catch (_) {
      return lang;
    }
  }

  bool get isEnabled => _enabled;
  double get rate => _rate;
  String get language => _language;

  // ── Buddha wisdom phrases ─────────────────────────────────────────────────
  // Used by the AI tutor throughout the app.

  static const List<String> breathingIntro = [
    "Welcome, seeker. I am here to guide you. Let us begin with the breath — the bridge between body and mind.",
    "Peace be with you. The breath is your anchor. Let us breathe together and find stillness.",
    "Greetings. The mind is like water — when still, it reflects all things clearly. Let us still the waters.",
  ];

  static const List<String> inhalePrompts = [
    "Breathe in... draw life into every cell.",
    "Inhale... feel the universe filling you.",
    "Breathe in deeply... you are receiving.",
  ];

  static const List<String> holdPrompts = [
    "Hold... rest in this moment of fullness.",
    "Be still... this is the space between worlds.",
    "Hold gently... neither grasping nor releasing.",
  ];

  static const List<String> exhalePrompts = [
    "Release... let go of all that does not serve you.",
    "Exhale... surrender what you cannot control.",
    "Breathe out... return to emptiness, which is fullness.",
  ];

  static const List<String> poseTransitions = [
    "Now we move into the next posture. Let the body follow the breath.",
    "Transition with awareness. Each movement is a meditation.",
    "Shift gently. The body is a temple — move within it with reverence.",
  ];

  static const List<String> sessionCompleteLines = [
    "You have done well, seeker. Carry this stillness into your day.",
    "The practice is complete. Remember — the peace you found here lives within you always.",
    "Well done. The lotus grows from mud, yet remains unstained. So too shall you.",
  ];

  static const List<String> encouragement = [
    "The mind wanders — this is its nature. Gently return, without judgment.",
    "There is no failure in practice. Only returning, again and again.",
    "You are exactly where you need to be.",
  ];

  static const Map<String, String> yogaPoseInstructions = {
    'Mountain Pose':
        "Stand as a mountain — rooted, immovable, yet open to the sky.",
    'Warrior I':
        "Be the warrior of peace. Ground your feet. Reach toward the heavens.",
    'Tree Pose':
        "Find your centre. The tree bends in the wind but its roots hold firm.",
    "Child's Pose":
        "Return to the earth. Rest here. You need not strive in this moment.",
    'Downward Dog':
        "Lengthen the spine. Let gravity do the work. Surrender to the pose.",
    'Lotus Meditation':
        "Sit in stillness. The lotus blooms in muddy water — so does wisdom.",
  };

  /// Speak a random phrase from a category.
  Future<void> speakRandom(List<String> phrases) async {
    if (phrases.isEmpty) return;
    final idx = DateTime.now().millisecond % phrases.length;
    await speak(phrases[idx]);
  }

  Future<void> speakBreathingIntro() =>
      speakRandom(AppCopy.list(_appLanguage, 'breathingIntro'));
  Future<void> speakInhale() =>
      speakRandom(AppCopy.list(_appLanguage, 'inhalePrompts'));
  Future<void> speakHold() =>
      speakRandom(AppCopy.list(_appLanguage, 'holdPrompts'));
  Future<void> speakExhale() =>
      speakRandom(AppCopy.list(_appLanguage, 'exhalePrompts'));
  Future<void> speakPoseTransition() =>
      speakRandom(AppCopy.list(_appLanguage, 'poseTransitions'));
  Future<void> speakComplete() =>
      speakRandom(AppCopy.list(_appLanguage, 'sessionCompleteLines'));
  Future<void> speakEncouragement() =>
      speakRandom(AppCopy.list(_appLanguage, 'encouragement'));

  Future<void> sessionStart(String sessionType) async {
    await speak(
      AppCopy.tr(
        _appLanguage,
        'voiceSessionStart',
        vars: {
          'greeting': _timeGreeting(),
          'sessionType': AppCopy.tr(_appLanguage, sessionType),
        },
      ),
    );
  }

  Future<void> sessionComplete(int minutes) async {
    await speak(
      AppCopy.tr(
        _appLanguage,
        'voiceSessionComplete',
        vars: {'minutes': minutes},
      ),
    );
  }

  String _timeGreeting() {
    return AppCopy.greeting(_appLanguage);
  }

  Future<void> speakPoseInstruction(String poseName) async {
    await speak(AppCopy.poseInstruction(_appLanguage, poseName));
  }
}
