// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:shared_analytics/shared_analytics.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AnalyticsScreen — Wellness Insights dashboard
//
// The backend URL is resolved in priority order:
//   1. Compile-time  --dart-define=MASTER_BACKEND_URL=https://your-server.com
//   2. Debug Android emulator shortcut  http://10.0.2.2:8000
//   3. Release fallback                 https://api.pranaverse.app
//
// To point at a live server set the define in your build command, e.g.:
//   flutter run --dart-define=MASTER_BACKEND_URL=https://your-render-url.onrender.com
// ─────────────────────────────────────────────────────────────────────────────

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  /// Resolves the correct base URL at runtime.
  static String get _backendUrl {
    // 1. Compile-time override (production / CI)
    const envUrl = String.fromEnvironment('MASTER_BACKEND_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // 2. Debug: Android emulator loopback
    //    (kDebugMode is evaluated at compile time so tree-shaking still works)
    const bool isDebug = bool.fromEnvironment('dart.vm.product') == false;
    if (isDebug) return 'http://10.0.2.2:8000';

    // 3. Release fallback
    return 'https://api.pranaverse.app';
  }

  static AnalyticsService get _service => AnalyticsService(
        gameId: 'pranaverse',
        gameName: 'PranaVerse',
        baseUrl: _backendUrl,
      );

  @override
  Widget build(BuildContext context) {
    return AnalyticsDashboardScreen(
      service: _service,
      title: 'Wellness Insights',
      accentColor: const Color(0xFF39D353), // Garden Serenity green pop
    );
  }
}
