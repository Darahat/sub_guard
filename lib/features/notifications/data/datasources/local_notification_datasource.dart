import 'dart:convert';
import 'package:hive_ce/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/notification_model.dart';

/// Local data source for notifications using Hive
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
  final Box<String> notificationsBox;
  final Box<String> settingsBox;

  LocalNotificationDataSourceImpl({
    required this.notificationsBox,
    required this.settingsBox,
  });

  static const String _settingsKey = 'notification_settings_key';

  @override
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      return notificationsBox.values
          .map((str) => NotificationModel.fromJson(
              json.decode(str) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get notifications: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getNotificationsBySubscriptionId(
    String subscriptionId,
  ) async {
    try {
      final all = await getAllNotifications();
      return all.where((n) => n.subscriptionId == subscriptionId).toList();
    } catch (e) {
      throw CacheException('Failed to get notifications by subscription: $e');
    }
  }

  @override
  Future<List<NotificationModel>> getPendingNotifications() async {
    try {
      final all = await getAllNotifications();
      return all.where((n) => n.deliveredAt == null && !n.isCancelled).toList();
    } catch (e) {
      throw CacheException('Failed to get pending notifications: $e');
    }
  }

  @override
  Future<NotificationModel?> getNotificationById(String notificationId) async {
    try {
      final jsonStr = notificationsBox.get(notificationId);
      if (jsonStr == null) return null;
      return NotificationModel.fromJson(
          json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get notification by ID: $e');
    }
  }

  @override
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await notificationsBox.put(
        notification.notificationId,
        json.encode(notification.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to add notification: $e');
    }
  }

  @override
  Future<void> updateNotification(NotificationModel notification) async {
    try {
      await notificationsBox.put(
        notification.notificationId,
        json.encode(notification.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to update notification: $e');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationsBox.delete(notificationId);
    } catch (e) {
      throw CacheException('Failed to delete notification: $e');
    }
  }

  @override
  Future<void> deleteNotificationsBySubscriptionId(
    String subscriptionId,
  ) async {
    try {
      final all = await getAllNotifications();
      for (final n in all) {
        if (n.subscriptionId == subscriptionId) {
          await notificationsBox.delete(n.notificationId);
        }
      }
    } catch (e) {
      throw CacheException(
        'Failed to delete notifications by subscription: $e',
      );
    }
  }

  @override
  Future<void> markAsDelivered(String notificationId) async {
    try {
      final notification = await getNotificationById(notificationId);
      if (notification != null) {
        notification.deliveredAt = DateTime.now();
        await updateNotification(notification);
      }
    } catch (e) {
      throw CacheException('Failed to mark notification as delivered: $e');
    }
  }

  @override
  Future<void> markAsCancelled(String notificationId) async {
    try {
      final notification = await getNotificationById(notificationId);
      if (notification != null) {
        notification.isCancelled = true;
        await updateNotification(notification);
      }
    } catch (e) {
      throw CacheException('Failed to mark notification as cancelled: $e');
    }
  }

  @override
  Future<NotificationSettingsModel> getSettings() async {
    try {
      final jsonStr = settingsBox.get(_settingsKey);
      if (jsonStr == null) {
        final def = NotificationSettingsModel.defaults();
        await updateSettings(def);
        return def;
      }
      return NotificationSettingsModel.fromJson(
          json.decode(jsonStr) as Map<String, dynamic>);
    } catch (e) {
      throw CacheException('Failed to get notification settings: $e');
    }
  }

  @override
  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      settings.updatedAt = DateTime.now();
      await settingsBox.put(
        _settingsKey,
        json.encode(settings.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to update notification settings: $e');
    }
  }
}
