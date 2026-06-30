// lib/core/services/notification_service.dart
//
// Thin wrapper that delegates to FcmService.
// Keeps the existing call-sites working without changes.

import 'package:pranaverse/core/services/fcm_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FcmService _fcm = FcmService();

  Future<void> initialize() => _fcm.initialize();

  Future<void> requestPermissions() async {
    // Permissions are requested inside FcmService.initialize()
  }

  Future<void> showSessionCompleteNotification({
    required int duration,
    required int streak,
  }) =>
      _fcm.showSessionCompleteNotification(duration: duration, streak: streak);

  Future<void> showMeditationReminder({
    required String title,
    required String body,
  }) =>
      _fcm.showMeditationReminder(title: title, body: body);

  Future<void> cancelAllNotifications() => _fcm.cancelAll();

  Future<void> subscribeToTopic(String topic) => _fcm.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  void dispose() {}
}
