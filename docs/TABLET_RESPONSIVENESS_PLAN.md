# SubGuard Tablet Responsiveness Plan

> **Goal:** Make all SubGuard screens and components adapt gracefully from **mobile (360dp)** to **tablet (600dp-1024dp+)** using Flutter LayoutBuilder, MediaQuery, and Material 3 NavigationRail patterns.
> **Approach:** No new packages required. Zero breaking changes to existing logic. All changes are purely layout/structural.

---

## 1. Breakpoint System

A single shared utility class used across all files:

`dart
// lib/core/layout/responsive_layout.dart [NEW]
class Breakpoints {
static const double mobile = 0;
static const double tablet = 600;
static const double desktop = 900;

static bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < tablet;
static bool isTablet(BuildContext context) => MediaQuery.sizeOf(context).width >= tablet;
static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= desktop;
}
`

---

## 2. Complete Inventory

### 2.1 Screens (17 total)

| #   | Screen                                    | Route                    | Tablet Issue                                                   |
| --- | ----------------------------------------- | ------------------------ | -------------------------------------------------------------- |
| 1   | DashboardScreen                           | /dashboard               | Single-column wastes space; needs 2-col subscription grid      |
| 2   | InsightsScreen                            | /insights                | Charts unconstrained; needs side-by-side layout                |
| 3   | SettingsScreen                            | /settings                | Long list wastes width; needs 2-col tile grid                  |
| 4   | PaymentMethodsScreen                      | /payment-methods         | Carousel cards become tiny; needs adaptive viewportFraction    |
| 5   | AddEditSubscriptionScreen                 | /subscriptions/add       | Form fields stretch full screen; needs maxWidth + 2-col fields |
| 6   | SubscriptionDetailScreen                  | /subscriptions/:id       | Misses master-detail split layout                              |
| 7   | LoginScreen                               | /login                   | Full-width form; needs centered card (maxWidth 480dp)          |
| 8   | SignupScreen                              | /signup                  | Same as Login                                                  |
| 9   | ForgotPasswordScreen                      | /forgot-password         | Same as Login                                                  |
| 10  | VerifyEmailScreen                         | /verify-email            | Minor padding tweak only                                       |
| 11  | OnboardingScreen                          | /onboarding              | Slides need side-by-side icon+text on tablet                   |
| 12  | ProductTourScreen                         | /onboarding/tour         | Same as Onboarding                                             |
| 13  | ProfileScreen                             | /profile                 | Too wide; needs ConstrainedBox maxWidth 600                    |
| 14  | ChangePasswordScreen                      | /profile/change-password | Center-constrain on tablet                                     |
| 15  | NotificationSettingsScreen                | /settings/notifications  | maxWidth 600 constraint needed                                 |
| 16  | AboutScreen / PrivacyScreen / TermsScreen | /settings/\*             | maxWidth 720 text container                                    |
| 17  | AppLockScreen                             | (gate)                   | Already OK; minor padding                                      |

### 2.2 Reusable Widgets (20+ total)

| #   | Widget                             | Tablet Issue                             |
| --- | ---------------------------------- | ---------------------------------------- |
| 1   | SubscriptionCard                   | Max-width 480dp cap                      |
| 2   | StatsCard                          | 2-col / 4-col grid on tablet             |
| 3   | BudgetProgressCard                 | Max-width 600dp cap                      |
| 4   | PaymentShieldCard (dashboard)      | Max-width cap                            |
| 5   | ContractShieldCard                 | Max-width cap                            |
| 6   | PriceHikeAlertCard                 | Max-width cap                            |
| 7   | RenewalConfirmationCard            | Max-width cap                            |
| 8   | SubscriptionHealthCard             | Max-width cap                            |
| 9   | SmartActionHubCard                 | Side panel candidate on tablet           |
| 10  | ZombieSubscriptionCard             | Max-width cap                            |
| 11  | ServiceBrandIcon                   | Fine at any size                         |
| 12  | PaymentConfirmationDialog          | Auto-constrained                         |
| 13  | ActionHubModalSheet                | Sheet maxWidth 600dp on tablet           |
| 14  | PriceHistoryTimeline               | Wider chart on tablet                    |
| 15  | PaymentShieldCard (payment screen) | Adaptive carousel size                   |
| 16  | ReassignPaymentMethodSheet         | Sheet maxWidth 600dp                     |
| 17  | BulkLinkSubscriptionsSheet         | Sheet maxWidth 600dp                     |
| 18  | CategoryPieChart                   | Adaptive chart size                      |
| 19  | SpendingTrendChart                 | Larger chart area on tablet              |
| 20  | StatsOverviewCard                  | 2-col grid on tablet                     |
| 21  | TopSubscriptionsBar                | More items visible                       |
| 22  | ShimmerLoading                     | Responsive column count                  |
| 23  | MainBottomNavScaffold              | BIGGEST CHANGE: NavigationRail on tablet |

---

## 3. The Big Change: Navigation Shell

MainBottomNavScaffold in app_router.dart must switch from BottomNavigationBar to NavigationRail on tablet.

Mobile (< 600dp): BottomNavigationBar stays unchanged.

Tablet (>= 600dp): NavigationRail on the left side.

Desktop (>= 900dp): Extended NavigationRail with labels always visible.

---

## 4. Layout Strategy Per Screen Category

### Auth Forms (Login, Signup, ForgotPassword, ChangePassword, Profile)

Center + ConstrainedBox(maxWidth: 480)

### Dashboard

Stats: GridView crossAxisCount isTablet ? 4 : 2
Subscriptions: GridView crossAxisCount isTablet ? 2 : 1

### Insights

LayoutBuilder Row on tablet: PieChart left (40%), Stats+Trend right (60%)

### Settings

GridView 2-col on tablet for setting tiles

### Payment Methods

viewportFraction: isTablet ? 0.6 : 0.88

### Subscription Detail

Row master-detail on tablet: info left, actions right

### Add/Edit Subscription

ConstrainedBox maxWidth 680 + 2-col field pairs on tablet

### Onboarding / Product Tour

Row side-by-side: icon/art left (40%), text+CTA right (60%)

### All Bottom Sheets

constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity)

---

## 5. Phased Implementation

### Phase 1 - Foundation (CRITICAL - Do First)

Files:

- [NEW] lib/core/layout/responsive_layout.dart
- [MODIFY] lib/core/router/app_router.dart (MainBottomNavScaffold)

Steps:

1. Create responsive_layout.dart with Breakpoints class and showAdaptiveBottomSheet helper
2. Update MainBottomNavScaffold to use LayoutBuilder
3. On mobile: keep BottomNavigationBar
4. On tablet: use NavigationRail (collapsed)
5. On desktop: use NavigationRail (extended with labels)

---

### Phase 2 - Auth Screens (Quick Wins)

Files:

- [MODIFY] login_screen.dart
- [MODIFY] signup_screen.dart
- [MODIFY] forgot_password_screen.dart
- [MODIFY] change_password_screen.dart
- [MODIFY] profile_screen.dart

Steps per file:

1. Wrap root column in Center > ConstrainedBox(maxWidth: isTablet ? 480 : double.infinity)
2. Add horizontal padding EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16)

---

### Phase 3 - Dashboard (HIGH IMPACT)

Files:

- [MODIFY] dashboard_screen.dart
- [MODIFY] subscription_card.dart (add internal ConstrainedBox)
- [MODIFY] stats_card.dart (adaptive font size)
- [MODIFY] budget_progress_card.dart

Steps:

1. Wrap full page in LayoutBuilder
2. StatsCard row: change to GridView.count(crossAxisCount: isTablet ? 4 : 2)
3. Subscription list: change SliverList to SliverGrid on tablet (crossAxisCount: 2)
4. All cards: wrap with ConstrainedBox(maxWidth: 480) in tablet mode
5. Add maxCrossAxisExtent: 480 to SliverGrid for tablet

---

### Phase 4 - Insights Screen

Files:

- [MODIFY] insights_screen.dart
- [MODIFY] category_pie_chart.dart
- [MODIFY] spending_trend_chart.dart
- [MODIFY] stats_overview_card.dart
- [MODIFY] top_subscriptions_bar.dart

Steps:

1. Wrap InsightsScreen body in LayoutBuilder
2. On tablet: use Row with two columns (charts left, stats right)
3. CategoryPieChart: use LayoutBuilder to grow chart size proportionally
4. SpendingTrendChart: increase chart height on tablet (isTablet ? 300 : 200)
5. StatsOverviewCard: GridView crossAxisCount isTablet ? 2 : 1

---

### Phase 5 - Settings Screens

Files:

- [MODIFY] settings_screen.dart
- [MODIFY] legal_screens.dart (About, Privacy, Terms)
- [MODIFY] notification_settings_screen.dart

Steps:

1. SettingsScreen: LayoutBuilder, on tablet 2-col GridView of setting tiles
2. Legal screens: Center > ConstrainedBox(maxWidth: 720) for all text content
3. NotificationSettings: ConstrainedBox(maxWidth: 600)

---

### Phase 6 - Subscription Screens

Files:

- [MODIFY] add_edit_subscription_screen.dart
- [MODIFY] subscription_detail_screen.dart
- [MODIFY] action_hub_modal_sheet.dart (sheet in detail screen)

Steps:

1. AddEdit: ConstrainedBox maxWidth 680 + row pairs for Name+Amount, Currency+Billing
2. Detail: LayoutBuilder, on tablet Row(info panel left, SmartActionHub right)
3. ActionHubModalSheet: add constraints maxWidth 600 on tablet

---

### Phase 7 - Payment Methods

Files:

- [MODIFY] payment_methods_screen.dart
- [MODIFY] reassign_payment_method_sheet.dart

Steps:

1. Carousel: viewportFraction isTablet ? 0.55 : 0.88
2. Card height: isTablet ? 200 : 168
3. Linked subs: GridView 2-col on tablet
4. Both bottom sheets: constraints maxWidth 600 on tablet

---

### Phase 8 - Onboarding Screens

Files:

- [MODIFY] onboarding_screen.dart
- [MODIFY] product_tour_screen.dart

Steps:

1. Each slide: on tablet use Row instead of Column
   - Left 40%: hero icon / image
   - Right 60%: title, subtitle, feature points, CTA
2. Adjust font sizes: isTablet ? 32 : 28 for titles

---

### Phase 9 - Bottom Sheets (Sweep Pass)

After all screens done, sweep through and ensure all showModalBottomSheet calls use:
constraints: Breakpoints.isTablet(context) ? const BoxConstraints(maxWidth: 600) : null

---

## 6. Standard Code Patterns

### Pattern A: Center-constrained screen

`dart
body: Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: Breakpoints.isTablet(context) ? 640 : double.infinity,
    ),
    child: existingContent,
  ),
)
`

### Pattern B: Adaptive layout switch

`dart
body: LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= Breakpoints.tablet) {
      return _buildTabletLayout();
    }
    return _buildMobileLayout();
  },
)
`

### Pattern C: NavigationRail shell

`dart
Widget build(BuildContext context) {
  final isTablet = Breakpoints.isTablet(context);
  final isDesktop = Breakpoints.isDesktop(context);
  if (isTablet) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isDesktop,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (i) => navigationShell.goBranch(i),
            destinations: [...],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
  return Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(...),
  );
}
`

---

## 7. Verification Checklist

- [ ] NavigationRail visible on tablet, hidden on mobile
- [ ] Auth forms max-width 480dp centered
- [ ] Dashboard subscription cards in 2-col grid on tablet
- [ ] Insights charts larger on tablet, side-by-side layout
- [ ] Settings 2-col tile grid on tablet
- [ ] Subscription form 2-col field pairs on tablet
- [ ] Onboarding side-by-side on tablet
- [ ] All bottom sheets max-width 600dp on tablet
- [ ] No RenderFlex overflows on any screen at any breakpoint
- [ ] Landscape orientation works on all screens
- [ ] Dark mode + tablet layout combinations tested

---

## 8. Priority Order

| Phase                   | Priority | Effort | Impact                         |
| ----------------------- | -------- | ------ | ------------------------------ |
| 1. Foundation + Nav     | CRITICAL | Medium | All screens get proper nav     |
| 2. Auth Forms           | High     | Low    | Polished first impressions     |
| 3. Dashboard            | CRITICAL | High   | Core screen of app             |
| 4. Insights             | High     | Medium | Data-heavy charts benefit most |
| 5. Settings             | Medium   | Low    | Administrative screens         |
| 6. Subscription Screens | High     | Medium | Core user flows                |
| 7. Payment Methods      | Medium   | Low    | Already carousel-based         |
| 8. Onboarding           | Medium   | Low    | One-time UX                    |
| 9. Sheet Sweep          | Low      | Low    | Polish pass                    |

**Total files to touch: ~30**
**Estimated effort: 4-6 implementation sessions**
