import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  eventReminder,
  eventUpdate,
  eventCancelled,
  registrationConfirmed,
  attendanceMarked,
  applicationSubmitted,
  applicationStatusUpdate,
  interviewScheduled,
  generalAnnouncement,
  systemUpdate,
}

enum NotificationPriority {
  low,
  medium,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String userId;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final String? actionUrl;
  final String? actionType;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;
  
  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    this.priority = NotificationPriority.medium,
    required this.title,
    required this.body,
    this.imageUrl,
    this.data,
    this.actionUrl,
    this.actionType,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
  });
  
  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${data['type']}',
        orElse: () => NotificationType.generalAnnouncement,
      ),
      priority: NotificationPriority.values.firstWhere(
        (e) => e.toString() == 'NotificationPriority.${data['priority']}',
        orElse: () => NotificationPriority.medium,
      ),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      imageUrl: data['imageUrl'],
      data: data['data'],
      actionUrl: data['actionUrl'],
      actionType: data['actionType'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      readAt: data['readAt'] != null 
          ? (data['readAt'] as Timestamp).toDate() 
          : null,
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'title': title,
      'body': body,
      'imageUrl': imageUrl,
      'data': data,
      'actionUrl': actionUrl,
      'actionType': actionType,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }
  
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

class NotificationPreferences {
  final String userId;
  final bool eventReminders;
  final bool eventUpdates;
  final bool applicationUpdates;
  final bool generalAnnouncements;
  final bool marketingEmails;
  final Map<String, bool>? customPreferences;
  
  NotificationPreferences({
    required this.userId,
    this.eventReminders = true,
    this.eventUpdates = true,
    this.applicationUpdates = true,
    this.generalAnnouncements = true,
    this.marketingEmails = false,
    this.customPreferences,
  });
  
  factory NotificationPreferences.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationPreferences(
      userId: doc.id,
      eventReminders: data['eventReminders'] ?? true,
      eventUpdates: data['eventUpdates'] ?? true,
      applicationUpdates: data['applicationUpdates'] ?? true,
      generalAnnouncements: data['generalAnnouncements'] ?? true,
      marketingEmails: data['marketingEmails'] ?? false,
      customPreferences: data['customPreferences'] != null
          ? Map<String, bool>.from(data['customPreferences'])
          : null,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'eventReminders': eventReminders,
      'eventUpdates': eventUpdates,
      'applicationUpdates': applicationUpdates,
      'generalAnnouncements': generalAnnouncements,
      'marketingEmails': marketingEmails,
      'customPreferences': customPreferences,
    };
  }
}
