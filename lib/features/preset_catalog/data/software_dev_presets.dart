import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> softwareDevPresets = [
  PresetService(
    id: 'github_copilot',
    name: 'GitHub Copilot',
    aliases: ['copilot', 'github copilot individual', 'github'],
    category: PresetCategories.softwareDev,
    suggestedAmount: 10.00,
    brandColor: const Color(0xFF24292F),
    websiteUrl: 'https://github.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://github.com/settings/billing/summary',
        steps: [
          'Go to GitHub Settings -> "Billing and plans".',
          'Under Add-ons / Copilot, click "Edit" -> "Cancel Copilot".',
          'Confirm cancellation to turn off recurring charges.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'cursor_pro',
    name: 'Cursor Pro',
    aliases: ['cursor', 'cursor ai', 'anysphere'],
    category: PresetCategories.softwareDev,
    suggestedAmount: 20.00,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://www.cursor.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.cursor.com/settings',
        steps: [
          'Log in to Cursor Settings on the web.',
          'Under Billing, select "Manage Subscription".',
          'Click "Cancel Plan" and follow the cancellation flow.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'adobe_creative_cloud',
    name: 'Adobe Creative Cloud',
    aliases: [
      'adobe',
      'photoshop',
      'illustrator',
      'premiere pro',
      'adobe all apps',
    ],
    category: PresetCategories.softwareDev,
    suggestedAmount: 54.99,
    brandColor: const Color(0xFFFF0000),
    websiteUrl: 'https://www.adobe.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.adobe.com/plans',
        steps: [
          'Sign in to your Adobe Account Plans page.',
          'Under your active plan, select "Manage plan".',
          'Choose "Cancel your plan" and follow prompts.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'figma_professional',
    name: 'Figma Professional',
    aliases: ['figma', 'figma org', 'figjam'],
    category: PresetCategories.softwareDev,
    suggestedAmount: 12.00,
    brandColor: const Color(0xFFF24E1E),
    websiteUrl: 'https://www.figma.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.figma.com/settings',
        steps: [
          'Open your Figma Team Settings -> Billing.',
          'Click "Change plan" or "Cancel plan".',
          'Select the Free Starter plan to downgrade.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'jetbrains_all_products',
    name: 'JetBrains All Products Pack',
    aliases: ['jetbrains', 'intellij idea', 'pycharm', 'webstorm'],
    category: PresetCategories.softwareDev,
    suggestedAmount: 28.90,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://www.jetbrains.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.jetbrains.com/',
        steps: [
          'Log in to JetBrains Account portal.',
          'Find your subscription and select "Cancel subscription".',
          'Confirm to keep your perpetual fallback license.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'setapp',
    name: 'Setapp',
    aliases: ['setapp mac', 'setapp power user'],
    category: PresetCategories.softwareDev,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF1E2837),
    websiteUrl: 'https://setapp.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://my.setapp.com/account',
        steps: [
          'Sign in to your Setapp Account page.',
          'Under Subscription overview, click "Cancel Subscription".',
          'Follow the instructions to finalize cancellation.',
        ],
      ),
    ),
  ),
];
