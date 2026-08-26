import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

import 'hive_service.dart';

/// Provider for HiveService instance
final hiveServiceProvider = Provider<HiveService>((ref) {
  return hiveService;
});

/// Provider for Subscriptions Hive Box
final subscriptionsBoxProvider = Provider<Box<String>>((ref) {
  return ref.watch(hiveServiceProvider).subscriptionsBox;
});

/// Provider for Users Hive Box
final usersBoxProvider = Provider<Box<String>>((ref) {
  return ref.watch(hiveServiceProvider).usersBox;
});

/// Provider for Notifications Hive Box
final notificationsBoxProvider = Provider<Box<String>>((ref) {
  return ref.watch(hiveServiceProvider).notificationsBox;
});

/// Provider for Settings Hive Box
final settingsBoxProvider = Provider<Box<String>>((ref) {
  return ref.watch(hiveServiceProvider).settingsBox;
});

/// Provider for Payment Methods Hive Box
final paymentMethodsBoxProvider = Provider<Box<String>>((ref) {
  return ref.watch(hiveServiceProvider).paymentMethodsBox;
});
