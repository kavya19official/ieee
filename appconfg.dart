class AppConfig {
  // App Information
  static const String appName = 'University Society';
  static const String appVersion = '1.0.0';
  
  // Firebase Configuration
  static const String firebaseAndroidApiKey = 'YOUR_ANDROID_API_KEY';
  static const String firebaseIosApiKey = 'YOUR_IOS_API_KEY';
  static const String firebaseProjectId = 'YOUR_PROJECT_ID';
  static const String firebaseMessagingSenderId = 'YOUR_SENDER_ID';
  static const String firebaseAppId = 'YOUR_APP_ID';
  
  // Google Sign-In
  static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
  
  // University Domain Restriction
  static const String allowedEmailDomain = 'university.edu';
  static const bool enforceEmailDomainRestriction = true;
  
  // Feature Flags
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // API Configuration
  static const String baseApiUrl = 'https://api.yourplatform.com';
  static const int apiTimeout = 30000; // milliseconds
  
  // Storage
  static const int maxImageSizeMB = 5;
  static const int maxVideoSizeMB = 50;
  
  // Pagination
  static const int eventsPerPage = 20;
  static const int applicationsPerPage = 15;
  
  // Cache Duration
  static const Duration cacheValidDuration = Duration(hours: 24);
  
  // QR Code
  static const int qrScanTimeout = 10; // seconds
  static const bool allowDuplicateScans = false;
  
  // Theme
  static const bool isDarkModeDefault = false;
  
  // Content Moderation
  static const bool requireAdminApproval = true;
  static const List<String> bannedWords = []; // Add as needed
  
  // Rate Limiting
  static const int maxRegistrationsPerDay = 10;
  static const int maxApplicationsPerWeek = 5;
}
