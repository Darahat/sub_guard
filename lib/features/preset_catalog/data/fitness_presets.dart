import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> fitnessPresets = [
  PresetService(
    id: 'strava',
    name: 'Strava Subscription',
    aliases: ['strava', 'strava premium', 'strava summit'],
    category: PresetCategories.healthFitness,
    suggestedAmount: 11.99,
    brandColor: const Color(0xFFFC4C02),
    websiteUrl: 'https://www.strava.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.strava.com/account',
        steps: [
          'Log in to Strava Account Settings on the web.',
          'Under "My Account" -> "Membership", select "Cancel Membership".',
          'Confirm cancellation to revert to free tier at end of cycle.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'headspace',
    name: 'Headspace',
    aliases: ['headspace plus', 'headspace meditation'],
    category: PresetCategories.healthFitness,
    suggestedAmount: 12.99,
    brandColor: const Color(0xFFF47D31),
    websiteUrl: 'https://www.headspace.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.headspace.com/subscription/manage',
        steps: [
          'Sign in to Headspace Account Management in browser.',
          'Under Subscription Details, select "Cancel subscription".',
          'Complete the cancellation survey and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'calm',
    name: 'Calm',
    aliases: ['calm premium', 'calm app'],
    category: PresetCategories.healthFitness,
    suggestedAmount: 14.99,
    brandColor: const Color(0xFF0080FF),
    websiteUrl: 'https://www.calm.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.calm.com/profile/manage-subscription',
        steps: [
          'Go to Calm Profile -> Manage Subscription.',
          'Select "Cancel Subscription" and follow the cancellation flow.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'myfitnesspal_premium',
    name: 'MyFitnessPal Premium',
    aliases: ['myfitnesspal', 'mfp premium'],
    category: PresetCategories.healthFitness,
    suggestedAmount: 19.99,
    brandColor: const Color(0xFF0066EE),
    websiteUrl: 'https://www.myfitnesspal.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.myfitnesspal.com/account/settings',
        steps: [
          'Log in to MyFitnessPal Account Settings on web.',
          'Under "Premium Features", select "Manage".',
          'Choose "Cancel Premium" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'whoop_membership',
    name: 'Whoop Membership',
    aliases: ['whoop', 'whoop 4.0'],
    category: PresetCategories.healthFitness,
    suggestedAmount: 30.00,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://www.whoop.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://app.whoop.com/membership',
        steps: [
          'Sign in to WHOOP Account Management portal.',
          'Under Membership & Billing, click "Cancel Membership".',
          'Confirm your cancellation choice.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'apple_fitness_plus',
    name: 'Apple Fitness+',
    aliases: ['apple fitness', 'fitness plus'],
    category: PresetCategories.healthFitness,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF2C2C2E),
    websiteUrl: 'https://www.apple.com/apple-fitness-plus/',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://apps.apple.com/account/subscriptions',
        steps: [
          'Open iPhone Settings -> Tap your Profile at top.',
          'Tap "Subscriptions" -> "Apple Fitness+".',
          'Tap "Cancel Subscription".',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'peloton_app',
    name: 'Peloton App',
    aliases: [
      'peloton',
      'peloton app one',
      'peloton app+',
      'peloton all-access',
    ],
    category: PresetCategories.healthFitness,
    suggestedAmount: 12.99,
    brandColor: const Color(0xFFDF1C25),
    websiteUrl: 'https://www.onepeloton.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://members.onepeloton.com/preferences/subscriptions',
        steps: [
          'Log in to Peloton Member Preferences.',
          'Under Subscriptions, click your active membership.',
          'Select "Cancel Subscription" and confirm.',
        ],
      ),
    ),
  ),
];
