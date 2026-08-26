import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> cloudPresets = [
  PresetService(
    id: 'icloud_plus',
    name: 'iCloud+ / Apple One',
    aliases: [
      'icloud',
      'apple one',
      'icloud 50gb',
      'icloud 200gb',
      'icloud 2tb',
    ],
    category: PresetCategories.cloudStorage,
    suggestedAmount: 2.99,
    brandColor: const Color(0xFF007AFF),
    websiteUrl: 'https://www.apple.com/icloud',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://support.apple.com/HT207594',
        steps: [
          'Open your iPhone/iPad Settings -> Tap your Profile at the top.',
          'Select "iCloud" -> "Manage Account Storage".',
          'Tap "Change Storage Plan" -> "Downgrade Options".',
          'Choose the Free 5GB plan and tap "Done" to prevent future renewals.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'google_one',
    name: 'Google One',
    aliases: ['google drive', 'google storage', 'google 100gb', 'google 2tb'],
    category: PresetCategories.cloudStorage,
    suggestedAmount: 1.99,
    brandColor: const Color(0xFF4285F4),
    websiteUrl: 'https://one.google.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://one.google.com/settings',
        steps: [
          'Go to Google One Settings page on web or app.',
          'Under Membership management, click "Cancel membership".',
          'Confirm cancellation to revert to default 15GB free tier.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'dropbox_plus',
    name: 'Dropbox Plus',
    aliases: ['dropbox', 'dropbox professional', 'dropbox essentials'],
    category: PresetCategories.cloudStorage,
    suggestedAmount: 11.99,
    brandColor: const Color(0xFF0061FF),
    websiteUrl: 'https://www.dropbox.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.dropbox.com/account/plan',
        steps: [
          'Sign in to Dropbox Account -> Plan tab.',
          'Scroll down and select "Cancel plan".',
          'Follow the step-by-step confirmation prompts.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'onedrive_standalone',
    name: 'OneDrive Standalone',
    aliases: ['onedrive', 'microsoft onedrive 100gb'],
    category: PresetCategories.cloudStorage,
    suggestedAmount: 1.99,
    brandColor: const Color(0xFF0078D4),
    websiteUrl: 'https://onedrive.live.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.microsoft.com/services',
        steps: [
          'Sign in to Microsoft Account Services.',
          'Locate your OneDrive storage subscription.',
          'Click "Manage" -> "Cancel subscription".',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'proton_unlimited',
    name: 'Proton Unlimited',
    aliases: ['proton', 'proton mail', 'proton drive', 'proton vpn'],
    category: PresetCategories.cloudStorage,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF6D4AFF),
    websiteUrl: 'https://proton.me',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.proton.me/u/0/mail/dashboard',
        steps: [
          'Log in to your Proton Account Dashboard.',
          'Select "Subscription" or "Billing" from the sidebar.',
          'Choose "Customize plan" and downgrade to Proton Free.',
        ],
      ),
    ),
  ),
];
