import 'package:flutter/material.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/services/sound_service.dart';
import 'package:pranaverse/core/services/auto_theme_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppLanguage Enum — Single Source of Truth for Language
// ─────────────────────────────────────────────────────────────────────────────

enum AppLanguage {
  english('en', 'English'),
  bengali('bn', 'Bengali'),
  hindi('hi', 'Hindi');

  final String code;
  final String displayName;

  const AppLanguage(this.code, this.displayName);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.english,
    );
  }

  Locale get locale => Locale(code);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppSettingsProvider — Single Source of Truth for All App Settings
//
// Manages:
// - Theme (AppUiTheme)
// - Language (AppLanguage)
// - Voice Language (synced with app language)
// - Voice Personality (VoicePersonality)
//
// All screens must subscribe to this provider.
// All settings persist via LocalStorageService.
// ─────────────────────────────────────────────────────────────────────────────

class AppSettingsProvider with ChangeNotifier {
  // Theme
  AppUiTheme _uiTheme = AppUiTheme.midnightZen;
  ThemeMode _themeMode = ThemeMode.dark;

  // Language
  AppLanguage _language = AppLanguage.english;

  // Voice
  VoicePersonality _voicePersonality = VoicePersonality.buddha;
  bool _voiceEnabled = true;

  // Sound / SFX
  bool _soundEnabled = true;
  bool _bgMusicEnabled = true;
  double _sfxVolume = 0.7;

  // Auto Theme Service
  final AutoThemeService _autoThemeService = AutoThemeService();

  bool get soundEnabled => _soundEnabled;
  bool get bgMusicEnabled => _bgMusicEnabled;
  double get sfxVolume => _sfxVolume;
  AutoThemeService get autoThemeService => _autoThemeService;
  // Getters
  AppUiTheme get uiTheme => _uiTheme;
  AppUiThemeData get uiThemeData => appUiThemes[_uiTheme]!;
  ThemeMode get themeMode => _themeMode;
  AppLanguage get language => _language;
  VoicePersonality get voicePersonality => _voicePersonality;
  bool get voiceEnabled => _voiceEnabled;

  AppSettingsProvider() {
    _loadSettings();
    // Listen to auto theme changes
    _autoThemeService.addListener(_onAutoThemeChanged);
  }

  /// Called when auto theme service detects a change
  void _onAutoThemeChanged() {
    // If auto theme is enabled, update theme mode
    if (_autoThemeService.autoThemeEnabled) {
      final shouldBeDark = _autoThemeService.shouldUseDarkTheme();
      if ((shouldBeDark && _themeMode != ThemeMode.dark) ||
          (!shouldBeDark && _themeMode != ThemeMode.light)) {
        _themeMode = shouldBeDark ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    }
  }

  // ── Load Settings from SharedPreferences ─────────────────────────────────────

  Future<void> _loadSettings() async {
    // Load theme
    final savedTheme = LocalStorageService.getSetting('ui_theme');
    if (savedTheme is String) {
      try {
        _uiTheme = AppUiTheme.values.firstWhere((e) => e.name == savedTheme);
      } catch (_) {}
    }

    final darkMode = LocalStorageService.getSetting('dark_mode');
    if (darkMode is bool) {
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    // Load language
    final savedLanguage = LocalStorageService.getSetting('app_language');
    if (savedLanguage is String) {
      try {
        _language = AppLanguage.values.firstWhere(
          (e) => e.code == savedLanguage,
        );
      } catch (_) {}
    }

    // Load voice personality
    final savedPersonality = LocalStorageService.getSetting(
      'voice_personality',
    );
    if (savedPersonality is String) {
      try {
        _voicePersonality = VoicePersonality.values.firstWhere(
          (v) => v.name == savedPersonality,
          orElse: () => VoicePersonality.buddha,
        );
      } catch (_) {}
    }

    // Load voice enabled
    final savedVoiceEnabled = LocalStorageService.getSetting('voice_enabled');
    if (savedVoiceEnabled is bool) {
      _voiceEnabled = savedVoiceEnabled;
    } else if (savedVoiceEnabled is String) {
      // Handle corrupted string values like "trrue"
      _voiceEnabled = savedVoiceEnabled.toLowerCase() == 'true';
      // Fix the corrupted value
      await LocalStorageService.saveSetting('voice_enabled', _voiceEnabled);
    }

    // Sync voice service with loaded settings
    VoiceService().setEnabled(_voiceEnabled);
    VoiceService().setPersonality(_voicePersonality);
    await VoiceService().updateLanguage(_language);

    // Load sound settings
    final savedSoundEnabled = LocalStorageService.getSetting('sound_enabled');
    if (savedSoundEnabled is bool) _soundEnabled = savedSoundEnabled;

    final savedBgEnabled = LocalStorageService.getSetting('bg_music_enabled');
    if (savedBgEnabled is bool) _bgMusicEnabled = savedBgEnabled;

    final savedSfxVol = LocalStorageService.getSetting('sfx_volume');
    if (savedSfxVol is double) _sfxVolume = savedSfxVol;

    SoundService().setEnabled(_soundEnabled);
    SoundService().setBgEnabled(_bgMusicEnabled);
    await SoundService().setSfxVolume(_sfxVolume);

    notifyListeners();
  }

  // ── Theme Methods ───────────────────────────────────────────────────────────

  Future<void> setUiTheme(AppUiTheme theme) async {
    _uiTheme = theme;
    _themeMode = ThemeMode.dark; // Themes handle their own colors
    await LocalStorageService.saveSetting('ui_theme', theme.name);
    await LocalStorageService.saveSetting('dark_mode', true);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await LocalStorageService.saveSetting('dark_mode', mode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await LocalStorageService.saveSetting('dark_mode', isDark);
    notifyListeners();
  }

  // ── Language Methods ────────────────────────────────────────────────────────

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    await LocalStorageService.saveSetting('app_language', language.code);
    // Sync voice service language
    await VoiceService().updateLanguage(language);
    notifyListeners();
  }

  // ── Voice Methods ───────────────────────────────────────────────────────────

  Future<void> setVoicePersonality(VoicePersonality personality) async {
    _voicePersonality = personality;
    await LocalStorageService.saveSetting(
      'voice_personality',
      personality.name,
    );
    await VoiceService().setPersonality(personality);
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    _voiceEnabled = enabled;
    await LocalStorageService.saveSetting('voice_enabled', enabled);
    VoiceService().setEnabled(enabled);
    notifyListeners();
  }

  // ── Sound Methods ───────────────────────────────────────────────────────────

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    await LocalStorageService.saveSetting('sound_enabled', enabled);
    SoundService().setEnabled(enabled);
    notifyListeners();
  }

  Future<void> setBgMusicEnabled(bool enabled) async {
    _bgMusicEnabled = enabled;
    await LocalStorageService.saveSetting('bg_music_enabled', enabled);
    SoundService().setBgEnabled(enabled);
    if (!enabled) SoundService().stopBg();
    notifyListeners();
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume;
    await LocalStorageService.saveSetting('sfx_volume', volume);
    await SoundService().setSfxVolume(volume);
    notifyListeners();
  }

  // ── Reset ───────────────────────────────────────────────────────────────────

  Future<void> resetToDefaults() async {
    _uiTheme = AppUiTheme.midnightZen;
    _themeMode = ThemeMode.dark;
    _language = AppLanguage.english;
    _voicePersonality = VoicePersonality.buddha;
    _voiceEnabled = true;
    _soundEnabled = true;
    _bgMusicEnabled = true;
    _sfxVolume = 0.7;

    await LocalStorageService.saveSetting('ui_theme', _uiTheme.name);
    await LocalStorageService.saveSetting('dark_mode', true);
    await LocalStorageService.saveSetting('app_language', _language.code);
    await LocalStorageService.saveSetting(
      'voice_personality',
      _voicePersonality.name,
    );
    await LocalStorageService.saveSetting('voice_enabled', true);
    await LocalStorageService.saveSetting('sound_enabled', true);
    await LocalStorageService.saveSetting('bg_music_enabled', true);
    await LocalStorageService.saveSetting('sfx_volume', 0.7);

    VoiceService().setEnabled(true);
    VoiceService().setPersonality(VoicePersonality.buddha);
    VoiceService().updateLanguage(AppLanguage.english);
    SoundService().setEnabled(true);
    SoundService().setBgEnabled(true);
    await SoundService().setSfxVolume(0.7);

    notifyListeners();
  }
}
