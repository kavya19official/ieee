# System Architecture Documentation

## 1. System Overview

### 1.1 Architecture Pattern
- **Pattern**: Clean Architecture with MVVM
- **State Management**: Provider
- **Navigation**: MaterialApp with Navigator 2.0
- **Dependency Injection**: Provider-based DI

### 1.2 Layer Structure

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (Screens, Widgets, ViewModels)     │
├─────────────────────────────────────┤
│      Business Logic Layer           │
│  (Services, Use Cases, Providers)   │
├─────────────────────────────────────┤
│      Data Layer                     │
│  (Models, Repositories, Firebase)   │
└─────────────────────────────────────┘
```

## 2. Core Components

### 2.1 Authentication Flow

```
User Opens App
    ↓
AuthWrapper (StreamBuilder)
    ↓
Check Firebase Auth State
    ├─ Authenticated → HomeScreen
    └─ Not Authenticated → LoginScreen
            ↓
    Google Sign-In
            ↓
    Verify Email Domain
            ↓
    Create/Update Firestore User
            ↓
    Navigate to HomeScreen
```

### 2.2 Data Flow

```
UI Layer (Screens/Widgets)
    ↓ (Reads)
Provider/ViewModel
    ↓ (Calls)
Service Layer
    ↓ (CRUD)
Firebase Firestore
    ↓ (Real-time updates)
StreamBuilder
    ↓ (Rebuilds)
UI Updates
```

## 3. Module Architecture

### 3.1 Event Module

**Components:**
- EventsScreen (List view)
- EventDetailScreen (Detail view)
- EventCard (Widget)
- EventService (Business logic)
- Event Model (Data structure)

**Flow:**
```
EventsScreen
    ↓ StreamBuilder
EventService.getUpcomingEvents()
    ↓ Firestore Query
Stream<List<Event>>
    ↓ Build
ListView of EventCard
    ↓ OnTap
EventDetailScreen
    ↓ User Action
EventService.registerForEvent()
    ↓ Update
Firestore + Local State
```

### 3.2 Authentication Module

**Components:**
- LoginScreen
- AuthService
- AuthWrapper
- User Model

**Security:**
- Email domain verification
- Firebase Auth rules
- Secure token storage
- Automatic session management

### 3.3 Notification Module

**Components:**
- NotificationService
- Firebase Cloud Messaging
- Local Notifications
- Notification Model

**Triggers:**
- Event reminders (2 hours before)
- Registration confirmations
- Application updates
- Admin announcements

## 4. Database Design

### 4.1 Firestore Collections

**users/**
- Purpose: Store user profiles and preferences
- Indexes: email, role, membershipStatus
- Security: User can read/write own document

**events/**
- Purpose: Store event information
- Indexes: startTime, isPublished, isFeatured, category
- Security: All read, organizers write

**registrations/**
- Purpose: Link users to events
- Indexes: eventId, userId, hasAttended
- Security: User can read own, organizers can write

**notifications/**
- Purpose: Store user notifications
- Indexes: userId, isRead, createdAt
- Security: User can read own notifications

**applications/**
- Purpose: Store role applications
- Indexes: roleId, userId, status
- Security: User can read own, organizers can review

**recruitment_roles/**
- Purpose: Store open positions
- Indexes: isActive, closingDate, department
- Security: All read, organizers write

### 4.2 Data Relationships

```
User (1) ──── (M) EventRegistration
             │
             └──── (M) Applications
             │
             └──── (M) Notifications

Event (1) ──── (M) EventRegistration
         │
         └──── (1) QR Code Data

RecruitmentRole (1) ──── (M) Applications
```

## 5. Feature Implementation

### 5.1 QR Attendance System

**Architecture:**
```
Event Creation
    ↓
Generate Unique QR Data
    format: "event:{eventId}:{scanId}"
    ↓
Store in Event Document
    ↓
Display QR Code Widget
    ↓
Scanner App
    ↓
Verify QR Code
    ↓
Check Duplicate Scan
    ↓
Mark Attendance
    ↓
Update Firestore
    ↓
Send Confirmation
```

**Offline Handling:**
1. Store scan in local queue
2. Display pending status
3. Sync when connection restored
4. Update UI on success

### 5.2 Role-Based Access Control

**Permission Matrix:**

| Feature               | Student | Organizer | Admin |
|-----------------------|---------|-----------|-------|
| View Events           | ✓       | ✓         | ✓     |
| Register for Events   | ✓       | ✓         | ✓     |
| Create Events         | ✗       | ✓         | ✓     |
| Edit Events           | ✗       | ✓         | ✓     |
| Delete Events         | ✗       | ✗         | ✓     |
| View All Registrations| ✗       | ✓         | ✓     |
| Mark Attendance       | ✗       | ✓         | ✓     |
| View Analytics        | ✗       | ✓         | ✓     |
| User Management       | ✗       | ✗         | ✓     |

**Implementation:**
```dart
class PermissionService {
  bool canCreateEvent(AppUser user) {
    return user.role == UserRole.organizer || 
           user.role == UserRole.admin;
  }
  
  bool canDeleteEvent(AppUser user) {
    return user.role == UserRole.admin;
  }
}
```

### 5.3 Analytics System

**Metrics Tracked:**

**Event Metrics:**
- Total registrations
- Actual attendance
- Attendance rate
- Registration timeline
- Category popularity

**User Engagement:**
- Events registered
- Events attended
- Application submissions
- Login frequency
- Session duration

**Implementation:**
```dart
class AnalyticsService {
  Future<Map<String, dynamic>> getEventAnalytics(String eventId) async {
    final event = await getEvent(eventId);
    final registrations = await getRegistrations(eventId);
    
    return {
      'totalRegistrations': event.currentRegistrations,
      'actualAttendance': event.actualAttendance,
      'attendanceRate': event.attendanceRate,
      'waitlistCount': event.waitlistCount,
      'registrationTrend': calculateTrend(registrations),
    };
  }
}
```

## 6. Notification Architecture

### 6.1 Notification Types

**Push Notifications (FCM):**
- Event reminders
- Breaking announcements
- Urgent updates

**In-App Notifications:**
- Registration confirmations
- Application status
- General updates

**Email Notifications (Future):**
- Weekly digests
- Important updates
- Receipts

### 6.2 Delivery Flow

```
Trigger Event
    ↓
NotificationService.sendNotification()
    ↓
┌─────────────┬─────────────┐
│             │             │
FCM           Firestore     Email
(Push)        (In-App)      (Future)
│             │             │
└─────────────┴─────────────┘
    ↓
User Devices
```

## 7. Scalability Considerations

### 7.1 Performance Optimization

**Data Loading:**
- Pagination (20 items per page)
- Lazy loading images
- Query result caching
- Index optimization

**State Management:**
- Minimize rebuilds
- Use const constructors
- Dispose controllers
- Stream optimization

**Image Handling:**
- Cached Network Image
- Compression before upload
- Progressive loading
- Placeholder images

### 7.2 Growth Handling

**Current Capacity:**
- 1000+ users
- 100+ concurrent events
- 10000+ registrations

**Scaling Strategy:**
- Firestore automatic scaling
- CDN for images
- Cloud Functions for heavy tasks
- Database sharding if needed

## 8. Security Architecture

### 8.1 Authentication Security

- OAuth 2.0 via Google
- Secure token storage
- Automatic token refresh
- Session timeout

### 8.2 Data Security

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Events - public read, organizers write
    match /events/{eventId} {
      allow read: if request.auth != null;
      allow create, update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['organizer', 'admin'];
      allow delete: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Registrations
    match /registrations/{regId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.userId ||
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['organizer', 'admin'];
    }
  }
}
```

### 8.3 Input Validation

- Email domain verification
- Form field validation
- File size limits
- Rate limiting

## 9. Testing Strategy

### 9.1 Test Types

**Unit Tests:**
- Service methods
- Model serialization
- Utility functions

**Widget Tests:**
- Screen rendering
- User interactions
- Navigation flows

**Integration Tests:**
- End-to-end flows
- Firebase integration
- Authentication flow

### 9.2 Test Coverage Goals

- Services: 80%+
- Models: 90%+
- Widgets: 70%+
- Critical flows: 100%

## 10. Deployment Pipeline

```
Development
    ↓
Code Review
    ↓
Testing (Unit + Integration)
    ↓
Staging Environment
    ↓
User Acceptance Testing
    ↓
Production Build
    ├─ Android (APK/AAB)
    └─ iOS (IPA)
    ↓
App Store Submission
    ↓
Production Release
    ↓
Monitoring & Feedback
```

## 11. Monitoring & Maintenance

### 11.1 Error Tracking
- Firebase Crashlytics
- Error logging
- User feedback

### 11.2 Performance Monitoring
- Firebase Performance
- App startup time
- Network latency
- Screen rendering

### 11.3 Maintenance Schedule
- Weekly: Review crash reports
- Monthly: Performance review
- Quarterly: Security audit
- Annually: Major updates

---

This architecture is designed to be:
- **Scalable**: Handle growth from 100 to 10,000+ users
- **Maintainable**: Clear separation of concerns
- **Secure**: Multiple layers of security
- **Performant**: Optimized for mobile devices
- **Extensible**: Easy to add new features
