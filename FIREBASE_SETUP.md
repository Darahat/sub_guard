# Firebase Setup Guide for SubGuard

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: **SubGuard**
4. Disable Google Analytics (or enable if you want)
5. Click "Create project"

## Step 2: Enable Authentication Methods

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Go to **Sign-in method** tab
4. Enable the following:
   - ✅ **Email/Password** - Enable
   - ✅ **Google** - Enable (add your support email)
   - ✅ **Apple** - Enable (iOS only, configure later)

## Step 3: Add Android App

1. In Project Overview, click **Android icon**
2. Enter package name: `com.subguard.app` (or your chosen package)
3. Download `google-services.json`
4. Place it in: `android/app/google-services.json`
5. Follow the setup instructions in Firebase Console

## Step 4: Add iOS App

1. In Project Overview, click **iOS icon**
2. Enter bundle ID: `com.subguard.app` (same as Android)
3. Download `GoogleService-Info.plist`
4. Place it in: `ios/Runner/GoogleService-Info.plist`
5. Follow the setup instructions

## Step 5: Configure FlutterFire CLI

Run these commands in your project root:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your Flutter project
flutterfire configure
```

This will:

- Generate `lib/firebase_options.dart`
- Auto-configure Android and iOS apps
- Set up necessary configurations

## Step 6: Update Android build.gradle

**android/build.gradle.kts** - Add classpath:

```kotlin
dependencies {
    classpath("com.android.tools.build:gradle:8.1.0")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    classpath("com.google.gms:google-services:4.4.0") // Add this
}
```

**android/app/build.gradle.kts** - Add plugin at the bottom:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// ... rest of file ...

// Add this at the very end
apply(plugin = "com.google.gms.google-services")
```

## Step 7: Update iOS Configuration

No additional configuration needed if you placed `GoogleService-Info.plist` correctly.

## Step 8: Verify Setup

After running `flutterfire configure`, uncomment these lines in `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// In main() function:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Step 9: Test Firebase Connection

Run the app and check logs for:

```
✅ Firebase initialized successfully
```

## ⚠️ Important Notes

- Keep `google-services.json` and `GoogleService-Info.plist` secure
- Don't commit them to public repositories
- For production, use environment-specific configurations

## Next Steps After Firebase Setup

Once Firebase is configured, we'll implement:

1. ✅ User authentication (email/password)
2. ✅ Google Sign-In
3. ✅ Apple Sign-In (iOS)
4. ✅ Password reset
5. ✅ Email verification
