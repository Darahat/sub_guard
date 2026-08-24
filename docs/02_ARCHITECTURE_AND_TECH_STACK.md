# SubGuard — Architecture & Technology Stack Specification

**Architecture Pattern:** Clean Architecture (Domain, Data, Presentation)  
**State Management:** Flutter Riverpod 2.6+  
**Local Database:** Isar Database (v3.1.0+1)  
**Cloud Backend:** Firebase Serverless (Auth, Firestore, Cloud Functions, FCM)  
**Navigation:** GoRouter (v14.6+)  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 1. Architectural Philosophy: The Concentric Layer Model

SubGuard is built using **Clean Architecture** combined with a **Local-First** design pattern. The code is strictly divided into three concentric layers with one-way dependency flow towards the domain core.

```
       ┌────────────────────────────────────────────────────────┐
       │                  PRESENTATION LAYER                    │
       │   (Widgets, Screens, Notifiers, State, Providers)      │
       │                           │                            │
       │                           ▼                            │
       │                    DOMAIN LAYER                        │
       │       (Entities, Use Cases, Repository Contracts)      │
       │                           ▲                            │
       │                           │                            │
       │                     DATA LAYER                         │
       │   (DataSources [Isar / Firestore], Models, Repos Impl) │
       └────────────────────────────────────────────────────────┘
```

### 1.1 Domain Layer (Core Business Logic)
* **Purity:** Contains **zero** dependencies on Flutter UI, Firebase SDKs, Isar, or external frameworks. Pure Dart only.
* **Entities:** Immutable business models created with `Freezed` (e.g., `SubscriptionEntity`, `UserEntity`, `NotificationEntity`, `InsightEntity`).
* **Repository Interfaces:** Abstract contracts defining data operations (e.g., `SubscriptionRepository`, `AuthRepository`).
* **Use Cases:** Single-responsibility orchestrators encapsulating specific business actions (e.g., `AddSubscriptionUseCase`, `GetTotalMonthlySpendingUseCase`, `ScheduleRenewalReminderUseCase`).

### 1.2 Data Layer (Infrastructure & Persistence)
* **Models:** Serializable objects tailored for persistence engines (e.g., `SubscriptionModel` with `@collection` for Isar, `UserModel`).
* **Data Sources:**
  - **Local:** `LocalSubscriptionDataSource`, `LocalAuthDataSource`, `LocalNotificationDataSource` (interacting directly with Isar DB and FlutterSecureStorage).
  - **Remote:** `RemoteSubscriptionDataSource`, `FirebaseAuthDataSource` (interacting with Cloud Firestore and Firebase Auth).
* **Repository Implementations:** Concrete classes (e.g., `SubscriptionRepositoryImpl`) orchestrating local cache reads, background remote sync, and error mapping to `Failure` types.

### 1.3 Presentation Layer (UI & State Management)
* **Notifiers:** `StateNotifier` / `Notifier` classes managing reactive state (e.g., `SubscriptionNotifier`, `AuthNotifier`, `InsightNotifier`, `NotificationSettingsNotifier`).
* **Providers:** Riverpod providers injecting use cases and dependencies cleanly.
* **Screens & Widgets:** Material 3 declarative widgets built with `ConsumerWidget` or `ConsumerStatefulWidget`.

---

## 2. Technology Stack & Package Matrix

| Category | Recommended Package | Version | Purpose & Architectural Rationale |
| :--- | :--- | :--- | :--- |
| **Framework** | `flutter` | 3.24+ | Cross-platform, high-performance UI rendering engine. |
| **State Management** | `flutter_riverpod` | ^2.6.1 | Compile-safe dependency injection & reactive state management. |
| **Code Generation** | `riverpod_annotation` | ^2.6.1 | Type-safe provider definitions. |
| **Navigation** | `go_router` | ^14.6.2 | Declarative URL routing, nested routes, deep links & redirect guards. |
| **Local Database** | `isar` / `isar_flutter_libs` | ^3.1.0+1 | Ultra-fast, zero-boilerplate NoSQL database with encryption & index support. |
| **Cloud Auth** | `firebase_auth` | ^5.3.1 | Google, Apple, and Email authentication with automated token management. |
| **Cloud DB** | `cloud_firestore` | ^5.6.12 | Real-time multi-device cloud backup & document database. |
| **Local Alarms** | `flutter_local_notifications`| ^18.0.1 | Exact alarm scheduling, Android channels, and heads-up notifications. |
| **Timezone** | `timezone` | ^0.10.1 | Safe calendar calculation across daylight savings & timezone changes. |
| **OAuth** | `google_sign_in` | ^6.2.1 | Native Google Sign-In SDK integration. |
| **OAuth** | `sign_in_with_apple` | ^6.1.4 | Required native Apple Sign-In support for iOS App Store compliance. |
| **Secure Vault** | `flutter_secure_storage` | ^9.2.2 | Encrypted keychain/keystore storage for sensitive tokens and keys. |
| **Charts** | `fl_chart` | ^0.69.0 | Performant, customizable line, pie, and bar charts. |
| **Functional Error** | `dartz` | ^0.10.1 | Functional `Either<Failure, Success>` programming pattern. |
| **Immutability** | `freezed` / `freezed_annotation`| ^2.5.2 | Immutable entities, copyWith methods, and union types. |
| **Currency/Dates** | `intl` | ^0.19.0 | International currency formatting and localized date parsing. |

---

## 3. Project Directory Structure

```
lib/
├── core/
│   ├── constants/            # Global constants (currencies, categories, keys)
│   ├── error/                # Failure & Exception definitions (Failures -> Either)
│   ├── firebase/             # FirebaseConfig, Firestore instances, Crashlytics
│   ├── notifications/        # NotificationService (local notification initialization)
│   ├── router/               # AppRouter (GoRouter configuration with auth guards)
│   ├── sync/                 # SyncService, SyncQueue, SyncStatus entities
│   ├── theme/                # Material 3 AppTheme, AppColors, AppTypography
│   └── utils/                # DateUtils (month-end safe math), CurrencyUtils, Logger
│
├── features/
│   ├── auth/
│   │   ├── domain/           # UserEntity, AuthRepository, 8 Use Cases
│   │   ├── data/             # UserModel (Isar), FirebaseAuthDS, LocalAuthDS, AuthRepoImpl
│   │   └── presentation/     # AuthNotifier, LoginScreen, SignupScreen, ForgotPasswordScreen
│   │
│   ├── subscriptions/
│   │   ├── domain/           # SubscriptionEntity, SubscriptionRepository, 7 Use Cases
│   │   ├── data/             # SubscriptionModel (Isar), LocalSubDS, RemoteSubDS, SubRepoImpl
│   │   └── presentation/     # SubscriptionNotifier, DashboardScreen, AddEditSubScreen, DetailScreen
│   │
│   ├── insights/
│   │   ├── domain/           # InsightEntities (SpendingDataPoint, CategorySpending), InsightRepo
│   │   ├── data/             # InsightRepositoryImpl (computed directly from local subscriptions)
│   │   └── presentation/     # InsightNotifier, InsightsScreen, Chart Widgets (Line, Pie, Bar)
│   │
│   └── notifications/
│       ├── domain/           # NotificationEntity, NotificationSettingsEntity, NotifRepo, Use Cases
│       ├── data/             # NotificationModel (Isar), LocalNotifDS, NotifRepoImpl
│       └── presentation/     # NotificationSettingsNotifier, NotificationSettingsScreen
│
├── firebase_options.dart     # Auto-generated by FlutterFire CLI
└── main.dart                 # Application entry point with Isar & Firebase initialization
```

---

## 4. Error Handling & Data Flow Strategy

### 4.1 Functional Error Handling with `Either<Failure, T>`
Never throw uncaught exceptions into the UI layer. All repository methods and use cases return `Either<Failure, T>`:

```dart
// Domain Contract
abstract class SubscriptionRepository {
  Future<Either<Failure, List<SubscriptionEntity>>> getAllSubscriptions();
}

// Presentation Consumption
final result = await _getAllSubscriptionsUseCase();
result.fold(
  (failure) => state = state.copyWith(errorMessage: failure.message, isLoading: false),
  (subscriptions) => state = state.copyWith(subscriptions: subscriptions, isLoading: false),
);
```

### 4.2 Failure Hierarchy
* `ServerFailure`: Cloud Firestore or network synchronization issues.
* `CacheFailure`: Local Isar database read/write errors.
* `AuthFailure`: Firebase Authentication credential errors or permission denied.
* `NotificationFailure`: Exact alarm permission denied or scheduling failure.
