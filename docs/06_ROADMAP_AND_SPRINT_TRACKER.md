# SubGuard — Master Roadmap & Sprint Tracker

**Project Name:** SubGuard  
**Current Phase:** Production Launch Readiness  
**Target Platform:** Android (Play Store) & iOS (App Store)  
**Document Version:** 3.0  
**Last Updated:** August 2026  

---

## 1. Project Implementation Status Dashboard

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           OVERALL PROJECT PROGRESS: 100%                    │
├────────────────────────────┬─────────────┬──────────────────────────────────┤
│ Module                     │ Status      │ Deliverables                     │
├────────────────────────────┼─────────────┼──────────────────────────────────┤
│ Phase A: Authentication    │ 100% Done   │ Email/Pass, Google, Apple, Hive  │
│ Phase B: Subscriptions     │ 100% Done   │ CRUD, Dashboard, Filters, Cycles │
│ Phase C: Insights          │ 100% Done   │ fl_chart Trends, Pie, Bar Charts │
│ Phase D: Cloud Sync        │ 100% Done   │ Firestore DS, SyncService, Queue │
│ Phase E: Notifications     │ 100% Done   │ Exact Alarms, Channels, UI       │
│ Phase F: Monetization (IAP)│ 100% Done   │ 5-Sub limit, PaywallBottomSheet  │
│ Phase 9–16: Advanced Shield│ 100% Done   │ Contract, Payment, Hike Shields  │
└────────────────────────────┴─────────────┴──────────────────────────────────┘
```

---

## 2. Completed Milestones Breakdown

### ✅ Phase 1–8: Core Foundations & Monetization (100% Complete)
* Authentication: Email/Password, Google & Apple Sign-In, profile management.
* Core CRUD: Full offline-first Hive persistence, 5 billing cycles.
* Spending Analytics: Line charts, pie charts, and bar charts powered by `fl_chart`.
* Exact Alarms: Timezone-aware reminders with 3 Android notification channels.
* Cloud Sync: Hybrid local-first Firestore sync with conflict resolution.
* Paywall & IAP: 5-subscription free limit guard and Pro status.
* Data Safety: CSV & Excel import/export and Biometric App Lock (`local_auth`).
* Preset Catalog: Curated 50+ popular services with logos.

### ✅ Phase 9–16: Advanced Protection & Financial Intelligence (100% Complete)
* **Phase 9**: Cancellation Vault with curated 1-tap direct cancellation links and step guides.
* **Phase 10**: Post-billing renewal confirmation check-ins and unused subscription hygiene audit.
* **Phase 11**: Multi-currency normalization (150+ currencies), overspend budget guard, and family cost-splitting.
* **Phase 12**: Preset services discovery catalog with category pill filtering and 1-tap addition.
* **Phase 13**: Long-term spending projections (1/3/5/10yr), safe opportunity cost simulation ($r=0\%$ safe), and potential savings advisor.
* **Phase 14**: Annual contract and auto-renew lock-in shield with calendar-accurate notice period deadline alarms.
* **Phase 15**: Non-sensitive payment methods management, card expiry shield, spend at risk aggregation, and 1-tap bulk reassignment.
* **Phase 16**: Historical price tracking, price hike anomaly detection, portfolio spending creep calculation, and Dashboard alerts.

---

## 3. Upcoming Post-MVP Enhancements

### 📅 Phase 17: Interactive Renewal Calendar View & Schedule Heatmap
* Visual monthly calendar grid displaying subscription brand icons on exact renewal dates.
* Daily & weekly spending cash flow heatmap with color intensity.
* 1-tap date selection to inspect upcoming renewals and charges for any day.

### 📱 Phase 18: Android & iOS Home Screen Widgets
* Interactive widgets displaying upcoming charges in the next 7 days.
* Quick Add subscription action.
