// lib/core/services/fcm_service.dart
//
// Firebase Cloud Messaging service for PranaVerse.
// Handles:
//   • FCM token retrieval & refresh
//   • Foreground / background / terminated message handling
//   • Local notification display for foreground messages
//   • Meditation / streak reminder topic subscriptions

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Background handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('📲 FCM background message: ${message.messageId}');
  }
}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _initialized = false;

  String? get fcmToken => _fcmToken;

  // ─── Initialization ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request permission (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      debugPrint('🔔 FCM permission: ${settings.authorizationStatus.name}');
    }

    // Configure local notifications for foreground display
    await _initLocalNotifications();

    // Foreground messages → show as local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Message tap while app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageTap);

    // App launched from a notification (terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) _handleMessageTap(initialMessage);

    // Get / refresh token
    _fcmToken = await _messaging.getToken();
    if (kDebugMode) debugPrint('🔑 FCM token: $_fcmToken');

    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      if (kDebugMode) debugPrint('🔄 FCM token refreshed: $token');
      // TODO: send updated token to your backend / Firestore
    });

    // Subscribe to default topics
    await subscribeToTopic('daily_reminders');
    await subscribeToTopic('mindfulness_tips');

    _initialized = true;
    if (kDebugMode) debugPrint('✅ FCM service initialized');
  }

  // ─── Local notifications setup ────────────────────────────────────────────

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotif.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Create high-importance channel for Android
    await _localNotif
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'pranaverse_high',
            'PranaVerse Notifications',
            description: 'Mindfulness reminders and session updates',
            importance: Importance.high,
          ),
        );
  }

  // ─── Message handlers ─────────────────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📬 FCM foreground: ${message.notification?.title}');
    }
    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      message.hashCode,
      notif.title,
      notif.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pranaverse_high',
          'PranaVerse Notifications',
          channelDescription: 'Mindfulness reminders and session updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('👆 FCM tapped: ${message.data}');
    }
    // TODO: route user to the relevant screen based on message.data['screen']
  }

  // ─── Topic subscriptions ──────────────────────────────────────────────────

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    if (kDebugMode) debugPrint('✅ Subscribed to topic: $topic');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    if (kDebugMode) debugPrint('❌ Unsubscribed from topic: $topic');
  }

  // ─── Scheduled local reminders (no FCM needed) ───────────────────────────

  Future<void> showMeditationReminder({
    required String title,
    required String body,
  }) async {
    await _localNotif.show(
      1001,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pranaverse_high',
          'PranaVerse Notifications',
          channelDescription: 'Mindfulness reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showSessionCompleteNotification({
    required int duration,
    required int streak,
  }) async {
    await _localNotif.show(
      1002,
      'Session Complete! 🧘',
      '$duration minutes of mindfulness. Streak: $streak days 🔥',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pranaverse_high',
          'PranaVerse Notifications',
          channelDescription: 'Session completion alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelAll() async {
    await _localNotif.cancelAll();
  }
}
