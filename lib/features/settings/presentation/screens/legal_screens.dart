import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About SubGuard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.security_outlined,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SubGuard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Version 1.0.0 (MVP Build)',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Know what will charge you before it happens.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'SubGuard is engineered to protect users from forgotten free-trial conversions and unexpected recurring charges. We prioritize privacy, speed, and notification reliability above all else.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Open Source Licenses'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'SubGuard',
              applicationVersion: '1.0.0',
            ),
          ),
        ],
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
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy First Architecture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'SubGuard is built on local-first principles. We do not require or ask for your bank credentials, credit card numbers, or transaction statements.\n\n'
              '1. Data Collection: We only store subscription details you manually enter (service name, renewal date, amount, currency).\n\n'
              '2. Cloud Storage: If you create an account, your data is securely stored in encrypted Cloud Firestore tied to your private user ID.\n\n'
              '3. Third-Party Sharing: We never sell or share your subscription spending patterns.\n\n'
              '4. Data Portability: You may export or delete your subscription data at any time via Settings.',
              style: TextStyle(fontSize: 14, height: 1.6),
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
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms and Conditions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'By using SubGuard, you agree to the following terms:\n\n'
              '1. Information Accuracy: SubGuard is a self-managed reminder and tracking utility. Users are responsible for verifying their subscription dates.\n\n'
              '2. Cancellation Responsibility: SubGuard provides guides and links to assist you, but the actual cancellation must be performed by you on the provider platform.\n\n'
              '3. Fair Use: The free tier includes tracking for up to 5 active subscriptions.',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
