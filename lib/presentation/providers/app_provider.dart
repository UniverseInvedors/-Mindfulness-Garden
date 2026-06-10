import 'package:flutter/material.dart';
import 'package:mindfulness_garden/core/services/localization_service.dart';
import 'package:mindfulness_garden/core/services/voice_service.dart';
import 'package:mindfulness_garden/core/themes/app_theme.dart';
import 'package:mindfulness_garden/data/local_storage/local_storage_service.dart';

class AppProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppUiTheme _uiTheme = AppUiTheme.cosmicDark;
  AppLanguage _appLanguage = AppLanguage.english;
  VoicePersonality _voicePersonality = VoicePersonality.buddha;
  int _streakDays = 24;
  int _totalMinutes = 240;
  String _currentMood = '';

  ThemeMode get themeMode => _themeMode;
  AppUiTheme get uiTheme => _uiTheme;
  AppLanguage get appLanguage => _appLanguage;
  AppUiThemeData get uiThemeData => appUiThemes[_uiTheme]!;
  int get streakDays => _streakDays;
  int get totalMinutes => _totalMinutes;
  String get currentMood => _currentMood;

  AppProvider() {
    _loadTheme();
    _loadLanguage();
  }

  void _loadTheme() {
    final saved = LocalStorageService.getSetting('ui_theme');
    if (saved is String) {
      try {
        _uiTheme = AppUiTheme.values.firstWhere((e) => e.name == saved);
      } catch (_) {}
    }
    final darkMode = LocalStorageService.getSetting('dark_mode');
    if (darkMode is bool) {
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark; // default dark
    }
  }

  void _loadLanguage() {
    final saved = LocalStorageService.getSetting('app_language');
    if (saved is String) {
      _appLanguage = LocalizationService.languageFromName(saved);
    } else {
      final voiceLang = LocalStorageService.getSetting('voice_language');
      if (voiceLang is String) {
        _appLanguage = LocalizationService.languageFromCode(voiceLang);
      }
    }
    // Load voice personality preference
    final p = LocalStorageService.getSetting('voice_personality');
    if (p is String) {
      try {
        _voicePersonality = VoicePersonality.values.firstWhere(
            (v) => v.name == p,
            orElse: () => VoicePersonality.buddha);
      } catch (_) {
        _voicePersonality = VoicePersonality.buddha;
      }
    }
  }

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    LocalStorageService.saveSetting('dark_mode', isDark);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setUiTheme(AppUiTheme theme) {
    _uiTheme = theme;
    LocalStorageService.saveSetting('ui_theme', theme.name);
    // Sync dark mode with theme
    _themeMode = ThemeMode.dark;
    notifyListeners();
  }

  void updateStreak(int days) {
    _streakDays = days;
    notifyListeners();
  }

  void addSessionMinutes(int minutes) {
    _totalMinutes += minutes;
    notifyListeners();
  }

  void setMood(String mood) {
    _currentMood = mood;
    notifyListeners();
  }

  Future<void> setAppLanguage(AppLanguage language) async {
    _appLanguage = language;
    await LocalStorageService.saveSetting('app_language', language.displayName);
    await LocalStorageService.saveSetting(
        'voice_language', language.localeCode);
    await VoiceService().setAppLanguage(language);
    // Announce the change using the voice system (voice-first UX)
    try {
      final template =
          LocalizationService.translate('language_set', _appLanguage);
      final phrase = template.replaceAll('{language}', language.displayName);
      await VoiceService().speak(phrase);
    } catch (_) {}
    notifyListeners();
  }

  VoicePersonality get voicePersonality => _voicePersonality;

  Future<void> setVoicePersonality(VoicePersonality p) async {
    _voicePersonality = p;
    await LocalStorageService.saveSetting('voice_personality', p.name);
    await VoiceService().setPersonality(p);
    // short spoken confirmation
    final announce = {
      VoicePersonality.buddha: 'Buddha voice selected',
      VoicePersonality.zeno: 'Zeno voice selected',
      VoicePersonality.monk: 'Monk voice selected',
    }[p]!;
    try {
      await VoiceService().speak(announce);
    } catch (_) {}
    notifyListeners();
  }

  void reset() {
    _streakDays = 0;
    _totalMinutes = 0;
    _currentMood = '';
    notifyListeners();
  }
}
