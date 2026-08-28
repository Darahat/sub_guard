import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/product_tour_screen.dart';
import '../../features/payment_methods/presentation/screens/payment_methods_screen.dart';
import '../../features/settings/presentation/screens/legal_screens.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscriptions/presentation/screens/add_edit_subscription_screen.dart';
import '../../features/subscriptions/presentation/screens/dashboard_screen.dart';
import '../../features/subscriptions/presentation/screens/subscription_detail_screen.dart';
import '../services/onboarding_service.dart';
import '../theme/app_colors.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String productTour = '/onboarding/tour';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String dashboard = '/dashboard';
  static const String subscriptions = '/subscriptions';
  static const String subscriptionDetail = '/subscriptions/:id';
  static const String addSubscription = '/subscriptions/add';
  static const String insights = '/insights';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String changePassword = '/profile/change-password';
  static const String notificationSettings = '/settings/notifications';
  static const String paymentMethods = '/payment-methods';
  static const String about = '/settings/about';
  static const String privacy = '/settings/privacy';
  static const String terms = '/settings/terms';

  static GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      // Splash / Initial Route
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding & Interactive Tour
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
        routes: [
          GoRoute(
            path: 'tour',
            name: 'productTour',
            builder: (context, state) => const ProductTourScreen(),
          ),
        ],
      ),

      // Auth Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) {
          final email = state.extra as String? ?? '';
          return VerifyEmailScreen(email: email);
        },
      ),

      // ---------------- Stateful Bottom Navigation Shell ----------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainBottomNavScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Subscriptions (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Insights & Spending Analytics
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: insights,
                name: 'insights',
                builder: (context, state) => const InsightsScreen(),
              ),
            ],
          ),

          // Branch 2: Settings & Data
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                name: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Subscriptions Sub-Routes
      GoRoute(path: '/subscriptions', redirect: (context, state) => dashboard),
      GoRoute(
        path: '/subscriptions/add',
        name: 'addSubscription',
        builder: (context, state) => const AddEditSubscriptionScreen(),
      ),
      GoRoute(
        path: '/subscriptions/edit/:id',
        name: 'editSubscription',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddEditSubscriptionScreen(subscriptionId: id);
        },
      ),
      GoRoute(
        path: '/subscriptions/:id',
        name: 'subscriptionDetail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubscriptionDetailScreen(subscriptionId: id);
        },
      ),

      GoRoute(
        path: paymentMethods,
        name: 'paymentMethods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),

      // Settings sub-routes
      GoRoute(
        path: '/settings/notifications',
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/about',
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/settings/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(),
      ),

      // Profile
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'change-password',
            name: 'changePassword',
            builder: (context, state) => const ChangePasswordScreen(),
          ),
        ],
      ),
    ],

    // Error handler
    errorBuilder: (context, state) =>
        ErrorScreen(error: state.error.toString()),

    // Redirect logic
    redirect: (context, state) {
      return null;
    },
  );
}

// Stateful Bottom Navigation Shell Scaffold
class MainBottomNavScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainBottomNavScaffold({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: HeroIcon(HeroIcons.rectangleStack, size: 22),
            selectedIcon: HeroIcon(
              HeroIcons.rectangleStack,
              style: HeroIconStyle.solid,
              size: 22,
            ),
            label: 'Subscriptions',
          ),
          NavigationDestination(
            icon: HeroIcon(HeroIcons.chartPie, size: 22),
            selectedIcon: HeroIcon(
              HeroIcons.chartPie,
              style: HeroIconStyle.solid,
              size: 22,
            ),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: HeroIcon(HeroIcons.cog6Tooth, size: 22),
            selectedIcon: HeroIcon(
              HeroIcons.cog6Tooth,
              style: HeroIconStyle.solid,
              size: 22,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Provider for router
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.router;
});

// Splash Screen with intelligent onboarding and auth routing
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
        HapticFeedback.lightImpact();
      }
    });
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    try {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted) return;

      final onboardingService = ref.read(onboardingServiceProvider);
      final hasCompleted = await onboardingService.hasCompletedOnboarding();

      if (!mounted) return;
      if (!hasCompleted) {
        context.go(AppRouter.onboarding);
      } else {
        context.go(AppRouter.dashboard);
      }
    } catch (_) {
      if (mounted) {
        context.go(AppRouter.dashboard);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            child: AnimatedScale(
              scale: _isVisible ? 1.0 : 0.85,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Centered App Icon with Subtle Elevation
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/logos/icon.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: const Center(
                            child: HeroIcon(
                              HeroIcons.shieldCheck,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Brand Title & Tagline
                  Text(
                    'SubGuard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Subscription & Free Trial Shield',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
