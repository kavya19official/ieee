import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus {
  draft,
  published,
  ongoing,
  completed,
  cancelled,
}

enum EventCategory {
  workshop,
  seminar,
  networking,
  competition,
  social,
  recruitment,
  general,
}

class Event {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final EventCategory category;
  final EventStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final String venue;
  final String? venueDetails;
  final double? latitude;
  final double? longitude;
  final String? speaker;
  final String? speakerBio;
  final String? speakerImage;
  final int maxAttendees;
  final int currentRegistrations;
  final int actualAttendance;
  final bool requiresRegistration;
  final String? registrationFormUrl;
  final String? registrationFormId;
  final bool isPublished;
  final bool isFeatured;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final List<String> organizers;
  final String? qrCodeData;
  final Map<String, dynamic>? additionalInfo;
  final bool allowWaitlist;
  final int waitlistCount;
  final DateTime? registrationDeadline;
  final List<String> eligibilityCriteria;
  final bool requiresApproval;
  
  Event({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.category,
    this.status = EventStatus.draft,
    required this.startTime,
    required this.endTime,
    required this.venue,
    this.venueDetails,
    this.latitude,
    this.longitude,
    this.speaker,
    this.speakerBio,
    this.speakerImage,
    this.maxAttendees = 100,
    this.currentRegistrations = 0,
    this.actualAttendance = 0,
    this.requiresRegistration = true,
    this.registrationFormUrl,
    this.registrationFormId,
    this.isPublished = false,
    this.isFeatured = false,
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.organizers = const [],
    this.qrCodeData,
    this.additionalInfo,
    this.allowWaitlist = false,
    this.waitlistCount = 0,
    this.registrationDeadline,
    this.eligibilityCriteria = const [],
    this.requiresApproval = false,
  });
  
  factory Event.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      category: EventCategory.values.firstWhere(
        (e) => e.toString() == 'EventCategory.${data['category']}',
        orElse: () => EventCategory.general,
      ),
      status: EventStatus.values.firstWhere(
        (e) => e.toString() == 'EventStatus.${data['status']}',
        orElse: () => EventStatus.draft,
      ),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      venue: data['venue'] ?? '',
      venueDetails: data['venueDetails'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      speaker: data['speaker'],
      speakerBio: data['speakerBio'],
      speakerImage: data['speakerImage'],
      maxAttendees: data['maxAttendees'] ?? 100,
      currentRegistrations: data['currentRegistrations'] ?? 0,
      actualAttendance: data['actualAttendance'] ?? 0,
      requiresRegistration: data['requiresRegistration'] ?? true,
      registrationFormUrl: data['registrationFormUrl'],
      registrationFormId: data['registrationFormId'],
      isPublished: data['isPublished'] ?? false,
      isFeatured: data['isFeatured'] ?? false,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      tags: List<String>.from(data['tags'] ?? []),
      organizers: List<String>.from(data['organizers'] ?? []),
      qrCodeData: data['qrCodeData'],
      additionalInfo: data['additionalInfo'],
      allowWaitlist: data['allowWaitlist'] ?? false,
      waitlistCount: data['waitlistCount'] ?? 0,
      registrationDeadline: data['registrationDeadline'] != null
          ? (data['registrationDeadline'] as Timestamp).toDate()
          : null,
      eligibilityCriteria: List<String>.from(data['eligibilityCriteria'] ?? []),
      requiresApproval: data['requiresApproval'] ?? false,
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last,
      'status': status.toString().split('.').last,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'venue': venue,
      'venueDetails': venueDetails,
      'latitude': latitude,
      'longitude': longitude,
      'speaker': speaker,
      'speakerBio': speakerBio,
      'speakerImage': speakerImage,
      'maxAttendees': maxAttendees,
      'currentRegistrations': currentRegistrations,
      'actualAttendance': actualAttendance,
      'requiresRegistration': requiresRegistration,
      'registrationFormUrl': registrationFormUrl,
      'registrationFormId': registrationFormId,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'tags': tags,
      'organizers': organizers,
      'qrCodeData': qrCodeData,
      'additionalInfo': additionalInfo,
      'allowWaitlist': allowWaitlist,
      'waitlistCount': waitlistCount,
      'registrationDeadline': registrationDeadline != null 
          ? Timestamp.fromDate(registrationDeadline!) 
          : null,
      'eligibilityCriteria': eligibilityCriteria,
      'requiresApproval': requiresApproval,
    };
  }
  
  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing => DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isPast => endTime.isBefore(DateTime.now());
  bool get isFull => currentRegistrations >= maxAttendees;
  bool get hasRegistrationClosed => registrationDeadline != null && 
      DateTime.now().isAfter(registrationDeadline!);
  
  double get attendanceRate => currentRegistrations > 0 
      ? (actualAttendance / currentRegistrations) * 100 
      : 0;
}

class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final DateTime registeredAt;
  final bool isWaitlisted;
  final bool isApproved;
  final bool hasAttended;
  final DateTime? attendedAt;
  final String? attendanceMethod; // 'qr', 'manual'
  final Map<String, dynamic>? formResponses;
  final String? qrScanId;
  
  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.registeredAt,
    this.isWaitlisted = false,
    this.isApproved = true,
    this.hasAttended = false,
    this.attendedAt,
    this.attendanceMethod,
    this.formResponses,
    this.qrScanId,
  });
  
  factory EventRegistration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventRegistration(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      registeredAt: (data['registeredAt'] as Timestamp).toDate(),
      isWaitlisted: data['isWaitlisted'] ?? false,
      isApproved: data['isApproved'] ?? true,
      hasAttended: data['hasAttended'] ?? false,
      attendedAt: data['attendedAt'] != null 
          ? (data['attendedAt'] as Timestamp).toDate() 
          : null,
      attendanceMethod: data['attendanceMethod'],
      formResponses: data['formResponses'],
      qrScanId: data['qrScanId'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'userId': userId,
      'registeredAt': Timestamp.fromDate(registeredAt),
      'isWaitlisted': isWaitlisted,
      'isApproved': isApproved,
      'hasAttended': hasAttended,
      'attendedAt': attendedAt != null ? Timestamp.fromDate(attendedAt!) : null,
      'attendanceMethod': attendanceMethod,
      'formResponses': formResponses,
      'qrScanId': qrScanId,
    };
  }
}
