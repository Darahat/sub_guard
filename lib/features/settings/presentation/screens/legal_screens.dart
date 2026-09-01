import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/layout/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About SubGuard')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Breakpoints.isTablet(context) ? 680 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Colors.deepPurple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset(
                          'assets/logos/icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: HeroIcon(
                                  HeroIcons.shieldCheck,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SubGuard',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'VERSION ${AppConstants.appVersion}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Know what will charge you before it happens. SubGuard is engineered to protect users from forgotten free-trial conversions and unexpected recurring charges. We prioritize privacy, speed, and notification reliability above all else.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.15),
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const HeroIcon(
                      HeroIcons.documentText,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Open Source Licenses',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const HeroIcon(
                    HeroIcons.chevronRight,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: 'SubGuard',
                    applicationVersion: AppConstants.appVersion,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Designed with ♥ in Flutter',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Breakpoints.isTablet(context) ? 720 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Text(
                  'Privacy First Architecture',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'SubGuard is built on local-first principles. We do not require or ask for your bank credentials, credit card numbers, or transaction statements.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildExpandablePolicyCard(
                title: '1. Data Collection',
                content:
                    'We only store subscription details you manually enter (service name, renewal date, amount, currency).',
              ),
              const SizedBox(height: 12),
              _buildExpandablePolicyCard(
                title: '2. Cloud Storage',
                content:
                    'If you create an account, your data is securely stored in encrypted Cloud Firestore tied to your private user ID.',
              ),
              const SizedBox(height: 12),
              _buildExpandablePolicyCard(
                title: '3. Third-Party Sharing',
                content:
                    'We never sell or share your subscription spending patterns to advertisers or third parties.',
              ),
              const SizedBox(height: 12),
              _buildExpandablePolicyCard(
                title: '4. Data Portability',
                content:
                    'You may export or delete your subscription data permanently at any time via the Settings menu.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandablePolicyCard({
    required String title,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.textSecondary,
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Breakpoints.isTablet(context) ? 720 : double.infinity,
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                child: Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(
                  'By using SubGuard, you agree to the following operational terms:',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildPolicyCard(
                title: '1. Information Accuracy',
                content:
                    'SubGuard is a self-managed reminder and tracking utility. Users are responsible for verifying their subscription dates. We are not liable for missed cancellations due to incorrect dates entered.',
              ),
              const SizedBox(height: 12),
              _buildPolicyCard(
                title: '2. Cancellation Responsibility',
                content:
                    'SubGuard provides guides and links to assist you, but the actual cancellation must be performed by you on the provider platform. We cannot cancel services on your behalf.',
              ),
              const SizedBox(height: 12),
              _buildPolicyCard(
                title: '3. Fair Use',
                content:
                    'The free tier includes tracking for up to 5 active subscriptions. Upgrading to Pro unlocks unlimited subscriptions and advanced tracking features.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
