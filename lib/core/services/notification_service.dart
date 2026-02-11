import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/notification.dart';
import '../utils/app_logger.dart';
import '../utils/platform_utils.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('NotificationService',
      'Background message received: ${message.messageId}');
  // Handle background notification here
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _logScope = 'NotificationService';

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Skip FCM initialization on web (use in-app notifications only)
    if (PlatformUtils.isWeb) {
      AppLogger.info(_logScope,
          'Running on web - FCM push notifications not fully supported');
      AppLogger.info(_logScope, 'Using in-app notification center only');
      return;
    }

    // Request notification permissions (mobile only)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.info(_logScope, 'User granted notification permission');

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        AppLogger.info(_logScope, 'FCM token acquired.');
        // Save token to Firestore (will be done after user authentication)
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        AppLogger.info(_logScope, 'FCM token refreshed.');
        // Update token in Firestore
      });

      // Configure foreground notification presentation
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check if app was opened from a notification
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
    } else {
      AppLogger.warn(_logScope, 'User declined notification permission');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
        _logScope, 'Foreground message: ${message.notification?.title}');

    // Create in-app notification
    if (message.data.isNotEmpty) {
      _createInAppNotification(
        userId: message.data['userId'] ?? '',
        type: message.data['type'] ?? 'system_announcement',
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        data: message.data,
      );
    }
  }

  /// Handle notification tap (app opened from background)
  void _handleNotificationTap(RemoteMessage message) {
    AppLogger.info(_logScope, 'Notification tapped. data=${message.data}');

    // Navigate to relevant screen based on data
    String? actionUrl = message.data['actionUrl'];
    if (actionUrl != null) {
      // TODO: Implement deep linking navigation
      AppLogger.info(_logScope, 'Navigate to: $actionUrl');
    }
  }

  /// Save FCM token to user document
  Future<void> saveFcmToken(String userId) async {
    if (PlatformUtils.isWeb) return; // Skip on web

    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(userId).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        AppLogger.info(_logScope, 'FCM token saved for user: $userId');
      }
    } catch (e) {
      AppLogger.error(_logScope, 'Error saving FCM token for user: $userId', e);
    }
  }

  /// Delete FCM token on logout
  Future<void> deleteFcmToken(String userId) async {
    if (PlatformUtils.isWeb) return; // Skip on web

    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      await _firebaseMessaging.deleteToken();
      AppLogger.info(_logScope, 'FCM token deleted for user: $userId');
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error deleting FCM token for user: $userId', e);
    }
  }

  /// Create in-app notification in Firestore
  Future<void> _createInAppNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': type,
        'title': title,
        'body': body,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
        'data': data,
        'actionUrl': data?['actionUrl'],
      });
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error creating in-app notification for user: $userId', e);
    }
  }

  /// Get user notifications stream
  Stream<List<AppNotification>> getUserNotifications(String userId,
      {int limit = 50}) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error marking notification as read: $notificationId', e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error(_logScope,
          'Error marking all notifications as read for user: $userId', e);
    }
  }

  /// Get unread notification count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.size);
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error deleting notification: $notificationId', e);
    }
  }

  /// Delete all notifications for user
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      AppLogger.error(
          _logScope, 'Error deleting all notifications for user: $userId', e);
    }
  }

  /// Subscribe to topic (for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.info(_logScope, 'Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error(_logScope, 'Error subscribing to topic: $topic', e);
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.info(_logScope, 'Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error(_logScope, 'Error unsubscribing from topic: $topic', e);
    }
  }
}
