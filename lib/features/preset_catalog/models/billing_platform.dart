import 'package:flutter/material.dart';

enum BillingPlatform {
  web('Website', Icons.language, 'Subscribed directly via website/card'),
  googlePlay('Google Play', Icons.shop, 'Billed through Google Play Store'),
  apple(
    'Apple App Store',
    Icons.apple,
    'Billed through Apple ID / In-App Purchase',
  ),
  amazon(
    'Amazon Appstore',
    Icons.shopping_bag,
    'Billed through Amazon account',
  ),
  other(
    'Other Provider',
    Icons.more_horiz,
    'Billed through carrier or telecom partner',
  );

  final String label;
  final IconData icon;
  final String description;
  const BillingPlatform(this.label, this.icon, this.description);
}
