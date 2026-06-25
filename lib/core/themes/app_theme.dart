import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Named UI themes for the app
// ─────────────────────────────────────────────────────────────────────────────

enum AppUiTheme {
  gardenSerenity,
  skyCalm,
  sunriseGlow,
  roseHarmony,
  lavenderDream,
  midnightZen,
}

class AppUiThemeData {
  final String name;
  final String emoji;
  final String description;
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final Color accent;
  final List<Color> gradientColors;

  const AppUiThemeData({
    required this.name,
    required this.emoji,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.accent,
    required this.gradientColors,
  });
}

const Map<AppUiTheme, AppUiThemeData> appUiThemes = {
  AppUiTheme.gardenSerenity: AppUiThemeData(
    name: 'Garden Serenity',
    emoji: '�',
    description: 'Peaceful green garden tranquility',
    primary: Color(0xFF4CAF50),
    secondary: Color(0xFF81C784),
    background: Color(0xFFE8F5E9),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B5E20),
    accent: Color(0xFF66BB6A),
    gradientColors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
  ),
  AppUiTheme.skyCalm: AppUiThemeData(
    name: 'Sky Calm',
    emoji: '☁️',
    description: 'Gentle light blue serenity',
    primary: Color(0xFF2196F3),
    secondary: Color(0xFF64B5F6),
    background: Color(0xFFE3F2FD),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF0D47A1),
    accent: Color(0xFF42A5F5),
    gradientColors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
  ),
  AppUiTheme.sunriseGlow: AppUiThemeData(
    name: 'Sunrise Glow',
    emoji: '�',
    description: 'Warm yellow morning radiance',
    primary: Color(0xFFFFC107),
    secondary: Color(0xFFFFD54F),
    background: Color(0xFFFFF8E1),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFFFF6F00),
    accent: Color(0xFFFFCA28),
    gradientColors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
  ),
  AppUiTheme.roseHarmony: AppUiThemeData(
    name: 'Rose Harmony',
    emoji: '�',
    description: 'Soft rose pink elegance',
    primary: Color(0xFFE91E63),
    secondary: Color(0xFFF06292),
    background: Color(0xFFFCE4EC),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF880E4F),
    accent: Color(0xFFEC407A),
    gradientColors: [Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
  ),
  AppUiTheme.lavenderDream: AppUiThemeData(
    name: 'Lavender Dream',
    emoji: '💜',
    description: 'Calming purple tranquility',
    primary: Color(0xFF9C27B0),
    secondary: Color(0xFFBA68C8),
    background: Color(0xFFF3E5F5),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF4A148C),
    accent: Color(0xFFAB47BC),
    gradientColors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
  ),
  AppUiTheme.midnightZen: AppUiThemeData(
    name: 'Midnight Zen',
    emoji: '�',
    description: 'Deep dark peaceful night',
    primary: Color(0xFF3F51B5),
    secondary: Color(0xFF7986CB),
    background: Color(0xFF1A237E),
    surface: Color(0xFF283593),
    onSurface: Colors.white,
    accent: Color(0xFF5C6BC0),
    gradientColors: [Color(0xFF1A237E), Color(0xFF283593)],
  ),
};

class AppColors {
  // Primary Palette
  static const Color primary = Color(0xFF6C63FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE0E0FF);
  static const Color onPrimaryContainer = Color(0xFF1A0061);

  // Secondary Palette
  static const Color secondary = Color(0xFF4CD97B);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFC9F0D4);
  static const Color onSecondaryContainer = Color(0xFF00210A);

  // Tertiary Palette
  static const Color tertiary = Color(0xFFFF6584);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD9E0);
  static const Color onTertiaryContainer = Color(0xFF3F0014);

  // Neutral Palette
  static const Color background = Color(0xFFF9F9F9);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFFE1E1E1);
  static const Color onSurfaceVariant = Color(0xFF444746);

  // Semantic Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color outline = Color(0xFF757575);
  static const Color outlineVariant = Color(0xFFC9C9C9);
  static const Color shadow = Color(0xFF000000);
  static const Color scrim = Color(0xFF000000);
  static const Color inverseSurface = Color(0xFF2F3033);
  static const Color inverseOnSurface = Color(0xFFF1F0F4);
  static const Color inversePrimary = Color(0xFFBBC3FF);

  // Surface Tints
  static const Color surfaceTint = Color(0xFF6C63FF);

  // UI Specific
  static const Color divider = Color(0xFFE2E8F0);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF4CD97B);
  static const Color warning = Color(0xFFFFB74D);
  static const Color info = Color(0xFF29B6F6);
}

class AppTheme {
  static ThemeData buildTheme(AppUiThemeData uiTheme) {
    final isDark = uiTheme.background.computeLuminance() < 0.5;
    
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: isDark 
          ? ColorScheme.dark(
              primary: uiTheme.primary,
              onPrimary: Colors.white,
              primaryContainer: uiTheme.primary.withAlpha(80),
              onPrimaryContainer: Colors.white,
              secondary: uiTheme.secondary,
              onSecondary: Colors.white,
              secondaryContainer: uiTheme.secondary.withAlpha(60),
              onSecondaryContainer: Colors.white,
              tertiary: uiTheme.accent,
              onTertiary: Colors.white,
              error: const Color(0xFFFFB4AB),
              onError: const Color(0xFF690005),
              surface: uiTheme.surface,
              onSurface: uiTheme.onSurface,
              surfaceContainerHighest: uiTheme.surface.withAlpha(200),
              onSurfaceVariant: uiTheme.onSurface.withAlpha(180),
              outline: uiTheme.primary.withAlpha(100),
              outlineVariant: uiTheme.surface.withAlpha(150),
              shadow: Colors.black,
              scrim: Colors.black,
              inverseSurface: Colors.white,
              onInverseSurface: uiTheme.background,
              inversePrimary: uiTheme.primary,
              surfaceTint: uiTheme.primary,
            )
          : ColorScheme.light(
              primary: uiTheme.primary,
              onPrimary: Colors.white,
              primaryContainer: uiTheme.primary.withAlpha(80),
              onPrimaryContainer: uiTheme.onSurface,
              secondary: uiTheme.secondary,
              onSecondary: Colors.white,
              secondaryContainer: uiTheme.secondary.withAlpha(60),
              onSecondaryContainer: uiTheme.onSurface,
              tertiary: uiTheme.accent,
              onTertiary: Colors.white,
              error: const Color(0xFFBA1A1A),
              onError: Colors.white,
              errorContainer: const Color(0xFFFFDAD6),
              onErrorContainer: const Color(0xFF410002),
              surface: uiTheme.surface,
              onSurface: uiTheme.onSurface,
              surfaceContainerHighest: uiTheme.surface.withAlpha(200),
              onSurfaceVariant: uiTheme.onSurface.withAlpha(180),
              outline: uiTheme.primary.withAlpha(100),
              outlineVariant: uiTheme.surface.withAlpha(150),
              shadow: Colors.black,
              scrim: Colors.black,
              inverseSurface: uiTheme.onSurface,
              onInverseSurface: uiTheme.background,
              inversePrimary: uiTheme.primary,
              surfaceTint: uiTheme.primary,
            ),
      scaffoldBackgroundColor: uiTheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: uiTheme.onSurface),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: uiTheme.onSurface,
        ),
      ),
      fontFamily: 'Inter',
      textTheme: isDark ? _textThemeDark : _textTheme,
      cardTheme: CardThemeData(
        elevation: isDark ? 1 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: uiTheme.primary.withAlpha(40), width: 1),
        ),
        color: uiTheme.surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: uiTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: uiTheme.primary,
          side: BorderSide(color: uiTheme.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: uiTheme.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: uiTheme.primary.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: uiTheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(color: uiTheme.onSurface.withAlpha(120), fontSize: 16),
        labelStyle: TextStyle(color: uiTheme.onSurface.withAlpha(150), fontSize: 14),
        floatingLabelStyle: TextStyle(color: uiTheme.primary, fontSize: 14),
      ),
      dividerTheme: DividerThemeData(
        color: uiTheme.primary.withAlpha(40),
        thickness: 1,
        space: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: uiTheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: uiTheme.surface,
        elevation: 8,
        selectedItemColor: uiTheme.primary,
        unselectedItemColor: uiTheme.onSurface.withAlpha(120),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? uiTheme.surface : uiTheme.onSurface,
        contentTextStyle: TextStyle(color: isDark ? uiTheme.onSurface : uiTheme.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: uiTheme.surface.withAlpha(200),
        disabledColor: uiTheme.surface.withAlpha(100),
        selectedColor: uiTheme.primary.withAlpha(80),
        secondarySelectedColor: uiTheme.primary.withAlpha(80),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: TextStyle(color: uiTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(color: uiTheme.onSurface, fontSize: 14, fontWeight: FontWeight.w500),
        brightness: isDark ? Brightness.dark : Brightness.light,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: uiTheme.primary,
        thumbColor: uiTheme.primary,
        inactiveTrackColor: uiTheme.primary.withAlpha(60),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? uiTheme.primary : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? uiTheme.primary.withAlpha(100) : Colors.grey.withAlpha(60)),
      ),
    );
  }

  static ThemeData get lightTheme =>
      buildTheme(appUiThemes[AppUiTheme.gardenSerenity]!);

  static ThemeData get darkTheme =>
      buildTheme(appUiThemes[AppUiTheme.midnightZen]!);


  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0.25,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0.4,
      ),
    );
  }

  static TextTheme get _textThemeDark {
    return const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.4,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0.25,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: 0.4,
      ),
    ).apply(displayColor: Colors.white, bodyColor: Colors.white);
  }
}

// Extension methods for easy access
extension ThemeExtensions on ThemeData {
  Color get cardBorderColor => AppColors.cardBorder;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get infoColor => AppColors.info;
}

extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // Convenience getters
  Color get primaryColor => colors.primary;
  Color get secondaryColor => colors.secondary;
  Color get backgroundColor => colors.surface;
  Color get surfaceColor => colors.surface;
  Color get onSurfaceColor => colors.onSurface;
}

