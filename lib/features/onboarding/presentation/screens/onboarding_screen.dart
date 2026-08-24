import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/onboarding_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Primary Onboarding Screen introducing SubGuard value propositions
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      title: 'Master Your Subscriptions',
      subtitle: 'Track Netflix, Spotify, gym memberships, and cloud tools in one organized dashboard.',
      icon: Icons.subscriptions_rounded,
      accentColor: AppColors.primary,
      heroBadge: 'ZERO CHAOS',
      highlightPoints: [
        'Total monthly & annual spend at a glance',
        'Custom billing cycles (Monthly, Yearly, Weekly)',
        'Automatic next payment date math',
      ],
    ),
    OnboardingSlideData(
      title: 'Smart Renewal Shield',
      subtitle: 'Get notified 1, 3, or 7 days before you get charged. Cancel free trials before they auto-renew.',
      icon: Icons.shield_outlined,
      accentColor: Colors.amber.shade800,
      heroBadge: 'NEVER OVERPAY',
      highlightPoints: [
        'Timezone-accurate exact alarm notifications',
        'Direct one-tap cancellation links',
        'Visual trial expiration countdowns',
      ],
    ),
    OnboardingSlideData(
      title: 'Visual Spending Insights',
      subtitle: 'See where your money goes with category breakdowns, spending trends, and top cost rankings.',
      icon: Icons.pie_chart_outline_rounded,
      accentColor: Colors.purple,
      heroBadge: 'FINANCIAL CLARITY',
      highlightPoints: [
        'Interactive spending charts & category curves',
        'Identify duplicate or unused subscriptions',
        'Filter spending over 1M, 3M, 6M, or 1 Year',
      ],
    ),
    OnboardingSlideData(
      title: 'Private, Secure & Exportable',
      subtitle: 'Local-first database with Face ID lock, Cloud backup, and standard CSV data export.',
      icon: Icons.lock_outline_rounded,
      accentColor: Colors.teal,
      heroBadge: 'YOU OWN YOUR DATA',
      highlightPoints: [
        'Biometric lock with 15s grace period',
        'Zero tracking or ad networks',
        'Export entire portfolio to CSV anytime',
      ],
    ),
  ];

  void _completeOnboarding({bool openLogin = false}) async {
    await ref.read(onboardingServiceProvider).setOnboardingCompleted();
    if (mounted) {
      if (openLogin) {
        context.go('/login');
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => _completeOnboarding(),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Slide Carousel
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero Icon with Gradient Background
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                slide.accentColor.withValues(alpha: 0.15),
                                slide.accentColor.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: slide.accentColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(slide.icon, size: 48, color: slide.accentColor),
                        ),
                        const SizedBox(height: 16),

                        // Hero Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: slide.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide.heroBadge,
                            style: TextStyle(
                              color: slide.accentColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Highlight Points Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: slide.highlightPoints.map((point) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: slide.accentColor, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        point,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isSelected = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Bottom Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Primary Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        isLastPage ? 'Get Started' : 'Continue',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Interactive Tour Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.explore_outlined, size: 20),
                      label: const Text(
                        'Take a Quick Interactive Tour',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      onPressed: () => context.push('/onboarding/tour'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class OnboardingSlideData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String heroBadge;
  final List<String> highlightPoints;

  OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.heroBadge,
    required this.highlightPoints,
  });
}
