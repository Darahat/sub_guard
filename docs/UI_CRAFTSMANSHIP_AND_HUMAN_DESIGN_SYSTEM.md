# 🎨 SubGuard — UI Craftsmanship & Anti-AI Design System Manifesto

**Project:** SubGuard  
**Design Philosophy:** Apple Design Award Tier-1 Fintech Craftsmanship (_Linear, Cron, Revolut, Apple Wallet_)  
**Version:** 1.0  
**Status:** Active Design Standard

---

## 🏛️ Part 1: The 10 Strict Anti-AI UI Rules

These rules eliminate the generic "AI-generated prototype" appearance and elevate the app into a polished, production-grade consumer product.

### 1. 🚫 Eliminate "Emoji Soup" — Vector Icons Only

- **Rule:** Never use colorful emojis (`🛡️ 🔒 ⚠️ 🚨 💳 💡 📊 📈`) in system headers, banners, buttons, card titles, or navigation bars.
- **Standard:** Use monochrome vector icons (`IconData` from Cupertino/Material Symbols or curated SVGs) enclosed in a subtle tinted container with 8–12% opacity of the brand or semantic color.
- **Exception:** Emojis are permitted only if explicitly chosen by the user as a custom category avatar.

### 2. 🧱 Ban "Card Stacking Fatigue" — Adopt Apple-Style Grouped Lists

- **Rule:** Do not stack 10 independent floating rectangular cards with generic drop shadows (`BoxShadow(blurRadius: 10)`) on a single screen.
- **Standard:** Group related controls and metrics into **Grouped Inset Sections** (`borderRadius: 16` to `20`, subtle border `Border.all(color: Colors.grey.withOpacity(0.12))`, internal 1px hair dividers between rows).
- **Grid:** Enforce a strict **4pt / 8pt spatial rhythm** (`4, 8, 12, 16, 24, 32, 48`). No arbitrary paddings (e.g. `11px`, `19px`).

### 3. 🌑 Layered Zinc/Slate Elevation (No Pure Black `#000000`)

- **Rule:** Never use `#000000` pitch black backgrounds with raw `#FFFFFF` text and harsh neon alert boxes.
- **Standard:** Use a 4-tier dark mode zinc palette:
  - **Base Canvas:** `#09090B` (Zinc-950)
  - **Grouped Surface:** `#121215` / `#18181B` (Zinc-900)
  - **Interactive Element / Input:** `#27272A` (Zinc-800)
  - **Subtle Outline:** `#3F3F46` with 15–20% opacity.
  - **Muted Semantic Accents:** Desaturated warning amber (`Color(0xFFF59E0B)` at 10% bg), error crimson (`Color(0xFFEF4444)` at 10% bg), and success emerald (`Color(0xFF10B981)` at 10% bg).

### 4. ✍️ Radical Typographic Hierarchy & Tabular Financial Figures

- **Rule:** Avoid uniform 14sp/16sp regular font dumping across the screen.
- **Standard:**
  - **Hero Financial Totals:** `32sp` to `40sp`, `FontWeight.w700`, `letterSpacing: -1.0`, enabled with `fontFeatures: [FontFeature.tabularFigures()]` so digits don't jump when animating.
  - **Section Overheads:** `11sp` to `12sp`, `FontWeight.w600`, uppercase with `letterSpacing: 0.8`, `color: textSecondary`.
  - **Body / Metadata:** `13sp` to `14sp`, `FontWeight.w400` / `w500`, high contrast readability.

### 5. 🎛️ Unified Action Hub (Progressive Disclosure)

- **Rule:** Do not stack 5 separate warning banners on the dashboard simultaneously (Contract Alert + Payment Expiry + Renewal Check-in + Price Hike + Budget Alert).
- **Standard:** Consolidate active warnings into a single sleek **Smart Action Hub** (e.g. _"2 items need your attention →"_). Tapping opens a focused resolution sheet.

### 6. 🌊 Smooth Micro-Interactions & Animated Layout Shifts

- **Rule:** Never pop UI in and out abruptly with hard cuts or use raw `CircularProgressIndicator` spinners in content areas.
- **Standard:**
  - Wrap dynamic/collapsible sections in `AnimatedSize` and `AnimatedSwitcher` (`duration: Duration(milliseconds: 240)`, `curve: Curves.easeInOutCubic`).
  - Use geometry-matched **Skeleton Shimmer Loaders** during initial data hydration.

### 7. 📳 Sensory Haptic Craftsmanship

- **Rule:** Avoid uniform vibrations on every tap or omitting haptics entirely.
- **Standard:**
  - `HapticFeedback.selectionClick()`: Tab bar switches, segment changes, calendar date taps.
  - `HapticFeedback.lightImpact()`: Toggles, checkboxes, filter chips.
  - `HapticFeedback.mediumImpact()`: Deletions, confirmations, payment reassignments.
  - `HapticFeedback.heavyImpact()` / Success vibration: Pro tier unlock, successful export.

### 8. 📋 Modern Input Ergonomics (Curved Sheets over Desktop Dialogs)

- **Rule:** Avoid boxy centered `AlertDialog` modals for forms.
- **Standard:** Use **Curved Modal Bottom Sheets** (`borderRadius: BorderRadius.vertical(top: Radius.circular(24))`) equipped with a top grab handle pill (`width: 36, height: 4, borderRadius: 2`). Form inputs automatically scroll into view on keyboard display.

### 9. 🏷️ High-End Gradient Monograms for Custom Services

- **Rule:** Avoid blank grey generic circles with plain letters when a service logo is missing.
- **Standard:** Generate deterministic dual-tone subtle linear gradients derived from the service name string with crisp white typographic monograms.

### 10. 📱 Edge-to-Edge Fluidity & Platform Native Feel

- **Rule:** No clipping into system navigation bars, gesture pills, or camera cutouts.
- **Standard:** Set edge-to-edge transparent system overlay bars, strictly respect `SafeArea` bottom padding, and preserve native iOS edge-swipe back navigation.

---

## 📱 Part 2: Complete Page & Component Audit Inventory

Below is the exhaustive inventory of all routed pages from [`AppRouter`](file:///d:/Dream/Flutter%20App/sub_guard/lib/core/router/app_router.dart) and all non-routed components, with their required design elevation tasks:

### 🌐 Section A: Routed Pages (`AppRouter`)

| Route Path                 | Screen Class                 | Current AI Aesthetic Issues       | Required Craftsmanship Refinement                                                                             |
| :------------------------- | :--------------------------- | :-------------------------------- | :------------------------------------------------------------------------------------------------------------ |
| `/`                        | `SplashScreen`               | Basic center logo                 | Add smooth brand fade-in and scale animation with haptic tick.                                                |
| `/onboarding`              | `OnboardingScreen`           | Standard PageView dots            | Add interactive swipe physics, parallax illustration depth, and haptic page snaps.                            |
| `/onboarding/tour`         | `ProductTourScreen`          | Basic step stepper                | Add animated interactive preview cards with interactive micro-taps.                                           |
| `/login`                   | `LoginScreen`                | Standard boxed text fields        | Grouped inputs with integrated validation feedback and clean OAuth icon pills.                                |
| `/signup`                  | `SignupScreen`               | Generic layout                    | Modern grouped form with live password strength meter bar.                                                    |
| `/forgot-password`         | `ForgotPasswordScreen`       | Standard form                     | Minimalist card with clean mail icon container and success state transition.                                  |
| `/verify-email`            | `VerifyEmailScreen`          | Generic status box                | Animated pulse on email illustration and 60s cooldown timer button.                                           |
| `/dashboard`               | `DashboardScreen`            | 5 stacked alert banners & cards   | Consolidate into **Unified Smart Action Hub**; elevate hero spending header with tabular font figures.        |
| `/insights`                | `InsightsScreen`             | Multiple separate chart cards     | Group charts into unified segmented analytics canvas; add interactive chart touch tooltips with haptics.      |
| `/settings`                | `SettingsScreen`             | Long flat list of ListTiles       | Group into iOS-style Inset Grouped sections (`ACCOUNT`, `PREFERENCES`, `DATA & SECURITY`, `ABOUT`).           |
| `/subscriptions/add`       | `AddEditSubscriptionScreen`  | Very long single scroll form      | Segment form into modern Cupertino-style grouped cards (Core Details, Billing & Method, Contract & Sharing).  |
| `/subscriptions/edit/:id`  | `AddEditSubscriptionScreen`  | Long form with multiple pickers   | Refine with inline segmented pickers and clean currency selector sheet.                                       |
| `/subscriptions/:id`       | `SubscriptionDetailScreen`   | Mixed card styles                 | Clean hero card showing upcoming charge, grouped billing details, and sleek price history timeline.           |
| `/payment-methods`         | `PaymentMethodsScreen`       | Separate cards with delete popups | Elevate card graphics to credit card aspect ratio (1.586) with subtle shimmer, and bottom sheet action menus. |
| `/settings/notifications`  | `NotificationSettingsScreen` | Basic switch list tiles           | Inset grouped list with interactive time-of-day wheel picker.                                                 |
| `/settings/about`          | `AboutScreen`                | Plain text labels                 | Clean branding card with version badges, open-source attribution links, and developer info.                   |
| `/settings/privacy`        | `PrivacyScreen`              | Raw text view                     | Formatted typography with expandable policy sections.                                                         |
| `/settings/terms`          | `TermsScreen`                | Raw text view                     | Formatted typography with clear section headers.                                                              |
| `/profile`                 | `ProfileScreen`              | Basic avatar + text               | Sleek user header with account type badge (Pro / Free) and grouped action tiles.                              |
| `/profile/change-password` | `ChangePasswordScreen`       | Standard dialog-like form         | Modern grouped security card with clear requirements checklist.                                               |

---

### 🧩 Section B: Non-Routed Components (Modals, Dialogs, Cards & Widgets)

| Component                         | File Path                                                                              | Current AI Aesthetic Issues      | Required Craftsmanship Refinement                                                                                          |
| :-------------------------------- | :------------------------------------------------------------------------------------- | :------------------------------- | :------------------------------------------------------------------------------------------------------------------------- |
| **Paywall Bottom Sheet**          | `lib/features/monetization/presentation/widgets/paywall_bottom_sheet.dart`             | Generic feature checklist        | Add frosted glass header, glowing Pro badge, annual/monthly toggle with "Save 44%" pill, and animated feature carousel.    |
| **Cancellation Vault Card**       | `lib/features/preset_catalog/presentation/widgets/cancellation_vault_card.dart`        | Emoji headers and text blocks    | Replace emoji with clean vector icons, add step-by-step numbered progress pills, and sleek Safari/Chrome deep-link button. |
| **Payment Shield Card**           | `lib/features/payment_methods/presentation/widgets/payment_shield_card.dart`           | Amber warning banner with emojis | Compact, refined warning pill with spend-at-risk metric and 1-tap sheet trigger.                                           |
| **Contract Shield Card**          | `lib/features/subscriptions/presentation/widgets/contract_shield_card.dart`            | Standalone amber alert           | Integrate into Smart Action Hub with countdown progress circle.                                                            |
| **Price Hike Alert Card**         | `lib/features/subscriptions/presentation/widgets/price_hike_alert_card.dart`           | Standalone orange banner         | Integrate into Smart Action Hub with clean delta tags (`+16.1%`).                                                          |
| **Renewal Confirmation Card**     | `lib/features/subscriptions/presentation/widgets/renewal_confirmation_card.dart`       | Multi-card banner                | Smooth swipeable or 1-tap `[ Confirm ]` / `[ Missed / Changed ]` micro-buttons.                                            |
| **Subscription Health Card**      | `lib/features/subscriptions/presentation/widgets/subscription_health_card.dart`        | Generic warning card             | Refined hygiene score badge with progressive review sheet.                                                                 |
| **Reassign Payment Method Sheet** | `lib/features/payment_methods/presentation/screens/reassign_payment_method_sheet.dart` | Standard checkbox list           | Modern bottom sheet with search, select-all pill, and target card preview chip.                                            |
| **Payment Confirmation Dialog**   | `lib/features/subscriptions/presentation/widgets/payment_confirmation_dialog.dart`     | Centered `AlertDialog`           | Convert to compact bottom sheet with payment date picker and price confirmation toggle.                                    |
| **Subscription Card**             | `lib/features/subscriptions/presentation/widgets/subscription_card.dart`               | Many stacked small badges        | Refine badge styling to muted 10% opacity micro-pills; add subtle slide actions (Swipe to delete/edit).                    |
| **App Lock Screen**               | `lib/core/security/app_lock_screen.dart`                                               | Basic lock icon and button       | Frosted glass blur overlay (`BackdropFilter`) with animated biometric fingerprint prompt.                                  |
| **Service Brand Icon**            | `lib/features/subscriptions/presentation/widgets/service_brand_icon.dart`              | Plain grey circle fallback       | Dual-tone subtle linear gradients with crisp typography.                                                                   |
