// lib/core/services/analytics_service.dart
//
// Firebase Analytics + Crashlytics service for PranaVerse.
// Replaces the previous Sentry + PostHog implementation.

import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // NavigatorObserver for automatic screen tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> initialize() async {
    // Enable Crashlytics in release, disable in debug so dev errors stay local
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // Forward Flutter framework errors to Crashlytics
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _crashlytics.recordFlutterFatalError(details);
    };

    // Catch async errors outside of Flutter's widget tree
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };

    if (kDebugMode) debugPrint('📊 Firebase Analytics + Crashlytics ready');
  }

  // ─── Screen tracking ───────────────────────────────────────────────────────

  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass ?? screenName,
    );
  }

  // ─── Generic event ────────────────────────────────────────────────────────

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  // ─── Mindfulness-specific events ──────────────────────────────────────────

  Future<void> logMeditationStarted({
    required String type,
    required int duration,
  }) async {
    await _analytics.logEvent(
      name: 'meditation_started',
      parameters: {
        'type': type,
        'duration_minutes': duration,
      },
    );
  }

  Future<void> logMeditationCompleted({
    required String type,
    required int duration,
    required bool completed,
  }) async {
    await _analytics.logEvent(
      name: 'meditation_completed',
      parameters: {
        'type': type,
        'duration_minutes': duration,
        'completed': completed ? 1 : 0,
      },
    );
  }

  Future<void> logBreathingExercise({
    required String exerciseType,
    required int durationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'breathing_exercise',
      parameters: {
        'exercise_type': exerciseType,
        'duration_seconds': durationSeconds,
      },
    );
  }

  Future<void> logGardenAction({
    required String action,
    required String plantType,
  }) async {
    await _analytics.logEvent(
      name: 'garden_action',
      parameters: {'action': action, 'plant_type': plantType},
    );
  }

  Future<void> logMoodTracked({
    required String mood,
    required double rating,
  }) async {
    await _analytics.logEvent(
      name: 'mood_tracked',
      parameters: {
        'mood': mood,
        'rating': rating.toStringAsFixed(1),
      },
    );
  }

  Future<void> logSubscriptionEvent({
    required String event,
    required String plan,
    required double price,
  }) async {
    await _analytics.logEvent(
      name: 'subscription_$event',
      parameters: {'plan': plan, 'price': price.toString()},
    );
  }

  Future<void> logAchievementUnlocked(String achievementId) async {
    await _analytics.logEvent(
      name: 'unlock_achievement',
      parameters: {'achievement_id': achievementId},
    );
  }

  // ─── User identity ────────────────────────────────────────────────────────

  Future<void> setUserId(String uid) async {
    await _analytics.setUserId(id: uid);
    await _crashlytics.setUserIdentifier(uid);
  }

  Future<void> setUserProperty(String name, String? value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ─── Error reporting ──────────────────────────────────────────────────────

  Future<void> recordError({
    required dynamic exception,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      fatal: fatal,
    );
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }
}

// ─── Navigator observer (pass to MaterialApp.router navigatorObservers) ───────

FirebaseAnalyticsObserver get firebaseAnalyticsObserver =>
    AnalyticsService().observer;

// ─── Screen-tracking wrapper widget ──────────────────────────────────────────

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService().logScreenView(screenName);
    });
    return child;
  }
}
