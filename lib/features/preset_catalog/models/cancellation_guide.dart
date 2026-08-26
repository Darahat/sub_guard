import 'billing_platform.dart';
import 'cancellation_method.dart';

class CancellationGuide {
  final CancellationMethod? web;
  final CancellationMethod? googlePlay;
  final CancellationMethod? apple;
  final CancellationMethod? amazon;
  final DateTime lastVerified;

  const CancellationGuide({
    this.web,
    this.googlePlay = const CancellationMethod(
      actionUrl: 'https://play.google.com/store/account/subscriptions',
      steps: [
        'Open Google Play Store on your device (or visit play.google.com).',
        'Tap your Profile icon at the top right -> "Payments & Subscriptions".',
        'Select "Subscriptions" and choose the service.',
        'Tap "Cancel Subscription" and follow prompts to confirm.',
      ],
    ),
    this.apple = const CancellationMethod(
      actionUrl: 'https://apps.apple.com/account/subscriptions',
      steps: [
        'Open your device Settings -> Tap your Apple ID Profile at top.',
        'Tap "Subscriptions".',
        'Select the active subscription from the list.',
        'Tap "Cancel Subscription" (or "Cancel Free Trial") and confirm.',
      ],
    ),
    this.amazon,
    required this.lastVerified,
  });

  CancellationMethod? getMethod(BillingPlatform platform) {
    switch (platform) {
      case BillingPlatform.web:
        return web;
      case BillingPlatform.googlePlay:
        return googlePlay;
      case BillingPlatform.apple:
        return apple;
      case BillingPlatform.amazon:
        return amazon ?? web;
      default:
        return web ?? googlePlay ?? apple;
    }
  }
}
