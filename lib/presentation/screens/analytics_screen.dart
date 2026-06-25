import 'package:flutter/material.dart';
import 'package:shared_analytics/shared_analytics.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  static final _service = AnalyticsService(gameId: 'pranaverse', gameName: 'PranaVerse');
  @override
  Widget build(BuildContext context) => AnalyticsDashboardScreen(
        service: _service, title: 'Wellness Insights',
        accentColor: const Color(0xFF8DD9C4));
}
