import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  shortlisted,
  interviewed,
  accepted,
  rejected,
  withdrawn,
}

enum RoleType {
  technical,
  creative,
  marketing,
  operations,
  leadership,
  general,
}

class RecruitmentRole {
  final String id;
  final String title;
  final String description;
  final RoleType type;
  final String department;
  final List<String> responsibilities;
  final List<String> requirements;
  final List<String> eligibilityCriteria;
  final int vacancies;
  final int currentApplications;
  final bool isActive;
  final DateTime openingDate;
  final DateTime closingDate;
  final String? applicationFormUrl;
  final String? applicationFormId;
  final bool requiresInterview;
  final List<String> recruitmentStages;
  final String createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final Map<String, dynamic>? additionalInfo;
  
  RecruitmentRole({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.department,
    this.responsibilities = const [],
    this.requirements = const [],
    this.eligibilityCriteria = const [],
    this.vacancies = 1,
    this.currentApplications = 0,
    this.isActive = true,
    required this.openingDate,
    required this.closingDate,
    this.applicationFormUrl,
    this.applicationFormId,
    this.requiresInterview = false,
    this.recruitmentStages = const ['Application', 'Review', 'Interview', 'Decision'],
    required this.createdBy,
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
    this.additionalInfo,
  });
  
  factory RecruitmentRole.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecruitmentRole(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: RoleType.values.firstWhere(
        (e) => e.toString() == 'RoleType.${data['type']}',
        orElse: () => RoleType.general,
      ),
      department: data['department'] ?? '',
      responsibilities: List<String>.from(data['responsibilities'] ?? []),
      requirements: List<String>.from(data['requirements'] ?? []),
      eligibilityCriteria: List<String>.from(data['eligibilityCriteria'] ?? []),
      vacancies: data['vacancies'] ?? 1,
      currentApplications: data['currentApplications'] ?? 0,
      isActive: data['isActive'] ?? true,
      openingDate: (data['openingDate'] as Timestamp).toDate(),
      closingDate: (data['closingDate'] as Timestamp).toDate(),
      applicationFormUrl: data['applicationFormUrl'],
      applicationFormId: data['applicationFormId'],
      requiresInterview: data['requiresInterview'] ?? false,
      recruitmentStages: List<String>.from(
        data['recruitmentStages'] ?? ['Application', 'Review', 'Interview', 'Decision'],
      ),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
      tags: List<String>.from(data['tags'] ?? []),
      additionalInfo: data['additionalInfo'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'department': department,
      'responsibilities': responsibilities,
      'requirements': requirements,
      'eligibilityCriteria': eligibilityCriteria,
      'vacancies': vacancies,
      'currentApplications': currentApplications,
      'isActive': isActive,
      'openingDate': Timestamp.fromDate(openingDate),
      'closingDate': Timestamp.fromDate(closingDate),
      'applicationFormUrl': applicationFormUrl,
      'applicationFormId': applicationFormId,
      'requiresInterview': requiresInterview,
      'recruitmentStages': recruitmentStages,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'tags': tags,
      'additionalInfo': additionalInfo,
    };
  }
  
  bool get isOpen => DateTime.now().isAfter(openingDate) && 
      DateTime.now().isBefore(closingDate) && isActive;
  bool get isClosed => DateTime.now().isAfter(closingDate) || !isActive;
  bool get hasFreeSlots => currentApplications < vacancies;
}

class Application {
  final String id;
  final String roleId;
  final String userId;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final Map<String, dynamic>? formResponses;
  final String? resumeUrl;
  final String? coverLetter;
  final List<String> attachments;
  final String? currentStage;
  final Map<String, dynamic>? reviewNotes;
  final List<ApplicationReview> reviews;
  final DateTime? interviewDate;
  final String? interviewLocation;
  final String? interviewLink;
  final double? score;
  final String? rejectionReason;
  final DateTime? statusUpdatedAt;
  final String? updatedBy;
  
  Application({
    required this.id,
    required this.roleId,
    required this.userId,
    this.status = ApplicationStatus.submitted,
    required this.submittedAt,
    this.formResponses,
    this.resumeUrl,
    this.coverLetter,
    this.attachments = const [],
    this.currentStage,
    this.reviewNotes,
    this.reviews = const [],
    this.interviewDate,
    this.interviewLocation,
    this.interviewLink,
    this.score,
    this.rejectionReason,
    this.statusUpdatedAt,
    this.updatedBy,
  });
  
  factory Application.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Application(
      id: doc.id,
      roleId: data['roleId'] ?? '',
      userId: data['userId'] ?? '',
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == 'ApplicationStatus.${data['status']}',
        orElse: () => ApplicationStatus.submitted,
      ),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      formResponses: data['formResponses'],
      resumeUrl: data['resumeUrl'],
      coverLetter: data['coverLetter'],
      attachments: List<String>.from(data['attachments'] ?? []),
      currentStage: data['currentStage'],
      reviewNotes: data['reviewNotes'],
      reviews: (data['reviews'] as List<dynamic>?)
          ?.map((review) => ApplicationReview.fromMap(review))
          .toList() ?? [],
      interviewDate: data['interviewDate'] != null 
          ? (data['interviewDate'] as Timestamp).toDate() 
          : null,
      interviewLocation: data['interviewLocation'],
      interviewLink: data['interviewLink'],
      score: data['score']?.toDouble(),
      rejectionReason: data['rejectionReason'],
      statusUpdatedAt: data['statusUpdatedAt'] != null 
          ? (data['statusUpdatedAt'] as Timestamp).toDate() 
          : null,
      updatedBy: data['updatedBy'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'roleId': roleId,
      'userId': userId,
      'status': status.toString().split('.').last,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'formResponses': formResponses,
      'resumeUrl': resumeUrl,
      'coverLetter': coverLetter,
      'attachments': attachments,
      'currentStage': currentStage,
      'reviewNotes': reviewNotes,
      'reviews': reviews.map((r) => r.toMap()).toList(),
      'interviewDate': interviewDate != null 
          ? Timestamp.fromDate(interviewDate!) 
          : null,
      'interviewLocation': interviewLocation,
      'interviewLink': interviewLink,
      'score': score,
      'rejectionReason': rejectionReason,
      'statusUpdatedAt': statusUpdatedAt != null 
          ? Timestamp.fromDate(statusUpdatedAt!) 
          : null,
      'updatedBy': updatedBy,
    };
  }
}

class ApplicationReview {
  final String reviewerId;
  final String reviewerName;
  final DateTime reviewedAt;
  final double score;
  final String? comments;
  final Map<String, dynamic>? criteria;
  
  ApplicationReview({
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewedAt,
    required this.score,
    this.comments,
    this.criteria,
  });
  
  factory ApplicationReview.fromMap(Map<String, dynamic> data) {
    return ApplicationReview(
      reviewerId: data['reviewerId'] ?? '',
      reviewerName: data['reviewerName'] ?? '',
      reviewedAt: (data['reviewedAt'] as Timestamp).toDate(),
      score: data['score']?.toDouble() ?? 0,
      comments: data['comments'],
      criteria: data['criteria'],
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewedAt': Timestamp.fromDate(reviewedAt),
      'score': score,
      'comments': comments,
      'criteria': criteria,
    };
  }
}
