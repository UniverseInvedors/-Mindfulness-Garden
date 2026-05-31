import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    // No initialization needed for testing
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> scheduleDailyReminder({
    required DateTime time,
    required String title,
    required String body,
  }) async {
    // For testing, just log the notification
    print('📱 Would schedule notification: $title - $body at $time');
  }

  Future<void> showSessionCompleteNotification({
    required int duration,
    required int streak,
  }) async {
    print('📱 Session complete: $duration min, streak: $streak days');
  }

  Future<void> cancelAllNotifications() async {
    print('📱 All notifications cancelled');
  }

  Future<void> requestPermissions() async {
    print('📱 Requesting notification permissions');
  }
}
