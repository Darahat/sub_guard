import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> gamingPresets = [
  PresetService(
    id: 'xbox_game_pass',
    name: 'Xbox Game Pass',
    aliases: [
      'game pass ultimate',
      'pc game pass',
      'xbox live gold',
      'game pass',
    ],
    category: PresetCategories.gaming,
    suggestedAmount: 16.99,
    brandColor: const Color(0xFF107C10),
    websiteUrl: 'https://www.xbox.com/gamepass',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.microsoft.com/services',
        steps: [
          'Go to Microsoft Account Services page.',
          'Find Xbox Game Pass -> select "Manage".',
          'Click "Cancel subscription" -> "Turn off recurring billing".',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'playstation_plus',
    name: 'PlayStation Plus',
    aliases: [
      'ps plus',
      'psn',
      'ps plus essential',
      'ps plus extra',
      'ps plus premium',
    ],
    category: PresetCategories.gaming,
    suggestedAmount: 17.99,
    brandColor: const Color(0xFF003791),
    websiteUrl: 'https://www.playstation.com/ps-plus/',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.playstation.com/acct/management',
        steps: [
          'Sign in to PlayStation Account Management on web or PS console.',
          'Select "Subscription" from the left menu.',
          'Find PlayStation Plus and click "Cancel Auto-Renew".',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'nintendo_switch_online',
    name: 'Nintendo Switch Online',
    aliases: ['nso', 'nintendo online', 'switch online expansion pack'],
    category: PresetCategories.gaming,
    suggestedAmount: 3.99,
    brandColor: const Color(0xFFE60012),
    websiteUrl: 'https://www.nintendo.com/switch/online/',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://ec.nintendo.com/my/membership',
        steps: [
          'Go to Nintendo Account Shop Menu in browser.',
          'Select "Nintendo Switch Online" memberships.',
          'Click "Terminate Automatic Renewal" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'discord_nitro',
    name: 'Discord Nitro',
    aliases: ['nitro', 'nitro basic'],
    category: PresetCategories.gaming,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF5865F2),
    websiteUrl: 'https://discord.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://discord.com/app',
        steps: [
          'Open Discord and click User Settings (gear icon).',
          'Select "Subscriptions" from the left sidebar.',
          'Under Nitro, click "Cancel" and follow prompts to confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'ea_play',
    name: 'EA Play',
    aliases: ['ea play pro', 'origin access'],
    category: PresetCategories.gaming,
    suggestedAmount: 5.99,
    brandColor: const Color(0xFFFF4747),
    websiteUrl: 'https://www.ea.com/ea-play',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://myaccount.ea.com/cp-ui/subscription/index',
        steps: [
          'Log in to EA Account Billing portal.',
          'Select "EA Play" -> "Manage Subscription".',
          'Click "Cancel Membership" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'geforce_now',
    name: 'GeForce NOW',
    aliases: ['nvidia geforce now', 'gfn priority', 'gfn ultimate'],
    category: PresetCategories.gaming,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF76B900),
    websiteUrl: 'https://www.nvidia.com/geforce-now/',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.nvidia.com/account/edit-profile/',
        steps: [
          'Sign in to NVIDIA Account Dashboard.',
          'Under GeForce NOW, select "Manage Membership".',
          'Switch plan to "Free" to disable recurring billing.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'twitch_sub',
    name: 'Twitch Channel Sub',
    aliases: ['twitch', 'twitch turbo', 'twitch prime'],
    category: PresetCategories.gaming,
    suggestedAmount: 4.99,
    brandColor: const Color(0xFF9146FF),
    websiteUrl: 'https://www.twitch.tv',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.twitch.tv/subscriptions',
        steps: [
          'Go to Twitch Subscriptions management page.',
          'Click the gear icon next to the channel subscription.',
          'Select "Don\'t Renew Subscription" and choose a reason.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'x_premium',
    name: 'X Premium (Twitter)',
    aliases: ['twitter blue', 'x premium plus', 'x basic'],
    category: PresetCategories.gaming,
    suggestedAmount: 8.00,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://x.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://x.com/settings/premium',
        steps: [
          'Open X (Twitter) Settings -> Premium.',
          'Select "Manage Subscription" -> "Cancel Subscription".',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
];
