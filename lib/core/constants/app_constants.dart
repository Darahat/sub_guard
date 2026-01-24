class AppConstants {
  // App Info
  static const String appName = 'SubGuard';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Track, manage, and cancel subscriptions effortlessly';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String themeModeKey = 'theme_mode';

  // Notification Channels
  static const String renewalChannelId = 'renewal_notifications';
  static const String renewalChannelName = 'Renewal Notifications';
  static const String renewalChannelDescription =
      'Notifications for upcoming subscription renewals';

  static const String priceChangeChannelId = 'price_change_notifications';
  static const String priceChangeChannelName = 'Price Change Notifications';
  static const String priceChangeChannelDescription =
      'Notifications for subscription price changes';

  // Alert Days
  static const int sevenDayAlert = 7;
  static const int threeDayAlert = 3;
  static const int sameDayAlert = 0;

  // Free Tier Limits
  static const int freeSubscriptionLimit = 3;

  // Session
  static const int sessionTimeoutMinutes = 15;
  static const int maxLoginAttempts = 5;

  // Pagination
  static const int defaultPageSize = 20;

  // Currency
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';

  static const List<String> supportedCurrencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CAD',
    'AUD',
    'INR',
    'CNY',
  ];

  // Date Formats
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String displayDateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Billing Cycles
  static const String billingMonthly = 'monthly';
  static const String billingYearly = 'yearly';
  static const String billingTrial = 'trial';

  // Subscription Status
  static const String statusActive = 'active';
  static const String statusCancelled = 'cancelled';
  static const String statusTrial = 'trial';
  static const String statusExpired = 'expired';

  // Stripe
  static const String stripePublishableKeyTest = 'pk_test_YOUR_KEY_HERE';
  static const String stripePublishableKeyLive = 'pk_live_YOUR_KEY_HERE';

  // Pro Plan
  static const double proPlanMonthlyPrice = 6.99;
  static const double proPlanYearlyPrice = 59.99;
  static const int freeTrialDays = 7;

  // Support
  static const String supportEmail = 'support@subguard.app';
  static const String privacyPolicyUrl = 'https://subguard.app/privacy';
  static const String termsOfServiceUrl = 'https://subguard.app/terms';

  // Social Media (for future use)
  static const String twitterUrl = 'https://twitter.com/subguard';
  static const String redditUrl = 'https://reddit.com/r/subguard';
}
