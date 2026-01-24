import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Use case for scheduling renewal reminder
class ScheduleRenewalReminderUseCase {
  final NotificationRepository _repository;

  ScheduleRenewalReminderUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required SubscriptionEntity subscription,
    required int daysBeforeRenewal,
  }) {
    return _repository.scheduleRenewalReminder(
      subscription: subscription,
      daysBeforeRenewal: daysBeforeRenewal,
    );
  }
}

/// Use case for canceling notifications
class CancelNotificationUseCase {
  final NotificationRepository _repository;

  CancelNotificationUseCase(this._repository);

  Future<Either<Failure, void>> call(String notificationId) {
    return _repository.cancelNotification(notificationId);
  }
}

/// Use case for canceling notifications by subscription
class CancelNotificationsBySubscriptionUseCase {
  final NotificationRepository _repository;

  CancelNotificationsBySubscriptionUseCase(this._repository);

  Future<Either<Failure, void>> call(String subscriptionId) {
    return _repository.cancelNotificationsBySubscriptionId(subscriptionId);
  }
}

/// Use case for getting notification settings
class GetNotificationSettingsUseCase {
  final NotificationRepository _repository;

  GetNotificationSettingsUseCase(this._repository);

  Future<Either<Failure, NotificationSettingsEntity>> call() {
    return _repository.getSettings();
  }
}

/// Use case for updating notification settings
class UpdateNotificationSettingsUseCase {
  final NotificationRepository _repository;

  UpdateNotificationSettingsUseCase(this._repository);

  Future<Either<Failure, void>> call(NotificationSettingsEntity settings) {
    return _repository.updateSettings(settings);
  }
}
