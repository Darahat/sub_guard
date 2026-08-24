import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
          'Tap the "+" floating button on your dashboard to add any recurring charge. '
          'Select your billing cycle (Monthly, Yearly, Weekly, Daily, or Quarterly), '
          'set the renewal date, and assign a category like Entertainment, SaaS, or Utilities.',
      badgeText: 'Core Activity #1',
      icon: Icons.add_circle_outline,
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
      badgeText: 'Core Activity #2',
      icon: Icons.alarm_on_outlined,
      iconColor: Colors.amber.shade700,
      featuresList: [
        'Timezone-aware exact notification alarms',
        '3 Dedicated Android Notification Channels',
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
          'category breakdowns via interactive pie charts, and a ranking of your top 5 most expensive subscriptions.',
      badgeText: 'Core Activity #3',
      icon: Icons.insights_outlined,
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
          'Your data is saved instantly on your device via high-speed Isar Database. '
          'When you log in, changes automatically sync with Cloud Firestore. '
          'You can also export your full portfolio as an RFC 4180 CSV file at any time.',
      badgeText: 'Core Activity #4',
      icon: Icons.cloud_sync_outlined,
      iconColor: Colors.teal,
      featuresList: [
        'Zero-latency offline first architecture',
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
      badgeText: 'Core Activity #5',
      icon: Icons.fingerprint,
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
    await ref.read(onboardingServiceProvider).setOnboardingCompleted();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _steps.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Interactive App Tour (${_currentStep + 1}/${_steps.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: _finishTour,
            child: const Text('Skip Tour', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Linear Progress Indicator
            LinearProgressIndicator(
              value: (_currentStep + 1) / _steps.length,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
            const SizedBox(height: 16),

            // Main Content Area
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                itemBuilder: (context, index) {
                  final data = _steps[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge & Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: data.iconColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data.badgeText,
                                style: TextStyle(
                                  color: data.iconColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: data.iconColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(data.icon, color: data.iconColor, size: 28),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title & Subtitle
                        Text(
                          data.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description Text
                        Text(
                          data.description,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Interactive Simulated Card Preview
                        _buildInteractiveCardPreview(data.interactiveDemoType),
                        const SizedBox(height: 20),

                        // Highlights Checklist
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KEY CAPABILITIES',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...data.featuresList.map(
                                (feature) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Back'),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () {
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
                        isLastStep ? 'Start Using SubGuard' : 'Next Step (${_currentStep + 2}/${_steps.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveCardPreview(TourDemoType type) {
    switch (type) {
      case TourDemoType.addSubscription:
        return _buildDemoCard(
          title: 'Sample Subscription Card',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Netflix Premium', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('Next billing: Sept 15, 2026', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                const Text('\$19.99/mo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        );

      case TourDemoType.notifications:
        return _buildDemoCard(
          title: 'Upcoming Renewal Alert Preview',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.amber, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Renewal in 3 Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.brown)),
                      Text('Spotify (\$10.99) will renew on Sept 20', style: TextStyle(fontSize: 12, color: Colors.brown)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

      case TourDemoType.insights:
        return _buildDemoCard(
          title: 'Spending Breakdown Preview',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniInsightStat('Monthly', '\$124.50', Colors.blue),
                _buildMiniInsightStat('Annual', '\$1,494.00', Colors.purple),
                _buildMiniInsightStat('Active', '8 Services', Colors.green),
              ],
            ),
          ),
        );

      case TourDemoType.cloudSync:
        return _buildDemoCard(
          title: 'Data Portability Options',
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.cloud_done, color: Colors.blue),
                      SizedBox(height: 4),
                      Text('Cloud Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Auto Backup', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.file_download, color: Colors.teal),
                      SizedBox(height: 4),
                      Text('CSV Export', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Universal Backup', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

      case TourDemoType.biometrics:
        return _buildDemoCard(
          title: 'Security Gate Preview',
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Biometric App Lock Enabled (15s timeout)',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                Icon(Icons.fingerprint, color: AppColors.primary, size: 24),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildDemoCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  Widget _buildMiniInsightStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
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
  final IconData icon;
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
