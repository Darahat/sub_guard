import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

/// Notification entity
@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required NotificationType type,
    required String title,
    required String body,
    String? payload,
    required DateTime scheduledAt,
    DateTime? deliveredAt,
    @Default(false) bool isCancelled,
    String? subscriptionId,
    DateTime? createdAt,
  }) = _NotificationEntity;
}

/// Notification type enum
enum NotificationType {
  renewalReminder,
  trialEnding,
  paymentFailed,
  priceChange,
  cancelled,
}

/// Notification settings entity
@freezed
class NotificationSettingsEntity with _$NotificationSettingsEntity {
  const factory NotificationSettingsEntity({
    @Default(true) bool enabled,
    @Default([1, 7]) List<int> defaultReminderDays,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(true) bool badgeEnabled,
    DateTime? updatedAt,
  }) = _NotificationSettingsEntity;
}
