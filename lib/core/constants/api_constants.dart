class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://api.subguard.app/api';
  static const String developmentUrl = 'http://localhost:8000/api';

  // API Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String appleAuth = '/auth/apple';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Subscriptions
  static const String subscriptions = '/subscriptions';
  static String subscriptionById(String id) => '/subscriptions/$id';

  // Email
  static const String emailConnect = '/email/connect';
  static const String emailSync = '/email/sync';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsTest = '/notifications/test';

  // Insights
  static const String insightsMonthly = '/insights/monthly';
  static const String insightsYearly = '/insights/yearly';

  // Billing
  static const String billingSubscribe = '/billing/subscribe';
  static const String billingCancel = '/billing/cancel';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
