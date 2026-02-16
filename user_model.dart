import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  student,
  organizer,
  admin,
}

enum MembershipStatus {
  pending,
  active,
  inactive,
  suspended,
}

class AppUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? phoneNumber;
  final String? department;
  final String? yearOfStudy;
  final String? studentId;
  final UserRole role;
  final MembershipStatus membershipStatus;
  final List<String> permissions;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? preferences;
  final bool isEmailVerified;
  final bool isProfileComplete;
  final int engagementScore;
  final List<String> registeredEventIds;
  final List<String> attendedEventIds;
  final List<String> applicationIds;
  
  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.phoneNumber,
    this.department,
    this.yearOfStudy,
    this.studentId,
    this.role = UserRole.student,
    this.membershipStatus = MembershipStatus.pending,
    this.permissions = const [],
    required this.createdAt,
    this.lastLoginAt,
    this.preferences,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
    this.engagementScore = 0,
    this.registeredEventIds = const [],
    this.attendedEventIds = const [],
    this.applicationIds = const [],
  });
  
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      department: data['department'],
      yearOfStudy: data['yearOfStudy'],
      studentId: data['studentId'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.student,
      ),
      membershipStatus: MembershipStatus.values.firstWhere(
        (e) => e.toString() == 'MembershipStatus.${data['membershipStatus']}',
        orElse: () => MembershipStatus.pending,
      ),
      permissions: List<String>.from(data['permissions'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : null,
      preferences: data['preferences'],
      isEmailVerified: data['isEmailVerified'] ?? false,
      isProfileComplete: data['isProfileComplete'] ?? false,
      engagementScore: data['engagementScore'] ?? 0,
      registeredEventIds: List<String>.from(data['registeredEventIds'] ?? []),
      attendedEventIds: List<String>.from(data['attendedEventIds'] ?? []),
      applicationIds: List<String>.from(data['applicationIds'] ?? []),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'department': department,
      'yearOfStudy': yearOfStudy,
      'studentId': studentId,
      'role': role.toString().split('.').last,
      'membershipStatus': membershipStatus.toString().split('.').last,
      'permissions': permissions,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'preferences': preferences,
      'isEmailVerified': isEmailVerified,
      'isProfileComplete': isProfileComplete,
      'engagementScore': engagementScore,
      'registeredEventIds': registeredEventIds,
      'attendedEventIds': attendedEventIds,
      'applicationIds': applicationIds,
    };
  }
  
  AppUser copyWith({
    String? email,
    String? name,
    String? photoUrl,
    String? phoneNumber,
    String? department,
    String? yearOfStudy,
    String? studentId,
    UserRole? role,
    MembershipStatus? membershipStatus,
    List<String>? permissions,
    DateTime? lastLoginAt,
    Map<String, dynamic>? preferences,
    bool? isEmailVerified,
    bool? isProfileComplete,
    int? engagementScore,
    List<String>? registeredEventIds,
    List<String>? attendedEventIds,
    List<String>? applicationIds,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      preferences: preferences ?? this.preferences,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      engagementScore: engagementScore ?? this.engagementScore,
      registeredEventIds: registeredEventIds ?? this.registeredEventIds,
      attendedEventIds: attendedEventIds ?? this.attendedEventIds,
      applicationIds: applicationIds ?? this.applicationIds,
    );
  }
  
  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }
  
  bool get isAdmin => role == UserRole.admin;
  bool get isOrganizer => role == UserRole.organizer || role == UserRole.admin;
  bool get isActiveStudent => membershipStatus == MembershipStatus.active;
}
