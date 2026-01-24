# Phase E: Notifications & Reminders - Implementation Plan

## Overview

Add local notifications to remind users about upcoming subscription renewals, trial endings, and important events.

## Notification Types

### 1. Renewal Reminders

- **1 Day Before**: "Your [Service] subscription renews tomorrow ($X.XX)"
- **1 Week Before**: "Your [Service] subscription renews in 7 days ($X.XX)"
- **Custom**: User-defined days before renewal

### 2. Trial Ending Reminders

- **3 Days Before**: "Your [Service] trial ends in 3 days"
- **1 Day Before**: "Your [Service] trial ends tomorrow"

### 3. Payment Failure Alerts

- "Payment failed for [Service]. Please update your payment method."

### 4. Price Change Notifications

- "[Service] price will change from $X to $Y starting [Date]"

### 5. Cancelled Subscription Reminders

- "Your [Service] subscription ends in 7 days (cancelled)"

## Architecture

### Domain Layer

```
entities/
  - notification_entity.dart (id, type, title, body, payload, scheduledAt, deliveredAt)
  - notification_settings_entity.dart (enabled, defaultReminderDays, soundEnabled)

repositories/
  - notification_repository.dart (schedule, cancel, getScheduled, markDelivered)

usecases/
  - schedule_renewal_reminder_usecase.dart
  - cancel_notification_usecase.dart
  - get_notification_settings_usecase.dart
  - update_notification_settings_usecase.dart
```

### Data Layer

```
datasources/
  - local_notification_datasource.dart (flutter_local_notifications wrapper)
  - notification_settings_datasource.dart (Isar storage)

models/
  - notification_model.dart (Isar collection)
  - notification_settings_model.dart (Isar collection)

repositories/
  - notification_repository_impl.dart
```

### Presentation Layer

```
providers/
  - notification_providers.dart
  - notification_notifier.dart

screens/
  - notification_settings_screen.dart
  - notification_history_screen.dart

widgets/
  - notification_tile.dart
  - reminder_time_picker.dart
```

## Implementation Steps

### Step 1: Dependencies & Setup

```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.9.4
```

**Platform Setup:**

- **Android**: Configure notification channels, icons
- **iOS**: Request permissions, configure sound/badges
- **Web**: Not supported (graceful degradation)

### Step 2: Notification Service

```dart
class NotificationService {
  // Initialize with timezone and platform configs
  Future<void> initialize();

  // Request permissions (iOS)
  Future<bool> requestPermissions();

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  });

  // Cancel notification
  Future<void> cancelNotification(int id);

  // Cancel all notifications
  Future<void> cancelAllNotifications();

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications();

  // Handle notification tap
  void onNotificationTap(String? payload);
}
```

### Step 3: Notification Models

```dart
@collection
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

  bool isCancelled = false;

  @Index()
  String? subscriptionId; // Related subscription

  DateTime? createdAt;
}

enum NotificationType {
  renewalReminder,
  trialEnding,
  paymentFailed,
  priceChange,
  cancelled,
}

@collection
class NotificationSettingsModel {
  Id id = Isar.autoIncrement;

  bool enabled = true;
  List<int> defaultReminderDays = [1, 7]; // Days before renewal
  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool badgeEnabled = true;

  DateTime? updatedAt;
}
```

### Step 4: Auto-Schedule Logic

```dart
// When adding/updating subscription:
if (subscription.status == SubscriptionStatus.active) {
  // Cancel existing notifications for this subscription
  await notificationRepository.cancelBySubscriptionId(subscription.id);

  // Schedule new notifications based on settings
  final settings = await notificationRepository.getSettings();

  for (final days in settings.defaultReminderDays) {
    final scheduledDate = subscription.renewalDate.subtract(Duration(days: days));

    if (scheduledDate.isAfter(DateTime.now())) {
      await notificationRepository.scheduleRenewalReminder(
        subscription: subscription,
        daysBeforeRenewal: days,
      );
    }
  }
}
```

### Step 5: Notification Settings UI

```dart
class NotificationSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Notification Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Enable Notifications'),
            value: settings.enabled,
            onChanged: (value) => ref.read(notificationNotifierProvider.notifier)
                .toggleNotifications(value),
          ),

          ListTile(
            title: Text('Reminder Times'),
            subtitle: Text('Get notified X days before renewal'),
            onTap: () => _showReminderTimePicker(context, ref),
          ),

          SwitchListTile(
            title: Text('Sound'),
            value: settings.soundEnabled,
            onChanged: (value) => ref.read(notificationNotifierProvider.notifier)
                .toggleSound(value),
          ),

          SwitchListTile(
            title: Text('Vibration'),
            value: settings.vibrationEnabled,
            onChanged: (value) => ref.read(notificationNotifierProvider.notifier)
                .toggleVibration(value),
          ),

          ListTile(
            title: Text('Notification History'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => context.push('/notifications/history'),
          ),
        ],
      ),
    );
  }
}
```

### Step 6: Integration with Subscriptions

```dart
// In SubscriptionNotifier:

Future<void> addSubscription(SubscriptionEntity subscription) async {
  // Add to repository
  final result = await _addSubscriptionUseCase(subscription);

  result.fold(
    (failure) => /* handle error */,
    (addedSubscription) {
      // Schedule notifications
      _scheduleNotificationsForSubscription(addedSubscription);
    },
  );
}

Future<void> _scheduleNotificationsForSubscription(
  SubscriptionEntity subscription,
) async {
  if (subscription.status != SubscriptionStatus.active) return;

  final settingsResult = await _getNotificationSettingsUseCase();

  settingsResult.fold(
    (failure) => /* handle error */,
    (settings) async {
      if (!settings.enabled) return;

      for (final days in settings.defaultReminderDays) {
        await _scheduleRenewalReminderUseCase(
          subscription: subscription,
          daysBeforeRenewal: days,
        );
      }
    },
  );
}
```

## Android Configuration

### android/app/src/main/res/drawable/app_icon.png

Create notification icon (white, transparent background)

### android/app/src/main/AndroidManifest.xml

```xml
<manifest>
  <application>
    <!-- Notification channel -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_channel_id"
      android:value="subscription_reminders" />

    <!-- Notification icon -->
    <meta-data
      android:name="com.google.firebase.messaging.default_notification_icon"
      android:resource="@drawable/app_icon" />
  </application>

  <!-- Permissions -->
  <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
  <uses-permission android:name="android.permission.VIBRATE" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
</manifest>
```

## iOS Configuration

### ios/Runner/Info.plist

```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

### Request Permissions

```dart
final bool? result = await flutterLocalNotificationsPlugin
  .resolvePlatformSpecificImplementation<
    IOSFlutterLocalNotificationsPlugin>()
  ?.requestPermissions(
    alert: true,
    badge: true,
    sound: true,
  );
```

## Testing Checklist

### Notification Scheduling

- [ ] Schedule notification 1 day before renewal
- [ ] Schedule notification 1 week before renewal
- [ ] Custom reminder days work correctly
- [ ] Notifications cancelled when subscription deleted
- [ ] Notifications updated when renewal date changes

### Notification Delivery

- [ ] Notifications appear at correct time
- [ ] Title and body text correct
- [ ] Tapping notification opens subscription detail
- [ ] Sound plays if enabled
- [ ] Vibration works if enabled

### Settings

- [ ] Toggle notifications on/off
- [ ] Change default reminder days
- [ ] Toggle sound on/off
- [ ] Toggle vibration on/off
- [ ] Settings persist across app restarts

### Edge Cases

- [ ] Notifications work after phone restart
- [ ] Timezone changes handled correctly
- [ ] Permission denied handled gracefully
- [ ] Notification history displays correctly
- [ ] Past notifications not scheduled

## Success Criteria

- ✅ Users receive timely renewal reminders
- ✅ Notifications respect user settings
- ✅ Tapping notification navigates to detail screen
- ✅ Settings UI is intuitive and functional
- ✅ Notifications work after app close
- ✅ Timezone-aware scheduling
- ✅ No duplicate notifications

## Timeline Estimate

- **Step 1**: Dependencies & Setup - 1 hour
- **Step 2**: Notification Service - 3 hours
- **Step 3**: Models & Storage - 2 hours
- **Step 4**: Auto-Schedule Logic - 2 hours
- **Step 5**: Settings UI - 3 hours
- **Step 6**: Integration - 2 hours
- **Testing**: 3 hours

**Total**: 16 hours

## Next Steps

1. Add dependencies to pubspec.yaml ✅
2. Create notification service
3. Build notification models
4. Implement auto-scheduling
5. Create settings screen
6. Integrate with subscriptions
7. Test on Android and iOS devices

---

**Status**: Planning Complete
**Blocking**: None
**Dependencies**: flutter_local_notifications, timezone
