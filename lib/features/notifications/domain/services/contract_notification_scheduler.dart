import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';

/// Service to manage advance-notice contractual cancellation deadline alerts
class ContractNotificationScheduler {
  final NotificationService _notificationService;

  static const List<int> _reminderOffsets = [30, 14, 7, 3, 0];

  ContractNotificationScheduler({NotificationService? notificationService})
    : _notificationService =
          notificationService ??
          NotificationService(FlutterLocalNotificationsPlugin());

  /// Schedules advance-notice alarms for subscriptions with active auto-renewing contracts
  Future<void> scheduleContractReminders(
    SubscriptionEntity subscription,
  ) async {
    // 1. Always clear any previous contract alarms for this subscription first
    await cancelContractReminders(subscription.id);

    final contract = subscription.contractCommitment;
    if (contract == null ||
        !contract.autoRenews ||
        subscription.status != SubscriptionStatus.active) {
      return;
    }

    final now = DateTime.now();
    final deadline = DateHelper.dateOnly(contract.cancellationDeadline);

    // If deadline has already passed, no advance notice to schedule
    if (DateHelper.dateOnly(now).isAfter(deadline)) {
      return;
    }

    for (final daysBefore in _reminderOffsets) {
      // Don't schedule a 30d reminder if the notice period itself was only 7 or 14 days
      if (daysBefore > contract.cancellationNoticeDays) continue;

      final reminderDate = deadline.subtract(Duration(days: daysBefore));
      // Target 9:00 AM on the reminder date
      final targetDateTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        9,
        0,
      );

      if (targetDateTime.isBefore(now)) continue;

      final notificationId = _generateContractNotificationId(
        subscription.id,
        daysBefore,
      );

      final title = daysBefore == 0
          ? '🚨 Cancellation Deadline Today: ${subscription.serviceName}'
          : '⚠️ Contract Notice ($daysBefore days left): ${subscription.serviceName}';

      final body = daysBefore == 0
          ? 'Today is your last day to cancel ${subscription.serviceName} before it auto-renews for another contract period.'
          : 'Your cancellation notice deadline is on ${DateHelper.formatDisplayDate(deadline)} ($daysBefore days away).';

      try {
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: targetDateTime,
          channelId: AppConstants.renewalChannelId,
          payload: 'contract_shield:${subscription.id}',
        );
      } catch (_) {
        // Handle notification scheduling errors gracefully
      }
    }
  }

  /// Cancels all scheduled contract alarms for a subscription
  Future<void> cancelContractReminders(String subscriptionId) async {
    for (final daysBefore in _reminderOffsets) {
      final id = _generateContractNotificationId(subscriptionId, daysBefore);
      try {
        await _notificationService.cancelNotification(id);
      } catch (_) {}
    }
  }

  /// Deterministically creates unique notification IDs for contract alerts
  int _generateContractNotificationId(String subscriptionId, int daysBefore) {
    return (subscriptionId.hashCode ^ (daysBefore + 9999)).abs() % 2147483647;
  }
}
