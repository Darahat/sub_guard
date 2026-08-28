/// Notification entity
class NotificationEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? payload;
  final DateTime scheduledAt;
  final DateTime? deliveredAt;
  final bool isCancelled;
  final String? subscriptionId;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
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

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? body,
    String? payload,
    DateTime? scheduledAt,
    DateTime? deliveredAt,
    bool? isCancelled,
    String? subscriptionId,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      payload: payload ?? this.payload,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      isCancelled: isCancelled ?? this.isCancelled,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
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
class NotificationSettingsEntity {
  final bool enabled;
  final List<int> defaultReminderDays;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool badgeEnabled;
  final String reminderTime;
  final DateTime? updatedAt;

  const NotificationSettingsEntity({
    this.enabled = true,
    this.defaultReminderDays = const [1, 7],
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.badgeEnabled = true,
    this.reminderTime = '09:00',
    this.updatedAt,
  });

  NotificationSettingsEntity copyWith({
    bool? enabled,
    List<int>? defaultReminderDays,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? badgeEnabled,
    String? reminderTime,
    DateTime? updatedAt,
  }) {
    return NotificationSettingsEntity(
      enabled: enabled ?? this.enabled,
      defaultReminderDays: defaultReminderDays ?? this.defaultReminderDays,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      badgeEnabled: badgeEnabled ?? this.badgeEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettingsEntity &&
          runtimeType == other.runtimeType &&
          enabled == other.enabled &&
          soundEnabled == other.soundEnabled;

  @override
  int get hashCode => enabled.hashCode ^ soundEnabled.hashCode;
}
