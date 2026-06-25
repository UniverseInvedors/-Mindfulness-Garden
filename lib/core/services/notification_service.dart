import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FlutterLocalNotificationsPlugin? _notificationsPlugin;
  bool _isInitialized = false;
  Position? _lastKnownPosition;
  Timer? _locationCheckTimer;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize notifications
      _notificationsPlugin = FlutterLocalNotificationsPlugin();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings();

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _notificationsPlugin!.initialize(initializationSettings);

      // Request permissions
      await requestPermissions();

      // Start location-based notification monitoring
      _startLocationMonitoring();

      _isInitialized = true;

      if (kDebugMode) {
        print('📱 Notification service initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize notification service: $e');
      }
    }
  }

  Future<void> requestPermissions() async {
    try {
      // Request notification permissions
      final notificationStatus = await Permission.notification.request();
      if (kDebugMode) {
        print('📱 Notification permission: ${notificationStatus.isGranted}');
      }

      // Request location permissions for direction-based notifications
      final locationStatus = await Permission.location.request();
      if (kDebugMode) {
        print('📍 Location permission: ${locationStatus.isGranted}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to request permissions: $e');
      }
    }
  }

  void _startLocationMonitoring() {
    // Check location every 5 minutes for direction-based notifications
    _locationCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _checkLocationAndNotify();
    });
  }

  Future<void> _checkLocationAndNotify() async {
    try {
      final hasPermission = await Permission.location.isGranted;
      if (!hasPermission) return;

      final currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (_lastKnownPosition != null) {
        final bearing = Geolocator.bearingBetween(
          _lastKnownPosition!.latitude,
          _lastKnownPosition!.longitude,
          currentPosition.latitude,
          currentPosition.longitude,
        );

        // Get direction based on bearing
        final direction = _getDirectionFromBearing(bearing);

        // Send direction-based notification
        await _showDirectionNotification(direction);
      }

      _lastKnownPosition = currentPosition;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking location: $e');
      }
    }
  }

  String _getDirectionFromBearing(double bearing) {
    // Normalize bearing to 0-360
    var normalizedBearing = bearing % 360;
    if (normalizedBearing < 0) normalizedBearing += 360;

    if (normalizedBearing >= 337.5 || normalizedBearing < 22.5) {
      return 'North';
    } else if (normalizedBearing >= 22.5 && normalizedBearing < 67.5) {
      return 'Northeast';
    } else if (normalizedBearing >= 67.5 && normalizedBearing < 112.5) {
      return 'East';
    } else if (normalizedBearing >= 112.5 && normalizedBearing < 157.5) {
      return 'Southeast';
    } else if (normalizedBearing >= 157.5 && normalizedBearing < 202.5) {
      return 'South';
    } else if (normalizedBearing >= 202.5 && normalizedBearing < 247.5) {
      return 'Southwest';
    } else if (normalizedBearing >= 247.5 && normalizedBearing < 292.5) {
      return 'West';
    } else {
      return 'Northwest';
    }
  }

  Future<void> _showDirectionNotification(String direction) async {
    if (_notificationsPlugin == null) return;

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'direction_notifications',
      'Direction Notifications',
      channelDescription: 'Notifications based on movement direction',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin!.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      'Mindfulness Moment',
      'Heading $direction - Take a moment to breathe',
      platformChannelSpecifics,
    );

    if (kDebugMode) {
      print('📱 Direction notification sent: $direction');
    }
  }

  Future<void> scheduleDailyReminder({
    required DateTime time,
    required String title,
    required String body,
  }) async {
    if (_notificationsPlugin == null) return;

    try {
      final scheduledTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        time.hour,
        time.minute,
      );

      if (scheduledTime.isBefore(DateTime.now())) {
        scheduledTime.add(const Duration(days: 1));
      }

      await _notificationsPlugin!.showDailyAtTime(
        0,
        title,
        body,
        Time(time.hour, time.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminders',
            'Daily Reminders',
            channelDescription: 'Daily meditation reminders',
          ),
        ),
      );

      if (kDebugMode) {
        print('📱 Daily reminder scheduled: $title at $time');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule daily reminder: $e');
      }
    }
  }

  Future<void> showSessionCompleteNotification({
    required int duration,
    required int streak,
  }) async {
    if (_notificationsPlugin == null) return;

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'session_complete',
        'Session Complete',
        channelDescription: 'Notifications when meditation sessions complete',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notificationsPlugin!.show(
        DateTime.now().millisecondsSinceEpoch % 100000,
        'Session Complete! 🧘',
        'Great job! $duration minutes of mindfulness. Streak: $streak days 🔥',
        platformChannelSpecifics,
      );

      if (kDebugMode) {
        print('📱 Session complete notification: $duration min, streak: $streak days');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to show session notification: $e');
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    if (_notificationsPlugin == null) return;

    try {
      await _notificationsPlugin!.cancelAll();
      if (kDebugMode) {
        print('📱 All notifications cancelled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel notifications: $e');
      }
    }
  }

  void dispose() {
    _locationCheckTimer?.cancel();
    _isInitialized = false;
  }
}
