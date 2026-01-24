import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../entities/notification_entity.dart';

/// Repository interface for notifications
abstract class NotificationRepository {
  /// Get all notifications
  Future<Either<Failure, List<NotificationEntity>>> getAllNotifications();

  /// Get notifications by subscription ID
  Future<Either<Failure, List<NotificationEntity>>>
  getNotificationsBySubscriptionId(String subscriptionId);

  /// Get pending notifications
  Future<Either<Failure, List<NotificationEntity>>> getPendingNotifications();

  /// Schedule renewal reminder
  Future<Either<Failure, void>> scheduleRenewalReminder({
    required SubscriptionEntity subscription,
    required int daysBeforeRenewal,
  });

  /// Schedule trial ending reminder
  Future<Either<Failure, void>> scheduleTrialEndingReminder({
    required SubscriptionEntity subscription,
    required int daysBeforeEnd,
  });

  /// Cancel notification
  Future<Either<Failure, void>> cancelNotification(String notificationId);

  /// Cancel all notifications for a subscription
  Future<Either<Failure, void>> cancelNotificationsBySubscriptionId(
    String subscriptionId,
  );

  /// Get notification settings
  Future<Either<Failure, NotificationSettingsEntity>> getSettings();

  /// Update notification settings
  Future<Either<Failure, void>> updateSettings(
    NotificationSettingsEntity settings,
  );
}
