# SubGuard — Master Roadmap & Sprint Tracker

**Project Name:** SubGuard  
**Current Phase:** Production Launch Readiness  
**Target Platform:** Android (Play Store) & iOS (App Store)  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 1. Project Implementation Status Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           OVERALL PROJECT PROGRESS: 96%                    │
├────────────────────────────┬─────────────┬──────────────────────────────────┤
│ Module                     │ Status      │ Deliverables                     │
├────────────────────────────┼─────────────┼──────────────────────────────────┤
│ Phase A: Authentication    │ 100% Done   │ Email/Pass, Google, Apple, Isar  │
│ Phase B: Subscriptions     │ 100% Done   │ CRUD, Dashboard, Filters, Cycles │
│ Phase C: Insights          │ 100% Done   │ fl_chart Trends, Pie, Bar Charts │
│ Phase D: Cloud Sync        │ 100% Done   │ Firestore DS, SyncService, Queue │
│ Phase E: Notifications     │ 100% Done   │ Exact Alarms, Channels, UI       │
│ Phase F: Monetization (IAP)│ Planned     │ RevenueCat / Google Play Billing │
└────────────────────────────┴─────────────┴──────────────────────────────────┘
```

---

## 2. Completed Milestones Breakdown

### ✅ Phase A: Authentication & Profile (100% Complete)
* `UserEntity` with Freezed immutability & `AuthProvider` enum.
* 8 Use Cases: SignIn, SignUp, GoogleSignIn, AppleSignIn, SignOut, ResetPassword, EmailVerification, GetCurrentUser.
* `UserModel` Isar caching for fast offline access.
* `FirebaseAuthDataSource` with custom Firebase exception mapping.
* Full UI: `LoginScreen`, `SignupScreen`, `ForgotPasswordScreen`.

### ✅ Phase B: Core Subscription Management (100% Complete)
* `SubscriptionEntity` with computed properties (`monthlyCost`, `yearlyCost`, `daysUntilBilling`, `isExpiringSoon`).
* Full CRUD operations with 14 repository methods.
* `SubscriptionModel` Isar schema with search and status indexing.
* Full UI: `DashboardScreen` with status chips & search, `AddEditSubscriptionScreen`, `SubscriptionDetailScreen`, `SubscriptionCard`, `StatsCard`.

### ✅ Phase C: Insights & Analytics (100% Complete)
* In-memory analytical calculations from local `Isar` DB (zero server latency).
* `SpendingDataPoint`, `CategorySpending`, `SubscriptionStats`, `TopSubscription`.
* Full UI: `InsightsScreen` with 3 tabs (Overview, Trends, Categories) powered by `fl_chart`.

### ⚙️ Phase D: Cloud Sync & Backend (80% Complete)
* `FirebaseConfig` with Firestore persistence and Crashlytics.
* `RemoteSubscriptionDataSource` implementing full Firestore CRUD and real-time streams (`watchSubscriptions()`).
* `SyncService` implementing hybrid local-first sync with timestamp-based conflict resolution.
* `SyncStatus` state model.
* *Remaining:* Configure live Firebase project and link `SubscriptionRepositoryImpl`.

### ✅ Phase E: Notifications & Exact Alarms (100% Complete)
* `NotificationService` supporting exact alarms (`zonedSchedule`) and timezone awareness.
* 3 Android notification channels (`subscription_reminders`, `trial_alerts`, `payment_confirmations`).
* `NotificationEntity`, `NotificationModel`, `NotificationSettingsModel`.
* Full UI: `NotificationSettingsScreen` with reminder day chips (1, 3, 7, 14, 30 days) and test alarm triggers.

---

## 3. Sprint Execution Plan

```
  ┌─────────────────────────────────────────────────────────────────────────┐
  │                         ACTIVE SPRINT SCHEDULE                          │
  ├─────────────────────────────────────────────────────────────────────────┤
  │ SPRINT 1: Backend Linkage & Device Validation (Immediate - 3 Days)      │
  │  ├── 1. Run FlutterFire configure with live Firebase project            │
  │  ├── 2. Hook RemoteSubscriptionDataSource into SubscriptionRepoImpl     │
  │  ├── 3. Deploy Firestore Security Rules & Indexes                       │
  │  └── 4. Validate exact alarms on physical Android 13/14 device          │
  │                                                                         │
  │ SPRINT 2: Data Portability & Monetization (5 Days)                      │
  │  ├── 1. Implement CSV Export & Import Service                           │
  │  ├── 2. Add Biometric Lock (local_auth)                                 │
  │  ├── 3. Integrate RevenueCat / Google Play Billing                      │
  │  └── 4. Build Paywall BottomSheet & 5-subscription limit check          │
  │                                                                         │
  │ SPRINT 3: Store Submission & Release (4 Days)                           │
  │  ├── 1. App signing (Android Keystore / iOS Certificate)                │
  │  ├── 2. Prepare screenshots, icon, and privacy policy URL              │
  │  ├── 3. Deploy to Google Play Internal Testing Track                    │
  │  └── 4. Public MVP Launch                                               │
  └─────────────────────────────────────────────────────────────────────────┘
```

---

## 4. Future Post-MVP Roadmap

### Phase 2: User Experience Polish
* Android Home Screen Widget (upcoming charges list).
* Interactive Siri / Google Assistant shortcuts ("What subscriptions renew this week?").
* Multi-currency exchange rate auto-conversion.

### Phase 3: Advanced Intelligence & Discovery
* Opt-in Gmail / Outlook receipt scanning via Serverless Cloud Function (with full Google Security Verification).
* Price hike anomaly detection.
* Unused subscription flags based on manual check-ins.
