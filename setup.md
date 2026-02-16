# Setup Guide - University Society Platform

This guide will walk you through setting up the Flutter project from scratch on your development machine.

## Prerequisites Checklist

- [ ] Flutter SDK 3.0+ installed
- [ ] Android Studio or VS Code installed
- [ ] Xcode installed (for iOS development, Mac only)
- [ ] Git installed
- [ ] Firebase account created
- [ ] University Google Workspace access

## Step-by-Step Setup

### 1. Install Flutter

**macOS/Linux:**
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
```

**Windows:**
1. Download Flutter SDK from https://flutter.dev
2. Extract to C:\src\flutter
3. Add to PATH: C:\src\flutter\bin
4. Run `flutter doctor`

### 2. Install IDE and Extensions

**VS Code:**
```bash
# Install extensions
code --install-extension Dart-Code.dart-code
code --install-extension Dart-Code.flutter
```

**Android Studio:**
1. Download from https://developer.android.com/studio
2. Install Flutter and Dart plugins
3. Configure Android SDK

### 3. Project Setup

**Copy Project Files:**
```bash
# Navigate to your workspace
cd ~/Documents/workspace

# Copy the society_platform folder here
# All files should maintain the same structure
```

**Install Dependencies:**
```bash
cd society_platform
flutter pub get
```

### 4. Firebase Setup

#### 4.1 Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Enter project name: "University Society"
4. Disable Google Analytics (or enable if needed)
5. Click "Create project"

#### 4.2 Enable Firebase Services

**Authentication:**
1. Navigate to Authentication → Sign-in method
2. Enable "Google" provider
3. Add your university email domain to authorized domains

**Firestore Database:**
1. Navigate to Firestore Database
2. Click "Create database"
3. Start in "Production mode"
4. Select location (closest to users)

**Cloud Storage:**
1. Navigate to Storage
2. Click "Get started"
3. Accept default security rules

**Cloud Messaging:**
1. Navigate to Cloud Messaging
2. Note the Server Key for later

#### 4.3 Add Android App

1. Click "Add app" → Android icon
2. Package name: `com.university.society.society_platform`
3. Download `google-services.json`
4. Place in `android/app/`

**Update android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**Update android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

#### 4.4 Add iOS App (macOS only)

1. Click "Add app" → iOS icon
2. Bundle ID: `com.university.society.societyPlatform`
3. Download `GoogleService-Info.plist`
4. Open Xcode: `open ios/Runner.xcworkspace`
5. Drag `GoogleService-Info.plist` into Runner folder

**Update ios/Podfile:**
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

Run: `cd ios && pod install`

#### 4.5 Get OAuth Client ID

1. Go to Google Cloud Console
2. Navigate to APIs & Services → Credentials
3. Create OAuth 2.0 Client ID
   - Type: Web application
   - Authorized domains: your-university.edu
4. Copy the Client ID
5. Update `lib/config/app_config.dart`:
   ```dart
   static const String googleWebClientId = 'YOUR_CLIENT_ID_HERE.apps.googleusercontent.com';
   ```

### 5. Configure Application

**Update lib/config/app_config.dart:**

```dart
class AppConfig {
  // Update these values
  static const String allowedEmailDomain = 'youruniversity.edu';
  static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID';
  
  // Customize as needed
  static const String appName = 'Your Society Name';
  static const bool enforceEmailDomainRestriction = true;
}
```

### 6. Set Up Firestore Security Rules

In Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth.uid == userId;
    }
    
    function isOrganizer() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['organizer', 'admin'];
    }
    
    function isAdmin() {
      return isAuthenticated() && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId) || isAdmin();
    }
    
    match /events/{eventId} {
      allow read: if isAuthenticated();
      allow create, update: if isOrganizer();
      allow delete: if isAdmin();
    }
    
    match /registrations/{regId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update, delete: if isOwner(resource.data.userId) || isOrganizer();
    }
    
    match /notifications/{notifId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isOrganizer();
    }
    
    match /applications/{appId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated();
      allow update: if isOrganizer();
    }
    
    match /recruitment_roles/{roleId} {
      allow read: if isAuthenticated();
      allow write: if isOrganizer();
    }
  }
}
```

Click "Publish"

### 7. Add App Icons (Optional)

**Generate Icons:**
```bash
# Create icon image at assets/icons/app_icon.png (1024x1024)
flutter pub run flutter_launcher_icons
```

**Or manually:**
- Android: Replace files in `android/app/src/main/res/mipmap-*/`
- iOS: Replace files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 8. Run the Application

**Check device connection:**
```bash
flutter devices
```

**Run on connected device:**
```bash
flutter run
```

**Run in debug mode:**
```bash
flutter run --debug
```

**Run in release mode:**
```bash
flutter run --release
```

### 9. Test Core Features

**Test Checklist:**
- [ ] App launches successfully
- [ ] Login screen appears
- [ ] Google Sign-In works
- [ ] Email domain restriction works
- [ ] Home screen loads
- [ ] Events tab shows (empty state OK)
- [ ] Profile shows user info
- [ ] Sign out works

### 10. Common Issues & Solutions

**Issue: Google Sign-In fails**
```
Solution:
1. Verify google-services.json is in android/app/
2. Check SHA-1 fingerprint in Firebase Console
3. Ensure OAuth client ID is correct
4. Clear app data and try again
```

**Issue: Build fails with dependency errors**
```bash
# Solution:
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ios && pod deintegrate && pod install
flutter run
```

**Issue: iOS build fails**
```bash
# Solution:
cd ios
pod repo update
pod install
cd ..
flutter run
```

**Issue: Firebase not connecting**
```
Solution:
1. Verify config files are in correct locations
2. Check Firebase project settings
3. Ensure internet connectivity
4. Review Firebase Console for errors
```

**Issue: Email domain restriction not working**
```dart
// Check app_config.dart
static const String allowedEmailDomain = 'university.edu'; // No @ symbol
static const bool enforceEmailDomainRestriction = true;
```

### 11. Development Workflow

**Hot Reload:**
- Press `r` in terminal while app is running
- Changes appear instantly (UI changes only)

**Hot Restart:**
- Press `R` in terminal
- Full restart (for logic changes)

**VS Code:**
- Save file to trigger hot reload
- Use debug panel for breakpoints

**Android Studio:**
- Click lightning bolt for hot reload
- Click restart for hot restart

### 12. Building for Production

**Android APK:**
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

**Android App Bundle (for Play Store):**
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

**iOS (macOS only):**
```bash
flutter build ios --release
# Then open in Xcode to archive and submit
```

### 13. Adding Test Users

**Firebase Console:**
1. Authentication → Users
2. Add user manually
3. Or sign in via app first time

**Set as Organizer/Admin:**
1. Firestore Database → users collection
2. Find user document
3. Edit `role` field to "organizer" or "admin"

### 14. Next Steps

- [ ] Customize branding (colors, logos, name)
- [ ] Add real event data
- [ ] Set up Cloud Functions (for advanced features)
- [ ] Configure push notifications
- [ ] Add analytics tracking
- [ ] Set up CI/CD pipeline
- [ ] Plan app store submission

### 15. Resources

- **Flutter Documentation**: https://docs.flutter.dev
- **Firebase Documentation**: https://firebase.google.com/docs
- **Material Design**: https://m3.material.io
- **Stack Overflow**: https://stackoverflow.com/questions/tagged/flutter

### 16. Getting Help

**Error Messages:**
1. Read the full error message
2. Check Flutter doctor: `flutter doctor -v`
3. Search error on Stack Overflow
4. Check GitHub issues

**Firebase Issues:**
1. Check Firebase Console logs
2. Verify configuration files
3. Review security rules
4. Check quota limits

**Performance Issues:**
1. Run in release mode
2. Use Flutter DevTools
3. Check network requests
4. Optimize images

---

## Quick Start Checklist

For experienced developers, here's the quick checklist:

```bash
# 1. Install dependencies
flutter pub get

# 2. Add Firebase config files
# - android/app/google-services.json
# - ios/Runner/GoogleService-Info.plist

# 3. Update app config
# - Edit lib/config/app_config.dart

# 4. Run app
flutter run

# 5. Set up Firebase
# - Enable Auth, Firestore, Storage, Messaging
# - Deploy security rules

# 6. Test
# - Sign in
# - Verify data flow
# - Test permissions
```

That's it! You're ready to develop.
