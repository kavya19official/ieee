import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../config/app_config.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize notification service
  Future<void> initialize() async {
    if (!AppConfig.enablePushNotifications) return;
    
    // Request permission
    await _requestPermission();
    
    // Initialize local notifications
    await _initializeLocalNotifications();
    
    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');
    
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Handle background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    
    // Handle notification when app is terminated
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleMessageOpenedApp(message);
      }
    });
  }
  
  // Request notification permission
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permission: ${settings.authorizationStatus}');
  }
  
  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }
  
  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');
    
    // Show local notification
    _showLocalNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
    
    // Save notification to Firestore
    if (message.data['userId'] != null) {
      _saveNotificationToFirestore(message);
    }
  }
  
  // Handle message opened from background/terminated
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened: ${message.notification?.title}');
    // Navigate to appropriate screen based on message data
    // This will be handled in the UI layer
  }
  
  // Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
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
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // On notification tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }
  
  // Save notification to Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: message.data['userId'] ?? '',
        type: _getNotificationType(message.data['type']),
        priority: _getNotificationPriority(message.data['priority']),
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        imageUrl: message.notification?.android?.imageUrl,
        data: message.data,
        actionUrl: message.data['actionUrl'],
        actionType: message.data['actionType'],
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('notifications').add(notification.toFirestore());
    } catch (e) {
      print('Error saving notification: $e');
    }
  }
  
  // Get user notifications
  Stream<List<AppNotification>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isGreaterThan: Timestamp.now())
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => 
          snapshot.docs.map((doc) => AppNotification.fromFirestore(doc)).toList()
        );
  }
  
  // Get unread notification count
  Stream<int> getUnreadNotificationCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
  
  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  
  // Mark all notifications as read
  Future<void> markAllAsRead(String userId) async {
    try {
      final batch = _firestore.batch();
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }
  
  // Send notification to user
  Future<void> sendNotificationToUser({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.medium,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    String? actionType,
  }) async {
    try {
      final notification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        type: type,
        priority: priority,
        title: title,
        body: body,
        imageUrl: imageUrl,
        data: data,
        actionUrl: actionUrl,
        actionType: actionType,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('notifications').add(notification.toFirestore());
      
      // Also send push notification via FCM (requires Cloud Function)
      // This would typically be done server-side
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
  
  // Schedule event reminder
  Future<void> scheduleEventReminder({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventTime,
  }) async {
    try {
      final reminderTime = eventTime.subtract(const Duration(hours: 2));
      
      if (reminderTime.isAfter(DateTime.now())) {
        await sendNotificationToUser(
          userId: userId,
          type: NotificationType.eventReminder,
          title: 'Event Reminder',
          body: '$eventTitle starts in 2 hours!',
          priority: NotificationPriority.high,
          data: {'eventId': eventId},
          actionUrl: '/event/$eventId',
          actionType: 'view_event',
        );
      }
    } catch (e) {
      print('Error scheduling event reminder: $e');
    }
  }
  
  // Get notification type from string
  NotificationType _getNotificationType(String? type) {
    if (type == null) return NotificationType.generalAnnouncement;
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => NotificationType.generalAnnouncement,
    );
  }
  
  // Get notification priority from string
  NotificationPriority _getNotificationPriority(String? priority) {
    if (priority == null) return NotificationPriority.medium;
    return NotificationPriority.values.firstWhere(
      (e) => e.toString().split('.').last == priority,
      orElse: () => NotificationPriority.medium,
    );
  }
  
  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }
  
  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
