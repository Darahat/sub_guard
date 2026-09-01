import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/services/onboarding_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Interactive walkthrough tour guiding users through all core activities and features
class ProductTourScreen extends ConsumerStatefulWidget {
  const ProductTourScreen({super.key});

  @override
  ConsumerState<ProductTourScreen> createState() => _ProductTourScreenState();
}

class _ProductTourScreenState extends ConsumerState<ProductTourScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<TourStepData> _steps = [
    TourStepData(
      stepNumber: 1,
      title: 'Adding Your Subscriptions',
      subtitle: 'Manual-First, Fast & Private',
      description:
          'Tap the "+" button on your dashboard to add any recurring charge. '
          'Select your billing cycle (Monthly, Yearly, Weekly, Daily, or Quarterly), '
          'set the renewal date, and assign a category like Entertainment, SaaS, or Utilities.',
      badgeText: 'CORE ACTIVITY #1',
      icon: HeroIcons.plusCircle,
      iconColor: AppColors.primary,
      featuresList: [
        'Multi-currency support (USD, EUR, GBP, etc.)',
        'Support for free trials with auto-calculating deadlines',
        'Direct cancellation URLs for one-tap service cancellation',
      ],
      interactiveDemoType: TourDemoType.addSubscription,
    ),
    TourStepData(
      stepNumber: 2,
      title: 'Smart Renewal Alarms',
      subtitle: 'Never Get Caught by Surprise Charges',
      description:
          'SubGuard automatically schedules timezone-accurate alarms before every billing date. '
          'You can customize alerts to trigger 1, 3, or 7 days prior to payment, '
          'giving you ample time to cancel free trials or renew knowingly.',
      badgeText: 'CORE ACTIVITY #2',
      icon: HeroIcons.bellAlert,
      iconColor: Colors.amber.shade700,
      featuresList: [
        'Timezone-aware exact notification alarms',
        'Dedicated Android Notification Channels',
        'Alarms automatically survive device reboots',
      ],
      interactiveDemoType: TourDemoType.notifications,
    ),
    TourStepData(
      stepNumber: 3,
      title: 'Expense Insights & Analytics',
      subtitle: 'Visual Financial Clarity',
      description:
          'Head over to the Insights tab to discover your monthly spending curve, '
          'category breakdowns via interactive charts, and a ranking of your top 5 most expensive subscriptions.',
      badgeText: 'CORE ACTIVITY #3',
      icon: HeroIcons.chartBar,
      iconColor: Colors.purple,
      featuresList: [
        'Dynamic monthly spending projections',
        'Interactive category distribution breakdown',
        'Filter analytics across 1M, 3M, 6M, 1Y, or All-Time',
      ],
      interactiveDemoType: TourDemoType.insights,
    ),
    TourStepData(
      stepNumber: 4,
      title: 'Cloud Sync & CSV Backups',
      subtitle: 'Local-First + Complete Portability',
      description:
          'Your data is saved instantly on your device via high-speed Hive Database. '
          'When you log in, changes automatically sync with Cloud Firestore. '
          'You can also export your full portfolio as an RFC 4180 CSV file at any time.',
      badgeText: 'CORE ACTIVITY #4',
      icon: HeroIcons.arrowPathRoundedSquare,
      iconColor: Colors.teal,
      featuresList: [
        'Zero-latency offline-first architecture',
        'Automatic LWW timestamp conflict resolution',
        'One-tap CSV export to Google Drive, Email, or Files',
      ],
      interactiveDemoType: TourDemoType.cloudSync,
    ),
    TourStepData(
      stepNumber: 5,
      title: 'Biometric Security & Privacy',
      subtitle: 'Your Finances Are Kept Safe',
      description:
          'Enable Face ID or Fingerprint Lock in Settings to safeguard your financial details. '
          'A smart 15-second background grace period keeps switching between apps smooth without unnecessary lockouts.',
      badgeText: 'CORE ACTIVITY #5',
      icon: HeroIcons.fingerPrint,
      iconColor: Colors.indigo,
      featuresList: [
        'Native Face ID & Android BiometricPrompt',
        'Secure preferences stored in hardware-backed storage',
        'Zero tracking or advertising SDKs',
      ],
      interactiveDemoType: TourDemoType.biometrics,
    ),
  ];

  void _finishTour() async {
    HapticFeedback.mediumImpact();
    await ref.read(onboardingServiceProvider).setOnboardingCompleted();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _steps.length - 1;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Interactive Tour (${_currentStep + 1}/${_steps.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _finishTour();
            },
            child: Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Breakpoints.isTablet(context) ? 600 : double.infinity,
            ),
            child: Column(
              children: [
                // Linear Progress Indicator
                LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  minHeight: 3,
                ),
                const SizedBox(height: 12),

                // Main Content Area with Parallax Animation
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _steps.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentStep = index);
                    },
                    itemBuilder: (context, index) {
                      final data = _steps[index];

                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double pageValue = index.toDouble();
                          if (_pageController.position.haveDimensions) {
                            pageValue =
                                _pageController.page ?? index.toDouble();
                          }
                          final double delta = (pageValue - index).clamp(
                            -1.0,
                            1.0,
                          );
                          final double translation = delta * 120.0;
                          final double opacity = (1 - delta.abs()).clamp(
                            0.0,
                            1.0,
                          );

                          return Transform.translate(
                            offset: Offset(translation, 0),
                            child: Opacity(opacity: opacity, child: child),
                          );
                        },
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),

                              // Header: Badge & Icon
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: data.iconColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      data.badgeText,
                                      style: TextStyle(
                                        color: data.iconColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: data.iconColor.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: HeroIcon(
                                      data.icon,
                                      color: data.iconColor,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Title & Subtitle
                              Text(
                                data.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data.subtitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: data.iconColor,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Description Text
                              Text(
                                data.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Interactive Simulated Card Preview
                              _buildInteractiveCardPreview(
                                data.interactiveDemoType,
                                theme,
                              ),
                              const SizedBox(height: 18),

                              // Highlights Checklist (Inset Grouped Style)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.dividerColor.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KEY CAPABILITIES',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textSecondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ...data.featuresList.map(
                                      (feature) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            HeroIcon(
                                              HeroIcons.checkCircle,
                                              color: AppColors.success,
                                              size: 16,
                                              style: HeroIconStyle.solid,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                feature,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation Controls
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: const Text('Back'),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (isLastStep) {
                                _finishTour();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              isLastStep
                                  ? 'Start Using SubGuard'
                                  : 'Next Step (${_currentStep + 2}/${_steps.length})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCardPreview(TourDemoType type, ThemeData theme) {
    switch (type) {
      case TourDemoType.addSubscription:
        return _buildDemoCard(
          title: 'SUBSCRIPTION CARD PREVIEW',
          theme: theme,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/logos/netflix.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Netflix Premium',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Next billing: Sept 15, 2026',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$19.99/mo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );

      case TourDemoType.notifications:
        return _buildDemoCard(
          title: 'UPCOMING RENEWAL ALERT PREVIEW',
          theme: theme,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: HeroIcon(
                    HeroIcons.bellAlert,
                    color: Colors.amber.shade800,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Renewal in 3 Days',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.amber.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Spotify (\$10.99) will renew on Sept 20',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case TourDemoType.insights:
        return _buildDemoCard(
          title: 'SPENDING BREAKDOWN PREVIEW',
          theme: theme,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniInsightStat('Monthly', '\$124.50', AppColors.primary),
                Container(
                  width: 1,
                  height: 28,
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
                _buildMiniInsightStat('Annual', '\$1,494.00', Colors.purple),
                Container(
                  width: 1,
                  height: 28,
                  color: theme.dividerColor.withValues(alpha: 0.12),
                ),
                _buildMiniInsightStat(
                  'Active',
                  '8 Services',
                  AppColors.success,
                ),
              ],
            ),
          ),
        );

      case TourDemoType.cloudSync:
        return _buildDemoCard(
          title: 'DATA PORTABILITY PREVIEW',
          theme: theme,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      HeroIcon(
                        HeroIcons.cloudArrowUp,
                        color: Colors.blue.shade700,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Cloud Sync',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      Text(
                        'Auto Backup',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      HeroIcon(
                        HeroIcons.arrowDownTray,
                        color: Colors.teal.shade700,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'CSV Export',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.teal.shade900,
                        ),
                      ),
                      Text(
                        'RFC 4180 Format',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      case TourDemoType.biometrics:
        return _buildDemoCard(
          title: 'SECURITY GATE PREVIEW',
          theme: theme,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const HeroIcon(
                    HeroIcons.lockClosed,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Biometric App Lock (15s grace period)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const HeroIcon(
                  HeroIcons.fingerPrint,
                  color: AppColors.primary,
                  size: 22,
                ),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildDemoCard({
    required String title,
    required ThemeData theme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildMiniInsightStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

enum TourDemoType {
  addSubscription,
  notifications,
  insights,
  cloudSync,
  biometrics,
}

class TourStepData {
  final int stepNumber;
  final String title;
  final String subtitle;
  final String description;
  final String badgeText;
  final HeroIcons icon;
  final Color iconColor;
  final List<String> featuresList;
  final TourDemoType interactiveDemoType;

  TourStepData({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.badgeText,
    required this.icon,
    required this.iconColor,
    required this.featuresList,
    required this.interactiveDemoType,
  });
}
