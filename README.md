# ieee
# University Society Platform - Production-Ready Flutter App

A comprehensive mobile platform for managing university student professional societies, built with Flutter for both iOS and Android.

## 🎯 Overview

This is a production-grade mobile application designed as institutional infrastructure for university student societies. It provides:

- **Student Experience**: Event discovery, registration, role applications, and personal dashboard
- **Organizer Tools**: Event management, QR attendance tracking, analytics
- **Admin Control**: Content governance, user management, system analytics

## 🏗️ Architecture

### Tech Stack

**Frontend**
- Flutter 3.0+
- Material Design 3
- Provider for state management
- Firebase integration

**Backend Services**
- Firebase Authentication (Google Sign-In)
- Cloud Firestore (Database)
- Firebase Cloud Messaging (Notifications)
- Firebase Storage (Media files)
- Firebase Analytics

### Project Structure

```
lib/
├── config/
│   ├── app_config.dart          # App configuration & feature flags
│   └── app_theme.dart            # Theme, colors, typography
├── models/
│   ├── user_model.dart           # User data model with roles
│   ├── event_model.dart          # Event & registration models
│   ├── recruitment_model.dart    # Recruitment roles & applications
│   └── notification_model.dart   # Notification models
├── services/
│   ├── auth_service.dart         # Authentication logic
│   ├── event_service.dart        # Event CRUD & operations
│   └── notification_service.dart # Push notifications
├── screens/
│   ├── auth/
│   │   └── login_screen.dart     # Google sign-in
│   ├── home/
│   │   └── home_screen.dart      # Main navigation
│   ├── events/
│   │   ├── events_screen.dart    # Event listing
│   │   └── event_detail_screen.dart
│   ├── recruitment/
│   │   └── recruitment_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── admin/
│       └── admin_screen.dart
├── widgets/
│   ├── event_card.dart           # Reusable event card
│   └── event_filter_chips.dart   # Category filters
└── main.dart                      # App entry point
```

## 🚀 Getting Started

### Prerequisites

1. **Flutter SDK** (3.0 or higher)
   ```bash
   flutter --version
   ```

2. **Firebase Project**
   - Create a project at [Firebase Console](https://console.firebase.google.com)
   - Enable Authentication (Google provider)
   - Enable Cloud Firestore
   - Enable Cloud Messaging
   - Enable Cloud Storage

3. **Development Tools**
   - Android Studio / Xcode
   - VS Code with Flutter extension

### Installation

1. **Clone the repository**
   ```bash
   cd path/to/your/workspace
   # Copy the society_platform folder here
   ```

2. **Install dependencies**
   ```bash
   cd society_platform
   flutter pub get
   ```

3. **Firebase Configuration**

   **For Android:**
   - Download `google-services.json` from Firebase Console
   - Place it in `android/app/`

   **For iOS:**
   - Download `GoogleService-Info.plist` from Firebase Console
   - Place it in `ios/Runner/`

4. **Update Configuration**
   
   Edit `lib/config/app_config.dart`:
   ```dart
   static const String allowedEmailDomain = 'youruniversity.edu';
   static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Features

### MVP Features (Implemented)

✅ **Authentication**
- Google Sign-In
- Email domain restriction
- Role-based access control

✅ **Event Management**
- Event listing (Upcoming, Featured, Past)
- Event details with registration
- Category filtering
- Event creation (Organizers)

✅ **User Dashboard**
- Profile management
- Registration history
- Attendance tracking

✅ **Admin Dashboard**
- Quick access to management tools

### Phase 2 Features (To Implement)

🔲 **QR Attendance System**
- QR code generation per event
- Mobile QR scanner
- Offline scan handling
- Duplicate prevention

🔲 **Recruitment Management**
- Role listings
- Application submission
- Review workflow
- Interview scheduling

🔲 **Push Notifications**
- Event reminders
- Registration confirmations
- Application updates
- General announcements

🔲 **Analytics Dashboard**
- Event metrics
- Attendance tracking
- Engagement analytics
- Export reports

### Phase 3 Features (Future)

🔲 **Advanced Features**
- Smart event recommendations
- Community discussions
- Volunteer tracking
- Gamification & badges
- Email automation
- Sponsor management

## 🗄️ Database Schema

### Collections

**users**
```
{
  id: string
  email: string
  name: string
  photoUrl: string
  role: enum (student, organizer, admin)
  membershipStatus: enum
  registeredEventIds: string[]
  attendedEventIds: string[]
  applicationIds: string[]
  engagementScore: number
  createdAt: timestamp
}
```

**events**
```
{
  id: string
  title: string
  description: string
  imageUrl: string
  category: enum
  status: enum
  startTime: timestamp
  endTime: timestamp
  venue: string
  speaker: string
  maxAttendees: number
  currentRegistrations: number
  actualAttendance: number
  qrCodeData: string
  isPublished: boolean
  isFeatured: boolean
  createdBy: string
}
```

**registrations**
```
{
  id: string
  eventId: string
  userId: string
  registeredAt: timestamp
  hasAttended: boolean
  attendedAt: timestamp
  attendanceMethod: string (qr/manual)
  isWaitlisted: boolean
}
```

**notifications**
```
{
  id: string
  userId: string
  type: enum
  priority: enum
  title: string
  body: string
  data: map
  isRead: boolean
  createdAt: timestamp
}
```

## 🔐 Security & Permissions

### Role-Based Access Control

**Student** (Default)
- View events
- Register for events
- Apply for roles
- View own profile

**Organizer**
- All student permissions
- Create/edit events
- View registrations
- Mark attendance
- View analytics

**Admin**
- All organizer permissions
- User management
- Delete events
- System configuration
- Full analytics access

### Data Security

- Firebase Security Rules configured
- Email domain verification
- Rate limiting on registrations
- Input validation and sanitization

## 🎨 Design System

### Color Palette
- **Primary**: #6C63FF (Purple)
- **Secondary**: #00D9FF (Cyan)
- **Accent**: #FF6584 (Pink)
- **Success**: #10B981 (Green)
- **Warning**: #F59E0B (Orange)
- **Error**: #EF4444 (Red)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Large Headings**: 32-28px, Bold
- **Body Text**: 16-14px, Regular
- **Small Text**: 12-11px, Medium

### Components
- High contrast design
- Large touch targets (min 44x44)
- Consistent spacing (4px grid)
- Smooth animations
- Accessibility compliant

## 📊 Analytics & Monitoring

Tracked metrics:
- User engagement
- Event popularity
- Registration conversion
- Attendance rates
- App performance
- Crash reports

## 🚢 Deployment

### Build Release APK (Android)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (Android)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Build iOS App
```bash
flutter build ios --release
# Then open in Xcode to archive
```

## 🔧 Configuration

### Feature Flags (app_config.dart)

```dart
enablePushNotifications: true/false
enableOfflineMode: true/false
enableAnalytics: true/false
enforceEmailDomainRestriction: true/false
requireAdminApproval: true/false
```

### Environment Variables

Create `.env` file for sensitive data:
```
FIREBASE_API_KEY=your_api_key
GOOGLE_SIGN_IN_CLIENT_ID=your_client_id
```

## 📝 Code Standards

- Follow Flutter/Dart style guide
- Use meaningful variable names
- Comment complex logic
- Write widget tests for critical flows
- Keep widgets small and focused
- Use const constructors where possible

## 🐛 Troubleshooting

**Google Sign-In not working**
- Verify SHA-1 fingerprint in Firebase
- Check google-services.json is in place
- Ensure correct OAuth client ID

**Build errors**
```bash
flutter clean
flutter pub get
flutter run
```

**Firebase connection issues**
- Verify Firebase configuration files
- Check internet connectivity
- Review Firebase Console for errors

## 📖 Documentation

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design 3](https://m3.material.io/)

## 🤝 Contributing

1. Create feature branch
2. Make changes
3. Test thoroughly
4. Submit pull request

## 📄 License

Private institutional use only.

## 👥 Support

For issues or questions:
- Create GitHub issue
- Contact development team
- Review documentation

## 🗺️ Roadmap

**Q1 2024**
- ✅ MVP release
- 🔲 QR attendance system
- 🔲 Recruitment module

**Q2 2024**
- 🔲 Analytics dashboard
- 🔲 Email notifications
- 🔲 Advanced filtering

**Q3 2024**
- 🔲 Social features
- 🔲 Gamification
- 🔲 Sponsor integration

---

Built with ❤️ for student success
