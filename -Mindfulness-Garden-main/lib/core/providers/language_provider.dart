import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranaverse/core/services/voice_service.dart';

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

final languageProvider = StateNotifierProvider<LanguageNotifier, AppLanguage>(
  (ref) => LanguageNotifier(),
);

class LanguageNotifier extends StateNotifier<AppLanguage> {
  static const String _storageKey = 'app_language';

  LanguageNotifier() : super(AppLanguage.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_storageKey) ?? 'en';
    state = AppLanguage.fromCode(languageCode);
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, language.code);
    state = language;
    // Auto-switch TTS language
    VoiceService().updateLanguage(language);
  }

  Future<void> setLanguageByCode(String code) async {
    final language = AppLanguage.fromCode(code);
    await setLanguage(language);
  }
}

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(languageProvider).locale;
});
