import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pranaverse/core/services/localization_service.dart';
import 'package:pranaverse/core/services/voice_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';
import 'package:pranaverse/data/local_storage/local_storage_service.dart';

// App State
class AppState {
  final ThemeMode themeMode;
  final AppUiTheme uiTheme;
  final AppLanguage appLanguage;
  final VoicePersonality voicePersonality;
  final int streakDays;
  final int totalMinutes;
  final String currentMood;

  AppState({
    this.themeMode = ThemeMode.dark,
    this.uiTheme = AppUiTheme.cosmicDark,
    this.appLanguage = AppLanguage.english,
    this.voicePersonality = VoicePersonality.buddha,
    this.streakDays = 24,
    this.totalMinutes = 240,
    this.currentMood = '',
  });

  AppState copyWith({
    ThemeMode? themeMode,
    AppUiTheme? uiTheme,
    AppLanguage? appLanguage,
    VoicePersonality? voicePersonality,
    int? streakDays,
    int? totalMinutes,
    String? currentMood,
  }) {
    return AppState(
      themeMode: themeMode ?? this.themeMode,
      uiTheme: uiTheme ?? this.uiTheme,
      appLanguage: appLanguage ?? this.appLanguage,
      voicePersonality: voicePersonality ?? this.voicePersonality,
      streakDays: streakDays ?? this.streakDays,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      currentMood: currentMood ?? this.currentMood,
    );
  }

  AppUiThemeData get uiThemeData => appUiThemes[uiTheme]!;
}

// App StateNotifier
class AppNotifier extends StateNotifier<AppState> {
  AppNotifier() : super(AppState()) {
    _loadTheme();
    _loadLanguage();
  }

  // Getters
  ThemeMode get themeMode => state.themeMode;
  AppUiTheme get uiTheme => state.uiTheme;
  AppLanguage get appLanguage => state.appLanguage;
  int get streakDays => state.streakDays;
  int get totalMinutes => state.totalMinutes;
  String get currentMood => state.currentMood;

  // Load theme
  void _loadTheme() {
    final saved = LocalStorageService.getSetting('ui_theme');
    AppUiTheme loadedTheme = state.uiTheme;
    if (saved is String) {
      try {
        loadedTheme = AppUiTheme.values.firstWhere((e) => e.name == saved);
      } catch (_) {}
    }
    final darkMode = LocalStorageService.getSetting('dark_mode');
    ThemeMode loadedMode = darkMode is bool
        ? (darkMode ? ThemeMode.dark : ThemeMode.light)
        : ThemeMode.dark;

    state = state.copyWith(
      uiTheme: loadedTheme,
      themeMode: loadedMode,
    );
  }

  // Load language
  void _loadLanguage() {
    final saved = LocalStorageService.getSetting('app_language');
    AppLanguage loadedLanguage = state.appLanguage;
    if (saved is String) {
      loadedLanguage = LocalizationService.languageFromName(saved);
    } else {
      final voiceLang = LocalStorageService.getSetting('voice_language');
      if (voiceLang is String) {
        loadedLanguage = LocalizationService.languageFromCode(voiceLang);
      }
    }

    VoicePersonality loadedPersonality = state.voicePersonality;
    final p = LocalStorageService.getSetting('voice_personality');
    if (p is String) {
      try {
        loadedPersonality = VoicePersonality.values.firstWhere(
          (v) => v.name == p,
          orElse: () => VoicePersonality.buddha,
        );
      } catch (_) {
        loadedPersonality = VoicePersonality.buddha;
      }
    }

    state = state.copyWith(
      appLanguage: loadedLanguage,
      voicePersonality: loadedPersonality,
    );
  }

  // Toggle theme
  void toggleTheme(bool isDark) {
    state = state.copyWith(themeMode: isDark ? ThemeMode.dark : ThemeMode.light);
    LocalStorageService.saveSetting('dark_mode', isDark);
  }

  // Set theme mode
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
  }

  // Set UI theme
  void setUiTheme(AppUiTheme theme) {
    state = state.copyWith(
      uiTheme: theme,
      themeMode: ThemeMode.dark,
    );
    LocalStorageService.saveSetting('ui_theme', theme.name);
  }

  // Update streak
  void updateStreak(int days) {
    state = state.copyWith(streakDays: days);
  }

  // Add session minutes
  void addSessionMinutes(int minutes) {
    state = state.copyWith(totalMinutes: state.totalMinutes + minutes);
  }

  // Set mood
  void setMood(String mood) {
    state = state.copyWith(currentMood: mood);
  }

  // Set app language
  Future<void> setAppLanguage(AppLanguage language) async {
    state = state.copyWith(appLanguage: language);
    await LocalStorageService.saveSetting('app_language', language.displayName);
    await LocalStorageService.saveSetting('voice_language', language.localeCode);
    await VoiceService().setAppLanguage(language);

    try {
      final template = LocalizationService.translate('language_set', language);
      final phrase = template.replaceAll('{language}', language.displayName);
      await VoiceService().speak(phrase);
    } catch (_) {}
  }

  // Set voice personality
  Future<void> setVoicePersonality(VoicePersonality p) async {
    state = state.copyWith(voicePersonality: p);
    await LocalStorageService.saveSetting('voice_personality', p.name);
    await VoiceService().setPersonality(p);

    final announce = {
      VoicePersonality.buddha: 'Buddha voice selected',
      VoicePersonality.zeno: 'Zeno voice selected',
      VoicePersonality.monk: 'Monk voice selected',
    }[p]!;

    try {
      await VoiceService().speak(announce);
    } catch (_) {}
  }

  // Reset
  void reset() {
    state = state.copyWith(
      streakDays: 0,
      totalMinutes: 0,
      currentMood: '',
    );
  }
}

// Providers
final appProvider = StateNotifierProvider<AppNotifier, AppState>((ref) {
  return AppNotifier();
});

// Convenience providers
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appProvider).themeMode;
});

final uiThemeProvider = Provider<AppUiTheme>((ref) {
  return ref.watch(appProvider).uiTheme;
});

final uiThemeDataProvider = Provider<AppUiThemeData>((ref) {
  return ref.watch(appProvider).uiThemeData;
});

final appLanguageProvider = Provider<AppLanguage>((ref) {
  return ref.watch(appProvider).appLanguage;
});

final streakDaysProvider = Provider<int>((ref) {
  return ref.watch(appProvider).streakDays;
});

final totalMinutesProvider = Provider<int>((ref) {
  return ref.watch(appProvider).totalMinutes;
});
