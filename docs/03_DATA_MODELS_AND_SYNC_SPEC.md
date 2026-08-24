# SubGuard — Data Models & Synchronization Specification

**Local Database Engine:** Isar Database (NoSQL)  
**Cloud Database Engine:** Cloud Firestore (Document Database)  
**Sync Philosophy:** Hybrid Local-First with Last-Write-Wins (LWW) Conflict Resolution  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 1. Local Database Schema (Isar Collections)

All local schemas are defined using Isar annotations and generated via `build_runner`.

### 1.1 `SubscriptionModel`
```dart
@collection
class SubscriptionModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String subscriptionId;      // UUID v4

  @Index()
  late String userId;              // Firebase Auth UID or 'local_user'

  @Index(type: IndexType.value, caseSensitive: false)
  late String serviceName;

  String? logoUrl;
  late double amount;
  late String currency;            // e.g. 'USD', 'EUR'

  @Enumerated(EnumType.name)
  late BillingCycle billingCycle;  // daily, weekly, monthly, quarterly, yearly

  @Index()
  late DateTime nextBillingDate;
  DateTime? trialEndDate;

  @Enumerated(EnumType.name)
  late SubscriptionStatus status;  // active, trial, paused, cancelled, expired

  String? category;
  String? cancellationUrl;
  String? notes;
  String? paymentMethodLabel;

  late DateTime createdAt;
  late DateTime updatedAt;

  // Sync Metadata
  String? firebaseId;
  DateTime? lastSyncedAt;
  bool needsSync = true;
  bool isDeleted = false;
  DateTime? deletedAt;
}
```

### 1.2 `UserModel`
```dart
@collection
class UserModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uid;

  @Index()
  late String email;
  String? displayName;
  String? photoUrl;
  bool isEmailVerified = false;
  bool isPremium = false;

  @Enumerated(EnumType.name)
  late AuthProvider provider;      // email, google, apple

  DateTime? createdAt;
  DateTime? lastLoginAt;
}
```

### 1.3 `NotificationModel` & `NotificationSettingsModel`
```dart
@collection
class NotificationModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String notificationId;

  @Index()
  late String subscriptionId;

  @Enumerated(EnumType.name)
  late NotificationType type;      // renewalReminder, trialEnding, paymentConfirmation

  late String title;
  late String body;
  String? payload;

  late DateTime scheduledAt;
  DateTime? deliveredAt;
  bool isCancelled = false;
  DateTime? createdAt;
}

@collection
class NotificationSettingsModel {
  Id id = Isar.autoIncrement;

  bool enabled = true;
  List<int> defaultReminderDays = [1, 7]; // Days before renewal (e.g. 7 days, 1 day)
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool badgeEnabled = true;
  DateTime? updatedAt;
}
```

---

## 2. Cloud Firestore Document Hierarchy

To guarantee privacy, zero data leakage, and straightforward security rules, data is organized under isolated user namespaces:

```
users/
  └── {userId}/
        ├── profile (Document)
        │     ├── email: String
        │     ├── displayName: String
        │     ├── isPremium: Boolean
        │     ├── createdAt: Timestamp
        │     └── lastSyncedAt: Timestamp
        │
        └── subscriptions (Subcollection)
              └── {subscriptionId}/ (Document)
                    ├── serviceName: String
                    ├── amount: Number
                    ├── currency: String
                    ├── billingCycle: String
                    ├── nextBillingDate: Timestamp
                    ├── trialEndDate: Timestamp (nullable)
                    ├── status: String
                    ├── category: String
                    ├── cancellationUrl: String
                    ├── notes: String
                    ├── createdAt: Timestamp
                    ├── updatedAt: Timestamp
                    ├── isDeleted: Boolean
                    └── deletedAt: Timestamp (nullable)
```

---

## 3. Hybrid Local-First Sync Architecture

```
  ┌────────────────────────────────────────────────────────────────────────┐
  │                            USER INTERFACE                              │
  └────────────────────────────────────────────────────────────────────────┘
          │                                                  ▲
     (1) Write                                          (4) Read
   Instant Update                                     Instant Fetch
          ▼                                                  │
  ┌─────────────────┐                                ┌─────────────────┐
  │     LOCAL       │                                │      LOCAL      │
  │     ISAR DB     │                                │     ISAR DB     │
  └─────────────────┘                                └─────────────────┘
          │                                                  ▲
     (2) Queue                                          (3) Merge
   [needsSync=true]                                  (Last-Write-Wins)
          ▼                                                  │
  ┌─────────────────┐                                ┌─────────────────┐
  │   SyncService   │ ────────── (Background) ─────► │ Cloud Firestore │
  │   Background    │ ◄───────── (Realtime) ──────── │   Remote DB     │
  └─────────────────┘                                └─────────────────┘
```

### 3.1 Write Operation Flow
1. **Instant Local Persistence:** User creates/updates/deletes a subscription. Data writes directly to `Isar` with `needsSync = true` and `updatedAt = DateTime.now().toUtc()`. The UI updates with **zero latency**.
2. **Background Sync Trigger:** `SyncService` detects pending records and uploads dirty documents to Firestore in a batched transaction.
3. **Acknowledgment:** Upon Firestore write success, `lastSyncedAt` is updated and `needsSync` is set to `false`.

### 3.2 Read Operation Flow (Cache-First)
1. **Instant UI Load:** The application always queries local `Isar` storage first (`getAllSubscriptions()`).
2. **Background Refresh:** If an authenticated user is online, Firestore real-time streams or incremental queries (`watchSubscriptions()`) fetch remote changes created on other devices.
3. **Timestamp Comparison & Merge:** If remote `updatedAt > local.updatedAt`, local Isar is silently updated and the UI streams new state.

### 3.3 Conflict Resolution Rules (Last-Write-Wins)
* All conflict evaluations occur at the document level using UTC timestamps (`updatedAt`).
* If `local.updatedAt > remote.updatedAt` -> Local overwrites remote.
* If `remote.updatedAt > local.updatedAt` -> Remote overwrites local.
* In the case of exact timestamp collision, the remote state takes precedence.
* **Soft Deletes:** Deletions are written as `{ isDeleted: true, deletedAt: Timestamp }` so that offline devices receiving the update can clean up their local database without missing delete events.

---

## 4. Firestore Security Rules

To ensure strict GDPR compliance and total user data isolation, deploy the following security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Auth validation helper
    function isAuthenticated() {
      return request.auth != null;
    }

    // Ownership validation helper
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Root user document
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Subscriptions subcollection
      match /subscriptions/{subscriptionId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```
