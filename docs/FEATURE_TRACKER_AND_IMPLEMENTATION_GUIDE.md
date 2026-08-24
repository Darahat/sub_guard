# 🎯 SubGuard — Feature Tracker & Step-by-Step Implementation Guide

**Project Name:** SubGuard  
**Framework:** Flutter (Clean Architecture + Riverpod + Isar + Firebase)  
**Overall Completion:** 92% (MVP Core Functionality Built)  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 📊 Executive Feature Matrix: Completed vs. Pending

```
========================================================================================
MODULE / FEATURE                        | STATUS        | LAYER COMPLETION
========================================================================================
1. AUTHENTICATION, ONBOARDING & TOUR     | ✅ 100% DONE  | Domain: 100% | Data: 100% | UI: 100%
   - Email/Password Sign Up & Login     | ✅ Complete   | FirebaseAuthDataSource + Isar
   - Google & Apple OAuth Sign In       | ✅ Complete   | google_sign_in + Apple Sign In
   - 4-Slide Value Proposition Carousel | ✅ Complete   | OnboardingScreen + PageView
   - 5-Step Interactive Product Tour    | ✅ Complete   | ProductTourScreen + Interactive Previews
   - First-Time User State Persistence  | ✅ Complete   | OnboardingService + SecureStorage
   - Password Reset & Verification      | ✅ Complete   | UseCases + UI form validation
   - Offline User Profile Caching       | ✅ Complete   | UserModel schema in Isar
----------------------------------------------------------------------------------------
2. SUBSCRIPTION MANAGEMENT              | ✅ 100% DONE  | Domain: 100% | Data: 100% | UI: 100%
   - Full CRUD (Add, Edit, Delete)      | ✅ Complete   | SubscriptionRepositoryImpl
   - Billing Cycles (5 intervals)       | ✅ Complete   | Daily, Weekly, Monthly, Qtr, Yr
   - Trial Expiry Countdown & Badges    | ✅ Complete   | SubscriptionEntity computed props
   - Status & Category Filtering        | ✅ Complete   | LocalSubscriptionDataSource
   - Real-time Search                   | ✅ Complete   | Isar case-insensitive query
   - Dashboard Summary & Stats Cards    | ✅ Complete   | DashboardScreen + StatsCard
----------------------------------------------------------------------------------------
3. INSIGHTS & SPENDING ANALYTICS        | ✅ 100% DONE  | Domain: 100% | Data: 100% | UI: 100%
   - Monthly Spending Trend Chart       | ✅ Complete   | fl_chart Line Chart with gradient
   - Category Breakdown Pie Chart       | ✅ Complete   | fl_chart Pie Chart with legend
   - Top 5 Expensive Subscriptions      | ✅ Complete   | fl_chart Vertical Bar Chart
   - Fast In-Memory Calculations        | ✅ Complete   | InsightRepositoryImpl (Zero Lag)
   - Date Range Filtering (6 ranges)    | ✅ Complete   | InsightNotifier state filter
----------------------------------------------------------------------------------------
4. NOTIFICATIONS & EXACT ALARMS         | ✅ 100% DONE  | Domain: 100% | Data: 100% | UI: 100%
   - Timezone-Aware Exact Alarms        | ✅ Complete   | NotificationService (zonedSchedule)
   - 3 Android Channels                 | ✅ Complete   | Reminders, Trials, Confirmations
   - Subscription Lifecycle Auto-Hook   | ✅ Complete   | SubscriptionNotifier auto-schedules
   - Notification Settings & Toggle UI  | ✅ Complete   | NotificationSettingsScreen
----------------------------------------------------------------------------------------
5. BACKEND & CLOUD SYNC                 | ✅ 100% DONE  | Domain: 100% | Data: 100% | UI: 100%
   - Firebase Config & Crashlytics      | ✅ Complete   | FirebaseConfig.initialize()
   - Cloud Firestore Remote DataSource  | ✅ Complete   | RemoteSubscriptionDataSourceImpl
   - Hybrid Local-First Sync Service    | ✅ Complete   | SyncService (LWW conflict merge)
   - Real Firebase Project Config       | ✅ Complete   | Configured for sub-guard-cb8f5
   - Repository Remote Sync Linkage     | ✅ Complete   | Connected in SubscriptionRepoImpl
   - Dynamic User ID in SyncService     | ✅ Complete   | Uses authenticated UserEntity.id
   - Sync Status Indicator in App Bar   | ✅ Complete   | Real-time Cloud Icon in Dashboard
----------------------------------------------------------------------------------------
6. MONETIZATION (IN-APP PURCHASES)      | 🔲 PENDING    | Target: Sprint 2
   - RevenueCat / Play Billing SDK      | 🔲 PENDING    | purchases_flutter setup
   - 5-Subscription Free Limit Guard    | 🔲 PENDING    | SubscriptionNotifier check
   - Paywall BottomSheet UI             | 🔲 PENDING    | Monthly ($2.99) & Annual ($19.99)
----------------------------------------------------------------------------------------
7. DATA SAFETY & UTILITIES              | ⚙️ 75% DONE   | Data: 100% | Domain: 100% | UI: 100%
   - CSV Export & Import Service        | ✅ Complete   | CsvService + Export/Import UseCases
   - Settings & Backup Screen           | ✅ Complete   | SettingsScreen data controls
   - Biometric App Lock (FaceID/Finger) | ✅ Complete   | local_auth + AppLockGate + Timeout
   - Curated Cancellation URL Database  | 🔲 PENDING    | Top 50 services dataset
   - Post-Billing Confirmation Dialog   | 🔲 PENDING    | "Did charge occur?" check-in
========================================================================================
```

---

## 🛠️ Step-by-Step Implementation Guide for Pending Items

Below is the concrete engineering guide to complete the remaining **8% of MVP and launch preparation**.

---

### Step 1: Link Remote Sync in `SubscriptionRepositoryImpl`

**Goal:** Allow `SubscriptionRepositoryImpl` to write to `Isar` first (instant), and trigger `RemoteSubscriptionDataSource` in the background when an authenticated user is online.

#### Code Implementation Blueprint:
```dart
// Location: lib/features/subscriptions/data/repositories/subscription_repository_impl.dart

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final LocalSubscriptionDataSource localDataSource;
  final RemoteSubscriptionDataSource? remoteDataSource; // Injected
  final Uuid uuid;

  SubscriptionRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, SubscriptionEntity>> addSubscription(
    SubscriptionEntity subscription,
  ) async {
    try {
      final subscriptionWithId = subscription.id.isEmpty
          ? subscription.copyWith(
              id: uuid.v4(),
              createdAt: DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            )
          : subscription.copyWith(
              createdAt: subscription.createdAt ?? DateTime.now().toUtc(),
              updatedAt: DateTime.now().toUtc(),
            );

      final model = SubscriptionModel.fromEntity(subscriptionWithId)
        ..needsSync = true;

      // 1. Instant local write
      final added = await localDataSource.addSubscription(model);

      // 2. Non-blocking background remote sync if remoteDataSource is available
      if (remoteDataSource != null && subscriptionWithId.userId.isNotEmpty) {
        remoteDataSource!
            .createSubscription(subscriptionWithId.userId, added)
            .then((_) => localDataSource.updateSubscription(added..needsSync = false))
            .catchError((_) {}); // Retried later by SyncService
      }

      return Right(added.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
```

---

### Step 2: Connect Authenticated User ID to `SyncService`

**Goal:** Replace hardcoded `'demo-user'` in `SyncService` with the dynamic authenticated Firebase UID.

#### Code Implementation Blueprint:
```dart
// Location: lib/core/sync/sync_service.dart

// Riverpod Provider Hookup
final syncServiceProvider = Provider<SyncService>((ref) {
  final authState = ref.watch(currentUserProvider);
  final isar = ref.watch(isarProvider);
  final firestore = ref.watch(firestoreProvider);

  final syncService = SyncService(
    isar: isar,
    firestore: firestore,
  );

  // Automatically initialize when user logs in, dispose when logged out
  authState.whenData((user) {
    if (user != null) {
      syncService.initialize(userId: user.uid);
    } else {
      syncService.dispose();
    }
  });

  return syncService;
});
```

---

### Step 3: Add Sync Status Badge in Dashboard

**Goal:** Give users visual confidence that their data is safely backed up.

```dart
// Location: lib/features/subscriptions/presentation/screens/dashboard_screen.dart (AppBar action)

Widget _buildSyncStatusIcon(WidgetRef ref) {
  final syncStatus = ref.watch(syncStatusProvider);

  return syncStatus.when(
    data: (status) {
      if (status.isSyncing) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
        );
      }
      if (status.hasError) {
        return const Icon(Icons.cloud_off, color: Colors.orange);
      }
      return const Icon(Icons.cloud_done, color: Colors.green);
    },
    loading: () => const SizedBox.shrink(),
    error: (_, __) => const Icon(Icons.cloud_off, color: Colors.red),
  );
}
```

---

### Step 4: Implement In-App Purchases (Freemium Paywall)

**Goal:** Enforce 5-subscription limit on Free plan and offer monthly ($2.99) & annual ($19.99) Pro subscriptions.

#### Package Dependency:
```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^8.0.0 # RevenueCat SDK for Google Play & Apple StoreKit
```

#### Entitlement Guard Logic:
```dart
// In SubscriptionNotifier
Future<bool> checkCanAddSubscription(BuildContext context) async {
  final isPremium = ref.read(currentUserProvider).value?.isPremium ?? false;
  final currentActive = state.subscriptions.where((s) => s.status == SubscriptionStatus.active).length;

  if (!isPremium && currentActive >= 5) {
    // Show Paywall Modal
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PaywallBottomSheet(),
    );
    return false;
  }
  return true;
}
```

---

### Step 5: Implement CSV Export & Import

**Goal:** Provide an escape hatch for users so they never feel locked in.

#### Package Dependency:
```yaml
# pubspec.yaml
dependencies:
  csv: ^6.0.0
  share_plus: ^10.0.0
  file_picker: ^8.0.0
```

#### CSV Export Service:
```dart
// Location: lib/core/services/csv_service.dart

class CsvService {
  static String exportSubscriptionsToCsv(List<SubscriptionEntity> subscriptions) {
    List<List<dynamic>> rows = [
      ['Service Name', 'Amount', 'Currency', 'Billing Cycle', 'Next Billing Date', 'Status', 'Category', 'Notes']
    ];

    for (var sub in subscriptions) {
      rows.add([
        sub.serviceName,
        sub.amount,
        sub.currency,
        sub.billingCycle.name,
        sub.nextBillingDate.toIso8601String(),
        sub.status.name,
        sub.category ?? '',
        sub.notes ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }
}
```

---

### Step 6: Add Biometric App Lock (`local_auth`)

**Goal:** Allow users to protect their subscription spending data with Fingerprint / Face ID.

#### Package Dependency:
```yaml
# pubspec.yaml
dependencies:
  local_auth: ^2.3.0
```

#### Biometric Auth Trigger:
```dart
// Location: lib/core/services/biometric_service.dart

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> authenticate() async {
    final canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    if (!canAuthenticate) return true;

    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock SubGuard',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }
}
```

---

## 🎯 Verification & Launch Readiness Checklist

Before submitting the build to Google Play Store / Apple App Store:

- [ ] **Exact Alarms:** Test on Android 13/14 physical device (reminders fire accurately at scheduled hour).
- [ ] **Reboot Recovery:** Reboot test phone, verify scheduled notifications are restored from Isar.
- [ ] **Offline Resilience:** Turn on Airplane mode, add subscription, verify instant UI update. Turn on Wi-Fi, verify background Firestore sync.
- [ ] **In-App Purchases:** Verify test purchase on Google Play Billing Sandbox unlocks Pro status.
- [ ] **Data Export:** Generate and share CSV export file to Google Drive / Email.
- [ ] **Account Deletion:** Test `Delete Account` button; confirm user data is wiped from Firestore and Isar.
