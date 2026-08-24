# 🛡️ SubGuard

> **Know what will charge you before it happens.**  
> A privacy-first, local-first subscription watchdog and renewal tracker built with Flutter, Isar, and Firebase.

---

## 📱 About SubGuard

SubGuard is a mobile application engineered to protect consumers from forgotten free-trial conversions, unexpected subscription renewals, and unmanaged recurring expenses. 

Unlike traditional budgeting apps that mandate invasive bank logins, SubGuard is **local-first and privacy-focused**, ensuring complete offline utility with optional cloud synchronization.

---

## ✨ Key Features

- **⚡ Local-First & Zero Latency:** Fast offline-first architecture powered by the Isar Database.
- **⏰ Zero-Failure Exact Alarms:** Multi-stage renewal and trial-ending notifications (7d, 2d, 1d, same day) with timezone awareness and reboot resilience.
- **🛡️ Free Trial Protection:** Dedicated trial countdowns and pre-conversion alerts.
- **🚪 Cancellation Assistant:** Curated one-tap cancellation portals, step-by-step guides, and status tracking.
- **📊 Spending Analytics:** Interactive spending trends, category distributions, and top spenders powered by `fl_chart`.
- **☁️ Cloud Backup & Sync:** Optional Firebase Authentication (Email, Google, Apple) with real-time Cloud Firestore synchronization.
- **💎 Store-Compliant In-App Purchases:** Clean freemium model utilizing Google Play Billing and Apple StoreKit.

---

## 🏗️ Architecture & Technology Stack

SubGuard is built using **Clean Architecture** principles (Domain, Data, Presentation layers):

```
       ┌────────────────────────────────────────────────────────┐
       │                  PRESENTATION LAYER                    │
       │     (Flutter Material 3, Riverpod StateNotifier)       │
       │                           │                            │
       │                           ▼                            │
       │                    DOMAIN LAYER                        │
       │   (Entities [Freezed], Use Cases, Repository Contracts)│
       │                           ▲                            │
       │                           │                            │
       │                     DATA LAYER                         │
       │    (Isar NoSQL DB, Cloud Firestore, Repository Impl)   │
       └────────────────────────────────────────────────────────┘
```

- **Framework:** Flutter 3.24+ (Dart 3.5+)
- **State Management:** Riverpod 2.6+
- **Local Database:** Isar Database 3.1+
- **Cloud Backend:** Firebase (Auth, Cloud Firestore, Crashlytics, FCM)
- **Local Alarms:** `flutter_local_notifications` + `timezone`
- **Routing:** GoRouter 14.6+

---

## 📚 Project Documentation

All product, technical, and operational specifications are maintained in the [`docs/`](docs/) directory:

- [📄 01. Product Requirements Document (PRD)](docs/01_PRD_PRODUCT_REQUIREMENTS.md)
- [🏛️ 02. Architecture & Technology Stack](docs/02_ARCHITECTURE_AND_TECH_STACK.md)
- [💾 03. Data Models & Synchronization Spec](docs/03_DATA_MODELS_AND_SYNC_SPEC.md)
- [🔔 04. Notification & Exact Alarms Spec](docs/04_NOTIFICATIONS_AND_ALARMS_SPEC.md)
- [⚖️ 05. Compliance & In-App Monetization](docs/05_COMPLIANCE_AND_MONETIZATION.md)
- [🚀 06. Master Roadmap & Sprint Tracker](docs/06_ROADMAP_AND_SPRINT_TRACKER.md)
- [🎯 07. Feature Tracker & Implementation Guide](docs/FEATURE_TRACKER_AND_IMPLEMENTATION_GUIDE.md)
- [🔧 Firebase Setup Runbook](docs/runbooks/FIREBASE_SETUP_RUNBOOK.md)

---

## 🚀 Quick Start Guide

### Prerequisites
- Flutter SDK (>= 3.24.0)
- Android Studio / Xcode
- Firebase CLI & FlutterFire CLI

### Installation & Run

```bash
# 1. Clone the repository
git clone https://github.com/Darahat/sub_guard.git
cd sub_guard

# 2. Install dependencies
flutter pub get

# 3. Generate Freezed & Isar models
dart run build_runner build --delete-conflicting-outputs

# 4. Configure Firebase (Runbook in docs/runbooks/)
flutterfire configure

# 5. Run on connected device
flutter run
```

---

## 📄 License
This project is proprietary and confidential. All rights reserved.
