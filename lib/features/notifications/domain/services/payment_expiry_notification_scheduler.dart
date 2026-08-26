import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../payment_methods/domain/entities/payment_method_entity.dart';

/// Schedules advance-notice notifications before credit/debit card expiration
class PaymentExpiryNotificationScheduler {
  final NotificationService _notificationService;

  static const List<int> _reminderOffsets = [30, 7, 1];

  PaymentExpiryNotificationScheduler({NotificationService? notificationService})
    : _notificationService =
          notificationService ??
          NotificationService(FlutterLocalNotificationsPlugin());

  /// Schedules advance alarms for an expiring payment method
  Future<void> scheduleExpiryReminders(PaymentMethodEntity method) async {
    // 1. Cancel previous alarms
    await cancelExpiryReminders(method.id);

    if (!method.type.supportsExpiry) return;
    final exp = method.expirationDate;
    if (exp == null) return;

    final now = DateTime.now();
    final expiryDate = DateHelper.dateOnly(exp);

    // If already past expiry, skip
    if (DateHelper.dateOnly(now).isAfter(expiryDate)) return;

    for (final daysBefore in _reminderOffsets) {
      final reminderDate = expiryDate.subtract(Duration(days: daysBefore));
      // Schedule at 10:00 AM
      final targetDateTime = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        10,
        0,
      );

      if (targetDateTime.isBefore(now)) continue;

      final notificationId = _generatePaymentNotificationId(
        method.id,
        daysBefore,
      );

      final title = daysBefore == 1
          ? '🚨 Card Expires Tomorrow: ${method.name}'
          : '⚠️ Payment Card Expiring: ${method.name} ($daysBefore days left)';

      final body = daysBefore == 1
          ? 'Your ${method.displayLabel} expires tomorrow. Check and update your recurring subscriptions.'
          : 'Your ${method.displayLabel} will expire on ${method.formattedExpiry}. Review linked subscriptions in SubGuard.';

      try {
        await _notificationService.scheduleNotification(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: targetDateTime,
          channelId: AppConstants.renewalChannelId,
          payload: 'payment_shield:${method.id}',
        );
      } catch (_) {}
    }
  }

  /// Cancels all scheduled expiry alarms for a payment method
  Future<void> cancelExpiryReminders(String paymentMethodId) async {
    for (final daysBefore in _reminderOffsets) {
      final id = _generatePaymentNotificationId(paymentMethodId, daysBefore);
      try {
        await _notificationService.cancelNotification(id);
      } catch (_) {}
    }
  }

  /// Deterministically creates unique notification IDs for payment alerts
  int _generatePaymentNotificationId(String paymentMethodId, int daysBefore) {
    return (paymentMethodId.hashCode ^ (daysBefore + 88888)).abs() % 2147483647;
  }
}
