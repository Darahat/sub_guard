# 🍎 SubGuard — Apple-Grade UI/UX Specification & Design System

**Document Title:** SubGuard Human Interface Guidelines & Product Design Specification  
**Role / Perspective:** Apple Senior UX Architect & Lead Product Designer  
**Document Version:** 1.0 (Production Blueprint)  
**Target Platform:** iOS (App Store Ready) & Android (Material 3 Adaptive)  
**Framework:** Flutter (Material 3 + Cupertino Polish)  
**Last Updated:** August 2026  

---

## 1. Executive Vision & The Apple Design Philosophy

SubGuard is not a spreadsheet, nor is it a passive budgeting log. SubGuard is a **proactive financial guardian**. 

Every interaction must embody the three foundational pillars of Apple Human Interface Guidelines:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       THE THREE APPLE DESIGN PILLARS                        │
├─────────────────────────────────────────────────────────────────────────────┤
│ 1. DEFERENCE      │ The interface recedes. The user's subscriptions,        │
│                   │ renewal timelines, and savings are hero. Fluid motion    │
│                   │ and crisp typography convey meaning effortlessly.       │
├───────────────────┼─────────────────────────────────────────────────────────┤
│ 2. CLARITY        │ Typography is legible at every size. Icons are precise.  │
│                   │ Financial amounts are prominent and neutral. Semantic   │
│                   │ colors (Amber/Red/Green) are reserved for urgency.      │
├───────────────────┼─────────────────────────────────────────────────────────┤
│ 3. DEPTH & CRAFT  │ Visual layers, frosted glass (blur), tactile haptic      │
│                   │ feedback, and realistic spring animations make the app  │
│                   │ feel tangible, responsive, and delightful.              │
└───────────────────┴─────────────────────────────────────────────────────────┘
```

---

## 2. Core UX Principles & Ergonomics

### 2.1 The 44pt Touch Target & Thumb-Zone Rule
* **Ergonomics:** All interactive buttons, chips, and list tiles must have a minimum hit target of **44 × 44 pt** (Apple standard).
* **Bottom-Anchored Architecture:** 90% of primary daily actions (Tabs, Floating Add Button, Quick Filter Chips, Modal Confirmations) must reside in the **Natural Thumb Zone** (bottom 40% of the screen).
* **Avoid Top Reach:** No critical workflows require reaching to the top-left or top-right corners with one hand.

```
┌─────────────────────────────────────────┐
│ [ Top Navigation Bar: Title Only ]     │  <-- Hard to reach (Display only)
│                                         │
│                                         │
│             CONTENT AREA                │  <-- Natural viewing area
│                                         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │       NATURAL THUMB ZONE            │ │
│ │  • Floating Action Button (+)       │ │  <-- Primary touch zone
│ │  • Floating Island Bottom Bar       │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 2.2 Progressive Disclosure
* Never overwhelm the user with 10 form fields at once.
* Present the essential 3 items first (Service, Amount, Cycle), and progressively reveal optional fields (Notes, Website, Notification Days) on demand or auto-fill them from the preset catalog.

---

## 3. Strict Design Tokens & Visual Hierarchy

### 3.1 Apple-Tailored Color Palette

```
+-----------------------------------------------------------------------------------+
| TOKEN NAME             | LIGHT MODE       | DARK MODE        | PURPOSE            |
+-----------------------------------------------------------------------------------+
| backgroundPrimary      | #F2F2F7 (iOS)    | #000000 (OLED)   | Canvas background  |
| surfaceCard            | #FFFFFF          | #1C1C1E          | Cards & Containers |
| surfaceElevated        | #FFFFFF          | #2C2C2E          | Modals & Sheets    |
| textPrimary            | #000000          | #FFFFFF          | Titles & Amounts   |
| textSecondary          | #8E8E93          | #8E8E93          | Subtitles & Dates  |
| accentPrimary          | #007AFF (Apple)  | #0A84FF          | Key interactive CTA|
| statusActive           | #34C759 (Green)  | #30D158          | Active status only |
| statusTrialUrgent      | #FF9500 (Amber)  | #FF9F0A          | Free Trial warning |
| statusCancelled        | #8E8E93 (Gray)   | #636366          | Cancelled / Inact  |
| statusExpense          | #FF3B30 (Red)    | #FF453A          | Destructive delete |
+-----------------------------------------------------------------------------------+
```

> [!IMPORTANT]
> **Financial Amount Typography Rule:**
> Subscription amounts (e.g. `$15.49`) must **never** be rendered in green. Green signifies incoming revenue/profit. Subscription amounts must always be styled with `textPrimary` (`#000000` / `#FFFFFF`) bold typography. Semantic colors are strictly confined to status badges and countdown indicators.

### 3.2 Typography Scale (Apple Dynamic Type Compatible)

| Style | Size | Weight | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Large Title** | 34pt | Bold (700) | 41pt | Top screen headers (e.g. "My Subscriptions") |
| **Title 1** | 28pt | Bold (700) | 34pt | Modal sheet headers |
| **Title 2** | 22pt | SemiBold (600)| 28pt | Section headers & card titles |
| **Title 3** | 20pt | SemiBold (600)| 25pt | Service names in detail view |
| **Headline** | 17pt | SemiBold (600)| 22pt | Card titles & list labels |
| **Body** | 17pt | Regular (400) | 22pt | Primary paragraphs & descriptions |
| **Callout** | 16pt | Regular (400) | 21pt | Badges & highlighted tips |
| **Subheadline** | 15pt | Regular (400) | 20pt | Secondary metadata & categories |
| **Footnote** | 13pt | Regular (400) | 18pt | Timestamp & fine print |
| **Caption 1** | 12pt | Medium (500)  | 16pt | Chip labels & tiny status tags |

---

## 4. Sensory & Motion Architecture (Haptics & Physics)

### 4.1 Tactile Haptic Feedback Matrix

Every touch in SubGuard must provide subtle, deliberate physical confirmation using `HapticFeedback`:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         HAPTIC FEEDBACK SPECIFICATION                       │
├──────────────────────────┬─────────────────────────────┬────────────────────┤
│ User Interaction         │ Flutter API Method          │ Physical Sensation │
├──────────────────────────┼─────────────────────────────┼────────────────────┤
│ Tab Switching / Chips    │ HapticFeedback.selection()  │ Crisp light tick   │
│ Button Tap (Primary CTA) │ HapticFeedback.lightImpact()│ Soft mechanical tap│
│ Add / Save Subscription  │ HapticFeedback.mediumImpact()| Solid confirmation │
│ Pull-to-Refresh Sync     │ HapticFeedback.mediumImpact()| Snapping detent    │
│ Cancel / Delete Action   │ HapticFeedback.heavyImpact()│ Firm warning pulse │
│ Biometric Auth Success   │ HapticFeedback.mediumImpact()| Dual success pulse │
└──────────────────────────┴─────────────────────────────┴────────────────────┘
```

### 4.2 Motion Physics & Fluidity (60/120 FPS)
1. **Spring Transitions:** Modals and bottom sheets must use iOS-style spring damping curve:  
   `Curves.easeOutCubic` (duration: `320ms`).
2. **Hero Transitions:** Tapping a `SubscriptionCard` on the dashboard must seamlessly expand the card container into the `SubscriptionDetailScreen` using Flutter's `Hero` widget (avoiding disorienting page slides).
3. **Micro-Interactions:** When a user marks a trial as *"Successfully Cancelled"*, trigger a micro-haptic pulse with a subtle confetti particle burst or green check animation.

---

## 5. Detailed Component Specifications

---

### Component 1: Smart Preset Catalog & 1-Tap Add Flow

#### User Problem Solved:
Eliminates 90% of manual typing friction by providing a curated database of the top 30 global subscription services.

#### Presets Dataset (Auto-Filled Fields):
```json
[
  {
    "serviceName": "Netflix",
    "category": "Video Streaming",
    "defaultAmount": 15.49,
    "currency": "USD",
    "billingCycle": "monthly",
    "brandColor": "#E50914",
    "logoAsset": "assets/logos/netflix.png",
    "cancellationUrl": "https://www.netflix.com/youraccount",
    "cancelSteps": [
      "Open your Netflix Account page.",
      "Under 'Membership & Billing', tap 'Cancel Membership'.",
      "Tap 'Finish Cancellation' to stop renewal charges."
    ]
  },
  {
    "serviceName": "Spotify",
    "category": "Music",
    "defaultAmount": 11.99,
    "currency": "USD",
    "billingCycle": "monthly",
    "brandColor": "#1DB954",
    "logoAsset": "assets/logos/spotify.png",
    "cancellationUrl": "https://www.spotify.com/account/subscription/",
    "cancelSteps": [
      "Go to your Spotify Account Overview.",
      "Scroll to 'Your plan' and tap 'Change plan'.",
      "Scroll down to 'Cancel Spotify' and tap 'Cancel Premium'."
    ]
  },
  {
    "serviceName": "ChatGPT Plus",
    "category": "Productivity & AI",
    "defaultAmount": 20.00,
    "currency": "USD",
    "billingCycle": "monthly",
    "brandColor": "#10A37F",
    "logoAsset": "assets/logos/chatgpt.png",
    "cancellationUrl": "https://chatgpt.com/#settings/Subscription",
    "cancelSteps": [
      "Click your Profile picture -> Settings.",
      "Select 'Subscription' -> 'Manage my subscription'.",
      "In the Stripe portal, click 'Cancel Plan'."
    ]
  },
  {
    "serviceName": "YouTube Premium",
    "category": "Video Streaming",
    "defaultAmount": 13.99,
    "currency": "USD",
    "billingCycle": "monthly",
    "brandColor": "#FF0000",
    "logoAsset": "assets/logos/youtube.png",
    "cancellationUrl": "https://www.youtube.com/paid_memberships",
    "cancelSteps": [
      "Go to Paid Memberships on YouTube.",
      "Tap 'Manage Membership' next to Premium.",
      "Select 'Deactivate' -> 'Continue to Cancel'."
    ]
  },
  {
    "serviceName": "Apple One / iCloud+",
    "category": "Cloud Storage",
    "defaultAmount": 9.99,
    "currency": "USD",
    "billingCycle": "monthly",
    "brandColor": "#007AFF",
    "logoAsset": "assets/logos/apple.png",
    "cancellationUrl": "https://apps.apple.com/account/subscriptions",
    "cancelSteps": [
      "Open iPhone Settings -> Tap your Name at top.",
      "Tap 'Subscriptions'.",
      "Select the subscription and tap 'Cancel Subscription'."
    ]
  }
]
```

#### Add Screen UI Flow:
1. **Header:** Large Search Field (`"Search service e.g. Netflix, Adobe, Gym..."`).
2. **Top Row:** Horizontal scrollable preset pills (`[Netflix] [Spotify] [ChatGPT] [YouTube] [iCloud] [Prime] [Adobe]`).
3. **Free Trial Switcher (Segmented Control):**  
   `[ 💳 Standard Subscription ] | [ ⏳ Free Trial ]`
4. If **"Free Trial"** is selected, show 4 quick duration chips:  
   `[ 3 Days ]  [ 7 Days ]  [ 14 Days ]  [ 30 Days ]` (automatically sets `nextBillingDate` and configures high-priority pre-conversion alarms).

---

### Component 2: The Apple-Grade Subscription Card

#### Visual Anatomy:
```
┌─────────────────────────────────────────────────────────────────┐
│ [Logo]  Netflix                           [ 🟢 Active Pill ]    │
│         Streaming • Billed Monthly                              │
│                                                                 │
│ $15.49 / mo                      Next charge: Oct 24 (in 4 days)│
│                                  [ ⏳ 4 days left ]             │
└─────────────────────────────────────────────────────────────────┘
```

#### Strict Card Styling Rules:
1. **Container:** 16pt Padding, 16pt Corner Radius (`BorderRadius.circular(16)`), Subtle Border (`Border.all(color: Colors.grey.withOpacity(0.12))`), Zero Harsh Drop-Shadows (Use soft ambient shadow: `BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: Offset(0, 4))`).
2. **Logo Icon:** 44 × 44 pt rounded container with `ClipRRect(borderRadius: BorderRadius.circular(10))`.
3. **Swipe-to-Action Gestures:**
   - **Swipe Right (Leading):** Green Background (`#34C759`) with `Pause / Reactivate` icon.
   - **Swipe Left (Trailing):** Red Background (`#FF3B30`) with `Cancel / Delete` icon.

---

### Component 3: The Dedicated Cancellation Action Hub

#### The Core Problem Solved:
Users forget how to cancel or face dark patterns from providers. SubGuard acts as the user's copilot.

#### Detail View Layout:
1. **Hero Header:** Service Logo, Title, Active Badge, Monthly/Yearly normalized cost.
2. **Cancellation Action Hub (The Hero Card):**
   ```
   ┌─────────────────────────────────────────────────────────────┐
   │ 🛡️ Cancellation Assistant                                   │
   │ Avoid being charged $15.49 on Oct 24.                       │
   │                                                             │
   │ [ 🚀 Open Netflix Cancellation Page ↗ ] (Primary Button)    │
   │                                                             │
   │ Step-by-Step Instructions:                                  │
   │ 1. Tap the button above to launch Netflix in your browser.  │
   │ 2. Scroll to 'Membership & Billing' and tap 'Cancel'.       │
   │ 3. Return here and confirm below.                           │
   │                                                             │
   │ [ ✅ Mark as Successfully Cancelled ] (Secondary Outlined)  │
   └─────────────────────────────────────────────────────────────┘
   ```
3. **One-Tap Browser Deep Link:** Calling `url_launcher` with `LaunchMode.externalApplication` to open the provider's direct cancellation route.
4. **Post-Cancellation State:** Updates status to `SubscriptionStatus.cancelled`, removes scheduled alarms, and displays a green confirmation banner with date cancelled.

---

### Component 4: Proactive Intelligence & Insights

#### Screen Layout:
1. **Conversational Weekly Watchdog Digest (Top Card):**
   > *"💡 **Upcoming Charges This Week:** You have **2 renewals** totaling **$27.48** due in the next 7 days (`ChatGPT Plus` on Wednesday, `Spotify` on Friday)."*
2. **Spending Breakdown (Pie Chart):** Clean `fl_chart` with interactive slice selection and high-contrast category legends.
3. **Monthly Projections Bar Chart:** Shows annualized projection (`$1,840 / year total subscription burn rate`).

---

### Component 5: Engaging Empty States

#### Empty Dashboard State:
Instead of a static blank page, display a warm, welcoming setup card:
```
┌─────────────────────────────────────────────────────────────┐
│ 🛡️ Welcome to SubGuard                                      │
│ Let's protect you from unwanted renewal charges.            │
│                                                             │
│ Quick start with popular subscriptions:                     │
│ [ + Netflix ]  [ + Spotify ]  [ + ChatGPT ]  [ + iCloud ]   │
│                                                             │
│                     [ + Custom Subscription ]               │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. Accessibility (a11y) & Store Compliance

1. **Dynamic Type Support:** All text widgets must support system font scaling up to 200% without clipping (use `FittedBox` or flexible wrapping where appropriate).
2. **Contrast Ratio:** All text and critical badges must maintain a minimum contrast ratio of **4.5:1** (WCAG Level AA / AAA).
3. **Screen Readers (VoiceOver / TalkBack):** All custom gesture cards must include semantic labels:
   ```dart
   Semantics(
     label: 'Netflix subscription, $15.49 monthly, renewing in 4 days. Double tap to view details.',
     child: SubscriptionCard(...),
   );
   ```

---

## 7. Implementation Checklist & Acceptance Criteria

- [ ] **Smart Presets Catalog:** Implemented with top 30 services, instant auto-fill, and high-res vector logos.
- [ ] **Cancellation Hub:** Direct URL launcher and step-by-step checklist working in `SubscriptionDetailScreen`.
- [ ] **Tactile Haptic Engine:** Integrated into all taps, card swipes, sync pulls, and deletions.
- [ ] **Typography & Color Guard:** Price amounts neutral, status pills semantic, zero green text for expense figures.
- [ ] **Bottom Navigation:** Smooth thumb-zone navigation between Subscriptions, Insights, and Settings.
- [ ] **Hero Transitions:** Fluid card expansion into detail views.
