import '../../domain/entities/notification_entity.dart';

/// Notification model for local storage
class NotificationModel {
  String notificationId;
  NotificationType type;
  String title;
  String body;
  String? payload;
  DateTime scheduledAt;
  DateTime? deliveredAt;
  bool isCancelled;
  String? subscriptionId;
  DateTime? createdAt;

  NotificationModel({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    required this.scheduledAt,
    this.deliveredAt,
    this.isCancelled = false,
    this.subscriptionId,
    this.createdAt,
  });

  /// Create from domain entity
  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      notificationId: entity.id,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      payload: entity.payload,
      scheduledAt: entity.scheduledAt,
      deliveredAt: entity.deliveredAt,
      isCancelled: entity.isCancelled,
      subscriptionId: entity.subscriptionId,
      createdAt: entity.createdAt ?? DateTime.now(),
    );
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

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'type': type.name,
      'title': title,
      'body': body,
      'payload': payload,
      'scheduledAt': scheduledAt.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'isCancelled': isCancelled,
      'subscriptionId': subscriptionId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create from JSON Map
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] as String? ?? json['id'] as String? ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.renewalReminder,
      ),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      payload: json['payload'] as String?,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : DateTime.now(),
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      isCancelled: json['isCancelled'] as bool? ?? false,
      subscriptionId: json['subscriptionId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

/// Notification settings model for local storage
class NotificationSettingsModel {
  bool enabled;
  List<int> defaultReminderDays;
  bool soundEnabled;
  bool vibrationEnabled;
  bool badgeEnabled;
  DateTime? updatedAt;

  NotificationSettingsModel({
    required this.enabled,
    required this.defaultReminderDays,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.badgeEnabled,
    this.updatedAt,
  });

  /// Create from domain entity
  factory NotificationSettingsModel.fromEntity(
    NotificationSettingsEntity entity,
  ) {
    return NotificationSettingsModel(
      enabled: entity.enabled,
      defaultReminderDays: entity.defaultReminderDays,
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      badgeEnabled: entity.badgeEnabled,
      updatedAt: entity.updatedAt ?? DateTime.now(),
    );
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
    return NotificationSettingsModel(
      enabled: true,
      defaultReminderDays: [1, 7],
      soundEnabled: true,
      vibrationEnabled: true,
      badgeEnabled: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'defaultReminderDays': defaultReminderDays,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'badgeEnabled': badgeEnabled,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON Map
  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      enabled: json['enabled'] as bool? ?? true,
      defaultReminderDays: (json['defaultReminderDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [1, 7],
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      badgeEnabled: json['badgeEnabled'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
