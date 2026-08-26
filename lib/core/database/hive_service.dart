import 'package:hive_ce_flutter/hive_flutter.dart';

import '../utils/logger.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  static const String subscriptionsBoxName = 'subscriptions_box';
  static const String usersBoxName = 'users_box';
  static const String notificationsBoxName = 'notifications_box';
  static const String settingsBoxName = 'settings_box';
  static const String paymentMethodsBoxName = 'payment_methods_box';

  late Box<String> _subscriptionsBox;
  late Box<String> _usersBox;
  late Box<String> _notificationsBox;
  late Box<String> _settingsBox;
  late Box<String> _paymentMethodsBox;

  Box<String> get subscriptionsBox => _subscriptionsBox;
  Box<String> get usersBox => _usersBox;
  Box<String> get notificationsBox => _notificationsBox;
  Box<String> get settingsBox => _settingsBox;
  Box<String> get paymentMethodsBox => _paymentMethodsBox;

  /// Initialize all Hive boxes
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      _subscriptionsBox = await Hive.openBox<String>(subscriptionsBoxName);
      _usersBox = await Hive.openBox<String>(usersBoxName);
      _notificationsBox = await Hive.openBox<String>(notificationsBoxName);
      _settingsBox = await Hive.openBox<String>(settingsBoxName);
      _paymentMethodsBox = await Hive.openBox<String>(paymentMethodsBoxName);
      logger.info('✅ Hive database and all boxes successfully initialized');
    } catch (e, stackTrace) {
      logger.error('❌ Failed to initialize Hive database: $e', stackTrace);
      rethrow;
    }
  }

  /// Clear all boxes
  Future<void> clearAll() async {
    try {
      await _subscriptionsBox.clear();
      await _usersBox.clear();
      await _notificationsBox.clear();
      await _settingsBox.clear();
      await _paymentMethodsBox.clear();
      logger.info('🧹 All Hive boxes cleared');
    } catch (e, stackTrace) {
      logger.error('❌ Failed to clear Hive boxes: $e', stackTrace);
      rethrow;
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    logger.info('Hive database closed');
  }
}

final hiveService = HiveService();
