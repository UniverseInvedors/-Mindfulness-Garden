// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UI Theme System
//
// 6 immersive themes that change the entire app's colour palette.
// Persisted via Hive so the choice survives restarts.
// ─────────────────────────────────────────────────────────────────────────────

enum AppUiTheme {
  forest,
  night,
  ocean,
  cosmic,
  desert,
  zen,
}

class AppUiThemeData {
  final AppUiTheme id;
  final String name;
  final String emoji;
  final String description;

  // Scaffold / background
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Accent colours
  final Color primary;
  final Color secondary;
  final Color accent;

  // Text
  final Color onBackground;
  final Color onSurface;
  final Color onSurfaceSubtle;

  // Gradient pair for hero areas
  final List<Color> heroGradient;

  // Card border
  final Color cardBorder;

  const AppUiThemeData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.onBackground,
    required this.onSurface,
    required this.onSurfaceSubtle,
    required this.heroGradient,
    required this.cardBorder,
  });
}

const Map<AppUiTheme, AppUiThemeData> kUiThemes = {
  AppUiTheme.forest: AppUiThemeData(
    id: AppUiTheme.forest,
    name: 'Forest',
    emoji: '🌲',
    description: 'Deep greens and earthy tones',
    background: Color(0xFF0a1a0f),
    surface: Color(0xFF122018),
    surfaceVariant: Color(0xFF1b3325),
    primary: Color(0xFF38b000),
    secondary: Color(0xFF70e000),
    accent: Color(0xFFb7e4c7),
    onBackground: Color(0xFFe8f5e9),
    onSurface: Color(0xFFd8f3dc),
    onSurfaceSubtle: Color(0xFF74c69d),
    heroGradient: [Color(0xFF1b4332), Color(0xFF081c15)],
    cardBorder: Color(0xFF2d6a4f),
  ),
  AppUiTheme.night: AppUiThemeData(
    id: AppUiTheme.night,
    name: 'Night',
    emoji: '🌙',
    description: 'Deep space blues and purples',
    background: Color(0xFF0a0a1a),
    surface: Color(0xFF12122a),
    surfaceVariant: Color(0xFF1a1a35),
    primary: Color(0xFF9d4edd),
    secondary: Color(0xFF00b4d8),
    accent: Color(0xFFc77dff),
    onBackground: Color(0xFFe8e8ff),
    onSurface: Color(0xFFdde1ff),
    onSurfaceSubtle: Color(0xFF9d9dcc),
    heroGradient: [Color(0xFF10002b), Color(0xFF000010)],
    cardBorder: Color(0xFF3a0ca3),
  ),
  AppUiTheme.ocean: AppUiThemeData(
    id: AppUiTheme.ocean,
    name: 'Ocean',
    emoji: '🌊',
    description: 'Deep blues and aqua tones',
    background: Color(0xFF03045e),
    surface: Color(0xFF023e8a),
    surfaceVariant: Color(0xFF0077b6),
    primary: Color(0xFF00b4d8),
    secondary: Color(0xFF90e0ef),
    accent: Color(0xFFcaf0f8),
    onBackground: Color(0xFFe0f7fa),
    onSurface: Color(0xFFb2ebf2),
    onSurfaceSubtle: Color(0xFF4dd0e1),
    heroGradient: [Color(0xFF023e8a), Color(0xFF03045e)],
    cardBorder: Color(0xFF0096c7),
  ),
  AppUiTheme.cosmic: AppUiThemeData(
    id: AppUiTheme.cosmic,
    name: 'Cosmic',
    emoji: '🌌',
    description: 'Nebula purples and star gold',
    background: Color(0xFF0d0015),
    surface: Color(0xFF1a0030),
    surfaceVariant: Color(0xFF2d0050),
    primary: Color(0xFFb5179e),
    secondary: Color(0xFFf72585),
    accent: Color(0xFFFFD700),
    onBackground: Color(0xFFffe8ff),
    onSurface: Color(0xFFffd6ff),
    onSurfaceSubtle: Color(0xFFcc99ff),
    heroGradient: [Color(0xFF10002b), Color(0xFF3a0ca3)],
    cardBorder: Color(0xFF7209b7),
  ),
  AppUiTheme.desert: AppUiThemeData(
    id: AppUiTheme.desert,
    name: 'Desert',
    emoji: '🏜️',
    description: 'Warm sands and sunset oranges',
    background: Color(0xFF1a0a00),
    surface: Color(0xFF2d1500),
    surfaceVariant: Color(0xFF3d2000),
    primary: Color(0xFFf77f00),
    secondary: Color(0xFFe9c46a),
    accent: Color(0xFFffd166),
    onBackground: Color(0xFFfff3e0),
    onSurface: Color(0xFFffe0b2),
    onSurfaceSubtle: Color(0xFFffb74d),
    heroGradient: [Color(0xFF3d1f00), Color(0xFF1a0a00)],
    cardBorder: Color(0xFFf4a261),
  ),
  AppUiTheme.zen: AppUiThemeData(
    id: AppUiTheme.zen,
    name: 'Zen',
    emoji: '🏯',
    description: 'Warm stone and golden lanterns',
    background: Color(0xFF0f0a05),
    surface: Color(0xFF1a1208),
    surfaceVariant: Color(0xFF2a1e0f),
    primary: Color(0xFFe9c46a),
    secondary: Color(0xFFf4a261),
    accent: Color(0xFFffd166),
    onBackground: Color(0xFFfff8e7),
    onSurface: Color(0xFFfff0c8),
    onSurfaceSubtle: Color(0xFFd4a96a),
    heroGradient: [Color(0xFF3d2b1f), Color(0xFF1a0f0a)],
    cardBorder: Color(0xFF6b4c2a),
  ),
};

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

class AppUiThemeProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _themeKey = 'ui_theme';

  AppUiTheme _current = AppUiTheme.night;

  AppUiTheme get current => _current;
  AppUiThemeData get data => kUiThemes[_current]!;

  AppUiThemeProvider() {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box(_boxName);
      final saved = box.get(_themeKey, defaultValue: 'night') as String;
      _current = AppUiTheme.values.firstWhere(
        (t) => t.name == saved,
        orElse: () => AppUiTheme.night,
      );
    } catch (_) {
      _current = AppUiTheme.night;
    }
  }

  Future<void> setTheme(AppUiTheme theme) async {
    _current = theme;
    notifyListeners();
    try {
      final box = Hive.box(_boxName);
      await box.put(_themeKey, theme.name);
    } catch (_) {}
  }

  /// Build a Flutter ThemeData from the current UI theme.
  ThemeData buildThemeData() {
    final d = data;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: d.background,
      colorScheme: ColorScheme.dark(
        primary: d.primary,
        secondary: d.secondary,
        surface: d.surface,
        onSurface: d.onSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        outline: d.cardBorder,
        outlineVariant: d.cardBorder.withAlpha(80),
      ),
      cardTheme: CardThemeData(
        color: d.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: d.cardBorder.withAlpha(80)),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: d.background,
        elevation: 0,
        iconTheme: IconThemeData(color: d.onSurface),
        titleTextStyle: TextStyle(
          color: d.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: d.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge:
            TextStyle(color: d.onBackground, fontWeight: FontWeight.w800),
        displayMedium:
            TextStyle(color: d.onBackground, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: d.onSurface, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: d.onSurface, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: d.onSurface),
        bodyMedium: TextStyle(color: d.onSurfaceSubtle),
        bodySmall: TextStyle(color: d.onSurfaceSubtle),
      ),
      fontFamily: 'Inter',
    );
  }
}
