# SubGuard — Product Requirements Document (PRD)

**Product Name:** SubGuard  
**Tagline:** Know what will charge you before it happens.  
**Target Platform:** Mobile (Android Primary, iOS Ready)  
**Framework:** Flutter (Material 3)  
**Architecture:** Clean Architecture + Local-First + Firebase Serverless  
**Document Version:** 2.0 (Consolidated & Production-Ready)  
**Last Updated:** August 2026  

---

## 1. Executive Summary & Vision

### 1.1 The Core Problem
Modern consumers face a silent financial drain:
1. **Forgotten Free Trials:** Signing up for a 7-day or 30-day trial and forgetting to cancel before the full annual/monthly fee is charged.
2. **Hidden Renewal Dates:** Inability to track when dozens of subscriptions (streaming, SaaS, gym, cloud storage, domains) renew.
3. **Unnoticed Price Hikes:** Incremental price increases that slip past monthly credit card statements.
4. **Friction in Cancellation:** Providers deliberately obscure cancellation routes (dark patterns), making cancellation tedious.
5. **Privacy & Trust Anxiety:** Existing competitor apps demand full bank credentials (Plaid/Yodlee), which frequently disconnect, fail, or create security concerns.

### 1.2 The SubGuard Promise
> **"SubGuard is your personal subscription watchdog. It detects, tracks, alerts, and assists you in cancelling recurring subscriptions before they turn into unwanted charges."**

### 1.3 Core Product Principles
- **Privacy-First (No Bank Access Required):** Users can get 100% of the core watchdog value without ever connecting a bank account or exposing financial credentials.
- **Zero-Tolerance Notification Reliability:** A reminder that arrives late or never is a total product failure. SubGuard treats notification scheduling and exact alarms as mission-critical infrastructure.
- **Action-Oriented Cancellation Assistance:** We don't just show a list of costs; we provide direct links, step-by-step guides, and a structured cancellation tracking workflow.
- **Instant Local-First Performance:** Zero UI lag. All operations are local-first via Isar DB, syncing seamlessly to Firebase in the background.

---

## 2. Target Audience & Personas

### 2.1 Primary Persona: "The Active Digital Consumer"
* **Demographics:** 20–45 years old, digital worker, student, or professional.
* **Subscription Profile:** 5 to 15 recurring subscriptions ($50 – $300+/month) across entertainment, productivity, AI tools, cloud storage, and utility apps.
* **Pain Points:** Loses $50–$200/year to forgotten trials and forgotten renewals; dislikes budgeting apps that require bank logins.

### 2.2 Secondary Persona: "The Privacy-Conscious Saver"
* **Demographics:** Values financial privacy, open-source/local-first software.
* **Pain Points:** Will not use apps like Rocket Money due to data selling or bank connection requirements; needs a reliable, self-contained subscription tracker.

---

## 3. Product Scope & MVP Boundaries

### 3.1 MVP In-Scope (Strictly Enforced)
1. **Onboarding & Local-First Access:** Instant app usage without mandatory account creation.
2. **Account System (Firebase Auth):** Optional sign-in via Email/Password, Google OAuth, and Apple Sign-In.
3. **Subscription Management (CRUD):** Add, edit, pause, cancel, archive, and delete subscriptions with custom billing cycles (daily, weekly, monthly, quarterly, yearly).
4. **Trial Expiration Protection:** Dedicated trial countdown, prominent visual badges, and pre-conversion alerts.
5. **Multi-Stage Local Reminder Engine:** Local notifications with exact alarms (7 days, 2 days, 1 day, same day) with timezone handling and reboot recovery.
6. **Cancellation Assistance Portal:** Provider-specific deep links, verified cancellation steps, and structured status tracking (Requested -> Confirmed).
7. **Post-Renewal Payment Confirmation:** Simple validation dialog asking if scheduled charge occurred, keeping records accurate.
8. **Insights & Spending Analytics:** Monthly spending trends, category breakdowns (pie chart), and Top 5 subscriptions (bar chart).
9. **Data Safety & Portability:** CSV export & import capability.
10. **In-App Purchase Monetization:** Free tier (up to 5 active subscriptions) + Pro Tier unlocked via Google Play Billing / Apple StoreKit.

### 3.2 MVP Non-Goals (Deferred to Post-MVP)
- ❌ Direct Bank Connection / Plaid Sync (avoids sync breakages and compliance issues).
- ❌ Email Scanning / Gmail API OAuth (avoids Google CASA Tier 2 security review delays).
- ❌ Third-Party Automated Cancellation on Behalf of User (avoids legal liability and credential storage).
- ❌ Credit Card Negotiation / Bill Lowering Services.
- ❌ Complex Multi-User Shared Family Budgets.

---

## 4. Detailed Functional Requirements (FRD)

```
+--------------------------------------------------------------------------+
|                         SUBGUARD CORE USER FLOW                          |
+--------------------------------------------------------------------------+
|                                                                          |
|  [ Install App ]                                                         |
|         │                                                                |
|         ▼                                                                |
|  [ 3-Screen Onboarding ] ──► Explains value & requests notification perm │
|         │                                                                |
|         ▼                                                                |
|  [ Dashboard ] ◄──────────────────────────────────────────────┐          |
|         │                                                     │          |
|         ├──► [ Add / Edit Subscription ]                      │          |
|         │         │                                           │          |
|         │         ├── Input: Service, Amount, Cycle, Date     │          |
|         │         └── Auto-Schedules Multi-Stage Local Alarms │          |
|         │                                                     │          |
|         ├──► [ Renewal Watchdog Alert Fires ]                 │          |
|         │         │                                           │          |
|         │         ├── User taps notification                  │          |
|         │         └── Decision: Keep or Cancel?               │          |
|         │                  │                                  │          |
|         │                  ├── Keep ──► Charge Confirmed ─────┤          |
|         │                  │                                  │          |
|         │                  └── Cancel ──► Open Cancel Portal ─┘          |
|         │                                      │                         |
|         │                                      ▼                         |
|         │                             Mark as Cancelled                  |
|         │                                                                |
|         └──► [ View Spending Insights & Charts ]                         |
|                                                                          |
+--------------------------------------------------------------------------+
```

### Module 1: User Onboarding & Authentication
* **FR-1.1:** 3-screen onboarding highlighting trial protection, reminder reliability, and privacy.
* **FR-1.2:** Contextual notification permission request explaining *why* exact alarms are required.
* **FR-1.3:** Local-first guest mode allowing immediate subscription entry.
* **FR-1.4:** Optional Cloud Account linking with Firebase Auth (Email/Password, Google, Apple).
* **FR-1.5:** Local user data migration upon first account creation/login.

### Module 2: Subscription CRUD & Date Calculation Engine
* **FR-2.1:** Create/Update subscription with name, category, amount, currency (USD, EUR, GBP, CAD, AUD, JPY, INR, BDT), billing cycle, next billing date, trial end date, cancellation URL, and notes.
* **FR-2.2:** Dynamic computation of normalized `monthlyEquivalent` and `yearlyEquivalent` costs.
* **FR-2.3:** Safe calendar date arithmetic handling month-end transitions (e.g., Jan 31 -> Feb 28/29) and leap years.
* **FR-2.4:** Filter and search subscriptions by status (Active, Paused, Cancelled, Expired), category, or name.

### Module 3: Trial Protection & Renewal Watchdog
* **FR-3.1:** Distinct UI treatment for trials with remaining days countdown badge.
* **FR-3.2:** Separate pre-trial conversion alarms (3 days before, 1 day before).
* **FR-3.3:** Post-renewal payment confirmation prompt: *"Did your $X charge for [Service] happen?"* to advance next billing date accurately.

### Module 4: Cancellation Assistance Workflow
* **FR-4.1:** Curated cancellation URLs for top 50 services (Netflix, Spotify, Adobe, Apple, Google, Amazon, etc.).
* **FR-4.2:** In-app cancellation walkthrough with step-by-step instructions.
* **FR-4.3:** One-tap button to open cancellation URL in external browser.
* **FR-4.4:** Status tracking: `Active` -> `Cancellation Requested` -> `Cancellation Confirmed`.

### Module 5: Insights & Analytics
* **FR-5.1:** Interactive spending trend line chart (`fl_chart`) with monthly filtering.
* **FR-5.2:** Category breakdown pie chart showing percentage and monetary contribution.
* **FR-5.3:** Top 5 costliest subscriptions vertical bar chart.
* **FR-5.4:** Summary metrics: Total active spending, average monthly cost, highest single subscription.

### Module 6: Data Portability & Backup
* **FR-6.1:** CSV export containing all subscription history, amounts, dates, and statuses.
* **FR-6.2:** CSV import parser with preview and duplicate detection.
* **FR-6.3:** Complete account and data deletion fulfilling GDPR and store policies.

---

## 5. Monetization Strategy & In-App Purchases

SubGuard uses a freemium model aligned with Google Play and Apple App Store digital content guidelines.

### Free Tier
- Up to **5 active subscriptions**
- Standard local reminder alerts (1 day before)
- Dashboard overview & trial tracking
- Local Isar database storage
- Basic CSV export

### Pro Tier ($2.99 / month or $19.99 / year)
- **Unlimited subscriptions**
- Custom multi-stage reminder schedules (7d, 3d, 2d, 1d, same day)
- Real-time Firebase Cloud backup & multi-device sync
- Advanced Insights & spending trend projections
- CSV Import & full data export
- Biometric App Lock

---

## 6. Definition of MVP Done

The MVP is production-ready when:
1. A new user installs the app, adds 3 subscriptions in < 2 minutes without account friction.
2. Local notifications fire accurately on Android (API 26–34) across reboots and Doze mode.
3. User can mark a subscription for cancellation, view the guide, and confirm cancellation.
4. User can optionally sign in with Google/Email to sync data securely to Firestore.
5. In-App Purchase unlocks Pro entitlements properly on Google Play and Apple StoreKit.
