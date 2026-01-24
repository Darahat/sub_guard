import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/local_notification_datasource.dart';
import '../models/notification_model.dart';

/// Implementation of notification repository
class NotificationRepositoryImpl implements NotificationRepository {
  final LocalNotificationDataSource _localDataSource;
  final NotificationService _notificationService;
  final Uuid _uuid;

  NotificationRepositoryImpl(
    this._localDataSource,
    this._notificationService,
    this._uuid,
  );

  @override
  Future<Either<Failure, List<NotificationEntity>>>
  getAllNotifications() async {
    try {
      final models = await _localDataSource.getAllNotifications();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>>
  getNotificationsBySubscriptionId(String subscriptionId) async {
    try {
      final models = await _localDataSource.getNotificationsBySubscriptionId(
        subscriptionId,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<NotificationEntity>>>
  getPendingNotifications() async {
    try {
      final models = await _localDataSource.getPendingNotifications();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleRenewalReminder({
    required SubscriptionEntity subscription,
    required int daysBeforeRenewal,
  }) async {
    try {
      final notificationId = _uuid.v4();
      final scheduledDate = subscription.nextBillingDate.subtract(
        Duration(days: daysBeforeRenewal),
      );

      // Don't schedule if the date is in the past
      if (scheduledDate.isBefore(DateTime.now())) {
        return const Right(null);
      }

      // Create notification entity
      final notification = NotificationEntity(
        id: notificationId,
        type: NotificationType.renewalReminder,
        title: 'Subscription Renewal Reminder',
        body:
            '${subscription.serviceName} renews in $daysBeforeRenewal ${daysBeforeRenewal == 1 ? 'day' : 'days'} (${subscription.currency}${subscription.amount.toStringAsFixed(2)})',
        payload: subscription.id,
        scheduledAt: scheduledDate,
        subscriptionId: subscription.id,
        createdAt: DateTime.now(),
      );

      // Save to database
      final model = NotificationModel.fromEntity(notification);
      await _localDataSource.addNotification(model);

      // Schedule with notification service
      await _notificationService.scheduleNotification(
        id: notificationId.hashCode,
        title: notification.title,
        body: notification.body,
        scheduledDate: scheduledDate,
        payload: notification.payload,
        channelId: 'subscription_reminders',
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to schedule renewal reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> scheduleTrialEndingReminder({
    required SubscriptionEntity subscription,
    required int daysBeforeEnd,
  }) async {
    try {
      // For trial ending, use start date + trial period
      // This is a simplified implementation
      // In production, you'd have a trial end date in the subscription

      final notificationId = _uuid.v4();
      final scheduledDate = subscription.nextBillingDate.subtract(
        Duration(days: daysBeforeEnd),
      );

      if (scheduledDate.isBefore(DateTime.now())) {
        return const Right(null);
      }

      final notification = NotificationEntity(
        id: notificationId,
        type: NotificationType.trialEnding,
        title: 'Trial Ending Soon',
        body:
            'Your ${subscription.serviceName} trial ends in $daysBeforeEnd ${daysBeforeEnd == 1 ? 'day' : 'days'}',
        payload: subscription.id,
        scheduledAt: scheduledDate,
        subscriptionId: subscription.id,
        createdAt: DateTime.now(),
      );

      final model = NotificationModel.fromEntity(notification);
      await _localDataSource.addNotification(model);

      await _notificationService.scheduleNotification(
        id: notificationId.hashCode,
        title: notification.title,
        body: notification.body,
        scheduledDate: scheduledDate,
        payload: notification.payload,
        channelId: 'trial_reminders',
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to schedule trial reminder: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotification(
    String notificationId,
  ) async {
    try {
      // Cancel in notification service
      await _notificationService.cancelNotification(notificationId.hashCode);

      // Mark as cancelled in database
      await _localDataSource.markAsCancelled(notificationId);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to cancel notification: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelNotificationsBySubscriptionId(
    String subscriptionId,
  ) async {
    try {
      // Get all notifications for this subscription
      final notifications = await _localDataSource
          .getNotificationsBySubscriptionId(subscriptionId);

      // Cancel each one
      for (final notification in notifications) {
        await _notificationService.cancelNotification(
          notification.notificationId.hashCode,
        );
      }

      // Delete from database
      await _localDataSource.deleteNotificationsBySubscriptionId(
        subscriptionId,
      );

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
        CacheFailure('Failed to cancel notifications by subscription: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, NotificationSettingsEntity>> getSettings() async {
    try {
      final model = await _localDataSource.getSettings();
      return Right(model.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(
    NotificationSettingsEntity settings,
  ) async {
    try {
      final model = NotificationSettingsModel.fromEntity(settings);
      await _localDataSource.updateSettings(model);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
