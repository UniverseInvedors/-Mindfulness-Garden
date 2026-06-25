// DEPRECATED: This file is deprecated. Use AppSettingsProvider instead.
// This provider duplicates functionality that should be in AppSettingsProvider.
// All screens should use AppSettingsProvider as the single source of truth.

import 'package:flutter/material.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';

// This class is deprecated. Use AppSettingsProvider instead.
@Deprecated('Use AppSettingsProvider instead')
class AppProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppUiTheme _uiTheme = AppUiTheme.midnightZen;
  VoicePersonality _voicePersonality = VoicePersonality.buddha;
  int _streakDays = 24;
  int _totalMinutes = 240;
  String _currentMood = '';

  ThemeMode get themeMode => _themeMode;
  AppUiTheme get uiTheme => _uiTheme;
  AppUiThemeData get uiThemeData => appUiThemes[_uiTheme]!;
  int get streakDays => _streakDays;
  int get totalMinutes => _totalMinutes;
  String get currentMood => _currentMood;

  AppProvider() {
    _loadTheme();
    _loadVoicePersonality();
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

  void _loadVoicePersonality() {
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
