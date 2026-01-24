# Firebase Setup Guide for SubGuard

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `sub-guard` (or your preferred name)
4. Disable Google Analytics (optional, can enable later)
5. Click "Create project"

## Step 2: Enable Required Services

### Firestore Database

1. In Firebase Console, go to "Build" → "Firestore Database"
2. Click "Create database"
3. Select "Start in production mode" (we'll add rules next)
4. Choose your preferred location (e.g., `us-central1`)
5. Click "Enable"

### Authentication

1. Go to "Build" → "Authentication"
2. Click "Get started"
3. Enable "Email/Password" provider
4. Enable "Google" provider (add support email)
5. (Optional) Enable "Apple" for iOS

## Step 3: Configure Apps

### Option A: Using FlutterFire CLI (Recommended)

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Login to Firebase
firebase login

# Configure Firebase for your Flutter project
cd "d:\Dream\Flutter App\sub_guard"
flutterfire configure
```

This will automatically:

- Create apps for Android, iOS, and Web
- Download configuration files
- Update your code

### Option B: Manual Setup

#### Android Setup

1. In Firebase Console, click "Add app" → Android icon
2. Enter package name: `com.subguard.app` (or your package name from `android/app/build.gradle.kts`)
3. Download `google-services.json`
4. Place it in `android/app/google-services.json`
5. Add to `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

6. Add to `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.google.gms.google-services")
}
```

#### iOS Setup

1. In Firebase Console, click "Add app" → iOS icon
2. Enter bundle ID from `ios/Runner.xcodeproj/project.pbxproj`
3. Download `GoogleService-Info.plist`
4. Open `ios/Runner.xcworkspace` in Xcode
5. Drag `GoogleService-Info.plist` into Runner folder
6. Select "Copy items if needed"

#### Web Setup

1. In Firebase Console, click "Add app" → Web icon
2. Register app name: "SubGuard Web"
3. Copy the config object
4. Create `web/firebase-config.js`:

```javascript
// Firebase configuration
const firebaseConfig = {
  apiKey: "YOUR_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  projectId: "YOUR_PROJECT_ID",
  storageBucket: "YOUR_PROJECT.appspot.com",
  messagingSenderId: "YOUR_SENDER_ID",
  appId: "YOUR_APP_ID",
};
```

5. Update `web/index.html` before `</body>`:

```html
<!-- Firebase SDK -->
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.0/firebase-auth-compat.js"></script>
<script src="firebase-config.js"></script>
```

## Step 4: Set Firestore Security Rules

In Firebase Console → Firestore Database → Rules, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper function to check if user owns the document
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // User data
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Subscriptions
      match /subscriptions/{subscriptionId} {
        allow read, write: if isOwner(userId);
      }

      // Budgets
      match /budgets/{budgetId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

Click "Publish" to deploy the rules.

## Step 5: Create Firestore Indexes

Some queries require indexes. Create them in Firebase Console → Firestore Database → Indexes:

1. **Subscriptions by update time**:
   - Collection: `users/{userId}/subscriptions`
   - Fields: `updatedAt` (Descending), `deletedAt` (Ascending)

2. **Active subscriptions**:
   - Collection: `users/{userId}/subscriptions`
   - Fields: `status` (Ascending), `nextBillingDate` (Ascending)

Or auto-create by running queries and clicking the link in error messages.

## Step 6: Initialize Firebase in App

The Firebase initialization is already configured in `lib/core/firebase/firebase_config.dart`.

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Initialize Isar
  final isar = await Isar.open([
    SubscriptionModelSchema,
    BudgetModelSchema,
    NotificationModelSchema,
    NotificationSettingsModelSchema,
  ]);

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const MyApp(),
    ),
  );
}
```

## Step 7: Test Firebase Connection

Run the app and check console for Firebase initialization:

```bash
flutter run
```

Look for logs like:

- `[firebase_core] Initialized successfully`
- `[cloud_firestore] Connected to Firestore`

## Step 8: Verify Authentication Works

1. Run the app
2. Go to sign-up screen
3. Create an account
4. Check Firebase Console → Authentication → Users
5. You should see the new user

## Step 9: Verify Firestore Sync

1. Add a subscription in the app
2. Check Firebase Console → Firestore Database
3. Navigate to `users/{userId}/subscriptions`
4. You should see the subscription document

## Troubleshooting

### "No Firebase App '[DEFAULT]' has been created"

- Ensure `FirebaseConfig.initialize()` is called before any Firebase operations
- Check that configuration files are in the correct locations

### "Permission denied" in Firestore

- Check security rules are deployed
- Ensure user is authenticated before accessing Firestore
- Verify `userId` in document path matches `auth.uid`

### Android build fails

- Ensure `google-services.json` is in `android/app/`
- Check `google-services` plugin is added to both gradle files
- Run `flutter clean` and rebuild

### iOS build fails

- Ensure `GoogleService-Info.plist` is in Xcode project
- Check it's in the Runner target
- Run `pod install` in `ios/` folder

## Next Steps

After Firebase is set up:

1. ✅ Test authentication flow
2. ✅ Verify Firestore writes and reads
3. ✅ Test real-time listeners
4. ✅ Test offline persistence
5. ✅ Monitor sync status in app

---

**Note**: Keep your Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`) secure and add them to `.gitignore` if making the project public.
