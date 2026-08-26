import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> securityPresets = [
  PresetService(
    id: 'one_password',
    name: '1Password',
    aliases: ['1password individual', '1password families'],
    category: PresetCategories.securityVpn,
    suggestedAmount: 2.99,
    brandColor: const Color(0xFF0A85EA),
    websiteUrl: 'https://1password.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://my.1password.com/billing',
        steps: [
          'Sign in to 1Password web vault.',
          'Click your profile name in the top right -> "Billing".',
          'Select "Cancel Subscription" and confirm your password.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'nordvpn',
    name: 'NordVPN',
    aliases: ['nord vpn', 'nord security', 'nordpass'],
    category: PresetCategories.securityVpn,
    suggestedAmount: 12.99,
    brandColor: const Color(0xFF4687FF),
    websiteUrl: 'https://nordvpn.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://my.nordaccount.com/billing/my-subscriptions/',
        steps: [
          'Log in to your Nord Account Billing page.',
          'Under Subscriptions, click "Manage" next to Auto-Renewal.',
          'Select "Cancel auto-renewal" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'bitwarden_premium',
    name: 'Bitwarden Premium',
    aliases: ['bitwarden', 'bitwarden families'],
    category: PresetCategories.securityVpn,
    suggestedAmount: 0.83, // $10/year
    brandColor: const Color(0xFF175DDC),
    websiteUrl: 'https://bitwarden.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://vault.bitwarden.com/#/settings/subscription',
        steps: [
          'Log in to Bitwarden Web Vault -> Settings -> Subscription.',
          'Click "Cancel Subscription" at the bottom.',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'dashlane_premium',
    name: 'Dashlane Premium',
    aliases: ['dashlane', 'dashlane friends and family'],
    category: PresetCategories.securityVpn,
    suggestedAmount: 4.99,
    brandColor: const Color(0xFF0E3E3E),
    websiteUrl: 'https://www.dashlane.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://app.dashlane.com/settings/my-account',
        steps: [
          'Open Dashlane Web App -> My Account Settings.',
          'Under Subscription, select "Cancel subscription".',
          'Follow the prompts to turn off automatic renewal.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'surfshark',
    name: 'Surfshark VPN',
    aliases: ['surfshark', 'surfshark one'],
    category: PresetCategories.securityVpn,
    suggestedAmount: 12.95,
    brandColor: const Color(0xFF1CB0B8),
    websiteUrl: 'https://surfshark.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://my.surfshark.com/account/subscription',
        steps: [
          'Log in to Surfshark Account Dashboard.',
          'Under Subscription, locate auto-renewal settings.',
          'Choose "Turn off auto-renewal" or submit a cancellation request.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'expressvpn',
    name: 'ExpressVPN',
    aliases: ['express vpn'],
    category: PresetCategories.securityVpn,
    suggestedAmount: 12.95,
    brandColor: const Color(0xFFDA3A27),
    websiteUrl: 'https://www.expressvpn.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.expressvpn.com/my_account',
        steps: [
          'Sign in to ExpressVPN My Account page.',
          'Select "Manage Subscription Settings".',
          'Click "Turn off automatic renewal" and confirm.',
        ],
      ),
    ),
  ),
];
