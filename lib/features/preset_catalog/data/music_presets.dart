import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> musicPresets = [
  PresetService(
    id: 'spotify',
    name: 'Spotify',
    aliases: [
      'spotify premium',
      'spotify duo',
      'spotify family',
      'spotify student',
    ],
    category: PresetCategories.musicAudio,
    suggestedAmount: 11.99,
    brandColor: const Color(0xFF1DB954),
    websiteUrl: 'https://www.spotify.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.spotify.com/account/subscription/',
        steps: [
          'Log in to Spotify Account overview on the web.',
          'Under "Your plan", tap "Change plan".',
          'Scroll down to "Cancel Spotify" -> "Cancel Premium" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'apple_music',
    name: 'Apple Music',
    aliases: ['apple music family', 'apple music student', 'apple music voice'],
    category: PresetCategories.musicAudio,
    suggestedAmount: 10.99,
    brandColor: const Color(0xFFFA243C),
    websiteUrl: 'https://music.apple.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://music.apple.com/account/settings',
        steps: [
          'Go to Apple Music Settings in web or Music app.',
          'Under Subscriptions, choose "Manage".',
          'Select "Cancel Subscription" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'audible',
    name: 'Audible',
    aliases: ['audible premium plus', 'audible plus', 'amazon audible'],
    category: PresetCategories.musicAudio,
    suggestedAmount: 14.95,
    brandColor: const Color(0xFFF7991C),
    websiteUrl: 'https://www.audible.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.audible.com/account/overview',
        steps: [
          'Go to Audible Account Details page in a browser.',
          'Under "Membership details", click "Cancel membership".',
          'Follow the prompts and confirm to keep your already downloaded audiobooks.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'youtube_music',
    name: 'YouTube Music',
    aliases: ['youtube music premium', 'yt music'],
    category: PresetCategories.musicAudio,
    suggestedAmount: 10.99,
    brandColor: const Color(0xFFFF0000),
    websiteUrl: 'https://music.youtube.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.youtube.com/paid_memberships',
        steps: [
          'Go to YouTube Music Settings -> Memberships.',
          'Tap "Manage" next to YouTube Music Premium.',
          'Select "Deactivate" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'tidal',
    name: 'Tidal',
    aliases: ['tidal hifi', 'tidal hifi plus', 'tidal individual'],
    category: PresetCategories.musicAudio,
    suggestedAmount: 10.99,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://tidal.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://my.tidal.com/account/subscription',
        steps: [
          'Log in to my.tidal.com on the web.',
          'Select "Subscription" -> "Cancel Subscription".',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'deezer',
    name: 'Deezer',
    aliases: ['deezer premium', 'deezer family'],
    category: PresetCategories.musicAudio,
    suggestedAmount: 11.99,
    brandColor: const Color(0xFFFEAA2D),
    websiteUrl: 'https://www.deezer.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.deezer.com/account/subscription',
        steps: [
          'Go to Account Settings on Deezer.',
          'Select "Manage my subscription" -> "Cancel my subscription".',
          'Choose a reason and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'amazon_music_unlimited',
    name: 'Amazon Music',
    aliases: ['amazon music unlimited', 'amazon music hd'],
    category: PresetCategories.musicAudio,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFF25D1DA),
    websiteUrl: 'https://music.amazon.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.amazon.com/music/settings',
        steps: [
          'Go to Amazon Music Settings in your browser.',
          'Under Amazon Music Unlimited, select "Cancel Subscription".',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
];
