// lib/core/services/analytics_service.dart
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'dart:async';

import 'package:flutter/material.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  Future<void> initialize() async {
    // Initialize Sentry for crash reporting
    await SentryFlutter.init(
      (options) {
        options.dsn = 'YOUR_SENTRY_DSN'; // Replace with your Sentry DSN
        options.tracesSampleRate = kDebugMode ? 1.0 : 0.1;
        options.environment = kDebugMode ? 'development' : 'production';
      },
    );

    // Initialize PostHog for analytics
    await PosthogFlutter().start(
      apiKey: 'YOUR_POSTHOG_API_KEY', // Replace with your PostHog API key
      host: 'https://app.posthog.com',
    );

    if (kDebugMode) {
      print('📊 Analytics service initialized (Sentry + PostHog)');
    }
  }

  // Screen Tracking
  Future<void> logScreenView(String screenName) async {
    await PosthogFlutter().screen(screenName: screenName);
  }

  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await PosthogFlutter().capture(
      eventName: name,
      properties: parameters,
    );
  }

  // Common Events
  Future<void> logMeditationStarted({
    required String type,
    required int duration,
  }) async {
    await logEvent(
      name: 'meditation_started',
      parameters: {
        'type': type,
        'duration_minutes': duration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logMeditationCompleted({
    required String type,
    required int duration,
    required bool completed,
  }) async {
    await logEvent(
      name: 'meditation_completed',
      parameters: {
        'type': type,
        'duration_minutes': duration,
        'completed': completed,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logGardenAction({
    required String action,
    required String plantType,
  }) async {
    await logEvent(
      name: 'garden_action',
      parameters: {
        'action': action,
        'plant_type': plantType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  Future<void> logSubscriptionEvent({
    required String event,
    required String plan,
    required double price,
  }) async {
    await logEvent(
      name: 'subscription_$event',
      parameters: {
        'plan': plan,
        'price': price,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Error Reporting
  Future<void> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      hint: reason,
    );
  }

  // User Identification
  Future<void> setUserId(String userId) async {
    await PosthogFlutter().identify(userId: userId);
    Sentry.configureScope((scope) => scope.setUser(SentryUser(id: userId)));
  }

  // Custom Attributes
  Future<void> setCustomKey(String key, dynamic value) async {
    await PosthogFlutter().capture(
      eventName: '$key_set',
      properties: {key: value},
    );
    Sentry.configureScope((scope) => scope.setExtra(key, value));
  }
}

// Usage in app
class AnalyticsWrapper extends StatelessWidget {
  final Widget child;
  final String screenName;

  const AnalyticsWrapper({
    super.key,
    required this.child,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    // Log screen view when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logScreenView(screenName);
    });

    return child;
  }
}

// Error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext, FlutterErrorDetails) fallback;

  const ErrorBoundary({super.key, required this.child, required this.fallback});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      _errorDetails = details;
      AnalyticsService().recordError(
        exception: details.exception,
        stackTrace: details.stack,
        reason: details.context?.toString(),
      );
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.fallback(context, _errorDetails!);
    }
    return widget.child;
  }
}
