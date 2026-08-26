import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> streamingPresets = [
  PresetService(
    id: 'netflix',
    name: 'Netflix',
    aliases: ['netflix standard', 'netflix premium', 'netflix basic'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 15.49,
    brandColor: const Color(0xFFE50914),
    websiteUrl: 'https://www.netflix.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.netflix.com/youraccount',
        steps: [
          'Log in to your Netflix account in a web browser.',
          'Under "Membership & Billing", select "Cancel Membership".',
          'Confirm cancellation on the prompt to stop renewal charges.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'disney_plus',
    name: 'Disney+',
    aliases: ['disney plus', 'disney+ trio bundle', 'disney bundle'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 13.99,
    brandColor: const Color(0xFF113CCF),
    websiteUrl: 'https://www.disneyplus.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.disneyplus.com/account',
        steps: [
          'Log in to your Disney+ account page on the web.',
          'Under "Subscription", select your active plan.',
          'Choose "Cancel Subscription" and confirm your reason.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'youtube_premium',
    name: 'YouTube Premium',
    aliases: ['youtube red', 'yt premium', 'youtube family'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 13.99,
    brandColor: const Color(0xFFFF0000),
    websiteUrl: 'https://www.youtube.com/premium',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.youtube.com/paid_memberships',
        steps: [
          'Go to YouTube Paid Memberships on your browser.',
          'Select "Manage Membership" next to your Premium plan.',
          'Click "Deactivate" (or "Cancel") and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'max_hbo',
    name: 'Max (HBO)',
    aliases: ['hbo max', 'hbo', 'max'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 15.99,
    brandColor: const Color(0xFF002BE7),
    websiteUrl: 'https://www.max.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://auth.max.com/subscription',
        steps: [
          'Sign in to your Max Account Settings.',
          'Select "Subscription" -> "Manage Subscription".',
          'Choose "Cancel Subscription" and follow instructions.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'amazon_prime_video',
    name: 'Amazon Prime',
    aliases: ['prime video', 'amazon prime video', 'prime'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 14.99,
    brandColor: const Color(0xFF00A8E1),
    websiteUrl: 'https://www.amazon.com/prime',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.amazon.com/mc/manage',
        steps: [
          'Go to Amazon "Manage Prime Membership" page.',
          'Select "Update, cancel and more" under Membership.',
          'Click "End membership" and confirm your choice.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'apple_tv_plus',
    name: 'Apple TV+',
    aliases: ['apple tv', 'apple tv plus'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF1C1C1E),
    websiteUrl: 'https://tv.apple.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://tv.apple.com/settings',
        steps: [
          'Go to Apple TV+ Settings in your browser or Apple device.',
          'Under Subscriptions, choose "Manage" next to Apple TV+.',
          'Click "Cancel Subscription" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'hulu',
    name: 'Hulu',
    aliases: ['hulu with ads', 'hulu no ads', 'hulu live tv'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 17.99,
    brandColor: const Color(0xFF1CE783),
    websiteUrl: 'https://www.hulu.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://secure.hulu.com/account',
        steps: [
          'Log in to your Hulu Account page.',
          'Under "Your Subscription", click "Cancel".',
          'Follow the on-screen prompts to confirm cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'paramount_plus',
    name: 'Paramount+',
    aliases: ['paramount plus', 'paramount', 'cbs all access'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 11.99,
    brandColor: const Color(0xFF0064FF),
    websiteUrl: 'https://www.paramountplus.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.paramountplus.com/account/',
        steps: [
          'Sign in to Paramount+ Account page on the web.',
          'Scroll down to "Subscription & Billing" section.',
          'Click "Cancel subscription" and follow prompts.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'peacock',
    name: 'Peacock',
    aliases: ['peacock premium', 'peacock tv'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 7.99,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://www.peacocktv.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.peacocktv.com/account/plans',
        steps: [
          'Go to Peacock Account -> Plans & Payment.',
          'Under Your Plan, choose "Change or Cancel Plan".',
          'Select "Cancel Plan" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'crunchyroll',
    name: 'Crunchyroll',
    aliases: ['crunchyroll fan', 'crunchyroll mega fan', 'funimation'],
    category: PresetCategories.videoStreaming,
    suggestedAmount: 7.99,
    brandColor: const Color(0xFFF47521),
    websiteUrl: 'https://www.crunchyroll.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.crunchyroll.com/account/membership',
        steps: [
          'Sign in to Crunchyroll and go to Account Settings.',
          'Under Membership Info, click "Cancel Membership".',
          'Confirm cancellation on the final page.',
        ],
      ),
    ),
  ),
];
