import 'package:flutter/material.dart';

import '../../subscriptions/domain/entities/subscription_entity.dart';
import 'billing_platform.dart';
import 'cancellation_guide.dart';

class PresetService {
  final String id;
  final String name;
  final List<String> aliases;
  final String category;
  final double suggestedAmount;
  final String suggestedCurrency;
  final BillingCycle defaultBillingCycle;
  final Color brandColor;
  final String? logoAsset;
  final String? websiteUrl;
  final List<BillingPlatform> supportedPlatforms;
  final CancellationGuide cancellationGuide;

  const PresetService({
    required this.id,
    required this.name,
    this.aliases = const [],
    required this.category,
    this.suggestedAmount = 0.0,
    this.suggestedCurrency = 'USD',
    this.defaultBillingCycle = BillingCycle.monthly,
    required this.brandColor,
    this.logoAsset,
    this.websiteUrl,
    this.supportedPlatforms = const [
      BillingPlatform.web,
      BillingPlatform.googlePlay,
      BillingPlatform.apple,
    ],
    required this.cancellationGuide,
  });
}
