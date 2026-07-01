// lib/core/mixins/theme_audio_mixin.dart
//
// Mix this into any StatefulWidget State to get theme-based ambient audio
// that starts when the screen opens and stops when it closes.
//
// Usage:
//   class _MyScreenState extends State<MyScreen> with ThemeAudioMixin {
//     @override void initState() { super.initState(); startThemeAudio(); }
//     @override void dispose()   { stopThemeAudio(); super.dispose(); }
//   }

import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:pranaverse/core/providers/app_settings_provider.dart';
import 'package:pranaverse/core/services/sound_service.dart';
import 'package:pranaverse/core/themes/app_theme.dart';

mixin ThemeAudioMixin<T extends StatefulWidget> on State<T> {
  // ── Public API ────────────────────────────────────────────────────────────

  /// Call from initState (via addPostFrameCallback so context is ready).
  void startThemeAudio() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final theme = context.read<AppSettingsProvider>().uiTheme;
      SoundService().playAmbientTrack(_trackForTheme(theme));
    });
  }

  /// Call at the top of dispose, before super.dispose().
  void stopThemeAudio() {
    SoundService().stopBg();
  }

  // ── Theme → track mapping ─────────────────────────────────────────────────

  /// Each UI theme maps to the ambient track that best fits its mood.
  static String _trackForTheme(AppUiTheme theme) {
    switch (theme) {
      case AppUiTheme.gardenSerenity:
        return 'assets/music/stress_relief.mp3'; // Lush, peaceful forest
      case AppUiTheme.skyCalm:
        return 'assets/music/morning_meditation.mp3'; // Bright, open sky
      case AppUiTheme.sunriseGlow:
        return 'assets/music/energy_boost.mp3'; // Warm sunrise energy
      case AppUiTheme.roseHarmony:
        return 'assets/music/stress_relief.mp3'; // Gentle, harmonic calm
      case AppUiTheme.lavenderDream:
        return 'assets/music/deep_sleep.mp3'; // Cosmic, dreamy night
      case AppUiTheme.midnightZen:
        return 'assets/music/deep_sleep.mp3'; // Deep midnight calm
    }
  }
}
