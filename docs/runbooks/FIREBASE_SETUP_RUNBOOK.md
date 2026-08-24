# SubGuard — Firebase Setup & Deployment Runbook

**Purpose:** Complete, step-by-step operational runbook to configure Firebase Authentication, Cloud Firestore, and FCM for SubGuard.  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 1. Firebase Project Creation

1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add Project** and name it `subguard-app` (or your chosen project ID).
3. (Optional) Enable Google Analytics and Crashlytics.
4. Click **Create Project**.

---

## 2. Service Activation in Firebase Console

### 2.1 Firebase Authentication
1. In the left sidebar, go to **Build** -> **Authentication**.
2. Click **Get Started**.
3. In the **Sign-in method** tab, enable:
   - ✅ **Email/Password**
   - ✅ **Google** (provide your project support email)
   - ✅ **Apple** (for iOS support)

### 2.2 Cloud Firestore Database
1. Go to **Build** -> **Firestore Database**.
2. Click **Create Database**.
3. Select **Start in production mode**.
4. Choose your server location (e.g., `nam5 (us-central)` or your closest region).
5. Click **Enable**.

---

## 3. Automated Configuration via FlutterFire CLI

Run the following commands in your terminal at the root of the project:

```bash
# 1. Install FlutterFire CLI globally if not already installed
dart pub global activate flutterfire_cli

# 2. Login to your Firebase account
firebase login

# 3. Configure SubGuard for Android, iOS, and Web
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This automated command will:
- Register the Android app (`com.subguard.app`), iOS app, and Web app in your Firebase project.
- Automatically generate a valid `lib/firebase_options.dart` with your API keys.
- Place `google-services.json` inside `android/app/`.
- Place `GoogleService-Info.plist` inside `ios/Runner/`.

---

## 4. Deploy Firestore Security Rules

1. In Firebase Console, go to **Firestore Database** -> **Rules**.
2. Paste the following production rules and click **Publish**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    match /users/{userId} {
      allow read, write: if isOwner(userId);

      match /subscriptions/{subscriptionId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## 5. Deploy Firestore Composite Indexes

Create the following composite indexes in **Firestore Database** -> **Indexes**:

1. **Subscriptions by Next Billing Date:**
   - Collection: `users/{userId}/subscriptions`
   - Fields: `status` (Ascending), `nextBillingDate` (Ascending)
2. **Subscriptions by Sync Time:**
   - Collection: `users/{userId}/subscriptions`
   - Fields: `updatedAt` (Descending), `isDeleted` (Ascending)

*(Note: You can also generate indexes automatically by running queries in debug mode and clicking the auto-generated index creation link in the terminal).*

---

## 6. App Verification Checklist

1. Run `flutter run` on an Android device or emulator.
2. Check debug logs for:
   ```
   [firebase_core] Initialized successfully
   [cloud_firestore] Connected to Firestore
   ```
3. Test creating a new user account via Email or Google Sign-In.
4. Verify the new user appears under **Firebase Console -> Authentication -> Users**.
5. Add a test subscription and confirm it syncs to **Firestore -> `users/{userId}/subscriptions`**.
