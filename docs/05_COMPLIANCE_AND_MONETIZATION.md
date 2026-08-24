# SubGuard — Compliance & In-App Monetization Specification

**Monetization Engine:** Google Play Billing & Apple StoreKit (via RevenueCat / `purchases_flutter`)  
**Store Compliance:** Google Play Policy (Section 3 - Monetization) & Apple Guideline 3.1.1  
**Privacy Framework:** GDPR / CCPA Compliant (Data Minimization & Portability)  
**Document Version:** 2.0  
**Last Updated:** August 2026  

---

## 1. Compliance Strategy: Zero Launch Delays

To achieve a fast, frictionless launch on the **Google Play Store** and **Apple App Store**, SubGuard strictly eliminates compliance blockers:

```
+-----------------------------------------------------------------------------------+
|                        COMPLIANCE & LEGAL SAFETY MATRIX                           |
+-----------------------------------------------------------------------------------+
| Risk Vector                 Competitor Trap              SubGuard MVP Strategy    |
+-----------------------------------------------------------------------------------+
| Bank Account Linking        Plaid / Yodlee sync errors   ❌ AVOIDED: 100% Manual  |
|                             & banking regulations        & Local-First MVP        |
+-----------------------------------------------------------------------------------+
| Email Receipt Scanning      Requires Google Cloud CASA   ❌ AVOIDED: Postponed    |
|                             Tier 2 Security Audit ($$$)  to Phase 3 Post-MVP      |
+-----------------------------------------------------------------------------------+
| In-App Payment Method       Stripe Credit Card Form      ✅ COMPLIANT: Native     |
|                             (Violates Apple/Google IAP)  In-App Purchases (IAP)   |
+-----------------------------------------------------------------------------------+
| Automated Cancellation      Legal power-of-attorney &    ✅ SAFE: Direct User     |
| on Behalf of User           chargeback liabilities       Deep Links & Guides Only |
+-----------------------------------------------------------------------------------+
```

---

## 2. In-App Purchase Architecture

### 2.1 Why In-App Purchases (Not Stripe)?
* **Google Play Policy Section 3.1 & Apple App Store Guideline 3.1.1** mandate that any digital feature unlocked inside a mobile app (e.g., unlimited subscriptions, cloud backup, advanced analytics) **must** use Google Play Billing / Apple In-App Purchases.
* Using Stripe inside a mobile app for digital feature unlocks leads to **instant app rejection or account suspension**.
* Stripe is strictly reserved for a future web dashboard only.

### 2.2 Entitlement & Feature Matrix

| Feature | Free Tier | Pro Tier ($2.99/mo or $19.99/yr) |
| :--- | :--- | :--- |
| **Max Active Subscriptions** | 5 Subscriptions | **Unlimited** |
| **Reminder Timing** | Default 1 Day Before | **Custom Multi-Stage (7d, 3d, 2d, 1d, same day)** |
| **Local Database Storage** | ✅ Yes (Isar) | ✅ Yes (Isar) |
| **Cloud Backup & Multi-Device Sync** | ❌ No (Local Only) | **✅ Yes (Cloud Firestore)** |
| **Insights & Analytics** | Basic Monthly Spend | **Full Trends, Pie Charts & Projections** |
| **Data Export** | Basic CSV Export | **Full CSV Export & CSV Import** |
| **Biometric App Lock** | ❌ No | **✅ Fingerprint / Face ID Unlock** |

### 2.3 Paywall Trigger Flow & Guarding
```dart
// Entitlement Guard in SubscriptionNotifier
Future<bool> canAddSubscription(int currentActiveCount, bool isPremium) async {
  if (!isPremium && currentActiveCount >= 5) {
    // Trigger Paywall BottomSheet / Screen
    return false;
  }
  return true;
}
```

---

## 3. Privacy Policy & Store Submission Blueprint

### 3.1 Privacy Declarations
1. **Financial Info:** SubGuard stores user-entered subscription labels and amounts. SubGuard **never** collects, transmits, or stores credit card numbers, CVVs, bank account numbers, or bank login passwords.
2. **User Identifiers:** If an account is created, only Email and Display Name are collected for authentication and cloud sync.
3. **Analytics:** Firebase Crashlytics & Analytics operate only on anonymized usage metrics with user opt-out support.

### 3.2 Right to Deletion & Data Portability (GDPR / Google Play Policy)
* **In-App Account Deletion Button:** Located under `Settings -> Privacy -> Delete Account`.
* **Action:** Instantly deletes all user documents from Cloud Firestore, purges user authentication record from Firebase Auth, and clears local Isar DB & secure storage.
* **Data Export:** User can export a full, unencrypted CSV of their subscription database at any time.
