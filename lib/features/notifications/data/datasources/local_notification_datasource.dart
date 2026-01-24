import 'package:isar/isar.dart';

import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

/// Local data source for notifications using Isar
abstract class LocalNotificationDataSource {
  /// Get all notifications
  Future<List<NotificationModel>> getAllNotifications();

  /// Get notifications by subscription ID
  Future<List<NotificationModel>> getNotificationsBySubscriptionId(
    String subscriptionId,
  );

  /// Get pending notifications (not delivered and not cancelled)
  Future<List<NotificationModel>> getPendingNotifications();

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(String notificationId);

  /// Add notification
  Future<void> addNotification(NotificationModel notification);

  /// Update notification
  Future<void> updateNotification(NotificationModel notification);

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Delete notifications by subscription ID
  Future<void> deleteNotificationsBySubscriptionId(String subscriptionId);

  /// Mark notification as delivered
  Future<void> markAsDelivered(String notificationId);

  /// Mark notification as cancelled
  Future<void> markAsCancelled(String notificationId);

  /// Get notification settings
  Future<NotificationSettingsModel> getSettings();

  /// Update notification settings
  Future<void> updateSettings(NotificationSettingsModel settings);
}

class LocalNotificationDataSourceImpl implements LocalNotificationDataSource {
  final Isar _isar;

  LocalNotificationDataSourceImpl(this._isar);

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      return await _isar.notificationModels.where().findAll();
    } catch (e) {
      throw CacheException('Failed to get notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsBySubscriptionId(
    String subscriptionId,
  ) async {
    try {
      return await _isar.notificationModels
          .filter()
          .subscriptionIdEqualTo(subscriptionId)
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get notifications by subscription: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getPendingNotifications() async {
    try {
      return await _isar.notificationModels
          .filter()
          .deliveredAtIsNull()
          .and()
          .isCancelledEqualTo(false)
          .findAll();
    } catch (e) {
      throw CacheException('Failed to get pending notifications: $e');
    }
  }

  @override
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      return await _isar.notificationModels
          .filter()
          .notificationIdEqualTo(notificationId)
          .findFirst();
    } catch (e) {
      throw CacheException('Failed to get notification by ID: $e');
    }
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.notificationModels.put(notification);
      });
    } catch (e) {
      throw CacheException('Failed to add notification: $e');
    }
  }

  @override
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.notificationModels.put(notification);
      });
    } catch (e) {
      throw CacheException('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _isar.writeTxn(() async {
        final notification = await _isar.notificationModels
            .filter()
            .notificationIdEqualTo(notificationId)
            .findFirst();

        if (notification != null) {
          await _isar.notificationModels.delete(notification.id);
        }
      });
    } catch (e) {
      throw CacheException('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> deleteNotificationsBySubscriptionId(
    String subscriptionId,
  ) async {
    try {
      await _isar.writeTxn(() async {
        final notifications = await _isar.notificationModels
            .filter()
            .subscriptionIdEqualTo(subscriptionId)
            .findAll();

        final ids = notifications.map((n) => n.id).toList();
        await _isar.notificationModels.deleteAll(ids);
      });
    } catch (e) {
      throw CacheException(
        'Failed to delete notifications by subscription: $e',
      );
    }
  }

  @override
  Future<void> markAsDelivered(String notificationId) async {
    try {
      await _isar.writeTxn(() async {
        final notification = await _isar.notificationModels
            .filter()
            .notificationIdEqualTo(notificationId)
            .findFirst();

        if (notification != null) {
          notification.deliveredAt = DateTime.now();
          await _isar.notificationModels.put(notification);
        }
      });
    } catch (e) {
      throw CacheException('Failed to mark notification as delivered: $e');
    }
  }

  @override
  Future<void> markAsCancelled(String notificationId) async {
    try {
      await _isar.writeTxn(() async {
        final notification = await _isar.notificationModels
            .filter()
            .notificationIdEqualTo(notificationId)
            .findFirst();

        if (notification != null) {
          notification.isCancelled = true;
          await _isar.notificationModels.put(notification);
        }
      });
    } catch (e) {
      throw CacheException('Failed to mark notification as cancelled: $e');
    }
  }

  @override
  Future<NotificationSettingsModel> getSettings() async {
    try {
      final settings = await _isar.notificationSettingsModels
          .where()
          .findFirst();

      // Return existing settings or create defaults
      return settings ?? NotificationSettingsModel.defaults();
    } catch (e) {
      throw CacheException('Failed to get notification settings: $e');
    }
  }

  @override
  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      settings.updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        // Delete old settings
        await _isar.notificationSettingsModels.clear();

        // Add new settings
        await _isar.notificationSettingsModels.put(settings);
      });
    } catch (e) {
      throw CacheException('Failed to update notification settings: $e');
    }
  }
}
