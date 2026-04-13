import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'logger_service.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here
  LoggerService.instance.info(
    'Handling background message: ${message.messageId}',
  );
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  static NotificationService get to => instance;

  final _plugin = FlutterLocalNotificationsPlugin();
  final _fcm = FirebaseMessaging.instance;
  final _logger = LoggerService.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  static Future<void> initialize() async {
    // Initialize local notifications
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await instance._plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        instance._logger.info('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channel for Android
    await instance._createNotificationChannel();

    // Initialize Firebase Messaging
    await instance._initializeFCM();
  }

  /// Initialize Firebase Cloud Messaging
  Future<void> _initializeFCM() async {
    try {
      // Request permission for iOS
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.info('FCM permission status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Get FCM token
        _fcmToken = await _fcm.getToken();
        _logger.info('FCM Token: $_fcmToken');

        // Listen to token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          _logger.info('FCM Token refreshed: $newToken');
          // TODO: Send updated token to your backend
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        // Handle notification opened from terminated state
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        // Check if app was opened from a notification
        final initialMessage = await _fcm.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }
      }
    } catch (e, stack) {
      _logger.error('Failed to initialize FCM', e, stack);
    }
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    _logger.info('Foreground message received: ${message.messageId}');

    final notification = message.notification;

    if (notification != null) {
      // Show local notification when app is in foreground
      await show(
        id: message.hashCode,
        title: notification.title ?? 'Notification',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.info('Notification opened: ${message.messageId}');
    // TODO: Navigate to specific screen based on message data
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'vahaan_channel',
        'Vahaan Notifications',
        description: 'Notifications for Vahaan Bazar app',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Show local notification
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const android = AndroidNotificationDetails(
      'vahaan_channel',
      'Vahaan Notifications',
      channelDescription: 'Notifications for Vahaan Bazar app',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: android, iOS: ios),
      payload: payload,
    );
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      _logger.info('Subscribed to topic: $topic');
    } catch (e, stack) {
      _logger.error('Failed to subscribe to topic: $topic', e, stack);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      _logger.info('Unsubscribed from topic: $topic');
    } catch (e, stack) {
      _logger.error('Failed to unsubscribe from topic: $topic', e, stack);
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Cancel specific notification
  Future<void> cancel(int id) => _plugin.cancel(id);
}
