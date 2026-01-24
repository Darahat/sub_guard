import 'package:isar/isar.dart';

import '../../domain/entities/notification_entity.dart';

part 'notification_model.g.dart';

/// Notification model for Isar database
@Collection()
class NotificationModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String notificationId;

  @Enumerated(EnumType.name)
  late NotificationType type;

  late String title;
  late String body;
  String? payload;

  late DateTime scheduledAt;
  DateTime? deliveredAt;

  late bool isCancelled;

  @Index()
  String? subscriptionId;

  DateTime? createdAt;

  /// Empty constructor for Isar
  NotificationModel();

  /// Create from domain entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel()
      ..notificationId = entity.id
      ..type = entity.type
      ..title = entity.title
      ..body = entity.body
      ..payload = entity.payload
      ..scheduledAt = entity.scheduledAt
      ..deliveredAt = entity.deliveredAt
      ..isCancelled = entity.isCancelled
      ..subscriptionId = entity.subscriptionId
      ..createdAt = entity.createdAt ?? DateTime.now();
  }

  /// Convert to domain entity
  NotificationEntity toEntity() {
    return NotificationEntity(
      id: notificationId,
      type: type,
      title: title,
      body: body,
      payload: payload,
      scheduledAt: scheduledAt,
      deliveredAt: deliveredAt,
      isCancelled: isCancelled,
      subscriptionId: subscriptionId,
      createdAt: createdAt,
    );
  }
}

/// Notification settings model for Isar database
@Collection()
class NotificationSettingsModel {
  Id id = Isar.autoIncrement;

  late bool enabled;

  late List<int> defaultReminderDays;

  late bool soundEnabled;

  late bool vibrationEnabled;

  late bool badgeEnabled;

  DateTime? updatedAt;

  /// Empty constructor for Isar
  NotificationSettingsModel();

  /// Create from domain entity
  factory NotificationSettingsModel.fromEntity(
    NotificationSettingsEntity entity,
  ) {
    return NotificationSettingsModel()
      ..enabled = entity.enabled
      ..defaultReminderDays = entity.defaultReminderDays
      ..soundEnabled = entity.soundEnabled
      ..vibrationEnabled = entity.vibrationEnabled
      ..badgeEnabled = entity.badgeEnabled
      ..updatedAt = entity.updatedAt ?? DateTime.now();
  }

  /// Convert to domain entity
  NotificationSettingsEntity toEntity() {
    return NotificationSettingsEntity(
      enabled: enabled,
      defaultReminderDays: defaultReminderDays,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      badgeEnabled: badgeEnabled,
      updatedAt: updatedAt,
    );
  }

  /// Create default settings
  factory NotificationSettingsModel.defaults() {
    return NotificationSettingsModel()
      ..enabled = true
      ..defaultReminderDays = [1, 7]
      ..soundEnabled = true
      ..vibrationEnabled = true
      ..badgeEnabled = true
      ..updatedAt = DateTime.now();
  }
}
