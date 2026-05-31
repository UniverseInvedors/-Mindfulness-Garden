import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Named UI themes for the app
// ─────────────────────────────────────────────────────────────────────────────

enum AppUiTheme {
  cosmicDark,
  forest,
  night,
  ocean,
  desert,
  zenTemple,
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
  AppUiTheme.cosmicDark: AppUiThemeData(
    name: 'Cosmic Dark',
    emoji: '🌌',
    description: 'Deep space — the default dark experience',
    primary: Color(0xFF9d4edd),
    secondary: Color(0xFF00b4d8),
    background: Color(0xFF0a0a1a),
    surface: Color(0xFF1a1a2e),
    onSurface: Colors.white,
    accent: Color(0xFFf72585),
    gradientColors: [Color(0xFF0a0a1a), Color(0xFF1a0533)],
  ),
  AppUiTheme.forest: AppUiThemeData(
    name: 'Forest',
    emoji: '🌲',
    description: 'Calm greens of an ancient forest',
    primary: Color(0xFF38b000),
    secondary: Color(0xFF70e000),
    background: Color(0xFF081c15),
    surface: Color(0xFF1b4332),
    onSurface: Colors.white,
    accent: Color(0xFFd8f3dc),
    gradientColors: [Color(0xFF081c15), Color(0xFF1b4332)],
  ),
  AppUiTheme.night: AppUiThemeData(
    name: 'Night Sky',
    emoji: '🌙',
    description: 'Moonlit stillness',
    primary: Color(0xFF4cc9f0),
    secondary: Color(0xFF4361ee),
    background: Color(0xFF000010),
    surface: Color(0xFF0a0a2e),
    onSurface: Colors.white,
    accent: Color(0xFFe9c46a),
    gradientColors: [Color(0xFF000010), Color(0xFF0a0a2e)],
  ),
  AppUiTheme.ocean: AppUiThemeData(
    name: 'Ocean',
    emoji: '🌊',
    description: 'Deep blue tranquility',
    primary: Color(0xFF0077b6),
    secondary: Color(0xFF00b4d8),
    background: Color(0xFF03045e),
    surface: Color(0xFF023e8a),
    onSurface: Colors.white,
    accent: Color(0xFF90e0ef),
    gradientColors: [Color(0xFF03045e), Color(0xFF023e8a)],
  ),
  AppUiTheme.desert: AppUiThemeData(
    name: 'Desert',
    emoji: '🏜️',
    description: 'Warm golden sands at dusk',
    primary: Color(0xFFf77f00),
    secondary: Color(0xFFe9c46a),
    background: Color(0xFF1a0a00),
    surface: Color(0xFF3d1f00),
    onSurface: Colors.white,
    accent: Color(0xFFffb700),
    gradientColors: [Color(0xFF1a0a00), Color(0xFF3d1f00)],
  ),
  AppUiTheme.zenTemple: AppUiThemeData(
    name: 'Zen Temple',
    emoji: '🏯',
    description: 'Sacred golden serenity',
    primary: Color(0xFFe9c46a),
    secondary: Color(0xFFf4a261),
    background: Color(0xFF1a0f0a),
    surface: Color(0xFF3d2b1f),
    onSurface: Colors.white,
    accent: Color(0xFFffd166),
    gradientColors: [Color(0xFF1a0f0a), Color(0xFF3d2b1f)],
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
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
        surfaceTint: AppColors.surfaceTint,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      fontFamily: 'Inter',
      typography: Typography.material2021(
        black: _textTheme,
        white: _textTheme,
        englishLike: _textTheme,
        dense: _textTheme,
        tall: _textTheme,
      ),
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: const TextStyle(color: AppColors.surface),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        disabledColor: AppColors.surfaceVariant.withValues(alpha: 0.38),
        selectedColor: AppColors.primaryContainer,
        secondarySelectedColor: AppColors.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.onPrimaryContainer,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme =>
      buildDarkTheme(appUiThemes[AppUiTheme.cosmicDark]!);

  static ThemeData buildDarkTheme(AppUiThemeData uiTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
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
      textTheme: _textThemeDark,
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: uiTheme.primary.withAlpha(40)),
        ),
        color: uiTheme.surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: uiTheme.primary,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
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
        hintStyle:
            TextStyle(color: uiTheme.onSurface.withAlpha(120), fontSize: 16),
        labelStyle:
            TextStyle(color: uiTheme.onSurface.withAlpha(150), fontSize: 14),
        floatingLabelStyle: TextStyle(color: uiTheme.primary, fontSize: 14),
      ),
      dividerTheme: DividerThemeData(
        color: uiTheme.primary.withAlpha(40),
        thickness: 1,
        space: 0,
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
      sliderTheme: SliderThemeData(
        activeTrackColor: uiTheme.primary,
        thumbColor: uiTheme.primary,
        inactiveTrackColor: uiTheme.primary.withAlpha(60),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? uiTheme.primary : Colors.grey),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? uiTheme.primary.withAlpha(100)
                : Colors.grey.withAlpha(60)),
      ),
    );
  }

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

