# UI Tester Task List for SubGuard

This document provides a full activity checklist for every user-visible flow in the app, the screen/widget that implements it, the purpose it solves, and the specific actions a tester should verify.

## 1. Onboarding

- **File / Widget**: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
- **Purpose**: Introduce the app value propositions with animated slides.
- **Test Checklist**:
  - [done] Swipe through all onboarding pages and observe smooth parallax animations and dot indicator updates.
  - [done ] Press **Skip** in the AppBar and verify immediate navigation to the Dashboard (or Login).
  - [done ] Press **Get Started** on the final slide and verify navigation to the next screen.
  - [done] Ensure onboarding is only shown on first launch or after a manual reset.

## 2. App Lock Screen

- **File / Widget**: `lib/core/security/app_lock_screen.dart`
- **Purpose**: Secure the app when the user is away; require biometric or PIN unlock.
- **Test Checklist**:
  - [done ] Trigger the lock screen (e.g., send app to background then foreground).
  - [done] Verify the frosted-glass overlay appears and the background is blurred.
  - [done ] Test successful biometric authentication - the screen should dismiss with subtle haptic feedback.
  - [done ] Test failed authentication - an error message should appear and haptics should indicate failure.
  - [ done] Verify fallback PIN entry works when biometrics are unavailable.
  - [done ] Ensure the unlock button shows a loading spinner while authenticating.
  - [ done] Confirm that the UI adapts correctly to dark and light themes.

## 3. Dashboard

- **File / Widget**: `lib/features/subscriptions/presentation/screens/dashboard_screen.dart`
- **Purpose**: Provide an overview of all subscriptions, quick actions, and analytics.
- **Test Checklist**:
  - [ done] Scroll through the dashboard and verify the sticky header (stats) behaves correctly.
  - [done ] Tap the **Add Subscription** FAB and ensure it routes to the add screen without clipping (even with bottom nav).
  - [ done] Tap a subscription card and ensure it routes to the subscription details screen.
  - [done ] Verify that Shimmer loading skeletons display correctly before data loads.

## 4. Add / Edit Subscription

- **File / Widget**: `lib/features/subscriptions/presentation/screens/add_edit_subscription_screen.dart`
- **Purpose**: Add or update subscription details.
- **Test Checklist**:
  - [ done] Verify the preset category buttons populate fields correctly.
  - [its working ] Check the Category dropdown - ensure selecting a preset updates the dropdown without crashing.
  - [done ] Toggle the "Shared / Family Plan" switch and ensure split cost fields animate in cleanly.
  - [ done] Save the subscription and verify it reflects on the dashboard.

## 5. Notification Alarms Settings

- **File / Widget**: `lib/features/notifications/presentation/screens/notification_settings_screen.dart`
- **Purpose**: Manage reminder preferences and test notifications.
- **Test Checklist**:
  - [done ] Toggle master switch and verify time picker expands/collapses smoothly.
  - [done ] Tap "Dispatch Test Alarm" at the bottom and ensure the button is fully visible above the system notch.
  - [ done] Verify that local push notifications appear when triggered.

## 6. Payment Methods & Reassignment

=]??']\[=-]\[6]'

- **File / Widget**: `lib/features/payment_methods/presentation/screens/reassign_payment_method_sheet.dart`
- **Location**: Settings → **Payment Methods** → Tap a card with linked subscriptions → **"Reassign Subscriptions"** (or via **PaymentShieldCard**)
- **Purpose**: Batch-migrate subscriptions from one payment method to another (e.g., when a card expires or is deleted).
- **Test Checklist**:
  - [done ] Tap a payment method with linked subscriptions and select **Reassign Subscriptions**.
  - [ done] Verify the list of affected subscriptions is displayed with checkboxes.
  - [ done] Test the **Select All** pill (toggles between select-all and deselect-all).
  - [done] Pick a new target payment method and tap **Reassign Subscriptions**.
  - [ done] Confirm that all selected subscriptions are updated with the new card.

## 7. Smart Action Hub Cards

- **File / Widget**: `lib/features/subscriptions/presentation/widgets/smart_action_hub_card.dart`- **Purpose**: Aggregate contextual actions such as price-hike alerts, contract renewals, etc.
- **Test Checklist**:
  - [ done] Verify each hub entry displays a clear header, supporting icon, and actionable button.
  - [ done] Tap the action button and confirm the appropriate bottom sheet or dialog appears.
  - [ done] Ensure the hub respects the muted color palette and does not overflow on small screens.

## 8. General UI/UX Consistency (Cross-Feature)

- **Purpose**: Ensure the entire app adheres to the **10 Strict Anti-AI UI Rules**.
- **Test Checklist**:
  - [done ] All buttons use the rounded-pill style with appropriate hover/press states.
  - [ done] Haptic feedback is present on taps, swipes, and state changes.
  - [done ] No layout overflow warnings on any screen (verified on small screen devices).
  - [ done] Visual contrast meets accessibility guidelines in both light and dark mode.
  - [done ] Animations (e.g., fingerprint pulsation, bottom-sheet slide) are smooth and do not cause jank.
