import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> educationNewsPresets = [
  PresetService(
    id: 'duolingo_super',
    name: 'Duolingo Super',
    aliases: ['duolingo', 'duolingo plus', 'duolingo max'],
    category: PresetCategories.educationNews,
    suggestedAmount: 12.99,
    brandColor: const Color(0xFF58CC02),
    websiteUrl: 'https://www.duolingo.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.duolingo.com/settings/super',
        steps: [
          'Go to Duolingo Settings -> Super Duolingo on web or app.',
          'Under Subscription management, click "Cancel Subscription".',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'masterclass',
    name: 'MasterClass',
    aliases: [
      'masterclass standard',
      'masterclass plus',
      'masterclass premium',
    ],
    category: PresetCategories.educationNews,
    suggestedAmount: 10.00, // $120/year billed annually
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://www.masterclass.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.masterclass.com/account/edit',
        steps: [
          'Sign in to MasterClass Account Settings.',
          'Under Subscription, click "Cancel".',
          'Follow the prompts to turn off automatic renewal.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'coursera_plus',
    name: 'Coursera Plus',
    aliases: ['coursera', 'coursera monthly'],
    category: PresetCategories.educationNews,
    suggestedAmount: 59.00,
    brandColor: const Color(0xFF0056D2),
    websiteUrl: 'https://www.coursera.org',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.coursera.org/my-purchases',
        steps: [
          'Log in to Coursera "My Purchases" page.',
          'Under "Manage Subscriptions", locate Coursera Plus.',
          'Click "Cancel Subscription" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'medium_membership',
    name: 'Medium Membership',
    aliases: ['medium', 'medium friend'],
    category: PresetCategories.educationNews,
    suggestedAmount: 5.00,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://medium.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://medium.com/me/settings/membership',
        steps: [
          'Go to Medium Settings -> Membership.',
          'Click "Manage membership" -> "Cancel membership".',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'nytimes_all_access',
    name: 'The New York Times',
    aliases: [
      'nyt',
      'new york times',
      'nyt games',
      'the athletic',
      'nyt cooking',
    ],
    category: PresetCategories.educationNews,
    suggestedAmount: 4.00,
    brandColor: const Color(0xFF121212),
    websiteUrl: 'https://www.nytimes.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.nytimes.com/subscription/cancel',
        steps: [
          'Log in to NYTimes Account Management / Subscription page.',
          'Click "Cancel subscription" under your active plan.',
          'Follow the self-service flow or confirm via online chat.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'wsj_digital',
    name: 'The Wall Street Journal',
    aliases: ['wsj', 'wall street journal', 'wsj digital'],
    category: PresetCategories.educationNews,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF002F6C),
    websiteUrl: 'https://www.wsj.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://customercenter.wsj.com/',
        steps: [
          'Go to Dow Jones / WSJ Customer Center.',
          'Under "Manage Subscription", select "Cancel Subscription".',
          'Complete the guided cancellation flow.',
        ],
      ),
    ),
  ),
];
