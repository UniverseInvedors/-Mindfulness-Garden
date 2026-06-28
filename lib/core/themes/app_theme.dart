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

// ─────────────────────────────────────────────────────────────────────────────
// Theme palette philosophy
//
// • Background  = deepest shade of the colour family (~5-8 % lightness)
// • Surface     = one step lighter (~10-14 % lightness) — cards & drawers
// • Primary     = saturated, vivid accent used for buttons & highlights
// • Secondary   = brighter / lighter sibling — chips, progress bars
// • Accent      = high-energy pop colour for icons & badges (kids appeal)
// • onSurface   = always white for maximum contrast on deep backgrounds
// • All themes pass WCAG AA contrast (white on deep bg ≥ 7 : 1)
// ─────────────────────────────────────────────────────────────────────────────
const Map<AppUiTheme, AppUiThemeData> appUiThemes = {
  // ── 🌿 Garden Serenity — deep jungle green ───────────────────────────────
  // Background: near-black forest green  Surface: rich dark emerald
  // Primary: vivid lime-green            Secondary: bright spring green
  // Accent: neon yellow-green pop (kids love it)
  AppUiTheme.gardenSerenity: AppUiThemeData(
    name: 'Garden Serenity',
    emoji: '🌿',
    description: 'Deep jungle forest — vivid greens, white text',
    primary: Color(0xFF39D353), // bright leaf green — great on dark
    secondary: Color(0xFF57CC99), // fresh mint — readable chips
    background: Color(0xFF061410), // near-black jungle
    surface: Color(0xFF0D2318), // deep forest card surface
    onSurface: Colors.white,
    accent: Color(0xFFB7FF6E), // neon lime pop — eye-catching for kids
    gradientColors: [Color(0xFF061410), Color(0xFF0D2318)],
  ),

  // ── ☁️ Sky Calm — deep ocean midnight blue ──────────────────────────────
  // Background: deep navy               Surface: rich cobalt
  // Primary: electric cyan              Secondary: sky blue
  // Accent: vivid aqua flash (playful)
  AppUiTheme.skyCalm: AppUiThemeData(
    name: 'Sky Calm',
    emoji: '☁️',
    description: 'Deep ocean night — electric blues, white text',
    primary: Color(0xFF00D4FF), // electric cyan — pops on navy
    secondary: Color(0xFF48CAE4), // cool sky blue
    background: Color(0xFF03052A), // deep midnight navy
    surface: Color(0xFF08145E), // rich cobalt surface
    onSurface: Colors.white,
    accent: Color(0xFF7BFFF5), // bright aqua-teal glow — kids love neon
    gradientColors: [Color(0xFF03052A), Color(0xFF08145E)],
  ),

  // ── 🌅 Sunrise Glow — deep burnt amber / dark mahogany ──────────────────
  // Background: deep dark mahogany       Surface: rich burnt sienna
  // Primary: vivid warm orange           Secondary: golden yellow
  // Accent: hot coral-yellow (energetic, warm)
  AppUiTheme.sunriseGlow: AppUiThemeData(
    name: 'Sunrise Glow',
    emoji: '🌅',
    description: 'Deep amber night — bold oranges & gold, white text',
    primary: Color(0xFFFF8500), // vivid fire orange
    secondary: Color(0xFFFFCC00), // bright golden yellow
    background: Color(0xFF180A00), // deep dark mahogany
    surface: Color(0xFF2E1400), // rich burnt sienna surface
    onSurface: Colors.white,
    accent: Color(0xFFFFE566), // hot neon gold pop
    gradientColors: [Color(0xFF180A00), Color(0xFF2E1400)],
  ),

  // ── 🌹 Rose Harmony — deep dark crimson / wine ──────────────────────────
  // Background: near-black deep crimson   Surface: rich wine red
  // Primary: vivid hot rose/magenta       Secondary: coral pink
  // Accent: bright fuchsia pop (bold, playful, very visible on dark rose)
  AppUiTheme.roseHarmony: AppUiThemeData(
    name: 'Rose Harmony',
    emoji: '🌹',
    description: 'Deep crimson night — vivid rose & fuchsia, white text',
    primary: Color(0xFFFF3D6E), // vivid hot rose — glows on dark crimson
    secondary: Color(0xFFFF7096), // coral rose — warm readable tint
    background: Color(0xFF1A0008), // near-black deep crimson
    surface: Color(0xFF2E0015), // rich wine-dark surface
    onSurface: Colors.white,
    accent: Color(0xFFFF6FD8), // neon fuchsia-magenta pop (very kid-friendly!)
    gradientColors: [Color(0xFF1A0008), Color(0xFF2E0015)],
  ),

  // ── 💜 Lavender Dream — deep cosmic violet / ultraviolet ────────────────
  // Background: near-black ultra-deep violet   Surface: rich deep purple
  // Primary: vivid violet                      Secondary: bright lilac
  // Accent: electric purple-pink flash (magical feel for kids)
  AppUiTheme.lavenderDream: AppUiThemeData(
    name: 'Lavender Dream',
    emoji: '💜',
    description: 'Deep cosmic violet — bright purples & magic, white text',
    primary: Color(0xFFAA44FF), // vivid violet — stands out beautifully
    secondary: Color(0xFFCF8FFF), // bright lilac — great for labels
    background: Color(0xFF0C0015), // near-black deep violet-black
    surface: Color(0xFF1A0035), // rich deep purple surface
    onSurface: Colors.white,
    accent: Color(0xFFFF6BF5), // neon pink-purple flash — kids favourite!
    gradientColors: [Color(0xFF0C0015), Color(0xFF1A0035)],
  ),

  // ── 🌙 Midnight Zen — deep space indigo / obsidian (default) ────────────
  // Background: deep obsidian black-blue   Surface: space indigo
  // Primary: vivid electric indigo         Secondary: bright periwinkle
  // Accent: electric starlight blue (premium, calming yet vibrant)
  AppUiTheme.midnightZen: AppUiThemeData(
    name: 'Midnight Zen',
    emoji: '🌙',
    description:
        'Deep space obsidian — electric indigo & starlight, white text',
    primary: Color(0xFF4D6EFF), // vivid electric indigo — great default
    secondary: Color(0xFF8B9EFF), // soft periwinkle — readable subtitles
    background: Color(0xFF07071A), // deep obsidian black-blue
    surface: Color(0xFF10102E), // space indigo surface
    onSurface: Colors.white,
    accent: Color(0xFF64DFFF), // electric starlight cyan — kids love glow
    gradientColors: [Color(0xFF07071A), Color(0xFF10102E)],
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

// ─── Theme-aware text color helper ─────────────────────────────────────────
// All screens that previously hardcoded Colors.white should use
// Theme.of(context).colorScheme.onSurface instead. The theme system
// now correctly provides white for dark themes and dark color for light themes.

class AppTheme {
  static ThemeData buildTheme(AppUiThemeData uiTheme) {
    // All themes are deep/dark — text is always pure white.
    const textColor = Colors.white;
    // Subtle text at 75 % opacity — still passes WCAG AA on any deep background.
    final subtleTextColor = Colors.white.withAlpha(191); // ~75 %

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: uiTheme.primary,
        onPrimary: Colors.white,
        primaryContainer: uiTheme.primary.withAlpha(55),
        onPrimaryContainer: Colors.white,
        secondary: uiTheme.secondary,
        onSecondary: Colors.white,
        secondaryContainer: uiTheme.secondary.withAlpha(45),
        onSecondaryContainer: Colors.white,
        // Tertiary maps to accent — used for icons, FABs, badges
        tertiary: uiTheme.accent,
        onTertiary: Colors.black,
        tertiaryContainer: uiTheme.accent.withAlpha(40),
        onTertiaryContainer: Colors.white,
        error: const Color(0xFFFF6B6B),
        onError: Colors.white,
        surface: uiTheme.surface,
        onSurface: Colors.white,
        surfaceContainerHighest:
            Color.alphaBlend(uiTheme.primary.withAlpha(20), uiTheme.surface),
        onSurfaceVariant: Colors.white.withAlpha(180),
        outline: uiTheme.primary.withAlpha(90),
        outlineVariant: Colors.white.withAlpha(30),
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
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(textColor, subtleTextColor),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          // Subtle glowing border in the theme's primary colour
          side: BorderSide(color: uiTheme.primary.withAlpha(55), width: 1.2),
        ),
        color: uiTheme.surface,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: uiTheme.primary,
          foregroundColor: Colors.white,
          // Rounded pill shape — friendly for all ages
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: uiTheme.primary,
          side: BorderSide(color: uiTheme.primary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            Color.alphaBlend(uiTheme.primary.withAlpha(18), uiTheme.surface),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: uiTheme.primary.withAlpha(70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          // Accent glow on focus — visually exciting
          borderSide: BorderSide(color: uiTheme.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 15),
        labelStyle: TextStyle(color: Colors.white.withAlpha(150), fontSize: 14),
        floatingLabelStyle: TextStyle(
            color: uiTheme.accent, fontSize: 14, fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(
        color: uiTheme.primary.withAlpha(45),
        thickness: 1,
        space: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: uiTheme.accent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 4,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: uiTheme.surface,
        elevation: 10,
        selectedItemColor: uiTheme.accent, // accent for selected = glow
        unselectedItemColor: Colors.white.withAlpha(100),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 10),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            Color.alphaBlend(uiTheme.primary.withAlpha(40), uiTheme.surface),
        contentTextStyle:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 6,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: uiTheme.primary.withAlpha(35),
        disabledColor: uiTheme.surface.withAlpha(100),
        selectedColor: uiTheme.primary.withAlpha(90),
        secondarySelectedColor: uiTheme.secondary.withAlpha(90),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        labelStyle: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: uiTheme.primary.withAlpha(60))),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: uiTheme.primary,
        thumbColor: uiTheme.accent, // accent thumb = visible pop
        inactiveTrackColor: uiTheme.primary.withAlpha(50),
        overlayColor: uiTheme.accent.withAlpha(40),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? uiTheme.accent // accent on = vibrant
                : Colors.white.withAlpha(120)),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected)
                ? uiTheme.primary.withAlpha(120)
                : Colors.white.withAlpha(40)),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor, Color subtleColor) {
    return TextTheme(
      // Display styles — hero titles, big numbers
      displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          height: 1.15,
          letterSpacing: -0.5,
          color: textColor),
      displayMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: -0.3,
          color: textColor),
      // Title styles — section headers
      titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: 0.1,
          color: textColor),
      titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          height: 1.35,
          letterSpacing: 0.1,
          color: textColor),
      titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.4,
          letterSpacing: 0.1,
          color: textColor),
      // Body styles — readable at arm's length for all ages
      bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.55,
          letterSpacing: 0.3,
          color: textColor),
      bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.55,
          letterSpacing: 0.2,
          color: subtleColor),
      bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.3,
          color: subtleColor),
      // Label styles — buttons, chips, badges
      labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.0,
          letterSpacing: 0.5,
          color: textColor),
      labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.0,
          letterSpacing: 0.3,
          color: textColor),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          height: 1.0,
          letterSpacing: 0.5,
          color: subtleColor),
    );
  }

  static ThemeData get lightTheme =>
      buildTheme(appUiThemes[AppUiTheme.gardenSerenity]!);

  static ThemeData get darkTheme =>
      buildTheme(appUiThemes[AppUiTheme.midnightZen]!);
} // end AppTheme

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
