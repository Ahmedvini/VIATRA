import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'chat_service.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('[NotificationService] Background message: ${message.messageId}');
  // Handle background message
}

/// Service for handling push notifications via Firebase Cloud Messaging
class NotificationService {
  factory NotificationService() => _instance;
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ChatService _chatService = ChatService();

  final _messageController = StreamController<RemoteMessage>.broadcast();
  String? _fcmToken;

  /// Stream of notification messages
  Stream<RemoteMessage> get onMessage => _messageController.stream;

  /// Get the FCM token
  String? get fcmToken => _fcmToken;

  /// Initialize the notification service
  Future<void> initialize() async {
    // Request permission
    final settings = await _requestPermission();
    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      print('[NotificationService] Notification permissions not granted');
      return;
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get FCM token
    _fcmToken = await _messaging.getToken();
    print('[NotificationService] FCM Token: $_fcmToken');

    // Upload token to backend
    if (_fcmToken != null) {
      try {
        await _chatService.updateFcmToken(_fcmToken!);
      } catch (e) {
        print('[NotificationService] Error uploading FCM token: $e');
      }
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      _fcmToken = newToken;
      print('[NotificationService] FCM Token refreshed: $newToken');
      try {
        await _chatService.updateFcmToken(newToken);
      } catch (e) {
        print('[NotificationService] Error uploading refreshed FCM token: $e');
      }
    });

    // Set up message handlers
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification opened app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Check if app was opened from a notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  /// Request notification permissions
  Future<NotificationSettings> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    return settings;
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'chat_messages',
        'Chat Messages',
        description: 'Notifications for new chat messages',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('[NotificationService] Foreground message: ${message.messageId}');
    print('[NotificationService] Data: ${message.data}');

    _messageController.add(message);

    // Show local notification
    _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification != null) {
      const androidDetails = AndroidNotificationDetails(
        'chat_messages',
        'Chat Messages',
        channelDescription: 'Notifications for new chat messages',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload: message.data['conversation_id'] as String?,
      );
    }
  }

  /// Handle notification tap from local notification
  void _handleLocalNotificationTap(NotificationResponse response) {
    print(
        '[NotificationService] Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      // Navigate to conversation
      // This will be handled by the app's navigation logic
      _messageController.add(
        RemoteMessage(
          data: {
            'type': 'new_message',
            'conversation_id': response.payload!,
          },
        ),
      );
    }
  }

  /// Handle notification opened app
  void _handleNotificationOpen(RemoteMessage message) {
    print('[NotificationService] Notification opened app: ${message.messageId}');
    print('[NotificationService] Data: ${message.data}');

    _messageController.add(message);
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('[NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      print('[NotificationService] Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('[NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      print('[NotificationService] Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      print('[NotificationService] FCM token deleted');
    } catch (e) {
      print('[NotificationService] Error deleting FCM token: $e');
    }
  }

  /// Set badge count (iOS)
  Future<void> setBadgeCount(int count) async {
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Clean up resources
  void dispose() {
    _messageController.close();
  }
}
