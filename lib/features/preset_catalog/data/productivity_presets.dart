import 'package:flutter/material.dart';

import '../models/cancellation_guide.dart';
import '../models/cancellation_method.dart';
import '../models/preset_service.dart';
import 'categories.dart';

final List<PresetService> productivityPresets = [
  PresetService(
    id: 'chatgpt_plus',
    name: 'ChatGPT Plus',
    aliases: ['chatgpt', 'openai', 'gpt plus', 'chat gpt'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 20.00,
    brandColor: const Color(0xFF10A37F),
    websiteUrl: 'https://chatgpt.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://chatgpt.com/#settings/Subscription',
        steps: [
          'Open ChatGPT and click your Profile avatar -> Settings.',
          'Select "Subscription" -> "Manage my subscription".',
          'In the account billing management portal, select "Cancel Plan".',
          'Follow the prompts to confirm your cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'claude_pro',
    name: 'Claude Pro',
    aliases: ['claude', 'anthropic', 'claude.ai'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 20.00,
    brandColor: const Color(0xFFD97757),
    websiteUrl: 'https://claude.ai',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://claude.ai/settings/billing',
        steps: [
          'Open Claude and go to Settings -> Billing.',
          'Under Subscription, click "Manage Subscription".',
          'Select "Cancel Plan" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'midjourney',
    name: 'Midjourney',
    aliases: ['midjourney basic', 'midjourney standard', 'midjourney pro'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 10.00,
    brandColor: const Color(0xFF000000),
    websiteUrl: 'https://www.midjourney.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.midjourney.com/account',
        steps: [
          'Sign in to your Midjourney account page with Discord/Google.',
          'Under Plan Details, select "Cancel Plan".',
          'Choose whether to cancel immediately or at end of billing period.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'perplexity_pro',
    name: 'Perplexity Pro',
    aliases: ['perplexity', 'perplexity ai'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 20.00,
    brandColor: const Color(0xFF1FB8CD),
    websiteUrl: 'https://www.perplexity.ai',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.perplexity.ai/settings/account',
        steps: [
          'Go to Perplexity Settings -> Account.',
          'Under Pro Subscription, select "Manage Subscription".',
          'Click "Cancel Subscription" and confirm.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'notion_plus',
    name: 'Notion Plus',
    aliases: ['notion', 'notion personal pro', 'notion workspace'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 10.00,
    brandColor: const Color(0xFF1C1C1E),
    websiteUrl: 'https://www.notion.so',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.notion.so/settings',
        steps: [
          'Open Notion Settings & Members -> Billing.',
          'Click "Change Plan" and select the Free plan.',
          'Confirm the downgrade to stop upcoming charges.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'microsoft_365',
    name: 'Microsoft 365',
    aliases: ['office 365', 'ms office', 'microsoft office', 'm365 personal'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 9.99,
    brandColor: const Color(0xFFD83B01),
    websiteUrl: 'https://www.microsoft.com/microsoft-365',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.microsoft.com/services',
        steps: [
          'Sign in to Microsoft Services & Subscriptions page.',
          'Find Microsoft 365 and click "Manage" -> "Cancel subscription".',
          'Follow the guided instructions to turn off recurring billing.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'canva_pro',
    name: 'Canva Pro',
    aliases: ['canva', 'canva for teams'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 12.99,
    brandColor: const Color(0xFF00C4CC),
    websiteUrl: 'https://www.canva.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://www.canva.com/settings/billing-and-plans',
        steps: [
          'Go to Canva Account Settings -> Billing & Plans.',
          'Click the options menu next to your plan -> "Cancel plan".',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
  PresetService(
    id: 'grammarly_premium',
    name: 'Grammarly Premium',
    aliases: ['grammarly', 'grammarly business'],
    category: PresetCategories.aiProductivity,
    suggestedAmount: 12.00,
    brandColor: const Color(0xFF15C39A),
    websiteUrl: 'https://www.grammarly.com',
    cancellationGuide: CancellationGuide(
      lastVerified: DateTime(2026, 8, 26),
      web: const CancellationMethod(
        actionUrl: 'https://account.grammarly.com/subscription',
        steps: [
          'Sign in to your Grammarly Account Subscription page.',
          'Click "Cancel Subscription" at the bottom of the page.',
          'Confirm cancellation.',
        ],
      ),
    ),
  ),
];
